-----------------------------------------------------------------------------------
--!     @file    pump_controller.vhd
--!     @brief   PUMP CONTROLLER
--!     @version 1.0.4
--!     @date    2013/1/19
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
end PUMP_CONTROLLER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_COUNT_UP_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_COUNT_DOWN_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROL_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_INTAKE_VALVE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_OUTLET_VALVE;
architecture RTL of PUMP_CONTROLLER is
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_BITS          : integer := BUF_DEPTH+1;
    ------------------------------------------------------------------------------
    -- バッファのバイト数.
    ------------------------------------------------------------------------------
    constant BUFFER_SIZE        : std_logic_vector(SIZE_BITS-1 downto 0) := 
                                  std_logic_vector(to_unsigned(2**BUF_DEPTH, SIZE_BITS));
    ------------------------------------------------------------------------------
    -- 入力側の閾値. フローカウンタがこの値以下の時に入力する.
    ------------------------------------------------------------------------------
    constant I_THRESHOLD_SIZE   : std_logic_vector(SIZE_BITS-1 downto 0) :=
                                  std_logic_vector(to_unsigned(I_THRESHOLD , SIZE_BITS));
    ------------------------------------------------------------------------------
    -- 出力側の閾値. フローカウンタがこの値以下の時に出力する.
    ------------------------------------------------------------------------------
    constant O_THRESHOLD_SIZE   : std_logic_vector(SIZE_BITS-1 downto 0) :=
                                  std_logic_vector(to_unsigned(O_THRESHOLD , SIZE_BITS));
    ------------------------------------------------------------------------------
    -- バッファへのアクセス用信号群.
    ------------------------------------------------------------------------------
    constant BUF_INIT_PTR       : std_logic_vector(BUF_DEPTH      -1 downto 0) := (others => '0');
    constant BUF_UP_BEN         : std_logic_vector(BUF_DEPTH      -1 downto 0) := (others => '1');
    ------------------------------------------------------------------------------
    -- 入力側の各種信号群.
    ------------------------------------------------------------------------------
    signal   i_addr_up_ben      : std_logic_vector(I_REQ_ADDR_BITS-1 downto 0);
    signal   i_buf_ptr_init     : std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal   i_reset            : std_logic;
    signal   i_pause            : std_logic;
    signal   i_stop             : std_logic;
    signal   i_valve_open       : std_logic;
    signal   i_xfer_running     : std_logic;
    ------------------------------------------------------------------------------
    -- 出力側の各種信号群.
    ------------------------------------------------------------------------------
    signal   o_addr_up_ben      : std_logic_vector(O_REQ_ADDR_BITS-1 downto 0);
    signal   o_buf_ptr_init     : std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal   o_reset            : std_logic;
    signal   o_pause            : std_logic;
    signal   o_stop             : std_logic;
    signal   o_valve_open       : std_logic;
    signal   o_xfer_running     : std_logic;
begin
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_ADDR_REGS: PUMP_COUNT_UP_REGISTER
        generic map (
            VALID           => I_REQ_ADDR_VALID,
            BITS            => I_REQ_ADDR_BITS ,
            REGS_BITS       => I_REG_ADDR_BITS
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => I_ADDR_L        ,
            REGS_WDATA      => I_ADDR_D        ,
            REGS_RDATA      => I_ADDR_Q        ,
            UP_ENA          => i_xfer_running  ,
            UP_VAL          => I_ACK_VALID     ,
            UP_BEN          => i_addr_up_ben   ,
            UP_SIZE         => I_ACK_SIZE      ,
            COUNTER         => I_REQ_ADDR
        );
    i_addr_up_ben <= (others => '1');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_SIZE_REGS: PUMP_COUNT_DOWN_REGISTER
        generic map (
            VALID           => I_REQ_SIZE_VALID,
            BITS            => I_REQ_SIZE_BITS ,
            REGS_BITS       => I_REG_SIZE_BITS
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => I_SIZE_L        ,
            REGS_WDATA      => I_SIZE_D        ,
            REGS_RDATA      => I_SIZE_Q        ,
            DN_ENA          => i_xfer_running  ,
            DN_VAL          => I_ACK_VALID     ,
            DN_SIZE         => I_ACK_SIZE      ,
            COUNTER         => I_REQ_SIZE      ,
            ZERO            => open            ,
            NEG             => open
       );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_BUF_PTR: PUMP_COUNT_UP_REGISTER
        generic map (
            VALID           => 1               ,
            BITS            => BUF_DEPTH       ,
            REGS_BITS       => BUF_DEPTH
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => i_buf_ptr_init  ,
            REGS_WDATA      => BUF_INIT_PTR    ,
            REGS_RDATA      => open            ,
            UP_ENA          => i_xfer_running  ,
            UP_VAL          => I_ACK_VALID     ,
            UP_BEN          => BUF_UP_BEN      ,
            UP_SIZE         => I_ACK_SIZE      ,
            COUNTER         => I_REQ_BUF_PTR
       );
    i_buf_ptr_init <= (others => '1') when (i_valve_open = '0') else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_CTRL_REGS: PUMP_CONTROL_REGISTER
        generic map (
            MODE_BITS       => I_REG_MODE_BITS ,
            STAT_BITS       => I_REG_STAT_BITS 
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            RESET_L         => I_RESET_L       ,
            RESET_D         => I_RESET_D       ,
            RESET_Q         => i_reset         ,
            START_L         => I_START_L       ,
            START_D         => I_START_D       ,
            START_Q         => I_START_Q       ,
            STOP_L          => I_STOP_L        ,
            STOP_D          => I_STOP_D        ,
            STOP_Q          => i_stop          ,
            PAUSE_L         => I_PAUSE_L       ,
            PAUSE_D         => I_PAUSE_D       ,
            PAUSE_Q         => i_pause         ,
            FIRST_L         => I_FIRST_L       ,
            FIRST_D         => I_FIRST_D       ,
            FIRST_Q         => I_FIRST_Q       ,
            LAST_L          => I_LAST_L        ,
            LAST_D          => I_LAST_D        ,
            LAST_Q          => I_LAST_Q        ,
            DONE_EN_L       => I_DONE_EN_L     ,
            DONE_EN_D       => I_DONE_EN_D     ,
            DONE_EN_Q       => I_DONE_EN_Q     ,
            DONE_ST_L       => I_DONE_ST_L     ,
            DONE_ST_D       => I_DONE_ST_D     ,
            DONE_ST_Q       => I_DONE_ST_Q     ,
            ERR_ST_L        => I_ERR_ST_L      ,
            ERR_ST_D        => I_ERR_ST_D      ,
            ERR_ST_Q        => I_ERR_ST_Q      ,
            MODE_L          => I_MODE_L        ,
            MODE_D          => I_MODE_D        ,
            MODE_Q          => I_MODE_Q        ,
            STAT_L          => I_STAT_L        ,
            STAT_D          => I_STAT_D        ,
            STAT_Q          => I_STAT_Q        ,
            STAT_I          => I_STAT_I        ,
            REQ_VALID       => I_REQ_VALID     ,
            REQ_FIRST       => I_REQ_FIRST     ,
            REQ_LAST        => I_REQ_LAST      ,
            REQ_READY       => I_REQ_READY     ,
            ACK_VALID       => I_ACK_VALID     ,
            ACK_ERROR       => I_ACK_ERROR     ,
            ACK_NEXT        => I_ACK_NEXT      ,
            ACK_LAST        => I_ACK_LAST      ,
            ACK_STOP        => I_ACK_STOP      ,
            ACK_NONE        => I_ACK_NONE      ,
            VALVE_OPEN      => i_valve_open    ,
            XFER_DONE       => I_DONE          ,
            XFER_RUNNING    => i_xfer_running    
        );
    I_RESET_Q <= i_reset;
    I_PAUSE_Q <= i_pause;
    I_STOP_Q  <= i_stop;
    I_OPEN    <= i_valve_open;
    I_RUNNING <= i_xfer_running;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_VALVE: PUMP_INTAKE_VALVE 
        generic map (
            COUNT_BITS      => SIZE_BITS       ,
            SIZE_BITS       => SIZE_BITS       
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            BUFFER_SIZE     => BUFFER_SIZE     ,
            THRESHOLD_SIZE  => I_THRESHOLD_SIZE,
            I_OPEN          => i_valve_open    ,
            O_OPEN          => o_valve_open    ,
            RESET           => i_reset         ,
            PAUSE           => i_pause         ,
            STOP            => i_stop          ,
            PUSH_VAL        => I_ACK_VALID     ,
            PUSH_LAST       => I_ACK_LAST      ,
            PUSH_SIZE       => I_ACK_SIZE      ,
            PULL_VAL        => O_PULL_VALID    ,
            PULL_LAST       => O_PULL_LAST     ,
            PULL_SIZE       => O_PULL_SIZE     ,
            FLOW_PAUSE      => I_FLOW_PAUSE    ,
            FLOW_STOP       => I_FLOW_STOP     ,
            FLOW_LAST       => I_FLOW_LAST     ,
            FLOW_SIZE       => I_FLOW_SIZE     ,
            FLOW_COUNT      => open            ,
            FLOW_NEG        => open            ,
            PAUSED          => open            
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_ADDR_REGS: PUMP_COUNT_UP_REGISTER
        generic map (
            VALID           => O_REQ_ADDR_VALID,
            BITS            => O_REQ_ADDR_BITS ,
            REGS_BITS       => O_REG_ADDR_BITS
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => O_ADDR_L        ,
            REGS_WDATA      => O_ADDR_D        ,
            REGS_RDATA      => O_ADDR_Q        ,
            UP_ENA          => o_xfer_running  ,
            UP_VAL          => O_ACK_VALID     ,
            UP_BEN          => o_addr_up_ben   ,
            UP_SIZE         => O_ACK_SIZE      ,
            COUNTER         => O_REQ_ADDR
        );
    o_addr_up_ben <= (others => '1');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_SIZE_REGS: PUMP_COUNT_DOWN_REGISTER
        generic map (
            VALID           => O_REQ_SIZE_VALID,
            BITS            => O_REQ_SIZE_BITS ,
            REGS_BITS       => O_REG_SIZE_BITS
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => O_SIZE_L        ,
            REGS_WDATA      => O_SIZE_D        ,
            REGS_RDATA      => O_SIZE_Q        ,
            DN_ENA          => o_xfer_running  ,
            DN_VAL          => O_ACK_VALID     ,
            DN_SIZE         => O_ACK_SIZE      ,
            COUNTER         => O_REQ_SIZE      ,
            ZERO            => open            ,
            NEG             => open
       );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_BUF_PTR: PUMP_COUNT_UP_REGISTER
        generic map (
            VALID           => 1               ,
            BITS            => BUF_DEPTH       ,
            REGS_BITS       => BUF_DEPTH
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => o_buf_ptr_init  ,
            REGS_WDATA      => BUF_INIT_PTR    ,
            REGS_RDATA      => open            ,
            UP_ENA          => o_xfer_running  ,
            UP_VAL          => O_ACK_VALID     ,
            UP_BEN          => BUF_UP_BEN      ,
            UP_SIZE         => O_ACK_SIZE      ,
            COUNTER         => O_REQ_BUF_PTR
       );
    o_buf_ptr_init <= (others => '1') when (o_valve_open = '0') else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_CTRL_REGS: PUMP_CONTROL_REGISTER
        generic map (
            MODE_BITS       => O_REG_MODE_BITS ,
            STAT_BITS       => O_REG_STAT_BITS 
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            RESET_L         => O_RESET_L       ,
            RESET_D         => O_RESET_D       ,
            RESET_Q         => o_reset         ,
            START_L         => O_START_L       ,
            START_D         => O_START_D       ,
            START_Q         => O_START_Q       ,
            STOP_L          => O_STOP_L        ,
            STOP_D          => O_STOP_D        ,
            STOP_Q          => o_stop          ,
            PAUSE_L         => O_PAUSE_L       ,
            PAUSE_D         => O_PAUSE_D       ,
            PAUSE_Q         => o_pause         ,
            FIRST_L         => O_FIRST_L       ,
            FIRST_D         => O_FIRST_D       ,
            FIRST_Q         => O_FIRST_Q       ,
            LAST_L          => O_LAST_L        ,
            LAST_D          => O_LAST_D        ,
            LAST_Q          => O_LAST_Q        ,
            DONE_EN_L       => O_DONE_EN_L     ,
            DONE_EN_D       => O_DONE_EN_D     ,
            DONE_EN_Q       => O_DONE_EN_Q     ,
            DONE_ST_L       => O_DONE_ST_L     ,
            DONE_ST_D       => O_DONE_ST_D     ,
            DONE_ST_Q       => O_DONE_ST_Q     ,
            ERR_ST_L        => O_ERR_ST_L      ,
            ERR_ST_D        => O_ERR_ST_D      ,
            ERR_ST_Q        => O_ERR_ST_Q      ,
            MODE_L          => O_MODE_L        ,
            MODE_D          => O_MODE_D        ,
            MODE_Q          => O_MODE_Q        ,
            STAT_L          => O_STAT_L        ,
            STAT_D          => O_STAT_D        ,
            STAT_Q          => O_STAT_Q        ,
            STAT_I          => O_STAT_I        ,
            REQ_VALID       => O_REQ_VALID     ,
            REQ_FIRST       => O_REQ_FIRST     ,
            REQ_LAST        => O_REQ_LAST      ,
            REQ_READY       => O_REQ_READY     ,
            ACK_VALID       => O_ACK_VALID     ,
            ACK_ERROR       => O_ACK_ERROR     ,
            ACK_NEXT        => O_ACK_NEXT      ,
            ACK_LAST        => O_ACK_LAST      ,
            ACK_STOP        => O_ACK_STOP      ,
            ACK_NONE        => O_ACK_NONE      ,
            VALVE_OPEN      => o_valve_open    ,
            XFER_DONE       => O_DONE          ,
            XFER_RUNNING    => o_xfer_running    
        );
    O_RESET_Q <= o_reset;
    O_PAUSE_Q <= o_pause;
    O_STOP_Q  <= o_stop;
    O_OPEN    <= o_valve_open;
    O_RUNNING <= o_xfer_running;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_VALVE: PUMP_OUTLET_VALVE 
        generic map (
            COUNT_BITS      => SIZE_BITS       ,
            SIZE_BITS       => SIZE_BITS       
        )
        port map (
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
            THRESHOLD_SIZE  => O_THRESHOLD_SIZE,
            I_OPEN          => i_valve_open    ,
            O_OPEN          => o_valve_open    ,
            RESET           => o_reset         ,
            PAUSE           => o_pause         ,
            STOP            => o_stop          ,
            PUSH_VAL        => I_PUSH_VALID    ,
            PUSH_LAST       => I_PUSH_LAST     ,
            PUSH_SIZE       => I_PUSH_SIZE     ,
            PULL_VAL        => O_ACK_VALID     ,
            PULL_LAST       => O_ACK_LAST      ,
            PULL_SIZE       => O_ACK_SIZE      ,
            FLOW_PAUSE      => O_FLOW_PAUSE    ,
            FLOW_STOP       => O_FLOW_STOP     ,
            FLOW_LAST       => O_FLOW_LAST     ,
            FLOW_SIZE       => O_FLOW_SIZE     ,
            FLOW_COUNT      => open            ,
            FLOW_NEG        => open            ,
            PAUSED          => open            
        );
end RTL;
