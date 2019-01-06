-----------------------------------------------------------------------------------
--!     @file    image_window_buffer_outlet.vhd
--!     @brief   Image Window Buffer Outlet Module :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2019/1/4
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
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   IMAGE_WINDOW_BUFFER_OUTLET :
--!          異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_BUFFER_OUTLET is
    generic (
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        MAX_D_SIZE      : --! @brief MAX OUTPUT CHANNEL SIZE :
                          integer := 1;
        D_STRIDE        : --! @brief OUTPUT CHANNEL STRIDE SIZE :
                          integer := 1;
        D_UNROLL        : --! @brief OUTPUT CHANNEL UNROLL SIZE :
                          integer := 1;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8
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
    -- 各種サイズ
    -------------------------------------------------------------------------------
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_D_SIZE := 1;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        C_OFFSET        : --! @brief OUTPUT CHANNEL BUFFER ADDRESS OFFSET :
                          in  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_LINE_VALID    : --! @brief INPUT LINE VALID :
                          --! ライン有効信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_ATRB     : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        I_LINE_FEED     : --! @brief INPUT LINE FEED :
                          --! ラインフィード信号出力.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          out std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        I_LINE_RETURN   : --! @brief INPUT LINE RETURN :
                          --! ラインリターン信号出力.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          out std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT WINDOW DATA :
                          --! ウィンドウデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_D_ATRB        : --! @brief OUTPUT CHANNEL ATTRIBUTE :
                          out IMAGE_ATRB_VECTOR(0 to D_UNROLL-1);
        O_VALID         : --! @brief OUTPUT WINDOW DATA VALID :
                          --! 出力ウィンドウデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT WINDOW DATA READY :
                          --! 出力ウィンドウデータレディ信号.
                          in  std_logic;
        O_LAST          : --! @brief OUTPUT LINE FEED :
                          --! 最終ウィンドウ入力.
                          in  std_logic;
        O_FEED          : --! @brief OUTPUT LINE FEED :
                          --! ラインフィード入力.
                          in  std_logic;
        O_RETURN        : --! @brief OUTPUT LINE RETURN :
                          --! ラインリターン入力.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end IMAGE_WINDOW_BUFFER_OUTLET;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_OUTLET_LINE_SELECTOR;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_OUTLET_BANK_READER;
architecture RTL of IMAGE_WINDOW_BUFFER_OUTLET is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  C_PARAM       :  IMAGE_WINDOW_PARAM_TYPE
                            := NEW_IMAGE_WINDOW_PARAM(
                                   ELEM_BITS    => O_PARAM.ELEM_BITS,
                                   INFO_BITS    => D_UNROLL*IMAGE_ATRB_BITS,
                                   SHAPE        => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                       C => O_PARAM.SHAPE.C,
                                                       X => O_PARAM.SHAPE.X,
                                                       Y => O_PARAM.SHAPE.Y
                                                   ),
                                   STRIDE       => O_PARAM.STRIDE,
                                   BORDER_TYPE  => O_PARAM.BORDER_TYPE
                               );
    signal    c_data        :  std_logic_vector(C_PARAM.DATA.SIZE-1 downto 0);
    signal    c_valid       :  std_logic;
    signal    c_ready       :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  L_PARAM       :  IMAGE_WINDOW_PARAM_TYPE
                            := NEW_IMAGE_WINDOW_PARAM(
                                   ELEM_BITS    => C_PARAM.ELEM_BITS,
                                   INFO_BITS    => C_PARAM.INFO_BITS,
                                   SHAPE        => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                       C => C_PARAM.SHAPE.C,
                                                       X => C_PARAM.SHAPE.X,
                                                       Y => NEW_IMAGE_VECTOR_RANGE(LINE_SIZE)
                                                   ),
                                   STRIDE       => C_PARAM.STRIDE,
                                   BORDER_TYPE  => C_PARAM.BORDER_TYPE
                               );
    signal    l_data        :  std_logic_vector(L_PARAM.DATA.SIZE-1 downto 0);
    signal    l_valid       :  std_logic;
    signal    l_ready       :  std_logic;
    signal    l_start       :  std_logic_vector(LINE_SIZE-1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BANK_READER: IMAGE_WINDOW_BUFFER_OUTLET_BANK_READER
        generic map (                            -- 
            O_PARAM         => L_PARAM         , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE    , --   
            CHANNEL_SIZE    => CHANNEL_SIZE    , --   
            BANK_SIZE       => BANK_SIZE       , --   
            LINE_SIZE       => LINE_SIZE       , --   
            MAX_D_SIZE      => MAX_D_SIZE      , --
            D_STRIDE        => D_STRIDE        , --
            D_UNROLL        => D_UNROLL        , --
            BUF_ADDR_BITS   => BUF_ADDR_BITS   , --   
            BUF_DATA_BITS   => BUF_DATA_BITS     --
        )                                        -- 
        port map (                               -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_LINE_START    => l_start         , -- In  :
            I_LINE_ATRB     => I_LINE_ATRB     , -- In  :
            X_SIZE          => X_SIZE          , -- In  :
            D_SIZE          => D_SIZE          , -- In  :
            C_SIZE          => C_SIZE          , -- In  :
            C_OFFSET        => C_OFFSET        , -- In  :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => l_data          , -- Out :
            O_VALID         => l_valid         , -- Out :
            O_READY         => l_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- バッファメモリ I/F
        ---------------------------------------------------------------------------
            BUF_DATA        => BUF_DATA        , -- In  :
            BUF_ADDR        => BUF_ADDR          -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    LINE_SELECTOR: IMAGE_WINDOW_BUFFER_OUTLET_LINE_SELECTOR
        generic map (                            -- 
            I_PARAM         => L_PARAM         , -- 
            O_PARAM         => C_PARAM         , -- 
            LINE_SIZE       => LINE_SIZE       , --   
            QUEUE_SIZE      => 1                 --   
        )                                        -- 
        port map (                               -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_LINE_START    => l_start         , -- Out :
            I_DATA          => l_data          , -- In  :
            I_VALID         => l_valid         , -- In  :
            I_READY         => l_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => c_data          , -- Out :
            O_VALID         => c_valid         , -- Out :
            O_READY         => c_ready         , -- In  :
            O_LAST          => O_LAST          , -- In  :
            O_FEED          => O_FEED          , -- In  :
            O_RETURN        => O_RETURN        , -- In  :
        ---------------------------------------------------------------------------
        -- ライン制御 I/F
        ---------------------------------------------------------------------------
            LINE_VALID      => I_LINE_VALID    , -- In  :
            LINE_ATRB       => I_LINE_ATRB     , -- In  :
            LINE_FEED       => I_LINE_FEED     , -- Out :
            LINE_RETURN     => I_LINE_RETURN     -- Out :
    );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (c_data)
        alias info :  std_logic_vector(C_PARAM.INFO_BITS-1 downto 0) is c_data(C_PARAM.DATA.INFO_FIELD.HI downto C_PARAM.DATA.INFO_FIELD.LO);
    begin
        for d_pos in 0 to D_UNROLL-1 loop
            O_D_ATRB(d_pos).VALID <= (info(d_pos*IMAGE_ATRB_BITS + IMAGE_ATRB_VALID_POS) = '1');
            O_D_ATRB(d_pos).START <= (info(d_pos*IMAGE_ATRB_BITS + IMAGE_ATRB_START_POS) = '1');
            O_D_ATRB(d_pos).LAST  <= (info(d_pos*IMAGE_ATRB_BITS + IMAGE_ATRB_LAST_POS ) = '1');
        end loop;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_DATA(O_PARAM.DATA.ELEM_FIELD.HI downto O_PARAM.DATA.ELEM_FIELD.LO) <= c_data(C_PARAM.DATA.ELEM_FIELD.HI downto C_PARAM.DATA.ELEM_FIELD.LO);
    O_DATA(O_PARAM.DATA.ATRB_FIELD.HI downto O_PARAM.DATA.ATRB_FIELD.LO) <= c_data(C_PARAM.DATA.ATRB_FIELD.HI downto C_PARAM.DATA.ATRB_FIELD.LO);
    O_VALID <= c_valid;
    c_ready <= O_READY;
end RTL;
