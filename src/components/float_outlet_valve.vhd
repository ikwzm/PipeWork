-----------------------------------------------------------------------------------
--!     @file    float_outlet_valve.vhd
--!     @brief   FLOAT OUTLET VALVE
--!     @version 1.5.4
--!     @date    2014/2/20
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
-----------------------------------------------------------------------------------
--! @brief   FLOAT OUTLET VALVE :
-----------------------------------------------------------------------------------
entity  FLOAT_OUTLET_VALVE is
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
                          in  std_logic := '0';
        PAUSE           : --! @brief PAUSE REQUEST :
                          --! 強制的にフローを一時的に停止する事を指示する信号.
                          in  std_logic := '0';
        STOP            : --! @brief STOP  REQUEST :
                          --! 強制的にフローを中止する事を指示する信号.
                          in  std_logic := '0';
        INTAKE_OPEN     : --! @brief INTAKE VALVE OPEN FLAG :
                          --! 入力(INTAKE)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! 出力(OUTLET)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! * フローカウンタの値がこの値以上の時に出力を開始する.
                          --! * フローカウンタの値がこの値未満の時に出力を一時停止.
                          in  std_logic_vector(COUNT_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Flow Counter Load Signals.
    -------------------------------------------------------------------------------
        LOAD            : --! @breif LOAD FLOW COUNTER :
                          --! フローカウンタに値をロードする事を指示する信号.
                          in  std_logic := '0';
        LOAD_COUNT      : --! @brief LOAD FLOW COUNTER VALUE :
                          --! LOAD='1'にフローカウンタにロードする値.
                          in  std_logic_vector(COUNT_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VALID      : --! @brief PUSH VALID :
                          --! PUSH_LAST/PUSH_SIZEが有効であることを示す信号.
                          in  std_logic := '0';
        PUSH_LAST       : --! @brief PUSH LAST :
                          --! 最後の入力であることを示す信号.
                          in  std_logic := '0';
        PUSH_SIZE       : --! @brief PUSH SIZE :
                          --! 入力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VALID      : --! @brief PULL VALID :
                          --! PULL_LAST/PULL_SIZEが有効であることを示す信号.
                          in  std_logic := '0';
        PULL_LAST       : --! @brief PULL LAST :
                          --! 最後の出力であることを示す信号.
                          in  std_logic := '0';
        PULL_SIZE       : --! @brief PULL SIZE :
                          --! 出力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW OUTLET READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY='1' : 再開.
                          --! * FLOW_READY='0' : 一時停止.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以上の時に
                          --!   '1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 未満の時に
                          --!   '0'を出力する.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW OUTLET PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE='0' : 再開.
                          --! * FLOW_PAUSE='1' : 一時停止.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以上の時に
                          --!   '0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 未満の時に
                          --!   '1'を出力する.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW OUTLET STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_STOP='1' : 中止を指示.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW OUTLET LAST :
                          --! 入力側から最後の入力を示すフラグがあったことを示す.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW OUTLET ENABLE SIZE :
                          --! 出力可能なバイト数
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter Signals.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! 現在のフローカウンタの値を出力.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_ZERO       : --! @brief FLOW COUNTER is ZERO :
                          --! フローカウンタの値が0になったことを示すフラグ.
                          out std_logic;
        FLOW_POS        : --! @brief FLOW COUNTER is POSitive :
                          --! フローカウンタの値が正(>0)になったことを示すフラグ.
                          out std_logic;
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! フローカウンタの値が負(<0)になったことを示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic
    );
end FLOAT_OUTLET_VALVE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of FLOAT_OUTLET_VALVE is
    signal   flow_counter       : unsigned(COUNT_BITS-1 downto 0);
    signal   flow_negative      : boolean;
    signal   flow_positive      : boolean;
    signal   flow_eq_zero       : boolean;
    signal   io_open_req        : boolean;
    signal   io_open            : boolean;
    signal   io_last            : boolean;
    signal   pause_flag         : boolean;
    signal   last_flag          : boolean;
begin
    -------------------------------------------------------------------------------
    -- io_open : 入力側のバルブと出力側のバルブが開いていることを示すフラグ.
    --           入力側のバルブと出力側のバルブが双方とも開いた時点でアサート.
    --           入力側のバルブと出力側のバルブが双方とも閉じた時点でネゲート.
    -------------------------------------------------------------------------------
    io_open_req <= TRUE  when (io_open = FALSE and INTAKE_OPEN = '1' and OUTLET_OPEN = '1') else
                   FALSE when (io_open = TRUE  and INTAKE_OPEN = '0' and OUTLET_OPEN = '0') else
                   io_open;
    process (CLK, RST) begin
        if    (RST = '1') then
                io_open <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if    (CLR   = '1' or RESET = '1') then
                io_open <= FALSE;
            else
                io_open <= io_open_req;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- io_last : I_LAST(入力側からの最後の入力だったことを示すフラグ)を、
    --           io_open=TRUE の間だけ保持するレジスタ.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if    (RST = '1') then
                io_last <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if    (CLR   = '1' or RESET = '1' or io_open_req = FALSE) then
                io_last <= FALSE;
            elsif (PUSH_VALID = '1' and PUSH_LAST = '1') then
                io_last <= TRUE;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- flow_counter  : 現在バッファに入っている(または入る予定)の量をカウント.
    -- flow_positive : フローカウンタの値が正(>0)になったことを示すフラグ.
    -- flow_negative : フローカウンタの値が負(<0)になったことを示すフラグ.
    -- flow_eq_zero  : フローカウンタの値が0になったことを示すフラグ.
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
                if (io_open_req) then
                    if (LOAD  = '1') then
                        next_counter := "0" & unsigned(LOAD_COUNT);
                    else
                        next_counter := "0" & flow_counter;
                    end if;
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
                           (io_last and flow_negative) else '0';
    -------------------------------------------------------------------------------
    -- FLOW_PAUSE : フローカウンタの状態で、転送を一時的に止めたり、再開することを
    --              指示する信号.
    -------------------------------------------------------------------------------
    pause_flag <= (PAUSE   = '1'  ) or
                  (io_open = FALSE) or
                  (io_last = TRUE  and flow_eq_zero) or
                  (io_last = FALSE and to_01(flow_counter) <  to_01(unsigned(FLOW_READY_LEVEL)));
    FLOW_READY <= '1' when (pause_flag = FALSE) else '0';
    FLOW_PAUSE <= '1' when (pause_flag = TRUE ) else '0';
    PAUSED     <= '1' when (pause_flag = TRUE ) else '0';
    -------------------------------------------------------------------------------
    -- FLOW_LAST  : 入力側から最後の入力を示すフラグがあったことを示す.
    --              ただし、flow_counter の値が FLOW_OPEN_LEVEL 以下である場合のみ、
    --              アサートされる.
    -------------------------------------------------------------------------------
    last_flag  <= (io_last = TRUE  and to_01(flow_counter) <= to_01(unsigned(FLOW_READY_LEVEL)));
    FLOW_LAST  <= '1' when (last_flag  = TRUE ) else '0';
    -------------------------------------------------------------------------------
    -- FLOW_SIZE  : 出力可能なバイト数(すなわちflow_counterの値)を出力.
    --              ただし、FLOW_SIZEのビット幅がflow_counterのビット幅に満たない
    --              場合は、最大でも 2**(FLOW_SIZE'high) 以下の値しか出力しない.
    -------------------------------------------------------------------------------
    process (flow_counter)
        constant MAX_FLOW_SIZE : integer := 2**(FLOW_SIZE'high);
    begin
        if (flow_counter'length > FLOW_SIZE'length) then
            if (flow_counter > MAX_FLOW_SIZE) then
                FLOW_SIZE <= std_logic_vector(to_unsigned(MAX_FLOW_SIZE, FLOW_SIZE'length));
            else
                FLOW_SIZE <= std_logic_vector(resize     (flow_counter , FLOW_SIZE'length));
            end if;
        else
                FLOW_SIZE <= std_logic_vector(resize     (flow_counter , FLOW_SIZE'length));
        end if;
    end process;
end RTL;
