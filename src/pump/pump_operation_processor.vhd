-----------------------------------------------------------------------------------
--!     @file    pump_operation_processor.vhd
--!     @brief   PUMP Operation Processor
--!     @version 1.7.0
--!     @date    2018/5/21
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2018 Ichiro Kawazome
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
--! @brief   PUMP OPERATION PROCESSOR :
-----------------------------------------------------------------------------------
entity  PUMP_OPERATION_PROCESSOR is
    generic (
        M_ADDR_BITS     : --! @brief Operation Code Fetch Address Bits :
                          --! M_REQ_ADDR のビット数を示す.
                          integer := 32;
        M_BUF_SIZE      : --! @brief Operation Code Fetch Buffer Size :
                          --! オペレーションコードを格納するバッファのバイト数を２
                          --! のべき乗値で示す.
                          integer :=  4;
        M_BUF_WIDTH     : --! @brief Operation Code Fetch Data Width :
                          --! オペレーションコードを格納するバッファのデータのビッ
                          --! ト幅を２のべき乗値で示す.
                          integer :=  5;
        OP_BITS         : --! @brief Operation Code Bits:
                          --! オペレーションコードの総ビット数を指定する.
                          integer := 128;
        OP_XFER_LO      : --! @brief Transfer Operation Code Low :
                          --! 転送オペレーションコードの最下位ビットの位置を指定す
                          --! る.
                          integer :=  0;
        OP_XFER_HI      : --! @brief Transfer Operation Code High :
                          --! 転送オペレーションコードの最上位ビットの位置を指定す
                          --! る.
                          integer := 121;
        OP_CPRO_LO      : --! @brief Co-Processor Operation Code Low :
                          --! コプロセッサオペレーションコードの最下位ビットの位置を
                          --! 指定する.
                          integer :=  0;
        OP_CPRO_HI      : --! @brief Co-Processor Operation Code High :
                          --! コプロセッサオペレーションコードの最上位ビットの位置を
                          --! 指定する.
                          integer := 121;
        OP_ADDR_LO      : --! @brief Link Operation Code Jump Address Low :
                          --! リンクオペレーション時の次のフェッチアドレスの最下位
                          --! ビットの位置を指定する.
                          integer :=   0;
        OP_ADDR_HI      : --! @brief Link Operation Code Jump Address High :
                          --! リンクオペレーション時の次のフェッチアドレスの最上位
                          --! ビットの位置を指定する.
                          integer :=  63;
        OP_MODE_LO      : --! @brief Link Operation Code Mode Low :
                          --! リンクオペレーション時の Mode Field の最下位ビットの
                          --! 位置を指定する.
                          integer :=  64;
        OP_MODE_HI      : --! @brief Link Operation Code Mode High :
                          --! リンクオペレーション時の Mode Field の最上位ビットの
                          --! 位置を指定する.
                          integer := 111;
        OP_STAT_LO      : --! @brief Link Operation Code Status Low :
                          --! リンクオペレーション時の Status Field の最下位ビット
                          --! の位置を指定する.
                          integer := 112;
        OP_STAT_HI      : --! @brief Link Operation Code Status High :
                          --! リンクオペレーション時の Status Field の最上位ビット
                          --! の位置を指定する.
                          integer := 119;
        OP_FETCH_POS    : --! @brief Operation Fetch Code Posigion :
                          --! オペレーションコードをフェッチした時に割り込みを通知
                          --! することを示すビットの位置を指定する.
                          integer := 122;
        OP_END_POS      : --! @brief Operation End Code Posigion :
                          --! 最後のオペレーションコードであることを示すビットの位
                          --! 置を指定する.
                          integer := 123;
        OP_TYPE_LO      : --! @brief Operation Type Low :
                          --! オペレーションのタイプを示すフィールドの最下位ビット
                          --! の位置を指定する.
                          integer := 124;
        OP_TYPE_HI      : --! @brief Operation Type High :
                          --! オペレーションのタイプを示すフィールドの最上位ビット
                          --! の位置を指定する.
                          integer := 127;
        OP_NONE_CODE    : --! @brief None Operation Type :
                          --! ノーオペレーションタイプのコードを指定する.
                          integer := 0;
        OP_CPRO_CODE    : --! @brief Co-Pocesser Set Operation Type :
                          --! コプロセッサオペレーションタイプのコードを指定する.
                          --! ただし OP_CPRO_CODE<0を指定した場合はこの機能は無効.
                          integer := 11;
        OP_XFER_CODE    : --! @brief Transfer Operation Type :
                          --! 転送オペレーションタイプのコードを指定する.
                          integer := 12;
        OP_LINK_CODE    : --! @brief Transfer Operation Type :
                          --! リンクオペレーションタイプのコードを指定する.
                          --! ただし OP_LINE_CODE<0を指定した場合はこの機能は無効.
                          integer := 13
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : in  std_logic; 
        RST             : in  std_logic;
        CLR             : in  std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch Interface Signals.
    -------------------------------------------------------------------------------
        M_REQ_VALID     : out std_logic;
        M_REQ_ADDR      : out std_logic_vector(M_ADDR_BITS-1        downto 0);
        M_REQ_SIZE      : out std_logic_vector(M_BUF_SIZE           downto 0);
        M_REQ_PTR       : out std_logic_vector(M_BUF_SIZE -1        downto 0);
        M_REQ_FIRST     : out std_logic;
        M_REQ_LAST      : out std_logic;
        M_REQ_READY     : in  std_logic;
        M_ACK_VALID     : in  std_logic;
        M_ACK_ERROR     : in  std_logic;
        M_ACK_NEXT      : in  std_logic;
        M_ACK_LAST      : in  std_logic;
        M_ACK_STOP      : in  std_logic;
        M_ACK_NONE      : in  std_logic;
        M_ACK_SIZE      : in  std_logic_vector(M_BUF_SIZE           downto 0);
        M_XFER_BUSY     : in  std_logic;
        M_XFER_DONE     : in  std_logic;
        M_XFER_ERROR    : in  std_logic := '0';
        M_BUF_WE        : in  std_logic;
        M_BUF_BEN       : in  std_logic_vector(2**(M_BUF_WIDTH-3)-1 downto 0);
        M_BUF_DATA      : in  std_logic_vector(2**(M_BUF_WIDTH  )-1 downto 0);
        M_BUF_PTR       : in  std_logic_vector(M_BUF_SIZE        -1 downto 0);
        M_BUF_RDY       : out std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register Interface Signals.
    -------------------------------------------------------------------------------
        T_ADDR_L        : in  std_logic_vector(OP_ADDR_HI downto OP_ADDR_LO);
        T_ADDR_D        : in  std_logic_vector(OP_ADDR_HI downto OP_ADDR_LO);
        T_ADDR_Q        : out std_logic_vector(OP_ADDR_HI downto OP_ADDR_LO);
        T_MODE_L        : in  std_logic_vector(OP_MODE_HI downto OP_MODE_LO);
        T_MODE_D        : in  std_logic_vector(OP_MODE_HI downto OP_MODE_LO);
        T_MODE_Q        : out std_logic_vector(OP_MODE_HI downto OP_MODE_LO);
        T_STAT_L        : in  std_logic_vector(OP_STAT_HI downto OP_STAT_LO);
        T_STAT_D        : in  std_logic_vector(OP_STAT_HI downto OP_STAT_LO);
        T_STAT_Q        : out std_logic_vector(OP_STAT_HI downto OP_STAT_LO);
        T_STAT_I        : in  std_logic_vector(OP_STAT_HI downto OP_STAT_LO);
        T_RESET_L       : in  std_logic;
        T_RESET_D       : in  std_logic;
        T_RESET_Q       : out std_logic;
        T_START_L       : in  std_logic;
        T_START_D       : in  std_logic;
        T_START_Q       : out std_logic;
        T_STOP_L        : in  std_logic;
        T_STOP_D        : in  std_logic;
        T_STOP_Q        : out std_logic;
        T_PAUSE_L       : in  std_logic;
        T_PAUSE_D       : in  std_logic;
        T_PAUSE_Q       : out std_logic;
        T_BUSY          : out std_logic;
        T_ERROR         : out std_logic_vector(2 downto 0);
        T_FETCH         : out std_logic;
        T_DONE          : out std_logic;
    -------------------------------------------------------------------------------
    -- Co-Processer Interface Signals.
    -------------------------------------------------------------------------------
        C_OPERAND_L     : out std_logic_vector(OP_CPRO_HI downto OP_CPRO_LO);
        C_OPERAND_D     : out std_logic_vector(OP_CPRO_HI downto OP_CPRO_LO);
        C_REQ           : out std_logic;
        C_ACK           : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Transfer Control Register Interface Signals.
    -------------------------------------------------------------------------------
        X_RESET_L       : out std_logic;
        X_RESET_D       : out std_logic;
        X_RESET_Q       : in  std_logic;
        X_START_L       : out std_logic;
        X_START_D       : out std_logic;
        X_START_Q       : in  std_logic;
        X_STOP_L        : out std_logic;
        X_STOP_D        : out std_logic;
        X_STOP_Q        : in  std_logic;
        X_PAUSE_L       : out std_logic;
        X_PAUSE_D       : out std_logic;
        X_PAUSE_Q       : in  std_logic;
        X_OPERAND_L     : out std_logic_vector(OP_XFER_HI downto OP_XFER_LO);
        X_OPERAND_D     : out std_logic_vector(OP_XFER_HI downto OP_XFER_LO);
        X_OPERAND_Q     : in  std_logic_vector(OP_XFER_HI downto OP_XFER_LO);
        X_RUN           : in  std_logic;
        X_DONE          : in  std_logic;
        X_ERROR         : in  std_logic
    );
end PUMP_OPERATION_PROCESSOR;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.QUEUE_REGISTER;
use     PIPEWORK.COMPONENTS.COUNT_UP_REGISTER;
use     PIPEWORK.COMPONENTS.COUNT_DOWN_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROL_REGISTER;
architecture RTL of PUMP_OPERATION_PROCESSOR is
    -------------------------------------------------------------------------------
    -- Operation Code のバイト数を示す.
    -------------------------------------------------------------------------------
    constant OP_CODE_BYTES      : integer := (OP_BITS+7)/8;
    -------------------------------------------------------------------------------
    -- Control/Status Register Bit
    -------------------------------------------------------------------------------
    signal   reset_bit          : std_logic;
    signal   start_bit          : std_logic;
    signal   pause_bit          : std_logic;
    signal   stop_bit           : std_logic;
    signal   fetch_bit          : std_logic;
    signal   error_bits         : std_logic_vector(2 downto 0);
    constant NO_ERROR           : std_logic_vector(2 downto 0) := (others => '0');
    signal   mode_load          : std_logic_vector(OP_MODE_HI downto OP_MODE_LO);
    signal   mode_data          : std_logic_vector(OP_MODE_HI downto OP_MODE_LO);
    signal   mode_regs          : std_logic_vector(OP_MODE_HI downto OP_MODE_LO);
    signal   stat_load          : std_logic_vector(OP_STAT_HI downto OP_STAT_LO);
    signal   stat_data          : std_logic_vector(OP_STAT_HI downto OP_STAT_LO);
    signal   stat_regs          : std_logic_vector(OP_STAT_HI downto OP_STAT_LO);
    -------------------------------------------------------------------------------
    -- Operation Code Fetch Signals.
    -------------------------------------------------------------------------------
    signal   m_addr_load        : std_logic_vector(OP_ADDR_HI downto OP_ADDR_LO);
    signal   m_addr_data        : std_logic_vector(OP_ADDR_HI downto OP_ADDR_LO);
    constant m_addr_up_ben      : std_logic_vector(M_ADDR_BITS-1 downto 0) := (others => '1');
    signal   m_size_load        : std_logic_vector(M_BUF_SIZE    downto 0);
    constant m_size_data        : std_logic_vector(M_BUF_SIZE    downto 0) :=
                                  std_logic_vector(to_unsigned(OP_CODE_BYTES, M_BUF_SIZE+1));
    signal   m_buf_ptr_load     : std_logic_vector(M_BUF_SIZE-1 downto 0);
    constant m_buf_ptr_data     : std_logic_vector(M_BUF_SIZE-1 downto 0) := (others => '0');
    constant m_buf_ptr_up_ben   : std_logic_vector(M_BUF_SIZE-1 downto 0) := (others => '1');
    signal   m_start            : std_logic;
    signal   m_start_load       : std_logic;
    signal   m_done_load        : std_logic;
    signal   m_stop             : std_logic;
    signal   m_done             : std_logic;
    signal   m_error            : std_logic;
    signal   m_running          : std_logic;
    constant m_first            : std_logic := '1';
    constant m_last             : std_logic := '1';
    constant m_start_data       : std_logic := '1';
    constant m_done_en_data     : std_logic := '1';
    constant m_done_st_data     : std_logic := '0';
    constant m_err_st_data      : std_logic := '0';
    -------------------------------------------------------------------------------
    -- State Machine
    -------------------------------------------------------------------------------
    type     STATE_TYPE     is  ( IDLE_STATE   ,
                                  M_START_STATE,
                                  M_RUN_STATE  ,
                                  X_START_STATE,
                                  X_DONE_STATE ,
                                  DECODE_STATE ,
                                  CO_PRO_STATE ,
                                  STOP_STATE   ,
                                  DONE_STATE   );
    signal   curr_state         : STATE_TYPE;
    -------------------------------------------------------------------------------
    -- Operation Code
    -------------------------------------------------------------------------------
    signal   op_code            : std_logic_vector(OP_BITS-1 downto 0);
    signal   op_valid           : std_logic;
    signal   op_shift           : std_logic;
    signal   op_type            : std_logic_vector(OP_TYPE_HI downto OP_TYPE_LO);
    function OP_EQ(OP_TYPE: std_logic_vector;OP_CODE:integer) return boolean is
    begin
        if (OP_CODE >= 0) then
            return (to_01(unsigned(OP_TYPE),'0') = OP_CODE);
        else
            return FALSE;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- Control Signals.
    -------------------------------------------------------------------------------
    signal   stop_request       : boolean;
    signal   op_decode          : boolean;
    signal   op_start           : boolean;
    signal   link_start         : boolean;
    signal   xfer_start         : boolean;
    signal   cpro_request       : boolean;
    signal   xfer_last          : std_logic;
begin
    -------------------------------------------------------------------------------
    -- M_REQ_ADDR : Operation Code Fetch Address Register.
    -------------------------------------------------------------------------------
    M_REQ_ADDR_REGS: COUNT_UP_REGISTER           -- 
        generic map (                            -- 
            VALID           => 1               , -- 
            BITS            => M_ADDR_BITS     , -- 
            REGS_BITS       => T_ADDR_Q'length   -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            REGS_WEN        => m_addr_load     , -- In  :
            REGS_WDATA      => m_addr_data     , -- In  :
            REGS_RDATA      => T_ADDR_Q        , -- Out :
            UP_ENA          => m_running       , -- In  :
            UP_VAL          => M_ACK_VALID     , -- In  :
            UP_BEN          => m_addr_up_ben   , -- In  :
            UP_SIZE         => M_ACK_SIZE      , -- In  :
            COUNTER         => M_REQ_ADDR        -- Out :
        );
    m_addr_load <= (others => '1')                       when (link_start) else T_ADDR_L;
    m_addr_data <= op_code(OP_ADDR_HI downto OP_ADDR_LO) when (link_start) else T_ADDR_D;
    -------------------------------------------------------------------------------
    -- M_REQ_SIZE : Operation Code Fetch Size Counter.
    -------------------------------------------------------------------------------
    M_REQ_SIZE_REGS: COUNT_DOWN_REGISTER         -- 
        generic map (                            -- 
            VALID           => 1               , -- 
            BITS            => M_BUF_SIZE+1    , -- 
            REGS_BITS       => M_BUF_SIZE+1      -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            REGS_WEN        => m_size_load     , -- In  :
            REGS_WDATA      => m_size_data     , -- In  :
            REGS_RDATA      => open            , -- Out :
            DN_ENA          => m_running       , -- In  :
            DN_VAL          => M_ACK_VALID     , -- In  :
            DN_SIZE         => M_ACK_SIZE      , -- In  :
            COUNTER         => M_REQ_SIZE      , -- Out :
            ZERO            => open            , -- Out :
            NEG             => open              -- Out :
       );
    m_size_load <= (others => '1') when (curr_state = M_START_STATE) else (others => '0');
    -------------------------------------------------------------------------------
    -- M_REQ_PTR  : Operation Code Fetch Queue Pointer.
    -------------------------------------------------------------------------------
    M_REQ_PTR_REGS: COUNT_UP_REGISTER            -- 
        generic map (                            -- 
            VALID           => 1               , -- 
            BITS            => M_BUF_SIZE      , -- 
            REGS_BITS       => M_BUF_SIZE        -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            REGS_WEN        => m_buf_ptr_load  , -- In  :
            REGS_WDATA      => m_buf_ptr_data  , -- In  :
            REGS_RDATA      => open            , -- Out :
            UP_ENA          => m_running       , -- In  :
            UP_VAL          => M_ACK_VALID     , -- In  :
            UP_BEN          => m_buf_ptr_up_ben, -- In  :
            UP_SIZE         => M_ACK_SIZE      , -- In  :
            COUNTER         => M_REQ_PTR         -- Out :
        );
    m_buf_ptr_load <= (others => '1') when (curr_state = M_START_STATE) else (others => '0');
    -------------------------------------------------------------------------------
    -- M_CTRL_REGS: Operation Code Fetch Control Registers.
    -------------------------------------------------------------------------------
    M_CTRL_REGS: PUMP_CONTROL_REGISTER           -- 
        generic map (                            -- 
            MODE_BITS       => mode_regs'length, -- 
            STAT_BITS       => stat_regs'length  -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            RESET_L         => T_RESET_L       , -- In  :
            RESET_D         => T_RESET_D       , -- In  :
            RESET_Q         => reset_bit       , -- Out :
            START_L         => m_start_load    , -- In  :
            START_D         => m_start_data    , -- In  :
            START_Q         => m_start         , -- Out :
            STOP_L          => T_STOP_L        , -- In  :
            STOP_D          => T_STOP_D        , -- In  :
            STOP_Q          => m_stop          , -- Out :
            PAUSE_L         => T_PAUSE_L       , -- In  :
            PAUSE_D         => T_PAUSE_D       , -- In  :
            PAUSE_Q         => pause_bit       , -- Out :
            FIRST_L         => m_start_load    , -- In  :
            FIRST_D         => m_first         , -- In  :
            FIRST_Q         => open            , -- Out :
            LAST_L          => m_start_load    , -- In  :
            LAST_D          => m_last          , -- In  :
            LAST_Q          => open            , -- Out :
            DONE_EN_L       => m_start_load    , -- In  :
            DONE_EN_D       => m_done_en_data  , -- In  :
            DONE_EN_Q       => open            , -- Out :
            DONE_ST_L       => m_done_load     , -- In  :
            DONE_ST_D       => m_done_st_data  , -- In  :
            DONE_ST_Q       => open            , -- Out :
            ERR_ST_L        => m_done_load     , -- In  :
            ERR_ST_D        => m_err_st_data   , -- In  :
            ERR_ST_Q        => open            , -- Out :
            MODE_L          => mode_load       , -- In  :
            MODE_D          => mode_data       , -- In  :
            MODE_Q          => mode_regs       , -- Out :
            STAT_L          => stat_load       , -- In  :
            STAT_D          => stat_data       , -- In  :
            STAT_Q          => stat_regs       , -- Out :
            STAT_I          => T_STAT_I        , -- In  :
            REQ_VALID       => M_REQ_VALID     , -- Out :
            REQ_FIRST       => M_REQ_FIRST     , -- Out :
            REQ_LAST        => M_REQ_LAST      , -- Out :
            REQ_READY       => M_REQ_READY     , -- In  :
            ACK_VALID       => M_ACK_VALID     , -- In  :
            ACK_ERROR       => M_ACK_ERROR     , -- In  :
            ACK_NEXT        => M_ACK_NEXT      , -- In  :
            ACK_LAST        => M_ACK_LAST      , -- In  :
            ACK_STOP        => M_ACK_STOP      , -- In  :
            ACK_NONE        => M_ACK_NONE      , -- In  :
            XFER_BUSY       => M_XFER_BUSY     , -- In  :
            XFER_DONE       => M_XFER_DONE     , -- In  :
            XFER_ERROR      => M_XFER_ERROR    , -- In  :
            VALVE_OPEN      => open            , -- Out :
            TRAN_DONE       => m_done          , -- Out :
            TRAN_ERROR      => m_error         , -- Out :
            TRAN_BUSY       => m_running         -- Out :
        );
    -------------------------------------------------------------------------------
    -- モードレジスタ入出力
    -------------------------------------------------------------------------------
    process (link_start, op_code, T_MODE_L, T_MODE_D) begin
        if (OP_MODE_LO < OP_BITS and OP_MODE_HI < OP_BITS and link_start = TRUE) then
            mode_load <= (others => '1');
            mode_data <= op_code(OP_MODE_HI downto OP_MODE_LO);
        else
            mode_load <= T_MODE_L;
            mode_data <= T_MODE_D;
        end if;
    end process;
    T_MODE_Q <= mode_regs;
    -------------------------------------------------------------------------------
    -- ステータスレジスタ入出力
    -------------------------------------------------------------------------------
    process (link_start, op_code, T_STAT_L, T_STAT_D) begin
        if (OP_STAT_LO < OP_BITS and OP_STAT_HI < OP_BITS and link_start = TRUE) then
            stat_load <= (others => '1');
            stat_data <= op_code(OP_STAT_HI downto OP_STAT_LO);
        else
            stat_load <= T_STAT_L;
            stat_data <= T_STAT_D;
        end if;
    end process;
    T_STAT_Q <= stat_regs;
    -------------------------------------------------------------------------------
    -- 各種制御ビットとステートマシン
    -------------------------------------------------------------------------------
    process (CLK, RST) 
        variable next_state : STATE_TYPE;
    begin
        if    (RST = '1') then
                curr_state <= IDLE_STATE;
                start_bit  <= '0';
                stop_bit   <= '0';
                xfer_last  <= '0';
                fetch_bit  <= '0';
                op_shift   <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR   = '1') then
                curr_state <= IDLE_STATE;
                start_bit  <= '0';
                stop_bit   <= '0';
                xfer_last  <= '0';
                fetch_bit  <= '0';
                op_shift   <= '0';
            else
                -------------------------------------------------------------------
                -- ステートマシン
                -------------------------------------------------------------------
                case curr_state is
                    ---------------------------------------------------------------
                    -- アイドル状態
                    ---------------------------------------------------------------
                    when IDLE_STATE =>
                        if    (start_bit = '1' and m_running = '0') then
                            next_state := M_START_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                    ---------------------------------------------------------------
                    -- オペレーションコードのフェッチを開始
                    ---------------------------------------------------------------
                    when M_START_STATE =>
                        if    (m_running = '1') then
                            next_state := M_RUN_STATE;
                        else
                            next_state := M_START_STATE;
                        end if;
                    ---------------------------------------------------------------
                    -- オペレーションコードをフェッチ中
                    ---------------------------------------------------------------
                    when M_RUN_STATE =>
                        if    (stop_request) then
                            next_state := STOP_STATE;
                        elsif (m_running = '0') then
                            next_state := DECODE_STATE;
                        else
                            next_state := M_RUN_STATE;
                        end if;
                    ---------------------------------------------------------------
                    -- オペレーションコードのデコード
                    ---------------------------------------------------------------
                    when DECODE_STATE =>
                        if    (stop_request) then
                                next_state := STOP_STATE;
                        elsif (op_valid = '0') then
                                next_state := DECODE_STATE;
                        elsif (OP_EQ(op_type, OP_XFER_CODE) = TRUE) then
                            if (X_RUN = '1') then
                                next_state := DECODE_STATE;
                            else
                                next_state := X_START_STATE;
                            end if;
                        elsif (OP_EQ(op_type, OP_CPRO_CODE) = TRUE) then
                            if (X_RUN = '1') then
                                next_state := DECODE_STATE;
                            else
                                next_state := CO_PRO_STATE;
                            end if;
                        elsif (OP_EQ(op_type, OP_NONE_CODE) = TRUE) or
                              (OP_EQ(op_type, OP_LINK_CODE) = TRUE) then
                            if (op_code(OP_END_POS) = '1') then
                                next_state := X_DONE_STATE;
                            else
                                next_state := M_START_STATE;
                            end if;
                        else
                                next_state := X_DONE_STATE;
                        end if;
                    ---------------------------------------------------------------
                    -- コプロッセッサーオペレーション実行中
                    ---------------------------------------------------------------
                    when CO_PRO_STATE =>
                        if    (OP_CPRO_CODE < 0) then
                                next_state := IDLE_STATE;
                        elsif (C_ACK = '1') then
                            if (op_code(OP_END_POS) = '1') then
                                next_state := X_DONE_STATE;
                            else
                                next_state := M_START_STATE;
                            end if;
                        else
                                next_state := CO_PRO_STATE;
                        end if;
                    ---------------------------------------------------------------
                    -- 転送オペレーション実行中
                    ---------------------------------------------------------------
                    when X_START_STATE =>
                        if    (stop_request) then
                            next_state := STOP_STATE;
                        elsif (X_RUN     = '0') then
                            next_state := X_START_STATE;
                        elsif (xfer_last = '1') then
                            next_state := X_DONE_STATE;
                        else
                            next_state := M_START_STATE;
                        end if;
                    ---------------------------------------------------------------
                    -- 転送オペレーション終了処理またはオペレーション停止処理中
                    ---------------------------------------------------------------
                    when X_DONE_STATE | STOP_STATE => 
                        if    (X_RUN = '0') then
                            next_state := DONE_STATE;
                        else
                            next_state := curr_state;
                        end if;
                    ---------------------------------------------------------------
                    -- オペレーション終了処理
                    ---------------------------------------------------------------
                    when DONE_STATE =>
                            next_state := IDLE_STATE;
                    ---------------------------------------------------------------
                    -- その他
                    ---------------------------------------------------------------
                    when others =>
                            next_state := IDLE_STATE;
                end case;
                -------------------------------------------------------------------
                -- 現在の状態
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    curr_state <= IDLE_STATE;
                else
                    curr_state <= next_state;
                end if;
                -------------------------------------------------------------------
                -- START BIT :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    start_bit <= '0';
                elsif (T_START_L = '1' and T_START_D = '1') then
                    start_bit <= '1';
                elsif (next_state = DONE_STATE) then
                    start_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- STOP BIT  :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    stop_bit  <= '0';
                elsif (T_STOP_L  = '1' and T_STOP_D  = '1') then
                    stop_bit  <= '1';
                elsif (next_state = DONE_STATE) then
                    stop_bit  <= '0';
                end if;
                -------------------------------------------------------------------
                -- xfer_last : 最後のトランザクションであることを示す.
                -------------------------------------------------------------------
                if   (op_decode and OP_EQ(op_type, OP_XFER_CODE)) then
                    xfer_last <= op_code(OP_END_POS);
                elsif(curr_state = IDLE_STATE or curr_state = DONE_STATE) then
                    xfer_last <= '0';
                end if;
                -------------------------------------------------------------------
                -- op_shift  : キューからデコード済みのコードを破棄する.
                -------------------------------------------------------------------
                if   (curr_state = DECODE_STATE and next_state /= DECODE_STATE and next_state /= CO_PRO_STATE) or
                     (curr_state = CO_PRO_STATE and next_state /= CO_PRO_STATE) then
                    op_shift  <= '1';
                else
                    op_shift  <= '0';
                end if;
                -------------------------------------------------------------------
                -- FETCH BIT :
                -------------------------------------------------------------------
                if   (op_decode and OP_FETCH_POS < OP_BITS) then
                    fetch_bit <= op_code(OP_FETCH_POS);
                else
                    fetch_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- ERROR(0)  :
                -------------------------------------------------------------------
                if (op_decode = TRUE) and
                   (OP_EQ(op_type, OP_NONE_CODE) = FALSE) and 
                   (OP_EQ(op_type, OP_CPRO_CODE) = FALSE) and 
                   (OP_EQ(op_type, OP_XFER_CODE) = FALSE) and 
                   (OP_EQ(op_type, OP_LINK_CODE) = FALSE) then
                    error_bits(0) <= '1';
                elsif(curr_state = IDLE_STATE or curr_state = DONE_STATE) then
                    error_bits(0) <= '0';
                end if;
                -------------------------------------------------------------------
                -- ERROR(1)  :
                -------------------------------------------------------------------
                if   (m_error = '1') then
                    error_bits(1) <= '1';
                elsif(curr_state = IDLE_STATE or curr_state = DONE_STATE) then
                    error_bits(1) <= '0';
                end if;
                -------------------------------------------------------------------
                -- ERROR(2)  :
                -------------------------------------------------------------------
                if   (X_ERROR = '1') then
                    error_bits(2) <= '1';
                elsif(curr_state = IDLE_STATE or curr_state = DONE_STATE) then
                    error_bits(2) <= '0';
                end if;
            end if;
        end if;     
    end process;
    -------------------------------------------------------------------------------
    -- m_start_load : オペレーションフェッチ開始時に各種レジスタを設定するための信号
    -- m_done_load  : オペレーション終了時にステータスレジスタをクリアするための信号
    -------------------------------------------------------------------------------
    m_start_load <= '1' when (curr_state = M_START_STATE) else '0';
    m_done_load  <= '1' when (curr_state = M_START_STATE or
                              curr_state = DONE_STATE   ) else '0';
    -------------------------------------------------------------------------------
    -- stop_request : オペレーションの中止を指示する信号
    -------------------------------------------------------------------------------
    stop_request <= (stop_bit = '1' or error_bits /= NO_ERROR);
    -------------------------------------------------------------------------------
    -- link_start   : リンクオペレーションの開始を指示する信号
    -- xfer_start   : 転送オペレーションの開始を指示する信号
    -------------------------------------------------------------------------------
    link_start   <= (op_start and OP_EQ(op_type, OP_LINK_CODE));
    xfer_start   <= (op_start and OP_EQ(op_type, OP_XFER_CODE) and X_RUN = '0');
    -------------------------------------------------------------------------------
    -- Control Status Register Output Signals.
    -------------------------------------------------------------------------------
    T_RESET_Q    <= reset_bit;
    T_START_Q    <= start_bit;
    T_STOP_Q     <= stop_bit;
    T_PAUSE_Q    <= pause_bit;
    T_FETCH      <= fetch_bit;
    T_BUSY       <= '1'        when (curr_state /= IDLE_STATE) else '0';
    T_DONE       <= '1'        when (curr_state  = DONE_STATE) else '0';
    T_ERROR      <= error_bits when (curr_state  = DONE_STATE) else (others => '0');
    -------------------------------------------------------------------------------
    -- op_code  : キューの先頭にあるオペコード.
    -- op_valid : 有効なオペコードがキューに入っていることを示すフラグ.
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable lo_ptr : unsigned(M_BUF_SIZE downto 0);
        variable hi_ptr : unsigned(M_BUF_SIZE downto 0);
        variable valid  : std_logic_vector(op_code'range);
    begin
        if    (RST = '1') then
                op_code  <= (others => '0');
                op_valid <= '0';
        elsif (CLK'event and CLK = '1') then
            if    (CLR   = '1' or reset_bit = '1') then
                op_code  <= (others => '0');
                op_valid <= '0';
            -----------------------------------------------------------------------
            -- M_BUF_WE 信号によりオペレーションコードがキューに取り込まれる.
            -----------------------------------------------------------------------
            elsif (M_BUF_WE = '1') then
                for i in lo_ptr'range loop
                    if (i < M_BUF_SIZE) then
                        if (i >= M_BUF_WIDTH-3) then
                            lo_ptr(i) := M_BUF_PTR(i);
                            hi_ptr(i) := M_BUF_PTR(i);
                        else
                            lo_ptr(i) := '0';
                            hi_ptr(i) := '1';
                        end if;
                    else
                            lo_ptr(i) := '0';
                            hi_ptr(i) := '0';
                    end if;
                end loop;
                valid := (others => '0');
                for i in op_code 'range loop
                    if (i/8 >= lo_ptr) and (i/8 <= hi_ptr) then
                        if (M_BUF_BEN((i/8) mod 2**(M_BUF_WIDTH-3)) = '1') then
                            op_code(i) <= M_BUF_DATA(i mod 2**(M_BUF_WIDTH));
                            valid(i) := '1';
                        end if;
                    end if;
                end loop;
                if (valid(valid'high) = '1') then
                    op_valid <= '1';
                end if;
            -----------------------------------------------------------------------
            -- op_shift 信号によりキューからデコード済みのコードを破棄する.
            -----------------------------------------------------------------------
            elsif (op_shift = '1') then
                op_valid <= '0';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- op_decode : キューに有効なコードがあり、デコード中である事を示すフラグ
    -- op_type   : キューの先頭にあるコードの、オペレーションのタイプを示す.
    -------------------------------------------------------------------------------
    op_decode    <= (curr_state = DECODE_STATE and op_valid = '1');
    op_start     <= (op_decode and stop_request = FALSE);
    op_type      <= op_code(OP_TYPE_HI downto OP_TYPE_LO);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    M_BUF_RDY    <= '1';
    -------------------------------------------------------------------------------
    -- 転送オペレーション要求信号出力
    -------------------------------------------------------------------------------
    X_OPERAND_L  <= (others => '1') when (xfer_start) else (others => '0');
    X_OPERAND_D  <= op_code(OP_XFER_HI downto OP_XFER_LO);
    X_START_L    <= '1' when (xfer_start) else '0';
    X_START_D    <= '1' when (xfer_start) else '0';
    X_STOP_L     <= T_STOP_L;
    X_STOP_D     <= T_STOP_D;
    X_RESET_L    <= T_RESET_L;
    X_RESET_D    <= T_RESET_D;
    X_PAUSE_L    <= T_PAUSE_L;
    X_PAUSE_D    <= T_PAUSE_D;
    -------------------------------------------------------------------------------
    -- コプロセッサオペレーション要求信号出力
    -------------------------------------------------------------------------------
    cpro_request <= (curr_state = CO_PRO_STATE and OP_CPRO_CODE >= 0);
    C_REQ        <= '1'             when (cpro_request) else '0';
    C_OPERAND_L  <= (others => '1') when (cpro_request) else (others => '0');
    C_OPERAND_D  <= op_code(OP_CPRO_HI downto OP_CPRO_LO);
end RTL;
