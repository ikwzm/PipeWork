-----------------------------------------------------------------------------------
--!     @file    pump_stream_intake_controller.vhd
--!     @brief   PUMP STREAM INTAKE CONTROLLER
--!     @version 1.8.1
--!     @date    2020/10/2
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2020 Ichiro Kawazome
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
--! @brief   PUMP STREAM INTAKE CONTROLLER :
-----------------------------------------------------------------------------------
entity  PUMP_STREAM_INTAKE_CONTROLLER is
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
        O_DATA_BITS         : --! @brief OUTPUT STREAM DATA BITS :
                              --! O_DATA のビット数を指定する.
                              integer := 32;
        O_WORD_BITS         : --! @brief INPUT STREAM WORD BITS :
                              --! O_DATA の１ワードあたりのビット数を指定する.
                              --! * O_DATA_BITS   >=  O_WORD_BITS でなければならない.
                              --! * O_DATA_BITS   mod O_WORD_BITS = 0 でなければならない.
                              --! * BUF_DATA_BITS >=  O_WORD_BITS でなければならない.
                              --! * BUF_DATA_BITS mod O_WORD_BITS = 0 でなければならない.
                              integer := 8;
        BUF_DEPTH           : --! @brief BUFFER DEPTH :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        BUF_DATA_BITS       : --! @brief BUFFER DATA BITS :
                              --! BUF_DATA のビット数を指定する.
                              integer := 32;
        I2O_OPEN_INFO_BITS  : --! @brief I2O_OPEN_INFO BITS :
                              --! I_I2O_OPEN_INFO/O_I2O_OPEN_INFO のビット数を指定する.
                              integer :=  1;
        I2O_CLOSE_INFO_BITS : --! @brief I2O_CLOSE_INFO BITS :
                              --! I_I2O_CLOSE_INFO/O_I2O_CLOSE_INFO のビット数を指定する.
                              integer :=  1;
        O2I_OPEN_INFO_BITS  : --! @brief O2I_OPEN_INFO BITS :
                              --! I_O2I_OPEN_INFO/O_O2I_OPEN_INFO のビット数を指定する.
                              integer :=  1;
        O2I_CLOSE_INFO_BITS : --! @brief O2I_CLOSE_INFO BITS :
                              --! I_O2I_CLOSE_INFO/O_O2I_CLOSE_INFO のビット数を指定する.
                              integer :=  1;
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
        I_CLOSE_ST_L        : in  std_logic := '0';
        I_CLOSE_ST_D        : in  std_logic := '0';
        I_CLOSE_ST_Q        : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Configuration Signals.
    -------------------------------------------------------------------------------
        I_ADDR_FIX          : in  std_logic := '0';
        I_BUF_READY_LEVEL   : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_FLOW_READY_LEVEL  : in  std_logic_vector(BUF_DEPTH         downto 0);
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
    -- Intake Status Signals.
    -------------------------------------------------------------------------------
        I_OPEN              : out std_logic;
        I_TRAN_BUSY         : out std_logic;
        I_TRAN_DONE         : out std_logic;
        I_TRAN_NONE         : out std_logic;
        I_TRAN_ERROR        : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Open/Close Infomation Interface Signals.
    -------------------------------------------------------------------------------
        I_I2O_OPEN_INFO     : in  std_logic_vector(I2O_OPEN_INFO_BITS -1 downto 0) := (others => '0');
        I_I2O_CLOSE_INFO    : in  std_logic_vector(I2O_CLOSE_INFO_BITS-1 downto 0) := (others => '0');
        I_O2I_OPEN_INFO     : out std_logic_vector(O2I_OPEN_INFO_BITS -1 downto 0);
        I_O2I_OPEN_VALID    : out std_logic;
        I_O2I_CLOSE_INFO    : out std_logic_vector(O2I_CLOSE_INFO_BITS-1 downto 0);
        I_O2I_CLOSE_VALID   : out std_logic;
        I_O2I_STOP          : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Clock and Clock Enable.
    -------------------------------------------------------------------------------
        O_CLK               : in  std_logic;
        O_CLR               : in  std_logic;
        O_CKE               : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Outlet Stream Interface.
    -------------------------------------------------------------------------------
        O_DATA              : out std_logic_vector(O_DATA_BITS    -1 downto 0);
        O_STRB              : out std_logic_vector(O_DATA_BITS/8  -1 downto 0);
        O_LAST              : out std_logic;
        O_VALID             : out std_logic;
        O_READY             : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Status.
    -------------------------------------------------------------------------------
        O_OPEN              : out std_logic;
        O_DONE              : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Open/Close Infomation Interface
    -------------------------------------------------------------------------------
        O_I2O_RESET         : out std_logic;
        O_I2O_STOP          : out std_logic;
        O_I2O_NONE          : out std_logic;
        O_I2O_ERROR         : out std_logic;
        O_I2O_OPEN_INFO     : out std_logic_vector(I2O_OPEN_INFO_BITS -1 downto 0);
        O_I2O_OPEN_VALID    : out std_logic;
        O_I2O_CLOSE_INFO    : out std_logic_vector(I2O_CLOSE_INFO_BITS-1 downto 0);
        O_I2O_CLOSE_VALID   : out std_logic;
        O_O2I_STOP          : in  std_logic := '0';
        O_O2I_OPEN_INFO     : in  std_logic_vector(O2I_OPEN_INFO_BITS -1 downto 0) := (others => '0');
        O_O2I_OPEN_VALID    : in  std_logic;
        O_O2I_CLOSE_INFO    : in  std_logic_vector(O2I_CLOSE_INFO_BITS-1 downto 0) := (others => '0');
        O_O2I_CLOSE_VALID   : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Buffer Read Interface.
    -------------------------------------------------------------------------------
        BUF_REN             : out std_logic;
        BUF_PTR             : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        BUF_DATA            : in  std_logic_vector(BUF_DATA_BITS  -1 downto 0)
    );
end PUMP_STREAM_INTAKE_CONTROLLER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.FLOAT_OUTLET_VALVE;
use     PIPEWORK.COMPONENTS.POOL_OUTLET_PORT;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER_INTAKE_SIDE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_FLOW_SYNCRONIZER;
architecture RTL of PUMP_STREAM_INTAKE_CONTROLLER is
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant  SIZE_BITS             :  integer := BUF_DEPTH+1;
    -------------------------------------------------------------------------------
    -- 入力側の各種信号群.
    -------------------------------------------------------------------------------
    signal    i_valve_open          :  std_logic;
    signal    i_open_valid          :  std_logic;
    signal    i_close_valid         :  std_logic;
    signal    i_reset_valid         :  std_logic;
    signal    i_error_valid         :  std_logic;
    signal    i_none_valid          :  std_logic;
    signal    i_stop_valid          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  I_STAT_CLOSE_POS      :  integer := 0;
    constant  I_STAT_REG_LO         :  integer := 1;
    constant  I_STAT_REG_HI         :  integer := I_REG_STAT_BITS;
    constant  I_STAT_BITS           :  integer := I_STAT_REG_HI + 1;
    signal    i_status_load         :  std_logic_vector(I_STAT_BITS-1 downto 0);
    signal    i_status_wbit         :  std_logic_vector(I_STAT_BITS-1 downto 0);
    signal    i_status_regs         :  std_logic_vector(I_STAT_BITS-1 downto 0);
    signal    i_status_in           :  std_logic_vector(I_STAT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側の各種信号群.
    -------------------------------------------------------------------------------
    signal    o_valve_open          :  std_logic;
    signal    o_pull_fin_valid      :  std_logic;
    signal    o_pull_fin_last       :  std_logic;
    signal    o_pull_fin_size       :  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 入力側->出力側の各種信号群.
    -------------------------------------------------------------------------------
    signal    i2o_valve_open        :  std_logic;
    signal    i2o_reset_valid       :  std_logic;
    signal    i2o_error_valid       :  std_logic;
    signal    i2o_none_valid        :  std_logic;
    signal    i2o_stop_valid        :  std_logic;
    signal    i2o_open_info         :  std_logic_vector(I2O_OPEN_INFO_BITS -1 downto 0);
    signal    i2o_open_valid        :  std_logic;
    signal    i2o_close_info        :  std_logic_vector(I2O_CLOSE_INFO_BITS-1 downto 0);
    signal    i2o_close_valid       :  std_logic;
    signal    i2o_push_fin_valid    :  std_logic;
    signal    i2o_push_fin_last     :  std_logic;
    signal    i2o_push_fin_size     :  std_logic_vector(SIZE_BITS-1 downto 0);
    signal    i2o_push_rsv_valid    :  std_logic;
    signal    i2o_push_rsv_last     :  std_logic;
    signal    i2o_push_rsv_size     :  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側->入力側の各種信号群.
    -------------------------------------------------------------------------------
    signal    o2i_valve_open        :  std_logic;
    signal    o2i_stop_valid        :  std_logic;
    signal    o2i_open_info         :  std_logic_vector(O2I_OPEN_INFO_BITS -1 downto 0);
    signal    o2i_open_valid        :  std_logic;
    signal    o2i_close_info        :  std_logic_vector(O2I_CLOSE_INFO_BITS-1 downto 0);
    signal    o2i_close_valid       :  std_logic;
    signal    o2i_pull_fin_valid    :  std_logic;
    signal    o2i_pull_fin_last     :  std_logic;
    signal    o2i_pull_fin_size     :  std_logic_vector(SIZE_BITS-1 downto 0);
    signal    o2i_pull_rsv_valid    :  std_logic;
    signal    o2i_pull_rsv_last     :  std_logic;
    signal    o2i_pull_rsv_size     :  std_logic_vector(SIZE_BITS-1 downto 0);
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
            REG_STAT_BITS       => I_STAT_BITS         , --   
            FIXED_FLOW_OPEN     => I_FIXED_FLOW_OPEN   , --   
            FIXED_POOL_OPEN     => I_FIXED_POOL_OPEN   , --   
            USE_PUSH_BUF_SIZE   => I_USE_PUSH_BUF_SIZE , --   
            USE_PULL_RSV_SIZE   => 0                   , --   
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
            REG_STAT_L          => i_status_load       , -- In  :
            REG_STAT_D          => i_status_wbit       , -- In  :
            REG_STAT_Q          => i_status_regs       , -- Out :
            REG_STAT_I          => i_status_in         , -- In  :
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
            O_STOP              => o2i_stop_valid      , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Status Output.
        ---------------------------------------------------------------------------
            I_OPEN              => i_valve_open        , -- Out :
        ---------------------------------------------------------------------------
        -- Transaction Status Signals.
        ---------------------------------------------------------------------------
            TRAN_BUSY           => I_TRAN_BUSY         , -- Out :
            TRAN_DONE           => I_TRAN_DONE         , -- Out :
            TRAN_NONE           => i_none_valid        , -- Out :
            TRAN_ERROR          => i_error_valid         -- Out :
        );
    I_OPEN       <= i_valve_open;
    I_TRAN_NONE  <= i_none_valid;
    I_TRAN_ERROR <= i_error_valid;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_status_load(I_STAT_CLOSE_POS)                   <= I_CLOSE_ST_L;
    i_status_wbit(I_STAT_CLOSE_POS)                   <= I_CLOSE_ST_D;
    i_status_in  (I_STAT_CLOSE_POS)                   <= o2i_close_valid;
    I_CLOSE_ST_Q <= i_status_regs(I_STAT_CLOSE_POS);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_status_load(I_STAT_REG_HI downto I_STAT_REG_LO) <= I_STAT_L;
    i_status_wbit(I_STAT_REG_HI downto I_STAT_REG_LO) <= I_STAT_D;
    i_status_in  (I_STAT_REG_HI downto I_STAT_REG_LO) <= I_STAT_I;
    I_STAT_Q     <= i_status_regs(I_STAT_REG_HI downto I_STAT_REG_LO);
    -------------------------------------------------------------------------------
    -- 入力側から出力側への各種情報転送
    -------------------------------------------------------------------------------
    I2O: block
        signal    i_valve_opened    :  std_logic;
        constant  null_valid        :  std_logic := '0';
        constant  null_last         :  std_logic := '0';
        constant  null_size         :  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (I_CLK, RST) begin
            if (RST = '1') then
                    i_reset_valid <= '0';
                    i_stop_valid  <= '0';
            elsif (I_CLK'event and I_CLK = '1') then
                if (I_CLR = '1') then
                    i_reset_valid <= '0';
                elsif (I_RESET_L = '1' and I_RESET_D = '1') then
                    i_reset_valid <= '1';
                else
                    i_reset_valid <= '0';
                end if;
                if (I_CLR = '1') then
                    i_stop_valid  <= '0';
                elsif (I_STOP_L  = '1' and I_STOP_D  = '1') then
                    i_stop_valid  <= '1';
                else
                    i_stop_valid  <= '0';
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- 入力側のバルブの開閉情報
        ---------------------------------------------------------------------------
        process (I_CLK, RST) begin
            if (RST = '1') then
                    i_valve_opened <= '0';
            elsif (I_CLK'event and I_CLK = '1') then
                if (I_CLR = '1') then
                    i_valve_opened <= '0';
                else
                    i_valve_opened <= i_valve_open;
                end if;
            end if;
        end process;
        i_open_valid  <= '1' when (i_valve_open = '1' and i_valve_opened = '0') else '0';
        i_close_valid <= '1' when (i_valve_open = '0' and i_valve_opened = '1') else '0';
        ---------------------------------------------------------------------------
        -- クロック同期回路
        ---------------------------------------------------------------------------
        SYNC: PUMP_FLOW_SYNCRONIZER                      -- 
            generic map (                                --
                I_CLK_RATE      => I_CLK_RATE          , -- 
                O_CLK_RATE      => O_CLK_RATE          , --
                OPEN_INFO_BITS  => I2O_OPEN_INFO_BITS  , --
                CLOSE_INFO_BITS => I2O_CLOSE_INFO_BITS , --
                EVENT_SIZE      => 4                   , --
                XFER_SIZE_BITS  => SIZE_BITS           , --
                PUSH_FIN_DELAY  => I2O_DELAY_CYCLE     , --
                PUSH_FIN_VALID  => 1                   , --
                PUSH_RSV_VALID  => 0                   , --
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
                I_OPEN_INFO     => I_I2O_OPEN_INFO     , -- In  :
                I_CLOSE_VAL     => i_close_valid       , -- In  :
                I_CLOSE_INFO    => I_I2O_CLOSE_INFO    , -- In  :
                I_EVENT(0)      => i_stop_valid        , -- In  :
                I_EVENT(1)      => i_reset_valid       , -- In  :
                I_EVENT(2)      => i_error_valid       , -- In  :
                I_EVENT(3)      => i_none_valid        , -- In  :
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
                O_OPEN_VAL      => i2o_open_valid      , -- Out :
                O_OPEN_INFO     => i2o_open_info       , -- Out :
                O_CLOSE_VAL     => i2o_close_valid     , -- Out :
                O_CLOSE_INFO    => i2o_close_info      , -- Out :
                O_EVENT(0)      => i2o_stop_valid      , -- Out :
                O_EVENT(1)      => i2o_reset_valid     , -- Out :
                O_EVENT(2)      => i2o_error_valid     , -- Out :
                O_EVENT(3)      => i2o_none_valid      , -- Out :
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
    end block;        
    -------------------------------------------------------------------------------
    -- 出力側から入力側への各種情報転送
    -------------------------------------------------------------------------------
    O2I: block
        signal    o2i_valve_opened  :  std_logic;
        constant  null_valid        :  std_logic := '0';
        constant  null_last         :  std_logic := '0';
        constant  null_size         :  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        -- クロック同期回路
        ---------------------------------------------------------------------------
        SYNC: PUMP_FLOW_SYNCRONIZER                      -- 
            generic map (                                --
                I_CLK_RATE      => O_CLK_RATE          , -- 
                O_CLK_RATE      => I_CLK_RATE          , --
                OPEN_INFO_BITS  => O2I_OPEN_INFO_BITS  , --
                CLOSE_INFO_BITS => O2I_CLOSE_INFO_BITS , --
                EVENT_SIZE      => 1                   , --
                XFER_SIZE_BITS  => SIZE_BITS           , --
                PUSH_FIN_DELAY  => 0                   , --
                PUSH_FIN_VALID  => 0                   , --
                PUSH_RSV_VALID  => 0                   , --
                PULL_FIN_VALID  => 1                   , --
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
                I_CLK           => O_CLK               , -- In  :
                I_CLR           => O_CLR               , -- In  :
                I_CKE           => O_CKE               , -- In  :
                I_OPEN_VAL      => O_O2I_OPEN_VALID    , -- In  :
                I_OPEN_INFO     => O_O2I_OPEN_INFO     , -- In  :
                I_CLOSE_VAL     => O_O2I_CLOSE_VALID   , -- In  :
                I_CLOSE_INFO    => O_O2I_CLOSE_INFO    , -- In  :
                I_EVENT(0)      => O_O2I_STOP          , -- In  :
                I_PUSH_FIN_VAL  => null_valid          , -- In  :
                I_PUSH_FIN_LAST => null_last           , -- In  :
                I_PUSH_FIN_SIZE => null_size           , -- In  :
                I_PUSH_RSV_VAL  => null_valid          , -- In  :
                I_PUSH_RSV_LAST => null_last           , -- In  :
                I_PUSH_RSV_SIZE => null_size           , -- In  :
                I_PULL_FIN_VAL  => o_pull_fin_valid    , -- In  :
                I_PULL_FIN_LAST => o_pull_fin_last     , -- In  :
                I_PULL_FIN_SIZE => o_pull_fin_size     , -- In  :
                I_PULL_RSV_VAL  => null_valid          , -- In  :
                I_PULL_RSV_LAST => null_last           , -- In  :
                I_PULL_RSV_SIZE => null_size           , -- In  :
            ---------------------------------------------------------------------------
            -- Output 
            ---------------------------------------------------------------------------
                O_CLK           => I_CLK               , -- In  :
                O_CLR           => I_CLR               , -- In  :
                O_CKE           => I_CKE               , -- In  :
                O_OPEN_VAL      => o2i_open_valid      , -- Out :
                O_OPEN_INFO     => o2i_open_info       , -- Out :
                O_CLOSE_VAL     => o2i_close_valid     , -- Out :
                O_CLOSE_INFO    => o2i_close_info      , -- Out :
                O_EVENT(0)      => o2i_stop_valid      , -- Out :
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
                    o2i_valve_opened <= '0';
            elsif (I_CLK'event and I_CLK = '1') then
                if (I_CLR = '1' or o2i_close_valid = '1') then
                    o2i_valve_opened <= '0';
                elsif (o2i_open_valid  = '1') then
                    o2i_valve_opened <= '1';
                end if;
            end if;
        end process;
        o2i_valve_open <= '1' when (o2i_valve_opened = '1' and o2i_close_valid = '0') or
                                   (o2i_open_valid   = '1') else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        I_O2I_OPEN_INFO   <= o2i_open_info;
        I_O2I_OPEN_VALID  <= o2i_open_valid;
        I_O2I_CLOSE_INFO  <= o2i_close_info;
        I_O2I_CLOSE_VALID <= o2i_close_valid;
        I_O2I_STOP        <= o2i_stop_valid;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_SIDE: block
        constant  null_buf_ptr      :  std_logic_vector(BUF_DEPTH      -1 downto 0) := (others => '0');
        constant  null_size         :  std_logic_vector(SIZE_BITS      -1 downto 0) := (others => '0');
        constant  BUF_DATA_BYTES    :  std_logic_vector(SIZE_BITS      -1 downto 0) := std_logic_vector(to_unsigned(BUF_DATA_BITS/8, SIZE_BITS));
        signal    pool_valid        :  std_logic;
        signal    pool_ready        :  std_logic;
        signal    pool_last         :  std_logic;
        signal    pool_dval         :  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
        signal    pool_size         :  std_logic_vector(SIZE_BITS      -1 downto 0);
        constant  pool_error        :  std_logic := '0';
        signal    pool_done         :  std_logic;
        signal    pool_busy         :  std_logic;
        signal    flow_count        :  std_logic_vector(SIZE_BITS      -1 downto 0);
        signal    flow_last         :  std_logic;
        signal    flow_ready        :  std_logic;
        signal    port_reset        :  std_logic;
        signal    port_busy         :  std_logic;
        signal    o_valve_opened    :  std_logic;
        signal    i2o_valve_opened  :  std_logic;
        signal    i2o_close_busy    :  std_logic;
    begin
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (O_CLK, RST) begin
            if (RST = '1') then
                    i2o_valve_opened <= '0';
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1' or i2o_close_valid = '1' or i2o_reset_valid = '1') then
                    i2o_valve_opened <= '0';
                elsif (i2o_open_valid  = '1') then
                    i2o_valve_opened <= '1';
                end if;
            end if;
        end process;
        i2o_valve_open <= '1' when (i2o_valve_opened = '1' and i2o_close_valid = '0') or
                                   (i2o_open_valid   = '1') else '0';
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        O_I2O_OPEN_INFO   <= i2o_open_info;
        O_I2O_OPEN_VALID  <= i2o_open_valid;
        O_I2O_STOP        <= i2o_stop_valid;
        O_I2O_RESET       <= i2o_reset_valid;
        O_I2O_NONE        <= i2o_none_valid;
        O_I2O_ERROR       <= i2o_error_valid;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (O_CLK, RST) begin
            if (RST = '1') then
                    i2o_close_busy   <= '0';
                    O_I2O_CLOSE_INFO <= (others => '0');
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1' or i2o_reset_valid = '1') then
                    i2o_close_busy   <= '0';
                    O_I2O_CLOSE_INFO <= (others => '0');
                elsif (i2o_close_busy = '0') then
                    if (i2o_close_valid = '1') then
                        i2o_close_busy   <= '1';
                        O_I2O_CLOSE_INFO <= i2o_close_info;
                    else
                        i2o_close_busy   <= '0';
                    end if;
                else
                    if (port_busy = '0') then
                        i2o_close_busy   <= '0';
                    else
                        i2o_close_busy   <= '1';
                    end if;
                end if;
            end if;
        end process;
        O_I2O_CLOSE_VALID <= '1' when (i2o_close_busy = '1' and port_busy = '0') else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        VALVE: FLOAT_OUTLET_VALVE                        -- 
            generic map (                                -- 
                COUNT_BITS      => SIZE_BITS           , --
                SIZE_BITS       => SIZE_BITS             --
            )                                            -- 
            port map (                                   -- 
            -----------------------------------------------------------------------
            -- Clock & Reset Signals.
            -----------------------------------------------------------------------
                CLK             => O_CLK               , -- In  :
                RST             => RST                 , -- In  :
                CLR             => O_CLR               , -- In  :
            ------------------------------------------------------------------------
            -- Control Signals.
            ------------------------------------------------------------------------
                RESET           => i2o_reset_valid     , -- In  :
                PAUSE           => '0'                 , -- In  :
                STOP            => '0'                 , -- In  :
                INTAKE_OPEN     => i2o_valve_open      , -- In  :
                OUTLET_OPEN     => o_valve_open        , -- In  :
                FLOW_READY_LEVEL=> BUF_DATA_BYTES      , -- In  :
            ------------------------------------------------------------------------
            -- Flow Counter Load Signals.
            ------------------------------------------------------------------------
                LOAD            => i2o_open_valid      , -- In  :
                LOAD_COUNT      => null_size           , -- In  :
            ------------------------------------------------------------------------
            -- Push Size Signals.
            ------------------------------------------------------------------------
                PUSH_VALID      => i2o_push_fin_valid  , -- In  :
                PUSH_LAST       => i2o_push_fin_last   , -- In  :
                PUSH_SIZE       => i2o_push_fin_size   , -- In  :
            ------------------------------------------------------------------------
            -- Pull Size Signals.
            ------------------------------------------------------------------------
                PULL_VALID      => o_pull_fin_valid    , -- In  :
                PULL_LAST       => o_pull_fin_last     , -- In  :
                PULL_SIZE       => o_pull_fin_size     , -- In  :
            ------------------------------------------------------------------------
            -- Outlet Flow Control Signals.
            ------------------------------------------------------------------------
                FLOW_READY      => flow_ready          , -- Out :
                FLOW_PAUSE      => open                , -- Out :
                FLOW_STOP       => open                , -- Out :
                FLOW_LAST       => flow_last           , -- Out :
                FLOW_SIZE       => open                , -- Out :
            -------------------------------------------------------------------------
            -- Flow Counter Signals.
            -------------------------------------------------------------------------
                FLOW_COUNT      => flow_count          , -- Out :
                FLOW_ZERO       => open                , -- Out :
                FLOW_POS        => open                , -- Out :
                FLOW_NEG        => open                , -- Out :
                PAUSED          => open                  -- Out :
            );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        O_PORT: POOL_OUTLET_PORT                         -- 
            generic map (                                -- 
                UNIT_BITS       => 8                   , -- 
                WORD_BITS       => O_WORD_BITS         , --   
                PORT_DATA_BITS  => O_DATA_BITS         , --   
                POOL_DATA_BITS  => BUF_DATA_BITS       , --   
                PORT_PTR_BITS   => BUF_DEPTH           , --   
                POOL_PTR_BITS   => BUF_DEPTH           , --   
                SEL_BITS        => 1                   , --   
                SIZE_BITS       => SIZE_BITS           , --   
                POOL_SIZE_VALID => 0                   , --   
                QUEUE_SIZE      => 0                   , --
                POOL_JUSTIFIED  => 1                     -- 
            )                                            -- 
            port map (                                   -- 
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => O_CLK               , -- In  :
                RST             => RST                 , -- In  :
                CLR             => port_reset          , -- In  :
            -----------------------------------------------------------------------
            -- Control Signals.
            -----------------------------------------------------------------------
                START           => i2o_open_valid      , -- In  :
                START_POOL_PTR  => null_buf_ptr        , -- In  :
                START_PORT_PTR  => null_buf_ptr        , -- In  :
                XFER_LAST       => '0'                 , -- In  :
                XFER_SEL        => "1"                 , -- In  :
            -----------------------------------------------------------------------
            -- Outlet Port Signals.
            -----------------------------------------------------------------------
                PORT_DATA       => O_DATA              , -- Out :
                PORT_DVAL       => O_STRB              , -- Out :
                PORT_LAST       => O_LAST              , -- Out :
                PORT_ERROR      => open                , -- Out :
                PORT_SIZE       => open                , -- Out :
                PORT_VAL        => O_VALID             , -- Out :
                PORT_RDY        => O_READY             , -- In  :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VAL(0)     => o_pull_fin_valid    , -- Out :
                PULL_LAST       => o_pull_fin_last     , -- Out :
                PULL_XFER_LAST  => open                , -- Out :
                PULL_XFER_DONE  => open                , -- Out :
                PULL_ERROR      => open                , -- Out :
                PULL_SIZE       => o_pull_fin_size     , -- Out :
            -----------------------------------------------------------------------
            -- Pool Buffer Interface Signals.
            -----------------------------------------------------------------------
                POOL_REN(0)     => BUF_REN             , -- Out :
                POOL_PTR        => BUF_PTR             , -- Out :
                POOL_DATA       => BUF_DATA            , -- In  :
                POOL_DVAL       => pool_dval           , -- In  :
                POOL_SIZE       => pool_size           , -- In  :
                POOL_ERROR      => pool_error          , -- In  :
                POOL_LAST       => pool_last           , -- In  :
                POOL_VAL        => pool_valid          , -- In  :
                POOL_RDY        => pool_ready          , -- Out :
            -----------------------------------------------------------------------
            -- Status Signals.
            -----------------------------------------------------------------------
                POOL_BUSY       => pool_busy           , -- Out :
                POOL_DONE       => pool_done           , -- Out :
                BUSY            => port_busy             -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (flow_count)
        begin
            if (to_01(unsigned(flow_count)) >= BUF_DATA_BITS/8) then
                pool_size <= std_logic_vector(to_unsigned(BUF_DATA_BITS/8, SIZE_BITS));
            else
                pool_size <= flow_count;
            end if;
            for i in pool_dval'range loop
                if (i = 0) or (to_01(unsigned(flow_count)) > i) then
                    pool_dval(i) <= '1';
                else
                    pool_dval(i) <= '0';
                end if;
            end loop;
        end process;
        port_reset <= '1' when (O_CLR = '1' or i2o_reset_valid = '1' or i2o_stop_valid = '1' or i2o_error_valid = '1' or i2o_none_valid = '1' or O_O2I_STOP = '1') else '0';
        pool_last  <= flow_last;
        pool_valid <= '1' when (flow_ready = '1' and pool_ready = '1') else '0';
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (O_CLK, RST) begin
            if (RST = '1') then
                    o_valve_opened <= '0';
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1' or i2o_reset_valid = '1') then
                    o_valve_opened <= '0';
                elsif (O_O2I_CLOSE_VALID = '1') then
                    o_valve_opened <= '0';
                elsif (O_O2I_OPEN_VALID  = '1') then
                    o_valve_opened <= '1';
                end if;
            end if;
        end process;
        o_valve_open <= '1' when (O_O2I_OPEN_VALID = '1' or o_valve_opened = '1') else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        O_OPEN <= o_valve_open;
        O_DONE <= O_O2I_CLOSE_VALID;
    end block;
end RTL;
