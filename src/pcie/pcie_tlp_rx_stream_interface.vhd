-----------------------------------------------------------------------------------
--!     @file    pcie_tlp_rx_stream_interface.vhd
--!     @brief   PCI-Express TLP(Transaction Layer Packet) Receive Stream Interface
--!     @version 0.0.4
--!     @date    2013/3/5
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
library PIPEWORK;
use     PIPEWORK.PCIe_TLP_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   PCI-Express Receive Stream Interface
-----------------------------------------------------------------------------------
entity  PCIe_TLP_RX_STREAM_INTERFACE is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        RX_WORD_ORDER   : --! @brief RX_DATAのワード(1word=32bit)単位での並びを指定する.
                          --! * 0 = 1st_word RX_DATA[31:00], 2nd_word RX_DATA[63:32]
                          --! * 1 = 1st_word RX_DATA[63:32], 2nd_word RX_DATA[31:00]
                          integer := 0;
        RX_BYTE_ORDER   : --! @brief RX_DATAのワード内でのバイトの並びを指定する.
                          --! * 0 = 1st_byte RX_DATA[07:00], 2nd_byte RX_DATA[15:08]
                          --!       3rd_byte RX_DATA[23:16], 4th_byte RX_DATA[31:24]
                          --! * 1 = 1st_byte RX_DATA[31:24], 2nd_byte RX_DATA[23:16]
                          --!       3rd_byte RX_DATA[15:08], 4th_byte RX_DATA[07:00]
                          integer := 0;
        RX_DATA_WIDTH   : --! @brief RX_DATA WIDTH :
                          --! RX_DATAのビット幅を２のべき乗値で指定する.
                          --! * 5 = 2**5=32bit
                          --! * 6 = 2**6=64bit
                          integer range 5 to 7 := 6;
        TLP_DATA_WIDTH  : --! @brief TLP_DATA WIDTH :
                          --! TLP_DATAのビット幅を２のべき乗値で指定する.
                          --! * 5 = 2**5=32bit
                          --! * 6 = 2**6=64bit
                          integer range 5 to 8 := 6
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- PCI-Express Receive Stream Interface.
    -------------------------------------------------------------------------------
        RX_VAL          : in  std_logic;
        RX_SOP          : in  std_logic;
        RX_EOP          : in  std_logic;
        RX_VC           : in  std_logic_vector(2 downto 0);
        RX_BAR_HIT      : in  std_logic_vector;
        RX_DATA         : in  std_logic_vector(2**(RX_DATA_WIDTH  )-1 downto 0);
        RX_BEN          : in  std_logic_vector(2**(RX_DATA_WIDTH-3)-1 downto 0);
        RX_RDY          : out std_logic;
    -------------------------------------------------------------------------------
    -- PCI-Express TLP Header Output Interface.
    -------------------------------------------------------------------------------
        TLP_HEAD        : out PCIe_TLP_HEAD_TYPE;
        TLP_HVAL        : out std_logic;
        TLP_HHIT        : in  std_logic;
        TLP_HSEL        : in  std_logic_vector;
        TLP_HRDY        : in  std_logic;
        BAR_HIT         : out std_logic_vector;
    -------------------------------------------------------------------------------
    -- PCI-Express TLP Payload Data Output Interface.
    -------------------------------------------------------------------------------
        TLP_DATA        : out std_logic_vector(2**(TLP_DATA_WIDTH )-1 downto 0);
        TLP_DSEL        : out std_logic_vector;
        TLP_DVAL        : out std_logic;
        TLP_DEND        : out std_logic;
        TLP_DRDY        : in  std_logic
    );
end PCIe_TLP_RX_STREAM_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PCIe_TLP_TYPES.all;
use     PIPEWORK.COMPONENTS.REDUCER;
architecture RTL of PCIe_TLP_RX_STREAM_INTERFACE is
    -------------------------------------------------------------------------------
    -- ワードタイプ
    -------------------------------------------------------------------------------
    constant WORD_WIDTH     : integer := 5;  -- 2**5 = 32bit
    constant BYTE_WIDTH     : integer := 3;  -- 2**3 =  8bit
    constant RX_DATA_BITS   : integer := 2**RX_DATA_WIDTH;
    constant TLP_DATA_BITS  : integer := 2**TLP_DATA_WIDTH;
    constant WORD_BITS      : integer := 2**WORD_WIDTH;
    constant BYTE_BITS      : integer := 2**BYTE_WIDTH;
    constant WORD_BYTES     : integer := WORD_BITS/BYTE_BITS;
    subtype  WORD_TYPE     is std_logic_vector(WORD_BITS-1 downto 0);
    type     WORD_VECTOR   is array (INTEGER range <>) of WORD_TYPE;
    constant NULL_WORD      : WORD_TYPE := (others => '0');
    constant NULL_BEN       : std_logic_vector(WORD_BYTES-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- ヘッダ長のワード数
    -------------------------------------------------------------------------------
    constant HEAD_WORD_SIZE : integer := (128+RX_DATA'length-1)/(RX_DATA'length);
    signal   curr_head      : WORD_VECTOR(0 to 1);
    signal   next_head      : WORD_VECTOR(0 to 1);
    signal   curr_addr      : WORD_VECTOR(0 to 1);
    signal   next_addr      : WORD_VECTOR(0 to 1);
    -------------------------------------------------------------------------------
    -- 入力フェーズ信号
    -------------------------------------------------------------------------------
    type     PHASE_TYPE    is (HEAD_PHASE, DATA_PHASE, BUSY_PHASE, ERROR_PHASE);
    signal   curr_phase     : PHASE_TYPE;
    signal   next_phase     : PHASE_TYPE;
    signal   curr_h_pos     : integer range 0 to HEAD_WORD_SIZE-1;
    signal   next_h_pos     : integer range 0 to HEAD_WORD_SIZE-1;
    signal   head_start     : boolean;
    signal   head_end       : boolean;
    -------------------------------------------------------------------------------
    -- 各種信号
    -------------------------------------------------------------------------------
    signal   head_valid     : std_logic;
    signal   rx_ready       : std_logic;
    signal   rx_data_word   : std_logic_vector( RX_DATA_BITS          -1 downto 0);
    signal   rx_data_wen    : std_logic_vector( RX_DATA_BITS/WORD_BITS-1 downto 0);
    signal   rx_data_valid  : std_logic;
    signal   rx_data_ready  : std_logic;
    signal   rx_data_start  : std_logic;
    constant rx_data_flush  : std_logic := '0';
    constant rx_data_done   : std_logic := '0';
    signal   rx_data_offset : std_logic_vector(TLP_DATA_BITS/WORD_BITS-1 downto 0);
    signal   tlp_data_valid : std_logic;
    signal   tlp_data_ready : std_logic;
    signal   tlp_data_skip  : std_logic;
    signal   tlp_data_last  : std_logic;
    signal   tlp_data_state : std_logic;
    signal   data_busy      : std_logic;
begin
    -------------------------------------------------------------------------------
    -- ★ ヘッダ処理部
    -------------------------------------------------------------------------------
    process (RX_VAL, RX_SOP, RX_EOP, RX_DATA, RX_BEN, 
             rx_ready, curr_phase, curr_h_pos, curr_head, curr_addr)
        variable phase       : PHASE_TYPE;
        variable head_pos    : integer range 0 to HEAD_WORD_SIZE - 1;
        variable head_4dw    : boolean;
        variable with_data   : boolean;
        variable message     : boolean;
        variable recv_word   : WORD_VECTOR     (RX_DATA_BITS/WORD_BITS-1 downto 0);
        variable recv_wval   : std_logic_vector(RX_DATA_BITS/WORD_BITS-1 downto 0);
        variable data_wval   : std_logic_vector(RX_DATA_BITS/WORD_BITS-1 downto 0);
        constant NULL_WVAL   : std_logic_vector(RX_DATA_BITS/WORD_BITS-1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        -- RX_WORD_ORDER の値によってワード単位でRX_DATA/RX_BENを入れ替える.
        ---------------------------------------------------------------------------
        if (RX_WORD_ORDER = 0) then
            for i in recv_word'range loop
                recv_word(recv_word'low +i) := RX_DATA(WORD_BITS*(i+1)-1 downto WORD_BITS*i);
                if (RX_BEN(WORD_BYTES*(i+1)-1 downto WORD_BYTES*i) /= NULL_BEN) then
                    recv_wval(recv_word'low +i) := '1';
                else
                    recv_wval(recv_word'low +i) := '0';
                end if;
            end loop;
        else
            for i in recv_word'range loop
                recv_word(recv_word'high-i) := RX_DATA(WORD_BITS*(i+1)-1 downto WORD_BITS*i);
                if (RX_BEN(WORD_BYTES*(i+1)-1 downto WORD_BYTES*i) /= NULL_BEN) then
                    recv_wval(recv_word'high-i) := '1';
                else
                    recv_wval(recv_word'high-i) := '0';
                end if;
            end loop;
        end if;
        ---------------------------------------------------------------------------
        -- RX_SOPアサート時に各種変数およびレジスタを初期状態にする.
        ---------------------------------------------------------------------------
        if (RX_VAL = '1' and RX_SOP = '1' and rx_ready = '1') then
            head_start <= TRUE;
            phase      := HEAD_PHASE;
            head_pos   := 0;
            with_data  := (recv_word(0)(30) = '1');
            head_4dw   := (recv_word(0)(29) = '1');
            message    := (recv_word(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG0) or
                          (recv_word(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG1) or
                          (recv_word(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG2) or
                          (recv_word(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG3) or
                          (recv_word(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG4) or
                          (recv_word(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG5) or
                          (recv_word(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG6) or
                          (recv_word(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG7) ;
        else
            head_start <= FALSE;
            phase      := curr_phase;
            head_pos   := curr_h_pos;
            with_data  := (curr_head(0)(30) = '1');
            head_4dw   := (curr_head(0)(29) = '1');
            message    := (curr_head(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG0) or
                          (curr_head(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG1) or
                          (curr_head(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG2) or
                          (curr_head(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG3) or
                          (curr_head(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG4) or
                          (curr_head(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG5) or
                          (curr_head(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG6) or
                          (curr_head(0)(28 downto 24) = PCIe_TLP_PKT_TYPE_MSG7) ;
        end if;
        ---------------------------------------------------------------------------
        -- 有効な入力があった場合
        ---------------------------------------------------------------------------
        if (RX_VAL = '1' and rx_ready = '1') then
            -----------------------------------------------------------------------
            -- ヘッダ入力フェーズ
            -----------------------------------------------------------------------
            -- 当初は１種類の記述で全部のデータ幅に対応するようにしていたが、そう
            -- すると合成後の結果が芳しくなかったため、データ幅ごとに記述を変える
            -- ようにした。
            -----------------------------------------------------------------------
            if (phase = HEAD_PHASE) then
                -------------------------------------------------------------------
                -- データ幅が32bitの場合の１ワード目のヘッダ入力フェーズ
                -------------------------------------------------------------------
                if    (RX_DATA_BITS = 32 and head_pos = 0) then
                    next_head(0)   <= recv_word(0);    -- ヘッダの１ワード目
                    next_head(1)   <= NULL_WORD;       -- ダミー
                    next_addr(0)   <= NULL_WORD;       -- ダミー
                    next_addr(1)   <= NULL_WORD;       -- ダミー
                    data_wval      := (others => '0'); -- データはすべて無効
                    head_end       <= FALSE;           -- ヘッダはまだ揃っていない
                    if (RX_EOP = '1') then             -- EOPがここでアサートされた
                        next_phase <= ERROR_PHASE;     -- 場合は不正なパケットなので
                        next_h_pos <= 0;               -- エラー処理フェーズへ
                    else                               --
                        next_phase <= HEAD_PHASE;      --
                        next_h_pos <= 1;               --
                    end if;                            --
                -------------------------------------------------------------------
                -- データ幅が32bitの場合の２ワード目のヘッダ入力フェーズ
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS = 32 and head_pos = 1) then
                    next_head(0)   <= curr_head(0);    -- ヘッダの１ワード目は入力済み
                    next_head(1)   <= recv_word(0);    -- ヘッダの２ワード目
                    next_addr(0)   <= NULL_WORD;       -- ダミー
                    next_addr(1)   <= NULL_WORD;       -- ダミー
                    data_wval      := (others => '0'); -- データはすべて無効
                    head_end       <= FALSE;           -- ヘッダはまだ揃っていない
                    if (RX_EOP = '1') then             -- EOPがここでアサートされた
                        next_phase <= ERROR_PHASE;     -- 場合は不正なパケットなので
                        next_h_pos <= 0;               -- エラー処理フェーズへ
                    else                               -- 
                        next_phase <= HEAD_PHASE;      -- 
                        next_h_pos <= 2;               --
                    end if;                            -- 
                -------------------------------------------------------------------
                -- データ幅が32bitの場合の３ワード目のヘッダ入力フェーズ(ヘッダが3DWの場合)
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS = 32 and head_pos = 2 and head_4dw = FALSE) then
                    next_head(0)   <= curr_head(0);    -- ヘッダの１ワード目は入力済み
                    next_head(1)   <= curr_head(1);    -- ヘッダの２ワード目は入力済み
                    next_addr(0)   <= recv_word(0);    -- アドレスの下位ワード
                    next_addr(1)   <= NULL_WORD;       -- アドレスの上位ワードは０クリア
                    data_wval      := (others => '0'); -- データはすべて無効
                    if    (with_data = FALSE and RX_EOP = '1') then
                        head_end   <= TRUE;
                        next_phase <= BUSY_PHASE;
                        next_h_pos <= 0;
                    elsif (with_data = TRUE  and RX_EOP = '0') then
                        head_end   <= TRUE;
                        next_phase <= DATA_PHASE;
                        next_h_pos <= 0;
                    else
                        head_end   <= FALSE;
                        next_phase <= ERROR_PHASE;
                        next_h_pos <= 0;
                    end if;
                -------------------------------------------------------------------
                -- データ幅が32bitの場合の３ワード目のヘッダ入力フェーズ(ヘッダが4DWの場合)
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS = 32 and head_pos = 2 and head_4dw = TRUE) then
                    next_head(0)   <= curr_head(0);    -- ヘッダの１ワード目は入力済み
                    next_head(1)   <= curr_head(1);    -- ヘッダの２ワード目は入力済み
                    next_addr(0)   <= recv_word(0);    -- アドレスの下位ワード(ダミー入力)
                    next_addr(1)   <= recv_word(0);    -- アドレスの上位ワード
                    data_wval      := (others => '0'); -- データはすべて無効
                    head_end       <= FALSE;           -- ヘッダはまだ揃っていない
                    if (RX_EOP = '1') then             -- EOPがここでアサートされた
                        next_phase <= ERROR_PHASE;     -- 場合は不正なパケットなので
                        next_h_pos <= 0;               -- エラー処理フェーズへ
                    else
                        next_phase <= HEAD_PHASE;
                        next_h_pos <= 3;
                    end if;
                -------------------------------------------------------------------
                -- データ幅が32bitの場合の４ワード目のヘッダ入力フェーズ
                -- ヘッダが4DWの場合のみ、この条件が成立する
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS = 32 and head_pos = 3) then
                    next_head(0)   <= curr_head(0);    -- ヘッダの１ワード目は入力済み
                    next_head(1)   <= curr_head(1);    -- ヘッダの２ワード目は入力済み
                    next_addr(0)   <= recv_word(0);    -- アドレスの下位ワード
                    next_addr(1)   <= curr_addr  (1);  -- アドレスの上位ワードは入力済み
                    data_wval      := (others => '0'); -- データはすべて無効
                    if    (with_data = FALSE and RX_EOP = '1') then
                        head_end   <= TRUE;
                        next_phase <= BUSY_PHASE;
                        next_h_pos <= 0;
                    elsif (with_data = TRUE  and RX_EOP = '0') then
                        head_end   <= TRUE;
                        next_phase <= DATA_PHASE;
                        next_h_pos <= 0;
                    else
                        head_end   <= FALSE;
                        next_phase <= ERROR_PHASE;
                        next_h_pos <= 0;
                    end if;
                -------------------------------------------------------------------
                -- データ幅が64bitの場合の１ワード目のヘッダ入力フェーズ
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS = 64 and head_pos = 0) then
                    next_head(0)   <= recv_word(0);    -- ヘッダの１ワード目
                    next_head(1)   <= recv_word(1);    -- ヘッダの２ワード目
                    next_addr(1)   <= NULL_WORD;       -- ダミー
                    next_addr(0)   <= NULL_WORD;       -- ダミー
                    data_wval      := (others => '0'); -- データはすべて無効
                    head_end       <= FALSE;           -- ヘッダはまだ揃っていない
                    if (RX_EOP = '1') then             -- EOPがここでアサートされた
                        next_phase <= ERROR_PHASE;     -- 場合は不正なパケットなので
                        next_h_pos <= 0;               -- エラー処理フェーズへ
                    else                               -- 
                        next_phase <= HEAD_PHASE;      -- 
                        next_h_pos <= 1;               -- 
                    end if;                            -- 
                -------------------------------------------------------------------
                -- データ幅が64bitの場合の２ワード目のヘッダ入力フェーズ(ヘッダが3DWの場合)
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS = 64 and head_pos = 1 and head_4dw = FALSE) then
                    next_head(0)   <= curr_head(0);    -- ヘッダの１ワード目は入力済み
                    next_head(1)   <= curr_head(1);    -- ヘッダの２ワード目は入力済み
                    next_addr(0)   <= recv_word(0);    -- アドレスの下位ワード
                    next_addr(1)   <= NULL_WORD;       -- アドレスの上位ワードは０クリア
                    if (with_data = TRUE) then
                        data_wval := "10";
                    else
                        data_wval := "00";
                    end if;
                    if    (with_data = FALSE and RX_EOP = '1') then
                        head_end   <= TRUE;      
                        next_phase <= BUSY_PHASE;
                        next_h_pos <= 0;
                    elsif (with_data = TRUE) then
                        head_end   <= TRUE;      
                        next_phase <= DATA_PHASE;
                        next_h_pos <= 0;
                    else
                        head_end   <= FALSE;
                        next_phase <= ERROR_PHASE;
                        next_h_pos <= 0;
                    end if;
                -------------------------------------------------------------------
                -- データ幅が64bitの場合の２ワード目のヘッダ入力フェーズ(ヘッダが4DWの場合)
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS = 64 and head_pos = 1 and head_4dw = TRUE) then
                    next_head(0)   <= curr_head(0);    -- ヘッダの１ワード目は入力済み
                    next_head(1)   <= curr_head(1);    -- ヘッダの２ワード目は入力済み
                    next_addr(0)   <= recv_word(1);    -- アドレスの下位ワード
                    next_addr(1)   <= recv_word(0);    -- アドレスの上位ワード
                    data_wval      := (others => '0'); -- データはすべて無効
                    if    (with_data = FALSE and RX_EOP = '1') then
                        head_end   <= TRUE;
                        next_phase <= BUSY_PHASE;
                        next_h_pos <= 0;
                    elsif (with_data = TRUE  and RX_EOP = '0') then
                        head_end   <= TRUE;
                        next_phase <= DATA_PHASE;
                        next_h_pos <= 0;
                    else
                        head_end   <= FALSE;
                        next_phase <= ERROR_PHASE;
                        next_h_pos <= 0;
                    end if;
                -------------------------------------------------------------------
                -- データ幅が128bit以上の場合のヘッダ入力フェーズ(ヘッダが3DWの場合)
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS >= 128 and head_4dw = FALSE) then
                    next_head(0)   <= recv_word(0);    -- ヘッダの１ワード目
                    next_head(1)   <= recv_word(1);    -- ヘッダの２ワード目
                    next_addr(0)   <= recv_word(2);    -- アドレスの下位ワード
                    next_addr(1)   <= NULL_WORD;       -- アドレスの上位ワードは０クリア
                    if (with_data = TRUE) then
                        for i in data_wval'range loop
                            if (i >= 3) then
                                data_wval(i) := '1';
                            else
                                data_wval(i) := '0';
                            end if;
                        end loop;
                    else
                            data_wval := (others => '0');
                    end if;
                    if    (with_data = FALSE and RX_EOP = '1') then
                        head_end   <= TRUE;
                        next_phase <= BUSY_PHASE;
                        next_h_pos <= 0;
                    elsif (with_data = TRUE) then
                        head_end   <= TRUE;      
                        next_phase <= DATA_PHASE;
                        next_h_pos <= 0;
                    else
                        head_end   <= FALSE;
                        next_phase <= ERROR_PHASE;
                        next_h_pos <= 0;
                    end if;
                -------------------------------------------------------------------
                -- データ幅が128bit以上の場合のヘッダ入力フェーズ(ヘッダが4DWの場合)
                -------------------------------------------------------------------
                elsif (RX_DATA_BITS >= 128 and head_4dw = TRUE) then
                    next_head(0)   <= recv_word(0);    -- ヘッダの１ワード目
                    next_head(1)   <= recv_word(1);    -- ヘッダの２ワード目
                    next_addr(0)   <= recv_word(3);    -- アドレスの下位ワード
                    next_addr(1)   <= recv_word(2);    -- アドレスの上位ワード
                    if (with_data = TRUE) then
                        for i in data_wval'range loop
                            if (i >= 4) then
                                data_wval(i) := '1';
                            else
                                data_wval(i) := '0';
                            end if;
                        end loop;
                    else
                            data_wval := (others => '0');
                    end if;
                    if    (with_data = FALSE and RX_EOP = '1') then
                        head_end   <= TRUE;
                        next_phase <= BUSY_PHASE;
                        next_h_pos <= 0;
                    elsif (with_data = TRUE  and RX_EOP = '0') then
                        head_end   <= TRUE;
                        next_phase <= DATA_PHASE;
                        next_h_pos <= 0;
                    else
                        head_end   <= FALSE;
                        next_phase <= ERROR_PHASE;
                        next_h_pos <= 0;
                    end if;
                -------------------------------------------------------------------
                -- 上記以外は起こり得ないはずだが、論理合成ツールによっては不要な警
                -- 告が出る場合があるので、とりあえず信号を生成しておく
                -------------------------------------------------------------------
                else
                    next_head      <= curr_head;       -- ダミー
                    next_addr      <= curr_addr;       -- ダミー
                    data_wval      := (others => '0'); -- データはすべて無効
                    head_end       <= FALSE;
                    next_phase     <= HEAD_PHASE;
                    next_h_pos     <= 0;
                end if;
            -----------------------------------------------------------------------
            -- データ入力フェーズ(データ幅に関わらず共通)
            -----------------------------------------------------------------------
            elsif (phase = DATA_PHASE) then
                    next_head      <= curr_head;       -- ヘッダは入力済み
                    next_addr      <= curr_addr;       -- アドレスは入力済み
                    data_wval      := (others => '1'); -- データ有効フラグ
                    head_end       <= FALSE;           -- ヘッダ情報は入力済み
                    next_phase     <= DATA_PHASE;      -- データ入力フェーズに固定
                    next_h_pos     <= 0;
            -------------------------------------------------------------------
            -- BUSYフェーズ(データ幅に関わらず共通)
            -------------------------------------------------------------------
            elsif (phase = BUSY_PHASE) then
                    next_head      <= curr_head;       -- ヘッダは入力済み
                    next_addr      <= curr_addr;       -- アドレスは入力済み
                    data_wval      := (others => '0'); -- データはすべて無効
                    head_end       <= FALSE;           -- ヘッダ情報は入力済み
                    next_phase     <= BUSY_PHASE;      -- BUSYフェーズに固定
                    next_h_pos     <= 0;
            -------------------------------------------------------------------
            -- エラー処理フェーズ(データ幅に関わらず共通)
            -------------------------------------------------------------------
            else -- if (phase = ERROR_PHASE) then
                    next_head      <= curr_head;       -- ヘッダは入力済み
                    next_addr      <= curr_addr;       -- アドレスは入力済み
                    data_wval      := (others => '0'); -- データはすべて無効
                    head_end       <= FALSE;           -- ヘッダ情報は入力済み
                    next_phase     <= ERROR_PHASE;     -- エラー処理フェーズに固定
                    next_h_pos     <= 0;
            end if;
        ---------------------------------------------------------------------------
        -- 有効な入力がない場合
        ---------------------------------------------------------------------------
        else -- if (not (RX_VAL = '1' and rx_ready = '1')) then
                    next_head      <= curr_head;       -- ヘッダは入力済み
                    next_addr      <= curr_addr;       -- アドレスは入力済み
                    data_wval      := (others => '0'); -- データはすべて無効
                    head_end       <= FALSE;           -- ヘッダ情報は入力済み
                    next_phase     <= phase;
                    next_h_pos     <= head_pos;
        end if;
        ---------------------------------------------------------------------------
        -- RX_DATA/RX_BENを RX_WORD_ORDER および RX_BYTE_ORDER に基づいて並びを変える.
        ---------------------------------------------------------------------------
        for i in recv_word'range loop
            if (RX_BYTE_ORDER = 0) then
                rx_data_word(WORD_BITS*(i+1)-1 downto WORD_BITS*i) <= recv_word(i);
            else
                for b in 0 to WORD_BITS/BYTE_BITS-1 loop
                    rx_data_word(WORD_BITS*i+BYTE_BITS*(b+1)-1 downto WORD_BITS*i+BYTE_BITS*b) <=
                        recv_word(i)(WORD_BITS-BYTE_BITS*b-1 downto WORD_BITS-BYTE_BITS*(b+1));
                end loop;
            end if;                
            rx_data_wen(i) <= recv_wval(i) and data_wval(i);
        end loop;
        if ((recv_wval and data_wval) /= NULL_WVAL and RX_VAL = '1') then
            rx_data_valid <= '1';
        else
            rx_data_valid <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    rx_ready <= '0' when (curr_phase = DATA_PHASE and rx_data_ready = '0') or
                         (curr_phase = BUSY_PHASE and head_valid    = '1') else '1';
    RX_RDY   <= rx_ready;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                head_valid <= '0';
                curr_phase <= HEAD_PHASE;
                curr_h_pos <= 0;
                curr_head  <= (others => NULL_WORD);
                curr_addr  <= (others => NULL_WORD);
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                head_valid <= '0';
                curr_phase <= HEAD_PHASE;
                curr_h_pos <= 0;
                curr_head  <= (others => NULL_WORD);
                curr_addr  <= (others => NULL_WORD);
            else
                if (head_valid = '1' and TLP_HRDY = '1') then
                    head_valid <= '0';
                elsif (head_end = TRUE) then
                    head_valid <= '1';
                end if;
                curr_phase <= next_phase;
                curr_h_pos <= next_h_pos;
                curr_head  <= next_head;
                curr_addr  <= next_addr;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                BAR_HIT <= (BAR_HIT'range => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                BAR_HIT <= (BAR_HIT'range => '0');
            elsif (head_end = TRUE) then
                BAR_HIT <= RX_BAR_HIT;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                TLP_DSEL <= (TLP_DSEL'range => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                TLP_DSEL <= (TLP_DSEL'range => '0');
            elsif (head_valid = '1' and TLP_HRDY = '1') then
                TLP_DSEL <= TLP_HSEL;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    TLP_HVAL           <= head_valid;
    TLP_HEAD.WITH_DATA <= curr_head(0)(30);
    TLP_HEAD.HEAD_LEN  <= curr_head(0)(29);
    TLP_HEAD.PKT_TYPE  <= curr_head(0)(28 downto 24);
    TLP_HEAD.TC        <= curr_head(0)(22 downto 20);
    TLP_HEAD.TD        <= curr_head(0)(15);
    TLP_HEAD.EP        <= curr_head(0)(14);
    TLP_HEAD.ATTR      <= curr_head(0)(13 downto 12);
    TLP_HEAD.DATA_LEN  <= curr_head(0)( 9 downto  0);
    TLP_HEAD.INFO      <= curr_head(1)(31 downto  0);
    TLP_HEAD.ADDR      <= curr_addr(1) & curr_addr(0);
    TLP_HEAD.WORD_POS  <= curr_addr(0)(6 downto 2); -- ダミー入力
    -------------------------------------------------------------------------------
    -- rx_data_start  :
    -- rx_data_offset : 
    -------------------------------------------------------------------------------
    rx_data_start <= '1' when (head_end = TRUE) else '0';
    process (next_addr)
        variable word_pos : unsigned(TLP_DATA_WIDTH-BYTE_WIDTH downto WORD_WIDTH-BYTE_WIDTH);
    begin
        for i in word_pos'range loop
            if (i < TLP_DATA_WIDTH-BYTE_WIDTH) then
                word_pos(i) := next_addr(0)(i);
            else
                word_pos(i) := '0';
            end if;
        end loop;
        for i in rx_data_offset'range loop
            if (i < word_pos) then
                rx_data_offset(i) <= '1';
            else
                rx_data_offset(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- DATA
    -------------------------------------------------------------------------------
    D: REDUCER
        generic map (
            WORD_BITS   => WORD_BITS       ,
            ENBL_BITS   => 1               ,
            I_WIDTH     =>  RX_DATA_BITS/WORD_BITS,
            O_WIDTH     => TLP_DATA_BITS/WORD_BITS,
            QUEUE_SIZE  => 0               ,
            VALID_MIN   => 0               ,
            VALID_MAX   => 0               ,
            I_JUSTIFIED => 0               ,
            FLUSH_ENABLE=> 0
        )
        port map (
            CLK         => CLK             , -- In  :
            RST         => RST             , -- In  :
            CLR         => CLR             , -- In  :
            START       => rx_data_start   , -- In  :
            OFFSET      => rx_data_offset  , -- In  :
            DONE        => rx_data_done    , -- In  :
            FLUSH       => rx_data_flush   , -- In  :
            BUSY        => data_busy       , -- Out :
            VALID       => open            , -- Out :
            I_DATA      => rx_data_word    , -- In  :
            I_ENBL      => rx_data_wen     , -- In  :
            I_DONE      => RX_EOP          , -- In  :
            I_FLUSH     => rx_data_flush   , -- In  :
            I_VAL       => rx_data_valid   , -- In  :
            I_RDY       => rx_data_ready   , -- Out :
            O_DATA      => TLP_DATA        , -- Out :
            O_ENBL      => open            , -- Out :
            O_DONE      => tlp_data_last   , -- Out :
            O_FLUSH     => open            , -- Out :
            O_VAL       => tlp_data_valid  , -- Out :
            O_RDY       => tlp_data_ready    -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                    tlp_data_state <= '0';
                    tlp_data_skip  <= '0';
        elsif (CLK'event and CLK = '1') then
            if    (CLR = '1') then
                    tlp_data_state <= '0';
                    tlp_data_skip  <= '0';
            elsif (head_valid = '1' and TLP_HRDY = '1') then
                if (curr_phase = DATA_PHASE) then
                    tlp_data_state <= '1';
                else
                    tlp_data_state <= '0';
                end if;
                if (curr_phase = DATA_PHASE and TLP_HHIT = '0') then
                    tlp_data_skip  <= '1';
                else
                    tlp_data_skip  <= '0';
                end if;
            elsif (tlp_data_valid = '1' and tlp_data_last = '1' and tlp_data_ready = '1') then
                    tlp_data_state <= '0';
                    tlp_data_skip  <= '0';
            end if;
        end if;
    end process;
    tlp_data_ready <= '1' when (tlp_data_state = '1' and TLP_DRDY = '1') or
                               (tlp_data_skip  = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    TLP_DVAL <= tlp_data_valid and tlp_data_state;
    TLP_DEND <= tlp_data_last;
end RTL;
