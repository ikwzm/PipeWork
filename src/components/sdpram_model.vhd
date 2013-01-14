-----------------------------------------------------------------------------------
--!     @file    sdpram_model.vhd
--!     @brief   Synchronous Dual Port RAM Model.
--!              デュアルポートメモリのモデル.
--!              実際にASIC/FPGAに実装する時は、このモジュールを
--!              ベンダーに依存したものに置き換える。
--!     @version 0.0.2
--!     @date    2012/8/1
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
use     ieee.numeric_std.all;
architecture MODEL of SDPRAM is
    signal   ram    : std_logic_vector(2**DEPTH-1 downto 0);
begin
    process (WCLK)
        variable w_ptr     : integer;
        variable w_be      : std_logic_vector(WDATA'range);
        constant W_BE_SIZE : integer := (2**WWIDTH)/(2**WEBIT);
    begin
        if (WCLK'event and WCLK = '1') then
            w_ptr := TO_INTEGER(unsigned(WADDR)) * (2**WWIDTH);
            for i in WE'range loop
                for n in 0 to W_BE_SIZE-1 loop
                    w_be(i*W_BE_SIZE + n) := WE(i);
                end loop;
            end loop;
            for i in WDATA'range loop
                if (w_be(i) = '1') then
                    ram(w_ptr+i) <= WDATA(i);
                end if;
            end loop;
        end if;
    end process;

    process (RCLK)
        variable r_ptr     : integer;
    begin
        if (RCLK'event and RCLK = '1') then
            r_ptr := TO_INTEGER(unsigned(RADDR)) * (2**RWIDTH);
            for i in RDATA'range loop
                RDATA(i) <= ram(r_ptr+i);
            end loop;
        end if;
    end process;

end MODEL;
