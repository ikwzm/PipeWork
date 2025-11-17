-----------------------------------------------------------------------------------
--!     @file    axi4_traffic_monitor.vhd
--!     @brief   AXI4 Traffic Monitor
--!     @version 2.5.0
--!     @date    2025/11/17
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2025 Ichiro Kawazome
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
--! @brief   AXI4 Traffic Monitor
-----------------------------------------------------------------------------------
entity  AXI4_TRAFFIC_MONITOR is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        ENABLE          : --! @brief ENABLE :
                          --! モニターを行うか否かを指定.
                          --! * ENABLE=1 で有効. 出力レジスタに各種カウンタの値を出力.
                          --! * ENABLE=0 で無効. 出力レジスタにALL-0を出力.
                          integer range 0 to 1:= 1;
        COUNT_BITS      : --! @brief COUNT_BITS :
                          --! モニターカウンタのビット幅.
                          integer := 64;
        REGS_BITS       : --! @brief MONITOR REGISTER BITS :
                          --! モニター出力レジスタのビット幅.
                          integer := 64
    );
    port(
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- RESET Bit        : カウンタをリセットする.
    -------------------------------------------------------------------------------
    -- * RESET_L='1' and RESET_D='1' でリセット開始.
    -- * RESET_L='1' and RESET_D='0' でリセット解除.
    -- * RESET_Q は現在のリセット状態を返す.
    -- * RESET_Q='1' で現在リセット中であることを示す.
    -------------------------------------------------------------------------------
        RESET_L         : in  std_logic := '0';
        RESET_D         : in  std_logic := '0';
        RESET_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- START Bit        : モニターの開始を指示する.
    -------------------------------------------------------------------------------
    -- * START_L='1' and START_D='1' でモニター開始.
    -- * START_L='1' and START_D='0' の場合は無視される.
    -- * START_Q は現在の状態を返す.
    -- * START_Q='1' でモニター中であることを示す.
    -- * START_Q='0 'でモニターは行われていないことを示す.
    -------------------------------------------------------------------------------
        START_L         : in  std_logic := '0';
        START_D         : in  std_logic := '0';
        START_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- STOP Bit         : モニターの中止を指示する.
    -------------------------------------------------------------------------------
    -- * STOP_L='1' and STOP_D='1' でモニターの中止処理開始.
    -- * STOP_L='1' and STOP_D='0' の場合は無視される.
    -- * STOP_Q は現在の状態を返す.
    -- * STOP_Q='1' でモニターの中止処理中であることを示す.
    -- * STOP_Q='0' でモニターの中止処理が完了していることを示す.
    -------------------------------------------------------------------------------
        STOP_L          : in  std_logic := '0';
        STOP_D          : in  std_logic := '0';
        STOP_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- PAUSE Bit        : モニターの中断を指示する.
    -------------------------------------------------------------------------------
    -- * PAUSE_L='1' and PAUSE_D='1' でモニター中断.
    -- * PAUSE_L='1' and PAUSE_D='0' でモニター再開.
    -- * PAUSE_Q は現在中断中か否かを返す.
    -- * PAUSE_Q='1' で現在モニターを中断していることを示す.
    -- * PAUSE_Q='0' で現在モニターを再開していることを示す.
    -------------------------------------------------------------------------------
        PAUSE_L         : in  std_logic := '0';
        PAUSE_D         : in  std_logic := '0';
        PAUSE_Q         : out std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Address Channel Signals.
    ------------------------------------------------------------------------------
        AVALID          : --! @brief Address Valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read/write address and control infomation.
                          in    std_logic;
        AREADY          : --! @brief Address Ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Data Channel Signals.
    ------------------------------------------------------------------------------
        DVALID          : --! @brief data valid.
                          --! This signal indicates that the channel is signaling
                          --! the required read/write data.
                          in    std_logic;
        DREADY          : --! @brief data ready.
                          --! This signal indicates that the master can accept the
                          --! read/write data and response information.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- Monitor Output Registers.
    ------------------------------------------------------------------------------
        TOTAL_REGS      : --! @brief Monitor Total Count.
                          out   std_logic_vector(REGS_BITS-1 downto 0);
        ADDR_REGS       : --! @brief Monitor Address Valid and Ready Count.
                          out   std_logic_vector(REGS_BITS-1 downto 0);
        AVALID_REGS     : --! @brief Monitor Address Valid Count.
                          out   std_logic_vector(REGS_BITS-1 downto 0);
        AREADY_REGS     : --! @brief Monitor Address Ready Count.
                          out   std_logic_vector(REGS_BITS-1 downto 0);
        DATA_REGS       : --! @brief Monitor Data Valid and Ready Count.
                          out   std_logic_vector(REGS_BITS-1 downto 0);
        DVALID_REGS     : --! @brief Monitor Data Valid Count.
                          out   std_logic_vector(REGS_BITS-1 downto 0);
        DREADY_REGS     : --! @brief Monitor Data Ready Count.
                          out   std_logic_vector(REGS_BITS-1 downto 0)
    );
end AXI4_TRAFFIC_MONITOR;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of AXI4_TRAFFIC_MONITOR is
begin
    -------------------------------------------------------------------------------
    -- ENABLE = 1 : 
    -------------------------------------------------------------------------------
    ENABLE_EQ_1: if (ENABLE = 1) generate
        constant  limit_count   :  unsigned(COUNT_BITS-1 downto 0) := (others => '1');
        signal    total_count   :  unsigned(COUNT_BITS-1 downto 0);
        signal    addr_count    :  unsigned(COUNT_BITS-1 downto 0);
        signal    aval_count    :  unsigned(COUNT_BITS-1 downto 0);
        signal    ardy_count    :  unsigned(COUNT_BITS-1 downto 0);
        signal    data_count    :  unsigned(COUNT_BITS-1 downto 0);
        signal    dval_count    :  unsigned(COUNT_BITS-1 downto 0);
        signal    drdy_count    :  unsigned(COUNT_BITS-1 downto 0);
        signal    q_avalid      :  std_logic;
        signal    q_aready      :  std_logic;
        signal    q_dvalid      :  std_logic;
        signal    q_dready      :  std_logic;
        signal    count_reset   :  std_logic;
        signal    count_stop    :  std_logic;
        signal    count_enable  :  std_logic;
        signal    count_pause   :  std_logic;
        signal    start_regs    :  std_logic;
        signal    pause_regs    :  std_logic;
        function  to_regs(count: unsigned; BITS: integer) return std_logic_vector is
            variable regs : std_logic_vector(BITS-1 downto 0);
        begin
            for i in regs'range loop
                if (count'low <= i and i <= count'high) then
                    if (count(i) = '1') then
                        regs(i) := '1';
                    else
                        regs(i) := '0';
                    end if;
                else
                        regs(i) := '0';
                end if;
            end loop;
            return regs;
        end function;
    begin
        ---------------------------------------------------------------------------
        -- count_reset  : 
        ---------------------------------------------------------------------------
        count_reset <= '1' when (RESET_L = '1' and RESET_D = '1') else '0';
        RESET_Q     <= count_reset;
        ---------------------------------------------------------------------------
        -- count_stop   : 
        ---------------------------------------------------------------------------
        count_stop  <= '1' when (STOP_L  = '1' and STOP_D  = '1') else '0';
        STOP_Q      <= count_stop;
        ---------------------------------------------------------------------------
        -- count_enable : 
        -- start_regs   :
        ---------------------------------------------------------------------------
        count_enable <=  '0' when (count_reset = '1') else
                         '0' when (count_stop  = '1') else
                         '1' when (START_L = '1' and START_D = '1') else
                         '1' when (start_regs  = '1') else
                         '0';
        process (CLK, RST) begin 
            if (RST = '1') then
                    start_regs <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    start_regs <= '0';
                else
                    start_regs <= count_enable;
                end if;
            end if;
        end process;
        START_Q <= start_regs;
        ---------------------------------------------------------------------------
        -- count_pause  :
        -- pause_regs   :
        ---------------------------------------------------------------------------
        count_pause  <= '0' when (count_reset = '1') else
                        '0' when (PAUSE_L = '1' and PAUSE_D = '0') else
                        '1' when (PAUSE_L = '1' and PAUSE_D = '1') else
                        '1' when (pause_regs = '1') else
                        '0';
        process (CLK, RST) begin 
            if (RST = '1') then
                    pause_regs <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    pause_regs <= '0';
                else
                    pause_regs <= count_pause;
                end if;
            end if;
        end process;
        PAUSE_Q <= pause_regs;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (CLK, RST) begin 
            if (RST = '1') then
                    q_avalid <= '0';
                    q_aready <= '0';
                    q_dvalid <= '0';
                    q_dready <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    q_avalid <= '0';
                    q_aready <= '0';
                    q_dvalid <= '0';
                    q_dready <= '0';
                else
                    q_avalid <= AVALID;
                    q_aready <= AREADY;
                    q_dvalid <= DVALID;
                    q_dready <= DREADY;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (CLK, RST) begin 
            if (RST = '1') then
                    total_count <= (others => '0');
                    addr_count  <= (others => '0');
                    aval_count  <= (others => '0');
                    ardy_count  <= (others => '0');
                    data_count  <= (others => '0');
                    dval_count  <= (others => '0');
                    drdy_count  <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1') or
                      (count_reset = '1') then
                    total_count <= (others => '0');
                    addr_count  <= (others => '0');
                    aval_count  <= (others => '0');
                    ardy_count  <= (others => '0');
                    data_count  <= (others => '0');
                    dval_count  <= (others => '0');
                    drdy_count  <= (others => '0');
                elsif (count_enable = '1') and
                      (count_pause  = '0') and 
                      (total_count < limit_count) then
                    total_count <= total_count + 1;
                    if (q_avalid = '1' and q_aready = '1') then
                        addr_count <= addr_count + 1;
                    end if;
                    if (q_avalid = '1') then
                        aval_count <= aval_count + 1;
                    end if;
                    if (q_aready = '1') then
                        ardy_count <= ardy_count + 1;
                    end if;
                    if (q_dvalid = '1' and q_dready = '1') then
                        data_count <= data_count + 1;
                    end if;
                    if (q_dvalid = '1') then
                        dval_count <= dval_count + 1;
                    end if;
                    if (q_dready = '1') then
                        drdy_count <= drdy_count + 1;
                    end if;
                end if;
            end if;
        end process;
        TOTAL_REGS  <= to_regs(total_count, REGS_BITS);
        ADDR_REGS   <= to_regs(addr_count , REGS_BITS);
        AVALID_REGS <= to_regs(aval_count , REGS_BITS);
        AREADY_REGS <= to_regs(ardy_count , REGS_BITS);
        DATA_REGS   <= to_regs(data_count , REGS_BITS);
        DVALID_REGS <= to_regs(dval_count , REGS_BITS);
        DREADY_REGS <= to_regs(drdy_count , REGS_BITS);
    end generate;
    -------------------------------------------------------------------------------
    -- ENABLE = 0 : 
    -------------------------------------------------------------------------------
    ENABLE_EQ_0: if (ENABLE = 0) generate
        RESET_Q     <= '0';
        START_Q     <= '0';
        STOP_Q      <= '0';
        PAUSE_Q     <= '0';
        TOTAL_REGS  <= (others => '0');
        ADDR_REGS   <= (others => '0');
        AVALID_REGS <= (others => '0');
        AREADY_REGS <= (others => '0');
        DATA_REGS   <= (others => '0');
        DVALID_REGS <= (others => '0');
        DREADY_REGS <= (others => '0');
    end generate;
end RTL;
