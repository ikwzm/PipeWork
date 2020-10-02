-----------------------------------------------------------------------------------
--!     @file    pump_controller.vhd
--!     @brief   PUMP CONTROLLER
--!     @version 1.8.1
--!     @date    2020/10/2
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2020 Ichiro Kawazome
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
--! @brief   PUMP CONTROLLER :
-----------------------------------------------------------------------------------
entity  PUMP_CONTROLLER is
    generic (
        I_CLK_RATE          : --! @brief INPUT CLOCK RATE :
                              --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側
                              --! のクロック(O_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        I_REQ_ADDR_VALID    : --! @brief INTAKE REQUEST ADDRESS VALID :
                              --! I_REQ_ADDR信号を有効にするか否かを指示する.
                              --! * I_REQ_ADDR_VALID=0で無効.
                              --! * I_REQ_ADDR_VALID=1で有効.
                              integer range 0 to 1 := 1;
        I_REQ_ADDR_BITS     : --! @brief INTAKE REQUEST ADDRESS BITS :
                              --! I_REQ_ADDR信号のビット数を指定する.
                              --! * I_REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_ADDR_BITS     : --! @brief INTAKE ADDRESS REGISTER BITS :
                              --! I_REG_ADDR信号のビット数を指定する.
                              --! * I_REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REQ_SIZE_VALID    : --! @brief INTAKE REQUEST SIZE VALID :
                              --! I_REQ_SIZE信号を有効にするか否かを指示する.
                              --! * I_REQ_SIZE_VALID=0で無効.
                              --! * I_REQ_SIZE_VALID=1で有効.
                              integer range 0 to 1 := 1;
        I_REQ_SIZE_BITS     : --! @brief INTAKE REQUEST SIZE BITS :
                              --! I_REQ_SIZE信号のビット数を指定する.
                              --! * I_REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_SIZE_BITS     : --! @brief INTAKE SIZE REGISTER BITS :
                              --! I_REG_SIZE信号のビット数を指定する.
                              --! * I_REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_MODE_BITS     : --! @brief INTAKE MODE REGISTER BITS :
                              --! I_MODE_L/I_MODE_D/I_MODE_Qのビット数を指定する.
                              integer := 32;
        I_REG_STAT_BITS     : --! @brief INTAKE STATUS REGISTER BITS :
                              --! I_STAT_L/I_STAT_D/I_STAT_Qのビット数を指定する.
                              integer := 32;
        I_USE_PUSH_RSV_SIZE : --! @brief INTAKE USE PUSH RESERVE SIZE :
                              --! I_PUSH_RSV_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PUSH_RSV_SIZE=0で使用しない.
                              --! * I_USE_PUSH_RSV_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        I_USE_PUSH_BUF_SIZE : --! @brief INTAKE USE PUSH BUFFER SIZE :
                              --! I_PUSH_BUF_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PUSH_BUF_SIZE=0で使用しない.
                              --! * I_USE_PUSH_BUF_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        I_FIXED_FLOW_OPEN   : --! @brief INTAKE VALVE FIXED FLOW OPEN :
                              --! I_FLOW_READYを常に'1'にするか否かを指定する.
                              --! * I_FIXED_FLOW_OPEN=1で常に'1'にする.
                              --! * I_FIXED_FLOW_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        I_FIXED_POOL_OPEN   : --! @brief INTAKE VALVE FIXED POOL OPEN :
                              --! I_PUSH_BUF_READYを常に'1'にするか否かを指定する.
                              --! * I_FIXED_POOL_OPEN=1で常に'1'にする.
                              --! * I_FIXED_POOL_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        O_CLK_RATE          : --! @brief OUTPUT CLOCK RATE :
                              --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側
                              --! のクロック(O_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        O_REQ_ADDR_VALID    : --! @brief OUTLET REQUEST ADDRESS VALID :
                              --! O_REQ_ADDR信号を有効にするか否かを指示する.
                              --! * O_REQ_ADDR_VAL=0で無効.
                              --! * O_REQ_ADDR_VAL=1で有効.
                              integer range 0 to 1 := 1;
        O_REQ_ADDR_BITS     : --! @brief OUTLET REQUEST ADDRESS BITS :
                              --! O_REQ_ADDR信号のビット数を指定する.
                              --! * O_REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        O_REG_ADDR_BITS     : --! @brief OUTLET ADDRESS REGISTER BITS :
                              --! O_REG_ADDR信号のビット数を指定する.
                              --! * O_REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        O_REQ_SIZE_VALID    : --! @brief OUTLET REQUEST SIZE VALID :
                              --! O_REQ_SIZE信号を有効にするか否かを指示する.
                              --! * O_REQ_SIZE_VAL=0で無効.
                              --! * O_REQ_SIZE_VAL=1で有効.
                              integer range 0 to 1 := 1;
        O_REQ_SIZE_BITS     : --! @brief OUTLET REQUEST SIZE BITS :
                              --! O_REQ_SIZE信号のビット数を指定する.
                              --! * O_REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        O_REG_SIZE_BITS     : --! @brief OUTLET SIZE REGISTER BITS :
                              --! O_REG_SIZE信号のビット数を指定する.
                              --! * O_REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        O_REG_MODE_BITS     : --! @brief OUTLET MODE REGISTER BITS :
                              --! O_MODE_L/O_MODE_D/O_MODE_Qのビット数を指定する.
                              integer := 32;
        O_REG_STAT_BITS     : --! @brief OUTLET STATUS REGISTER BITS :
                              --! O_STAT_L/O_STAT_D/O_STAT_Qのビット数を指定する.
                              integer := 32;
        O_FIXED_FLOW_OPEN   : --! @brief OUTLET VALVE FIXED FLOW OPEN :
                              --! O_FLOW_READYを常に'1'にするか否かを指定する.
                              --! * O_FIXED_FLOW_OPEN=1で常に'1'にする.
                              --! * O_FIXED_FLOW_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        O_FIXED_POOL_OPEN   : --! @brief OUTLET VALVE FIXED POOL OPEN :
                              --! O_PULL_BUF_READYを常に'1'にするか否かを指定する.
                              --! * O_FIXED_POOL_OPEN=1で常に'1'にする.
                              --! * O_FIXED_POOL_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        O_USE_PULL_RSV_SIZE : --! @brief OUTLET USE PULL RESERVE SIZE :
                              --! I_PULL_RSV_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PULL_RSV_SIZE=0で使用しない.
                              --! * I_USE_PULL_RSV_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        O_USE_PULL_BUF_SIZE : --! @brief OUTLET USE PULL BUFFER SIZE :
                              --! I_PULL_BUF_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PULL_BUF_SIZE=0で使用しない.
                              --! * I_USE_PULL_BUF_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        BUF_DEPTH           : --! @brief BUFFER DEPTH :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        I2O_DELAY_CYCLE     : --! @brief DELAY CYCLE :
                              --! 入力側から出力側への転送する際の遅延サイクルを
                              --! 指定する.
                              integer :=  0
    );
    port (
    -------------------------------------------------------------------------------
    --Reset Signals.
    -------------------------------------------------------------------------------
        RST                 : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Clock and Clock Enable.
    -------------------------------------------------------------------------------
        I_CLK               : in  std_logic;
        I_CLR               : in  std_logic;
        I_CKE               : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Intake Control Register Interface.
    -------------------------------------------------------------------------------
        I_ADDR_L            : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0) := (others => '0');
        I_ADDR_D            : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0) := (others => '0');
        I_ADDR_Q            : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_SIZE_L            : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0) := (others => '0');
        I_SIZE_D            : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0) := (others => '0');
        I_SIZE_Q            : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_MODE_L            : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0) := (others => '0');
        I_MODE_D            : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0) := (others => '0');
        I_MODE_Q            : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_STAT_L            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_STAT_D            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_STAT_Q            : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_I            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_RESET_L           : in  std_logic := '0';
        I_RESET_D           : in  std_logic := '0';
        I_RESET_Q           : out std_logic;
        I_START_L           : in  std_logic := '0';
        I_START_D           : in  std_logic := '0';
        I_START_Q           : out std_logic;
        I_STOP_L            : in  std_logic := '0';
        I_STOP_D            : in  std_logic := '0';
        I_STOP_Q            : out std_logic;
        I_PAUSE_L           : in  std_logic := '0';
        I_PAUSE_D           : in  std_logic := '0';
        I_PAUSE_Q           : out std_logic;
        I_FIRST_L           : in  std_logic := '0';
        I_FIRST_D           : in  std_logic := '0';
        I_FIRST_Q           : out std_logic;
        I_LAST_L            : in  std_logic := '0';
        I_LAST_D            : in  std_logic := '0';
        I_LAST_Q            : out std_logic;
        I_DONE_EN_L         : in  std_logic := '0';
        I_DONE_EN_D         : in  std_logic := '0';
        I_DONE_EN_Q         : out std_logic;
        I_DONE_ST_L         : in  std_logic := '0';
        I_DONE_ST_D         : in  std_logic := '0';
        I_DONE_ST_Q         : out std_logic;
        I_ERR_ST_L          : in  std_logic := '0';
        I_ERR_ST_D          : in  std_logic := '0';
        I_ERR_ST_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Configuration Signals.
    -------------------------------------------------------------------------------
        I_ADDR_FIX          : in  std_logic := '0';
        I_BUF_READY_LEVEL   : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_FLOW_READY_LEVEL  : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Clock and Clock Enable.
    -------------------------------------------------------------------------------
        O_CLK               : in  std_logic;
        O_CLR               : in  std_logic;
        O_CKE               : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Outlet Control Register Interface.
    -------------------------------------------------------------------------------
        O_ADDR_L            : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0) := (others => '0');
        O_ADDR_D            : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0) := (others => '0');
        O_ADDR_Q            : out std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_SIZE_L            : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0) := (others => '0');
        O_SIZE_D            : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0) := (others => '0');
        O_SIZE_Q            : out std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_MODE_L            : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0) := (others => '0');
        O_MODE_D            : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0) := (others => '0');
        O_MODE_Q            : out std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_STAT_L            : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0) := (others => '0');
        O_STAT_D            : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0) := (others => '0');
        O_STAT_Q            : out std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_I            : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0) := (others => '0');
        O_RESET_L           : in  std_logic := '0';
        O_RESET_D           : in  std_logic := '0';
        O_RESET_Q           : out std_logic;
        O_START_L           : in  std_logic := '0';
        O_START_D           : in  std_logic := '0';
        O_START_Q           : out std_logic;
        O_STOP_L            : in  std_logic := '0';
        O_STOP_D            : in  std_logic := '0';
        O_STOP_Q            : out std_logic;
        O_PAUSE_L           : in  std_logic := '0';
        O_PAUSE_D           : in  std_logic := '0';
        O_PAUSE_Q           : out std_logic;
        O_FIRST_L           : in  std_logic := '0';
        O_FIRST_D           : in  std_logic := '0';
        O_FIRST_Q           : out std_logic;
        O_LAST_L            : in  std_logic := '0';
        O_LAST_D            : in  std_logic := '0';
        O_LAST_Q            : out std_logic;
        O_DONE_EN_L         : in  std_logic := '0';
        O_DONE_EN_D         : in  std_logic := '0';
        O_DONE_EN_Q         : out std_logic;
        O_DONE_ST_L         : in  std_logic := '0';
        O_DONE_ST_D         : in  std_logic := '0';
        O_DONE_ST_Q         : out std_logic;
        O_ERR_ST_L          : in  std_logic := '0';
        O_ERR_ST_D          : in  std_logic := '0';
        O_ERR_ST_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Configuration Signals.
    -------------------------------------------------------------------------------
        O_ADDR_FIX          : in  std_logic := '0';
        O_BUF_READY_LEVEL   : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_FLOW_READY_LEVEL  : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        I_REQ_VALID         : out std_logic;
        I_REQ_ADDR          : out std_logic_vector(I_REQ_ADDR_BITS-1 downto 0);
        I_REQ_SIZE          : out std_logic_vector(I_REQ_SIZE_BITS-1 downto 0);
        I_REQ_BUF_PTR       : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        I_REQ_FIRST         : out std_logic;
        I_REQ_LAST          : out std_logic;
        I_REQ_NONE          : out std_logic;
        I_REQ_READY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        I_ACK_VALID         : in  std_logic;
        I_ACK_SIZE          : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_ACK_ERROR         : in  std_logic;
        I_ACK_NEXT          : in  std_logic;
        I_ACK_LAST          : in  std_logic;
        I_ACK_STOP          : in  std_logic;
        I_ACK_NONE          : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transfer Status Signals.
    -------------------------------------------------------------------------------
        I_XFER_BUSY         : in  std_logic;
        I_XFER_DONE         : in  std_logic;
        I_XFER_ERROR        : in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        I_FLOW_READY        : out std_logic;
        I_FLOW_PAUSE        : out std_logic;
        I_FLOW_STOP         : out std_logic;
        I_FLOW_LAST         : out std_logic;
        I_FLOW_SIZE         : out std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_FIN_VALID    : in  std_logic := '0';
        I_PUSH_FIN_LAST     : in  std_logic := '0';
        I_PUSH_FIN_ERROR    : in  std_logic := '0';
        I_PUSH_FIN_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_RSV_VALID    : in  std_logic := '0';
        I_PUSH_RSV_LAST     : in  std_logic := '0';
        I_PUSH_RSV_ERROR    : in  std_logic := '0';
        I_PUSH_RSV_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_BUF_RESET    : in  std_logic := '0';
        I_PUSH_BUF_VALID    : in  std_logic := '0';
        I_PUSH_BUF_LAST     : in  std_logic := '0';
        I_PUSH_BUF_ERROR    : in  std_logic := '0';
        I_PUSH_BUF_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Status.
    -------------------------------------------------------------------------------
        I_OPEN              : out std_logic;
        I_RUNNING           : out std_logic;
        I_DONE              : out std_logic;
        I_NONE              : out std_logic;
        I_ERROR             : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        O_REQ_VALID         : out std_logic;
        O_REQ_ADDR          : out std_logic_vector(O_REQ_ADDR_BITS-1 downto 0);
        O_REQ_SIZE          : out std_logic_vector(O_REQ_SIZE_BITS-1 downto 0);
        O_REQ_BUF_PTR       : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        O_REQ_FIRST         : out std_logic;
        O_REQ_LAST          : out std_logic;
        O_REQ_NONE          : out std_logic;
        O_REQ_READY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Transaction Command Response Signals.
    -------------------------------------------------------------------------------
        O_ACK_VALID         : in  std_logic;
        O_ACK_SIZE          : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_ACK_ERROR         : in  std_logic;
        O_ACK_NEXT          : in  std_logic;
        O_ACK_LAST          : in  std_logic;
        O_ACK_STOP          : in  std_logic;
        O_ACK_NONE          : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Transfer Status Signals.
    -------------------------------------------------------------------------------
        O_XFER_BUSY         : in  std_logic;
        O_XFER_DONE         : in  std_logic;
        O_XFER_ERROR        : in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        O_FLOW_READY        : out std_logic;
        O_FLOW_PAUSE        : out std_logic;
        O_FLOW_STOP         : out std_logic;
        O_FLOW_LAST         : out std_logic;
        O_FLOW_SIZE         : out std_logic_vector(BUF_DEPTH         downto 0);
        O_PULL_FIN_VALID    : in  std_logic := '0';
        O_PULL_FIN_LAST     : in  std_logic := '0';
        O_PULL_FIN_ERROR    : in  std_logic := '0';
        O_PULL_FIN_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        O_PULL_RSV_VALID    : in  std_logic := '0';
        O_PULL_RSV_LAST     : in  std_logic := '0';
        O_PULL_RSV_ERROR    : in  std_logic := '0';
        O_PULL_RSV_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        O_PULL_BUF_RESET    : in  std_logic := '0';
        O_PULL_BUF_VALID    : in  std_logic := '0';
        O_PULL_BUF_LAST     : in  std_logic := '0';
        O_PULL_BUF_ERROR    : in  std_logic := '0';
        O_PULL_BUF_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        O_PULL_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Status.
    -------------------------------------------------------------------------------
        O_OPEN              : out std_logic;
        O_RUNNING           : out std_logic;
        O_DONE              : out std_logic;
        O_NONE              : out std_logic;
        O_ERROR             : out std_logic
    );
end PUMP_CONTROLLER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER_INTAKE_SIDE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER_OUTLET_SIDE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_FLOW_SYNCRONIZER;
architecture RTL of PUMP_CONTROLLER is
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_BITS          :  integer := BUF_DEPTH+1;
    -------------------------------------------------------------------------------
    -- 入力側の各種信号群.
    -------------------------------------------------------------------------------
    signal   i_valve_open       :  std_logic;
    -------------------------------------------------------------------------------
    -- 出力側の各種信号群.
    -------------------------------------------------------------------------------
    signal   o_valve_open       :  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側->出力側の各種信号群.
    -------------------------------------------------------------------------------
    signal   i2o_valve_open     :  std_logic;
    signal   i2o_push_fin_valid :  std_logic;
    signal   i2o_push_fin_last  :  std_logic;
    signal   i2o_push_fin_size  :  std_logic_vector(SIZE_BITS      -1 downto 0);
    signal   i2o_push_rsv_valid :  std_logic;
    signal   i2o_push_rsv_last  :  std_logic;
    signal   i2o_push_rsv_size  :  std_logic_vector(SIZE_BITS      -1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側->入力側の各種信号群.
    -------------------------------------------------------------------------------
    signal   o2i_valve_open     :  std_logic;
    signal   o2i_pull_fin_valid :  std_logic;
    signal   o2i_pull_fin_last  :  std_logic;
    signal   o2i_pull_fin_size  :  std_logic_vector(SIZE_BITS      -1 downto 0);
    signal   o2i_pull_rsv_valid :  std_logic;
    signal   o2i_pull_rsv_last  :  std_logic;
    signal   o2i_pull_rsv_size  :  std_logic_vector(SIZE_BITS      -1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 入力側の制御
    -------------------------------------------------------------------------------
    I_SIDE: PUMP_CONTROLLER_INTAKE_SIDE                  -- 
        generic map (                                    -- 
            REQ_ADDR_VALID      => I_REQ_ADDR_VALID    , -- 
            REQ_ADDR_BITS       => I_REQ_ADDR_BITS     , --   
            REG_ADDR_BITS       => I_REG_ADDR_BITS     , --   
            REQ_SIZE_VALID      => I_REQ_SIZE_VALID    , --   
            REQ_SIZE_BITS       => I_REQ_SIZE_BITS     , --   
            REG_SIZE_BITS       => I_REG_SIZE_BITS     , --   
            REG_MODE_BITS       => I_REG_MODE_BITS     , --   
            REG_STAT_BITS       => I_REG_STAT_BITS     , --   
            FIXED_FLOW_OPEN     => I_FIXED_FLOW_OPEN   , --   
            FIXED_POOL_OPEN     => I_FIXED_POOL_OPEN   , --   
            USE_PUSH_BUF_SIZE   => I_USE_PUSH_BUF_SIZE , --   
            USE_PULL_RSV_SIZE   => O_USE_PULL_RSV_SIZE , --   
            BUF_DEPTH           => BUF_DEPTH             --   
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => I_CLK               , -- In  :
            RST                 => RST                 , -- In  :
            CLR                 => I_CLR               , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Control Status Register Interface.
        ---------------------------------------------------------------------------
            REG_ADDR_L          => I_ADDR_L            , -- In  :
            REG_ADDR_D          => I_ADDR_D            , -- In  :
            REG_ADDR_Q          => I_ADDR_Q            , -- Out :
            REG_SIZE_L          => I_SIZE_L            , -- In  :
            REG_SIZE_D          => I_SIZE_D            , -- In  :
            REG_SIZE_Q          => I_SIZE_Q            , -- Out :
            REG_MODE_L          => I_MODE_L            , -- In  :
            REG_MODE_D          => I_MODE_D            , -- In  :
            REG_MODE_Q          => I_MODE_Q            , -- Out :
            REG_STAT_L          => I_STAT_L            , -- In  :
            REG_STAT_D          => I_STAT_D            , -- In  :
            REG_STAT_Q          => I_STAT_Q            , -- Out :
            REG_STAT_I          => I_STAT_I            , -- In  :
            REG_RESET_L         => I_RESET_L           , -- In  :
            REG_RESET_D         => I_RESET_D           , -- In  :
            REG_RESET_Q         => I_RESET_Q           , -- Out :
            REG_START_L         => I_START_L           , -- In  :
            REG_START_D         => I_START_D           , -- In  :
            REG_START_Q         => I_START_Q           , -- Out :
            REG_STOP_L          => I_STOP_L            , -- In  :
            REG_STOP_D          => I_STOP_D            , -- In  :
            REG_STOP_Q          => I_STOP_Q            , -- Out :
            REG_PAUSE_L         => I_PAUSE_L           , -- In  :
            REG_PAUSE_D         => I_PAUSE_D           , -- In  :
            REG_PAUSE_Q         => I_PAUSE_Q           , -- Out :
            REG_FIRST_L         => I_FIRST_L           , -- In  :
            REG_FIRST_D         => I_FIRST_D           , -- In  :
            REG_FIRST_Q         => I_FIRST_Q           , -- Out :
            REG_LAST_L          => I_LAST_L            , -- In  :
            REG_LAST_D          => I_LAST_D            , -- In  :
            REG_LAST_Q          => I_LAST_Q            , -- Out :
            REG_DONE_EN_L       => I_DONE_EN_L         , -- In  :
            REG_DONE_EN_D       => I_DONE_EN_D         , -- In  :
            REG_DONE_EN_Q       => I_DONE_EN_Q         , -- Out :
            REG_DONE_ST_L       => I_DONE_ST_L         , -- In  :
            REG_DONE_ST_D       => I_DONE_ST_D         , -- In  :
            REG_DONE_ST_Q       => I_DONE_ST_Q         , -- Out :
            REG_ERR_ST_L        => I_ERR_ST_L          , -- In  :
            REG_ERR_ST_D        => I_ERR_ST_D          , -- In  :
            REG_ERR_ST_Q        => I_ERR_ST_Q          , -- Out :
        ---------------------------------------------------------------------------
        -- Intake Configuration Signals.
        ---------------------------------------------------------------------------
            ADDR_FIX            => I_ADDR_FIX          , -- In  :
            BUF_READY_LEVEL     => I_BUF_READY_LEVEL   , -- In  :
            FLOW_READY_LEVEL    => I_FLOW_READY_LEVEL  , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_VALID           => I_REQ_VALID         , -- Out :
            REQ_ADDR            => I_REQ_ADDR          , -- Out :
            REQ_SIZE            => I_REQ_SIZE          , -- Out :
            REQ_BUF_PTR         => I_REQ_BUF_PTR       , -- Out :
            REQ_FIRST           => I_REQ_FIRST         , -- Out :
            REQ_LAST            => I_REQ_LAST          , -- Out :
            REQ_NONE            => I_REQ_NONE          , -- Out :
            REQ_READY           => I_REQ_READY         , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            ACK_VALID           => I_ACK_VALID         , -- In  :
            ACK_SIZE            => I_ACK_SIZE          , -- In  :
            ACK_ERROR           => I_ACK_ERROR         , -- In  :
            ACK_NEXT            => I_ACK_NEXT          , -- In  :
            ACK_LAST            => I_ACK_LAST          , -- In  :
            ACK_STOP            => I_ACK_STOP          , -- In  :
            ACK_NONE            => I_ACK_NONE          , -- In  :
        ---------------------------------------------------------------------------
        -- Intake_Transfer Status Signals.
        ---------------------------------------------------------------------------
            XFER_BUSY           => I_XFER_BUSY         , -- In  :
            XFER_DONE           => I_XFER_DONE         , -- In  :
            XFER_ERROR          => I_XFER_ERROR        , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY          => I_FLOW_READY        , -- Out :
            FLOW_PAUSE          => I_FLOW_PAUSE        , -- Out :
            FLOW_STOP           => I_FLOW_STOP         , -- Out :
            FLOW_LAST           => I_FLOW_LAST         , -- Out :
            FLOW_SIZE           => I_FLOW_SIZE         , -- Out :
            PUSH_FIN_VALID      => I_PUSH_FIN_VALID    , -- In  :
            PUSH_FIN_LAST       => I_PUSH_FIN_LAST     , -- In  :
            PUSH_FIN_ERROR      => I_PUSH_FIN_ERROR    , -- In  :
            PUSH_FIN_SIZE       => I_PUSH_FIN_SIZE     , -- In  :
            PUSH_RSV_VALID      => I_PUSH_RSV_VALID    , -- In  :
            PUSH_RSV_LAST       => I_PUSH_RSV_LAST     , -- In  :
            PUSH_RSV_ERROR      => I_PUSH_RSV_ERROR    , -- In  :
            PUSH_RSV_SIZE       => I_PUSH_RSV_SIZE     , -- In  :
            PUSH_BUF_RESET      => I_PUSH_BUF_RESET    , -- In  :
            PUSH_BUF_VALID      => I_PUSH_BUF_VALID    , -- In  :
            PUSH_BUF_LAST       => I_PUSH_BUF_LAST     , -- In  :
            PUSH_BUF_ERROR      => I_PUSH_BUF_ERROR    , -- In  :
            PUSH_BUF_SIZE       => I_PUSH_BUF_SIZE     , -- In  :
            PUSH_BUF_READY      => I_PUSH_BUF_READY    , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet to Intake Flow Control Signals.
        ---------------------------------------------------------------------------
            PULL_FIN_VALID      => o2i_pull_fin_valid  , -- In  :
            PULL_FIN_LAST       => o2i_pull_fin_last   , -- In  :
            PULL_FIN_SIZE       => o2i_pull_fin_size   , -- In  :
            PULL_RSV_VALID      => o2i_pull_rsv_valid  , -- In  :
            PULL_RSV_LAST       => o2i_pull_rsv_last   , -- In  :
            PULL_RSV_SIZE       => o2i_pull_rsv_size   , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Status Input.
        ---------------------------------------------------------------------------
            O_OPEN              => o2i_valve_open      , -- In  :
            O_STOP              => '0'                 , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Status Output.
        ---------------------------------------------------------------------------
            I_OPEN              => i_valve_open        , -- Out :
            TRAN_BUSY           => I_RUNNING           , -- Out :
            TRAN_DONE           => I_DONE              , -- Out :
            TRAN_NONE           => I_NONE              , -- Out :
            TRAN_ERROR          => I_ERROR               -- Out :
        );
    I_OPEN <= i_valve_open;
    -------------------------------------------------------------------------------
    -- 出力側の制御
    -------------------------------------------------------------------------------
    O_SIDE: PUMP_CONTROLLER_OUTLET_SIDE                  -- 
        generic map (                                    -- 
            REQ_ADDR_VALID      => O_REQ_ADDR_VALID    , -- 
            REQ_ADDR_BITS       => O_REQ_ADDR_BITS     , --   
            REG_ADDR_BITS       => O_REG_ADDR_BITS     , --   
            REQ_SIZE_VALID      => O_REQ_SIZE_VALID    , --   
            REQ_SIZE_BITS       => O_REQ_SIZE_BITS     , --   
            REG_SIZE_BITS       => O_REG_SIZE_BITS     , --   
            REG_MODE_BITS       => O_REG_MODE_BITS     , --   
            REG_STAT_BITS       => O_REG_STAT_BITS     , --   
            FIXED_FLOW_OPEN     => O_FIXED_FLOW_OPEN   , --   
            FIXED_POOL_OPEN     => O_FIXED_POOL_OPEN   , --   
            USE_PULL_BUF_SIZE   => O_USE_PULL_BUF_SIZE , --   
            USE_PUSH_RSV_SIZE   => I_USE_PUSH_RSV_SIZE , --   
            BUF_DEPTH           => BUF_DEPTH             --   
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => O_CLK               , -- In  :
            RST                 => RST                 , -- In  :
            CLR                 => O_CLR               , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Control Status Register Interface.
        ---------------------------------------------------------------------------
            REG_ADDR_L          => O_ADDR_L            , -- In  :
            REG_ADDR_D          => O_ADDR_D            , -- In  :
            REG_ADDR_Q          => O_ADDR_Q            , -- Out :
            REG_SIZE_L          => O_SIZE_L            , -- In  :
            REG_SIZE_D          => O_SIZE_D            , -- In  :
            REG_SIZE_Q          => O_SIZE_Q            , -- Out :
            REG_MODE_L          => O_MODE_L            , -- In  :
            REG_MODE_D          => O_MODE_D            , -- In  :
            REG_MODE_Q          => O_MODE_Q            , -- Out :
            REG_STAT_L          => O_STAT_L            , -- In  :
            REG_STAT_D          => O_STAT_D            , -- In  :
            REG_STAT_Q          => O_STAT_Q            , -- Out :
            REG_STAT_I          => O_STAT_I            , -- In  :
            REG_RESET_L         => O_RESET_L           , -- In  :
            REG_RESET_D         => O_RESET_D           , -- In  :
            REG_RESET_Q         => O_RESET_Q           , -- Out :
            REG_START_L         => O_START_L           , -- In  :
            REG_START_D         => O_START_D           , -- In  :
            REG_START_Q         => O_START_Q           , -- Out :
            REG_STOP_L          => O_STOP_L            , -- In  :
            REG_STOP_D          => O_STOP_D            , -- In  :
            REG_STOP_Q          => O_STOP_Q            , -- Out :
            REG_PAUSE_L         => O_PAUSE_L           , -- In  :
            REG_PAUSE_D         => O_PAUSE_D           , -- In  :
            REG_PAUSE_Q         => O_PAUSE_Q           , -- Out :
            REG_FIRST_L         => O_FIRST_L           , -- In  :
            REG_FIRST_D         => O_FIRST_D           , -- In  :
            REG_FIRST_Q         => O_FIRST_Q           , -- Out :
            REG_LAST_L          => O_LAST_L            , -- In  :
            REG_LAST_D          => O_LAST_D            , -- In  :
            REG_LAST_Q          => O_LAST_Q            , -- Out :
            REG_DONE_EN_L       => O_DONE_EN_L         , -- In  :
            REG_DONE_EN_D       => O_DONE_EN_D         , -- In  :
            REG_DONE_EN_Q       => O_DONE_EN_Q         , -- Out :
            REG_DONE_ST_L       => O_DONE_ST_L         , -- In  :
            REG_DONE_ST_D       => O_DONE_ST_D         , -- In  :
            REG_DONE_ST_Q       => O_DONE_ST_Q         , -- Out :
            REG_ERR_ST_L        => O_ERR_ST_L          , -- In  :
            REG_ERR_ST_D        => O_ERR_ST_D          , -- In  :
            REG_ERR_ST_Q        => O_ERR_ST_Q          , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Configuration Signals.
        ---------------------------------------------------------------------------
            ADDR_FIX            => O_ADDR_FIX          , -- In  :
            BUF_READY_LEVEL     => O_BUF_READY_LEVEL   , -- In  :
            FLOW_READY_LEVEL    => O_FLOW_READY_LEVEL  , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_VALID           => O_REQ_VALID         , -- Out :
            REQ_ADDR            => O_REQ_ADDR          , -- Out :
            REQ_SIZE            => O_REQ_SIZE          , -- Out :
            REQ_BUF_PTR         => O_REQ_BUF_PTR       , -- Out :
            REQ_FIRST           => O_REQ_FIRST         , -- Out :
            REQ_LAST            => O_REQ_LAST          , -- Out :
            REQ_NONE            => O_REQ_NONE          , -- Out :
            REQ_READY           => O_REQ_READY         , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            ACK_VALID           => O_ACK_VALID         , -- In  :
            ACK_SIZE            => O_ACK_SIZE          , -- In  :
            ACK_ERROR           => O_ACK_ERROR         , -- In  :
            ACK_NEXT            => O_ACK_NEXT          , -- In  :
            ACK_LAST            => O_ACK_LAST          , -- In  :
            ACK_STOP            => O_ACK_STOP          , -- In  :
            ACK_NONE            => O_ACK_NONE          , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Transfer Status Signals.
        ---------------------------------------------------------------------------
            XFER_BUSY           => O_XFER_BUSY         , -- In  :
            XFER_DONE           => O_XFER_DONE         , -- In  :
            XFER_ERROR          => O_XFER_ERROR        , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY          => O_FLOW_READY        , -- Out :
            FLOW_PAUSE          => O_FLOW_PAUSE        , -- Out :
            FLOW_STOP           => O_FLOW_STOP         , -- Out :
            FLOW_LAST           => O_FLOW_LAST         , -- Out :
            FLOW_SIZE           => O_FLOW_SIZE         , -- Out :
            PULL_FIN_VALID      => O_PULL_FIN_VALID    , -- In  :
            PULL_FIN_LAST       => O_PULL_FIN_LAST     , -- In  :
            PULL_FIN_ERROR      => O_PULL_FIN_ERROR    , -- In  :
            PULL_FIN_SIZE       => O_PULL_FIN_SIZE     , -- In  :
            PULL_RSV_VALID      => O_PULL_RSV_VALID    , -- In  :
            PULL_RSV_LAST       => O_PULL_RSV_LAST     , -- In  :
            PULL_RSV_ERROR      => O_PULL_RSV_ERROR    , -- In  :
            PULL_RSV_SIZE       => O_PULL_RSV_SIZE     , -- In  :
            PULL_BUF_RESET      => O_PULL_BUF_RESET    , -- In  :
            PULL_BUF_VALID      => O_PULL_BUF_VALID    , -- In  :
            PULL_BUF_LAST       => O_PULL_BUF_LAST     , -- In  :
            PULL_BUF_ERROR      => O_PULL_BUF_ERROR    , -- In  :
            PULL_BUF_SIZE       => O_PULL_BUF_SIZE     , -- In  :
            PULL_BUF_READY      => O_PULL_BUF_READY    , -- Out :
        ---------------------------------------------------------------------------
        -- Intake to Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VALID      => i2o_push_fin_valid  , -- In  :
            PUSH_FIN_LAST       => i2o_push_fin_last   , -- In  :
            PUSH_FIN_SIZE       => i2o_push_fin_size   , -- In  :
            PUSH_RSV_VALID      => i2o_push_rsv_valid  , -- In  :
            PUSH_RSV_LAST       => i2o_push_rsv_last   , -- In  :
            PUSH_RSV_SIZE       => i2o_push_rsv_size   , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Status Input.
        ---------------------------------------------------------------------------
            I_OPEN              => i2o_valve_open      , -- In  :
            I_STOP              => '0'                 , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Status Output.
        ---------------------------------------------------------------------------
            O_OPEN              => o_valve_open        , -- Out :
            TRAN_BUSY           => O_RUNNING           , -- Out :
            TRAN_DONE           => O_DONE              , -- Out :
            TRAN_NONE           => O_NONE              , -- Out :
            TRAN_ERROR          => O_ERROR               -- Out :
        );
    O_OPEN <= o_valve_open;
    -------------------------------------------------------------------------------
    -- 入力側から出力側への各種情報転送
    -------------------------------------------------------------------------------
    I2O: block
        constant  i_open_info   :  std_logic_vector(0 downto 0) := (others => '0');
        constant  i_close_info  :  std_logic_vector(0 downto 0) := (others => '0');
        constant  i_event       :  std_logic_vector(0 downto 0) := (others => '0');
        signal    i_open_valid  :  std_logic;
        signal    i_close_valid :  std_logic;
        signal    o_open_valid  :  std_logic;
        signal    o_close_valid :  std_logic;
        signal    ii_valve_open :  std_logic;
        signal    oo_valve_open :  std_logic;
        constant  null_valid    :  std_logic := '0';
        constant  null_last     :  std_logic := '0';
        constant  null_size     :  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        -- 入力側のバルブの開閉情報
        ---------------------------------------------------------------------------
        process (I_CLK, RST) begin
            if (RST = '1') then
                    ii_valve_open <= '0';
            elsif (I_CLK'event and I_CLK = '1') then
                if (I_CLR = '1') then
                    ii_valve_open <= '0';
                else
                    ii_valve_open <= i_valve_open;
                end if;
            end if;
        end process;
        i_open_valid  <= '1' when (i_valve_open = '1' and ii_valve_open = '0') else '0';
        i_close_valid <= '1' when (i_valve_open = '0' and ii_valve_open = '1') else '0';
        ---------------------------------------------------------------------------
        -- クロック同期回路
        ---------------------------------------------------------------------------
        SYNC: PUMP_FLOW_SYNCRONIZER                      -- 
            generic map (                                --
                I_CLK_RATE      => I_CLK_RATE          , -- 
                O_CLK_RATE      => O_CLK_RATE          , --
                OPEN_INFO_BITS  => i_open_info'length  , --
                CLOSE_INFO_BITS => i_close_info'length , --
                EVENT_SIZE      => i_event'length      , --
                XFER_SIZE_BITS  => SIZE_BITS           , --
                PUSH_FIN_DELAY  => I2O_DELAY_CYCLE     , --
                PUSH_FIN_VALID  => 1                   , --
                PUSH_RSV_VALID  => 1                   , --
                PULL_FIN_VALID  => 0                   , --
                PULL_RSV_VALID  => 0                     --
            )                                            -- 
            port map (                                   -- 
            ---------------------------------------------------------------------------
            -- Asyncronous Reset Signal.
            ---------------------------------------------------------------------------
                RST             => RST                 , -- In  :
            ---------------------------------------------------------------------------
            -- Input
            ---------------------------------------------------------------------------
                I_CLK           => I_CLK               , -- In  :
                I_CLR           => I_CLR               , -- In  :
                I_CKE           => I_CKE               , -- In  :
                I_OPEN_VAL      => i_open_valid        , -- In  :
                I_OPEN_INFO     => i_open_info         , -- In  :
                I_CLOSE_VAL     => i_close_valid       , -- In  :
                I_CLOSE_INFO    => i_close_info        , -- In  :
                I_EVENT         => i_event             , -- In  :
                I_PUSH_FIN_VAL  => I_PUSH_FIN_VALID    , -- In  :
                I_PUSH_FIN_LAST => I_PUSH_FIN_LAST     , -- In  :
                I_PUSH_FIN_SIZE => I_PUSH_FIN_SIZE     , -- In  :
                I_PUSH_RSV_VAL  => I_PUSH_RSV_VALID    , -- In  :
                I_PUSH_RSV_LAST => I_PUSH_RSV_LAST     , -- In  :
                I_PUSH_RSV_SIZE => I_PUSH_RSV_SIZE     , -- In  :
                I_PULL_FIN_VAL  => null_valid          , -- In  :
                I_PULL_FIN_LAST => null_last           , -- In  :
                I_PULL_FIN_SIZE => null_size           , -- In  :
                I_PULL_RSV_VAL  => null_valid          , -- In  :
                I_PULL_RSV_LAST => null_last           , -- In  :
                I_PULL_RSV_SIZE => null_size           , -- In  :
            ---------------------------------------------------------------------------
            -- Output 
            ---------------------------------------------------------------------------
                O_CLK           => O_CLK               , -- In  :
                O_CLR           => O_CLR               , -- In  :
                O_CKE           => O_CKE               , -- In  :
                O_OPEN_VAL      => o_open_valid        , -- Out :
                O_OPEN_INFO     => open                , -- Out :
                O_CLOSE_VAL     => o_close_valid       , -- Out :
                O_CLOSE_INFO    => open                , -- Out :
                O_EVENT         => open                , -- Out :
                O_PUSH_FIN_VAL  => i2o_push_fin_valid  , -- Out :
                O_PUSH_FIN_LAST => i2o_push_fin_last   , -- Out :
                O_PUSH_FIN_SIZE => i2o_push_fin_size   , -- Out :
                O_PUSH_RSV_VAL  => i2o_push_rsv_valid  , -- Out :
                O_PUSH_RSV_LAST => i2o_push_rsv_last   , -- Out :
                O_PUSH_RSV_SIZE => i2o_push_rsv_size   , -- Out :
                O_PULL_FIN_VAL  => open                , -- Out :
                O_PULL_FIN_LAST => open                , -- Out :
                O_PULL_FIN_SIZE => open                , -- Out :
                O_PULL_RSV_VAL  => open                , -- Out :
                O_PULL_RSV_LAST => open                , -- Out :
                O_PULL_RSV_SIZE => open                  -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- 入力側のバルブの状態を出力側のクロックに同期
        ---------------------------------------------------------------------------
        process (O_CLK, RST) begin
            if (RST = '1') then
                    oo_valve_open <= '0';
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1' or o_close_valid = '1') then
                    oo_valve_open <= '0';
                elsif (o_open_valid  = '1') then
                    oo_valve_open <= '1';
                end if;
            end if;
        end process;
        i2o_valve_open <= '1' when (oo_valve_open = '1' and o_close_valid = '0') or
                                   (o_open_valid  = '1') else '0';
    end block;        
    -------------------------------------------------------------------------------
    -- 出力側から入力側への各種情報転送
    -------------------------------------------------------------------------------
    O2I: block
        constant  o_open_info   :  std_logic_vector(0 downto 0) := (others => '0');
        constant  o_close_info  :  std_logic_vector(0 downto 0) := (others => '0');
        constant  o_event       :  std_logic_vector(0 downto 0) := (others => '0');
        signal    o_open_valid  :  std_logic;
        signal    o_close_valid :  std_logic;
        signal    i_open_valid  :  std_logic;
        signal    i_close_valid :  std_logic;
        signal    oo_valve_open :  std_logic;
        signal    ii_valve_open :  std_logic;
        constant  null_valid    :  std_logic := '0';
        constant  null_last     :  std_logic := '0';
        constant  null_size     :  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        -- 出力側のバルブの開閉情報
        ---------------------------------------------------------------------------
        process (O_CLK, RST) begin
            if (RST = '1') then
                    oo_valve_open <= '0';
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1') then
                    oo_valve_open <= '0';
                else
                    oo_valve_open <= o_valve_open;
                end if;
            end if;
        end process;
        o_open_valid  <= '1' when (o_valve_open = '1' and oo_valve_open = '0') else '0';
        o_close_valid <= '1' when (o_valve_open = '0' and oo_valve_open = '1') else '0';
        ---------------------------------------------------------------------------
        -- クロック同期回路
        ---------------------------------------------------------------------------
        SYNC: PUMP_FLOW_SYNCRONIZER                      -- 
            generic map (                                --
                I_CLK_RATE      => O_CLK_RATE          , -- 
                O_CLK_RATE      => I_CLK_RATE          , --
                OPEN_INFO_BITS  => o_open_info'length  , --
                CLOSE_INFO_BITS => o_close_info'length , --
                EVENT_SIZE      => o_event'length      , --
                XFER_SIZE_BITS  => SIZE_BITS           , --
                PUSH_FIN_DELAY  => 0                   , --
                PUSH_FIN_VALID  => 0                   , --
                PUSH_RSV_VALID  => 0                   , --
                PULL_FIN_VALID  => 1                   , --
                PULL_RSV_VALID  => 1                     --
            )                                            -- 
            port map (                                   -- 
            ---------------------------------------------------------------------------
            -- Asyncronous Reset Signal.
            ---------------------------------------------------------------------------
                RST             => RST                 , -- In  :
            ---------------------------------------------------------------------------
            -- Input
            ---------------------------------------------------------------------------
                I_CLK           => O_CLK               , -- In  :
                I_CLR           => O_CLR               , -- In  :
                I_CKE           => O_CKE               , -- In  :
                I_OPEN_VAL      => o_open_valid        , -- In  :
                I_OPEN_INFO     => o_open_info         , -- In  :
                I_CLOSE_VAL     => o_close_valid       , -- In  :
                I_CLOSE_INFO    => o_close_info        , -- In  :
                I_EVENT         => o_event             , -- In  :
                I_PUSH_FIN_VAL  => null_valid          , -- In  :
                I_PUSH_FIN_LAST => null_last           , -- In  :
                I_PUSH_FIN_SIZE => null_size           , -- In  :
                I_PUSH_RSV_VAL  => null_valid          , -- In  :
                I_PUSH_RSV_LAST => null_last           , -- In  :
                I_PUSH_RSV_SIZE => null_size           , -- In  :
                I_PULL_FIN_VAL  => O_PULL_FIN_VALID    , -- In  :
                I_PULL_FIN_LAST => O_PULL_FIN_LAST     , -- In  :
                I_PULL_FIN_SIZE => O_PULL_FIN_SIZE     , -- In  :
                I_PULL_RSV_VAL  => O_PULL_RSV_VALID    , -- In  :
                I_PULL_RSV_LAST => O_PULL_RSV_LAST     , -- In  :
                I_PULL_RSV_SIZE => O_PULL_RSV_SIZE     , -- In  :
            ---------------------------------------------------------------------------
            -- Output 
            ---------------------------------------------------------------------------
                O_CLK           => I_CLK               , -- In  :
                O_CLR           => I_CLR               , -- In  :
                O_CKE           => I_CKE               , -- In  :
                O_OPEN_VAL      => i_open_valid        , -- Out :
                O_OPEN_INFO     => open                , -- Out :
                O_CLOSE_VAL     => i_close_valid       , -- Out :
                O_CLOSE_INFO    => open                , -- Out :
                O_EVENT         => open                , -- Out :
                O_PUSH_FIN_VAL  => open                , -- Out :
                O_PUSH_FIN_LAST => open                , -- Out :
                O_PUSH_FIN_SIZE => open                , -- Out :
                O_PUSH_RSV_VAL  => open                , -- Out :
                O_PUSH_RSV_LAST => open                , -- Out :
                O_PUSH_RSV_SIZE => open                , -- Out :
                O_PULL_FIN_VAL  => o2i_pull_fin_valid  , -- Out :
                O_PULL_FIN_LAST => o2i_pull_fin_last   , -- Out :
                O_PULL_FIN_SIZE => o2i_pull_fin_size   , -- Out :
                O_PULL_RSV_VAL  => o2i_pull_rsv_valid  , -- Out :
                O_PULL_RSV_LAST => o2i_pull_rsv_last   , -- Out :
                O_PULL_RSV_SIZE => o2i_pull_rsv_size     -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- 出力側のバルブの状態を入力側のクロックに同期
        ---------------------------------------------------------------------------
        process (I_CLK, RST) begin
            if (RST = '1') then
                    ii_valve_open <= '0';
            elsif (I_CLK'event and I_CLK = '1') then
                if (I_CLR = '1' or i_close_valid = '1') then
                    ii_valve_open <= '0';
                elsif (i_open_valid  = '1') then
                    ii_valve_open <= '1';
                end if;
            end if;
        end process;
        o2i_valve_open <= '1' when (ii_valve_open = '1' and i_close_valid = '0') or
                                   (i_open_valid  = '1') else '0';
    end block;        
end RTL;
