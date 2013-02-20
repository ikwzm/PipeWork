-----------------------------------------------------------------------------------
--!     @file    pcie_tlp_rx_decoder.vhd
--!     @brief   PCI-Express TLP Receive Decoder Module.
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
--! @brief   PCI-Express TLP(Transaction Layer Packet) Receive Decoder Module.
-----------------------------------------------------------------------------------
entity  PCIe_TLP_RX_DECODER is
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
        REQ_MIN         : --! @brief REQ_DESC配列の最小引数値.
                          integer := 0;
        REQ_MAX         : --! @brief REQ_DESC配列の最大引数値.
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
        CPL_MIN         : --! @brief CPL_DESC配列の最小引数値.
                          integer := 0;   
        CPL_MAX         : --! @brief CPL_DESC配列の最大引数値.
                          integer := 0;   
        MSG_ENABLE      : --! @brief メッセージパケットを受け付けるかどうかを指定する.
                          --! * MSG_ENABLE=0の場合はメッセージパケットを受け付けない.
                          --!   MSG_ENABLE=0でメッセージパケットを受信した時は、その
                          --!   パケットは読み飛ばされる.
                          --! * MSG_ENABLE=1の場合は、MSG_HVAL/MSG_HACK/MSG_DESC
                          --!   配列の範囲はHSEL配列の範囲内でなければならない.
                          integer := 1;
        MSG_MIN         : --! @brief MSG_DESC配列の最小引数値.
                          integer := 0;
        MSG_MAX         : --! @brief MSG_DESC配列の最大引数値.
                          integer := 0;
        USE_BAR_HIT     : --! @brief BAR_HIT 信号を使うかどうかを指定する.
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
        REQ_HVAL        : out std_logic_vector           (REQ_MIN to REQ_MAX);
        REQ_HRDY        : in  std_logic_vector           (REQ_MIN to REQ_MAX);
        REQ_DESC        : in  PCIe_TLP_REQ_RX_DESC_VECTOR(REQ_MIN to REQ_MAX);
    -------------------------------------------------------------------------------
    -- コンプレッションパケット I/F
    -------------------------------------------------------------------------------
        CPL_HEAD        : out PCIe_TLP_CPL_HEAD_TYPE;
        CPL_HVAL        : out std_logic_vector           (CPL_MIN to CPL_MAX);
        CPL_HRDY        : in  std_logic_vector           (CPL_MIN to CPL_MAX);
        CPL_DESC        : in  PCIe_TLP_CPL_RX_DESC_VECTOR(CPL_MIN to CPL_MAX);
    -------------------------------------------------------------------------------
    -- メッセージパケット I/F
    -------------------------------------------------------------------------------
        MSG_HEAD        : out PCIe_TLP_MSG_HEAD_TYPE;
        MSG_HVAL        : out std_logic_vector           (MSG_MIN to MSG_MAX);
        MSG_HRDY        : in  std_logic_vector           (MSG_MIN to MSG_MAX);
        MSG_DESC        : in  PCIe_TLP_MSG_RX_DESC_VECTOR(MSG_MIN to MSG_MAX);
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
        IO_ENA          : in  std_logic
    );
end PCIe_TLP_RX_DECODER;
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PCIe_TLP_TYPES.all;
architecture RTL of PCIe_TLP_RX_DECODER is
    -------------------------------------------------------------------------------
    -- このモジュール内で使用する各種タイプの定義
    -------------------------------------------------------------------------------
    subtype     REQ_SEL_NUM_TYPE    is integer range REQ_DESC'low to REQ_DESC'high;
    subtype     CPL_SEL_NUM_TYPE    is integer range CPL_DESC'low to CPL_DESC'high;
    subtype     MSG_SEL_NUM_TYPE    is integer range MSG_DESC'low to MSG_DESC'high;
    type        boolean_vector      is array (natural range <>) of boolean;
    -------------------------------------------------------------------------------
    -- ステートマシンの定義
    -------------------------------------------------------------------------------
    type        STATE_TYPE       is ( IDLE, S_REQ, S_CPL, S_MSG, S_ERR);
    signal      state               : STATE_TYPE;
    -------------------------------------------------------------------------------
    -- リクエストパケット用のデコード信号
    -------------------------------------------------------------------------------
    signal      req_hit             : std_logic;
    signal      req_hit_sel         : std_logic_vector(REQ_DESC'range);
    signal      req_sel_num         : REQ_SEL_NUM_TYPE;
    signal      req_header          : PCIe_TLP_REQ_HEAD_TYPE;
    signal      req_decode_hit      : std_logic_vector(REQ_DESC'range);
    signal      req_type_mem        : std_logic;
    signal      req_type_io         : std_logic;
    signal      req_type_cfg0       : std_logic;
    signal      req_type_cfg1       : std_logic;
    -------------------------------------------------------------------------------
    --  コンプレッションパケット用デコード信号
    -------------------------------------------------------------------------------
    signal      cpl_header          : PCIe_TLP_CPL_HEAD_TYPE;
    signal      cpl_hit             : std_logic;
    signal      cpl_hit_sel         : std_logic_vector(CPL_DESC'range);
    signal      cpl_sel_num         : CPL_SEL_NUM_TYPE;
    -------------------------------------------------------------------------------
    -- メッセージパケット用デコード信号
    -------------------------------------------------------------------------------
    signal      msg_hit             : std_logic;
    signal      msg_hit_sel         : std_logic_vector(MSG_DESC'range);
    signal      msg_sel_num         : MSG_SEL_NUM_TYPE;
    -------------------------------------------------------------------------------
    -- ★ ヘッダ保存信号
    -------------------------------------------------------------------------------
    signal      tlp_header          : PCIe_TLP_HEAD_TYPE;
begin
    -------------------------------------------------------------------------------
    -- ★ シーケンサ
    -------------------------------------------------------------------------------
    FSM: process (CLK, RST) begin
        if (RST = '1') then
                state <= IDLE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                state <= IDLE;
            else
                case state is
                   when IDLE => 
                       if (HVAL = '1') then
                           if    (req_hit = '1') then
                               state <= S_REQ;
                           elsif (cpl_hit = '1') then
                               state <= S_CPL;
                           elsif (msg_hit = '1') then
                               state <= S_MSG;
                           elsif (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_IO  ) or
                                 (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_CFG0) or
                                 (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_CFG1) or
                                 (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MEM   and TLP_HEAD.WITH_DATA = '0') or
                                 (TLP_HEAD.PKT_TYPE = PCIe_TLP_PKT_TYPE_MEMLK and TLP_HEAD.WITH_DATA = '0') then
                               state <= S_ERR;
                           else
                               state <= IDLE;
                           end if;
                       else
                               state <= IDLE;
                       end if;
                    when S_REQ =>
                       if (REQ_ENABLE = 0 or REQ_HRDY(req_sel_num) = '1') then
                           state <= IDLE;
                       else
                           state <= S_REQ;
                       end if;
                    when S_CPL =>
                       if (CPL_ENABLE = 0 or CPL_HRDY(cpl_sel_num) = '1') then
                           state <= IDLE;
                       else
                           state <= S_RES;
                       end if;
                    when S_MSG =>
                       if (MSG_ENABLE = 0 or MSG_HRDY(msg_sel_num) = '1') then
                           state <= IDLE;
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
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- tlp_header
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
    -- TLP_HRDY : 
    -------------------------------------------------------------------------------
    TLP_HRDY <= '1' when (state = IDLE and TLP_HVAL = '1') else '0';
    -------------------------------------------------------------------------------
    -- TLP_HHIT : 
    -------------------------------------------------------------------------------
    TLP_HHIT <= '1' when (req_hit = '1' or cpl_hit = '1' or msg_hit = '1') else '0';
    -------------------------------------------------------------------------------
    -- TLP_HSEL : 
    -------------------------------------------------------------------------------
    process (req_hit_sel, res_hit_sel, msg_hit_sel) begin
        for i in TLP_HSEL'range loop
            if    (REQ_ENABLE /= 0 and i >= REQ_DESC'low and i <= REQ_DESC'high) then
                TLP_HSEL(i) <= req_hit_sel(i);
            elsif (CPL_ENABLE /= 0 and i >= CPL_DESC'low and i <= CPL_DESC'high) then
                TLP_HSEL(i) <= cpl_hit_sel(i);
            elsif (MSG_ENABLE /= 0 and i >= MSG_DESC'low and i <= MSG_DESC'high) then
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
    -------------------------------------------------------------------------------
    -- req_sel_num
    -------------------------------------------------------------------------------
    process (CLK, RST) 
        variable num : REQ_SEL_NUM_TYPE;
    begin
        if (RST = '1') then
                req_sel_num <= REQ_DESC'low;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') or
               (REQ_DESC'low = REQ_DESC'high) then
                req_sel_num <= REQ_DESC'low;
            elsif (state = IDLE and TLP_HVAL = '1' and req_hit = '1') then
                num := REQ_DESC'low;
                for i in req_hit_sel'range loop
                    if (req_hit_sel(i) = '1') then
                        num := i;
                        exit;
                    end if;
                end loop;
                req_sel_num <= num;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- REQ_HVAL :
    -------------------------------------------------------------------------------
    process (state, req_sel_num) begin
        for i in REQ_HVAL'range loop
            if (REQ_ENABLE /= 0 and state = S_REQ and i = req_sel_num) then
                REQ_HVAL(i) <= '1';
            else
                REQ_HVAL(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- REQ_HEAD :
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
    -- cpl_header 
    -------------------------------------------------------------------------------
    cpl_header <= To_PCIe_TLP_CPL_HEADER(TLP_HEAD);
    -------------------------------------------------------------------------------
    -- cpl_hit
    -- cpl_hit_sel
    -------------------------------------------------------------------------------
    process (TLP_HVAL, cpl_header, CPL_DESC) 
        variable min_tag_num : integer range 0 to 255;
        variable max_tag_num : integer range 0 to 255;
        variable res_tag_num : integer range 0 to 255;
        variable hit         : std_logic;
        variable hits        : std_logic_vector(CPL_DESC'range);
    begin
        hit  := '0';
        hits := (others => '0');
        if (CPL_ENABLE /= 0) and 
           (TLP_HVAL = '1') and
           ((cpl_header.PKT_TYPE = PCIe_TLP_PKT_TYPE_CPL  )  or
            (cpl_header.PKT_TYPE = PCIe_TLP_PKT_TYPE_CPLLK)) then
            res_tag_num := TO_INTEGER(unsigned(cpl_header.TAG));
            for i in CPL_DESC'range loop
                if (CPL_DESC(i).ENABLE = '1') then
                    min_tag_num := TO_INTEGER(TO_01(unsigned(CPL_DESC(i).MIN_TAG)));
                    max_tag_num := TO_INTEGER(TO_01(unsigned(CPL_DESC(i).MAX_TAG)));
                    if (res_tag_num >= min_tag_num) and
                       (res_tag_num <= max_tag_num) then
                        hits(i) := '1';
                        hit     := '1';
                    else
                        hits(i) := '0';
                    end if;
                else
                        hits(i) := '0';
                end if;
            end loop;
        end if;
        cpl_hit_sel <= hits;
        cpl_hit     <= hit;
    end process;
    -------------------------------------------------------------------------------
    -- cpl_sel_num 
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                cpl_sel_num <= CPL_DESC'low;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                cpl_sel_num <= CPL_DESC'low;
            elsif (CPL_ENABLE /= 0) and 
                  (state = IDLE and TLP_HVAL = '1' and cpl_hit = '1') then
                for i in cpl_hit_sel'range loop
                    if (cpl_hit_sel(i) = '1') then
                        cpl_sel_num <= i;
                        exit;
                    end if;
                end loop;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- CPL_HVAL
    -------------------------------------------------------------------------------
    process (state, cpl_sel_num) begin
        for i in CPL_HVAL'range loop
            if (CPL_ENABLE /= 0 and state = S_CPL and i = cpl_sel_num) then
                CPL_HVAL(i) <= '1';
            else
                CPL_HVAL(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- CPL_HEAD
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
    -- msg_hit
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
    -- msg_hit/msg_sel_num(未実装のため常にMSG_DESC'lowが選択される)
    -------------------------------------------------------------------------------
    process (msg_hit) begin
        for i in MSG_DESC'low to MSG_DESC'high loop
            if (msg_hit = '1' and i = MSG_DESC'low) then
                msg_hit_sel(i) <= '1';
            else
                msg_hit_sel(i) <= '0';
            end if;
        end loop;
    end process;
    msg_sel_num <=  MSG_DESC'low;
    -------------------------------------------------------------------------------
    -- MSG_HVAL
    -------------------------------------------------------------------------------
    process (state, msg_sel_num) begin
        for i in MSG_DESC'range loop
            if (MSG_ENABLE /= 0 and state = S_MSG and i = msg_sel_num) then
                MSG_HVAL(i) <= '1';
            else
                MSG_HVAL(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- MSG_HEAD
    -------------------------------------------------------------------------------
    MSG_HEAD <= To_PCIe_TLP_MSG_HEADER(tlp_header);
    -------------------------------------------------------------------------------
    -- ERR_HVAL
    -- ERR_HEAD
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
        ERR_HEAD.PKT_TYPE  <= req_header.PKT_TYPE;
        ERR_HEAD.TAG       <= req_header.TAG;
        ERR_HEAD.ADDR      <= req_header.ADDR(PCIe_TLP_CPL_ADDR_TYPE'range);
        ERR_HEAD.SIZE      <= std_logic_vector(TO_UNSIGNED(4, PCIe_TLP_SIZE_TYPE'length));
        ERR_HVAL           <= '1' when (state = S_ERR) else '0';
    end block;
end RTL;
