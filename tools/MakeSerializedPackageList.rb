#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.0.2
#       Created     :   2014/5/28
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
#       Copyright (C) 2012-2014 Ichiro Kawazome
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
require_relative 'PipeWork/vhdl-reader'
class SerializedPackageList
  #-------------------------------------------------------------------------------
  # initialize    :
  #-------------------------------------------------------------------------------
  def initialize
    @program_name      = "MakeSerializedPackageList"
    @program_version   = "0.0.2"
    @program_id        = @program_name + " " + @program_version
    @path_list         = Hash.new
    @file_name_list    = Array.new
    @use_entity_list   = Array.new
    @top_entity_list   = Array.new
    @library_name      = "WORK"
    @verbose           = false
    @debug             = false
    @format            = '#{file_name}'
    @execute           = nil
    @output_file_name  = nil
    @archive_file_name = nil
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"                        ){|val| @verbose          = true}
      opt.on("--debug"                          ){|val| @debug            = true}
      opt.on("--library    LIBRARY_NAME"        ){|val| @library_name     = val }
      opt.on("--format     STRING"              ){|val| @format           = val }
      opt.on("--execute    STRING"              ){|val| @execute          = val }
      opt.on("--use_entity ENTITY(ARCHITECHURE)"){|val| @use_entity_list << val }
      opt.on("--use        ENTITY(ARCHITECHURE)"){|val| @use_entity_list << val }
      opt.on("--top        ENTITY(ARCHITECHURE)"){|val| @top_entity_list << val }
      opt.on("--output     FILE_NAME"           ){|val| @output_file_name = val }
      opt.on("--archive    FILE_NAME"           ){|val| @archive_file_name= val }
    end
  end
  #-------------------------------------------------------------------------------
  # parse_options
  #-------------------------------------------------------------------------------
  def parse_options(argv)
    @opt.order(argv){ |path|
      if @path_list.key?(@library_name) == false
        @path_list[@library_name] = Array.new
      end
      @path_list[@library_name] << path
    }
  end
  #-------------------------------------------------------------------------------
  # generate   : 
  #-------------------------------------------------------------------------------
  def generate
    #-----------------------------------------------------------------------------
    # @path_list で指定されたパスに対して走査して unit_list を生成する.
    #-----------------------------------------------------------------------------
    unit_list = Array.new
    @path_list.each do |library_name, path_list|
      path_list.each do |path_name|
        unit_list.concat(PipeWork::VHDL_Reader.analyze_path(path_name, library_name))
      end
    end
    # unit_list.each { |unit| unit.debug_print }
    #-----------------------------------------------------------------------------
    # use_entity_dict を生成しておく.
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
    # entity 対して architecture を指定されている場合は、指定された architecture
    # 以外 を unit_list から取り除く.
    # 上で作っておいた use_entity_dict を使う.
    #-----------------------------------------------------------------------------
    unit_list.reject! do |unit|
        (unit.type == :Architecture) and
        (use_entity_dict.key?(unit.name) == true) and
        (use_entity_dict[unit.name] != unit.arch_name)
    end
    # unit_list.each { |unit| unit.debug_print }
    #-----------------------------------------------------------------------------
    # 出来上がった unit_list を元にファイル間の依存関係順に整列した unit_file_list
    # を生成する.
    #-----------------------------------------------------------------------------
    unit_file_list = PipeWork::VHDL_Reader.generate_unit_file_list(unit_list)
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
    # @archive_file_name が指定されている場合は 指定された順番でひとつのファイルに
    # まとめる.
    #-----------------------------------------------------------------------------
    elsif @archive_file_name
      File.open(@archive_file_name, "w") do |archive_file|
        unit_file_list.each do |unit_file|
          archive_file.write File.open(unit_file.file_name, "r").read
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
