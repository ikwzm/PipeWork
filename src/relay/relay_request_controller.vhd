-----------------------------------------------------------------------------------
--!     @file    relay_request_controller.vhd
--!     @brief   RELAY REQUEST CONTROLLER
--!              Relay の Requester側 の制御回路.
--!     @version 0.0.1
--!     @date    2013/3/14
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
--! @brief   RELAY REQUEST CONTROLLER
-----------------------------------------------------------------------------------
entity  RELAY_REQUEST_CONTROLLER is
    generic (
        ADDR_BITS       : --! @brief Request Address Bits :
                          --! REQ_ADDR信号のビット数を指定する.
                          integer := 32;
        ADDR_VALID      : --! @brief Request Address Valid :
                          --! REQ_ADDR信号を有効にするかどうかを指定する.
                          --! * ADDR_VALID=0で無効.
                          --! * ADDR_VALID>0で有効.
                          integer :=  1;
        SIZE_BITS       : --! @brief Transfer Size Bits :
                          --! REQ_SIZE/ACK_SIZE信号のビット数を指定する.
                          integer := 32;
        SIZE_VALID      : --! @brief Request Size Valid :
                          --! REQ_SIZE信号を有効にするかどうかを指定する.
                          --! * SIZE_VALID=0で無効.
                          --! * SIZE_VALID>0で有効.
                          integer :=  1;
        MODE_BITS       : --! @brief Request Mode Bits :
                          --! REQ_MODE信号のビット数を指定する.
                          integer := 32;
        BUF_DEPTH       : --! @brief BUFFER DEPTH :
                          --! バッファの容量(バイト数)を２のべき乗値で指定する.
                          integer := 12;
        XFER_MAX_SIZE   : --! @brief TRANSFER MAXIMUM SIZE :
                          --! 一回の転送サイズの最大バイト数を２のべき乗で指定する.
                          integer := 4
    );
    port (
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- Command Request Signals.
    -------------------------------------------------------------------------------
        M_REQ_ADDR      : --! @brief Request Address.
                          --! 転送開始アドレスを出力する.  
                          out   std_logic_vector(ADDR_BITS-1 downto 0);
        M_REQ_SIZE      : --! @brief Request Transfer Size.
                          --! 転送したいバイト数を出力する. 
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
        M_REQ_BUF_PTR   : --! @brief Request Buffer Pointer.
                          --! 転送時のバッファポインタを出力する.
                          out   std_logic_vector(BUF_DEPTH-1 downto 0);
        M_REQ_MODE      : --! @brief Request Mode Signals.
                          --! 転送開始時に指定された各種情報を出力する.
                          out   std_logic_vector(MODE_BITS-1 downto 0);
        M_REQ_FIRST     : --! @brief Request First Transaction.
                          --! 最初のトランザクションであることを示す.
                          --! * REQ_FIRST=1の場合、内部状態を初期化してからトランザ
                          --!   クションを開始する.
                          out   std_logic;
        M_REQ_LAST      : --! @brief Request Last Transaction.
                          --! 最後のトランザクションであることを示す.
                          --! * REQ_LAST=1の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_LAST 信号をア
                          --!   サートする.
                          --! * REQ_LAST=0の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_NEXT 信号をア
                          --!   サートする.
                          out   std_logic;
        M_REQ_VALID     : --! @brief Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          out   std_logic;
        M_REQ_READY     : --! @brief Request Ready Signal.
                          --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        M_ACK_VALID     : --! @brief Acknowledge Valid Signal.
                          --! 上記の Command Request の応答信号.
                          --! 下記の 各種 Acknowledge 信号が有効である事を示す.
                          --! * この信号のアサートでもって、Command Request が受け
                          --!   付けられたことを示す. ただし、あくまでも Request が
                          --!   受け付けられただけであって、必ずしもトランザクショ
                          --!   ンが完了したわけではないことに注意.
                          --! * この信号は Request につき１クロックだけアサートされ
                          --!   る.
                          --! * この信号がアサートされたら、アプリケーション側は速
                          --!   やかに REQ_VAL 信号をネゲートして Request を取り下
                          --!   げるか、REQ_VALをアサートしたままで次の Request 情
                          --!   報を用意しておかなければならない.
                          in    std_logic;
        M_ACK_NEXT      : --! @brief Acknowledge with need Next transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=0 の場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        M_ACK_LAST      : --! @brief Acknowledge with Last transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=1 の場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        M_ACK_ERROR     : --! @brief Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        M_ACK_STOP      : --! @brief Acknowledge with Stop operation.
                          --! トランザクションが中止された場合、この信号がアサート
                          --! される.
                          in    std_logic;
        M_ACK_NONE      : --! @brief Acknowledge with None Request transfer size.
                          --! REQ_SIZE=0 の Request だった場合、この信号がアサート
                          --! される.
                          in    std_logic;
        M_ACK_SIZE      : --! @brief Acknowledge transfer size.
                          --! 転送するバイト数を示す.
                          --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で示さ
                          --! れるバイト数分を加算/減算すると良い.
                          in    std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
        T_REQ_ADDR      : --! @brief Request Address.
                          --! 転送開始アドレスを入力する.  
                          in    std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE      : --! @brief Request Transfer Size.
                          --! 転送したいバイト数を入力する. 
                          in    std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR   : --! @brief Request Buffer Pointer.
                          --! 転送時のバッファポインタを入力する.
                          in    std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE      : --! @brief Request Mode Signals.
                          --! 転送開始時に指定された各種情報を入力する.
                          in    std_logic_vector(MODE_BITS-1 downto 0);
        T_REQ_VALID     : --! @brief Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          in    std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
        T_START         : --! @brief Request Start Signal.
                          --! 転送を開始したことを示す出力信号.
                          out   std_logic;
        T_DONE          : --! @brief Transaction Done Signal.
                          --! 転送を終了したことを示す出力信号.
                          out   std_logic;
        T_ERROR         : --! @brief Transaction Error Signal.
                          --! 転送を異常終了したことを示す出力信号.
                          out   std_logic;
        VALVE_OPEN      : --!  @brief Valve Open Signal.
                          out   std_logic

    );
end RELAY_REQUEST_CONTROLLER;
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
architecture RTL of RELAY_REQUEST_CONTROLLER is
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal   addr_load          : std_logic_vector(ADDR_BITS-1 downto 0);
    function ADDR_UP_BEN return std_logic_vector is
        variable up_ben    : std_logic_vector(ADDR_BITS-1 downto 0);
    begin
        for i in up_ben'range loop
            if (i <= XFER_MAX_SIZE) then
                up_ben(i) := '1';
            else
                up_ben(i) := '0';
            end if;
        end loop;
        return up_ben;
    end function;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal   size_load          : std_logic_vector(SIZE_BITS-1 downto 0);
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal   buf_ptr_load       : std_logic_vector(BUF_DEPTH-1 downto 0);
    constant buf_ptr_up         : std_logic_vector(BUF_DEPTH-1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   mode_load          : std_logic_vector(MODE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant STAT_BITS          : integer := 1;
    signal   stat_load          : std_logic_vector(STAT_BITS-1 downto 0);
    constant stat_all0          : std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
    signal   stat_i             : std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
    signal   stat_o             : std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant reset_load         : std_logic := '0';
    constant reset_data         : std_logic := '0';
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant stop_load          : std_logic := '0';
    constant stop_data          : std_logic := '0';
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant pause_load         : std_logic := '0';
    constant pause_data         : std_logic := '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant start_data         : std_logic := '1';
    constant first_data         : std_logic := '1';
    constant last_data          : std_logic := '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   xfer_running       : std_logic;
begin
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    ADDR_REGS: PUMP_COUNT_UP_REGISTER            -- 
        generic map (                            -- 
            VALID           => ADDR_VALID      , -- 
            BITS            => ADDR_BITS       , -- 
            REGS_BITS       => ADDR_BITS         -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            REGS_WEN        => addr_load       , -- In  :
            REGS_WDATA      => T_REQ_ADDR      , -- In  :
            REGS_RDATA      => open            , -- Out :
            UP_ENA          => xfer_running    , -- In  :
            UP_VAL          => M_ACK_VALID     , -- In  :
            UP_BEN          => ADDR_UP_BEN     , -- In  :
            UP_SIZE         => M_ACK_SIZE      , -- In  :
            COUNTER         => M_REQ_ADDR        -- Out :
        );
    addr_load   <= (others => '1') when (T_REQ_VALID = '1') else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    SIZE_REGS: PUMP_COUNT_DOWN_REGISTER          -- 
        generic map (                            -- 
            VALID           => SIZE_VALID      , -- 
            BITS            => SIZE_BITS       , -- 
            REGS_BITS       => SIZE_BITS         -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            REGS_WEN        => size_load       , -- In  :
            REGS_WDATA      => T_REQ_SIZE      , -- In  :
            REGS_RDATA      => open            , -- Out :
            DN_ENA          => xfer_running    , -- In  :
            DN_VAL          => M_ACK_VALID     , -- In  :
            DN_SIZE         => M_ACK_SIZE      , -- In  :
            COUNTER         => M_REQ_SIZE      , -- Out :
            ZERO            => open            , -- Out :
            NEG             => open              -- Out :
       );
    size_load <= (others => '1') when (T_REQ_VALID = '1') else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    BUF_PTR: PUMP_COUNT_UP_REGISTER              -- 
        generic map (                            -- 
            VALID           => 1               , -- 
            BITS            => BUF_DEPTH       , --
            REGS_BITS       => BUF_DEPTH         -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            REGS_WEN        => buf_ptr_load    , -- In  :
            REGS_WDATA      => T_REQ_BUF_PTR   , -- In  :
            REGS_RDATA      => open            , -- Out :
            UP_ENA          => xfer_running    , -- In  :
            UP_VAL          => M_ACK_VALID     , -- In  :
            UP_BEN          => buf_ptr_up      , -- In  :
            UP_SIZE         => M_ACK_SIZE      , -- In  :
            COUNTER         => M_REQ_BUF_PTR     -- Out :
       );
    buf_ptr_load <= (others => '1') when (T_REQ_VALID = '1') else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    CTRL_REGS: PUMP_CONTROL_REGISTER             -- 
        generic map (                            -- 
            MODE_BITS       => MODE_BITS       , -- 
            STAT_BITS       => STAT_BITS         -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            RESET_L         => reset_load      , -- In  :
            RESET_D         => reset_data      , -- In  :
            RESET_Q         => open            , -- Out :
            START_L         => T_REQ_VALID     , -- In  :
            START_D         => start_data      , -- In  :
            START_Q         => open            , -- Out :
            STOP_L          => stop_load       , -- In  :
            STOP_D          => stop_data       , -- In  :
            STOP_Q          => open            , -- Out :
            PAUSE_L         => pause_load      , -- In  :
            PAUSE_D         => pause_data      , -- In  :
            PAUSE_Q         => open            , -- Out :
            FIRST_L         => T_REQ_VALID     , -- In  :
            FIRST_D         => first_data      , -- In  :
            FIRST_Q         => open            , -- Out :
            LAST_L          => T_REQ_VALID     , -- In  :
            LAST_D          => last_data       , -- In  :
            LAST_Q          => open            , -- Out :
            DONE_EN_L       => T_REQ_VALID     , -- In  :
            DONE_EN_D       => stat_all0(0)    , -- In  :
            DONE_EN_Q       => open            , -- Out :
            DONE_ST_L       => T_REQ_VALID     , -- In  :
            DONE_ST_D       => stat_all0(0)    , -- In  :
            DONE_ST_Q       => open            , -- Out :
            ERR_ST_L        => T_REQ_VALID     , -- In  :
            ERR_ST_D        => stat_all0(0)    , -- In  :
            ERR_ST_Q        => open            , -- Out :
            MODE_L          => mode_load       , -- In  :
            MODE_D          => T_REQ_MODE      , -- In  :
            MODE_Q          => M_REQ_MODE      , -- Out :
            STAT_L          => stat_load       , -- In  :
            STAT_D          => stat_all0       , -- In  :
            STAT_Q          => stat_o          , -- Out :
            STAT_I          => stat_i          , -- In  :
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
            VALVE_OPEN      => VALVE_OPEN      , -- Out :
            XFER_DONE       => T_DONE          , -- Out :
            XFER_ERROR      => T_ERROR         , -- Out :
            XFER_RUNNING    => xfer_running      -- Out :
        );
    mode_load <= (others => '1') when (T_REQ_VALID = '1') else (others => '0');
    stat_load <= (others => '1') when (T_REQ_VALID = '1') else (others => '0');
    stat_i    <= (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    T_START   <= T_REQ_VALID;
end RTL;
