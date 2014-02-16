-----------------------------------------------------------------------------------
--!     @file    register_access_decoder.vhd
--!     @brief   REGISTER ACCESS DECODER MODULE :
--!              レジスタアクセスデコーダ.
--!     @version 1.5.4
--!     @date    2014/2/16
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2014 Ichiro Kawazome
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
--! @brief   REGISTER ACCESS DECODER MODULE 
-----------------------------------------------------------------------------------
entity  REGISTER_ACCESS_DECODER is
    generic (
        ADDR_WIDTH  : --! @brief REGISTER ADDRESS WIDTH :
                      --! レジスタアクセスインターフェースのアドレスのビット幅を指
                      --! 定する.
                      integer := 8;
        DATA_WIDTH  : --! @brief REGISTER DATA WIDTH :
                      --! レジスタアクセスインターフェースのデータのビット幅を指定
                      --! する.
                      integer := 32;
        WBIT_MIN    : --! @brief REGISTER WRITE BIT MIN INDEX :
                      integer := 0;
        WBIT_MAX    : --! @brief REGISTER WRITE BIT MAX INDEX :
                      integer := (2**8)*8-1;
        RBIT_MIN    : --! @brief REGISTER READ  BIT MIN INDEX :
                      integer := 0;
        RBIT_MAX    : --! @brief REGISTER READ  BIT MAX INDEX :
                      integer := (2**8)*8-1
    );
    port (
    -------------------------------------------------------------------------------
    -- 入力側のレジスタアクセスインターフェース
    -------------------------------------------------------------------------------
        REGS_REQ    : --! @brief REGISTER ACCESS REQUEST :
                      --! レジスタアクセス要求信号.
                      in  std_logic;
        REGS_WRITE  : --! @brief REGISTER WRITE ACCESS :
                      --! レジスタライトアクセス信号.
                      --! * この信号が'1'の時はライトアクセスを行う.
                      --! * この信号が'0'の時はリードアクセスを行う.
                      in  std_logic;
        REGS_ADDR   : --! @brief REGISTER ACCESS ADDRESS :
                      --! レジスタアクセスアドレス信号.
                      in  std_logic_vector(ADDR_WIDTH  -1 downto 0);
        REGS_BEN    : --! @brief REGISTER BYTE ENABLE :
                      --! レジスタアクセスバイトイネーブル信号.
                      in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
        REGS_WDATA  : --! @brief REGISTER ACCESS WRITE DATA :
                      --! レジスタアクセスライトデータ.
                      in  std_logic_vector(DATA_WIDTH  -1 downto 0);
        REGS_RDATA  : --! @brief REGISTER ACCESS READ DATA :
                      --! レジスタアクセスリードデータ.
                      out std_logic_vector(DATA_WIDTH  -1 downto 0);
        REGS_ACK    : --! @brief REGISTER ACCESS ACKNOWLEDGE :
                      --! レジスタアクセス応答信号.
                      out std_logic;
        REGS_ERR    : --! @brief REGISTER ACCESS ERROR ACKNOWLEDGE :
                      --! レジスタアクセスエラー応答信号.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- レジスタライトデータ/ロード出力
    -------------------------------------------------------------------------------
        W_DATA      : out std_logic_vector(WBIT_MAX downto WBIT_MIN);
        W_LOAD      : out std_logic_vector(WBIT_MAX downto WBIT_MIN);
    -------------------------------------------------------------------------------
    -- レジスタリードデータ入力
    -------------------------------------------------------------------------------
        R_DATA      : in  std_logic_vector(RBIT_MAX downto RBIT_MIN)
    );
end REGISTER_ACCESS_DECODER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of REGISTER_ACCESS_DECODER is
    constant BYTE_BITS  : natural := 8;
    constant WORD_BYTES : natural := DATA_WIDTH/BYTE_BITS;
    constant W_POS_LO   : natural := (WBIT_MIN)/DATA_WIDTH;
    constant W_POS_HI   : natural := (WBIT_MAX)/DATA_WIDTH;
    constant R_POS_LO   : natural := (RBIT_MIN)/DATA_WIDTH;
    constant R_POS_HI   : natural := (RBIT_MAX)/DATA_WIDTH;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    REGS_ACK <= REGS_REQ;
    REGS_ERR <= '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (REGS_WDATA) begin
        for i in W_POS_LO to W_POS_HI loop
            for n in 0 to DATA_WIDTH-1 loop
                if (W_DATA'low <= DATA_WIDTH*i+n and DATA_WIDTH*i+n <= W_DATA'high) then
                    W_DATA(DATA_WIDTH*i+n) <= REGS_WDATA(n);
                end if;
            end loop;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (REGS_ADDR, REGS_REQ, REGS_WRITE, REGS_BEN)
        variable addr      : unsigned        (ADDR_WIDTH-1 downto 0);
        variable ben_bit   : std_logic_vector(DATA_WIDTH-1 downto 0);
    begin
        if (REGS_REQ = '1' and REGS_WRITE = '1') then
            addr := to_01(unsigned(REGS_ADDR));
            for i in 0 to DATA_WIDTH/8-1 loop
                if (REGS_BEN(i) = '1') then
                    ben_bit(8*(i+1)-1 downto 8*i) := (8*(i+1)-1 downto 8*i => '1');
                else
                    ben_bit(8*(i+1)-1 downto 8*i) := (8*(i+1)-1 downto 8*i => '0');
                end if;
            end loop;
            for i in W_POS_LO to W_POS_HI loop
                if (i = addr/WORD_BYTES) then
                    for n in 0 to DATA_WIDTH-1 loop
                        if (W_LOAD'low <= DATA_WIDTH*i+n and DATA_WIDTH*i+n <= W_LOAD'high) then
                            W_LOAD(DATA_WIDTH*i+n) <= ben_bit(n);
                        end if;
                    end loop;
                else
                    for n in 0 to DATA_WIDTH-1 loop
                        if (W_LOAD'low <= DATA_WIDTH*i+n and DATA_WIDTH*i+n <= W_LOAD'high) then
                            W_LOAD(DATA_WIDTH*i+n) <= '0';
                        end if;
                    end loop;
                end if;
            end loop;
        else
            W_LOAD <= (others => '0');
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (R_DATA, REGS_ADDR)
        variable addr      : unsigned        (ADDR_WIDTH-1 downto 0);
        variable data      : std_logic_vector(DATA_WIDTH-1 downto 0);
    begin
        addr := to_01(unsigned(REGS_ADDR));
        data := (others => '0');
        for i in R_POS_LO to R_POS_HI loop
            if (i = addr/WORD_BYTES) then
                for n in data'range loop
                    if (R_DATA'low <= DATA_WIDTH*i+n and DATA_WIDTH*i+n <= R_DATA'high) then
                        data(n) := data(n) or R_DATA(DATA_WIDTH*i+n);
                    end if;
                end loop;
            end if;
        end loop;
        REGS_RDATA <= data;
    end process;
end RTL;
