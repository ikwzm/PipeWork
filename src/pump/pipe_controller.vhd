-----------------------------------------------------------------------------------
--!     @file    pipe_controller.vhd
--!     @brief   PIPE CONTROLLER
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
--! @brief   PIPE CORE UNIT
-----------------------------------------------------------------------------------
entity  PIPE_CONTROLLER is
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
        T_CLK_RATE          : --! @brief RESPONDER CLOCK RATE :
                              --! M_CLK_RATEとペアでレスポンダ側のクロック(T_CLK)とリク
                              --! エスト側のクロック(M_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        M_CLK_RATE          : --! @brief REQUESTER CLOCK RATE :
                              --! T_CLK_RATEとペアでレスポンダ側のクロック(T_CLK)とリク
                              --! エスト側のクロック(M_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        ADDR_BITS           : --! @brief Request Address Bits :
                              --! REQ_ADDR信号のビット数を指定する.
                              integer := 32;
        ADDR_VALID          : --! @brief Request Address Valid :
                              --! REQ_ADDR信号を有効にするかどうかを指定する.
                              --! * ADDR_VALID=0で無効.
                              --! * ADDR_VALID=1で有効.
                              integer range 0 to 1 := 1;
        SIZE_BITS           : --! @brief Transfer Size Bits :
                              --! 各種サイズ信号のビット幅を指定する.
                              integer := 32;
        SIZE_VALID          : --! @brief Request Size Valid :
                              --! REQ_SIZE信号を有効にするかどうかを指定する.
                              --! * SIZE_VALID=0で無効.
                              --! * SIZE_VALID=1で有効.
                              integer range 0 to 1 :=  1;
        MODE_BITS           : --! @brief Request Mode Bits :
                              --! REQ_MODE信号のビット数を指定する.
                              integer := 32;
        XFER_COUNT_BITS     : --! @brief Transfer Counter Bits :
                              --! このモジュール内で使用している各種カウンタのビット
                              --! 幅を指定する.
                              integer := 12;
        XFER_SIZE_BITS      : --! @brief Transfer Size Bits :
                              --! １回の転送バイト数入力信号(FLOW_SIZE/PULL_SIZE/
                              --! PUSH_SIZEなど)のビット幅を指定する.
                              integer := 12;
        BUF_DEPTH           : --! @brief Buffer Depth :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        M_O_FIXED_CLOSE     : --! @brief OUTLET VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_O_FIXED_FLOW_OPEN : --! @brief OUTLET VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_O_FIXED_POOL_OPEN : --! @brief OUTLET FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_I_FIXED_CLOSE     : --! @brief INTAKE VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_I_FIXED_FLOW_OPEN : --! @brief INTAKE VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_I_FIXED_POOL_OPEN : --! @brief INTAKE FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_O_FIXED_CLOSE     : --! @brief OUTLET VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_O_FIXED_FLOW_OPEN : --! @brief OUTLET VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_O_FIXED_POOL_OPEN : --! @brief OUTLET FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_I_FIXED_CLOSE     : --! @brief INTAKE VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_I_FIXED_FLOW_OPEN : --! @brief INTAKE VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_I_FIXED_POOL_OPEN : --! @brief INTAKE FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M2T_PUSH_RSV_VALID  : --! @brief USE PUSH RESERVE SIGNALS :
                              --! フローカウンタの加算に M_PUSH_RSV_SIZE を使うか 
                              --! M_PUSH_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        M2T_PULL_RSV_VALID  : --! @brief USE PULL RESERVE SIGNALS :
                              --! フローカウンタの減算に M_PULL_RSV_SIZE を使うか 
                              --! M_PULL_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        M2T_PUSH_BUF_VALID  : --! @brief USE PUSH BUFFER  SIGNALS :
                              --! プールカウンタの加算に M_PUSH_BUF_SIZE を使うか 
                              --! M_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        M2T_PULL_BUF_VALID  : --! @brief USE PULL BUFFER  SIGNALS :
                              --! プールカウンタの減算に M_PULL_BUF_SIZE を使うか 
                              --! M_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        M2T_PUSH_FIN_DELAY  : --! @brief Requester to Responder Pull Final Size Delay Cycle :
                              integer :=  0;
        T2M_PUSH_RSV_VALID  : --! @brief USE PUSH RESERVE SIGNALS :
                              --! フローカウンタの加算に T_PUSH_RSV_SIZE を使うか 
                              --! T_PUSH_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        T2M_PULL_RSV_VALID  : --! @brief USE PULL RESERVE SIGNALS :
                              --! フローカウンタの減算に T_PULL_RSV_SIZE を使うか 
                              --! T_PULL_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        T2M_PUSH_BUF_VALID  : --! @brief USE PUSH BUFFER  SIGNALS :
                              --! プールカウンタの加算に T_PUSH_BUF_SIZE を使うか 
                              --! T_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        T2M_PULL_BUF_VALID  : --! @brief USE PULL BUFFER  SIGNALS :
                              --! プールカウンタの減算に T_PULL_BUF_SIZE を使うか 
                              --! T_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        T2M_PUSH_FIN_DELAY  : --! @brief Responder to Requester Pull Final Size Delay Cycle :
                              integer :=  0;
        T_XFER_MAX_SIZE     : --! @brief Responder Transfer Max Size :
                              integer := 12
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号.
    -------------------------------------------------------------------------------
        RST                 : --! @brief RESET :
                              --! 非同期リセット信号(ハイ・アクティブ).
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Responder Side Clock.
    -------------------------------------------------------------------------------
        T_CLK               : --! @brief Responder Clock :
                              --! クロック信号
                              in  std_logic;
        T_CLR               : --! @brief Responder Side Syncronouse Reset :
                              --! 同期リセット信号.アクティブハイ.
                              in  std_logic;
        T_CKE               : --! @brief Responder Side Clock Enable :
                              --! レスポンダ側のクロック(T_CLK)の立上りが有効である
                              --! ことを示す信号.
                              --! * この信号は T_CLK_RATE > 1 の時に、T_CLK と M_CLK 
                              --!   の位相関係を示す時に使用する.
                              --! * T_CLKの立上り時とM_CLKの立上り時が同じ時にアサー
                              --!   トするように入力されなければならない.
                              --! * この信号は T_CLK_RATE > 1 かつ M_CLK_RATE = 1の
                              --!   時のみ有効. それ以外は未使用.
                              in  std_logic := '1';
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
                              in  std_logic;
        T_REQ_LAST          : --! @brief Request Last transaction from responder :
                              --! 最後のトランザクションであることを示す.
                              --! * T_REQ_LAST=1の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   T_ACK_LAST 信号をアサートする.
                              --! * T_REQ_LAST=0の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   T_ACK_NEXT 信号をアサートする.
                              in  std_logic;
        T_REQ_VALID         : --! @brief Request Valid signal from responder  :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              --! * この信号のアサートでもってトランザクションを開始する.
                              --! * 一度この信号をアサートすると Acknowledge を返す
                              --!   まで、この信号はアサートされなくてはならない.
                              in  std_logic;
        T_REQ_READY         : --! @brief Request Ready signal to responder :
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
                              --! すべてのトランザクションが終了かつ T_REQ_LAST=0 の
                              --! 場合、この信号がアサートされる.
                              out std_logic;
        T_ACK_LAST          : --! @brief Acknowledge with Last transaction to responder :
                              --! すべてのトランザクションが終了かつ T_REQ_LAST=1 の
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
        T_XFER_BUSY         : --! @brief Transfer Busy from responder :
                              --! レスポンダ側がデータ転送中であることを示すフラグ.
                              in  std_logic;
        T_XFER_ERROR        : --! @brief Transfer Error from responder :
                              --! レスポンダ側がデータの転送中にエラーが発生した事
                              --! を示す.
                              in  std_logic := '0';
        T_XFER_DONE         : --! @brief Transfer Done from responder :
                              --! データ転送中かつ、次のクロックで T_XFER_BUSY が
                              --! ネゲートされる事を示すフラグ.
                              --! * ただし、T_XFER_BUSY のネゲート前に 必ずしもこの
                              --!   信号がアサートされるわけでは無い.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from/to Responder.
    -------------------------------------------------------------------------------
        T_I_FLOW_LEVEL      : --! @brief Intake Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以下の時に入力を開始する.
                              --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        T_I_BUF_SIZE        : --! @brief Intake Pool Size  :
                              --! 入力用プールの総容量を指定する.
                              --! T_I_FLOW_SIZE を求めるのに使用する.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        T_I_FLOW_READY      : --! @brief Intake Valve Flow Ready to responder :
                              --! プールバッファに T_I_FLOW_LEVEL 以下のデータ
                              --! しか無く、データの入力が可能な事を示す.
                              out std_logic;
        T_I_FLOW_PAUSE      : --! @brief Intake Valve Flow Pause to responder :
                              --! 入力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに T_I_FLOW_LEVEL を越えるデータ
                              --! が溜っていて、これ以上データが入らないことを示す.
                              out std_logic;
        T_I_FLOW_STOP       : --! @brief Intake Valve Flow Stop to responder :
                              --! 入力の中止を指示する信号.
                              out std_logic;
        T_I_FLOW_LAST       : --! @brief Intake Valve Flow Last to responder :
                              --! リクエスタ側から最後の入力を示すフラグがあったこと
                              --! を示す.
                              out std_logic;
        T_I_FLOW_SIZE       : --! @brief Intake Valve Flow Enable Size to responder :
                              --! 入力可能なバイト数
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        T_PUSH_FIN_VALID    : --! @brief Push Final Valid from responder :
                              --! T_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PUSH_FIN_LAST     : --! @brief Push Final Last flags from responder :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PUSH_FIN_ERROR    : --! @brief Push Final Error flags from responder :
                              --! レスポンダ側からのデータ入力時にエラーが発生した
                              --! ことを示すフラグ.
                              --! * 現在この信号は未使用.
                              in  std_logic := '0';
        T_PUSH_FIN_SIZE     : --! @brief Push Final Size from responder :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PUSH_RSV_VALID    : --! @brief Push Reserve Valid from responder :
                              --! T_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        T_PUSH_RSV_LAST     : --! @brief Push Reserve Last flags from responder :
                              --! レスポンダ側からの最後の"予約した"データ入力であ
                              --! ることを示す.
                              in  std_logic := '0';
        T_PUSH_RSV_ERROR    : --! @brief Push Reserve Error flags from responder :
                              --! レスポンダ側からのデータ入力時にエラーが発生した
                              --! ことを示すフラグ.
                              in  std_logic := '0';
        T_PUSH_RSV_SIZE     : --! @brief Push Reserve Size from responder :
                              --! レスポンダ側からの"予約した"入力バイト数.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PUSH_BUF_LEVEL    : --! @brief Push Buffer Ready Level :
                              --! T_PUSH_BUF_READY 信号をアサートするかしないかを
                              --! 指示するための閾値.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0) := (others => '0');
        T_PUSH_BUF_RESET    : --! @brief Push Buffer Reset from responder :
                              in  std_logic := '0';
        T_PUSH_BUF_VALID    : --! @brief Push Buffer Valid from responder :
                              --! T_PUSH_BUF_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        T_PUSH_BUF_LAST     : --! @brief Push Buffer Last  from responder :
                              --! レスポンダ側からの最後のバッファ書き込みであるこ
                              --! とを示す.
                              in  std_logic := '0';
        T_PUSH_BUF_ERROR    : --! @brief Push Buffer Error from responder :
                              --! レスポンダ側からのデータ書き込み時にエラーが発生
                              --! したことを示すフラグ.
                              in  std_logic := '0';
        T_PUSH_BUF_SIZE     : --! @brief Push Buffer Size  from responder :
                              --! レスポンダ側からのデータ書き込みサイズ.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PUSH_BUF_READY    : --! @brief Push Buffer Ready to   responder :
                              --! プールバッファに T_PUSH_BUF_LEVEL 以下のデータし
                              --! かないことを示すフラグ.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals from/to Responder.
    -------------------------------------------------------------------------------
        T_O_FLOW_LEVEL      : --! @brief Outlet Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以上の時に転送を開始する.
                              --! フローカウンタの値がこの値未満の時に転送を一時停止.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        T_O_FLOW_READY      : --! @brief Outlet Valve Flow Ready to responder :
                              --! プールバッファに T_O_FLOW_LEVEL 以上のデータがある
                              --! ことを示す.
                              out std_logic;
        T_O_FLOW_PAUSE      : --! @brief Outlet Valve Flow Pause to responder :
                              --! 出力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに T_O_FLOW_LEVEL 未満のデータしか無
                              --! いことを示す.
                              out std_logic;
        T_O_FLOW_STOP       : --! @brief Outlet Valve Flow Stop to responder :
                              --! 出力の中止を指示する信号.
                              out std_logic;
        T_O_FLOW_LAST       : --! @brief Outlet Valve Flow Last to responder :
                              --! リクエスト側から最後の入力を示すフラグがあった
                              --! ことを示す.
                              out std_logic;
        T_O_FLOW_SIZE       : --! @brief Outlet Valve Flow Enable Size to responder :
                              --! 出力可能なバイト数を出力.
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        T_PULL_FIN_VALID    : --! @brief Pull Final Valid from responder :
                              --! T_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PULL_FIN_LAST     : --! @brief Pull Final Last flags from responder :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T_PULL_FIN_ERROR    : --! @brief Pull Final Error flags from responder :
                              --! レスポンダ側からのデータ出力時にエラーが発生した
                              --! ことを示すフラグ.
                              --! * 現在この信号は未使用.
                              in  std_logic := '0';
        T_PULL_FIN_SIZE     : --! @brief Pull Final Size from responder :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PULL_RSV_VALID    : --! @brief Pull Reserve Valid from responder :
                              --! T_PULL_RSV_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        T_PULL_RSV_LAST     : --! @brief Pull Reserve Last flags from responder :
                              --! レスポンダ側からの最後の"予約した"データ出力であ
                              --! ることを示す.
                              in  std_logic := '0';
        T_PULL_RSV_ERROR    : --! @brief Pull Reserve Error flags from responder :
                              --! レスポンダ側からのデータ出力時にエラーが発生した
                              --! ことを示すフラグ.
                              in  std_logic := '0';
        T_PULL_RSV_SIZE     : --! @brief Pull Reserve Size from responder :
                              --! レスポンダ側からのデータ書き込みサイズ.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0) := (others => '0');
        T_PULL_BUF_LEVEL    : --! @brief Pull Buffer Ready Level :
                              --! T_PULL_BUF_READY 信号をアサートするかしないかを
                              --! 指示するための閾値.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        T_PULL_BUF_RESET    : --! @brief Pull Buffer Reset from responder :
                              in  std_logic := '0';
        T_PULL_BUF_VALID    : --! @brief Pull Buffer Valid from responder :
                              --! T_PULL_BUF_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        T_PULL_BUF_LAST     : --! @brief Pull Buffer Last  from responder :
                              --! レスポンダ側からのバッファからの最後のデータ読み
                              --! 出しであることを示す.
                              in  std_logic := '0';
        T_PULL_BUF_ERROR    : --! @brief Pull Buffer Error from responder :
                              --! レスポンダ側からのデータ読み出し時にエラーが発生
                              --! したことを示すフラグ.
                              in  std_logic := '0';
        T_PULL_BUF_SIZE     : --! @brief Pull Buffer Size  from responder :
                              --! レスポンダ側からのデータ読み出しサイズ.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T_PULL_BUF_READY    : --! @brief Pull Buffer Ready to   responder :
                              --! プールバッファに T_PULL_BUF_LEVEL 以上のデータが
                              --! あることを示すフラグ.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- Requester Side Clock.
    -------------------------------------------------------------------------------
        M_CLK               : --! @brief Requester Clock :
                              --! クロック信号
                              in  std_logic;
        M_CLR               : --! @brief Requester Side Syncronouse Reset :
                              --! 同期リセット信号.アクティブハイ.
                              in  std_logic;
        M_CKE               : --! @brief Requester Side Clock Enable :
                              --! リクエスト側のクロック(M_CLK)の立上りが有効である
                              --! ことを示す信号.
                              --! * この信号は M_CLK_RATE > 1 の時に、T_CLK と M_CLK 
                              --!   の位相関係を示す時に使用する.
                              --! * T_CLKの立上り時とM_CLKの立上り時が同じ時にアサー
                              --!   トするように入力されなければならない.
                              --! * この信号は M_CLK_RATE > 1 かつ T_CLK_RATE = 1の
                              --!   時のみ有効. それ以外は未使用.
                              in  std_logic := '1';
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
                              --! * M_REQ_FIRST=1の場合、内部状態を初期化してから
                              --!   トランザクションを開始する.
                              out std_logic;
        M_REQ_LAST          : --! @brief Request Last transaction to requester :
                              --! 最後のトランザクションであることを示す.
                              --! * M_REQ_LAST=1の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   M_ACK_LAST 信号をアサートする.
                              --! * M_REQ_LAST=0の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   M_ACK_NEXT 信号をアサートする.
                              out std_logic;
        M_REQ_VALID         : --! @brief Request Valid signal to requester :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              --! * この信号のアサートでもってトランザクションを開始する.
                              --! * 一度この信号をアサートすると Acknowledge を返す
                              --!   まで、この信号はアサートされたまま.
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
                              in  std_logic;
        M_ACK_NEXT          : --! @brief Acknowledge with need Next transaction from requester :
                              --! すべてのトランザクションが終了かつ M_REQ_LAST=0 の
                              --! 場合、この信号がアサートされる.
                              in  std_logic;
        M_ACK_LAST          : --! @brief Acknowledge with Last transaction from requester :
                              --! すべてのトランザクションが終了かつ M_REQ_LAST=1 の
                              --! 場合、この信号がアサートされる.
                              in  std_logic;
        M_ACK_ERROR         : --! @brief Acknowledge with Error from requester :
                              --! トランザクション中になんらかのエラーが発生した場
                              --! 合、この信号がアサートされる.
                              in  std_logic := '0';
        M_ACK_STOP          : --! @brief Acknowledge with Stop operation from requester :
                              --! トランザクションが中止された場合、この信号がアサ
                              --! ートされる.
                              in  std_logic;
        M_ACK_NONE          : --! @brief Acknowledge with no traxsfer from requester :
                              --! トランザクションが行われなかった場合(例えば転送、
                              --! 要求サイズ(M_REQ_SIZE)=0の場合)、この信号がアサー
                              --! トされる.
                              in  std_logic;
        M_ACK_SIZE          : --! @brief Acknowledge transfer Size from requester :
                              --! 転送したバイト数を示す.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- Status from Requester Signals.
    -------------------------------------------------------------------------------
        M_XFER_BUSY         : --! @brief Transfer Busy from requester :
                              --! リクエスタ側がデータ転送中であることを示すフラグ.
                              in  std_logic;
        M_XFER_ERROR        : --! @brief Transfer Error from requester :
                              --! リクエスタ側がデータの転送中にエラーが発生した事
                              --! を示す.
                              in  std_logic := '0';
        M_XFER_DONE         : --! @brief Transfer Done from requester :
                              --! データ転送中かつ、次のクロックで M_XFER_BUSY が
                              --! ネゲートされる事を示すフラグ.
                              --! * ただし、M_XFER_BUSY のネゲート前に 必ずしもこの
                              --!   信号がアサートされるわけでは無い.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from/to Requester.
    -------------------------------------------------------------------------------
        M_I_FLOW_LEVEL      : --! @brief Intake Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以下の時に入力を開始する.
                              --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_I_BUF_SIZE        : --! @brief Intake Pool Size  :
                              --! 入力用プールの総容量を指定する.
                              --! M_I_FLOW_SIZE を求めるのに使用する.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_I_FLOW_READY      : --! @brief Intake Valve Flow Ready to requester :
                              --! プールバッファに M_I_FLOW_LEVEL 以下のデータ
                              --! しか無く、データの入力が可能な事を示す.
                              out std_logic;
        M_I_FLOW_PAUSE      : --! @brief Intake Valve Flow Pause to requester :
                              --! 入力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに M_I_FLOW_LEVEL を越えるデータ
                              --! が溜っていて、これ以上データが入らないことを示す.
                              out std_logic;
        M_I_FLOW_STOP       : --! @brief Intake Valve Flow Stop to requester :
                              --! 入力の中止を指示する信号.
                              out std_logic;
        M_I_FLOW_LAST       : --! @brief Intake Valve Flow Last to requester :
                              --! リクエスタ側から最後の入力を示すフラグがあったこと
                              --! を示す.
                              out std_logic;
        M_I_FLOW_SIZE       : --! @brief Intake Valve Flow Enable Size to requester :
                              --! 入力可能なバイト数
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        M_PUSH_FIN_VALID    : --! @brief Push Final Valid from requester :
                              --! M_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        M_PUSH_FIN_LAST     : --! @brief Push Final Last flags from requester :
                              --! リクエスタ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        M_PUSH_FIN_ERROR    : --! @brief Push Final Error flags from requester :
                              --! リクエスタ側からのデータ入力時にエラーが発生した
                              --! ことを示すフラグ.
                              --! * 現在この信号は未使用.
                              in  std_logic := '0';
        M_PUSH_FIN_SIZE     : --! @brief Push Final Size from requester :
                              --! リクエスタ側からの"確定した"入力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PUSH_RSV_VALID    : --! @brief Push Reserve Valid from requester :
                              --! M_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        M_PUSH_RSV_LAST     : --! @brief Push Reserve Last flags from requester :
                              in  std_logic := '0';
        M_PUSH_RSV_ERROR    : --! @brief Push Reserve Error flags from requester :
                              in  std_logic := '0';
        M_PUSH_RSV_SIZE     : --! @brief Push Reserve Size from requester :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PUSH_BUF_LEVEL    : --! @brief Push Buffer Ready Level :
                              --! M_PUSH_BUF_READY 信号をアサートするかしないかを
                              --! 指示するための閾値.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_PUSH_BUF_RESET    : --! @brief Push Buffer Reset from requester :
                              in  std_logic := '0';
        M_PUSH_BUF_VALID    : --! @brief Push Buffer Valid from requester :
                              in  std_logic := '0';
        M_PUSH_BUF_LAST     : --! @brief Push Buffer Last  from requester :
                              in  std_logic := '0';
        M_PUSH_BUF_ERROR    : --! @brief Push Buffer Error from requester :
                              in  std_logic := '0';
        M_PUSH_BUF_SIZE     : --! @brief Push Buffer Size  from requester :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PUSH_BUF_READY    : --! @brief Push Buffer Ready to   requester :
                              --! プールバッファに M_PUSH_BUF_LEVEL 以下のデータし
                              --! かないことを示すフラグ.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals from/to Requester.
    -------------------------------------------------------------------------------
        M_O_FLOW_LEVEL      : --! @brief Outlet Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以上の時に転送を開始する.
                              --! フローカウンタの値がこの値未満の時に転送を一時停止.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_O_FLOW_READY      : --! @brief Outlet Valve Flow Ready to requester :
                              --! プールバッファに M_O_FLOW_LEVEL 以上のデータがある
                              --! ことを示す.
                              out std_logic;
        M_O_FLOW_PAUSE      : --! @brief Outlet Valve Flow Pause to requester :
                              --! 出力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに M_O_FLOW_LEVEL 未満のデータしか無
                              --! いことを示す.
                              out std_logic;
        M_O_FLOW_STOP       : --! @brief Outlet Valve Flow Stop to requester :
                              --! 出力の中止を指示する信号.
                              out std_logic;
        M_O_FLOW_LAST       : --! @brief Outlet Valve Flow Last to requester :
                              --! レスポンダ側から最後の入力を示すフラグがあった
                              --! ことを示す.
                              out std_logic;
        M_O_FLOW_SIZE       : --! @brief Outlet Valve Flow Enable Size to requester :
                              --! 出力可能なバイト数を出力.
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        M_PULL_FIN_VALID    : --! @brief Pull Final Valid from requester :
                              --! M_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        M_PULL_FIN_LAST     : --! @brief Pull Final Last flags from requester :
                              --! リクエスタ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        M_PULL_FIN_ERROR    : --! @brief Pull Final Error flags from requester :
                              --! リクエスタ側からのデータ出力時にエラーが発生した
                              --! ことを示すフラグ.
                              --! * 現在この信号は未使用.
                              in  std_logic := '0';
        M_PULL_FIN_SIZE     : --! @brief Pull Final Size from requester :
                              --! リクエスタ側からの"確定した"出力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PULL_RSV_VALID    : --! @brief Pull Reserve Valid from requester :
                              --! M_PULL_RSV_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        M_PULL_RSV_LAST     : --! @brief Pull Reserve Last flags from requester :
                              in  std_logic := '0';
        M_PULL_RSV_ERROR    : --! @brief Pull Reserve Error flags from requester :
                              in  std_logic := '0';
        M_PULL_RSV_SIZE     : --! @brief Pull Reserve Size from requester :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PULL_BUF_RESET    : --! @brief Pull Buffer Reset from requester :
                              in  std_logic := '0';
        M_PULL_BUF_LEVEL    : --! @brief Pull Buffer Ready Level :
                              --! M_PULL_BUF_READY 信号をアサートするかしないかを
                              --! 指示するための閾値.
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_PULL_BUF_VALID    : --! @brief Pull Buffer Valid from requester :
                              in  std_logic := '0';
        M_PULL_BUF_LAST     : --! @brief Pull Buffer Last  from requester :
                              in  std_logic := '0';
        M_PULL_BUF_ERROR    : --! @brief Pull Buffer Error from requester :
                              in  std_logic := '0';
        M_PULL_BUF_SIZE     : --! @brief Pull Buffer Size  from requester :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PULL_BUF_READY    : --! @brief Pull Buffer Ready to   requester :
                              --! プールバッファに M_PULL_BUF_LEVEL 以上のデータが
                              --! あることを示すフラグ.
                              out std_logic
    );
end PIPE_CONTROLLER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PUMP_COMPONENTS.PIPE_REQUESTER_INTERFACE;
use     PIPEWORK.PUMP_COMPONENTS.PIPE_RESPONDER_INTERFACE;
architecture RTL of PIPE_CONTROLLER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_req_start       : std_logic;
    signal    s_req_valid       : std_logic;
    signal    s_req_dir         : std_logic;
    signal    s_req_first       : std_logic;
    signal    s_req_last        : std_logic;
    signal    s_req_addr        : std_logic_vector(ADDR_BITS-1 downto 0);
    signal    s_req_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    s_req_mode        : std_logic_vector(MODE_BITS-1 downto 0);
    signal    s_req_buf_ptr     : std_logic_vector(BUF_DEPTH-1 downto 0);
    constant  s_req_ready       : std_logic := '1';
    signal    s_req_done        : std_logic;
    signal    s_req_stop        : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_res_start       : std_logic;
    signal    s_res_done        : std_logic;
    signal    s_res_error       : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_push_fin_valid  : std_logic;
    signal    s_push_fin_last   : std_logic;
    signal    s_push_fin_error  : std_logic;
    signal    s_push_fin_size   : std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    signal    s_push_rsv_valid  : std_logic;
    signal    s_push_rsv_last   : std_logic;
    signal    s_push_rsv_error  : std_logic;
    signal    s_push_rsv_size   : std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_pull_fin_valid  : std_logic;
    signal    s_pull_fin_last   : std_logic;
    signal    s_pull_fin_error  : std_logic;
    signal    s_pull_fin_size   : std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    signal    s_pull_rsv_valid  : std_logic;
    signal    s_pull_rsv_last   : std_logic;
    signal    s_pull_rsv_error  : std_logic;
    signal    s_pull_rsv_size   : std_logic_vector(XFER_SIZE_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    T: PIPE_RESPONDER_INTERFACE                                  -- 
        generic map (                                            -- 
            PUSH_VALID              => PUSH_VALID              , -- 
            PULL_VALID              => PULL_VALID              , -- 
            ADDR_BITS               => ADDR_BITS               , -- 
            ADDR_VALID              => ADDR_VALID              , -- 
            SIZE_BITS               => SIZE_BITS               , -- 
            SIZE_VALID              => SIZE_VALID              , -- 
            MODE_BITS               => MODE_BITS               , -- 
            XFER_COUNT_BITS         => XFER_COUNT_BITS         , -- 
            XFER_SIZE_BITS          => XFER_SIZE_BITS          , -- 
            BUF_DEPTH               => BUF_DEPTH               , -- 
            O_FIXED_CLOSE           => T_O_FIXED_CLOSE         , -- 
            O_FIXED_FLOW_OPEN       => T_O_FIXED_FLOW_OPEN     , -- 
            O_FIXED_POOL_OPEN       => T_O_FIXED_POOL_OPEN     , -- 
            I_FIXED_CLOSE           => T_I_FIXED_CLOSE         , -- 
            I_FIXED_FLOW_OPEN       => T_I_FIXED_FLOW_OPEN     , -- 
            I_FIXED_POOL_OPEN       => T_I_FIXED_POOL_OPEN     , -- 
            USE_M_PUSH_RSV          => M2T_PUSH_RSV_VALID      , -- 
            USE_T_PULL_BUF          => T2M_PULL_BUF_VALID      , -- 
            USE_M_PULL_RSV          => M2T_PULL_RSV_VALID      , -- 
            USE_T_PUSH_BUF          => T2M_PUSH_BUF_VALID        --    
        )                                                        -- 
        port map (                                               -- 
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK                     => T_CLK                   , -- In  :
            RST                     => RST                     , -- In  :
            CLR                     => T_CLR                   , -- In  :
        ---------------------------------------------------------------------------
        -- Request from Responder Signals.
        ---------------------------------------------------------------------------
            T_REQ_ADDR              => T_REQ_ADDR              , -- In  :
            T_REQ_SIZE              => T_REQ_SIZE              , -- In  :
            T_REQ_BUF_PTR           => T_REQ_BUF_PTR           , -- In  :
            T_REQ_MODE              => T_REQ_MODE              , -- In  :
            T_REQ_DIR               => T_REQ_DIR               , -- In  :
            T_REQ_FIRST             => T_REQ_FIRST             , -- In  :
            T_REQ_LAST              => T_REQ_LAST              , -- In  :
            T_REQ_VALID             => T_REQ_VALID             , -- In  :
            T_REQ_READY             => T_REQ_READY             , -- Out :
        ---------------------------------------------------------------------------
        -- Acknowledge to Responder Signals.
        ---------------------------------------------------------------------------
            T_ACK_VALID             => T_ACK_VALID             , -- Out :
            T_ACK_NEXT              => T_ACK_NEXT              , -- Out :
            T_ACK_LAST              => T_ACK_LAST              , -- Out :
            T_ACK_ERROR             => T_ACK_ERROR             , -- Out :
            T_ACK_STOP              => T_ACK_STOP              , -- Out :
            T_ACK_SIZE              => T_ACK_SIZE              , -- Out :
        ---------------------------------------------------------------------------
        -- Control from Responder Signals.
        ---------------------------------------------------------------------------
            T_REQ_STOP              => T_REQ_STOP              , -- In  :
            T_REQ_PAUSE             => T_REQ_PAUSE             , -- In  :
        ---------------------------------------------------------------------------
        -- Status from Responder Signals.
        ---------------------------------------------------------------------------
            T_XFER_BUSY             => T_XFER_BUSY             , -- In  :
            T_XFER_ERROR            => T_XFER_ERROR            , -- In  :
            T_XFER_DONE             => T_XFER_DONE             , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Valve Signals from Responder.
        ---------------------------------------------------------------------------
            T_PUSH_FIN_VALID        => T_PUSH_FIN_VALID        , -- In  :
            T_PUSH_FIN_LAST         => T_PUSH_FIN_LAST         , -- In  :
            T_PUSH_FIN_SIZE         => T_PUSH_FIN_SIZE         , -- In  :
            T_PUSH_BUF_LEVEL        => T_PUSH_BUF_LEVEL        , -- In  :
            T_PUSH_BUF_RESET        => T_PUSH_BUF_RESET        , -- In  :
            T_PUSH_BUF_VALID        => T_PUSH_BUF_VALID        , -- In  :
            T_PUSH_BUF_LAST         => T_PUSH_BUF_LAST         , -- In  :
            T_PUSH_BUF_SIZE         => T_PUSH_BUF_SIZE         , -- In  :
            T_PUSH_BUF_READY        => T_PUSH_BUF_READY        , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Valve Signals from Responder.
        ---------------------------------------------------------------------------
            T_PULL_FIN_VALID        => T_PULL_FIN_VALID        , -- In  :
            T_PULL_FIN_LAST         => T_PULL_FIN_LAST         , -- In  :
            T_PULL_FIN_SIZE         => T_PULL_FIN_SIZE         , -- In  :
            T_PULL_BUF_LEVEL        => T_PULL_BUF_LEVEL        , -- In  :
            T_PULL_BUF_RESET        => T_PULL_BUF_RESET        , -- In  :
            T_PULL_BUF_VALID        => T_PULL_BUF_VALID        , -- In  :
            T_PULL_BUF_LAST         => T_PULL_BUF_LAST         , -- In  :
            T_PULL_BUF_SIZE         => T_PULL_BUF_SIZE         , -- In  :
            T_PULL_BUF_READY        => T_PULL_BUF_READY        , -- Out :
        ---------------------------------------------------------------------------
        -- Requester Outlet Flow Signals.
        ---------------------------------------------------------------------------
            O_FLOW_PAUSE            => T_O_FLOW_PAUSE          , -- Out :
            O_FLOW_STOP             => T_O_FLOW_STOP           , -- Out :
            O_FLOW_LAST             => T_O_FLOW_LAST           , -- Out :
            O_FLOW_SIZE             => T_O_FLOW_SIZE           , -- Out :
            O_FLOW_READY            => T_O_FLOW_READY          , -- Out :
            O_FLOW_LEVEL            => T_O_FLOW_LEVEL          , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Intake Flow Signals.
        ---------------------------------------------------------------------------
            I_FLOW_PAUSE            => T_I_FLOW_PAUSE          , -- Out :
            I_FLOW_STOP             => T_I_FLOW_STOP           , -- Out :
            I_FLOW_LAST             => T_I_FLOW_LAST           , -- Out :
            I_FLOW_SIZE             => T_I_FLOW_SIZE           , -- Out :
            I_FLOW_READY            => T_I_FLOW_READY          , -- Out :
            I_FLOW_LEVEL            => T_I_FLOW_LEVEL          , -- In  :
            I_BUF_SIZE              => T_I_BUF_SIZE            , -- In  :
        ---------------------------------------------------------------------------
        -- Request to Requester Signals.
        ---------------------------------------------------------------------------
            M_REQ_START             => s_req_start             , -- Out :
            M_REQ_ADDR              => s_req_addr              , -- Out :
            M_REQ_SIZE              => s_req_size              , -- Out :
            M_REQ_BUF_PTR           => s_req_buf_ptr           , -- Out :
            M_REQ_MODE              => s_req_mode              , -- Out :
            M_REQ_DIR               => s_req_dir               , -- Out :
            M_REQ_FIRST             => s_req_first             , -- Out :
            M_REQ_LAST              => s_req_last              , -- Out :
            M_REQ_VALID             => s_req_valid             , -- Out :
            M_REQ_READY             => s_req_ready             , -- In  :
            M_REQ_DONE              => s_req_done              , -- Out :
            M_REQ_STOP              => s_req_stop              , -- Out :
        ---------------------------------------------------------------------------
        -- Response from Requester Signals.
        ---------------------------------------------------------------------------
            M_RES_START             => s_res_start             , -- In  :
            M_RES_DONE              => s_res_done              , -- In  :
            M_RES_ERROR             => s_res_error             , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Valve Signals from Requester.
        ---------------------------------------------------------------------------
            M_PUSH_FIN_VALID        => s_push_fin_valid        , -- In  :
            M_PUSH_FIN_LAST         => s_push_fin_last         , -- In  :
            M_PUSH_FIN_SIZE         => s_push_fin_size         , -- In  :
            M_PUSH_RSV_VALID        => s_push_rsv_valid        , -- In  :
            M_PUSH_RSV_LAST         => s_push_rsv_last         , -- In  :
            M_PUSH_RSV_SIZE         => s_push_rsv_size         , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            M_PULL_FIN_VALID        => s_pull_fin_valid        , -- In  :
            M_PULL_FIN_LAST         => s_pull_fin_last         , -- In  :
            M_PULL_FIN_SIZE         => s_pull_fin_size         , -- In  :
            M_PULL_RSV_VALID        => s_pull_rsv_valid        , -- In  :
            M_PULL_RSV_LAST         => s_pull_rsv_last         , -- In  :
            M_PULL_RSV_SIZE         => s_pull_rsv_size           -- In  :
       );                                                        -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    M: PIPE_REQUESTER_INTERFACE                                  -- 
        generic map (                                            -- 
            PUSH_VALID              => PUSH_VALID              , -- 
            PULL_VALID              => PULL_VALID              , -- 
            T_CLK_RATE              => T_CLK_RATE              , -- 
            M_CLK_RATE              => M_CLK_RATE              , -- 
            ADDR_BITS               => ADDR_BITS               , -- 
            ADDR_VALID              => ADDR_VALID              , -- 
            SIZE_BITS               => SIZE_BITS               , -- 
            SIZE_VALID              => SIZE_VALID              , -- 
            MODE_BITS               => MODE_BITS               , -- 
            XFER_COUNT_BITS         => XFER_COUNT_BITS         , -- 
            XFER_SIZE_BITS          => XFER_SIZE_BITS          , -- 
            BUF_DEPTH               => BUF_DEPTH               , -- 
            M_O_FIXED_CLOSE         => M_O_FIXED_CLOSE         , -- 
            M_O_FIXED_FLOW_OPEN     => M_O_FIXED_FLOW_OPEN     , -- 
            M_O_FIXED_POOL_OPEN     => M_O_FIXED_POOL_OPEN     , -- 
            M_I_FIXED_CLOSE         => M_I_FIXED_CLOSE         , -- 
            M_I_FIXED_FLOW_OPEN     => M_I_FIXED_FLOW_OPEN     , -- 
            M_I_FIXED_POOL_OPEN     => M_I_FIXED_POOL_OPEN     , -- 
            T_O_FIXED_CLOSE         => T_O_FIXED_CLOSE         , -- 
            T_I_FIXED_CLOSE         => T_I_FIXED_CLOSE         , -- 
            USE_M_PUSH_RSV          => M2T_PUSH_RSV_VALID      , -- 
            USE_M_PULL_RSV          => M2T_PULL_RSV_VALID      , -- 
            USE_M_PUSH_BUF          => M2T_PUSH_BUF_VALID      , -- 
            USE_M_PULL_BUF          => M2T_PULL_BUF_VALID      , -- 
            USE_T2M_PUSH_RSV        => T2M_PUSH_RSV_VALID      , -- 
            USE_T2M_PULL_RSV        => T2M_PULL_RSV_VALID      , -- 
            M2T_PUSH_FIN_DELAY      => M2T_PUSH_FIN_DELAY      , -- 
            T2M_PUSH_FIN_DELAY      => T2M_PUSH_FIN_DELAY      , -- 
            T_XFER_MAX_SIZE         => T_XFER_MAX_SIZE           -- 
        )                                                        -- 
        port map (                                               -- 
        ---------------------------------------------------------------------------
        -- リセット信号.
        ---------------------------------------------------------------------------
            RST                     => RST                     , -- In  :
        ---------------------------------------------------------------------------
        -- Responder Side Clock.
        ---------------------------------------------------------------------------
            T_CLK                   => T_CLK                   , -- In  :
            T_CLR                   => T_CLR                   , -- In  :
            T_CKE                   => T_CKE                   , -- In  :
        ---------------------------------------------------------------------------
        -- Request from Responder Signals.
        ---------------------------------------------------------------------------
            T_REQ_ADDR              => s_req_addr              , -- In  :
            T_REQ_SIZE              => s_req_size              , -- In  :
            T_REQ_BUF_PTR           => s_req_buf_ptr           , -- In  :
            T_REQ_MODE              => s_req_mode              , -- In  :
            T_REQ_DIR               => s_req_dir               , -- In  :
            T_REQ_FIRST             => s_req_first             , -- In  :
            T_REQ_LAST              => s_req_last              , -- In  :
            T_REQ_START             => s_req_start             , -- In  :
            T_REQ_STOP              => s_req_stop              , -- In  :
            T_REQ_DONE              => s_req_done              , -- In  :
        ---------------------------------------------------------------------------
        -- Response to Responder Signals.
        ---------------------------------------------------------------------------
            T_RES_START             => s_res_start             , -- Out :
            T_RES_DONE              => s_res_done              , -- Out :
            T_RES_ERROR             => s_res_error             , -- Out :
        ---------------------------------------------------------------------------
        -- Push from Responder Signals.
        ---------------------------------------------------------------------------
            T2M_PUSH_FIN_VALID      => T_PUSH_FIN_VALID        , -- In  :
            T2M_PUSH_FIN_LAST       => T_PUSH_FIN_LAST         , -- In  :
            T2M_PUSH_FIN_ERROR      => T_PUSH_FIN_ERROR        , -- In  :
            T2M_PUSH_FIN_SIZE       => T_PUSH_FIN_SIZE         , -- In  :
            T2M_PUSH_RSV_VALID      => T_PUSH_RSV_VALID        , -- In  :
            T2M_PUSH_RSV_LAST       => T_PUSH_RSV_LAST         , -- In  :
            T2M_PUSH_RSV_ERROR      => T_PUSH_RSV_ERROR        , -- In  :
            T2M_PUSH_RSV_SIZE       => T_PUSH_RSV_SIZE         , -- In  :
        ---------------------------------------------------------------------------
        -- Pull from Responder Signals.
        ---------------------------------------------------------------------------
            T2M_PULL_FIN_VALID      => T_PULL_FIN_VALID        , -- In  :
            T2M_PULL_FIN_LAST       => T_PULL_FIN_LAST         , -- In  :
            T2M_PULL_FIN_ERROR      => T_PULL_FIN_ERROR        , -- In  :
            T2M_PULL_FIN_SIZE       => T_PULL_FIN_SIZE         , -- In  :
            T2M_PULL_RSV_VALID      => T_PULL_RSV_VALID        , -- In  :
            T2M_PULL_RSV_LAST       => T_PULL_RSV_LAST         , -- In  :
            T2M_PULL_RSV_ERROR      => T_PULL_RSV_ERROR        , -- In  :
            T2M_PULL_RSV_SIZE       => T_PULL_RSV_SIZE         , -- In  :
        ---------------------------------------------------------------------------
        -- Push to Responder Signals.
        ---------------------------------------------------------------------------
            M2T_PUSH_FIN_VALID      => s_push_fin_valid        , -- Out :
            M2T_PUSH_FIN_LAST       => s_push_fin_last         , -- Out :
            M2T_PUSH_FIN_ERROR      => s_push_fin_error        , -- Out :
            M2T_PUSH_FIN_SIZE       => s_push_fin_size         , -- Out :
            M2T_PUSH_RSV_VALID      => s_push_rsv_valid        , -- Out :
            M2T_PUSH_RSV_LAST       => s_push_rsv_last         , -- Out :
            M2T_PUSH_RSV_ERROR      => s_push_rsv_error        , -- Out :
            M2T_PUSH_RSV_SIZE       => s_push_rsv_size         , -- Out :
        ---------------------------------------------------------------------------
        -- Pull to Responder Signals.
        ---------------------------------------------------------------------------
            M2T_PULL_FIN_VALID      => s_pull_fin_valid        , -- Out :
            M2T_PULL_FIN_LAST       => s_pull_fin_last         , -- Out :
            M2T_PULL_FIN_ERROR      => s_pull_fin_error        , -- Out :
            M2T_PULL_FIN_SIZE       => s_pull_fin_size         , -- Out :
            M2T_PULL_RSV_VALID      => s_pull_rsv_valid        , -- Out :
            M2T_PULL_RSV_LAST       => s_pull_rsv_last         , -- Out :
            M2T_PULL_RSV_ERROR      => s_pull_rsv_error        , -- Out :
            M2T_PULL_RSV_SIZE       => s_pull_rsv_size         , -- Out :
        ---------------------------------------------------------------------------
        -- リクエスト側クロック.
        ---------------------------------------------------------------------------
            M_CLK                   => M_CLK                   , -- In  :
            M_CLR                   => M_CLR                   , -- In  :
            M_CKE                   => M_CKE                   , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側への要求信号出力.
        ---------------------------------------------------------------------------
            M_REQ_ADDR              => M_REQ_ADDR              , -- Out :
            M_REQ_SIZE              => M_REQ_SIZE              , -- Out :
            M_REQ_BUF_PTR           => M_REQ_BUF_PTR           , -- Out :
            M_REQ_MODE              => M_REQ_MODE              , -- Out :
            M_REQ_DIR               => M_REQ_DIR               , -- Out :
            M_REQ_FIRST             => M_REQ_FIRST             , -- Out :
            M_REQ_LAST              => M_REQ_LAST              , -- Out :
            M_REQ_VALID             => M_REQ_VALID             , -- Out :
            M_REQ_READY             => M_REQ_READY             , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側からの応答信号入力.
        ---------------------------------------------------------------------------
            M_ACK_VALID             => M_ACK_VALID             , -- In  :
            M_ACK_NEXT              => M_ACK_NEXT              , -- In  :
            M_ACK_LAST              => M_ACK_LAST              , -- In  :
            M_ACK_ERROR             => M_ACK_ERROR             , -- In  :
            M_ACK_STOP              => M_ACK_STOP              , -- In  :
            M_ACK_NONE              => M_ACK_NONE              , -- In  :
            M_ACK_SIZE              => M_ACK_SIZE              , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側からのステータス信号入力.
        ---------------------------------------------------------------------------
            M_XFER_BUSY             => M_XFER_BUSY             , -- In  :
            M_XFER_ERROR            => M_XFER_ERROR            , -- In  :
            M_XFER_DONE             => M_XFER_DONE             , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側からデータ入力のフロー制御信号入出力.
        ---------------------------------------------------------------------------
            M_I_FLOW_PAUSE          => M_I_FLOW_PAUSE          , -- Out :
            M_I_FLOW_STOP           => M_I_FLOW_STOP           , -- Out :
            M_I_FLOW_LAST           => M_I_FLOW_LAST           , -- Out :
            M_I_FLOW_SIZE           => M_I_FLOW_SIZE           , -- Out :
            M_I_FLOW_READY          => M_I_FLOW_READY          , -- Out :
            M_I_FLOW_LEVEL          => M_I_FLOW_LEVEL          , -- In  :
            M_I_BUF_SIZE            => M_I_BUF_SIZE            , -- In  :
            M_PUSH_FIN_VALID        => M_PUSH_FIN_VALID        , -- In  :
            M_PUSH_FIN_LAST         => M_PUSH_FIN_LAST         , -- In  :
            M_PUSH_FIN_ERROR        => M_PUSH_FIN_ERROR        , -- In  :
            M_PUSH_FIN_SIZE         => M_PUSH_FIN_SIZE         , -- In  :
            M_PUSH_RSV_VALID        => M_PUSH_RSV_VALID        , -- In  :
            M_PUSH_RSV_LAST         => M_PUSH_RSV_LAST         , -- In  :
            M_PUSH_RSV_ERROR        => M_PUSH_RSV_ERROR        , -- In  :
            M_PUSH_RSV_SIZE         => M_PUSH_RSV_SIZE         , -- In  :
            M_PUSH_BUF_LEVEL        => M_PUSH_BUF_LEVEL        , -- In  :
            M_PUSH_BUF_RESET        => M_PUSH_BUF_RESET        , -- In  :
            M_PUSH_BUF_VALID        => M_PUSH_BUF_VALID        , -- In  :
            M_PUSH_BUF_LAST         => M_PUSH_BUF_LAST         , -- In  :
            M_PUSH_BUF_ERROR        => M_PUSH_BUF_ERROR        , -- In  :
            M_PUSH_BUF_SIZE         => M_PUSH_BUF_SIZE         , -- In  :
            M_PUSH_BUF_READY        => M_PUSH_BUF_READY        , -- Out :
        ---------------------------------------------------------------------------
        -- リクエスタ側へのデータ出力のフロー制御信号入出力
        ---------------------------------------------------------------------------
            M_O_FLOW_PAUSE          => M_O_FLOW_PAUSE          , -- Out :
            M_O_FLOW_STOP           => M_O_FLOW_STOP           , -- Out :
            M_O_FLOW_LAST           => M_O_FLOW_LAST           , -- Out :
            M_O_FLOW_SIZE           => M_O_FLOW_SIZE           , -- Out :
            M_O_FLOW_READY          => M_O_FLOW_READY          , -- Out :
            M_O_FLOW_LEVEL          => M_O_FLOW_LEVEL          , -- In  :
            M_PULL_FIN_VALID        => M_PULL_FIN_VALID        , -- In  :
            M_PULL_FIN_LAST         => M_PULL_FIN_LAST         , -- In  :
            M_PULL_FIN_ERROR        => M_PULL_FIN_ERROR        , -- In  :
            M_PULL_FIN_SIZE         => M_PULL_FIN_SIZE         , -- In  :
            M_PULL_RSV_VALID        => M_PULL_RSV_VALID        , -- In  :
            M_PULL_RSV_LAST         => M_PULL_RSV_LAST         , -- In  :
            M_PULL_RSV_ERROR        => M_PULL_RSV_ERROR        , -- In  :
            M_PULL_RSV_SIZE         => M_PULL_RSV_SIZE         , -- In  :
            M_PULL_BUF_LEVEL        => M_PULL_BUF_LEVEL        , -- In  :
            M_PULL_BUF_RESET        => M_PULL_BUF_RESET        , -- In  :
            M_PULL_BUF_VALID        => M_PULL_BUF_VALID        , -- In  :
            M_PULL_BUF_LAST         => M_PULL_BUF_LAST         , -- In  :
            M_PULL_BUF_ERROR        => M_PULL_BUF_ERROR        , -- In  :
            M_PULL_BUF_SIZE         => M_PULL_BUF_SIZE         , -- In  :
            M_PULL_BUF_READY        => M_PULL_BUF_READY          -- Out :
        );                                                       -- 
end RTL;
