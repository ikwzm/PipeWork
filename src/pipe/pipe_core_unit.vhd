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
        PUSH_VALID          : --! @brief PUSH VALID :
                              --! レスポンダ側からリクエスタ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PUSH_VALID>1でデータ転送を行う.
                              --! * PUSH_VALID=0でデータ転送を行わない.
                              integer :=  1;
        PULL_VALID          : --! @brief PUSH VALID :
                              --! リクエスタ側からレスポンダ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PULL_VALID>1でデータ転送を行う.
                              --! * PULL_VALID=0でデータ転送を行わない.
                              integer :=  1;
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
                              --! * ADDR_VALID>0で有効.
                              integer :=  1;
        SIZE_BITS           : --! @brief Transfer Size Bits :
                              --! REQ_SIZE/ACK_SIZE信号のビット数を指定する.
                              integer := 32;
        SIZE_VALID          : --! @brief Request Size Valid :
                              --! REQ_SIZE信号を有効にするかどうかを指定する.
                              --! * SIZE_VALID=0で無効.
                              --! * SIZE_VALID>0で有効.
                              integer :=  1;
        MODE_BITS           : --! @brief Request Mode Bits :
                              --! REQ_MODE信号のビット数を指定する.
                              integer := 32;
        BUF_DEPTH           : --! @brief Buffer Depth :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        M_COUNT_BITS        : --! @brief Requester Flow Counter Bits :
                              integer := 12;
        T_COUNT_BITS        : --! @brief Responder Flow Counter Bits :
                              integer := 12;
        M_O_VALVE_FIXED     : --! @brief Requester Outlet Valve Fixed Mode :
                              integer :=  0;
        M_O_VALVE_PRECEDE   : --! @brief Requester Outlet Valve Precede Mode :
                              integer :=  0;
        M_I_VALVE_FIXED     : --! @brief Requester Intake Valve Fixed Mode :
                              integer :=  0;
        M_I_VALVE_PRECEDE   : --! @brief Requester Intake Valve Precede Mode :
                              integer :=  0;
        T_O_VALVE_FIXED     : --! @brief Responder Outlet Valve Fixed Mode :
                              integer :=  0;
        T_O_VALVE_PRECEDE   : --! @brief Responder Outlet Valve Precede Mode :
                              integer :=  0;
        T_I_VALVE_FIXED     : --! @brief Responder Intake Valve Fixed Mode :
                              integer :=  0;
        T_I_VALVE_PRECEDE   : --! @brief Responder Intake Valve Precede Mode :
                              integer :=  0;
        T2M_PUSH_FIN_DELAY  : --! @brief Responder to Requester Pull Final Size Delay Cycle :
                              integer :=  0;
        M2T_PUSH_FIN_DELAY  : --! @brief Requester to Responder Pull Final Size Delay Cycle :
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
    -- レスポンダ側クロック.
    -------------------------------------------------------------------------------
        T_CLK               : in  std_logic;
        T_CLR               : in  std_logic;
        T_CKE               : in  std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側からの要求信号入力.
    -------------------------------------------------------------------------------
        T_REQ_ADDR          : --! @brief Responder Request Address :
                              --! 転送開始アドレスを入力する.  
                              in  std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE          : --! @brief Responder Request Transfer Size :
                              --! 転送したいバイト数を出力する. 
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR       : --! @brief Responder Request Buffer Pointer :
                              --! 転送時のバッファポインタを出力する.
                              in  std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE          : --! @brief Responder Request Mode Signals :
                              --! 転送開始時に指定された各種情報を出力する.
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
                              in  std_logic;
        T_REQ_LAST          : --! @brief Request Last transaction from responder :
                              --! 最後のトランザクションであることを示す.
                              --! * T_REQ_LAST=1の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_LAST 信号をアサートする.
                              --! * T_REQ_LAST=0の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_NEXT 信号をアサートする.
                              in  std_logic;
        T_REQ_VALID         : --! @brief Responder Request Valid Signal :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              --! * この信号のアサートでもってトランザクションを開始する.
                              --! * 一度この信号をアサートすると Acknowledge を返すまで、
                              --!   この信号はアサートされなくてはならない.
                              in  std_logic;
        T_REQ_READY         : --! @brief Responder Request Ready Signal :
                              --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側への応答信号出力.
    -------------------------------------------------------------------------------
        T_ACK_VALID         : --! @brief Responder Acknowledge Valid Signal :
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
                              --! 転送するバイト数を示す.
                              --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で
                              --! 示されるバイト数分を加算/減算すると良い.
                              out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- レスポンダ側からデータ入力のフロー制御信号入出力.
    -------------------------------------------------------------------------------
        T_I_VALVE_OPEN      : in  std_logic;
        T_I_FLOW_RDY        : out std_logic;
        T_I_FLOW_PAUSE      : out std_logic;
        T_I_FLOW_STOP       : out std_logic;
        T_I_FLOW_LAST       : out std_logic;
        T_I_FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
        T_I_POOL_RDY        : out std_logic;
        T_I_FLOW_RDY_LVL    : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_I_POOL_RDY_LVL    : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_I_POOL_SIZE       : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_FIN_VAL      : in  std_logic;
        T_PUSH_FIN_LAST     : in  std_logic;
        T_PUSH_FIN_ERR      : in  std_logic;
        T_PUSH_FIN_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_RSV_VAL      : in  std_logic;
        T_PUSH_RSV_LAST     : in  std_logic;
        T_PUSH_RSV_ERR      : in  std_logic;
        T_PUSH_RSV_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- レスポンダ側へのデータ出力のフロー制御信号入出力
    -------------------------------------------------------------------------------
        T_O_VALVE_OPEN      : in  std_logic;
        T_O_FLOW_RDY        : out std_logic;
        T_O_FLOW_PAUSE      : out std_logic;
        T_O_FLOW_STOP       : out std_logic;
        T_O_FLOW_LAST       : out std_logic;
        T_O_FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
        T_O_POOL_RDY        : out std_logic;
        T_O_FLOW_RDY_LVL    : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_O_POOL_RDY_LVL    : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_FIN_VAL      : in  std_logic;
        T_PULL_FIN_LAST     : in  std_logic;
        T_PULL_FIN_ERR      : in  std_logic;
        T_PULL_FIN_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_RSV_VAL      : in  std_logic;
        T_PULL_RSV_LAST     : in  std_logic;
        T_PULL_RSV_ERR      : in  std_logic;
        T_PULL_RSV_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- リクエスト側クロック.
    -------------------------------------------------------------------------------
        M_CLK               : in  std_logic;
        M_CLR               : in  std_logic;
        M_CKE               : in  std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側への要求信号出力.
    -------------------------------------------------------------------------------
        M_REQ_ADDR          : --! @brief Requester Request Address :
                              --! 転送開始アドレスを出力する.  
                              out std_logic_vector(ADDR_BITS-1 downto 0);
        M_REQ_SIZE          : --! @brief Requester Request Transfer Size :
                              --! 転送したいバイト数を出力する. 
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        M_REQ_BUF_PTR       : --! @brief Requester Request Buffer Pointer :
                              --! 転送時のバッファポインタを出力する.
                              out std_logic_vector(BUF_DEPTH-1 downto 0);
        M_REQ_MODE          : --! @brief Requester Request Mode Signals :
                              --! 転送開始時に指定された各種情報を出力する.
                              out std_logic_vector(MODE_BITS-1 downto 0);
        M_REQ_DIR           : --! @brief Request Direction to requester :
                              --! 転送方向(PUSH/PULL)を指定する.
                              --! * M_REQ_DIR='1' : PUSH(Responder側からRequester側へデータ転送)
                              --! * M_REQ_DIR='0' : PULL(Requester側からResponder側へデータ転送)
                              out std_logic;
        M_REQ_FIRST         : --! @brief Requester Request First Transaction :
                              --! 最初のトランザクションであることを示す.
                              --! * REQ_FIRST=1の場合、内部状態を初期化してからトランザ
                              --!   クションを開始する.
                              out std_logic;
        M_REQ_LAST          : --! @brief Requester Request Last Transaction :
                              --! 最後のトランザクションであることを示す.
                              --! * REQ_LAST=1の場合、Acknowledge を返す際に、すべての
                              --!   トランザクションが終了していると、ACK_LAST 信号をア
                              --!   サートする.
                              --! * REQ_LAST=0の場合、Acknowledge を返す際に、すべての
                              --!   トランザクションが終了していると、ACK_NEXT 信号をア
                              --!   サートする.
                              out std_logic;
        M_REQ_VALID         : --! @brief Requester Request Valid Signal :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              --! * この信号のアサートでもってトランザクションを開始する.
                              --! * 一度この信号をアサートすると Acknowledge を返すまで、
                              --!   この信号はアサートされなくてはならない.
                              out std_logic;
        M_REQ_READY         : --! @brief Requester Request Ready Signal :
                              --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側からの応答信号入力.
    -------------------------------------------------------------------------------
        M_ACK_VALID         : --! @brief Requester Acknowledge Valid Signal :
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
                              in  std_logic;
        M_ACK_NEXT          : --! @brief Requester Acknowledge with need Next transaction :
                              --! すべてのトランザクションが終了かつ REQ_LAST=0 の場合、
                              --! この信号がアサートされる.
                              in  std_logic;
        M_ACK_LAST          : --! @brief Requester Acknowledge with Last transaction :
                              --! すべてのトランザクションが終了かつ REQ_LAST=1 の場合、
                              --! この信号がアサートされる.
                              in  std_logic;
        M_ACK_ERROR         : --! @brief Requester Acknowledge with Error :
                              --! トランザクション中になんらかのエラーが発生した場合、
                              --! この信号がアサートされる.
                              in  std_logic;
        M_ACK_STOP          : --! @brief Requester Acknowledge with Stop operation :
                              --! トランザクションが中止された場合、この信号がアサート
                              --! される.
                              in  std_logic;
        M_ACK_NONE          : --! @brief Requester Acknowledge with None Request Transfer Size :
                              --! REQ_SIZE=0 の Request だった場合、この信号がアサート
                              --! される.
                              in  std_logic;
        M_ACK_SIZE          : --! @brief Acknowledge transfer size :
                              --! 転送するバイト数を示す.
                              --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で示さ
                              --! れるバイト数分を加算/減算すると良い.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- リクエスタ側からデータ入力のフロー制御信号入出力.
    -------------------------------------------------------------------------------
        M_I_FLOW_PAUSE      : --! @brief Requester Intake Valve Flow Pause :
                              --! 入力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに I_FLOW_RDY_LVL を越えるデータが溜っ
                              --! ていて、これ以上データが入らないことを示す.
                              out std_logic;
        M_I_FLOW_STOP       : --! @brief Requester Intake Valve Flow Stop :
                              --! 入力の中止を指示する信号.
                              out std_logic;
        M_I_FLOW_LAST       : --! @brief Requester Intake Valve Flow Last :
                              --! 入力側から最後の入力を示すフラグがあったことを示す.
                              out std_logic;
        M_I_FLOW_SIZE       : --! @brief Requester Intake Valve Flow Enable Size :
                              --! 入力可能なバイト数
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        M_I_FLOW_RDY        : --! @brief Requester Intake Valve Flow Ready :
                              --! プールバッファに I_FLOW_RDY_LVL 以下のデータしか無く、
                              --! データの入力が可能な事を示す.
                              out std_logic;
        M_I_POOL_RDY        : --! @brief Requester Intake Valve Pool Ready :
                              --! 先行モード(I_VALVE_PRECEDE=1)の時、プールバッファに 
                              --! I_POOL_RDY_LVL以下のデータしか無いことを示す.
                              out std_logic;
        M_I_FLOW_RDY_LVL    : --! @brief Requester Intake Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以下の時に入力を開始する.
                              --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_I_POOL_RDY_LVL    : --! @brief Requester Intake Valve Pool Ready Level :
                              --! 先行モード(I_VALVE_PRECEDE=1)の時、T_PULL_FIN_SIZE に
                              --! よるフローカウンタの減算結果が、この値以下の時に
                              --! I_POOL_RDY 信号をアサートする.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_I_POOL_SIZE       : --! @brief Requester Intake Pool Size :
                              --! 入力用プールの総容量を指定する.
                              --! M_I_FLOW_SIZE を求めるのに使用する.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_FIN_VAL      : in  std_logic;
        M_PUSH_FIN_LAST     : in  std_logic;
        M_PUSH_FIN_ERR      : in  std_logic;
        M_PUSH_FIN_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_RSV_VAL      : in  std_logic;
        M_PUSH_RSV_LAST     : in  std_logic;
        M_PUSH_RSV_ERR      : in  std_logic;
        M_PUSH_RSV_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- リクエスタ側へのデータ出力のフロー制御信号入出力
    -------------------------------------------------------------------------------
        M_O_FLOW_PAUSE      : --! @brief Requester Outlet Valve Flow Pause :
                              --! 出力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに M_O_FLOW_RDY_LVL 未満のデータしか
                              --! 無いことを示す.
                              out std_logic;
        M_O_FLOW_STOP       : --! @brief Requester Outlet Valve Flow Stop :
                              --! 出力の中止を指示する信号.
                              out std_logic;
        M_O_FLOW_LAST       : --! @brief Requester Outlet Valve Flow Last :
                              --! 入力側から最後の入力を示すフラグがあったことを示す.
                              out std_logic;
        M_O_FLOW_SIZE       : --! @brief Requester Outlet Valve Flow Enable Size. :
                              --! 出力可能なバイト数を出力.
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        M_O_FLOW_RDY        : --! @brief Outlet Valve Flow Ready :
                              --! プールバッファに M_O_FLOW_RDY_LVL 以上のデータがあ
                              --! ることを示す.
                              out std_logic;
        M_O_POOL_RDY        : --! @brief Requester Outlet Valve Flow Ready :
                              --! プールバッファに M_O_FLOW_RDY_LVL 以上のデータがあ
                              --! ることを示す.
                              out std_logic;
        M_O_FLOW_RDY_LVL    : --! @brief Requester Outlet Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以上の時に転送を開始する.
                              --! フローカウンタの値がこの値未満の時に転送を一時停止.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_O_POOL_RDY_LVL    : --! @brief Requester Outlet Valve Pool Ready Lelvel :
                              --! 先行モード(M_O_VALVE_PRECEDE=1)の時、T_PULL_FIN_SIZE
                              --! によるフローカウンタの加算結果が、この値以上の時に
                              --! M_O_POOL_RDY 信号をアサートする.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_FIN_VAL      : in  std_logic;
        M_PULL_FIN_LAST     : in  std_logic;
        M_PULL_FIN_ERR      : in  std_logic;
        M_PULL_FIN_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_RSV_VAL      : in  std_logic;
        M_PULL_RSV_LAST     : in  std_logic;
        M_PULL_RSV_ERR      : in  std_logic;
        M_PULL_RSV_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0)
    );
end PIPE_CORE_UNIT;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PIPE_COMPONENTS.PIPE_REQUESTER_INTERFACE;
use     PIPEWORK.PIPE_COMPONENTS.PIPE_RESPONDER_INTERFACE;
use     PIPEWORK.PIPE_COMPONENTS.PIPE_FLOW_SYNCRONIZER;
architecture RTL of PIPE_CORE_UNIT is
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
    constant  s_push_fin_error  : std_logic := '0';
    signal    s_push_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    s_push_rsv_valid  : std_logic;
    signal    s_push_rsv_last   : std_logic;
    constant  s_push_rsv_error  : std_logic := '0';
    signal    s_push_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_pull_fin_valid  : std_logic;
    signal    s_pull_fin_last   : std_logic;
    constant  s_pull_fin_error  : std_logic := '0';
    signal    s_pull_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    s_pull_rsv_valid  : std_logic;
    signal    s_pull_rsv_last   : std_logic;
    constant  s_pull_rsv_error  : std_logic := '0';
    signal    s_pull_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_req_start       : std_logic;
    signal    q_req_dir         : std_logic;
    signal    q_req_first       : std_logic;
    signal    q_req_last        : std_logic;
    signal    q_req_addr        : std_logic_vector(ADDR_BITS-1 downto 0);
    signal    q_req_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    q_req_mode        : std_logic_vector(MODE_BITS-1 downto 0);
    signal    q_req_buf_ptr     : std_logic_vector(BUF_DEPTH-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_res_start       : std_logic;
    signal    q_res_done        : std_logic;
    signal    q_res_error       : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_push_fin_valid  : std_logic;
    signal    q_push_fin_last   : std_logic;
    constant  q_push_fin_error  : std_logic := '0';
    signal    q_push_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    q_push_rsv_valid  : std_logic;
    signal    q_push_rsv_last   : std_logic;
    constant  q_push_rsv_error  : std_logic := '0';
    signal    q_push_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_pull_fin_valid  : std_logic;
    signal    q_pull_fin_last   : std_logic;
    constant  q_pull_fin_error  : std_logic := '0';
    signal    q_pull_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    q_pull_rsv_valid  : std_logic;
    signal    q_pull_rsv_last   : std_logic;
    constant  q_pull_rsv_error  : std_logic := '0';
    signal    q_pull_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    T: PIPE_RESPONDER_INTERFACE 
        generic map (
            PUSH_VALID              => PUSH_VALID                  ,
            PULL_VALID              => PULL_VALID                  ,
            ADDR_BITS               => ADDR_BITS                   ,
            ADDR_VALID              => ADDR_VALID                  ,
            SIZE_BITS               => SIZE_BITS                   ,
            SIZE_VALID              => SIZE_VALID                  ,
            MODE_BITS               => MODE_BITS                   ,
            COUNT_BITS              => T_COUNT_BITS                ,
            BUF_DEPTH               => BUF_DEPTH                   ,
            O_VALVE_FIXED           => T_O_VALVE_FIXED             ,
            O_VALVE_PRECEDE         => T_O_VALVE_PRECEDE           ,
            I_VALVE_FIXED           => T_I_VALVE_FIXED             ,
            I_VALVE_PRECEDE         => T_I_VALVE_PRECEDE
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK                     => T_CLK                       , -- In  :
            RST                     => RST                         , -- In  :
            CLR                     => T_CLR                       , -- In  :
        ---------------------------------------------------------------------------
        -- Request from Responder Signals.
        ---------------------------------------------------------------------------
            T_REQ_ADDR              => T_REQ_ADDR                  , -- In  :
            T_REQ_SIZE              => T_REQ_SIZE                  , -- In  :
            T_REQ_BUF_PTR           => T_REQ_BUF_PTR               , -- In  :
            T_REQ_MODE              => T_REQ_MODE                  , -- In  :
            T_REQ_DIR               => T_REQ_DIR                   , -- In  :
            T_REQ_FIRST             => T_REQ_FIRST                 , -- In  :
            T_REQ_LAST              => T_REQ_LAST                  , -- In  :
            T_REQ_VALID             => T_REQ_VALID                 , -- In  :
            T_REQ_READY             => T_REQ_READY                 , -- Out :
        ---------------------------------------------------------------------------
        -- Acknowledge to Responder Signals.
        ---------------------------------------------------------------------------
            T_ACK_VALID             => T_ACK_VALID                 , -- Out :
            T_ACK_NEXT              => T_ACK_NEXT                  , -- Out :
            T_ACK_LAST              => T_ACK_LAST                  , -- Out :
            T_ACK_ERROR             => T_ACK_ERROR                 , -- Out :
            T_ACK_STOP              => T_ACK_STOP                  , -- Out :
            T_ACK_SIZE              => T_ACK_SIZE                  , -- Out :
        ---------------------------------------------------------------------------
        -- Intake Valve Signals from Responder.
        ---------------------------------------------------------------------------
            T_PUSH_FIN_VALID        => T_PUSH_FIN_VAL              , -- In  :
            T_PUSH_FIN_LAST         => T_PUSH_FIN_LAST             , -- In  :
            T_PUSH_FIN_SIZE         => T_PUSH_FIN_SIZE             , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Valve Signals from Requester.
        ---------------------------------------------------------------------------
            T_PULL_FIN_VALID        => T_PULL_FIN_VAL              , -- In  :
            T_PULL_FIN_LAST         => T_PULL_FIN_LAST             , -- In  :
            T_PULL_FIN_SIZE         => T_PULL_FIN_SIZE             , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Outlet Flow Signals.
        ---------------------------------------------------------------------------
            O_VALVE_OPEN            => T_O_VALVE_OPEN              , -- In  :
            O_FLOW_PAUSE            => T_O_FLOW_PAUSE              , -- Out :
            O_FLOW_STOP             => T_O_FLOW_STOP               , -- Out :
            O_FLOW_LAST             => T_O_FLOW_LAST               , -- Out :
            O_FLOW_SIZE             => T_O_FLOW_SIZE               , -- Out :
            O_FLOW_READY            => T_O_FLOW_RDY                , -- Out :
            O_POOL_READY            => T_O_POOL_RDY                , -- Out :
            O_FLOW_READY_LEVEL      => T_O_FLOW_RDY_LVL            , -- In  :
            O_POOL_READY_LEVEL      => T_O_POOL_RDY_LVL            , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Intake Flow Signals.
        ---------------------------------------------------------------------------
            I_VALVE_OPEN            => T_I_VALVE_OPEN              , -- In  :
            I_FLOW_PAUSE            => T_I_FLOW_PAUSE              , -- Out :
            I_FLOW_STOP             => T_I_FLOW_STOP               , -- Out :
            I_FLOW_LAST             => T_I_FLOW_LAST               , -- Out :
            I_FLOW_SIZE             => T_I_FLOW_SIZE               , -- Out :
            I_FLOW_READY            => T_I_FLOW_RDY                , -- Out :
            I_POOL_READY            => T_I_POOL_RDY                , -- Out :
            I_FLOW_READY_LEVEL      => T_I_FLOW_RDY_LVL            , -- In  :
            I_POOL_READY_LEVEL      => T_I_POOL_RDY_LVL            , -- In  :
            I_POOL_SIZE             => T_I_POOL_SIZE               , -- In  :
        ---------------------------------------------------------------------------
        -- Request to Requester Signals.
        ---------------------------------------------------------------------------
            M_REQ_START             => s_req_start                 , -- Out :
            M_REQ_ADDR              => s_req_addr                  , -- Out :
            M_REQ_SIZE              => s_req_size                  , -- Out :
            M_REQ_BUF_PTR           => s_req_buf_ptr               , -- Out :
            M_REQ_MODE              => s_req_mode                  , -- Out :
            M_REQ_DIR               => s_req_dir                   , -- Out :
            M_REQ_FIRST             => s_req_first                 , -- Out :
            M_REQ_LAST              => s_req_last                  , -- Out :
            M_REQ_VALID             => s_req_valid                 , -- Out :
            M_REQ_READY             => s_req_ready                 , -- In  :
        ---------------------------------------------------------------------------
        -- Response from Requester Signals.
        ---------------------------------------------------------------------------
            M_RES_START             => s_res_start                 , -- In  :
            M_RES_DONE              => s_res_done                  , -- In  :
            M_RES_ERROR             => s_res_error                 , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Valve Signals from Requester.
        ---------------------------------------------------------------------------
            M_PUSH_FIN_VALID        => s_push_fin_valid            , -- In  :
            M_PUSH_FIN_LAST         => s_push_fin_last             , -- In  :
            M_PUSH_FIN_SIZE         => s_push_fin_size             , -- In  :
            M_PUSH_RSV_VALID        => s_push_rsv_valid            , -- In  :
            M_PUSH_RSV_LAST         => s_push_rsv_last             , -- In  :
            M_PUSH_RSV_SIZE         => s_push_rsv_size             , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            M_PULL_FIN_VALID        => s_pull_fin_valid            , -- In  :
            M_PULL_FIN_LAST         => s_pull_fin_last             , -- In  :
            M_PULL_FIN_SIZE         => s_pull_fin_size             , -- In  :
            M_PULL_RSV_VALID        => s_pull_rsv_valid            , -- In  :
            M_PULL_RSV_LAST         => s_pull_rsv_last             , -- In  :
            M_PULL_RSV_SIZE         => s_pull_rsv_size               -- In  :
       );
    -------------------------------------------------------------------------------
    -- レスポンダ側からリクエスタ側へのリクエスト情報などを転送する.
    -------------------------------------------------------------------------------
    T2M: block
        ---------------------------------------------------------------------------
        --! @brief OPEN_INFO のビットの割り当てを保持する定数の型.
        ---------------------------------------------------------------------------
        type      OPEN_INFO_RANGE_TYPE is record
                  ADDR_LO           : integer;
                  ADDR_HI           : integer;
                  SIZE_LO           : integer;
                  SIZE_HI           : integer;
                  MODE_LO           : integer;
                  MODE_HI           : integer;
                  PTR_LO            : integer;
                  PTR_HI            : integer;
                  DIR_POS           : integer;
                  FIRST_POS         : integer;
                  LAST_POS          : integer;
                  BITS              : integer;
        end record;
        ---------------------------------------------------------------------------
        --! @brief OPEN_INFO のビットの割り当てを決める関数.
        ---------------------------------------------------------------------------
        function  SET_OPEN_INFO_RANGE return OPEN_INFO_RANGE_TYPE is
            variable param : OPEN_INFO_RANGE_TYPE;
            variable index : integer;
        begin
            -----------------------------------------------------------------------
            -- 必要な分だけビットを割り当てる.
            -----------------------------------------------------------------------
            index := 0;
            if (ADDR_VALID /= 0) then
                param.ADDR_LO := index;
                param.ADDR_HI := index + ADDR_BITS - 1;
                index := index + ADDR_BITS;
            end if;
            if (SIZE_VALID /= 0) then
                param.SIZE_LO := index;
                param.SIZE_HI := index + SIZE_BITS - 1;
                index := index + SIZE_BITS;
            end if;
            if (PUSH_VALID /= 0 and PULL_VALID /= 0) then
                param.DIR_POS := index;
                index := index + 1;
            end if;
            param.FIRST_POS := index;
            index := index + 1;
            param.LAST_POS  := index;
            index := index + 1;
            param.PTR_LO    := index;
            param.PTR_HI    := index + BUF_DEPTH - 1;
            index := index + BUF_DEPTH;
            param.MODE_LO   := index;
            param.MODE_HI   := index + MODE_BITS - 1;
            index := index + MODE_BITS;
            -----------------------------------------------------------------------
            -- この段階で必要な分のビット割り当ては終了.
            -----------------------------------------------------------------------
            param.BITS    := index;
            -----------------------------------------------------------------------
            -- 後は必要無いが、放っておくのも気持ち悪いので、ダミーの値をセット.
            -----------------------------------------------------------------------
            if (ADDR_VALID = 0) then
                param.ADDR_LO := index;
                param.ADDR_HI := index + ADDR_BITS - 1;
                index := index + ADDR_BITS;
            end if;
            if (SIZE_VALID = 0) then
                param.SIZE_LO := index;
                param.SIZE_HI := index + SIZE_BITS - 1;
                index := index + SIZE_BITS;
            end if;
            if (PUSH_VALID = 0 or PULL_VALID = 0) then
                param.DIR_POS := index;
                index := index + 1;
            end if;
            return param;
        end function;
        ---------------------------------------------------------------------------
        --! @brief OPEN_INFO のビットの割り当てを保持する定数.
        ---------------------------------------------------------------------------
        constant  OPEN_INFO_RANGE   : OPEN_INFO_RANGE_TYPE := SET_OPEN_INFO_RANGE;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを保持する定数の型.
        ---------------------------------------------------------------------------
        type      SYNC_PARAM_TYPE   is record
                  PUSH_FIN_DELAY : integer;
                  PUSH_FIN_VALID : integer;
                  PUSH_RSV_VALID : integer;
                  PULL_FIN_VALID : integer;
                  PULL_RSV_VALID : integer;
        end record;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを決める関数.
        ---------------------------------------------------------------------------
        function  SET_SYNC_PARAM return SYNC_PARAM_TYPE is
            variable param : SYNC_PARAM_TYPE;
        begin
            if (M_O_VALVE_FIXED = 0) then
                param.PUSH_FIN_DELAY := T2M_PUSH_FIN_DELAY;
                param.PUSH_FIN_VALID := 1;
                if (M_O_VALVE_PRECEDE /= 0) then
                    param.PUSH_RSV_VALID := 1;
                else
                    param.PUSH_RSV_VALID := 0;
                end if;
            else
                param.PUSH_FIN_DELAY := 0;
                param.PUSH_FIN_VALID := 0;
                param.PUSH_RSV_VALID := 0;
            end if;
            if (M_I_VALVE_FIXED = 0) then
                param.PULL_FIN_VALID := 1;
                if (M_I_VALVE_PRECEDE /= 0) then
                    param.PULL_RSV_VALID := 1;
                else
                    param.PULL_RSV_VALID := 0;
                end if;
            else
                param.PULL_FIN_VALID := 0;
                param.PULL_RSV_VALID := 0;
            end if;
            return param;
        end function;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを保持する定数.
        ---------------------------------------------------------------------------
        constant  SYNC_PARAM        : SYNC_PARAM_TYPE := SET_SYNC_PARAM;
        ---------------------------------------------------------------------------
        --! @brief CLOSE_INFO のビットの割り当てを保持する定数.
        ---------------------------------------------------------------------------
        constant  CLOSE_INFO_BITS   : integer :=  1;
        ---------------------------------------------------------------------------
        -- 内部変数信号.
        ---------------------------------------------------------------------------
        signal    i_open_valid      : std_logic;
        signal    i_open_info       : std_logic_vector(OPEN_INFO_RANGE.BITS-1 downto 0);
        signal    i_close_valid     : std_logic;
        signal    i_close_info      : std_logic_vector(CLOSE_INFO_BITS     -1 downto 0);
        signal    o_open_valid      : std_logic;
        signal    o_open_info       : std_logic_vector(OPEN_INFO_RANGE.BITS-1 downto 0);
        signal    o_close_valid     : std_logic;
        signal    o_close_info      : std_logic_vector(CLOSE_INFO_BITS     -1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        I_ADDR_VALID_T: if (ADDR_VALID /= 0) generate
            i_open_info(OPEN_INFO_RANGE.ADDR_HI downto OPEN_INFO_RANGE.ADDR_LO) <= s_req_addr;
        end generate;
        I_SIZE_VALID_T: if (SIZE_VALID /= 0) generate
            i_open_info(OPEN_INFO_RANGE.SIZE_HI downto OPEN_INFO_RANGE.SIZE_LO) <= s_req_size;
        end generate;
        I_DIR_VALID_T : if (PUSH_VALID /= 0 and PULL_VALID /= 0) generate
            i_open_info(OPEN_INFO_RANGE.DIR_POS) <= s_req_dir;
        end generate;
        I_REQ_VALID_T : block begin
            i_open_valid  <= s_req_start;
            i_open_info(OPEN_INFO_RANGE.FIRST_POS) <= s_req_first;
            i_open_info(OPEN_INFO_RANGE.LAST_POS ) <= s_req_last;
            i_open_info(OPEN_INFO_RANGE.MODE_HI downto OPEN_INFO_RANGE.MODE_LO) <= s_req_mode;
            i_open_info(OPEN_INFO_RANGE.PTR_HI  downto OPEN_INFO_RANGE.PTR_LO ) <= s_req_buf_ptr;
            i_close_valid <= '0';
            i_close_info  <= (others => '0');
        end block;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SYNC: PIPE_FLOW_SYNCRONIZER
            generic map (
                I_CLK_RATE          => T_CLK_RATE                  , -- 
                O_CLK_RATE          => M_CLK_RATE                  , --
                OPEN_INFO_BITS      => OPEN_INFO_RANGE.BITS        , --
                CLOSE_INFO_BITS     => CLOSE_INFO_BITS             , --
                SIZE_BITS           => SIZE_BITS                   , --
                PUSH_FIN_VALID      => SYNC_PARAM.PUSH_FIN_VALID   , --
                PUSH_FIN_DELAY      => SYNC_PARAM.PUSH_FIN_DELAY   , --
                PUSH_RSV_VALID      => SYNC_PARAM.PUSH_RSV_VALID   , --
                PULL_FIN_VALID      => SYNC_PARAM.PULL_FIN_VALID   , --
                PULL_RSV_VALID      => SYNC_PARAM.PULL_RSV_VALID     --
            )                                                        -- 
            port map (                                               -- 
            ---------------------------------------------------------------------------
            -- Asyncronous Reset Signal.
            ---------------------------------------------------------------------------
                RST                 => RST                         , -- In  :
            ---------------------------------------------------------------------------
            -- Input
            ---------------------------------------------------------------------------
                I_CLK               => T_CLK                       , -- In  :
                I_CLR               => T_CLR                       , -- In  :
                I_CKE               => T_CKE                       , -- In  :
                I_OPEN_VAL          => i_open_valid                , -- In  :
                I_OPEN_INFO         => i_open_info                 , -- In  :
                I_CLOSE_VAL         => i_close_valid               , -- In  :
                I_CLOSE_INFO        => i_close_info                , -- In  :
                I_PUSH_FIN_VAL      => T_PUSH_FIN_VAL              , -- In  :
                I_PUSH_FIN_LAST     => T_PUSH_FIN_LAST             , -- In  :
                I_PUSH_FIN_SIZE     => T_PUSH_FIN_SIZE             , -- In  :
                I_PUSH_RSV_VAL      => T_PUSH_RSV_VAL              , -- In  :
                I_PUSH_RSV_LAST     => T_PUSH_RSV_LAST             , -- In  :
                I_PUSH_RSV_SIZE     => T_PUSH_RSV_SIZE             , -- In  :
                I_PULL_FIN_VAL      => T_PULL_FIN_VAL              , -- In  :
                I_PULL_FIN_LAST     => T_PULL_FIN_LAST             , -- In  :
                I_PULL_FIN_SIZE     => T_PULL_FIN_SIZE             , -- In  :
                I_PULL_RSV_VAL      => T_PULL_RSV_VAL              , -- In  :
                I_PULL_RSV_LAST     => T_PULL_RSV_LAST             , -- In  :
                I_PULL_RSV_SIZE     => T_PULL_RSV_SIZE             , -- In  :
            ---------------------------------------------------------------------------
            -- Output Clock and Clock Enable and Syncronous reset.
            ---------------------------------------------------------------------------
                O_CLK               => M_CLK                       , -- In  :
                O_CLR               => M_CLR                       , -- In  :
                O_CKE               => M_CKE                       , -- In  :
                O_OPEN_VAL          => o_open_valid                , -- Out :
                O_OPEN_INFO         => o_open_info                 , -- Out :
                O_CLOSE_VAL         => o_close_valid               , -- Out :
                O_CLOSE_INFO        => o_close_info                , -- Out :
                O_PUSH_FIN_VAL      => q_push_fin_valid            , -- Out :
                O_PUSH_FIN_LAST     => q_push_fin_last             , -- Out :
                O_PUSH_FIN_SIZE     => q_push_fin_size             , -- Out :
                O_PUSH_RSV_VAL      => q_push_rsv_valid            , -- Out :
                O_PUSH_RSV_LAST     => q_push_rsv_last             , -- Out :
                O_PUSH_RSV_SIZE     => q_push_rsv_size             , -- Out :
                O_PULL_FIN_VAL      => q_pull_fin_valid            , -- Out :
                O_PULL_FIN_LAST     => q_pull_fin_last             , -- Out :
                O_PULL_FIN_SIZE     => q_pull_fin_size             , -- Out :
                O_PULL_RSV_VAL      => q_pull_rsv_valid            , -- Out :
                O_PULL_RSV_LAST     => q_pull_rsv_last             , -- Out :
                O_PULL_RSV_SIZE     => q_pull_rsv_size               -- Out :
            );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        O_ADDR_VALID_T: if (ADDR_VALID /= 0) generate
            q_req_addr    <= o_open_info(OPEN_INFO_RANGE.ADDR_HI downto OPEN_INFO_RANGE.ADDR_LO);
        end generate;
        O_ADDR_VALID_F: if (ADDR_VALID  = 0) generate
            q_req_addr    <= (others => '0');
        end generate;
        O_SIZE_VALID_T: if (SIZE_VALID /= 0) generate
            q_req_size    <= o_open_info(OPEN_INFO_RANGE.SIZE_HI downto OPEN_INFO_RANGE.SIZE_LO);
        end generate;
        O_SIZE_VALID_F: if (SIZE_VALID  = 0) generate
            q_req_size    <= (others => '0');
        end generate;
        O_DIR_VALID_T : if (PUSH_VALID /= 0 and PULL_VALID /= 0) generate
            q_req_dir     <= o_open_info(OPEN_INFO_RANGE.DIR_POS);
        end generate;
        O_DIR_VALID_F : if (PUSH_VALID  = 0 or  PULL_VALID  = 0) generate
            q_req_dir     <= '1' when (PUSH_VALID /= 0) else '0';
        end generate;
        O_REQ_VALID_T : block begin
            q_req_start   <= o_open_valid;
            q_req_first   <= o_open_info(OPEN_INFO_RANGE.FIRST_POS);
            q_req_last    <= o_open_info(OPEN_INFO_RANGE.LAST_POS);
            q_req_buf_ptr <= o_open_info(OPEN_INFO_RANGE.PTR_HI  downto OPEN_INFO_RANGE.PTR_LO );
            q_req_mode    <= o_open_info(OPEN_INFO_RANGE.MODE_HI downto OPEN_INFO_RANGE.MODE_LO);
        end block;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    M2T: block
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを保持する定数の型.
        ---------------------------------------------------------------------------
        type      SYNC_PARAM_TYPE   is record
                  PUSH_FIN_DELAY : integer;
                  PUSH_FIN_VALID : integer;
                  PUSH_RSV_VALID : integer;
                  PULL_FIN_VALID : integer;
                  PULL_RSV_VALID : integer;
        end record;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを決める関数.
        ---------------------------------------------------------------------------
        function  SET_SYNC_PARAM return SYNC_PARAM_TYPE is
            variable param : SYNC_PARAM_TYPE;
        begin
            if (T_O_VALVE_FIXED = 0) then
                param.PUSH_FIN_DELAY := M2T_PUSH_FIN_DELAY;
                param.PUSH_FIN_VALID := 1;
                if (T_O_VALVE_PRECEDE /= 0) then
                    param.PUSH_RSV_VALID := 1;
                else
                    param.PUSH_RSV_VALID := 0;
                end if;
            else
                param.PUSH_FIN_DELAY := 0;
                param.PUSH_FIN_VALID := 0;
                param.PUSH_RSV_VALID := 0;
            end if;
            if (T_I_VALVE_FIXED = 0) then
                param.PULL_FIN_VALID := 1;
                if (T_I_VALVE_PRECEDE /= 0) then
                    param.PULL_RSV_VALID := 1;
                else
                    param.PULL_RSV_VALID := 0;
                end if;
            else
                param.PULL_FIN_VALID := 0;
                param.PULL_RSV_VALID := 0;
            end if;
            return param;
        end function;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを保持する定数.
        ---------------------------------------------------------------------------
        constant  SYNC_PARAM        : SYNC_PARAM_TYPE := SET_SYNC_PARAM;
        signal    o_open_info       : std_logic_vector(0 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        SYNC: PIPE_FLOW_SYNCRONIZER                                  -- 
            generic map (                                            -- 
                I_CLK_RATE          => M_CLK_RATE                  , -- 
                O_CLK_RATE          => T_CLK_RATE                  , --
                OPEN_INFO_BITS      => 1                           , --
                CLOSE_INFO_BITS     => 1                           , --
                SIZE_BITS           => SIZE_BITS                   , --
                PUSH_FIN_VALID      => SYNC_PARAM.PUSH_FIN_VALID   , --
                PUSH_FIN_DELAY      => SYNC_PARAM.PUSH_FIN_DELAY   , --
                PUSH_RSV_VALID      => SYNC_PARAM.PUSH_RSV_VALID   , --
                PULL_FIN_VALID      => SYNC_PARAM.PULL_FIN_VALID   , --
                PULL_RSV_VALID      => SYNC_PARAM.PULL_RSV_VALID     --
            )                                                        -- 
            port map (                                               -- 
            ---------------------------------------------------------------------------
            -- Asyncronous Reset Signal.
            ---------------------------------------------------------------------------
                RST                 => RST                         , -- In  :
            ---------------------------------------------------------------------------
            -- Input
            ---------------------------------------------------------------------------
                I_CLK               => M_CLK                       , -- In  :
                I_CLR               => M_CLR                       , -- In  :
                I_CKE               => M_CKE                       , -- In  :
                I_OPEN_VAL          => q_res_start                 , -- In  :
                I_OPEN_INFO(0)      => q_res_start                 , -- In  :
                I_CLOSE_VAL         => q_res_done                  , -- In  :
                I_CLOSE_INFO(0)     => q_res_error                 , -- In  :
                I_PUSH_FIN_VAL      => M_PUSH_FIN_VAL              , -- In  :
                I_PUSH_FIN_LAST     => M_PUSH_FIN_LAST             , -- In  :
                I_PUSH_FIN_SIZE     => M_PUSH_FIN_SIZE             , -- In  :
                I_PUSH_RSV_VAL      => M_PUSH_RSV_VAL              , -- In  :
                I_PUSH_RSV_LAST     => M_PUSH_RSV_LAST             , -- In  :
                I_PUSH_RSV_SIZE     => M_PUSH_RSV_SIZE             , -- In  :
                I_PULL_FIN_VAL      => M_PULL_FIN_VAL              , -- In  :
                I_PULL_FIN_LAST     => M_PULL_FIN_LAST             , -- In  :
                I_PULL_FIN_SIZE     => M_PULL_FIN_SIZE             , -- In  :
                I_PULL_RSV_VAL      => M_PULL_RSV_VAL              , -- In  :
                I_PULL_RSV_LAST     => M_PULL_RSV_LAST             , -- In  :
                I_PULL_RSV_SIZE     => M_PULL_RSV_SIZE             , -- In  :
            ---------------------------------------------------------------------------
            -- Output Clock and Clock Enable and Syncronous reset.
            ---------------------------------------------------------------------------
                O_CLK               => T_CLK                       , -- In  :
                O_CLR               => T_CLR                       , -- In  :
                O_CKE               => T_CKE                       , -- In  :
                O_OPEN_VAL          => s_res_start                 , -- Out :
                O_OPEN_INFO         => o_open_info                 , -- Out :
                O_CLOSE_VAL         => s_res_done                  , -- Out :
                O_CLOSE_INFO(0)     => s_res_error                 , -- Out :
                O_PUSH_FIN_VAL      => s_push_fin_valid            , -- Out :
                O_PUSH_FIN_LAST     => s_push_fin_last             , -- Out :
                O_PUSH_FIN_SIZE     => s_push_fin_size             , -- Out :
                O_PUSH_RSV_VAL      => s_push_rsv_valid            , -- Out :
                O_PUSH_RSV_LAST     => s_push_rsv_last             , -- Out :
                O_PUSH_RSV_SIZE     => s_push_rsv_size             , -- Out :
                O_PULL_FIN_VAL      => s_pull_fin_valid            , -- Out :
                O_PULL_FIN_LAST     => s_pull_fin_last             , -- Out :
                O_PULL_FIN_SIZE     => s_pull_fin_size             , -- Out :
                O_PULL_RSV_VAL      => s_pull_rsv_valid            , -- Out :
                O_PULL_RSV_LAST     => s_pull_rsv_last             , -- Out :
                O_PULL_RSV_SIZE     => s_pull_rsv_size               -- Out :
            );
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    M: PIPE_REQUESTER_INTERFACE 
        generic map (
            ADDR_BITS               => ADDR_BITS                   ,
            ADDR_VALID              => ADDR_VALID                  ,
            SIZE_BITS               => SIZE_BITS                   ,
            SIZE_VALID              => SIZE_VALID                  ,
            MODE_BITS               => MODE_BITS                   ,
            COUNT_BITS              => M_COUNT_BITS                ,
            BUF_DEPTH               => BUF_DEPTH                   ,
            T_XFER_MAX_SIZE         => T_XFER_MAX_SIZE             ,
            O_VALVE_FIXED           => M_O_VALVE_FIXED             ,
            O_VALVE_PRECEDE         => M_O_VALVE_PRECEDE           ,
            I_VALVE_FIXED           => M_I_VALVE_FIXED             ,
            I_VALVE_PRECEDE         => M_I_VALVE_PRECEDE
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK                     => M_CLK                       , -- In  :
            RST                     => RST                         , -- In  :
            CLR                     => M_CLR                       , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Request Signals.
        ---------------------------------------------------------------------------
            M_REQ_ADDR              => M_REQ_ADDR                  , -- Out :
            M_REQ_SIZE              => M_REQ_SIZE                  , -- Out :
            M_REQ_BUF_PTR           => M_REQ_BUF_PTR               , -- Out :
            M_REQ_MODE              => M_REQ_MODE                  , -- Out :
            M_REQ_DIR               => M_REQ_DIR                   , -- Out :
            M_REQ_FIRST             => M_REQ_FIRST                 , -- Out :
            M_REQ_LAST              => M_REQ_LAST                  , -- Out :
            M_REQ_VALID             => M_REQ_VALID                 , -- Out :
            M_REQ_READY             => M_REQ_READY                 , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Acknowledge Signals.
        ---------------------------------------------------------------------------
            M_ACK_VALID             => M_ACK_VALID                 , -- In  :
            M_ACK_NEXT              => M_ACK_NEXT                  , -- In  :
            M_ACK_LAST              => M_ACK_LAST                  , -- In  :
            M_ACK_ERROR             => M_ACK_ERROR                 , -- In  :
            M_ACK_STOP              => M_ACK_STOP                  , -- In  :
            M_ACK_NONE              => M_ACK_NONE                  , -- In  :
            M_ACK_SIZE              => M_ACK_SIZE                  , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Outlet Flow Signals.
        ---------------------------------------------------------------------------
            O_FLOW_READY            => M_O_FLOW_RDY                , -- Out :
            O_FLOW_PAUSE            => M_O_FLOW_PAUSE              , -- Out :
            O_FLOW_STOP             => M_O_FLOW_STOP               , -- Out :
            O_FLOW_LAST             => M_O_FLOW_LAST               , -- Out :
            O_FLOW_SIZE             => M_O_FLOW_SIZE               , -- Out :
            O_POOL_READY            => M_O_POOL_RDY                , -- Out :
            O_FLOW_READY_LEVEL      => M_O_FLOW_RDY_LVL            , -- In  :
            O_POOL_READY_LEVEL      => M_O_POOL_RDY_LVL            , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Intake Flow Signals.
        ---------------------------------------------------------------------------
            I_FLOW_PAUSE            => M_I_FLOW_PAUSE              , -- Out :
            I_FLOW_STOP             => M_I_FLOW_STOP               , -- Out :
            I_FLOW_LAST             => M_I_FLOW_LAST               , -- Out :
            I_FLOW_SIZE             => M_I_FLOW_SIZE               , -- Out :
            I_FLOW_READY            => M_I_FLOW_RDY                , -- Out :
            I_POOL_READY            => M_I_POOL_RDY                , -- Out :
            I_FLOW_READY_LEVEL      => M_I_FLOW_RDY_LVL            , -- In  :
            I_POOL_READY_LEVEL      => M_I_POOL_RDY_LVL            , -- In  :
            I_POOL_SIZE             => M_I_POOL_SIZE               , -- In  :
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
            T_REQ_START             => q_req_start                 , -- In  :
            T_REQ_ADDR              => q_req_addr                  , -- In  :
            T_REQ_SIZE              => q_req_size                  , -- In  :
            T_REQ_BUF_PTR           => q_req_buf_ptr               , -- In  :
            T_REQ_FIRST             => q_req_first                 , -- In  :
            T_REQ_LAST              => q_req_last                  , -- In  :
            T_REQ_MODE              => q_req_mode                  , -- In  :
            T_REQ_DIR               => q_req_dir                   , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            T_RES_START             => q_res_start                 , -- Out :
            T_RES_DONE              => q_res_done                  , -- Out :
            T_RES_ERROR             => q_res_error                 , -- Out :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            T_PUSH_FIN_VALID        => q_push_fin_valid            , -- In  :
            T_PUSH_FIN_LAST         => q_push_fin_last             , -- In  :
            T_PUSH_FIN_ERR          => q_push_fin_error            , -- In  :
            T_PUSH_FIN_SIZE         => q_push_fin_size             , -- In  :
            T_PUSH_RSV_VALID        => q_push_rsv_valid            , -- In  :
            T_PUSH_RSV_LAST         => q_push_rsv_last             , -- In  :
            T_PUSH_RSV_ERR          => q_push_rsv_error            , -- In  :
            T_PUSH_RSV_SIZE         => q_push_rsv_size             , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            T_PULL_FIN_VALID        => q_pull_fin_valid            , -- In  :
            T_PULL_FIN_LAST         => q_pull_fin_last             , -- In  :
            T_PULL_FIN_ERR          => q_pull_fin_error            , -- In  :
            T_PULL_FIN_SIZE         => q_pull_fin_size             , -- In  :
            T_PULL_RSV_VALID        => q_pull_rsv_valid            , -- In  :
            T_PULL_RSV_LAST         => q_pull_rsv_last             , -- In  :
            T_PULL_RSV_ERR          => q_pull_rsv_error            , -- In  :
            T_PULL_RSV_SIZE         => q_pull_rsv_size               -- In  :
        );
end RTL;
