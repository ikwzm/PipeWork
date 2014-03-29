-----------------------------------------------------------------------------------
--!     @file    axi4_slave_write_interface.vhd
--!     @brief   AXI4 Slave Write Interface
--!     @version 1.5.5
--!     @date    2014/3/28
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2014 Ichiro Kawazome
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
use     PIPEWORK.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4 Slave Write Interface.
-----------------------------------------------------------------------------------
entity  AXI4_SLAVE_WRITE_INTERFACE is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 ライトアドレスチャネルのAWADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 WRITE DATA CHANNEL DATA WIDTH :
                          --! AXI4 ライトデータチャネルのWDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびライトレスポンスチャネルの
                          --! ID信号のビット幅.
                          integer := 4;
        XFER_SIZE_BITS  : --! @brief TRANSFER SIZE BITS :
                          --! 各種サイズカウンタのビット数を指定する.
                          integer := 32;
        VAL_BITS        : --! @brief VALID BITS :
                          --! XFER_BUSY、XFER_DONE、PUSH_FIN_VAL、PUSH_RSV_VAL信号の
                          --! ビット数を指定する.
                          integer := 1;
        BUF_DATA_WIDTH  : --! @brief BUFFER DATA WIDTH :
                          --! バッファのビット幅を指定する.
                          integer := 32;
        BUF_PTR_BITS    : --! @brief BUFFER POINTER BITS :
                          --! バッファポインタなどを表す信号のビット数を指定する.
                          integer := 8;
        ALIGNMENT_BITS  : --! @brief ALIGNMENT BITS :
                          --! アライメントサイズのビット数を指定する.
                          integer := 8
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        AWID            : --! @brief Write address ID.
                          --! This signal is identification tag for the write
                          --! address group of singals.
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        AWADDR          : --! @brief Write address.  
                          --! The read address gives the address of the first
                          --! transfer in a write burst transaction.
                          in    std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        AWLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          in    std_logic_vector(AXI4_ALEN_WIDTH  -1 downto 0);
        AWSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          in    AXI4_ASIZE_TYPE;
        AWBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          in    AXI4_ABURST_TYPE;
        AWVALID         : --! @brief Write address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          in    std_logic;
        AWREADY         : --! @brief Write address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        WDATA           : --! @brief Write data.
                          in    std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        WSTRB           : --! @brief Write strobes.
                          --! This signal indicates which byte lanes holdvalid 
                          --! data. There is one write strobe bit for each eight
                          --! bits of the write data bus.
                          in    std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
        WLAST           : --! @brief Write last.
                          --! This signal indicates the last transfer in a write burst.
                          in    std_logic;
        WVALID          : --! @brief Write valid.
                          --! This signal indicates that valid write data and
                          --! strobes are available.
                          in    std_logic;
        WREADY          : --! @brief Write ready.
                          --! This signal indicates that the slave can accept the
                          --! write data.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        BID             : --! @brief Response ID tag.
                          --! This signal is the identification tag of write
                          --! response .
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        BRESP           : --! @brief Write response.
                          --! This signal indicates the status of the write transaction.
                          out   AXI4_RESP_TYPE;
        BVALID          : --! @brief Write response valid.
                          --! This signal indicates that the channel is signaling
                          --! a valid write response.
                          out   std_logic;
        BREADY          : --! @brief Write response ready.
                          --! This signal indicates that the master can accept a
                          --! write response.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_ADDR        : --! @brief Request Address.
                          --! 転送開始アドレスを指定する.  
                          out   std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        REQ_ID          : --! @brief Request ID.
                          --! ARID の値を指定する.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        REQ_BURST       : --! @brief Request Burst type.
                          --! バーストタイプを指定する.  
                          --! * このモジュールでは AXI4_ABURST_INCR と AXI4_ABURST_FIXED
                          --!   のみをサポートしている.
                          out   AXI4_ABURST_TYPE;
        REQ_VAL         : --! @brief Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          out   std_logic;
        REQ_START       : --! @brief Request Start Signal.
                          --! REQ_VAL信号がアサートされた最初のサイクルだけアサート
                          --! される.
                          out   std_logic;
        REQ_RDY         : --! @brief Request Ready Signal.
                          --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VAL         : --! @brief Acknowledge Valid Signal.
                          --! 上記の Command Request の応答信号.
                          --! 下記の 各種 Acknowledge 信号が有効である事を示す.
                          --! * この信号のアサートでもって、Command Request が受け
                          --!   付けられたことを示す. ただし、あくまでも Request が
                          --!   受け付けられただけであって、必ずしもトランザクショ
                          --!   ンが完了したわけではないことに注意.
                          --! * この信号は Request につき１クロックだけアサートされ
                          --!   る.
                          --! * この信号がアサートされたら、アプリケーション側は速
                          --!   やかに REQ_VAL 信号をネゲートして Request を取り下
                          --!   げるか、REQ_VALをアサートしたままで次の Request 情
                          --!   報を用意しておかなければならない.
                          in    std_logic;
        ACK_NEXT        : --! @brief Acknowledge with need Next transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=0 の場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        ACK_LAST        : --! @brief Acknowledge with Last transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=1 の場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        ACK_ERROR       : --! @brief Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        ACK_SIZE        : --! @brief Acknowledge transfer size.
                          --! 転送するバイト数を示す.
                          --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で示さ
                          --! れるバイト数分を加算/減算すると良い.
                          in    std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transfer Control Signal.
    -------------------------------------------------------------------------------
        XFER_START      : --! @brief Transfer Start.
                          --! データ転送開始を指示する信号.
                          --! * 下記の各種リクエスト信号が有効であることを示す.
                          in    std_logic;
        XFER_LAST       : --! @brief Transfer Last.
                          --! 最後の転送であることを指示する信号.
                          --! * XFER_START 信号がアサートされている時のみ有効.
                          in    std_logic;
        XFER_SEL        : --! @brief Transfer Select.
                          --! XFER_BUSY、XFER_DONE、PULL_FIN_VAL、PULL_RSV_VAL 信号
                          --! の生成パターンを指定する.
                          --! * XFER_START 信号がアサートされている時のみ有効.
                          in    std_logic_vector(VAL_BITS         -1 downto 0);
        XFER_BUF_PTR    : --! @brief Transfer Write Buffer Pointer.
                          --! ライトバッファの先頭ポインタの値を指定する.
                          --! * XFER_START 信号がアサートされている時のみ有効.
                          --! * ライトバッファのこのポインタの位置からRDATAを書き込
                          --!   む.
                          in    std_logic_vector(BUF_PTR_BITS     -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transfer Status Signal.
    -------------------------------------------------------------------------------
        XFER_BUSY       : --! @brief Transfer Busy.
                          --! このモジュールが未だデータの転送中であることを示す.
                          --! * QUEUE_SIZEの設定によっては、XFER_BUSY がアサートさ
                          --!   れていても、次のリクエストを受け付け可能な場合があ
                          --!   る.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        XFER_ERROR      : --! @brief Transfer Error.
                          --! データの転送中にエラーが発生した事を示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        XFER_DONE       : --! @brief Transfer Done.
                          --! このモジュールが未だデータの転送中かつ、次のクロック
                          --! で XFER_BUSY がネゲートされる事を示す.
                          --! * ただし、XFER_BUSY のネゲート前に 必ずしもこの信号が
                          --!   アサートされるわけでは無い.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Reserve Size Signals.
    -------------------------------------------------------------------------------
        PUSH_RSV_VAL    : --! @brief Push Reserve Valid.
                          --! PUSH_RSV_LAST/PUSH_RSV_ERROR/PUSH_RSV_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PUSH_RSV_LAST   : --! @brief Push Reserve Last.
                          --! 最後の転送"する予定"である事を示すフラグ.
                          out   std_logic;
        PUSH_RSV_ERROR  : --! @brief Push Reserve Error.
                          --! 転送"する予定"がエラーだった事を示すフラグ.
                          out   std_logic;
        PUSH_RSV_SIZE   : --! @brief Push Reserve Size.
                          --! 転送"する予定"のバイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Final Size Signals.
    -------------------------------------------------------------------------------
        PUSH_FIN_VAL    : --! @brief Push Final Valid.
                          --! PUSH_FIN_LAST/PUSH_FIN_ERROR/PUSH_FIN_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PUSH_FIN_LAST   : --! @brief Push Final Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PUSH_FIN_ERROR  : --! @brief Push Final Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PUSH_FIN_SIZE   : --! @brief Push Final Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Buffer Size Signals.
    -------------------------------------------------------------------------------
        PUSH_BUF_RESET  : --! @brief Push Buffer Counter Reset.
                          --! バッファのカウンタをリセットする信号.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PUSH_BUF_VAL    : --! @brief Push Buffer Valid.
                          --! PUSH_BUF_LAST/PUSH_BUF_ERROR/PUSH_BUF_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PUSH_BUF_LAST   : --! @brief Push Buffer Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PUSH_BUF_ERROR  : --! @brief Push Buffer Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PUSH_BUF_SIZE   : --! @brief Push Buffer Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
        PUSH_BUF_RDY    : --! @brief Push Buffer Ready.
                          --! バッファにデータを書き込み可能な事をを示す.
                          in    std_logic_vector(VAL_BITS         -1 downto 0);
    -------------------------------------------------------------------------------
    -- Read Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_WEN         : --! @brief Buffer Write Enable.
                          --! バッファにデータをライトすることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        BUF_BEN         : --! @brief Buffer Byte Enable.
                          --! バッファにデータをライトする際のバイトイネーブル信号.
                          --! * BUF_WEN='1'の場合にのみ有効.
                          --! * BUF_WEN='0'の場合のこの信号の値は不定.
                          out   std_logic_vector(BUF_DATA_WIDTH/8 -1 downto 0);
        BUF_DATA        : --! @brief Buffer Data.
                          --! バッファへライトするデータを出力する.
                          out   std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
        BUF_PTR         : --! @brief Buffer Write Pointer.
                          --! ライト時にデータを書き込むバッファの位置を出力する.
                          out   std_logic_vector(BUF_PTR_BITS     -1 downto 0)
    );
end AXI4_SLAVE_WRITE_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.COMPONENTS.POOL_INTAKE_PORT;
architecture RTL of AXI4_SLAVE_WRITE_INTERFACE is
    -------------------------------------------------------------------------------
    -- 内部信号
    -------------------------------------------------------------------------------
    type     STATE_TYPE        is (IDLE_STATE, REQ_STATE, TAR_STATE, RESP_STATE);
    signal   curr_state         : STATE_TYPE;
    signal   curr_select        : std_logic_vector(VAL_BITS-1 downto 0);
    signal   write_error        : std_logic;
    signal   prev_busy          : std_logic;
    signal   port_busy          : std_logic;
    signal   push_buf_ready     : std_logic;
    signal   push_buf_done      : std_logic;
    constant PUSH_BUF_ALL0      : std_logic_vector(VAL_BITS-1 downto 0) := (others => '0');
    signal   o_push_valid       : std_logic_vector(VAL_BITS-1 downto 0);
    signal   o_push_last        : std_logic;
    signal   o_push_error       : std_logic;
    signal   o_push_size        : std_logic_vector(XFER_SIZE_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- ステートマシン
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
        variable busy       : boolean;
    begin
        if (RST = '1') then
                curr_state <= IDLE_STATE;
                write_error<= '0';
                BVALID     <= '0';
                BID        <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state <= IDLE_STATE;
                write_error<= '0';
                BVALID     <= '0';
                BID        <= (others => '0');
            else
                -------------------------------------------------------------------
                -- ステートマシン
                -------------------------------------------------------------------
                case curr_state is
                    when IDLE_STATE =>
                        if (AWVALID = '1' and REQ_RDY = '1') then
                            next_state := REQ_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                    when REQ_STATE =>
                        busy := (prev_busy = '1' or port_busy = '1');
                        if    (ACK_VAL = '1' and busy = TRUE ) then
                            next_state := TAR_STATE;
                        elsif (ACK_VAL = '1' and busy = FALSE) then
                            next_state := RESP_STATE;
                        else
                            next_state := REQ_STATE;
                        end if;
                    when TAR_STATE =>
                        busy := (prev_busy = '1' or port_busy = '1');
                        if (busy = TRUE) then
                            next_state := TAR_STATE;
                        else
                            next_state := RESP_STATE;
                        end if;
                    when RESP_STATE =>
                        if (BREADY = '1') then
                            next_state := IDLE_STATE;
                        else
                            next_state := RESP_STATE;
                        end if;
                    when others =>
                            next_state := IDLE_STATE;
                end case;
                curr_state <= next_state;
                -------------------------------------------------------------------
                -- write_error : エラーが返ってきたことを示すフラグ.
                -------------------------------------------------------------------
                if    (curr_state = REQ_STATE and ACK_VAL = '1' and ACK_ERROR = '1') then
                    write_error <= '1';
                elsif (next_state = IDLE_STATE) then
                    write_error <= '0';
                end if;
                -------------------------------------------------------------------
                -- prev_busy : port_busy は最初のデータが入ってくるまでアサートされ
                --             ないので、それまでの間、ビジーであることを示す必要
                --             がある.
                -------------------------------------------------------------------
                if    (curr_state = IDLE_STATE and next_state = REQ_STATE) then
                    prev_busy  <= '1';
                elsif (port_busy = '1' or next_state = IDLE_STATE) then
                    prev_busy  <= '0';
                end if;
                -------------------------------------------------------------------
                -- BVALID : 
                -------------------------------------------------------------------
                if (next_state = RESP_STATE) then
                    BVALID  <= '1';
                else
                    BVALID  <= '0';
                end if;
                -------------------------------------------------------------------
                -- BID    : 
                -------------------------------------------------------------------
                if (curr_state = IDLE_STATE and AWVALID = '1') then
                    BID     <= AWID;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    XFER_BUSY  <= curr_select when (prev_busy = '1' or port_busy = '1') else (others => '0');
    XFER_DONE  <= curr_select when (push_buf_done = '1') else (others => '0');
    XFER_ERROR <= (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    AWREADY    <= '1' when (curr_state = IDLE_STATE and REQ_RDY = '1') else '0';
    BRESP      <= AXI4_RESP_SLVERR when (write_error = '1') else AXI4_RESP_OKAY;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REQ_START  <= '1' when (curr_state = IDLE_STATE and REQ_RDY = '1' and AWVALID = '1') else '0';
    REQ_VAL    <= '1' when (curr_state = IDLE_STATE and REQ_RDY = '1' and AWVALID = '1') or
                           (curr_state = REQ_STATE                                     ) else '0';
    REQ_ADDR   <= AWADDR;
    REQ_BURST  <= AWBURST;
    REQ_ID     <= AWID;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    push_buf_ready  <= '1' when ((PUSH_BUF_RDY and curr_select) /= PUSH_BUF_ALL0) else '0';
    push_buf_done   <= '1' when ((o_push_valid and curr_select) /= PUSH_BUF_ALL0) else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    INTAKE_PORT: POOL_INTAKE_PORT                -- 
        generic map (                            -- 
            UNIT_BITS       => 8               , -- 
            WORD_BITS       => 8               , -- 
            PORT_DATA_BITS  => AXI4_DATA_WIDTH , -- 
            POOL_DATA_BITS  =>  BUF_DATA_WIDTH , -- 
            SEL_BITS        => VAL_BITS        , -- 
            SIZE_BITS       => XFER_SIZE_BITS  , -- 
            PTR_BITS        => BUF_PTR_BITS    , -- 
            QUEUE_SIZE      => 0                 -- 
        )                                        -- 
        port map (                               -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            START           => XFER_START      , -- In  :
            START_PTR       => XFER_BUF_PTR    , -- In  :
            XFER_LAST       => XFER_LAST       , -- In  :
            XFER_SEL        => XFER_SEL        , -- In  :
        -------------------------------------------------------------------------------
        -- Intake Port Signals.
        -------------------------------------------------------------------------------
            PORT_DATA       => WDATA           , -- In  :
            PORT_DVAL       => WSTRB           , -- In  :
            PORT_ERROR      => write_error     , -- In  :
            PORT_LAST       => WLAST           , -- In  :
            PORT_VAL        => WVALID          , -- In  :
            PORT_RDY        => WREADY          , -- Out :
        -------------------------------------------------------------------------------
        -- Push Size Signals.
        -------------------------------------------------------------------------------
            PUSH_VAL        => o_push_valid    , -- Out :
            PUSH_LAST       => open            , -- Out :
            PUSH_XFER_LAST  => open            , -- Out :
            PUSH_XFER_DONE  => o_push_last     , -- Out :
            PUSH_ERROR      => o_push_error    , -- Out :
            PUSH_SIZE       => o_push_size     , -- Out :
        -------------------------------------------------------------------------------
        -- Pool Buffer Interface Signals.
        -------------------------------------------------------------------------------
            POOL_WEN        => BUF_WEN         , -- Out :
            POOL_DVAL       => BUF_BEN         , -- Out :
            POOL_DATA       => BUF_DATA        , -- Out :
            POOL_PTR        => BUF_PTR         , -- Out :
            POOL_RDY        => push_buf_ready  , -- In  :
        -------------------------------------------------------------------------------
        -- Status Signals.
        -------------------------------------------------------------------------------
            BUSY            => port_busy         -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    VAL_BIT_GT_1: if (VAL_BITS > 1) generate
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_select <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_select <= (others => '0');
                elsif (XFER_START    = '1') then
                    curr_select <= XFER_SEL;
                elsif (push_buf_done = '1') then
                    curr_select <= (others => '0');
                end if;
            end if;
        end process;
    end generate;
    VAL_BIT_LE_1: if (VAL_BITS <= 1) generate
        curr_select <= (others => '1');
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PUSH_FIN_VAL   <= o_push_valid;
    PUSH_FIN_LAST  <= o_push_last;
    PUSH_FIN_ERROR <= o_push_error;
    PUSH_FIN_SIZE  <= o_push_size;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PUSH_RSV_VAL   <= o_push_valid;
    PUSH_RSV_LAST  <= o_push_last;
    PUSH_RSV_ERROR <= o_push_error;
    PUSH_RSV_SIZE  <= o_push_size;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PUSH_BUF_RESET <= XFER_SEL when (XFER_START = '1') else (others => '0');
    PUSH_BUF_VAL   <= o_push_valid;
    PUSH_BUF_LAST  <= o_push_last;
    PUSH_BUF_ERROR <= o_push_error;
    PUSH_BUF_SIZE  <= o_push_size;
end RTL;
