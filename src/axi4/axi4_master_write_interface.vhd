-----------------------------------------------------------------------------------
--!     @file    axi4_master_write_interface.vhd
--!     @brief   AXI4 Master Write Interface
--!     @version 0.0.7
--!     @date    2013/1/13
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
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
--! @brief   AXI4 Master Write Interface
-----------------------------------------------------------------------------------
entity  AXI4_MASTER_WRITE_INTERFACE is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 ライトアドレスチャネルのAWADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 WRITE DATA CHANNEL DATA WIDTH :
                          --! AXI4 ライトデータチャネルのRDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびライトレスポンスチャネルの
                          --! ID信号のビット幅.
                          integer range 1 to AXI4_ID_MAX_WIDTH;
        REQ_SIZE_BITS   : --! @brief REQUEST SIZE BITS:
                          --! REQ_SIZE信号のビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! 各種サイズカウンタのビット数を指定する.
                          integer := 32;
        BUF_DATA_WIDTH  : --! @brief BUFFER DATA WIDTH :
                          --! バッファのビット幅を指定する.
                          integer := 32;
        BUF_PTR_BITS    : --! @brief BUFFER POINTER BITS :
                          --! バッファポインタなどを表す信号のビット数を指定する.
                          integer := 8;
        XFER_MIN_SIZE   : --! @brief TRANSFER MINIMUM SIZE :
                          --! 一回の転送サイズの最小バイト数を２のべき乗で指定する.
                          integer := 4;
        XFER_MAX_SIZE   : --! @brief TRANSFER MAXIMUM SIZE :
                          --! 一回の転送サイズの最大バイト数を２のべき乗で指定する.
                          integer := 4;
        QUEUE_SIZE      : --! @brief RESPONSE QUEUE SIZE :
                          --! キューの大きさを指定する.
                          integer := 1
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
        --------------------------------------------------------------------------
        -- AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
        AWID            : --! @brief Write address ID.
                          --! This signal is identification tag for the write
                          --! address group of singals.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        AWADDR          : --! @brief Write address.  
                          --! The read address gives the address of the first
                          --! transfer in a write burst transaction.
                          out   std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        AWLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          out   AXI4_ALEN_TYPE;
        AWSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          out   AXI4_ASIZE_TYPE;
        AWBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          out   AXI4_ABURST_TYPE;
        AWLOCK          : --! @brief Lock type.
                          --! This signal provides additional information about
                          --! the atomic characteristics of the transfer.
                          out   AXI4_ALOCK_TYPE;
        AWCACHE         : --! @brief Memory type.
                          --! This signal indicates how transactions are required
                          --! to progress through a system.
                          out   AXI4_ACACHE_TYPE;
        AWPROT          : --! @brief Protection type.
                          --! This signal indicates the privilege and security
                          --! level of the transaction, and wherther the
                          --! transaction is a data access or an instruction access.
                          out   AXI4_APROT_TYPE;
        AWQOS           : --! @brief Quality of Service, QoS.
                          --! QoS identifier sent for each read transaction.
                          out   AXI4_AQOS_TYPE;
        AWREGION        : --! @brief Region identifier.
                          --! Permits a single physical interface on a slave to be
                          --! used for multiple logical interfaces.
                          out   AXI4_AREGION_TYPE;
        AWVALID         : --! @brief Write address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          out   std_logic;
        AWREADY         : --! @brief Write address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          in    std_logic;
        --------------------------------------------------------------------------
        -- AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
        WID             : --! @brief Write ID tag.
                          --! This signal is the identification tag for the write
                          --! data transfer. Supported only AXI3.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        WDATA           : --! @brief Write data.
                          out   std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        WSTRB           : --! @brief Write strobes.
                          --! This signal indicates which byte lanes holdvalid 
                          --! data. There is one write strobe bit for each eight
                          --! bits of the write data bus.
                          out   std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
        WLAST           : --! @brief Write last.
                          --! This signal indicates the last transfer in a write burst.
                          out   std_logic;
        WVALID          : --! @brief Write valid.
                          --! This signal indicates that valid write data and
                          --! strobes are available.
                          out   std_logic;
        WREADY          : --! @brief Write ready.
                          --! This signal indicates that the slave can accept the
                          --! write data.
                          in    std_logic;
        --------------------------------------------------------------------------
        -- AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
        BID             : --! @brief Response ID tag.
                          --! This signal is the identification tag of write
                          --! response .
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        BRESP           : --! @brief Write response.
                          --! This signal indicates the status of the write transaction.
                          in    AXI4_RESP_TYPE;
        BVALID          : --! @brief Write response valid.
                          --! This signal indicates that the channel is signaling
                          --! a valid write response.
                          in    std_logic;
        BREADY          : --! @brief Write response ready.
                          --! This signal indicates that the master can accept a
                          --! write response.
                          out   std_logic;
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
        REQ_ADDR        : in    std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        REQ_SIZE        : in    std_logic_vector(REQ_SIZE_BITS    -1 downto 0);
        REQ_ID          : in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        REQ_BURST       : in    AXI4_ABURST_TYPE;
        REQ_LOCK        : in    AXI4_ALOCK_TYPE;
        REQ_CACHE       : in    AXI4_ACACHE_TYPE;
        REQ_PROT        : in    AXI4_APROT_TYPE;
        REQ_QOS         : in    AXI4_AQOS_TYPE;
        REQ_REGION      : in    AXI4_AREGION_TYPE;
        REQ_FIRST       : in    std_logic;
        REQ_LAST        : in    std_logic;
        REQ_SPECULATIVE : in    std_logic;
        REQ_SAFETY      : in    std_logic;
        REQ_VAL         : in    std_logic;
        REQ_RDY         : out   std_logic;
        XFER_SIZE_SEL   : in    std_logic_vector(XFER_MAX_SIZE downto XFER_MIN_SIZE);
        XFER_BUSY       : out   std_logic;
        ---------------------------------------------------------------------------
        -- Command Response Signals.
        ---------------------------------------------------------------------------
        ACK_VAL         : out   std_logic;
        ACK_NEXT        : out   std_logic;
        ACK_LAST        : out   std_logic;
        ACK_ERROR       : out   std_logic;
        ACK_STOP        : out   std_logic;
        ACK_NONE        : out   std_logic;
        ACK_SIZE        : out   std_logic_vector(SIZE_BITS        -1 downto 0);
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
        FLOW_PAUSE      : in    std_logic;
        FLOW_STOP       : in    std_logic;
        FLOW_LAST       : in    std_logic;
        FLOW_SIZE       : in    std_logic_vector(SIZE_BITS        -1 downto 0);
        ---------------------------------------------------------------------------
        -- Reserve Size Signals.
        ---------------------------------------------------------------------------
        RESV_VAL        : out   std_logic;
        RESV_SIZE       : out   std_logic_vector(SIZE_BITS        -1 downto 0);
        RESV_LAST       : out   std_logic;
        RESV_ERROR      : out   std_logic;
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
        PULL_VAL        : out   std_logic;
        PULL_SIZE       : out   std_logic_vector(SIZE_BITS        -1 downto 0);
        PULL_LAST       : out   std_logic;
        PULL_ERROR      : out   std_logic;
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
        BUF_REN         : out   std_logic;
        BUF_DATA        : in    std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
        BUF_PTR         : out   std_logic_vector(BUF_PTR_BITS     -1 downto 0);
        BUF_RDY         : in    std_logic
    );
end AXI4_MASTER_WRITE_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     PIPEWORK.COMPONENTS.REDUCER;
use     PIPEWORK.COMPONENTS.QUEUE_REGISTER;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER;
architecture RTL of AXI4_MASTER_WRITE_INTERFACE is
    -------------------------------------------------------------------------------
    -- データバスのバイト数の２のべき乗値を計算する.
    -------------------------------------------------------------------------------
    function CALC_DATA_SIZE(WIDTH:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**(value+3) < WIDTH) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    constant AXI4_DATA_SIZE     : integer := CALC_DATA_SIZE(AXI4_DATA_WIDTH);
    constant BUF_DATA_SIZE      : integer := CALC_DATA_SIZE( BUF_DATA_WIDTH);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_req_addr      : std_logic_vector(AXI4_ADDR_WIDTH-1 downto 0);
    signal   xfer_req_size      : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   xfer_req_valid     : std_logic;
    signal   xfer_req_ready     : std_logic;
    signal   xfer_req_next      : std_logic;
    signal   xfer_req_last      : std_logic;
    signal   xfer_req_first     : std_logic;
    signal   xfer_req_safety    : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_ack_valid     : std_logic;
    signal   xfer_ack_size      : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   xfer_ack_next      : std_logic;
    signal   xfer_ack_last      : std_logic;
    signal   xfer_ack_error     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_start         : std_logic;
    signal   xfer_running       : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   risky_ack_mode     : boolean;
    signal   risky_ack_valid    : std_logic;
    signal   risky_ack_size     : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   risky_ack_next     : std_logic;
    signal   risky_ack_last     : std_logic;
    signal   risky_ack_error    : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   safety_ack_mode    : boolean;
    signal   safety_ack_valid   : std_logic;
    signal   safety_ack_size    : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   safety_ack_next    : std_logic;
    signal   safety_ack_last    : std_logic;
    signal   safety_ack_error   : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant xfer_beat_sel      : std_logic_vector(BUF_DATA_SIZE downto BUF_DATA_SIZE) := "1";
    signal   xfer_beat_chop     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   buf_busy           : std_logic;
    signal   buf_enable         : std_logic;
    signal   buf_push_valid     : std_logic;
    signal   buf_push_ben       : std_logic_vector(BUF_DATA_WIDTH/8-1 downto 0);
    signal   buf_push_size      : std_logic_vector(BUF_DATA_SIZE      downto 0);
    signal   buf_push_last      : std_logic;
    signal   buf_push_ready     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   data_valid         : std_logic;
    signal   data_last          : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   init_read_ptr      : std_logic_vector(BUF_PTR_BITS-1 downto 0);
    signal   next_read_ptr      : std_logic_vector(BUF_PTR_BITS-1 downto 0);
    signal   curr_read_ptr      : std_logic_vector(BUF_PTR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   ack_queue_ready    : std_logic;
    signal   ack_queue_valid    : std_logic_vector(QUEUE_SIZE     downto 0);
    signal   ack_queue_next     : std_logic;
    signal   ack_queue_last     : std_logic;
    signal   ack_queue_size     : std_logic_vector(XFER_MAX_SIZE  downto 0);
    signal   ack_queue_empty    : std_logic;
    signal   ack_queue_safety   : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    type     STATE_TYPE      is ( IDLE, WAIT_WFIRST, WAIT_WLAST, TURN_AR);
    signal   curr_state         : STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Controller.
    -------------------------------------------------------------------------------
    AW: AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER
        generic map (
            DATA_SIZE       => AXI4_DATA_SIZE    ,
            ADDR_BITS       => AXI4_ADDR_WIDTH   ,
            REQ_SIZE_BITS   => REQ_SIZE_BITS     ,
            SIZE_BITS       => SIZE_BITS         ,
            XFER_MIN_SIZE   => XFER_MIN_SIZE     ,
            XFER_MAX_SIZE   => XFER_MAX_SIZE     
        )
        port map (
            ----------------------------------------------------------------------
            -- Clock and Reset Signals.
            ----------------------------------------------------------------------
            CLK             => CLK               , -- In  :
            RST             => RST               , -- In  :
            CLR             => CLR               , -- In  :
            ----------------------------------------------------------------------
            -- AXI4 Address Channel Signals.
            ----------------------------------------------------------------------
            AADDR           => AWADDR            , -- Out :
            ALEN            => AWLEN             , -- Out :
            AVALID          => AWVALID           , -- Out :
            AREADY          => AWREADY           , -- In  :
            -----------------------------------------------------------------------
            -- Command Request Signals.
            -----------------------------------------------------------------------
            REQ_ADDR        => REQ_ADDR          , -- In  :
            REQ_SIZE        => REQ_SIZE          , -- In  :
            REQ_FIRST       => REQ_FIRST         , -- In  :
            REQ_LAST        => REQ_LAST          , -- In  :
            REQ_SPECULATIVE => REQ_SPECULATIVE   , -- In  :
            REQ_SAFETY      => REQ_SAFETY        , -- In  :
            REQ_VAL         => REQ_VAL           , -- In  :
            REQ_RDY         => REQ_RDY           , -- Out :
            -----------------------------------------------------------------------
            -- Command Response Signals.
            -----------------------------------------------------------------------
            ACK_VAL         => ACK_VAL           , -- Out :
            ACK_NEXT        => ACK_NEXT          , -- Out :
            ACK_LAST        => ACK_LAST          , -- Out :
            ACK_ERROR       => ACK_ERROR         , -- Out :
            ACK_STOP        => ACK_STOP          , -- Out :
            ACK_NONE        => ACK_NONE          , -- Out :
            ACK_SIZE        => ACK_SIZE          , -- Out :
            -----------------------------------------------------------------------
            -- Transfer Control Signals.
            -----------------------------------------------------------------------
            FLOW_PAUSE      => FLOW_PAUSE        , -- In  :
            FLOW_STOP       => FLOW_STOP         , -- In  :
            FLOW_LAST       => FLOW_LAST         , -- In  :
            FLOW_SIZE       => FLOW_SIZE         , -- In  :
            -----------------------------------------------------------------------
            -- Transfer Size Select Signals.
            -----------------------------------------------------------------------
            XFER_SIZE_SEL   => XFER_SIZE_SEL     , -- In  :
            -----------------------------------------------------------------------
            -- Transfer Request Signals. 
            -----------------------------------------------------------------------
            XFER_REQ_ADDR   => xfer_req_addr     , -- Out : 
            XFER_REQ_SIZE   => xfer_req_size     , -- Out :
            XFER_REQ_FIRST  => xfer_req_first    , -- Out :
            XFER_REQ_LAST   => xfer_req_last     , -- Out :
            XFER_REQ_NEXT   => xfer_req_next     , -- Out :
            XFER_REQ_SAFETY => xfer_req_safety   , -- Out :
            XFER_REQ_VAL    => xfer_req_valid    , -- Out :
            XFER_REQ_RDY    => xfer_req_ready    , -- In  :
            -----------------------------------------------------------------------
            -- Transfer Response Signals.
            -----------------------------------------------------------------------
            XFER_ACK_SIZE   => xfer_ack_size     , -- In  :
            XFER_ACK_VAL    => xfer_ack_valid    , -- In  :
            XFER_ACK_NEXT   => xfer_ack_next     , -- In  :
            XFER_ACK_LAST   => xfer_ack_last     , -- In  :
            XFER_ACK_ERR    => xfer_ack_error    , -- In  :
            XFER_RUNNING    => xfer_running        -- In  :
        );
    -------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Signals Output.
    -------------------------------------------------------------------------------
    AWBURST  <= REQ_BURST;
    AWSIZE   <= std_logic_vector(to_unsigned(AXI4_DATA_SIZE, AWSIZE'length));
    AWLOCK   <= REQ_LOCK;
    AWCACHE  <= REQ_CACHE;
    AWPROT   <= REQ_PROT;
    AWQOS    <= REQ_QOS;
    AWREGION <= REQ_REGION;
    AWID     <= REQ_ID;
    WID      <= REQ_ID;
    -------------------------------------------------------------------------------
    -- ライトデータチャネルの状態遷移
    -------------------------------------------------------------------------------
    WDT_FSM: process(CLK, RST) begin
        if (RST = '1') then
                curr_state <= IDLE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state <= IDLE;
            else
                case curr_state is
                    ---------------------------------------------------------------
                    -- Transfer Request の受け付け待ち.
                    ---------------------------------------------------------------
                    when IDLE =>
                        if (xfer_req_valid = '1' and ack_queue_ready = '1') then
                            curr_state <= WAIT_WFIRST;
                        else
                            curr_state <= IDLE;
                        end if;
                    ---------------------------------------------------------------
                    -- AXI4 Write Data Channel に最初のデータを出力するのを待つ.
                    ---------------------------------------------------------------
                    when WAIT_WFIRST =>
                        if    (data_valid = '1' and WREADY = '1' and data_last = '1') then
                            curr_state <= TURN_AR;
                        elsif (data_valid = '1' and WREADY = '1' and data_last = '0') then
                            curr_state <= WAIT_WLAST;
                        else
                            curr_state <= WAIT_WFIRST;
                        end if;
                    ---------------------------------------------------------------
                    -- AXI4 Write Data Channel に最初のデータを出力するのを待つ.
                    ---------------------------------------------------------------
                    when WAIT_WLAST  =>
                        if    (data_valid = '1' and WREADY = '1' and data_last = '1') then
                            curr_state <= TURN_AR;
                        else
                            curr_state <= WAIT_WLAST;
                        end if;
                    ---------------------------------------------------------------
                    -- １クロック待ってから IDLE に戻る.
                    ---------------------------------------------------------------
                    when TURN_AR   =>
                            curr_state <= IDLE;
                    ---------------------------------------------------------------
                    -- 念のため.
                    ---------------------------------------------------------------
                    when others      =>
                            curr_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- XFER_BUSY      : 動作中である事を示すフラグ.
    -------------------------------------------------------------------------------
    XFER_BUSY    <= '1' when (curr_state = WAIT_WFIRST or
                              curr_state = WAIT_WLAST  or
                              ack_queue_empty = '0' ) else '0';
    -------------------------------------------------------------------------------
    -- xfer_running   : 動作中である事を示すフラグ.
    -------------------------------------------------------------------------------
    xfer_running <= '1' when (curr_state = WAIT_WFIRST or
                              curr_state = WAIT_WLAST  or
                              ack_queue_empty = '0' ) else '0';
    -------------------------------------------------------------------------------
    -- xfer_req_ready : 
    -------------------------------------------------------------------------------
    xfer_req_ready  <= '1' when (curr_state = IDLE and ack_queue_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_start     : この信号がトリガーとなっていろいろと処理を開始する.
    -------------------------------------------------------------------------------
    xfer_start      <= '1' when (xfer_req_ready = '1' and xfer_req_valid = '1') else '0';
    -------------------------------------------------------------------------------
    -- buf_push_ben   : 送信バッファに書き込むためのバイトイネーブル信号.
    -- buf_push_size  : 送信バッファに書き込むバイト数を１ビート毎に出力する.
    -- buf_push_last  : 送信バッファに書き込む最後のビートであることを示す.
    -------------------------------------------------------------------------------
    BEN: CHOPPER
        generic map (
            BURST           => 1                     ,
            MIN_PIECE       => BUF_DATA_SIZE         ,
            MAX_PIECE       => BUF_DATA_SIZE         ,
            MAX_SIZE        => XFER_MAX_SIZE         ,
            ADDR_BITS       => init_read_ptr'length  ,
            SIZE_BITS       => xfer_req_size'length  ,
            COUNT_BITS      => 1                     ,
            PSIZE_BITS      => buf_push_size'length  ,
            GEN_VALID       => 1
        )
        port map (
            ----------------------------------------------------------------------
            -- Clock and Reset Signals.
            ----------------------------------------------------------------------
            CLK             => CLK                   , -- In  :
            RST             => RST                   , -- In  :
            CLR             => CLR                   , -- In  :
            -----------------------------------------------------------------------
            -- 各種初期値
            -----------------------------------------------------------------------
            ADDR            => init_read_ptr         , -- In  :
            SIZE            => xfer_req_size         , -- In  :
            SEL             => xfer_beat_sel         , -- In  :
            LOAD            => xfer_start            , -- In  :
            -----------------------------------------------------------------------
            -- 制御信号
            -----------------------------------------------------------------------
            CHOP            => xfer_beat_chop        , -- In  :
            -----------------------------------------------------------------------
            -- ピースカウンタ/フラグ出力
            -----------------------------------------------------------------------
            COUNT           => open                  , -- Out :
            NONE            => open                  , -- Out :
            LAST            => buf_push_last         , -- Out :
            NEXT_NONE       => open                  , -- Out :
            NEXT_LAST       => open                  , -- Out :
            -----------------------------------------------------------------------
            -- １ワードのバイト数
            -----------------------------------------------------------------------
            PSIZE           => buf_push_size         , -- Out :
            NEXT_PSIZE      => open                  , -- Out :
            -----------------------------------------------------------------------
            -- バイトイネーブル信号
            -----------------------------------------------------------------------
            VALID           => buf_push_ben          , -- Out :
            NEXT_VALID      => open                    -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    init_read_ptr <= (others => '0') when (xfer_req_first = '1') else curr_read_ptr;
    next_read_ptr <= std_logic_vector(to_01(unsigned(curr_read_ptr)) +
                                      to_01(unsigned(buf_push_size)));
    process(CLK, RST) begin
        if (RST = '1') then
                curr_read_ptr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_read_ptr <= (others => '0');
            elsif (xfer_start = '1') then
                curr_read_ptr <= init_read_ptr;
            elsif (xfer_beat_chop = '1') then
                curr_read_ptr <= next_read_ptr;
            end if;
        end if;
    end process;
    BUF_PTR <= init_read_ptr when (xfer_start     = '1') else
               next_read_ptr when (xfer_beat_chop = '1') else
               curr_read_ptr;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                buf_enable <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                buf_enable <= '0';
            elsif (xfer_start = '1') then
                buf_enable <= '1';
            elsif (buf_push_valid = '1' and buf_push_ready = '1' and buf_push_last = '1') then
                buf_enable <= '0';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    buf_push_valid <= '1' when (buf_enable = '1' and BUF_RDY = '1') else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    xfer_beat_chop <= '1' when (buf_push_valid = '1' and buf_push_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- 送信バッファ : 
    -------------------------------------------------------------------------------
    SBUF: block
        constant WORD_BITS      : integer := 8;
        constant ENBL_BITS      : integer := 1;
        constant I_WIDTH        : integer :=  BUF_DATA_WIDTH/WORD_BITS;
        constant O_WIDTH        : integer := AXI4_DATA_WIDTH/WORD_BITS;
        constant QUEUE_SIZE     : integer := O_WIDTH+I_WIDTH+I_WIDTH-1;
        constant done           : std_logic := '0';
        constant flush          : std_logic := '0';
        signal   offset         : std_logic_vector(O_WIDTH-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (xfer_req_addr)
            variable addr : unsigned(AXI4_DATA_SIZE downto 0);
        begin
            for i in addr'range loop
                if (i < AXI4_DATA_SIZE and xfer_req_addr(i) = '1') then
                    addr(i) := '1';
                else
                    addr(i) := '0';
                end if;
            end loop;
            for i in offset'range loop
                if (i < addr) then
                    offset(i) <= '1';
                else
                    offset(i) <= '0';
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        B: REDUCER
            generic map (
                WORD_BITS       => WORD_BITS      ,
                ENBL_BITS       => ENBL_BITS      ,
                I_WIDTH         => I_WIDTH        ,
                O_WIDTH         => O_WIDTH        ,
                QUEUE_SIZE      => QUEUE_SIZE     ,
                VALID_MIN       => 0              ,
                VALID_MAX       => 0              ,
                I_JUSTIFIED     => 0              ,
                FLUSH_ENABLE    => 0                     
            )
            port map (
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK            , -- In  :
                RST             => RST            , -- In  :
                CLR             => CLR            , -- In  :
            -----------------------------------------------------------------------
            -- 各種制御信号
            -----------------------------------------------------------------------
                START           => xfer_start     , -- In  :
                OFFSET          => offset         , -- In  :
                DONE            => done           , -- In  :
                FLUSH           => flush          , -- In  :
                BUSY            => buf_busy       , -- Out :
                VALID           => open           , -- Out :
            -----------------------------------------------------------------------
            -- 入力側 I/F
            -----------------------------------------------------------------------
                I_DATA          => BUF_DATA       , -- In  :
                I_ENBL          => buf_push_ben   , -- In  :
                I_DONE          => buf_push_last  , -- In  :
                I_FLUSH         => flush          , -- In  :
                I_VAL           => buf_push_valid , -- In  :
                I_RDY           => buf_push_ready , -- Out :
            -----------------------------------------------------------------------
            -- 出力側 I/F
            -----------------------------------------------------------------------
                O_DATA          => WDATA          , -- Out :
                O_ENBL          => WSTRB          , -- Out :
                O_DONE          => data_last      , -- Out :
                O_FLUSH         => open           , -- Out :
                O_VAL           => data_valid     , -- Out :
                O_RDY           => WREADY           -- In  :
        );
        WVALID <= data_valid;
        WLAST  <= data_last;
    end block;
    -------------------------------------------------------------------------------
    -- Non Safety(Risky) Return Response.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                risky_ack_size <= (others => '0');
                risky_ack_next <= '0';
                risky_ack_last <= '0';
                risky_ack_mode <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                risky_ack_size <= (others => '0');
                risky_ack_next <= '0';
                risky_ack_last <= '0';
                risky_ack_mode <= FALSE;
            elsif (xfer_start = '1') then
                if (xfer_req_safety = '0') then
                    risky_ack_size <= xfer_req_size;
                    risky_ack_next <= xfer_req_next;
                    risky_ack_last <= xfer_req_last;
                    risky_ack_mode <= TRUE;
                else
                    risky_ack_size <= (others => '0');
                    risky_ack_next <= '0';
                    risky_ack_last <= '0';
                    risky_ack_mode <= FALSE;
                end if;
            elsif (risky_ack_valid = '1') then
                    risky_ack_size <= (others => '0');
                    risky_ack_next <= '0';
                    risky_ack_last <= '0';
                    risky_ack_mode <= FALSE;
            end if;
        end if;
    end process;
    risky_ack_valid <= '1' when (risky_ack_mode and data_valid = '1' and data_last = '1' and WREADY = '1') else '0';
    risky_ack_error <= '0';
    -------------------------------------------------------------------------------
    -- Transfer Response Queue.
    -------------------------------------------------------------------------------
    RES: block
        constant VEC_LO         : integer := 0;
        constant VEC_SIZE_LO    : integer := VEC_LO;
        constant VEC_SIZE_HI    : integer := VEC_SIZE_LO  + XFER_MAX_SIZE;
        constant VEC_NEXT_POS   : integer := VEC_SIZE_HI  + 1;
        constant VEC_LAST_POS   : integer := VEC_NEXT_POS + 1;
        constant VEC_SAFETY_POS : integer := VEC_LAST_POS + 1;
        constant VEC_HI         : integer := VEC_SAFETY_POS;
        signal   i_vec          : std_logic_vector(VEC_HI downto VEC_LO);
        signal   q_vec          : std_logic_vector(VEC_HI downto VEC_LO);
        constant Q_ALL_0        : std_logic_vector(QUEUE_SIZE downto 0) := (others => '0');
    begin
        i_vec(VEC_SIZE_HI downto VEC_SIZE_LO) <= xfer_req_size;
        i_vec(VEC_NEXT_POS)                   <= xfer_req_next;
        i_vec(VEC_LAST_POS)                   <= xfer_req_last;
        i_vec(VEC_SAFETY_POS)                 <= xfer_req_safety;
        QUEUE: QUEUE_REGISTER
            generic map (
                QUEUE_SIZE  => QUEUE_SIZE        ,
                DATA_BITS   => i_vec'length      ,
                LOWPOWER    => 1
            )
            port map (
                CLK         => CLK               , -- In  :
                RST         => RST               , -- In  :
                CLR         => CLR               , -- In  :
                I_DATA      => i_vec             , -- In  :
                I_VAL       => xfer_start        , -- In  :
                I_RDY       => ack_queue_ready   , -- Out :
                O_DATA      => open              , -- Out :
                O_VAL       => open              , -- Out :
                Q_DATA      => q_vec             , -- Out :
                Q_VAL       => ack_queue_valid   , -- Out :
                Q_RDY       => BVALID              -- In  :
            );
        ack_queue_size   <= q_vec(VEC_SIZE_HI downto VEC_SIZE_LO);
        ack_queue_next   <= q_vec(VEC_NEXT_POS);
        ack_queue_last   <= q_vec(VEC_LAST_POS);
        ack_queue_safety <= q_vec(VEC_SAFETY_POS);
        ack_queue_empty  <= '1' when (ack_queue_valid = Q_ALL_0) else '0';
    end block;
    -------------------------------------------------------------------------------
    -- BREADY : Write Response Ready
    -------------------------------------------------------------------------------
    BREADY  <= '1' when (ack_queue_valid(0) = '1') else '0';
    -------------------------------------------------------------------------------
    -- Safety Return Response.
    -------------------------------------------------------------------------------
    safety_ack_mode  <= (ack_queue_safety = '1');
    safety_ack_valid <= '1' when (safety_ack_mode and ack_queue_valid(0) = '1' and BVALID = '1') else '0';
    safety_ack_error <= '1' when (safety_ack_mode and (BRESP = AXI4_RESP_SLVERR or BRESP = AXI4_RESP_DECERR)) else '0';
    safety_ack_next  <= '1' when (safety_ack_mode and ack_queue_next = '1') else '0';
    safety_ack_last  <= '1' when (safety_ack_mode and ack_queue_last = '1') else '0';
    safety_ack_size  <= ack_queue_size when (safety_ack_mode and safety_ack_error = '0') else (others => '0');
    -------------------------------------------------------------------------------
    -- Return Response.
    -------------------------------------------------------------------------------
    xfer_ack_valid <= risky_ack_valid or safety_ack_valid;
    xfer_ack_error <= risky_ack_error or safety_ack_error;
    xfer_ack_next  <= risky_ack_next  or safety_ack_next;
    xfer_ack_last  <= risky_ack_last  or safety_ack_last;
    xfer_ack_size  <= risky_ack_size  or safety_ack_size;
    -------------------------------------------------------------------------------
    -- Reserve Size and Last
    -------------------------------------------------------------------------------
    RESV_VAL       <= '1' when (xfer_start    = '1') else '0';
    RESV_LAST      <= '1' when (xfer_req_last = '1') else '0';
    RESV_ERROR     <= '0';
    RESV_SIZE      <= std_logic_vector(RESIZE(unsigned(xfer_req_size) , RESV_SIZE'length));
    -------------------------------------------------------------------------------
    -- Pull Size and Last
    -------------------------------------------------------------------------------
    PULL_VAL       <= '1' when (ack_queue_valid(0) = '1' and BVALID = '1') else '0';
    PULL_LAST      <= '1' when (ack_queue_last = '1') else '0';
    PULL_ERROR     <= '1' when (BRESP = AXI4_RESP_SLVERR or BRESP = AXI4_RESP_DECERR) else '0';
    PULL_SIZE      <= (others => '0') when (BRESP = AXI4_RESP_SLVERR or BRESP = AXI4_RESP_DECERR) else
                      std_logic_vector(RESIZE(unsigned(ack_queue_size), PULL_SIZE'length));
end RTL;
