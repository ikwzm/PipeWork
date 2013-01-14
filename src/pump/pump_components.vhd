-----------------------------------------------------------------------------------
--!     @file    pump_components.vhd                                             --
--!     @brief   PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION                    --
--!     @version 0.0.2                                                           --
--!     @date    2013/01/14                                                      --
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
-----------------------------------------------------------------------------------
--! @brief PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION                          --
-----------------------------------------------------------------------------------
package PUMP_COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief PUMP_COUNT_UP_REGISTER                                                --
-----------------------------------------------------------------------------------
component PUMP_COUNT_UP_REGISTER
    generic (
        VALID       : --! @brief COUNTER VALID :
                      --! このカウンターを有効にするかどうかを指定する.
                      --! * VALID =0 : このカウンターは常に無効.
                      --! * VALID/=0 : このカウンターは常に有効.
                      integer := 1;
        BITS        : --! @brief  COUNTER BITS :
                      --! カウンターのビット数を指定する.
                      --! * BIT=0の場合、このカウンターは常に無効になる.
                      integer := 32;
        REGS_BITS   : --! @brief REGISTER ACCESS INTERFACE BITS :
                      --! レジスタアクセスインターフェースのビット数を指定する.
                      integer := 32
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
    -- レジスタアクセスインターフェース
    -------------------------------------------------------------------------------
        REGS_WEN    : --! @brief REGISTER WRITE ENABLE :
                      --! カウンタレジスタ書き込み制御信号.
                      --! * 書き込みを行うビットに'1'をセットする.  
                      --!   この信号に１がセットされたビットの位置に、REGS_DINの値
                      --!   がカウンタレジスタにセットされる.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_WDATA  : --! @brief REGISTER WRITE DATA :
                      --! カウンタレジスタ書き込みデータ.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_RDATA  : --! @brief REGISTER READ DATA :
                      --! カウンタレジスタ読み出しデータ.
                      out std_logic_vector(REGS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- カウントインターフェース
    -------------------------------------------------------------------------------
        UP_ENA      : --! @brief COUNT UP ENABLE :
                      --! カウントアップ許可信号.
                      --! * この信号が'1'の場合、UP_VAL信号およびUP_SIZE信号による
                      --!   カウントアップが許可される.
                      --! * この信号が'1'の場合、REGS_WEN信号およびREGS_WDATA信号に
                      --!   よるレジスタ書き込みは無視される.
                      --! * この信号が'0'の場合、UP_VAL信号およびUP_SIZE信号による
                      --!   カウントアップは無視される.
                      in  std_logic;
        UP_VAL      : --! @brief COUNT UP SIZE VALID :
                      --! カウントアップ有効信号.
                      --! * この信号が'1'の場合、UP_SIZEで指定された数だけカウンタ
                      --!   ーの値がアップする.
                      in  std_logic;
        UP_BEN      : --! @brief COUNT UP BIT ENABLE :
                      --! カウントアップビット有効信号.
                      --! * この信号が'1'の位置のビットのみ、カウンタアップを有効に
                      --!   する.
                      in  std_logic_vector;
        UP_SIZE     : --! @brief COUNT UP SIZE :
                      --! カウントアップサイズ信号.
                      in  std_logic_vector;
    -------------------------------------------------------------------------------
    -- カウンター出力
    -------------------------------------------------------------------------------
        COUNTER     : --! @brief COUNTER OUTPUT :
                      --! カウンタの値を出力.
                      out std_logic_vector
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_COUNT_DOWN_REGISTER                                              --
-----------------------------------------------------------------------------------
component PUMP_COUNT_DOWN_REGISTER
    generic (
        VALID       : --! @brief COUNTER VALID :
                      --! このカウンターを有効にするかどうかを指定する.
                      --! * VALID =0 : このカウンターは常に無効.
                      --! * VALID/=0 : このカウンターは常に有効.
                      integer := 1;
        BITS        : --! @brief  COUNTER BITS :
                      --! カウンターのビット数を指定する.
                      --! * BIT=0の場合、このカウンターは常に無効になる.
                      integer := 32;
        REGS_BITS   : --! @brief REGISTER ACCESS INTERFACE BITS :
                      --! レジスタアクセスインターフェースのビット数を指定する.
                      integer := 32
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
    -- レジスタアクセスインターフェース
    -------------------------------------------------------------------------------
        REGS_WEN    : --! @brief REGISTER WRITE ENABLE :
                      --! カウンタレジスタ書き込み制御信号.
                      --! * 書き込みを行うビットに'1'をセットする.  
                      --!   この信号に１がセットされたビットの位置に、REGS_DINの値
                      --!   がカウンタレジスタにセットされる.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_WDATA  : --! @brief REGISTER WRITE DATA :
                      --! カウンタレジスタ書き込みデータ.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_RDATA  : --! @brief REGISTER READ DATA :
                      --! カウンタレジスタ読み出しデータ.
                      out std_logic_vector(REGS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- カウントインターフェース
    -------------------------------------------------------------------------------
        DN_ENA      : --! @brief COUNT DOWN ENABLE :
                      --! カウントダウン許可信号.
                      --! * この信号が'1'の場合、DN_VAL信号およびDN_SIZE信号による
                      --!   カウントダウンが許可される.
                      --! * この信号が'1'の場合、REGS_WEN信号およびREGS_WDATA信号に
                      --!   よるレジスタ書き込みは無視される.
                      --! * この信号が'0'の場合、DN_VAL信号およびDN_SIZE信号による
                      --!   カウントダウンは無視される.
                      in  std_logic;
        DN_VAL      : --! @brief COUNT DOWN SIZE VALID :
                      --! カウントダウン有効信号.
                      --! * この信号が'1'の場合、DN_SIZEで指定された数だけカウンタ
                      --!   ーの値がアップする.
                      in  std_logic;
        DN_SIZE     : --! @brief COUNT DOWN SIZE :
                      --! カウントダウンサイズ信号.
                      in  std_logic_vector;
    -------------------------------------------------------------------------------
    -- カウンター出力
    -------------------------------------------------------------------------------
        COUNTER     : --! @brief COUNTER OUTPUT :
                      --! カウンタの値を出力.
                      out std_logic_vector;
        ZERO        : --! @brief COUNTER ZERO FLAG :
                      --! カウンタの値が0になったことを示すフラグ.
                      out std_logic;
        NEG         : --! @brief COUNTER ZERO FLAG :
                      --! カウンタの値が負になりそうだったことを示すフラグ.
                      --! * このフラグはDN_ENA信号が'1'の時のみ有効.
                      --! * このフラグはDN_ENA信号が'0'の時はクリアされる.
                      out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_CONTROL_REGISTER                                                 --
-----------------------------------------------------------------------------------
component PUMP_CONTROL_REGISTER
    generic (
        MODE_BITS       : --! @brief MODE REGISTER BITS :
                          integer := 32;
        STAT_BITS       : --! @brief STATUS REGISTER BITS :
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief CLOCK :
                          --! クロック信号
                          in  std_logic; 
        RST             : --! @brief ASYNCRONOUSE RESET :
                          --! 非同期リセット信号.アクティブハイ.
                          in  std_logic;
        CLR             : --! @brief SYNCRONOUSE RESET :
                          --! 同期リセット信号.アクティブハイ.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- RESET Bit Register Access Interface.
    -------------------------------------------------------------------------------
        RESET_WRITE     : in  std_logic;
        RESET_WDATA     : in  std_logic;
        RESET_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- START Bit Register Access Interface.
    -------------------------------------------------------------------------------
        START_WRITE     : in  std_logic;
        START_WDATA     : in  std_logic;
        START_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- STOP Bit Register Access Interface.
    -------------------------------------------------------------------------------
        STOP_WRITE      : in  std_logic;
        STOP_WDATA      : in  std_logic;
        STOP_RDATA      : out std_logic;
    -------------------------------------------------------------------------------
    -- PAUSE Bit Register Access Interface.
    -------------------------------------------------------------------------------
        PAUSE_WRITE     : in  std_logic;
        PAUSE_WDATA     : in  std_logic;
        PAUSE_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- FIRST Bit Register Access Interface.
    -------------------------------------------------------------------------------
        FIRST_WRITE     : in  std_logic;
        FIRST_WDATA     : in  std_logic;
        FIRST_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- LAST Bit Register Access Interface.
    -------------------------------------------------------------------------------
        LAST_WRITE      : in  std_logic;
        LAST_WDATA      : in  std_logic;
        LAST_RDATA      : out std_logic;
    -------------------------------------------------------------------------------
    -- DONE Status Bit Register Access Interface.
    -------------------------------------------------------------------------------
        DONE_WRITE      : in  std_logic;
        DONE_WDATA      : in  std_logic;
        DONE_RDATA      : out std_logic;
    -------------------------------------------------------------------------------
    -- ERROR Status Bit Register Access Interface.
    -------------------------------------------------------------------------------
        ERROR_WRITE     : in  std_logic;
        ERROR_WDATA     : in  std_logic;
        ERROR_RDATA     : out std_logic;
    -------------------------------------------------------------------------------
    -- MODE Register Access Interface.
    -------------------------------------------------------------------------------
        MODE_WRITE      : in  std_logic_vector(MODE_BITS-1 downto 0);
        MODE_WDATA      : in  std_logic_vector(MODE_BITS-1 downto 0);
        MODE_RDATA      : out std_logic_vector(MODE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- STAT Register Access Interface.
    -------------------------------------------------------------------------------
        STAT_WRITE      : in  std_logic_vector(STAT_BITS-1 downto 0);
        STAT_WDATA      : in  std_logic_vector(STAT_BITS-1 downto 0);
        STAT_RDATA      : out std_logic_vector(STAT_BITS-1 downto 0);
        STAT            : in  std_logic_vector(STAT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_VALID       : out std_logic;
        REQ_FIRST       : out std_logic;
        REQ_LAST        : out std_logic;
        REQ_READY       : in  std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Command Response Signals.
    -------------------------------------------------------------------------------
        ACK_VALID       : in  std_logic;
        ACK_ERROR       : in  std_logic;
        ACK_NEXT        : in  std_logic;
        ACK_LAST        : in  std_logic;
        ACK_STOP        : in  std_logic;
        ACK_NONE        : in  std_logic;
    -------------------------------------------------------------------------------
    -- Status.
    -------------------------------------------------------------------------------
        VALVE_OPEN      : out std_logic;
        XFER_RUNNING    : out std_logic;
        XFER_DONE       : out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_IN_VALVE                                                         --
-----------------------------------------------------------------------------------
component PUMP_IN_VALVE
    generic (
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! 内部カウンタのビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! サイズ信号のビット数を指定する.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief CLOCK :
                          --! クロック信号
                          in  std_logic; 
        RST             : --! @brief ASYNCRONOUSE RESET :
                          --! 非同期リセット信号.アクティブハイ.
                          in  std_logic;
        CLR             : --! @brief SYNCRONOUSE RESET :
                          --! 同期リセット信号.アクティブハイ.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Control Signals.
    -------------------------------------------------------------------------------
        BUFFER_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        THRESHOLD_SIZE  : in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_OPEN          : in  std_logic;
        O_OPEN          : in  std_logic;
        RESET           : in  std_logic;
        PAUSE           : in  std_logic;
        STOP            : in  std_logic;
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VAL        : in  std_logic;
        PUSH_LAST       : in  std_logic;
        PUSH_SIZE       : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VAL        : in  std_logic;
        PULL_LAST       : in  std_logic;
        PULL_SIZE       : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Input Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_PAUSE      : out std_logic;
        FLOW_STOP       : out std_logic;
        FLOW_LAST       : out std_logic;
        FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_NEG        : out std_logic;
        PAUSED          : out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_OUT_VALVE                                                        --
-----------------------------------------------------------------------------------
component PUMP_OUT_VALVE
    generic (
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! 内部カウンタのビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! サイズ信号のビット数を指定する.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief CLOCK :
                          --! クロック信号
                          in  std_logic; 
        RST             : --! @brief ASYNCRONOUSE RESET :
                          --! 非同期リセット信号.アクティブハイ.
                          in  std_logic;
        CLR             : --! @brief SYNCRONOUSE RESET :
                          --! 同期リセット信号.アクティブハイ.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Control Signals.
    -------------------------------------------------------------------------------
        THRESHOLD_SIZE  : in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_OPEN          : in  std_logic;
        O_OPEN          : in  std_logic;
        RESET           : in  std_logic;
        PAUSE           : in  std_logic;
        STOP            : in  std_logic;
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VAL        : in  std_logic;
        PUSH_LAST       : in  std_logic;
        PUSH_SIZE       : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VAL        : in  std_logic;
        PULL_LAST       : in  std_logic;
        PULL_SIZE       : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Input Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_PAUSE      : out std_logic;
        FLOW_STOP       : out std_logic;
        FLOW_LAST       : out std_logic;
        FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_NEG        : out std_logic;
        PAUSED          : out std_logic
    );
end component;
end PUMP_COMPONENTS;
