-----------------------------------------------------------------------------------
--!     @file    unrolled_loop_counter.vhd
--!     @brief   Unrolled Loop Counter Module
--!     @version 1.7.1
--!     @date    2018/12/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018 Ichiro Kawazome
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
--! @brief   Unroll Loop Counter Module :
--           * このモジュールはループカウンタの最大値(SIZE)とインクリメント(STRIDE)
--             を与えて、次のような各種ループの状態を出力する.
--             - LOOP_DONE : ループが終了"する"ことを示す.
--             - LOOP_BUSY : ループ実行中であることを示す.
--             - LOOP_FIRST: ループの最初であることを示す.
--             - LOOP_LAST : ループの最後であることを示す.
--             - LOOP_TERM : ループが終了"した"ことを示す.
--           * 次の記述のループを実行するようなもの
--             for (i = 0; i < MAX_SIZE; i += STRIDE) {}
--           * UNROLL に 2以上を指定すると、次のようなループになる
--             for (i = 0; i < MAX_SIZE/UNROLL; i += (STRIDE*UNROLL)) {}
-----------------------------------------------------------------------------------
entity  UNROLLED_LOOP_COUNTER is
    generic (
        STRIDE          : --! @brief STRIDE SIZE :
                          --! １回のループで加算する値を指定.
                          integer := 1;
        UNROLL          : --! @brief UNROLL SIZE :
                          --! Unroll する数を指定する.
                          integer := 1;
        MAX_LOOP_SIZE   : --! @brief MAX LOOP SIZE :
                          --! ループ回数の最大値を指定する.
                          integer := 8;
        MAX_LOOP_INIT   : --! @brief MAX LOOP INIT SIZE :
                          --! Unroll 時の LOOP_VALID(ループ有効信号)のオフセット値
                          --! を指定する.
                          --! * ここで指定する値は UNROLL で指定した値未満でなけれ
                          --!   ばならない.
                          --! * ここでのオフセット値は、あくまでも Unroll 時の最初
                          --!   の端数分を指定していることに注意.
                          integer := 0
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
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
    -- 入力 I/F
    -------------------------------------------------------------------------------
        LOOP_START      : --! @brief LOOP START :
                          --! LOOP_SIZE と LOOP_INIT をロードしてループを開始するこ
                          --! とを指示する信号.
                          in  std_logic;
        LOOP_NEXT       : --! @brief COUNT ENABLE :
                          --! ループを一つ進めることを指定する信号.
                          in  std_logic;
        LOOP_SIZE       : --! @brief LOOP SIZE :
                          --! ループする回数を指定する.
                          in  integer range 0 to MAX_LOOP_SIZE;
        LOOP_INIT       : --! @brief UNROLL OFFSET SIZE :
                          --! ループカウンタの初期値を指定する.
                          in  integer range 0 to MAX_LOOP_INIT := 0;
    -------------------------------------------------------------------------------
    -- 出力 I/F
    -------------------------------------------------------------------------------
        LOOP_DONE       : --! @brief OUTPUT LOOP DONE :
                          --! ループ終了信号出力.
                          --! * ループが終了"する"ことを示す信号.
                          out std_logic;
        LOOP_BUSY       : --! @brief OUTPUT LOOP BUSY :
                          --! ループ実行信号出力.
                          --! * ループ中であることを示す信号.
                          out std_logic;
        LOOP_VALID      : --! @brief OUTPUT LOOP VALID VECTOR:
                          --! ループ有効信号出力.
                          --! * Unroll されたループのうち、有効な部分が '1' のセッ
                          --!   トされる.
                          out std_logic_vector(UNROLL-1 downto 0);
        LOOP_FIRST      : --! @brief OUTPUT LOOP FIRST :
                          --! ループの最初であることを示す出力信号.
                          out std_logic;
        LOOP_LAST       : --! @brief OUTPUT LOOP LAST :
                          --! ループの最後であることを示す出力信号.
                          out std_logic;
        LOOP_TERM       : --! @brief OUTPUT LOOP TERMINATE :
                          --! ループが終了したことを示す出力信号.
                          out std_logic;
        NEXT_BUSY       : --! @brief OUTPUT LOOP BUSY(NEXT_CYCLE) :
                          --! ループ実行信号出力.
                          --! * ループ中であることを示す信号.
                          out std_logic;
        NEXT_VALID      : --! @brief OUTPUT LOOP VALID VECTOR(NEXT CYCLE) :
                          --! 次のクロックでのループ有効信号出力.
                          --! * Unroll されたループのうち、有効な部分が '1' のセッ
                          --!   トされる.
                          out std_logic_vector(UNROLL-1 downto 0);
        NEXT_FIRST      : --! @brief OUTPUT LOOP FIRST(NEXT CYCLE) :
                          --! 次のクロックでループの最初であることを示す出力信号.
                          out std_logic;
        NEXT_LAST       : --! @brief OUTPUT LOOP LAST(NEXT_CYCLE) :
                          --! 次のクロックでループの最後になることを示す出力信号.
                          out std_logic;
        NEXT_TERM       : --! @brief OUTPUT LOOP TERMINATE(NEXT_CYCLE) :
                          --! 次のクロックでループが終了することを示す出力信号.
                          out std_logic
    );
end UNROLLED_LOOP_COUNTER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of UNROLLED_LOOP_COUNTER is
    -------------------------------------------------------------------------------
    -- CALC_BITS : 引数で指定された数を表現出来るビット数を計算する関数
    -------------------------------------------------------------------------------
    function  CALC_BITS(NUM:integer) return integer is
        variable bits : integer;
    begin
        bits := 0;
        while (2**bits <= NUM) loop
            bits := bits + 1;
        end loop;
        return bits;
    end function;
    -------------------------------------------------------------------------------
    -- MAX : 二つの引数を比較して大きい方を選択する関数
    -------------------------------------------------------------------------------
    function  MAX(A,B:integer) return integer is
    begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- MAX : 三つの引数を比較して大きい方を選択する関数
    -------------------------------------------------------------------------------
    function  MAX(A,B,C:integer) return integer is
    begin
        return MAX(MAX(A,B),C);
    end function;
    -------------------------------------------------------------------------------
    -- MAX_LAST_POS      : 最後の位置の取り得る値の最大値
    -------------------------------------------------------------------------------
    constant  MAX_LAST_POS          :  integer := MAX_LOOP_SIZE-1;
    -------------------------------------------------------------------------------
    -- MAX_LAST_POS_BITS : MAX_LAST_POS を表現するのに必要なビット数
    -------------------------------------------------------------------------------
    constant  MAX_LAST_POS_BITS     :  integer := MAX(1, CALC_BITS(MAX_LAST_POS));
    -------------------------------------------------------------------------------
    -- DECRIMENT_BITS    : STRIDE*UNROLL を表現するのに必要なビット数
    -------------------------------------------------------------------------------
    constant  DECRIMENT_BITS        :  integer := MAX(1, CALC_BITS(STRIDE*UNROLL));
    -------------------------------------------------------------------------------
    -- VALID_POS_BITS    : VALID 配列の位置を表現するのに必要なビット数
    -------------------------------------------------------------------------------
    constant  VALID_POS_BITS        :  integer := MAX(1, CALC_BITS(UNROLL-1));
    -------------------------------------------------------------------------------
    -- LAST_POS_BITS : curr_last_pos/next_last_pos を表現するのに必要なビット数
    --                 curr_last_pos/next_last_pos は signed 型なので１ビット多い
    -------------------------------------------------------------------------------
    constant  LAST_POS_BITS         :  integer := MAX(MAX_LAST_POS_BITS,
                                                      DECRIMENT_BITS   ,
                                                      VALID_POS_BITS   )+1;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    curr_last_pos         :  signed(LAST_POS_BITS-1 downto 0);
    signal    next_last_pos         :  signed(LAST_POS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    curr_first_pos        :  integer range 0 to MAX_LOOP_INIT;
    signal    next_first_pos        :  integer range 0 to MAX_LOOP_INIT;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    curr_loop_busy        :  std_logic;
    signal    next_loop_busy        :  std_logic;
    signal    curr_loop_term        :  std_logic;
    signal    next_loop_term        :  std_logic;
    signal    curr_loop_last        :  std_logic;
    signal    next_loop_last        :  std_logic;
    signal    curr_loop_first       :  std_logic;
    signal    next_loop_first       :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    curr_loop_valid       :  std_logic_vector(UNROLL-1 downto 0);
    signal    next_loop_valid       :  std_logic_vector(UNROLL-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    loop_done_by_term     :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- curr_first_pos  :
    -- next_first_pos  :
    -------------------------------------------------------------------------------
    MAX_INIT_GT_0: if MAX_LOOP_INIT > 0 generate
        ---------------------------------------------------------------------------
        -- next_first_pos  :
        ---------------------------------------------------------------------------
        process(LOOP_START, LOOP_INIT, LOOP_NEXT, curr_first_pos) begin
            if    (LOOP_START = '1') then
                    next_first_pos <= LOOP_INIT;
            elsif (LOOP_NEXT  = '1') then
                if (curr_first_pos < STRIDE*UNROLL) then
                    next_first_pos <= 0;
                else
                    next_first_pos <= curr_first_pos - (STRIDE*UNROLL);
                end if;
            else
                    next_first_pos <= curr_first_pos;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- curr_first_pos
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_first_pos <= 0;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_first_pos <= 0;
                else
                    curr_first_pos <= next_first_pos;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- curr_first_pos  :
    -- next_first_pos  :
    -------------------------------------------------------------------------------
    MAX_INIT_EQ_0: if MAX_LOOP_INIT = 0 generate
        curr_first_pos <= 0;
        next_first_pos <= 0;
    end generate;
    -------------------------------------------------------------------------------
    -- loop_done_by_term : SIZE=0 の時にループを終了するための信号.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                loop_done_by_term <= '0';
        elsif (CLK'event and CLK = '1') then
            if    (CLR = '1') then
                loop_done_by_term <= '0';
            elsif (LOOP_START = '1' and next_loop_term = '1') then
                loop_done_by_term <= '1';
            else
                loop_done_by_term <= '0';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- next_loop_busy  : 次のクロックでのループ中であることを示す信号.
    -------------------------------------------------------------------------------
    next_loop_busy  <= '1' when (LOOP_START = '1' and next_loop_term = '0') else
                       '0' when (LOOP_START = '1' and next_loop_term = '1') else
                       '1' when (LOOP_NEXT  = '1' and next_loop_term = '0') else
                       '0' when (LOOP_NEXT  = '1' and next_loop_term = '1') else
                       curr_loop_busy;
    -------------------------------------------------------------------------------
    -- next_loop_first : 次のクロックでの出力が最初のループであることを示す信号
    -------------------------------------------------------------------------------
    next_loop_first <= '1' when (LOOP_START = '1' and next_loop_term = '0') else
                       '0' when (LOOP_START = '1' and next_loop_term = '1') else
                       '0' when (LOOP_NEXT  = '1') else
                       curr_loop_first;
    -------------------------------------------------------------------------------
    -- next_last_pos   : 次のクロックでの最終位置を示す信号
    -- next_loop_last  : 次のクロックでループの最後になることを示す信号
    -- next_loop_term  : 次のクロックでループが終了することを示す信号.
    -------------------------------------------------------------------------------
    process(LOOP_START, LOOP_SIZE, LOOP_NEXT, curr_last_pos)
        variable last_pos  :  signed(LAST_POS_BITS-1 downto 0);
    begin
        if    (LOOP_START = '1') then
            last_pos := to_01(to_signed(LOOP_SIZE-1, LAST_POS_BITS));
        elsif (LOOP_NEXT  = '1') then
            last_pos := to_01(curr_last_pos) - (STRIDE*UNROLL);
        else
            last_pos := to_01(curr_last_pos);
        end if;
        next_last_pos  <= last_pos;
        next_loop_term <= last_pos(last_pos'high);
        if (last_pos < (STRIDE*UNROLL)) then
            next_loop_last <= '1';
        else
            next_loop_last <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- curr_last_pos   : 現在の最終位置を示すレジスタ
    -- curr_loop_busy  : ループ中であることを示すレジスタ
    -- curr_loop_term  : ループが終了したことを示すレジスタ
    -- curr_loop_first : ループの最初であることを示すレジスタ
    -- curr_loop_last  : ループの最後であることを示すレジスタ
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_last_pos   <= (others => '0');
                curr_loop_busy  <= '0';
                curr_loop_term  <= '0';
                curr_loop_first <= '0';
                curr_loop_last  <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_last_pos   <= (others => '0');
                curr_loop_busy  <= '0';
                curr_loop_term  <= '0';
                curr_loop_first <= '0';
                curr_loop_last  <= '0';
            else
                curr_last_pos   <= next_last_pos;
                curr_loop_busy  <= next_loop_busy;
                curr_loop_term  <= next_loop_term;
                curr_loop_first <= next_loop_first;
                curr_loop_last  <= next_loop_last;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- next_loop_valid : 次のクロックでの LOOP_VALID の値
    -------------------------------------------------------------------------------
    process (next_last_pos, next_first_pos, next_loop_term)
        variable next_last_pos_sv      :  std_logic_vector(next_last_pos'range);
        variable next_last_pos_hi      :  std_logic_vector(next_last_pos'high-1 downto VALID_POS_BITS);
        variable next_last_pos_lo      :  unsigned        (VALID_POS_BITS    -1 downto 0);
        constant NEXT_LAST_POS_HI_ZERO :  std_logic_vector(next_last_pos_hi'range) := (others => '0');
    begin
        next_last_pos_sv := std_logic_vector(to_01(next_last_pos));
        next_last_pos_hi := std_logic_vector(next_last_pos_sv(next_last_pos_hi'range));
        next_last_pos_lo := unsigned(        next_last_pos_sv(next_last_pos_lo'range));
        if    (next_loop_term = '1') then
            next_loop_valid <= (others => '0');
        elsif (next_last_pos_hi /= NEXT_LAST_POS_HI_ZERO) then
            next_loop_valid <= (others => '1');
        else
            for i in 0 to UNROLL-1 loop
                if (i >= next_first_pos and i <= next_last_pos_lo) then
                    next_loop_valid(i) <= '1';
                else
                    next_loop_valid(i) <= '0';
                end if;
            end loop;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- curr_loop_valid : 現在の LOOP_VALID の値
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_loop_valid <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_loop_valid <= (others => '0');
            else
                curr_loop_valid <= next_loop_valid;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    LOOP_DONE  <= '1' when (loop_done_by_term = '1') or
                           (curr_loop_busy = '1' and curr_loop_last = '1' and LOOP_NEXT = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    LOOP_BUSY  <= curr_loop_busy;
    NEXT_BUSY  <= next_loop_busy;
    LOOP_VALID <= curr_loop_valid;
    NEXT_VALID <= next_loop_valid;
    LOOP_FIRST <= curr_loop_first;
    NEXT_FIRST <= next_loop_first;
    LOOP_LAST  <= curr_loop_last;
    NEXT_LAST  <= next_loop_last;
    LOOP_TERM  <= curr_loop_term;
    NEXT_TERM  <= next_loop_term;
end RTL;
    
