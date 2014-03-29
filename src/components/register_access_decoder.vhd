-----------------------------------------------------------------------------------
--!     @file    register_access_decoder.vhd
--!     @brief   REGISTER ACCESS DECODER MODULE :
--!              レジスタアクセスデコーダ.
--!     @version 1.5.5
--!     @date    2014/3/13
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
    function min(L,R:integer) return integer is begin
        if (L > R) then return R;
        else            return L;
        end if;
    end function;
    function max(L,R:integer) return integer is begin
        if (L > R) then return L;
        else            return R;
        end if;
    end function;
    constant W_POS_LO   : natural := (WBIT_MIN)/DATA_WIDTH;
    constant W_POS_HI   : natural := (WBIT_MAX)/DATA_WIDTH;
    constant R_POS_LO   : natural := (RBIT_MIN)/DATA_WIDTH;
    constant R_POS_HI   : natural := (RBIT_MAX)/DATA_WIDTH;
    constant A_POS_LO   : natural := min(R_POS_LO,W_POS_LO);
    constant A_POS_HI   : natural := max(R_POS_HI,W_POS_HI);
    signal   addr_hit   : std_logic_vector(A_POS_HI downto A_POS_LO);
    signal   word_wen   : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- addr_hit   : 
    -------------------------------------------------------------------------------
    process (REGS_ADDR)
        variable byte_addr : unsigned(ADDR_WIDTH-1 downto 0);
    begin
        byte_addr := to_01(unsigned(REGS_ADDR));
        for word_pos in addr_hit'range loop
            if (word_pos = byte_addr/WORD_BYTES) then
                addr_hit(word_pos) <= '1';
            else
                addr_hit(word_pos) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- word_wen   : 
    -------------------------------------------------------------------------------
    process (REGS_REQ, REGS_WRITE, REGS_BEN) begin
        if (REGS_REQ = '1' and REGS_WRITE = '1') then
            for i in 0 to DATA_WIDTH/8-1 loop
                if (REGS_BEN(i) = '1') then
                    word_wen(8*(i+1)-1 downto 8*i) <= (8*(i+1)-1 downto 8*i => '1');
                else
                    word_wen(8*(i+1)-1 downto 8*i) <= (8*(i+1)-1 downto 8*i => '0');
                end if;
            end loop;
        else
            word_wen <= (others => '0');
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- W_DATA     :
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
    -- W_LOAD     :
    -------------------------------------------------------------------------------
    process (addr_hit, word_wen) begin
        for i in W_POS_LO to W_POS_HI loop
            if (addr_hit(i) = '1') then
                for n in 0 to DATA_WIDTH-1 loop
                    if (W_LOAD'low <= DATA_WIDTH*i+n and DATA_WIDTH*i+n <= W_LOAD'high) then
                        W_LOAD(DATA_WIDTH*i+n) <= word_wen(n);
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
    end process;
    -------------------------------------------------------------------------------
    -- REGS_RDATA :
    -------------------------------------------------------------------------------
    process (R_DATA, addr_hit)
        type     WORD_VEC_TYPE is array(DATA_WIDTH-1 downto 0)
                               of std_logic_vector(R_POS_HI downto R_POS_LO);
        variable word_vec      :  WORD_VEC_TYPE;
        function or_reduce_tree(A:std_logic_vector) return std_logic is
            alias V : std_logic_vector(A'length-1 downto 0) is A;
        begin
            if    (V'length < 1) then
                return '0';
            elsif (V'length = 1) then
                return V(0);
            elsif (V'length = 2) then
                return V(0) or V(1);
            elsif (V'length = 3) then
                return V(0) or V(1) or V(2);
            else
                return or_reduce_tree(V(V'length/2-1 downto V'low     ))
                    or or_reduce_tree(V(V'high       downto V'length/2));
            end if;
        end function;
    begin
        for i in R_POS_LO to R_POS_HI loop
            for n in DATA_WIDTH-1 downto 0 loop
                if (addr_hit(i) = '1') and 
                   (R_DATA'low <= DATA_WIDTH*i+n and DATA_WIDTH*i+n <= R_DATA'high) then
                    word_vec(n)(i) := R_DATA(DATA_WIDTH*i+n);
                else
                    word_vec(n)(i) := '0';
                end if;
            end loop;
        end loop;
        for n in DATA_WIDTH-1 downto 0 loop
            REGS_RDATA(n) <= or_reduce_tree(word_vec(n));
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- REGS_ACK   :
    -- REGS_ERR   :
    -------------------------------------------------------------------------------
    REGS_ACK <= REGS_REQ;
    REGS_ERR <= '0';
end RTL;
