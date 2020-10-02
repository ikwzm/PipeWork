-----------------------------------------------------------------------------------
--!     @file    pump_controller_intake_side.vhd
--!     @brief   PUMP CONTROLLER INTAKE SIDE
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
--! @brief   PUMP CONTROLLER INTAKE SIDE :
-----------------------------------------------------------------------------------
entity  PUMP_CONTROLLER_INTAKE_SIDE is
    generic (
        REQ_ADDR_VALID      : --! @brief REQUEST ADDRESS VALID :
                              --! REQ_ADDR信号を有効にするか否かを指示する.
                              --! * REQ_ADDR_VALID=0で無効.
                              --! * REQ_ADDR_VALID=1で有効.
                              integer range 0 to 1 := 1;
        REQ_ADDR_BITS       : --! @brief REQUEST ADDRESS BITS :
                              --! REQ_ADDR信号のビット数を指定する.
                              --! * REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        REG_ADDR_BITS       : --! @brief ADDRESS REGISTER BITS :
                              --! REG_ADDR信号のビット数を指定する.
                              --! * REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        REQ_SIZE_VALID      : --! @brief REQUEST SIZE VALID :
                              --! REQ_SIZE信号を有効にするか否かを指示する.
                              --! * REQ_SIZE_VALID=0で無効.
                              --! * REQ_SIZE_VALID=1で有効.
                              integer range 0 to 1 := 1;
        REQ_SIZE_BITS       : --! @brief REQUEST SIZE BITS :
                              --! REQ_SIZE信号のビット数を指定する.
                              --! * REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        REG_SIZE_BITS       : --! @brief SIZE REGISTER BITS :
                              --! REG_SIZE信号のビット数を指定する.
                              --! * REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        REG_MODE_BITS       : --! @brief MODE REGISTER BITS :
                              --! REG_MODE_L/REG_MODE_D/REG_MODE_Qのビット数を指定する.
                              integer := 32;
        REG_STAT_BITS       : --! @brief STATUS REGISTER BITS :
                              --! REG_STAT_L/REG_STAT_D/REG_STAT_Qのビット数を指定する.
                              integer := 32;
        FIXED_FLOW_OPEN     : --! @brief VALVE FIXED FLOW OPEN :
                              --! FLOW_READYを常に'1'にするか否かを指定する.
                              --! * FIXED_FLOW_OPEN=1で常に'1'にする.
                              --! * FIXED_FLOW_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        FIXED_POOL_OPEN     : --! @brief VALVE FIXED POOL OPEN :
                              --! PUSH_BUF_READYを常に'1'にするか否かを指定する.
                              --! * FIXED_POOL_OPEN=1で常に'1'にする.
                              --! * FIXED_POOL_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        USE_PUSH_BUF_SIZE   : --! @brief USE PUSH BUFFER SIZE :
                              --! PUSH_BUF_SIZE信号を使用するか否かを指示する.
                              --! * USE_PUSH_BUF_SIZE=0で使用しない.
                              --! * USE_PUSH_BUF_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        USE_PULL_RSV_SIZE   : --! @brief USE PULL RESERVE SIZE :
                              --! PULL_RSV_SIZE信号を使用するか否かを指示する.
                              --! * USE_PULL_RSV_SIZE=0で使用しない.
                              --! * USE_PULL_RSV_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        BUF_DEPTH           : --! @brief BUFFER DEPTH :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock/Reset Signals.
    -------------------------------------------------------------------------------
        CLK                 : in  std_logic;
        RST                 : in  std_logic;
        CLR                 : in  std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register Interface.
    -------------------------------------------------------------------------------
        REG_ADDR_L          : in  std_logic_vector(REG_ADDR_BITS-1 downto 0) := (others => '0');
        REG_ADDR_D          : in  std_logic_vector(REG_ADDR_BITS-1 downto 0) := (others => '0');
        REG_ADDR_Q          : out std_logic_vector(REG_ADDR_BITS-1 downto 0);
        REG_SIZE_L          : in  std_logic_vector(REG_SIZE_BITS-1 downto 0) := (others => '0');
        REG_SIZE_D          : in  std_logic_vector(REG_SIZE_BITS-1 downto 0) := (others => '0');
        REG_SIZE_Q          : out std_logic_vector(REG_SIZE_BITS-1 downto 0);
        REG_MODE_L          : in  std_logic_vector(REG_MODE_BITS-1 downto 0) := (others => '0');
        REG_MODE_D          : in  std_logic_vector(REG_MODE_BITS-1 downto 0) := (others => '0');
        REG_MODE_Q          : out std_logic_vector(REG_MODE_BITS-1 downto 0);
        REG_STAT_L          : in  std_logic_vector(REG_STAT_BITS-1 downto 0) := (others => '0');
        REG_STAT_D          : in  std_logic_vector(REG_STAT_BITS-1 downto 0) := (others => '0');
        REG_STAT_Q          : out std_logic_vector(REG_STAT_BITS-1 downto 0);
        REG_STAT_I          : in  std_logic_vector(REG_STAT_BITS-1 downto 0) := (others => '0');
        REG_RESET_L         : in  std_logic := '0';
        REG_RESET_D         : in  std_logic := '0';
        REG_RESET_Q         : out std_logic;
        REG_START_L         : in  std_logic := '0';
        REG_START_D         : in  std_logic := '0';
        REG_START_Q         : out std_logic;
        REG_STOP_L          : in  std_logic := '0';
        REG_STOP_D          : in  std_logic := '0';
        REG_STOP_Q          : out std_logic;
        REG_PAUSE_L         : in  std_logic := '0';
        REG_PAUSE_D         : in  std_logic := '0';
        REG_PAUSE_Q         : out std_logic;
        REG_FIRST_L         : in  std_logic := '0';
        REG_FIRST_D         : in  std_logic := '0';
        REG_FIRST_Q         : out std_logic;
        REG_LAST_L          : in  std_logic := '0';
        REG_LAST_D          : in  std_logic := '0';
        REG_LAST_Q          : out std_logic;
        REG_DONE_EN_L       : in  std_logic := '0';
        REG_DONE_EN_D       : in  std_logic := '0';
        REG_DONE_EN_Q       : out std_logic;
        REG_DONE_ST_L       : in  std_logic := '0';
        REG_DONE_ST_D       : in  std_logic := '0';
        REG_DONE_ST_Q       : out std_logic;
        REG_ERR_ST_L        : in  std_logic := '0';
        REG_ERR_ST_D        : in  std_logic := '0';
        REG_ERR_ST_Q        : out std_logic;
    -------------------------------------------------------------------------------
    -- Configuration Signals.
    -------------------------------------------------------------------------------
        ADDR_FIX            : in  std_logic := '0';
        BUF_READY_LEVEL     : in  std_logic_vector(BUF_DEPTH       downto 0);
        FLOW_READY_LEVEL    : in  std_logic_vector(BUF_DEPTH       downto 0);
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_VALID           : out std_logic;
        REQ_ADDR            : out std_logic_vector(REQ_ADDR_BITS-1 downto 0);
        REQ_SIZE            : out std_logic_vector(REQ_SIZE_BITS-1 downto 0);
        REQ_BUF_PTR         : out std_logic_vector(BUF_DEPTH    -1 downto 0);
        REQ_FIRST           : out std_logic;
        REQ_LAST            : out std_logic;
        REQ_NONE            : out std_logic;
        REQ_READY           : in  std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VALID           : in  std_logic;
        ACK_SIZE            : in  std_logic_vector(BUF_DEPTH       downto 0);
        ACK_ERROR           : in  std_logic := '0';
        ACK_NEXT            : in  std_logic;
        ACK_LAST            : in  std_logic;
        ACK_STOP            : in  std_logic;
        ACK_NONE            : in  std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Status Signals.
    -------------------------------------------------------------------------------
        XFER_BUSY           : in  std_logic;
        XFER_DONE           : in  std_logic;
        XFER_ERROR          : in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY          : out std_logic;
        FLOW_PAUSE          : out std_logic;
        FLOW_STOP           : out std_logic;
        FLOW_LAST           : out std_logic;
        FLOW_SIZE           : out std_logic_vector(BUF_DEPTH       downto 0);
        PUSH_FIN_VALID      : in  std_logic := '0';
        PUSH_FIN_LAST       : in  std_logic := '0';
        PUSH_FIN_ERROR      : in  std_logic := '0';
        PUSH_FIN_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
        PUSH_RSV_VALID      : in  std_logic := '0';
        PUSH_RSV_LAST       : in  std_logic := '0';
        PUSH_RSV_ERROR      : in  std_logic := '0';
        PUSH_RSV_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
        PUSH_BUF_RESET      : in  std_logic := '0';
        PUSH_BUF_VALID      : in  std_logic := '0';
        PUSH_BUF_LAST       : in  std_logic := '0';
        PUSH_BUF_ERROR      : in  std_logic := '0';
        PUSH_BUF_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
        PUSH_BUF_READY      : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        PULL_FIN_VALID      : in  std_logic := '0';
        PULL_FIN_LAST       : in  std_logic := '0';
        PULL_FIN_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
        PULL_RSV_VALID      : in  std_logic := '0';
        PULL_RSV_LAST       : in  std_logic := '0';
        PULL_RSV_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Outlet Status Input.
    -------------------------------------------------------------------------------
        O_OPEN              : in  std_logic;
        O_STOP              : in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Intake Status Output.
    -------------------------------------------------------------------------------
        I_OPEN              : out std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Status Signals.
    -------------------------------------------------------------------------------
        TRAN_BUSY           : out std_logic;
        TRAN_DONE           : out std_logic;
        TRAN_NONE           : out std_logic;
        TRAN_ERROR          : out std_logic
    );
end PUMP_CONTROLLER_INTAKE_SIDE;
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
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROL_REGISTER;
architecture RTL of PUMP_CONTROLLER_INTAKE_SIDE is
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_BITS          :  integer := BUF_DEPTH+1;
    ------------------------------------------------------------------------------
    -- バッファのバイト数.
    ------------------------------------------------------------------------------
    constant BUFFER_SIZE        :  std_logic_vector(SIZE_BITS-1  downto 0) := 
                                   std_logic_vector(to_unsigned(2**BUF_DEPTH, SIZE_BITS));
    ------------------------------------------------------------------------------
    -- バッファへのアクセス用信号群.
    ------------------------------------------------------------------------------
    constant BUF_INIT_PTR       :  std_logic_vector(BUF_DEPTH    -1 downto 0) := (others => '0');
    constant BUF_UP_BEN         :  std_logic_vector(BUF_DEPTH    -1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- 各種信号群.
    -------------------------------------------------------------------------------
    signal   addr_up_ben        :  std_logic_vector(REQ_ADDR_BITS-1 downto 0);
    signal   buf_ptr_init       :  std_logic_vector(BUF_DEPTH    -1 downto 0);
    signal   reg_reset          :  std_logic;
    signal   reg_pause          :  std_logic;
    signal   reg_stop           :  std_logic;
    signal   valve_stop         :  std_logic;
    signal   valve_open         :  std_logic;
    signal   transaction_busy   :  std_logic;
    signal   transaction_error  :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- アドレスレジスタ
    -------------------------------------------------------------------------------
    ADDR_REGS: COUNT_UP_REGISTER                     -- 
        generic map (                                -- 
            VALID           => REQ_ADDR_VALID      , -- 
            BITS            => REQ_ADDR_BITS       , -- 
            REGS_BITS       => REG_ADDR_BITS         -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            REGS_WEN        => REG_ADDR_L          , -- In  :
            REGS_WDATA      => REG_ADDR_D          , -- In  :
            REGS_RDATA      => REG_ADDR_Q          , -- Out :
            UP_ENA          => transaction_busy    , -- In  :
            UP_VAL          => ACK_VALID           , -- In  :
            UP_BEN          => addr_up_ben         , -- In  :
            UP_SIZE         => ACK_SIZE            , -- In  :
            COUNTER         => REQ_ADDR              -- Out :
        );                                           -- 
    addr_up_ben <= (others => '0') when (ADDR_FIX = '1') else (others => '1');
    -------------------------------------------------------------------------------
    -- サイズカウンタ
    -------------------------------------------------------------------------------
    SIZE_REGS: COUNT_DOWN_REGISTER                   -- 
        generic map (                                -- 
            VALID           => REQ_SIZE_VALID      , -- 
            BITS            => REQ_SIZE_BITS       , -- 
            REGS_BITS       => REG_SIZE_BITS         -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            REGS_WEN        => REG_SIZE_L          , -- In  :
            REGS_WDATA      => REG_SIZE_D          , -- In  :
            REGS_RDATA      => REG_SIZE_Q          , -- Out :
            DN_ENA          => transaction_busy    , -- In  :
            DN_VAL          => ACK_VALID           , -- In  :
            DN_SIZE         => ACK_SIZE            , -- In  :
            COUNTER         => REQ_SIZE            , -- Out :
            ZERO            => REQ_NONE            , -- Out :
            NEG             => open                  -- Out :
       );                                            -- 
    -------------------------------------------------------------------------------
    -- バッファポインタ
    -------------------------------------------------------------------------------
    BUF_PTR: COUNT_UP_REGISTER                       -- 
        generic map (                                -- 
            VALID           => 1                   , -- 
            BITS            => BUF_DEPTH           , --
            REGS_BITS       => BUF_DEPTH             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            REGS_WEN        => buf_ptr_init        , -- In  :
            REGS_WDATA      => BUF_INIT_PTR        , -- In  :
            REGS_RDATA      => open                , -- Out :
            UP_ENA          => transaction_busy    , -- In  :
            UP_VAL          => ACK_VALID           , -- In  :
            UP_BEN          => BUF_UP_BEN          , -- In  :
            UP_SIZE         => ACK_SIZE            , -- In  :
            COUNTER         => REQ_BUF_PTR           -- Out :
       );                                            -- 
    buf_ptr_init <= (others => '1') when (valve_open = '0') else (others => '0');
    -------------------------------------------------------------------------------
    -- 制御レジスタ
    -------------------------------------------------------------------------------
    CTRL_REGS: PUMP_CONTROL_REGISTER                 -- 
        generic map (                                -- 
            MODE_BITS       => REG_MODE_BITS       , -- 
            STAT_BITS       => REG_STAT_BITS         -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            RESET_L         => REG_RESET_L         , -- In  :
            RESET_D         => REG_RESET_D         , -- In  :
            RESET_Q         => reg_reset           , -- Out :
            START_L         => REG_START_L         , -- In  :
            START_D         => REG_START_D         , -- In  :
            START_Q         => REG_START_Q         , -- Out :
            STOP_L          => REG_STOP_L          , -- In  :
            STOP_D          => REG_STOP_D          , -- In  :
            STOP_Q          => reg_stop            , -- Out :
            PAUSE_L         => REG_PAUSE_L         , -- In  :
            PAUSE_D         => REG_PAUSE_D         , -- In  :
            PAUSE_Q         => reg_pause           , -- Out :
            FIRST_L         => REG_FIRST_L         , -- In  :
            FIRST_D         => REG_FIRST_D         , -- In  :
            FIRST_Q         => REG_FIRST_Q         , -- Out :
            LAST_L          => REG_LAST_L          , -- In  :
            LAST_D          => REG_LAST_D          , -- In  :
            LAST_Q          => REG_LAST_Q          , -- Out :
            DONE_EN_L       => REG_DONE_EN_L       , -- In  :
            DONE_EN_D       => REG_DONE_EN_D       , -- In  :
            DONE_EN_Q       => REG_DONE_EN_Q       , -- Out :
            DONE_ST_L       => REG_DONE_ST_L       , -- In  :
            DONE_ST_D       => REG_DONE_ST_D       , -- In  :
            DONE_ST_Q       => REG_DONE_ST_Q       , -- Out :
            ERR_ST_L        => REG_ERR_ST_L        , -- In  :
            ERR_ST_D        => REG_ERR_ST_D        , -- In  :
            ERR_ST_Q        => REG_ERR_ST_Q        , -- Out :
            MODE_L          => REG_MODE_L          , -- In  :
            MODE_D          => REG_MODE_D          , -- In  :
            MODE_Q          => REG_MODE_Q          , -- Out :
            STAT_L          => REG_STAT_L          , -- In  :
            STAT_D          => REG_STAT_D          , -- In  :
            STAT_Q          => REG_STAT_Q          , -- Out :
            STAT_I          => REG_STAT_I          , -- In  :
            REQ_VALID       => REQ_VALID           , -- Out :
            REQ_FIRST       => REQ_FIRST           , -- Out :
            REQ_LAST        => REQ_LAST            , -- Out :
            REQ_READY       => REQ_READY           , -- In  :
            ACK_VALID       => ACK_VALID           , -- In  :
            ACK_ERROR       => ACK_ERROR           , -- In  :
            ACK_NEXT        => ACK_NEXT            , -- In  :
            ACK_LAST        => ACK_LAST            , -- In  :
            ACK_STOP        => ACK_STOP            , -- In  :
            ACK_NONE        => ACK_NONE            , -- In  :
            XFER_BUSY       => XFER_BUSY           , -- In  :
            XFER_DONE       => XFER_DONE           , -- In  :
            XFER_ERROR      => XFER_ERROR          , -- In  :
            VALVE_OPEN      => valve_open          , -- Out :
            TRAN_DONE       => TRAN_DONE           , -- Out :
            TRAN_NONE       => TRAN_NONE           , -- Out :
            TRAN_ERROR      => transaction_error   , -- Out :
            TRAN_BUSY       => transaction_busy      -- Out :
        );                                           -- 
    REG_RESET_Q <= reg_reset;
    REG_PAUSE_Q <= reg_pause;
    REG_STOP_Q  <= reg_stop;
    TRAN_BUSY   <= transaction_busy;
    TRAN_ERROR  <= transaction_error;
    I_OPEN      <= valve_open;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                valve_stop <= '0';
        elsif (CLK'event and CLK = '1') then
            if    (CLR = '1'    or reg_reset = '1' or valve_open = '0') then
                valve_stop <= '0';
            elsif (O_STOP = '1' or reg_stop  = '1' or transaction_error = '1') then
                valve_stop <= '1';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 入力側のバルブ
    -------------------------------------------------------------------------------
    VALVE: FLOAT_INTAKE_MANIFOLD_VALVE               -- 
        generic map (                                --
            FIXED_CLOSE     => 0                   , --
            FIXED_FLOW_OPEN => FIXED_FLOW_OPEN     , --
            FIXED_POOL_OPEN => FIXED_POOL_OPEN     , --
            USE_PULL_RSV    => USE_PULL_RSV_SIZE   , --
            USE_POOL_PUSH   => USE_PUSH_BUF_SIZE   , --
            COUNT_BITS      => SIZE_BITS           , -- 
            SIZE_BITS       => SIZE_BITS             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            POOL_SIZE       => BUFFER_SIZE         , -- In  :
            FLOW_READY_LEVEL=> FLOW_READY_LEVEL    , -- In  :
            POOL_READY_LEVEL=> BUF_READY_LEVEL     , -- In  :
            INTAKE_OPEN     => valve_open          , -- In  :
            OUTLET_OPEN     => O_OPEN              , -- In  :
            RESET           => reg_reset           , -- In  :
            PAUSE           => reg_pause           , -- In  :
            STOP            => valve_stop          , -- In  :
            PULL_FIN_VALID  => PULL_FIN_VALID      , -- In  :
            PULL_FIN_LAST   => PULL_FIN_LAST       , -- In  :
            PULL_FIN_SIZE   => PULL_FIN_SIZE       , -- In  :
            PULL_RSV_VALID  => PULL_RSV_VALID      , -- In  :
            PULL_RSV_LAST   => PULL_RSV_LAST       , -- In  :
            PULL_RSV_SIZE   => PULL_RSV_SIZE       , -- In  :
            FLOW_PUSH_VALID => ACK_VALID           , -- In  :
            FLOW_PUSH_LAST  => ACK_LAST            , -- In  :
            FLOW_PUSH_SIZE  => ACK_SIZE            , -- In  :
            FLOW_READY      => FLOW_READY          , -- Out :
            FLOW_PAUSE      => FLOW_PAUSE          , -- Out :
            FLOW_STOP       => FLOW_STOP           , -- Out :
            FLOW_LAST       => FLOW_LAST           , -- Out :
            FLOW_SIZE       => FLOW_SIZE           , -- Out :
            FLOW_COUNT      => open                , -- Out :
            FLOW_ZERO       => open                , -- Out :
            FLOW_POS        => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            POOL_PUSH_RESET => PUSH_BUF_RESET      , -- In  :
            POOL_PUSH_VALID => PUSH_BUF_VALID      , -- In  :
            POOL_PUSH_LAST  => PUSH_BUF_LAST       , -- In  :
            POOL_PUSH_SIZE  => PUSH_BUF_SIZE       , -- In  :
            POOL_READY      => PUSH_BUF_READY      , -- Out :
            POOL_COUNT      => open                , -- Out :
            PAUSED          => open                  -- Out :
        );                                           --
end RTL;

