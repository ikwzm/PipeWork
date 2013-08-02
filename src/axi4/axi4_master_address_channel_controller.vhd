-----------------------------------------------------------------------------------
--!     @file    axi4_master_address_channel_controller.vhd
--!     @brief   AXI4 Master Address Channel Controller
--!     @version 1.5.0
--!     @date    2013/8/2
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
--! @brief   AXI4 Master Address Channel Controller
-----------------------------------------------------------------------------------
entity  AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        VAL_BITS        : --! @brief VALID BITS :
                          --! REQ_VAL、ACK_VAL のビット数を指定する.
                          integer := 1;
        DATA_SIZE       : --! @brief DATA SIZE :
                          --! データバスのバイト数を"２のべき乗値"で指定する.
                          integer := 6;
        ADDR_BITS       : --! @brief ADDRESS BITS :
                          --! アドレス信号のビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! 各種SIZE信号のビット数を指定する.
                          integer := 32;
        ALEN_BITS       : --! @brief BURST LENGTH BITS :
                          --! バースト長を示す信号のビット幅を指定する.
                          integer := AXI4_ALEN_WIDTH;
        REQ_SIZE_BITS   : --! @brief REQUEST SIZE BITS :
                          --! REQ_SIZE信号のビット数を指定する.
                          --! * REQ_SIZE信号が無効(REQ_SIZE_ENABLE=0)の場合でもエラ
                          --!   ーが発生しないように、REQ_SIZE_BITS>0にしておかなけ
                          --!   ればならない.
                          integer := 32;
        REQ_SIZE_VALID  : --! @brief REQUEST SIZE VALID :
                          --! REQ_SIZE信号を有効にするかどうかを指定する.
                          --! * REQ_SIZE_VALID=0で無効.
                          --! * REQ_SIZE_VALID=1で有効.
                          integer range 0 to 1 :=  1;
        FLOW_VALID      : --! @brief FLOW VALID :
                          --! FLOW_PAUSE、FLOW_STOP、FLOW_SIZE、FLOW_LAST信号を有効
                          --! にするかどうかを指定する.
                          --! * FLOW_VALID=0で無効.
                          --! * FLOW_VALID=1で有効.
                          integer range 0 to 1 := 1;
        XFER_MIN_SIZE   : --! @brief TRANSFER MINIMUM SIZE :
                          --! 一回の転送サイズの最小バイト数を２のべき乗で指定する.
                          integer := 4;
        XFER_MAX_SIZE   : --! @brief TRANSFER MAXIMUM SIZE :
                          --! 一回の転送サイズの最大バイト数を２のべき乗で指定する.
                          integer := 4
    );
    port(
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK             : in    std_logic;
        RST             : in    std_logic;
        CLR             : in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Address Channel Signals.
    ------------------------------------------------------------------------------
        AADDR           : out   std_logic_vector(ADDR_BITS    -1 downto 0);
        ALEN            : out   std_logic_vector(ALEN_BITS    -1 downto 0);
        ASIZE           : out   AXI4_ASIZE_TYPE;
        AVALID          : out   std_logic;
        AREADY          : in    std_logic;
    -------------------------------------------------------------------------------
    -- Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_ADDR        : in    std_logic_vector(ADDR_BITS    -1 downto 0);
        REQ_SIZE        : in    std_logic_vector(REQ_SIZE_BITS-1 downto 0);
        REQ_FIRST       : in    std_logic;
        REQ_LAST        : in    std_logic;
        REQ_SPECULATIVE : in    std_logic;
        REQ_SAFETY      : in    std_logic;
        REQ_VAL         : in    std_logic_vector(VAL_BITS     -1 downto 0);
        REQ_RDY         : out   std_logic;
    -------------------------------------------------------------------------------
    -- Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VAL         : out   std_logic_vector(VAL_BITS     -1 downto 0);
        ACK_NEXT        : out   std_logic;
        ACK_LAST        : out   std_logic;
        ACK_ERROR       : out   std_logic;
        ACK_STOP        : out   std_logic;
        ACK_NONE        : out   std_logic;
        ACK_SIZE        : out   std_logic_vector(SIZE_BITS    -1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_PAUSE      : in    std_logic := '0';
        FLOW_STOP       : in    std_logic := '0';
        FLOW_LAST       : in    std_logic := '1';
        FLOW_SIZE       : in    std_logic_vector(SIZE_BITS    -1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- Transfer Size Select Signals.
    -------------------------------------------------------------------------------
        XFER_SIZE_SEL   : in    std_logic_vector(XFER_MAX_SIZE   downto XFER_MIN_SIZE) := (others => '1');
    -------------------------------------------------------------------------------
    -- Transfer Request Signals.
    -------------------------------------------------------------------------------
        XFER_REQ_ADDR   : out   std_logic_vector(ADDR_BITS    -1 downto 0);
        XFER_REQ_SIZE   : out   std_logic_vector(XFER_MAX_SIZE   downto 0);
        XFER_REQ_SEL    : out   std_logic_vector(VAL_BITS     -1 downto 0);
        XFER_REQ_FIRST  : out   std_logic;
        XFER_REQ_LAST   : out   std_logic;
        XFER_REQ_NEXT   : out   std_logic;
        XFER_REQ_SAFETY : out   std_logic;
        XFER_REQ_VAL    : out   std_logic;
        XFER_REQ_RDY    : in    std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Response Signals.
    -------------------------------------------------------------------------------
        XFER_ACK_SIZE   : in    std_logic_vector(XFER_MAX_SIZE   downto 0);
        XFER_ACK_VAL    : in    std_logic;
        XFER_ACK_NEXT   : in    std_logic;
        XFER_ACK_LAST   : in    std_logic;
        XFER_ACK_ERR    : in    std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Status Signals.
    -------------------------------------------------------------------------------
        XFER_RUNNING    : in    std_logic
    );
end AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.COMPONENTS.CHOPPER;
architecture RTL of AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   req_size_last      : std_logic;
    signal   req_size_none      : std_logic;
    signal   max_xfer_size      : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   max_xfer_load      : std_logic;
    constant max_xfer_chop      : std_logic := '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   req_xfer_start     : std_logic;
    signal   req_xfer_none      : std_logic;
    signal   req_xfer_stop      : std_logic;
    signal   req_xfer_pause     : std_logic;
    signal   req_xfer_valid     : std_logic;
    signal   req_xfer_size      : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   req_xfer_last      : std_logic;
    signal   req_xfer_next      : std_logic;
    signal   req_xfer_end       : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   ack_xfer_valid     : std_logic;
    signal   ack_xfer_error     : std_logic;
    signal   ack_xfer_last      : std_logic;
    signal   ack_xfer_next      : std_logic;
    signal   ack_xfer_size      : std_logic_vector(SIZE_BITS-1   downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   q_ack_xfer_size    : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   q_ack_xfer_last    : std_logic;
    signal   q_ack_xfer_next    : std_logic;
    signal   q_ack_xfer_end     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   burst_length       : std_logic_vector(ALEN_BITS-1   downto 0);
    signal   addr_valid         : std_logic;
    signal   speculative        : boolean;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    type     STATE_TYPE     is  ( IDLE_STATE, 
                                  WAIT_STATE,
                                  XFER_STATE,
                                  STOP_STATE,
                                  NONE_STATE);
    signal   curr_state         : STATE_TYPE;
    signal   curr_valid         : std_logic_vector(VAL_BITS -1   downto 0);
    constant NULL_VALID         : std_logic_vector(VAL_BITS -1   downto 0) := (others => '0');
begin
    -------------------------------------------------------------------------------
    -- req_xfer_stop : 転送中止要求.
    -------------------------------------------------------------------------------
    req_xfer_stop  <= '1' when (FLOW_STOP     = '1' and FLOW_VALID /= 0) else '0';
    -------------------------------------------------------------------------------
    -- req_xfer_pause: 転送中断要求.
    -------------------------------------------------------------------------------
    req_xfer_pause <= '1' when (FLOW_PAUSE    = '1' and FLOW_VALID /= 0) else '0';
    -------------------------------------------------------------------------------
    -- req_xfer_none : 転送無効要求.
    -------------------------------------------------------------------------------
    req_xfer_none  <= '1' when (req_xfer_stop = '0'  and
                                req_size_none = '1') else '0';
    -------------------------------------------------------------------------------
    -- req_xfer_start: 転送開始要求.
    -------------------------------------------------------------------------------
    req_xfer_start <= '1' when (req_xfer_stop  = '0' and
                                req_xfer_none  = '0' and 
                                req_xfer_pause = '0' and
                                XFER_REQ_RDY   = '1') else '0';
    -------------------------------------------------------------------------------
    -- ステートマシン
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
    begin
        if (RST = '1') then
                curr_state    <= IDLE_STATE;
                curr_valid    <= NULL_VALID;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state    <= IDLE_STATE;
                curr_valid    <= NULL_VALID;
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (REQ_VAL /= NULL_VALID) then
                            next_state := WAIT_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                        curr_valid <= REQ_VAL;
                    when WAIT_STATE =>
                        if    (req_xfer_stop  = '1') then
                            next_state := STOP_STATE;
                        elsif (req_xfer_none  = '1') then
                            next_state := NONE_STATE;
                        elsif (req_xfer_start = '1') then
                            next_state := XFER_STATE;
                        else
                            next_state := WAIT_STATE;
                        end if;
                    when XFER_STATE =>
                        if (ack_xfer_valid = '1') then
                            next_state := IDLE_STATE;
                        else
                            next_state := XFER_STATE;
                        end if;
                    when STOP_STATE =>
                        if (XFER_RUNNING = '1') then
                            next_state := STOP_STATE;
                        else 
                            next_state := IDLE_STATE;
                        end if;
                    when NONE_STATE =>
                        next_state := IDLE_STATE;
                    when others =>
                        next_state := IDLE_STATE;
                end case;
                curr_state <= next_state;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- REQ_RDY
    -------------------------------------------------------------------------------
    REQ_RDY        <= '1' when (curr_state = IDLE_STATE) else '0';
    -------------------------------------------------------------------------------
    -- max_xfer_load : max_xfer_size などを計算するためのトリガー信号.
    -------------------------------------------------------------------------------
    max_xfer_load  <= '1' when (curr_state = IDLE_STATE and REQ_VAL /= NULL_VALID) else '0';
    -------------------------------------------------------------------------------
    -- req_xfer_valid: 転送開始要求トリガー.
    -------------------------------------------------------------------------------
    req_xfer_valid <= '1' when (curr_state = WAIT_STATE and req_xfer_start = '1') else '0';
    -------------------------------------------------------------------------------
    -- max_xfer_size : １回のトランザクションでの最大転送サイズ.
    -- req_size_none : REQ_SIZEの値が0であることを示すフラグ.
    -- req_size_last : REQ_SIZEによる最後の転送要求であることを示すフラグ.
    -------------------------------------------------------------------------------
    -- REQ_SIZE_VALID /= 0 の場合.
    -------------------------------------------------------------------------------
    MAX_XFER_SIZE_NE_0: if (REQ_SIZE_VALID /= 0) generate
        GEN: CHOPPER
            generic map (
                BURST       => 1                     , --
                MIN_PIECE   => XFER_MIN_SIZE         , --
                MAX_PIECE   => XFER_MAX_SIZE         , --
                MAX_SIZE    => SIZE_BITS+1           , --
                ADDR_BITS   => REQ_ADDR'length       , --
                SIZE_BITS   => REQ_SIZE'length       , --
                COUNT_BITS  => 1                     , --
                PSIZE_BITS  => max_xfer_size'length  , --
                GEN_VALID   => 0                       --
            )                                          --
            port map (                                 --
                CLK         => CLK                   , -- In  :
                RST         => RST                   , -- In  :
                CLR         => CLR                   , -- In  :
                ADDR        => REQ_ADDR              , -- In  :
                SIZE        => REQ_SIZE              , -- In  :
                SEL         => XFER_SIZE_SEL         , -- In  :
                LOAD        => max_xfer_load         , -- In  :
                CHOP        => max_xfer_chop         , -- In  :
                COUNT       => open                  , -- Out :
                NONE        => req_size_none         , -- Out : 
                LAST        => req_size_last         , -- Out : 
                NEXT_NONE   => open                  , -- Out :
                NEXT_LAST   => open                  , -- Out :
                PSIZE       => max_xfer_size         , -- Out :
                NEXT_PSIZE  => open                  , -- Out :
                VALID       => open                  , -- Out :
                NEXT_VALID  => open                    -- Out :
            );
    end generate;
    -------------------------------------------------------------------------------
    -- REQ_SIZE_VALID = 0 の場合.
    -------------------------------------------------------------------------------
    MAX_XFER_SIZE_EQ_0: if (REQ_SIZE_VALID = 0) generate
        function GEN_MAX_REQ_SIZE return std_logic_vector is
            variable value : std_logic_vector(XFER_MAX_SIZE downto 0);
        begin
            for i in value'range loop
                if (i = value'high) then
                    value(i) := '1';
                else
                    value(i) := '0';
                end if;
            end loop;
            return value;
        end function;
        constant MAX_REQ_SIZE : std_logic_vector(XFER_MAX_SIZE downto 0) := GEN_MAX_REQ_SIZE;
    begin
        GEN: CHOPPER
            generic map (
                BURST       => 1                     , --
                MIN_PIECE   => XFER_MIN_SIZE         , --
                MAX_PIECE   => XFER_MAX_SIZE         , --
                MAX_SIZE    => SIZE_BITS+1           , --
                ADDR_BITS   => REQ_ADDR'length       , --
                SIZE_BITS   => MAX_REQ_SIZE'length   , --
                COUNT_BITS  => 1                     , --
                PSIZE_BITS  => max_xfer_size'length  , --
                GEN_VALID   => 0                       --
            )                                          -- 
            port map (                                 -- 
                CLK         => CLK                   , -- In  :
                RST         => RST                   , -- In  :
                CLR         => CLR                   , -- In  :
                ADDR        => REQ_ADDR              , -- In  :
                SIZE        => MAX_REQ_SIZE          , -- In  :
                SEL         => XFER_SIZE_SEL         , -- In  :
                LOAD        => max_xfer_load         , -- In  :
                CHOP        => max_xfer_chop         , -- In  :
                COUNT       => open                  , -- Out :
                NONE        => req_size_none         , -- Out : 
                LAST        => req_size_last         , -- Out : 
                NEXT_NONE   => open                  , -- Out :
                NEXT_LAST   => open                  , -- Out :
                PSIZE       => max_xfer_size         , -- Out :
                NEXT_PSIZE  => open                  , -- Out :
                VALID       => open                  , -- Out :
                NEXT_VALID  => open                    -- Out :
            );
    end generate;
    -------------------------------------------------------------------------------
    -- req_xfer_size : 実際の転送要求サイズ.
    -- req_xfer_last : 最後の転送要求かつREQ_LAST='1'であることを示すフラグ.
    -- req_xfer_end  : 最後の転送要求であることを示すフラグ.
    -- burst_length  : バースト長(１少ないことに注意).
    -------------------------------------------------------------------------------
    process (max_xfer_size, req_size_last, FLOW_SIZE, FLOW_LAST, REQ_ADDR, REQ_LAST)
        variable u_flow_size     : unsigned(FLOW_SIZE'length-1 downto 0);
        variable u_xfer_req_size : unsigned(XFER_MAX_SIZE downto 0);
        variable u_xfer_max_size : unsigned(XFER_MAX_SIZE downto 0);
        variable u_start_address : unsigned(XFER_MAX_SIZE downto 0);
        variable u_last_address  : unsigned(XFER_MAX_SIZE downto 0);
        variable u_burst_length  : unsigned(XFER_MAX_SIZE downto DATA_SIZE);
    begin
        if (FLOW_VALID /= 0) then
            u_flow_size     := to_01(unsigned(FLOW_SIZE    ), '0');
            u_xfer_max_size := to_01(unsigned(max_xfer_size), '0');
            if    (u_flow_size < u_xfer_max_size) then
                u_xfer_req_size := RESIZE(u_flow_size    , u_xfer_req_size'length);
                req_xfer_last   <= FLOW_LAST;
                req_xfer_next   <= '0';
                req_xfer_end    <= FLOW_LAST;
            elsif (u_flow_size = u_xfer_max_size) then
                u_xfer_req_size := RESIZE(u_xfer_max_size, u_xfer_req_size'length);
                req_xfer_last   <= FLOW_LAST or (req_size_last and     REQ_LAST);
                req_xfer_next   <= '0'       or (req_size_last and not REQ_LAST);
                req_xfer_end    <= FLOW_LAST or (req_size_last                 );
            else
                u_xfer_req_size := RESIZE(u_xfer_max_size, u_xfer_req_size'length);
                req_xfer_last   <= '0'       or (req_size_last and     REQ_LAST);
                req_xfer_next   <= '0'       or (req_size_last and not REQ_LAST);
                req_xfer_end    <= '0'       or (req_size_last                 );
            end if;
        else
                u_xfer_max_size := to_01(unsigned(max_xfer_size), '0');
                u_xfer_req_size := RESIZE(u_xfer_max_size, u_xfer_req_size'length);
                req_xfer_last   <= '0'       or (req_size_last and     REQ_LAST);
                req_xfer_next   <= '0'       or (req_size_last and not REQ_LAST);
                req_xfer_end    <= '0'       or (req_size_last                 );
        end if;
        for i in u_start_address'range loop
            if (i < DATA_SIZE) then
                u_start_address(i) := REQ_ADDR(i);
            else
                u_start_address(i) := '0';
            end if;
        end loop;
        u_last_address := u_start_address + u_xfer_req_size - 1;
        u_burst_length := u_last_address(u_burst_length'range);
        burst_length   <= std_logic_vector(RESIZE(u_burst_length, burst_length'length));
        req_xfer_size  <= std_logic_vector(u_xfer_req_size);
    end process;
    -------------------------------------------------------------------------------
    -- q_ack_xfer_size : req_xfer_size を保持しておくレジスタ.
    -- q_ack_xfer_end  : req_xfer_end  を保持しておくレジスタ.
    -- q_ack_xfer_last : req_xfer_last を保持しておくレジスタ.
    -- q_ack_xfer_next : req_xfer_next を保持しておくレジスタ.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                q_ack_xfer_size <= (others => '0');
                q_ack_xfer_last <= '0';
                q_ack_xfer_next <= '0';
                q_ack_xfer_end  <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                q_ack_xfer_size <= (others => '0');
                q_ack_xfer_last <= '0';
                q_ack_xfer_next <= '0';
                q_ack_xfer_end  <= '0';
            elsif (curr_state = WAIT_STATE) then
                q_ack_xfer_size <= req_xfer_size;
                q_ack_xfer_last <= req_xfer_last;
                q_ack_xfer_next <= req_xfer_next;
                q_ack_xfer_end  <= req_xfer_end ;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- speculative     : 投機実行可能であることを示すフラグ.
    -------------------------------------------------------------------------------
    speculative    <= (REQ_SPECULATIVE = '1' and
                      not (q_ack_xfer_last = '1' and q_ack_xfer_end = '1'));
    -------------------------------------------------------------------------------
    -- ack_xfer_valid  : 転送応答有効信号.
    -- ack_xfer_last   : 最後の転送要求の応答であることを示すフラグ.
    -- ack_xfer_next   : 最後の転送要求の応答であることを示すフラグ.
    -- ack_xfer_size   : 転送応答サイズ.
    -------------------------------------------------------------------------------
    ack_xfer_valid <= '1' when (speculative = TRUE  and addr_valid = '1' and AREADY = '1') or
                               (speculative = FALSE and XFER_ACK_VAL    = '1') else '0';
    ack_xfer_last  <= '1' when (speculative = TRUE  and q_ack_xfer_last = '1') or
                               (speculative = FALSE and XFER_ACK_LAST   = '1') else '0';
    ack_xfer_next  <= '1' when (speculative = TRUE  and q_ack_xfer_next = '1') or
                               (speculative = FALSE and XFER_ACK_NEXT   = '1') else '0';
    ack_xfer_size  <= std_logic_vector(RESIZE(unsigned(q_ack_xfer_size),SIZE_BITS)) when (speculative) else
                      std_logic_vector(RESIZE(unsigned(  XFER_ACK_SIZE),SIZE_BITS));
    -------------------------------------------------------------------------------
    -- ACK_VAL         : 転送応答有効信号出力.
    -- ACK_NEXT        : 転送が終わって次の転送があることを示すフラグ.
    -- ACK_LAST        : 転送が終わって次の転送がもう無いことを示すフラグ.
    -- ACK_ERROR       : 転送エラーが発生した事を示すフラグ.
    -- ACK_STOP        : XFER_STOP による転送中止が発生した事を示すフラグ.
    -- ACK_NONE        : 転送サイズが０の転送要求だったことを示すフラグ.
    -- ACK_SIZE        : 転送応答サイズ信号出力.
    -------------------------------------------------------------------------------
    ACK_VAL   <= curr_valid    when (curr_state = XFER_STATE and ack_xfer_valid = '1') or
                                    (curr_state = STOP_STATE and XFER_RUNNING   = '0') or
                                    (curr_state = NONE_STATE) else NULL_VALID;
    ACK_NEXT  <= '1'           when (curr_state = XFER_STATE and ack_xfer_next  = '1') or
                                    (curr_state = NONE_STATE and REQ_LAST       = '0') else '0';
    ACK_LAST  <= '1'           when (curr_state = XFER_STATE and ack_xfer_last  = '1') or
                                    (curr_state = NONE_STATE and REQ_LAST       = '1') else '0';
    ACK_ERROR <= '1'           when (curr_state = XFER_STATE and XFER_ACK_ERR   = '1') else '0';
    ACK_STOP  <= '1'           when (curr_state = STOP_STATE and XFER_RUNNING   = '0') else '0';
    ACK_NONE  <= '1'           when (curr_state = NONE_STATE) else '0';
    ACK_SIZE  <= ack_xfer_size when (curr_state = XFER_STATE) else (others => '0');
    -------------------------------------------------------------------------------
    -- XFER_REQ_VAL    : 転送要求有効信号
    -- XFER_REQ_SEL    : 転送要求選択信号
    -- XFER_REQ_ADDR   : 転送要求開始アドレス
    -- XFER_REQ_SIZE   : 転送要求サイズ.
    -- XFER_REQ_END    : 最後の転送要求であることを示すフラグ.
    -- XFER_REQ_LAST   : 最後の転送要求(かつLAST='1')であることを示すフラグ.
    -- XFER_REQ_FIRST  : 最初の転送要求であることを示すフラグ.
    -- XFER_REQ_SAFETY : セーフティモード.
    -------------------------------------------------------------------------------
    XFER_REQ_VAL    <= req_xfer_valid;
    XFER_REQ_SEL    <= curr_valid;
    XFER_REQ_ADDR   <= REQ_ADDR;
    XFER_REQ_SIZE   <= req_xfer_size;
    XFER_REQ_NEXT   <= req_xfer_next;
    XFER_REQ_LAST   <= req_xfer_last;
    XFER_REQ_FIRST  <= REQ_FIRST;
    XFER_REQ_SAFETY <= '1' when (REQ_SAFETY   = '1') or
                                (req_xfer_end = '1' and req_xfer_last = '1') else '0';
    -------------------------------------------------------------------------------
    -- AXI4 Read Address Channel Signals Output.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                addr_valid <= '0';
                AVALID     <= '0';
                AADDR      <= (others => '0');
                ALEN       <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                addr_valid <= '0';
                AVALID     <= '0';
                AADDR      <= (others => '0');
                ALEN       <= (others => '0');
            elsif (req_xfer_valid = '1') then
                addr_valid <= '1';
                AVALID     <= '1';
                AADDR      <= REQ_ADDR;
                ALEN       <= burst_length;
            elsif (AREADY = '1') then
                addr_valid <= '0';
                AVALID     <= '0';
            end if;
        end if;
    end process;
    ASIZE <= std_logic_vector(to_unsigned(DATA_SIZE, ASIZE'length));
end RTL;
