-----------------------------------------------------------------------------------
--!     @file    image_stream_generator.vhd
--!     @brief   Image Stream Generator Module
--!     @version 2.1.0
--!     @date    2024/2/21
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2024 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
--! @brief   IMAGE_STREAM_GENERATOR_SINGLE_ELEMENT_WITH_PADDING :
--!          入力データに対してイメージストリームの属性を付加して出力する.
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_GENERATOR is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        O_PARAM         : --! @brief OUTPUT IMAGE STREAM PARAMETER :
                          --! 出力側イメージストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(32,1,1,1);
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE PARAMETER :
                          IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(32,1,1,1);
                          --! 出力側イメージストリームのパラメータを指定する.
        I_DATA_BITS     : --! @brief INPUT  STREAM DATA BIT SIZE :
                          --! 入力側のデータのビット幅を指定する.
                          integer := 32;
        I_STRB_BITS     : --! @brief INPUT  STREAM STRB BIT SIZE :
                          --! 入力側のストローブ信号のビット幅を指定する.
                          integer := 1;
        MAX_PAD_SIZE    : --! @brief MAX PADDING SIZE SIZE :
                          integer := 0
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
    -- 
    -------------------------------------------------------------------------------
        START           : --! @brief STREAM START :
                          in  std_logic;
        BUSY            : --! @brief STREAM BUSY :
                          out std_logic;
        DONE            : --! @brief STREAM DONE :
                          out std_logic;
        C_SIZE          : --! @brief INPUT C CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
        D_SIZE          : --! @brief INPUT D CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.D.SIZE;
        X_SIZE          : --! @brief INPUT IMAGE WIDTH :
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
        Y_SIZE          : --! @brief INPUT IMAGE HEIGHT :
                          in  integer range 0 to O_SHAPE.Y.MAX_SIZE := O_SHAPE.Y.SIZE;
        LEFT_PAD_SIZE   : --! @brief IMAGE WIDTH START PAD SIZE :
                          in  integer range 0 to MAX_PAD_SIZE := 0;
        RIGHT_PAD_SIZE  : --! @brief IMAGE WIDTH LAST  PAD SIZE :
                          in  integer range 0 to MAX_PAD_SIZE := 0;
        TOP_PAD_SIZE    : --! @brief IMAGE HEIGHT START PAD SIZE :
                          in  integer range 0 to MAX_PAD_SIZE := 0;
        BOTTOM_PAD_SIZE : --! @brief IMAGE HEIGHT LAST  PAD SIZE :
                          in  integer range 0 to MAX_PAD_SIZE := 0;
        PAD_DATA        : --! @brief PADDING DATA :
                          in  std_logic_vector(I_DATA_BITS    -1 downto 0);
    -------------------------------------------------------------------------------
    -- STREAM 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_DATA_BITS    -1 downto 0);
        I_STRB          : --! @brief INPUT STREAM STROBE :
                          --! ストリームストローブ入力.
                          in  std_logic_vector(I_STRB_BITS    -1 downto 0);
        I_VALID         : --! @brief INPUT STREAM VALID :
                          --! 入力ストリムーデータ有効信号.
                          --! I_DATA/I_STRB/I_LAST が有効であることを示す.
                          in  std_logic;
        I_READY         : --! @brief INPUT STREAM READY :
                          --! 入力ストリムーデータレディ信号.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- IMAGE STREAM 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT IMAGE STREAM DATA :
                          --! イメージストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT IMAGE STREAM DATA VALID :
                          --! 出力イメージストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE STREAM DATA READY :
                          --! 出力イメージストリームデータレディ信号.
                          in  std_logic
    );
end IMAGE_STREAM_GENERATOR;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_GENERATOR_SINGLE_ELEMENT_NO_PADDING;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_GENERATOR_SINGLE_ELEMENT_WITH_PADDING;
architecture RTL of IMAGE_STREAM_GENERATOR is
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    SINGLE_ELEMENT_NO_PADDING: if (I_DATA_BITS = O_PARAM.DATA.ELEM_FIELD.SIZE) and
                                   (MAX_PAD_SIZE = 0) generate
    begin
        GEN: IMAGE_STREAM_GENERATOR_SINGLE_ELEMENT_NO_PADDING
            generic map (                            -- 
                O_PARAM         => O_PARAM         , -- 
                O_SHAPE         => O_SHAPE         , --
                I_DATA_BITS     => I_DATA_BITS       -- 
            )                                        -- 
            port map (                               -- 
                CLK             => CLK             , -- In  :
                RST             => RST             , -- In  :
                CLR             => CLR             , -- In  :
                START           => START           , -- In  :
                BUSY            => BUSY            , -- Out :
                DONE            => DONE            , -- Out :
                C_SIZE          => C_SIZE          , -- In  :
                D_SIZE          => D_SIZE          , -- In  :
                X_SIZE          => X_SIZE          , -- In  :
                Y_SIZE          => Y_SIZE          , -- In  :
                I_DATA          => I_DATA          , -- In  :
                I_VALID         => I_VALID         , -- In  :
                I_READY         => I_READY         , -- Out :
                O_DATA          => O_DATA          , -- Out :
                O_VALID         => O_VALID         , -- Out :
                O_READY         => O_READY           -- In  :
            );
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    SINGLE_ELEMENT_WITH_PADDING: if (I_DATA_BITS = O_PARAM.DATA.ELEM_FIELD.SIZE) and
                                    (MAX_PAD_SIZE > 0) generate
    begin
        GEN: IMAGE_STREAM_GENERATOR_SINGLE_ELEMENT_WITH_PADDING
            generic map (                            -- 
                O_PARAM         => O_PARAM         , -- 
                O_SHAPE         => O_SHAPE         , --
                I_DATA_BITS     => I_DATA_BITS     , --
                MAX_PAD_SIZE    => MAX_PAD_SIZE      -- 
            )                                        -- 
            port map (                               -- 
                CLK             => CLK             , -- In  :
                RST             => RST             , -- In  :
                CLR             => CLR             , -- In  :
                START           => START           , -- In  :
                BUSY            => BUSY            , -- Out :
                DONE            => DONE            , -- Out :
                C_SIZE          => C_SIZE          , -- In  :
                D_SIZE          => D_SIZE          , -- In  :
                X_SIZE          => X_SIZE          , -- In  :
                Y_SIZE          => Y_SIZE          , -- In  :
                LEFT_PAD_SIZE   => LEFT_PAD_SIZE   , -- In  :
                RIGHT_PAD_SIZE  => RIGHT_PAD_SIZE  , -- In  :
                TOP_PAD_SIZE    => TOP_PAD_SIZE    , -- In  :
                BOTTOM_PAD_SIZE => BOTTOM_PAD_SIZE , -- In  :
                PAD_DATA        => PAD_DATA        , -- In  :
                I_DATA          => I_DATA          , -- In  :
                I_VALID         => I_VALID         , -- In  :
                I_READY         => I_READY         , -- Out :
                O_DATA          => O_DATA          , -- Out :
                O_VALID         => O_VALID         , -- Out :
                O_READY         => O_READY           -- In  :
            );
    end generate;
end RTL;

