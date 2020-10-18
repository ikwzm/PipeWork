-----------------------------------------------------------------------------------
--!     @file    pump_components.vhd                                             --
--!     @brief   PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION                    --
--!     @version 1.8.3                                                           --
--!     @date    2020/10/18                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2020 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
--      All rights reserved.                                                     --
--                                                                               --
--      Redistribution and use in source and binary forms, with or without       --
--      modification, are permitted provided that the following conditions       --
--      are met:                                                                 --
--                                                                               --
--        1. Redistributions of source code must retain the above copyright      --
--           notice, this list of conditions and the following disclaimer.       --
--                                                                               --
--        2. Redistributions in binary form must reproduce the above copyright   --
--           notice, this list of conditions and the following disclaimer in     --
--           the documentation and/or other materials provided with the          --
--           distribution.                                                       --
--                                                                               --
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT    --
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,    --
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT         --
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    --
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY    --
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      --
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE    --
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.     --
--                                                                               --
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
-----------------------------------------------------------------------------------
--! @brief PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION                          --
-----------------------------------------------------------------------------------
package PUMP_COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief PUMP_CONTROL_REGISTER                                                 --
-----------------------------------------------------------------------------------
component PUMP_CONTROL_REGISTER
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
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_FLOW_SYNCRONIZER                                                 --
-----------------------------------------------------------------------------------
component PUMP_FLOW_SYNCRONIZER
    generic (
        I_CLK_RATE      : --! @brief INPUT CLOCK RATE :
                          --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        O_CLK_RATE      : --! @brief OUTPUT CLOCK RATE :
                          --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        OPEN_INFO_BITS  : --! @brief OPEN INFOMATION BITS :
                          --! I_OPEN_INFO/O_OPEN_INFOのビット数を指定する.
                          integer :=  1;
        CLOSE_INFO_BITS : --! @brief CLOSE INFOMATION BITS :
                          --! I_CLOSE_INFO/O_CLOSE_INFOのビット数を指定する.
                          integer :=  1;
        EVENT_SIZE      : --! @brief EVENT SIZE
                          --! イベントの数を指定する.
                          integer :=  1;
        XFER_SIZE_BITS  : --! @brief SIZE BITS :
                          --! 各種サイズ信号のビット数を指定する.
                          integer :=  8;
        PUSH_FIN_VALID  : --! @brief PUSH FINAL SIZE VALID :
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PUSH_FIN_VALID = 1 : 有効. 
                          --! * PUSH_FIN_VALID = 0 : 無効. 回路は省略される.
                          integer range 0 to 1 := 1;
        PUSH_FIN_DELAY  : --! @brief PUSH FINAL SIZE DELAY CYCLE :
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST を遅延するサ
                          --! イクル数を指定する.
                          integer :=  0;
        PUSH_RSV_VALID  : --! @brief PUSH RESERVE SIZE VALID :
                          --! PUSH_RSV_VAL/PUSH_RSV_SIZE/PUSH_RSV_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PUSH_RSV_VALID = 1 : 有効. 
                          --! * PUSH_RSV_VALID = 0 : 無効. 回路は省略される.
                          integer range 0 to 1 := 1;
        PULL_FIN_VALID  : --! @brief PULL FINAL SIZE VALID :
                          --! PULL_FIN_VAL/PULL_FIN_SIZE/PULL_FIN_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PULL_FIN_VALID = 1 : 有効. 
                          --! * PULL_FIN_VALID = 0 : 無効. 回路は省略される.
                          integer range 0 to 1 := 1;
        PULL_RSV_VALID  : --! @brief PULL RESERVE SIZE VALID :
                          --! PULL_RSV_VAL/PULL_RSV_SIZE/PULL_RSV_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PULL_RSV_VALID = 1 : 有効. 
                          --! * PULL_RSV_VALID = 0 : 無効. 回路は省略される.
                          integer range 0 to 1 := 1
    );
    port (
    -------------------------------------------------------------------------------
    -- Asyncronous Reset Signal.
    -------------------------------------------------------------------------------
        RST             : --! @brief RESET :
                          --! 非同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Input Clock and Clock Enable and Syncronous reset.
    -------------------------------------------------------------------------------
        I_CLK           : --! @brief INPUT CLOCK :
                          --! 入力側のクロック信号.
                          in  std_logic;
        I_CLR           : --! @brief INPUT CLEAR :
                          --! 入力側の同期リセット信号(ハイ・アクティブ).
                          in  std_logic := '0';
        I_CKE           : --! @brief INPUT CLOCK ENABLE :
                          --! 入力側のクロック(I_CLK)の立上りが有効であることを示す信号.
                          --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の
                          --!   位相関係を示す時に使用する.
                          --! * I_CLKの立上り時とOCLKの立上り時が同じ時にアサートす
                          --!   るように入力されなければならない.
                          --! * この信号は I_CLK_RATE > 1 かつ O_CLK_RATE = 1の時の
                          --!   み有効. それ以外は未使用.
                          in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- 入力側からのOPEN(トランザクションの開始)を指示する信号.
    -------------------------------------------------------------------------------
        I_OPEN_VAL      : --! @brief INPUT OPEN VALID :
                          --! 入力側からのOPEN(トランザクションの開始)を指示する信号.
                          --! * I_OPEN_INFO が有効であることを示す.
                          in  std_logic := '0';
        I_OPEN_INFO     : --! @brief INPUT OPEN INFOMATION DATA :
                          --! OPEN(トランザクションの開始)時に出力側に伝達する各種
                          --! 情報入力.
                          --! * I_OPEN_VALがアサートされている時のみ有効.
                          in  std_logic_vector(OPEN_INFO_BITS -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのCLOSE(トランザクションの終了)を指示する信号.
    -------------------------------------------------------------------------------
        I_CLOSE_VAL     : --! @brief INPUT CLOSE VALID :
                          --! 入力側からのCLOSE(トランザクションの終了)を指示する信号.
                          --! * I_CLOSE_INFO が有効であることを示す.
                          in  std_logic := '0';
        I_CLOSE_INFO    : --! @brief INPUT CLOSE INFOMATION DATA :
                          --! CLOSE(トランザクションの終了)時に出力側に伝達する各種
                          --! 情報入力.
                          --! * I_CLOSE_VALがアサートされている時のみ有効.
                          in  std_logic_vector(CLOSE_INFO_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのイベントを通知する信号.
    -------------------------------------------------------------------------------
        I_EVENT         : --! @brief INPUT EVENT
                          in  std_logic_vector(EVENT_SIZE     -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのPUSH_FIN(入力側から出力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PUSH_FIN_VAL  : --! @brief INPUT PUSH FINAL VALID :
                          --! * I_PUSH_FIN_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PUSH_FIN_LAST : --! @brief INPUT PUSH FINAL LAST FLAG :
                          --! 入力側から出力側へ最後の"確定した"転送であることを示す.
                          in  std_logic := '0';
        I_PUSH_FIN_SIZE : --! @brief INPUT PUSH FINAL SIZE :
                          --! 入力側から出力側への転送が"確定した"バイト数を入力.
                          in  std_logic_vector(XFER_SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのPUSH_RSV(入力側から出力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PUSH_RSV_VAL  : --! @brief INPUT PUSH RESERVE VALID :
                          --! * I_PUSH_RSV_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PUSH_RSV_LAST : --! @brief INPUT PUSH RESERVE LAST FLAG :
                          --! 入力側から出力側へ最後の"予定された"転送であることを示す.
                          in  std_logic := '0';
        I_PUSH_RSV_SIZE : --! @brief INPUT PUSH RESERVE SIZE :
                          --! 入力側から出力側への転送が"予定された"バイト数を入力.
                          in  std_logic_vector(XFER_SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのPULL_FIN(出力側から入力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PULL_FIN_VAL  : --! @brief INPUT PULL FINAL VALID :
                          --! * I_PULL_FIN_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PULL_FIN_LAST : --! @brief INPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"確定した"転送であることを示す.
                          in  std_logic := '0';
        I_PULL_FIN_SIZE : --! @brief INPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送が"確定した"バイト数を入力.
                          in  std_logic_vector(XFER_SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのPULL_RSV(出力側から入力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PULL_RSV_VAL  : --! @brief INPUT PULL RESERVE VALID :
                          --! * I_PULL_RSV_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PULL_RSV_LAST : --! @brief INPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"予定された"転送であることを示す.
                          in  std_logic := '0';
        I_PULL_RSV_SIZE : --! @brief INPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送"が予定された"バイト数を入力.
                          in  std_logic_vector(XFER_SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Output Clock and Clock Enable and Syncronous reset.
    -------------------------------------------------------------------------------
        O_CLK           : --! @brief OUTPUT CLOCK :
                          --! 入力側のクロック信号.
                          in  std_logic;
        O_CLR           : --! @brief OUTPUT CLEAR :
                          --! 入力側の同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
        O_CKE           : --! @brief OUTPUT CLOCK ENABLE :
                          --! 出力側のクロック(O_CLK)の立上りが有効であることを示す信号.
                          --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の
                          --!   位相関係を示す時に使用する.
                          --! * I_CLKの立上り時とO_CLKの立上り時が同じ時にアサートす
                          --!   るように入力されなければならない.
                          --! * この信号は O_CLK_RATE > 1 かつ I_CLK_RATE = 1の時のみ
                          --!   有効. それ以外は未使用.
                          in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- 出力側へのOPEN(トランザクションの開始)を指示する信号.
    -------------------------------------------------------------------------------
        O_OPEN_VAL      : --! @brief OUTPUT OPEN VALID :
                          --! 出力側へのOPEN(トランザクションの開始)を指示する信号.
                          --! * O_OPEN_INFO が有効であることを示す.
                          out std_logic;
        O_OPEN_INFO     : --! @brief OUTPUT OPEN INFOMATION DATA :
                          --! OPEN(トランザクションの開始)時に出力側に伝達する各種
                          --! 情報出力.
                          --! * I_OPEN_VALがアサートされている時のみ有効.
                          out std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのCLOSE(トランザクションの終了)を指示する信号.
    -------------------------------------------------------------------------------
        O_CLOSE_VAL     : --! @brief OUTPUT CLOSE VALID :
                          --! 出力側へCLOSE(トランザクションの終了)を指示する信号.
                          --! * O_CLOSE_VAL/INFO は O_PUSH_FIN_XXX の出力タイミング
                          --!   に合わせて出力される.
                          out std_logic;
        O_CLOSE_INFO    : --! @brief OUTPUT CLOSE INFOMATION DATA :
                          --! CLOSE(トランザクションの終了)時に出力側に伝達する各種
                          --! 情報出力.
                          --! * I_CLOSE_VALがアサートされている時のみ有効.
                          out std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのイベントを通知する信号.
    -------------------------------------------------------------------------------
        O_EVENT         : --! @brief OUTPUT EVENT
                          out std_logic_vector(EVENT_SIZE     -1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのPUSH_FIN(入力側から出力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PUSH_FIN_VAL  : --! @brief OUTPUT PUSH FINAL VALID :
                          --! * O_PUSH_FIN_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PUSH_FIN_LAST : --! @brief OUTPUT PUSH FINAL LAST FLAG :
                          --! 入力側から出力側へ最後の"確定した"転送であることを示す.
                          out std_logic;
        O_PUSH_FIN_SIZE : --! @brief OUTPUT PUSH FINAL SIZE :
                          --! 入力側から出力側への転送が"確定した"バイト数を出力.
                          out std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのPUSH_RSV(入力側から出力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PUSH_RSV_VAL  : --! @brief OUTPUT PUSH RESERVE VALID :
                          --! * O_PUSH_RSV_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PUSH_RSV_LAST : --! @brief OUTPUT PUSH RESERVE LAST FLAG :
                          --! 入力側から出力側へ最後の"予定された"転送であることを示す.
                          out std_logic;
        O_PUSH_RSV_SIZE : --! @brief OUTPUT PUSH RESERVE SIZE :
                          --! 入力側から出力側への転送が"予定された"バイト数を出力.
                          out std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのPULL_FIN(出力側から入力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PULL_FIN_VAL  : --! @brief OUTPUT PULL FINAL VALID :
                          --! * O_PULL_FIN_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PULL_FIN_LAST : --! @brief OUTPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"確定した"転送であることを示す.
                          out std_logic;
        O_PULL_FIN_SIZE : --! @brief OUTPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送が"確定した"バイト数を出力.
                          out std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのPULL_RSV(出力側から入力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PULL_RSV_VAL  : --! @brief OUTPUT PULL RESERVE VALID :
                          --! * O_PULL_RSV_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PULL_RSV_LAST : --! @brief OUTPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"予定された"転送であることを示す.
                          out std_logic;
        O_PULL_RSV_SIZE : --! @brief OUTPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送"が予定された"バイト数を出力.
                          out std_logic_vector(XFER_SIZE_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_CONTROLLER_INTAKE_SIDE                                           --
-----------------------------------------------------------------------------------
component PUMP_CONTROLLER_INTAKE_SIDE
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
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_CONTROLLER_OUTLET_SIDE                                           --
-----------------------------------------------------------------------------------
component PUMP_CONTROLLER_OUTLET_SIDE
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
                              --! PULL_BUF_READYを常に'1'にするか否かを指定する.
                              --! * FIXED_POOL_OPEN=1で常に'1'にする.
                              --! * FIXED_POOL_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        USE_PULL_BUF_SIZE   : --! @brief USE PULL BUFFER SIZE :
                              --! PULL_BUF_SIZE信号を使用するか否かを指示する.
                              --! * USE_PULL_BUF_SIZE=0で使用しない.
                              --! * USE_PULL_BUF_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        USE_PUSH_RSV_SIZE   : --! @brief USE PUSH RESERVE SIZE :
                              --! PUSH_RSV_SIZE信号を使用するか否かを指示する.
                              --! * USE_PUSH_RSV_SIZE=0で使用しない.
                              --! * USE_PUSH_RSV_SIZE=1で使用する.
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
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY          : out std_logic;
        FLOW_PAUSE          : out std_logic;
        FLOW_STOP           : out std_logic;
        FLOW_LAST           : out std_logic;
        FLOW_SIZE           : out std_logic_vector(BUF_DEPTH       downto 0);
        PULL_FIN_VALID      : in  std_logic := '0';
        PULL_FIN_LAST       : in  std_logic := '0';
        PULL_FIN_ERROR      : in  std_logic := '0';
        PULL_FIN_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
        PULL_RSV_VALID      : in  std_logic := '0';
        PULL_RSV_LAST       : in  std_logic := '0';
        PULL_RSV_ERROR      : in  std_logic := '0';
        PULL_RSV_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
        PULL_BUF_RESET      : in  std_logic := '0';
        PULL_BUF_VALID      : in  std_logic := '0';
        PULL_BUF_LAST       : in  std_logic := '0';
        PULL_BUF_ERROR      : in  std_logic := '0';
        PULL_BUF_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
        PULL_BUF_READY      : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        PUSH_FIN_VALID      : in  std_logic := '0';
        PUSH_FIN_LAST       : in  std_logic := '0';
        PUSH_FIN_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
        PUSH_RSV_VALID      : in  std_logic := '0';
        PUSH_RSV_LAST       : in  std_logic := '0';
        PUSH_RSV_SIZE       : in  std_logic_vector(BUF_DEPTH       downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Intake Status Input.
    -------------------------------------------------------------------------------
        I_OPEN              : in  std_logic;
        I_STOP              : in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Outlet Status Output.
    -------------------------------------------------------------------------------
        O_OPEN              : out std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Status Signals.
    -------------------------------------------------------------------------------
        TRAN_BUSY           : out std_logic;
        TRAN_DONE           : out std_logic;
        TRAN_NONE           : out std_logic;
        TRAN_ERROR          : out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_CONTROLLER                                                       --
-----------------------------------------------------------------------------------
component PUMP_CONTROLLER
    generic (
        I_CLK_RATE          : --! @brief INPUT CLOCK RATE :
                              --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側
                              --! のクロック(O_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        I_REQ_ADDR_VALID    : --! @brief INTAKE REQUEST ADDRESS VALID :
                              --! I_REQ_ADDR信号を有効にするか否かを指示する.
                              --! * I_REQ_ADDR_VALID=0で無効.
                              --! * I_REQ_ADDR_VALID=1で有効.
                              integer range 0 to 1 := 1;
        I_REQ_ADDR_BITS     : --! @brief INTAKE REQUEST ADDRESS BITS :
                              --! I_REQ_ADDR信号のビット数を指定する.
                              --! * I_REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_ADDR_BITS     : --! @brief INTAKE ADDRESS REGISTER BITS :
                              --! I_REG_ADDR信号のビット数を指定する.
                              --! * I_REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REQ_SIZE_VALID    : --! @brief INTAKE REQUEST SIZE VALID :
                              --! I_REQ_SIZE信号を有効にするか否かを指示する.
                              --! * I_REQ_SIZE_VALID=0で無効.
                              --! * I_REQ_SIZE_VALID=1で有効.
                              integer range 0 to 1 := 1;
        I_REQ_SIZE_BITS     : --! @brief INTAKE REQUEST SIZE BITS :
                              --! I_REQ_SIZE信号のビット数を指定する.
                              --! * I_REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_SIZE_BITS     : --! @brief INTAKE SIZE REGISTER BITS :
                              --! I_REG_SIZE信号のビット数を指定する.
                              --! * I_REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_MODE_BITS     : --! @brief INTAKE MODE REGISTER BITS :
                              --! I_MODE_L/I_MODE_D/I_MODE_Qのビット数を指定する.
                              integer := 32;
        I_REG_STAT_BITS     : --! @brief INTAKE STATUS REGISTER BITS :
                              --! I_STAT_L/I_STAT_D/I_STAT_Qのビット数を指定する.
                              integer := 32;
        I_USE_PUSH_RSV_SIZE : --! @brief INTAKE USE PUSH RESERVE SIZE :
                              --! I_PUSH_RSV_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PUSH_RSV_SIZE=0で使用しない.
                              --! * I_USE_PUSH_RSV_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        I_USE_PUSH_BUF_SIZE : --! @brief INTAKE USE PUSH BUFFER SIZE :
                              --! I_PUSH_BUF_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PUSH_BUF_SIZE=0で使用しない.
                              --! * I_USE_PUSH_BUF_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        I_FIXED_FLOW_OPEN   : --! @brief INTAKE VALVE FIXED FLOW OPEN :
                              --! I_FLOW_READYを常に'1'にするか否かを指定する.
                              --! * I_FIXED_FLOW_OPEN=1で常に'1'にする.
                              --! * I_FIXED_FLOW_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        I_FIXED_POOL_OPEN   : --! @brief INTAKE VALVE FIXED POOL OPEN :
                              --! I_PUSH_BUF_READYを常に'1'にするか否かを指定する.
                              --! * I_FIXED_POOL_OPEN=1で常に'1'にする.
                              --! * I_FIXED_POOL_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        O_CLK_RATE          : --! @brief OUTPUT CLOCK RATE :
                              --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側
                              --! のクロック(O_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        O_REQ_ADDR_VALID    : --! @brief OUTLET REQUEST ADDRESS VALID :
                              --! O_REQ_ADDR信号を有効にするか否かを指示する.
                              --! * O_REQ_ADDR_VAL=0で無効.
                              --! * O_REQ_ADDR_VAL=1で有効.
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
                              --! * O_REQ_SIZE_VAL=0で無効.
                              --! * O_REQ_SIZE_VAL=1で有効.
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
        O_USE_PULL_RSV_SIZE : --! @brief OUTLET USE PULL RESERVE SIZE :
                              --! I_PULL_RSV_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PULL_RSV_SIZE=0で使用しない.
                              --! * I_USE_PULL_RSV_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        O_USE_PULL_BUF_SIZE : --! @brief OUTLET USE PULL BUFFER SIZE :
                              --! I_PULL_BUF_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PULL_BUF_SIZE=0で使用しない.
                              --! * I_USE_PULL_BUF_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        BUF_DEPTH           : --! @brief BUFFER DEPTH :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
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
    -- Intake Clock and Clock Enable.
    -------------------------------------------------------------------------------
        I_CLK               : in  std_logic;
        I_CLR               : in  std_logic;
        I_CKE               : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Intake Control Register Interface.
    -------------------------------------------------------------------------------
        I_ADDR_L            : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0) := (others => '0');
        I_ADDR_D            : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0) := (others => '0');
        I_ADDR_Q            : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_SIZE_L            : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0) := (others => '0');
        I_SIZE_D            : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0) := (others => '0');
        I_SIZE_Q            : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_MODE_L            : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0) := (others => '0');
        I_MODE_D            : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0) := (others => '0');
        I_MODE_Q            : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_STAT_L            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_STAT_D            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_STAT_Q            : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_I            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_RESET_L           : in  std_logic := '0';
        I_RESET_D           : in  std_logic := '0';
        I_RESET_Q           : out std_logic;
        I_START_L           : in  std_logic := '0';
        I_START_D           : in  std_logic := '0';
        I_START_Q           : out std_logic;
        I_STOP_L            : in  std_logic := '0';
        I_STOP_D            : in  std_logic := '0';
        I_STOP_Q            : out std_logic;
        I_PAUSE_L           : in  std_logic := '0';
        I_PAUSE_D           : in  std_logic := '0';
        I_PAUSE_Q           : out std_logic;
        I_FIRST_L           : in  std_logic := '0';
        I_FIRST_D           : in  std_logic := '0';
        I_FIRST_Q           : out std_logic;
        I_LAST_L            : in  std_logic := '0';
        I_LAST_D            : in  std_logic := '0';
        I_LAST_Q            : out std_logic;
        I_DONE_EN_L         : in  std_logic := '0';
        I_DONE_EN_D         : in  std_logic := '0';
        I_DONE_EN_Q         : out std_logic;
        I_DONE_ST_L         : in  std_logic := '0';
        I_DONE_ST_D         : in  std_logic := '0';
        I_DONE_ST_Q         : out std_logic;
        I_ERR_ST_L          : in  std_logic := '0';
        I_ERR_ST_D          : in  std_logic := '0';
        I_ERR_ST_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Configuration Signals.
    -------------------------------------------------------------------------------
        I_ADDR_FIX          : in  std_logic := '0';
        I_BUF_READY_LEVEL   : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_FLOW_READY_LEVEL  : in  std_logic_vector(BUF_DEPTH         downto 0);
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
    -------------------------------------------------------------------------------
    -- Outlet Configuration Signals.
    -------------------------------------------------------------------------------
        O_ADDR_FIX          : in  std_logic := '0';
        O_BUF_READY_LEVEL   : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_FLOW_READY_LEVEL  : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        I_REQ_VALID         : out std_logic;
        I_REQ_ADDR          : out std_logic_vector(I_REQ_ADDR_BITS-1 downto 0);
        I_REQ_SIZE          : out std_logic_vector(I_REQ_SIZE_BITS-1 downto 0);
        I_REQ_BUF_PTR       : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        I_REQ_FIRST         : out std_logic;
        I_REQ_LAST          : out std_logic;
        I_REQ_NONE          : out std_logic;
        I_REQ_READY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        I_ACK_VALID         : in  std_logic;
        I_ACK_SIZE          : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_ACK_ERROR         : in  std_logic;
        I_ACK_NEXT          : in  std_logic;
        I_ACK_LAST          : in  std_logic;
        I_ACK_STOP          : in  std_logic;
        I_ACK_NONE          : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transfer Status Signals.
    -------------------------------------------------------------------------------
        I_XFER_BUSY         : in  std_logic;
        I_XFER_DONE         : in  std_logic;
        I_XFER_ERROR        : in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        I_FLOW_READY        : out std_logic;
        I_FLOW_PAUSE        : out std_logic;
        I_FLOW_STOP         : out std_logic;
        I_FLOW_LAST         : out std_logic;
        I_FLOW_SIZE         : out std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_FIN_VALID    : in  std_logic := '0';
        I_PUSH_FIN_LAST     : in  std_logic := '0';
        I_PUSH_FIN_ERROR    : in  std_logic := '0';
        I_PUSH_FIN_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_RSV_VALID    : in  std_logic := '0';
        I_PUSH_RSV_LAST     : in  std_logic := '0';
        I_PUSH_RSV_ERROR    : in  std_logic := '0';
        I_PUSH_RSV_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_BUF_RESET    : in  std_logic := '0';
        I_PUSH_BUF_VALID    : in  std_logic := '0';
        I_PUSH_BUF_LAST     : in  std_logic := '0';
        I_PUSH_BUF_ERROR    : in  std_logic := '0';
        I_PUSH_BUF_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Status.
    -------------------------------------------------------------------------------
        I_OPEN              : out std_logic;
        I_RUNNING           : out std_logic;
        I_DONE              : out std_logic;
        I_NONE              : out std_logic;
        I_ERROR             : out std_logic;
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
    -- Outlet Transaction Command Response Signals.
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
    -- Outlet Status.
    -------------------------------------------------------------------------------
        O_OPEN              : out std_logic;
        O_RUNNING           : out std_logic;
        O_DONE              : out std_logic;
        O_NONE              : out std_logic;
        O_ERROR             : out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_STREAM_INTAKE_CONTROLLER                                         --
-----------------------------------------------------------------------------------
component PUMP_STREAM_INTAKE_CONTROLLER
    generic (
        I_CLK_RATE          : --! @brief INPUT CLOCK RATE :
                              --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側
                              --! のクロック(O_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        I_REQ_ADDR_VALID    : --! @brief INTAKE REQUEST ADDRESS VALID :
                              --! I_REQ_ADDR信号を有効にするか否かを指示する.
                              --! * I_REQ_ADDR_VALID=0で無効.
                              --! * I_REQ_ADDR_VALID=1で有効.
                              integer range 0 to 1 := 1;
        I_REQ_ADDR_BITS     : --! @brief INTAKE REQUEST ADDRESS BITS :
                              --! I_REQ_ADDR信号のビット数を指定する.
                              --! * I_REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_ADDR_BITS     : --! @brief INTAKE ADDRESS REGISTER BITS :
                              --! I_REG_ADDR信号のビット数を指定する.
                              --! * I_REQ_ADDR_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REQ_SIZE_VALID    : --! @brief INTAKE REQUEST SIZE VALID :
                              --! I_REQ_SIZE信号を有効にするか否かを指示する.
                              --! * I_REQ_SIZE_VALID=0で無効.
                              --! * I_REQ_SIZE_VALID=1で有効.
                              integer range 0 to 1 := 1;
        I_REQ_SIZE_BITS     : --! @brief INTAKE REQUEST SIZE BITS :
                              --! I_REQ_SIZE信号のビット数を指定する.
                              --! * I_REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_SIZE_BITS     : --! @brief INTAKE SIZE REGISTER BITS :
                              --! I_REG_SIZE信号のビット数を指定する.
                              --! * I_REQ_SIZE_VALID=0の場合でもビット数は１以上を
                              --!   指定しなければならない.
                              integer := 32;
        I_REG_MODE_BITS     : --! @brief INTAKE MODE REGISTER BITS :
                              --! I_MODE_L/I_MODE_D/I_MODE_Qのビット数を指定する.
                              integer := 32;
        I_REG_STAT_BITS     : --! @brief INTAKE STATUS REGISTER BITS :
                              --! I_STAT_L/I_STAT_D/I_STAT_Qのビット数を指定する.
                              integer := 32;
        I_USE_PUSH_BUF_SIZE : --! @brief INTAKE USE PUSH BUFFER SIZE :
                              --! I_PUSH_BUF_SIZE信号を使用するか否かを指示する.
                              --! * I_USE_PUSH_BUF_SIZE=0で使用しない.
                              --! * I_USE_PUSH_BUF_SIZE=1で使用する.
                              integer range 0 to 1 := 0;
        I_FIXED_FLOW_OPEN   : --! @brief INTAKE VALVE FIXED FLOW OPEN :
                              --! I_FLOW_READYを常に'1'にするか否かを指定する.
                              --! * I_FIXED_FLOW_OPEN=1で常に'1'にする.
                              --! * I_FIXED_FLOW_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        I_FIXED_POOL_OPEN   : --! @brief INTAKE VALVE FIXED POOL OPEN :
                              --! I_PUSH_BUF_READYを常に'1'にするか否かを指定する.
                              --! * I_FIXED_POOL_OPEN=1で常に'1'にする.
                              --! * I_FIXED_POOL_OPEN=0で状況に応じて開閉する.
                              integer range 0 to 1 := 0;
        O_CLK_RATE          : --! @brief OUTPUT CLOCK RATE :
                              --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側
                              --! のクロック(O_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        O_DATA_BITS         : --! @brief OUTPUT STREAM DATA BITS :
                              --! O_DATA のビット数を指定する.
                              integer := 32;
        O_WORD_BITS         : --! @brief INPUT STREAM WORD BITS :
                              --! O_DATA の１ワードあたりのビット数を指定する.
                              --! * O_DATA_BITS   >=  O_WORD_BITS でなければならない.
                              --! * O_DATA_BITS   mod O_WORD_BITS = 0 でなければならない.
                              --! * BUF_DATA_BITS >=  O_WORD_BITS でなければならない.
                              --! * BUF_DATA_BITS mod O_WORD_BITS = 0 でなければならない.
                              integer := 8;
        BUF_DEPTH           : --! @brief BUFFER DEPTH :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        BUF_DATA_BITS       : --! @brief BUFFER DATA BITS :
                              --! BUF_DATA のビット数を指定する.
                              integer := 32;
        I2O_OPEN_INFO_BITS  : --! @brief I2O_OPEN_INFO BITS :
                              --! I_I2O_OPEN_INFO/O_I2O_OPEN_INFO のビット数を指定する.
                              integer :=  1;
        I2O_CLOSE_INFO_BITS : --! @brief I2O_CLOSE_INFO BITS :
                              --! I_I2O_CLOSE_INFO/O_I2O_CLOSE_INFO のビット数を指定する.
                              integer :=  1;
        O2I_OPEN_INFO_BITS  : --! @brief O2I_OPEN_INFO BITS :
                              --! I_O2I_OPEN_INFO/O_O2I_OPEN_INFO のビット数を指定する.
                              integer :=  1;
        O2I_CLOSE_INFO_BITS : --! @brief O2I_CLOSE_INFO BITS :
                              --! I_O2I_CLOSE_INFO/O_O2I_CLOSE_INFO のビット数を指定する.
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
    -- Intake Clock and Clock Enable.
    -------------------------------------------------------------------------------
        I_CLK               : in  std_logic;
        I_CLR               : in  std_logic;
        I_CKE               : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Intake Control Register Interface.
    -------------------------------------------------------------------------------
        I_ADDR_L            : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0) := (others => '0');
        I_ADDR_D            : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0) := (others => '0');
        I_ADDR_Q            : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_SIZE_L            : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0) := (others => '0');
        I_SIZE_D            : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0) := (others => '0');
        I_SIZE_Q            : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_MODE_L            : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0) := (others => '0');
        I_MODE_D            : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0) := (others => '0');
        I_MODE_Q            : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_STAT_L            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_STAT_D            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_STAT_Q            : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_I            : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0) := (others => '0');
        I_RESET_L           : in  std_logic := '0';
        I_RESET_D           : in  std_logic := '0';
        I_RESET_Q           : out std_logic;
        I_START_L           : in  std_logic := '0';
        I_START_D           : in  std_logic := '0';
        I_START_Q           : out std_logic;
        I_STOP_L            : in  std_logic := '0';
        I_STOP_D            : in  std_logic := '0';
        I_STOP_Q            : out std_logic;
        I_PAUSE_L           : in  std_logic := '0';
        I_PAUSE_D           : in  std_logic := '0';
        I_PAUSE_Q           : out std_logic;
        I_FIRST_L           : in  std_logic := '0';
        I_FIRST_D           : in  std_logic := '0';
        I_FIRST_Q           : out std_logic;
        I_LAST_L            : in  std_logic := '0';
        I_LAST_D            : in  std_logic := '0';
        I_LAST_Q            : out std_logic;
        I_DONE_EN_L         : in  std_logic := '0';
        I_DONE_EN_D         : in  std_logic := '0';
        I_DONE_EN_Q         : out std_logic;
        I_DONE_ST_L         : in  std_logic := '0';
        I_DONE_ST_D         : in  std_logic := '0';
        I_DONE_ST_Q         : out std_logic;
        I_ERR_ST_L          : in  std_logic := '0';
        I_ERR_ST_D          : in  std_logic := '0';
        I_ERR_ST_Q          : out std_logic;
        I_CLOSE_ST_L        : in  std_logic := '0';
        I_CLOSE_ST_D        : in  std_logic := '0';
        I_CLOSE_ST_Q        : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Configuration Signals.
    -------------------------------------------------------------------------------
        I_ADDR_FIX          : in  std_logic := '0';
        I_BUF_READY_LEVEL   : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_FLOW_READY_LEVEL  : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        I_REQ_VALID         : out std_logic;
        I_REQ_ADDR          : out std_logic_vector(I_REQ_ADDR_BITS-1 downto 0);
        I_REQ_SIZE          : out std_logic_vector(I_REQ_SIZE_BITS-1 downto 0);
        I_REQ_BUF_PTR       : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        I_REQ_FIRST         : out std_logic;
        I_REQ_LAST          : out std_logic;
        I_REQ_NONE          : out std_logic;
        I_REQ_READY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        I_ACK_VALID         : in  std_logic;
        I_ACK_SIZE          : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_ACK_ERROR         : in  std_logic;
        I_ACK_NEXT          : in  std_logic;
        I_ACK_LAST          : in  std_logic;
        I_ACK_STOP          : in  std_logic;
        I_ACK_NONE          : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transfer Status Signals.
    -------------------------------------------------------------------------------
        I_XFER_BUSY         : in  std_logic;
        I_XFER_DONE         : in  std_logic;
        I_XFER_ERROR        : in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        I_FLOW_READY        : out std_logic;
        I_FLOW_PAUSE        : out std_logic;
        I_FLOW_STOP         : out std_logic;
        I_FLOW_LAST         : out std_logic;
        I_FLOW_SIZE         : out std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_FIN_VALID    : in  std_logic := '0';
        I_PUSH_FIN_LAST     : in  std_logic := '0';
        I_PUSH_FIN_ERROR    : in  std_logic := '0';
        I_PUSH_FIN_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_RSV_VALID    : in  std_logic := '0';
        I_PUSH_RSV_LAST     : in  std_logic := '0';
        I_PUSH_RSV_ERROR    : in  std_logic := '0';
        I_PUSH_RSV_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_BUF_RESET    : in  std_logic := '0';
        I_PUSH_BUF_VALID    : in  std_logic := '0';
        I_PUSH_BUF_LAST     : in  std_logic := '0';
        I_PUSH_BUF_ERROR    : in  std_logic := '0';
        I_PUSH_BUF_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0) := (others => '0');
        I_PUSH_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Status Signals.
    -------------------------------------------------------------------------------
        I_OPEN              : out std_logic;
        I_TRAN_BUSY         : out std_logic;
        I_TRAN_DONE         : out std_logic;
        I_TRAN_NONE         : out std_logic;
        I_TRAN_ERROR        : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Open/Close Infomation Interface Signals.
    -------------------------------------------------------------------------------
        I_I2O_OPEN_INFO     : in  std_logic_vector(I2O_OPEN_INFO_BITS -1 downto 0) := (others => '0');
        I_I2O_CLOSE_INFO    : in  std_logic_vector(I2O_CLOSE_INFO_BITS-1 downto 0) := (others => '0');
        I_O2I_OPEN_INFO     : out std_logic_vector(O2I_OPEN_INFO_BITS -1 downto 0);
        I_O2I_OPEN_VALID    : out std_logic;
        I_O2I_CLOSE_INFO    : out std_logic_vector(O2I_CLOSE_INFO_BITS-1 downto 0);
        I_O2I_CLOSE_VALID   : out std_logic;
        I_O2I_STOP          : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Clock and Clock Enable.
    -------------------------------------------------------------------------------
        O_CLK               : in  std_logic;
        O_CLR               : in  std_logic;
        O_CKE               : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Outlet Stream Interface.
    -------------------------------------------------------------------------------
        O_DATA              : out std_logic_vector(O_DATA_BITS    -1 downto 0);
        O_STRB              : out std_logic_vector(O_DATA_BITS/8  -1 downto 0);
        O_LAST              : out std_logic;
        O_VALID             : out std_logic;
        O_READY             : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Status.
    -------------------------------------------------------------------------------
        O_OPEN              : out std_logic;
        O_DONE              : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Open/Close Infomation Interface
    -------------------------------------------------------------------------------
        O_I2O_RESET         : out std_logic;
        O_I2O_STOP          : out std_logic;
        O_I2O_NONE          : out std_logic;
        O_I2O_ERROR         : out std_logic;
        O_I2O_OPEN_INFO     : out std_logic_vector(I2O_OPEN_INFO_BITS -1 downto 0);
        O_I2O_OPEN_VALID    : out std_logic;
        O_I2O_CLOSE_INFO    : out std_logic_vector(I2O_CLOSE_INFO_BITS-1 downto 0);
        O_I2O_CLOSE_VALID   : out std_logic;
        O_O2I_STOP          : in  std_logic := '0';
        O_O2I_OPEN_INFO     : in  std_logic_vector(O2I_OPEN_INFO_BITS -1 downto 0) := (others => '0');
        O_O2I_OPEN_VALID    : in  std_logic;
        O_O2I_CLOSE_INFO    : in  std_logic_vector(O2I_CLOSE_INFO_BITS-1 downto 0) := (others => '0');
        O_O2I_CLOSE_VALID   : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Buffer Read Interface.
    -------------------------------------------------------------------------------
        BUF_REN             : out std_logic;
        BUF_PTR             : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        BUF_DATA            : in  std_logic_vector(BUF_DATA_BITS  -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_STREAM_OUTLET_CONTROLLER                                         --
-----------------------------------------------------------------------------------
component PUMP_STREAM_OUTLET_CONTROLLER
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
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_OPERATION_PROCESSOR                                              --
-----------------------------------------------------------------------------------
component PUMP_OPERATION_PROCESSOR
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
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_REQUEST_CONTROLLER                                               --
-----------------------------------------------------------------------------------
component PUMP_REQUEST_CONTROLLER
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
end component;
-----------------------------------------------------------------------------------
--! @brief PIPE_REQUESTER_INTERFACE                                              --
-----------------------------------------------------------------------------------
component PIPE_REQUESTER_INTERFACE
    generic (
        PUSH_VALID          : --! @brief PUSH VALID :
                              --! レスポンダ側からリクエスタ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PUSH_VALID=1でデータ転送を行う.
                              --! * PUSH_VALID=0でデータ転送を行わない.
                              integer range 0 to 1 :=  1;
        PULL_VALID          : --! @brief PUSH VALID :
                              --! リクエスタ側からレスポンダ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PULL_VALID=1でデータ転送を行う.
                              --! * PULL_VALID=0でデータ転送を行わない.
                              integer range 0 to 1 :=  1;
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
                              integer range 0 to 1 :=  1;
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
        T_I_FIXED_CLOSE     : --! @brief INTAKE VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        USE_M_PUSH_RSV      : --! @brief USE PUSH RESERVE SIGNALS :
                              --! フローカウンタの加算に M_PUSH_RSV_SIZE を使うか 
                              --! M_PUSH_FIN_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        USE_M_PULL_RSV      : --! @brief USE PULL RESERVE SIGNALS :
                              --! フローカウンタの減算に M_PULL_RSV_SIZE を使うか 
                              --! M_PULL_FIN_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        USE_M_PUSH_BUF      : --! @brief USE PUSH BUFFER  SIGNALS :
                              --! プールカウンタの加算に M_PUSH_BUF_SIZE を使うか 
                              --! M_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        USE_M_PULL_BUF      : --! @brief USE PULL BUFFER  SIGNALS :
                              --! プールカウンタの減算に M_PULL_BUF_SIZE を使うか 
                              --! M_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        USE_T2M_PUSH_RSV    : --! @brief USE PUSH RESERVE SIGNALS :
                              --! フローカウンタの加算に T2M_PUSH_RSV_SIZE を使うか 
                              --! T2M_PUSH_FIN_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        USE_T2M_PULL_RSV    : --! @brief USE PULL RESERVE SIGNALS :
                              --! フローカウンタの減算に T2M_PULL_RSV_SIZE を使うか 
                              --! T2M_PULL_FIN_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        M2T_PUSH_FIN_DELAY  : --! @brief Requester to Responder Pull Final Size Delay Cycle :
                              integer :=  0;
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
                              --!   ACK_LAST 信号をアサートする.
                              --! * T_REQ_LAST=0の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_NEXT 信号をアサートする.
                              in  std_logic;
        T_REQ_START         : --! @brief Request Start signal from responder  :
                              --! トランザクション開始を指定する信号.
                              in  std_logic;
        T_REQ_STOP          : --! @brief Request Stop signal from requester :
                              --! トランザクションの中止を指定する信号.
                              in  std_logic := '0';
        T_REQ_DONE          : --! @brief Request Done signal from requester :
                              --! トランザクションの終了を指定する信号.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Response to Responder Signals.
    -------------------------------------------------------------------------------
        T_RES_START         : --! @brief Response to responder :
                              --! トランザクション開始を指定する信号.
                              out std_logic;
        T_RES_DONE          : --! @brief Response to responder :
                              --! トランザクションの終了を指定する信号.
                              --! 場合、この信号がアサートされる.
                              out std_logic;
        T_RES_ERROR         : --! @brief Acknowledge with Error to responder :
                              --! トランザクション中になんらかのエラーが発生した場
                              --! 合、この信号がアサートされる.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- Push from Responder Signals.
    -------------------------------------------------------------------------------
        T2M_PUSH_FIN_VALID  : --! @brief Push Final Valid from responder :
                              --! T2M_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T2M_PUSH_FIN_LAST   : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T2M_PUSH_FIN_ERROR  : --! @brief Push Final Error flags :
                              --! レスポンダ側からのデータ入力時にエラーが発生した
                              --! ことを示すフラグ.
                              --! * 現在この信号は未使用.
                              in  std_logic := '0';
        T2M_PUSH_FIN_SIZE   : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T2M_PUSH_RSV_VALID  : --! @brief Push Reserve Valid from responder :
                              --! T2M_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        T2M_PUSH_RSV_LAST   : --! @brief Push Reserve Last flags :
                              in  std_logic := '0';
        T2M_PUSH_RSV_ERROR  : --! @brief Push Reserve Error flags :
                              in  std_logic := '0';
        T2M_PUSH_RSV_SIZE   : --! @brief Push Reserve Size :
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Pull from Responder Signals.
    -------------------------------------------------------------------------------
        T2M_PULL_FIN_VALID  : --! @brief Pull Final Valid from responder :
                              --! T2M_PULL_FIN_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        T2M_PULL_FIN_LAST   : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic := '0';
        T2M_PULL_FIN_ERROR  : --! @brief Pull Final Error flags :
                              --! レスポンダ側からのデータ出力時にエラーが発生した
                              --! ことを示すフラグ.
                              --! * 現在この信号は未使用.
                              in  std_logic := '0';
        T2M_PULL_FIN_SIZE   : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        T2M_PULL_RSV_VALID  : --! @brief Pull Reserve Valid from responder :
                              --! T2M_PULL_RSV_LAST/SIZE が有効であることを示す.
                              in  std_logic := '0';
        T2M_PULL_RSV_LAST   : --! @brief Pull Reserve Last flags :
                              in  std_logic := '0';
        T2M_PULL_RSV_ERROR  : --! @brief Pull Reserve Error flags :
                              in  std_logic := '0';
        T2M_PULL_RSV_SIZE   : --! @brief Pull Reserve Size :
                              in  std_logic_vector(XFER_COUNT_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Push to Responder Signals.
    -------------------------------------------------------------------------------
        M2T_PUSH_FIN_VALID  : --! @brief Push Final Valid from responder :
                              --! M2T_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              out std_logic;
        M2T_PUSH_FIN_LAST   : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              out std_logic;
        M2T_PUSH_FIN_ERROR  : --! @brief Push Final Error flags :
                              --! レスポンダ側からのデータ入力時にエラーが発生した
                              --! ことを示すフラグ.
                              --! * 現在この信号は未使用.
                              out std_logic;
        M2T_PUSH_FIN_SIZE   : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        M2T_PUSH_RSV_VALID  : --! @brief Push Reserve Valid from responder :
                              --! M2T_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              out std_logic;
        M2T_PUSH_RSV_LAST   : --! @brief Push Reserve Last flags :
                              out std_logic;
        M2T_PUSH_RSV_ERROR  : --! @brief Push Reserve Error flags :
                              out std_logic;
        M2T_PUSH_RSV_SIZE   : --! @brief Push Reserve Size :
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull to Responder Signals.
    -------------------------------------------------------------------------------
        M2T_PULL_FIN_VALID  : --! @brief Pull Final Valid from responder :
                              --! M2T_PULL_FIN_LAST/SIZE が有効であることを示す.
                              out std_logic;
        M2T_PULL_FIN_LAST   : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              out std_logic;
        M2T_PULL_FIN_ERROR  : --! @brief Pull Final Error flags :
                              --! レスポンダ側からのデータ出力時にエラーが発生した
                              --! ことを示すフラグ.
                              --! * 現在この信号は未使用.
                              out std_logic;
        M2T_PULL_FIN_SIZE   : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        M2T_PULL_RSV_VALID  : --! @brief Pull Reserve Valid from responder :
                              --! M2T_PULL_RSV_LAST/SIZE が有効であることを示す.
                              out std_logic;
        M2T_PULL_RSV_LAST   : --! @brief Pull Reserve Last flags :
                              out std_logic;
        M2T_PULL_RSV_ERROR  : --! @brief Pull Reserve Error flags :
                              out std_logic;
        M2T_PULL_RSV_SIZE   : --! @brief Pull Reserve Size :
                              out std_logic_vector(XFER_COUNT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- リクエスト側クロック.
    -------------------------------------------------------------------------------
        M_CLK               : in  std_logic;
        M_CLR               : in  std_logic;
        M_CKE               : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- リクエスタ側への要求信号出力.
    -------------------------------------------------------------------------------
        M_REQ_ADDR          : out std_logic_vector(ADDR_BITS-1 downto 0);
        M_REQ_SIZE          : out std_logic_vector(SIZE_BITS-1 downto 0);
        M_REQ_BUF_PTR       : out std_logic_vector(BUF_DEPTH-1 downto 0);
        M_REQ_MODE          : out std_logic_vector(MODE_BITS-1 downto 0);
        M_REQ_DIR           : out std_logic;
        M_REQ_FIRST         : out std_logic;
        M_REQ_LAST          : out std_logic;
        M_REQ_VALID         : out std_logic;
        M_REQ_READY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側からの応答信号入力.
    -------------------------------------------------------------------------------
        M_ACK_VALID         : in  std_logic;
        M_ACK_NEXT          : in  std_logic;
        M_ACK_LAST          : in  std_logic;
        M_ACK_ERROR         : in  std_logic;
        M_ACK_STOP          : in  std_logic;
        M_ACK_NONE          : in  std_logic;
        M_ACK_SIZE          : in  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- リクエスタ側からのステータス信号入力.
    -------------------------------------------------------------------------------
        M_XFER_BUSY         : in  std_logic;
        M_XFER_ERROR        : in  std_logic;
        M_XFER_DONE         : in  std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側からデータ入力のフロー制御信号入出力.
    -------------------------------------------------------------------------------
        M_I_FLOW_PAUSE      : out std_logic;
        M_I_FLOW_STOP       : out std_logic;
        M_I_FLOW_LAST       : out std_logic;
        M_I_FLOW_SIZE       : out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        M_I_FLOW_READY      : out std_logic;
        M_I_FLOW_LEVEL      : in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_I_BUF_SIZE        : in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_PUSH_FIN_VALID    : in  std_logic := '0';
        M_PUSH_FIN_LAST     : in  std_logic := '0';
        M_PUSH_FIN_ERROR    : in  std_logic := '0';
        M_PUSH_FIN_SIZE     : in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PUSH_RSV_VALID    : in  std_logic := '0';
        M_PUSH_RSV_LAST     : in  std_logic := '0';
        M_PUSH_RSV_ERROR    : in  std_logic := '0';
        M_PUSH_RSV_SIZE     : in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PUSH_BUF_LEVEL    : in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_PUSH_BUF_RESET    : in  std_logic := '0';
        M_PUSH_BUF_VALID    : in  std_logic := '0';
        M_PUSH_BUF_LAST     : in  std_logic := '0';
        M_PUSH_BUF_ERROR    : in  std_logic := '0';
        M_PUSH_BUF_SIZE     : in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PUSH_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側へのデータ出力のフロー制御信号入出力
    -------------------------------------------------------------------------------
        M_O_FLOW_PAUSE      : out std_logic;
        M_O_FLOW_STOP       : out std_logic;
        M_O_FLOW_LAST       : out std_logic;
        M_O_FLOW_SIZE       : out std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        M_O_FLOW_READY      : out std_logic;
        M_O_FLOW_LEVEL      : in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_PULL_FIN_VALID    : in  std_logic := '0';
        M_PULL_FIN_LAST     : in  std_logic := '0';
        M_PULL_FIN_ERROR    : in  std_logic := '0';
        M_PULL_FIN_SIZE     : in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PULL_RSV_VALID    : in  std_logic := '0';
        M_PULL_RSV_LAST     : in  std_logic := '0';
        M_PULL_RSV_ERROR    : in  std_logic := '0';
        M_PULL_RSV_SIZE     : in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PULL_BUF_LEVEL    : in  std_logic_vector(XFER_COUNT_BITS-1 downto 0);
        M_PULL_BUF_RESET    : in  std_logic := '0';
        M_PULL_BUF_VALID    : in  std_logic := '0';
        M_PULL_BUF_LAST     : in  std_logic := '0';
        M_PULL_BUF_ERROR    : in  std_logic := '0';
        M_PULL_BUF_SIZE     : in  std_logic_vector(XFER_SIZE_BITS -1 downto 0) := (others => '0');
        M_PULL_BUF_READY    : out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PIPE_RESPONDER_INTERFACE                                              --
-----------------------------------------------------------------------------------
component PIPE_RESPONDER_INTERFACE
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
end component;
-----------------------------------------------------------------------------------
--! @brief PIPE_CONTROLLER                                                       --
-----------------------------------------------------------------------------------
component PIPE_CONTROLLER
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
end component;
end PUMP_COMPONENTS;
