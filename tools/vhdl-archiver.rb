#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.0.1
#       Created     :   2014/5/27
#       File name   :   vhdl-arichiver.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   複数のVHDLのソースコードを解析してパッケージの依存関係を
#                       調べて、ファイルをコンパイルする順番に並べて一つのファイル
#                       に結合するスクリプト.
#                       VHDL 言語としてアナライズしているわけでなく、たんなる文字
#                       列として処理していることに注意。
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2014 Ichiro Kawazome
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
class VhdlArchiver
  #-------------------------------------------------------------------------------
  # initialize    :
  #-------------------------------------------------------------------------------
  def initialize
    @program_name      = "vhdl-archiver"
    @program_version   = "0.0.1"
    @program_id        = @program_name + " " + @program_version
    @library_name      = ""
    @verbose           = false
    @debug             = false
    @library_info      = Hash.new
    @use_entity_list   = Array.new
    @top_entity_list   = Array.new
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"                        ){|val| @verbose = true                  }
      opt.on("--debug"                          ){|val| @debug   = true                  }
      opt.on("--library    LIBRARY_NAME"        ){|val| new_lib(val)                     }
      opt.on("--use_entity ENTITY(ARCHITECHURE)"){|val| add_val(:use_entity       , val) }
      opt.on("--use        ENTITY(ARCHITECHURE)"){|val| add_val(:use_entity       , val) }
      opt.on("--top        ENTITY(ARCHITECHURE)"){|val| add_val(:top_entity       , val) }
      opt.on("--output     FILE_NAME"           ){|val| add_val(:output_file_name , val) }
      opt.on("--archive    FILE_NAME"           ){|val| add_val(:archive_file_name, val) }
    end
    new_lib("WORK")
  end
  #-------------------------------------------------------------------------------
  # new_lib       :
  #-------------------------------------------------------------------------------
  def new_lib(name)
    @library_name = name
    if @library_info.key?(@library_name) == false
      @library_info[@library_name] = Hash.new
      @library_info[@library_name][:name             ] = name
      @library_info[@library_name][:replace_name     ] = nil
      @library_info[@library_name][:path_list        ] = Array.new
      @library_info[@library_name][:use_entity       ] = Hash.new
      @library_info[@library_name][:top_entity       ] = Hash.new
      @library_info[@library_name][:output_file_name ] = nil
      @library_info[@library_name][:archive_file_name] = nil
    end
  end
  #-------------------------------------------------------------------------------
  # add_val       :
  #-------------------------------------------------------------------------------
  def add_val(key,item)
    if @library_info.key?(@library_name)
      case key
      when :name              then
        @library_info[@library_name][:name             ] =  item
      when :replace_name      then
        @library_info[@library_name][:replace_name     ] =  item
      when :output_file_name  then
        @library_info[@library_name][:output_file_name ] =  item
      when :archive_file_name then
        @library_info[@library_name][:archive_file_name] =  item
      when :path_list         then
        @library_info[@library_name][:path_list        ] << item
      when :use_entity        then
        if (add_use_entity(@library_name, item) == false)
          @use_entity_list << item
        end
      when :top_entity        then
        if (add_top_entity(@library_name, item) == false)
          @top_entity_list << item
        end
      else
      end
    end
  end
  #-------------------------------------------------------------------------------
  # add_use_entity :
  #-------------------------------------------------------------------------------
  def add_use_entity(default_library_name, item)
    if    (item =~ /^([\w]+)\.([\w]+)\(([\w]+)\)$/)
      library_name = $1.upcase
      entity_name  = $2.upcase
      architecture = $3.upcase
      if (@library_info.key?(library_name) == false)
        return false
      end
      if (@library_info[library_name][:use_entity].key?(entity_name) == false)
        @library_info[library_name][:use_entity][entity_name] = Set.new
      end
      @library_info[library_name][:use_entity][entity_name] << architecture
      return true
    elsif (item =~ /^([\w]+)\(([\w]+)\)$/)
      library_name = default_library_name
      entity_name  = $1.upcase
      architecture = $2.upcase
      if (@library_info[library_name][:use_entity].key?(entity_name) == false)
        @library_info[library_name][:use_entity][entity_name] = Set.new
      end
      @library_info[library_name][:use_entity][entity_name] << architecture
      return true
    else
      return false
    end 
  end
  #-------------------------------------------------------------------------------
  # add_top_entity :
  #-------------------------------------------------------------------------------
  def add_top_entity(lib_name, item)
    if    (item =~ /^([\w]+)\.([\w]+)\(([\w]+)\)$/)
      library_name = $1.upcase
      entity_name  = $2.upcase
      architecture = $3.upcase
      if (@library_info.key?(library_name) == false)
        return false
      end
      if (@library_info[library_name][:top_entity].key?(entity_name) == false)
        @library_info[library_name][:top_entity][entity_name] = Set.new
      end
      @library_info[library_name][:top_entity][entity_name] << architecture
      return true
    elsif (item =~ /^([\w]+)\(([\w]+)\)$/)
      library_name = lib_name
      entity_name  = $1.upcase
      architecture = $2.upcase
      if (@library_info[library_name][:top_entity].key?(entity_name) == false)
        @library_info[library_name][:top_entity][entity_name] = Set.new
      end
      @library_info[library_name][:top_entity][entity_name] << architecture
      return true
    elsif (item =~ /^([\w]+)$/)
      library_name = lib_name
      entity_name  = $1.upcase
      architecture = :any
      if (@library_info[library_name][:top_entity].key?(entity_name) == false)
        @library_info[library_name][:top_entity][entity_name] = Set.new
      end
      @library_info[library_name][:top_entity][entity_name] << architecture
      return true
    else
      return false
    end 
  end
  #-------------------------------------------------------------------------------
  # parse_options
  #-------------------------------------------------------------------------------
  def parse_options(argv)
    @opt.order(argv) do |path|
      add_val(:path_list, path)
    end
    @use_entity_list.each do |item|
      add_use_entity("WORK", item)
    end
    @top_entity_list.each do |item|
      add_top_entity("WORK", item)
    end
  end
  #-------------------------------------------------------------------------------
  # execute   : 
  #-------------------------------------------------------------------------------
  def execute
    #-----------------------------------------------------------------------------
    # @library_infoに格納された各ライブラリのパスに対して走査して unit_list を生成する.
    #-----------------------------------------------------------------------------
    @library_info.each_key do |library_name|
      unit_list = Array.new
      @library_info[library_name][:path_list].each do |path_name|
        unit_list.concat(PipeWork::VHDL_Reader.analyze_path(path_name, library_name))
      end
      @library_info[library_name][:unit_list] = unit_list
      unit_list.each { |unit| unit.debug_print }
    end
  end
end

archiver = VhdlArchiver.new
archiver.parse_options(ARGV)
archiver.execute
