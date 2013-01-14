-----------------------------------------------------------------------------------
--!     @file    axi4_master_read_interface.vhd
--!     @brief   AXI4 Master Read Interface
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
--! @brief   AXI4 Master Read Interface
-----------------------------------------------------------------------------------
entity  AXI4_MASTER_READ_INTERFACE is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 リードアドレスチャネルのARADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 READ DATA CHANNEL DATA WIDTH :
                          --! AXI4 リードデータチャネルのRDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびリードデータチャネルの
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
        -- AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
        ARID            : --! @brief Read address ID.
                          --! This signal is identification tag for the read
                          --! address group of singals.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        ARADDR          : --! @brief Read address.  
                          --! The read address gives the address of the first
                          --! transfer in a read burst transaction.
                          out   std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        ARLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          out   AXI4_ALEN_TYPE;
        ARSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          out   AXI4_ASIZE_TYPE;
        ARBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          out   AXI4_ABURST_TYPE;
        ARLOCK          : --! @brief Lock type.
                          --! This signal provides additional information about
                          --! the atomic characteristics of the transfer.
                          out   AXI4_ALOCK_TYPE;
        ARCACHE         : --! @brief Memory type.
                          --! This signal indicates how transactions are required
                          --! to progress through a system.
                          out   AXI4_ACACHE_TYPE;
        ARPROT          : --! @brief Protection type.
                          --! This signal indicates the privilege and security
                          --! level of the transaction, and wherther the
                          --! transaction is a data access or an instruction access.
                          out   AXI4_APROT_TYPE;
        ARQOS           : --! @brief Quality of Service, QoS.
                          --! QoS identifier sent for each read transaction.
                          out   AXI4_AQOS_TYPE;
        ARREGION        : --! @brief Region identifier.
                          --! Permits a single physical interface on a slave to be
                          --! used for multiple logical interfaces.
                          out   AXI4_AREGION_TYPE;
        ARVALID         : --! @brief Read address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          out   std_logic;
        ARREADY         : --! @brief Read address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          in    std_logic;
        --------------------------------------------------------------------------
        -- AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
        RID             : --! @brief Read ID tag.
                          --! This signal is the identification tag for the read
                          --! data group of signals generated by the slave.
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        RDATA           : --! @brief Read data.
                          in    std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        RRESP           : --! @brief Read response.
                          --! This signal indicates the status of the read transaction.
                          in    AXI4_RESP_TYPE;
        RLAST           : --! @brief Read last.
                          --! This signal indicates the last transfer in a read burst.
                          in    std_logic;
        RVALID          : --! @brief Read data valid.
                          --! This signal indicates that the channel is signaling
                          --! the required read data.
                          in    std_logic;
        RREADY          : --! @brief Read data ready.
                          --! This signal indicates that the master can accept the
                          --! read data and response information.
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
        -- Command Acknowledge Signals.
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
        RESV_LAST       : out   std_logic;
        RESV_ERROR      : out   std_logic;
        RESV_SIZE       : out   std_logic_vector(SIZE_BITS        -1 downto 0);
        ---------------------------------------------------------------------------
        -- Push Size Signals.
        ---------------------------------------------------------------------------
        PUSH_VAL        : out   std_logic;
        PUSH_LAST       : out   std_logic;
        PUSH_ERROR      : out   std_logic;
        PUSH_SIZE       : out   std_logic_vector(SIZE_BITS        -1 downto 0);
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
        BUF_WEN         : out   std_logic;
        BUF_BEN         : out   std_logic_vector(BUF_DATA_WIDTH/8 -1 downto 0);
        BUF_DATA        : out   std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
        BUF_PTR         : out   std_logic_vector(BUF_PTR_BITS     -1 downto 0);
        BUF_RDY         : in    std_logic
    );
end AXI4_MASTER_READ_INTERFACE;
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
architecture RTL of AXI4_MASTER_READ_INTERFACE is
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
    signal   xfer_safety        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_start         : std_logic;
    signal   xfer_init_start    : std_logic;
    signal   xfer_running       : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_queue_addr    : std_logic_vector(AXI4_DATA_SIZE downto 0);
    signal   xfer_queue_size    : std_logic_vector(XFER_MAX_SIZE  downto 0);
    signal   xfer_queue_next    : std_logic;
    signal   xfer_queue_last    : std_logic;
    signal   xfer_queue_first   : std_logic;
    signal   xfer_queue_safety  : std_logic;
    signal   xfer_queue_empty   : std_logic;
    signal   xfer_queue_valid   : std_logic_vector(QUEUE_SIZE     downto 0);
    signal   xfer_queue_ready   : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant xfer_beat_sel      : std_logic_vector(AXI4_DATA_SIZE downto AXI4_DATA_SIZE) := "1";
    signal   xfer_beat_chop     : std_logic;
    signal   xfer_beat_last     : std_logic;
    signal   xfer_beat_size     : std_logic_vector(SIZE_BITS-1   downto 0);
    signal   xfer_beat_valid    : std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   buf_busy           : std_logic;
    signal   read_enable        : std_logic;
    signal   read_data_valid    : std_logic;
    signal   read_data_ready    : std_logic;
    signal   read_data_ben      : std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
    signal   read_data_flush    : std_logic;
    signal   read_data_done     : std_logic;
    signal   read_data_error    : boolean;
    signal   response_error     : boolean;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   buf_beat_valid     : std_logic;
    signal   buf_beat_ben       : std_logic_vector(BUF_DATA_WIDTH/8-1 downto 0);
    signal   buf_beat_flush     : std_logic;
    signal   buf_beat_done      : std_logic;
    signal   buf_beat_size      : unsigned(SIZE_BITS-1    downto 0);
    signal   buf_write_ptr      : unsigned(BUF_PTR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    type     STATE_TYPE     is  ( IDLE, WAIT_RFIRST, WAIT_RLAST, TURN_AR );
    signal   curr_state         : STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- AXI4 Read Address Channel Controller.
    -------------------------------------------------------------------------------
    AR: AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER
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
            AADDR           => ARADDR            , -- Out :
            ALEN            => ARLEN             , -- Out :
            AVALID          => ARVALID           , -- Out :
            AREADY          => ARREADY           , -- In  :
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
    -- AXI4 Read Address Channel Signals Output.
    -------------------------------------------------------------------------------
    ARBURST  <= REQ_BURST;
    ARSIZE   <= std_logic_vector(to_unsigned(AXI4_DATA_SIZE, ARSIZE'length));
    ARLOCK   <= REQ_LOCK;
    ARCACHE  <= REQ_CACHE;
    ARPROT   <= REQ_PROT;
    ARQOS    <= REQ_QOS;
    ARREGION <= REQ_REGION;
    ARID     <= REQ_ID;
    -------------------------------------------------------------------------------
    -- Transfer Request Queue.
    -------------------------------------------------------------------------------
    REQ: block
        constant VEC_LO         : integer := 0;
        constant VEC_SIZE_LO    : integer := VEC_LO;
        constant VEC_SIZE_HI    : integer := VEC_SIZE_LO  + XFER_MAX_SIZE;
        constant VEC_ADDR_LO    : integer := VEC_SIZE_HI  + 1;
        constant VEC_ADDR_HI    : integer := VEC_ADDR_LO  + AXI4_DATA_SIZE;
        constant VEC_NEXT_POS   : integer := VEC_ADDR_HI  + 1;
        constant VEC_LAST_POS   : integer := VEC_NEXT_POS + 1;
        constant VEC_FIRST_POS  : integer := VEC_LAST_POS + 1;
        constant VEC_SAFETY_POS : integer := VEC_FIRST_POS+ 1;
        constant VEC_HI         : integer := VEC_SAFETY_POS;
        signal   i_vec          : std_logic_vector(VEC_HI downto VEC_LO);
        signal   q_vec          : std_logic_vector(VEC_HI downto VEC_LO);
        constant Q_ALL_0        : std_logic_vector(QUEUE_SIZE downto 0) := (others => '0');
    begin
        i_vec(VEC_SIZE_HI downto VEC_SIZE_LO) <= xfer_req_size;
        i_vec(VEC_ADDR_HI downto VEC_ADDR_LO) <= xfer_req_addr(AXI4_DATA_SIZE downto 0);
        i_vec(VEC_NEXT_POS)                   <= xfer_req_next;
        i_vec(VEC_LAST_POS)                   <= xfer_req_last;
        i_vec(VEC_FIRST_POS)                  <= xfer_req_first;
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
                I_VAL       => xfer_req_valid    , -- In  :
                I_RDY       => xfer_req_ready    , -- Out :
                O_DATA      => open              , -- Out :
                O_VAL       => open              , -- Out :
                Q_DATA      => q_vec             , -- Out :
                Q_VAL       => xfer_queue_valid  , -- Out :
                Q_RDY       => xfer_queue_ready    -- In  :
            );
        xfer_queue_size   <= q_vec(VEC_SIZE_HI downto VEC_SIZE_LO);
        xfer_queue_addr   <= q_vec(VEC_ADDR_HI downto VEC_ADDR_LO);
        xfer_queue_next   <= q_vec(VEC_NEXT_POS);
        xfer_queue_last   <= q_vec(VEC_LAST_POS);
        xfer_queue_first  <= q_vec(VEC_FIRST_POS);
        xfer_queue_safety <= q_vec(VEC_SAFETY_POS);
        xfer_queue_empty  <= '1' when (xfer_queue_valid = Q_ALL_0) else '0';
    end block;
    -------------------------------------------------------------------------------
    -- xfer_beat_valid : AXI4 Read Data Channel はバイトイネーブル信号が無いので、
    --                   ここで作っておく.
    -------------------------------------------------------------------------------
    BEN: CHOPPER
        generic map (
            BURST           => 1                     ,              
            MIN_PIECE       => AXI4_DATA_SIZE        ,
            MAX_PIECE       => AXI4_DATA_SIZE        ,
            MAX_SIZE        => XFER_MAX_SIZE         ,
            ADDR_BITS       => xfer_queue_addr'length,
            SIZE_BITS       => xfer_queue_size'length,
            COUNT_BITS      => 1                     ,
            PSIZE_BITS      => xfer_beat_size'length ,
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
            ADDR            => xfer_queue_addr       , -- In  :
            SIZE            => xfer_queue_size       , -- In  :
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
            LAST            => xfer_beat_last        , -- Out :
            NEXT_NONE       => open                  , -- Out :
            NEXT_LAST       => open                  , -- Out :
            -----------------------------------------------------------------------
            -- １ワードのバイト数
            -----------------------------------------------------------------------
            PSIZE           => xfer_beat_size        , -- Out :
            NEXT_PSIZE      => open                  , -- Out :
            -----------------------------------------------------------------------
            -- バイトイネーブル信号
            -----------------------------------------------------------------------
            VALID           => xfer_beat_valid       , -- Out :
            NEXT_VALID      => open                    -- Out :
        );
    -------------------------------------------------------------------------------
    -- 応答側の状態遷移
    -------------------------------------------------------------------------------
    ACK_FSM: process(CLK, RST) begin
        if (RST = '1') then
                curr_state <= IDLE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state <= IDLE;
            else
                case curr_state is
                    ---------------------------------------------------------------
                    -- Transfer Request Queue から Request を取り出す.
                    ---------------------------------------------------------------
                    when IDLE        =>
                        if (xfer_queue_valid(0) = '1') then
                            curr_state <= WAIT_RFIRST;
                        else
                            curr_state <= IDLE;
                        end if;
                    ---------------------------------------------------------------
                    -- AXI4 Read Data Channel から最初の RVALID が来るのを待つ.
                    ---------------------------------------------------------------
                    when WAIT_RFIRST =>
                        if    (RVALID = '1' and read_data_ready = '1' and RLAST = '1') then
                            curr_state <= TURN_AR;
                        elsif (RVALID = '1' and read_data_ready = '1' and RLAST = '0') then
                            curr_state <= WAIT_RLAST;
                        else
                            curr_state <= WAIT_RFIRST;
                        end if;
                    ---------------------------------------------------------------
                    -- AXI4 Read Data Channel から最後の RVALID が来るのを待つ.
                    ---------------------------------------------------------------
                    when WAIT_RLAST  =>
                        if    (RVALID = '1' and read_data_ready = '1' and RLAST = '1') then
                            curr_state <= TURN_AR;
                        else
                            curr_state <= WAIT_RLAST;
                        end if;
                    ---------------------------------------------------------------
                    -- １クロック待ってから IDLE に戻る.
                    ---------------------------------------------------------------
                    when TURN_AR     =>
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
    XFER_BUSY    <= '1' when (curr_state = WAIT_RFIRST or
                              curr_state = WAIT_RLAST  or
                              xfer_queue_empty = '0' ) else '0';
    -------------------------------------------------------------------------------
    -- xfer_running   : 動作中である事を示すフラグ.
    -------------------------------------------------------------------------------
    xfer_running <= '1' when (curr_state = WAIT_RFIRST or
                              curr_state = WAIT_RLAST  or
                              xfer_queue_empty = '0' ) else '0';
    -------------------------------------------------------------------------------
    -- xfer_ack_size  : Transfer Request Queue から取り出したサイズ情報を保持.
    -- xfer_ack_next  : Transfer Request Queue から取り出したNEXTを保持.
    -- xfer_ack_last  : Transfer Request Queue から取り出したLASTを保持.
    -- xfer_safety    : Transfer Request Queue から取り出したSAFETYを保持.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                xfer_ack_size <= (others => '0');
                xfer_ack_next <= '0';
                xfer_ack_last <= '0';
                xfer_safety   <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                xfer_ack_size <= (others => '0');
                xfer_ack_next <= '0';
                xfer_ack_last <= '0';
                xfer_safety   <= '0';
            elsif (xfer_start = '1') then
                xfer_ack_size <= xfer_queue_size;
                xfer_ack_next <= xfer_queue_next;
                xfer_ack_last <= xfer_queue_last;
                xfer_safety   <= xfer_queue_safety;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- xfer_queue_ready : Transfer Request Queue から情報を取り出すための信号.
    -------------------------------------------------------------------------------
    xfer_queue_ready<= '1' when (curr_state = IDLE) else '0';
    -------------------------------------------------------------------------------
    -- xfer_start       : この信号がトリガーとなっていろいろと処理を開始する.
    -------------------------------------------------------------------------------
    xfer_start      <= '1' when (curr_state = IDLE and xfer_queue_valid(0) = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_init_start  : 一番最初の転送はポインタのクリアなどの作業が必要になる.
    -------------------------------------------------------------------------------
    xfer_init_start <= '1' when (xfer_start = '1'  and xfer_queue_first    = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_beat_chop   : バイトイネーブル信号生成用のトリガー信号.
    -------------------------------------------------------------------------------
    xfer_beat_chop  <= '1' when (read_data_valid = '1' and read_data_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- read_enable      : レシーブバッファを有効にするための信号.
    -------------------------------------------------------------------------------
    read_enable     <= '1' when (curr_state = WAIT_RFIRST or curr_state = WAIT_RLAST) else '0';
    -------------------------------------------------------------------------------
    -- read_data_valid  : レシーブバッファにRDATAを書き込むための信号.
    -------------------------------------------------------------------------------
    read_data_valid <= '1' when (read_enable = '1' and RVALID = '1') else '0';
    -------------------------------------------------------------------------------
    -- read_data_flush  : レシーブバッファに最後のデータであることを示す信号.
    -------------------------------------------------------------------------------
    read_data_flush <= '1' when (read_data_valid  = '1' and RLAST  = '1' and xfer_ack_last = '0') else '0';
    -------------------------------------------------------------------------------
    -- read_data_done   : レシーブバッファに最後のデータであることを示す信号.
    -------------------------------------------------------------------------------
    read_data_done  <= '1' when (read_data_valid  = '1' and RLAST  = '1' and xfer_ack_last = '1') else '0';
    -------------------------------------------------------------------------------
    -- read_data_ben    : レシーブバッファへのバイトイネーブル信号.
    --                    エラー時は書き込みが行われないようにしておく.
    -------------------------------------------------------------------------------
    read_data_ben   <= (others => '0') when (read_data_error) else xfer_beat_valid;
    -------------------------------------------------------------------------------
    -- read_data_error  : エラーレスンポンス
    -------------------------------------------------------------------------------
    read_data_error <= (RRESP = AXI4_RESP_SLVERR or RRESP = AXI4_RESP_DECERR);
    -------------------------------------------------------------------------------
    -- xfer_ack_valid   : 
    -------------------------------------------------------------------------------
    xfer_ack_valid  <= '1' when ((xfer_safety = '0' and curr_state = WAIT_RFIRST                ) or
                                 (xfer_safety = '1' and curr_state = WAIT_RFIRST and RLAST = '1') or
                                 (xfer_safety = '1' and curr_state = WAIT_RLAST  and RLAST = '1')) and
                                 (RVALID = '1' and read_data_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_ack_error   : 
    -------------------------------------------------------------------------------
    xfer_ack_error  <= '1' when (read_data_error or response_error) else '0';
    -------------------------------------------------------------------------------
    -- read_res_error   : 
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                response_error <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or xfer_init_start = '1') then 
                response_error <= FALSE;
            elsif (read_data_error) then
                response_error <= TRUE;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- RREADY : AXI4 Read Data Channel の レディ信号出力.
    -------------------------------------------------------------------------------
    RREADY <= '1' when (read_enable = '1' and read_data_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- RESV_SIZE : 何バイト書き込む予定かを示す信号.
    -- RESV_LAST : 最後のデータを書き込む予定であることを示す信号.
    -- RESV_ERROR: エラーが発生したことを示す信号.
    -- RESV_VAL  : RESV_LAST、RESV_ERROR、RESV_SIZE が有効であることを示す信号.
    -------------------------------------------------------------------------------
    RESV: block
        signal enable : boolean;
        signal error  : boolean;
        signal last   : boolean;
        signal valid  : boolean;
    begin
        enable <= (curr_state = WAIT_RFIRST);
        error  <= (enable and read_data_error = TRUE);
        last   <= (enable and xfer_ack_last   = '1' );
        valid  <= (enable and read_data_valid = '1' and read_data_ready = '1');
        RESV_VAL   <= '1' when (valid) else '0';
        RESV_LAST  <= '1' when (last ) else '0';
        RESV_ERROR <= '1' when (error) else '0';
        RESV_SIZE  <= (others => '0') when (enable = FALSE or error = TRUE) else
                      std_logic_vector(RESIZE(unsigned(xfer_ack_size), RESV_SIZE'length));
    end block;
    -------------------------------------------------------------------------------
    -- レシーブバッファ : 外部のリードバッファに書き込む前に、一旦このバッファで
    --                    受けて、バス幅の変換やバイトレーンの調整を行う.
    -------------------------------------------------------------------------------
    RBUF: block
        constant WORD_BITS      : integer := 8;
        constant ENBL_BITS      : integer := 1;
        constant I_WIDTH        : integer := AXI4_DATA_WIDTH/WORD_BITS;
        constant O_WIDTH        : integer :=  BUF_DATA_WIDTH/WORD_BITS;
        constant QUEUE_SIZE     : integer := O_WIDTH+I_WIDTH+I_WIDTH-1;
        constant offset         : std_logic_vector(O_WIDTH-1 downto 0) := (others => '0');
        constant start          : std_logic := '0';
        constant done           : std_logic := '0';
        constant flush          : std_logic := '0';
        signal   o_enbl         : std_logic_vector(O_WIDTH*ENBL_BITS-1 downto 0);
        signal   o_done         : std_logic;
        signal   o_flush        : std_logic;
        signal   o_valid        : std_logic;
        signal   clear          : std_logic;
    begin
        clear <= '1' when (xfer_init_start = '1' or CLR = '1') else '0';
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
                FLUSH_ENABLE    => 1                     
            )
            port map (
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK            , -- In  :
                RST             => RST            , -- In  :
                CLR             => clear          , -- In  :
            -----------------------------------------------------------------------
            -- 各種制御信号
            -----------------------------------------------------------------------
                START           => start          , -- In  :
                OFFSET          => offset         , -- In  :
                DONE            => done           , -- In  :
                FLUSH           => flush          , -- In  :
                BUSY            => buf_busy       , -- Out :
                VALID           => open           , -- Out :
            -----------------------------------------------------------------------
            -- 入力側 I/F
            -----------------------------------------------------------------------
                I_DATA          => RDATA          , -- In  :
                I_ENBL          => read_data_ben  , -- In  :
                I_DONE          => read_data_done , -- In  :
                I_FLUSH         => read_data_flush, -- In  :
                I_VAL           => read_data_valid, -- In  :
                I_RDY           => read_data_ready, -- Out :
            -----------------------------------------------------------------------
            -- 出力側 I/F
            -----------------------------------------------------------------------
                O_DATA          => BUF_DATA       , -- Out :
                O_ENBL          => buf_beat_ben   , -- Out :
                O_DONE          => buf_beat_done  , -- Out :
                O_FLUSH         => buf_beat_flush , -- Out :
                O_VAL           => buf_beat_valid , -- Out :
                O_RDY           => BUF_RDY          -- In  :
        );
        ---------------------------------------------------------------------------
        -- buf_beat_size : バッファの出力側のバイト数.
        --                 ここでは buf_beat_ben の'1'の数を数えている.
        ---------------------------------------------------------------------------
        process (buf_beat_ben)
            function count_assert_bit(ARG:std_logic_vector) return integer is
                variable n  : integer range 0 to ARG'length;
                variable nL : integer range 0 to ARG'length/2;
                variable nH : integer range 0 to ARG'length/2;
                alias    a  : std_logic_vector(ARG'length-1 downto 0) is ARG;
            begin
                case a'length is
                    when 0 =>                   n := 0;
                    when 1 =>
                        if    (a =    "1") then n := 1;
                        else                    n := 0;
                        end if;
                    when 2 =>
                        if    (a =   "11") then n := 2;
                        elsif (a =   "01") then n := 1;
                        elsif (a =   "10") then n := 1;
                        else                    n := 0;
                        end if;
                    when 4 =>
                        if    (a = "1111") then n := 4;
                        elsif (a = "1101") then n := 3;
                        elsif (a = "1110") then n := 3;
                        elsif (a = "1100") then n := 2;
                        elsif (a = "1011") then n := 3;
                        elsif (a = "1001") then n := 2;
                        elsif (a = "1010") then n := 2;
                        elsif (a = "1000") then n := 1;
                        elsif (a = "0111") then n := 3;
                        elsif (a = "0101") then n := 2;
                        elsif (a = "0110") then n := 2;
                        elsif (a = "0100") then n := 1;
                        elsif (a = "0011") then n := 2;
                        elsif (a = "0001") then n := 1;
                        elsif (a = "0010") then n := 1;
                        else                    n := 0;
                        end if;
                    when others =>
                        nL := count_assert_bit(a(a'length  -1 downto a'length/2));
                        nH := count_assert_bit(a(a'length/2-1 downto 0         ));
                        n  := nL + nH;
                end case;
                return n;
            end function;
            variable size : integer range 0 to buf_beat_ben'length;
        begin
            size := count_assert_bit(buf_beat_ben);
            buf_beat_size <= to_unsigned(size, buf_beat_size'length);
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- PUSH_SIZE : 何バイト書き込んだかを示す信号.
    -- PUSH_LAST : 最後のデータ書き込みであることを示す信号.
    -- PUSH_ERROR: エラーが発生したことを示す信号.
    -- PUSH_VAL  : PUSH_LAST、PUSH_ERROR、PUSH_SIZE が有効であることを示す信号.
    -------------------------------------------------------------------------------
    PUSH: block
        signal error  : boolean;
        signal last   : boolean;
        signal valid  : boolean;
    begin
        error  <= (buf_beat_valid = '1' and buf_beat_done = '1' and response_error);
        last   <= (buf_beat_valid = '1' and buf_beat_done = '1');
        valid  <= (buf_beat_valid = '1' and BUF_RDY       = '1');
        PUSH_VAL   <= '1' when (valid) else '0';
        PUSH_LAST  <= '1' when (last ) else '0';
        PUSH_ERROR <= '1' when (error) else '0';
        PUSH_SIZE  <= (others => '0') when (error) else
                      std_logic_vector(buf_beat_size);
    end block;
    -------------------------------------------------------------------------------
    -- BUF_WEN   : 外部リードバッファへの書き込み信号.
    -------------------------------------------------------------------------------
    BUF_WEN    <= '1' when (buf_beat_valid = '1' and BUF_RDY = '1') else '0';
    -------------------------------------------------------------------------------
    -- BUF_BEN   : 外部リードバッファへの書き込み信号.
    -------------------------------------------------------------------------------
    BUF_BEN    <= buf_beat_ben;
    -------------------------------------------------------------------------------
    -- BUF_PTR   : 外部リードバッファへの書き込みポインタ.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                buf_write_ptr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                buf_write_ptr <= (others => '0');
            elsif (xfer_init_start = '1') then
                buf_write_ptr <= (others => '0');
            elsif (buf_beat_valid = '1' and BUF_RDY = '1') then
                buf_write_ptr <= buf_write_ptr + RESIZE(buf_beat_size, buf_write_ptr'length);
            end if;
        end if;
    end process;
    BUF_PTR <= std_logic_vector(buf_write_ptr);
end RTL;

