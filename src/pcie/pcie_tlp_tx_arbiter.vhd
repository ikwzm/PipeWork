-----------------------------------------------------------------------------------
--!     @file    pcie_tlp_tx_arbiter.vhd
--!     @brief   PCI-Express TLP(Transaction Layer Packet) Transmit Arbiter
--!     @version 0.0.1
--!     @date    2013/2/18
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
--! @brief   PCI-Express Transmit Arbiter Interface
-----------------------------------------------------------------------------------
entity  PCIe_TLP_TX_ARBITER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        REQ_ENABLE      : --! @brief リクエストパケットを送信するかどうかを指定する.
                          --! * REQ_ENABLE=1の場合はリクエストパケットを送信する.
                          --!   この場合、REQ_HVAL/REQ_HRDY/REQ_HEAD配列の範囲は
                          --!   TLP_HSEL配列の範囲"内"でなければならない.
                          --! * REQ_ENABLE=0の場合はリクエストパケットを送信しない.
                          --!   この場合、REQ_HVAL/REQ_HRDY/REQ_HEAD配列の範囲は
                          --!   適当でも構わないが長さは１以上でなければならない.
                          integer := 1;
        CPL_ENABLE      : --! @breif コンプレッションパケットを送信するかどうかを指定する.
                          --! * CPL_ENABLE=1の場合はコンプレッションパケットを送信
                          --!   する. この場合、CPL_HVAL/CPL_HRDY/CPL_HEAD配列の範
                          --!   囲はTLP_HSEL配列の範囲"内"でなければならない.
                          --! * CPL_ENABLE=0の場合はコンプレッションパケットを送信
                          --!   しない. この場合、CPL_HVAL/CPL_HRDY/CPL_HEAD配列の
                          --!   範囲は適当でも構わないが長さは１以上でなければなら
                          --!   ない.
                          integer := 1;
        MSG_ENABLE      : --! @brief メッセージパケットを送信するかどうかを指定する.
                          --! * MSG_ENABLE=1の場合はメッセージパケットを送信する.
                          --!   この場合、MES_HVAL/MES_HRDY/MES_HEAD配列の範囲は
                          --!   TLP_HSEL配列の範囲"内"でなければならない.
                          --! * MSG_ENABLE=0の場合はメッセージパケットを送信しない.
                          --!   この場合、MSG_HVAL/MSG_HRDY/MSG_HEAD配列の範囲は
                          --!   適当でも構わないが長さは１以上でなければならない.
                          integer := 1;
        ERR_ENABLE      : --! @brief エラー応答パケットを送信するかどうかを指定する.
                          --! * ERR_ENABLE=1の場合はエラー応答パケットを送信する.
                          --!   この場合、ERR_HVAL/ERR_HRDY/MERR_HEAD配列の範囲は
                          --!   TLP_HSEL配列の範囲"内"でなければならない.
                          --! * ERR_ENABLE=0の場合はエラー応答パケットを送信しない.
                          --!   この場合、ERR_HVAL/ERR_HRDY/ERR_HEAD配列の範囲は
                          --!   適当でも構わないが長さは１以上でなければならない.
                          integer := 1;
        LATENCY         : --! @brief 調停した結果を一度レジスタで叩くかどうかを指定する.
                          --! * LATENCY=1の場合、調停結果を一度レジスタで叩いて
                          --!   TLP_HVAL/TLP_HEAD/TLP_HSEL を出力する.
                          --!   そのため高周波数で動作する可能性があるがレイテンシー
                          --!   は１クロック遅くなる.
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
    -- 調停した後のTLP(Transaction Layer Packet)出力
    -------------------------------------------------------------------------------
        TLP_HEAD        : out PCIe_TLP_HEAD_TYPE;
        TLP_HSEL        : out std_logic_vector;
        TLP_HVAL        : out std_logic;
        TLP_HRDY        : in  std_logic;
    -------------------------------------------------------------------------------
    -- リクエストパケット入力
    -------------------------------------------------------------------------------
        REQ_HEAD        : in  PCIe_TLP_REQ_HEAD_VECTOR;
        REQ_HVAL        : in  std_logic_vector;
        REQ_HRDY        : out std_logic_vector;
    -------------------------------------------------------------------------------
    -- コンプレッションパケット入力
    -------------------------------------------------------------------------------
        CPL_HEAD        : in  PCIe_TLP_CPL_HEAD_VECTOR;
        CPL_HVAL        : in  std_logic_vector;
        CPL_HRDY        : out std_logic_vector;
    -------------------------------------------------------------------------------
    -- メッセージパケット 入力
    -------------------------------------------------------------------------------
        MSG_HEAD        : in  PCIe_TLP_MSG_HEAD_VECTOR;
        MSG_HVAL        : in  std_logic_vector;
        MSG_HRDY        : out std_logic_vector;
    -------------------------------------------------------------------------------
    -- 不正なリクエストパケットを受けとった時のレスポンスパケット入力
    -------------------------------------------------------------------------------
        ERR_HEAD        : in  PCIe_TLP_CPL_HEAD_VECTOR;
        ERR_HVAL        : in  std_logic_vector;
        ERR_HRDY        : out std_logic_vector
    );
end PCIe_TLP_TX_ARBITER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PCIe_TLP_TYPES.all;
use     PIPEWORK.COMPONENTS.QUEUE_ARBITER;
architecture RTL of PCIe_TLP_TX_ARBITER is
    -------------------------------------------------------------------------------
    -- リクエストパケット関連の内部信号
    -------------------------------------------------------------------------------
    constant    REQ_MIN_NUM  : integer := 0;
    constant    REQ_MAX_NUM  : integer := REQ_HVAL'length-1;
    alias       req_hval_vec : std_logic_vector        (REQ_MIN_NUM to REQ_MAX_NUM) is REQ_HVAL;
    alias       req_head_vec : PCIe_TLP_REQ_HEAD_VECTOR(REQ_MIN_NUM to REQ_MAX_NUM) is REQ_HEAD;
    signal      req_arb_gnt  : std_logic_vector        (REQ_MIN_NUM to REQ_MAX_NUM);
    signal      req_arb_num  : integer range            REQ_MIN_NUM to REQ_MAX_NUM;
    signal      req_arb_req  : std_logic;
    signal      req_arb_sft  : std_logic;
    signal      req_arb_ena  : std_logic;
    signal      req_grant    : std_logic_vector        (REQ_MIN_NUM to REQ_MAX_NUM);
    signal      req_header   : PCIe_TLP_REQ_HEAD_TYPE;
    -------------------------------------------------------------------------------
    -- コンプレッションパケット関連の内部信号
    -------------------------------------------------------------------------------
    constant    CPL_MIN_NUM  : integer := 0;
    constant    CPL_MAX_NUM  : integer := CPL_HVAL'length-1;
    alias       cpl_hval_vec : std_logic_vector        (CPL_MIN_NUM to CPL_MAX_NUM) is CPL_HVAL;
    alias       cpl_head_vec : PCIe_TLP_CPL_HEAD_VECTOR(CPL_MIN_NUM to CPL_MAX_NUM) is CPL_HEAD;
    signal      cpl_arb_gnt  : std_logic_vector        (CPL_MIN_NUM to CPL_MAX_NUM);
    signal      cpl_arb_num  : integer range            CPL_MIN_NUM to CPL_MAX_NUM;
    signal      cpl_arb_req  : std_logic;
    signal      cpl_arb_sft  : std_logic;
    signal      cpl_arb_ena  : std_logic;
    signal      cpl_grant    : std_logic_vector        (CPL_MIN_NUM to CPL_MAX_NUM);
    signal      cpl_header   : PCIe_TLP_CPL_HEAD_TYPE;
    -------------------------------------------------------------------------------
    -- メッセージパケット関連の内部信号
    -------------------------------------------------------------------------------
    constant    MSG_MIN_NUM  : integer := 0;
    constant    MSG_MAX_NUM  : integer := MSG_HVAL'length-1;
    alias       msg_hval_vec : std_logic_vector        (MSG_MIN_NUM to MSG_MAX_NUM) is MSG_HVAL;
    alias       msg_head_vec : PCIe_TLP_MSG_HEAD_VECTOR(MSG_MIN_NUM to MSG_MAX_NUM) is MSG_HEAD;
    signal      msg_arb_gnt  : std_logic_vector        (MSG_MIN_NUM to MSG_MAX_NUM);
    signal      msg_arb_num  : integer range            MSG_MIN_NUM to MSG_MAX_NUM;
    signal      msg_arb_req  : std_logic;
    signal      msg_arb_sft  : std_logic;
    signal      msg_arb_ena  : std_logic;
    signal      msg_grant    : std_logic_vector        (MSG_MIN_NUM to MSG_MAX_NUM);
    signal      msg_header   : PCIe_TLP_MSG_HEAD_TYPE;
    -------------------------------------------------------------------------------
    -- エラー応答パケット関連の内部信号
    -------------------------------------------------------------------------------
    constant    ERR_MIN_NUM  : integer := 0;
    constant    ERR_MAX_NUM  : integer := ERR_HVAL'length-1;
    alias       err_hval_vec : std_logic_vector        (ERR_MIN_NUM to ERR_MAX_NUM) is ERR_HVAL;
    alias       err_head_vec : PCIe_TLP_CPL_HEAD_VECTOR(ERR_MIN_NUM to ERR_MAX_NUM) is ERR_HEAD;
    signal      err_arb_gnt  : std_logic_vector        (ERR_MIN_NUM to ERR_MAX_NUM);
    signal      err_arb_num  : integer range            ERR_MIN_NUM to ERR_MAX_NUM;
    signal      err_arb_req  : std_logic;
    signal      err_arb_sft  : std_logic;
    signal      err_arb_ena  : std_logic;
    signal      err_grant    : std_logic_vector        (ERR_MIN_NUM to ERR_MAX_NUM);
    signal      err_header   : PCIe_TLP_CPL_HEAD_TYPE;
    -------------------------------------------------------------------------------
    -- ステートマシン関連
    -------------------------------------------------------------------------------
    type        SEL_TYPE   is (NON_SEL, REQ_SEL, CPL_SEL, MSG_SEL, ERR_SEL);
    signal      arb_grant    : SEL_TYPE;
    signal      arb_sel_d    : SEL_TYPE;
    signal      request      : std_logic;
    signal      header       : PCIe_TLP_HEAD_TYPE;
begin
    -------------------------------------------------------------------------------
    -- リクエストパケットの送信の調停
    -------------------------------------------------------------------------------
    REQ_ARB: QUEUE_ARBITER
        generic map (
            MIN_NUM     => REQ_MIN_NUM , -- 配列のインデックスの最小値
            MAX_NUM     => REQ_MAX_NUM   -- 配列のインデックスの最小値
        )
        port map (
            CLK         => CLK         , -- In  : システムクロック
            RST         => RST         , -- In  : 非同期リセット
            CLR         => CLR         , -- In  : 同期リセット
            ENABLE      => req_arb_ena , -- In  : リクエストパケット有効信号
            REQUEST     => req_hval_vec, -- In  : リクエストパケット送信要求信号
            SHIFT       => req_arb_sft , -- In  : リクエストパケット送信終了信号
            GRANT       => req_arb_gnt , -- Out : 選択された送信要求信号の配列
            GRANT_NUM   => req_arb_num , -- Out : 選択された送信要求信号の番号
            REQUEST_O   => req_arb_req   -- Out : リクエストパケット送信要求信号
        );
    req_header  <= req_head_vec(req_arb_num) when (REQ_ENABLE /= 0) else PCIe_TLP_REQ_HEAD_NULL;
    req_arb_ena <= '1' when (REQ_ENABLE /= 0) else '0';
    req_arb_sft <= '1' when (arb_grant = REQ_SEL and TLP_HRDY = '1') else '0';
    -------------------------------------------------------------------------------
    -- コンプレッションパケットの送信の調停
    -------------------------------------------------------------------------------
    CPL_ARB: QUEUE_ARBITER
        generic map (
            MIN_NUM     => CPL_MIN_NUM , -- 配列のインデックスの最小値
            MAX_NUM     => CPL_MAX_NUM   -- 配列のインデックスの最小値
        )
        port map (
            CLK         => CLK         , -- In  : システムクロック
            RST         => RST         , -- In  : 非同期リセット
            CLR         => CLR         , -- In  : 同期リセット
            ENABLE      => cpl_arb_ena , -- In  : コンプレッションパケット有効信号
            REQUEST     => cpl_hval_vec, -- In  : コンプレッションパケット送信要求信号
            SHIFT       => cpl_arb_sft , -- In  : コンプレッションパケット送信終了信号
            GRANT       => cpl_arb_gnt , -- Out : 選択された送信要求信号の配列
            GRANT_NUM   => cpl_arb_num , -- Out : 選択された送信要求信号の番号
            REQUEST_O   => cpl_arb_req   -- Out : コンプレッションパケット送信要求信号
        );
    cpl_header  <= cpl_head_vec(cpl_arb_num) when (CPL_ENABLE /= 0) else PCIe_TLP_CPL_HEAD_NULL;
    cpl_arb_ena <= '1' when (CPL_ENABLE /= 0) else '0';
    cpl_arb_sft <= '1' when (arb_grant = CPL_SEL and TLP_HRDY = '1') else '0';
    -------------------------------------------------------------------------------
    -- メッセージパケットの送信の調停
    -------------------------------------------------------------------------------
    MSG_ARB: QUEUE_ARBITER
        generic map (
            MIN_NUM     => MSG_MIN_NUM , -- 配列のインデックスの最小値
            MAX_NUM     => MSG_MAX_NUM   -- 配列のインデックスの最小値
        )
        port map (
            CLK         => CLK         , -- In  : システムクロック
            RST         => RST         , -- In  : 非同期リセット
            CLR         => CLR         , -- In  : 同期リセット
            ENABLE      => msg_arb_ena , -- In  : メッセージパケット有効信号
            REQUEST     => msg_hval_vec, -- In  : メッセージパケット送信要求信号
            SHIFT       => msg_arb_sft , -- In  : メッセージパケット送信終了信号
            GRANT       => msg_arb_gnt , -- Out : 選択された送信要求信号の配列
            GRANT_NUM   => msg_arb_num , -- Out : 選択された要求信号のインデックス
            REQUEST_O   => msg_arb_req   -- Out : メッセージパケット送信要求信号
        );
    msg_header  <= msg_head_vec(msg_arb_num) when (MSG_ENABLE /= 0) else PCIe_TLP_MSG_HEAD_NULL;
    msg_arb_ena <= '1' when (MSG_ENABLE /= 0) else '0';
    msg_arb_sft <= '1' when (arb_grant = MSG_SEL and TLP_HRDY = '1') else '0';
    -------------------------------------------------------------------------------
    -- エラー応答パケットの送信の調停
    -------------------------------------------------------------------------------
    ERR_ARB: QUEUE_ARBITER
        generic map (
            MIN_NUM     => ERR_MIN_NUM , -- 配列のインデックスの最小値
            MAX_NUM     => ERR_MAX_NUM   -- 配列のインデックスの最小値
        )
        port map (
            CLK         => CLK         , -- In  : システムクロック
            RST         => RST         , -- In  : 非同期リセット
            CLR         => CLR         , -- In  : 同期リセット
            ENABLE      => err_arb_ena , -- In  : エラー応答パケット有効信号
            REQUEST     => err_hval_vec, -- In  : エラー応答パケット送信要求信号
            SHIFT       => err_arb_sft , -- In  : エラー応答パケット送信終了信号
            GRANT       => err_arb_gnt , -- Out : 選択された送信要求信号の配列
            GRANT_NUM   => err_arb_num , -- Out : 選択された要求信号のインデックス
            REQUEST_O   => err_arb_req   -- Out : エラー応答パケット送信要求信号
        );
    err_header  <= err_head_vec(err_arb_num) when (ERR_ENABLE /= 0) else PCIe_TLP_CPL_HEAD_NULL;
    err_arb_ena <= '1' when (ERR_ENABLE /= 0) else '0';
    err_arb_sft <= '1' when (arb_grant = ERR_SEL and TLP_HRDY = '1') else '0';
    -------------------------------------------------------------------------------
    -- 優先順位に基づき各リクエスト信号を調停
    -------------------------------------------------------------------------------
    arb_sel_d <= ERR_SEL when (ERR_ENABLE /= 0 and err_arb_req = '1') else
                 MSG_SEL when (MSG_ENABLE /= 0 and msg_arb_req = '1') else
                 CPL_SEL when (CPL_ENABLE /= 0 and cpl_arb_req = '1') else
                 REQ_SEL when (REQ_ENABLE /= 0 and req_arb_req = '1') else
                 NON_SEL;
    -------------------------------------------------------------------------------
    -- LATENCY = 0 の場合はクロックで叩かずに出力
    -------------------------------------------------------------------------------
    LAT0: if (LATENCY = 0) generate
        arb_grant <= arb_sel_d;
        req_grant <= req_arb_gnt when (REQ_ENABLE /= 0 and arb_sel_d = REQ_SEL) else (others => '0');
        cpl_grant <= cpl_arb_gnt when (CPL_ENABLE /= 0 and arb_sel_d = CPL_SEL) else (others => '0');
        msg_grant <= msg_arb_gnt when (MSG_ENABLE /= 0 and arb_sel_d = MSG_SEL) else (others => '0');
        err_grant <= err_arb_gnt when (ERR_ENABLE /= 0 and arb_sel_d = ERR_SEL) else (others => '0');
        request   <= '1' when (arb_sel_d /= NON_SEL) else '0';
        header    <= To_PCIe_TLP_HEADER(req_header) when (REQ_ENABLE /= 0 and arb_sel_d = REQ_SEL) else
                     To_PCIe_TLP_HEADER(cpl_header) when (CPL_ENABLE /= 0 and arb_sel_d = CPL_SEL) else
                     To_PCIe_TLP_HEADER(msg_header) when (MSG_ENABLE /= 0 and arb_sel_d = MSG_SEL) else
                     To_PCIe_TLP_HEADER(err_header) when (ERR_ENABLE /= 0 and arb_sel_d = ERR_SEL) else
                     PCIe_TLP_HEAD_NULL;
    end generate;
    -------------------------------------------------------------------------------
    -- LATENCY /= 0 の場合は一度クロックで叩いてから出力
    -------------------------------------------------------------------------------
    LAT1: if (LATENCY /= 0) generate
        process (CLK, RST) begin
            if    (RST = '1') then      arb_grant <= NON_SEL;
                                        req_grant <= (others => '0');
                                        cpl_grant <= (others => '0');
                                        msg_grant <= (others => '0');
                                        err_grant <= (others => '0');
                                        request   <= '0';
                                        header    <= PCIe_TLP_HEAD_NULL;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then     arb_grant <= NON_SEL;
                                        req_grant <= (others => '0');
                                        cpl_grant <= (others => '0');
                                        msg_grant <= (others => '0');
                                        err_grant <= (others => '0');
                                        request   <= '0';
                                        header    <= PCIe_TLP_HEAD_NULL;
                elsif (request = '1' and TLP_HRDY = '1') then 
                                        arb_grant <= NON_SEL;
                                        req_grant <= (others => '0');
                                        cpl_grant <= (others => '0');
                                        msg_grant <= (others => '0');
                                        err_grant <= (others => '0');
                                        request   <= '0';
                else
                    case arb_sel_d is
                        when REQ_SEL => arb_grant <= REQ_SEL;
                                        req_grant <= req_arb_gnt;
                                        cpl_grant <= (others => '0');
                                        msg_grant <= (others => '0');
                                        err_grant <= (others => '0');
                                        request   <= '1';
                                        header    <= To_PCIe_TLP_HEADER(req_header);
                        when CPL_SEL => arb_grant <= CPL_SEL;
                                        req_grant <= (others => '0');
                                        cpl_grant <= cpl_arb_gnt;
                                        msg_grant <= (others => '0');
                                        err_grant <= (others => '0');
                                        request   <= '1';
                                        header    <= To_PCIe_TLP_HEADER(cpl_header);
                        when MSG_SEL => arb_grant <= MSG_SEL;
                                        req_grant <= (others => '0');
                                        cpl_grant <= (others => '0');
                                        msg_grant <= msg_arb_gnt;
                                        err_grant <= (others => '0');
                                        request   <= '1';
                                        header    <= To_PCIe_TLP_HEADER(msg_header);
                        when ERR_SEL => arb_grant <= ERR_SEL;
                                        req_grant <= (others => '0');
                                        cpl_grant <= (others => '0');
                                        msg_grant <= (others => '0');
                                        err_grant <= err_arb_gnt;
                                        request   <= '1';
                                        header    <= To_PCIe_TLP_HEADER(err_header);
                        when others  => arb_grant <= NON_SEL;
                                        req_grant <= (others => '0');
                                        cpl_grant <= (others => '0');
                                        msg_grant <= (others => '0');
                                        err_grant <= (others => '0');
                                        request   <= '0';
                                        header    <= To_PCIe_TLP_HEADER(err_header);
                    end case;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    TLP_HVAL <= request;
    TLP_HEAD <= header;
    process (req_grant, cpl_grant, msg_grant)
        alias req_sel_vec : std_logic_vector(REQ_HVAL'range) is req_grant;
        alias cpl_sel_vec : std_logic_vector(CPL_HVAL'range) is cpl_grant;
        alias msg_sel_vec : std_logic_vector(MSG_HVAL'range) is msg_grant;
        alias err_sel_vec : std_logic_vector(ERR_HVAL'range) is err_grant;
    begin
        for i in TLP_HSEL'range loop
            if    (REQ_ENABLE /= 0 and i >= REQ_HVAL'low and i <= REQ_HVAL'high) then
                TLP_HSEL(i) <= req_sel_vec(i);
            elsif (CPL_ENABLE /= 0 and i >= CPL_HVAL'low and i <= CPL_HVAL'high) then
                TLP_HSEL(i) <= cpl_sel_vec(i);
            elsif (MSG_ENABLE /= 0 and i >= MSG_HVAL'low and i <= MSG_HVAL'high) then
                TLP_HSEL(i) <= msg_sel_vec(i);
            elsif (ERR_ENABLE /= 0 and i >= ERR_HVAL'low and i <= ERR_HVAL'high) then
                TLP_HSEL(i) <= err_sel_vec(i);
            else
                TLP_HSEL(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    REQ_HRDY <= req_grant when (REQ_ENABLE /= 0 and TLP_HRDY = '1') else (REQ_HRDY'range => '0');
    CPL_HRDY <= cpl_grant when (CPL_ENABLE /= 0 and TLP_HRDY = '1') else (CPL_HRDY'range => '0');
    MSG_HRDY <= msg_grant when (MSG_ENABLE /= 0 and TLP_HRDY = '1') else (MSG_HRDY'range => '0');
    ERR_HRDY <= err_grant when (ERR_ENABLE /= 0 and TLP_HRDY = '1') else (ERR_HRDY'range => '0');
end RTL;
