-----------------------------------------------------------------------------------
--!     @file    image_types.vhd
--!     @brief   Image Types Package.
--!     @version 1.8.0
--!     @date    2019/3/22
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
                  IMAGE_SHAPE_SIDE_DICIDE_CONSTANT , -- 指定された値で常に静的に決める.
                  IMAGE_SHAPE_SIDE_DICIDE_EXTERNAL , -- 外部からの信号で動的に決める.
                  IMAGE_SHAPE_SIDE_DICIDE_AUTO       -- 各モジュール内部で自動計算する.
    );
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺の値を定義.
    -------------------------------------------------------------------------------
    type      IMAGE_SHAPE_SIDE_TYPE        is record
                  DICIDE_TYPE              :  IMAGE_SHAPE_SIDE_DICIDE_TYPE;
                  ELEM_IN_DATA             :  boolean;  -- DATA ELEM FIELD を持っているか否か(DICIDE_CONSTANTのみ有効)
                  ATRB_IN_DATA             :  boolean;  -- DATA ATRB FIELD を持っているか否か(DICIDE_CONSTANTのみ有効)
                  LO                       :  integer;  -- 範囲の最小値(DICIDE_CONSTANTのみ設定可)
                  HI                       :  integer;  -- 範囲の最大値(DICIDE_CONSTANTのみ設定可)
                  SIZE                     :  integer;  -- 辺の大きさ  (DICIDE_CONSTANTのみ有効)
                  MAX_SIZE                 :  integer;  -- 辺の最大値  (DICIDE_AUTOおよびDICIDE_EXTERNALのみ有効)
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,D,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_AUTO    (MAX_SIZE: integer) return IMAGE_SHAPE_SIDE_TYPE;
    function  NEW_IMAGE_SHAPE_SIDE_EXTERNAL(MAX_SIZE: integer) return IMAGE_SHAPE_SIDE_TYPE;
    function  NEW_IMAGE_SHAPE_SIDE_CONSTANT(SIZE    : integer; ELEM_IN_DATA: boolean := TRUE; ATRB_IN_DATA: boolean := TRUE) return IMAGE_SHAPE_SIDE_TYPE;
    function  NEW_IMAGE_SHAPE_SIDE_CONSTANT(LO,HI   : integer; ELEM_IN_DATA: boolean := TRUE; ATRB_IN_DATA: boolean := TRUE) return IMAGE_SHAPE_SIDE_TYPE;

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
    --! @brief IMAGE_STREAM_ATRB_VECTOR を生成する関数群
    -------------------------------------------------------------------------------
    function  GENERATE_IMAGE_STREAM_ATRB_VECTOR(VALID: std_logic_vector;START,LAST: boolean  ) return IMAGE_STREAM_ATRB_VECTOR;
    function  GENERATE_IMAGE_STREAM_ATRB_VECTOR(VALID: std_logic_vector;START,LAST: std_logic) return IMAGE_STREAM_ATRB_VECTOR;

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
    --! @brief Image Stream Data(一回の転送単位) の要素フィールドを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_STREAM_DATA_ELEM_FIELD_TYPE is record
                  LO                :  integer;
                  HI                :  integer;
                  SIZE              :  integer;
                  C_SIZE            :  integer;
                  D_SIZE            :  integer;
                  X_SIZE            :  integer;
                  Y_SIZE            :  integer;
    end record;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data(一回の転送単位) の属性フィールドを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_STREAM_DATA_ATRB_FIELD_TYPE is record
                  LO                :  integer;
                  HI                :  integer;
                  SIZE              :  integer;
                  C                 :  IMAGE_VECTOR_RANGE_TYPE;
                  D                 :  IMAGE_VECTOR_RANGE_TYPE;
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE;
    end record;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data(一回の転送単位) の各種パラメータを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      IMAGE_STREAM_DATA_FIELD_TYPE is record
                  LO                :  integer;
                  HI                :  integer;
                  SIZE              :  integer;
                  ELEM_FIELD        :  IMAGE_STREAM_DATA_ELEM_FIELD_TYPE;
                  INFO_FIELD        :  IMAGE_VECTOR_RANGE_TYPE;
                  ATRB_FIELD        :  IMAGE_STREAM_DATA_ATRB_FIELD_TYPE;
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
                  DATA              :  IMAGE_STREAM_DATA_FIELD_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  D                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  D                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE;
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
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
                  D                 :  integer;
                  X                 :  integer;
                  Y                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から C Channel の属性を取り出す関数
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
    --! @brief Image Stream Data から D Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_D_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  D_LO              :  integer;
                  D_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR;
    function  GET_ATRB_D_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR;
    function  GET_ATRB_D_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  D                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE;
    function  GET_ATRB_D_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  D                 :  integer;
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
    --! @brief Image Stream Data から Y 方向の属性を取り出す関数
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
                  D                 :  in    integer;
                  X                 :  in    integer;
                  Y                 :  in    integer;
                  ELEMENT           :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief IMAGE_STREAM_ATRB_VECTOR を生成する関数.
    -------------------------------------------------------------------------------
    procedure SET_ATRB_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in   IMAGE_STREAM_PARAM_TYPE;
                  ATRB_C_VEC        :  in   IMAGE_STREAM_ATRB_VECTOR;
                  ATRB_D_VEC        :  in   IMAGE_STREAM_ATRB_VECTOR;
                  ATRB_X_VEC        :  in   IMAGE_STREAM_ATRB_VECTOR;
                  ATRB_Y_VEC        :  in   IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に C Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC          :  in    IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector);
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
    --! @brief Image Stream Data に D Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_D_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC          :  in    IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector);
    procedure SET_ATRB_D_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  D                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector);
    procedure SET_ATRB_D_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  D                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector);
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC          :  in    IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector);
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
    procedure SET_ATRB_Y_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC          :  in    IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector);
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
    --! @brief Image Stream Attribute が C Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_C_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_C            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が C Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_C_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_C            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が D Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_D_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_D            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が D Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_D_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_D            :  IMAGE_STREAM_ATRB_VECTOR;
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
    --! @brief Image Stream が C Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_C(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が C Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_C(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が D Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_D(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean;
    -------------------------------------------------------------------------------
    --! @brief Image Stream が D Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_D(
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
    --! @brief Image の形(各辺の大きさ)の各辺(C,D,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE(
                 LO          :  integer;
                 HI          :  integer;
                 SIZE        :  integer;
                 MAX_SIZE    :  integer;
                 ELEM_IN_DATA:  boolean;
                 ATRB_IN_DATA:  boolean;
                 DICIDE_TYPE :  IMAGE_SHAPE_SIDE_DICIDE_TYPE)
                 return         IMAGE_SHAPE_SIDE_TYPE
    is 
        variable param       :  IMAGE_SHAPE_SIDE_TYPE;
    begin
        param.LO             := LO;
        param.HI             := HI;
        param.SIZE           := SIZE;
        param.MAX_SIZE       := MAX_SIZE;
        param.ELEM_IN_DATA   := ELEM_IN_DATA;
        param.ATRB_IN_DATA   := ATRB_IN_DATA;
        param.DICIDE_TYPE    := DICIDE_TYPE;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,D,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_NONE return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE_SIDE(
                   LO           => 0,
                   HI           => 0,
                   SIZE         => 1,
                   MAX_SIZE     => 1,
                   ELEM_IN_DATA => FALSE,
                   ATRB_IN_DATA => FALSE,
                   DICIDE_TYPE  => IMAGE_SHAPE_SIDE_DICIDE_CONSTANT);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,D,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_AUTO    (MAX_SIZE: integer) return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        assert (MAX_SIZE > 0) report "NEW_IMAGE_SHAPE_SIDE_AUTO: Error MAX_SIZE=0." severity FAILURE;
        return NEW_IMAGE_SHAPE_SIDE(
                   LO           => 0,
                   HI           => MAX_SIZE-1,
                   SIZE         => MAX_SIZE,
                   MAX_SIZE     => MAX_SIZE,
                   ELEM_IN_DATA => FALSE,
                   ATRB_IN_DATA => FALSE,
                   DICIDE_TYPE  => IMAGE_SHAPE_SIDE_DICIDE_AUTO);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,D,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_EXTERNAL(MAX_SIZE: integer) return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        assert (MAX_SIZE > 0) report "NEW_IMAGE_SHAPE_SIDE_EXTERNAL: Error MAX_SIZE=0." severity FAILURE;
        return NEW_IMAGE_SHAPE_SIDE(
                   LO           => 0,
                   HI           => MAX_SIZE-1,
                   SIZE         => MAX_SIZE,
                   MAX_SIZE     => MAX_SIZE,
                   ELEM_IN_DATA => FALSE,
                   ATRB_IN_DATA => FALSE,
                   DICIDE_TYPE  => IMAGE_SHAPE_SIDE_DICIDE_EXTERNAL);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_CONSTANT(SIZE    : integer; ELEM_IN_DATA: boolean := TRUE; ATRB_IN_DATA: boolean := TRUE) return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        if (SIZE > 0) then
            return NEW_IMAGE_SHAPE_SIDE(
                       LO           => 0,
                       HI           => SIZE-1,
                       SIZE         => SIZE,
                       MAX_SIZE     => SIZE,
                       ELEM_IN_DATA => ELEM_IN_DATA,
                       ATRB_IN_DATA => ATRB_IN_DATA,
                       DICIDE_TYPE  => IMAGE_SHAPE_SIDE_DICIDE_CONSTANT);
        else
            return NEW_IMAGE_SHAPE_SIDE_NONE;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)の各辺(C,X,Y) の値を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_SIDE_CONSTANT(LO,HI   : integer; ELEM_IN_DATA: boolean := TRUE; ATRB_IN_DATA: boolean := TRUE) return IMAGE_SHAPE_SIDE_TYPE
    is
    begin
        if (HI >= LO) then
            return NEW_IMAGE_SHAPE_SIDE(
                       LO           => LO,
                       HI           => HI,
                       SIZE         => HI-LO+1,
                       MAX_SIZE     => HI-LO+1,
                       ELEM_IN_DATA => ELEM_IN_DATA,
                       ATRB_IN_DATA => ATRB_IN_DATA,
                       DICIDE_TYPE  => IMAGE_SHAPE_SIDE_DICIDE_CONSTANT);
        else
            return NEW_IMAGE_SHAPE_SIDE_NONE;
        end if;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE(ELEM_BITS: integer;C,D,X,Y: IMAGE_SHAPE_SIDE_TYPE) return IMAGE_SHAPE_TYPE
    is
        variable param  :  IMAGE_SHAPE_TYPE;
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
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE   ,
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
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE       ,
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
                   C         => NEW_IMAGE_SHAPE_SIDE_NONE       ,
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE       ,
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
                   C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(C, TRUE,  TRUE),
                   D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(D, FALSE, TRUE),
                   X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(X, TRUE , TRUE),
                   Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(Y, TRUE , TRUE));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,C,  X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(C, TRUE, TRUE),
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE                   ,
                   X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(X, TRUE, TRUE),
                   Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(Y, TRUE, TRUE));
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image の形(各辺の大きさ)を設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_SHAPE_CONSTANT(ELEM_BITS,    X,Y: integer) return IMAGE_SHAPE_TYPE
    is
    begin
        return NEW_IMAGE_SHAPE(
                   ELEM_BITS => ELEM_BITS,
                   C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE, FALSE),
                   D         => NEW_IMAGE_SHAPE_SIDE_NONE                    ,
                   X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(X, TRUE, TRUE ),
                   Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(Y, TRUE, TRUE ));
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
    function  NEW_IMAGE_VECTOR_RANGE(LO,HI:integer;
                                     SIZE :integer) return IMAGE_VECTOR_RANGE_TYPE
    is
        variable param :  IMAGE_VECTOR_RANGE_TYPE;
    begin
        param.LO   := LO;
        param.HI   := HI;
        param.SIZE := SIZE;
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
    --! @brief Image Stream の DATA の要素(Element)フィールドを設定する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_DATA_ELEM_FIELD(
                  ELEM_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE)
                  return               IMAGE_STREAM_DATA_ELEM_FIELD_TYPE
    is
        variable  elem_field        :  IMAGE_STREAM_DATA_ELEM_FIELD_TYPE;
        variable  elem_size         :  integer;
    begin
        elem_size := 1;
        if (SHAPE.C.ELEM_IN_DATA = TRUE) then
            elem_field.C_SIZE := elem_size;
            elem_size         := elem_size * SHAPE.C.SIZE;
        else
            elem_field.C_SIZE := 0;
        end if;
        if (SHAPE.D.ELEM_IN_DATA = TRUE) then
            elem_field.D_SIZE := elem_size;
            elem_size         := elem_size * SHAPE.D.SIZE;
        else
            elem_field.D_SIZE := 0;
        end if;
        if (SHAPE.X.ELEM_IN_DATA = TRUE) then
            elem_field.X_SIZE := elem_size;
            elem_size         := elem_size * SHAPE.X.SIZE;
        else
            elem_field.X_SIZE := 0;
        end if;
        if (SHAPE.Y.ELEM_IN_DATA = TRUE) then
            elem_field.Y_SIZE := elem_size;
            elem_size         := elem_size * SHAPE.Y.SIZE;
        else
            elem_field.Y_SIZE := 0;
        end if;
        elem_field.SIZE   := ELEM_BITS * elem_size;
        elem_field.LO     := 0;
        elem_field.HI     := elem_field.SIZE-1;
        return elem_field;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream の DATA の属性フィールドを設定する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_DATA_ATRB_FIELD(
                  LO                :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE)
                  return               IMAGE_STREAM_DATA_ATRB_FIELD_TYPE
    is
        variable  atrb_field        :  IMAGE_STREAM_DATA_ATRB_FIELD_TYPE;
        variable  next_field_lo     :  integer;
        variable  atrb_field_size   :  integer;
    begin
        atrb_field.LO   := LO;
        next_field_lo   := LO;
        atrb_field_size := 0;
        if (SHAPE.C.ATRB_IN_DATA = TRUE) then
            atrb_field.C    := NEW_IMAGE_VECTOR_RANGE(LO => next_field_lo, HI => next_field_lo + IMAGE_STREAM_ATRB_BITS*SHAPE.C.SIZE - 1);
            next_field_lo   := atrb_field.C.HI + 1;
            atrb_field_size := atrb_field_size + atrb_field.C.SIZE;
        end if;
        if (SHAPE.D.ATRB_IN_DATA = TRUE) then
            atrb_field.D    := NEW_IMAGE_VECTOR_RANGE(LO => next_field_lo, HI => next_field_lo + IMAGE_STREAM_ATRB_BITS*SHAPE.D.SIZE - 1);
            next_field_lo   := atrb_field.D.HI + 1;
            atrb_field_size := atrb_field_size + atrb_field.D.SIZE;
        end if;
        if (SHAPE.X.ATRB_IN_DATA = TRUE) then
            atrb_field.X    := NEW_IMAGE_VECTOR_RANGE(LO => next_field_lo, HI => next_field_lo + IMAGE_STREAM_ATRB_BITS*SHAPE.X.SIZE - 1);
            next_field_lo   := atrb_field.X.HI + 1;
            atrb_field_size := atrb_field_size + atrb_field.X.SIZE;
        end if;
        if (SHAPE.Y.ATRB_IN_DATA = TRUE) then
            atrb_field.Y    := NEW_IMAGE_VECTOR_RANGE(LO => next_field_lo, HI => next_field_lo + IMAGE_STREAM_ATRB_BITS*SHAPE.Y.SIZE - 1);
            next_field_lo   := atrb_field.Y.HI + 1;
            atrb_field_size := atrb_field_size + atrb_field.Y.SIZE;
        end if;
        if (SHAPE.C.ATRB_IN_DATA = FALSE) then
            atrb_field.C    := NEW_IMAGE_VECTOR_RANGE(LO => next_field_lo, HI => next_field_lo, SIZE => 0);
        end if;
        if (SHAPE.D.ATRB_IN_DATA = FALSE) then
            atrb_field.D    := NEW_IMAGE_VECTOR_RANGE(LO => next_field_lo, HI => next_field_lo, SIZE => 0);
        end if;
        if (SHAPE.X.ATRB_IN_DATA = FALSE) then
            atrb_field.X    := NEW_IMAGE_VECTOR_RANGE(LO => next_field_lo, HI => next_field_lo, SIZE => 0);
        end if;
        if (SHAPE.Y.ATRB_IN_DATA = FALSE) then
            atrb_field.Y    := NEW_IMAGE_VECTOR_RANGE(LO => next_field_lo, HI => next_field_lo, SIZE => 0);
        end if;
        if (atrb_field_size > 0) then
            atrb_field.SIZE := atrb_field_size;
            atrb_field.HI   := atrb_field.LO + atrb_field_size - 1;
        else
            atrb_field.SIZE := 0;
            atrb_field.HI   := atrb_field.LO;
        end if;
        return atrb_field;
    end function;
        
    -------------------------------------------------------------------------------
    --! @brief Image Stream の DATA の情報フィールドを設定する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_DATA_INFO_FIELD(LO, BITS: integer) return IMAGE_VECTOR_RANGE_TYPE
    is
    begin
        if (BITS > 0) then
            return NEW_IMAGE_VECTOR_RANGE(LO => LO, HI => LO + BITS - 1);
        else
            return NEW_IMAGE_VECTOR_RANGE(LO => LO, HI => LO, SIZE => 0);
        end if;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream の DATAフィールドを設定する関数.
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_DATA_FIELD(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE)
                  return               IMAGE_STREAM_DATA_FIELD_TYPE
    is
        variable  data_field        :  IMAGE_STREAM_DATA_FIELD_TYPE;
        variable  data_field_size   :  integer;
        variable  next_field_lo     :  integer;
    begin
        data_field.LO         := 0;
        data_field_size       := 0;

        data_field.ELEM_FIELD := NEW_IMAGE_STREAM_DATA_ELEM_FIELD(ELEM_BITS    , SHAPE);
        next_field_lo         := data_field.ELEM_FIELD.HI + 1;
        data_field_size       := data_field_size + data_field.ELEM_FIELD.SIZE;

        data_field.ATRB_FIELD := NEW_IMAGE_STREAM_DATA_ATRB_FIELD(next_field_lo, SHAPE);
        next_field_lo         := data_field.ATRB_FIELD.HI + 1;
        data_field_size       := data_field_size + data_field.ATRB_FIELD.SIZE;

        data_field.INFO_FIELD := NEW_IMAGE_STREAM_DATA_INFO_FIELD(next_field_lo, INFO_BITS);
        data_field_size       := data_field_size + data_field.INFO_FIELD.SIZE;

        data_field.SIZE       := data_field_size;
        data_field.HI         := data_field.LO + data_field_size - 1;
        return data_field; 
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
        variable  param             :  IMAGE_STREAM_PARAM_TYPE;
    begin
        assert (ELEM_BITS > 0)
            report "NEW_IMAGE_STREAM_PARAM: Error ELEM_BITS=0." severity FAILURE;
        assert (SHAPE.C.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT)
            report "NEW_IMAGE_STREAM_PARAM: Error SHAPE.C.DICIDE_TYPE." severity FAILURE;
        assert (SHAPE.D.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT)
            report "NEW_IMAGE_STREAM_PARAM: Error SHAPE.D.DICIDE_TYPE." severity FAILURE;
        assert (SHAPE.X.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT)
            report "NEW_IMAGE_STREAM_PARAM: Error SHAPE.X.DICIDE_TYPE." severity FAILURE;
        assert (SHAPE.Y.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT)
            report "NEW_IMAGE_STREAM_PARAM: Error SHAPE.Y.DICIDE_TYPE." severity FAILURE;
        param.ELEM_BITS   := ELEM_BITS;
        param.ATRB_BITS   := IMAGE_STREAM_ATRB_BITS;
        param.INFO_BITS   := INFO_BITS;
        param.SHAPE       := SHAPE;
        param.STRIDE      := STRIDE;
        param.BORDER_TYPE := BORDER_TYPE;
        param.DATA        := NEW_IMAGE_STREAM_DATA_FIELD(ELEM_BITS, INFO_BITS, SHAPE);
        return param;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => SHAPE    ,
                  STRIDE            => NEW_IMAGE_STREAM_STRIDE_PARAM(SHAPE.X.SIZE, SHAPE.Y.SIZE),
                  BORDER_TYPE       => BORDER_TYPE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  D                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,C,D,X,Y),
                  STRIDE            => STRIDE,
                  BORDER_TYPE       => BORDER_TYPE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  D                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,C,D,X,Y),
                  STRIDE            => NEW_IMAGE_STREAM_STRIDE_PARAM(X.SIZE, Y.SIZE),
                  BORDER_TYPE       => BORDER_TYPE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,C,X,Y),
                  STRIDE            => STRIDE,
                  BORDER_TYPE       => BORDER_TYPE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  C                 :  IMAGE_SHAPE_SIDE_TYPE;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,C,X,Y),
                  STRIDE            => NEW_IMAGE_STREAM_STRIDE_PARAM(X.SIZE, Y.SIZE),
                  BORDER_TYPE       => BORDER_TYPE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,X,Y),
                  STRIDE            => STRIDE,
                  BORDER_TYPE       => BORDER_TYPE
               );
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の各種パラメータをを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         :  integer;
                  INFO_BITS         :  integer := 0;
                  X                 :  IMAGE_SHAPE_SIDE_TYPE;
                  Y                 :  IMAGE_SHAPE_SIDE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               IMAGE_STREAM_PARAM_TYPE
    is
    begin
        return NEW_IMAGE_STREAM_PARAM(
                  ELEM_BITS         => ELEM_BITS,
                  INFO_BITS         => INFO_BITS,
                  SHAPE             => NEW_IMAGE_SHAPE(ELEM_BITS,X,Y),
                  STRIDE            => NEW_IMAGE_STREAM_STRIDE_PARAM(X.SIZE, Y.SIZE),
                  BORDER_TYPE       => BORDER_TYPE
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
    --! @brief Image Stream Data から 指定された辺(C,D,X,Y)の属性を取り出す関数
    -------------------------------------------------------------------------------
    --  * Image Stream Data に 対応する辺の属性フィールドが存在するならば、DATA から
    --    対応するフィールドのベクタを取り出す.
    --  * Image Stream Data に 対応する辺の属性フィールドが存在しないならば、ダミー
    --    データとして .VALID=TRUE,START=TRUE,LAST=TRUE の属性を返す.
    -------------------------------------------------------------------------------
    function  GET_ATRB_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  SHAPE_SIDE        :  IMAGE_SHAPE_SIDE_TYPE;
                  ATRB_FIELD        :  IMAGE_VECTOR_RANGE_TYPE;
                  POS               :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE
    is
        alias     input_data        :  std_logic_vector(PARAM.DATA.SIZE-1 downto 0) is DATA;
        variable  atrb              :  IMAGE_STREAM_ATRB_TYPE;
    begin
        if (ATRB_FIELD.SIZE > 0) then
            assert (POS >= SHAPE_SIDE.LO and POS <= SHAPE_SIDE.HI)
                report "GET_ATRB_FROM_IMAGE_STREAM_DATA: Out of range." severity FAILURE;
            atrb := to_atrb_type(input_data((POS-SHAPE_SIDE.LO+1)*PARAM.ATRB_BITS-1+ATRB_FIELD.LO downto
                                            (POS-SHAPE_SIDE.LO  )*PARAM.ATRB_BITS  +ATRB_FIELD.LO));
        else
            atrb.VALID := TRUE;
            atrb.START := (POS <= SHAPE_SIDE.LO);
            atrb.LAST  := (POS >= SHAPE_SIDE.HI);
        end if;
        return atrb;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から 指定された辺(C,D,X,Y)の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  SHAPE_SIDE        :  IMAGE_SHAPE_SIDE_TYPE;
                  ATRB_FIELD        :  IMAGE_VECTOR_RANGE_TYPE;
                  LO                :  integer;
                  HI                :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
        variable  atrb_vector       :  IMAGE_STREAM_ATRB_VECTOR(LO to HI);
    begin
        for i in atrb_vector'range loop
            atrb_vector(i) := GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, SHAPE_SIDE, ATRB_FIELD, i, DATA);
        end loop;
        return atrb_vector;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から 指定された辺(C,D,X,Y)の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  SHAPE_SIDE        :  IMAGE_SHAPE_SIDE_TYPE;
                  ATRB_FIELD        :  IMAGE_VECTOR_RANGE_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
        variable  atrb_vector       :  IMAGE_STREAM_ATRB_VECTOR(SHAPE_SIDE.LO to SHAPE_SIDE.HI);
    begin
        for i in atrb_vector'range loop
            atrb_vector(i) := GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, SHAPE_SIDE, ATRB_FIELD, i, DATA);
        end loop;
        return atrb_vector;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から要素を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C                 :  integer;
                  D                 :  integer;
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
        element   := elem_data(((Y-PARAM.SHAPE.Y.LO)*PARAM.DATA.ELEM_FIELD.Y_SIZE +
                                (X-PARAM.SHAPE.X.LO)*PARAM.DATA.ELEM_FIELD.X_SIZE +
                                (D-PARAM.SHAPE.D.LO)*PARAM.DATA.ELEM_FIELD.D_SIZE +
                                (C-PARAM.SHAPE.C.LO)*PARAM.DATA.ELEM_FIELD.C_SIZE + 1)*PARAM.ELEM_BITS-1 downto
                               ((Y-PARAM.SHAPE.Y.LO)*PARAM.DATA.ELEM_FIELD.Y_SIZE +
                                (X-PARAM.SHAPE.X.LO)*PARAM.DATA.ELEM_FIELD.X_SIZE +
                                (D-PARAM.SHAPE.D.LO)*PARAM.DATA.ELEM_FIELD.D_SIZE +
                                (C-PARAM.SHAPE.C.LO)*PARAM.DATA.ELEM_FIELD.C_SIZE    )*PARAM.ELEM_BITS);
        return element;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から C Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C_LO              :  integer;
                  C_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
    begin
        return GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.C, PARAM.DATA.ATRB_FIELD.C, C_LO, C_HI, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から C Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
    begin
        return GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.C, PARAM.DATA.ATRB_FIELD.C, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から C Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE
    is
    begin
        return GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.C, PARAM.DATA.ATRB_FIELD.C, C, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から C Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  C                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector
    is
    begin
        return to_std_logic_vector(GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.C, PARAM.DATA.ATRB_FIELD.C, C, DATA));
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から D Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_D_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  D_LO              :  integer;
                  D_HI              :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
    begin
        return GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.D, PARAM.DATA.ATRB_FIELD.D, D_LO, D_HI, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から D Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_D_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
    begin
        return GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.D, PARAM.DATA.ATRB_FIELD.D, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から D Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_D_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  D                 :  integer;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_TYPE
    is
    begin
        return GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.D, PARAM.DATA.ATRB_FIELD.D, D, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から D Channel の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_D_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  D                 :  integer;
                  DATA              :  std_logic_vector)
                  return               std_logic_vector
    is
    begin
        return to_std_logic_vector(GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.D, PARAM.DATA.ATRB_FIELD.D, D, DATA));
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
    begin
        return GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.X, PARAM.DATA.ATRB_FIELD.X, X_LO, X_HI, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から X 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
    begin
        return GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.X, PARAM.DATA.ATRB_FIELD.X, DATA);
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
    begin
        return to_std_logic_vector(GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.X, PARAM.DATA.ATRB_FIELD.X, X, DATA));
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
    begin
        return GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.X, PARAM.DATA.ATRB_FIELD.X, X, DATA);
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
    begin
        return GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.Y, PARAM.DATA.ATRB_FIELD.Y, Y_LO, Y_HI, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data から Y 方向 の属性を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector)
                  return               IMAGE_STREAM_ATRB_VECTOR
    is
    begin
        return GET_ATRB_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.Y, PARAM.DATA.ATRB_FIELD.Y, DATA);
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
    begin
        return to_std_logic_vector(GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.Y, PARAM.DATA.ATRB_FIELD.Y, Y, DATA));
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
    begin
        return GET_ATRB_FROM_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.Y, PARAM.DATA.ATRB_FIELD.Y, Y, DATA);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に要素を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  C                 :  in    integer;
                  D                 :  in    integer;
                  X                 :  in    integer;
                  Y                 :  in    integer;
                  ELEMENT           :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        DATA(((Y-PARAM.SHAPE.Y.LO)*PARAM.DATA.ELEM_FIELD.Y_SIZE +
              (X-PARAM.SHAPE.X.LO)*PARAM.DATA.ELEM_FIELD.X_SIZE +
              (D-PARAM.SHAPE.D.LO)*PARAM.DATA.ELEM_FIELD.D_SIZE +
              (C-PARAM.SHAPE.C.LO)*PARAM.DATA.ELEM_FIELD.C_SIZE +1)*PARAM.ELEM_BITS -1 + PARAM.DATA.ELEM_FIELD.LO downto
             ((Y-PARAM.SHAPE.Y.LO)*PARAM.DATA.ELEM_FIELD.Y_SIZE +
              (X-PARAM.SHAPE.X.LO)*PARAM.DATA.ELEM_FIELD.X_SIZE +
              (D-PARAM.SHAPE.D.LO)*PARAM.DATA.ELEM_FIELD.D_SIZE +
              (C-PARAM.SHAPE.C.LO)*PARAM.DATA.ELEM_FIELD.C_SIZE   )*PARAM.ELEM_BITS    + PARAM.DATA.ELEM_FIELD.LO) := ELEMENT;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief IMAGE_STREAM_ATRB_VECTOR を生成する関数.
    -------------------------------------------------------------------------------
    procedure SET_ATRB_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in   IMAGE_STREAM_PARAM_TYPE;
                  ATRB_C_VEC        :  in   IMAGE_STREAM_ATRB_VECTOR;
                  ATRB_D_VEC        :  in   IMAGE_STREAM_ATRB_VECTOR;
                  ATRB_X_VEC        :  in   IMAGE_STREAM_ATRB_VECTOR;
                  ATRB_Y_VEC        :  in   IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector)
    is
        alias     i_atrb_c_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_C_VEC'length-1) is ATRB_C_VEC;
        alias     i_atrb_d_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_D_VEC'length-1) is ATRB_D_VEC;
        alias     i_atrb_x_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_X_VEC'length-1) is ATRB_X_VEC;
        alias     i_atrb_y_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_Y_VEC'length-1) is ATRB_Y_VEC;
    begin
        ---------------------------------------------------------------------------
        -- ATRB_C_VEC を DATA にセット
        ---------------------------------------------------------------------------
        for c_pos in i_atrb_c_vec'range loop
            SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                PARAM => PARAM,
                C     => c_pos + PARAM.SHAPE.C.LO,
                ATRB  => i_atrb_c_vec(c_pos),
                DATA  => DATA
            );
        end loop;
        ---------------------------------------------------------------------------
        -- ATRB_D_VEC を DATA にセット
        ---------------------------------------------------------------------------
        for d_pos in i_atrb_d_vec'range loop
            SET_ATRB_D_TO_IMAGE_STREAM_DATA(
                PARAM => PARAM,
                D     => d_pos + PARAM.SHAPE.D.LO,
                ATRB  => i_atrb_d_vec(d_pos),
                DATA  => DATA
            );
        end loop;
        ---------------------------------------------------------------------------
        -- ATRB_X_VEC を DATA にセット
        ---------------------------------------------------------------------------
        for x_pos in i_atrb_x_vec'range loop
            SET_ATRB_X_TO_IMAGE_STREAM_DATA(
                PARAM => PARAM,
                X     => x_pos + PARAM.SHAPE.X.LO,
                ATRB  => i_atrb_x_vec(x_pos),
                DATA  => DATA
            );
        end loop;
        ---------------------------------------------------------------------------
        -- ATRB_Y_VEC を DATA にセット
        ---------------------------------------------------------------------------
        for y_pos in i_atrb_y_vec'range loop
            SET_ATRB_Y_TO_IMAGE_STREAM_DATA(
                PARAM => PARAM,
                Y     => y_pos + PARAM.SHAPE.Y.LO,
                ATRB  => i_atrb_y_vec(y_pos),
                DATA  => DATA
            );
        end loop;
    end procedure;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に 辺(C,D,X,Y) の属性を追加するプロシージャ
    --  * Image Stream Data に 対応する辺の属性フィールドが存在するならば、DATA の
    --    対応するフィールドにデータを上書きする.
    --  * Image Stream Data に 対応する辺の属性フィールドが存在しないならば、なにも
    --    しない.
    -------------------------------------------------------------------------------
    procedure SET_ATRB_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  SHAPE_SIDE        :  in    IMAGE_SHAPE_SIDE_TYPE;
                  ATRB_FIELD        :  in    IMAGE_VECTOR_RANGE_TYPE;
                  POS               :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        if (ATRB_FIELD.SIZE > 0) then
            assert (POS >= SHAPE_SIDE.LO and POS <= SHAPE_SIDE.HI)
                report "SET_ATRB_TO_IMAGE_STREAM_DATA: Out of range." severity FAILURE;
            DATA((POS-SHAPE_SIDE.LO+1)*PARAM.ATRB_BITS-1 + ATRB_FIELD.LO downto
                 (POS-SHAPE_SIDE.LO  )*PARAM.ATRB_BITS   + ATRB_FIELD.LO) := ATRB;
        end if;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に C Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC          :  in    IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector)
    is
        alias     atrb_c_vec        :        IMAGE_STREAM_ATRB_VECTOR(PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI) is ATRB_VEC;
    begin
        for c_pos in atrb_c_vec'range loop
            SET_ATRB_C_TO_IMAGE_STREAM_DATA(PARAM, c_pos, atrb_c_vec(c_pos), DATA);
        end loop;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に C Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_TO_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.C, PARAM.DATA.ATRB_FIELD.C, C, ATRB, DATA);
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に C Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  C                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_TO_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.C, PARAM.DATA.ATRB_FIELD.C, C, to_std_logic_vector(ATRB), DATA);
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に C Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_D_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC          :  in    IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector)
    is
        alias     atrb_d_vec        :        IMAGE_STREAM_ATRB_VECTOR(PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI) is ATRB_VEC;
    begin
        for d_pos in atrb_d_vec'range loop
            SET_ATRB_D_TO_IMAGE_STREAM_DATA(PARAM, d_pos, atrb_d_vec(d_pos), DATA);
        end loop;
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に D Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_D_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  D                 :  in    integer;
                  ATRB              :  in    std_logic_vector;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_TO_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.D, PARAM.DATA.ATRB_FIELD.D, D, ATRB, DATA);
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に D Channel の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_D_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  D                 :  in    integer;
                  ATRB              :  in    IMAGE_STREAM_ATRB_TYPE;
        variable  DATA              :  inout std_logic_vector)
    is
    begin
        SET_ATRB_TO_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.D, PARAM.DATA.ATRB_FIELD.D, D, to_std_logic_vector(ATRB), DATA);
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に X 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_X_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC          :  in    IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector)
    is
        alias     atrb_x_vec        :        IMAGE_STREAM_ATRB_VECTOR(PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI) is ATRB_VEC;
    begin
        for x_pos in atrb_x_vec'range loop
            SET_ATRB_X_TO_IMAGE_STREAM_DATA(PARAM, x_pos, atrb_x_vec(x_pos), DATA);
        end loop;
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
        SET_ATRB_TO_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.X, PARAM.DATA.ATRB_FIELD.X, X, ATRB, DATA);
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
        SET_ATRB_TO_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.X, PARAM.DATA.ATRB_FIELD.X, X, to_std_logic_vector(ATRB), DATA);
    end procedure;

    -------------------------------------------------------------------------------
    --! @brief Image Stream Data に Y 方向の属性を追加するプロシージャ
    -------------------------------------------------------------------------------
    procedure SET_ATRB_Y_VECTOR_TO_IMAGE_STREAM_DATA(
                  PARAM             :  in    IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC          :  in    IMAGE_STREAM_ATRB_VECTOR;
        variable  DATA              :  inout std_logic_vector)
    is
        alias     atrb_y_vec        :        IMAGE_STREAM_ATRB_VECTOR(PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI) is ATRB_VEC;
    begin
        for y_pos in atrb_y_vec'range loop
            SET_ATRB_Y_TO_IMAGE_STREAM_DATA(PARAM, y_pos, atrb_y_vec(y_pos), DATA);
        end loop;
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
        SET_ATRB_TO_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.Y, PARAM.DATA.ATRB_FIELD.Y, Y, ATRB, DATA);
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
        SET_ATRB_TO_IMAGE_STREAM_DATA(PARAM, PARAM.SHAPE.Y, PARAM.DATA.ATRB_FIELD.Y, Y, to_std_logic_vector(ATRB), DATA);
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
    --! @brief Image Stream Attribute が C Channel の最初であることを示す関数
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
    --! @brief Image Stream Attribute が C Channel の最後であることを示す関数
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
    --! @brief Image Stream Attribute が D Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_D_VECTOR_IS_START(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_D            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return CHECK_IMAGE_STREAM_ATRB(
                  ATRB_VEC => ATRB_D(PARAM.SHAPE.D.LO to PARAM.SHAPE.D.LO),
                  VALID    => VALID,
                  START    => TRUE,
                  LAST     => FALSE
               );
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Image Stream Attribute が C Channel の最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_ATRB_D_VECTOR_IS_LAST(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_D            :  IMAGE_STREAM_ATRB_VECTOR;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return CHECK_IMAGE_STREAM_ATRB(
                  ATRB_VEC => ATRB_D(PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI),
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
    --! @brief Image Stream が C Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_C(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
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
    --! @brief Image Stream が C Channel の有効な最後であることを示す関数
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
    --! @brief Image Stream が D Channel の最初であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_START_D(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin 
        return IMAGE_STREAM_ATRB_D_VECTOR_IS_START(
                  PARAM   => PARAM, 
                  ATRB_D  => GET_ATRB_D_VECTOR_FROM_IMAGE_STREAM_DATA(
                                 PARAM => PARAM,
                                 DATA  => DATA
                             ),
                  VALID   => VALID
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Image Stream が C Channel の有効な最後であることを示す関数
    -------------------------------------------------------------------------------
    function  IMAGE_STREAM_DATA_IS_LAST_D(
                  PARAM             :  IMAGE_STREAM_PARAM_TYPE;
                  DATA              :  std_logic_vector;
                  VALID             :  boolean := TRUE)
                  return               boolean
    is
    begin
        return IMAGE_STREAM_ATRB_D_VECTOR_IS_LAST(
                  PARAM   => PARAM, 
                  ATRB_D  => GET_ATRB_D_VECTOR_FROM_IMAGE_STREAM_DATA(
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
    
    -------------------------------------------------------------------------------
    --! @brief IMAGE_STREAM_ATRB_VECTOR を生成する関数
    -------------------------------------------------------------------------------
    function  GENERATE_IMAGE_STREAM_ATRB_VECTOR(VALID: std_logic_vector;START,LAST: boolean) return IMAGE_STREAM_ATRB_VECTOR
    is
        alias     i_valid     :  std_logic_vector(VALID'length-1 downto 0) is VALID;
        variable  i_start     :  boolean;
        variable  i_last      :  boolean;
        variable  atrb_vector :  IMAGE_STREAM_ATRB_VECTOR(0 to VALID'length-1);
    begin
        i_start := START;
        for i in atrb_vector'low to atrb_vector'high loop
            atrb_vector(i).VALID := (i_valid(i) = '1');
            atrb_vector(i).START := i_start;
            if (i_valid(i) = '1') then
                i_start := FALSE;
            end if;
        end loop;
        i_last  := LAST;
        for i in atrb_vector'high downto atrb_vector'low loop
            atrb_vector(i).LAST  := i_last;
            if (i_valid(i) = '1') then
                i_last  := FALSE;
            end if;
        end loop;
        return atrb_vector;
    end function;
        
    -------------------------------------------------------------------------------
    --! @brief IMAGE_STREAM_ATRB_VECTOR を生成する関数
    -------------------------------------------------------------------------------
    function  GENERATE_IMAGE_STREAM_ATRB_VECTOR(VALID: std_logic_vector;START,LAST: std_logic) return IMAGE_STREAM_ATRB_VECTOR
    is
    begin
        return GENERATE_IMAGE_STREAM_ATRB_VECTOR(VALID, boolean'((START = '1')), boolean'((LAST = '1')));
    end function;
end IMAGE_TYPES;
