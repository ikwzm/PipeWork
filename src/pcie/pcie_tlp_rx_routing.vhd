-----------------------------------------------------------------------------------
--!     @file    pcie_tlp_rx_routing.vhd
--!     @brief   PCI-Express TLP Receive Routing Package.
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
--! @brief   PCI-Express TLP(Transaction Layer Packet) Receive Routing Package.
-----------------------------------------------------------------------------------
package  PCIe_TLP_RX_ROUTING is
    -------------------------------------------------------------------------------
    --! @brief PCIe_TLP_RX_ROUTERでターゲットを選択できる最大数.
    -------------------------------------------------------------------------------
    constant  MAX_TARGET        : integer := 32;
    -------------------------------------------------------------------------------
    --! @brief 現在処理中のリクエストパケットに関する情報を記述している構造体.
    -------------------------------------------------------------------------------
    --! PCIe_TLP_RX_ROUTER(受信パケットの経路選択回路)で、リクエストパケットの処理
    --! を依頼するモジュールを選択するのに使用する.
    -------------------------------------------------------------------------------
    type      REQ_TABLE_ENTRY_TYPE is record
        ---------------------------------------------------------------------------
        --! @brief 
        ---------------------------------------------------------------------------
              TARGET_SELECT     : std_logic_vector(0 to MAX_TARGET-1);
        ---------------------------------------------------------------------------
        --! @brief リードアクセス可能であることを示すフラグ.
        ---------------------------------------------------------------------------
              READ              : std_logic;
        ---------------------------------------------------------------------------
        --! @brief ライトアクセス可能であることを示すフラグ.
        ---------------------------------------------------------------------------
              WRITE             : std_logic;
        ---------------------------------------------------------------------------
        --! @brief 現在リクエストパケットを処理中であることを示すフラグ.
        ---------------------------------------------------------------------------
              BUSY              : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief 現在受信待ち中のコンプレッションケットに関する情報を記述している構造体.
    -------------------------------------------------------------------------------
    --! PCIe_TLP_RX_ROUTER(受信パケットの経路選択回路)で、コンプレッションパケット
    --! の処理を待っているモジュールを選択するのに使用する.
    -------------------------------------------------------------------------------
    type      CPL_TABLE_ENTRY_TYPE is record
        ---------------------------------------------------------------------------
        --! @brief エントリーが有効であることを示すフラグ.
        ---------------------------------------------------------------------------
              ENABLE            : std_logic;
        ---------------------------------------------------------------------------
        --! @brief タグマップ
        ---------------------------------------------------------------------------
              TAG_SELECT_MAP    : std_logic_vector(0 to 255);
        ---------------------------------------------------------------------------
        --! @brief コンプレッションID
        ---------------------------------------------------------------------------
              CPL_ID            : PCIe_TLP_ID_TYPE;
        ---------------------------------------------------------------------------
        --! @brief リクエスターのID
        ---------------------------------------------------------------------------
              REQ_ID            : PCIe_TLP_ID_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief 現在受信待ち中のメッセージパケットに関する情報を記述している構造体.
    -------------------------------------------------------------------------------
    --! PCIe_TLP_RX_ROUTER(受信パケットの経路選択回路)で、メッセージパケットの処理
    --! を待っているモジュールを選択するのに使用する。
    --! 注)2013/2/23時点ではメッセージパケット処理は未実装
    -------------------------------------------------------------------------------
    type      MSG_TABLE_ENTRY_TYPE is record
              BUSY              : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief 現在処理中のリクエストパケットに関する情報を記述しているテーブル.
    -------------------------------------------------------------------------------
    type      REQ_TABLE    is array (INTEGER range <>) of REQ_TABLE_ENTRY_TYPE;
    -------------------------------------------------------------------------------
    --! @brief 現在処理中のコンプレッションパケットに関する情報を記述しているテーブル.
    -------------------------------------------------------------------------------
    type      CPL_TABLE    is array (INTEGER range <>) of CPL_TABLE_ENTRY_TYPE;
    -------------------------------------------------------------------------------
    --! @brief 現在処理中のメッセージパケットに関する情報を記述しているテーブル.
    -------------------------------------------------------------------------------
    type      MSG_TABLE    is array (INTEGER range <>) of MSG_TABLE_ENTRY_TYPE;
    -------------------------------------------------------------------------------
    --! @brief REQ_TABLE_ENTRY_TYPEのNULL値を得る関数.
    -------------------------------------------------------------------------------
    constant  REQ_TABLE_ENTRY_NULL : REQ_TABLE_ENTRY_TYPE := (
              TARGET_SELECT     => (others => '0'),
              READ              => '0',
              WRITE             => '0',
              BUSY              => '0'
    );
    -------------------------------------------------------------------------------
    --! @brief CPL_TABLE_ENTRY_TYPEのNULL値を得る関数.
    -------------------------------------------------------------------------------
    constant  CPL_TABLE_ENTRY_NULL : CPL_TABLE_ENTRY_TYPE := (
              ENABLE            => '0',
              TAG_SELECT_MAP    => (others => '0'),
              CPL_ID            => (others => '0'),
              REQ_ID            => (others => '0')
    );
    -------------------------------------------------------------------------------
    --! @brief MSG_TABLE_ENTRY_TYPEのNULL値を得る関数.
    -------------------------------------------------------------------------------
    constant  MSG_TABLE_ENTRY_NULL : MSG_TABLE_ENTRY_TYPE := (
              BUSY              => '0'
    );
end PCIe_TLP_RX_ROUTING;
