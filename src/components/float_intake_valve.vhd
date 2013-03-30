-----------------------------------------------------------------------------------
--!     @file    float_intake_valve.vhd
--!     @brief   FLOAT INTAKE VALVE
--!     @version 1.5.0
--!     @date    2013/3/31
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
--! @brief   FLOAT INTAKE VALVE :
-----------------------------------------------------------------------------------
entity  FLOAT_INTAKE_VALVE is
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
        RESET           : --! @brief RESET REQUEST :
                          --! 強制的に内部状態をリセットする事を指示する信号.
                          in  std_logic;
        PAUSE           : --! @brief PAUSE REQUEST :
                          --! 強制的にフローを一時的に停止する事を指示する信号.
                          in  std_logic;
        STOP            : --! @brief STOP  REQUEST :
                          --! 強制的にフローを中止する事を指示する信号.
                          in  std_logic;
        INTAKE_OPEN     : --! @brief INTAKE VALVE OPEN FLAG :
                          --! 入力(INTAKE)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! 出力(OUTLET)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        POOL_SIZE       : --! @brief POOL SIZE :
                          --! プールの大きさをバイト数で指定する.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以下の時に出力を開始する.
                          --! フローカウンタの値がこの値を越えた時に出力を一時停止.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VALID      : --! @brief PUSH VALID :
                          --! PUSH_LAST/PUSH_SIZEが有効であることを示す信号.
                          in  std_logic;
        PUSH_LAST       : --! @brief PUSH LAST :
                          --! 最後の入力であることを示す信号.
                          in  std_logic;
        PUSH_SIZE       : --! @brief PUSH SIZE :
                          --! 入力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VALID      : --! @brief PULL VALID :
                          --! PULL_LAST/PULL_SIZEが有効であることを示す信号.
                          in  std_logic;
        PULL_LAST       : --! @brief PULL LAST :
                          --! 最後の出力であることを示す信号.
                          in  std_logic;
        PULL_SIZE       : --! @brief PULL SIZE :
                          --! 出力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW INTAKE READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY=1 : 再開.
                          --! * FLOW_PAUSE=0 : 一時停止.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW INTAKE PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE=0 : 再開.
                          --! * FLOW_PAUSE=1 : 一時停止.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW INTAKE STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_PAUSE=1 : 中止.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW INTAKE LAST :
                          --! INTAKE側では未使用.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW INTAKE ENABLE SIZE :
                          --! 入力可能なバイト数
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter Signals.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! 現在のフローカウンタの値を出力.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_ZERO       : --! @brief FLOW COUNTER is ZERO :
                          --! 現在のフローカウンタの値が0になった事示すフラグ.
                          out std_logic;
        FLOW_POS        : --! @brief FLOW COUNTER is POSitive :
                          --! 現在のフローカウンタの値が正(>0)になった事示すフラグ.
                          out std_logic;
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! 現在のフローカウンタの値が負(<0)になった事示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic
    );
end FLOAT_INTAKE_VALVE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of FLOAT_INTAKE_VALVE is
    signal   flow_counter       : unsigned(COUNT_BITS-1 downto 0);
    signal   flow_negative      : boolean;
    signal   flow_positive      : boolean;
    signal   flow_eq_zero       : boolean;
    signal   io_open            : boolean;
    signal   pause_flag         : boolean;
begin
    -------------------------------------------------------------------------------
    -- io_open : 入力側のバルブと出力側のバルブが開いていることを示すフラグ.
    --           入力側のバルブと出力側のバルブが双方とも開いた時点でアサート.
    --           入力側のバルブと出力側のバルブが双方とも閉じた時点でネゲート.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if    (RST = '1') then
                io_open       <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if    (CLR   = '1' or RESET = '1') then
                io_open       <= FALSE;
            elsif (io_open = FALSE and INTAKE_OPEN = '1' and OUTLET_OPEN = '1') then
                io_open <= TRUE;
            elsif (io_open = TRUE  and INTAKE_OPEN = '0' and OUTLET_OPEN = '0') then
                io_open <= FALSE;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- flow_counter : 現在バッファに入っている(または入る予定)の量をカウント
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_counter : unsigned(COUNT_BITS downto 0);
    begin
        if    (RST = '1') then
                flow_counter  <= (others => '0');
                flow_positive <= FALSE;
                flow_negative <= FALSE;
                flow_eq_zero  <= TRUE;
        elsif (CLK'event and CLK = '1') then
            if (CLR   = '1' or RESET = '1') then
                flow_counter  <= (others => '0');
                flow_positive <= FALSE;
                flow_negative <= FALSE;
                flow_eq_zero  <= TRUE;
            else
                if (io_open) then
                    next_counter := "0" & flow_counter;
                    if (PUSH_VALID = '1') then
                        next_counter := next_counter + resize(unsigned(PUSH_SIZE),next_counter'length);
                    end if;
                    if (PULL_VALID = '1') then
                        next_counter := next_counter - resize(unsigned(PULL_SIZE),next_counter'length);
                    end if;
                else
                    next_counter := (others => '0');
                end if;
                if    (next_counter(next_counter'high) = '1') then
                    flow_positive <= FALSE;
                    flow_negative <= TRUE;
                    flow_eq_zero  <= FALSE;
                    next_counter  := (others => '0');
                elsif (next_counter > 0) then
                    flow_positive <= TRUE;
                    flow_negative <= FALSE;
                    flow_eq_zero  <= FALSE;
                else
                    flow_positive <= FALSE;
                    flow_negative <= FALSE;
                    flow_eq_zero  <= TRUE;
                end if;
                flow_counter <= next_counter(flow_counter'range);
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- FLOW_COUNT : flow_counter の値を出力.
    -------------------------------------------------------------------------------
    FLOW_COUNT <= std_logic_vector(flow_counter);
    FLOW_ZERO  <= '1' when (flow_eq_zero ) else '0';
    FLOW_POS   <= '1' when (flow_positive) else '0';
    FLOW_NEG   <= '1' when (flow_negative) else '0';
    -------------------------------------------------------------------------------
    -- FLOW_STOP  : 転送の中止を指示する信号.
    -------------------------------------------------------------------------------
    FLOW_STOP  <= '1' when (STOP  = '1') or
                           (io_open = TRUE  and INTAKE_OPEN = '1' and OUTLET_OPEN = '0') else '0';
    -------------------------------------------------------------------------------
    -- FLOW_PAUSE : フローカウンタの状態で、転送を一時的に止めたり、再開することを
    --              指示する信号.
    -------------------------------------------------------------------------------
    pause_flag <= (PAUSE   = '1'  ) or
                  (io_open = FALSE) or
                  (to_01(flow_counter) > to_01(unsigned(FLOW_READY_LEVEL)));
    FLOW_READY <= '1' when (pause_flag = FALSE) else '0';
    FLOW_PAUSE <= '1' when (pause_flag = TRUE ) else '0';
    PAUSED     <= '1' when (pause_flag = TRUE ) else '0';
    -------------------------------------------------------------------------------
    -- FLOW_LAST  : INTAKE側では未使用.
    -------------------------------------------------------------------------------
    FLOW_LAST  <= '0';
    -------------------------------------------------------------------------------
    -- FLOW_SIZE  : 入力可能なバイト数を出力.
    -------------------------------------------------------------------------------
    FLOW_SIZE  <= std_logic_vector(to_01(unsigned(POOL_SIZE)) - to_01(unsigned(FLOW_READY_LEVEL)));
end RTL;
