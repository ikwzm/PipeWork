-----------------------------------------------------------------------------------
--!     @file    image_window_buffer.vhd
--!     @brief   Image Window Buffer Module :
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
        MAX_D_SIZE      : --! @brief MAX OUTPUT CHANNEL SIZE :
                          integer := 1;
        D_STRIDE        : --! @brief OUTPUT CHANNEL STRIDE SIZE :
                          integer := 1;
        D_UNROLL        : --! @brief OUTPUT CHANNEL UNROLL SIZE :
                          integer := 1;
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
    -- 
    -------------------------------------------------------------------------------
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_D_SIZE := 1;
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
        O_D_ATRB        : --! @brief OUTPUT CHANNEL ATTRIBUTE :
                          out IMAGE_ATRB_VECTOR(0 to D_UNROLL-1);
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
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_INTAKE;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_OUTLET;
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
    -- BUF_WIDTH : メモリのビット幅を２のべき乗値で示す
    -------------------------------------------------------------------------------
    function  CALC_BUF_WIDTH    return integer is
        variable width              :  integer;
    begin
        width := 0;
        while (2**width < (O_PARAM.SHAPE.C.SIZE * O_PARAM.ELEM_BITS)) loop
            width := width + 1;
        end loop;
        return width;
    end function;
    constant  BUF_WIDTH             :  integer := CALC_BUF_WIDTH;
    -------------------------------------------------------------------------------
    -- BUF_DEPTH: メモリバンク１つあたりの深さ(ビット単位)を２のべき乗値で示す
    -------------------------------------------------------------------------------
    function  CALC_BUF_DEPTH    return integer is
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
    constant  BUF_DEPTH             :  integer := CALC_BUF_DEPTH;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  BUF_DATA_BITS         :  integer := 2**BUF_WIDTH;
    constant  BUF_ADDR_BITS         :  integer := BUF_DEPTH - BUF_WIDTH;
    constant  BUF_WENA_BITS         :  integer := 1;
    signal    buf_wdata             :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
    signal    buf_waddr             :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
    signal    buf_we                :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_WENA_BITS-1 downto 0);
    signal    buf_rdata             :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
    signal    buf_raddr             :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    x_size                :  integer range 0 to ELEMENT_SIZE;
    signal    c_size                :  integer range 0 to ELEMENT_SIZE;
    signal    c_offset              :  integer range 0 to 2**BUF_ADDR_BITS;
    signal    line_atrb             :  IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
    signal    line_valid            :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    line_feed             :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    line_return           :  std_logic_vector(LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    outlet_data           :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    signal    outlet_d_atrb         :  IMAGE_ATRB_VECTOR(0 to D_UNROLL-1);
    signal    outlet_valid          :  std_logic;
    signal    outlet_ready          :  std_logic;
    signal    outlet_line_last      :  std_logic;
    signal    outlet_last           :  std_logic;
    signal    outlet_feed           :  std_logic;
    signal    outlet_return         :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    INTAKE: IMAGE_WINDOW_BUFFER_INTAKE           -- 
        generic map(                             -- 
            I_PARAM         => I_PARAM         , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE    , -- 
            CHANNEL_SIZE    => CHANNEL_SIZE    , -- 
            BANK_SIZE       => BANK_SIZE       , -- 
            LINE_SIZE       => LINE_SIZE       , -- 
            BUF_ADDR_BITS   => BUF_ADDR_BITS   , --
            BUF_DATA_BITS   => BUF_DATA_BITS     -- 
        )                                        -- 
        port map(                                -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            I_DATA          => I_DATA          , -- In  :
            I_VALID         => I_VALID         , -- In  :
            I_READY         => I_READY         , -- Out :
            O_LINE_VALID    => line_valid      , -- Out :
            O_X_SIZE        => x_size          , -- Out :
            O_C_SIZE        => c_size          , -- Out :
            O_C_OFFSET      => c_offset        , -- Out :
            O_LINE_ATRB     => line_atrb       , -- Out :
            O_LINE_FEED     => line_feed       , -- In  :
            O_LINE_RETURN   => line_return     , -- In  :
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
                signal    wdata  :  std_logic_vector(BUF_DATA_BITS-1 downto 0);
                signal    waddr  :  std_logic_vector(BUF_ADDR_BITS-1 downto 0);
                signal    we     :  std_logic_vector(BUF_WENA_BITS-1 downto 0);
                signal    rdata  :  std_logic_vector(BUF_DATA_BITS-1 downto 0);
                signal    raddr  :  std_logic_vector(BUF_ADDR_BITS-1 downto 0);
            begin
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            wdata <= buf_wdata((line*BANK_SIZE+bank+1)*BUF_DATA_BITS-1 downto (line*BANK_SIZE+bank)*BUF_DATA_BITS);
            waddr <= buf_waddr((line*BANK_SIZE+bank+1)*BUF_ADDR_BITS-1 downto (line*BANK_SIZE+bank)*BUF_ADDR_BITS);
            we    <= buf_we   ((line*BANK_SIZE+bank+1)*BUF_WENA_BITS-1 downto (line*BANK_SIZE+bank)*BUF_WENA_BITS);
            raddr <= buf_raddr((line*BANK_SIZE+bank+1)*BUF_ADDR_BITS-1 downto (line*BANK_SIZE+bank)*BUF_ADDR_BITS);
            buf_rdata((line*BANK_SIZE+bank+1)*BUF_DATA_BITS-1 downto (line*BANK_SIZE+bank)*BUF_DATA_BITS) <= rdata;
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            RAM: SDPRAM                   -- 
                generic map (             -- 
                    DEPTH   => BUF_DEPTH, -- メモリの深さ(ビット単位)を2のべき乗値で指定する.
                    RWIDTH  => BUF_WIDTH, -- リードデータ(RDATA)の幅(ビット数)を2のべき乗値で指定する.
                    WWIDTH  => BUF_WIDTH, -- ライトデータ(WDATA)の幅(ビット数)を2のべき乗値で指定する.
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
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    OUTLET: IMAGE_WINDOW_BUFFER_OUTLET           -- 
        generic map (                            -- 
            O_PARAM         => O_PARAM         , -- 
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
        -- 各種サイズ
        ---------------------------------------------------------------------------
            X_SIZE          => x_size          , -- In  :
            D_SIZE          => d_size          , -- In  :
            C_SIZE          => c_size          , -- In  :
            C_OFFSET        => c_offset        , -- Out :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_LINE_VALID    => line_valid      , -- In  :
            I_LINE_ATRB     => line_atrb       , -- In  :
            I_LINE_FEED     => line_feed       , -- Out :
            I_LINE_RETURN   => line_return     , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => outlet_data     , -- Out :
            O_D_ATRB        => outlet_d_atrb   , -- Out :
            O_VALID         => outlet_valid    , -- Out :
            O_READY         => outlet_ready    , -- In  :
            O_LAST          => outlet_last     , -- In  :
            O_FEED          => outlet_feed     , -- In  :
            O_RETURN        => outlet_return   , -- In  :
        ---------------------------------------------------------------------------
        -- バッファメモリ I/F
        ---------------------------------------------------------------------------
            BUF_DATA        => buf_rdata       , -- In  :
            BUF_ADDR        => buf_raddr         -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_DATA   <= outlet_data;
    O_D_ATRB <= outlet_d_atrb;
    O_VALID  <= outlet_valid;
    outlet_ready  <= O_READY;
    outlet_line_last <= '1' when (IMAGE_WINDOW_DATA_IS_LAST_C(O_PARAM, outlet_data) and
                                  IMAGE_WINDOW_DATA_IS_LAST_X(O_PARAM, outlet_data) and
                                  outlet_d_atrb(outlet_d_atrb'high).LAST            and
                                  outlet_valid = '1' and outlet_ready = '1'        ) else '0';
    outlet_last      <= '1' when (outlet_line_last = '1' and
                                  IMAGE_WINDOW_DATA_IS_LAST_Y(O_PARAM, outlet_data)) else '0';
    outlet_feed      <= '1' when (outlet_line_last = '1' and O_FEED   = '1') else '0';
    outlet_return    <= '1' when (outlet_line_last = '1' and O_RETURN = '1') else '0';

end RTL;
