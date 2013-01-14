-----------------------------------------------------------------------------------
--!     @file    syncronizer_input_pending_register.vhd
--!     @brief   SYNCRONIZER INPUT PENDING REGISTER : 
--!     @version 0.1.2
--!     @date    2012/9/10
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
--! @brief   SYNCRONIZER INPUT PENDING_REGSISTER
--!          異なるクロックで動作するパスを継ぐアダプタ(SYNCRONIZER)の入力側レジスタ.
--!        * SYNCRONIZER の入力側(I_DATA,I_VAL)に接続し、
--!          SYNCRONIZERが入力不可の際(I_RDY='0')に
--!          一時的に入力データを保存(ペンディング)しておくためレジスタ.
--!        * ペンディングする際の方法はジェネリック変数OPERATIONで指示する.
--!          OPERATION = 0 の場合は常に新しい入力データで上書きされる.  
--!          OPERATION = 1 の場合は入力データとペンディングデータとをビット単位で 
--!          論理和して新しいペンディングデータとする.   
--!          OPERATION = 2 の場合は入力データとペンディングデータとを加算して 
--!          新しいペンディングデータとする.  
-----------------------------------------------------------------------------------
entity  SYNCRONIZER_INPUT_PENDING_REGISTER is
    generic (
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(IDATA/ODATA)のビット幅を指定する.
                      integer :=  8;
        OPERATION   : --! @brief PENDING OPERATION :
                      --! ペンディング(出力待ち)時に次のIVALがアサートされた時に
                      --! データをどう扱うを指定する.
                      --! * OPERATION = 0 の場合は常に新しい入力データで上書きされる. 
                      --! * OPERATION = 1 の場合は入力データ(IDATA)と
                      --!   ペンディングデータとをビット単位で論理和して
                      --!   新しいペンディングデータとする.
                      --!   主に入力データがフラグ等の場合に使用する.
                      --! * OPERATION = 2 の場合は入力データ(IDATA)と
                      --!   ペンディングデータとを加算して
                      --!   新しいペンディングデータとする.
                      --!   主に入力データがカウンタ等の場合に使用する.
                      integer range 0 to 2 := 0
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT DATA :
                      --! 入力データ.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT VALID :
                      --! 入力有効信号.
                      --! * この信号がアサートされている時はI_DATAに有効なデータが
                      --!   入力されていなければならない。
                      in  std_logic;
        I_PAUSE     : --! @brief INPUT PAUSE :
                      --! * 入力側の情報(I_VAL,I_DATA)を、出力側(O_VAL,O_DATA)に
                      --!   出力するのを一時的に中断する。
                      --! * この信号がアサートされている間に入力された入力側の情報(
                      --!   I_VAL,I_DATA)は、出力側(O_VAL,O_DATA)には出力されず、
                      --!   ペンディングレジスタに保持される。
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側(PENDING) I/F
    -------------------------------------------------------------------------------
        P_DATA      : --! @brief PENDING DATA :
                      --! 現在ペンディング中のデータ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        P_VAL       : --! @brief PENDING VALID :
                      --! 現在ペンディング中のデータがあることを示すフラグ.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT DATA :
                      --! 出力データ.
                      --! * SYNCRONIZERのI_DATAに接続する.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT VALID :
                      --! 出力有効信号.
                      --! * SYNCRONIZERのI_VALに接続する.
                      --! * この信号がアサートされている時はO_DATAに有効なデータが
                      --!   出力されていることを示す.
                      out std_logic;
        O_RDY       : --! @brief OUTPUT READY :
                      --! 出力許可信号.
                      --! * SYNCRONIZERのI_RDYに接続する.
                      in  std_logic
    );
end SYNCRONIZER_INPUT_PENDING_REGISTER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of SYNCRONIZER_INPUT_PENDING_REGISTER is
    -------------------------------------------------------------------------------
    --! @brief 出力側に出力するデータ有効信号.
    -------------------------------------------------------------------------------
    signal   out_valid       : std_logic;
    -------------------------------------------------------------------------------
    --! @brief 出力側に出力するデータ.
    -------------------------------------------------------------------------------
    signal   out_data        : std_logic_vector(DATA_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief データが出力側に出力されていないことを示すフラグ.
    -------------------------------------------------------------------------------
    signal   pend_valid      : std_logic;
    -------------------------------------------------------------------------------
    --! @brief 出力側に出力できない時にデータを保持しておくレジスタ.
    -------------------------------------------------------------------------------
    signal   pend_data       : std_logic_vector(DATA_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 常に I_PAUSE=0 かつ O_RDY=1 が成立するような場合は pend_valid, pend_data
    -- はすべて0になり、その場合は out_valid, out_data は次のように簡略化されるよ
    -- うに記述している.
    -- out_valid <= I_VAL; out_data  <= I_DATA
    -------------------------------------------------------------------------------
    out_valid <= '1' when (I_PAUSE = '0' and (I_VAL = '1' or pend_valid = '1')) else '0';
    process (I_VAL, I_DATA, pend_valid, pend_data) begin
        if    (I_VAL = '1') then
            case OPERATION is
                when 2      => out_data <= std_logic_vector(unsigned(I_DATA) + unsigned(pend_data));
                when 1      => out_data <= I_DATA or pend_data;
                when others => out_data <= I_DATA;
            end case;
        elsif (pend_valid = '1') then
            out_data <= pend_data;
        else
            out_data <= I_DATA;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 少し変則的で判りにくい記述だが、out_data を再利用することで回路がなるべく
    -- 簡単になるようにしている.
    -- 常に I_PAUSE=0 かつ O_RDY=1 が成立するような場合は pend_valid, pend_data
    -- はすべて0になるようにしている.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then 
                pend_valid <= '0';
                pend_data  <= (others => '0');
        elsif  (CLK'event and CLK = '1') then
            if (CLR = '1') or 
               (O_RDY       = '1' and I_PAUSE = '0') or
               (pend_valid  = '0' and I_VAL   = '0') then
                pend_valid <= '0';
                pend_data  <= (others => '0');
            else
                pend_valid <= '1';
                pend_data  <= out_data;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 出力情報をモジュール外部に出力する.
    -------------------------------------------------------------------------------
    O_VAL  <= out_valid;
    O_DATA <= out_data;
    -------------------------------------------------------------------------------
    -- ペンディング情報をモジュール外部に出力する.
    -------------------------------------------------------------------------------
    P_VAL  <= pend_valid;
    P_DATA <= pend_data;
end RTL;
