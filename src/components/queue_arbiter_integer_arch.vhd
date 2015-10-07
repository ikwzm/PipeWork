-----------------------------------------------------------------------------------
--!     @file    queue_arbiter_integer_arch.vhd
--!     @brief   QUEUE ARBITER INTEGER ARCHITECTURE :
--!              キュータイプの調停回路のアーキテクチャ(整数デコード)
--!     @version 1.0.0
--!     @date    2012/8/11
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012 Ichiro Kawazome
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
--
-----------------------------------------------------------------------------------
architecture INTEGER_ARCH of QUEUE_ARBITER is
    type     REQUEST_VECTOR is array(integer range <>) of integer range MIN_NUM to MAX_NUM;
    constant QUEUE_TOP      :  integer := MIN_NUM;
    constant QUEUE_END      :  integer := MAX_NUM;
    signal   curr_queue     :  REQUEST_VECTOR  (QUEUE_TOP to QUEUE_END);
    signal   next_queue     :  REQUEST_VECTOR  (QUEUE_TOP to QUEUE_END);
    signal   curr_valid     :  std_logic_vector(QUEUE_TOP to QUEUE_END);
    signal   next_valid     :  std_logic_vector(QUEUE_TOP to QUEUE_END);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (ENABLE, REQUEST, curr_queue, curr_valid)
        variable req_enable :  std_logic_vector(MIN_NUM to MAX_NUM);
        variable req_num    :  integer   range  MIN_NUM to MAX_NUM ;
        variable req_new    :  boolean;
        variable temp_queue :  REQUEST_VECTOR  (QUEUE_TOP to QUEUE_END);
        variable temp_valid :  std_logic_vector(QUEUE_TOP to QUEUE_END);
        variable temp_num   :  integer   range  MIN_NUM to MAX_NUM ;
    begin
        --------------------------------------------------------------------------
        -- ENABLE信号がネゲートされている場合.
        --------------------------------------------------------------------------
        if    (ENABLE /= '1') then
                next_valid <= (others => '0');
                next_queue <= (others => MIN_NUM);
                VALID      <= '0';
                REQUEST_O  <= '0';
                GRANT_NUM  <= MIN_NUM;
                GRANT      <= (others => '0');
        --------------------------------------------------------------------------
        -- リクエスト信号が一つしかない場合は話は簡単だ.
        --------------------------------------------------------------------------
        elsif (MIN_NUM >= MAX_NUM) then
            if (REQUEST(MIN_NUM) = '1') then 
                next_valid <= (others => '0');
                next_queue <= (others => MIN_NUM);
                VALID      <= '1';
                REQUEST_O  <= '1';
                GRANT_NUM  <= MIN_NUM;
                GRANT      <= (others => '1');
            else
                next_valid <= (others => '0');
                next_queue <= (others => MIN_NUM);
                VALID      <= '0';
                REQUEST_O  <= '0';
                GRANT_NUM  <= MIN_NUM;
                GRANT      <= (others => '0');
            end if;
        --------------------------------------------------------------------------
        -- 複数のリクエスト信号がある場合は調停しなければならない.
        -- あたりまえだ. それがこの回路の本来の仕事だ.
        --------------------------------------------------------------------------
        else
            req_enable := (others => '1');
            for i in QUEUE_TOP to QUEUE_END loop
                if (curr_valid(i) = '1') then
                    for n in MIN_NUM to MAX_NUM loop
                        if (n = curr_queue(i)) then
                            req_enable(n) := '0';
                        end if;
                    end loop;
                    temp_valid(i) := '1';
                    temp_queue(i) := curr_queue(i);
                else
                    req_new := FALSE;
                    req_num := MIN_NUM;
                    for n in MIN_NUM to MAX_NUM loop
                        if (REQUEST(n) = '1' and req_enable(n) = '1') then
                            req_new       := TRUE;
                            req_num       := n;
                            req_enable(n) := '0';
                            exit;
                        end if;
                    end loop;
                    if (req_new) then
                        temp_valid(i) := '1';
                        temp_queue(i) := req_num;
                    else
                        temp_valid(i) := '0';
                        temp_queue(i) := MIN_NUM;
                    end if;
                end if;
            end loop;
            VALID      <= temp_valid(QUEUE_TOP);
            next_valid <= temp_valid;
            next_queue <= temp_queue;
            temp_num   := temp_queue(QUEUE_TOP);
            if (temp_valid(QUEUE_TOP) = '1' and REQUEST(temp_num) = '1') then
                REQUEST_O <= '1';
                GRANT_NUM <= temp_num;
                for i in GRANT'range loop
                    if (i = temp_num) then
                        GRANT(i) <= '1';
                    else
                        GRANT(i) <= '0';
                    end if;
                end loop;
            else
                REQUEST_O <= '0';
                GRANT_NUM <= temp_num;
                GRANT     <= (others => '0');
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if     (RST = '1') then
                curr_queue <= (others => MIN_NUM);
                curr_valid <= (others => '0');
        elsif  (CLK'event and CLK = '1') then
            if (CLR     = '1') or
               (ENABLE /= '1') then
                curr_queue <= (others => MIN_NUM);
                curr_valid <= (others => '0');
            elsif (SHIFT = '1') then
                for i in QUEUE_TOP to QUEUE_END loop
                    if (i < QUEUE_END) then
                        curr_queue(i) <= next_queue(i+1);
                        curr_valid(i) <= next_valid(i+1);
                    else
                        curr_queue(i) <= MIN_NUM;
                        curr_valid(i) <= '0';
                    end if;
                end loop;
            else
                curr_queue <= next_queue;
                curr_valid <= next_valid;
            end if;
        end if;
    end process;
end INTEGER_ARCH;
