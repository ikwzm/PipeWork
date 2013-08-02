-----------------------------------------------------------------------------------
--!     @file    pcie_tlp_types.vhd
--!     @brief   PCI-Express TLP(Transaction Layer Packet) Type Package.
--!     @version 0.0.2
--!     @date    2013/3/2
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
-----------------------------------------------------------------------------------
--! @brief PCI-Express TLP(Transaction Layer Packet)の各種タイプ/定数を定義している
--!        パッケージ.
-----------------------------------------------------------------------------------
package PCIe_TLP_TYPES is

    -------------------------------------------------------------------------------
    --! @brief PCIe_TLP_HEAD_TYPE.PKT_TYPE のタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_PKT_TYPE         is std_logic_vector(4 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe_TLP_HEAD_TYPE.PKT_TYPE の値. 
    -------------------------------------------------------------------------------
    constant PCIe_TLP_PKT_TYPE_NULL     : PCIe_TLP_PKT_TYPE := "00000";
    constant PCIe_TLP_PKT_TYPE_MEM      : PCIe_TLP_PKT_TYPE := "00000";
    constant PCIe_TLP_PKT_TYPE_MEMLK    : PCIe_TLP_PKT_TYPE := "00001";
    constant PCIe_TLP_PKT_TYPE_IO       : PCIe_TLP_PKT_TYPE := "00010";
    constant PCIe_TLP_PKT_TYPE_CFG0     : PCIe_TLP_PKT_TYPE := "00100";
    constant PCIe_TLP_PKT_TYPE_CFG1     : PCIe_TLP_PKT_TYPE := "00101";
    constant PCIe_TLP_PKT_TYPE_MSG0     : PCIe_TLP_PKT_TYPE := "10000";
    constant PCIe_TLP_PKT_TYPE_MSG1     : PCIe_TLP_PKT_TYPE := "10001";
    constant PCIe_TLP_PKT_TYPE_MSG2     : PCIe_TLP_PKT_TYPE := "10010";
    constant PCIe_TLP_PKT_TYPE_MSG3     : PCIe_TLP_PKT_TYPE := "10011";
    constant PCIe_TLP_PKT_TYPE_MSG4     : PCIe_TLP_PKT_TYPE := "10100";
    constant PCIe_TLP_PKT_TYPE_MSG5     : PCIe_TLP_PKT_TYPE := "10101";
    constant PCIe_TLP_PKT_TYPE_MSG6     : PCIe_TLP_PKT_TYPE := "10110";
    constant PCIe_TLP_PKT_TYPE_MSG7     : PCIe_TLP_PKT_TYPE := "10111";
    constant PCIe_TLP_PKT_TYPE_CPL      : PCIe_TLP_PKT_TYPE := "01010";
    constant PCIe_TLP_PKT_TYPE_CPLLK    : PCIe_TLP_PKT_TYPE := "01011";
    -------------------------------------------------------------------------------
    --! @brief PCIe_TLP_CPL_HEAD_TYPE.STATUS のタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_CPL_STATUS_TYPE  is std_logic_vector(2 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe_TLP_CPL_HEAD_TYPE.STATUS の値. 
    -------------------------------------------------------------------------------
    constant PCIe_TLP_CPL_STATUS_NULL   : PCIe_TLP_CPL_STATUS_TYPE := "000";
    constant PCIe_TLP_CPL_SUCCESS       : PCIe_TLP_CPL_STATUS_TYPE := "000";
    constant PCIe_TLP_CPL_UNSUPPORT     : PCIe_TLP_CPL_STATUS_TYPE := "001";
    constant PCIe_TLP_CPL_CFG_RETRY     : PCIe_TLP_CPL_STATUS_TYPE := "010";
    constant PCIe_TLP_CPL_ABORT         : PCIe_TLP_CPL_STATUS_TYPE := "100";
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP で使用するアドレスのタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_ADDR_TYPE        is std_logic_vector(63 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP で使用するサイズのタイプ バイト単位かつ最大4Kバイト. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_SIZE_TYPE        is std_logic_vector(12 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP で使用する Requester ID および Completer ID のタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_ID_TYPE          is std_logic_vector(15 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP で使用する Tag のタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_TAG_TYPE         is std_logic_vector( 7 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP で使用する TC(Transaction Class) のタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_TC_TYPE          is std_logic_vector( 2 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP で使用する Attribute のタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_ATTR_TYPE        is std_logic_vector( 1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP で使用する VC(Virtual Channel) のタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_VC_TYPE          is std_logic_vector( 2 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP リクエストパケットで使用するアドレスのタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_REQ_ADDR_TYPE    is std_logic_vector(63 downto 0);
    -------------------------------------------------------------------------------
    --! @brief PCIE TLP リクエストパケットのトランザクションタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_REQ_TRAN_TYPE    is std_logic_vector( 1 downto 0);
    constant PCIe_TLP_REQ_TRAN_NULL     : PCIe_TLP_REQ_TRAN_TYPE := "00";
    constant PCIe_TLP_REQ_TRAN_READ     : PCIe_TLP_REQ_TRAN_TYPE := "01";
    constant PCIe_TLP_REQ_TRAN_WRITE    : PCIe_TLP_REQ_TRAN_TYPE := "10";
    constant PCIe_TLP_REQ_TRAN_FLUSH    : PCIe_TLP_REQ_TRAN_TYPE := "11";
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP コンプレッションパケットで使用するアドレスのタイプ. 
    -------------------------------------------------------------------------------
    subtype  PCIe_TLP_CPL_ADDR_TYPE    is std_logic_vector( 6 downto 0);
    -------------------------------------------------------------------------------
    --! @brief TLP(Transaction Layer Packet)のヘッダー部を記述した構造体. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!   後述の PCIe_TLP_REQ_HEAD_TYPE(リクエストパケットのヘッダー部を記述した構
    --!   造体)、PCIe_TLP_CPL_HEAD_TYPE(コンプレッションパケットのヘッダー部を記述
    --!   した構造体)、PCIe_TLP_MSG_HEAD_TYPE(メッセージパケットのヘッダー部を記述
    --!   した構造体)を単一の構造体で統一的に扱いたい時に使用する. 
    -------------------------------------------------------------------------------
    type  PCIe_TLP_HEAD_TYPE is record
        ---------------------------------------------------------------------------
        --! @brief Header Length (Fmt[0]) ヘッダーの長さを示す.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! * '1' = ヘッダーは4DW(16バイト,128bit)長. 
        --! * '0' = ヘッダーは3DW(12バイト,96bit)長. 
        ---------------------------------------------------------------------------
        HEAD_LEN        : std_logic;
        ---------------------------------------------------------------------------
        --! @brief With Data (Fmt[1]) データを伴うかどうかを示す.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! * '1' = データあり. 
        --! * '0' = データなし. 
        ---------------------------------------------------------------------------
        WITH_DATA       : std_logic;
        ---------------------------------------------------------------------------
        --! @brief Packet Type (Type[4:0]) パケットの種類を示す. 
        ---------------------------------------------------------------------------
        PKT_TYPE        : PCIe_TLP_PKT_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Traffic Class. 
        ---------------------------------------------------------------------------
        TC              : PCIe_TLP_TC_TYPE;
        ---------------------------------------------------------------------------
        --! @brief TLP Digest Field Present. 
        ---------------------------------------------------------------------------
        TD              : std_logic;
        ---------------------------------------------------------------------------
        --! @brief Poisoned Data. 
        ---------------------------------------------------------------------------
        EP              : std_logic;
        ---------------------------------------------------------------------------
        --! @brief Attributes. 
        ---------------------------------------------------------------------------
        ATTR            : PCIe_TLP_ATTR_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Data Length(ワード(32bit)単位). 
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! * 00-0000-0001 = 1DW. 
        --! * 00-0000-0010 = 2DW. 
        --! * 11-1111-1111 = 1023DW. 
        --! * 00-0000-0000 = 1024DW. 
        ---------------------------------------------------------------------------
        DATA_LEN        : std_logic_vector( 9 downto 0);
        ---------------------------------------------------------------------------
        --! @brief ヘッダの2DW目に格納されているパケットの種類に依存した各種情報. 
        ---------------------------------------------------------------------------
        INFO            : std_logic_vector(31 downto 0);
        ---------------------------------------------------------------------------
        --! @brief アドレス情報またはヘッダの3DW〜4DW目に格納されているパケットの
        --!        種類に依存した各種情報. 
        ---------------------------------------------------------------------------
        ADDR            : std_logic_vector(63 downto 0);
        ---------------------------------------------------------------------------
        --! @brief データワード位置. 
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! この情報はTLP(Transaction Layer Packet)のヘッダに含まれるものではなく、
        --! 送信パケット生成時において、送信するペイロードデータの最初のワードの開
        --! 始位置を指示するためのもの.    
        --! Mem Read のコンプレッションパケットの場合は、ヘッダにアドレスを含むので
        --! このフィールドは意味無いが、IO Read/Write, Config Read/Write のコンプレ
        --! ッションパケットの場合は、通常のヘッダ内のアドレスは０クリアされてしま
        --! っているので、アドレス情報を別のフィールドで保持しておかなければならない.
        ---------------------------------------------------------------------------
        WORD_POS        : std_logic_vector( 6 downto 2);
    end record;
    -------------------------------------------------------------------------------
    --! @brief リクエストパケットのヘッダー部を記述した構造体. 
    -------------------------------------------------------------------------------
    type  PCIe_TLP_REQ_HEAD_TYPE is record
        ---------------------------------------------------------------------------
        -- PCIe_TLP_HEAD_TYPE と共通部 : 詳細は PCIe_TLP_HEAD_TYPE を参照. 
        ---------------------------------------------------------------------------
        HEAD_LEN        : std_logic;
        PKT_TYPE        : PCIe_TLP_PKT_TYPE;
        TC              : PCIe_TLP_TC_TYPE;
        TD              : std_logic;
        EP              : std_logic;
        ATTR            : PCIe_TLP_ATTR_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Requester ID. 
        ---------------------------------------------------------------------------
        REQ_ID          : PCIe_TLP_ID_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Tag. 
        ---------------------------------------------------------------------------
        TAG             : PCIe_TLP_TAG_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Transaction Request Address. 
        ---------------------------------------------------------------------------
        ADDR            : PCIe_TLP_REQ_ADDR_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Transaction Request Byte Size. 
        ---------------------------------------------------------------------------
        SIZE            : PCIe_TLP_SIZE_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Transaction Request Type. 
        ---------------------------------------------------------------------------
        TRAN_TYPE       : PCIe_TLP_REQ_TRAN_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief コンプレッションパケットのヘッダー部を記述した構造体. 
    -------------------------------------------------------------------------------
    type  PCIe_TLP_CPL_HEAD_TYPE is record
        ---------------------------------------------------------------------------
        -- PCIe_TLP_HEAD_TYPE と共通部: 詳細は PCIe_TLP_HEAD_TYPE を参照. 
        ---------------------------------------------------------------------------
        WITH_DATA       : std_logic;
        TC              : PCIe_TLP_TC_TYPE;
        TD              : std_logic;
        EP              : std_logic;
        ATTR            : PCIe_TLP_ATTR_TYPE;
        ---------------------------------------------------------------------------
        --! @brief LOCK. 
        ---------------------------------------------------------------------------
        LOCK            : std_logic;
        ---------------------------------------------------------------------------
        --! @brief Completer ID. 
        ---------------------------------------------------------------------------
        CPL_ID          : PCIe_TLP_ID_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Completion Status. 
        ---------------------------------------------------------------------------
        STATUS          : PCIe_TLP_CPL_STATUS_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Byte Count Modified. 
        ---------------------------------------------------------------------------
        BCM             : std_logic;
        ---------------------------------------------------------------------------
        --! @brief Byte Count(残りの転送バイト数). 
        ---------------------------------------------------------------------------
        COUNT           : PCIe_TLP_SIZE_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Requester ID. 
        ---------------------------------------------------------------------------
        REQ_ID          : PCIe_TLP_ID_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Tag. 
        ---------------------------------------------------------------------------
        TAG             : PCIe_TLP_TAG_TYPE;
        ---------------------------------------------------------------------------
        --! @ brief Requester TLP Type. 
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! これは PCIe_TLP_CPL_HEAD_TYPE -> PCIe_TLP_HEAD_TYPE に変換する場合でのみ
        --! 使用する. PCIe_TLP_HEAD_TYPE -> PCIe_TLP_CPL_HEAD_TYPE に変換した場合は、
        --! PCIe_TLP_HEAD_TYPE の PKT_TYPE がセットされる. 
        ---------------------------------------------------------------------------
        REQ_TYPE        : PCIe_TLP_PKT_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Completion Low Address. 
        ---------------------------------------------------------------------------
        ADDR            : PCIe_TLP_CPL_ADDR_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Payload Size(パケットに含まれるデータのバイト数). 
        ---------------------------------------------------------------------------
        SIZE            : PCIe_TLP_SIZE_TYPE;
        ---------------------------------------------------------------------------
        --! @brief 最後のペイロードパケットであることを示すフラグ. 
        ---------------------------------------------------------------------------
        LAST            : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief メッセージパケットのヘッダー部を記述した構造体. 
    -------------------------------------------------------------------------------
    type  PCIe_TLP_MSG_HEAD_TYPE is record
        ---------------------------------------------------------------------------
        -- PCIe_TLP_HEAD_TYPE と共通部: 詳細は PCIe_TLP_HEAD_TYPE を参照. 
        ---------------------------------------------------------------------------
        WITH_DATA       : std_logic;
        TC              : PCIe_TLP_TC_TYPE;
        TD              : std_logic;
        EP              : std_logic;
        ATTR            : PCIe_TLP_ATTR_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Routing. 
        ---------------------------------------------------------------------------
        ROUTING         : std_logic_vector( 2 downto 0);
        ---------------------------------------------------------------------------
        --! @brief Requester ID. 
        ---------------------------------------------------------------------------
        REQ_ID          : PCIe_TLP_ID_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Tag. 
        ---------------------------------------------------------------------------
        TAG             : PCIe_TLP_TAG_TYPE;
        ---------------------------------------------------------------------------
        --! @brief Message Code. 
        ---------------------------------------------------------------------------
        CODE            : std_logic_vector( 7 downto 0);
        ---------------------------------------------------------------------------
        --! @brief Infomation. 
        ---------------------------------------------------------------------------
        INFO            : std_logic_vector(63 downto 0);
        ---------------------------------------------------------------------------
        --! @brief Payload Size(パケットに含まれるデータのバイト数). 
        ---------------------------------------------------------------------------
        SIZE            : PCIe_TLP_SIZE_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header の配列タイプ. 
    -------------------------------------------------------------------------------
    type  PCIe_TLP_HEAD_VECTOR     is array (INTEGER range <>) of PCIe_TLP_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Request Header の配列タイプ. 
    -------------------------------------------------------------------------------
    type  PCIe_TLP_REQ_HEAD_VECTOR is array (INTEGER range <>) of PCIe_TLP_REQ_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Completion Header の配列タイプ. 
    -------------------------------------------------------------------------------
    type  PCIe_TLP_CPL_HEAD_VECTOR is array (INTEGER range <>) of PCIe_TLP_CPL_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Message Header の配列タイプ. 
    -------------------------------------------------------------------------------
    type  PCIe_TLP_MSG_HEAD_VECTOR is array (INTEGER range <>) of PCIe_TLP_MSG_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header の NULL値を生成する関数. 
    -------------------------------------------------------------------------------
    function PCIe_TLP_HEAD_NULL     return PCIe_TLP_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Request Header のNULL値を生成する関数. 
    -------------------------------------------------------------------------------
    function PCIe_TLP_REQ_HEAD_NULL return PCIe_TLP_REQ_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Completion Header のNULL値を生成する関数. 
    -------------------------------------------------------------------------------
    function PCIe_TLP_CPL_HEAD_NULL return PCIe_TLP_CPL_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Message Header のNULL値を生成する関数. 
    -------------------------------------------------------------------------------
    function PCIe_TLP_MSG_HEAD_NULL return PCIe_TLP_MSG_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Request Header を PCIe TLP Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param REQ    PCIe TLP Request Header. 
    --! @return       PCIe TLP Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_HEADER(REQ:PCIe_TLP_REQ_HEAD_TYPE) return PCIe_TLP_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Completion Header を PCIe TLP Header に変換する関数
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param CPL    PCIe TLP Completion Header
    --! @return       PCIe TLP Header
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_HEADER(CPL:PCIe_TLP_CPL_HEAD_TYPE) return PCIe_TLP_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Message Header を PCIe TLP Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param MSG    PCIe TLP Message Header. 
    --! @return       PCIe TLP Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_HEADER(MSG:PCIe_TLP_MSG_HEAD_TYPE) return PCIe_TLP_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header を PCIe TLP Request Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param TLP    PCIe TLP Header. 
    --! @return       PCIe TLP Request Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_REQ_HEADER(TLP:PCIe_TLP_HEAD_TYPE) return PCIe_TLP_REQ_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header を PCIe TLP Completion Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param TLP    PCIe TLP Header. 
    --! @return       PCIe TLP Completion Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_CPL_HEADER(TLP:PCIe_TLP_HEAD_TYPE) return PCIe_TLP_CPL_HEAD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header を PCIe TLP Message Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param TLP    PCIe TLP Header. 
    --! @return       PCIe TLP Message Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_MSG_HEADER(TLP:PCIe_TLP_HEAD_TYPE) return PCIe_TLP_MSG_HEAD_TYPE;
end PCIe_TLP_TYPES;
-----------------------------------------------------------------------------------
--! @brief PCI-Express TLP(Transaction Layer Packet)の各種タイプ/定数を定義している
--!        パッケージ本体.
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
package body PCIe_TLP_TYPES is
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header の NULL値を生成する関数. 
    -------------------------------------------------------------------------------
    function PCIe_TLP_HEAD_NULL return PCIe_TLP_HEAD_TYPE is
        variable tlp_head  : PCIe_TLP_HEAD_TYPE;
    begin
        tlp_head.HEAD_LEN  := '0';
        tlp_head.WITH_DATA := '0';
        tlp_head.PKT_TYPE  := PCIe_TLP_PKT_TYPE_NULL;
        tlp_head.TC        := (others => '0');
        tlp_head.TD        := '0';
        tlp_head.EP        := '0';
        tlp_head.ATTR      := (others => '0');
        tlp_head.DATA_LEN  := (others => '0');
        tlp_head.INFO      := (others => '0');
        tlp_head.ADDR      := (others => '0');
        tlp_head.WORD_POS  := (others => '0');
        return tlp_head;
    end PCIe_TLP_HEAD_NULL;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Request Header のNULL値を生成する関数. 
    -------------------------------------------------------------------------------
    function PCIe_TLP_REQ_HEAD_NULL return PCIe_TLP_REQ_HEAD_TYPE is
        variable req_head  : PCIe_TLP_REQ_HEAD_TYPE;
    begin
        req_head.HEAD_LEN  := '0';
        req_head.PKT_TYPE  := PCIe_TLP_PKT_TYPE_NULL;
        req_head.TC        := (others => '0');
        req_head.TD        := '0';
        req_head.EP        := '0';
        req_head.ATTR      := (others => '0');
        req_head.REQ_ID    := (others => '0');
        req_head.TAG       := (others => '0');
        req_head.ADDR      := (others => '0');
        req_head.SIZE      := (others => '0');
        req_head.TRAN_TYPE := PCIe_TLP_REQ_TRAN_NULL;
        return req_head;
    end PCIe_TLP_REQ_HEAD_NULL;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Completion Header のNULL値を生成する関数. 
    -------------------------------------------------------------------------------
    function PCIe_TLP_CPL_HEAD_NULL return PCIe_TLP_CPL_HEAD_TYPE is
        variable cpl_head  : PCIe_TLP_CPL_HEAD_TYPE;
    begin
        cpl_head.WITH_DATA := '0';
        cpl_head.TC        := (others => '0');
        cpl_head.TD        := '0';
        cpl_head.EP        := '0';
        cpl_head.ATTR      := (others => '0');
        cpl_head.LOCK      := '0';
        cpl_head.CPL_ID    := (others => '0');
        cpl_head.STATUS    := (others => '0');
        cpl_head.BCM       := '0';
        cpl_head.COUNT     := (others => '0');
        cpl_head.REQ_ID    := (others => '0');
        cpl_head.TAG       := (others => '0');
        cpl_head.REQ_TYPE  := PCIe_TLP_PKT_TYPE_NULL;
        cpl_head.ADDR      := (others => '0');
        cpl_head.SIZE      := (others => '0');
        cpl_head.LAST      := '0';
        return cpl_head;
    end PCIe_TLP_CPL_HEAD_NULL;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Message Header のNULL値を生成する関数. 
    -------------------------------------------------------------------------------
    function PCIe_TLP_MSG_HEAD_NULL return PCIe_TLP_MSG_HEAD_TYPE is
        variable msg_head  : PCIe_TLP_MSG_HEAD_TYPE;
    begin
        msg_head.WITH_DATA := '0';
        msg_head.TC        := (others => '0');
        msg_head.TD        := '0';
        msg_head.EP        := '0';
        msg_head.ATTR      := (others => '0');
        msg_head.ROUTING   := (others => '0');
        msg_head.REQ_ID    := (others => '0');
        msg_head.TAG       := (others => '0');
        msg_head.CODE      := (others => '0');
        msg_head.INFO      := (others => '0');
        msg_head.SIZE      := (others => '0');
        return msg_head;
    end PCIe_TLP_MSG_HEAD_NULL;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Request Header を PCIe TLP Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param REQ    PCIe TLP Request Header. 
    --! @return       PCIe TLP Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_HEADER(REQ:PCIe_TLP_REQ_HEAD_TYPE) return PCIe_TLP_HEAD_TYPE is
        variable tlp_head   : PCIe_TLP_HEAD_TYPE;
        variable u_size     : unsigned(PCIe_TLP_SIZE_TYPE'range);
        variable u_addr_1st : unsigned(1 downto 0);
        variable u_addr_end : unsigned(PCIe_TLP_SIZE_TYPE'range);
        variable u_length   : unsigned(PCIe_TLP_SIZE_TYPE'range);
        variable ben_first  : std_logic_vector(3 downto 0);
        variable ben_last   : std_logic_vector(3 downto 0);
        variable with_data  : std_logic;
    begin
        ---------------------------------------------------------------------------
        -- u_size   : REQ.SIZE に不定値があるとシミュレーション時に警告が出るので、
        --            正規化しおく. 
        ---------------------------------------------------------------------------
        u_size := to_01(unsigned(REQ.SIZE),'0');
        ---------------------------------------------------------------------------
        -- もし REQ.SIZE(転送バイト数)が０の場合またはフラッシュの場合. 
        ---------------------------------------------------------------------------
        if (u_size = 0 or REQ.TRAN_TYPE = PCIe_TLP_REQ_TRAN_FLUSH) then
            ben_first := "0000";
            ben_last  := "0000";
            u_length  := to_unsigned(4, u_length'length);
            with_data := '0';
        ---------------------------------------------------------------------------
        -- もし REQ.SIZE(転送バイト数)が１以上の場合. 
        ---------------------------------------------------------------------------
        else
            u_addr_1st := to_01(unsigned(REQ.ADDR(1 downto 0)));
            if    (u_addr_1st(1 downto 0) = "11") then ben_first := "1000";
            elsif (u_addr_1st(1 downto 0) = "10") then ben_first := "1100";
            elsif (u_addr_1st(1 downto 0) = "01") then ben_first := "1110";
            else                                       ben_first := "1111";
            end if;
            u_addr_end := u_size + u_addr_1st;
            if    (u_addr_end(1 downto 0) = "01") then ben_last  := "0001";
            elsif (u_addr_end(1 downto 0) = "10") then ben_last  := "0011";
            elsif (u_addr_end(1 downto 0) = "11") then ben_last  := "0111";
            else                                       ben_last  := "1111";
            end if;
            if (u_addr_end < 4) then
                ben_first := ben_first and ben_last;
                ben_last  := "0000";
            end if;
            if (REQ.TRAN_TYPE = PCIe_TLP_REQ_TRAN_WRITE) then
                with_data := '1';
            else
                with_data := '0';
            end if;
            u_length := u_addr_end + 3;
        end if;
        tlp_head.DATA_LEN           := std_logic_vector(u_length(11 downto 2));
        tlp_head.WITH_DATA          := with_data;
        tlp_head.HEAD_LEN           := REQ.HEAD_LEN;
        tlp_head.PKT_TYPE           := REQ.PKT_TYPE;
        tlp_head.TC                 := REQ.TC;
        tlp_head.TD                 := REQ.TD;
        tlp_head.EP                 := REQ.EP;
        tlp_head.ATTR               := REQ.ATTR;
        tlp_head.ADDR               := REQ.ADDR;
        tlp_head.INFO( 3 downto  0) := ben_first;
        tlp_head.INFO( 7 downto  4) := ben_last;
        tlp_head.INFO(15 downto  8) := REQ.TAG;
        tlp_head.INFO(31 downto 16) := REQ.REQ_ID;
        tlp_head.WORD_POS           := REQ.ADDR(6 downto 2);
        return tlp_head;
    end To_PCIe_TLP_HEADER;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Completion Header を PCIe TLP Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param CPL    PCIe TLP Completion Header. 
    --! @return       PCIe TLP Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_HEADER(CPL:PCIe_TLP_CPL_HEAD_TYPE) return PCIe_TLP_HEAD_TYPE is
        variable tlp_head   : PCIe_TLP_HEAD_TYPE;
        variable byte_count : unsigned(11 downto 0);
        variable length     : unsigned(12 downto 0);
        variable low_addr   : unsigned( 6 downto 0);
    begin
        if (CPL.LOCK = '1') then
            tlp_head.PKT_TYPE := PCIe_TLP_PKT_TYPE_CPLLK;
        else
            tlp_head.PKT_TYPE := PCIe_TLP_PKT_TYPE_CPL;
        end if;
        if (CPL.REQ_TYPE = PCIe_TLP_PKT_TYPE_MEM  ) or
           (CPL.REQ_TYPE = PCIe_TLP_PKT_TYPE_MEMLK) then
            -----------------------------------------------------------------------
            -- if (CPL.COUNT(12) = '1') then
            --     byte_count := "000000000000";
            -- else
            --     byte_count := RES.COUNT(11 downto 0);
            -- end if;
            -- 上の記述だと回路が面倒になるので下記のように省略
            -----------------------------------------------------------------------
            byte_count := unsigned(CPL.COUNT(byte_count'range));
            low_addr   := unsigned(CPL.ADDR (low_addr  'range));
        else
            byte_count := to_unsigned(4, byte_count'length);
            low_addr   := to_unsigned(0, low_addr  'length);
        end if;
        if (CPL.WITH_DATA = '1') then
            length := unsigned(CPL.SIZE) + unsigned(CPL.ADDR(1 downto 0)) + 3;
            --------------------------------------------------------------------
            -- if (length(12) = '1') then
            --     tlp_head.DATA_LEN :=  "0000000000";
            -- else
            --     tlp_head.DATA_LEN := length(11 downto 2);
            -- end if;
            -- 上の記述だと回路が面倒になるので下記のように省略
            --------------------------------------------------------------------
            tlp_head.DATA_LEN := std_logic_vector(length(11 downto 2));
        else
            tlp_head.DATA_LEN := "0000000000";
        end if;
        tlp_head.HEAD_LEN           := '0';
        tlp_head.WITH_DATA          := CPL.WITH_DATA;
        tlp_head.TC                 := CPL.TC;
        tlp_head.TD                 := CPL.TD;
        tlp_head.EP                 := CPL.EP;
        tlp_head.ATTR               := CPL.ATTR;
        tlp_head.INFO(11 downto  0) := std_logic_vector(byte_count);
        tlp_head.INFO(12)           := CPL.BCM;
        tlp_head.INFO(15 downto 13) := CPL.STATUS;
        tlp_head.INFO(31 downto 16) := CPL.CPL_ID;
        tlp_head.ADDR( 6 downto  0) := std_logic_vector(low_addr);
        tlp_head.ADDR( 7 downto  7) := "0";
        tlp_head.ADDR(15 downto  8) := CPL.TAG;
        tlp_head.ADDR(31 downto 16) := CPL.REQ_ID;
        tlp_head.ADDR(63 downto 32) := "00000000000000000000000000000000";
        tlp_head.WORD_POS           := CPL.ADDR(6 downto 2);
        return tlp_head;
    end To_PCIe_TLP_HEADER;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Message Header を PCIe TLP Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param MSG    PCIe TLP Message Header. 
    --! @return       PCIe TLP Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_HEADER(MSG:PCIe_TLP_MSG_HEAD_TYPE) return PCIe_TLP_HEAD_TYPE is
        variable tlp_head   : PCIe_TLP_HEAD_TYPE;
    begin
        tlp_head.PKT_TYPE           := "10" & MSG.ROUTING;
        tlp_head.HEAD_LEN           := '1';
        tlp_head.WITH_DATA          := MSG.WITH_DATA;
        tlp_head.TC                 := MSG.TC;
        tlp_head.TD                 := MSG.TD;
        tlp_head.EP                 := MSG.EP;
        tlp_head.ATTR               := MSG.ATTR;
        tlp_head.DATA_LEN           := MSG.SIZE(11 downto 2);
        tlp_head.INFO( 7 downto  0) := MSG.CODE;
        tlp_head.INFO(15 downto  8) := MSG.TAG;
        tlp_head.INFO(31 downto 16) := MSG.REQ_ID;
        tlp_head.ADDR(63 downto  0) := MSG.INFO;
        return tlp_head;
    end To_PCIe_TLP_HEADER;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header を PCIe TLP Request Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param TLP    PCIe TLP Header. 
    --! @return       PCIe TLP Request Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_REQ_HEADER(TLP:PCIe_TLP_HEAD_TYPE) return PCIe_TLP_REQ_HEAD_TYPE is
        variable req_head       : PCIe_TLP_REQ_HEAD_TYPE;
        variable u_size         : unsigned(PCIe_TLP_SIZE_TYPE'range);
        variable ben_1st        : std_logic_vector(3 downto 0);
        variable ben_last       : std_logic_vector(3 downto 0);
        variable fraction_1st   : integer range 0 to 3;
        variable fraction_last  : integer range 0 to 3;
    begin
        req_head.HEAD_LEN := TLP.HEAD_LEN;
        req_head.PKT_TYPE := TLP.PKT_TYPE;
        req_head.TC       := TLP.TC;
        req_head.TD       := TLP.TD;
        req_head.EP       := TLP.EP;
        req_head.ATTR     := TLP.ATTR;
        req_head.REQ_ID   := TLP.INFO(31 downto 16);
        req_head.TAG      := TLP.INFO(15 downto  8);
        ben_last          := TLP.INFO( 7 downto  4);
        ben_1st           := TLP.INFO( 3 downto  0);
        ---------------------------------------------------------------------------
        -- アドレスの下位２ビットは 1st DW BE から得る. 
        ---------------------------------------------------------------------------
        if    (ben_1st(0) = '1') then req_head.ADDR(1 downto 0) := "00";
        elsif (ben_1st(1) = '1') then req_head.ADDR(1 downto 0) := "01";
        elsif (ben_1st(2) = '1') then req_head.ADDR(1 downto 0) := "10";
        elsif (ben_1st(3) = '1') then req_head.ADDR(1 downto 0) := "11";
        else                          req_head.ADDR(1 downto 0) := "00";
        end if;
        ---------------------------------------------------------------------------
        -- アドレスの上位62ビットは TLP.ADDR から得る. 
        ---------------------------------------------------------------------------
        req_head.ADDR(63 downto 2) := TLP.ADDR(63 downto 2);
        ---------------------------------------------------------------------------
        -- リクエストヘッダの Length フィールド が 1DW の場合(この場合 Last DW 
        -- BE は必ず 0000b になるはず)の転送要求バイト数を計算する. 
        ---------------------------------------------------------------------------
        if (ben_last = "0000") then
            case ben_1st is
                when "0000" => u_size := TO_UNSIGNED(0, u_size'length);
                when "0001" => u_size := TO_UNSIGNED(1, u_size'length);
                when "0010" => u_size := TO_UNSIGNED(1, u_size'length);
                when "0100" => u_size := TO_UNSIGNED(1, u_size'length);
                when "1000" => u_size := TO_UNSIGNED(1, u_size'length);
                when "0011" => u_size := TO_UNSIGNED(2, u_size'length);
                when "0110" => u_size := TO_UNSIGNED(2, u_size'length);
                when "1100" => u_size := TO_UNSIGNED(2, u_size'length);
                when "0101" => u_size := TO_UNSIGNED(3, u_size'length);
                when "0111" => u_size := TO_UNSIGNED(3, u_size'length);
                when "1010" => u_size := TO_UNSIGNED(3, u_size'length);
                when "1110" => u_size := TO_UNSIGNED(3, u_size'length);
                when "1001" => u_size := TO_UNSIGNED(4, u_size'length);
                when "1011" => u_size := TO_UNSIGNED(4, u_size'length);
                when "1101" => u_size := TO_UNSIGNED(4, u_size'length);
                when "1111" => u_size := TO_UNSIGNED(4, u_size'length);
                when others => u_size := TO_UNSIGNED(0, u_size'length);
            end case;
        -------------------------------------------------------------------------------
        -- リクエストヘッダの Length が 1DW を越える場合の転送要求バイト数を計算する.
        -------------------------------------------------------------------------------
        else
            u_size( 1 downto 0) := "00";
            u_size(11 downto 2) := TO_01(unsigned(TLP.DATA_LEN),'0');
            if (u_size(11 downto 2) = 0) then
                u_size(12) := '1';
            else
                u_size(12) := '0';
            end if;
            if    (ben_1st(0)  = '1') then fraction_1st  := 0; -- when(ben_1st  = "xxx1")
            elsif (ben_1st(1)  = '1') then fraction_1st  := 1; -- when(ben_1st  = "xx10")
            elsif (ben_1st(2)  = '1') then fraction_1st  := 2; -- when(ben_1st  = "x100")
            elsif (ben_1st(3)  = '1') then fraction_1st  := 3; -- when(ben_1st  = "1000")
            else                           fraction_1st  := 3; -- when(ben_1st  = "0000")
            end if;
            if    (ben_last(3) = '1') then fraction_last := 0; -- when(ben_last = "1xxx")
            elsif (ben_last(2) = '1') then fraction_last := 1; -- when(ben_last = "01xx")
            elsif (ben_last(1) = '1') then fraction_last := 2; -- when(ben_last = "001x")
            elsif (ben_last(0) = '1') then fraction_last := 3; -- when(ben_last = "0001")
            else                           fraction_last := 0; -- when(ben_last = "0000")
            end if;
            u_size := u_size - fraction_1st - fraction_last;
        end if;
        req_head.SIZE   := std_logic_vector(u_size);
        if (TLP.WITH_DATA = '1') then
            req_head.TRAN_TYPE := PCIe_TLP_REQ_TRAN_WRITE;
        elsif (u_size = 0) then
            req_head.TRAN_TYPE := PCIe_TLP_REQ_TRAN_FLUSH;
        else
            req_head.TRAN_TYPE := PCIe_TLP_REQ_TRAN_READ;
        end if;
        return req_head;
    end To_PCIe_TLP_REQ_HEADER;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header を PCIe TLP Completion Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param TLP    PCIe TLP Header. 
    --! @return       PCIe TLP Completion Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_CPL_HEADER(TLP:PCIe_TLP_HEAD_TYPE) return PCIe_TLP_CPL_HEAD_TYPE is
        variable cpl_head       : PCIe_TLP_CPL_HEAD_TYPE;
        variable u_size         : unsigned(PCIe_TLP_SIZE_TYPE'range);
        variable fraction_1st   : integer range 0 to 3;
    begin
        if    (TLP.PKT_TYPE = PCIe_TLP_PKT_TYPE_CPLLK) then
            cpl_head.LOCK  := '1';
        elsif (TLP.PKT_TYPE = PCIe_TLP_PKT_TYPE_CPL  ) then
            cpl_head.LOCK  := '0';
        else -- この場合はエラー
            cpl_head.LOCK  := '0';
        end if;
        cpl_head.WITH_DATA := TLP.WITH_DATA;
        cpl_head.TC        := TLP.TC;
        cpl_head.TD        := TLP.TD;
        cpl_head.EP        := TLP.EP;
        cpl_head.ATTR      := TLP.ATTR;
        cpl_head.REQ_TYPE  := TLP.PKT_TYPE;
        if (TLP.INFO(11 downto 0) = "000000000000") then
            cpl_head.COUNT := "1" & TLP.INFO(11 downto 0);
        else
            cpl_head.COUNT := "0" & TLP.INFO(11 downto 0);
        end if;
        cpl_head.BCM       := TLP.INFO(12);
        cpl_head.STATUS    := TLP.INFO(15 downto 13);
        cpl_head.CPL_ID    := TLP.INFO(31 downto 16);
        cpl_head.ADDR      := TLP.ADDR( 6 downto  0);
        cpl_head.TAG       := TLP.ADDR(15 downto  8);
        cpl_head.REQ_ID    := TLP.ADDR(31 downto 16);
        u_size( 1 downto 0) := "00";
        u_size(11 downto 2) := TO_01(unsigned(TLP.DATA_LEN),'0');
        if (u_size(11 downto 2) = 0) then
            u_size(12) := '1';
        else
            u_size(12) := '0';
        end if;
        if    (TLP.ADDR(1 downto 0) = "11") then fraction_1st := 3;
        elsif (TLP.ADDR(1 downto 0) = "10") then fraction_1st := 2;
        elsif (TLP.ADDR(1 downto 0) = "01") then fraction_1st := 1;
        else                                     fraction_1st := 0;
        end if;
        u_size := u_size - fraction_1st;
        if (TO_01(unsigned(cpl_head.COUNT),'0') > u_size) then
            cpl_head.SIZE := std_logic_vector(u_size);
            cpl_head.LAST := '0';
        else
            cpl_head.SIZE := std_logic_vector(cpl_head.COUNT);
            cpl_head.LAST := '1';
        end if;
        return cpl_head;
    end To_PCIe_TLP_CPL_HEADER;
    -------------------------------------------------------------------------------
    --! @brief PCIe TLP Header を PCIe TLP Message Header に変換する関数. 
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param TLP    PCIe TLP Header. 
    --! @return       PCIe TLP Message Header. 
    -------------------------------------------------------------------------------
    function To_PCIe_TLP_MSG_HEADER(TLP:PCIe_TLP_HEAD_TYPE) return PCIe_TLP_MSG_HEAD_TYPE is
        variable msg_head       : PCIe_TLP_MSG_HEAD_TYPE;
    begin
        msg_head.ROUTING   := TLP.PKT_TYPE(2 downto 0);
        msg_head.WITH_DATA := TLP.WITH_DATA;
        msg_head.TC        := TLP.TC;
        msg_head.TD        := TLP.TD;
        msg_head.EP        := TLP.EP;
        msg_head.ATTR      := TLP.ATTR;
        if (TLP.DATA_LEN = "0000000000") then
            msg_head.SIZE  := "1" & TLP.DATA_LEN & "00";
        else
            msg_head.SIZE  := "0" & TLP.DATA_LEN & "00";
        end if;
        msg_head.CODE      := TLP.INFO( 7 downto  0);
        msg_head.TAG       := TLP.INFO(15 downto  8);
        msg_head.REQ_ID    := TLP.INFO(31 downto 16);
        msg_head.INFO      := TLP.ADDR(63 downto  0);
        return msg_head;
    end To_PCIe_TLP_MSG_HEADER;
end PCIe_TLP_TYPES;
