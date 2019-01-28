-----------------------------------------------------------------------------------
--!     @file    image_types.vhd
--!     @brief   Image Types Package.
--!     @version 1.8.0
--!     @date    2019/1/28
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2019 Ichiro Kawazome
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
    --! @brief Image の形(各辺の大きさ)の各辺をどのように算出するかを決めるタイプの定義
    -------------------------------------------------------------------------------
    type      IMAGE_SHAPE_SIDE_DICIDE_TYPE is (
                  IMAGE_SHAPE_SIDE_DICIDE_NONE     , -- 辺が存在しない.
                  IMAGE_SHAPE_SIDE_DICIDE_CONSTANT , -- 指定された値で常に静的に決める.
                  IMAGE_SHAPE_SIDE_DICIDE_EXTERNAL , -- 外部からの信号で動的に決める.
                  IMAGE_SHAPE_SIDE_DICIDE_AUTO       -- 各モジュール内部で自動計算する.
    );
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺の値を定義.
    -------------------------------------------------------------------------------
    type      IMAGE_SHAPE_SIDE_TYPE        is record
                  DICIDE_TYPE              :  IMAGE_SHAPE_SIDE_DICIDE_TYPE;
                  LO                       :  integer;  -- 範囲の最小値(DICIDE_CONSTANTのみ設定可)
                  HI                       :  integer;  -- 範囲の最大値(DICIDE_CONSTANTのみ設定可)
                  SIZE                     :  integer;  -- 辺の大きさ  (DICIDE_CONSTANTのみ有効)
                  MAX_SIZE                 :  integer;  -- 辺の最大値  (DICIDE_AUTOおよびDICIDE_EXTERNALのみ有効)
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,D,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_NONE                        return IMAGE_SHAPE_SIDE_TYPE;
    function  NEW_IMAGE_SHAPE_SIDE_AUTO    (MAX_SIZE: integer) return IMAGE_SHAPE_SIDE_TYPE;
    function  NEW_IMAGE_SHAPE_SIDE_EXTERNAL(MAX_SIZE: integer) return IMAGE_SHAPE_SIDE_TYPE;
    function  NEW_IMAGE_SHAPE_SIDE_CONSTANT(SIZE    : integer) return IMAGE_SHAPE_SIDE_TYPE;
    function  NEW_IMAGE_SHAPE_SIDE_CONSTANT(LO,HI   : integer) return IMAGE_SHAPE_SIDE_TYPE;

    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_SHAPE_TYPE             is record
                  ELEM_BITS                :  integer;
                  C                        :  IMAGE_SHAPE_SIDE_TYPE;
                  D                        :  IMAGE_SHAPE_SIDE_TYPE;
                  X                        :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                        :  IMAGE_SHAPE_SIDE_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE         (ELEM_BITS: integer;
                                       C,D,X,Y  : IMAGE_SHAPE_SIDE_TYPE) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE         (ELEM_BITS: integer;
                                       C,  X,Y  : IMAGE_SHAPE_SIDE_TYPE) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE         (ELEM_BITS: integer;
                                           X,Y  : IMAGE_SHAPE_SIDE_TYPE) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_AUTO    (ELEM_BITS,C,D,X,Y: integer      ) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_AUTO    (ELEM_BITS,C,  X,Y: integer      ) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_AUTO    (ELEM_BITS,    X,Y: integer      ) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_EXTERNAL(ELEM_BITS,C,D,X,Y: integer      ) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_EXTERNAL(ELEM_BITS,C,  X,Y: integer      ) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_EXTERNAL(ELEM_BITS,    X,Y: integer      ) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,C,D,X,Y: integer      ) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,C,  X,Y: integer      ) return IMAGE_SHAPE_TYPE;
    function  NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,    X,Y: integer      ) return IMAGE_SHAPE_TYPE;

    -------------------------------------------------------------------------------
    --! @brief Image Stream の ボーダー処理タイプの定義
    -------------------------------------------------------------------------------
    type      IMAGE_STREAM_BORDER_TYPE is (
                  IMAGE_STREAM_BORDER_NONE,
                  IMAGE_STREAM_BORDER_CONSTANT,
                  IMAGE_STREAM_BORDER_REPEAT_EDGE
    );
    -------------------------------------------------------------------------------
    --! @brief Image Stream の 属性(Attribute)信号の定義
    -------------------------------------------------------------------------------
    type      IMAGE_STREAM_ATRB_TYPE       is record
                  VALID             :  boolean;  -- (チャネル or 列 or 行の)有効な要素であることを示すフラグ
                  START             :  boolean;  -- (チャネル or 列 or 行の)最初の要素であることを示すフラグ
                  LAST              :  boolean;  -- (チャネル or 列 or 行の)最後の要素であることを示すフラグ
    end record;
    type      IMAGE_STREAM_ATRB_VECTOR     is array (integer range <>) of IMAGE_STREAM_ATRB_TYPE;
    constant  IMAGE_STREAM_ATRB_BITS       :  integer := 3;
    constant  IMAGE_STREAM_ATRB_VALID_POS  :  integer := 0;
    constant  IMAGE_STREAM_ATRB_START_POS  :  integer := 1;
    constant  IMAGE_STREAM_ATRB_LAST_POS   :  integer := 2;
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
    type      IMAGE_STREAM_DATA_PARAM_TYPE is record
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
    --! @brief Image Stream のストライド(移動距離)を定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_STREAM_STRIDE_PARAM_TYPE is record
                  X                 :  integer;
                  Y                 :  integer;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Stream のストライド(移動距離)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_STRIDE_PARAM(X,Y:integer) return IMAGE_STREAM_STRIDE_PARAM_TYPE;

    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_STREAM_PARAM_TYPE is record
                  ELEM_BITS         :  integer;  -- 1要素(Element  )のビット数
                  ATRB_BITS         :  integer;  -- 1属性(Attribute)のビット数
                  INFO_BITS         :  integer;  -- その他情報のビット数
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  DATA              :  IMAGE_STREAM_DATA_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  integer;
                  X                 :  integer;
                  Y                 :  integer)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  X                 :  integer;
                  Y                 :  integer)
                  return               IMAGE_STREAM_PARAM_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から要素を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C                 :  integer;
                  X                 :  integer;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C_LO              :  integer;
                  C_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR;
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR;
    function  GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE;
    function  GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から X 方向の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  X_LO              :  integer;
                  X_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR;
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR;
    function  GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  X                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE;
    function  GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  X                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から  Y方向の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  Y_LO              :  integer;
                  Y_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR;
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR;
    function  GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE;
    function  GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に要素を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  C                 :  in    integer;
                  X                 :  in    integer;
                  Y                 :  in    integer;
                  ELEMENT           :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    procedure SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    procedure SET_ATRB_X_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に Y 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_Y_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    procedure SET_ATRB_Y_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_C_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_C            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_C_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_C            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が列(X方向)の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_X_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  ATRB_X            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    function  IMAGE_STREAM_ATRB_X_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_X            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が列(X方向)の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_X_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  ATRB_X            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    function  IMAGE_STREAM_ATRB_X_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_X            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が行(Y方向)の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_Y_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  ATRB_Y            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    function  IMAGE_STREAM_ATRB_Y_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_Y            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が行(Y方向)の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_Y_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  ATRB_Y            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    function  IMAGE_STREAM_ATRB_Y_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_Y            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_C(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_C(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が列(X方向)の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_X(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    function  IMAGE_STREAM_DATA_IS_START_X(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が行(Y方向)の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_Y(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    function  IMAGE_STREAM_DATA_IS_START_Y(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が列(X方向)の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_X(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    function  IMAGE_STREAM_DATA_IS_LAST_X(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が行(Y方向)の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_Y(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean;
    function  IMAGE_STREAM_DATA_IS_LAST_Y(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
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
    --! @brief Image の形(各辺の大きさ)の各辺(C,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE(
                 LO          :  integer;
                 HI          :  integer;
                 SIZE        :  integer;
                 MAX_SIZE    :  integer;
                 DICIDE_TYPE :  IMAGE_SHAPE_SIDE_DICIDE_TYPE)
                 return         IMAGE_SHAPE_SIDE_TYPE
    is 
        variable param       :  IMAGE_SHAPE_SIDE_TYPE;
    begin
        param.LO          := LO;
        param.HI          := HI;
        param.SIZE        := SIZE;
        param.MAX_SIZE    := MAX_SIZE;
        param.DICIDE_TYPE := DICIDE_TYPE;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,D,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_NONE return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE_SIDE(
                   LO          => 0,
                   HI          => 0,
                   SIZE        => 0,
                   MAX_SIZE    => 0,
                   DICIDE_TYPE => IMAGE_SHAPE_SIDE_DICIDE_NONE);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_AUTO    (MAX_SIZE: integer) return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE_SIDE(
                   LO          => 0,
                   HI          => MAX_SIZE-1,
                   SIZE        => MAX_SIZE,
                   MAX_SIZE    => MAX_SIZE,
                   DICIDE_TYPE => IMAGE_SHAPE_SIDE_DICIDE_AUTO);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_EXTERNAL(MAX_SIZE: integer) return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE_SIDE(
                   LO          => 0,
                   HI          => MAX_SIZE-1,
                   SIZE        => MAX_SIZE,
                   MAX_SIZE    => MAX_SIZE,
                   DICIDE_TYPE => IMAGE_SHAPE_SIDE_DICIDE_EXTERNAL);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_CONSTANT(SIZE    : integer) return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE_SIDE(
                   LO          => 0,
                   HI          => SIZE-1,
                   SIZE        => SIZE,
                   MAX_SIZE    => SIZE,
                   DICIDE_TYPE => IMAGE_SHAPE_SIDE_DICIDE_CONSTANT);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_CONSTANT(LO,HI   : integer) return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE_SIDE(
                   LO          => LO,
                   HI          => HI,
                   SIZE        => HI-LO+1,
                   MAX_SIZE    => HI-LO+1,
                   DICIDE_TYPE => IMAGE_SHAPE_SIDE_DICIDE_CONSTANT);
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE(ELEM_BITS: integer;C,D,X,Y: IMAGE_SHAPE_SIDE_TYPE) return IMAGE_SHAPE_TYPE
    is
        variable param :  IMAGE_SHAPE_TYPE;
    begin
        param.ELEM_BITS := ELEM_BITS;
        param.C         := C;
        param.D         := D;
        param.X         := X;
        param.Y         := Y;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE(ELEM_BITS: integer;C,  X,Y: IMAGE_SHAPE_SIDE_TYPE) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => C,
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   X         => X,
                   Y         => Y);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE(ELEM_BITS:integer;    X,Y: IMAGE_SHAPE_SIDE_TYPE) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   X         => X,
                   Y         => Y);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_AUTO    (ELEM_BITS,C,D,X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_AUTO(C),
                   D         => NEW_IMAGE_SHAPE_SIDE_AUTO(D),
                   X         => NEW_IMAGE_SHAPE_SIDE_AUTO(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_AUTO(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_AUTO    (ELEM_BITS,C,  X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_AUTO(C),
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   X         => NEW_IMAGE_SHAPE_SIDE_AUTO(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_AUTO(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_AUTO    (ELEM_BITS,    X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   X         => NEW_IMAGE_SHAPE_SIDE_AUTO(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_AUTO(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_EXTERNAL(ELEM_BITS,C,D,X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(C),
                   D         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(D),
                   X         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_EXTERNAL(ELEM_BITS,C,  X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(C),
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   X         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_EXTERNAL(ELEM_BITS,    X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   X         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,C,D,X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(C),
                   D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(D),
                   X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,C,  X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(C),
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(Y));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,    X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE,
                   X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(X),
                   Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(Y));
    end function;

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
    --! @brief Image Stream のストライド(移動距離)を設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_STRIDE_PARAM(X,Y:integer) return IMAGE_STREAM_STRIDE_PARAM_TYPE
    is
        variable  param            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
    begin
        param.X := X;
        param.Y := Y;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
        variable  param             :  IMAGE_STREAM_PARAM_TYPE;
    begin
        param.ELEM_BITS         := ELEM_BITS;
        param.ATRB_BITS         := IMAGE_STREAM_ATRB_BITS;
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
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin 
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => SHAPE    ,
                  STRIDE            => STRIDE   ,
                  BORDER_TYPE       => IMAGE_STREAM_BORDER_NONE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => SHAPE    ,
                  STRIDE            => STRIDE   ,
                  BORDER_TYPE       => IMAGE_STREAM_BORDER_NONE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => SHAPE    ,
                  STRIDE            => STRIDE   ,
                  BORDER_TYPE       => IMAGE_STREAM_BORDER_NONE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => SHAPE    ,
                  STRIDE            => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => SHAPE    ,
                  STRIDE            => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,C,X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,C,X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  C                 :  integer;
                  X                 :  integer;
                  Y                 :  integer)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,C,X,Y)
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  X                 :  integer;
                  Y                 :  integer)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => 0        ,
                  SHAPE             => NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,X,Y)
               );
    end function; 

    -------------------------------------------------------------------------------
    --! @brief std_logic_vector を Attribute に変換する関数
    -------------------------------------------------------------------------------
    function  to_atrb_type(
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE
    is
        alias     atrb_data         :  std_logic_vector(IMAGE_STREAM_ATRB_BITS-1 downto 0) is DATA;
        variable  atrb              :  IMAGE_STREAM_ATRB_TYPE;
    begin
        atrb.VALID := (atrb_data(IMAGE_STREAM_ATRB_VALID_POS) = '1');
        atrb.START := (atrb_data(IMAGE_STREAM_ATRB_START_POS) = '1');
        atrb.LAST  := (atrb_data(IMAGE_STREAM_ATRB_LAST_POS ) = '1');
        return atrb;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Attribute を std_logic_vector に変換する関数
    -------------------------------------------------------------------------------
    function  to_std_logic_vector(
                  ATRB              :  IMAGE_STREAM_ATRB_TYPE)
                  return               std_logic_vector
    is
        variable  atrb_data         :  std_logic_vector(IMAGE_STREAM_ATRB_BITS-1 downto 0);
    begin
        if (ATRB.VALID = TRUE) then
            atrb_data(IMAGE_STREAM_ATRB_VALID_POS) := '1';
        else
            atrb_data(IMAGE_STREAM_ATRB_VALID_POS) := '0';
        end if;
        if (ATRB.START = TRUE) then
            atrb_data(IMAGE_STREAM_ATRB_START_POS) := '1';
        else
            atrb_data(IMAGE_STREAM_ATRB_START_POS) := '0';
        end if;
        if (ATRB.LAST  = TRUE) then
            atrb_data(IMAGE_STREAM_ATRB_LAST_POS ) := '1';
        else
            atrb_data(IMAGE_STREAM_ATRB_LAST_POS ) := '0';
        end if;
        return atrb_data;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から要素を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
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
    --! @brief Image Stream Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C_LO              :  integer;
                  C_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
        variable  atrb_c_vector     :  IMAGE_STREAM_ATRB_VECTOR(C_LO to C_HI);
    begin
        for i in atrb_c_vector'range loop
            atrb_c_vector(i) := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(PARAM, i, DATA);
        end loop;
        return atrb_c_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
        variable  atrb_c_vector     :  IMAGE_STREAM_ATRB_VECTOR(PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI);
    begin
        for i in atrb_c_vector'range loop
            atrb_c_vector(i) := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(PARAM, i, DATA);
        end loop;
        return atrb_c_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
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
    --! @brief Image Stream Data から Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE
    is
        variable  atrb_c_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_c_data := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(PARAM, C, DATA);
        return to_atrb_type(atrb_c_data);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  X_LO              :  integer;
                  X_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
        variable  atrb_x_vector     :  IMAGE_STREAM_ATRB_VECTOR(X_LO to X_HI);
    begin
        for i in atrb_x_vector'range loop
            atrb_x_vector(i) := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(PARAM, i, DATA);
        end loop;
        return atrb_x_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
        variable  atrb_x_vector     :  IMAGE_STREAM_ATRB_VECTOR(PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI);
    begin
        for i in atrb_x_vector'range loop
            atrb_x_vector(i) := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(PARAM, i, DATA);
        end loop;
        return atrb_x_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
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
    --! @brief Image Stream Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  X                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE
    is
        variable  atrb_x_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_x_data := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(PARAM, X, DATA);
        return to_atrb_type(atrb_x_data);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  Y_LO              :  integer;
                  Y_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
        variable  atrb_y_vector     :  IMAGE_STREAM_ATRB_VECTOR(Y_LO to Y_HI);
    begin
        for i in atrb_y_vector'range loop
            atrb_y_vector(i) := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(PARAM, i, DATA);
        end loop;
        return atrb_y_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
        variable  atrb_y_vector     :  IMAGE_STREAM_ATRB_VECTOR(PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI);
    begin
        for i in atrb_y_vector'range loop
            atrb_y_vector(i) := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(PARAM, i, DATA);
        end loop;
        return atrb_y_vector;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
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
    --! @brief Image Stream Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE
    is
        variable  atrb_y_data       :  std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    begin
        atrb_y_data := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(PARAM, Y, DATA);
        return to_atrb_type(atrb_y_data);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に要素を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
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
    --! @brief Image Stream Data に Column の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA((C-PARAM.SHAPE.C.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_C_FIELD.LO downto
             (C-PARAM.SHAPE.C.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_C_FIELD.LO) := ATRB;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に Column の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_C_TO_IMAGE_STREAM_DATA(
            PARAM => PARAM,
            C     => C,
            ATRB  => to_std_logic_vector(ATRB),
            DATA  => DATA
        );
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA((X-PARAM.SHAPE.X.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_X_FIELD.LO downto
             (X-PARAM.SHAPE.X.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_X_FIELD.LO) := ATRB;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  X                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_X_TO_IMAGE_STREAM_DATA(
            PARAM => PARAM,
            X     => X,
            ATRB  => to_std_logic_vector(ATRB),
            DATA  => DATA
        );
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に Y 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_Y_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA((Y-PARAM.SHAPE.Y.LO+1)*PARAM.ATRB_BITS-1 + PARAM.DATA.ATRB_Y_FIELD.LO downto
             (Y-PARAM.SHAPE.Y.LO  )*PARAM.ATRB_BITS   + PARAM.DATA.ATRB_Y_FIELD.LO) := ATRB;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に Y 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_Y_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  Y                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_Y_TO_IMAGE_STREAM_DATA(
            PARAM => PARAM,
            Y     => Y,
            ATRB  => to_std_logic_vector(ATRB),
            DATA  => DATA
        );
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream の属性をチェックする関数
    -------------------------------------------------------------------------------
    function  CHECK_IMAGE_STREAM_ATRB(
                  ATRB              :  IMAGE_STREAM_ATRB_TYPE;
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
    --! @brief Image Stream の属性をチェックする関数
    -------------------------------------------------------------------------------
    function  CHECK_IMAGE_STREAM_ATRB(
                  ATRB_VEC          :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE;
                  START             :  boolean := FALSE;
                  LAST              :  boolean := FALSE)
                  return               boolean
    is
        variable  ret_value         :  boolean;
    begin
        ret_value := FALSE;
        for i in ATRB_VEC'range loop
            if (CHECK_IMAGE_STREAM_ATRB(ATRB_VEC(i), VALID, START, LAST) = TRUE) then
                ret_value := TRUE;
            end if;
        end loop;
        return ret_value;
    end function;
        
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_C_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_C            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return CHECK_IMAGE_STREAM_ATRB(
                  ATRB_VEC => ATRB_C(PARAM.SHAPE.C.LO to PARAM.SHAPE.C.LO),
                  VALID    => VALID,
                  START    => TRUE,
                  LAST     => FALSE
               );
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_C_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_C            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return CHECK_IMAGE_STREAM_ATRB(
                  ATRB_VEC => ATRB_C(PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI),
                  VALID    => VALID,
                  START    => FALSE,
                  LAST     => TRUE
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が列(X方向)の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_X_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  ATRB_X            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        if (BORDER = IMAGE_STREAM_BORDER_NONE) then
            return CHECK_IMAGE_STREAM_ATRB(
                       ATRB_VEC => ATRB_X(PARAM.SHAPE.X.LO to PARAM.SHAPE.X.LO+(PARAM.STRIDE.X-1)),
                       VALID    => VALID,
                       START    => TRUE,
                       LAST     => FALSE
                   );
        else
            return CHECK_IMAGE_STREAM_ATRB(
                       ATRB_VEC => ATRB_X(PARAM.SHAPE.X.LO to 0+(PARAM.STRIDE.X-1)),
                       VALID    => VALID,
                       START    => TRUE,
                       LAST     => FALSE
                   );
        end if;
    end function;

    function  IMAGE_STREAM_ATRB_X_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_X            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_X_VECTOR_IS_START(PARAM, PARAM.BORDER_TYPE, ATRB_X, VALID);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が列(X方向)の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_X_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  ATRB_X            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        if (BORDER = IMAGE_STREAM_BORDER_NONE) then
            return CHECK_IMAGE_STREAM_ATRB(
                       ATRB_VEC => ATRB_X(PARAM.SHAPE.X.HI-(PARAM.STRIDE.X-1) to PARAM.SHAPE.X.HI),
                       VALID    => VALID,
                       START    => FALSE,
                       LAST     => TRUE
                   );
        else
            return CHECK_IMAGE_STREAM_ATRB(
                       ATRB_VEC => ATRB_X(0-(PARAM.STRIDE.X-1) to PARAM.SHAPE.X.HI),
                       VALID    => VALID,
                       START    => FALSE,
                       LAST     => TRUE
                   );
        end if;
    end function;
    
    function  IMAGE_STREAM_ATRB_X_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_X            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_X_VECTOR_IS_LAST(PARAM, PARAM.BORDER_TYPE, ATRB_X, VALID);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が行(Y方向)の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_Y_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  ATRB_Y            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        if (BORDER = IMAGE_STREAM_BORDER_NONE) then
            return CHECK_IMAGE_STREAM_ATRB(
                       ATRB_VEC => ATRB_Y(PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.LO+(PARAM.STRIDE.Y-1)),
                       VALID    => VALID,
                       START    => TRUE,
                       LAST     => FALSE
                   );
        else
            return CHECK_IMAGE_STREAM_ATRB(
                       ATRB_VEC => ATRB_Y(PARAM.SHAPE.Y.LO to 0+(PARAM.STRIDE.Y-1)),
                       VALID    => VALID,
                       START    => TRUE,
                       LAST     => FALSE
                   );
        end if;
    end function;
    
    function  IMAGE_STREAM_ATRB_Y_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_Y            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_Y_VECTOR_IS_START(PARAM, PARAM.BORDER_TYPE, ATRB_Y, VALID);
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が行(Y方向)の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_Y_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  ATRB_Y            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        if (PARAM.BORDER_TYPE = IMAGE_STREAM_BORDER_NONE) then
            return CHECK_IMAGE_STREAM_ATRB(
                       ATRB_VEC => ATRB_Y(PARAM.SHAPE.Y.HI-(PARAM.STRIDE.Y-1) to PARAM.SHAPE.Y.HI),
                       VALID    => VALID,
                       START    => FALSE,
                       LAST     => TRUE
                   );
        else
            return CHECK_IMAGE_STREAM_ATRB(
                       ATRB_VEC => ATRB_Y(0-(PARAM.STRIDE.Y-1) to PARAM.SHAPE.Y.HI),
                       VALID    => VALID,
                       START    => FALSE,
                       LAST     => TRUE
                   );
        end if;
    end function;

    function  IMAGE_STREAM_ATRB_Y_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_Y            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_Y_VECTOR_IS_LAST(PARAM, PARAM.BORDER_TYPE, ATRB_Y, VALID);
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream が Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_C(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
        variable  atrb_c            :  IMAGE_STREAM_ATRB_TYPE;
    begin 
        return IMAGE_STREAM_ATRB_C_VECTOR_IS_START(
                  PARAM   => PARAM, 
                  ATRB_C  => GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream が Channel の有効な最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_C(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_C_VECTOR_IS_LAST(
                  PARAM   => PARAM, 
                  ATRB_C  => GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream が列(X方向)の有効な最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_X(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_X_VECTOR_IS_START(
                  PARAM   => PARAM ,
                  BORDER  => BORDER,
                  ATRB_X  => GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;

    function  IMAGE_STREAM_DATA_IS_START_X(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin 
        return IMAGE_STREAM_ATRB_X_VECTOR_IS_START(
                  PARAM   => PARAM ,
                  ATRB_X  => GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;
            
    -------------------------------------------------------------------------------
    --! @brief Image Stream が行(Y方向)の有効な最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_Y(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_Y_VECTOR_IS_START(
                  PARAM   => PARAM ,
                  BORDER  => BORDER,
                  ATRB_Y  => GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;

    function  IMAGE_STREAM_DATA_IS_START_Y(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_Y_VECTOR_IS_START(
                  PARAM   => PARAM ,
                  ATRB_Y  => GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream が列(X方向)の有効な最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_X(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_X_VECTOR_IS_LAST(
                  PARAM   => PARAM ,
                  BORDER  => BORDER,
                  ATRB_X  => GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;

    function  IMAGE_STREAM_DATA_IS_LAST_X(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_X_VECTOR_IS_LAST(
                  PARAM   => PARAM ,
                  ATRB_X  => GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream が行(Y方向)の有効な最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_Y(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  BORDER            :  IMAGE_STREAM_BORDER_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_Y_VECTOR_IS_LAST(
                  PARAM   => PARAM ,
                  BORDER  => BORDER,
                  ATRB_Y  => GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;

    function  IMAGE_STREAM_DATA_IS_LAST_Y(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := FALSE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_Y_VECTOR_IS_LAST(
                  PARAM   => PARAM ,
                  ATRB_Y  => GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;
    
end IMAGE_TYPES;
