-----------------------------------------------------------------------------------
--!     @file    pcie_tlp_tx_stream_interface.vhd
--!     @brief   PCI-Express TLP(Transaction Layer Packet) Transmit Stream Interface
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
--! @brief   PCI-Express Transmit Stream Interface
-----------------------------------------------------------------------------------
entity  PCIe_TLP_TX_STREAM_INTERFACE is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        TX_WORD_ORDER   : --! @brief TX_DATAのワード(1word=32bit)単位での並びを指定する.
                          --! * 0 = 1st_word TX_DATA[31:00], 2nd_word TX_DATA[63:32]
                          --! * 1 = 1st_word TX_DATA[63:32], 2nd_word TX_DATA[31:00]
                          integer := 0;
        TX_BYTE_ORDER   : --! @brief TX_DATAのワード内でのバイトの並びを指定する.
                          --! * 0 = 1st_byte TX_DATA[07:00], 2nd_byte TX_DATA[15:08]
                          --!       3rd_byte TX_DATA[23:16], 4th_byte TX_DATA[31:24]
                          --! * 1 = 1st_byte TX_DATA[31:24], 2nd_byte TX_DATA[23:16]
                          --!       3rd_byte TX_DATA[15:08], 4th_byte TX_DATA[07:00]
                          integer := 0;
        TX_DATA_WIDTH   : --! @brief TX_DATA WIDTH :
                          --! TX_DATAのビット幅を２のべき乗値で指定する.
                          --! * 5 = 2**5=32bit
                          --! * 6 = 2**6=64bit
                          integer range 5 to 7 := 6;
        TLP_DATA_WIDTH  : --! @brief TLP_DATA WIDTH :
                          --! TLP_DATAのビット幅を２のべき乗値で指定する.
                          --! * 5 = 2**5=32bit
                          --! * 6 = 2**6=64bit
                          integer range 5 to 8 := 6;
        QUEUE_SIZE      : --! @brief QUEUE SIZE :
                          --! 一時的に格納できるワードの数を指定する.
                          --! * QUEUE_SIZE=0の場合は、自動的に最適な数を設定する.
                          --! * QUEUE_SIZE>0の場合は、指定された数を指定する.
                          --!   ただし、4以上かつ TLP_DATAのワード数+TX_DATAのワー
                          --!   ド数以上でなければならない.
                          integer := 0;
        ALTERA_MODE     : --! @brief ALTERA MODE :
                          --! Altera社製 PCIe IP の仕様がちょっとおかしいので、それ
                          --! に対応するためのスイッチ.
                          integer := 0
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
    -- PCI-Express Transmit Stream Interface.
    -------------------------------------------------------------------------------
        TX_VAL          : out std_logic;
        TX_SOP          : out std_logic;
        TX_EOP          : out std_logic;
        TX_VC           : out std_logic_vector(2 downto 0);
        TX_DATA         : out std_logic_vector(2**(TX_DATA_WIDTH  )-1 downto 0);
        TX_BEN          : out std_logic_vector(2**(TX_DATA_WIDTH-3)-1 downto 0);
        TX_RDY          : in  std_logic;
    -------------------------------------------------------------------------------
    -- PCI-Express TLP Header Input Interface.
    -------------------------------------------------------------------------------
        TLP_HEAD        : in  PCIe_TLP_HEAD_TYPE;
        TLP_HSEL        : in  std_logic_vector;
        TLP_HVAL        : in  std_logic;
        TLP_HRDY        : out std_logic;
    -------------------------------------------------------------------------------
    -- PCI-Express TLP Payload Data Input Interface.
    -------------------------------------------------------------------------------
        TLP_DATA        : in  std_logic_vector(2**(TLP_DATA_WIDTH)-1 downto 0);
        TLP_DSEL        : out std_logic_vector;
        TLP_DEND        : in  std_logic;
        TLP_DVAL        : in  std_logic;
        TLP_DRDY        : out std_logic
    );
end PCIe_TLP_TX_STREAM_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PCIe_TLP_TYPES.all;
use     PIPEWORK.COMPONENTS.CHOPPER;
architecture RTL of PCIe_TLP_TX_STREAM_INTERFACE is
    -------------------------------------------------------------------------------
    -- ワードタイプ
    -------------------------------------------------------------------------------
    constant WORD_WIDTH     : integer := 5;  -- 2**5 = 32bit
    constant BYTE_WIDTH     : integer := 3;  -- 2**3 =  8bit
    constant TX_DATA_BITS   : integer := 2**TX_DATA_WIDTH;
    constant TLP_DATA_BITS  : integer := 2**TLP_DATA_WIDTH;
    constant WORD_BITS      : integer := 2**WORD_WIDTH;
    constant BYTE_BITS      : integer := 2**BYTE_WIDTH;
    constant I_WORDS        : integer := TLP_DATA_BITS/WORD_BITS;
    constant O_WORDS        : integer :=  TX_DATA_BITS/WORD_BITS;
    -------------------------------------------------------------------------------
    --! @brief ワード単位でデータ/データイネーブル信号/ワード有効フラグをまとめておく
    -------------------------------------------------------------------------------
    type      WORD_TYPE    is record
              DATA          : std_logic_vector(WORD_BITS-1 downto 0);
              ENBL          : std_logic;
              VAL           : boolean;
    end record;
    -------------------------------------------------------------------------------
    --! @brief WORD TYPE の初期化時の値.
    -------------------------------------------------------------------------------
    constant  WORD_NULL     : WORD_TYPE := (DATA => (others => '0'),
                                            ENBL => '0',
                                            VAL  => FALSE);
    -------------------------------------------------------------------------------
    --! @brief WORD TYPE の配列の定義.
    -------------------------------------------------------------------------------
    type      WORD_VECTOR  is array (INTEGER range <>) of WORD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief キューの最後にワードを追加するプロシージャ.
    -------------------------------------------------------------------------------
    procedure APPEND(
        variable QUEUE : inout WORD_VECTOR;
                 WORDS : in    WORD_VECTOR
    ) is
        alias    vec   :       WORD_VECTOR(0 to WORDS'length-1) is WORDS;
        type     bv    is      array (INTEGER range <>) of boolean;
        variable val   :       bv(QUEUE'low to QUEUE'high);
        variable hit   :       boolean;
    begin
        for i in val'range loop         -- 先に val を作っておいた方が論理合成の結果
            val(i) := QUEUE(i).VAL;     -- が良かった
        end loop;                       --
        for i in val'range loop
            if (val(i) = FALSE) then
                QUEUE(i) := WORD_NULL;
                for pos in vec'range loop
                    if (i-pos-1 < val'low) then
                        hit := TRUE;
                    else
                        hit := val(i-pos-1);
                    end if;
                    if (hit) then
                        QUEUE(i) := vec(pos);
                        exit;
                    end if;
                end loop;
           end if;
        end loop;
    end APPEND;
    -------------------------------------------------------------------------------
    --! @brief キューのサイズを計算する関数.
    -------------------------------------------------------------------------------
    function  QUEUE_DEPTH return integer is
        variable min_queue : integer;
    begin
        if (ALTERA_MODE /= 0) then
            if (O_WORDS+I_WORDS >= 5) then
                min_queue := O_WORDS+I_WORDS;
            else
                min_queue := 5;
            end if;
        else
            if (O_WORDS+I_WORDS >= 4) then
                min_queue := O_WORDS+I_WORDS;
            else
                min_queue := 4;
            end if;
        end if;            
        if (QUEUE_SIZE > 0) then
            if (QUEUE_SIZE >= min_queue) then
                return QUEUE_SIZE;
            else
                assert (QUEUE_SIZE >= min_queue)
                    report "require QUEUE_SIZE >= I_WORDS+O_WORDS-1" severity WARNING;
                return min_queue;
            end if;
        else
                return min_queue;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 現在のキューの状態.
    -------------------------------------------------------------------------------
    signal    curr_queue    : WORD_VECTOR(0 to QUEUE_DEPTH-1);
    -------------------------------------------------------------------------------
    --! @brief EOS 出力フラグ.
    -------------------------------------------------------------------------------
    signal    start_output  : std_logic;
    -------------------------------------------------------------------------------
    --! @brief EOP 出力フラグ.
    -------------------------------------------------------------------------------
    signal    done_output   : std_logic;
    -------------------------------------------------------------------------------
    --! @brief EOP 保留フラグ.
    -------------------------------------------------------------------------------
    signal    done_pending  : std_logic;
    -------------------------------------------------------------------------------
    --! @brief TX_VAL信号を内部で使うための信号.
    -------------------------------------------------------------------------------
    signal    tx_valid      : std_logic;
    -------------------------------------------------------------------------------
    --! @brief TLP_DACK信号を内部で使うための信号.
    -------------------------------------------------------------------------------
    signal    d_ready       : std_logic;
    -------------------------------------------------------------------------------
    --! @brief ステートマシン
    -------------------------------------------------------------------------------
    type      STATE_TYPE   is (IDLE, XFER, FLUSH);
    signal    state         : STATE_TYPE;
    -------------------------------------------------------------------------------
    --! @brief TLP_DATAのワードイネーブル信号
    -------------------------------------------------------------------------------
    signal    tlp_data_wen  : std_logic_vector(I_WORDS-1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief TLP_DATAをバイト単位で入れ替えた(かもしれない)結果
    -------------------------------------------------------------------------------
    signal    tlp_data_word : std_logic_vector(TLP_DATA_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- メインプロセス
    -------------------------------------------------------------------------------
    process (CLK, RST) 
        variable    next_state        : STATE_TYPE;
        variable    in_word           : WORD_VECTOR(0 to I_WORDS-1);
        variable    next_queue        : WORD_VECTOR(curr_queue'range);
        variable    next_done_output  : std_logic;
        variable    next_done_pending : std_logic;
        variable    next_done_fall    : std_logic;
        variable    pending_flag      : boolean;
        variable    end_of_packet     : boolean;
    begin
        if (RST = '1') then
                state         <= IDLE;
                curr_queue    <= (others => WORD_NULL);
                start_output  <= '0';
                done_output   <= '0';
                done_pending  <= '0';
                d_ready       <= '0';
                tx_valid      <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                state         <= IDLE;
                curr_queue    <= (others => WORD_NULL);
                start_output  <= '0';
                done_output   <= '0';
                done_pending  <= '0';
                d_ready       <= '0';
                tx_valid      <= '0';
            else
                -------------------------------------------------------------------
                -- next_queue : 次のクロックでのキューの内容を生成する
                -------------------------------------------------------------------
                -- state = IDLE 時に TLP_HVAL がアサートされた場合は、next_queue に
                -- はヘッダ情報がセットされる。
                -------------------------------------------------------------------
                if (state = IDLE) then
                    next_queue(0).DATA(31)           := '0';
                    next_queue(0).DATA(30)           := TLP_HEAD.WITH_DATA;
                    next_queue(0).DATA(29)           := TLP_HEAD.HEAD_LEN;
                    next_queue(0).DATA(28 downto 24) := TLP_HEAD.PKT_TYPE;
                    next_queue(0).DATA(23)           := '0';
                    next_queue(0).DATA(22 downto 20) := TLP_HEAD.TC;
                    next_queue(0).DATA(19 downto 16) := "0000";
                    next_queue(0).DATA(15)           := TLP_HEAD.TD;
                    next_queue(0).DATA(14)           := TLP_HEAD.EP;
                    next_queue(0).DATA(13 downto 12) := TLP_HEAD.ATTR;
                    next_queue(0).DATA(11 downto 10) := "00";
                    next_queue(0).DATA( 9 downto  0) := TLP_HEAD.DATA_LEN;
                    next_queue(1).DATA               := TLP_HEAD.INFO;
                    if (TLP_HEAD.HEAD_LEN = '1') then
                        next_queue(2).DATA := TLP_HEAD.ADDR(63 downto 32);
                        next_queue(3).DATA := TLP_HEAD.ADDR(31 downto  0);
                    else
                        next_queue(2).DATA := TLP_HEAD.ADDR(31 downto  0);
                        next_queue(3).DATA := TLP_HEAD.ADDR(31 downto  0);
                    end if;
                    if    (TLP_HVAL = '1') then
                        next_queue(0).VAL  := TRUE; next_queue(0).ENBL := '1';
                        next_queue(1).VAL  := TRUE; next_queue(1).ENBL := '1';
                        next_queue(2).VAL  := TRUE; next_queue(2).ENBL := '1';
                        if    (TLP_HEAD.HEAD_LEN = '1') then
                            next_queue(3).VAL := TRUE ; next_queue(3).ENBL := '1';
                        elsif (ALTERA_MODE  /= 0 ) and
                              (TX_DATA_BITS >= 64) and
                              (TLP_HEAD.ADDR(2) = '0') then
                            next_queue(3).VAL := TRUE ; next_queue(3).ENBL := '0';
                        else
                            next_queue(3).VAL := FALSE; next_queue(3).ENBL := '0';
                        end if;
                        end_of_packet := (TLP_HEAD.WITH_DATA = '0');
                    else
                        next_queue(0).VAL  := FALSE; next_queue(0).ENBL := '0';
                        next_queue(1).VAL  := FALSE; next_queue(1).ENBL := '0';
                        next_queue(2).VAL  := FALSE; next_queue(2).ENBL := '0';
                        next_queue(3).VAL  := FALSE; next_queue(3).ENBL := '0';
                        end_of_packet := FALSE;
                    end if;
                    for i in 4 to next_queue'high loop
                        next_queue(i).VAL  := (ALTERA_MODE  /=  0) and
                                              (TX_DATA_BITS >= 64) and
                                              (i = 4) and
                                              (TLP_HVAL          = '1') and
                                              (TLP_HEAD.HEAD_LEN = '1') and
                                              (TLP_HEAD.ADDR(2)  = '1');
                        next_queue(i).ENBL := '0';
                        next_queue(i).DATA := curr_queue(i).DATA;
                    end loop;
                -------------------------------------------------------------------
                -- state = XFER 時および state = FLUSH 時
                -------------------------------------------------------------------
                else
                    ---------------------------------------------------------------
                    -- 次のクロックでのキューの状態を示す変数に現在のキューの状態をセット
                    ---------------------------------------------------------------
                    next_queue := curr_queue;
                    ---------------------------------------------------------------
                    -- TX_DATA出力時の次のクロックでのキューの状態に更新
                    ---------------------------------------------------------------
                    if (tx_valid = '1' and TX_RDY = '1') then
                        for i in next_queue'range loop
                            if (i+O_WORDS > next_queue'high) then
                                next_queue(i) := WORD_NULL;
                            else
                                next_queue(i) := curr_queue(i+O_WORDS);
                            end if;
                        end loop;
                    end if;
                    ---------------------------------------------------------------
                    -- TLP_DATA入力時の次のクロックでのキューの状態に更新
                    ---------------------------------------------------------------
                    if (TLP_DVAL = '1' and d_ready = '1') then
                        for i in in_word'range loop
                            in_word(i).DATA :=  tlp_data_word((i+1)*WORD_BITS-1 downto i*WORD_BITS);
                            in_word(i).ENBL :=  tlp_data_wen(i);
                            in_word(i).VAL  := (tlp_data_wen(i) = '1');
                        end loop;
                        if (in_word'length = 1) then
                            APPEND(next_queue, in_word);
                        else
                            for i in in_word'range loop
                                if (in_word(i).VAL) then
                                    APPEND(next_queue, in_word(i to in_word'high));
                                    exit;
                                end if;
                            end loop;
                        end if;
                    end if;
                    end_of_packet := (TLP_DVAL = '1' and d_ready = '1' and TLP_DEND = '1');
                end if;
                -------------------------------------------------------------------
                -- 状態遷移
                -------------------------------------------------------------------
                case state is
                    when IDLE => 
                        if    (TLP_HVAL = '1' and TLP_HEAD.WITH_DATA = '1') then
                            next_state := XFER;
                        elsif (TLP_HVAL = '1' and TLP_HEAD.WITH_DATA = '0') then
                            next_state := FLUSH;
                        else
                            next_state := IDLE;
                        end if;
                    when XFER =>
                        if (d_ready = '1' and TLP_DVAL = '1' and TLP_DEND = '1') then
                            next_state := FLUSH;
                        else
                            next_state := XFER;
                        end if;
                    when FLUSH =>
                        if (next_queue(0).VAL = FALSE) then
                            next_state := IDLE;
                        else
                            next_state := FLUSH;
                        end if;
                    when others =>
                            next_state := IDLE;
                end case;
                state  <= next_state;
                -------------------------------------------------------------------
                -- 次のクロックでのキューの状態をレジスタに保持
                -------------------------------------------------------------------
                curr_queue <= next_queue;
                -------------------------------------------------------------------
                -- 次のクロックでのキューの状態でO_WORDSの位置にデータが入って
                -- いるか否かをチェック.
                -------------------------------------------------------------------
                if (next_queue'high >= O_WORDS) then
                    pending_flag := (next_queue(O_WORDS).VAL);
                else
                    pending_flag := FALSE;
                end if;
                -------------------------------------------------------------------
                -- SOP制御
                -------------------------------------------------------------------
                if    (state = IDLE and TLP_HVAL = '1') then
                    start_output <= '1';
                elsif (tx_valid = '1' and TX_RDY = '1') then
                    start_output <= '0';
                end if;
                -------------------------------------------------------------------
                -- EOP制御
                -------------------------------------------------------------------
                if    (done_output = '1') then
                    if (tx_valid = '1' and TX_RDY = '1') then
                        next_done_output   := '0';
                        next_done_pending  := '0';
                        next_done_fall     := '1';
                    else
                        next_done_output   := '1';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                    end if;
                elsif (done_pending  = '1' ) or
                      (end_of_packet = TRUE) then
                    if (pending_flag) then
                        next_done_output   := '0';
                        next_done_pending  := '1';
                        next_done_fall     := '0';
                    else
                        next_done_output   := '1';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                    end if;
                else
                        next_done_output   := '0';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                end if;
                done_output   <= next_done_output;
                done_pending  <= next_done_pending;
                -------------------------------------------------------------------
                -- 出力有効信号の生成
                -------------------------------------------------------------------
                if (next_done_output  = '1') or
                   (next_queue(O_WORDS-1).VAL = TRUE) then
                    tx_valid <= '1';
                else
                    tx_valid <= '0';
                end if;
                -------------------------------------------------------------------
                -- 入力可能信号の生成
                -------------------------------------------------------------------
                if (next_state = XFER) and 
                   (next_done_output  = '0' and next_done_pending  = '0') and
                   (next_queue(next_queue'length-I_WORDS).VAL = FALSE) then
                    d_ready <= '1';
                else
                    d_ready <= '0';
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- tlp_data_word :
    -------------------------------------------------------------------------------
    TX_BYTE_ORDER_NORMAL : if (TX_BYTE_ORDER  = 0) generate
        tlp_data_word <= TLP_DATA;
    end generate;
    TX_BYTE_ORDER_REVERSE: if (TX_BYTE_ORDER /= 0) generate
        process(TLP_DATA) begin
            for w in 0 to TLP_DATA_BITS/WORD_BITS-1 loop
                for b in 0 to WORD_BITS/BYTE_BITS-1 loop
                    tlp_data_word(WORD_BITS*(w  )+BYTE_BITS*(b+1)-1 downto WORD_BITS*(w  )+BYTE_BITS*(b  )) <=
                         TLP_DATA(WORD_BITS*(w+1)-BYTE_BITS*(b  )-1 downto WORD_BITS*(w+1)-BYTE_BITS*(b+1));
                end loop;
            end loop;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- tlp_data_wen  :
    -------------------------------------------------------------------------------
    DEN: block
        constant TX_WORD_WIDTH  : integer := TX_DATA_WIDTH-WORD_WIDTH;
        constant MAX_SIZE       : integer := 10;  -- 2**10 = 1Kword = 4KByte/4
        signal   tlp_word_size  : std_logic_vector(10 downto 0);
        signal   tlp_word_addr  : std_logic_vector( 4 downto 0);
        constant tlp_word_sel   : std_logic_vector(TX_WORD_WIDTH downto TX_WORD_WIDTH) := "1";
        signal   tlp_data_start : std_logic;
        signal   tlp_data_chop  : std_logic;
    begin
        tlp_word_addr( 4 downto 0) <= TLP_HEAD.WORD_POS;
        tlp_word_size(10         ) <= '1' when (TLP_HEAD.DATA_LEN = "0000000000") else '0';
        tlp_word_size( 9 downto 0) <= TLP_HEAD.DATA_LEN;
        tlp_data_start <= '1' when (state = IDLE  and TLP_HVAL = '1') else '0';
        tlp_data_chop  <= '1' when (d_ready = '1' and TLP_DVAL = '1') else '0';
        U: CHOPPER
            generic map (
                BURST       => 1               ,
                MIN_PIECE   => TX_WORD_WIDTH   ,
                MAX_PIECE   => TX_WORD_WIDTH   ,
                MAX_SIZE    => MAX_SIZE        ,
                ADDR_BITS   => tlp_word_addr'length,
                SIZE_BITS   => tlp_word_size'length,
                COUNT_BITS  => MAX_SIZE        ,
                PSIZE_BITS  => 1               ,
                GEN_VALID   => 1
            )
            port map (
                CLK         => CLK             , -- In :
                RST         => RST             , -- In :
                CLR         => CLR             , -- In :
                ADDR        => tlp_word_addr   , -- In :
                SIZE        => tlp_word_size   , -- In :
                SEL         => tlp_word_sel    , -- In :
                LOAD        => tlp_data_start  , -- In :
                CHOP        => tlp_data_chop   , -- In :
                COUNT       => open            , -- Out:
                NONE        => open            , -- Out:
                LAST        => open            , -- Out:
                NEXT_NONE   => open            , -- Out:
                NEXT_LAST   => open            , -- Out:
                PSIZE       => open            , -- Out:
                NEXT_PSIZE  => open            , -- Out:
                VALID       => tlp_data_wen    , -- Out:
                NEXT_VALID  => open              -- Out:
            );
    end block;
    -------------------------------------------------------------------------------
    -- TX_DATA :
    -- TX_BEN  :
    -------------------------------------------------------------------------------
    process (curr_queue) 
        variable k : integer range 0 to O_WORDS-1;
    begin
        if (TX_WORD_ORDER = 0) then
            for i in 0 to O_WORDS-1 loop
                TX_DATA(WORD_BITS*(i+1)-1 downto WORD_BITS*i) <= curr_queue(i).DATA;
                TX_BEN (4*i+3) <= curr_queue(i).ENBL;
                TX_BEN (4*i+2) <= curr_queue(i).ENBL;
                TX_BEN (4*i+1) <= curr_queue(i).ENBL;
                TX_BEN (4*i+0) <= curr_queue(i).ENBL;
            end loop;
        else
            for i in 0 to O_WORDS-1 loop
                k := O_WORDS-1-i;
                TX_DATA(WORD_BITS*(k+1)-1 downto WORD_BITS*k) <= curr_queue(i).DATA;
                TX_BEN (4*k+3) <= curr_queue(i).ENBL;
                TX_BEN (4*k+2) <= curr_queue(i).ENBL;
                TX_BEN (4*k+1) <= curr_queue(i).ENBL;
                TX_BEN (4*k+0) <= curr_queue(i).ENBL;
            end loop;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- TX_VAL   :
    -- TX_SOP   :
    -- TX_EOP   :
    -------------------------------------------------------------------------------
    TX_VAL   <= tx_valid;
    TX_SOP   <= start_output;
    TX_EOP   <= done_output;
    -------------------------------------------------------------------------------
    -- TLP_HRDY :
    -------------------------------------------------------------------------------
    TLP_HRDY <= '1' when (state = IDLE) else '0';
    -------------------------------------------------------------------------------
    -- TLP_DRDY :
    -------------------------------------------------------------------------------
    TLP_DRDY <= d_ready;
    -------------------------------------------------------------------------------
    -- TLP_DSEL :
    -------------------------------------------------------------------------------
    process (CLK, RST) 
        constant DSEL_NULL : std_logic_vector(TLP_DSEL'range) := (others => '0');
    begin
        if (RST = '1') then
                TLP_DSEL <= DSEL_NULL;
        elsif (CLK'event and CLK = '1') then
            if    (CLR = '1') then
                TLP_DSEL <= DSEL_NULL;
            elsif (state = IDLE and TLP_HVAL = '1') then
                TLP_DSEL <= TLP_HSEL;
            end if;
        end if;
    end process;

end RTL;
