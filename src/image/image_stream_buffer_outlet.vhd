-----------------------------------------------------------------------------------
--!     @file    image_stream_buffer_outlet.vhd
--!     @brief   Image Stream Buffer Outlet Module :
--!              異なる形のイメージストリームを継ぐためのバッファの出力側モジュール
--!     @version 1.8.0
--!     @date    2019/3/31
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
--! @brief   Image Stream Buffer Outlet Module :
--!          異なる形のイメージストリームを継ぐためのバッファの出力側モジュール
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_BUFFER_OUTLET is
    generic (
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          --! * O_PARAM.INFO_BITS = 0 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 出力側のイメージの形(SHAPE)を指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8;
        BANK_QUEUE      : --! @brief BANK MEMORY READER QUEUE SIZE :
                          --! IMAGE_STREAM_BUFFER_BANK_MEMORY_READER の出力キューの
                          --! 大きさをワード数で指定する.
                          --! * BANK_QUEUE=0 の場合は出力にキューが挿入されずダイレ
                          --!   クトに出力される.
                          integer := 0;
        LINE_QUEUE      : --! @brief OUTLET LINE SELECTOR QUEUE SIZE :
                          --! IMAGE_STREAM_BUFFER_OUTLET_LINE_SELECTOR の出力キュー
                          --! の大きさをワード数で指定する.
                          --! * QUEUE_SIZE=0 の場合は出力にキューが挿入されずダイレ
                          --!   クトに出力される.
                          integer := 2
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
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.D.MAX_SIZE := O_SHAPE.D.SIZE;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
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
                          in  IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
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
        O_DATA          : --! @brief OUTPUT STREAM DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT STREAM DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT STREAM DATA READY :
                          --! 出力ストリームデータレディ信号.
                          in  std_logic;
        O_LAST          : --! @brief OUTPUT LINE FEED :
                          --! 最終ストリーム入力.
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
end IMAGE_STREAM_BUFFER_OUTLET;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_BUFFER_OUTLET_LINE_SELECTOR;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_BUFFER_BANK_MEMORY_READER;
architecture RTL of IMAGE_STREAM_BUFFER_OUTLET is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  T_PARAM       :  IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(
                                   ELEM_BITS    => O_PARAM.ELEM_BITS,
                                   INFO_BITS    => O_PARAM.INFO_BITS,
                                   C            => O_PARAM.SHAPE.C,
                                   D            => O_PARAM.SHAPE.D,
                                   X            => O_PARAM.SHAPE.X,
                                   Y            => NEW_IMAGE_SHAPE_SIDE_CONSTANT(LINE_SIZE),
                                   STRIDE       => O_PARAM.STRIDE,
                                   BORDER_TYPE  => O_PARAM.BORDER_TYPE
                               );
    signal    t_data        :  std_logic_vector(T_PARAM.DATA.SIZE-1 downto 0);
    signal    t_valid       :  std_logic;
    signal    t_ready       :  std_logic;
    signal    t_start       :  std_logic_vector(LINE_SIZE-1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BANK_READER: IMAGE_STREAM_BUFFER_BANK_MEMORY_READER
        generic map (                            -- 
            O_PARAM         => T_PARAM         , -- 
            O_SHAPE         => O_SHAPE         , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE    , --   
            BANK_SIZE       => BANK_SIZE       , --   
            LINE_SIZE       => LINE_SIZE       , --   
            BUF_ADDR_BITS   => BUF_ADDR_BITS   , --   
            BUF_DATA_BITS   => BUF_DATA_BITS   , --
            QUEUE_SIZE      => BANK_QUEUE        -- 
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
            I_LINE_START    => t_start         , -- In  :
            I_LINE_ATRB     => I_LINE_ATRB     , -- In  :
            X_SIZE          => X_SIZE          , -- In  :
            D_SIZE          => D_SIZE          , -- In  :
            C_SIZE          => C_SIZE          , -- In  :
            C_OFFSET        => C_OFFSET        , -- In  :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => t_data          , -- Out :
            O_VALID         => t_valid         , -- Out :
            O_READY         => t_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- バッファメモリ I/F
        ---------------------------------------------------------------------------
            BUF_DATA        => BUF_DATA        , -- In  :
            BUF_ADDR        => BUF_ADDR          -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    LINE_SELECTOR: IMAGE_STREAM_BUFFER_OUTLET_LINE_SELECTOR
        generic map (                            -- 
            I_PARAM         => T_PARAM         , -- 
            O_PARAM         => O_PARAM         , -- 
            LINE_SIZE       => LINE_SIZE       , --   
            QUEUE_SIZE      => LINE_QUEUE        --   
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
            I_LINE_START    => t_start         , -- Out :
            I_DATA          => t_data          , -- In  :
            I_VALID         => t_valid         , -- In  :
            I_READY         => t_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => O_DATA          , -- Out :
            O_VALID         => O_VALID         , -- Out :
            O_READY         => O_READY         , -- In  :
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
end RTL;
