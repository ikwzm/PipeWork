-----------------------------------------------------------------------------------
--!     @file    image_window_buffer_intake.vhd
--!     @brief   Image Window Buffer Intake Module :
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
--! @brief   IMAGE_WINDOW_BUFFER :
--!          異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_BUFFER_INTAKE is
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT WINDOW DATA :
                          --! ウィンドウデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT WINDOW DATA VALID :
                          --! 入力ウィンドウデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でウィンドウデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT WINDOW DATA READY :
                          --! 入力ウィンドウデータレディ信号.
                          --! * キューが次のウィンドウデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でウィンドウデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_LINE_VALID    : --! @brief OUTPUT LINE VALID :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        O_X_SIZE        : --! @brief OUTPUT X SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_SIZE        : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_OFFSET      : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to 2**BUF_ADDR_BITS;
        O_LINE_ATRB     : --! @brief OUTPUT LINE ATTRIBUTE :
                          --! ライン属性出力.
                          out IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        O_LINE_FEED     : --! @brief OUTPUT LINE FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        O_LINE_RETURN   : --! @brief OUTPUT LINE RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER WRITE DATA :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
        BUF_WE          : --! @brief BUFFER WRITE ENABLE :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE              -1 downto 0)
    );
end IMAGE_WINDOW_BUFFER_INTAKE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_INTAKE_LINE_SELECTOR;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_INTAKE_BANK_WRITER;
architecture RTL of IMAGE_WINDOW_BUFFER_INTAKE is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  C_PARAM       :  IMAGE_WINDOW_PARAM_TYPE
                            := NEW_IMAGE_WINDOW_PARAM(
                                   ELEM_BITS    => I_PARAM.ELEM_BITS,
                                   SHAPE        => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                       C => I_PARAM.SHAPE.C,
                                                       X => I_PARAM.SHAPE.X,
                                                       Y => I_PARAM.SHAPE.Y
                                                   ),
                                   STRIDE       => I_PARAM.STRIDE,
                                   BORDER_TYPE  => I_PARAM.BORDER_TYPE
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
    signal    l_enable      :  std_logic;
    signal    l_start       :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    l_done        :  std_logic_vector(LINE_SIZE-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    c_data  <= I_DATA;
    c_valid <= I_VALID;
    I_READY <= c_ready;
    -------------------------------------------------------------------------------
    -- LINE_SELECTOR :
    -------------------------------------------------------------------------------
    LINE_SELECTOR: IMAGE_WINDOW_BUFFER_INTAKE_LINE_SELECTOR
        generic map (                                -- 
            I_PARAM         => C_PARAM             , -- 
            O_PARAM         => L_PARAM             , -- 
            LINE_SIZE       => LINE_SIZE           , --   
            QUEUE_SIZE      => 1                     --   
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_DATA          => c_data              , -- In  :
            I_VALID         => c_valid             , -- In  :
            I_READY         => c_ready             , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 Window I/F
        ---------------------------------------------------------------------------
            O_ENABLE        => l_enable            , -- Out :
            O_LINE_START    => l_start             , -- Out :
            O_LINE_DONE     => l_done              , -- Out :
            O_DATA          => l_data              , -- Out :
            O_VALID         => l_valid             , -- Out :
            O_READY         => l_ready             , -- In  :
        ---------------------------------------------------------------------------
        -- ライン制御 I/F
        ---------------------------------------------------------------------------
            LINE_VALID      => O_LINE_VALID        , -- Out :
            LINE_ATRB       => O_LINE_ATRB         , -- Out :
            LINE_FEED       => O_LINE_FEED         , -- In  :
            LINE_RETURN     => O_LINE_RETURN         -- In  :
        );
    -------------------------------------------------------------------------------
    -- BANK_WRITER :
    -------------------------------------------------------------------------------
    BANK_WRITER: IMAGE_WINDOW_BUFFER_INTAKE_BANK_WRITER
        generic map (                                -- 
            I_PARAM         => L_PARAM             , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE        , -- 
            CHANNEL_SIZE    => CHANNEL_SIZE        , --   
            BANK_SIZE       => BANK_SIZE           , --   
            LINE_SIZE       => LINE_SIZE           , --   
            BUF_ADDR_BITS   => BUF_ADDR_BITS       , --   
            BUF_DATA_BITS   => BUF_DATA_BITS         --   
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_ENABLE        => l_enable            , -- In  :
            I_LINE_START    => l_start             , -- In  :
            I_LINE_DONE     => l_done              , -- Out :
            I_DATA          => l_data              , -- In  :
            I_VALID         => l_valid             , -- In  :
            I_READY         => l_ready             , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_X_SIZE        => O_X_SIZE            , -- Out :
            O_C_SIZE        => O_C_SIZE            , -- Out :
            O_C_OFFSET      => O_C_OFFSET          , -- Out :
        ---------------------------------------------------------------------------
        -- バッファ I/F
        ---------------------------------------------------------------------------
            BUF_DATA        => BUF_DATA            , -- Out :
            BUF_ADDR        => BUF_ADDR            , -- Out :
            BUF_WE          => BUF_WE                -- Out :
        );
end RTL;
