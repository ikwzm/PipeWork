#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.0.2
#       Created     :   2014/6/2
#       File name   :   vhdl-reader.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   VHDLのソースコードを解析する ruby モジュール.
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
require 'forwardable'
module PipeWork
  module VHDL_Reader
    #-----------------------------------------------------------------------------
    # 
    #-----------------------------------------------------------------------------
    class Token
      attr_reader :sym, :text, :line_number
      def initialize(sym, text, line_number)
        @sym  = sym
        @text = text
        @line_number = line_number
      end
    end
    #-----------------------------------------------------------------------------
    # VHDLの字句解析モジュール
    #-----------------------------------------------------------------------------
    module Lexer
      #---------------------------------------------------------------------------
      # VHDL の予約語
      #---------------------------------------------------------------------------
      RESERVED_WORDS = [
        :ABS          , :ACCESS       , :AFTER        , :ALIAS        , :ALL          , 
        :AND          , :ARCHITECTURE , :ARRAY        , :ASSERT       , :ATTRIBUTE    ,
        :BEGIN        , :BLOCK        , :BODY         , :BUFFER       , :BUS          ,
        :CASE         , :COMPONENT    , :CONFIGULATION, :CONSTANT     , :DISCONNECT   , 
        :DOWNTO       , :ELSE         , :ELSIF        , :END          , :ENTITY       , 
        :EXIT         , :FILE         , :FOR          , :FUNCTION     , :GENERATE     , 
        :GENERIC      , :GUARDED      , :IF           , :IMPURE       , :IN           , 
        :INERTIAL     , :INOUT        , :IS           , :LABEL        , :LIBRARY      , 
        :LINKAGE      , :LITERAL      , :LOOP         , :MAP          , :MOD          ,
        :NAND         , :NEW          , :NEXT         , :NOR          , :NOT          , 
        :NULL         , :OF           , :ON           , :OPEN         , :OR           , 
        :OTHERS       , :OUT          , :PACKAGE      , :PORT         , :POSTPONED    , 
        :PROCEDURE    , :PROCESS      , :PURE         , :RANGE        , :RECORD       , 
        :REGISTER     , :REJECT       , :REM          , :REPORT       , :RETURN       , 
        :ROL          , :ROR          , :SELECT       , :SEVERITY     , :SHARED       , 
        :SIGNAL       , :SLA          , :SLL          , :SRA          , :SRL          , 
        :SUBTYPE      , :THEN         , :TO           , :TRANSPORT    , :TYPE         ,
        :UNAFFECTED   , :UNITS        , :UNTIL        , :USE          , :VARIABLE     ,
        :WAIT         , :WHEN         , :WHILE        , :WITH         , :XNOR         , 
        :XOR
      ]
      #---------------------------------------------------------------------------
      # VHDL の２文字以上からなるオペレータのパターンマッチを定義
      #---------------------------------------------------------------------------
      REGEXP_SPECIAL_OPS = [
        /^(=>)/   , /^(<=)/   , /^(:=)/   , /^(<<)/   , /^(>>)/   , /^(<>)/   ,
        /^(\/=)/  , /^(\*\*)/ , /^(\?\?)/ , /^(\?=)/  , /^(\?<)/  , /^(\?>)/  ,
        /^(\?<=)/ , /^(\?>=)/ , /^(\?\/=)/
      ]
      #---------------------------------------------------------------------------
      # VHDL の一文字からなるオペレータのパターンマッチを定義
      #---------------------------------------------------------------------------
      REGEXP_SPECIAL_SINGLE    = /^([\(\)\[\]\{\}\.\+\-\*\/\|\?,:;'#<>=&"@`])/
      #---------------------------------------------------------------------------
      # VHDL の一文字からなるオペレータのパターンマッチを定義
      #---------------------------------------------------------------------------
      REGEXP_SPECIAL_CHARACTER = /^([[:graph:]&&[:^alnum:]])/
      #---------------------------------------------------------------------------
      # VHDL のリテラルのパターンマッチを定義
      #---------------------------------------------------------------------------
      REGEXP_LITERAL = /^([a-zA-Z][a-zA-Z0-9_]+)/
      #---------------------------------------------------------------------------
      # 文字列から VHDL の字句を抽出してその配列を返すメソッド.
      #---------------------------------------------------------------------------
      def scan_text(text_line, line_number)
        tokens = Array.new
        line   = String.new(text_line)
        line.sub!(/--.*$/  ,'')
        line.sub!(/[\n\r]$/,'')
        while line.length > 0
          ## p line
          line.sub!(/^[[:^graph:]]+/ ,'')
          break if line.length == 0
          #-----------------------------------------------------------------------
          # 先頭に英文字がある場合
          #-----------------------------------------------------------------------
          if line[0] =~ /^[[:alpha:]]/
            text = ""
            line.sub!(/^([[:alpha:]][[:alnum:]_]*)/){text=$1;""}
            if RESERVED_WORDS.index(text.upcase.to_sym)
              tokens << Token.new(text.upcase.to_sym, text, line_number)
            else
              tokens << Token.new(:IDENTFIER,         text, line_number)
            end
            next
          end
          #-----------------------------------------------------------------------
          # 先頭に数字がある場合
          #-----------------------------------------------------------------------
          if line[0] =~ /^[[:digit:]]/
            text = ""
            line.sub!(/^([[:digit:]][[:digit:]_\.]*)/){text=$1;""}
            if line[0] =~ /^#/
              line.sub!(/^(#[[:xdigit:]_\.]+#)/){text=text+$1;""}
            end
            if line[0] =~ /^[Ee]/
              line.sub!(/^([Ee][\+\-]?[[:digit:]_\.]+#)/){text=text+$1;""}
            end
            tokens << Token.new(:NUMBER, text, line_number)
            next
          end
          #-----------------------------------------------------------------------
          # ２文字以上からなるオペレータがあるかどうかを解析する
          #-----------------------------------------------------------------------
          found_special_ops = FALSE
          REGEXP_SPECIAL_OPS.each {|r|
            if (line =~ r)
              text = ""
              line.sub!(r){text=$1;""}
              tokens << Token.new(text.to_sym, text, line_number)
              found_special_ops = TRUE
              break
            end
          }
          next if found_special_ops == TRUE
          #-----------------------------------------------------------------------
          # １文字からなるオペレータがあるかどうかを解析する
          #-----------------------------------------------------------------------
          if line[0] =~ REGEXP_SPECIAL_SINGLE
            text = ""
            line.sub!(REGEXP_SPECIAL_SINGLE){text=$1;""}
            tokens << Token.new(text.to_sym, text, line_number)
            next
          end
          #-----------------------------------------------------------------------
          # 上記以外はエラー
          #-----------------------------------------------------------------------
          line.sub!(/^./,'')
        end
        return tokens
      end
      module_function :scan_text
    end
    #-----------------------------------------------------------------------------
    # LibraryUnit   : ソースコードを読んだ時のユニット毎の依存関係を保持するクラス.
    #                 ここで言うユニットとは entity, architecture, package, 
    #                 package body のこと.
    #-----------------------------------------------------------------------------
    class LibraryUnit
      attr_reader :type, :name, :library_name, :use_library_list, :use_unit_list
      attr_reader :file_name  , :begin_line_number, :end_line_number
      attr_reader :text_lines , :tokens
      attr_reader :attributes
      def initialize(unit_type, unit_name, libary_name, file_name, line_number, library_list, use_list)
        @type              = unit_type
        @name              = unit_name.upcase
        @file_name         = file_name
        @begin_line_number = line_number
        @library_name      = libary_name.upcase
        @tokens            = [Token.new(nil,"",line_number)]
        @text_lines        = Hash.new
        @use_library_list  = library_list.uniq
        @use_unit_list     = Hash.new
        @attributes        = Hash.new
        use_list.each do |use_clause|
          library_name = use_clause[:LibraryName].upcase
          if use_clause.key?(:PackageName) 
            add_use_unit(library_name, use_clause[:PackageName].upcase)
          end
          if use_clause.key?(:EntityName) 
            add_use_unit(library_name, use_clause[:EntityName].upcase )
          end
        end
      end
      def add_use_unit(library_name, unit_name)
        if @use_unit_list[library_name] == nil
          @use_unit_list[library_name] = Set.new
        end
        @use_unit_list[library_name] << unit_name
      end
      def scan_text(text_line, line_number)
        @text_lines[line_number] = text_line
        tokens = Lexer.scan_text(text_line, line_number)
        @tokens.concat(tokens)
        return tokens
      end
      def debug_print
        warn @name
        warn "  name      : " + @name.to_s      
        warn "  type      : " + @type.to_s 
        warn "  library   : " + @library_name.to_s 
        warn "  file      : " + @file_name.to_s + "[" + @begin_line_number.to_s + ":" + @end_line_number.to_s + "]"
        warn "  attributes: " + @attributes.to_s
        warn "  use       : "
        @use_library_list.each do |library_name|
            warn "    - library : " + library_name.to_s
        end
        @use_unit_list.each do |library_name, identifier_set|
          identifier_set.each do |identifier|
            warn "    - library : " + library_name.to_s
            warn "      name    : " + identifier.to_s
          end
        end
      end
    end
    #-----------------------------------------------------------------------------
    # Entity        : ソースコードを読んだ時の Entity 記述を保持するクラス
    #-----------------------------------------------------------------------------
    class Entity < LibraryUnit
      def initialize(  entity_name, library_name, file_name, line_number, library_list, use_list)
        super(:Entity, entity_name, library_name, file_name, line_number, library_list, use_list)
      end
      def parse(text_line, line_number)
        scan_text(text_line, line_number)
        sym = @tokens[-4..-1].map{|token| token.sym}
        if (sym[-3..-1] == [:END, :ENTITY            , :";"]) or
           (sym[-3..-1] == [:END,          :IDENTFIER, :";"] and @tokens[-2].text.upcase == @name) or
           (sym[-4..-1] == [:END, :ENTITY, :IDENTFIER, :";"] and @tokens[-2].text.upcase == @name)
          @end_line_number = line_number
          return :END
        else
          return :BEGIN
        end
      end
    end
    #-----------------------------------------------------------------------------
    # Architecture  : ソースコードを読んだ時の Architecture 記述を保持するクラス
    #-----------------------------------------------------------------------------
    class Architecture < LibraryUnit
      attr_reader :arch_name, :instance_list
      def initialize(entity_name, arch_name, library_name, file_name, line_number, library_list, use_list)
        super(:Architecture, entity_name   , library_name, file_name, line_number, library_list, use_list)
        @arch_name     = arch_name.upcase
        @instance_list = Array.new
      end
      def parse(text_line, line_number)
        scan_text(text_line, line_number)
        sym = @tokens[-4..-1].map{|token| token.sym}
        if (sym[-3..-1] == [:END, :ARCHITECTURE            , :";"]) or
           (sym[-3..-1] == [:END,                :IDENTFIER, :";"] and @tokens[-2].text.upcase == @arch_name) or
           (sym[-4..-1] == [:END, :ARCHITECTURE, :IDENTFIER, :";"] and @tokens[-2].text.upcase == @arch_name)
          make_instance_list
          @end_line_number = line_number
          return :END
        else
          return :BEGIN
        end
      end
      def make_instance_list
        @tokens.each_index{ |i|
          if (@tokens[i  ].sym == :MAP) and 
             (@tokens[i+1].sym == :"(") and
             (@tokens[i-1].sym == :PORT or @tokens[i-1].sym == :GENERIC)
            tok  = @tokens[i-9..i-2]
            sym  = tok.map{|token| token.sym}
            if    (sym[-9..-1] == [:IDENTFIER, :":", :ENTITY   , :IDENTFIER, :".", :IDENTFIER, :"(", :IDENTFIER, :")"])
              instance = {:Label        => tok[-9].text.upcase,
                          :Library      => tok[-6].text.upcase,
                          :Entity       => tok[-4].text.upcase,
                          :Architecture => tok[-2].text.upcase
              }
            elsif (sym[-7..-1] == [:IDENTFIER, :":", :ENTITY   , :IDENTFIER, :"(", :IDENTFIER, :")"])
              instance = {:Label        => tok[-7].text.upcase,
                          :Library      => nil                 ,
                          :Entity       => tok[-4].text.upcase,
                          :Architecture => tok[-2].text.upcase,
              }
            elsif (sym[-6..-1] == [:IDENTFIER, :":", :ENTITY   , :IDENTFIER, :".", :IDENTFIER])
              instance = {:Label        => tok[-6].text.upcase,
                          :Library      => tok[-3].text.upcase,
                          :Entity       => tok[-1].text.upcase,
                          :Architecture => nil
              }
            elsif (sym[-4..-1] == [:IDENTFIER, :":", :ENTITY   , :IDENTFIER])
              instance = {:Label        => tok[-4].text.upcase,
                          :Library      => nil                 ,
                          :Entity       => tok[-1].text.upcase,
                          :Architecture => nil
              }
            elsif (sym[-8..-1] == [:IDENTFIER, :":", :COMPONENT, :IDENTFIER, :".", :IDENTFIER, :".", :IDENTFIER])
              instance = {:Label        => tok[-8].text.upcase,
                          :Library      => tok[-5].text.upcase,
                          :Component    => tok[-1].text.upcase
              }
            elsif (sym[-6..-1] == [:IDENTFIER, :":", :COMPONENT, :IDENTFIER, :".", :IDENTFIER])
              instance = {:Label        => tok[-6].text.upcase,
                          :Library      => tok[-3].text.upcase,
                          :Component    => tok[-1].text.upcase
              }
            elsif (sym[-4..-1] == [:IDENTFIER, :":", :COMPONENT, :IDENTFIER])
              instance = {:Label        => tok[-4].text.upcase,
                          :Library      => nil                 ,
                          :Component    => tok[-1].text.upcase
              }
            elsif (sym[-7..-1] == [:IDENTFIER, :":", :IDENTFIER, :".", :IDENTFIER, :".", :IDENTFIER])
              instance = {:Label        => tok[-7].text.upcase,
                          :Library      => tok[-5].text.upcase,
                          :Component    => tok[-1].text.upcase
              }
            elsif (sym[-5..-1] == [:IDENTFIER, :":", :IDENTFIER, :".", :IDENTFIER])
              instance = {:Label        => tok[-5].text.upcase,
                          :Library      => tok[-3].text.upcase,
                          :Component    => tok[-1].text.upcase
              }
            elsif (sym[-3..-1] == [:IDENTFIER, :":", :IDENTFIER])
              instance = {:Label        => tok[-3].text.upcase,
                          :Library      => nil                 ,
                          :Component    => tok[-1].text.upcase
              }
            else
              instance = nil
            end
            if instance != nil
               @instance_list << instance
            end
          end
        }
      end
      def debug_print
        super
        @instance_list.each do |instance|
          name  = instance[:Label] + ":"
          if instance[:Library] != nil
            name += instance[:Library] + "."
          end
          if instance[:Component] != nil
            name += instance[:Component]
          end
          if instance[:Entity] != nil
            name += instance[:Entity]
          end
          if instance[:Architecture] != nil
            name += "(" + instance[:Architecture] + ")"
          end
          warn "    - external: " + name
        end
      end
    end
    #-----------------------------------------------------------------------------
    # Package       : ソースコードを読んだ時の Package 記述を保持するクラス
    #-----------------------------------------------------------------------------
    class Package < LibraryUnit
      def initialize(   package_name, library_name, file_name, line_number, library_list, use_list)
        super(:Package, package_name, library_name, file_name, line_number, library_list, use_list)
      end
      def parse(text_line, line_number)
        scan_text(text_line, line_number)
        sym = @tokens[-3..-1].map{|token| token.sym}
        if (sym[-3..-1] == [:END, :PACKAGE            , :";"]) or
           (sym[-3..-1] == [:END,           :IDENTFIER, :";"] and @tokens[-2].text.upcase == @name) or
           (sym[-4..-1] == [:END, :PACKAGE, :IDENTFIER, :";"] and @tokens[-2].text.upcase == @name)
          @end_line_number = line_number
          return :END
        else
          return :BEGIN
        end
      end
    end
    #-----------------------------------------------------------------------------
    # PackageBody   : ソースコードを読んだ時の Package body 記述を保持するクラス
    #-----------------------------------------------------------------------------
    class PackageBody < LibraryUnit
      def initialize(       package_name, library_name, file_name, line_number, library_list, use_list)
        super(:PackageBody, package_name, library_name, file_name, line_number, library_list, use_list)
      end
      def parse(text_line, line_number)
        scan_text(text_line, line_number)
        sym = @tokens[-5..-1].map{|token| token.sym}
        if (sym[-4..-1] == [:END, :PACKAGE, :BODY            , :";"]) or
           (sym[-3..-1] == [:END,                  :IDENTFIER, :";"] and @tokens[-2].text.upcase == @name) or
           (sym[-5..-1] == [:END, :PACKAGE, :BODY, :IDENTFIER, :";"] and @tokens[-2].text.upcase == @name)
          @end_line_number = line_number
          return :END
        else
          return :BEGIN
        end
      end
    end
    #-----------------------------------------------------------------------------
    # LibraryUnitList  : LibraryUnitの配列クラス
    #-----------------------------------------------------------------------------
    class LibraryUnitList < Array
      #---------------------------------------------------------------------------
      # analyze_path : 与えられたパス名を解析し、ディレクトリならば再帰的に探索し、
      #                ファイルならば read_file を呼び出して、自分自身に LibraryUnit 
      #                を追加する.
      #                "."で始まるディレクトリは探索しない.
      #                "~"で終わるファイルは読まない.
      #---------------------------------------------------------------------------
      def analyze_path(path_name, library_name)
        if File::ftype(path_name) == "directory"
          Dir::foreach(path_name) do |name|
            next if name =~ /^\./
            if path_name =~ /\/$/
              analyze_path(path_name + name      , library_name)
            else
              analyze_path(path_name + "/" + name, library_name)
            end
          end
        elsif path_name =~ /~$/
        else 
          read_file(path_name, library_name)
        end
        return self
      end
      #---------------------------------------------------------------------------
      # read_file  : VHDLソースファイルを読んで自分自身に LibraryUnit を追加する.
      #---------------------------------------------------------------------------
      def read_file(file_name, library_name)
        if @verbose 
          warn "analyze file : " + file_name
        end
        File.open(file_name) do |file|
          analyze_file(file, file_name, library_name)
        end
        return self
      end
      #---------------------------------------------------------------------------
      # analyze_file : VHDLソースコードを解析して LibraryUnit を生成し、自分自身に
      #                生成した LibraryUnit を追加する.
      #---------------------------------------------------------------------------
      def analyze_file(file, file_name, library_name)
        unit_name         = nil
        unit_info         = nil
        library_list      = Array.new
        use_list          = Array.new
        line_number       = 0
        begin_line_number = 1
        #-------------------------------------------------------------------------
        # ファイルから一行ずつ読み込む。
        #-------------------------------------------------------------------------
        file.each_line do |line|
          text_line = line.encode("UTF-8", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?')
          #-----------------------------------------------------------------------
          # 行番号の更新
          #-----------------------------------------------------------------------
          line_number += 1
          #-----------------------------------------------------------------------
          # 
          #-----------------------------------------------------------------------
          if (unit_info == nil) 
            #---------------------------------------------------------------------
            # 
            #---------------------------------------------------------------------
            tokens = Lexer.scan_text(text_line, line_number)
            sym = tokens.map{|token| token.sym}
            #---------------------------------------------------------------------
            # library ライブラリ名; の解釈
            #---------------------------------------------------------------------
            if sym[0] == :LIBRARY
              tokens.drop(1).each {|token|
                break if token.sym == :";"
                next  if token.sym == :","
                library_list << token.text.upcase
              }
              ## p library_list
              next
            end
            #---------------------------------------------------------------------
            # use ライブラリ名.パッケージ名.アイテム名; の解釈
            #---------------------------------------------------------------------
            if (sym[0..6] == [:USE, :IDENTFIER, :".", :IDENTFIER, :".", :IDENTFIER, :";"])
              use_list << {:LibraryName => tokens[1].text, 
                           :PackageName => tokens[3].text, 
                           :ItemName    => tokens[5].text
                          }
              ## p use_list
              next
            end
            #---------------------------------------------------------------------
            # use ライブラリ名.パッケージ名.all; の解釈
            #---------------------------------------------------------------------
            if (sym[0..6] == [:USE, :IDENTFIER, :".", :IDENTFIER, :".", :ALL, :";"])
              use_list << {:LibraryName => tokens[1].text, 
                           :PackageName => tokens[3].text, 
                           :ItemName    => tokens[5].text
                          }
              ## p use_list
              next
            end
            #---------------------------------------------------------------------
            # use ライブラリ名.パッケージ名; の解釈
            #---------------------------------------------------------------------
            if (sym[0..4] == [:USE, :IDENTFIER, :".", :IDENTFIER, ";"])
              use_list << {:LibraryName => tokens[1].text, 
                           :PackageName => tokens[3].text, 
                          }
              ## p use_list
              next
            end
            #---------------------------------------------------------------------
            # entity 宣言の開始
            #---------------------------------------------------------------------
            if (sym[0..2] == [:ENTITY, :IDENTFIER, :IS])
              unit_name = tokens[1].text
              unit_info = Entity.new(unit_name, library_name, file_name, begin_line_number, library_list, use_list)
            end
            #---------------------------------------------------------------------
            # architecture 宣言の開始
            #---------------------------------------------------------------------
            if (sym[0..4] == [:ARCHITECTURE, :IDENTFIER, :OF, :IDENTFIER, :IS])
              unit_name   = tokens[1].text
              entity_name = tokens[3].text
              use_list << {:LibraryName => library_name, :EntityName => entity_name}
              unit_info = Architecture.new(entity_name, unit_name, library_name, file_name, begin_line_number, library_list, use_list)
            end
            #---------------------------------------------------------------------
            # package 宣言の開始
            #---------------------------------------------------------------------
            if (sym[0..2] == [:PACKAGE, :IDENTFIER, :IS])
              unit_name = tokens[1].text
              unit_info = Package.new(unit_name, library_name, file_name, begin_line_number, library_list, use_list)
            end
            #---------------------------------------------------------------------
            # package body 宣言の開始
            #---------------------------------------------------------------------
            if (sym[0..3] == [:PACKAGE, :BODY, :IDENTFIER, :IS])
              unit_name = tokens[2].text
              use_list << {:LibraryName => library_name, :PackageName => unit_name}
              unit_info = PackageBody.new(unit_name, library_name, file_name, begin_line_number, library_list, use_list)
            end
          end
          #-----------------------------------------------------------------------
          # entity, architecture, package, package body のパース
          #-----------------------------------------------------------------------
          if unit_info != nil
            case unit_info.parse(text_line, line_number)
              when :END
                # unit_info.debug_print
                self << unit_info
                unit_name         = ""
                unit_info         = nil
                library_list      = Array.new
                use_list          = Array.new
                begin_line_number = line_number + 1
            end
          end
        end
        #-------------------------------------------------------------------------
        # 自分自身を返す.
        #-------------------------------------------------------------------------
        return self
      end
      #---------------------------------------------------------------------------
      # 指定した Architecture から参照しているユニットを探し出して見つかった Unit 
      # をリストとして返すメソッド
      #---------------------------------------------------------------------------
      def select_found_instance(unit, instance)
        found_list  = LibraryUnitList.new
        #-------------------------------------------------------------------------
        # 指定された Unit が Architecture じゃ無い場合は空のリストを返す.
        #-------------------------------------------------------------------------
        if (unit.type != :Architecture)
          return found_list
        end
        #-------------------------------------------------------------------------
        # instance から entity_name と archtecture を得る.
        #-------------------------------------------------------------------------
        if (instance[:Entity] != nil)
          entity_name = instance[:Entity]
          archtecture = instance[:Architecture]
        end
        if (instance[:Component] != nil)
          entity_name = instance[:Component]
          archtecture = nil
        end
        #-------------------------------------------------------------------------
        # ライブラリ名が指定されてない場合
        #-------------------------------------------------------------------------
        if (instance[:Library] == nil)
          #-----------------------------------------------------------------------
          # まず、Unit が所属しているライブラリから探す.
          #-----------------------------------------------------------------------
          found_list.concat(
            self.select{ |u|
              (u.name         == entity_name       ) and
              (u.library_name == unit.library_name ) and
              (u.type         == :Architecture     ) and
              (u.arch_name    == archtecture or archtecture == nil)
            }
          )
          #-----------------------------------------------------------------------
          # 見つからなかった場合は、Unit が使っているライブラリから探す
          #-----------------------------------------------------------------------
          if (found_list.size < 1)
            unit.use_library_list.each do |library_name|
              found_list.concat(
                self.select{ |u|
                  (u.name         == entity_name  ) and
                  (u.library_name == library_name ) and
                  (u.type         == :Architecture) and
                  (u.arch_name    == archtecture or archtecture == nil)
                }
              )
            end
          end
        #-------------------------------------------------------------------------
        # ライブラリ名が指定されている場合はそのライブラリから探す
        #-------------------------------------------------------------------------
        else
          found_list.concat(
            self.select{ |u|
              (u.name         == entity_name  ) and
              (u.library_name == library_name ) and
              (u.type         == :Architecture) and
              (u.arch_name    == archtecture or archtecture == nil)
            }
          )
        end
        #-------------------------------------------------------------------------
        # 見つかったリストを返す.
        #-------------------------------------------------------------------------
        return found_list
      end
      #---------------------------------------------------------------------------
      # Architecture の instance_list の参照先を解決して use_unit_list に追加
      # するメソッド
      #---------------------------------------------------------------------------
      def resolve_external_name
        self.each do |unit|
          next if (unit.type != :Architecture)
          found_list = select_external_unit(unit)
          found_list.each do |use_unit|
            unit.add_use_unit(use_unit.library_name, use_unit.name)
          end
        end
        return self
      end
      #---------------------------------------------------------------------------
      # 指定された名前の Package と PackageBody のリストを返す.
      #---------------------------------------------------------------------------
      def select_package(library_name, package_name)
        self.select do |unit|
          (unit.name == pacakge_name) and
          (unit.library_name == library_name) and
          (unit.type == :Package or unit.type == :PackageBody)
        end
      end
      #---------------------------------------------------------------------------
      # 指定された名前の Entity と Architecture のリストを返す.
      #---------------------------------------------------------------------------
      def select_entity(library_name, entity_name, architecture)
        self.select do |unit|
          (unit.name == entity_name) and
          (unit.library_name == library_name) and
          ((unit.type == :Entity                                         ) or
           (unit.type == :Architecture and architecture == unit.arch_name) or
           (unit.type == :Architecture and architecture == nil           ) or
           (unit.type == :Architecture and architecture == :any          ))
        end
      end
      #---------------------------------------------------------------------------
      # 指定された名前の Architecture のリストを返す.
      #---------------------------------------------------------------------------
      def select_architecture(library_name, entity_name, architecture)
        self.select do |unit|
          (unit.name == entity_name) and
          (unit.library_name == library_name) and
          ((unit.type == :Architecture and architecture == unit.arch_name) or
           (unit.type == :Architecture and architecture == nil           ) or
           (unit.type == :Architecture and architecture == :any          ))
        end
      end
      #---------------------------------------------------------------------------
      # バインド
      #---------------------------------------------------------------------------
      def select_bound_unit(top_list)
        #-------------------------------------------------------------------------
        # bind_name_list を初期化する.
        #-------------------------------------------------------------------------
        bind_name_list = Hash.new
        self.each do |unit|
          if (bind_name_list.key?(unit.library_name) == false)
            bind_name_list[unit.library_name] = Hash.new
          end
          bind_name_list[unit.library_name][unit.name] = 0
        end
        # bind_name_list.each_key do |library_name|
        #   bind_name_list[library_name].each_key do |unit_name|
        #     mark = bind_name_list[library_name][unit_name]
        #     warn "==" + library_name + "." + unit_name + ": " + mark.to_s
        #   end
        # end
        #-------------------------------------------------------------------------
        # 解決すべきユニットの名前リストが空になるまで bind_unit_list を繰り返す.
        #-------------------------------------------------------------------------
        unsolved_list = top_list
        while unsolved_list.size > 0 do
          top_unit_list = unsolved_list
          unsolved_list = Array.new
          top_unit_list.each do |top_unit|
            library_name = top_unit[:library_name];
            entity_name  = top_unit[:entity_name ];
            architecture = top_unit[:architecture];
            top_name     = library_name + "." + entity_name
            if architecture != nil 
              top_name  += "(" + architecture.to_s + ")"
            end
            #---------------------------------------------------------------------
            # 解決すべきユニットを探し出してリストにする.
            #---------------------------------------------------------------------
            found_arch_list = self.select{ |unit|
              (unit.name == entity_name) and
              (unit.library_name == library_name) and
              (unit.type == :Architecture) and 
              ((architecture == unit.arch_name) or
               (architecture == :any          ) or
               (architecture == nil           ))
            }
            #---------------------------------------------------------------------
            # ユニットが見つからなかった場合は警告を出して終わり.
            #---------------------------------------------------------------------
            if (found_arch_list.size == 0) 
              warn "Not Found Top Unit: " + top_name
              next
            end
            #---------------------------------------------------------------------
            # ユニットが見つかった場合は
            #---------------------------------------------------------------------
            found_arch_list.each do |arch|
              #-------------------------------------------------------------------
              # use_unit_list を検索して、見つかった Unit の名前とライブラリ
              # を bind_name_list に登録する.
              #-------------------------------------------------------------------
              arch.use_unit_list.each_key do |use_library_name|
                arch.use_unit_list[use_library_name].each do |use_unit_name|
                  if (bind_name_list.key?(use_library_name) == true) and
                     (bind_name_list[use_library_name].key?(use_unit_name) == true)
                    bind_name_list[use_library_name][use_unit_name] = 1
                  else
                    warn "Not Found External Unit: " + top_name + " => " + use_library_name + "." + use_unit_name
                  end
                end
              end
              #-------------------------------------------------------------------
              # instance_list を検索して、見つかった Unit の名前とライブラリ
              # を bind_name_list に登録する.
              #-------------------------------------------------------------------
              arch.instance_list.each do |instance|
                #-----------------------------------------------------------------
                # ライブラリ名とエンティティ名から一致するユニットのリストを得る.
                #-----------------------------------------------------------------
                found_list = self.select_found_instance(arch, instance)
                #-----------------------------------------------------------------
                # 見つかったユニット数をチェック
                #-----------------------------------------------------------------
                instance_name = instance[:Label]
                if instance[:Library] != nil
                  instance_name += instance[:Library] + "."
                end
                if instance[:Component] != nil
                  instance_name += instance[:Component]
                end
                if instance[:Entity] != nil
                  instance_name += instance[:Entity]
                end
                if instance[:Architecture] != nil
                  instance_name += "(" + instance[:Architecture] + ")"
                end
                if    (found_list.size < 1) 
                  warn "Not Found External Unit: " + top_name + " => " + instance_name
                elsif (found_list.size > 1) 
                  warn "Conflict External Unit: "  + top_name + " => " + instance_name
                end
                #-----------------------------------------------------------------
                # 見つかったユニットの名前とライブラリを bind_name_list と突合せて
                # もし bind_name_list にまだ登録されてなかったら unsolved_list に
                # 追加する.
                #-----------------------------------------------------------------
                found_list.each do |u|
                  use_library_name = u.library_name
                  use_unit_name    = u.name
                  use_arch_name    = u.arch_name
                  if (bind_name_list.key?(use_library_name) == true) and
                     (bind_name_list[use_library_name].key?(use_unit_name) == true)
                    if (bind_name_list[use_library_name][use_unit_name] == 0)
                      unsolved_list << {
                        :library_name => use_library_name,
                        :entity_name  => use_unit_name,
                        :architecture => use_arch_name
                      }
                    end
                    bind_name_list[use_library_name][use_unit_name] = 1
                  end
                end
              end
            end
          end
        end
        #-------------------------------------------------------------------------
        # マークされたユニットのみ抽出して返す.
        #-------------------------------------------------------------------------
        return LibraryUnitList.new.concat(self.select{ |unit| bind_name_list[unit.library_name][unit.name] > 0})
      end
      #---------------------------------------------------------------------------
      # デバッグ用
      #---------------------------------------------------------------------------
      def debug_print
        self.each { |unit| unit.debug_print }
      end
    end
    #-----------------------------------------------------------------------------
    # UnitFile      : ソースコードを読んだ時のファイル毎の依存関係を保持するクラス
    #-----------------------------------------------------------------------------
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
      def compare_level (target)
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
    #-----------------------------------------------------------------------------
    # UnitFileList  : UnitFileの配列クラス
    #-----------------------------------------------------------------------------
    class UnitFileList
      extend Forwardable
      def initialize
        @list    = Array.new
        @defined = Hash.new
      end
      attr_reader :list
      def_delegators(:@list, :[], :each, :assoc, :size, :length)
      #---------------------------------------------------------------------------
      # add_unit : LibraryUnitオブジェクトをUnitFileに変換して@list に追加する.
      #---------------------------------------------------------------------------
      def add_unit(unit)
        #-------------------------------------------------------------------------
        # UnitFile を生成して、@list に登録する.
        # ただし、一度生成した UnitFile は新たに生成せずに、すでにあるものを使う.
        #-------------------------------------------------------------------------
        if @defined.key?(unit.file_name)
          unit_file = @defined[unit.file_name]
        else
          unit_file = UnitFile.new(unit.file_name, unit.library_name)
          @defined[unit.file_name] = unit_file
          @list << unit_file
        end
        #-------------------------------------------------------------------------
        # UnitFile に、そのファイルで定義しているエンティティの名前または
        # パッケージの名前を登録する
        #-------------------------------------------------------------------------
        case unit.type
          when :Entity 
            unit_file.unit_name_list << unit.name
          when :Package 
            unit_file.unit_name_list << unit.name
        end
        unit_file.add_use_name_list(unit.use_unit_list)
      end
      #---------------------------------------------------------------------------
      # add_unit_list : LibraryUnitの配列をUnitFileに変換して@listに追加する.
      #---------------------------------------------------------------------------
      def add_unit_list(unit_list)
        unit_list.each do |unit|
          add_unit(unit)
        end
      end
      #---------------------------------------------------------------------------
      # set_order     : @listを走査してファイル間の依存関係の順にlevelをセットする.
      #---------------------------------------------------------------------------
      def set_order_level
        defined_unit_file = Hash.new
        #-------------------------------------------------------------------------
        # @list を走査してファイルに定義されている unit_name を取り出して、
        # defined_unit_file を生成する.
        #-------------------------------------------------------------------------
        @list.each do |unit_file|
          unit_file.unit_name_list.each do |unit_name|
            defined_unit_file[unit_name] = unit_file
          end
        end
        #-------------------------------------------------------------------------
        # @list を走査して依存関係を構築し、各 unit_file の use_list および
        # be_used_list を作成する.
        #-------------------------------------------------------------------------
        @list.each do |unit_file|
          unit_file.use_name_list.each do |use_name|
            if defined_unit_file.key?(use_name)
              if (unit_file.equal?(defined_unit_file[use_name]) == false)
                unit_file.use_list << defined_unit_file[use_name]
                defined_unit_file[use_name].be_used_list << unit_file
              end
            else
              $stderr.printf "%s : %s を定義しているファイルがみつかりません.\n", unit_file.file_name, use_name
            end
          end
        end
        #-------------------------------------------------------------------------
        # @list を走査して、参照されている順に高い値をlevelにセットする.
        #-------------------------------------------------------------------------
        @list.each do |unit_file|
          if unit_file.use_list.empty? == false
            unit_file.set_level(1, Set.new)
          end
        end
      end
      #---------------------------------------------------------------------------
      # @list を level の高い順番にソートする.
      #---------------------------------------------------------------------------
      def sort_by_level
        @list.sort! { |a,b| a.compare_level(b) }
      end
      #---------------------------------------------------------------------------
      # デバッグ用
      #---------------------------------------------------------------------------
      def debug_print
        @list.each { |unit_file| unit_file.debug_print }
      end
    end
  end
end
