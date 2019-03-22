-----------------------------------------------------------------------------------
--!     @file    convolution_types.vhd
--!     @brief   Convolution Engine Types Package.
--!     @version 1.8.0
--!     @date    2019/3/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019 Ichiro Kawazome
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
library PipeWork;
use     PipeWork.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief Convolution Engine で使用する各種タイプ/定数を定義しているパッケージ.
-----------------------------------------------------------------------------------
package CONVOLUTION_TYPES is
    -------------------------------------------------------------------------------
    --! @brief Convolution Kernel の大きさを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      CONVOLUTION_KERNEL_SIZE_TYPE is record
                  X                 :  IMAGE_VECTOR_RANGE_TYPE;
                  Y                 :  IMAGE_VECTOR_RANGE_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Convolution Kernel の大きさを設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_CONVOLUTION_KERNEL_SIZE(X_SIZE   ,Y_SIZE   :integer) return CONVOLUTION_KERNEL_SIZE_TYPE;
    function  NEW_CONVOLUTION_KERNEL_SIZE(X_LO,X_HI,Y_LO,Y_HI:integer) return CONVOLUTION_KERNEL_SIZE_TYPE;
    constant  CONVOLUTION_KERNEL_SIZE_1x1  :  CONVOLUTION_KERNEL_SIZE_TYPE := NEW_CONVOLUTION_KERNEL_SIZE(1,1);
    constant  CONVOLUTION_KERNEL_SIZE_3x3  :  CONVOLUTION_KERNEL_SIZE_TYPE := NEW_CONVOLUTION_KERNEL_SIZE(-1,1,-1,1);

    -------------------------------------------------------------------------------
    --! @brief Convolution の各種パラメータを定義するレコードタイプ.
    -------------------------------------------------------------------------------
    type      CONVOLUTION_PARAM_TYPE is record
                  KERNEL_SIZE       :  CONVOLUTION_KERNEL_SIZE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  I_STREAM          :  IMAGE_STREAM_PARAM_TYPE;  -- イメージ入力側の IMAGE_STREAM パラメータ
                  I_SHAPE           :  IMAGE_SHAPE_TYPE;         -- イメージ入力側の IMAGE_SHAPE  パラメータ
                  O_STREAM          :  IMAGE_STREAM_PARAM_TYPE;  -- イメージ出力側の IMAGE_STREAM パラメータ
                  O_SHAPE           :  IMAGE_SHAPE_TYPE;         -- イメージ出力側の IMAGE_SHAPE  パラメータ
                  A_STREAM          :  IMAGE_STREAM_PARAM_TYPE;  -- 内部バッファの   IMAGE_STREAM パラメータ
                  A_SHAPE           :  IMAGE_SHAPE_TYPE;         -- 内部バッファの   IMAGE_SHAPE  パラメータ
                  B_STREAM          :  IMAGE_STREAM_PARAM_TYPE;  -- バイアス入力の   IMAGE_STREAM パラメータ
                  W_STREAM          :  IMAGE_STREAM_PARAM_TYPE;  -- ウェイト入力の   IMAGE_STREAM パラメータ
                  A_PIPELINE        :  IMAGE_STREAM_PARAM_TYPE; -- 内部のイメージ入力 Convolution Pipeline パラメータ
                  B_PIPELINE        :  IMAGE_STREAM_PARAM_TYPE; -- 内部のバイアス入力 Convolution Pipeline パラメータ
                  W_PIPELINE        :  IMAGE_STREAM_PARAM_TYPE; -- 内部のウェイト入力 Convolution Pipeline パラメータ
                  M_PIPELINE        :  IMAGE_STREAM_PARAM_TYPE; -- 内部の乗算出力     Convolution Pipeline パラメータ
                  O_PIPELINE        :  IMAGE_STREAM_PARAM_TYPE; -- 内部の積算出力     Convolution Pipeline パラメータ
                  C_UNROLL          :  integer;
                  D_UNROLL          :  integer;
                  X_UNROLL          :  integer;
                  Y_UNROLL          :  integer;
                  SHAPE             :  IMAGE_SHAPE_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Convolution の各種パラメータを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_CONVOLUTION_PARAM(
                  KERNEL_SIZE       :  CONVOLUTION_KERNEL_SIZE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  I_STREAM          :  IMAGE_STREAM_PARAM_TYPE;
                  I_SHAPE           :  IMAGE_SHAPE_TYPE;
                  B_ELEM_BITS       :  integer ;
                  W_ELEM_BITS       :  integer ;
                  M_ELEM_BITS       :  integer ;
                  O_ELEM_BITS       :  integer ;
                  O_SHAPE_C         :  IMAGE_SHAPE_SIDE_TYPE;
                  C_UNROLL          :  integer := 1;
                  D_UNROLL          :  integer := 1;
                  X_UNROLL          :  integer := 1;
                  Y_UNROLL          :  integer := 1;
                  X_BORDER          :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE;
                  Y_BORDER          :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               CONVOLUTION_PARAM_TYPE;

    -------------------------------------------------------------------------------
    --! @brief イメージ入力 Stream を Convolution Pipeline に変換する関数
    -------------------------------------------------------------------------------
    function  CONVOLUTION_PIPELINE_FROM_IMAGE_STREAM(
                  PIPELINE_PARAM    :  IMAGE_STREAM_PARAM_TYPE;
                  STREAM_PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  KERNEL_SIZE       :  CONVOLUTION_KERNEL_SIZE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  STREAM_DATA       :  std_logic_vector)
                  return               std_logic_vector;

    -------------------------------------------------------------------------------
    --! @brief ウェイト入力 Stream を Convolution Pipeline に変換する関数
    -------------------------------------------------------------------------------
    function  CONVOLUTION_PIPELINE_FROM_WEIGHT_STREAM(
                  PIPELINE_PARAM    :  IMAGE_STREAM_PARAM_TYPE;
                  STREAM_PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  KERNEL_SIZE       :  CONVOLUTION_KERNEL_SIZE_TYPE;
                  STREAM_DATA       :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief バイアス入力 Stream を Convolution Pipeline に変換する関数
    -------------------------------------------------------------------------------
    function  CONVOLUTION_PIPELINE_FROM_BIAS_STREAM(
                  PIPELINE_PARAM    :  IMAGE_STREAM_PARAM_TYPE;
                  STREAM_PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  STREAM_DATA       :  std_logic_vector)
                  return               std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief Convolution Pipeline を イメージ出力 Stream に変換する関数
    -------------------------------------------------------------------------------
    function  CONVOLUTION_PIPELINE_TO_IMAGE_STREAM(
                  STREAM_PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  PIPELINE_PARAM    :  IMAGE_STREAM_PARAM_TYPE;
                  PIPELINE_DATA     :  std_logic_vector)
                  return               std_logic_vector;
end CONVOLUTION_TYPES;
-----------------------------------------------------------------------------------
--! @brief Image の各種タイプ/定数を定義しているパッケージ.
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PipeWork;
use     PipeWork.IMAGE_TYPES.all;
package body CONVOLUTION_TYPES is
    -------------------------------------------------------------------------------
    --! @brief Convolution Kernel の大きさを設定する関数群
    -------------------------------------------------------------------------------
    function  NEW_CONVOLUTION_KERNEL_SIZE(X_SIZE   ,Y_SIZE   :integer) return CONVOLUTION_KERNEL_SIZE_TYPE is
        variable  kernel_size  :  CONVOLUTION_KERNEL_SIZE_TYPE;
    begin
        kernel_size.X := NEW_IMAGE_VECTOR_RANGE(X_SIZE);
        kernel_size.Y := NEW_IMAGE_VECTOR_RANGE(Y_SIZE);
        return kernel_size;
    end function;

    function  NEW_CONVOLUTION_KERNEL_SIZE(X_LO,X_HI,Y_LO,Y_HI:integer) return CONVOLUTION_KERNEL_SIZE_TYPE is
        variable  kernel_size  :  CONVOLUTION_KERNEL_SIZE_TYPE;
    begin
        kernel_size.X := NEW_IMAGE_VECTOR_RANGE(X_LO, X_HI);
        kernel_size.Y := NEW_IMAGE_VECTOR_RANGE(Y_LO, Y_HI);
        return kernel_size;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Convolution Pipeline Data に要素を追加するプロシージャ
    -------------------------------------------------------------------------------
    function  UPDATE_IMAGE_SHAPE_SIDE(
                  I_SHAPE_SIDE      :  IMAGE_SHAPE_SIDE_TYPE;
                  BORDER_TYPE       :  IMAGE_STREAM_BORDER_TYPE;
                  KERNEL_LO         :  integer;
                  KERNEL_HI         :  integer;
                  FORCE_DATA_ATRB   :  boolean := FALSE)
                  return               IMAGE_SHAPE_SIDE_TYPE
    is
        variable  o_shape_side      :  IMAGE_SHAPE_SIDE_TYPE;
        variable  data_atrb         :  boolean;
    begin
        if (FORCE_DATA_ATRB) then
            data_atrb := TRUE;
        else
            data_atrb := I_SHAPE_SIDE.ATRB_IN_DATA;
        end if;
        if I_SHAPE_SIDE.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT then
            if BORDER_TYPE = IMAGE_STREAM_BORDER_NONE then
                o_shape_side := NEW_IMAGE_SHAPE_SIDE_CONSTANT(I_SHAPE_SIDE.SIZE-(KERNEL_HI-KERNEL_LO), data_atrb);
            else
                o_shape_side := NEW_IMAGE_SHAPE_SIDE_CONSTANT(I_SHAPE_SIDE.SIZE, data_atrb);
            end if;
        else
                o_shape_side := NEW_IMAGE_SHAPE_SIDE_AUTO(I_SHAPE_SIDE.MAX_SIZE);
        end if;
        return o_shape_side;
    end function;
                 
    -------------------------------------------------------------------------------
    --! @brief Convolution の各種パラメータを設定する関数
    -------------------------------------------------------------------------------
    function  NEW_CONVOLUTION_PARAM(
                  KERNEL_SIZE       :  CONVOLUTION_KERNEL_SIZE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  I_STREAM          :  IMAGE_STREAM_PARAM_TYPE;
                  I_SHAPE           :  IMAGE_SHAPE_TYPE;
                  B_ELEM_BITS       :  integer ;
                  W_ELEM_BITS       :  integer ;
                  M_ELEM_BITS       :  integer ;
                  O_ELEM_BITS       :  integer ;
                  O_SHAPE_C         :  IMAGE_SHAPE_SIDE_TYPE;
                  C_UNROLL          :  integer := 1;
                  D_UNROLL          :  integer := 1;
                  X_UNROLL          :  integer := 1;
                  Y_UNROLL          :  integer := 1;
                  X_BORDER          :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE;
                  Y_BORDER          :  IMAGE_STREAM_BORDER_TYPE := IMAGE_STREAM_BORDER_NONE)
                  return               CONVOLUTION_PARAM_TYPE
    is
        variable  param             :  CONVOLUTION_PARAM_TYPE;
        variable  a_stream_x_size   :  integer;
        variable  a_stream_y_size   :  integer;
        variable  pipeline_shape_c  :  IMAGE_SHAPE_SIDE_TYPE;
        variable  pipeline_shape_d  :  IMAGE_SHAPE_SIDE_TYPE;
        variable  pipeline_shape_x  :  IMAGE_SHAPE_SIDE_TYPE;
        variable  pipeline_shape_y  :  IMAGE_SHAPE_SIDE_TYPE;
        variable  pipeline_stride   :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.KERNEL_SIZE := KERNEL_SIZE;
        param.STRIDE      := STRIDE;
        param.C_UNROLL    := C_UNROLL;
        param.D_UNROLL    := D_UNROLL;
        param.X_UNROLL    := X_UNROLL;
        param.Y_UNROLL    := Y_UNROLL;
        param.I_STREAM    := I_STREAM;
        param.I_SHAPE     := I_SHAPE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        pipeline_shape_c  := NEW_IMAGE_SHAPE_SIDE_CONSTANT(C_UNROLL*KERNEL_SIZE.X.SIZE*KERNEL_SIZE.Y.SIZE, TRUE, TRUE);
        pipeline_shape_d  := NEW_IMAGE_SHAPE_SIDE_CONSTANT(D_UNROLL, TRUE, TRUE);
        pipeline_shape_x  := NEW_IMAGE_SHAPE_SIDE_CONSTANT(X_UNROLL, TRUE, TRUE);
        pipeline_shape_y  := NEW_IMAGE_SHAPE_SIDE_CONSTANT(Y_UNROLL, TRUE, TRUE);
        pipeline_stride   := NEW_IMAGE_STREAM_STRIDE_PARAM(X_UNROLL, Y_UNROLL);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        a_stream_x_size   := KERNEL_SIZE.X.SIZE + STRIDE.X*(X_UNROLL-1);
        a_stream_y_size   := KERNEL_SIZE.Y.SIZE + STRIDE.Y*(Y_UNROLL-1);
        param.A_STREAM    := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => I_STREAM.ELEM_BITS,
                                 C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(C_UNROLL, TRUE , TRUE),
                                 D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(D_UNROLL, FALSE, TRUE),
                                 X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(KERNEL_SIZE.X.LO, KERNEL_SIZE.X.LO + a_stream_x_size - 1, TRUE, TRUE),
                                 Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(KERNEL_SIZE.Y.LO, KERNEL_SIZE.Y.LO + a_stream_y_size - 1, TRUE, TRUE),
                                 STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(
                                                  X         => STRIDE.X + X_UNROLL - 1,
                                                  Y         => STRIDE.Y + Y_UNROLL - 1
                                              )
                             );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.B_STREAM    := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => B_ELEM_BITS,
                                 C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(D_UNROLL, TRUE,  TRUE ),
                                 D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(0       , FALSE, FALSE),
                                 X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(0       , FALSE, FALSE),
                                 Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(0       , FALSE, FALSE),
                                 STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
                             );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.W_STREAM    := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => W_ELEM_BITS,
                                 C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(C_UNROLL, TRUE, TRUE),
                                 D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(D_UNROLL, TRUE, TRUE),
                                 X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(KERNEL_SIZE.X.LO, KERNEL_SIZE.X.HI, TRUE),
                                 Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(KERNEL_SIZE.Y.LO, KERNEL_SIZE.Y.HI, TRUE),
                                 STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
                             );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.A_PIPELINE  := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => I_STREAM.ELEM_BITS,
                                 C         => pipeline_shape_c,
                                 D         => pipeline_shape_d,
                                 X         => pipeline_shape_x,
                                 Y         => pipeline_shape_y,
                                 STRIDE    => pipeline_stride
                             );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.W_PIPELINE  := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => W_ELEM_BITS,
                                 C         => pipeline_shape_c,
                                 D         => pipeline_shape_d,
                                 X         => pipeline_shape_x,
                                 Y         => pipeline_shape_y,
                                 STRIDE    => pipeline_stride
                             );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.M_PIPELINE  := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => M_ELEM_BITS,
                                 C         => pipeline_shape_c,
                                 D         => pipeline_shape_d,
                                 X         => pipeline_shape_x,
                                 Y         => pipeline_shape_y,
                                 STRIDE    => pipeline_stride
                             );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.B_PIPELINE  := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => B_ELEM_BITS,
                                 C         => pipeline_shape_c,
                                 D         => pipeline_shape_d,
                                 X         => pipeline_shape_x,
                                 Y         => pipeline_shape_y,
                                 STRIDE    => pipeline_stride
                             );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.O_PIPELINE  := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => O_ELEM_BITS,
                                 C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE, TRUE),
                                 D         => pipeline_shape_d,
                                 X         => pipeline_shape_x,
                                 Y         => pipeline_shape_y,
                                 STRIDE    => pipeline_stride
                             );
            
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.O_STREAM    := NEW_IMAGE_STREAM_PARAM(
                                 ELEM_BITS => O_ELEM_BITS,
                                 C         => pipeline_shape_d,
                                 D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(0, FALSE, FALSE),
                                 X         => pipeline_shape_x,
                                 Y         => pipeline_shape_y,
                                 STRIDE    => pipeline_stride
                             );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.SHAPE   := NEW_IMAGE_SHAPE(
                             ELEM_BITS => O_ELEM_BITS,
                             C         => UPDATE_IMAGE_SHAPE_SIDE(I_SHAPE.C, I_STREAM.BORDER_TYPE, 0               , 0               ),
                             D         => UPDATE_IMAGE_SHAPE_SIDE(O_SHAPE_C, I_STREAM.BORDER_TYPE, 0               , 0               ),
                             X         => UPDATE_IMAGE_SHAPE_SIDE(I_SHAPE.X, I_STREAM.BORDER_TYPE, KERNEL_SIZE.X.LO, KERNEL_SIZE.X.HI),
                             Y         => UPDATE_IMAGE_SHAPE_SIDE(I_SHAPE.Y, I_STREAM.BORDER_TYPE, KERNEL_SIZE.Y.LO, KERNEL_SIZE.Y.HI)
                         );
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        param.A_SHAPE := NEW_IMAGE_SHAPE(
                             ELEM_BITS => I_STREAM.ELEM_BITS,
                             C         => I_SHAPE.C,
                             D         => O_SHAPE_C,
                             X         => I_SHAPE.X,
                             Y         => NEW_IMAGE_SHAPE_SIDE_AUTO(I_SHAPE.Y.MAX_SIZE)
                         );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.O_SHAPE := NEW_IMAGE_SHAPE(
                             ELEM_BITS => O_ELEM_BITS,
                             C         => O_SHAPE_C,
                             D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(0, FALSE, FALSE),
                             X         => param.SHAPE.X,
                             Y         => param.SHAPE.Y
                         );
        return param;
    end function;

    -------------------------------------------------------------------------------
    --! @brief イメージ入力 Stream を Convolution Pipeline に変換する関数
    -------------------------------------------------------------------------------
    function  CONVOLUTION_PIPELINE_FROM_IMAGE_STREAM(
                  PIPELINE_PARAM    :  IMAGE_STREAM_PARAM_TYPE;
                  STREAM_PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  KERNEL_SIZE       :  CONVOLUTION_KERNEL_SIZE_TYPE;
                  STRIDE            :  IMAGE_STREAM_STRIDE_PARAM_TYPE;
                  STREAM_DATA       :  std_logic_vector)
                  return               std_logic_vector
    is
        alias     i_data            :  std_logic_vector(STREAM_PARAM  .DATA.SIZE-1 downto 0) is STREAM_DATA;
        variable  o_data            :  std_logic_vector(PIPELINE_PARAM.DATA.SIZE-1 downto 0);
        variable  element           :  std_logic_vector(STREAM_PARAM  .ELEM_BITS-1 downto 0);
        variable  i_c_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  i_d_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  i_x_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  i_y_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  o_c_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.C.SIZE-1);
        variable  o_d_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.D.SIZE-1);
        variable  o_x_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.X.SIZE-1);
        variable  o_y_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.Y.SIZE-1);
        variable  o_c_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.C.SIZE-1 downto 0);
        variable  o_d_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.D.SIZE-1 downto 0);
        variable  o_x_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.X.SIZE-1 downto 0);
        variable  o_y_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.Y.SIZE-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        -- o_data を初期化しておく
        ---------------------------------------------------------------------------
        o_data    := (others => '0');
        ---------------------------------------------------------------------------
        -- o_data に i_data の要素部分をコピー
        -- ついでに o_c_valid を生成
        ---------------------------------------------------------------------------
        o_c_valid := (others => '0');
        for o_y_pos in 0 to PIPELINE_PARAM.SHAPE.Y.SIZE-1 loop
        for o_x_pos in 0 to PIPELINE_PARAM.SHAPE.X.SIZE-1 loop
            for i_y_pos in 0 to STREAM_PARAM.SHAPE.Y.SIZE-1 loop
            for i_x_pos in 0 to STREAM_PARAM.SHAPE.X.SIZE-1 loop
            for i_c_pos in 0 to STREAM_PARAM.SHAPE.C.SIZE-1 loop
                element := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                               PARAM   => STREAM_PARAM,
                               C       => i_c_pos + STREAM_PARAM.SHAPE.C.LO,
                               D       => 0,
                               X       => i_x_pos + STREAM_PARAM.SHAPE.X.LO + (o_x_pos * STRIDE.X),
                               Y       => i_y_pos + STREAM_PARAM.SHAPE.Y.LO + (o_y_pos * STRIDE.Y),
                               DATA    => i_data
                           );
                i_c_atrb := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                               PARAM   => STREAM_PARAM,
                               C       => i_c_pos + STREAM_PARAM.SHAPE.C.LO,
                               DATA    => i_data
                           );
                i_x_atrb := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                               PARAM   => STREAM_PARAM,
                               X       => i_x_pos + STREAM_PARAM.SHAPE.X.LO + (o_x_pos * STRIDE.X),
                               DATA    => i_data
                           );
                i_y_atrb := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                               PARAM   => STREAM_PARAM,
                               Y       => i_y_pos + STREAM_PARAM.SHAPE.Y.LO + (o_y_pos * STRIDE.Y),
                               DATA    => i_data
                            );
                for o_d_pos in 0 to PIPELINE_PARAM.SHAPE.D.SIZE-1 loop
                    SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                               PARAM   => PIPELINE_PARAM,
                               C       => i_c_pos + PIPELINE_PARAM.SHAPE.C.LO
                                        +(i_x_pos * STREAM_PARAM.SHAPE.C.SIZE)
                                        +(i_y_pos * STREAM_PARAM.SHAPE.C.SIZE * KERNEL_SIZE.X.SIZE),
                               D       => o_d_pos + PIPELINE_PARAM.SHAPE.D.LO,
                               X       => o_x_pos + PIPELINE_PARAM.SHAPE.X.LO,
                               Y       => o_y_pos + PIPELINE_PARAM.SHAPE.Y.LO,
                               ELEMENT => element,
                               DATA    => o_data
                    );
                end loop;
                if (i_c_atrb.VALID = TRUE and i_x_atrb.VALID = TRUE and i_y_atrb.VALID = TRUE) then
                    o_c_valid((i_c_pos                                                 ) +
                              (i_x_pos * STREAM_PARAM.SHAPE.C.SIZE                     ) +
                              (i_y_pos * STREAM_PARAM.SHAPE.C.SIZE * KERNEL_SIZE.X.SIZE)) := '1';
                end if;
            end loop;
            end loop;
            end loop;
        end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- o_c_atrb_vec を設定
        ---------------------------------------------------------------------------
        for o_c_pos in 0 to PIPELINE_PARAM.SHAPE.C.SIZE-1 loop
            o_c_atrb_vec(o_c_pos).VALID := (o_c_valid(o_c_pos) = '1');
            o_c_atrb_vec(o_c_pos).START := (o_c_pos = o_c_atrb_vec'low  and IMAGE_STREAM_DATA_IS_START_C(STREAM_PARAM, i_data) = TRUE);
            o_c_atrb_vec(o_c_pos).LAST  := (o_c_pos = o_c_atrb_vec'high and IMAGE_STREAM_DATA_IS_LAST_C (STREAM_PARAM, i_data) = TRUE);
        end loop;
        ---------------------------------------------------------------------------
        -- o_d_atrb_vec を設定
        ---------------------------------------------------------------------------
        o_d_valid := (others => '0');
        for o_d_pos in 0 to PIPELINE_PARAM.SHAPE.D.SIZE-1 loop
            i_d_atrb := GET_ATRB_D_FROM_IMAGE_STREAM_DATA(
                                PARAM => STREAM_PARAM,
                                D     => o_d_pos + STREAM_PARAM.SHAPE.D.LO,
                                DATA  => i_data
                        );
            if (i_d_atrb.VALID) then
                o_d_valid(o_d_pos) := '1';
            end if;
        end loop;
        o_d_atrb_vec := GENERATE_IMAGE_STREAM_ATRB_VECTOR(
                            VALID => o_d_valid,
                            START => IMAGE_STREAM_DATA_IS_START_D(STREAM_PARAM, i_data),
                            LAST  => IMAGE_STREAM_DATA_IS_LAST_D (STREAM_PARAM, i_data)
                        );
        ---------------------------------------------------------------------------
        -- o_x_atrb_vec を設定
        ---------------------------------------------------------------------------
        o_x_valid := (others => '0');
        for o_x_pos in 0 to PIPELINE_PARAM.SHAPE.X.SIZE-1 loop
            o_x_atrb_vec(o_x_pos).VALID := FALSE;
            for k_x_pos in 0 to KERNEL_SIZE.X.SIZE-1 loop
                i_x_atrb := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                                PARAM => STREAM_PARAM,
                                X     => k_x_pos + STREAM_PARAM.SHAPE.X.LO + (o_x_pos * STRIDE.X),
                                DATA  => i_data
                            );
                if (i_x_atrb.VALID) then
                    o_x_valid(o_x_pos) := '1';
                end if;
            end loop;
        end loop;
        o_x_atrb_vec := GENERATE_IMAGE_STREAM_ATRB_VECTOR(
                            VALID => o_x_valid,
                            START => IMAGE_STREAM_DATA_IS_START_X(STREAM_PARAM, i_data),
                            LAST  => IMAGE_STREAM_DATA_IS_LAST_X (STREAM_PARAM, i_data)
                        );
        ---------------------------------------------------------------------------
        -- o_y_atrb_vec を設定
        ---------------------------------------------------------------------------
        o_y_valid := (others => '0');
        for o_y_pos in 0 to PIPELINE_PARAM.SHAPE.Y.SIZE-1 loop
            o_y_atrb_vec(o_y_pos).VALID := FALSE;
            for k_y_pos in 0 to KERNEL_SIZE.Y.SIZE-1 loop
                i_y_atrb := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                                PARAM => STREAM_PARAM,
                                Y     => k_y_pos + STREAM_PARAM.SHAPE.Y.LO + (o_y_pos * STRIDE.Y),
                                DATA  => i_data
                            );
                if (i_y_atrb.VALID) then
                    o_y_valid(o_y_pos) := '1';
                end if;
            end loop;
        end loop;
        o_y_atrb_vec := GENERATE_IMAGE_STREAM_ATRB_VECTOR(
                            VALID => o_y_valid,
                            START => IMAGE_STREAM_DATA_IS_START_Y(STREAM_PARAM, i_data),
                            LAST  => IMAGE_STREAM_DATA_IS_LAST_Y (STREAM_PARAM, i_data)
                        );
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SET_ATRB_VECTOR_TO_IMAGE_STREAM_DATA(
            PARAM       => PIPELINE_PARAM,
            ATRB_C_VEC  => o_c_atrb_vec,
            ATRB_D_VEC  => o_d_atrb_vec,
            ATRB_X_VEC  => o_x_atrb_vec,
            ATRB_Y_VEC  => o_y_atrb_vec,
            DATA        => o_data
        );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        return o_data;
    end function;

    -------------------------------------------------------------------------------
    --! @brief ウェイト入力 Stream を Convolution Pipeline に変換する関数
    -------------------------------------------------------------------------------
    function  CONVOLUTION_PIPELINE_FROM_WEIGHT_STREAM(
                  PIPELINE_PARAM    :  IMAGE_STREAM_PARAM_TYPE;
                  STREAM_PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  KERNEL_SIZE       :  CONVOLUTION_KERNEL_SIZE_TYPE;
                  STREAM_DATA       :  std_logic_vector)
                  return               std_logic_vector
    is
        alias     i_data            :  std_logic_vector(STREAM_PARAM  .DATA.SIZE-1 downto 0) is STREAM_DATA;
        variable  o_data            :  std_logic_vector(PIPELINE_PARAM.DATA.SIZE-1 downto 0);
        variable  element           :  std_logic_vector(STREAM_PARAM  .ELEM_BITS-1 downto 0);
        variable  i_c_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  i_d_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  i_x_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  i_y_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  o_c_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.C.SIZE-1);
        variable  o_d_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.D.SIZE-1);
        variable  o_x_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.X.SIZE-1);
        variable  o_y_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.Y.SIZE-1);
        variable  o_c_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.C.SIZE-1 downto 0);
        variable  o_d_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.D.SIZE-1 downto 0);
        variable  o_x_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.X.SIZE-1 downto 0);
        variable  o_y_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.Y.SIZE-1 downto 0);
    begin
        o_data := (others => '0');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_c_valid := (others => '0');
        for i_y_pos in 0 to STREAM_PARAM.SHAPE.Y.SIZE-1 loop
        for i_x_pos in 0 to STREAM_PARAM.SHAPE.X.SIZE-1 loop
        for i_c_pos in 0 to STREAM_PARAM.SHAPE.C.SIZE-1 loop
            for i_d_pos in 0 to STREAM_PARAM.SHAPE.D.SIZE-1 loop
                element := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                               PARAM   => STREAM_PARAM,
                               C       => i_c_pos + STREAM_PARAM.SHAPE.C.LO,
                               D       => i_d_pos + STREAM_PARAM.SHAPE.D.LO,
                               X       => i_x_pos + STREAM_PARAM.SHAPE.X.LO,
                               Y       => i_y_pos + STREAM_PARAM.SHAPE.Y.LO,
                               DATA    => i_data
                            );
                for o_y_pos in 0 to PIPELINE_PARAM.SHAPE.Y.SIZE-1 loop
                for o_x_pos in 0 to PIPELINE_PARAM.SHAPE.X.SIZE-1 loop
                    SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                               PARAM   => PIPELINE_PARAM,
                               C       => i_c_pos + PIPELINE_PARAM.SHAPE.C.LO
                                        +(i_x_pos * STREAM_PARAM.SHAPE.C.SIZE)
                                        +(i_y_pos * STREAM_PARAM.SHAPE.C.SIZE * KERNEL_SIZE.X.SIZE),
                               D       => i_d_pos + PIPELINE_PARAM.SHAPE.D.LO,
                               X       => o_x_pos + PIPELINE_PARAM.SHAPE.X.LO,
                               Y       => o_y_pos + PIPELINE_PARAM.SHAPE.Y.LO,
                               ELEMENT => element,
                               DATA    => o_data
                    );
                end loop;
                end loop;
            end loop;
            i_c_atrb := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                           PARAM   => STREAM_PARAM,
                           C       => i_c_pos + STREAM_PARAM.SHAPE.C.LO,
                           DATA    => i_data
                        );
            i_x_atrb := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                           PARAM   => STREAM_PARAM,
                           X       => i_x_pos + STREAM_PARAM.SHAPE.X.LO,
                           DATA    => i_data
                        );
            i_y_atrb := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                           PARAM   => STREAM_PARAM,
                           Y       => i_y_pos + STREAM_PARAM.SHAPE.Y.LO,
                           DATA    => i_data
                        );
            if (i_c_atrb.VALID = TRUE and i_x_atrb.VALID = TRUE and i_y_atrb.VALID = TRUE) then
                o_c_valid((i_c_pos                                                 ) +
                          (i_x_pos * STREAM_PARAM.SHAPE.C.SIZE                     ) +
                          (i_y_pos * STREAM_PARAM.SHAPE.C.SIZE * KERNEL_SIZE.X.SIZE)) := '1';
            end if;
        end loop;
        end loop;
        end loop;
        for o_c_pos in 0 to PIPELINE_PARAM.SHAPE.C.SIZE-1 loop
            o_c_atrb_vec(o_c_pos).VALID := (o_c_valid(o_c_pos) = '1');
            o_c_atrb_vec(o_c_pos).START := (o_c_pos = o_c_atrb_vec'low  and IMAGE_STREAM_DATA_IS_START_C(STREAM_PARAM, i_data) = TRUE);
            o_c_atrb_vec(o_c_pos).LAST  := (o_c_pos = o_c_atrb_vec'high and IMAGE_STREAM_DATA_IS_LAST_C (STREAM_PARAM, i_data) = TRUE);
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_d_valid := (others => '0');
        for o_d_pos in 0 to PIPELINE_PARAM.SHAPE.D.SIZE-1 loop
                i_d_atrb := GET_ATRB_D_FROM_IMAGE_STREAM_DATA(
                                PARAM => STREAM_PARAM,
                                D     => o_d_pos + STREAM_PARAM.SHAPE.D.LO,
                                DATA  => i_data
                            );
                if (i_d_atrb.VALID) then
                    o_d_valid(o_d_pos) := '1';
                end if;
        end loop;
        o_d_atrb_vec := GENERATE_IMAGE_STREAM_ATRB_VECTOR(
                            VALID => o_d_valid,
                            START => IMAGE_STREAM_DATA_IS_START_D(STREAM_PARAM, i_data),
                            LAST  => IMAGE_STREAM_DATA_IS_LAST_D (STREAM_PARAM, i_data)
                        );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_x_valid := (others => '0');
        for o_x_pos in 0 to PIPELINE_PARAM.SHAPE.X.SIZE-1 loop
            for k_x_pos in 0 to KERNEL_SIZE.X.SIZE-1 loop
                i_x_atrb := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                                PARAM => STREAM_PARAM,
                                X     => k_x_pos + STREAM_PARAM.SHAPE.X.LO,
                                DATA  => i_data
                            );
                if (i_x_atrb.VALID) then
                    o_x_valid(o_x_pos) := '1';
                end if;
            end loop;
        end loop;
        o_x_atrb_vec := GENERATE_IMAGE_STREAM_ATRB_VECTOR(
                            VALID => o_x_valid,
                            START => IMAGE_STREAM_DATA_IS_START_X(STREAM_PARAM, i_data),
                            LAST  => IMAGE_STREAM_DATA_IS_LAST_X (STREAM_PARAM, i_data)
                        );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_y_valid := (others => '0');
        for o_y_pos in 0 to PIPELINE_PARAM.SHAPE.Y.SIZE-1 loop
            for k_y_pos in 0 to KERNEL_SIZE.Y.SIZE-1 loop
                i_y_atrb := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                                PARAM => STREAM_PARAM,
                                Y     => k_y_pos + STREAM_PARAM.SHAPE.Y.LO,
                                DATA  => i_data
                            );
                if (i_y_atrb.VALID) then
                    o_y_valid(o_y_pos) := '1';
                end if;
            end loop;
        end loop;
        o_y_atrb_vec := GENERATE_IMAGE_STREAM_ATRB_VECTOR(
                            VALID => o_y_valid,
                            START => IMAGE_STREAM_DATA_IS_START_Y(STREAM_PARAM, i_data),
                            LAST  => IMAGE_STREAM_DATA_IS_LAST_Y (STREAM_PARAM, i_data)
                        );
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SET_ATRB_VECTOR_TO_IMAGE_STREAM_DATA(
            PARAM       => PIPELINE_PARAM,
            ATRB_C_VEC  => o_c_atrb_vec,
            ATRB_D_VEC  => o_d_atrb_vec,
            ATRB_X_VEC  => o_x_atrb_vec,
            ATRB_Y_VEC  => o_y_atrb_vec,
            DATA        => o_data
        );
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        return o_data;
    end function;
    -------------------------------------------------------------------------------
    --! @brief バイアス入力 Stream を Convolution Pipeline に変換する関数
    -------------------------------------------------------------------------------
    function  CONVOLUTION_PIPELINE_FROM_BIAS_STREAM(
                  PIPELINE_PARAM    :  IMAGE_STREAM_PARAM_TYPE;
                  STREAM_PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  STREAM_DATA       :  std_logic_vector)
                  return               std_logic_vector
    is
        alias     i_data            :  std_logic_vector(STREAM_PARAM  .DATA.SIZE-1 downto 0) is STREAM_DATA;
        variable  o_data            :  std_logic_vector(PIPELINE_PARAM.DATA.SIZE-1 downto 0);
        variable  element           :  std_logic_vector(STREAM_PARAM  .ELEM_BITS-1 downto 0);
        variable  i_c_atrb          :  IMAGE_STREAM_ATRB_TYPE;
        variable  o_c_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.C.SIZE-1);
        variable  o_d_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.D.SIZE-1);
        variable  o_x_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.X.SIZE-1);
        variable  o_y_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to PIPELINE_PARAM.SHAPE.Y.SIZE-1);
        variable  o_d_valid         :  std_logic_vector(PIPELINE_PARAM.SHAPE.D.SIZE-1 downto 0);
    begin
        o_data := (others => '0');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for i_c_pos in 0 to STREAM_PARAM.SHAPE.C.SIZE-1 loop
            element := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                           PARAM   => STREAM_PARAM,
                           C       => i_c_pos + STREAM_PARAM.SHAPE.C.LO,
                           D       =>           STREAM_PARAM.SHAPE.D.LO,
                           X       =>           STREAM_PARAM.SHAPE.X.LO,
                           Y       =>           STREAM_PARAM.SHAPE.Y.LO,
                           DATA    => i_data
                        );
            for o_c_pos in 0 to PIPELINE_PARAM.SHAPE.C.SIZE-1 loop
            for o_y_pos in 0 to PIPELINE_PARAM.SHAPE.Y.SIZE-1 loop
            for o_x_pos in 0 to PIPELINE_PARAM.SHAPE.X.SIZE-1 loop
                SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                           PARAM   => PIPELINE_PARAM,
                           C       => o_c_pos + PIPELINE_PARAM.SHAPE.C.LO,
                           D       => i_c_pos + PIPELINE_PARAM.SHAPE.D.LO,
                           X       => o_x_pos + PIPELINE_PARAM.SHAPE.X.LO,
                           Y       => o_y_pos + PIPELINE_PARAM.SHAPE.Y.LO,
                           ELEMENT => element,
                           DATA    => o_data
                );
            end loop;
            end loop;
            end loop;
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_c_atrb_vec := (others => (VALID => TRUE, START => FALSE, LAST => FALSE));
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_d_valid := (others => '0');
        for o_d_pos in 0 to PIPELINE_PARAM.SHAPE.D.SIZE-1 loop
                i_c_atrb := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                                PARAM => STREAM_PARAM,
                                C     => o_d_pos + STREAM_PARAM.SHAPE.C.LO,
                                DATA  => i_data
                            );
                if (i_c_atrb.VALID) then
                    o_d_valid(o_d_pos) := '1';
                end if;
        end loop;
        o_d_atrb_vec := GENERATE_IMAGE_STREAM_ATRB_VECTOR(
                            VALID => o_d_valid,
                            START => IMAGE_STREAM_DATA_IS_START_D(STREAM_PARAM, i_data),
                            LAST  => IMAGE_STREAM_DATA_IS_LAST_D (STREAM_PARAM, i_data)
                        );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_x_atrb_vec := (others => (VALID => TRUE, START => FALSE, LAST => FALSE));
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_y_atrb_vec := (others => (VALID => TRUE, START => FALSE, LAST => FALSE));
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SET_ATRB_VECTOR_TO_IMAGE_STREAM_DATA(
            PARAM       => PIPELINE_PARAM,
            ATRB_C_VEC  => o_c_atrb_vec,
            ATRB_D_VEC  => o_d_atrb_vec,
            ATRB_X_VEC  => o_x_atrb_vec,
            ATRB_Y_VEC  => o_y_atrb_vec,
            DATA        => o_data
        );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        return o_data;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Convolution Pipeline を イメージ出力 Stream に変換する関数
    -------------------------------------------------------------------------------
    function  CONVOLUTION_PIPELINE_TO_IMAGE_STREAM(
                  STREAM_PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  PIPELINE_PARAM    :  IMAGE_STREAM_PARAM_TYPE;
                  PIPELINE_DATA     :  std_logic_vector)
                  return               std_logic_vector
    is
        alias     i_data            :  std_logic_vector(PIPELINE_PARAM.DATA.SIZE-1 downto 0) is PIPELINE_DATA;
        variable  o_data            :  std_logic_vector(STREAM_PARAM  .DATA.SIZE-1 downto 0);
        variable  element           :  std_logic_vector(STREAM_PARAM  .ELEM_BITS-1 downto 0);
        variable  o_c_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to STREAM_PARAM.SHAPE.C.SIZE-1);
        variable  o_d_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to STREAM_PARAM.SHAPE.D.SIZE-1);
        variable  o_x_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to STREAM_PARAM.SHAPE.X.SIZE-1);
        variable  o_y_atrb_vec      :  IMAGE_STREAM_ATRB_VECTOR(0 to STREAM_PARAM.SHAPE.Y.SIZE-1);
    begin
        o_data := (others => '0');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for o_y_pos in 0 to STREAM_PARAM.SHAPE.Y.SIZE-1 loop
        for o_x_pos in 0 to STREAM_PARAM.SHAPE.X.SIZE-1 loop
        for o_c_pos in 0 to STREAM_PARAM.SHAPE.C.SIZE-1 loop
            element := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                           PARAM   => PIPELINE_PARAM,
                           C       =>           PIPELINE_PARAM.SHAPE.C.LO,
                           D       => o_c_pos + PIPELINE_PARAM.SHAPE.D.LO,
                           X       => o_x_pos + PIPELINE_PARAM.SHAPE.X.LO,
                           Y       => o_y_pos + PIPELINE_PARAM.SHAPE.Y.LO,
                           DATA    => i_data
                        );
            SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                           PARAM   => STREAM_PARAM,
                           C       => o_c_pos + STREAM_PARAM.SHAPE.C.LO,
                           D       =>           STREAM_PARAM.SHAPE.D.LO,
                           X       => o_x_pos + STREAM_PARAM.SHAPE.X.LO,
                           Y       => o_y_pos + STREAM_PARAM.SHAPE.Y.LO,
                           ELEMENT => element,
                           DATA    => o_data
                );
        end loop;
        end loop;
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_c_atrb_vec := GET_ATRB_D_VECTOR_FROM_IMAGE_STREAM_DATA(PIPELINE_PARAM, i_data);
        o_d_atrb_vec := (others => (VALID => TRUE, START => TRUE, LAST => TRUE));
        o_x_atrb_vec := GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(PIPELINE_PARAM, i_data);
        o_y_atrb_vec := GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(PIPELINE_PARAM, i_data);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SET_ATRB_VECTOR_TO_IMAGE_STREAM_DATA(
            PARAM       => STREAM_PARAM,
            ATRB_C_VEC  => o_c_atrb_vec,
            ATRB_D_VEC  => o_d_atrb_vec,
            ATRB_X_VEC  => o_x_atrb_vec,
            ATRB_Y_VEC  => o_y_atrb_vec,
            DATA        => o_data
        );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        return o_data;
    end function;
        
end package body;
