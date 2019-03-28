-----------------------------------------------------------------------------------
--!     @file    pipe_responder_interface.vhd
--!     @brief   PIPE RESPONDER INTERFACE
--!     @version 1.8.0
--!     @date    2019/3/25
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2019 Ichiro Kawazome
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
--! @brief   PIPE RESPONDER INTERFACE
-----------------------------------------------------------------------------------
entity  PIPE_RESPONDER_INTERFACE is
    generic (
        PUSH_VALID          : --! @brief PUSH VALID :
                              --! レスポンダ側からリクエスタ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PUSH_VALID=1でデータ転送を行う.
                              --! * PUSH_VALID=0でデータ転送を行わない.
                              integer range 0 to 1 := 1;
        PULL_VALID          : --! @brief PUSH VALID :
                              --! リクエスタ側からレスポンダ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PULL_VALID=1でデータ転送を行う.
                              --! * PULL_VALID=0でデータ転送を行わない.
                              integer range 0 to 1 := 1;
        ADDR_BITS           : --! @brief Request Address Bits :
                              --! REQ_ADDR信号のビット数を指定する.
                              integer := 32;
        ADDR_VALID          : --! @brief Request Address Valid :
                              --! REQ_ADDR信号を有効にするかどうかを指定する.
                              --! * ADDR_VALID=0で無効.
                              --! * ADDR_VALID=1で有効.
                              integer range 0 to 1 := 1;
        SIZE_BITS           : --! @brief Transfer Size Bits :
                              --! REQ_SIZE/ACK_SIZE信号のビット数を指定する.
                              integer := 32;
        SIZE_VALID          : --! @brief Request Size Valid :
                              --! REQ_SIZE信号を有効にするかどうかを指定する.
                              --! * SIZE_VALID=0で無効.
                              --! * SIZE_VALID=1で有効.
                              integer range 0 to 1 := 1;
        MODE_BITS           : --! @brief Request Mode Bits :
                              --! REQ_MODE信号のビット数を指定する.
                              integer := 32;
        XFER_COUNT_BITS     : --! @brief Flow Counter Bits :
                              --! フロー制御用カウンタのビット数を指定する.
                              integer := 32;
        XFER_SIZE_BITS      : --! @brief Transfer Size Bits :
                              --! １回の転送バイト数入力信号(FLOW_SIZE/PULL_SIZE/
                              --! PUSH_SIZEなど)のビット幅を指定する.
                              integer := 12;
        BUF_DEPTH           : --! @brief Buffer Depth :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        O_FIXED_CLOSE       : --! @brief OUTLET VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        O_FIXED_FLOW_OPEN   : --! @brief OUTLET VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        O_FIXED_POOL_OPEN   : --! @brief OUTLET FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        I_FIXED_CLOSE       : --! @brief INTAKE VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        I_FIXED_FLOW_OPEN   : --! @brief INTAKE VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        I_FIXED_POOL_OPEN   : --! @brief INTAKE FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        USE_M_PUSH_RSV      : --! @brief USE PUSH RESERVE SIGNALS :
                              --! フローカウンタの加算に M_PUSH_RSV_SIZE を使うか 
                              --! M_PUSH_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        USE_T_PULL_BUF      : --! @brief USE PULL BUFFER  SIGNALS :
                              --! プールカウンタの減算に T_PULL_BUF_SIZE を使うか 
                              --! T_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        USE_M_PULL_RSV      : --! @brief USE PULL RESERVE SIGNALS :
                              --! フローカウンタの減算に M_PULL_RSV_SIZE を使うか 
                              --! M_PULL_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        USE_T_PUSH_BUF      : --! @brief USE PUSH BUFFER  SIGNALS :
                              --! プールカウンタの加算に T_PUSH_BUF_SIZE を使うか 
                              --! T_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1
    );
    port (
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK                 : --! @brief CLOCK :
                              --! クロック信号
                              in  std_logic;
        RST                 : --! @brief ASYNCRONOUSE RESET :
                              --! 非同期リセット信号.アクティブハイ.
                              in  std_logic;
        CLR                 : --! @brief SYNCRONOUSE RESET :
                              --! 同期リセット信号.アクティブハイ.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Request from Responder Signals.
    -------------------------------------------------------------------------------
        T_REQ_ADDR          : --! @brief Request Address from responder :
                              --! 転送開始アドレスを入力する.  
                              in  std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE          : --! @brief Request transfer Size from responder :
                              --! 転送したいバイト数を入力する. 
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR       : --! @brief Request Buffer Pointer from responder :
                              --! 転送時のバッファポインタを入力する.
                              in  std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE          : --! @brief Request Mode signals from responder :
                              --! 転送開始時に指定された各種情報を入力する.
                              in  std_logic_vector(MODE_BITS-1 downto 0);
        T_REQ_DIR           : --! @brief Request Direction from responder :
                              --! 転送方向(PUSH/PULL)を指定する.
                              --! * T_REQ_DIR='1' : PUSH(Responder側からRequester側へデータ転送)
                              --! * T_REQ_DIR='0' : PULL(Requester側からResponder側へデータ転送)
                              in  std_logic;
        T_REQ_FIRST         : --! @brief Request First transaction from responder :
                              --! 最初のトランザクションであることを示す.
                              --! * T_REQ_FIRST=1の場合、内部状態を初期化してから
                              --!   トランザクションを開始する.
                              in  std_logic := '1';
        T_REQ_LAST          : --! @brief Request Last transaction from responder :
                              --! 最後のトランザクションであることを示す.
                              --! * T_REQ_LAST=1の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_LAST 信号をアサートする.
                              --! * T_REQ_LAST=0の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_NEXT 信号をアサートする.
                              in  std_logic := '1';
        T_REQ_VALID         : --! @brief Request Valid signal from responder  :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              --! * この信号のアサートでもってトランザクションを開始する.
                              --! * 一度この信号をアサートすると Acknowledge を返す
                              --!   まで、この信号はアサートされなくてはならない.
                              in  std_logic;
        T_REQ_READY         : --! @brief Request Ready signal from requester :
                              --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- Acknowledge to Responder Signals.
    -------------------------------------------------------------------------------
        T_ACK_VALID         : --! @brief Acknowledge Valid signal to responder :
                              --! 上記の Command Request の応答信号.
                              --! 下記の 各種 Acknowledge 信号が有効である事を示す.
                              out std_logic;
        T_ACK_NEXT          : --! @brief Acknowledge with need Next transaction to responder :
                              --! すべてのトランザクションが終了かつ REQ_LAST=0 の
                              --! 場合、この信号がアサートされる.
                              out std_logic;
        T_ACK_LAST          : --! @brief Acknowledge with Last transaction to responder :
                              --! すべてのトランザクションが終了かつ REQ_LAST=1 の
                              --! 場合、この信号がアサートされる.
                              out std_logic;
        T_ACK_ERROR         : --! @brief Acknowledge with Error to responder :
                              --! トランザクション中になんらかのエラーが発生した場
                              --! 合、この信号がアサートされる.
                              out std_logic;
        T_ACK_STOP          : --! @brief Acknowledge with Stop operation to responder :
                              --! トランザクションが中止された場合、この信号がアサ
                              --! ートされる.
                              out std_logic;
        T_ACK_SIZE          : --! @brief Acknowledge transfer Size to responder :
                              --! 転送したバイト数を示す.
                              out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Control from Responder Signals.
    -------------------------------------------------------------------------------
        T_REQ_STOP          : --! @brief Transfer Stop Request.
                              --! レスポンダ側から強制的にデータ転送を中止すること
                              --! を要求する信号.
                              in  std_logic := '0';
        T_REQ_PAUSE         : --! @brief Transfer Pause Request.
                              --! レスポンダ側から強制的にデータ転送を一時的に中断
                              --! することを要求する信号.
                              in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Status from Responder Signals.
    -------------------------------------------------------------------------------
        T_XFER_BUSY         : --! @brief Transfer Busy.
                              --! データ転送中であることを示すフラグ.
                              in  std_logic;
        T_XFER_ERROR        : --! @brief Transfer Error.
                              --! データの転送中にエラーが発生した事を示す.
                              in  std_logic := '0';
        T_XFER_DONE         : --! @brief Transfer Done.
                              --! データ転送中かつ、次のクロックで T_XFER_BUSY が
                              --! ネゲートされる事を示すフラグ.
                              --! * ただし、T_XFER_BUSY のネゲート前に 必ずしもこの
                              --!   信号がアサートされるわけでは無い.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from Responder.
    -------------------------------------------------------------------------------
        T_PUSH_FIN_VALID    : --! @brief Push Final Valid from responder :
                              --! T_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PUSH_FIN_LAST     : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PUSH_FIN_SIZE     : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals from Requester.
    -------------------------------------------------------------------------------
        T_PULL_FIN_VALID    : --! @brief Pull Final Valid from responder :
                              --! T_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PULL_FIN_LAST     : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PULL_FIN_SIZE     : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
        T_PUSH_BUF_RESET    : --! @brief Push Buffer Reset from responder :
                              in  std_logic := '0';
        T_PUSH_BUF_VALID    : --! @brief Push Buffer Valid from responder :
                              in  std_logic := '0';
        T_PUSH_BUF_LAST     : --! @brief Push Buffer Last  from responder :
                              in  std_logic := '0';
        T_PUSH_BUF_SIZE     : --! @brief Push Buffer Size  from responder :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PUSH_BUF_READY    : --! @brief Push Buffer Ready to   responder :
                              --! プールバッファに T_PUSH_BUF_LEVEL 以下のデータし
                              --! かないことを示すフラグ.
                              out std_logic;
        T_PUSH_BUF_LEVEL    : --! @brief Push Buffer Ready Level :
                              --! T_PUSH_BUF_READY 信号をアサートするかしないかを
                              --! 指示するための閾値.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
        T_PULL_BUF_RESET    : --! @brief Pull Buffer Reset from responder :
                              in  std_logic := '0';
        T_PULL_BUF_VALID    : --! @brief Pull Buffer Valid from responder :
                              in  std_logic := '0';
        T_PULL_BUF_LAST     : --! @brief Pull Buffer Last  from responder :
                              in  std_logic := '0';
        T_PULL_BUF_SIZE     : --! @brief Pull Buffer Size  from responder :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PULL_BUF_READY    : --! @brief Pull Buffer Ready to   responder :
                              --! プールバッファに T_PULL_BUF_LEVEL 以上のデータが
                              --! あることを示すフラグ.
                              out std_logic;
        T_PULL_BUF_LEVEL    : --! @brief Pull Buffer Ready Level :
                              --! T_PULL_BUF_READY 信号をアサートするかしないかを
                              --! 指示するための閾値.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals to Responder.
    -------------------------------------------------------------------------------
        O_FLOW_PAUSE        : --! @brief Outlet Valve Flow Pause :
                              --! 出力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに O_FLOW_READY_LEVEL 未満のデータしか無い
                              --! ことを示す.
                              out std_logic;
        O_FLOW_STOP         : --! @brief Outlet Valve Flow Stop :
                              --! 出力の中止を指示する信号.
                              out std_logic;
        O_FLOW_LAST         : --! @brief Outlet Valve Flow Last :
                              --! 入力側から最後の入力を示すフラグがあったことを示す.
                              out std_logic;
        O_FLOW_SIZE         : --! @brief Outlet Valve Flow Enable Size :
                              --! 出力可能なバイト数を出力.
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        O_FLOW_READY        : --! @brief Outlet Valve Flow Ready :
                              --! プールバッファに O_FLOW_READY_LEVEL 以上のデータがある
                              --! ことを示す.
                              out std_logic;
        O_FLOW_LEVEL        : --! @brief Outlet Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以上の時に転送を開始する.
                              --! フローカウンタの値がこの値未満の時に転送を一時停止.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Valve Signals to Responder.
    -------------------------------------------------------------------------------
        I_FLOW_PAUSE        : --! @brief Intake Valve Flow Pause :
                              --! 入力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに I_FLOW_READY_LEVEL を越えるデータが溜っ
                              --! ていて、これ以上データが入らないことを示す.
                              out std_logic;
        I_FLOW_STOP         : --! @brief Intake Valve Flow Stop :
                              --! 入力の中止を指示する信号.
                              out std_logic;
        I_FLOW_LAST         : --! @brief Intake Valve Flow Last :
                              --! 入力側から最後の入力を示すフラグがあったことを示す.
                              out std_logic;
        I_FLOW_SIZE         : --! @brief Intake Valve Flow Enable Size :
                              --! 入力可能なバイト数
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        I_FLOW_READY        : --! @brief Intake Valve Flow Ready :
                              --! プールバッファに I_FLOW_READY_LEVEL 以下のデータしか無く、
                              --! データの入力が可能な事を示す.
                              out std_logic;
        I_FLOW_LEVEL        : --! @brief Intake Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以下の時に入力を開始する.
                              --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        I_BUF_SIZE          : --! @brief Intake Pool Size :
                              --! 入力用プールの総容量を指定する.
                              --! I_FLOW_SIZE を求めるのに使用する.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Request to Requester Signals.
    -------------------------------------------------------------------------------
        M_REQ_START         : --! @brief Request Start signal to requester :
                              --! 転送開始を指示する.
                              out std_logic;
        M_REQ_ADDR          : --! @brief Request Address to requester :
                              --! 転送開始アドレスを出力する.  
                              out std_logic_vector(ADDR_BITS-1 downto 0);
        M_REQ_SIZE          : --! @brief Request transfer Size to requester :
                              --! 転送したいバイト数を出力する. 
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        M_REQ_BUF_PTR       : --! @brief Request Buffer Pointer to requester :
                              --! 転送時のバッファポインタを出力する.
                              out std_logic_vector(BUF_DEPTH-1 downto 0);
        M_REQ_MODE          : --! @brief Request Mode signals to requester :
                              --! 転送開始時に指定された各種情報を出力する.
                              out std_logic_vector(MODE_BITS-1 downto 0);
        M_REQ_DIR           : --! @brief Request Direction to requester :
                              --! 転送方向(PUSH/PULL)を指定する.
                              --! * M_REQ_DIR='1' : PUSH(Responder側からRequester側へデータ転送)
                              --! * M_REQ_DIR='0' : PULL(Requester側からResponder側へデータ転送)
                              out std_logic;
        M_REQ_FIRST         : --! @brief Request First transaction to requester :
                              --! 最初のトランザクションであることを示す.
                              --! * REQ_FIRST=1の場合、内部状態を初期化してから
                              --!   トランザクションを開始する.
                              out std_logic;
        M_REQ_LAST          : --! @brief Request Last transaction to requester :
                              --! 最後のトランザクションであることを示す.
                              out std_logic;
        M_REQ_VALID         : --! @brief Request Valid signal to requester :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              out std_logic;
        M_REQ_READY         : --! @brief Request Ready signal from requester :
                              --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                              in  std_logic;
        M_REQ_DONE          : --! @brief Request Done signal to requeseter :
                              --! トランザクションの終了を指示する.
                              out std_logic;
        M_REQ_STOP          : --! @brief Request Done signal to requeseter :
                              --! トランザクションの中止を指示する.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- Response from Requester Signals.
    -------------------------------------------------------------------------------
        M_RES_START         : --! @brief Request Start signal from requester :
                              --! 転送を開始したことを示す入力信号.
                              in  std_logic;
        M_RES_DONE          : --! @brief Transaction Done signal from requester :
                              --! 転送を終了したことを示す入力信号.
                              in  std_logic;
        M_RES_ERROR         : --! @brief Transaction Error signal from requester :
                              --! 転送を異常終了したことを示す入力信号.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals from Requester.
    -------------------------------------------------------------------------------
        M_PUSH_FIN_VALID    : --! @brief Push Final Valid from requester :
                              --! M_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        M_PUSH_FIN_LAST     : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        M_PUSH_FIN_SIZE     : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PUSH_RSV_VALID    : --! @brief Push Reserve Valid from requester :
                              --! M_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic := '0';
        M_PUSH_RSV_LAST     : --! @brief Push Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ入力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic := '0';
        M_PUSH_RSV_SIZE     : --! @brief Push Reserve Size :
                              --! レスポンダ側からの"予定された"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from requester.
    -------------------------------------------------------------------------------
        M_PULL_FIN_VALID    : --! @brief Pull Final Valid from requester :
                              --! M_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        M_PULL_FIN_LAST     : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        M_PULL_FIN_SIZE     : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PULL_RSV_VALID    : --! @brief Pull Reserve Valid from requester :
                              --! M_PULL_RSV_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが先行(Precede)モードで無い場合は
                              --!   未使用.
                              in  std_logic := '0';
        M_PULL_RSV_LAST     : --! @brief Pull Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic := '0';
        M_PULL_RSV_SIZE     : --! @brief Pull Reserve Size :
                              --! レスポンダ側からの"予定された"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0')
    );
end PIPE_RESPONDER_INTERFACE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.FLOAT_OUTLET_MANIFOLD_VALVE;
use     PIPEWORK.COMPONENTS.FLOAT_INTAKE_MANIFOLD_VALVE;
use     PIPEWORK.COMPONENTS.COUNT_UP_REGISTER;
architecture RTL of PIPE_RESPONDER_INTERFACE is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  reset             : std_logic := '0';
    constant  pause             : std_logic := '0';
    constant  stop              : std_logic := '0';
    signal    start             : std_logic;
    type      STATE_TYPE    is  ( IDLE_STATE, REQ_STATE, STOP_STATE, ACK_STATE );
    signal    curr_state        : STATE_TYPE;
    signal    xfer_dir          : std_logic;
    signal    xfer_last         : std_logic;
    signal    ack_error         : std_logic;
    signal    ack_last          : std_logic;
    signal    ack_stop          : std_logic;
    signal    push_mode         : boolean;
    signal    pull_mode         : boolean;
    constant  size_all_clr      : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    constant  size_all_set      : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '1');
    signal    size_load         : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    size_up_size      : std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    signal    size_up_valid     : std_logic;
    signal    size_up_select    : boolean;
    signal    m_valve_open      : std_logic;
    signal    m_res_open        : std_logic;
    signal    t_valve_open      : std_logic;
    signal    t_req_open        : std_logic;
    signal    o_valve_i_open    : std_logic;
    signal    o_valve_o_open    : std_logic;
    signal    i_valve_i_open    : std_logic;
    signal    i_valve_o_open    : std_logic;
    type      DONE_STATE_TYPE is( DONE_IDLE_STATE   ,
                                  DONE_REQUEST_STATE,
                                  STOP_REQUEST_STATE,
                                  DONE_PENDING_STATE,
                                  STOP_TURN_AR_STATE
                                );
    signal    done_state        : DONE_STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    start <= '1' when (curr_state = IDLE_STATE and T_REQ_VALID = '1' and M_REQ_READY = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
    begin
        if (RST = '1') then
                curr_state <= IDLE_STATE;
                done_state <= DONE_IDLE_STATE;
                xfer_dir   <= '0';
                xfer_last  <= '1';
                ack_error  <= '0';
                ack_last   <= '0';
                ack_stop   <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_state <= IDLE_STATE;
                done_state <= DONE_IDLE_STATE;
                xfer_dir   <= '0';
                xfer_last  <= '1';
                ack_error  <= '0';
                ack_last   <= '0';
                ack_stop   <= '0';
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (start = '1') then
                            next_state := REQ_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                    when REQ_STATE  =>
                        if    (M_RES_DONE = '1') then
                            next_state := ACK_STATE;
                        elsif (T_REQ_STOP = '1') then
                            next_state := STOP_STATE;
                        else
                            next_state := REQ_STATE;
                        end if;
                    when STOP_STATE =>
                        if    (M_RES_DONE = '1') then
                            next_state := ACK_STATE;
                        else
                            next_state := STOP_STATE;
                        end if;
                    when ACK_STATE  =>
                            next_state := IDLE_STATE;
                    when others =>
                            next_state := IDLE_STATE;
                end case;
                curr_state <= next_state;
                if (start = '1') then
                    xfer_dir  <= T_REQ_DIR;
                    xfer_last <= T_REQ_LAST;
                end if;
                case next_state is
                    when IDLE_STATE =>
                        ack_error <= '0';
                        ack_last  <= '0';
                        ack_stop  <= '0';
                    when STOP_STATE =>
                        ack_stop  <= '1';
                    when ACK_STATE  =>
                        ack_error <=     M_RES_ERROR;
                        ack_last  <= not M_RES_ERROR and xfer_last;
                    when others     => 
                        null;
                end case;
                case done_state is
                    when DONE_IDLE_STATE =>
                        if    (next_state = STOP_STATE) then
                                done_state <= STOP_REQUEST_STATE;
                        elsif (next_state = ACK_STATE ) then
                            if (T_XFER_BUSY = '0' or T_XFER_DONE = '1') then
                                done_state <= DONE_REQUEST_STATE;
                            else
                                done_state <= DONE_PENDING_STATE;
                            end if;
                        else
                                done_state <= DONE_IDLE_STATE;
                        end if;
                    when STOP_REQUEST_STATE |
                         STOP_TURN_AR_STATE =>
                        if (next_state /= STOP_STATE ) then
                                done_state <= DONE_IDLE_STATE;
                        else
                                done_state <= STOP_TURN_AR_STATE;
                        end if;
                    when DONE_PENDING_STATE =>
                        if (T_XFER_BUSY = '0' or T_XFER_DONE = '1') then
                                done_state <= DONE_REQUEST_STATE;
                        else
                                done_state <= DONE_PENDING_STATE;
                        end if;
                    when DONE_REQUEST_STATE =>
                                done_state <= DONE_IDLE_STATE;
                    when others => 
                                done_state <= DONE_IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    push_mode   <= (PUSH_VALID /= 0 and PULL_VALID  = 0) or
                   (PUSH_VALID /= 0 and PULL_VALID /= 0 and xfer_dir  = '1');
    pull_mode   <= (PULL_VALID /= 0 and PUSH_VALID  = 0) or
                   (PULL_VALID /= 0 and PUSH_VALID /= 0 and xfer_dir  = '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    T_REQ_READY <= '1' when (curr_state = IDLE_STATE and M_REQ_READY = '1') else '0';
    T_ACK_VALID <= '1' when (curr_state = ACK_STATE) else '0';
    T_ACK_ERROR <= '1' when (curr_state = ACK_STATE  and ack_error   = '1') else '0';
    T_ACK_NEXT  <= '1' when (curr_state = ACK_STATE  and ack_last    = '0') else '0';
    T_ACK_LAST  <= '1' when (curr_state = ACK_STATE  and ack_last    = '1') else '0';
    T_ACK_STOP  <= '1' when (curr_state = ACK_STATE  and ack_stop    = '1') else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    SIZE_REGS: COUNT_UP_REGISTER                     -- 
        generic map (                                -- 
            VALID           => 1                   , -- 
            BITS            => SIZE_BITS           , --
            REGS_BITS       => SIZE_BITS             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            REGS_WEN        => size_load           , -- In  :
            REGS_WDATA      => size_all_clr        , -- In  :
            REGS_RDATA      => open                , -- Out :
            UP_ENA          => m_valve_open        , -- In  :
            UP_VAL          => size_up_valid       , -- In  :
            UP_BEN          => size_all_set        , -- In  :
            UP_SIZE         => size_up_size        , -- In  :
            COUNTER         => T_ACK_SIZE            -- Out :
       );
    size_load     <= size_all_set     when (start = '1') else size_all_clr;
    size_up_valid <= M_PULL_FIN_VALID when (push_mode  ) else M_PUSH_FIN_VALID;
    size_up_size  <= M_PULL_FIN_SIZE  when (push_mode  ) else M_PUSH_FIN_SIZE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    M_REQ_START   <= start;
    M_REQ_VALID   <= '1' when (start = '1' or curr_state = REQ_STATE) else '0';
    M_REQ_ADDR    <= T_REQ_ADDR;
    M_REQ_SIZE    <= T_REQ_SIZE;
    M_REQ_BUF_PTR <= T_REQ_BUF_PTR;
    M_REQ_MODE    <= T_REQ_MODE;
    M_REQ_FIRST   <= T_REQ_FIRST;
    M_REQ_LAST    <= T_REQ_LAST;
    M_REQ_DIR     <= '1' when (PUSH_VALID /= 0 and PULL_VALID  = 0) else
                     '0' when (PUSH_VALID  = 0 and PULL_VALID /= 0) else T_REQ_DIR;
    M_REQ_DONE    <= '1' when (done_state = DONE_REQUEST_STATE) else '0';
    M_REQ_STOP    <= '1' when (done_state = STOP_REQUEST_STATE) else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                m_res_open <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                m_res_open <= '0';
            elsif (M_RES_START = '1' and M_RES_DONE = '0') then
                m_res_open <= '1';
            elsif (m_res_open  = '1' and M_RES_DONE = '1' and xfer_last = '1') then
                m_res_open <= '0';
            end if;
        end if;
    end process;
    m_valve_open <= '1' when (M_RES_START = '1' and M_RES_DONE = '0') or
                             (m_res_open = '1') else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                t_req_open <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                t_req_open <= '0';
            elsif (curr_state = IDLE_STATE and start = '1') then
                t_req_open <= '1';
            elsif (t_req_open = '1') and
                  (xfer_last  = '1') and
                  (T_XFER_BUSY = '0' or T_XFER_DONE = '1') then
                t_req_open <= '0';
            end if;
        end if;
    end process;
    t_valve_open <= '1' when (curr_state = IDLE_STATE and start = '1') or
                             (t_req_open = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    o_valve_o_open <= '1' when (pull_mode and t_valve_open = '1') else '0';
    o_valve_i_open <= '1' when (pull_mode and m_valve_open = '1') else '0';
    i_valve_o_open <= '1' when (push_mode and m_valve_open = '1') else '0';
    i_valve_i_open <= '1' when (push_mode and t_valve_open = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_VALVE: FLOAT_OUTLET_MANIFOLD_VALVE             -- 
        generic map (                                -- 
            FIXED_CLOSE     => O_FIXED_CLOSE       , --
            FIXED_FLOW_OPEN => O_FIXED_FLOW_OPEN   , --
            FIXED_POOL_OPEN => O_FIXED_POOL_OPEN   , --
            USE_PUSH_RSV    => USE_M_PUSH_RSV      , --
            USE_POOL_PULL   => USE_T_PULL_BUF      , --
            COUNT_BITS      => XFER_COUNT_BITS     , -- 
            SIZE_BITS       => XFER_SIZE_BITS        -- 
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            RESET           => reset               , -- In  :
            PAUSE           => T_REQ_PAUSE         , -- In  :
            STOP            => T_REQ_STOP          , -- In  :
            INTAKE_OPEN     => o_valve_i_open      , -- In  :
            OUTLET_OPEN     => o_valve_o_open      , -- In  :
            FLOW_READY_LEVEL=> O_FLOW_LEVEL        , -- In  :
            POOL_READY_LEVEL=> T_PULL_BUF_LEVEL    , -- In  :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VALID  => M_PUSH_FIN_VALID    , -- In  :
            PUSH_FIN_LAST   => M_PUSH_FIN_LAST     , -- In  :
            PUSH_FIN_SIZE   => M_PUSH_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PUSH_RSV_VALID  => M_PUSH_RSV_VALID    , -- In  :
            PUSH_RSV_LAST   => M_PUSH_RSV_LAST     , -- In  :
            PUSH_RSV_SIZE   => M_PUSH_RSV_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            FLOW_PULL_VALID => T_PULL_FIN_VALID    , -- In  :
            FLOW_PULL_LAST  => T_PULL_FIN_LAST     , -- In  :
            FLOW_PULL_SIZE  => T_PULL_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY      => O_FLOW_READY        , -- Out :
            FLOW_PAUSE      => O_FLOW_PAUSE        , -- Out :
            FLOW_STOP       => O_FLOW_STOP         , -- Out :
            FLOW_LAST       => O_FLOW_LAST         , -- Out :
            FLOW_SIZE       => O_FLOW_SIZE         , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Counter.
        ---------------------------------------------------------------------------
            FLOW_COUNT      => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            PAUSED          => open                , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            POOL_PULL_RESET => T_PULL_BUF_RESET    , -- In  :
            POOL_PULL_VALID => T_PULL_BUF_VALID    , -- In  :
            POOL_PULL_LAST  => T_PULL_BUF_LAST     , -- In  :
            POOL_PULL_SIZE  => T_PULL_BUF_SIZE     , -- In  :
            POOL_READY      => T_PULL_BUF_READY    , -- Out :
            POOL_COUNT      => open                  -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_VALVE: FLOAT_INTAKE_MANIFOLD_VALVE             --
        generic map (                                -- 
            FIXED_CLOSE     => I_FIXED_CLOSE       , --
            FIXED_FLOW_OPEN => I_FIXED_FLOW_OPEN   , --
            FIXED_POOL_OPEN => I_FIXED_POOL_OPEN   , --
            USE_PULL_RSV    => USE_M_PULL_RSV      , --
            USE_POOL_PUSH   => USE_T_PUSH_BUF      , --
            COUNT_BITS      => XFER_COUNT_BITS     , -- 
            SIZE_BITS       => XFER_SIZE_BITS        -- 
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            RESET           => reset               , -- In  :
            PAUSE           => T_REQ_PAUSE         , -- In  :
            STOP            => T_REQ_STOP          , -- In  :
            INTAKE_OPEN     => i_valve_i_open      , -- In  :
            OUTLET_OPEN     => i_valve_o_open      , -- In  :
            POOL_SIZE       => I_BUF_SIZE          , -- In  :
            FLOW_READY_LEVEL=> I_FLOW_LEVEL        , -- In  :
            POOL_READY_LEVEL=> T_PUSH_BUF_LEVEL    , -- In  :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PULL_FIN_VALID  => M_PULL_FIN_VALID    , -- In  :
            PULL_FIN_LAST   => M_PULL_FIN_LAST     , -- In  :
            PULL_FIN_SIZE   => M_PULL_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PULL_RSV_VALID  => M_PULL_RSV_VALID    , -- In  :
            PULL_RSV_LAST   => M_PULL_RSV_LAST     , -- In  :
            PULL_RSV_SIZE   => M_PULL_RSV_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            FLOW_PUSH_VALID => T_PUSH_FIN_VALID    , -- In  :
            FLOW_PUSH_LAST  => T_PUSH_FIN_LAST     , -- In  :
            FLOW_PUSH_SIZE  => T_PUSH_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY      => I_FLOW_READY        , -- Out :
            FLOW_PAUSE      => I_FLOW_PAUSE        , -- Out :
            FLOW_STOP       => I_FLOW_STOP         , -- Out :
            FLOW_LAST       => I_FLOW_LAST         , -- Out :
            FLOW_SIZE       => I_FLOW_SIZE         , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Counter.
        ---------------------------------------------------------------------------
            FLOW_COUNT      => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            PAUSED          => open                , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            POOL_PUSH_RESET => T_PUSH_BUF_RESET    , -- In  :
            POOL_PUSH_VALID => T_PUSH_BUF_VALID    , -- In  :
            POOL_PUSH_LAST  => T_PUSH_BUF_LAST     , -- In  :
            POOL_PUSH_SIZE  => T_PUSH_BUF_SIZE     , -- In  :
            POOL_READY      => T_PUSH_BUF_READY    , -- Out :
            POOL_COUNT      => open                  -- Out :
        );                                           -- 
end RTL;
