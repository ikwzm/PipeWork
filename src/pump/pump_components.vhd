-----------------------------------------------------------------------------------
--!     @file    pump_components.vhd                                             --
--!     @brief   PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION                    --
--!     @version 1.0.4                                                           --
--!     @date    2013/01/19                                                      --
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
    -- RESET Bit        : コントローラの各種レジスタをリセットする.
    -------------------------------------------------------------------------------
    -- * RESET_L='1' and RESET_D='1' でリセット開始.
    -- * RESET_L='1' and RESET_D='0' でリセット解除.
    -- * RESET_Q は現在のリセット状態を返す.
    -- * RESET_Q='1' で現在リセット中であることを示す.
    -------------------------------------------------------------------------------
        RESET_L         : in  std_logic;
        RESET_D         : in  std_logic;
        RESET_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- START Bit        : 転送を開始を指示する.
    -------------------------------------------------------------------------------
    -- * START_L='1' and START_D='1' で転送開始.
    -- * START_L='1' and START_D='0' の場合は無視される.
    -- * START_Q は現在の状態を返す.
    -- * START_Q='1' で転送中であることを示す.
    -- * START_Q='0 'で転送は行われていないことを示す.
    -------------------------------------------------------------------------------
        START_L         : in  std_logic;
        START_D         : in  std_logic;
        START_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- STOP Bit         : 現在処理中の転送を中止する.
    -------------------------------------------------------------------------------
    -- * STOP_L='1' and STOP_D='1' で転送中止処理開始.
    -- * STOP_L='1' and STOP_D='0' の場合は無視される.
    -- * STOP_Q は現在の状態を返す.
    -- * STOP_Q='1' で転送中止処理中であることを示す.
    -- * STOP_Q='0' で転送中止処理が完了していることを示す.
    -------------------------------------------------------------------------------
        STOP_L          : in  std_logic;
        STOP_D          : in  std_logic;
        STOP_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- PAUSE Bit        : 転送の中断を指示する.
    -------------------------------------------------------------------------------
    -- * PAUSE_L='1' and PAUSE_D='1' で転送中断.
    -- * PAUSE_L='1' and PAUSE_D='0' で転送再開.
    -- * PAUSE_Q は現在中断中か否かを返す.
    -- * PAUSE_Q='1' で現在中断していることを示す.
    -- * PAUSE_Q='0' で現在転送を再開していることを示す.
    -------------------------------------------------------------------------------
        PAUSE_L         : in  std_logic;
        PAUSE_D         : in  std_logic;
        PAUSE_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- FIRST Bit        : 最初の転送であるか否かを指示する.
    -------------------------------------------------------------------------------
    -- * FIRST_L='1' and FIRST_D='1' で最初の転送であることを指示する.
    -- * FIRST_L='1' and FIRST_D='0' で最初の転送でないことを指示する.
    -- * FIRST_Q は現在の状態を示す.
    -------------------------------------------------------------------------------
        FIRST_L         : in  std_logic;
        FIRST_D         : in  std_logic;
        FIRST_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- LAST Bit         : 最後の転送であるか否かを指示する.
    -------------------------------------------------------------------------------
    -- * LAST_L='1' and LAST_D='1' で最後の転送であることを指示する.
    -- * LAST_L='1' and LAST_D='0' で最後の転送でないことを指示する.
    -- * LAST_Q は現在の状態を示す.
    -------------------------------------------------------------------------------
        LAST_L          : in  std_logic;
        LAST_D          : in  std_logic;
        LAST_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- DONE ENable Bit  : 転送終了時に DONE STatus Bit をセットするか否かを指示する.
    -------------------------------------------------------------------------------
    -- * DONE_EN_L='1' and DONE_EN_D='1' で転送終了時に DONE STatus Bit をセットす
    --   ることを指示する.
    -- * DONE_EN_L='1' and DONE_EN_D='0' で転送終了時に DONE STatus Bit をセットし
    --   ないことを指示する.
    -- * DONE_EN_Q は現在の状態を示す.
    -------------------------------------------------------------------------------
        DONE_EN_L       : in  std_logic;
        DONE_EN_D       : in  std_logic;
        DONE_EN_Q       : out std_logic;
    -------------------------------------------------------------------------------
    -- DONE STatus Bit  : DONE_EN_Q='1'の時、転送終了時にセットされる.
    -------------------------------------------------------------------------------
    -- * DONE_ST_L='1' and DONE_ST_D='0' でこのビットをクリアする.
    -- * DONE_ST_L='1' and DONE_ST_D='1' の場合、このビットに変化は無い.
    -- * DONE_ST_Q='1' は、DONE_EN_Q='1' の時、転送が終了したことを示す.
    -------------------------------------------------------------------------------
        DONE_ST_L       : in  std_logic;
        DONE_ST_D       : in  std_logic;
        DONE_ST_Q       : out std_logic;
    -------------------------------------------------------------------------------
    -- ERRor STatus Bit : 転送中にエラーが発生した時にセットされる.
    -------------------------------------------------------------------------------
    -- * ERR_ST_L='1' and ERR_ST_D='0' でこのビットをクリアする.
    -- * ERR_ST_L='1' and ERR_ST_D='1' の場合、このビットに変化は無い.
    -- * ERR_ST_Q='1' は転送中にエラーが発生したことを示す.
    -------------------------------------------------------------------------------
        ERR_ST_L        : in  std_logic;
        ERR_ST_D        : in  std_logic;
        ERR_ST_Q        : out std_logic;
    -------------------------------------------------------------------------------
    -- MODE Register    : その他のモードレジスタ.
    -------------------------------------------------------------------------------
    -- * MODE_L(x)='1' and MODE_D(x)='1' で MODE_Q(x) に'1'をセット.
    -- * MODE_L(x)='1' and MODE_D(x)='0' で MODE_Q(x) に'0'をセット.
    -------------------------------------------------------------------------------
        MODE_L          : in  std_logic_vector(MODE_BITS-1 downto 0);
        MODE_D          : in  std_logic_vector(MODE_BITS-1 downto 0);
        MODE_Q          : out std_logic_vector(MODE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- STATus Register  : その他のステータスレジスタ.
    -------------------------------------------------------------------------------
    -- * STAT_L(x)='1' and STAT_D(x)='1' で STAT_Q(x)をクリア.
    -- * STAT_L(x)='1' and STAT_D(x)='0' の場合、STAT_Q(x) に変化は無い.
    -- * STAT_I(x)='1' で STAT_Q(x) に'1'をセット.
    -- * STAT_I(x)='0' の場合、STAT_Q(x) に変化は無い.
    -------------------------------------------------------------------------------
        STAT_L          : in  std_logic_vector(STAT_BITS-1 downto 0);
        STAT_D          : in  std_logic_vector(STAT_BITS-1 downto 0);
        STAT_Q          : out std_logic_vector(STAT_BITS-1 downto 0);
        STAT_I          : in  std_logic_vector(STAT_BITS-1 downto 0);
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
--! @brief PUMP_INTAKE_VALVE                                                     --
-----------------------------------------------------------------------------------
component PUMP_INTAKE_VALVE
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
--! @brief PUMP_OUTLET_VALVE                                                     --
-----------------------------------------------------------------------------------
component PUMP_OUTLET_VALVE
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
-----------------------------------------------------------------------------------
--! @brief PUMP_CONTROLLER                                                       --
-----------------------------------------------------------------------------------
component PUMP_CONTROLLER
    generic (
        I_REQ_ADDR_VALID: --! @brief INTAKE REQUEST ADDRESS VALID :
                          --! I_REQ_ADDR信号を有効にするか否かを指示する.
                          --! * I_ADDR_VAL=0で無効.
                          --! * I_ADDR_VAL>0で有効.
                          integer := 1;
        I_REQ_ADDR_BITS : --! @brief INTAKE REQUEST ADDRESS BITS :
                          --! I_REQ_ADDR信号のビット数を指定する.
                          integer := 32;
        I_REG_ADDR_BITS : --! @brief INTAKE ADDRESS REGISTER BITS :
                          --! I_REG_ADDR信号のビット数を指定する.
                          integer := 32;
        I_REQ_SIZE_VALID: --! @brief INTAKE REQUEST SIZE VALID :
                          --! I_REQ_SIZE信号を有効にするか否かを指示する.
                          --! * I_SIZE_VAL=0で無効.
                          --! * I_SIZE_VAL>0で有効.
                          integer := 1;
        I_REQ_SIZE_BITS : --! @brief INTAKE REQUEST SIZE BITS :
                          --! I_REQ_SIZE信号のビット数を指定する.
                          integer := 32;
        I_REG_SIZE_BITS : --! @brief INTAKE SIZE REGISTER BITS :
                          --! I_REG_SIZE信号のビット数を指定する.
                          integer := 32;
        I_REG_MODE_BITS : --! @brief INTAKE MODE REGISTER BITS :
                          integer := 32;
        I_REG_STAT_BITS : --! @brief INTAKE STATUS REGISTER BITS :
                          integer := 32;
        O_REQ_ADDR_VALID: --! @brief OUTLET REQUEST ADDRESS VALID :
                          --! O_REQ_ADDR信号を有効にするか否かを指示する.
                          --! * O_ADDR_VAL=0で無効.
                          --! * O_ADDR_VAL>0で有効.
                          integer := 1;
        O_REQ_ADDR_BITS : --! @brief OUTLET REQUEST ADDRESS BITS :
                          --! O_REQ_ADDR信号のビット数を指定する.
                          integer := 32;
        O_REG_ADDR_BITS : --! @brief OUTLET ADDRESS REGISTER BITS :
                          --! O_REG_ADDR信号のビット数を指定する.
                          integer := 32;
        O_REQ_SIZE_VALID: --! @brief OUTLET REQUEST SIZE VALID :
                          --! O_REQ_SIZE信号を有効にするか否かを指示する.
                          --! * O_SIZE_VAL=0で無効.
                          --! * O_SIZE_VAL>0で有効.
                          integer := 1;
        O_REQ_SIZE_BITS : --! @brief OUTLET REQUEST SIZE BITS :
                          --! O_REQ_SIZE信号のビット数を指定する.
                          integer := 32;
        O_REG_SIZE_BITS : --! @brief OUTLET SIZE REGISTER BITS :
                          --! O_REG_SIZE信号のビット数を指定する.
                          integer := 32;
        O_REG_MODE_BITS : --! @brief OUTLET MODE REGISTER BITS :
                          integer := 32;
        O_REG_STAT_BITS : --! @brief OUTLET STATUS REGISTER BITS :
                          integer := 32;
        BUF_DEPTH       : --! @brief BUFFER DEPTH :
                          --! バッファの容量(バイト数)を２のべき乗値で指定する.
                          integer := 12;
        I_THRESHOLD     : --! @brief INTAKE THRESHOLD SIZE :
                          --! 入力側の閾値をバイト数で指定する.
                          --! フローカウンタがこの値以下の時に入力を開始する.
                          integer := 32;
        O_THRESHOLD     : --! @brief OUTLET THRESHOLD SIZE :
                          --! 出力側の閾値をバイト数で指定する.
                          --! フローカウンタがこの値以下の時に出力を開始する.
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
    -- Intake Control Register Interface.
    -------------------------------------------------------------------------------
        I_ADDR_L        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_ADDR_D        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_ADDR_Q        : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_SIZE_L        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_SIZE_D        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_SIZE_Q        : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_MODE_L        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_MODE_D        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_MODE_Q        : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_STAT_L        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_D        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_Q        : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_I        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_RESET_L       : in  std_logic;
        I_RESET_D       : in  std_logic;
        I_RESET_Q       : out std_logic;
        I_START_L       : in  std_logic;
        I_START_D       : in  std_logic;
        I_START_Q       : out std_logic;
        I_STOP_L        : in  std_logic;
        I_STOP_D        : in  std_logic;
        I_STOP_Q        : out std_logic;
        I_PAUSE_L       : in  std_logic;
        I_PAUSE_D       : in  std_logic;
        I_PAUSE_Q       : out std_logic;
        I_FIRST_L       : in  std_logic;
        I_FIRST_D       : in  std_logic;
        I_FIRST_Q       : out std_logic;
        I_LAST_L        : in  std_logic;
        I_LAST_D        : in  std_logic;
        I_LAST_Q        : out std_logic;
        I_DONE_EN_L     : in  std_logic;
        I_DONE_EN_D     : in  std_logic;
        I_DONE_EN_Q     : out std_logic;
        I_DONE_ST_L     : in  std_logic;
        I_DONE_ST_D     : in  std_logic;
        I_DONE_ST_Q     : out std_logic;
        I_ERR_ST_L      : in  std_logic;
        I_ERR_ST_D      : in  std_logic;
        I_ERR_ST_Q      : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Control Register Interface.
    -------------------------------------------------------------------------------
        O_ADDR_L        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_ADDR_D        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_ADDR_Q        : out std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_SIZE_L        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_SIZE_D        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_SIZE_Q        : out std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_MODE_L        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_MODE_D        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_MODE_Q        : out std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_STAT_L        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_D        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_Q        : out std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_I        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_RESET_L       : in  std_logic;
        O_RESET_D       : in  std_logic;
        O_RESET_Q       : out std_logic;
        O_START_L       : in  std_logic;
        O_START_D       : in  std_logic;
        O_START_Q       : out std_logic;
        O_STOP_L        : in  std_logic;
        O_STOP_D        : in  std_logic;
        O_STOP_Q        : out std_logic;
        O_PAUSE_L       : in  std_logic;
        O_PAUSE_D       : in  std_logic;
        O_PAUSE_Q       : out std_logic;
        O_FIRST_L       : in  std_logic;
        O_FIRST_D       : in  std_logic;
        O_FIRST_Q       : out std_logic;
        O_LAST_L        : in  std_logic;
        O_LAST_D        : in  std_logic;
        O_LAST_Q        : out std_logic;
        O_DONE_EN_L     : in  std_logic;
        O_DONE_EN_D     : in  std_logic;
        O_DONE_EN_Q     : out std_logic;
        O_DONE_ST_L     : in  std_logic;
        O_DONE_ST_D     : in  std_logic;
        O_DONE_ST_Q     : out std_logic;
        O_ERR_ST_L      : in  std_logic;
        O_ERR_ST_D      : in  std_logic;
        O_ERR_ST_Q      : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        I_REQ_VALID     : out std_logic;
        I_REQ_ADDR      : out std_logic_vector(I_REQ_ADDR_BITS-1 downto 0);
        I_REQ_SIZE      : out std_logic_vector(I_REQ_SIZE_BITS-1 downto 0);
        I_REQ_BUF_PTR   : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        I_REQ_FIRST     : out std_logic;
        I_REQ_LAST      : out std_logic;
        I_REQ_READY     : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        I_ACK_VALID     : in  std_logic;
        I_ACK_SIZE      : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_ACK_ERROR     : in  std_logic;
        I_ACK_NEXT      : in  std_logic;
        I_ACK_LAST      : in  std_logic;
        I_ACK_STOP      : in  std_logic;
        I_ACK_NONE      : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        I_FLOW_PAUSE    : out std_logic;
        I_FLOW_STOP     : out std_logic;
        I_FLOW_LAST     : out std_logic;
        I_FLOW_SIZE     : out std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_VALID    : in  std_logic;
        I_PUSH_LAST     : in  std_logic;
        I_PUSH_ERROR    : in  std_logic;
        I_PUSH_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Intake Status.
    -------------------------------------------------------------------------------
        I_OPEN          : out std_logic;
        I_RUNNING       : out std_logic;
        I_DONE          : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        O_REQ_VALID     : out std_logic;
        O_REQ_ADDR      : out std_logic_vector(O_REQ_ADDR_BITS-1 downto 0);
        O_REQ_SIZE      : out std_logic_vector(O_REQ_SIZE_BITS-1 downto 0);
        O_REQ_BUF_PTR   : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        O_REQ_FIRST     : out std_logic;
        O_REQ_LAST      : out std_logic;
        O_REQ_READY     : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Transaction Command Response Signals.
    -------------------------------------------------------------------------------
        O_ACK_VALID     : in  std_logic;
        O_ACK_SIZE      : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_ACK_ERROR     : in  std_logic;
        O_ACK_NEXT      : in  std_logic;
        O_ACK_LAST      : in  std_logic;
        O_ACK_STOP      : in  std_logic;
        O_ACK_NONE      : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        O_FLOW_PAUSE    : out std_logic;
        O_FLOW_STOP     : out std_logic;
        O_FLOW_LAST     : out std_logic;
        O_FLOW_SIZE     : out std_logic_vector(BUF_DEPTH         downto 0);
        O_PULL_VALID    : in  std_logic;
        O_PULL_LAST     : in  std_logic;
        O_PULL_ERROR    : in  std_logic;
        O_PULL_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Status.
    -------------------------------------------------------------------------------
        O_OPEN          : out std_logic;
        O_RUNNING       : out std_logic;
        O_DONE          : out std_logic
    );
end component;
end PUMP_COMPONENTS;
