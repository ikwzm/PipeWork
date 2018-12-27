-----------------------------------------------------------------------------------
--!     @file    image_types.vhd
--!     @brief   Image Types Package.
--!     @version 1.8.0
--!     @date    2018/12/27
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
-----------------------------------------------------------------------------------
--! @brief Image の各種タイプ/定数を定義しているパッケージ.
-----------------------------------------------------------------------------------
package IMAGE_TYPES is
    -------------------------------------------------------------------------------
    --! @brief Image Window の ボーダー処理タイプの定義
    -------------------------------------------------------------------------------
    type      IMAGE_WINDOW_BORDER_TYPE is (
                  IMAGE_WINDOW_BORDER_NONE,
                  IMAGE_WINDOW_BORDER_CONSTANT,
                  IMAGE_WINDOW_BORDER_REPEAT_EDGE
    );
    -------------------------------------------------------------------------------
    --! @brief Image Window の 属性(Attribute)信号の定義
    -------------------------------------------------------------------------------
    type      IMAGE_ATRB_TYPE       is record
                  VALID             :  boolean;  -- (チャネル or 列 or 行の)有効な要素であることを示すフラグ
                  START             :  boolean;  -- (チャネル or 列 or 行の)最初の要素であることを示すフラグ
                  LAST              :  boolean;  -- (チャネル or 列 or 行の)最後の要素であることを示すフラグ
    end record;
    type      IMAGE_ATRB_VECTOR     is array (integer range <>) of IMAGE_ATRB_TYPE;
    constant  IMAGE_ATRB_BITS       :  integer := 3;
    constant  IMAGE_ATRB_VALID_POS  :  integer := 0;
    constant  IMAGE_ATRB_START_POS  :  integer := 1;
    constant  IMAGE_ATRB_LAST_POS   :  integer := 2;
    -------------------------------------------------------------------------------
    --! @brief Image Vector(一次元) の各種パラメータを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_VECTOR_RANGE_TYPE is record
                  LO                :  integer;  -- Vector のインデックスの最小値
                  HI                :  integer;  -- Vector のインデックスの最大値
                  SIZE              :  integer;  -- Vector の大きさ
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Vector の各種パラメータを設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_VECTOR_RANGE(LO,HI:integer) return IMAGE_VECTOR_RANGE_TYPE;
    function  NEW_IMAGE_VECTOR_RANGE(SIZE :integer) return IMAGE_VECTOR_RANGE_TYPE;
    function  NEW_IMAGE_VECTOR_RANGE(PREV :IMAGE_VECTOR_RANGE_TYPE;
                                     SIZE: integer) return IMAGE_VECTOR_RANGE_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Image Data(一回の転送単位) の各種パラメータを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_WINDOW_DATA_PARAM_TYPE is record
                  LO                :  integer;
                  HI                :  integer;
                  SIZE              :  integer;
                  ELEM_FIELD        :  IMAGE_VECTOR_RANGE_TYPE;
                  INFO_FIELD        :  IMAGE_VECTOR_RANGE_TYPE;
                  ATRB_FIELD        :  IMAGE_VECTOR_RANGE_TYPE;
                  ATRB_C_FIELD      :  IMAGE_VECTOR_RANGE_TYPE;
                  ATRB_X_FIELD      :  IMAGE_VECTOR_RANGE_TYPE;
                  ATRB_Y_FIELD      :  IMAGE_VECTOR_RANGE_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Window の形(各辺の大きさ)を定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_WINDOW_SHAPE_PARAM_TYPE is record
                  C                 :  IMAGE_VECTOR_RANGE_TYPE;  -- Channel 配列の範囲
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;  -- X 方向の配列の範囲
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE;  -- Y 方向の配列の範囲
                  SIZE              :  integer;                  -- C.SIZE * X.SIZE * Y.SIZE
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Window の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_SHAPE_PARAM(C,X,Y:IMAGE_VECTOR_RANGE_TYPE) return IMAGE_WINDOW_SHAPE_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_SHAPE_PARAM(  X,Y:IMAGE_VECTOR_RANGE_TYPE) return IMAGE_WINDOW_SHAPE_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_SHAPE_PARAM(C,X,Y:integer                ) return IMAGE_WINDOW_SHAPE_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_SHAPE_PARAM(  X,Y:integer                ) return IMAGE_WINDOW_SHAPE_PARAM_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Image Window のストライド(移動距離)を定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_WINDOW_STRIDE_PARAM_TYPE is record
                  X                 :  integer;
                  Y                 :  integer;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Window のストライド(移動距離)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_STRIDE_PARAM(X,Y:integer) return IMAGE_WINDOW_STRIDE_PARAM_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_WINDOW_PARAM_TYPE is record
                  ELEM_BITS         :  integer;  -- 1要素(Element  )のビット数
                  ATRB_BITS         :  integer;  -- 1属性(Attribute)のビット数
                  INFO_BITS         :  integer;  -- その他情報のビット数
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE;
                  DATA              :  IMAGE_WINDOW_DATA_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_WINDOW_BORDER_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_WINDOW_BORDER_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_WINDOW_BORDER_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  C                 :  IMAGE_VECTOR_RANGE_TYPE;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  IMAGE_VECTOR_RANGE_TYPE;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  integer;
                  X                 :  integer;
                  Y                 :  integer)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  X                 :  integer;
                  Y                 :  integer)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から要素を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  integer;
                  X                 :  integer;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C_LO              :  integer;
                  C_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR;
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR;
    function  GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE;
    function  GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から X 方向の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  X_LO              :  integer;
                  X_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR;
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR;
    function  GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE;
    function  GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から  Y方向の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  Y_LO              :  integer;
                  Y_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR;
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR;
    function  GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE;
    function  GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Window Data に要素を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  in    integer;
                  X                 :  in    integer;
                  Y                 :  in    integer;
                  ELEMENT           :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Window Data に Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    procedure SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Window Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    procedure SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Window Data に Y 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    procedure SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Window が Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_START_C(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Window が Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_LAST_C(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Window が列(X方向)の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_START_X(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  BORDER            :  IMAGE_WINDOW_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    function  IMAGE_WINDOW_DATA_IS_START_X(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Window が行(Y方向)の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_START_Y(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  BORDER            :  IMAGE_WINDOW_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    function  IMAGE_WINDOW_DATA_IS_START_Y(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Window が列(X方向)の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_LAST_X(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  BORDER            :  IMAGE_WINDOW_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    function  IMAGE_WINDOW_DATA_IS_LAST_X(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Window が行(Y方向)の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_LAST_Y(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  BORDER            :  IMAGE_WINDOW_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    function  IMAGE_WINDOW_DATA_IS_LAST_Y(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
end IMAGE_TYPES;
-----------------------------------------------------------------------------------
--! @brief Image の各種タイプ/定数を定義しているパッケージ.
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
package body IMAGE_TYPES is
    -------------------------------------------------------------------------------
    --! @brief Image Vector の各種パラメータを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_VECTOR_RANGE(LO,HI:integer) return IMAGE_VECTOR_RANGE_TYPE
    is
        variable param :  IMAGE_VECTOR_RANGE_TYPE;
    begin
        param.LO   := LO;
        param.HI   := HI;
        param.SIZE := HI-LO+1;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Vector の各種パラメータを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_VECTOR_RANGE(SIZE :integer) return IMAGE_VECTOR_RANGE_TYPE
    is
    begin
        return NEW_IMAGE_VECTOR_RANGE(0, SIZE-1);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Vector の各種パラメータを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_VECTOR_RANGE(PREV :IMAGE_VECTOR_RANGE_TYPE;
                                     SIZE: integer) return IMAGE_VECTOR_RANGE_TYPE
    is
        variable param :  IMAGE_VECTOR_RANGE_TYPE;
    begin
        if (SIZE > 0) then
            param.LO   := PREV.HI+1;
            param.HI   := PREV.HI+1 + SIZE-1;
            param.SIZE := SIZE;
        else
            param.LO   := PREV.HI+1;
            param.HI   := PREV.HI+1;
            param.SIZE := SIZE;
        end if;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の形(各辺の大きさ)を設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_SHAPE_PARAM(C,X,Y:IMAGE_VECTOR_RANGE_TYPE) return IMAGE_WINDOW_SHAPE_PARAM_TYPE
    is
        variable param :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
    begin
        param.C    := C;
        param.X    := X;
        param.Y    := Y;
        param.SIZE := C.SIZE * X.SIZE * Y.SIZE;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の形(各辺の大きさ)を設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_SHAPE_PARAM(  X,Y:IMAGE_VECTOR_RANGE_TYPE) return IMAGE_WINDOW_SHAPE_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_SHAPE_PARAM(C => NEW_IMAGE_VECTOR_RANGE(1),
                                            X => X,
                                            Y => Y);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の形(各辺の大きさ)を設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_SHAPE_PARAM(C,X,Y:integer                ) return IMAGE_WINDOW_SHAPE_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_SHAPE_PARAM(C => NEW_IMAGE_VECTOR_RANGE(C),
                                            X => NEW_IMAGE_VECTOR_RANGE(X),
                                            Y => NEW_IMAGE_VECTOR_RANGE(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の形(各辺の大きさ)を設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_SHAPE_PARAM(  X,Y:integer                ) return IMAGE_WINDOW_SHAPE_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_SHAPE_PARAM(C => NEW_IMAGE_VECTOR_RANGE(1),
                                            X => NEW_IMAGE_VECTOR_RANGE(X),
                                            Y => NEW_IMAGE_VECTOR_RANGE(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window のストライド(移動距離)を設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_STRIDE_PARAM(X,Y:integer) return IMAGE_WINDOW_STRIDE_PARAM_TYPE
    is
        variable  param            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE;
    begin
        param.X := X;
        param.Y := Y;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_WINDOW_BORDER_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
        variable  param             :  IMAGE_WINDOW_PARAM_TYPE;
    begin
        param.ELEM_BITS         := ELEM_BITS;
        param.ATRB_BITS         := IMAGE_ATRB_BITS;
        param.INFO_BITS         := INFO_BITS;
        param.SHAPE             := SHAPE;
        param.STRIDE            := STRIDE;
        param.BORDER_TYPE       := BORDER_TYPE;
        param.DATA.ELEM_FIELD   := NEW_IMAGE_VECTOR_RANGE(param.ELEM_BITS * param.SHAPE.C.SIZE * param.SHAPE.X.SIZE * param.SHAPE.Y.SIZE);
        param.DATA.ATRB_C_FIELD := NEW_IMAGE_VECTOR_RANGE(param.DATA.ELEM_FIELD  , param.ATRB_BITS * param.SHAPE.C.SIZE);
        param.DATA.ATRB_X_FIELD := NEW_IMAGE_VECTOR_RANGE(param.DATA.ATRB_C_FIELD, param.ATRB_BITS * param.SHAPE.X.SIZE);
        param.DATA.ATRB_Y_FIELD := NEW_IMAGE_VECTOR_RANGE(param.DATA.ATRB_X_FIELD, param.ATRB_BITS * param.SHAPE.Y.SIZE);
        param.DATA.ATRB_FIELD   := NEW_IMAGE_VECTOR_RANGE(param.DATA.ATRB_C_FIELD.LO,
                                                          param.DATA.ATRB_Y_FIELD.HI);
        param.DATA.LO           := param.DATA.ELEM_FIELD.LO;
        param.DATA.INFO_FIELD   := NEW_IMAGE_VECTOR_RANGE(param.DATA.ATRB_FIELD, INFO_BITS);
        if (INFO_BITS > 0) then
            param.DATA.HI       := param.DATA.INFO_FIELD.HI;
        else
            param.DATA.HI       := param.DATA.ATRB_FIELD.HI;
        end if;
        param.DATA.SIZE         := param.DATA.HI - param.DATA.LO + 1;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_WINDOW_BORDER_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin 
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => SHAPE    ,
                  STRIDE            => STRIDE   ,
                  BORDER_TYPE       => IMAGE_WINDOW_BORDER_NONE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => SHAPE    ,
                  STRIDE            => STRIDE   ,
                  BORDER_TYPE       => IMAGE_WINDOW_BORDER_NONE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => SHAPE    ,
                  STRIDE            => STRIDE   ,
                  BORDER_TYPE       => IMAGE_WINDOW_BORDER_NONE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => SHAPE    ,
                  STRIDE            => NEW_IMAGE_WINDOW_STRIDE_PARAM(1,1)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => SHAPE    ,
                  STRIDE            => NEW_IMAGE_WINDOW_STRIDE_PARAM(1,1)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  C                 :  IMAGE_VECTOR_RANGE_TYPE;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_WINDOW_SHAPE_PARAM(C,X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  IMAGE_VECTOR_RANGE_TYPE;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => NEW_IMAGE_WINDOW_SHAPE_PARAM(C,X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_WINDOW_SHAPE_PARAM(X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => NEW_IMAGE_WINDOW_SHAPE_PARAM(X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  integer;
                  X                 :  integer;
                  Y                 :  integer)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => NEW_IMAGE_WINDOW_SHAPE_PARAM(C,X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  X                 :  integer;
                  Y                 :  integer)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => NEW_IMAGE_WINDOW_SHAPE_PARAM(X,Y)
               );
    end function; 

    -------------------------------------------------------------------------------
    --! @brief std_logic_vector を Attribute に変換する関数
    -------------------------------------------------------------------------------
    function  to_atrb_type(
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE
    is
        alias     atrb_data         :  std_logic_vector(IMAGE_ATRB_BITS-1 downto 0) is DATA;
        variable  atrb              :  IMAGE_ATRB_TYPE;
    begin
        atrb.VALID := (atrb_data(IMAGE_ATRB_VALID_POS) = '1');
        atrb.START := (atrb_data(IMAGE_ATRB_START_POS) = '1');
        atrb.LAST  := (atrb_data(IMAGE_ATRB_LAST_POS ) = '1');
        return atrb;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Attribute を std_logic_vector に変換する関数
    -------------------------------------------------------------------------------
    function  to_std_logic_vector(
                  ATRB              :  IMAGE_ATRB_TYPE)
                  return               std_logic_vector
    is
        variable  atrb_data         :  std_logic_vector(IMAGE_ATRB_BITS-1 downto 0);
    begin
        if (ATRB.VALID = TRUE) then
            atrb_data(IMAGE_ATRB_VALID_POS) := '1';
        else
            atrb_data(IMAGE_ATRB_VALID_POS) := '0';
        end if;
        if (ATRB.START = TRUE) then
            atrb_data(IMAGE_ATRB_START_POS) := '1';
        else
            atrb_data(IMAGE_ATRB_START_POS) := '0';
        end if;
        if (ATRB.LAST  = TRUE) then
            atrb_data(IMAGE_ATRB_LAST_POS ) := '1';
        else
            atrb_data(IMAGE_ATRB_LAST_POS ) := '0';
        end if;
        return atrb_data;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Window Data から要素を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  integer;
                  X                 :  integer;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector
    is
        alias     input_data        :  std_logic_vector(PARAM.DATA.SIZE           -1 downto 0) is DATA;
        variable  elem_data         :  std_logic_vector(PARAM.DATA.ELEM_FIELD.SIZE-1 downto 0);
        variable  element           :  std_logic_vector(PARAM.ELEM_BITS           -1 downto 0);
    begin
        elem_data := input_data(PARAM.DATA.ELEM_FIELD.HI downto PARAM.DATA.ELEM_FIELD.LO);
        element   := elem_data(((Y-PARAM.SHAPE.Y.LO)*PARAM.SHAPE.X.SIZE*PARAM.SHAPE.C.SIZE +
                                (X-PARAM.SHAPE.X.LO)*PARAM.SHAPE.C.SIZE                    +
                                (C-PARAM.SHAPE.C.LO)                                       + 1)*PARAM.ELEM_BITS-1 downto
                               ((Y-PARAM.SHAPE.Y.LO)*PARAM.SHAPE.X.SIZE*PARAM.SHAPE.C.SIZE +
                                (X-PARAM.SHAPE.X.LO)*PARAM.SHAPE.C.SIZE                    +
                                (C-PARAM.SHAPE.C.LO)                                          )*PARAM.ELEM_BITS);
        return element;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C_LO              :  integer;
                  C_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR
    is
        variable  atrb_c_vector     :  IMAGE_ATRB_VECTOR(C_LO to C_HI);
    begin
        for i in atrb_c_vector'range loop
            atrb_c_vector(i) := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(PARAM, i, DATA);
        end loop;
        return atrb_c_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR
    is
        variable  atrb_c_vector     :  IMAGE_ATRB_VECTOR(PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI);
    begin
        for i in atrb_c_vector'range loop
            atrb_c_vector(i) := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(PARAM, i, DATA);
        end loop;
        return atrb_c_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector
    is
        alias     input_data        :  std_logic_vector(PARAM.DATA.SIZE-1 downto 0) is DATA;
        variable  atrb_c_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_c_data  := input_data((C-PARAM.SHAPE.C.LO+1)*PARAM.ATRB_BITS-1+PARAM.DATA.ATRB_C_FIELD.LO downto
                                   (C-PARAM.SHAPE.C.LO  )*PARAM.ATRB_BITS  +PARAM.DATA.ATRB_C_FIELD.LO);
        return atrb_c_data;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE
    is
        variable  atrb_c_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_c_data := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(PARAM, C, DATA);
        return to_atrb_type(atrb_c_data);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  X_LO              :  integer;
                  X_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR
    is
        variable  atrb_x_vector     :  IMAGE_ATRB_VECTOR(X_LO to X_HI);
    begin
        for i in atrb_x_vector'range loop
            atrb_x_vector(i) := GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(PARAM, i, DATA);
        end loop;
        return atrb_x_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR
    is
        variable  atrb_x_vector     :  IMAGE_ATRB_VECTOR(PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI);
    begin
        for i in atrb_x_vector'range loop
            atrb_x_vector(i) := GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(PARAM, i, DATA);
        end loop;
        return atrb_x_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector
    is
        alias     input_data        :  std_logic_vector(PARAM.DATA.SIZE-1 downto 0) is DATA;
        variable  atrb_x_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_x_data  := input_data((X-PARAM.SHAPE.X.LO+1)*PARAM.ATRB_BITS-1+PARAM.DATA.ATRB_X_FIELD.LO downto
                                   (X-PARAM.SHAPE.X.LO  )*PARAM.ATRB_BITS  +PARAM.DATA.ATRB_X_FIELD.LO);
        return atrb_x_data;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE
    is
        variable  atrb_x_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_x_data := GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(PARAM, X, DATA);
        return to_atrb_type(atrb_x_data);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  Y_LO              :  integer;
                  Y_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR
    is
        variable  atrb_y_vector     :  IMAGE_ATRB_VECTOR(Y_LO to Y_HI);
    begin
        for i in atrb_y_vector'range loop
            atrb_y_vector(i) := GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(PARAM, i, DATA);
        end loop;
        return atrb_y_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_VECTOR
    is
        variable  atrb_y_vector     :  IMAGE_ATRB_VECTOR(PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI);
    begin
        for i in atrb_y_vector'range loop
            atrb_y_vector(i) := GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(PARAM, i, DATA);
        end loop;
        return atrb_y_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector
    is
        alias     input_data        :  std_logic_vector(PARAM.DATA.SIZE-1 downto 0) is DATA;
        variable  atrb_y_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_y_data  := input_data((Y-PARAM.SHAPE.Y.LO+1)*PARAM.ATRB_BITS-1+PARAM.DATA.ATRB_Y_FIELD.LO downto
                                   (Y-PARAM.SHAPE.Y.LO  )*PARAM.ATRB_BITS  +PARAM.DATA.ATRB_Y_FIELD.LO);
        return atrb_y_data;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE
    is
        variable  atrb_y_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_y_data := GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(PARAM, Y, DATA);
        return to_atrb_type(atrb_y_data);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window Data に要素を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  in    integer;
                  X                 :  in    integer;
                  Y                 :  in    integer;
                  ELEMENT           :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA(((Y-PARAM.SHAPE.Y.LO)*PARAM.SHAPE.X.SIZE*PARAM.SHAPE.C.SIZE +
              (X-PARAM.SHAPE.X.LO)*PARAM.SHAPE.C.SIZE                    +
              (C-PARAM.SHAPE.C.LO)                                       +1)*PARAM.ELEM_BITS -1 + PARAM.DATA.ELEM_FIELD.LO downto
             ((Y-PARAM.SHAPE.Y.LO)*PARAM.SHAPE.X.SIZE*PARAM.SHAPE.C.SIZE +
              (X-PARAM.SHAPE.X.LO)*PARAM.SHAPE.C.SIZE                    +
              (C-PARAM.SHAPE.C.LO)                                         )*PARAM.ELEM_BITS    + PARAM.DATA.ELEM_FIELD.LO) := ELEMENT;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Window Data に Column の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA((C-PARAM.SHAPE.C.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_C_FIELD.LO downto
             (C-PARAM.SHAPE.C.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_C_FIELD.LO) := ATRB;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Window Data に Column の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
            PARAM => PARAM,
            C     => C,
            ATRB  => to_std_logic_vector(ATRB),
            DATA  => DATA
        );
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Window Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA((X-PARAM.SHAPE.X.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_X_FIELD.LO downto
             (X-PARAM.SHAPE.X.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_X_FIELD.LO) := ATRB;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Window Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
            PARAM => PARAM,
            X     => X,
            ATRB  => to_std_logic_vector(ATRB),
            DATA  => DATA
        );
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Window Data に Y 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA((Y-PARAM.SHAPE.Y.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_Y_FIELD.LO downto
             (Y-PARAM.SHAPE.Y.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_Y_FIELD.LO) := ATRB;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Window Data に Y 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
            PARAM => PARAM,
            Y     => Y,
            ATRB  => to_std_logic_vector(ATRB),
            DATA  => DATA
        );
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Window の属性をチェックする関数
    -------------------------------------------------------------------------------
    function  CHECK_IMAGE_ATRB(
                  ATRB              :  IMAGE_ATRB_TYPE;
                  VALID             :  boolean := FALSE;
                  START             :  boolean := FALSE;
                  LAST              :  boolean := FALSE)
                  return               boolean
    is
    begin
        return ((VALID = TRUE and ATRB.VALID = TRUE) or (VALID = FALSE)) and
               ((START = TRUE and ATRB.START = TRUE) or (START = FALSE)) and
               ((LAST  = TRUE and ATRB.LAST  = TRUE) or (LAST  = FALSE));
    end function;
        
    -------------------------------------------------------------------------------
    --! @brief Image Window の属性をチェックする関数
    -------------------------------------------------------------------------------
    function  CHECK_IMAGE_ATRB(
                  ATRB_VEC          :  IMAGE_ATRB_VECTOR;
                  VALID             :  boolean := FALSE;
                  START             :  boolean := FALSE;
                  LAST              :  boolean := FALSE)
                  return               boolean
    is
        variable  ret_value         :  boolean;
    begin
        ret_value := FALSE;
        for i in ATRB_VEC'range loop
            if (CHECK_IMAGE_ATRB(ATRB_VEC(i), VALID, START, LAST) = TRUE) then
                ret_value := TRUE;
            end if;
        end loop;
        return ret_value;
    end function;
        
    -------------------------------------------------------------------------------
    --! @brief Image Window が Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_START_C(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
        variable  atrb_c            :  IMAGE_ATRB_TYPE;
    begin 
        return CHECK_IMAGE_ATRB(
                      ATRB  => GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                                   PARAM => PARAM,
                                   C     => PARAM.SHAPE.C.LO,
                                   DATA  => DATA
                               ),
                      VALID => VALID,
                      START => TRUE,
                      LAST  => FALSE
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Window が Channel の有効な最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_LAST_C(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return CHECK_IMAGE_ATRB(
                      ATRB_VEC  => GET_ATRB_C_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       C_LO  => PARAM.SHAPE.C.LO,
                                       C_HI  => PARAM.SHAPE.C.HI,
                                       DATA  => DATA
                                   ),
                      VALID     => VALID,
                      START     => FALSE,
                      LAST      => TRUE
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Window が列(X方向)の有効な最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_START_X(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  BORDER            :  IMAGE_WINDOW_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        if (BORDER = IMAGE_WINDOW_BORDER_NONE) then
            return CHECK_IMAGE_ATRB(
                       ATRB_VEC => GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       X_LO  => PARAM.SHAPE.X.LO,
                                       X_HI  => PARAM.SHAPE.X.LO+(PARAM.STRIDE.X-1),
                                       DATA  => DATA
                                   ),
                       VALID    => VALID,
                       START    => TRUE,
                       LAST     => FALSE
                   );
        else
            return CHECK_IMAGE_ATRB(
                       ATRB_VEC => GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       X_LO  => PARAM.SHAPE.X.LO,
                                       X_HI  => 0+(PARAM.STRIDE.X-1),
                                       DATA  => DATA
                                   ),
                       VALID    => VALID,
                       START    => TRUE,
                       LAST     => FALSE
                   );
        end if;
    end function;

    function  IMAGE_WINDOW_DATA_IS_START_X(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin 
        return IMAGE_WINDOW_DATA_IS_START_X(PARAM, PARAM.BORDER_TYPE, DATA, VALID);
    end function;
            
    -------------------------------------------------------------------------------
    --! @brief Image Window が行(Y方向)の有効な最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_START_Y(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  BORDER            :  IMAGE_WINDOW_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        if (BORDER = IMAGE_WINDOW_BORDER_NONE) then
            return CHECK_IMAGE_ATRB(
                       ATRB_VEC => GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       Y_LO  => PARAM.SHAPE.Y.LO,
                                       Y_HI  => PARAM.SHAPE.Y.LO+(PARAM.STRIDE.Y-1),
                                       DATA  => DATA
                                   ),
                       VALID    => VALID,
                       START    => TRUE,
                       LAST     => FALSE
                   );
        else
            return CHECK_IMAGE_ATRB(
                       ATRB_VEC => GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       Y_LO  => PARAM.SHAPE.Y.LO,
                                       Y_HI  => 0+(PARAM.STRIDE.Y-1),
                                       DATA  => DATA
                                   ),
                       VALID    => VALID,
                       START    => TRUE,
                       LAST     => FALSE
                   );
        end if;
    end function;

    function  IMAGE_WINDOW_DATA_IS_START_Y(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return IMAGE_WINDOW_DATA_IS_START_Y(PARAM, PARAM.BORDER_TYPE, DATA, VALID);
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Window が列(X方向)の有効な最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_LAST_X(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  BORDER            :  IMAGE_WINDOW_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        if (BORDER = IMAGE_WINDOW_BORDER_NONE) then
            return CHECK_IMAGE_ATRB(
                       ATRB_VEC => GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       X_LO  => PARAM.SHAPE.X.HI-(PARAM.STRIDE.X-1),
                                       X_HI  => PARAM.SHAPE.X.HI,
                                       DATA  => DATA
                                   ),
                       VALID    => VALID,
                       START    => FALSE,
                       LAST     => TRUE
                   );
        else
            return CHECK_IMAGE_ATRB(
                       ATRB_VEC => GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       X_LO  => 0-(PARAM.STRIDE.X-1),
                                       X_HI  => PARAM.SHAPE.X.HI,
                                       DATA  => DATA
                                   ),
                       VALID    => VALID,
                       START    => FALSE,
                       LAST     => TRUE
                   );
        end if;
    end function;

    function  IMAGE_WINDOW_DATA_IS_LAST_X(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return IMAGE_WINDOW_DATA_IS_LAST_X(PARAM, PARAM.BORDER_TYPE, DATA, VALID);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Window が行(Y方向)の有効な最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_WINDOW_DATA_IS_LAST_Y(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  BORDER            :  IMAGE_WINDOW_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        if (PARAM.BORDER_TYPE = IMAGE_WINDOW_BORDER_NONE) then
            return CHECK_IMAGE_ATRB(
                       ATRB_VEC => GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       Y_LO  => PARAM.SHAPE.Y.HI-(PARAM.STRIDE.Y-1),
                                       Y_HI  => PARAM.SHAPE.Y.HI,
                                       DATA  => DATA
                                   ),
                       VALID    => VALID,
                       START    => FALSE,
                       LAST     => TRUE
                   );
        else
            return CHECK_IMAGE_ATRB(
                       ATRB_VEC => GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(
                                       PARAM => PARAM,
                                       Y_LO  => 0-(PARAM.STRIDE.Y-1),
                                       Y_HI  => PARAM.SHAPE.Y.HI,
                                       DATA  => DATA
                                   ),
                       VALID    => VALID,
                       START    => FALSE,
                       LAST     => TRUE
                   );
        end if;
    end function;

    function  IMAGE_WINDOW_DATA_IS_LAST_Y(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return IMAGE_WINDOW_DATA_IS_LAST_Y(PARAM, PARAM.BORDER_TYPE, DATA, VALID);
    end function;
    
end IMAGE_TYPES;
