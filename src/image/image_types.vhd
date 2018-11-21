-----------------------------------------------------------------------------------
--!     @file    image_types.vhd
--!     @brief   Image Types Package.
--!     @version 1.8.0
--!     @date    2018/11/19
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
    -------------------------------------------------------------------------------
    --! @brief Image Data(一回の転送単位) の各種パラメータを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_WINDOW_DATA_PARAM_TYPE is record
                  LO                :  integer;
                  HI                :  integer;
                  SIZE              :  integer;
                  ELEM_FIELD        :  IMAGE_VECTOR_RANGE_TYPE;
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
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE;
                  DATA              :  IMAGE_WINDOW_DATA_PARAM_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Window の各種パラメータをを設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE)
                  return              IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE;
    function  NEW_IMAGE_WINDOW_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  IMAGE_VECTOR_RANGE_TYPE;
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
    function  GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から X 方向の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Image Window Data から  Y方向の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE;
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
    --! @brief Image Window Data に Column の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Window Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Window Data に Y 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                  PARAM             :  in    IMAGE_WINDOW_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
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
                  SHAPE             :  IMAGE_WINDOW_SHAPE_PARAM_TYPE;
                  STRIDE            :  IMAGE_WINDOW_STRIDE_PARAM_TYPE)
                  return               IMAGE_WINDOW_PARAM_TYPE
    is
        variable  param             :  IMAGE_WINDOW_PARAM_TYPE;
    begin
        param.ELEM_BITS         := ELEM_BITS;
        param.ATRB_BITS         := IMAGE_ATRB_BITS;
        param.SHAPE             := SHAPE;
        param.STRIDE            := STRIDE;
        param.DATA.ELEM_FIELD   := NEW_IMAGE_VECTOR_RANGE(param.ELEM_BITS * SHAPE.C.SIZE * SHAPE.X.SIZE * SHAPE.Y.SIZE);
        param.DATA.ATRB_C_FIELD := NEW_IMAGE_VECTOR_RANGE(param.DATA.ELEM_FIELD  .HI +1, param.ATRB_BITS * SHAPE.C.SIZE -1);
        param.DATA.ATRB_X_FIELD := NEW_IMAGE_VECTOR_RANGE(param.DATA.ATRB_C_FIELD.HI +1, param.ATRB_BITS * SHAPE.X.SIZE -1);
        param.DATA.ATRB_Y_FIELD := NEW_IMAGE_VECTOR_RANGE(param.DATA.ATRB_X_FIELD.HI +1, param.ATRB_BITS * SHAPE.Y.SIZE -1);
        param.DATA.ATRB_FIELD   := NEW_IMAGE_VECTOR_RANGE(param.DATA.ATRB_C_FIELD.LO   , param.DATA.ATRB_Y_FIELD.HI       );
        param.DATA.LO           := param.DATA.ELEM_FIELD.LO;
        param.DATA.HI           := param.DATA.ATRB_FIELD.HI;
        param.DATA.SIZE         := param.DATA.HI - param.DATA.LO + 1;
        return param;
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
                  SHAPE             => SHAPE    ,
                  STRIDE            => NEW_IMAGE_WINDOW_STRIDE_PARAM(1,1)
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
                  SHAPE             => NEW_IMAGE_WINDOW_SHAPE_PARAM(C,X,Y)
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
                  SHAPE             => NEW_IMAGE_WINDOW_SHAPE_PARAM(X,Y)
               );
    end function; 

    -------------------------------------------------------------------------------
    --! @brief std_logic_vector を Attribute に変換する関数
    -------------------------------------------------------------------------------
    function  to_attr(
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
        variable  elem_data         :  std_logic_vector(PARAM.DATA.ELEM_FIELD.SIZE-1 downto 0);
        variable  element           :  std_logic_vector(PARAM.ELEM_BITS           -1 downto 0);
    begin
        elem_data := DATA(PARAM.DATA.ELEM_FIELD.HI downto PARAM.DATA.ELEM_FIELD.LO);
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
    function  GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                  PARAM             :  IMAGE_WINDOW_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_ATRB_TYPE
    is
        variable  atrb_c_data       :  std_logic_vector(PARAM.DATA.ATRB_C_FIELD.SIZE-1 downto 0);
    begin
        atrb_c_data := DATA(PARAM.DATA.ATRB_C_FIELD.HI downto PARAM.DATA.ATRB_C_FIELD.LO);
        return to_attr(atrb_c_data((C-PARAM.SHAPE.C.LO+1)*PARAM.ATRB_BITS-1 downto
                                   (C-PARAM.SHAPE.C.LO  )*PARAM.ATRB_BITS));
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
        variable  atrb_x_data       :  std_logic_vector(PARAM.DATA.ATRB_X_FIELD.SIZE-1 downto 0);
    begin
        atrb_x_data := DATA(PARAM.DATA.ATRB_X_FIELD.HI downto PARAM.DATA.ATRB_X_FIELD.LO);
        return to_attr(atrb_x_data((X-PARAM.SHAPE.X.LO+1)*PARAM.ATRB_BITS-1 downto
                                   (X-PARAM.SHAPE.X.LO  )*PARAM.ATRB_BITS));
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
        variable  atrb_y_data       :  std_logic_vector(PARAM.DATA.ATRB_Y_FIELD.SIZE-1 downto 0);
    begin
        atrb_y_data := DATA(PARAM.DATA.ATRB_Y_FIELD.HI downto PARAM.DATA.ATRB_Y_FIELD.LO);
        return to_attr(atrb_y_data((Y-PARAM.SHAPE.Y.LO+1)*PARAM.ATRB_BITS-1 downto
                                   (Y-PARAM.SHAPE.Y.LO  )*PARAM.ATRB_BITS));
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
                  ATRB              :  in    IMAGE_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA((C-PARAM.SHAPE.C.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_C_FIELD.LO downto
             (C-PARAM.SHAPE.C.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_C_FIELD.LO) := to_std_logic_vector(ATRB);
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
        DATA((X-PARAM.SHAPE.X.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_X_FIELD.LO downto
             (X-PARAM.SHAPE.X.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_X_FIELD.LO) := to_std_logic_vector(ATRB);
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
        DATA((Y-PARAM.SHAPE.Y.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_Y_FIELD.LO downto
             (Y-PARAM.SHAPE.Y.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_Y_FIELD.LO) := to_std_logic_vector(ATRB);
    end procedure;

end IMAGE_TYPES;
