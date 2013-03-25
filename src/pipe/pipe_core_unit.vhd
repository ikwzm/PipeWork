-----------------------------------------------------------------------------------
--!     @file    pipe_core_unit.vhd
--!     @brief   PIPE CORE UNIT
--!     @version 0.0.1
--!     @date    2013/3/25
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
--! @brief   PIPE CORE UNIT
-----------------------------------------------------------------------------------
entity  PIPE_CORE_UNIT is
    generic (
        PUSH_ENABLE     : --! @brief PUSH ENABLE :
                          --! レスポンダ側からリクエスタ側へのデータ転送を行うか
                          --! どうかを指定する.
                          --! * PUSH_ENABLE>1でデータ転送を行う.
                          --! * PUSH_ENABLE=0でデータ転送を行わない.
                          integer :=  1;
        PULL_ENABLE     : --! @brief PUSH ENABLE :
                          --! リクエスタ側からレスポンダ側へのデータ転送を行うか
                          --! どうかを指定する.
                          --! * PULL_ENABLE>1でデータ転送を行う.
                          --! * PULL_ENABLE=0でデータ転送を行わない.
                          integer :=  1;
        T_CLK_RATE      : --! @brief RESPONDER CLOCK RATE :
                          --! M_CLK_RATEとペアでレスポンダ側のクロック(T_CLK)とリク
                          --! エスト側のクロック(M_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        M_CLK_RATE      : --! @brief REQUESTER CLOCK RATE :
                          --! T_CLK_RATEとペアでレスポンダ側のクロック(T_CLK)とリク
                          --! エスト側のクロック(M_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        DELAY_CYCLE     : --! @brief DELAY CYCLE :   
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST の入力側から
                          --! 出力側への遅延サイクルを指定する.
                          integer :=  0;
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
                          integer := 12
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号.
    -------------------------------------------------------------------------------
        RST             : --! @brief RESET :
                          --! 非同期リセット信号(ハイ・アクティブ).
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側クロック.
    -------------------------------------------------------------------------------
        T_CLK           : in    std_logic;
        T_CLR           : in    std_logic;
        T_CKE           : in    std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側からの要求信号入力.
    -------------------------------------------------------------------------------
        T_REQ_ADDR      : --! @brief Responder Request Address.
                          --! 転送開始アドレスを入力する.  
                          in    std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE      : --! @brief Responder Request Transfer Size.
                          --! 転送したいバイト数を出力する. 
                          in    std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR   : --! @brief Responder Request Buffer Pointer.
                          --! 転送時のバッファポインタを出力する.
                          in    std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE      : --! @brief Responder Request Mode Signals.
                          --! 転送開始時に指定された各種情報を出力する.
                          in    std_logic_vector(MODE_BITS-1 downto 0);
        T_REQ_VALID     : --! @brief Responder Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          in    std_logic;
        T_REQ_READY     : --! @brief Responder Request Ready Signal.
                          --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側への応答信号出力.
    -------------------------------------------------------------------------------
        T_ACK_VALID     : --! @brief Responder Acknowledge Valid Signal.
                          --! 上記の Responder Request の応答信号.
                          --! 下記の 各種 Acknowledge 信号が有効である事を示す.
                          --! * この信号のアサートでもって、Responder Request が受け
                          --!   付けられたことを示す. ただし、あくまでも Request が
                          --!   受け付けられただけであって、必ずしもトランザクショ
                          --!   ンが完了したわけではないことに注意.
                          --! * この信号は Request につき１クロックだけアサートされ
                          --!   る.
                          --! * この信号がアサートされたら、アプリケーション側は速
                          --!   やかに REQ_VAL 信号をネゲートして Request を取り下
                          --!   げるか、REQ_VALをアサートしたままで次の Request 情
                          --!   報を用意しておかなければならない.
                          out   std_logic;
        T_ACK_ERROR     : --! @brief Responder Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          out   std_logic;
        T_ACK_SIZE      : --! @brief Responder Acknowledge Transfer Size.
                          --! 転送したバイト数を示す.
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- レスポンダ側からデータ入力のフロー制御信号入出力.
    -------------------------------------------------------------------------------
        T_I_FLOW_PAUSE  : out   std_logic;
        T_I_FLOW_STOP   : out   std_logic;
        T_I_FLOW_LAST   : out   std_logic;
        T_I_FLOW_SIZE   : out   std_logic_vector(SIZE_BITS-1 downto 0);
        T_I_BUF_READY   : out   std_logic;
        T_PUSH_FIN_VAL  : in    std_logic;
        T_PUSH_FIN_LAST : in    std_logic;
        T_PUSH_FIN_ERR  : in    std_logic;
        T_PUSH_FIN_SIZE : in    std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_RSV_VAL  : in    std_logic;
        T_PUSH_RSV_LAST : in    std_logic;
        T_PUSH_RSV_ERR  : in    std_logic;
        T_PUSH_RSV_SIZE : in    std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- レスポンダ側へのデータ出力のフロー制御信号入出力
    -------------------------------------------------------------------------------
        T_O_FLOW_PAUSE  : out   std_logic;
        T_O_FLOW_STOP   : out   std_logic;
        T_O_FLOW_LAST   : out   std_logic;
        T_O_FLOW_SIZE   : out   std_logic_vector(SIZE_BITS-1 downto 0);
        T_O_BUF_READY   : out   std_logic;
        T_PULL_FIN_VAL  : in    std_logic;
        T_PULL_FIN_LAST : in    std_logic;
        T_PULL_FIN_ERR  : in    std_logic;
        T_PULL_FIN_SIZE : in    std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_RSV_VAL  : in    std_logic;
        T_PULL_RSV_LAST : in    std_logic;
        T_PULL_RSV_ERR  : in    std_logic;
        T_PULL_RSV_SIZE : in    std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- リクエスト側クロック.
    -------------------------------------------------------------------------------
        M_CLK           : in    std_logic;
        M_CLR           : in    std_logic;
        M_CKE           : in    std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側への要求信号出力.
    -------------------------------------------------------------------------------
        M_REQ_ADDR      : --! @brief Requester Request Address.
                          --! 転送開始アドレスを出力する.  
                          out   std_logic_vector(ADDR_BITS-1 downto 0);
        M_REQ_SIZE      : --! @brief Requester Request Transfer Size.
                          --! 転送したいバイト数を出力する. 
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
        M_REQ_BUF_PTR   : --! @brief Requester Request Buffer Pointer.
                          --! 転送時のバッファポインタを出力する.
                          out   std_logic_vector(BUF_DEPTH-1 downto 0);
        M_REQ_MODE      : --! @brief Requester Request Mode Signals.
                          --! 転送開始時に指定された各種情報を出力する.
                          out   std_logic_vector(MODE_BITS-1 downto 0);
        M_REQ_FIRST     : --! @brief Requester Request First Transaction.
                          --! 最初のトランザクションであることを示す.
                          --! * REQ_FIRST=1の場合、内部状態を初期化してからトランザ
                          --!   クションを開始する.
                          out   std_logic;
        M_REQ_LAST      : --! @brief Requester Request Last Transaction.
                          --! 最後のトランザクションであることを示す.
                          --! * REQ_LAST=1の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_LAST 信号をア
                          --!   サートする.
                          --! * REQ_LAST=0の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_NEXT 信号をア
                          --!   サートする.
                          out   std_logic;
        M_REQ_VALID     : --! @brief Requester Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          out   std_logic;
        M_REQ_READY     : --! @brief Requester Request Ready Signal.
                          --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側からの応答信号入力.
    -------------------------------------------------------------------------------
        M_ACK_VALID     : --! @brief Requester Acknowledge Valid Signal.
                          --! 上記の Requester Request の応答信号.
                          --! 下記の 各種 Acknowledge 信号が有効である事を示す.
                          --! * この信号のアサートでもって、Requester Request が受け
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
        M_ACK_NEXT      : --! @brief Requester Acknowledge with need Next transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=0 の場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        M_ACK_LAST      : --! @brief Requester Acknowledge with Last transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=1 の場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        M_ACK_ERROR     : --! @brief Requester Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        M_ACK_STOP      : --! @brief Requester Acknowledge with Stop operation.
                          --! トランザクションが中止された場合、この信号がアサート
                          --! される.
                          in    std_logic;
        M_ACK_NONE      : --! @brief Requester Acknowledge with None Request Transfer Size.
                          --! REQ_SIZE=0 の Request だった場合、この信号がアサート
                          --! される.
                          in    std_logic;
        M_ACK_SIZE      : --! @brief Acknowledge transfer size.
                          --! 転送するバイト数を示す.
                          --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で示さ
                          --! れるバイト数分を加算/減算すると良い.
                          in    std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- レスポンダ側からデータ入力のフロー制御信号入出力.
    -------------------------------------------------------------------------------
        M_I_FLOW_PAUSE  : out   std_logic;
        M_I_FLOW_STOP   : out   std_logic;
        M_I_FLOW_LAST   : out   std_logic;
        M_I_FLOW_SIZE   : out   std_logic_vector(SIZE_BITS-1 downto 0);
        M_I_BUF_READY   : out   std_logic;
        M_PUSH_FIN_VAL  : in    std_logic;
        M_PUSH_FIN_LAST : in    std_logic;
        M_PUSH_FIN_ERR  : in    std_logic;
        M_PUSH_FIN_SIZE : in    std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_RSV_VAL  : in    std_logic;
        M_PUSH_RSV_LAST : in    std_logic;
        M_PUSH_RSV_ERR  : in    std_logic;
        M_PUSH_RSV_SIZE : in    std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- レスポンダ側へのデータ出力のフロー制御信号入出力
    -------------------------------------------------------------------------------
        M_O_FLOW_PAUSE  : out   std_logic;
        M_O_FLOW_STOP   : out   std_logic;
        M_O_FLOW_LAST   : out   std_logic;
        M_O_FLOW_SIZE   : out   std_logic_vector(SIZE_BITS-1 downto 0);
        M_O_BUF_READY   : out   std_logic;
        M_PULL_FIN_VAL  : in    std_logic;
        M_PULL_FIN_LAST : in    std_logic;
        M_PULL_FIN_ERR  : in    std_logic;
        M_PULL_FIN_SIZE : in    std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_RSV_VAL  : in    std_logic;
        M_PULL_RSV_LAST : in    std_logic;
        M_PULL_RSV_ERR  : in    std_logic;
        M_PULL_RSV_SIZE : in    std_logic_vector(SIZE_BITS-1 downto 0)
    );
end PIPE_CORE_UNIT;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.FLOAT_OUTLET_MANIFOLD_VALVE;
use     PIPEWORK.RELAY_COMPONENTS.RELAY_REQUESTER_INTERFACE;
use     PIPEWORK.RELAY_COMPONENTS.RELAY_RESPONDER_INTERFACE;
use     PIPEWORK.RELAY_COMPONENTS.RELAY_FLOW_SYNCRONIZER;
architecture RTL of PIPE_CORE_UNIT is
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REQ: PIPE_REQUESTER_INTERFACE is
        generic map (
            ADDR_BITS       => ADDR_BITS,
            ADDR_VALID      => ADDR_VALID,
            SIZE_BITS       => SIZE_BITS,
            SIZE_VALID      => SIZE_VALID,
            MODE_BITS       => MODE_BITS,
            BUF_DEPTH       => BUF_DEPTH,
            BUF_WIDTH       => BUF_WIDTH,
            XFER_MAX_SIZE   => XFER_MAX_SIZE
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => M_CLK           , -- In  :
            RST             => RST             , -- In  :
            CLR             => M_CLR           , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Request Signals.
        ---------------------------------------------------------------------------
            M_REQ_ADDR      => M_REQ_ADDR      , -- Out :
            M_REQ_SIZE      => M_REQ_SIZE      , -- Out :
            M_REQ_BUF_PTR   => M_REQ_BUF_PTR   , -- Out :
            M_REQ_MODE      => M_REQ_MODE      , -- Out :
            M_REQ_FIRST     => M_REQ_FIRST     , -- Out :
            M_REQ_LAST      => M_REQ_LAST      , -- Out :
            M_REQ_VALID     => M_REQ_VALID     , -- Out :
            M_REQ_READY     => M_REQ_READY     , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Acknowledge Signals.
        ---------------------------------------------------------------------------
            M_ACK_VALID     => M_ACK_VALID     , -- In  :
            M_ACK_NEXT      => M_ACK_NEXT      , -- In  :
            M_ACK_LAST      => M_ACK_LAST      , -- In  :
            M_ACK_ERROR     => M_ACK_ERROR     , -- In  :
            M_ACK_STOP      => M_ACK_STOP      , -- In  :
            M_ACK_NONE      => M_ACK_NONE      , -- In  :
            M_ACK_SIZE      => M_ACK_SIZE      , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Outlet Flow Signals.
        ---------------------------------------------------------------------------
            M_O_FLOW_PAUSE  => M_O_FLOW_PAUSE  , -- Out :
            M_O_FLOW_STOP   => M_O_FLOW_STOP   , -- Out :
            M_O_FLOW_LAST   => M_O_FLOW_LAST   , -- Out :
            M_O_FLOW_SIZE   => M_O_FLOW_SIZE   , -- Out :
            M_O_BUF_READY   => M_O_BUF_READY   , -- Out :
            M_PULL_FIN_VAL  => M_PULL_FIN_VAL  , -- In  :
            M_PULL_FIN_LAST => M_PULL_FIN_LAST , -- In  :
            M_PULL_FIN_ERR  => M_PULL_FIN_ERR  , -- In  :
            M_PULL_FIN_SIZE => M_PULL_FIN_SIZE , -- In  :
            M_PULL_RSV_VAL  => M_PULL_RSV_VAL  , -- In  :
            M_PULL_RSV_LAST => M_PULL_RSV_LAST , -- In  :
            M_PULL_RSV_ERR  => M_PULL_RSV_ERR  , -- In  :
            M_PULL_RSV_SIZE => M_PULL_RSV_SIZE , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Intake Flow Signals.
        ---------------------------------------------------------------------------
            M_I_FLOW_PAUSE  => M_I_FLOW_PAUSE  , -- Out :
            M_I_FLOW_STOP   => M_I_FLOW_STOP   , -- Out :
            M_I_FLOW_LAST   => M_I_FLOW_LAST   , -- Out :
            M_I_FLOW_SIZE   => M_I_FLOW_SIZE   , -- Out :
            M_I_BUF_READY   => M_I_BUF_READY   , -- Out :
            M_PUSH_FIN_VAL  => M_PUSH_FIN_VAL  , -- In  :
            M_PUSH_FIN_LAST => M_PUSH_FIN_LAST , -- In  :
            M_PUSH_FIN_ERR  => M_PUSH_FIN_ERR  , -- In  :
            M_PUSH_FIN_SIZE => M_PUSH_FIN_SIZE , -- In  :
            M_PUSH_RSV_VAL  => M_PUSH_RSV_VAL  , -- In  :
            M_PUSH_RSV_LAST => M_PUSH_RSV_LAST , -- In  :
            M_PUSH_RESV_ERR => M_PUSH_RSV_ERR  , -- In  :
            M_PUSH_RSV_SIZE => M_PUSH_RSV_SIZE , -- In  :
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
            T_REQ_ADDR      => T_REQ_ADDR      , -- In  :
            T_REQ_SIZE      => T_REQ_SIZE      , -- In  :
            T_REQ_BUF_PTR   => T_REQ_BUF_PTR   , -- In  :
            T_REQ_MODE      => T_REQ_MODE      , -- In  :
            T_REQ_DIR       => T_REQ_DIR       , -- In  :
            T_REQ_VALID     => T_REQ_VALID     , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            T_RES_START     => T_RES_START     , -- Out :
            T_RES_DONE      => T_RES_DONE      , -- Out :
            T_RES_ERROR     => T_RES_ERROR     , -- Out :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            VALVE_OPEN      => VALVE_OPEN        -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_VALVE: FLOAT_OUTLET_MANIFOLD_VALVE
        generic map (
            PRECEDE         => M_O_PRECEDE,
            FIXED           => 0,
            COUNT_BITS      => VALVE_COUNT_BITS,
            SIZE_BITS       => SIZE_BITS 
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            RESET           => RESET           , -- In  :
            PAUSE           => PAUSE           , -- In  :
            STOP            => STOP            , -- In  :
            INTAKE_OPEN     => INTAKE_OPEN     , -- In  :
            OUTLET_OPEN     => OUTLET_OPEN     , -- In  :
            FLOW_READY_LEVEL=> FLOW_READY_LEVEL, -- In  :
            POOL_READY_LEVEL=> POOL_READY_LEVEL, -- In  :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VAL    => PUSH_FIN_VAL    , -- In  :
            PUSH_FIN_LAST   => PUSH_FIN_LAST   , -- In  :
            PUSH_FIN_SIZE   => PUSH_FIN_SIZE   , -- In  :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PUSH_RSV_VAL    => PUSH_RSV_VAL    , -- In  :
            PUSH_RSV_LAST   => PUSH_RSV_LAST   , -- In  :
            PUSH_RSV_SIZE   => PUSH_RSV_SIZE   , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PULL_VAL        => PULL_VAL        , -- In  :
            PULL_LAST       => PULL_LAST       , -- In  :
            PULL_SIZE       => PULL_SIZE       , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY      => FLOW_READY      , -- Out :
            FLOW_PAUSE      => FLOW_PAUSE      , -- Out :
            FLOW_STOP       => FLOW_STOP       , -- Out :
            FLOW_LAST       => FLOW_LAST       , -- Out :
            FLOW_SIZE       => FLOW_SIZE       , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Counter.
        ---------------------------------------------------------------------------
            FLOW_COUNT      => FLOW_COUNT      , -- Out :
            FLOW_NEG        => FLOW_NEG        , -- Out :
            PAUSED          => PAUSED          , -- Out :
            POOL_COUNT      => POOL_COUNT      , -- Out :
            POOL_READY      => POOL_READY        -- Out :
        );
    
end RTL;
