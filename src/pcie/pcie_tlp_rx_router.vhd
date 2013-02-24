-----------------------------------------------------------------------------------
--!     @file    pcie_tlp_rx_router.vhd
--!     @brief   PCI-Express TLP Receive Router Module.
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
use     PIPEWORK.PCIe_TLP_RX_ROUTING;
use     PIPEWORK.PCI_TARGET_SELECT.PCI_TARGET_SELECT_TABLE;
-----------------------------------------------------------------------------------
--! @brief   PCI-Express TLP(Transaction Layer Packet) Receive Router Module.
-----------------------------------------------------------------------------------
entity  PCIe_TLP_RX_ROUTER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        REQ_ENABLE      : --! @brief リクエストパケットを受け付けるかどうかを指定する.
                          --! * REQ_ENABLE=0の場合はリクエストパケットを受け付けない.
                          --!   REQ_ENABLE=0でリクエストパケットを受信した時は、パケ
                          --!   ットをすべて読み飛ばす. また、レスポンスパケットが必
                          --!   要なリクエストに関しては、ERR_HEADを生成して、ERR_VAL
                          --!   をアサートしてレスポンスパケットを送信する.
                          integer := 1;
        REQ_TABLE_MIN   : --! @brief REQ_TABLE配列の最小引数値.
                          integer := 0;
        REQ_TABLE_MAX   : --! @brief REQ_TABLE配列の最大引数値.
                          integer := 0;
        REQ_FORCE       : --! @brief リクエストパケットを受信した場合にADDR_MAPで指
                          --! 定されたアクセス条件に関わらず常に受け付けるか、
                          --! ADDR_MAPで指定されたアクセス条件の場合のみを受け付ける
                          --! かを指定する. 
                          --! * REQ_FORCE=0の場合は、リクエストパケットを常に受け付
                          --!   ける. その際、ADDR_MAP(1)の内容が選択される.
                          --! * この変数は Xilinx社の PCI-Express コアを使うための
                          --!   一時的な方便である。
                          integer := 0;
        PCI_TARGET_MIN  : --! @brief PCI_TARGET_SEL配列の最小引き数値.
                          integer := 0;
        PCI_TARGET_MAX  : --! @brief PCI_TARGET_SEL配列の最大引き数値.
                          integer := 0;
        CPL_ENABLE      : --! @brief コンプレッションパケットを受け付けるかどうかを指定する.
                          --! * CPL_ENABLE=0の場合はコンプレッションパケットを受け
                          --!   付けない. CPL_ENABLE=0でコンプレッションパケットを
                          --!   受信した時は、そのパケットは読み飛ばされる.
                          --! * CPL_ENABLE=1の場合はCPL_DESCで指定されたコンプレッ
                          --!   ションパケットのみを受け付ける.
                          --!   CPL_DESCで指定されていないコンプレッションパケット
                          --!   を受信した時は、そのパケットは読み飛ばされる.
                          --! * CPL_ENABLE=1の場合は、CPL_HVAL/CPL_HACK/CPL_DESC
                          --!   配列の範囲はTLP_HSEL配列の範囲内でなければならない.
                          integer := 1;
        CPL_TABLE_MIN   : --! @brief CPL_TABLE配列の最小引数値.
                          integer := 0;   
        CPL_TABLE_MAX   : --! @brief CPL_TABLE配列の最大引数値.
                          integer := 0;
        CPL_TAG_MIN     : --! @brief
                          integer := 0;
        CPL_TAG_MAX     : --! @brief
                          integer := 31;
        MSG_ENABLE      : --! @brief メッセージパケットを受け付けるかどうかを指定する.
                          --! * MSG_ENABLE=0の場合はメッセージパケットを受け付けない.
                          --!   MSG_ENABLE=0でメッセージパケットを受信した時は、その
                          --!   パケットは読み飛ばされる.
                          --! * MSG_ENABLE=1の場合は、MSG_HVAL/MSG_HACK/MSG_DESC
                          --!   配列の範囲はHSEL配列の範囲内でなければならない.
                          integer := 1;
        MSG_TABLE_MIN   : --! @brief MSG_TABLE配列の最小引数値.
                          integer := 0;
        MSG_TABLE_MAX   : --! @brief MSG_TABLE配列の最大引数値.
                          integer := 0;
        USE_BAR_HIT     : --! @brief BAR_HIT 信号を使うかどうかを指定する.
                          integer := 0;
        PCI_TO_PCI      : --! @brief PCI-PCI ブリッジをサポートするか否かを指定する.
                          integer := 0
    );
    port (
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
    -- TLP(Transaction Layer Packet)入力
    -------------------------------------------------------------------------------
        TLP_HEAD        : in  PCIe_TLP_HEAD_TYPE;
        TLP_HVAL        : in  std_logic;
        TLP_HRDY        : out std_logic;
        TLP_HHIT        : out std_logic;
        TLP_HSEL        : out std_logic_vector;
        BAR_HIT         : in  std_logic_vector;
    -------------------------------------------------------------------------------
    -- リクエストパケット I/F
    -------------------------------------------------------------------------------
        REQ_HEAD        : out PCIe_TLP_REQ_HEAD_TYPE;
        REQ_HVAL        : out std_logic_vector;
        REQ_HRDY        : in  std_logic_vector;
        REQ_TABLE       : in  PCIe_TLP_RX_ROUTING.REQ_TABLE(REQ_TABLE_MIN to REQ_TABLE_MAX);
        TARGET_SEL      : in  PCI_TARGET_SELECT_TABLE(PCI_TARGET_MIN to PCI_TARGET_MAX);
    -------------------------------------------------------------------------------
    -- コンプレッションパケット I/F
    -------------------------------------------------------------------------------
        CPL_HEAD        : out PCIe_TLP_CPL_HEAD_TYPE;
        CPL_HVAL        : out std_logic_vector;
        CPL_HRDY        : in  std_logic_vector;
        CPL_TABLE       : in  PCIe_TLP_RX_ROUTING.CPL_TABLE(CPL_TABLE_MIN to CPL_TABLE_MAX);
    -------------------------------------------------------------------------------
    -- メッセージパケット I/F
    -------------------------------------------------------------------------------
        MSG_HEAD        : out PCIe_TLP_MSG_HEAD_TYPE;
        MSG_HVAL        : out std_logic_vector;
        MSG_HRDY        : in  std_logic_vector;
        MSG_TABLE       : in  PCIe_TLP_RX_ROUTING.MSG_TABLE(MSG_TABLE_MIN to MSG_TABLE_MAX);
    -------------------------------------------------------------------------------
    -- 不正なリクエストパケットを受けとった時のレスポンスパケット送信 I/F
    -------------------------------------------------------------------------------
        ERR_HEAD        : out PCIe_TLP_CPL_HEAD_TYPE;
        ERR_HVAL        : out std_logic;
        ERR_HRDY        : in  std_logic;
    -------------------------------------------------------------------------------
    -- Configrationモジュールとやりとりするための信号たち。
    -------------------------------------------------------------------------------
        PCIe_ID         : in  PCIe_TLP_ID_TYPE;
        MEM_ENA         : in  std_logic;
        IO_ENA          : in  std_logic;
        PRIMARY         : in  std_logic
    );
end PCIe_TLP_RX_ROUTER;
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PCIe_TLP_TYPES.all;
use     PIPEWORK.PCI_TARGET_SELECT.all;
architecture RTL of PCIe_TLP_RX_ROUTER is
    -------------------------------------------------------------------------------
    -- ステートマシンの定義
    -------------------------------------------------------------------------------
    type        STATE_TYPE       is ( IDLE, S_REQ, S_CPL, S_MSG, S_ERR);
    signal      state               : STATE_TYPE;
    -------------------------------------------------------------------------------
    -- リクエストパケット用のデコード信号
    -------------------------------------------------------------------------------
    signal      req_header          : PCIe_TLP_REQ_HEAD_TYPE;
    signal      req_hit             : std_logic;
    signal      req_hit_sel         : std_logic_vector(REQ_TABLE'range);
    signal      req_type_mem        : std_logic;
    signal      req_type_io         : std_logic;
    signal      req_type_cfg0       : std_logic;
    signal      req_type_cfg1       : std_logic;
    signal      req_valid           : std_logic_vector(REQ_HVAL'range);
    constant    REQ_VALID_ALL0      : std_logic_vector(REQ_HVAL'range) := (others => '0');
    signal      target_sel_hit      : std_logic_vector(TARGET_SEL'range);
    -------------------------------------------------------------------------------
    --  コンプレッションパケット用デコード信号
    -------------------------------------------------------------------------------
    signal      cpl_header          : PCIe_TLP_CPL_HEAD_TYPE;
    signal      cpl_hit             : std_logic;
    signal      cpl_hit_sel         : std_logic_vector(CPL_TABLE'range);
    signal      cpl_valid           : std_logic_vector(CPL_HVAL'range);
    constant    CPL_VALID_ALL0      : std_logic_vector(CPL_HVAL'range) := (others => '0');
    -------------------------------------------------------------------------------
    -- メッセージパケット用デコード信号
    -------------------------------------------------------------------------------
    signal      msg_hit             : std_logic;
    signal      msg_hit_sel         : std_logic_vector(MSG_TABLE'range);
    signal      msg_valid           : std_logic_vector(MSG_HVAL'range);
    constant    MSG_VALID_ALL0      : std_logic_vector(MSG_HVAL'range) := (others => '0');
    -------------------------------------------------------------------------------
    -- ヘッダ保存信号
    -------------------------------------------------------------------------------
    signal      tlp_header          : PCIe_TLP_HEAD_TYPE;
begin
    -------------------------------------------------------------------------------
    -- シーケンサ  :
    -------------------------------------------------------------------------------
    FSM: process (CLK, RST)
        procedure SET_VALID(signal VAL:out std_logic_vector;HIT_SEL:in std_logic_vector) is
        begin
            for i in VAL'range loop
                if (HIT_SEL(i) = '1') then
                    VAL(i) <= '1';
                else
                    VAL(i) <= '0';
                end if;
            end loop;
        end procedure;
        procedure CLR_VALID(signal VAL:out std_logic_vector) is
        begin
            VAL <= (VAL'range => '0');
        end procedure;
    begin
        if (RST = '1') then
                state <= IDLE;
                CLR_VALID(req_valid);
                CLR_VALID(cpl_valid);
                CLR_VALID(msg_valid);
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                state <= IDLE;
                CLR_VALID(req_valid);
                CLR_VALID(cpl_valid);
                CLR_VALID(msg_valid);
            else
                case state is
                   when IDLE => 
                       if (TLP_HVAL = '1') then
                           if    (req_hit = '1') then
                               state   <= S_REQ;
                               SET_VALID(req_valid, req_hit_sel);
                               CLR_VALID(cpl_valid);
                               CLR_VALID(msg_valid);
                           elsif (cpl_hit = '1') then
                               state   <= S_CPL;
                               CLR_VALID(req_valid);
                               SET_VALID(cpl_valid, cpl_hit_sel);
                               CLR_VALID(msg_valid);
                           elsif (msg_hit = '1') then
                               state <= S_MSG;
                               CLR_VALID(req_valid);
                               CLR_VALID(cpl_valid);
                               SET_VALID(msg_valid, msg_hit_sel);
                           elsif (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_IO  ) or
                                 (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_CFG0) or
                                 (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_CFG1) or
                                 (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MEM   and TLP_HEAD.WITH_DATA = '0') or
                                 (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MEMLK and TLP_HEAD.WITH_DATA = '0') then
                               state <= S_ERR;
                               CLR_VALID(req_valid);
                               CLR_VALID(cpl_valid);
                               CLR_VALID(msg_valid);
                           else
                               state <= IDLE;
                               CLR_VALID(req_valid);
                               CLR_VALID(cpl_valid);
                               CLR_VALID(msg_valid);
                           end if;
                       else
                               state <= IDLE;
                               CLR_VALID(req_valid);
                               CLR_VALID(cpl_valid);
                               CLR_VALID(msg_valid);
                       end if;
                    when S_REQ =>
                       if (REQ_ENABLE = 0 or ((REQ_HRDY and req_valid) /= REQ_VALID_ALL0)) then
                               state <= IDLE;
                               CLR_VALID(req_valid);
                       else
                               state <= S_REQ;
                       end if;
                    when S_CPL =>
                       if (CPL_ENABLE = 0 or ((CPL_HRDY and cpl_valid) /= CPL_VALID_ALL0)) then
                               state <= IDLE;
                               CLR_VALID(cpl_valid);
                       else
                               state <= S_CPL;
                       end if;
                    when S_MSG =>
                       if (MSG_ENABLE = 0 or ((MSG_HRDY and msg_valid) /= MSG_VALID_ALL0)) then
                               state <= IDLE;
                               CLR_VALID(msg_valid);
                       else
                               state <= S_MSG;
                       end if;
                    when S_ERR =>
                       if (ERR_HRDY = '1') then
                               state <= IDLE;
                       else
                               state <= S_ERR;
                       end if;
                    when others =>
                               state <= IDLE;
                               CLR_VALID(req_valid);
                               CLR_VALID(cpl_valid);
                               CLR_VALID(msg_valid);
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- tlp_header  :
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                tlp_header <= PCIe_TLP_HEAD_NULL;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                tlp_header <= PCIe_TLP_HEAD_NULL;
            elsif (state = IDLE and TLP_HVAL = '1') then
                tlp_header <= TLP_HEAD;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- TLP_HRDY    : 
    -------------------------------------------------------------------------------
    TLP_HRDY <= '1' when (state = IDLE and TLP_HVAL = '1') else '0';
    -------------------------------------------------------------------------------
    -- TLP_HHIT    : 
    -------------------------------------------------------------------------------
    TLP_HHIT <= '1' when (req_hit = '1' or cpl_hit = '1' or msg_hit = '1') else '0';
    -------------------------------------------------------------------------------
    -- TLP_HSEL    : 
    -------------------------------------------------------------------------------
    process (req_hit_sel, cpl_hit_sel, msg_hit_sel) begin
        for i in TLP_HSEL'range loop
            if    (REQ_ENABLE /= 0 and i >= REQ_TABLE'low and i <= REQ_TABLE'high) then
                TLP_HSEL(i) <= req_hit_sel(i);
            elsif (CPL_ENABLE /= 0 and i >= CPL_TABLE'low and i <= CPL_TABLE'high) then
                TLP_HSEL(i) <= cpl_hit_sel(i);
            elsif (MSG_ENABLE /= 0 and i >= MSG_TABLE'low and i <= MSG_TABLE'high) then
                TLP_HSEL(i) <= msg_hit_sel(i);
            else
                TLP_HSEL(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- リクエストパケットのデコード
    -------------------------------------------------------------------------------
    req_header    <= To_PCIe_TLP_REQ_HEADER(TLP_HEAD);
    req_type_io   <= '1' when (req_header.PKT_TYPE = PCIe_TLP_PKT_TYPE_IO   ) else '0';
    req_type_mem  <= '1' when (req_header.PKT_TYPE = PCIe_TLP_PKT_TYPE_MEM  ) or
                              (req_header.PKT_TYPE = PCIe_TLP_PKT_TYPE_MEMLK) else '0';
    req_type_cfg0 <= '1' when (req_header.PKT_TYPE = PCIe_TLP_PKT_TYPE_CFG0 ) else '0';
    req_type_cfg1 <= '1' when (req_header.PKT_TYPE = PCIe_TLP_PKT_TYPE_CFG1 ) else '0';
    REQ_SEL: PCI_TARGET_SELECTER
        generic map (
            ENABLE      => REQ_ENABLE          , -- 
            FORCE       => REQ_FORCE           , -- 
            USE_BAR_HIT => USE_BAR_HIT         , -- 
            PCI_TO_PCI  => PCI_TO_PCI          , -- 
            PCI_EXPRESS => 1                   , -- 
            TARGET_MIN  => PCI_TARGET_MIN      , -- 
            TARGET_MAX  => PCI_TARGET_MAX        -- 
        )                                        -- 
        port map (                               -- 
            T_BAR_HIT   => BAR_HIT             , -- In  :ベースアドレスレジスタヒット
            T_ADDR      => req_header.ADDR     , -- In  : アドレス
            T_AD64      => req_header.HEAD_LEN , -- In  : Address Size(0=32bit/1=64bit)
            T_IO        => req_type_io         , -- In  : I/O Access
            T_MEM       => req_type_mem        , -- In  : Memory Access
            T_CFG0      => req_type_cfg0       , -- In  : Type0 Configuration Access
            HIT         => req_hit             , -- Out : 
            ENA64       => open                , -- Out :
            HIT_SEL     => target_sel_hit      , -- Out :
            TARGET_SEL  => TARGET_SEL          , -- In  : ターゲット選択記述
            MEM_ENA     => MEM_ENA             , -- In  : メモリアクセス許可信号
            IO_ENA      => IO_ENA              , -- In  : I/Oアクセス許可信号
            PRIMARY     => PRIMARY               -- In  : １次バス側/２次バス側
        );
    -------------------------------------------------------------------------------
    -- req_hit_sel : 
    -------------------------------------------------------------------------------
    process (TLP_HVAL, REQ_TABLE, req_hit, target_sel_hit, req_header) 
        variable sel : std_logic_vector(REQ_TABLE'range);
        variable hit : boolean;
    begin
        sel := (others => '0');
        if (TLP_HVAL = '1' and req_hit = '1') then
            for i in REQ_TABLE'range loop
                hit := FALSE;
                for target_num in target_sel_hit'range loop
                    if (REQ_TABLE(i).TARGET_SELECT(target_num) = '1') and
                       (target_sel_hit(target_num) = '1') then
                        hit := TRUE;
                    end if;
                end loop;
                if (hit = TRUE) and
                   ((REQ_TABLE(i).READ  = '1' and req_header.TRAN_TYPE = PCIe_TLP_REQ_TRAN_READ ) or
                    (REQ_TABLE(i).WRITE = '1' and req_header.TRAN_TYPE = PCIe_TLP_REQ_TRAN_WRITE) or
                    (REQ_TABLE(i).WRITE = '1' and req_header.TRAN_TYPE = PCIe_TLP_REQ_TRAN_FLUSH)) then
                    sel(i) := '1';
                    exit;
                end if;
            end loop;
        end if;
        req_hit_sel <= sel;
    end process;
    -------------------------------------------------------------------------------
    -- REQ_HVAL    :
    -------------------------------------------------------------------------------
    REQ_HVAL <= req_valid;
    -------------------------------------------------------------------------------
    -- REQ_HEAD    :
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                REQ_HEAD <= PCIe_TLP_REQ_HEAD_NULL;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                REQ_HEAD <= PCIe_TLP_REQ_HEAD_NULL;
            elsif (REQ_ENABLE /= 0 and state = IDLE and TLP_HVAL = '1') then
                REQ_HEAD <= req_header;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- cpl_hit     :
    -- cpl_hit_sel :
    -- cpl_header  :
    -------------------------------------------------------------------------------
    process (TLP_HVAL, TLP_HEAD, CPL_TABLE)
        variable cpl_head     : PCIe_TLP_CPL_HEAD_TYPE;
        variable cpl_tag_num  : integer range 0 to 255;
        variable tag_hit      : boolean;
        variable hit_sel      : std_logic_vector(CPL_TABLE'range);
        constant hit_sel_all0 : std_logic_vector(CPL_TABLE'range) := (others => '0');
    begin
        cpl_head := To_PCIe_TLP_CPL_HEADER(TLP_HEAD);
        hit_sel  := hit_sel_all0;
        if (CPL_ENABLE /= 0) and 
           (TLP_HVAL = '1') and
           ((TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_CPL  )  or
            (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_CPLLK)) then
            cpl_tag_num := TO_INTEGER(unsigned(cpl_head.TAG));
            for i in CPL_TABLE'range loop
                if (CPL_TABLE(i).ENABLE = '1') then
                    tag_hit := FALSE;
                    for tag in CPL_TAG_MIN to CPL_TAG_MAX loop
                        if (tag = cpl_tag_num and CPL_TABLE(i).TAG_SELECT_MAP(tag) = '1') then
                            tag_hit := TRUE;
                        end if;
                    end loop;
                    if (tag_hit) then
                        hit_sel(i) := '1';
                    else
                        hit_sel(i) := '0';
                    end if;
                end if;
            end loop;
        end if;
        cpl_header  <= cpl_head;
        cpl_hit_sel <= hit_sel;
        if (hit_sel /= hit_sel_all0) then
            cpl_hit <= '1';
        else
            cpl_hit <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- CPL_HVAL    :
    -------------------------------------------------------------------------------
    CPL_HVAL <= cpl_valid;
    -------------------------------------------------------------------------------
    -- CPL_HEAD    :
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                CPL_HEAD <= PCIe_TLP_CPL_HEAD_NULL;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                CPL_HEAD <= PCIe_TLP_CPL_HEAD_NULL;
            elsif (CPL_ENABLE /= 0 and state = IDLE and TLP_HVAL = '1') then
                CPL_HEAD <= cpl_header;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- msg_hit     :
    -------------------------------------------------------------------------------
    msg_hit <= '1' when (MSG_ENABLE /= 0) and 
                        ((TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MSG0) or
                         (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MSG1) or
                         (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MSG2) or
                         (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MSG3) or
                         (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MSG4) or
                         (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MSG5) or
                         (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MSG6) or
                         (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MSG7)) else '0';
    -------------------------------------------------------------------------------
    -- MSG_HVAL    :
    -------------------------------------------------------------------------------
    MSG_HVAL <= msg_valid;
    -------------------------------------------------------------------------------
    -- MSG_HEAD    :
    -------------------------------------------------------------------------------
    MSG_HEAD <= To_PCIe_TLP_MSG_HEADER(tlp_header);
    -------------------------------------------------------------------------------
    -- ERR_HVAL    :
    -- ERR_HEAD    :
    -------------------------------------------------------------------------------
    ERR_BLK: block  
        signal req_header : PCIe_TLP_REQ_HEAD_TYPE;
    begin
        req_header         <= To_PCIe_TLP_REQ_HEADER(tlp_header);
        ERR_HEAD.WITH_DATA <= '0';
        ERR_HEAD.TC        <= req_header.TC;
        ERR_HEAD.TD        <= req_header.TD;
        ERR_HEAD.EP        <= req_header.EP;
        ERR_HEAD.ATTR      <= req_header.ATTR;
        ERR_HEAD.LOCK      <= '0';
        ERR_HEAD.CPL_ID    <= PCIe_ID;
        ERR_HEAD.STATUS    <= PCIe_TLP_CPL_UNSUPPORT;
        ERR_HEAD.BCM       <= '0';
        ERR_HEAD.COUNT     <= req_header.SIZE;
        ERR_HEAD.REQ_ID    <= req_header.REQ_ID;
        ERR_HEAD.REQ_TYPE  <= req_header.PKT_TYPE;
        ERR_HEAD.TAG       <= req_header.TAG;
        ERR_HEAD.ADDR      <= req_header.ADDR(PCIe_TLP_CPL_ADDR_TYPE'range);
        ERR_HEAD.SIZE      <= std_logic_vector(TO_UNSIGNED(4, PCIe_TLP_SIZE_TYPE'length));
        ERR_HVAL           <= '1' when (state = S_ERR) else '0';
    end block;
end RTL;
