-----------------------------------------------------------------------------------
--!     @file    pump_control_register.vhd
--!     @brief   PUMP CONTROL REGISTER
--!     @version 1.0.3
--!     @date    2013/1/14
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
-----------------------------------------------------------------------------------
--! @brief   PUMP VALVE CONTROL REGISTER :
-----------------------------------------------------------------------------------
entity  PUMP_CONTROL_REGISTER is
    generic (
        MODE_BITS       : --! @brief MODE REGISTER BITS :
                          integer := 32;
        STAT_BITS       : --! @brief STATUS REGISTER BITS :
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
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
    -- RESET Bit Register Access Interface.
    -------------------------------------------------------------------------------
        RESET_WRITE     : in  std_logic;
        RESET_WDATA     : in  std_logic;
        RESET_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- START Bit Register Access Interface.
    -------------------------------------------------------------------------------
        START_WRITE     : in  std_logic;
        START_WDATA     : in  std_logic;
        START_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- STOP Bit Register Access Interface.
    -------------------------------------------------------------------------------
        STOP_WRITE      : in  std_logic;
        STOP_WDATA      : in  std_logic;
        STOP_RDATA      : out std_logic;
    -------------------------------------------------------------------------------
    -- PAUSE Bit Register Access Interface.
    -------------------------------------------------------------------------------
        PAUSE_WRITE     : in  std_logic;
        PAUSE_WDATA     : in  std_logic;
        PAUSE_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- FIRST Bit Register Access Interface.
    -------------------------------------------------------------------------------
        FIRST_WRITE     : in  std_logic;
        FIRST_WDATA     : in  std_logic;
        FIRST_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- LAST Bit Register Access Interface.
    -------------------------------------------------------------------------------
        LAST_WRITE      : in  std_logic;
        LAST_WDATA      : in  std_logic;
        LAST_RDATA      : out std_logic;
    -------------------------------------------------------------------------------
    -- DONE Status Bit Register Access Interface.
    -------------------------------------------------------------------------------
        DONE_WRITE      : in  std_logic;
        DONE_WDATA      : in  std_logic;
        DONE_RDATA      : out std_logic;
    -------------------------------------------------------------------------------
    -- ERROR Status Bit Register Access Interface.
    -------------------------------------------------------------------------------
        ERROR_WRITE     : in  std_logic;
        ERROR_WDATA     : in  std_logic;
        ERROR_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- MODE Register Access Interface.
    -------------------------------------------------------------------------------
        MODE_WRITE      : in  std_logic_vector(MODE_BITS-1 downto 0);
        MODE_WDATA      : in  std_logic_vector(MODE_BITS-1 downto 0);
        MODE_RDATA      : out std_logic_vector(MODE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- STAT Register Access Interface.
    -------------------------------------------------------------------------------
        STAT_WRITE      : in  std_logic_vector(STAT_BITS-1 downto 0);
        STAT_WDATA      : in  std_logic_vector(STAT_BITS-1 downto 0);
        STAT_RDATA      : out std_logic_vector(STAT_BITS-1 downto 0);
        STAT            : in  std_logic_vector(STAT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_VALID       : out std_logic;
        REQ_FIRST       : out std_logic;
        REQ_LAST        : out std_logic;
        REQ_READY       : in  std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Command Response Signals.
    -------------------------------------------------------------------------------
        ACK_VALID       : in  std_logic;
        ACK_ERROR       : in  std_logic;
        ACK_NEXT        : in  std_logic;
        ACK_LAST        : in  std_logic;
        ACK_STOP        : in  std_logic;
        ACK_NONE        : in  std_logic;
    -------------------------------------------------------------------------------
    -- Status.
    -------------------------------------------------------------------------------
        VALVE_OPEN      : out std_logic;
        XFER_RUNNING    : out std_logic;
        XFER_DONE       : out std_logic
    );
end PUMP_CONTROL_REGISTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of PUMP_CONTROL_REGISTER is
    -------------------------------------------------------------------------------
    -- Register Bits.
    -------------------------------------------------------------------------------
    signal   reset_bit          : std_logic;
    signal   start_bit          : std_logic;
    signal   stop_bit           : std_logic;
    signal   pause_bit          : std_logic;
    signal   first_bit          : std_logic;
    signal   last_bit           : std_logic;
    signal   done_bit           : std_logic;
    signal   error_bit          : std_logic;
    signal   mode_regs          : std_logic_vector(MODE_BITS-1 downto 0);
    signal   stat_regs          : std_logic_vector(STAT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- State Machine.
    -------------------------------------------------------------------------------
    type     STATE_TYPE     is  ( IDLE_STATE, REQ_STATE, ACK_STATE, TURN_AR, DONE_STATE);
    signal   curr_state         : STATE_TYPE;
    signal   first_state        : std_logic_vector(1 downto 0);
    signal   flag_clear         : boolean;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
    begin
        if    (RST = '1') then
                curr_state  <= IDLE_STATE;
                first_state <= "00";
                reset_bit   <= '0';
                start_bit   <= '0';
                stop_bit    <= '0';
                pause_bit   <= '0';
                first_bit   <= '0';
                last_bit    <= '0';
                done_bit    <= '0';
                error_bit   <= '0';
                mode_regs   <= (others => '0');
                stat_regs   <= (others => '0');
                flag_clear  <= TRUE;
        elsif (CLK'event and CLK = '1') then
            if (CLR   = '1') then
                curr_state  <= IDLE_STATE;
                first_state <= "00";
                reset_bit   <= '0';
                start_bit   <= '0';
                stop_bit    <= '0';
                pause_bit   <= '0';
                first_bit   <= '0';
                last_bit    <= '0';
                done_bit    <= '0';
                error_bit   <= '0';
                mode_regs   <= (others => '0');
                stat_regs   <= (others => '0');
                flag_clear  <= TRUE;
            else
                -------------------------------------------------------------------
                -- ステートマシン
                -------------------------------------------------------------------
                case curr_state is
                    when IDLE_STATE =>
                        if (start_bit = '1') then
                            next_state := REQ_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                    when REQ_STATE  =>
                        if    (REQ_READY = '0') then
                                next_state := REQ_STATE;
                        elsif (ACK_VALID = '1') then
                            if (ACK_NEXT = '1' or ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                                next_state := DONE_STATE;
                            else
                                next_state := TURN_AR;
                            end if;
                        else
                                next_state := ACK_STATE;
                        end if;
                    when ACK_STATE  =>
                        if (ACK_VALID = '1') then
                            if (ACK_NEXT = '1' or ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                                next_state := DONE_STATE;
                            else
                                next_state := TURN_AR;
                            end if;
                        else
                                next_state := ACK_STATE;
                        end if;
                    when TURN_AR    =>
                                next_state := REQ_STATE;
                    when DONE_STATE =>
                                next_state := IDLE_STATE;
                    when others =>
                                next_state := IDLE_STATE;
                end case;
                if (reset_bit = '1') then
                    curr_state <= IDLE_STATE;
                else
                    curr_state <= next_state;
                end if;
                -------------------------------------------------------------------
                -- flag_clear  : 
                -------------------------------------------------------------------
                flag_clear <= (next_state = DONE_STATE) and 
                              (ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1');
                -------------------------------------------------------------------
                -- first_state : REQ_FIRST(最初の転送要求信号)を作るためのステートマシン.
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                        first_state <= "00";
                elsif (first_state = "00") then
                    if (curr_state = IDLE_STATE and start_bit = '1' and first_bit = '1') then
                        first_state <= "11";
                    else
                        first_state <= "00";
                    end if;
                elsif (ACK_VALID = '1') then
                    if (ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                        first_state <= "00";
                    else
                        first_state <= "10";
                    end if;
                end if;
                -------------------------------------------------------------------
                -- RESET BIT   :
                -------------------------------------------------------------------
                if    (RESET_WRITE = '1') then
                    reset_bit <= RESET_WDATA;
                end if;
                -------------------------------------------------------------------
                -- START BIT   :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    start_bit <= '0';
                elsif (START_WRITE = '1' and START_WDATA = '1') then
                    start_bit <= '1';
                elsif (next_state = DONE_STATE) then
                    start_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- STOP BIT    :
                -------------------------------------------------------------------
                if    (STOP_WRITE  = '1' and STOP_WDATA  = '1') then
                    stop_bit  <= '1';
                elsif (next_state = DONE_STATE) then
                    stop_bit  <= '0';
                end if;
                -------------------------------------------------------------------
                -- PAUSE BIT   :
                -------------------------------------------------------------------
                if    (PAUSE_WRITE = '1') then
                    pause_bit <= PAUSE_WDATA;
                end if;
                -------------------------------------------------------------------
                -- FIRST BIT   :
                -------------------------------------------------------------------
                if    (FIRST_WRITE = '1') then
                    first_bit <= FIRST_WDATA;
                end if;
                -------------------------------------------------------------------
                -- LAST BIT    :
                -------------------------------------------------------------------
                if    (LAST_WRITE  = '1') then
                    last_bit  <= LAST_WDATA;
                end if;
                -------------------------------------------------------------------
                -- DONE BIT    :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    done_bit  <= '0';
                elsif (next_state = DONE_STATE) then
                    done_bit  <= '1';
                elsif (DONE_WRITE  = '1' and DONE_WDATA  = '0') then
                    done_bit  <= '0';
                end if;
                -------------------------------------------------------------------
                -- ERROR BIT   :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    error_bit <= '0';
                elsif (next_state = DONE_STATE and ACK_ERROR = '1') then
                    error_bit <= '1';
                elsif (ERROR_WRITE = '1' and ERROR_WDATA = '0') then
                    error_bit  <= '0';
                end if;
                -------------------------------------------------------------------
                -- MODE REGISTER
                -------------------------------------------------------------------
                if (reset_bit = '1') then
                    mode_regs <= (others => '0');
                else
                    for i in mode_regs'range loop
                        if (MODE_WRITE(i) = '1') then
                            mode_regs(i) <= MODE_WDATA(i);
                        end if;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- STATUS REGISTER
                -------------------------------------------------------------------
                if (reset_bit = '1') then
                    stat_regs <= (others => '0');
                else
                    for i in stat_regs'range loop
                        if    (STAT_WRITE(i) = '1' and STAT_WDATA(i) = '0') then
                            stat_regs(i) <= '0';
                        elsif (STAT(i) = '1') then
                            stat_regs(i) <= '1';
                        end if;
                    end loop;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- Register Output Signals.
    -------------------------------------------------------------------------------
    RESET_RDATA  <= reset_bit;
    START_RDATA  <= start_bit;
    STOP_RDATA   <= stop_bit;
    PAUSE_RDATA  <= pause_bit;
    FIRST_RDATA  <= first_bit;
    LAST_RDATA   <= last_bit;
    DONE_RDATA   <= done_bit;
    ERROR_RDATA  <= error_bit;
    MODE_RDATA   <= mode_regs;
    STAT_RDATA   <= stat_regs;
    -------------------------------------------------------------------------------
    -- Status
    -------------------------------------------------------------------------------
    XFER_RUNNING <= start_bit;
    XFER_DONE    <= '1' when (curr_state = DONE_STATE) else '0';
    VALVE_OPEN   <= first_state(1);
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
    REQ_VALID    <= '1' when (curr_state = REQ_STATE ) else '0';
    REQ_FIRST    <= first_state(0);
    REQ_LAST     <= last_bit;
end RTL;
