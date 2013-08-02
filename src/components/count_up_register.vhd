-----------------------------------------------------------------------------------
--!     @file    count_up_register.vhd
--!     @brief   COUNT UP REGISTER
--!              転送したバイト数をカウントするレジスタ.
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
--! @brief   PUMP COUNT UP REGISTER :
--!          データを転送したバイト数をカウントするレジスタ.
--!        * カウンタに指定されたサイズ分だけ加算する.
--!        * カウンタに直接、初期値を設定するためのレジスタアクセスインターフェース
--!          を持っている.
--!        * レジスタアクセスインターフェースからカウンタに書き込む時は COUNT_ENA
--!          信号が'0'でなければならない. '0'で無い場合は書き込みは無視される.
-----------------------------------------------------------------------------------
entity  COUNT_UP_REGISTER is
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
        UP_ENA      : --! @brief COUNT UP ENABLE :
                      --! カウントアップ許可信号.
                      --! * この信号が'1'の場合、UP_VAL信号およびUP_SIZE信号による
                      --!   カウントアップが許可される.
                      --! * この信号が'1'の場合、REGS_WEN信号およびREGS_WDATA信号に
                      --!   よるレジスタ書き込みは無視される.
                      --! * この信号が'0'の場合、UP_VAL信号およびUP_SIZE信号による
                      --!   カウントアップは無視される.
                      in  std_logic;
        UP_VAL      : --! @brief COUNT UP SIZE VALID :
                      --! カウントアップ有効信号.
                      --! * この信号が'1'の場合、UP_SIZEで指定された数だけカウンタ
                      --!   ーの値がアップする.
                      in  std_logic;
        UP_BEN      : --! @brief COUNT UP BIT ENABLE :
                      --! カウントアップビット有効信号.
                      --! * この信号が'1'の位置のビットのみ、カウンタアップを有効に
                      --!   する.
                      in  std_logic_vector;
        UP_SIZE     : --! @brief COUNT UP SIZE :
                      --! カウントアップサイズ信号.
                      in  std_logic_vector;
    -------------------------------------------------------------------------------
    -- カウンター出力
    -------------------------------------------------------------------------------
        COUNTER     : --! @brief COUNTER OUTPUT :
                      --! カウンタの値を出力.
                      out std_logic_vector
    );
end COUNT_UP_REGISTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of COUNT_UP_REGISTER is
begin
    COUNTER_ENABLE:if (BITS > 0 and VALID /= 0) generate
        signal count_regs : unsigned(BITS-1 downto 0);
    begin        
        process (CLK, RST)
            variable next_count : unsigned(BITS-1 downto 0);
        begin
            if    (RST = '1') then 
                    count_regs <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR   = '1') then
                    count_regs <= (others => '0');
                elsif (UP_ENA = '0') then
                    for i in 0 to BITS-1 loop
                        if (i >= REGS_WEN'low and i <= REGS_WEN'high) then
                            if (REGS_WEN(i) = '1') then
                                count_regs(i) <= REGS_WDATA(i);
                            end if;
                        end if;
                    end loop;
                elsif (UP_VAL = '1') then
                    next_count := count_regs + RESIZE(unsigned(UP_SIZE),BITS);
                    for i in 0 to BITS-1 loop
                        if (i >= UP_BEN'low and i <= UP_BEN'high) then
                            if (UP_BEN(i) = '1') then
                                count_regs(i) <= next_count(i);
                            end if;
                        end if;
                    end loop;
                end if;
            end if;
        end process;
        REGS_RDATA <= std_logic_vector(RESIZE(count_regs, REGS_RDATA'length));
        COUNTER    <= std_logic_vector(RESIZE(count_regs, COUNTER   'length));
    end generate;
    COUNTER_DISABLE:if (BITS = 0 or VALID = 0) generate
        REGS_RDATA <= (REGS_RDATA'range => '0');
        COUNTER    <= (COUNTER   'range => '0');
    end generate;
end RTL;
