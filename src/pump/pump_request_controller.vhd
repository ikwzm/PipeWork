-----------------------------------------------------------------------------------
--!     @file    pump_request_controller.vhd
--!     @brief   PUMP REQUEST CONTROLLER
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
--! @brief PUMP REQUEST CONTROLLER
-----------------------------------------------------------------------------------
entity  PUMP_REQUEST_CONTROLLER is
    generic (
        PUSH_VALID          : --! @brief PUSH VALID :
                              --! レスポンダ側からリクエスタ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PUSH_VALID=1でデータ転送を行う.
                              --! * PUSH_VALID=0でデータ転送を行わない.
                              integer range 0 to 1:= 1;
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
        T_XFER_MAX_SIZE     : --! @brief Transfer Maximum Size from responder :
                              --! レスポンダ側が想定している一回の転送時の最大
                              --! バイト数を２のべき乗で指定する.
                              --! リクエスタ側で想定している一回の転送時の最大
                              --! バイト数ではない事に注意.
                              integer :=  4;
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
        USE_T_PUSH_RSV      : --! @brief USE PUSH RESERVE SIGNALS :
                              --! フローカウンタの加算に T_PUSH_RSV_SIZE を使うか 
                              --! T_PUSH_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        USE_M_PULL_BUF      : --! @brief USE PULL BUFFER  SIGNALS :
                              --! プールカウンタの減算に M_PULL_BUF_SIZE を使うか 
                              --! M_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        USE_T_PULL_RSV      : --! @brief USE PULL RESERVE SIGNALS :
                              --! フローカウンタの減算に T_PULL_RSV_SIZE を使うか 
                              --! T_PULL_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        USE_M_PUSH_BUF      : --! @brief USE PUSH BUFFER  SIGNALS :
                              --! プールカウンタの加算に M_PUSH_BUF_SIZE を使うか 
                              --! M_ACK_SIZE を使うかを指定する.
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
    -- Request to Requester Signals.
    -------------------------------------------------------------------------------
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
                              --! * REQ_LAST=1の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_LAST 信号をアサートする.
                              --! * REQ_LAST=0の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_NEXT 信号をアサートする.
                              out std_logic;
        M_REQ_VALID         : --! @brief Request Valid signal to requester  :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              --! * この信号のアサートでもってトランザクションを開始する.
                              --! * 一度この信号をアサートすると Acknowledge を返す
                              --!   まで、この信号はアサートされなくてはならない.
                              out std_logic;
        M_REQ_READY         : --! @brief Request Ready signal from requester :
                              --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Acknowledge from Requester Signals.
    -------------------------------------------------------------------------------
        M_ACK_VALID         : --! @brief Acknowledge Valid signal from requester :
                              --! 上記の Command Request の応答信号.
                              --! 下記の 各種 Acknowledge 信号が有効である事を示す.
                              --! * この信号のアサートでもって、Command Request が
                              --!   受け付けられたことを示す. ただし、あくまでも 
                              --!   Request が受け付けられただけであって、必ずしも
                              --!   トランザクションが完了したわけではないことに注意.
                              --! * この信号は Request につき１クロックだけアサート
                              --!   される.
                              --! * この信号がアサートされたら、アプリケーション側
                              --!   は速やかに REQ_VAL 信号をネゲートして Request 
                              --!   を取り下げるか、REQ_VALをアサートしたままで次の 
                              --!   Request 情報を用意しておかなければならない.
                              in  std_logic;
        M_ACK_NEXT          : --! @brief Acknowledge with need Next transaction from requester :
                              --! すべてのトランザクションが終了かつ REQ_LAST=0 の
                              --! 場合、この信号がアサートされる.
                              in  std_logic;
        M_ACK_LAST          : --! @brief Acknowledge with Last transaction from requester :
                              --! すべてのトランザクションが終了かつ REQ_LAST=1 の
                              --! 場合、この信号がアサートされる.
                              in  std_logic;
        M_ACK_ERROR         : --! @brief Acknowledge with Error from requester :
                              --! トランザクション中になんらかのエラーが発生した場
                              --! 合、この信号がアサートされる.
                              in  std_logic;
        M_ACK_STOP          : --! @brief Acknowledge with Stop operation from requester :
                              --! トランザクションが中止された場合、この信号がアサ
                              --! ートされる.
                              in  std_logic;
        M_ACK_NONE          : --! @brief Acknowledge with None transfer from requester :
                              --! REQ_SIZE=0 の Request だった場合、この信号がアサ
                              --! ートされる.
                              in  std_logic;
        M_ACK_SIZE          : --! @brief Acknowledge transfer Size from requester :
                              --! 転送するバイト数を示す.
                              --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で
                              --! 示されるバイト数分を加算/減算すると良い.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- Status from Requester Signals.
    -------------------------------------------------------------------------------
        M_XFER_BUSY         : --! @brief Transfer Busy.
                              --! データ転送中であることを示すフラグ.
                              in  std_logic;
        M_XFER_ERROR        : --! @brief Transfer Error.
                              --! データの転送中にエラーが発生した事を示す.
                              in  std_logic := '0';
        M_XFER_DONE         : --! @brief Transfer Done.
                              --! データ転送中かつ、次のクロックで M_XFER_BUSY が
                              --! ネゲートされる事を示すフラグ.
                              --! * ただし、M_XFER_BUSY のネゲート前に 必ずしもこの
                              --!   信号がアサートされるわけでは無い.
                              in  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
        M_PULL_BUF_RESET    : --! @brief Pull Buffer Reset from requester :
                              in  std_logic := '0';
        M_PULL_BUF_VALID    : --! @brief Pull Buffer Valid from requester :
                              in  std_logic := '0';
        M_PULL_BUF_LAST     : --! @brief Pull Buffer Last  from requester :
                              in  std_logic := '0';
        M_PULL_BUF_SIZE     : --! @brief Pull Buffer Size  from requester :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PULL_BUF_READY    : --! @brief Pull Buffer Ready to   requester :
                              out std_logic;
        M_PULL_BUF_LEVEL    : --! @brief Pull Buffer Ready Level :
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
        M_PUSH_BUF_RESET    : --! @brief Push Buffer Reset from requester :
                              in  std_logic := '0';
        M_PUSH_BUF_VALID    : --! @brief Push Buffer Valid from requester :
                              in  std_logic := '0';
        M_PUSH_BUF_LAST     : --! @brief Push Buffer Last  from requester :
                              in  std_logic := '0';
        M_PUSH_BUF_SIZE     : --! @brief Push Buffer Size  from requester :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PUSH_BUF_READY    : --! @brief Push Buffer Ready to   requester :
                              out std_logic;
        M_PUSH_BUF_LEVEL    : --! @brief Push Buffer Ready Level :
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals to Requester.
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
    -- Intake Valve Signals to Requester.
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
        I_BUF_SIZE          : --! @brief Intake Buffer Size :
                              --! 入力用プールの総容量を指定する.
                              --! I_FLOW_SIZE を求めるのに使用する.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Request from Responder.
    -------------------------------------------------------------------------------
        T_REQ_START         : --! @brief Request Start signal from responder :
                              --! 転送開始を指示する.
                              in  std_logic;
        T_REQ_ADDR          : --! @brief Request Address from responder :
                              --! 転送開始アドレスを入力する.  
                              in  std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE          : --! @brief Request Transfer Size from responder :
                              --! 転送したいバイト数を入力する. 
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR       : --! @brief Request Buffer Pointer from responder :
                              --! 転送時のバッファポインタを入力する.
                              in  std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE          : --! @brief Request Mode signals from responder :
                              --! 転送開始時に指定された各種情報を入力する.
                              in  std_logic_vector(MODE_BITS-1 downto 0);
        T_REQ_DIR           : --! @brief Request Direction signals from responder :
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
        T_REQ_DONE          : --! @brief Request Done signal from responder :
                              --! トランザクションの終了を指示する.
                              in  std_logic;
        T_REQ_STOP          : --! @brief Request Done signal from responder :
                              --! トランザクションの中止を指示する.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Response to Responder.
    -------------------------------------------------------------------------------
        T_RES_START         : --! @brief Request Start signal to responder :
                              --! 転送を開始したことを示す出力信号.
                              out std_logic;
        T_RES_DONE          : --! @brief Transaction Done signal to responder :
                              --! 転送を終了したことを示す出力信号.
                              out std_logic;
        T_RES_ERROR         : --! @brief Transaction Error signal to responder :
                              --! 転送を異常終了したことを示す出力信号.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals from Responder.
    -------------------------------------------------------------------------------
        T_PUSH_FIN_VALID    : --! @brief Push Final Valid from responder :
                              --! T_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PUSH_FIN_LAST     : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PUSH_FIN_ERR      : --! @brief Push Final Error flags :
                              --! レスポンダ側からのデータ入力中にエラーが発生した
                              --! ことを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PUSH_FIN_SIZE     : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PUSH_RSV_VALID    : --! @brief Push Reserve Valid from responder :
                              --! T_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic := '0';
        T_PUSH_RSV_LAST     : --! @brief Push Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ入力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic := '0';
        T_PUSH_RSV_ERR      : --! @brief Push Reserve Error flags :
                              --! レスポンダ側からのデータ入力中にエラーが発生した
                              --! ことを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic := '0';
        T_PUSH_RSV_SIZE     : --! @brief Push Reserve Size :
                              --! レスポンダ側からの"予定された"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from Responder.
    -------------------------------------------------------------------------------
        T_PULL_FIN_VALID    : --! @brief Pull Final Valid from responder :
                              --! T_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PULL_FIN_LAST     : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PULL_FIN_ERR      : --! @brief Pull Final Error flags :
                              --! レスポンダ側からのデータ出力中にエラーが発生した
                              --! ことを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PULL_FIN_SIZE     : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PULL_RSV_VALID    : --! @brief Pull Reserve Valid from responder :
                              --! T_PULL_RSV_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが先行(Precede)モードで無い場合は
                              --!   未使用.
                              in  std_logic := '0';
        T_PULL_RSV_LAST     : --! @brief Pull Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic := '0';
        T_PULL_RSV_ERR      : --! @brief Pull Reserve Error flags :
                              --! レスポンダ側からのデータ出力中にエラーが発生した
                              --! ことを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic := '0';
        T_PULL_RSV_SIZE     : --! @brief Pull Reserve Size :
                              --! レスポンダ側からの"予定された"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0')
    );
end PUMP_REQUEST_CONTROLLER;
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
use     PIPEWORK.COMPONENTS.COUNT_DOWN_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROL_REGISTER;
architecture RTL of PUMP_REQUEST_CONTROLLER is
    ------------------------------------------------------------------------------
    -- アドレスレジスタ関連の信号.
    ------------------------------------------------------------------------------
    signal   addr_load          : std_logic_vector(ADDR_BITS-1 downto 0);
    function CALC_ADDR_UP_BEN return std_logic_vector is
        variable up_ben    : std_logic_vector(ADDR_BITS-1 downto 0);
    begin
        for i in up_ben'range loop
            if (i <= T_XFER_MAX_SIZE) then
                up_ben(i) := '1';
            else
                up_ben(i) := '0';
            end if;
        end loop;
        return up_ben;
    end function;
    constant  ADDR_UP_BEN       : std_logic_vector(ADDR_BITS-1 downto 0) := CALC_ADDR_UP_BEN;
    ------------------------------------------------------------------------------
    -- サイズレジスタ関連の信号.
    ------------------------------------------------------------------------------
    signal    size_load         : std_logic_vector(SIZE_BITS-1 downto 0);
    ------------------------------------------------------------------------------
    -- バッファポインタ関連の信号.
    ------------------------------------------------------------------------------
    signal    buf_ptr_load      : std_logic_vector(BUF_DEPTH-1 downto 0);
    constant  buf_ptr_up        : std_logic_vector(BUF_DEPTH-1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- モードレジスタ関連の信号.
    -------------------------------------------------------------------------------
    signal    mode_load         : std_logic_vector(MODE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- ステータスレジスタ関連の信号.
    -------------------------------------------------------------------------------
    constant  STAT_BITS         : integer := 1;
    signal    stat_load         : std_logic_vector(STAT_BITS-1 downto 0);
    constant  stat_all0         : std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
    signal    stat_i            : std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
    signal    stat_o            : std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
    ------------------------------------------------------------------------------
    -- リセットコントロールレジスタ関連の信号.
    ------------------------------------------------------------------------------
    constant  reset_load        : std_logic := '0';
    constant  reset_data        : std_logic := '0';
    signal    reset             : std_logic;
    ------------------------------------------------------------------------------
    -- ストップコントロールレジスタ関連の信号.
    ------------------------------------------------------------------------------
    signal    stop_load         : std_logic;
    constant  stop_data         : std_logic := '1';
    signal    stop              : std_logic;
    signal    push_stop         : boolean;
    signal    pull_stop         : boolean;
    ------------------------------------------------------------------------------
    -- 一時停止コントロールレジスタ関連の信号.
    ------------------------------------------------------------------------------
    constant  pause_load        : std_logic := '0';
    constant  pause_data        : std_logic := '0';
    signal    pause             : std_logic;
    -------------------------------------------------------------------------------
    -- その他コントロールレジスタ関連の信号.
    -------------------------------------------------------------------------------
    signal    m_running         : std_logic;
    signal    m_valve_open      : std_logic;
    signal    t_valve_open      : std_logic;
    signal    o_valve_i_open    : std_logic;
    signal    o_valve_o_open    : std_logic;
    signal    i_valve_i_open    : std_logic;
    signal    i_valve_o_open    : std_logic;
    signal    tran_dir          : std_logic;
    signal    tran_last         : std_logic;
    signal    push_mode         : boolean;
    signal    pull_mode         : boolean;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ADDR_REGS: COUNT_UP_REGISTER                     -- 
        generic map (                                -- 
            VALID           => ADDR_VALID          , -- 
            BITS            => ADDR_BITS           , -- 
            REGS_BITS       => ADDR_BITS             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            REGS_WEN        => addr_load           , -- In  :
            REGS_WDATA      => T_REQ_ADDR          , -- In  :
            REGS_RDATA      => open                , -- Out :
            UP_ENA          => m_running           , -- In  :
            UP_VAL          => M_ACK_VALID         , -- In  :
            UP_BEN          => ADDR_UP_BEN         , -- In  :
            UP_SIZE         => M_ACK_SIZE          , -- In  :
            COUNTER         => M_REQ_ADDR            -- Out :
        );
    addr_load   <= (others => '1') when (T_REQ_START = '1') else (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    SIZE_REGS: COUNT_DOWN_REGISTER                   -- 
        generic map (                                -- 
            VALID           => SIZE_VALID          , -- 
            BITS            => SIZE_BITS           , -- 
            REGS_BITS       => SIZE_BITS             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            REGS_WEN        => size_load           , -- In  :
            REGS_WDATA      => T_REQ_SIZE          , -- In  :
            REGS_RDATA      => open                , -- Out :
            DN_ENA          => m_running           , -- In  :
            DN_VAL          => M_ACK_VALID         , -- In  :
            DN_SIZE         => M_ACK_SIZE          , -- In  :
            COUNTER         => M_REQ_SIZE          , -- Out :
            ZERO            => open                , -- Out :
            NEG             => open                  -- Out :
       );
    size_load <= (others => '1') when (T_REQ_START = '1') else (others => '0');
    -------------------------------------------------------------------------------
    -- 
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
            REGS_WEN        => buf_ptr_load        , -- In  :
            REGS_WDATA      => T_REQ_BUF_PTR       , -- In  :
            REGS_RDATA      => open                , -- Out :
            UP_ENA          => m_running           , -- In  :
            UP_VAL          => M_ACK_VALID         , -- In  :
            UP_BEN          => buf_ptr_up          , -- In  :
            UP_SIZE         => M_ACK_SIZE          , -- In  :
            COUNTER         => M_REQ_BUF_PTR         -- Out :
       );
    buf_ptr_load <= (others => '1') when (T_REQ_START = '1') else (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    CTRL_REGS: PUMP_CONTROL_REGISTER                 -- 
        generic map (                                -- 
            MODE_BITS       => MODE_BITS           , -- 
            STAT_BITS       => STAT_BITS             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            RESET_L         => reset_load          , -- In  :
            RESET_D         => reset_data          , -- In  :
            RESET_Q         => reset               , -- Out :
            START_L         => T_REQ_START         , -- In  :
            START_D         => T_REQ_START         , -- In  :
            START_Q         => open                , -- Out :
            STOP_L          => stop_load           , -- In  :
            STOP_D          => stop_data           , -- In  :
            STOP_Q          => stop                , -- Out :
            PAUSE_L         => pause_load          , -- In  :
            PAUSE_D         => pause_data          , -- In  :
            PAUSE_Q         => pause               , -- Out :
            FIRST_L         => T_REQ_START         , -- In  :
            FIRST_D         => T_REQ_FIRST         , -- In  :
            FIRST_Q         => open                , -- Out :
            LAST_L          => T_REQ_START         , -- In  :
            LAST_D          => T_REQ_LAST          , -- In  :
            LAST_Q          => tran_last           , -- Out :
            DONE_EN_L       => T_REQ_START         , -- In  :
            DONE_EN_D       => stat_all0(0)        , -- In  :
            DONE_EN_Q       => open                , -- Out :
            DONE_ST_L       => T_REQ_START         , -- In  :
            DONE_ST_D       => stat_all0(0)        , -- In  :
            DONE_ST_Q       => open                , -- Out :
            ERR_ST_L        => T_REQ_START         , -- In  :
            ERR_ST_D        => stat_all0(0)        , -- In  :
            ERR_ST_Q        => open                , -- Out :
            MODE_L          => mode_load           , -- In  :
            MODE_D          => T_REQ_MODE          , -- In  :
            MODE_Q          => M_REQ_MODE          , -- Out :
            STAT_L          => stat_load           , -- In  :
            STAT_D          => stat_all0           , -- In  :
            STAT_Q          => stat_o              , -- Out :
            STAT_I          => stat_i              , -- In  :
            REQ_VALID       => M_REQ_VALID         , -- Out :
            REQ_FIRST       => M_REQ_FIRST         , -- Out :
            REQ_LAST        => M_REQ_LAST          , -- Out :
            REQ_READY       => M_REQ_READY         , -- In  :
            ACK_VALID       => M_ACK_VALID         , -- In  :
            ACK_ERROR       => M_ACK_ERROR         , -- In  :
            ACK_NEXT        => M_ACK_NEXT          , -- In  :
            ACK_LAST        => M_ACK_LAST          , -- In  :
            ACK_STOP        => M_ACK_STOP          , -- In  :
            ACK_NONE        => M_ACK_NONE          , -- In  :
            XFER_BUSY       => M_XFER_BUSY         , -- In  :
            XFER_DONE       => M_XFER_DONE         , -- In  :
            XFER_ERROR      => M_XFER_ERROR        , -- In  :
            VALVE_OPEN      => m_valve_open        , -- Out :
            TRAN_START      => T_RES_START         , -- Out :
            TRAN_DONE       => T_RES_DONE          , -- Out :
            TRAN_ERROR      => T_RES_ERROR         , -- Out :
            TRAN_BUSY       => m_running             -- Out :
        );
    push_stop <= (push_mode) and 
                 (O_FIXED_CLOSE /= 0 or O_FIXED_FLOW_OPEN /= 0) and
                 ((                        T_PUSH_FIN_ERR = '1' and T_PUSH_FIN_VALID = '1') or
                  (USE_T_PUSH_RSV /= 0 and T_PUSH_RSV_ERR = '1' and T_PUSH_RSV_VALID = '1'));
    pull_stop <= (pull_mode) and 
                 (I_FIXED_CLOSE /= 0 or I_FIXED_FLOW_OPEN /= 0) and
                 ((                        T_PULL_FIN_ERR = '1' and T_PULL_FIN_VALID = '1') or
                  (USE_T_PULL_RSV /= 0 and T_PULL_RSV_ERR = '1' and T_PULL_RSV_VALID = '1'));
    stop_load <= '1' when (push_stop or pull_stop or T_REQ_STOP = '1') else '0';
    mode_load <= (others => '1') when (T_REQ_START = '1') else (others => '0');
    stat_load <= (others => '1') when (T_REQ_START = '1') else (others => '0');
    stat_i    <= (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                t_valve_open <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                t_valve_open <= '0';
            elsif (T_REQ_DONE  = '1' and tran_last = '1') or
                  (T_REQ_STOP  = '1') then
                t_valve_open <= '0';
            elsif (T_REQ_START = '1') then
                t_valve_open <= '1';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                tran_dir  <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                tran_dir  <= '0';
            elsif (T_REQ_START = '1') then
                tran_dir  <= T_REQ_DIR;
            end if;
        end if;
    end process;
    push_mode   <= (PUSH_VALID /= 0 and PULL_VALID  = 0) or
                   (PUSH_VALID /= 0 and PULL_VALID /= 0 and tran_dir  = '1');
    pull_mode   <= (PULL_VALID /= 0 and PUSH_VALID  = 0) or
                   (PULL_VALID /= 0 and PUSH_VALID /= 0 and tran_dir  = '0');
    M_REQ_DIR   <= '1' when (push_mode) else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    o_valve_o_open <= '1' when (push_mode and m_valve_open = '1') else '0';
    o_valve_i_open <= '1' when (push_mode and t_valve_open = '1') else '0';
    i_valve_o_open <= '1' when (pull_mode and t_valve_open = '1') else '0';
    i_valve_i_open <= '1' when (pull_mode and m_valve_open = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_VALVE: FLOAT_OUTLET_MANIFOLD_VALVE             -- 
        generic map (                                --
            FIXED_CLOSE     => O_FIXED_CLOSE       , --
            FIXED_FLOW_OPEN => O_FIXED_FLOW_OPEN   , --
            FIXED_POOL_OPEN => O_FIXED_POOL_OPEN   , --
            USE_PUSH_RSV    => USE_T_PUSH_RSV      , --
            USE_POOL_PULL   => USE_M_PULL_BUF      , --
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
            PAUSE           => pause               , -- In  :
            STOP            => stop                , -- In  :
            INTAKE_OPEN     => o_valve_i_open      , -- In  :
            OUTLET_OPEN     => o_valve_o_open      , -- In  :
            FLOW_READY_LEVEL=> O_FLOW_LEVEL        , -- In  :
            POOL_READY_LEVEL=> M_PULL_BUF_LEVEL    , -- In  :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VALID  => T_PUSH_FIN_VALID    , -- In  :
            PUSH_FIN_LAST   => T_PUSH_FIN_LAST     , -- In  :
            PUSH_FIN_SIZE   => T_PUSH_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PUSH_RSV_VALID  => T_PUSH_RSV_VALID    , -- In  :
            PUSH_RSV_LAST   => T_PUSH_RSV_LAST     , -- In  :
            PUSH_RSV_SIZE   => T_PUSH_RSV_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            FLOW_PULL_VALID => M_ACK_VALID         , -- In  :
            FLOW_PULL_LAST  => M_ACK_LAST          , -- In  :
            FLOW_PULL_SIZE  => M_ACK_SIZE          , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY      => O_FLOW_READY        , -- Out :
            FLOW_PAUSE      => O_FLOW_PAUSE        , -- Out :
            FLOW_STOP       => O_FLOW_STOP         , -- Out :
            FLOW_LAST       => O_FLOW_LAST         , -- Out :
            FLOW_SIZE       => O_FLOW_SIZE         , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Flow Counter.
        ---------------------------------------------------------------------------
            FLOW_COUNT      => open                , -- Out :
            FLOW_ZERO       => open                , -- Out :
            FLOW_POS        => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            PAUSED          => open                , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Pool Size Signals.
        ---------------------------------------------------------------------------
            POOL_PULL_RESET => M_PULL_BUF_RESET    , -- In  :
            POOL_PULL_VALID => M_PULL_BUF_VALID    , -- In  :
            POOL_PULL_LAST  => M_PULL_BUF_LAST     , -- In  :
            POOL_PULL_SIZE  => M_PULL_BUF_SIZE     , -- In  :
            POOL_READY      => M_PULL_BUF_READY    , -- Out :
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
            USE_PULL_RSV    => USE_T_PULL_RSV      , --
            USE_POOL_PUSH   => USE_M_PUSH_BUF      , --
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
            PAUSE           => pause               , -- In  :
            STOP            => stop                , -- In  :
            INTAKE_OPEN     => i_valve_i_open      , -- In  :
            OUTLET_OPEN     => i_valve_o_open      , -- In  :
            POOL_SIZE       => I_BUF_SIZE          , -- In  :
            FLOW_READY_LEVEL=> I_FLOW_LEVEL        , -- In  :
            POOL_READY_LEVEL=> M_PUSH_BUF_LEVEL    , -- In  :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PULL_FIN_VALID  => T_PULL_FIN_VALID    , -- In  :
            PULL_FIN_LAST   => T_PULL_FIN_LAST     , -- In  :
            PULL_FIN_SIZE   => T_PULL_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PULL_RSV_VALID  => T_PULL_RSV_VALID    , -- In  :
            PULL_RSV_LAST   => T_PULL_RSV_LAST     , -- In  :
            PULL_RSV_SIZE   => T_PULL_RSV_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            FLOW_PUSH_VALID => M_ACK_VALID         , -- In  :
            FLOW_PUSH_LAST  => M_ACK_LAST          , -- In  :
            FLOW_PUSH_SIZE  => M_ACK_SIZE          , -- In  :
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
            FLOW_ZERO       => open                , -- Out :
            FLOW_POS        => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            PAUSED          => open                , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Pool Size Signals.
        ---------------------------------------------------------------------------
            POOL_PUSH_RESET => M_PUSH_BUF_RESET    , -- In  :
            POOL_PUSH_VALID => M_PUSH_BUF_VALID    , -- In  :
            POOL_PUSH_LAST  => M_PUSH_BUF_LAST     , -- In  :
            POOL_PUSH_SIZE  => M_PUSH_BUF_SIZE     , -- In  :
            POOL_READY      => M_PUSH_BUF_READY    , -- Out :
            POOL_COUNT      => open                  -- Out :
        );                                           -- 
end RTL;
