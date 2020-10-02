-----------------------------------------------------------------------------------
--!     @file    pump_stream_outlet_controller.vhd
--!     @brief   PUMP STREAM OUTLET CONTROLLER
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
--! @brief   PUMP STREAM OUTLET CONTROLLER :
-----------------------------------------------------------------------------------
entity  PUMP_STREAM_OUTLET_CONTROLLER is
    generic (
        O_CLK_RATE          : --! @brief OUTPUT CLOCK RATE :
                              --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側
                              --! のクロック(O_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        O_REQ_ADDR_VALID    : --! @brief OUTLET REQUEST ADDRESS VALID :
                              --! O_REQ_ADDR信号を有効にするか否かを指示する.
                              --! * O_REQ_ADDR_VALID=0で無効.
                              --! * O_REQ_ADDR_VALID=1で有効.
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
                              --! * O_REQ_SIZE_VALID=0で無効.
                              --! * O_REQ_SIZE_VALID=1で有効.
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
        O_USE_PULL_BUF_SIZE : --! @brief OUTLET USE PULL BUFFER SIZE :
                              --! O_PULL_BUF_SIZE信号を使用するか否かを指示する.
                              --! * O_USE_PULL_BUF_SIZE=0で使用しない.
                              --! * O_USE_PULL_BUF_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
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
        I_CLK_RATE          : --! @brief INPUT CLOCK RATE :
                              --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側
                              --! のクロック(O_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        I_DATA_BITS         : --! @brief INPUT STREAM DATA BITS :
                              --! I_DATA のビット数を指定する.
                              integer := 32;
        I_WORD_BITS         : --! @brief INPUT STREAM WORD BITS :
                              --! 入力側の１ワードあたりのビット数を指定する.
                              integer := 8;
        I_JUSTIFIED         : --! @brief INPUT STREAM DATA JUSTIFIED :
                              --! 入力側の有効なデータが常にLOW側に詰められていることを
                              --! 示すフラグ.
                              --! * 常にLOW側に詰められている場合は、シフタが必要なくなる
                              --!   ため回路が簡単になる.
                              integer range 0 to 1 := 0;
        BUF_DEPTH           : --! @brief BUFFER DEPTH :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        BUF_DATA_BITS       : --! @brief BUFFER DATA BITS :
                              --! BUF_DATA のビット数を指定する.
                              integer := 32;
        O2I_OPEN_INFO_BITS  : --! @brief O2I_OPEN_INFO BITS :
                              --! I_O2I_OPEN_INFO/O_O2I_OPEN_INFO のビット数を指定する.
                              integer :=  1;
        O2I_CLOSE_INFO_BITS : --! @brief O2I_CLOSE_INFO BITS :
                              --! I_O2I_CLOSE_INFO/O_O2I_CLOSE_INFO のビット数を指定する.
                              integer :=  1;
        I2O_OPEN_INFO_BITS  : --! @brief I2O_OPEN_INFO BITS :
                              --! I_I2O_OPEN_INFO/O_I2O_OPEN_INFO のビット数を指定する.
                              integer :=  1;
        I2O_CLOSE_INFO_BITS : --! @brief I2O_CLOSE_INFO BITS :
                              --! I_I2O_CLOSE_INFO/O_I2O_CLOSE_INFO のビット数を指定する.
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
        O_CLOSE_ST_L        : in  std_logic := '0';
        O_CLOSE_ST_D        : in  std_logic := '0';
        O_CLOSE_ST_Q        : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Configuration Signals.
    -------------------------------------------------------------------------------
        O_ADDR_FIX          : in  std_logic := '0';
        O_BUF_READY_LEVEL   : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_FLOW_READY_LEVEL  : in  std_logic_vector(BUF_DEPTH         downto 0);
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
    -- Outlet Transaction Command Acknowledge Signals.
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
    -- Outlet Status Signals.
    -------------------------------------------------------------------------------
        O_OPEN              : out std_logic;
        O_TRAN_BUSY         : out std_logic;
        O_TRAN_DONE         : out std_logic;
        O_TRAN_NONE         : out std_logic;
        O_TRAN_ERROR        : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Open/Close Infomation Interface
    -------------------------------------------------------------------------------
        O_O2I_OPEN_INFO     : in  std_logic_vector(O2I_OPEN_INFO_BITS -1 downto 0) := (others => '0');
        O_O2I_CLOSE_INFO    : in  std_logic_vector(O2I_CLOSE_INFO_BITS-1 downto 0) := (others => '0');
        O_I2O_OPEN_INFO     : out std_logic_vector(I2O_OPEN_INFO_BITS -1 downto 0);
        O_I2O_OPEN_VALID    : out std_logic;
        O_I2O_CLOSE_INFO    : out std_logic_vector(I2O_CLOSE_INFO_BITS-1 downto 0);
        O_I2O_CLOSE_VALID   : out std_logic;
        O_I2O_STOP          : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Clock and Clock Enable.
    -------------------------------------------------------------------------------
        I_CLK               : in  std_logic;
        I_CLR               : in  std_logic;
        I_CKE               : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Intake Stream Interface.
    -------------------------------------------------------------------------------
        I_DATA              : in  std_logic_vector(I_DATA_BITS    -1 downto 0);
        I_STRB              : in  std_logic_vector(I_DATA_BITS/8  -1 downto 0);
        I_LAST              : in  std_logic;
        I_VALID             : in  std_logic;
        I_READY             : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Status.
    -------------------------------------------------------------------------------
        I_OPEN              : out std_logic;
        I_DONE              : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Open/Close Infomation Interface
    -------------------------------------------------------------------------------
        I_O2I_RESET         : out std_logic;
        I_O2I_STOP          : out std_logic;
        I_O2I_NONE          : out std_logic;
        I_O2I_ERROR         : out std_logic;
        I_O2I_OPEN_INFO     : out std_logic_vector(O2I_OPEN_INFO_BITS -1 downto 0);
        I_O2I_OPEN_VALID    : out std_logic;
        I_O2I_CLOSE_INFO    : out std_logic_vector(O2I_CLOSE_INFO_BITS-1 downto 0);
        I_O2I_CLOSE_VALID   : out std_logic;
        I_I2O_STOP          : in  std_logic := '0';
        I_I2O_OPEN_INFO     : in  std_logic_vector(I2O_OPEN_INFO_BITS -1 downto 0) := (others => '0');
        I_I2O_OPEN_VALID    : in  std_logic;
        I_I2O_CLOSE_INFO    : in  std_logic_vector(O2I_CLOSE_INFO_BITS-1 downto 0) := (others => '0');
        I_I2O_CLOSE_VALID   : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Buffer Read Interface.
    -------------------------------------------------------------------------------
        BUF_WEN             : out std_logic;
        BUF_BEN             : out std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
        BUF_PTR             : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        BUF_DATA            : out std_logic_vector(BUF_DATA_BITS  -1 downto 0)
    );
end PUMP_STREAM_OUTLET_CONTROLLER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.FLOAT_INTAKE_VALVE;
use     PIPEWORK.COMPONENTS.POOL_INTAKE_PORT;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER_OUTLET_SIDE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_FLOW_SYNCRONIZER;
architecture RTL of PUMP_STREAM_OUTLET_CONTROLLER is
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant  SIZE_BITS             :  integer := BUF_DEPTH+1;
    -------------------------------------------------------------------------------
    -- 出力側の各種信号群.
    -------------------------------------------------------------------------------
    signal    o_valve_open          :  std_logic;
    signal    o_open_valid          :  std_logic;
    signal    o_close_valid         :  std_logic;
    signal    o_reset_valid         :  std_logic;
    signal    o_error_valid         :  std_logic;
    signal    o_none_valid          :  std_logic;
    signal    o_stop_valid          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  O_STAT_CLOSE_POS      :  integer := 0;
    constant  O_STAT_REG_LO         :  integer := 1;
    constant  O_STAT_REG_HI         :  integer := O_REG_STAT_BITS;
    constant  O_STAT_BITS           :  integer := O_STAT_REG_HI + 1;
    signal    o_status_load         :  std_logic_vector(O_STAT_BITS-1 downto 0);
    signal    o_status_wbit         :  std_logic_vector(O_STAT_BITS-1 downto 0);
    signal    o_status_regs         :  std_logic_vector(O_STAT_BITS-1 downto 0);
    signal    o_status_in           :  std_logic_vector(O_STAT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 入力側の各種信号群.
    -------------------------------------------------------------------------------
    signal    i_valve_open          :  std_logic;
    signal    i_open_valid          :  std_logic;
    signal    i_open_info           :  std_logic_vector(I2O_OPEN_INFO_BITS -1 downto 0);
    signal    i_close_valid         :  std_logic;
    signal    i_close_info          :  std_logic_vector(I2O_CLOSE_INFO_BITS-1 downto 0);
    signal    i_push_fin_valid      :  std_logic;
    signal    i_push_fin_last       :  std_logic;
    signal    i_push_fin_size       :  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側->入力側の各種信号群.
    -------------------------------------------------------------------------------
    signal    o2i_valve_open        :  std_logic;
    signal    o2i_reset_valid       :  std_logic;
    signal    o2i_error_valid       :  std_logic;
    signal    o2i_none_valid        :  std_logic;
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
    -------------------------------------------------------------------------------
    -- 入力側->出力側の各種信号群.
    -------------------------------------------------------------------------------
    signal    i2o_valve_open        :  std_logic;
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
begin
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
            REG_STAT_BITS       => O_STAT_BITS         , --   
            FIXED_FLOW_OPEN     => O_FIXED_FLOW_OPEN   , --   
            FIXED_POOL_OPEN     => O_FIXED_POOL_OPEN   , --   
            USE_PULL_BUF_SIZE   => O_USE_PULL_BUF_SIZE , --   
            USE_PUSH_RSV_SIZE   => 0                   , --   
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
            REG_STAT_L          => o_status_load       , -- In  :
            REG_STAT_D          => o_status_wbit       , -- In  :
            REG_STAT_Q          => o_status_regs       , -- Out :
            REG_STAT_I          => o_status_in         , -- In  :
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
            I_STOP              => i2o_stop_valid      , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Status Output.
        ---------------------------------------------------------------------------
            O_OPEN              => o_valve_open        , -- Out :
        ---------------------------------------------------------------------------
        -- Transaction Status Signals.
        ---------------------------------------------------------------------------
            TRAN_BUSY           => O_TRAN_BUSY         , -- Out :
            TRAN_DONE           => O_TRAN_DONE         , -- Out :
            TRAN_NONE           => o_none_valid        , -- Out :
            TRAN_ERROR          => o_error_valid         -- Out :
        );
    O_OPEN       <= o_valve_open;
    O_TRAN_NONE  <= o_none_valid;
    O_TRAN_ERROR <= o_error_valid;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    o_status_load(O_STAT_CLOSE_POS)                   <= O_CLOSE_ST_L;
    o_status_wbit(O_STAT_CLOSE_POS)                   <= O_CLOSE_ST_D;
    o_status_in  (O_STAT_CLOSE_POS)                   <= i2o_close_valid;
    O_CLOSE_ST_Q <= o_status_regs(O_STAT_CLOSE_POS);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    o_status_load(O_STAT_REG_HI downto O_STAT_REG_LO) <= O_STAT_L;
    o_status_wbit(O_STAT_REG_HI downto O_STAT_REG_LO) <= O_STAT_D;
    o_status_in  (O_STAT_REG_HI downto O_STAT_REG_LO) <= O_STAT_I;
    O_STAT_Q     <= o_status_regs(O_STAT_REG_HI downto O_STAT_REG_LO);
    -------------------------------------------------------------------------------
    -- 出力側から入力側への各種情報転送
    -------------------------------------------------------------------------------
    O2I: block
        signal    o_valve_opened    :  std_logic;
        constant  null_valid        :  std_logic := '0';
        constant  null_last         :  std_logic := '0';
        constant  null_size         :  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (O_CLK, RST) begin
            if (RST = '1') then
                    o_reset_valid <= '0';
                    o_stop_valid  <= '0';
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1') then
                    o_reset_valid <= '0';
                elsif (O_RESET_L = '1' and O_RESET_D = '1') then
                    o_reset_valid <= '1';
                else
                    o_reset_valid <= '0';
                end if;
                if (O_CLR = '1') then
                    o_stop_valid  <= '0';
                elsif (O_STOP_L  = '1' and O_STOP_D  = '1') then
                    o_stop_valid  <= '1';
                else
                    o_stop_valid  <= '0';
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- 出力側のバルブの開閉情報
        ---------------------------------------------------------------------------
        process (O_CLK, RST) begin
            if (RST = '1') then
                    o_valve_opened <= '0';
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1') then
                    o_valve_opened <= '0';
                else
                    o_valve_opened <= o_valve_open;
                end if;
            end if;
        end process;
        o_open_valid  <= '1' when (o_valve_open = '1' and o_valve_opened = '0') else '0';
        o_close_valid <= '1' when (o_valve_open = '0' and o_valve_opened = '1') else '0';
        ---------------------------------------------------------------------------
        -- クロック同期回路
        ---------------------------------------------------------------------------
        SYNC: PUMP_FLOW_SYNCRONIZER                      -- 
            generic map (                                --
                I_CLK_RATE      => O_CLK_RATE          , -- 
                O_CLK_RATE      => I_CLK_RATE          , --
                OPEN_INFO_BITS  => O2I_OPEN_INFO_BITS  , --
                CLOSE_INFO_BITS => O2I_CLOSE_INFO_BITS , --
                EVENT_SIZE      => 4                   , --
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
                I_OPEN_VAL      => o_open_valid        , -- In  :
                I_OPEN_INFO     => O_O2I_OPEN_INFO     , -- In  :
                I_CLOSE_VAL     => o_close_valid       , -- In  :
                I_CLOSE_INFO    => O_O2I_CLOSE_INFO    , -- In  :
                I_EVENT(0)      => o_stop_valid        , -- In  :
                I_EVENT(1)      => o_reset_valid       , -- In  :
                I_EVENT(2)      => o_error_valid       , -- In  :
                I_EVENT(3)      => o_none_valid        , -- In  :
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
                O_OPEN_VAL      => o2i_open_valid      , -- Out :
                O_OPEN_INFO     => o2i_open_info       , -- Out :
                O_CLOSE_VAL     => o2i_close_valid     , -- Out :
                O_CLOSE_INFO    => o2i_close_info      , -- Out :
                O_EVENT(0)      => o2i_stop_valid      , -- Out :
                O_EVENT(1)      => o2i_reset_valid     , -- Out :
                O_EVENT(2)      => o2i_error_valid     , -- Out :
                O_EVENT(3)      => o2i_none_valid      , -- Out :
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
    end block;        
    -------------------------------------------------------------------------------
    -- 入力側から出力側への各種情報転送
    -------------------------------------------------------------------------------
    I2O: block
        signal    i2o_valve_opened  :  std_logic;
        constant  null_valid        :  std_logic := '0';
        constant  null_last         :  std_logic := '0';
        constant  null_size         :  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        -- クロック同期回路
        ---------------------------------------------------------------------------
        SYNC: PUMP_FLOW_SYNCRONIZER                      -- 
            generic map (                                --
                I_CLK_RATE      => I_CLK_RATE          , -- 
                O_CLK_RATE      => O_CLK_RATE          , --
                OPEN_INFO_BITS  => I2O_OPEN_INFO_BITS  , --
                CLOSE_INFO_BITS => I2O_CLOSE_INFO_BITS , --
                EVENT_SIZE      => 1                   , --
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
                I_OPEN_INFO     => i_open_info         , -- In  :
                I_CLOSE_VAL     => i_close_valid       , -- In  :
                I_CLOSE_INFO    => i_close_info        , -- In  :
                I_EVENT(0)      => I_I2O_STOP          , -- In  :
                I_PUSH_FIN_VAL  => i_push_fin_valid    , -- In  :
                I_PUSH_FIN_LAST => i_push_fin_last     , -- In  :
                I_PUSH_FIN_SIZE => i_push_fin_size     , -- In  :
                I_PUSH_RSV_VAL  => null_valid          , -- In  :
                I_PUSH_RSV_LAST => null_last           , -- In  :
                I_PUSH_RSV_SIZE => null_size           , -- In  :
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
                    i2o_valve_opened <= '0';
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1' or i2o_close_valid = '1') then
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
        O_I2O_CLOSE_INFO  <= i2o_close_info;
        O_I2O_CLOSE_VALID <= i2o_close_valid;
        O_I2O_STOP        <= i2o_stop_valid;
    end block;        
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_SIDE: block
        constant  null_buf_ptr      :  std_logic_vector(BUF_DEPTH-1 downto 0) := (others => '0');
        constant  null_size         :  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
        constant  BUF_DATA_BYTES    :  integer := BUF_DATA_BITS/8;
        constant  BUF_SIZE          :  integer := 2**BUF_DEPTH;
        constant  POOL_SIZE         :  std_logic_vector(SIZE_BITS-1 downto 0) := std_logic_vector(to_unsigned(BUF_SIZE               , SIZE_BITS));
        constant  FLOW_READY_LEVEL  :  std_logic_vector(SIZE_BITS-1 downto 0) := std_logic_vector(to_unsigned(BUF_SIZE-BUF_DATA_BYTES, SIZE_BITS));
        signal    flow_ready        :  std_logic;
        signal    port_reset        :  std_logic;
        signal    port_busy         :  std_logic;
        signal    o2i_valve_opened  :  std_logic;
        signal    i_valve_opened    :  std_logic;
        signal    i_close_busy      :  std_logic;
    begin
        ---------------------------------------------------------------------------
        -- 
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
        o2i_valve_open    <= '1' when (o2i_valve_opened = '1' and o2i_close_valid = '0') or
                                      (o2i_open_valid   = '1') else '0';
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        I_O2I_OPEN_INFO   <= o2i_open_info;
        I_O2I_OPEN_VALID  <= o2i_open_valid;
        I_O2I_CLOSE_INFO  <= o2i_close_info;
        I_O2I_CLOSE_VALID <= o2i_close_valid;
        I_O2I_STOP        <= o2i_stop_valid;
        I_O2I_ERROR       <= o2i_error_valid;
        I_O2I_RESET       <= o2i_reset_valid;
        I_O2I_NONE        <= o2i_none_valid;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (I_CLK, RST) begin
            if (RST = '1') then
                    i_close_busy <= '0';
                    i_close_info <= (others => '0');
            elsif (I_CLK'event and I_CLK = '1') then
                if (I_CLR = '1') then
                    i_close_busy <= '0';
                    i_close_info <= (others => '0');
                elsif (i_close_busy = '0') then
                    if (I_I2O_CLOSE_VALID = '1') then
                        i_close_busy <= '1';
                        i_close_info <= I_I2O_CLOSE_INFO;
                    else
                        i_close_busy <= '0';
                    end if;
                else
                    if (port_busy = '0') then
                        i_close_busy <= '0';
                    else
                        i_close_busy <= '1';
                    end if;
                end if;
            end if;
        end process;
        i_open_valid  <= I_I2O_OPEN_VALID;
        i_open_info   <= I_I2O_OPEN_INFO;
        i_close_valid <= '1' when (i_close_busy = '1' and port_busy = '0') else '0';
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (I_CLK, RST) begin
            if (RST = '1') then
                    i_valve_opened <= '0';
            elsif (I_CLK'event and I_CLK = '1') then
                if (I_CLR = '1') then
                    i_valve_opened <= '0';
                elsif (i_close_valid = '1') then
                    i_valve_opened <= '0';
                elsif (i_open_valid  = '1') then
                    i_valve_opened <= '1';
                end if;
            end if;
        end process;
        i_valve_open  <= '1' when (i_open_valid   = '1' or i_valve_opened = '1') else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        VALVE: FLOAT_INTAKE_VALVE                        -- 
            generic map (                                -- 
                COUNT_BITS      => SIZE_BITS           , --
                SIZE_BITS       => SIZE_BITS             --
            )                                            -- 
            port map (                                   -- 
            -----------------------------------------------------------------------
            -- Clock & Reset Signals.
            -----------------------------------------------------------------------
                CLK             => I_CLK               , -- In  :
                RST             => RST                 , -- In  :
                CLR             => I_CLR               , -- In  :
            -----------------------------------------------------------------------
            -- Control Signals.
            -----------------------------------------------------------------------
                RESET           => o2i_reset_valid     , -- In  :
                PAUSE           => '0'                 , -- In  :
                STOP            => '0'                 , -- In  :
                INTAKE_OPEN     => o2i_valve_open      , -- In  :
                OUTLET_OPEN     => i_valve_open        , -- In  :
                POOL_SIZE       => POOL_SIZE           , -- In  :
                FLOW_READY_LEVEL=> FLOW_READY_LEVEL    , -- In  :
            -----------------------------------------------------------------------
            -- Flow Counter Load Signals.
            -----------------------------------------------------------------------
                LOAD            => i_open_valid        , -- In  :
                LOAD_COUNT      => null_size           , -- In  :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => i_push_fin_valid    , -- In  :
                PUSH_LAST       => i_push_fin_last     , -- In  :
                PUSH_SIZE       => i_push_fin_size     , -- In  :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => o2i_pull_fin_valid  , -- In  :
                PULL_LAST       => o2i_pull_fin_last   , -- In  :
                PULL_SIZE       => o2i_pull_fin_size   , -- In  :
            -----------------------------------------------------------------------
            -- Intake Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_READY      => flow_ready          , -- Out :
                FLOW_PAUSE      => open                , -- Out :
                FLOW_STOP       => open                , -- Out :
                FLOW_LAST       => open                , -- Out :
                FLOW_SIZE       => open                , -- Out :
            -----------------------------------------------------------------------
            -- Flow Counter Signals.
            -----------------------------------------------------------------------
                FLOW_COUNT      => open                , -- Out :
                FLOW_ZERO       => open                , -- Out :
                FLOW_POS        => open                , -- Out :
                FLOW_NEG        => open                , -- Out :
                PAUSED          => open                  -- Out :
            );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        I_PORT: POOL_INTAKE_PORT                         -- 
            generic map (                                -- 
                UNIT_BITS       => 8                   , -- 
                WORD_BITS       => I_WORD_BITS         , --   
                PORT_DATA_BITS  => I_DATA_BITS         , --   
                POOL_DATA_BITS  => BUF_DATA_BITS       , --   
                SEL_BITS        => 1                   , --   
                SIZE_BITS       => SIZE_BITS           , --   
                PTR_BITS        => BUF_DEPTH           , --   
                QUEUE_SIZE      => 0                   , --
                PORT_JUSTIFIED  => I_JUSTIFIED           -- 
            )                                            -- 
            port map (                                   --
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => I_CLK               , -- In  :
                RST             => RST                 , -- In  :
                CLR             => port_reset          , -- In  :
            -----------------------------------------------------------------------
            -- Control Signals.
            -----------------------------------------------------------------------
                START           => i_open_valid        , -- In  :
                START_PTR       => null_buf_ptr        , -- In  :
                XFER_LAST       => '0'                 , -- In  :
                XFER_SEL        => "1"                 , -- In  :
            -----------------------------------------------------------------------
            -- Intake Port Signals.
            -----------------------------------------------------------------------
                PORT_ENABLE     => i_valve_open        , -- In  :
                PORT_DATA       => I_DATA              , -- In  :
                PORT_DVAL       => I_STRB              , -- In  :
                PORT_ERROR      => '0'                 , -- In  :
                PORT_LAST       => I_LAST              , -- In  :
                PORT_VAL        => I_VALID             , -- In  :
                PORT_RDY        => I_READY             , -- Out :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VAL(0)     => i_push_fin_valid    , -- Out :
                PUSH_LAST       => i_push_fin_last     , -- Out :
                PUSH_XFER_LAST  => open                , -- Out :
                PUSH_XFER_DONE  => open                , -- Out :
                PUSH_ERROR      => open                , -- Out :
                PUSH_SIZE       => i_push_fin_size     , -- Out :
            -----------------------------------------------------------------------
            -- Pool Buffer Interface Signals.
            -----------------------------------------------------------------------
                POOL_WEN(0)     => BUF_WEN             , -- Out :
                POOL_DVAL       => BUF_BEN             , -- Out :
                POOL_DATA       => BUF_DATA            , -- Out :
                POOL_PTR        => BUF_PTR             , -- Out :
                POOL_RDY        => flow_ready          , -- In  :
            -----------------------------------------------------------------------
            -- Status Signals.
            -----------------------------------------------------------------------
                BUSY            => port_busy             -- Out :
        );
        port_reset <= '1' when (I_CLR = '1' or o2i_reset_valid = '1' or o2i_none_valid = '1') else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        I_OPEN <= i_valve_open;
        I_DONE <= i_close_valid;
    end block;
end RTL;
