#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.0.1
#       Created     :   2013/4/7
#       File name   :   MakeSerializedPackageList.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   複数のVHDLのソースコードを解析してパッケージの依存関係を
#                       調べて、ファイルをコンパイルする順番に並べたリストを作成
#                       するスクリプト.
#                       VHDL 言語としてアナライズしているわけでなく、たんなる文字
#                       列として処理していることに注意。
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2012,2013 Ichiro Kawazome
#       All rights reserved.
# 
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions
#       are met:
# 
#         1. Redistributions of source code must retain the above copyright
#            notice, this list of conditions and the following disclaimer.
# 
#         2. Redistributions in binary form must reproduce the above copyright
#            notice, this list of conditions and the following disclaimer in
#            the documentation and/or other materials provided with the
#            distribution.
# 
#       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#       A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
#       OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#       LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#       DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#       THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#       OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
#---------------------------------------------------------------------------------
require 'optparse'
require 'find'
require 'set'
class SerializedPackageList
  #-------------------------------------------------------------------------------
  # initialize    :
  #-------------------------------------------------------------------------------
  def initialize
    @program_name      = "MakeSerializedPackageList"
    @program_version   = "0.0.1"
    @program_id        = @program_name + " " + @program_version
    @path_list         = Array.new
    @file_name_list    = Array.new
    @use_entity_list   = Array.new
    @library_name      = "WORK"
    @verbose           = false
    @debug             = false
    @format            = '#{file_name}'
    @execute           = nil
    @output_file_name  = nil
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"                        ){|val| @verbose          = true}
      opt.on("--debug"                          ){|val| @debug            = true}
      opt.on("--library    LIBRARY_NAME"        ){|val| @library_name     = val }
      opt.on("--format     STRING"              ){|val| @format           = val }
      opt.on("--execute    STRING"              ){|val| @execute          = val }
      opt.on("--use_entity ENTITY(ARCHITECHURE)"){|val| @use_entity_list << val }
      opt.on("--output     FILE_NAME"           ){|val| @output_file_name = val }
    end
  end
  #-------------------------------------------------------------------------------
  # parse_options
  #-------------------------------------------------------------------------------
  def parse_options(argv)
    @path_list = @opt.parse(argv)
  end
  #-------------------------------------------------------------------------------
  # LibraryUnit   : ソースコードを読んだ時のユニット毎の依存関係を保持するクラス.
  #                 ここで言うユニットとは entity, architecture, package, 
  #                 package body のこと.
  #-------------------------------------------------------------------------------
  class LibraryUnit
    attr_reader :type, :name, :file_name, :use_unit_name_list
    def initialize(unit_type, unit_name, file_name, use_clause_list)
      @type               = unit_type
      @name               = unit_name.upcase
      @file_name          = file_name
      @use_unit_name_list = Hash.new
      use_clause_list.each do |use_clause|
        library_name = use_clause[:LibraryName].upcase
        if @use_unit_name_list[library_name] == nil
          @use_unit_name_list[library_name] = Set.new
        end
        if use_clause.key?(:PackageName) 
          @use_unit_name_list[library_name] << use_clause[:PackageName].upcase
        end
        if use_clause.key?(:EntityName) 
          @use_unit_name_list[library_name] << use_clause[:EntityName].upcase
        end
      end
    end
    def debug_print
      warn @name
      warn "  name      : " + @name.to_s      
      warn "  type      : " + @type.to_s 
      warn "  file_name : " + @file_name.to_s 
      warn "  use       : "
      @use_unit_name_list.each do |library_name, package_set|
        package_set.each do |package_name|
          warn "    - library : " + library_name.to_s
          warn "      package : " + package_name.to_s
        end
      end
    end
  end
  #-------------------------------------------------------------------------------
  # Entity        : ソースコードを読んだ時の Entity 記述を保持するクラス
  #-------------------------------------------------------------------------------
  class Entity < LibraryUnit
    def initialize(entity_name, file_name, use_clause_list)
      super(:Entity, entity_name, file_name, use_clause_list)
    end
  end
  #-------------------------------------------------------------------------------
  # Architecture  : ソースコードを読んだ時の Architecture 記述を保持するクラス
  #-------------------------------------------------------------------------------
  class Architecture < LibraryUnit
    attr_reader :arch_name
    def initialize(entity_name, arch_name, file_name, use_clause_list)
      super(:Architecture, entity_name, file_name, use_clause_list)
      @arch_name = arch_name.upcase
    end
  end
  #-------------------------------------------------------------------------------
  # Package       : ソースコードを読んだ時の Package 記述を保持するクラス
  #-------------------------------------------------------------------------------
  class Package < LibraryUnit
    def initialize(package_name, file_name, use_clause_list)
      super(:Package, package_name, file_name, use_clause_list)
    end
  end
  #-------------------------------------------------------------------------------
  # PackageBody   : ソースコードを読んだ時の Package body 記述を保持するクラス
  #-------------------------------------------------------------------------------
  class PackageBody < LibraryUnit
    def initialize(package_name, file_name, use_clause_list)
      super(:PackageBody, package_name, file_name, use_clause_list)
    end
  end
  #-------------------------------------------------------------------------------
  # analize_path : 与えられたパス名を解析し、ディレクトリならば再帰的に探索し、
  #                ファイルならば read_file を呼び出す.
  #                "."で始まるディレクトリは探索しない.
  #                "~"で終わるファイルは読まない.
  #-------------------------------------------------------------------------------
  def analize_path(path_name, library_name, unit_list)
    if File::ftype(path_name) == "directory"
      Dir::foreach(path_name) do |name|
        next if name =~ /^\./
        if path_name =~ /\/$/
          analize_path(path_name + name      , library_name, unit_list)
        else
          analize_path(path_name + "/" + name, library_name, unit_list)
        end
      end
    elsif path_name =~ /~$/
    else 
      read_file(path_name, library_name, unit_list)
    end
  end
  #-------------------------------------------------------------------------------
  # read_file  : VHDLソースファイルを読んで unit_list に格納する.
  #-------------------------------------------------------------------------------
  def read_file(file_name, library_name, unit_list)
    if @verbose 
      warn "analyze file : " + file_name
    end
    File.open(file_name) do |file|
      analize_file(file, file_name, library_name, unit_list)
    end
  end
  #-------------------------------------------------------------------------------
  # analize_file : VHDLソースコードを解析して unit_list に格納する.
  #-------------------------------------------------------------------------------
  def analize_file(file, file_name, library_name, unit_list)
    library_list   = Array.new
    use_list       = Array.new
    line_number    = 0
    unit_name     = nil
    unit_info     = nil
    #-----------------------------------------------------------------------------
    # ファイルから一行ずつ読み込む。
    #-----------------------------------------------------------------------------
    file.each_line do |o_line|
      line = o_line.encode("UTF-8", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?')
      #---------------------------------------------------------------------------
      # 行番号の更新
      #---------------------------------------------------------------------------
      line_number += 1
      #---------------------------------------------------------------------------
      # コメント、行頭の空白部分、行末文字を削除する。
      #---------------------------------------------------------------------------
      parse_line = String.new(line)
      parse_line.sub!(/--.*$/  ,'')
      parse_line.sub!(/^[\s]+/ ,'')
      parse_line.sub!(/[\n\r]$/,'')
      #---------------------------------------------------------------------------
      # library ライブラリ名; の解釈
      #---------------------------------------------------------------------------
      if (parse_line =~ /^library[\s]+([\w\s,]+);/i)
        library_list << $1.split(/\s*,\s*/)
        next;
      end
      #---------------------------------------------------------------------------
      # use ライブラリ名.パッケージ名.アイテム名; の解釈
      #---------------------------------------------------------------------------
      if (parse_line =~ /^use[\s]+([\w]+)\s*\.\s*([\w]+)\s*\.\s*([\w]+)[\s]*;/i)
        use_list << {:LibraryName => $1, :PackageName => $2, :ItemName => $3}
        next;
      end
      #---------------------------------------------------------------------------
      # use ライブラリ名.パッケージ名; の解釈
      #---------------------------------------------------------------------------
      if (parse_line =~ /^use[\s]+([\w]+)\s*\.\s*([\w]+)[\s]*;/i)
        use_list << {:LibraryName => $1, :PackageName => $2}
        next;
      end
      #---------------------------------------------------------------------------
      # end 処理
      #---------------------------------------------------------------------------
      if (unit_info != nil) and 
         (parse_line =~ /^end[\s]+([\w]+)/i)
        if ($1.upcase   == unit_name.upcase) or
           ($1.downcase == "entity"  and unit_info.type == :Entity ) or
           ($1.downcase == "package" and unit_info.type == :Package)
          unit_list << unit_info
          unit_name    = ""
          unit_info    = nil
          library_list = Array.new
          use_list     = Array.new
          next;
        end
      end
      #---------------------------------------------------------------------------
      # entity 宣言の開始
      #---------------------------------------------------------------------------
      if (parse_line =~ /^entity[\s]+([\w]+)[\s]+is/i)
        unit_name = $1
        unit_info = Entity.new(unit_name, file_name, use_list)
        next;
      end
      #---------------------------------------------------------------------------
      # architecture 宣言の開始
      #---------------------------------------------------------------------------
      if (parse_line =~ /^architecture[\s]+([\w]+)[\s]+of+[\s]+(\w+)[\s]+is/i)
        unit_name  = $1
        entity_name = $2
        use_list << {:LibraryName => library_name, :EntityName => entity_name}
        unit_info = Architecture.new(entity_name, unit_name, file_name, use_list)
        next;
      end
      #---------------------------------------------------------------------------
      # package 宣言の開始
      #---------------------------------------------------------------------------
      if (parse_line =~ /^package[\s]+([\w]+)[\s]+is/i)
        unit_name = $1
        unit_info = Package.new(unit_name, file_name, use_list)
        next;
      end
      #---------------------------------------------------------------------------
      # package body 宣言の開始
      #---------------------------------------------------------------------------
      if (parse_line =~ /^package[\s]+body[\s]+([\w]+)[\s]+is/i)
        unit_name = $1
        use_list << {:LibraryName => library_name, :PackageName => unit_name}
        unit_info = PackageBody.new(unit_name, file_name, use_list)
        next;
      end
    end
  end 
  #-------------------------------------------------------------------------------
  # UnitFile      : ソースコードを読んだ時のファイル毎の依存関係を保持するクラス
  #-------------------------------------------------------------------------------
  class UnitFile
    attr_reader   :file_name, :library_name
    attr_accessor :level, :unit_name_list, :use_name_list, :use_list, :be_used_list
    def initialize(file_name, library_name)
      @file_name      = file_name
      @library_name   = library_name
      @unit_name_list = Set.new
      @use_name_list  = Set.new
      @use_list       = Set.new
      @be_used_list   = Set.new
      @level          = 0
    end
    def add_use_name_list(use_name_list)
      use_name_list.each do |library_name, package_list|
        if (library_name.upcase == @library_name.upcase)
           @use_name_list = @use_name_list + package_list
        end
      end
    end
    def debug_print
      warn "- file_name : " + @file_name
      warn "  level     : " + @level.to_s
      @unit_name_list.each do |unit_name|
        warn "  - unit  : " + unit_name
      end
      @use_name_list.each   do |use_name|
        warn "  - use   : " + use_name
      end
      @use_list.each   do |use|
        warn "  - use!  : " + use.file_name
      end
      @be_used_list.each   do |use|
        warn "  - used! : " + use.file_name
      end
    end
    def set_level(level,checked_list)
      if level > @level
        @level = level
        @use_list.each do |use|
          next if checked_list.member?(use)
          use.set_level(level+1, checked_list << self)
        end
      end
    end
    def <=> (target)
      if    @level > target.level then return -1
      elsif @level < target.level then return  1
      else return @file_name <=> target.file_name
      end
    end
    def to_formatted_string(format)
      file_name    = @file_name
      library_name = @library_name
      return eval('"' + format + '"')
    end
  end
  #-------------------------------------------------------------------------------
  # generate_unit_file_list : unit_list を元にファイル間の依存関係順に整列した 
  #                           unit_file_listを生成する.
  #-------------------------------------------------------------------------------
  def generate_unit_file_list(unit_list, use_entity_dict)
    unit_file_list    = Array.new
    defined_unit_file = Hash.new
    defined_unit_name = Hash.new
    #-----------------------------------------------------------------------------
    # unit_list から unit_file_list の雛型を作る.
    #-----------------------------------------------------------------------------
    unit_list.each do |unit|
      next if (unit.type == :Architecture) and
              (use_entity_dict.key?(unit.name) == true) and
              (use_entity_dict[unit.name] != unit.arch_name)
      if defined_unit_file.key?(unit.file_name)
        unit_file = defined_unit_file[unit.file_name]
      else
        unit_file = UnitFile.new(unit.file_name, @library_name)
        defined_unit_file[unit.file_name] = unit_file
        unit_file_list << unit_file
      end
      case unit.type
        when :Entity 
          unit_file.unit_name_list << unit.name
          defined_unit_name[unit.name] = unit_file
        when :Package 
          unit_file.unit_name_list << unit.name
          defined_unit_name[unit.name] = unit_file
      end
      unit_file.add_use_name_list(unit.use_unit_name_list)
    end
    # unit_file_list.each { |unit_file| unit_file.debug_print }
    #-----------------------------------------------------------------------------
    # unit_file_list を走査して依存関係を構築する.
    #-----------------------------------------------------------------------------
    unit_file_list.each do |unit_file|
      unit_file.use_name_list.each do |use_name|
        if defined_unit_name.key?(use_name)
          if (unit_file.equal?(defined_unit_name[use_name]) == false)
            unit_file.use_list << defined_unit_name[use_name]
            defined_unit_name[use_name].be_used_list << unit_file
          end
        else
          $stderr.printf "%s : %s を定義しているファイルがみつかりません.\n", unit_file.file_name, use_name
        end
      end
    end
    #-----------------------------------------------------------------------------
    # unit_file_list を走査して、参照されている順に高い値をlevelにセットする.
    #-----------------------------------------------------------------------------
    unit_file_list.each do |unit_file|
      if unit_file.use_list.empty? == false
        unit_file.set_level(1, Set.new)
      end
    end
    #-----------------------------------------------------------------------------
    # unit_file_list を level の高い順番にソートして返す.
    #-----------------------------------------------------------------------------
    return unit_file_list.sort
  end
  #-------------------------------------------------------------------------------
  # generate   : 
  #-------------------------------------------------------------------------------
  def generate
    #-----------------------------------------------------------------------------
    # @path_list で指定されたパスに対して走査して unit_list を生成する.
    #-----------------------------------------------------------------------------
    unit_list = Array.new
    @path_list.each do |path_name|
      analize_path(path_name, @library_name, unit_list)
    end
    # unit_list.each { |unit| unit.debug_print }
    #-----------------------------------------------------------------------------
    # generate_unit_file_list に先立ち、use_entity_dict を生成しておく.
    # use_entity_dict は一つの entity に対して複数の architecture が定義されていた
    # 場合に、どの achitetcure を選択するかを指定するための辞書である.
    #-----------------------------------------------------------------------------
    use_entity_dict = Hash.new
    @use_entity_list.each do |use_entity|
      if (use_entity =~ /^([\w]+)\.([\w]+)\(([\w]+)\)$/)
        library_name = $1.upcase
        entity_name  = $2.upcase
        architecture = $3.upcase
        if (library_name == @library_name.upcase)
          use_entity_dict[entity_name] = architecture
        end
      elsif (use_entity =~ /^([\w]+)\(([\w]+)\)$/)
        entity_name  = $1.upcase
        architecture = $2.upcase
        use_entity_dict[entity_name] = architecture
      end 
    end
    #-----------------------------------------------------------------------------
    # 出来上がった unit_list を元にファイル間の依存関係順に整列した unit_file_list
    # を生成する.
    #-----------------------------------------------------------------------------
    unit_file_list = generate_unit_file_list(unit_list, use_entity_dict)
    # unit_file_list.each { |unit_file| unit_file.debug_print }
    #-----------------------------------------------------------------------------
    # @execute が指定されている場合は シェルを通じて実行する.
    #-----------------------------------------------------------------------------
    if @execute 
      unit_file_list.each do |unit_file|
        command = unit_file.to_formatted_string(@execute)
        puts command
        system(command)
      end
    #-----------------------------------------------------------------------------
    # @output_file_name が指定されている場合は @format に従ってファイルに出力.
    #-----------------------------------------------------------------------------
    elsif @output_file_name
      File.open(@output_file_name, "w") do |file|
        unit_file_list.each do |unit_file|
          file.puts unit_file.to_formatted_string(@format)
        end
      end
    #-----------------------------------------------------------------------------
    # 上記以外は @format に従って標準出力に出力.
    #-----------------------------------------------------------------------------
    else
      unit_file_list.each do |unit_file|
        puts unit_file.to_formatted_string(@format)
      end
    end
  end
end

package_list = SerializedPackageList.new
package_list.parse_options(ARGV)
package_list.generate
