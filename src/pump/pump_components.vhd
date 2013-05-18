-----------------------------------------------------------------------------------
--!     @file    pump_components.vhd                                             --
--!     @brief   PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION                    --
--!     @version 1.5.0                                                           --
--!     @date    2013/05/18                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2013 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
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
        RESET_L         : in  std_logic;
        RESET_D         : in  std_logic;
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
        START_L         : in  std_logic;
        START_D         : in  std_logic;
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
        STOP_L          : in  std_logic;
        STOP_D          : in  std_logic;
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
        PAUSE_L         : in  std_logic;
        PAUSE_D         : in  std_logic;
        PAUSE_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- FIRST Bit        : 最初の転送であるか否かを指示する.
    -------------------------------------------------------------------------------
    -- * FIRST_L='1' and FIRST_D='1' で最初の転送であることを指示する.
    -- * FIRST_L='1' and FIRST_D='0' で最初の転送でないことを指示する.
    -- * FIRST_Q は現在の状態を示す.
    -------------------------------------------------------------------------------
        FIRST_L         : in  std_logic;
        FIRST_D         : in  std_logic;
        FIRST_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- LAST Bit         : 最後の転送であるか否かを指示する.
    -------------------------------------------------------------------------------
    -- * LAST_L='1' and LAST_D='1' で最後の転送であることを指示する.
    -- * LAST_L='1' and LAST_D='0' で最後の転送でないことを指示する.
    -- * LAST_Q は現在の状態を示す.
    -------------------------------------------------------------------------------
        LAST_L          : in  std_logic;
        LAST_D          : in  std_logic;
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
        DONE_EN_L       : in  std_logic;
        DONE_EN_D       : in  std_logic;
        DONE_EN_Q       : out std_logic;
    -------------------------------------------------------------------------------
    -- DONE STatus Bit  : DONE_EN_Q='1'の時、転送終了時にセットされる.
    -------------------------------------------------------------------------------
    -- * DONE_ST_L='1' and DONE_ST_D='0' でこのビットをクリアする.
    -- * DONE_ST_L='1' and DONE_ST_D='1' の場合、このビットに変化は無い.
    -- * DONE_ST_Q='1' は、DONE_EN_Q='1' の時、転送が終了したことを示す.
    -------------------------------------------------------------------------------
        DONE_ST_L       : in  std_logic;
        DONE_ST_D       : in  std_logic;
        DONE_ST_Q       : out std_logic;
    -------------------------------------------------------------------------------
    -- ERRor STatus Bit : 転送中にエラーが発生した時にセットされる.
    -------------------------------------------------------------------------------
    -- * ERR_ST_L='1' and ERR_ST_D='0' でこのビットをクリアする.
    -- * ERR_ST_L='1' and ERR_ST_D='1' の場合、このビットに変化は無い.
    -- * ERR_ST_Q='1' は転送中にエラーが発生したことを示す.
    -------------------------------------------------------------------------------
        ERR_ST_L        : in  std_logic;
        ERR_ST_D        : in  std_logic;
        ERR_ST_Q        : out std_logic;
    -------------------------------------------------------------------------------
    -- MODE Register    : その他のモードレジスタ.
    -------------------------------------------------------------------------------
    -- * MODE_L(x)='1' and MODE_D(x)='1' で MODE_Q(x) に'1'をセット.
    -- * MODE_L(x)='1' and MODE_D(x)='0' で MODE_Q(x) に'0'をセット.
    -------------------------------------------------------------------------------
        MODE_L          : in  std_logic_vector(MODE_BITS-1 downto 0);
        MODE_D          : in  std_logic_vector(MODE_BITS-1 downto 0);
        MODE_Q          : out std_logic_vector(MODE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- STATus Register  : その他のステータスレジスタ.
    -------------------------------------------------------------------------------
    -- * STAT_L(x)='1' and STAT_D(x)='0' で STAT_Q(x)をクリア.
    -- * STAT_L(x)='1' and STAT_D(x)='1' の場合、STAT_Q(x) に変化は無い.
    -- * STAT_I(x)='1' で STAT_Q(x) に'1'をセット.
    -- * STAT_I(x)='0' の場合、STAT_Q(x) に変化は無い.
    -------------------------------------------------------------------------------
        STAT_L          : in  std_logic_vector(STAT_BITS-1 downto 0);
        STAT_D          : in  std_logic_vector(STAT_BITS-1 downto 0);
        STAT_Q          : out std_logic_vector(STAT_BITS-1 downto 0);
        STAT_I          : in  std_logic_vector(STAT_BITS-1 downto 0);
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
    -- Status.
    -------------------------------------------------------------------------------
        VALVE_OPEN      : --! @brief Valve Open Flag.
                          --! 最初の(REQ_FIRST='1'付き)トランザクション開始時にアサ
                          --! ートされ、最後の(REQ_LAST='1'付き)トランザクション終
                          --! 了時または、トランザクション中にエラーが発生した時に
                          --! ネゲートされる.
                          out std_logic;
        XFER_RUNNING    : --! @brief Transaction Running Flag.
                          --! トランザクション中であることを示すフラグ.
                          out std_logic;
        XFER_DONE       : --! @brief Transaction Done Flag.
                          --! トランザクションが終了したことを示すフラグ.
                          --! トランザクション終了時に１クロックだけアサートされる.
                          out std_logic;
        XFER_ERROR      : --! @brief Transaction Done Flag.
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
        I_CLK_RATE  : --! @brief INPUT CLOCK RATE :
                      --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側のクロッ
                      --! ク(O_CLK)との関係を指定する.
                      --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                      integer :=  1;
        O_CLK_RATE  : --! @brief OUTPUT CLOCK RATE :
                      --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側のクロッ
                      --! ク(O_CLK)との関係を指定する.
                      --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                      integer :=  1;
        DELAY_CYCLE : --! @brief DELAY CYCLE :
                      --! 入力側から出力側への転送する際の遅延サイクルを指定する.
                      integer :=  0;
        SIZE_BITS   : --! @brief I_SIZE/O_SIZEのビット数を指定する.
                      integer :=  8
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号
    -------------------------------------------------------------------------------
        RST         : --! @brief RESET :
                      --! 非同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側の各種信号
    -------------------------------------------------------------------------------
        I_CLK       : --! @brief INPUT CLOCK :
                      --! 入力側のクロック信号.
                      in  std_logic;
        I_CLR       : --! @brief INPUT CLEAR :
                      --! 入力側の同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
        I_CKE       : --! @brief INPUT CLOCK ENABLE :
                      --! 入力側のクロック(I_CLK)の立上りが有効であることを示す信号.
                      --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の位相
                      --!   関係を示す時に使用する.
                      --! * I_CLKの立上り時とOCLKの立上り時が同じ時にアサートするよ
                      --!   うに入力されなければならない.
                      --! * この信号は I_CLK_RATE > 1 かつ O_CLK_RATE = 1の時のみ有
                      --!   効. それ以外は未使用.
                      in  std_logic;
        I_OPEN      : --! @brief INPUT OPEN FLAG :
                      --! 入力側のバルブが開いていることを示すフラグ.
                      in  std_logic;
        I_VAL       : --! @brief INPUT SIZE/LAST VALID :
                      --! I_LAST、I_SIZEが有効であることを示す信号.
                      --! この信号のアサートによりI_LAST、I_SIZEの内容が出力側に伝達
                      --! されて、O_LAST、O_SIZEから出力される.
                      in  std_logic;
        I_LAST      : --! @brief INPUT LAST FLAG :
                      --! 最後の転送であることを示すフラグを入力.
                      in  std_logic;
        I_SIZE      : --! @brief INPUT SIZE :
                      --! 転送バイト数を入力.
                      in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側の各種信号
    -------------------------------------------------------------------------------
        O_CLK       : --! @brief OUTPUT CLK :
                      --! 出力側のクロック信号.
                      in  std_logic;
        O_CLR       : --! @brief OUTPUT CLEAR :
                      --! 出力側の同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
        O_CKE       : --! @brief OUTPUT CLOCK ENABLE :
                      --! 出力側のクロック(O_CLK)の立上りが有効であることを示す信号.
                      --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の位相
                      --!   関係を示す時に使用する.
                      --! * I_CLKの立上り時とO_CLKの立上り時が同じ時にアサートする
                      --!   ように入力されなければならない.
                      --! * この信号は O_CLK_RATE > 1 かつ I_CLK_RATE = 1の時のみ有
                      --!   効. それ以外は未使用.
                      in  std_logic;
        O_OPEN      : --! @brief OUTPUT OPEN FLAG :
                      --! 入力側のバルブが開いていることを示すフラグ.
                      out std_logic;
        O_VAL       : --! @brief OUTPUT SIZE/LAST VALID :
                      --! O_LAST、O_SIZEが有効であることを示す信号.
                      out std_logic;
        O_LAST      : --! @brief OUTPUT LAST FLAG :
                      --! 最後の転送であることを示すフラグを出力.
                      out std_logic;
        O_SIZE      : --! @brief INPUT SIZE :
                      --! 転送バイト数を出力.
                      out std_logic_vector(SIZE_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PUMP_CONTROLLER                                                       --
-----------------------------------------------------------------------------------
component PUMP_CONTROLLER
    generic (
        I_CLK_RATE      : --! @brief INPUT CLOCK RATE :
                          --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        I_REQ_ADDR_VALID: --! @brief INTAKE REQUEST ADDRESS VALID :
                          --! I_REQ_ADDR信号を有効にするか否かを指示する.
                          --! * I_REQ_ADDR_VAL=0で無効.
                          --! * I_REQ_ADDR_VAL=1で有効.
                          integer range 0 to 1 :=  1;
        I_REQ_ADDR_BITS : --! @brief INTAKE REQUEST ADDRESS BITS :
                          --! I_REQ_ADDR信号のビット数を指定する.
                          --! * I_REQ_ADDR_VALID=0の場合でもビット数は１以上を指定
                          --!   しなければならない.
                          integer := 32;
        I_REG_ADDR_BITS : --! @brief INTAKE ADDRESS REGISTER BITS :
                          --! I_REG_ADDR信号のビット数を指定する.
                          --! * I_REQ_ADDR_VALID=0の場合でもビット数は１以上を指定
                          --!   しなければならない.
                          integer := 32;
        I_REQ_SIZE_VALID: --! @brief INTAKE REQUEST SIZE VALID :
                          --! I_REQ_SIZE信号を有効にするか否かを指示する.
                          --! * I_REQ_SIZE_VAL=0で無効.
                          --! * I_REQ_SIZE_VAL=1で有効.
                          integer range 0 to 1 :=  1;
        I_REQ_SIZE_BITS : --! @brief INTAKE REQUEST SIZE BITS :
                          --! I_REQ_SIZE信号のビット数を指定する.
                          --! * I_REQ_SIZE_VALID=0の場合でもビット数は１以上を指定
                          --!   しなければならない.
                          integer := 32;
        I_REG_SIZE_BITS : --! @brief INTAKE SIZE REGISTER BITS :
                          --! I_REG_SIZE信号のビット数を指定する.
                          --! * I_REQ_SIZE_VALID=0の場合でもビット数は１以上を指定
                          --!   しなければならない.
                          integer := 32;
        I_REG_MODE_BITS : --! @brief INTAKE MODE REGISTER BITS :
                          --! I_MODE_L/I_MODE_D/I_MODE_Qのビット数を指定する.
                          integer := 32;
        I_REG_STAT_BITS : --! @brief INTAKE STATUS REGISTER BITS :
                          --! I_STAT_L/I_STAT_D/I_STAT_Qのビット数を指定する.
                          integer := 32;
        O_CLK_RATE      : --! @brief OUTPUT CLOCK RATE :
                          --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        O_REQ_ADDR_VALID: --! @brief OUTLET REQUEST ADDRESS VALID :
                          --! O_REQ_ADDR信号を有効にするか否かを指示する.
                          --! * O_REQ_ADDR_VAL=0で無効.
                          --! * O_REQ_ADDR_VAL=1で有効.
                          integer range 0 to 1 :=  1;
        O_REQ_ADDR_BITS : --! @brief OUTLET REQUEST ADDRESS BITS :
                          --! O_REQ_ADDR信号のビット数を指定する.
                          --! * O_REQ_ADDR_VALID=0の場合でもビット数は１以上を指定
                          --!   しなければならない.
                          integer := 32;
        O_REG_ADDR_BITS : --! @brief OUTLET ADDRESS REGISTER BITS :
                          --! O_REG_ADDR信号のビット数を指定する.
                          --! * O_REQ_ADDR_VALID=0の場合でもビット数は１以上を指定
                          --!   しなければならない.
                          integer := 32;
        O_REQ_SIZE_VALID: --! @brief OUTLET REQUEST SIZE VALID :
                          --! O_REQ_SIZE信号を有効にするか否かを指示する.
                          --! * O_REQ_SIZE_VAL=0で無効.
                          --! * O_REQ_SIZE_VAL=1で有効.
                          integer range 0 to 1 :=  1;
        O_REQ_SIZE_BITS : --! @brief OUTLET REQUEST SIZE BITS :
                          --! O_REQ_SIZE信号のビット数を指定する.
                          --! * O_REQ_SIZE_VALID=0の場合でもビット数は１以上を指定
                          --!   しなければならない.
                          integer := 32;
        O_REG_SIZE_BITS : --! @brief OUTLET SIZE REGISTER BITS :
                          --! O_REG_SIZE信号のビット数を指定する.
                          --! * O_REQ_SIZE_VALID=0の場合でもビット数は１以上を指定
                          --!   しなければならない.
                          integer := 32;
        O_REG_MODE_BITS : --! @brief OUTLET MODE REGISTER BITS :
                          --! O_MODE_L/O_MODE_D/O_MODE_Qのビット数を指定する.
                          integer := 32;
        O_REG_STAT_BITS : --! @brief OUTLET STATUS REGISTER BITS :
                          --! O_STAT_L/O_STAT_D/O_STAT_Qのビット数を指定する.
                          integer := 32;
        BUF_DEPTH       : --! @brief BUFFER DEPTH :
                          --! バッファの容量(バイト数)を２のべき乗値で指定する.
                          integer := 12;
        I2O_DELAY_CYCLE : --! @brief DELAY CYCLE :
                          --! 入力側から出力側への転送する際の遅延サイクルを指定する.
                          integer :=  0
    );
    port (
    -------------------------------------------------------------------------------
    --Reset Signals.
    -------------------------------------------------------------------------------
        RST             : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Clock and Clock Enable.
    -------------------------------------------------------------------------------
        I_CLK           : in  std_logic;
        I_CLR           : in  std_logic;
        I_CKE           : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Control Register Interface.
    -------------------------------------------------------------------------------
        I_ADDR_L        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_ADDR_D        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_ADDR_Q        : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_SIZE_L        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_SIZE_D        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_SIZE_Q        : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_MODE_L        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_MODE_D        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_MODE_Q        : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_STAT_L        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_D        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_Q        : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_I        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_RESET_L       : in  std_logic;
        I_RESET_D       : in  std_logic;
        I_RESET_Q       : out std_logic;
        I_START_L       : in  std_logic;
        I_START_D       : in  std_logic;
        I_START_Q       : out std_logic;
        I_STOP_L        : in  std_logic;
        I_STOP_D        : in  std_logic;
        I_STOP_Q        : out std_logic;
        I_PAUSE_L       : in  std_logic;
        I_PAUSE_D       : in  std_logic;
        I_PAUSE_Q       : out std_logic;
        I_FIRST_L       : in  std_logic;
        I_FIRST_D       : in  std_logic;
        I_FIRST_Q       : out std_logic;
        I_LAST_L        : in  std_logic;
        I_LAST_D        : in  std_logic;
        I_LAST_Q        : out std_logic;
        I_DONE_EN_L     : in  std_logic;
        I_DONE_EN_D     : in  std_logic;
        I_DONE_EN_Q     : out std_logic;
        I_DONE_ST_L     : in  std_logic;
        I_DONE_ST_D     : in  std_logic;
        I_DONE_ST_Q     : out std_logic;
        I_ERR_ST_L      : in  std_logic;
        I_ERR_ST_D      : in  std_logic;
        I_ERR_ST_Q      : out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Configuration Signals.
    -------------------------------------------------------------------------------
        I_ADDR_FIX      : in  std_logic;
        I_THRESHOLD_SIZE: in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Clock and Clock Enable.
    -------------------------------------------------------------------------------
        O_CLK           : in  std_logic;
        O_CLR           : in  std_logic;
        O_CKE           : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Control Register Interface.
    -------------------------------------------------------------------------------
        O_ADDR_L        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_ADDR_D        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_ADDR_Q        : out std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_SIZE_L        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_SIZE_D        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_SIZE_Q        : out std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_MODE_L        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_MODE_D        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_MODE_Q        : out std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_STAT_L        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_D        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_Q        : out std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_I        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_RESET_L       : in  std_logic;
        O_RESET_D       : in  std_logic;
        O_RESET_Q       : out std_logic;
        O_START_L       : in  std_logic;
        O_START_D       : in  std_logic;
        O_START_Q       : out std_logic;
        O_STOP_L        : in  std_logic;
        O_STOP_D        : in  std_logic;
        O_STOP_Q        : out std_logic;
        O_PAUSE_L       : in  std_logic;
        O_PAUSE_D       : in  std_logic;
        O_PAUSE_Q       : out std_logic;
        O_FIRST_L       : in  std_logic;
        O_FIRST_D       : in  std_logic;
        O_FIRST_Q       : out std_logic;
        O_LAST_L        : in  std_logic;
        O_LAST_D        : in  std_logic;
        O_LAST_Q        : out std_logic;
        O_DONE_EN_L     : in  std_logic;
        O_DONE_EN_D     : in  std_logic;
        O_DONE_EN_Q     : out std_logic;
        O_DONE_ST_L     : in  std_logic;
        O_DONE_ST_D     : in  std_logic;
        O_DONE_ST_Q     : out std_logic;
        O_ERR_ST_L      : in  std_logic;
        O_ERR_ST_D      : in  std_logic;
        O_ERR_ST_Q      : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Configuration Signals.
    -------------------------------------------------------------------------------
        O_ADDR_FIX      : in  std_logic;
        O_THRESHOLD_SIZE: in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        I_REQ_VALID     : out std_logic;
        I_REQ_ADDR      : out std_logic_vector(I_REQ_ADDR_BITS-1 downto 0);
        I_REQ_SIZE      : out std_logic_vector(I_REQ_SIZE_BITS-1 downto 0);
        I_REQ_BUF_PTR   : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        I_REQ_FIRST     : out std_logic;
        I_REQ_LAST      : out std_logic;
        I_REQ_READY     : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        I_ACK_VALID     : in  std_logic;
        I_ACK_SIZE      : in  std_logic_vector(BUF_DEPTH         downto 0);
        I_ACK_ERROR     : in  std_logic;
        I_ACK_NEXT      : in  std_logic;
        I_ACK_LAST      : in  std_logic;
        I_ACK_STOP      : in  std_logic;
        I_ACK_NONE      : in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        I_FLOW_PAUSE    : out std_logic;
        I_FLOW_STOP     : out std_logic;
        I_FLOW_LAST     : out std_logic;
        I_FLOW_SIZE     : out std_logic_vector(BUF_DEPTH         downto 0);
        I_PUSH_VALID    : in  std_logic;
        I_PUSH_LAST     : in  std_logic;
        I_PUSH_ERROR    : in  std_logic;
        I_PUSH_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Intake Status.
    -------------------------------------------------------------------------------
        I_OPEN          : out std_logic;
        I_RUNNING       : out std_logic;
        I_DONE          : out std_logic;
        I_ERROR         : out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        O_REQ_VALID     : out std_logic;
        O_REQ_ADDR      : out std_logic_vector(O_REQ_ADDR_BITS-1 downto 0);
        O_REQ_SIZE      : out std_logic_vector(O_REQ_SIZE_BITS-1 downto 0);
        O_REQ_BUF_PTR   : out std_logic_vector(BUF_DEPTH      -1 downto 0);
        O_REQ_FIRST     : out std_logic;
        O_REQ_LAST      : out std_logic;
        O_REQ_READY     : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Transaction Command Response Signals.
    -------------------------------------------------------------------------------
        O_ACK_VALID     : in  std_logic;
        O_ACK_SIZE      : in  std_logic_vector(BUF_DEPTH         downto 0);
        O_ACK_ERROR     : in  std_logic;
        O_ACK_NEXT      : in  std_logic;
        O_ACK_LAST      : in  std_logic;
        O_ACK_STOP      : in  std_logic;
        O_ACK_NONE      : in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        O_FLOW_PAUSE    : out std_logic;
        O_FLOW_STOP     : out std_logic;
        O_FLOW_LAST     : out std_logic;
        O_FLOW_SIZE     : out std_logic_vector(BUF_DEPTH         downto 0);
        O_PULL_VALID    : in  std_logic;
        O_PULL_LAST     : in  std_logic;
        O_PULL_ERROR    : in  std_logic;
        O_PULL_SIZE     : in  std_logic_vector(BUF_DEPTH         downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Status.
    -------------------------------------------------------------------------------
        O_OPEN          : out std_logic;
        O_RUNNING       : out std_logic;
        O_DONE          : out std_logic;
        O_ERROR         : out std_logic
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
        OP_XFER_CODE    : --! @brief Transfer Operation Type :
                          --! 転送オペレーションタイプのコードを指定する.
                          integer := 12;
        OP_LINK_CODE    : --! @brief Transfer Operation Type :
                          --! リンクオペレーションタイプのコードを指定する.
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
        T_ERROR         : out std_logic_vector(2 downto 0);
        T_FETCH         : out std_logic;
        T_END           : out std_logic;
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
end PUMP_COMPONENTS;
