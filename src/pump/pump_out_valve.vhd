-----------------------------------------------------------------------------------
--!     @file    pump_out_valve.vhd
--!     @brief   PUMP OUT VALVE
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
--! @brief   PUMP OUT VALVE :
-----------------------------------------------------------------------------------
entity  PUMP_OUT_VALVE is
    generic (
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! 内部カウンタのビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! サイズ信号のビット数を指定する.
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
    -- Control Signals.
    -------------------------------------------------------------------------------
        THRESHOLD_SIZE  : in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_OPEN          : in  std_logic;
        O_OPEN          : in  std_logic;
        RESET           : in  std_logic;
        PAUSE           : in  std_logic;
        STOP            : in  std_logic;
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VAL        : in  std_logic;
        PUSH_LAST       : in  std_logic;
        PUSH_SIZE       : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VAL        : in  std_logic;
        PULL_LAST       : in  std_logic;
        PULL_SIZE       : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Input Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_PAUSE      : out std_logic;
        FLOW_STOP       : out std_logic;
        FLOW_LAST       : out std_logic;
        FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_NEG        : out std_logic;
        PAUSED          : out std_logic
    );
end PUMP_OUT_VALVE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of PUMP_OUT_VALVE is
    signal   flow_counter       : unsigned(COUNT_BITS-1 downto 0);
    signal   flow_negative      : boolean;
    signal   flow_positive      : boolean;
    signal   flow_zero          : boolean;
    signal   io_open            : boolean;
    signal   io_last            : boolean;
begin
    process (CLK, RST)
        variable next_counter : unsigned(COUNT_BITS downto 0);
    begin
        if    (RST = '1') then
                flow_counter  <= (others => '0');
                flow_positive <= FALSE;
                flow_negative <= FALSE;
                flow_zero     <= TRUE;
                io_open       <= FALSE;
                io_last       <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if (CLR   = '1' or RESET = '1') then
                flow_counter  <= (others => '0');
                flow_positive <= FALSE;
                flow_negative <= FALSE;
                flow_zero     <= TRUE;
                io_open       <= FALSE;
                io_last       <= FALSE;
            else
                if (io_open) then
                    next_counter := "0" & flow_counter;
                    if (PUSH_VAL = '1') then
                        next_counter := next_counter + resize(unsigned(PUSH_SIZE),next_counter'length);
                    end if;
                    if (PULL_VAL = '1') then
                        next_counter := next_counter - resize(unsigned(PULL_SIZE),next_counter'length);
                    end if;
                else
                    next_counter := (others => '0');
                end if;
                if    (next_counter(next_counter'high) = '1') then
                    flow_positive <= FALSE;
                    flow_negative <= TRUE;
                    flow_zero     <= FALSE;
                    next_counter  := (others => '0');
                elsif (next_counter > 0) then
                    flow_positive <= TRUE;
                    flow_negative <= FALSE;
                    flow_zero     <= FALSE;
                else
                    flow_positive <= FALSE;
                    flow_negative <= FALSE;
                    flow_zero     <= TRUE;
                end if;
                flow_counter <= next_counter(flow_counter'range);
                if    (io_open = FALSE and I_OPEN = '1' and O_OPEN = '1') then
                    io_open <= TRUE;
                elsif (io_open = TRUE  and I_OPEN = '0' and O_OPEN = '0') then
                    io_open <= FALSE;
                end if;
                if (io_open = FALSE) then
                    io_last <= FALSE;
                elsif (PUSH_VAL = '1' and PUSH_LAST = '1') then
                    io_last <= TRUE;
                end if;
            end if;
        end if;
    end process;
    FLOW_COUNT <= std_logic_vector(flow_counter);
    FLOW_NEG   <= '1' when (flow_negative) else '0';
    FLOW_STOP  <= '1' when (STOP  = '1') or
                           (io_last and flow_negative) else '0';
    FLOW_PAUSE <= '1' when (PAUSE = '1') or
                           (io_open = FALSE) or
                           (io_last = TRUE  and flow_zero) or
                           (io_last = FALSE and to_01(flow_counter) <  to_01(unsigned(THRESHOLD_SIZE))) else '0';
    PAUSED     <= '1' when (PAUSE = '1') or
                           (io_open = FALSE) or
                           (io_last = TRUE  and flow_zero) or
                           (io_last = FALSE and to_01(flow_counter) <  to_01(unsigned(THRESHOLD_SIZE))) else '0';
    FLOW_LAST  <= '1' when (io_last = TRUE  and to_01(flow_counter) <= to_01(unsigned(THRESHOLD_SIZE))) else '0';
    FLOW_SIZE  <= std_logic_vector(flow_counter);
end RTL;
