-----------------------------------------------------------------------------------
--!     @file    pump_controller.vhd
--!     @brief   PUMP CONTROLLER
--!     @version 1.5.0
--!     @date    2013/5/19
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
                              integer range 0 to 1 :=  1;
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
                              integer range 0 to 1 :=  1;
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
                              integer range 0 to 1 :=  1;
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
                              integer range 0 to 1 :=  1;
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
        I_CKE               : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Control Register Interface.
    -------------------------------------------------------------------------------
        I_ADDR_L            : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_ADDR_D            : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_ADDR_Q            : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_SIZE_L            : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_SIZE_D            : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_SIZE_Q            : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_MODE_L            : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_MODE_D            : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_MODE_Q            : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_STAT_L            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_D            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_Q            : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_I            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_RESET_L           : in  std_logic;
        I_RESET_D           : in  std_logic;
        I_RESET_Q           : out std_logic;
        I_START_L           : in  std_logic;
        I_START_D           : in  std_logic;
        I_START_Q           : out std_logic;
        I_STOP_L            : in  std_logic;
        I_STOP_D            : in  std_logic;
        I_STOP_Q            : out std_logic;
        I_PAUSE_L           : in  std_logic;
        I_PAUSE_D           : in  std_logic;
        I_PAUSE_Q           : out std_logic;
        I_FIRST_L           : in  std_logic;
        I_FIRST_D           : in  std_logic;
        I_FIRST_Q           : out std_logic;
        I_LAST_L            : in  std_logic;
        I_LAST_D            : in  std_logic;
        I_LAST_Q            : out std_logic;
        I_DONE_EN_L         : in  std_logic;
        I_DONE_EN_D         : in  std_logic;
        I_DONE_EN_Q         : out std_logic;
        I_DONE_ST_L         : in  std_logic;
        I_DONE_ST_D         : in  std_logic;
        I_DONE_ST_Q         : out std_logic;
        I_ERR_ST_L          : in  std_logic;
        I_ERR_ST_D          : in  std_logic;
        I_ERR_ST_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Configuration Signals.
    -------------------------------------------------------------------------------
        I_ADDR_FIX          : in  std_logic;
        I_BUF_READY_LEVEL   : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_FLOW_READY_LEVEL  : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Clock and Clock Enable.
    -------------------------------------------------------------------------------
        O_CLK               : in  std_logic;
        O_CLR               : in  std_logic;
        O_CKE               : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Control Register Interface.
    -------------------------------------------------------------------------------
        O_ADDR_L            : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_ADDR_D            : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_ADDR_Q            : out std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_SIZE_L            : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_SIZE_D            : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_SIZE_Q            : out std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_MODE_L            : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_MODE_D            : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_MODE_Q            : out std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_STAT_L            : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_D            : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_Q            : out std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_I            : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_RESET_L           : in  std_logic;
        O_RESET_D           : in  std_logic;
        O_RESET_Q           : out std_logic;
        O_START_L           : in  std_logic;
        O_START_D           : in  std_logic;
        O_START_Q           : out std_logic;
        O_STOP_L            : in  std_logic;
        O_STOP_D            : in  std_logic;
        O_STOP_Q            : out std_logic;
        O_PAUSE_L           : in  std_logic;
        O_PAUSE_D           : in  std_logic;
        O_PAUSE_Q           : out std_logic;
        O_FIRST_L           : in  std_logic;
        O_FIRST_D           : in  std_logic;
        O_FIRST_Q           : out std_logic;
        O_LAST_L            : in  std_logic;
        O_LAST_D            : in  std_logic;
        O_LAST_Q            : out std_logic;
        O_DONE_EN_L         : in  std_logic;
        O_DONE_EN_D         : in  std_logic;
        O_DONE_EN_Q         : out std_logic;
        O_DONE_ST_L         : in  std_logic;
        O_DONE_ST_D         : in  std_logic;
        O_DONE_ST_Q         : out std_logic;
        O_ERR_ST_L          : in  std_logic;
        O_ERR_ST_D          : in  std_logic;
        O_ERR_ST_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Configuration Signals.
    -------------------------------------------------------------------------------
        O_ADDR_FIX          : in  std_logic;
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
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        I_FLOW_READY        : out std_logic;
        I_FLOW_PAUSE        : out std_logic;
        I_FLOW_STOP         : out std_logic;
        I_FLOW_LAST         : out std_logic;
        I_FLOW_SIZE         : out std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_FIN_VALID    : in  std_logic;
        I_PUSH_FIN_LAST     : in  std_logic;
        I_PUSH_FIN_ERROR    : in  std_logic;
        I_PUSH_FIN_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_RSV_VALID    : in  std_logic;
        I_PUSH_RSV_LAST     : in  std_logic;
        I_PUSH_RSV_ERROR    : in  std_logic;
        I_PUSH_RSV_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_BUF_RESET    : in  std_logic;
        I_PUSH_BUF_VALID    : in  std_logic;
        I_PUSH_BUF_LAST     : in  std_logic;
        I_PUSH_BUF_ERROR    : in  std_logic;
        I_PUSH_BUF_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Status.
    -------------------------------------------------------------------------------
        I_OPEN              : out std_logic;
        I_RUNNING           : out std_logic;
        I_DONE              : out std_logic;
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
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        O_FLOW_READY        : out std_logic;
        O_FLOW_PAUSE        : out std_logic;
        O_FLOW_STOP         : out std_logic;
        O_FLOW_LAST         : out std_logic;
        O_FLOW_SIZE         : out std_logic_vector(BUF_DEPTH         downto 0);
        O_PULL_FIN_VALID    : in  std_logic;
        O_PULL_FIN_LAST     : in  std_logic;
        O_PULL_FIN_ERROR    : in  std_logic;
        O_PULL_FIN_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_PULL_RSV_VALID    : in  std_logic;
        O_PULL_RSV_LAST     : in  std_logic;
        O_PULL_RSV_ERROR    : in  std_logic;
        O_PULL_RSV_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_PULL_BUF_RESET    : in  std_logic;
        O_PULL_BUF_VALID    : in  std_logic;
        O_PULL_BUF_LAST     : in  std_logic;
        O_PULL_BUF_ERROR    : in  std_logic;
        O_PULL_BUF_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_PULL_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Status.
    -------------------------------------------------------------------------------
        O_OPEN              : out std_logic;
        O_RUNNING           : out std_logic;
        O_DONE              : out std_logic;
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
use     PIPEWORK.COMPONENTS.COUNT_UP_REGISTER;
use     PIPEWORK.COMPONENTS.COUNT_DOWN_REGISTER;
use     PIPEWORK.COMPONENTS.FLOAT_INTAKE_MANIFOLD_VALVE;
use     PIPEWORK.COMPONENTS.FLOAT_OUTLET_MANIFOLD_VALVE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROL_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_FLOW_SYNCRONIZER;
architecture RTL of PUMP_CONTROLLER is
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_BITS          : integer := BUF_DEPTH+1;
    ------------------------------------------------------------------------------
    -- バッファのバイト数.
    ------------------------------------------------------------------------------
    constant BUFFER_SIZE        : std_logic_vector(SIZE_BITS-1  downto 0) := 
                                  std_logic_vector(to_unsigned(2**BUF_DEPTH, SIZE_BITS));
    ------------------------------------------------------------------------------
    -- バッファへのアクセス用信号群.
    ------------------------------------------------------------------------------
    constant BUF_INIT_PTR       : std_logic_vector(BUF_DEPTH      -1 downto 0) := (others => '0');
    constant BUF_UP_BEN         : std_logic_vector(BUF_DEPTH      -1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- 入力側の各種信号群.
    -------------------------------------------------------------------------------
    signal   i_addr_up_ben      : std_logic_vector(I_REQ_ADDR_BITS-1 downto 0);
    signal   i_buf_ptr_init     : std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal   i_reset            : std_logic;
    signal   i_pause            : std_logic;
    signal   i_stop             : std_logic;
    signal   i_valve_open       : std_logic;
    signal   i_tran_running     : std_logic;
    constant i_valve_load       : std_logic := '0';
    -------------------------------------------------------------------------------
    -- 出力側の各種信号群.
    -------------------------------------------------------------------------------
    signal   o_addr_up_ben      : std_logic_vector(O_REQ_ADDR_BITS-1 downto 0);
    signal   o_buf_ptr_init     : std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal   o_reset            : std_logic;
    signal   o_pause            : std_logic;
    signal   o_stop             : std_logic;
    signal   o_valve_open       : std_logic;
    signal   o_tran_running     : std_logic;
    constant o_valve_load       : std_logic := '0';
    -------------------------------------------------------------------------------
    -- 入力側->出力側の各種信号群.
    -------------------------------------------------------------------------------
    signal   i2o_valve_open     : std_logic;
    signal   i2o_push_fin_valid : std_logic;
    signal   i2o_push_fin_last  : std_logic;
    signal   i2o_push_fin_size  : std_logic_vector(SIZE_BITS      -1 downto 0);
    signal   i2o_push_rsv_valid : std_logic;
    signal   i2o_push_rsv_last  : std_logic;
    signal   i2o_push_rsv_size  : std_logic_vector(SIZE_BITS      -1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側->入力側の各種信号群.
    -------------------------------------------------------------------------------
    signal   o2i_valve_open     : std_logic;
    signal   o2i_pull_fin_valid : std_logic;
    signal   o2i_pull_fin_last  : std_logic;
    signal   o2i_pull_fin_size  : std_logic_vector(SIZE_BITS      -1 downto 0);
    signal   o2i_pull_rsv_valid : std_logic;
    signal   o2i_pull_rsv_last  : std_logic;
    signal   o2i_pull_rsv_size  : std_logic_vector(SIZE_BITS      -1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_ADDR_REGS: COUNT_UP_REGISTER                   -- 
        generic map (                                -- 
            VALID           => I_REQ_ADDR_VALID    , -- 
            BITS            => I_REQ_ADDR_BITS     , -- 
            REGS_BITS       => I_REG_ADDR_BITS       -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => I_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => I_CLR               , -- In  :
            REGS_WEN        => I_ADDR_L            , -- In  :
            REGS_WDATA      => I_ADDR_D            , -- In  :
            REGS_RDATA      => I_ADDR_Q            , -- Out :
            UP_ENA          => i_tran_running      , -- In  :
            UP_VAL          => I_ACK_VALID         , -- In  :
            UP_BEN          => i_addr_up_ben       , -- In  :
            UP_SIZE         => I_ACK_SIZE          , -- In  :
            COUNTER         => I_REQ_ADDR            -- Out :
        );                                           -- 
    i_addr_up_ben <= (others => '0') when (I_ADDR_FIX = '1') else (others => '1');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_SIZE_REGS: COUNT_DOWN_REGISTER                 -- 
        generic map (                                -- 
            VALID           => I_REQ_SIZE_VALID    , -- 
            BITS            => I_REQ_SIZE_BITS     , -- 
            REGS_BITS       => I_REG_SIZE_BITS       -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => I_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => I_CLR               , -- In  :
            REGS_WEN        => I_SIZE_L            , -- In  :
            REGS_WDATA      => I_SIZE_D            , -- In  :
            REGS_RDATA      => I_SIZE_Q            , -- Out :
            DN_ENA          => i_tran_running      , -- In  :
            DN_VAL          => I_ACK_VALID         , -- In  :
            DN_SIZE         => I_ACK_SIZE          , -- In  :
            COUNTER         => I_REQ_SIZE          , -- Out :
            ZERO            => open                , -- Out :
            NEG             => open                  -- Out :
       );                                            -- 
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_BUF_PTR: COUNT_UP_REGISTER                     -- 
        generic map (                                -- 
            VALID           => 1                   , -- 
            BITS            => BUF_DEPTH           , --
            REGS_BITS       => BUF_DEPTH             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => I_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => I_CLR               , -- In  :
            REGS_WEN        => i_buf_ptr_init      , -- In  :
            REGS_WDATA      => BUF_INIT_PTR        , -- In  :
            REGS_RDATA      => open                , -- Out :
            UP_ENA          => i_tran_running      , -- In  :
            UP_VAL          => I_ACK_VALID         , -- In  :
            UP_BEN          => BUF_UP_BEN          , -- In  :
            UP_SIZE         => I_ACK_SIZE          , -- In  :
            COUNTER         => I_REQ_BUF_PTR         -- Out :
       );                                            -- 
    i_buf_ptr_init <= (others => '1') when (i_valve_open = '0') else (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_CTRL_REGS: PUMP_CONTROL_REGISTER               -- 
        generic map (                                -- 
            MODE_BITS       => I_REG_MODE_BITS     , -- 
            STAT_BITS       => I_REG_STAT_BITS       -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => I_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => I_CLR               , -- In  :
            RESET_L         => I_RESET_L           , -- In  :
            RESET_D         => I_RESET_D           , -- In  :
            RESET_Q         => i_reset             , -- Out :
            START_L         => I_START_L           , -- In  :
            START_D         => I_START_D           , -- In  :
            START_Q         => I_START_Q           , -- Out :
            STOP_L          => I_STOP_L            , -- In  :
            STOP_D          => I_STOP_D            , -- In  :
            STOP_Q          => i_stop              , -- Out :
            PAUSE_L         => I_PAUSE_L           , -- In  :
            PAUSE_D         => I_PAUSE_D           , -- In  :
            PAUSE_Q         => i_pause             , -- Out :
            FIRST_L         => I_FIRST_L           , -- In  :
            FIRST_D         => I_FIRST_D           , -- In  :
            FIRST_Q         => I_FIRST_Q           , -- Out :
            LAST_L          => I_LAST_L            , -- In  :
            LAST_D          => I_LAST_D            , -- In  :
            LAST_Q          => I_LAST_Q            , -- Out :
            DONE_EN_L       => I_DONE_EN_L         , -- In  :
            DONE_EN_D       => I_DONE_EN_D         , -- In  :
            DONE_EN_Q       => I_DONE_EN_Q         , -- Out :
            DONE_ST_L       => I_DONE_ST_L         , -- In  :
            DONE_ST_D       => I_DONE_ST_D         , -- In  :
            DONE_ST_Q       => I_DONE_ST_Q         , -- Out :
            ERR_ST_L        => I_ERR_ST_L          , -- In  :
            ERR_ST_D        => I_ERR_ST_D          , -- In  :
            ERR_ST_Q        => I_ERR_ST_Q          , -- Out :
            MODE_L          => I_MODE_L            , -- In  :
            MODE_D          => I_MODE_D            , -- In  :
            MODE_Q          => I_MODE_Q            , -- Out :
            STAT_L          => I_STAT_L            , -- In  :
            STAT_D          => I_STAT_D            , -- In  :
            STAT_Q          => I_STAT_Q            , -- Out :
            STAT_I          => I_STAT_I            , -- In  :
            REQ_VALID       => I_REQ_VALID         , -- Out :
            REQ_FIRST       => I_REQ_FIRST         , -- Out :
            REQ_LAST        => I_REQ_LAST          , -- Out :
            REQ_READY       => I_REQ_READY         , -- In  :
            ACK_VALID       => I_ACK_VALID         , -- In  :
            ACK_ERROR       => I_ACK_ERROR         , -- In  :
            ACK_NEXT        => I_ACK_NEXT          , -- In  :
            ACK_LAST        => I_ACK_LAST          , -- In  :
            ACK_STOP        => I_ACK_STOP          , -- In  :
            ACK_NONE        => I_ACK_NONE          , -- In  :
            XFER_BUSY       => I_XFER_BUSY         , -- In  :
            XFER_DONE       => I_XFER_DONE         , -- In  :
            VALVE_OPEN      => i_valve_open        , -- Out :
            TRAN_DONE       => I_DONE              , -- Out :
            TRAN_ERROR      => I_ERROR             , -- Out :
            TRAN_BUSY       => i_tran_running        -- Out :
        );                                           -- 
    I_RESET_Q <= i_reset;
    I_PAUSE_Q <= i_pause;
    I_STOP_Q  <= i_stop;
    I_OPEN    <= i_valve_open;
    I_RUNNING <= i_tran_running;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_VALVE: FLOAT_INTAKE_MANIFOLD_VALVE             -- 
        generic map (                                --
            FIXED_CLOSE     => 0                   , --
            FIXED_FLOW_OPEN => I_FIXED_FLOW_OPEN   , --
            FIXED_POOL_OPEN => I_FIXED_POOL_OPEN   , --
            USE_PULL_RSV    => O_USE_PULL_RSV_SIZE , --
            USE_POOL_PUSH   => I_USE_PUSH_BUF_SIZE , --
            COUNT_BITS      => SIZE_BITS           , -- 
            SIZE_BITS       => SIZE_BITS             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => I_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => I_CLR               , -- In  :
            POOL_SIZE       => BUFFER_SIZE         , -- In  :
            FLOW_READY_LEVEL=> I_FLOW_READY_LEVEL  , -- In  :
            POOL_READY_LEVEL=> I_BUF_READY_LEVEL   , -- In  :
            INTAKE_OPEN     => i_valve_open        , -- In  :
            OUTLET_OPEN     => o2i_valve_open      , -- In  :
            RESET           => i_reset             , -- In  :
            PAUSE           => i_pause             , -- In  :
            STOP            => i_stop              , -- In  :
            PULL_FIN_VALID  => o2i_pull_fin_valid  , -- In  :
            PULL_FIN_LAST   => o2i_pull_fin_last   , -- In  :
            PULL_FIN_SIZE   => o2i_pull_fin_size   , -- In  :
            PULL_RSV_VALID  => o2i_pull_rsv_valid  , -- In  :
            PULL_RSV_LAST   => o2i_pull_rsv_last   , -- In  :
            PULL_RSV_SIZE   => o2i_pull_rsv_size   , -- In  :
            FLOW_PUSH_VALID => I_ACK_VALID         , -- In  :
            FLOW_PUSH_LAST  => I_ACK_LAST          , -- In  :
            FLOW_PUSH_SIZE  => I_ACK_SIZE          , -- In  :
            FLOW_READY      => I_FLOW_READY        , -- Out :
            FLOW_PAUSE      => I_FLOW_PAUSE        , -- Out :
            FLOW_STOP       => I_FLOW_STOP         , -- Out :
            FLOW_LAST       => I_FLOW_LAST         , -- Out :
            FLOW_SIZE       => I_FLOW_SIZE         , -- Out :
            FLOW_COUNT      => open                , -- Out :
            FLOW_ZERO       => open                , -- Out :
            FLOW_POS        => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            POOL_PUSH_RESET => I_PUSH_BUF_RESET    , -- In  :
            POOL_PUSH_VALID => I_PUSH_BUF_VALID    , -- In  :
            POOL_PUSH_LAST  => I_PUSH_BUF_LAST     , -- In  :
            POOL_PUSH_SIZE  => I_PUSH_BUF_SIZE     , -- In  :
            POOL_READY      => I_PUSH_BUF_READY    , -- Out :
            POOL_COUNT      => open                , -- Out :
            PAUSED          => open                  -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O_ADDR_REGS: COUNT_UP_REGISTER                   -- 
        generic map (                                -- 
            VALID           => O_REQ_ADDR_VALID    , -- 
            BITS            => O_REQ_ADDR_BITS     , -- 
            REGS_BITS       => O_REG_ADDR_BITS       -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => O_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => O_CLR               , -- In  :
            REGS_WEN        => O_ADDR_L            , -- In  :
            REGS_WDATA      => O_ADDR_D            , -- In  :
            REGS_RDATA      => O_ADDR_Q            , -- Out :
            UP_ENA          => o_tran_running      , -- In  :
            UP_VAL          => O_ACK_VALID         , -- In  :
            UP_BEN          => o_addr_up_ben       , -- In  :
            UP_SIZE         => O_ACK_SIZE          , -- In  :
            COUNTER         => O_REQ_ADDR            -- Out :
        );                                           -- 
    o_addr_up_ben <= (others => '0') when (O_ADDR_FIX = '1') else (others => '1');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O_SIZE_REGS: COUNT_DOWN_REGISTER                 -- 
        generic map (                                -- 
            VALID           => O_REQ_SIZE_VALID    , --
            BITS            => O_REQ_SIZE_BITS     , --
            REGS_BITS       => O_REG_SIZE_BITS       --
        )                                            -- 
        port map (                                   -- 
            CLK             => O_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => O_CLR               , -- In  :
            REGS_WEN        => O_SIZE_L            , -- In  :
            REGS_WDATA      => O_SIZE_D            , -- In  :
            REGS_RDATA      => O_SIZE_Q            , -- Out :
            DN_ENA          => o_tran_running      , -- In  :
            DN_VAL          => O_ACK_VALID         , -- In  :
            DN_SIZE         => O_ACK_SIZE          , -- In  :
            COUNTER         => O_REQ_SIZE          , -- Out :
            ZERO            => open                , -- Out :
            NEG             => open                  -- Out :
       );                                            -- 
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O_BUF_PTR: COUNT_UP_REGISTER                     -- 
        generic map (                                -- 
            VALID           => 1                   , --
            BITS            => BUF_DEPTH           , --
            REGS_BITS       => BUF_DEPTH             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => O_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => O_CLR               , -- In  :
            REGS_WEN        => o_buf_ptr_init      , -- In  :
            REGS_WDATA      => BUF_INIT_PTR        , -- In  :
            REGS_RDATA      => open                , -- Out :
            UP_ENA          => o_tran_running      , -- In  :
            UP_VAL          => O_ACK_VALID         , -- In  :
            UP_BEN          => BUF_UP_BEN          , -- In  :
            UP_SIZE         => O_ACK_SIZE          , -- In  :
            COUNTER         => O_REQ_BUF_PTR         -- Out :
       );                                            -- 
    o_buf_ptr_init <= (others => '1') when (o_valve_open = '0') else (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O_CTRL_REGS: PUMP_CONTROL_REGISTER               --
        generic map (                                --
            MODE_BITS       => O_REG_MODE_BITS     , --
            STAT_BITS       => O_REG_STAT_BITS       -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => O_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => O_CLR               , -- In  :
            RESET_L         => O_RESET_L           , -- In  :
            RESET_D         => O_RESET_D           , -- In  :
            RESET_Q         => o_reset             , -- Out :
            START_L         => O_START_L           , -- In  :
            START_D         => O_START_D           , -- In  :
            START_Q         => O_START_Q           , -- Out :
            STOP_L          => O_STOP_L            , -- In  :
            STOP_D          => O_STOP_D            , -- In  :
            STOP_Q          => o_stop              , -- Out :
            PAUSE_L         => O_PAUSE_L           , -- In  :
            PAUSE_D         => O_PAUSE_D           , -- In  :
            PAUSE_Q         => o_pause             , -- Out :
            FIRST_L         => O_FIRST_L           , -- In  :
            FIRST_D         => O_FIRST_D           , -- In  :
            FIRST_Q         => O_FIRST_Q           , -- Out :
            LAST_L          => O_LAST_L            , -- In  :
            LAST_D          => O_LAST_D            , -- In  :
            LAST_Q          => O_LAST_Q            , -- Out :
            DONE_EN_L       => O_DONE_EN_L         , -- In  :
            DONE_EN_D       => O_DONE_EN_D         , -- In  :
            DONE_EN_Q       => O_DONE_EN_Q         , -- Out :
            DONE_ST_L       => O_DONE_ST_L         , -- In  :
            DONE_ST_D       => O_DONE_ST_D         , -- In  :
            DONE_ST_Q       => O_DONE_ST_Q         , -- Out :
            ERR_ST_L        => O_ERR_ST_L          , -- In  :
            ERR_ST_D        => O_ERR_ST_D          , -- In  :
            ERR_ST_Q        => O_ERR_ST_Q          , -- Out :
            MODE_L          => O_MODE_L            , -- In  :
            MODE_D          => O_MODE_D            , -- In  :
            MODE_Q          => O_MODE_Q            , -- Out :
            STAT_L          => O_STAT_L            , -- In  :
            STAT_D          => O_STAT_D            , -- In  :
            STAT_Q          => O_STAT_Q            , -- Out :
            STAT_I          => O_STAT_I            , -- In  :
            REQ_VALID       => O_REQ_VALID         , -- Out :
            REQ_FIRST       => O_REQ_FIRST         , -- Out :
            REQ_LAST        => O_REQ_LAST          , -- Out :
            REQ_READY       => O_REQ_READY         , -- In  :
            ACK_VALID       => O_ACK_VALID         , -- In  :
            ACK_ERROR       => O_ACK_ERROR         , -- In  :
            ACK_NEXT        => O_ACK_NEXT          , -- In  :
            ACK_LAST        => O_ACK_LAST          , -- In  :
            ACK_STOP        => O_ACK_STOP          , -- In  :
            ACK_NONE        => O_ACK_NONE          , -- In  :
            XFER_BUSY       => O_XFER_BUSY         , -- In  :
            XFER_DONE       => O_XFER_DONE         , -- In  :
            VALVE_OPEN      => o_valve_open        , -- Out :
            TRAN_DONE       => O_DONE              , -- Out :
            TRAN_ERROR      => O_ERROR             , -- Out :
            TRAN_BUSY       => o_tran_running        -- Out :
        );                                           -- 
    O_RESET_Q <= o_reset;
    O_PAUSE_Q <= o_pause;
    O_STOP_Q  <= o_stop;
    O_OPEN    <= o_valve_open;
    O_RUNNING <= o_tran_running;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O_VALVE: FLOAT_OUTLET_MANIFOLD_VALVE             -- 
        generic map (                                -- 
            FIXED_CLOSE     => 0                   , --
            FIXED_FLOW_OPEN => O_FIXED_FLOW_OPEN   , --
            FIXED_POOL_OPEN => O_FIXED_POOL_OPEN   , --
            USE_PUSH_RSV    => I_USE_PUSH_RSV_SIZE , --
            USE_POOL_PULL   => O_USE_PULL_BUF_SIZE , --
            COUNT_BITS      => SIZE_BITS           , -- 
            SIZE_BITS       => SIZE_BITS             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => O_CLK               , -- In  :
            RST             => RST                 , -- In  :
            CLR             => O_CLR               , -- In  :
            FLOW_READY_LEVEL=> O_FLOW_READY_LEVEL  , -- In  :
            POOL_READY_LEVEL=> O_BUF_READY_LEVEL   , -- In  :
            INTAKE_OPEN     => i2o_valve_open      , -- In  :
            OUTLET_OPEN     => o_valve_open        , -- In  :
            RESET           => o_reset             , -- In  :
            PAUSE           => o_pause             , -- In  :
            STOP            => o_stop              , -- In  :
            PUSH_FIN_VALID  => i2o_push_fin_valid  , -- In  :
            PUSH_FIN_LAST   => i2o_push_fin_last   , -- In  :
            PUSH_FIN_SIZE   => i2o_push_fin_size   , -- In  :
            PUSH_RSV_VALID  => i2o_push_rsv_valid  , -- In  :
            PUSH_RSV_LAST   => i2o_push_rsv_last   , -- In  :
            PUSH_RSV_SIZE   => i2o_push_rsv_size   , -- In  :
            FLOW_PULL_VALID => O_ACK_VALID         , -- In  :
            FLOW_PULL_LAST  => O_ACK_LAST          , -- In  :
            FLOW_PULL_SIZE  => O_ACK_SIZE          , -- In  :
            FLOW_READY      => O_FLOW_READY        , -- Out :
            FLOW_PAUSE      => O_FLOW_PAUSE        , -- Out :
            FLOW_STOP       => O_FLOW_STOP         , -- Out :
            FLOW_LAST       => O_FLOW_LAST         , -- Out :
            FLOW_SIZE       => O_FLOW_SIZE         , -- Out :
            FLOW_COUNT      => open                , -- Out :
            FLOW_ZERO       => open                , -- Out :
            FLOW_POS        => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            POOL_PULL_RESET => O_PULL_BUF_RESET    , -- In  :
            POOL_PULL_VALID => O_PULL_BUF_VALID    , -- In  :
            POOL_PULL_LAST  => O_PULL_BUF_LAST     , -- In  :
            POOL_PULL_SIZE  => O_PULL_BUF_SIZE     , -- In  :
            POOL_READY      => O_PULL_BUF_READY    , -- Out :
            POOL_COUNT      => open                , -- Out :
            PAUSED          => open                  -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I2O_SYNC : PUMP_FLOW_SYNCRONIZER                 --
        generic map (                                --
            I_CLK_RATE     => I_CLK_RATE           , -- 
            O_CLK_RATE     => O_CLK_RATE           , --
            DELAY_CYCLE    => I2O_DELAY_CYCLE      , -- 
            SIZE_BITS      => SIZE_BITS              -- 
        )                                            -- 
        port map (                                   -- 
            RST            => RST                  , -- In  :
            I_CLK          => I_CLK                , -- In  :
            I_CLR          => I_CLR                , -- In  :
            I_CKE          => I_CKE                , -- In  :
            I_OPEN         => i_valve_open         , -- In  :
            I_FIN_VAL      => I_PUSH_FIN_VALID     , -- In  :
            I_FIN_LAST     => I_PUSH_FIN_LAST      , -- In  :
            I_FIN_SIZE     => I_PUSH_FIN_SIZE      , -- In  :
            I_RSV_VAL      => I_PUSH_RSV_VALID     , -- In  :
            I_RSV_LAST     => I_PUSH_RSV_LAST      , -- In  :
            I_RSV_SIZE     => I_PUSH_RSV_SIZE      , -- In  :
            O_CLK          => O_CLK                , -- In  :
            O_CLR          => O_CLR                , -- In  :
            O_CKE          => O_CKE                , -- In  :
            O_OPEN         => i2o_valve_open       , -- Out :
            O_FIN_VAL      => i2o_push_fin_valid   , -- Out :
            O_FIN_LAST     => i2o_push_fin_last    , -- Out :
            O_FIN_SIZE     => i2o_push_fin_size    , -- Out :
            O_RSV_VAL      => i2o_push_rsv_valid   , -- Out :
            O_RSV_LAST     => i2o_push_rsv_last    , -- Out :
            O_RSV_SIZE     => i2o_push_rsv_size      -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O2I_SYNC : PUMP_FLOW_SYNCRONIZER                 -- 
        generic map (                                -- 
            I_CLK_RATE     => O_CLK_RATE           , -- 
            O_CLK_RATE     => I_CLK_RATE           , -- 
            DELAY_CYCLE    => 0                    , -- 
            SIZE_BITS      => SIZE_BITS              -- 
        )                                            -- 
        port map (                                   -- 
            RST            => RST                  , -- In  :
            I_CLK          => O_CLK                , -- In  :
            I_CLR          => O_CLR                , -- In  :
            I_CKE          => O_CKE                , -- In  :
            I_OPEN         => o_valve_open         , -- In  :
            I_FIN_VAL      => O_PULL_FIN_VALID     , -- In  :
            I_FIN_LAST     => O_PULL_FIN_LAST      , -- In  :
            I_FIN_SIZE     => O_PULL_FIN_SIZE      , -- In  :
            I_RSV_VAL      => O_PULL_RSV_VALID     , -- In  :
            I_RSV_LAST     => O_PULL_RSV_LAST      , -- In  :
            I_RSV_SIZE     => O_PULL_RSV_SIZE      , -- In  :
            O_CLK          => I_CLK                , -- In  :
            O_CLR          => I_CLR                , -- In  :
            O_CKE          => I_CKE                , -- In  :
            O_OPEN         => o2i_valve_open       , -- Out :
            O_FIN_VAL      => o2i_pull_fin_valid   , -- Out :
            O_FIN_LAST     => o2i_pull_fin_last    , -- Out :
            O_FIN_SIZE     => o2i_pull_fin_size    , -- Out :
            O_RSV_VAL      => o2i_pull_rsv_valid   , -- Out :
            O_RSV_LAST     => o2i_pull_rsv_last    , -- Out :
            O_RSV_SIZE     => o2i_pull_rsv_size      -- Out :
        );                                           -- 
end RTL;
