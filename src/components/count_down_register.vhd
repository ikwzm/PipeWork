-----------------------------------------------------------------------------------
--!     @file    count_down_register.vhd
--!     @brief   COUNT DOWN REGISTER
--!              転送したバイト数をカウントダウンするレジスタ.
--!     @version 1.5.0
--!     @date    2013/4/2
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
--! @brief   COUNT DOWN REGISTER :
--!          データを転送したバイト数をカウントするレジスタ.
--!        * カウンタに指定されたサイズ分だけ減算する.
--!        * カウンタに指定されたサイズ分だけ減算した時にカウンタの値が負になりそう
--!          な場合は、カウンタの値は０になる. その際、NEGフラグをアサートする.
--!        * カウンタに直接、初期値を設定するためのレジスタアクセスインターフェース
--!          を持っている.
--!        * レジスタアクセスインターフェースからカウンタに書き込む時は COUNT_ENA
--!          信号が'0'でなければならない. '0'で無い場合は書き込みは無視される.
-----------------------------------------------------------------------------------
entity  COUNT_DOWN_REGISTER is
    generic (
        VALID       : --! @brief COUNTER VALID :
                      --! このカウンターを有効にするかどうかを指定する.
                      --! * VALID=0 : このカウンターは常に無効.
                      --! * VALID=1 : このカウンターは常に有効.
                      integer range 0 to 1 := 1;
        BITS        : --! @brief  COUNTER BITS :
                      --! カウンターのビット数を指定する.
                      --! * BIT=0の場合、このカウンターは常に無効になる.
                      integer := 32;
        REGS_BITS   : --! @brief REGISTER ACCESS INTERFACE BITS :
                      --! レジスタアクセスインターフェースのビット数を指定する.
                      integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK         : --! @brief CLOCK :
                      --! クロック信号
                      in  std_logic; 
        RST         : --! @brief ASYNCRONOUSE RESET :
                      --! 非同期リセット信号.アクティブハイ.
                      in  std_logic;
        CLR         : --! @brief SYNCRONOUSE RESET :
                      --! 同期リセット信号.アクティブハイ.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- レジスタアクセスインターフェース
    -------------------------------------------------------------------------------
        REGS_WEN    : --! @brief REGISTER WRITE ENABLE :
                      --! カウンタレジスタ書き込み制御信号.
                      --! * 書き込みを行うビットに'1'をセットする.  
                      --!   この信号に１がセットされたビットの位置に、REGS_DINの値
                      --!   がカウンタレジスタにセットされる.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_WDATA  : --! @brief REGISTER WRITE DATA :
                      --! カウンタレジスタ書き込みデータ.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_RDATA  : --! @brief REGISTER READ DATA :
                      --! カウンタレジスタ読み出しデータ.
                      out std_logic_vector(REGS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- カウントインターフェース
    -------------------------------------------------------------------------------
        DN_ENA      : --! @brief COUNT DOWN ENABLE :
                      --! カウントダウン許可信号.
                      --! * この信号が'1'の場合、DN_VAL信号およびDN_SIZE信号による
                      --!   カウントダウンが許可される.
                      --! * この信号が'1'の場合、REGS_WEN信号およびREGS_WDATA信号に
                      --!   よるレジスタ書き込みは無視される.
                      --! * この信号が'0'の場合、DN_VAL信号およびDN_SIZE信号による
                      --!   カウントダウンは無視される.
                      in  std_logic;
        DN_VAL      : --! @brief COUNT DOWN SIZE VALID :
                      --! カウントダウン有効信号.
                      --! * この信号が'1'の場合、DN_SIZEで指定された数だけカウンタ
                      --!   ーの値がアップする.
                      in  std_logic;
        DN_SIZE     : --! @brief COUNT DOWN SIZE :
                      --! カウントダウンサイズ信号.
                      in  std_logic_vector;
    -------------------------------------------------------------------------------
    -- カウンター出力
    -------------------------------------------------------------------------------
        COUNTER     : --! @brief COUNTER OUTPUT :
                      --! カウンタの値を出力.
                      out std_logic_vector;
        ZERO        : --! @brief COUNTER ZERO FLAG :
                      --! カウンタの値が0になったことを示すフラグ.
                      out std_logic;
        NEG         : --! @brief COUNTER ZERO FLAG :
                      --! カウンタの値が負になりそうだったことを示すフラグ.
                      --! * このフラグはDN_ENA信号が'1'の時のみ有効.
                      --! * このフラグはDN_ENA信号が'0'の時はクリアされる.
                      out std_logic
    );
end COUNT_DOWN_REGISTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of COUNT_DOWN_REGISTER is
begin
    COUNTER_ENABLE:if (BITS > 0 and VALID /= 0) generate
        signal count_regs : unsigned(BITS downto 0);
        signal count_zero : boolean;
        signal count_neg  : boolean;
    begin        
        process (CLK, RST)
            variable next_count : unsigned(BITS downto 0);
        begin
            if    (RST = '1') then 
                    count_regs <= (others => '0');
                    count_zero <= FALSE;
                    count_neg  <= FALSE;
            elsif (CLK'event and CLK = '1') then
                if (CLR   = '1') then
                    count_regs <= (others => '0');
                    count_zero <= FALSE;
                    count_neg  <= FALSE;
                else
                    if (DN_ENA = '0') then
                        for i in 0 to BITS-1 loop
                            if (i >= REGS_WEN'low and i <= REGS_WEN'high) then
                                if (REGS_WEN(i) = '1') then
                                    next_count(i) := REGS_WDATA(i);
                                else
                                    next_count(i) := count_regs(i);
                                end if;
                            else
                                    next_count(i) := count_regs(i);
                            end if;
                        end loop;
                        next_count(BITS) := '0';
                    elsif (DN_VAL = '1') then
                        next_count := count_regs - RESIZE(unsigned(DN_SIZE), BITS+1);
                    else
                        next_count := count_regs;
                    end if;
                    if (next_count(BITS) = '1') then
                        count_regs <= (others => '0');
                        count_neg  <= TRUE;
                        count_zero <= FALSE;
                    else
                        count_regs <= next_count;
                        count_neg  <= FALSE;
                        count_zero <= (next_count(BITS-1 downto 0) = 0);
                    end if;
                end if;
            end if;
        end process;
        REGS_RDATA <= std_logic_vector(RESIZE(count_regs, REGS_RDATA'length));
        COUNTER    <= std_logic_vector(RESIZE(count_regs, COUNTER   'length));
        ZERO       <= '1' when (count_zero) else '0';
        NEG        <= '1' when (count_neg ) else '0';
    end generate;
    COUNTER_DISABLE:if (BITS = 0 or VALID = 0) generate
        REGS_RDATA <= (REGS_RDATA'range => '0');
        COUNTER    <= (COUNTER   'range => '0');
        ZERO       <= '1';
        NEG        <= '0';
    end generate;
end RTL;
