-----------------------------------------------------------------------------------
--!     @file    image_stream_atrb_generator.vhd
--!     @brief   Image Stream Attribute Generator
--!     @version 1.8.0
--!     @date    2019/1/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2019 Ichiro Kawazome
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
use     PIPEWORK.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   IMAGE_STREAM_ATRB_GENERATOR :
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_ATRB_GENERATOR is
    generic (
        ATRB_SIZE       : --! @brief ATTRIBUTE VECTOR SIZE :
                          integer := 1;
        STRIDE          : --! @brief STRIDE SIZE SIZE :
                          integer := 1;
        MAX_SIZE        : --! @brief MAX SIZE :
                          integer := 8;
        MAX_START_BORDER: --! @brief MAX START BORDER SIZE :
                          integer := 0;
        MAX_LAST_BORDER : --! @brief MAX LAST  BORDER SIZE :
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
        LOAD            : --! @brief LOAD :
                          in  std_logic;
        CHOP            : --! @brief COUNT ENABLE :
                          in  std_logic;
        SIZE            : --! @brief SIZE :
                          in  integer range 0 to MAX_SIZE;
        START_BORDER    : --! @brief START BORDER SIZE :
                          in  integer range 0 to MAX_START_BORDER := 0;
        LAST_BORDER     : --! @brief LAST  BORDER SIZE :
                          in  integer range 0 to MAX_LAST_BORDER  := 0;
    -------------------------------------------------------------------------------
    -- 出力 I/F
    -------------------------------------------------------------------------------
        ATRB            : --! @brief OUTPUT ATTRIBUTE VECTOR:
                          --! 属性出力.
                          out IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
        START           : --! @brief OUTPUT START :
                          --! 現在の出力が最初の出力であることを示す.
                          out std_logic;
        LAST            : --! @brief OUTPUT LAST :
                          --! 現在の出力が最後の出力であることを示す.
                          out std_logic;
        TERM            : --! @brief OUTPUT TERMINATE :
                          --! 現在の最終位置が負になっていることを示す.
                          out std_logic;
        NEXT_ATRB       : --! @brief OUTPUT ATTRIBUTE VECTOR(NEXT CYCLE) :
                          --! 次のクロックでの属性出力.
                          out IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
        NEXT_START      : --! @brief OUTPUT START(NEXT CYCLE) :
                          --! 次のクロックでの出力が最初の出力であることを示す.
                          out std_logic;
        NEXT_LAST       : --! @brief OUTPUT LAST(NEXT_CYCLE) :
                          --! 次のクロックでの出力が最後の出力であることを示す.
                          out std_logic;
        NEXT_TERM       : --! @brief OUTPUT TERMINATE(NEXT_CYCLE) :
                          --! 次のクロックでの最終位置が負になっていることを示す.
                          out std_logic
    );
end IMAGE_STREAM_ATRB_GENERATOR;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
architecture RTL of IMAGE_STREAM_ATRB_GENERATOR is
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
    -- MAX_LAST_POS  : 最後の位置の取り得る値の最大値
    -------------------------------------------------------------------------------
    constant  MAX_LAST_POS          :  integer := MAX_SIZE+MAX_START_BORDER+MAX_LAST_BORDER-1;
    -------------------------------------------------------------------------------
    -- MAX_LAST_POS_BITS  : MAX_LAST_POS を表現するのに必要なビット数
    -------------------------------------------------------------------------------
    constant  MAX_LAST_POS_BITS     :  integer := MAX(1, CALC_BITS(MAX_SIZE+MAX_START_BORDER+MAX_LAST_BORDER-1));
    -------------------------------------------------------------------------------
    -- STRIDE_BITS        : STRIDE を表現するのに必要なビット数
    -------------------------------------------------------------------------------
    constant  STRIDE_BITS           :  integer := MAX(1, CALC_BITS(STRIDE));
    -------------------------------------------------------------------------------
    -- ATRB_POS_BITS : ATRB 配列の位置を表現するのに必要なビット数
    -------------------------------------------------------------------------------
    constant  ATRB_POS_BITS         :  integer := MAX(1, CALC_BITS(ATRB_SIZE-1));
    -------------------------------------------------------------------------------
    -- LAST_POS_BITS : curr_last_pos/next_last_pos を表現するのに必要なビット数
    --                 curr_last_pos/next_last_pos は signed 型なので１ビット多い
    -------------------------------------------------------------------------------
    constant  LAST_POS_BITS         :  integer := MAX(MAX_LAST_POS_BITS,
                                                      STRIDE_BITS      ,
                                                      ATRB_POS_BITS    )+1;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    curr_last_pos         :  signed(LAST_POS_BITS-1 downto 0);
    signal    next_last_pos         :  signed(LAST_POS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    curr_start_pos        :  integer range 0 to MAX_START_BORDER;
    signal    next_start_pos        :  integer range 0 to MAX_START_BORDER;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    curr_pos_term         :  std_logic;
    signal    next_pos_term         :  std_logic;
    signal    curr_pos_last         :  std_logic;
    signal    next_pos_last         :  std_logic;
    signal    curr_pos_start        :  std_logic;
    signal    next_pos_start        :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    curr_atrb_valid       :  std_logic_vector(0 to ATRB_SIZE-1);
    signal    next_atrb_valid       :  std_logic_vector(0 to ATRB_SIZE-1);
    signal    curr_atrb_start       :  std_logic_vector(0 to ATRB_SIZE-1);
    signal    next_atrb_start       :  std_logic_vector(0 to ATRB_SIZE-1);
    signal    curr_atrb_last        :  std_logic_vector(0 to ATRB_SIZE-1);
    signal    next_atrb_last        :  std_logic_vector(0 to ATRB_SIZE-1);
begin
    -------------------------------------------------------------------------------
    -- curr_start_pos  :
    -- next_start_pos  :
    -- next_atrb_start :
    -------------------------------------------------------------------------------
    START_BORDER_GT_0: if MAX_START_BORDER > 0 generate
        ---------------------------------------------------------------------------
        -- next_start_pos  :
        -- next_atrb_start :
        ---------------------------------------------------------------------------
        process(LOAD, START_BORDER, CHOP, curr_start_pos, curr_atrb_start) begin
            if    (LOAD = '1') then
                next_start_pos <= START_BORDER;
                for i in 0 to ATRB_SIZE-1 loop
                    if (i <= START_BORDER) then
                        next_atrb_start(i) <= '1';
                    else
                        next_atrb_start(i) <= '0';
                    end if;
                end loop;
            elsif (CHOP = '1') then
                if (curr_start_pos < STRIDE) then
                    next_start_pos <= 0;
                else
                    next_start_pos <= curr_start_pos - STRIDE;
                end if;
                for i in 0 to ATRB_SIZE-1 loop
                    if (i+STRIDE < ATRB_SIZE-1) then
                        next_atrb_start(i) <= curr_atrb_start(i+STRIDE);
                    else
                        next_atrb_start(i) <= '0';
                    end if;
                end loop;
            else
                next_start_pos  <= curr_start_pos  ;
                next_atrb_start <= curr_atrb_start;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- curr_start_pos
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_start_pos <= 0;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_start_pos <= 0;
                else
                    curr_start_pos <= next_start_pos;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- curr_start_pos  :
    -- next_start_pos  :
    -- next_atrb_start :
    -------------------------------------------------------------------------------
    START_BORDER_EQ_0: if MAX_START_BORDER = 0 generate
        curr_start_pos <= 0;
        next_start_pos <= 0;
        next_atrb_start <= (0 to 0 => '1', others => '0') when (LOAD = '1') else
                           (               others => '0') when (CHOP = '1') else
                           curr_atrb_start;
    end generate;
    -------------------------------------------------------------------------------
    -- next_pos_start : 次のクロックでの出力が最初の出力であることを示す信号
    -------------------------------------------------------------------------------
    next_pos_start <= '1' when (LOAD = '1') else
                      '0' when (CHOP = '1') else
                      curr_pos_start;
    -------------------------------------------------------------------------------
    -- next_last_pos : 次のクロックでの最終位置を示す信号
    -- next_pos_last : 次のクロックでの出力が最後の出力であることを示す信号
    -- next_pos_term : 次のクロックでの最終位置が負になっていることを示す信号
    -------------------------------------------------------------------------------
    process(LOAD, SIZE, START_BORDER, LAST_BORDER, CHOP, curr_last_pos)
        variable last_pos  :  signed(LAST_POS_BITS-1 downto 0);
    begin
        if    (LOAD = '1') then
            last_pos := to_01(to_signed(SIZE-1, LAST_POS_BITS));
            if (MAX_START_BORDER > 0) then
                last_pos := last_pos + START_BORDER;
            end if;
        elsif (CHOP = '1') then
            last_pos  := to_01(curr_last_pos) - STRIDE;
        else
            last_pos  := to_01(curr_last_pos);
        end if;
        next_last_pos <= last_pos;
        next_pos_term <= last_pos(last_pos'high);
        if (MAX_LAST_BORDER = 0 and last_pos             < ATRB_SIZE) or
           (MAX_LAST_BORDER > 0 and last_pos+LAST_BORDER < ATRB_SIZE) then
            next_pos_last <= '1';
        else
            next_pos_last <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- curr_last_pos  : 現在の最終位置を示すレジスタ
    -- curr_pos_term  : 現在の最終位置が負になっていることを示すレジスタ
    -- curr_pos_start : 現在の出力が最初であることを示すレジスタ
    -- curr_pos_last  : 現在の出力が最後であることを示すレジスタ
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_last_pos  <= (others => '0');
                curr_pos_term  <= '0';
                curr_pos_start <= '0';
                curr_pos_last  <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_last_pos  <= (others => '0');
                curr_pos_term  <= '0';
                curr_pos_start <= '0';
                curr_pos_last  <= '0';
            else
                curr_last_pos  <= next_last_pos;
                curr_pos_term  <= next_pos_term;
                curr_pos_start <= next_pos_start;
                curr_pos_last  <= next_pos_last;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- next_atrb_valid : 次のクロックでの ATRB.VALID の値
    -- next_atrb_last  : 次のクロックでの ATRB.LAST の値
    -------------------------------------------------------------------------------
    process (next_last_pos, next_start_pos, next_pos_term)
        variable next_last_pos_sv      :  std_logic_vector(next_last_pos'range);
        variable next_last_pos_hi      :  std_logic_vector(next_last_pos'high-1 downto ATRB_POS_BITS);
        variable next_last_pos_lo      :  unsigned        (ATRB_POS_BITS-1      downto 0);
        constant NEXT_LAST_POS_HI_ZERO :  std_logic_vector(next_last_pos_hi'range) := (others => '0');
    begin
        next_last_pos_sv := std_logic_vector(to_01(next_last_pos));
        next_last_pos_hi := std_logic_vector(next_last_pos_sv(next_last_pos_hi'range));
        next_last_pos_lo := unsigned(        next_last_pos_sv(next_last_pos_lo'range));
        if    (next_pos_term = '1') then
            next_atrb_valid <= (others => '0');
            next_atrb_last  <= (others => '1');
        elsif (next_last_pos_hi /= NEXT_LAST_POS_HI_ZERO) then
            next_atrb_valid <= (others => '1');
            next_atrb_last  <= (others => '0');
        else
            for i in 0 to ATRB_SIZE-1 loop
                if (i >= next_start_pos and i <= next_last_pos_lo) then
                    next_atrb_valid(i) <= '1';
                else
                    next_atrb_valid(i) <= '0';
                end if;
                if (i >= next_last_pos_lo) then
                    next_atrb_last (i) <= '1';
                else
                    next_atrb_last (i) <= '0';
                end if;
            end loop;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- curr_atrb_valid : 現在の ATRB.VALID の値
    -- curr_atrb_start : 現在の ATRB.START の値
    -- curr_atrb_last  : 現在の ATRB.LAST  の値
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_atrb_valid <= (others => '0');
                curr_atrb_start <= (others => '0');
                curr_atrb_last  <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_atrb_valid <= (others => '0');
                curr_atrb_start <= (others => '0');
                curr_atrb_last  <= (others => '0');
            else
                curr_atrb_valid <= next_atrb_valid;
                curr_atrb_start <= next_atrb_start;
                curr_atrb_last  <= next_atrb_last ;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- ATRB :
    -------------------------------------------------------------------------------
    process (curr_atrb_valid, curr_atrb_start, curr_atrb_last) begin
        for i in 0 to ATRB_SIZE-1 loop
            ATRB(i).VALID <= (curr_atrb_valid(i) = '1');
            ATRB(i).START <= (curr_atrb_start(i) = '1');
            ATRB(i).LAST  <= (curr_atrb_last (i) = '1');
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- NEXT_ATRB :
    -------------------------------------------------------------------------------
    process (next_atrb_valid, next_atrb_start, next_atrb_last) begin
        for i in 0 to ATRB_SIZE-1 loop
            NEXT_ATRB(i).VALID <= (next_atrb_valid(i) = '1');
            NEXT_ATRB(i).START <= (next_atrb_start(i) = '1');
            NEXT_ATRB(i).LAST  <= (next_atrb_last (i) = '1');
        end loop;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    START      <= curr_pos_start;
    NEXT_START <= next_pos_start;
    LAST       <= curr_pos_last;
    NEXT_LAST  <= next_pos_last;
    TERM       <= curr_pos_term;
    NEXT_TERM  <= next_pos_term;
end RTL;
