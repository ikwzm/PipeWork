-----------------------------------------------------------------------------------
--!     @file    pcie_tlp_components.vhd                                         --
--!     @brief   PIPEWORK PCI-Express LIBRARY DESCRIPTION                        --
--!     @version 0.0.4                                                           --
--!     @date    2013/03/06                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2013 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
--      All rights reserved.                                                     --
--                                                                               --
--      Redistribution and use in source and binary forms, with or without       --
--      modification, are permitted provided that the following conditions       --
--      are met:                                                                 --
--                                                                               --
--        1. Redistributions of source code must retain the above copyright      --
--           notice, this list of conditions and the following disclaimer.       --
--                                                                               --
--        2. Redistributions in binary form must reproduce the above copyright   --
--           notice, this list of conditions and the following disclaimer in     --
--           the documentation and/or other materials provided with the          --
--           distribution.                                                       --
--                                                                               --
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT    --
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,    --
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT         --
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    --
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY    --
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      --
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE    --
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.     --
--                                                                               --
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.PCIe_TLP_TYPES.all;
use     PIPEWORK.PCIe_TLP_RX_ROUTING;
use     PIPEWORK.PCI_TARGET_SELECT.PCI_TARGET_SELECT_TABLE;
-----------------------------------------------------------------------------------
--! @brief PIPEWORK PCI-Express LIBRARY DESCRIPTION                              --
-----------------------------------------------------------------------------------
package PCIe_COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief PCIe_TLP_RX_ROUTER                                                    --
-----------------------------------------------------------------------------------
component PCIe_TLP_RX_ROUTER
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
    -- Transaction Layer Packet Input Ports.
    -------------------------------------------------------------------------------
        TLP_HEAD        : in  PCIe_TLP_HEAD_TYPE;
        TLP_HVAL        : in  std_logic;
        TLP_HRDY        : out std_logic;
        TLP_HHIT        : out std_logic;
        TLP_HSEL        : out std_logic_vector;
        BAR_HIT         : in  std_logic_vector;
    -------------------------------------------------------------------------------
    -- Request Packet Output Ports.
    -------------------------------------------------------------------------------
        REQ_HEAD        : out PCIe_TLP_REQ_HEAD_TYPE;
        REQ_HVAL        : out std_logic_vector;
        REQ_HRDY        : in  std_logic_vector;
        REQ_TABLE       : in  PCIe_TLP_RX_ROUTING.REQ_TABLE(REQ_TABLE_MIN to REQ_TABLE_MAX);
        TARGET_SEL      : in  PCI_TARGET_SELECT_TABLE(PCI_TARGET_MIN to PCI_TARGET_MAX);
    -------------------------------------------------------------------------------
    -- Completion Packet Output Ports.
    -------------------------------------------------------------------------------
        CPL_HEAD        : out PCIe_TLP_CPL_HEAD_TYPE;
        CPL_HVAL        : out std_logic_vector;
        CPL_HRDY        : in  std_logic_vector;
        CPL_TABLE       : in  PCIe_TLP_RX_ROUTING.CPL_TABLE(CPL_TABLE_MIN to CPL_TABLE_MAX);
    -------------------------------------------------------------------------------
    -- Message Packet Output Ports.
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
    -- Configration Signals.
    -------------------------------------------------------------------------------
        PCIe_ID         : in  PCIe_TLP_ID_TYPE;
        MEM_ENA         : in  std_logic;
        IO_ENA          : in  std_logic;
        PRIMARY         : in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PCIe_TLP_TX_ARBITER                                                   --
-----------------------------------------------------------------------------------
component PCIe_TLP_TX_ARBITER
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
        CPL_ENABLE      : --! @brief コンプレッションパケットを送信するかどうかを指定する.
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
end component;
-----------------------------------------------------------------------------------
--! @brief PCIe_TLP_RX_STREAM_INTERFACE                                          --
-----------------------------------------------------------------------------------
component PCIe_TLP_RX_STREAM_INTERFACE
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
end component;
-----------------------------------------------------------------------------------
--! @brief PCIe_TLP_TX_STREAM_INTERFACE                                          --
-----------------------------------------------------------------------------------
component PCIe_TLP_TX_STREAM_INTERFACE
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
end component;
end PCIe_COMPONENTS;
