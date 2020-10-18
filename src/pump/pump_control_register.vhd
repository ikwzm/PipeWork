-----------------------------------------------------------------------------------
--!     @file    pump_control_register.vhd
--!     @brief   PUMP CONTROL REGISTER
--!     @version 1.8.3
--!     @date    2020/10/18
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
--! @brief   PUMP CONTROL REGISTER :
-----------------------------------------------------------------------------------
entity  PUMP_CONTROL_REGISTER is
    generic (
        MODE_BITS       : --! @brief MODE REGISTER BITS :
                          --! モードレジスタのビット数を指定する.
                          integer := 32;
        STAT_BITS       : --! @brief STATUS REGISTER BITS :
                          --! ステータスレジスタのビット数を指定する.
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
        RESET_L         : in  std_logic := '0';
        RESET_D         : in  std_logic := '0';
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
        START_L         : in  std_logic := '0';
        START_D         : in  std_logic := '0';
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
        STOP_L          : in  std_logic := '0';
        STOP_D          : in  std_logic := '0';
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
        PAUSE_L         : in  std_logic := '0';
        PAUSE_D         : in  std_logic := '0';
        PAUSE_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- FIRST Bit        : 最初の転送であるか否かを指示する.
    -------------------------------------------------------------------------------
    -- * FIRST_L='1' and FIRST_D='1' で最初の転送であることを指示する.
    -- * FIRST_L='1' and FIRST_D='0' で最初の転送でないことを指示する.
    -- * FIRST_Q は現在の状態を示す.
    -------------------------------------------------------------------------------
        FIRST_L         : in  std_logic := '0';
        FIRST_D         : in  std_logic := '0';
        FIRST_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- LAST Bit         : 最後の転送であるか否かを指示する.
    -------------------------------------------------------------------------------
    -- * LAST_L='1' and LAST_D='1' で最後の転送であることを指示する.
    -- * LAST_L='1' and LAST_D='0' で最後の転送でないことを指示する.
    -- * LAST_Q は現在の状態を示す.
    -------------------------------------------------------------------------------
        LAST_L          : in  std_logic := '0';
        LAST_D          : in  std_logic := '0';
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
        DONE_EN_L       : in  std_logic := '0';
        DONE_EN_D       : in  std_logic := '0';
        DONE_EN_Q       : out std_logic;
    -------------------------------------------------------------------------------
    -- DONE STatus Bit  : DONE_EN_Q='1'の時、転送終了時にセットされる.
    -------------------------------------------------------------------------------
    -- * DONE_ST_L='1' and DONE_ST_D='0' でこのビットをクリアする.
    -- * DONE_ST_L='1' and DONE_ST_D='1' の場合、このビットに変化は無い.
    -- * DONE_ST_Q='1' は、DONE_EN_Q='1' の時、転送が終了したことを示す.
    -------------------------------------------------------------------------------
        DONE_ST_L       : in  std_logic := '0';
        DONE_ST_D       : in  std_logic := '0';
        DONE_ST_Q       : out std_logic;
    -------------------------------------------------------------------------------
    -- ERRor STatus Bit : 転送中にエラーが発生した時にセットされる.
    -------------------------------------------------------------------------------
    -- * ERR_ST_L='1' and ERR_ST_D='0' でこのビットをクリアする.
    -- * ERR_ST_L='1' and ERR_ST_D='1' の場合、このビットに変化は無い.
    -- * ERR_ST_Q='1' は転送中にエラーが発生したことを示す.
    -------------------------------------------------------------------------------
        ERR_ST_L        : in  std_logic := '0';
        ERR_ST_D        : in  std_logic := '0';
        ERR_ST_Q        : out std_logic;
    -------------------------------------------------------------------------------
    -- MODE Register    : その他のモードレジスタ.
    -------------------------------------------------------------------------------
    -- * MODE_L(x)='1' and MODE_D(x)='1' で MODE_Q(x) に'1'をセット.
    -- * MODE_L(x)='1' and MODE_D(x)='0' で MODE_Q(x) に'0'をセット.
    -------------------------------------------------------------------------------
        MODE_L          : in  std_logic_vector(MODE_BITS-1 downto 0) := (others => '0');
        MODE_D          : in  std_logic_vector(MODE_BITS-1 downto 0) := (others => '0');
        MODE_Q          : out std_logic_vector(MODE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- STATus Register  : その他のステータスレジスタ.
    -------------------------------------------------------------------------------
    -- * STAT_L(x)='1' and STAT_D(x)='0' で STAT_Q(x)をクリア.
    -- * STAT_L(x)='1' and STAT_D(x)='1' の場合、STAT_Q(x) に変化は無い.
    -- * STAT_I(x)='1' で STAT_Q(x) に'1'をセット.
    -- * STAT_I(x)='0' の場合、STAT_Q(x) に変化は無い.
    -------------------------------------------------------------------------------
        STAT_L          : in  std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
        STAT_D          : in  std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
        STAT_Q          : out std_logic_vector(STAT_BITS-1 downto 0);
        STAT_I          : in  std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_VALID       : --! @brief Request Valid Signal.
                          --! 下記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          out std_logic;
        REQ_FIRST       : --! @brief Request First Transaction.
                          --! 最初のトランザクションであることを示す.
                          out std_logic;
        REQ_LAST        : --! @brief Request Last Transaction.
                          --! 最後のトランザクションであることを示す.
                          out std_logic;
        REQ_READY       : --! @brief Request Ready Signal.
                          --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VALID       : --! @brief Acknowledge Valid Signal.
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
                          in  std_logic;
        ACK_ERROR       : --! @brief Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          in  std_logic;
        ACK_NEXT        : --! @brief Acknowledge with need Next transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=0 の場合、
                          --! この信号がアサートされる.
                          in  std_logic;
        ACK_LAST        : --! @brief Acknowledge with Last transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=1 の場合、
                          --! この信号がアサートされる.
                          in  std_logic;
        ACK_STOP        : --! @brief Acknowledge with Stop operation.
                          --! トランザクションが中止された場合、この信号がアサート
                          --! される.
                          in  std_logic;
        ACK_NONE        : --! @brief Acknowledge with None Request transfer size.
                          --! REQ_SIZE=0 の Request だった場合、この信号がアサート
                          --! される.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Status Signals.
    -------------------------------------------------------------------------------
        XFER_BUSY       : --! @brief Transfer Busy.
                          --! データ転送中であることを示すフラグ.
                          in  std_logic;
        XFER_ERROR      : --! @brief Transfer Error.
                          --! データの転送中にエラーが発生した事を示す.
                          in  std_logic := '0';
        XFER_DONE       : --! @brief Transfer Done.
                          --! データ転送中かつ、次のクロックで XFER_BUSY がネゲート
                          --! される事を示すフラグ.
                          --! * ただし、XFER_BUSY のネゲート前に 必ずしもこの信号が
                          --!   アサートされるわけでは無い.
                          in std_logic;
    -------------------------------------------------------------------------------
    -- Status.
    -------------------------------------------------------------------------------
        VALVE_OPEN      : --! @brief Valve Open Flag.
                          --! 最初の(REQ_FIRST='1'付き)トランザクション開始時にアサ
                          --! ートされ、最後の(REQ_LAST='1'付き)トランザクション終
                          --! 了時または、トランザクション中にエラーが発生した時に
                          --! ネゲートされる.
                          out std_logic;
        TRAN_START      : --! @brief Transaction Start Flag.
                          --! トランザクションを開始したことを示すフラグ.
                          --! トランザクション開始"の直前"に１クロックだけアサート
                          --! される.
                          out std_logic;
        TRAN_BUSY       : --! @brief Transaction Busy Flag.
                          --! トランザクション中であることを示すフラグ.
                          out std_logic;
        TRAN_DONE       : --! @brief Transaction Done Flag.
                          --! トランザクションが終了したことを示すフラグ.
                          --! トランザクション終了時に１クロックだけアサートされる.
                          out std_logic;
        TRAN_NONE       : --! @brief Transaction None Flag.
                          --! トランザクション中に転送が行われなかったことを示すフラグ.
                          --! トランザクション終了時に１クロックだけアサートされる.
                          out std_logic;
        TRAN_ERROR      : --! @brief Transaction Error Flag.
                          --! トランザクション中にエラーが発生したことを示すフラグ.
                          --! トランザクション終了時に１クロックだけアサートされる.
                          out std_logic
    );
end PUMP_CONTROL_REGISTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of PUMP_CONTROL_REGISTER is
    -------------------------------------------------------------------------------
    -- Register Bits.
    -------------------------------------------------------------------------------
    signal   reset_bit          : std_logic;
    signal   start_bit          : std_logic;
    signal   stop_bit           : std_logic;
    signal   pause_bit          : std_logic;
    signal   first_bit          : std_logic;
    signal   last_bit           : std_logic;
    signal   done_en_bit        : std_logic;
    signal   done_bit           : std_logic;
    signal   none_flag          : std_logic;
    signal   error_bit          : std_logic;
    signal   error_flag         : std_logic;
    signal   request_bit        : std_logic;
    signal   mode_regs          : std_logic_vector(MODE_BITS-1 downto 0);
    signal   stat_regs          : std_logic_vector(STAT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Control Signals.
    -------------------------------------------------------------------------------
    signal   transaction_start  : boolean;
    -------------------------------------------------------------------------------
    -- Main State Machine.
    -------------------------------------------------------------------------------
    type     STATE_TYPE     is  ( IDLE_STATE    ,
                                  REQ_STATE     ,
                                  ACK_STATE     ,
                                  CONTINUE_STATE,
                                  TAR_STATE     ,
                                  DONE_STATE    );
    signal   curr_state         : STATE_TYPE;
    -------------------------------------------------------------------------------
    -- Transaction State Machine.
    -------------------------------------------------------------------------------
    signal   tran_state         : std_logic_vector(2 downto 0);
    constant TRAN_IDLE_STATE    : std_logic_vector(2 downto 0) := "000";
    constant TRAN_FIRST_STATE   : std_logic_vector(2 downto 0) := "111";
    constant TRAN_OTHER_STATE   : std_logic_vector(2 downto 0) := "110";
    constant TRAN_TAR_STATE     : std_logic_vector(2 downto 0) := "100";
    signal   tran_once          : std_logic;
    signal   tran_err           : std_logic;
begin
    -------------------------------------------------------------------------------
    -- transaction_start : トランザクション開始信号.
    -------------------------------------------------------------------------------
    transaction_start <= (curr_state = IDLE_STATE) and
                         (start_bit = '1' or (START_L = '1' and START_D = '1'));
    -------------------------------------------------------------------------------
    -- コントロールステータスレジスタとステートマシン
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
        variable xfer_run   : boolean;
        variable xfer_first : boolean;
        variable error_on   : boolean;
        variable none_on    : boolean;
    begin
        if    (RST = '1') then
                curr_state  <= IDLE_STATE;
                tran_state  <= (others => '0');
                tran_once   <= '0';
                tran_err    <= '0';
                reset_bit   <= '0';
                start_bit   <= '0';
                stop_bit    <= '0';
                pause_bit   <= '0';
                first_bit   <= '0';
                last_bit    <= '0';
                done_en_bit <= '0';
                done_bit    <= '0';
                error_bit   <= '0';
                error_flag  <= '0';
                mode_regs   <= (others => '0');
                stat_regs   <= (others => '0');
                request_bit <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR   = '1') then
                curr_state  <= IDLE_STATE;
                tran_state  <= (others => '0');
                tran_once   <= '0';
                tran_err    <= '0';
                reset_bit   <= '0';
                start_bit   <= '0';
                stop_bit    <= '0';
                pause_bit   <= '0';
                first_bit   <= '0';
                last_bit    <= '0';
                done_en_bit <= '0';
                done_bit    <= '0';
                error_bit   <= '0';
                error_flag  <= '0';
                mode_regs   <= (others => '0');
                stat_regs   <= (others => '0');
                request_bit <= '0';
            else
                -------------------------------------------------------------------
                --
                -------------------------------------------------------------------
                xfer_run := (XFER_BUSY = '1' and XFER_DONE = '0');
                -------------------------------------------------------------------
                -- ステートマシン
                -------------------------------------------------------------------
                case curr_state is
                    when IDLE_STATE =>
                        if (transaction_start) then
                            next_state := REQ_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                    when REQ_STATE  =>
                        if    (REQ_READY = '0') then
                                next_state := REQ_STATE;
                        elsif (ACK_VALID = '1') then
                            if (ACK_NEXT = '1' or ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                                if (xfer_run = TRUE) then
                                    next_state := TAR_STATE;
                                else
                                    next_state := DONE_STATE;
                                end if;
                            else
                                    next_state := CONTINUE_STATE;
                            end if;
                        else
                                    next_state := ACK_STATE;
                        end if;
                    when ACK_STATE  =>
                        if (ACK_VALID = '1') then
                            if (ACK_NEXT = '1' or ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                                if (xfer_run = TRUE) then
                                    next_state := TAR_STATE;
                                else
                                    next_state := DONE_STATE;
                                end if;
                            else
                                    next_state := CONTINUE_STATE;
                            end if;
                        else
                                    next_state := ACK_STATE;
                        end if;
                    when CONTINUE_STATE =>
                            next_state := REQ_STATE;
                    when TAR_STATE  =>
                        if (xfer_run = TRUE) then
                            next_state := TAR_STATE;
                        else
                            next_state := DONE_STATE;
                        end if;
                    when DONE_STATE =>
                            next_state := IDLE_STATE;
                    when others =>
                            next_state := IDLE_STATE;
                end case;
                if (reset_bit = '1') then
                    curr_state <= IDLE_STATE;
                else
                    curr_state <= next_state;
                end if;
                -------------------------------------------------------------------
                -- RESET BIT   :
                -------------------------------------------------------------------
                if    (RESET_L = '1') then
                    reset_bit <= RESET_D;
                end if;
                -------------------------------------------------------------------
                -- START BIT   :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    start_bit <= '0';
                elsif (START_L = '1' and START_D = '1') then
                    start_bit <= '1';
                elsif (next_state = DONE_STATE) then
                    start_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- STOP BIT    :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    stop_bit  <= '0';
                elsif (STOP_L  = '1' and STOP_D  = '1') then
                    stop_bit  <= '1';
                elsif (next_state = DONE_STATE) then
                    stop_bit  <= '0';
                end if;
                -------------------------------------------------------------------
                -- PAUSE BIT   :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    pause_bit <= '0';
                elsif (PAUSE_L = '1') then
                    pause_bit <= PAUSE_D;
                end if;
                -------------------------------------------------------------------
                -- FIRST BIT   :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    first_bit <= '0';
                elsif (FIRST_L = '1') then
                    first_bit <= FIRST_D;
                end if;
                xfer_first := (FIRST_L = '1' and FIRST_D = '1') or (first_bit = '1');
                -------------------------------------------------------------------
                -- LAST BIT    :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    last_bit  <= '0';
                elsif (LAST_L  = '1') then
                    last_bit  <= LAST_D;
                end if;
                -------------------------------------------------------------------
                -- DONE_EN BIT :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    done_en_bit  <= '0';
                elsif (DONE_EN_L  = '1') then
                    done_en_bit  <= DONE_EN_D;
                end if;
                -------------------------------------------------------------------
                -- DONE_ST BIT :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    done_bit <= '0';
                elsif (done_en_bit = '1' and next_state = DONE_STATE) then
                    done_bit <= '1';
                elsif (DONE_ST_L  = '1' and DONE_ST_D = '0') then
                    done_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- MODE REGISTER
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    mode_regs <= (others => '0');
                else
                    for i in mode_regs'range loop
                        if (MODE_L(i) = '1') then
                            mode_regs(i) <= MODE_D(i);
                        end if;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- STATUS REGISTER
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    stat_regs <= (others => '0');
                else
                    for i in stat_regs'range loop
                        if    (STAT_L(i) = '1' and STAT_D(i) = '0') then
                            stat_regs(i) <= '0';
                        elsif (STAT_I(i) = '1') then
                            stat_regs(i) <= '1';
                        end if;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- REQ_VALID   : 
                -------------------------------------------------------------------
                if (next_state = REQ_STATE or next_state = ACK_STATE) then
                    request_bit <= '1';
                else
                    request_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- tran_state : REQ_FIRST(最初の転送要求信号)を作るためのステートマシン.
                -- tran_once  : トランザクション中に最低１回転送が行われたことを示すフラグ
                -- tran_err   : トランザクション中にエラーが発生したことを示すフラグ
                -- none_on    : none_flag をアサートするための変数
                -- error_on   : error_flag をアサートするための変数
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    tran_state <= TRAN_IDLE_STATE;
                    tran_once <= '0';
                    tran_err  <= '0';
                    none_on   := FALSE;
                    error_on  := FALSE;
                elsif (tran_state = TRAN_IDLE_STATE) then
                    if (transaction_start and xfer_first) then
                        tran_state <= TRAN_FIRST_STATE;
                    else
                        tran_state <= TRAN_IDLE_STATE;
                    end if;
                    tran_once <= '0';
                    tran_err  <= '0';
                    none_on   := FALSE;
                    error_on  := FALSE;
                elsif (tran_state = TRAN_TAR_STATE) then
                    if (xfer_run = TRUE) then
                        tran_state <= TRAN_TAR_STATE;
                    else
                        tran_state <= TRAN_IDLE_STATE;
                    end if;
                    tran_err  <= XFER_ERROR;
                    none_on   := (tran_once = '0');
                    error_on  := (tran_err  = '1' or XFER_ERROR = '1');
                elsif (ACK_VALID = '1') then
                    if (ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                        if (xfer_run = TRUE) then
                            tran_state <= TRAN_TAR_STATE;
                        else
                            tran_state <= TRAN_IDLE_STATE;
                        end if;
                        none_on    := (tran_once = '0' and ACK_NONE  = '1');
                        error_on   := (tran_err  = '1' or XFER_ERROR = '1' or ACK_ERROR = '1');
                    else
                        tran_state <= TRAN_OTHER_STATE;
                        none_on    := FALSE;
                        error_on   := (tran_err  = '1' or XFER_ERROR = '1');
                    end if;
                    if (ACK_NONE = '0') then
                        tran_once  <= '1';
                    end if;
                    if (ACK_ERROR ='1' or XFER_ERROR = '1') then
                        tran_err   <= '1';
                    end if;
                else
                    if (XFER_ERROR = '1') then
                        tran_err   <= '1';
                    end if;
                    none_on  := FALSE;
                    error_on := FALSE;
                end if;
                -------------------------------------------------------------------
                -- NONE FLAG  : トランザクション中に転送が行われなかったことを示すフラグ
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    none_flag <= '0';
                elsif (next_state = DONE_STATE and none_on) then
                    none_flag <= '1';
                else
                    none_flag <= '0';
                end if;
                -------------------------------------------------------------------
                -- ERROR FLAG : トランザクション中にエラーが発生したことを示すフラグ.
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    error_flag <= '0';
                elsif (next_state = DONE_STATE and error_on) then
                    error_flag <= '1';
                end if;
                -------------------------------------------------------------------
                -- ERROR BIT  : トランザクション中にエラーが発生したことを示すフラグ.
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    error_bit <= '0';
                elsif (next_state = DONE_STATE and error_on) then
                    error_bit <= '1';
                elsif (ERR_ST_L = '1' and ERR_ST_D = '0') then
                    error_bit <= '0';
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- Register Output Signals.
    -------------------------------------------------------------------------------
    RESET_Q      <= reset_bit;
    START_Q      <= start_bit;
    STOP_Q       <= stop_bit;
    PAUSE_Q      <= pause_bit;
    FIRST_Q      <= first_bit;
    LAST_Q       <= last_bit;
    DONE_EN_Q    <= done_en_bit;
    DONE_ST_Q    <= done_bit;
    ERR_ST_Q     <= error_bit;
    MODE_Q       <= mode_regs;
    STAT_Q       <= stat_regs;
    -------------------------------------------------------------------------------
    -- Status
    -------------------------------------------------------------------------------
    VALVE_OPEN   <= tran_state(2);
    TRAN_START   <= '1' when (transaction_start = TRUE) else '0';
    TRAN_BUSY    <= start_bit;
    TRAN_DONE    <= '1' when (curr_state = DONE_STATE ) else '0';
    TRAN_NONE    <= none_flag;
    TRAN_ERROR   <= error_flag;
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
    REQ_VALID    <= request_bit;
    REQ_FIRST    <= tran_state(0);
    REQ_LAST     <= last_bit;
end RTL;
