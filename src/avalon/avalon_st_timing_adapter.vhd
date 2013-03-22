-----------------------------------------------------------------------------------
--!     @file    avalon_st_timing_adapter.vhd
--!     @brief   Avalon-ST Timing Adapter Module :
--!     @version 0.0.2
--!     @date    2013/3/7
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
--! @brief   Avalon-ST Timing Adapter
-----------------------------------------------------------------------------------
entity  Avalon_ST_Timing_Adapter is
    generic (
        DATA_BITS   : integer := 8;
        I_LATENCY   : integer := 0;
        O_LATENCY   : integer := 0
    );
    port (
        CLK         : in  std_logic; 
        RST         : in  std_logic;
        CLR         : in  std_logic;
        I_DATA      : in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : in  std_logic;
        I_RDY       : out std_logic;
        O_DATA      : out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : out std_logic;
        O_RDY       : in  std_logic
    );
end Avalon_ST_Timing_Adapter;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.QUEUE_REGISTER;
architecture RTL of Avalon_ST_Timing_Adapter is
    signal t_valid : std_logic;
    signal t_ready : std_logic;
begin
    I_LATENCY_EQ_0: if (I_LATENCY = 0) generate
        I_RDY    <= t_ready;
        O_DATA   <= I_DATA;
        t_valid  <= I_VAL;
    end generate;
    I_LATENCY_GT_0: if (I_LATENCY > 0) generate
        constant QUEUE_SIZE : integer := I_LATENCY+1;
        signal   i_valid    : std_logic;
        signal   q_data     : std_logic_vector(DATA_BITS-1 downto 0);
        signal   q_valid    : std_logic_vector(QUEUE_SIZE  downto 0);
    begin
        REGS: QUEUE_REGISTER
            generic map (
                QUEUE_SIZE => QUEUE_SIZE ,
                DATA_BITS  => DATA_BITS  ,
                LOWPOWER   => 0
            )
            port map (
                CLK        => CLK        ,
                RST        => RST        ,
                CLR        => CLR        ,
                I_DATA     => I_DATA     ,
                I_VAL      => i_valid    ,
                I_RDY      => open       ,
                O_DATA     => open       ,
                O_VAL      => open       ,
                Q_DATA     => q_data     ,
                Q_VAL      => q_valid    ,
                Q_RDY      => t_ready
            );
        I_RDY    <= '1'    when (q_valid(0) = '0') else '0';
        O_DATA   <= q_data when (q_valid(0) = '1') else I_DATA;
        t_valid  <= '1'    when (q_valid(0) = '1') else I_VAL;
        i_valid  <= '1'    when (I_VAL = '1' and t_ready    = '0') or
                                (I_VAL = '1' and q_valid(0) = '1') else '0';
    end generate;
    O_LATENCY_EQ_0: if (O_LATENCY = 0) generate
        t_ready <= O_RDY;
        O_VAL   <= t_valid and t_ready;
    end generate;
    O_LATENCY_GT_0: if (O_LATENCY > 0) generate
        signal d_ready : std_logic_vector(1 to O_LATENCY);
    begin 
        process (CLK, RST) begin
            if (RST = '1') then
                    d_ready <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    d_ready <= (others => '0');
                else
                    for i in d_ready'range loop
                        if (i = d_ready'low) then
                            d_ready(i) <= O_RDY;
                        else
                            d_ready(i) <= d_ready(i-1);
                        end if;
                    end loop;
                end if;
            end if;
        end process;
        t_ready <= d_ready(O_LATENCY);
        O_VAL   <= t_valid and t_ready;
    end generate;
end RTL;
