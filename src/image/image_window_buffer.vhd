-----------------------------------------------------------------------------------
--!     @file    image_window_buffer.vhd
--!     @brief   Image Window Buffer MODULE :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2018/12/12
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
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   IMAGE_WINDOW_BUFFER :
--!          異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_BUFFER is
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        MEM_BANK_SIZE   : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        MEM_LINE_SIZE   : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        ID              : --! @brief SDPRAM IDENTIFIER :
                          --! どのモジュールで使われているかを示す識別番号.
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
        O_FEED          : --! @brief OUTPUT FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic := '1';
        O_RETURN        : --! @brief OUTPUT RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic := '1';
        O_DATA          : --! @brief OUTPUT WINDOW DATA :
                          --! ウィンドウデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT WINDOW DATA VALID :
                          --! 出力ウィンドウデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でウィンドウデータがキュー
                          --!   から取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT WINDOW DATA READY :
                          --! 出力ウィンドウデータレディ信号.
                          --! * キューから次のウィンドウデータを取り除く準備が出来て
                          --!   いることを示す.
                          --! * O_VALID='1'and O_READY='1'でウィンドウデータがキュー
                          --!   から取り除かれる.
                          in  std_logic
    );
end IMAGE_WINDOW_BUFFER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.SDPRAM;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_WRITER;
architecture RTL of IMAGE_WINDOW_BUFFER is
    -------------------------------------------------------------------------------
    -- メモリのバンク数
    -------------------------------------------------------------------------------
    constant  BANK_SIZE             :  integer := MEM_BANK_SIZE;
    -------------------------------------------------------------------------------
    -- メモリのライン数
    -------------------------------------------------------------------------------
    constant  LINE_SIZE             :  integer := MEM_LINE_SIZE;
    -------------------------------------------------------------------------------
    -- メモリのビット幅
    -------------------------------------------------------------------------------
    function  CALC_RAM_WIDTH    return integer is
        variable width              :  integer;
    begin
        width := 0;
        while (2**width < (O_PARAM.SHAPE.C.SIZE * O_PARAM.ELEM_BITS)) loop
            width := width + 1;
        end loop;
        return width;
    end function;
    constant  RAM_WIDTH             :  integer := CALC_RAM_WIDTH;
    -------------------------------------------------------------------------------
    -- メモリバンク１つあたりの深さ(ビット単位)を２のべき乗値で示す
    -------------------------------------------------------------------------------
    function  CALC_RAM_DEPTH    return integer is
        variable size               :  integer;
        variable depth              :  integer;
    begin
        size  := ELEMENT_SIZE*O_PARAM.ELEM_BITS;
        size  := (size + BANK_SIZE - 1)/BANK_SIZE;
        depth := 0;
        while (2**depth < size) loop
            depth := depth + 1;
        end loop;
        return depth;
    end function;
    constant  RAM_DEPTH             :  integer := CALC_RAM_DEPTH;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  RAM_DATA_BITS         :  integer := 2**RAM_WIDTH;
    constant  RAM_ADDR_BITS         :  integer := RAM_DEPTH - RAM_WIDTH;
    constant  RAM_WENA_BITS         :  integer := 1;
    signal    buf_wdata             :  std_logic_vector(LINE_SIZE*BANK_SIZE*RAM_DATA_BITS-1 downto 0);
    signal    buf_waddr             :  std_logic_vector(LINE_SIZE*BANK_SIZE*RAM_ADDR_BITS-1 downto 0);
    signal    buf_we                :  std_logic_vector(LINE_SIZE*BANK_SIZE*RAM_WENA_BITS-1 downto 0);
    signal    buf_rdata             :  std_logic_vector(LINE_SIZE*BANK_SIZE*RAM_DATA_BITS-1 downto 0);
    signal    buf_raddr             :  std_logic_vector(LINE_SIZE*BANK_SIZE*RAM_ADDR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  W_PARAM               :  IMAGE_WINDOW_PARAM_TYPE
                                    := NEW_IMAGE_WINDOW_PARAM(
                                           ELEM_BITS    => I_PARAM.ELEM_BITS,
                                           SHAPE        => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                               C => I_PARAM.SHAPE.C,
                                                               X => I_PARAM.SHAPE.X,
                                                               Y => NEW_IMAGE_VECTOR_RANGE(LINE_SIZE)
                                                           ),
                                           STRIDE       => I_PARAM.STRIDE,
                                           BORDER_TYPE  => I_PARAM.BORDER_TYPE
                                       );
    signal    w_data                :  std_logic_vector(W_PARAM.DATA.SIZE-1 downto 0);
    signal    w_valid               :  std_logic;
    signal    w_ready               :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    outlet_c_size         :  integer range 0 to ELEMENT_SIZE;
    signal    outlet_x_size         :  integer range 0 to ELEMENT_SIZE;
    signal    outlet_y_atrb         :  IMAGE_ATRB_VECTOR(W_PARAM.SHAPE.Y.LO to W_PARAM.SHAPE.Y.HI);
    signal    outlet_valid          :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    outlet_feed           :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    outlet_return         :  std_logic_vector(LINE_SIZE-1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_SHAPE_Y_SIZE_EQ_1: if I_PARAM.SHAPE.Y.SIZE = 1 and LINE_SIZE = 1 generate
        w_data  <= I_DATA;
        w_valid <= I_VALID;
        I_READY <= w_ready;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    WRITER: IMAGE_WINDOW_BUFFER_WRITER           -- 
        generic map(                             -- 
            I_PARAM         => W_PARAM         , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE    , -- 
            CHANNEL_SIZE    => CHANNEL_SIZE    , -- 
            BANK_SIZE       => BANK_SIZE       , -- 
            LINE_SIZE       => LINE_SIZE       , -- 
            RAM_ADDR_BITS   => RAM_ADDR_BITS   , --
            RAM_DATA_BITS   => RAM_DATA_BITS     -- 
        )                                        -- 
        port map(                                -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            I_DATA          => w_data          , -- In  :
            I_VALID         => w_valid         , -- In  :
            I_READY         => w_ready         , -- Out :
            O_VALID         => outlet_valid    , -- Out :
            O_C_SIZE        => outlet_c_size   , -- Out :
            O_X_SIZE        => outlet_x_size   , -- Out :
            O_Y_ATRB        => outlet_y_atrb   , -- Out :
            O_FEED          => outlet_feed     , -- In  :
            O_RETURN        => outlet_return   , -- In  :
            BUF_DATA        => buf_wdata       , -- Out :
            BUF_ADDR        => buf_waddr       , -- Out :
            BUF_WE          => buf_we            -- Out :
        );                                       -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BUF_L:  for line in 0 to LINE_SIZE-1 generate
        B:  for bank in 0 to BANK_SIZE-1 generate
                constant  RAM_ID :  integer := ID + (line*BANK_SIZE)+bank;
                signal    wdata  :  std_logic_vector(RAM_DATA_BITS-1 downto 0);
                signal    waddr  :  std_logic_vector(RAM_ADDR_BITS-1 downto 0);
                signal    we     :  std_logic_vector(RAM_WENA_BITS-1 downto 0);
                signal    rdata  :  std_logic_vector(RAM_DATA_BITS-1 downto 0);
                signal    raddr  :  std_logic_vector(RAM_ADDR_BITS-1 downto 0);
            begin
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            wdata <= buf_wdata((line*BANK_SIZE+bank+1)*RAM_DATA_BITS-1 downto (line*BANK_SIZE+bank)*RAM_DATA_BITS);
            waddr <= buf_waddr((line*BANK_SIZE+bank+1)*RAM_ADDR_BITS-1 downto (line*BANK_SIZE+bank)*RAM_ADDR_BITS);
            we    <= buf_we   ((line*BANK_SIZE+bank+1)*RAM_WENA_BITS-1 downto (line*BANK_SIZE+bank)*RAM_WENA_BITS);
            raddr <= buf_raddr((line*BANK_SIZE+bank+1)*RAM_ADDR_BITS-1 downto (line*BANK_SIZE+bank)*RAM_ADDR_BITS);
            buf_rdata((line*BANK_SIZE+bank+1)*RAM_DATA_BITS-1 downto (line*BANK_SIZE+bank)*RAM_DATA_BITS) <= rdata;
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            RAM: SDPRAM                   -- 
                generic map (             -- 
                    DEPTH   => RAM_DEPTH, -- メモリの深さ(ビット単位)を2のべき乗値で指定する.
                    RWIDTH  => RAM_WIDTH, -- リードデータ(RDATA)の幅(ビット数)を2のべき乗値で指定する.
                    WWIDTH  => RAM_WIDTH, -- ライトデータ(WDATA)の幅(ビット数)を2のべき乗値で指定する.
                    WEBIT   => 0        , -- ライトイネーブル信号(WE)の幅(ビット数)を2のべき乗値で指定する.
                    ID      => RAM_ID     -- どのモジュールで使われているかを示す識別番号.
                )                         -- 
                port map (                -- 
                    WCLK    => CLK      , -- In  :
                    WE      => we       , -- In  : 
                    WADDR   => waddr    , -- In  : 
                    WDATA   => wdata    , -- In  : 
                    RCLK    => CLK      , -- In  :
                    RADDR   => raddr    , -- In  :
                    RDATA   => rdata      -- Out :
                );                        -- 
        end generate;
    end generate;
end RTL;
