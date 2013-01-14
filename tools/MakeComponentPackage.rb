#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.0.3
#       Created     :   2012/8/2
#       File name   :   MakeComponentPackage.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   VHDLのソースコードから entity 宣言している部分を
#                       component 宣言として 取り出して パッケージを生成
#                       するスクリプト。
#                       VHDL 言語としてアナライズしているわけでなく、たん
#                       なる文字列として処理していることに注意。
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2012 Ichiro Kawazome
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
class ComponentPackage
  def initialize
    @program_name      = "MakeComponentPackage"
    @program_version   = "0.0.3"
    @program_id        = @program_name + " " + @program_version
    @line_width        = 83
    @components        = Hash.new
    @libraries         = Hash.new
    @name              = "COMPONENT"
    @library_name      = "WORK"
    @file_name         = nil
    @entity_file_names = Array.new
    @brief             = ""
    @version           = "1.0.0"
    @author            = "Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>"
    @time              = Time.now
    @date_format       = "%Y/%m/%d"
    @license           = default_license
    @verbose           = true
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"             ){|val| @verbose      = true}
      opt.on("--package PACKAGE_NAME"){|val| @name         = val }
      opt.on("--library LIBRARY_NAME"){|val| @library_name = val }
      opt.on("--output  FILE_NAME"   ){|val| @file_name    = val }
      opt.on("--brief   STRING"      ){|val| @brief        = val }
      opt.on("--version VERSION"     ){|val| @version      = val }
      opt.on("--author  AUTHOR_NAME" ){|val| @author       = val }
      opt.on("--licnese LICENSE"     ){|val| @license      = val }
    end
  end
  def name=(val)
    @name = val
  end
  def library_name=(val)
    @library_name = val
  end
  def file_name=(val)
    @file_name = val
  end
  def brief=(val)
    @brief = val
  end
  def version=(val)
    @version = val
  end
  def author=(val)
    @author  = val
    @license = default_license
  end
  def license=(val)
    @license = val
  end
  def program_name
    @program_name
  end
  def program_version
    @program_version
  end
  def entity_file_names=(val)
    @entity_file_names = val
  end
  #-------------------------------------------------------------------------------
  # parse_options
  #-------------------------------------------------------------------------------
  def parse_options(argv)
    @entity_file_names = @opt.parse(argv)
  end
  #-------------------------------------------------------------------------------
  # default_license
  #-------------------------------------------------------------------------------
  def default_license
    <<-LICENSE_END

      Copyright (C) #{@time.year} #{@author}
      All rights reserved.

      Redistribution and use in source and binary forms, with or without
      modification, are permitted provided that the following conditions
      are met:
 
        1. Redistributions of source code must retain the above copyright
           notice, this list of conditions and the following disclaimer.

        2. Redistributions in binary form must reproduce the above copyright
           notice, this list of conditions and the following disclaimer in
           the documentation and/or other materials provided with the
           distribution.
 
      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
    LICENSE_END
  end
  #-------------------------------------------------------------------------------
  # read_entity_files : 
  #-------------------------------------------------------------------------------
  def read_entity_files
    @entity_file_names.each do |file_name|
      read_entity_file(file_name)
    end
  end
  #-------------------------------------------------------------------------------
  # read_entity_file  : 
  #-------------------------------------------------------------------------------
  def read_entity_file(file_name)
    File.open(file_name) do |file|
      read_entity(file, file_name)
    end
  end
  #-------------------------------------------------------------------------------
  # read_entity  : エンティティ宣言部を含むファイル(ストリーム)を読み込んで、
  #                エンティティ宣言部を抽出してレジストリに格納する.
  #-------------------------------------------------------------------------------
  def read_entity(file, file_name)
    line_number    = 0
    component_name = String.new
    component_line = String.new
    library_lines  = Array.new
    use_lines      = Array.new
    #-----------------------------------------------------------------------------
    # ファイルから一行ずつ読み込む。
    #-----------------------------------------------------------------------------
    file.each_line {|o_line|
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
      # entity 宣言の開始
      #---------------------------------------------------------------------------
      if (parse_line =~ /^entity[\s]+([\w]+)[\s]+is/i)
        component_name = $1;
        component_line = line.sub(/^[\s]*entity[\s]+[\w]+[\s]*is/i, "component #{component_name}");
        next;
      end
      #---------------------------------------------------------------------------
      # library ライブラリ名; の解釈
      #---------------------------------------------------------------------------
      if (parse_line =~ /^library[\s]+[\w\s,]+;/i)
        library_lines << line
        next;
      end
      #---------------------------------------------------------------------------
      # use ライブラリ名.パッケージ名.アイテム名; の解釈
      #---------------------------------------------------------------------------
      if (parse_line =~ /^use[\s]+[\w]+\.[\w]+\.[\w]+[\s]*;/i)
        use_lines << line;
        next;
      end
      #---------------------------------------------------------------------------
      # entity宣言処理中でない場合はスキップ
      #---------------------------------------------------------------------------
      if (component_name == nil)
        if (parse_line =~ /^end[\s]+[\w]+[\s]*;/i)
          library_lines.clear
          use_lines.clear
        end
        next;
      end
      #---------------------------------------------------------------------------
      # entity宣言処理中の end 処理
      #---------------------------------------------------------------------------
      if (parse_line =~ /^end[\s]+([\w]+)[\s]*;/i)
        if ($1 == component_name)
          #-----------------------------------------------------------------------
          # コンポーネント宣言として登録
          #-----------------------------------------------------------------------
          component_line += line.sub(/^end[\s]+([\w]+)[\s]*;/, "end component;")
          @components[component_name] = component_line
          #-----------------------------------------------------------------------
          # コンポーネント宣言で使用するライブラリ名の登録
          #-----------------------------------------------------------------------
          library_lines.each do |library_line|
            if (library_line =~ /^library[\s]+([\w\s,]+);/i)
              library_list = $1.gsub(/\s/,'')
              library_list.split(/,/).each do |library_name|
                if (@libraries[library_name.upcase] == nil)
                  @libraries[library_name.upcase] = {:Name => library_name}
                end 
              end
            end
          end
          #-----------------------------------------------------------------------
          # コンポーネント宣言で使用するライブラリのパッケージ名の登録
          #-----------------------------------------------------------------------
          use_lines.each do |use_line|
            if (use_line =~ /^use[\s]+([\w]+)\.([\w]+)\.([\w]+)[\s]*;/i)
              library_name = $1.upcase;
              package_name = $2.upcase;
              item_name    = $3.upcase;
              if (@libraries[library_name][:Use] == nil)
                @libraries[library_name][:Use] = Hash.new
              end
              if (@libraries[library_name][:Use][package_name] == nil)
                @libraries[library_name][:Use][package_name] = Hash.new
              end
              @libraries[library_name][:Use][package_name][item_name] = use_line
            end
          end
          #-----------------------------------------------------------------------
          # 使った後の変数はクリアしておき次のentityに備える
          #-----------------------------------------------------------------------
          component_name = nil
          component_line = nil
          library_lines.clear
          use_lines.clear
          next;
        end
        abort("#{@program_id} Error : #{file_name}(#{line_number}) end のコンポーネント名が一致しないよ!\n")
      end
      #---------------------------------------------------------------------------
      # entity宣言処理中の end 以外は component_line に行を追加
      #---------------------------------------------------------------------------
      component_line += line;
    }
    #------------------------------------------------------------------------------
    # ファイルを全て読み終っても end が無い場合はエラー
    #---------------------------------------------------------------------------
    if (component_name != nil)
      abort("#{@program_id} Error : #{file_name}(#{line_number}) ファイルの最後まで対応する end が無いよ!\n")
    end
  end
  #-------------------------------------------------------------------------------
  # write_package_file : パッケージファイルを生成する
  #-------------------------------------------------------------------------------
  def write_package_file
    if (@file_name != nil)
      File.open(@file_name,"w") do |file|
        write_package(file, @file_name)
      end
    else
      abort("#{@program_id} Error : 出力ファイルの名前が指定されていないようだ\n")
    end
  end
  #-------------------------------------------------------------------------------
  # write : パッケージファイルを生成する
  #-------------------------------------------------------------------------------
  def write_package(out, file_name)
    #-----------------------------------------------------------------------------
    # ヘッダの出力
    #-----------------------------------------------------------------------------
    date = @time.strftime(@date_format)
    out.print(comment(0, <<-END_OF_HEAD
!     @file    #{file_name}
!     @brief   #{@brief}
!     @version #{@version}
!     @date    #{date}
!     @author  #{@author}
    END_OF_HEAD
    ))
    out.print(comment(0, @license))
    #-----------------------------------------------------------------------------
    # ライブラリ宣言
    #-----------------------------------------------------------------------------
    @libraries.each_value do |library|
      library_name     = library[:Name]
      library_packages = library[:Use]
      item_name        = String.new
      out.print(statement(0, "library #{library_name};\n"))
      library_packages.each do |package_name, package_items|
        if ((library_name == @library_name.upcase) and 
            (package_name == @name.upcase))
          next
        end
        if (package_items["ALL"] != nil)
          out.print(statement(0, package_items["ALL"]))
          next
        end
        component_line = String.new;
        @components.each_key do |key|
          component_line += @components[key]
        end
        component_line.gsub!(/--.*\n/, ' ')
        component_line.gsub!(/\W+/   , ' ')
        package_items.each_key do |item_name|
          if (component_line =~ /#{item_name}/i)
            out.print(statement(0, package_items[item_name]))
          end
        end
      end
    end
    #-----------------------------------------------------------------------------
    # パッケージ名の出力
    #-----------------------------------------------------------------------------
    out.print(comment(0, "! @brief #{@brief}"))
    out.print("package #{@name} is\n")
    #-----------------------------------------------------------------------------
    # コンポーネント宣言
    #-----------------------------------------------------------------------------
    @components.each do |component_name, component_line|
      out.print(  comment(0, "! @brief #{component_name}"))
      out.print(statement(0, component_line))
    end
    #-----------------------------------------------------------------------------
    # パッケージの終了
    #-----------------------------------------------------------------------------
    out.print("end #{@name};\n")
  end
  #-------------------------------------------------------------------------------
  # statement : ユニークな文の出力.
  #-------------------------------------------------------------------------------
  def statement(indent, statement)
    str = String.new
    delete_space = String.new
    indent_space = String.new
    (1 .. 20    ).each{delete_space += " "}
    (1 .. indent).each{indent_space += " "}
    #-----------------------------------------------------------------------------
    # 各行の先頭の空白領域を調べて、最も短いものを選択する。
    #-----------------------------------------------------------------------------
    space = String.new
    statement.split(/\n/).each do |line|
      if (line =~ /(^\s+)/)
        space = $1;
      end
      if (space.length < delete_space.length)
        delete_space = space;
      end
    end
    #-----------------------------------------------------------------------------
    # 各行の先頭の空白のうち、上で調べた最も短い文字数の空白を削除し、
    # 替りにインデント分だけの空白を追加する。
    #-----------------------------------------------------------------------------
    statement.split(/\n/).each do |line|
      line.sub!(/^#{delete_space}/,'')
      str += indent_space + line + "\n";
    end
    str
  end
  #-------------------------------------------------------------------------------
  # comment   : 与えられた文字列をコメント文字列として新たに生成する.
  #-------------------------------------------------------------------------------
  def comment(indent, comment)
    hr     = String.new
    format = String.new
    str    = String.new

    if (indent > 1)
      format = sprintf("%%-%ds--%%-%ds --\n", indent, @line_width-indent-5);
      (1        .. indent     ).each{hr += " "}
      (indent+1 .. @line_width).each{hr += "-"}
      hr += "\n"
    else
      format = sprintf("%%-%ds--%%-%ds --\n", 0, @line_width-5);
      (1        .. @line_width).each{hr += "-"}
      hr += "\n"
    end

    str += hr
    comment.split(/\n/).each do |line|
      str += sprintf format, "", line;
    end
    str += hr
  end

end

package = ComponentPackage.new
package.parse_options(ARGV)
package.read_entity_files
package.write_package_file
