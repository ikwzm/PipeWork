-----------------------------------------------------------------------------------
--!     @file    convolution_int_core.vhd
--!     @brief   Convolution Integer Core Module
--!     @version 1.8.0
--!     @date    2019/3/21
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
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.CONVOLUTION_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief Convolution Integer Core Module
-----------------------------------------------------------------------------------
entity  CONVOLUTION_INT_CORE is
    generic (
        PARAM           : --! @brief CONVOLUTION PARAMETER :
                          --! 畳み込みのパラメータを指定する.
                          CONVOLUTION_PARAM_TYPE := NEW_CONVOLUTION_PARAM(
                              KERNEL_SIZE => CONVOLUTION_KERNEL_SIZE_3x3,
                              STRIDE      => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1),
                              I_STREAM    => NEW_IMAGE_STREAM_PARAM(8,1,1,1),
                              I_SHAPE     => NEW_IMAGE_SHAPE_CONSTANT(8,32,0,32,32),
                              B_ELEM_BITS => 16,
                              W_ELEM_BITS =>  8,
                              M_ELEM_BITS => 16,
                              O_ELEM_BITS => 16,
                              O_SHAPE_C   => NEW_IMAGE_SHAPE_SIDE_CONSTANT(32)
                          );
        SIGN            : --! 演算時の正負符号の有無を指定する.
                          --! * SIGN=TRUE  の場合、符号有り(  signed)で計算する.
                          --! * SIGN=FALSE の場合、符号無し(unsigned)で計算する.
                          boolean := TRUE
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK             : --! @brief CLOCK :
                          --! クロック信号
                          in  std_logic; 
        RST             : --! @brief ASYNCRONOUSE RESET :
                          --! 非同期リセット信号.アクティブハイ.
                          in  std_logic;
        CLR             : --! @brief SYNCRONOUSE RESET :
                          --! 同期リセット信号.アクティブハイ.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- 各種パラメータ入力 I/F
    -------------------------------------------------------------------------------
        C_SIZE          : --! @brief CONVOLUTION C CHANNEL SIZE :
                          in  integer range 0 to PARAM.SHAPE.C.MAX_SIZE := PARAM.SHAPE.C.SIZE;
        D_SIZE          : --! @brief CONVOLUTION D CHANNEL SIZE :
                          in  integer range 0 to PARAM.SHAPE.D.MAX_SIZE := PARAM.SHAPE.D.SIZE;
        X_SIZE          : --! @brief CONVOLUTION X SIZE :
                          in  integer range 0 to PARAM.SHAPE.X.MAX_SIZE := PARAM.SHAPE.X.SIZE;
        Y_SIZE          : --! @brief CONVOLUTION Y SIZE :
                          in  integer range 0 to PARAM.SHAPE.Y.MAX_SIZE := PARAM.SHAPE.Y.SIZE;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT IMAGE DATA :
                          --! イメージデータ入力.
                          in  std_logic_vector(PARAM.I_STREAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT IMAGE DATA VALID :
                          --! 入力イメージデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でイメージデータが取り込
                          --!   まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT IMAGE DATA READY :
                          --! 入力イメージデータレディ信号.
                          --! * 次のイメージデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でイメージデータが取り込
                          --!   まれる.
                          out std_logic;
        W_DATA          : --! @brief INPUT WEIGHT DATA :
                          --! 重みデータ入力.
                          in  std_logic_vector(PARAM.W_STREAM.DATA.SIZE-1 downto 0);
        W_VALID         : --! @brief INPUT WEIGHT DATA VALID :
                          --! 入力重みデータ有効信号.
                          --! * W_DATAが有効であることを示す.
                          --! * W_VALID='1'and W_READY='1'で重みデータが取り込ま
                          --!   れる.
                          in  std_logic;
        W_READY         : --! @brief INPUT WEIGHT DATA READY :
                          --! 入力重みデータレディ信号.
                          --! * 次の重みデータを入力出来ることを示す.
                          --! * W_VALID='1'and W_READY='1'で重みデータが取り込ま
                          --!   れる.
                          out std_logic;
        B_DATA          : --! @brief INPUT BIAS DATA :
                          --! バイアスデータ入力.
                          in  std_logic_vector(PARAM.B_STREAM.DATA.SIZE-1 downto 0);
        B_VALID         : --! @brief INPUT BIAS DATA VALID :
                          --! 入力バイアスデータ有効信号.
                          --! * B_DATAが有効であることを示す.
                          --! * B_VALID='1'and B_READY='1'でバイアスデータが取り込
                          --!   まれる.
                          in  std_logic;
        B_READY         : --! @brief INPUT BIAS DATA READY :
                          --! 入力バイアスデータレディ信号.
                          --! * 次のバイアスデータを入力出来ることを示す.
                          --! * B_VALID='1'and B_READY='1'でバイアスデータが取り込
                          --!   まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT IMAGE DATA :
                          --! イメージデータ出力.
                          out std_logic_vector(PARAM.O_STREAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT IMAGE DATA VALID :
                          --! 出力イメージデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でイメージデータがキュー
                          --!   から取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE DATA READY :
                          --! 出力イメージデータレディ信号.
                          --! * O_VALID='1'and O_READY='1'でイメージデータがキュー
                          --!   から取り除かれる.
                          in  std_logic
    );
end CONVOLUTION_INT_CORE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_BUFFER;
use     PIPEWORK.CONVOLUTION_TYPES.all;
use     PIPEWORK.CONVOLUTION_COMPONENTS.CONVOLUTION_INT_MULTIPLIER;
use     PIPEWORK.CONVOLUTION_COMPONENTS.CONVOLUTION_INT_ADDER_TREE;
use     PIPEWORK.CONVOLUTION_COMPONENTS.CONVOLUTION_INT_ACCUMULATOR;
architecture RTL of CONVOLUTION_INT_CORE is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    a_data          :  std_logic_vector(PARAM.A_STREAM.DATA.SIZE-1 downto 0);
    signal    a_valid         :  std_logic;
    signal    a_ready         :  std_logic;
    signal    a_atrb_x        :  IMAGE_STREAM_ATRB_VECTOR(0 to PARAM.A_STREAM.SHAPE.X.SIZE-1);
    signal    a_atrb_y        :  IMAGE_STREAM_ATRB_VECTOR(0 to PARAM.A_STREAM.SHAPE.Y.SIZE-1);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    mul_i_data      :  std_logic_vector(PARAM.A_PIPELINE.DATA.SIZE-1 downto 0);
    signal    mul_i_valid     :  std_logic;
    signal    mul_i_ready     :  std_logic;
    signal    mul_i_atrb_x    :  IMAGE_STREAM_ATRB_VECTOR(0 to PARAM.A_PIPELINE.SHAPE.X.SIZE-1);
    signal    mul_i_atrb_y    :  IMAGE_STREAM_ATRB_VECTOR(0 to PARAM.A_PIPELINE.SHAPE.Y.SIZE-1);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    mul_w_data      :  std_logic_vector(PARAM.W_PIPELINE.DATA.SIZE-1 downto 0);
    signal    mul_w_valid     :  std_logic;
    signal    mul_w_ready     :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    mul_o_data      :  std_logic_vector(PARAM.M_PIPELINE.DATA.SIZE-1 downto 0);
    signal    mul_o_valid     :  std_logic;
    signal    mul_o_ready     :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    add_o_data      :  std_logic_vector(PARAM.O_PIPELINE.DATA.SIZE-1 downto 0);
    signal    add_o_valid     :  std_logic;
    signal    add_o_ready     :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    acc_b_data      :  std_logic_vector(PARAM.B_PIPELINE.DATA.SIZE-1 downto 0);
    signal    acc_b_valid     :  std_logic;
    signal    acc_b_ready     :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    acc_o_data      :  std_logic_vector(PARAM.O_PIPELINE.DATA.SIZE-1 downto 0);
    signal    acc_o_valid     :  std_logic;
    signal    acc_o_ready     :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- INPUT BUFFER
    -------------------------------------------------------------------------------
    A: IMAGE_STREAM_BUFFER                       -- 
        generic map (                            -- 
            I_PARAM         => PARAM.I_STREAM  , -- 
            O_PARAM         => PARAM.A_STREAM  , -- 
            O_SHAPE         => PARAM.A_SHAPE   , -- 
            ELEMENT_SIZE    => PARAM.I_SHAPE.C.MAX_SIZE * PARAM.I_SHAPE.X.MAX_SIZE
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            C_SIZE          => C_SIZE          , -- In  :
            D_SIZE          => D_SIZE          , -- In  :
            X_SIZE          => X_SIZE          , -- In  :
            I_DATA          => I_DATA          , -- In  :
            I_VALID         => I_VALID         , -- In  :
            I_READY         => I_READY         , -- Out :
            O_DATA          => a_data          , -- Out :
            O_VALID         => a_valid         , -- Out :
            O_READY         => a_ready           -- In  :
        );                                       --
    a_atrb_x <= GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM.A_STREAM, a_data);
    a_atrb_y <= GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM.A_STREAM, a_data);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    mul_i_data  <= CONVOLUTION_PIPELINE_FROM_IMAGE_STREAM(
                       PIPELINE_PARAM => PARAM.A_PIPELINE ,
                       STREAM_PARAM   => PARAM.A_STREAM   ,
                       KERNEL_SIZE    => PARAM.KERNEL_SIZE,
                       STRIDE         => PARAM.STRIDE     ,
                       STREAM_DATA    => a_data
                   );
    mul_i_valid <= a_valid;
    a_ready     <= mul_i_ready;
    mul_i_atrb_x <= GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM.A_PIPELINE, mul_i_data);
    mul_i_atrb_y <= GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(PARAM.A_PIPELINE, mul_i_data);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    mul_w_data  <= CONVOLUTION_PIPELINE_FROM_WEIGHT_STREAM(
                       PIPELINE_PARAM => PARAM.W_PIPELINE ,
                       STREAM_PARAM   => PARAM.W_STREAM   ,
                       KERNEL_SIZE    => PARAM.KERNEL_SIZE,
                       STREAM_DATA    => W_DATA
                   );
    mul_w_valid <= W_VALID;
    W_READY     <= mul_w_ready;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    acc_b_data  <= CONVOLUTION_PIPELINE_FROM_BIAS_STREAM(
                       PIPELINE_PARAM => PARAM.B_PIPELINE ,
                       STREAM_PARAM   => PARAM.B_STREAM   ,
                       STREAM_DATA    => B_DATA
                   );
    acc_b_valid <= B_VALID;
    B_READY     <= acc_b_ready;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    MUL: CONVOLUTION_INT_MULTIPLIER              -- 
        generic map (                            -- 
            I_PARAM         => PARAM.A_PIPELINE, --
            W_PARAM         => PARAM.W_PIPELINE, --
            O_PARAM         => PARAM.M_PIPELINE, --
            QUEUE_SIZE      => 2               , --
            SIGN            => SIGN              --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            I_DATA          => mul_i_data      , -- In  :
            I_VALID         => mul_i_valid     , -- In  :
            I_READY         => mul_i_ready     , -- Out :
            W_DATA          => mul_w_data      , -- In  :
            W_VALID         => mul_w_valid     , -- In  :
            W_READY         => mul_w_ready     , -- Out :
            O_DATA          => mul_o_data      , -- Out :
            O_VALID         => mul_o_valid     , -- Out :
            O_READY         => mul_o_ready       -- In  :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ADD: CONVOLUTION_INT_ADDER_TREE              -- 
        generic map (                            -- 
            I_PARAM         => PARAM.M_PIPELINE, --
            O_PARAM         => PARAM.O_PIPELINE, --
            QUEUE_SIZE      => 2               , --
            SIGN            => SIGN              --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            I_DATA          => mul_o_data      , -- In  :
            I_VALID         => mul_o_valid     , -- In  :
            I_READY         => mul_o_ready     , -- Out :
            O_DATA          => add_o_data      , -- Out :
            O_VALID         => add_o_valid     , -- Out :
            O_READY         => add_o_ready       -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ACC: CONVOLUTION_INT_ACCUMULATOR             -- 
        generic map (                            -- 
            I_PARAM         => PARAM.O_PIPELINE, --
            O_PARAM         => PARAM.O_PIPELINE, --
            B_PARAM         => PARAM.B_PIPELINE, --
            QUEUE_SIZE      => 2               , --
            SIGN            => SIGN              --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            I_DATA          => add_o_data      , -- In  :
            I_VALID         => add_o_valid     , -- In  :
            I_READY         => add_o_ready     , -- Out :
            B_DATA          => acc_b_data      , -- In  :
            B_VALID         => acc_b_valid     , -- In  :
            B_READY         => acc_b_ready     , -- Out :
            O_DATA          => acc_o_data      , -- Out :
            O_VALID         => acc_o_valid     , -- Out :
            O_READY         => acc_o_ready       -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_DATA      <= CONVOLUTION_PIPELINE_TO_IMAGE_STREAM(
                       STREAM_PARAM   => PARAM.O_STREAM   ,
                       PIPELINE_PARAM => PARAM.O_PIPELINE ,
                       PIPELINE_DATA  => acc_o_data
                   );
    O_VALID     <= acc_o_valid;
    acc_o_ready <= O_READY;
end RTL;
