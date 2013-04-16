-----------------------------------------------------------------------------------
--!     @file    pipe_components.vhd                                             --
--!     @brief   PIPEWORK PIPE COMPONENTS LIBRARY DESCRIPTION                    --
--!     @version 0.0.1                                                           --
--!     @date    2013/03/31                                                      --
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
--! @brief PIPEWORK PIPE COMPONENTS LIBRARY DESCRIPTION                          --
-----------------------------------------------------------------------------------
package PIPE_COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief PIPE_FLOW_SYNCRONIZER                                                 --
-----------------------------------------------------------------------------------
component PIPE_FLOW_SYNCRONIZER
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
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! 各種サイズ信号のビット数を指定する.
                          integer :=  8;
        PUSH_FIN_VALID  : --! @brief PUSH FINAL SIZE VALID :
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PUSH_FIN_VALID = 1 : 有効. 
                          --! * PUSH_FIN_VALID = 0 : 無効. 回路は省略される.
                          integer :=  1;
        PUSH_FIN_DELAY  : --! @brief PUSH FINAL SIZE DELAY CYCLE :
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST を遅延するサ
                          --! イクル数を指定する.
                          integer :=  0;
        PUSH_RSV_VALID  : --! @brief PUSH RESERVE SIZE VALID :
                          --! PUSH_RSV_VAL/PUSH_RSV_SIZE/PUSH_RSV_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PUSH_RSV_VALID = 1 : 有効. 
                          --! * PUSH_RSV_VALID = 0 : 無効. 回路は省略される.
                          integer :=  1;
        PULL_FIN_VALID  : --! @brief PULL FINAL SIZE VALID :
                          --! PULL_FIN_VAL/PULL_FIN_SIZE/PULL_FIN_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PULL_FIN_VALID = 1 : 有効. 
                          --! * PULL_FIN_VALID = 0 : 無効. 回路は省略される.
                          integer :=  1;
        PULL_RSV_VALID  : --! @brief PULL RESERVE SIZE VALID :
                          --! PULL_RSV_VAL/PULL_RSV_SIZE/PULL_RSV_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PULL_RSV_VALID = 1 : 有効. 
                          --! * PULL_RSV_VALID = 0 : 無効. 回路は省略される.
                          integer :=  1
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
                          in  std_logic;
        I_CKE           : --! @brief INPUT CLOCK ENABLE :
                          --! 入力側のクロック(I_CLK)の立上りが有効であることを示す信号.
                          --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の
                          --!   位相関係を示す時に使用する.
                          --! * I_CLKの立上り時とOCLKの立上り時が同じ時にアサートす
                          --!   るように入力されなければならない.
                          --! * この信号は I_CLK_RATE > 1 かつ O_CLK_RATE = 1の時の
                          --!   み有効. それ以外は未使用.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側からのOPEN(トランザクションの開始)を指示する信号.
    -------------------------------------------------------------------------------
        I_OPEN_VAL      : --! @brief INPUT OPEN VALID :
                          --! 入力側からのOPEN(トランザクションの開始)を指示する信号.
                          --! * I_OPEN_INFO が有効であることを示す.
                          in  std_logic;
        I_OPEN_INFO     : --! @brief INPUT OPEN INFOMATION DATA :
                          --! OPEN(トランザクションの開始)時に出力側に伝達する各種
                          --! 情報入力.
                          --! * I_OPEN_VALがアサートされている時のみ有効.
                          in  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- 入力側からのCLOSE(トランザクションの終了)を指示する信号.
    -------------------------------------------------------------------------------
        I_CLOSE_VAL     : --! @brief INPUT CLOSE VALID :
                          --! 入力側からのCLOSE(トランザクションの終了)を指示する信号.
                          --! * I_CLOSE_INFO が有効であることを示す.
                          in  std_logic;
        I_CLOSE_INFO    : --! @brief INPUT CLOSE INFOMATION DATA :
                          --! CLOSE(トランザクションの終了)時に出力側に伝達する各種
                          --! 情報入力.
                          --! * I_CLOSE_VALがアサートされている時のみ有効.
                          in  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 入力側からの、PUSH_FIN(入力側から出力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PUSH_FIN_VAL  : --! @brief INPUT PUSH FINAL VALID :
                          --! * I_PUSH_FIN_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PUSH_FIN_LAST : --! @brief INPUT PUSH FINAL LAST FLAG :
                          --! 入力側から出力側へ最後の"確定した"転送であることを示す.
                          in  std_logic := '0';
        I_PUSH_FIN_SIZE : --! @brief INPUT PUSH FINAL SIZE :
                          --! 入力側から出力側への転送が"確定した"バイト数を入力.
                          in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からの、PUSH_RSV(入力側から出力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PUSH_RSV_VAL  : --! @brief INPUT PUSH RESERVE VALID :
                          --! * I_PUSH_RSV_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PUSH_RSV_LAST : --! @brief INPUT PUSH RESERVE LAST FLAG :
                          --! 入力側から出力側へ最後の"予定された"転送であることを示す.
                          in  std_logic := '0';
        I_PUSH_RSV_SIZE : --! @brief INPUT PUSH RESERVE SIZE :
                          --! 入力側から出力側への転送が"予定された"バイト数を入力.
                          in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からの、PULL_FIN(出力側から入力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PULL_FIN_VAL  : --! @brief INPUT PULL FINAL VALID :
                          --! * I_PULL_FIN_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PULL_FIN_LAST : --! @brief INPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"確定した"転送であることを示す.
                          in  std_logic := '0';
        I_PULL_FIN_SIZE : --! @brief INPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送が"確定した"バイト数を入力.
                          in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からの、PULL_RSV(出力側から入力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PULL_RSV_VAL  : --! @brief INPUT PULL RESERVE VALID :
                          --! * I_PULL_RSV_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PULL_RSV_LAST : --! @brief INPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"予定された"転送であることを示す.
                          in  std_logic := '0';
        I_PULL_RSV_SIZE : --! @brief INPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送"が予定された"バイト数を入力.
                          in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
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
                          in  std_logic;
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
    -- 出力側への、PUSH_FIN(入力側から出力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PUSH_FIN_VAL  : --! @brief OUTPUT PUSH FINAL VALID :
                          --! * O_PUSH_FIN_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PUSH_FIN_LAST : --! @brief OUTPUT PUSH FINAL LAST FLAG :
                          --! 入力側から出力側へ最後の"確定した"転送であることを示す.
                          out std_logic;
        O_PUSH_FIN_SIZE : --! @brief OUTPUT PUSH FINAL SIZE :
                          --! 入力側から出力側への転送が"確定した"バイト数を出力.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側への、PUSH_RSV(入力側から出力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PUSH_RSV_VAL  : --! @brief OUTPUT PUSH RESERVE VALID :
                          --! * O_PUSH_RSV_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PUSH_RSV_LAST : --! @brief OUTPUT PUSH RESERVE LAST FLAG :
                          --! 入力側から出力側へ最後の"予定された"転送であることを示す.
                          out std_logic;
        O_PUSH_RSV_SIZE : --! @brief OUTPUT PUSH RESERVE SIZE :
                          --! 入力側から出力側への転送が"予定された"バイト数を出力.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側への、PULL_FIN(出力側から入力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PULL_FIN_VAL  : --! @brief OUTPUT PULL FINAL VALID :
                          --! * O_PULL_FIN_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PULL_FIN_LAST : --! @brief OUTPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"確定した"転送であることを示す.
                          out std_logic;
        O_PULL_FIN_SIZE : --! @brief OUTPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送が"確定した"バイト数を出力.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側への、PULL_RSV(出力側から入力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PULL_RSV_VAL  : --! @brief OUTPUT PULL RESERVE VALID :
                          --! * O_PULL_RSV_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PULL_RSV_LAST : --! @brief OUTPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"予定された"転送であることを示す.
                          out std_logic;
        O_PULL_RSV_SIZE : --! @brief OUTPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送"が予定された"バイト数を出力.
                          out std_logic_vector(SIZE_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PIPE_REQUESTER_INTERFACE                                              --
-----------------------------------------------------------------------------------
component PIPE_REQUESTER_INTERFACE
    generic (
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
        COUNT_BITS          : --! @brief Flow Counter Bits :
                              --! フロー制御用カウンタのビット数を指定する.
                              integer := 32;
        BUF_DEPTH           : --! @brief Buffer Depth :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        T_XFER_MAX_SIZE     : --! @brief Transfer Maximum Size from responder :
                              --! レスポンダ側が想定している一回の転送時の最大
                              --! バイト数を２のべき乗で指定する.
                              --! リクエスタ側で想定している一回の転送時の最大
                              --! バイト数ではない事に注意.
                              integer :=  4;
        O_VALVE_FIXED       : --! @brief Outlet Valve Fixed Mode :
                              --! 出力用バルブのモードを指定する.
                              --! * O_VALVE_FIXED=0 : フローカウンタによるフロー制
                              --!   御を行う.
                              --! * O_VALVE_FIXED=1 : 常にバルブが閉じた状態にする.
                              --! * O_VALVE_FIXED=2 : 常にバルブが開いた状態にする.
                              integer :=  0;
        O_VALVE_PRECEDE     : --! @brief Outlet Valve Precede Mode :
                              --! 出力用バルブを先行(Precede)モードでフローを制御
                              --! するかどうかを指定する.
                              --! * O_VALVE_PRECEDE=0 : 非先行モード. フローカウン
                              --!   タの加算にT_PUSH_FIN_SIZE(入力が確定(FINAL)し
                              --!   たバイト数)を使う.
                              --! * O_VALVE_PRECEDE=1 : 先行モード. フローカウンタ
                              --!   の加算に T_PUSH_RSV_SIZE(入力する予定(RESERVE)
                              --!   のバイト数)を使う.
                              integer :=  0;
        I_VALVE_FIXED       : --! @brief Intake Valve Fixed Mode :
                              --! 入力用バルブのモードを指定する.
                              --! * I_VALVE_FIXED=0 : フローカウンタによるフロー制
                              --!   御を行う.
                              --! * I_VALVE_FIXED=1 : 常にバルブが閉じた状態にする.
                              --! * I_VALVE_FIXED=2 : 常にバルブが開いた状態にする.
                              integer :=  0;
        I_VALVE_PRECEDE     : --! @brief Intake Valve Precede Mode :
                              --! 入力用バルブを先行(Precede)モードでフローを制御
                              --! するかどうかを指定する.
                              --! * I_VALVE_PRECEDE=0 : 非先行モード. 
                              --!   フローカウンタの減算にT_PULL_FIN_SIZE(出力が確
                              --!   定(FINAL)したバイト数)を使う.
                              --! * I_VALVE_PRECEDE=1 : 先行モード. 
                              --!   フローカウンタの減算に T_PULL_RSV_SIZE(出力する
                              --!   予定(RESERVE)のバイト数)を使う.
                              integer :=  0
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
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
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
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        O_FLOW_READY        : --! @brief Outlet Valve Flow Ready :
                              --! プールバッファに O_FLOW_READY_LEVEL 以上のデータがある
                              --! ことを示す.
                              out std_logic;
        O_POOL_READY        : --! @brief Outlet Valve Pool Ready :
                              --! 先行モード(O_VALVE_PRECEDE=1)の時、プールバッファに 
                              --! O_POOL_READY_LEVEL 以上のデータがあることを示す.
                              out std_logic;
        O_FLOW_READY_LEVEL  : --! @brief Outlet Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以上の時に転送を開始する.
                              --! フローカウンタの値がこの値未満の時に転送を一時停止.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        O_POOL_READY_LEVEL  : --! @brief Outlet Valve Pool Ready Lelvel :
                              --! 先行モード(O_VALVE_PRECEDE=1)の時、T_PULL_FIN_SIZEに
                              --! よるフローカウンタの加算結果が、この値以上の時に
                              --! O_POOL_READY 信号をアサートする.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
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
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        I_FLOW_READY        : --! @brief Intake Valve Flow Ready :
                              --! プールバッファに I_FLOW_READY_LEVEL 以下のデータしか無く、
                              --! データの入力が可能な事を示す.
                              out std_logic;
        I_POOL_READY        : --! @brief Intake Valve Pool Ready :
                              --! 先行モード(I_VALVE_PRECEDE=1)の時、プールバッファに 
                              --! I_POOL_READY_LEVEL以下のデータしか無いことを示す.
                              out std_logic;
        I_FLOW_READY_LEVEL  : --! @brief Intake Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以下の時に入力を開始する.
                              --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_POOL_READY_LEVEL  : --! @brief Intake Valve Pool Ready Level :
                              --! 先行モード(I_VALVE_PRECEDE=1)の時、T_PULL_FIN_SIZE に
                              --! よるフローカウンタの減算結果が、この値以下の時に
                              --! I_POOL_READY 信号をアサートする.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_POOL_SIZE         : --! @brief Intake Pool Size :
                              --! 入力用プールの総容量を指定する.
                              --! I_FLOW_SIZE を求めるのに使用する.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Request from Responder.
    -------------------------------------------------------------------------------
        T_REQ_START         : --! @brief Request Valid signal from responder :
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
                              in  std_logic;
        T_PUSH_FIN_LAST     : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PUSH_FIN_ERR      : --! @brief Push Final Error flags :
                              --! レスポンダ側からのデータ入力中にエラーが発生した
                              --! ことを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PUSH_FIN_SIZE     : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_RSV_VALID    : --! @brief Push Reserve Valid from responder :
                              --! T_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        T_PUSH_RSV_LAST     : --! @brief Push Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ入力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        T_PUSH_RSV_ERR      : --! @brief Push Reserve Error flags :
                              --! レスポンダ側からのデータ入力中にエラーが発生した
                              --! ことを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        T_PUSH_RSV_SIZE     : --! @brief Push Reserve Size :
                              --! レスポンダ側からの"予定された"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from Responder.
    -------------------------------------------------------------------------------
        T_PULL_FIN_VALID    : --! @brief Pull Final Valid from responder :
                              --! T_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PULL_FIN_LAST     : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PULL_FIN_ERR      : --! @brief Pull Final Error flags :
                              --! レスポンダ側からのデータ出力中にエラーが発生した
                              --! ことを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PULL_FIN_SIZE     : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_RSV_VALID    : --! @brief Pull Reserve Valid from responder :
                              --! T_PULL_RSV_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが先行(Precede)モードで無い場合は
                              --!   未使用.
                              in  std_logic;
        T_PULL_RSV_LAST     : --! @brief Pull Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        T_PULL_RSV_ERR      : --! @brief Pull Reserve Error flags :
                              --! レスポンダ側からのデータ出力中にエラーが発生した
                              --! ことを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        T_PULL_RSV_SIZE     : --! @brief Pull Reserve Size :
                              --! レスポンダ側からの"予定された"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0)
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
                              --! * PUSH_VALID>1でデータ転送を行う.
                              --! * PUSH_VALID=0でデータ転送を行わない.
                              integer :=  1;
        PULL_VALID          : --! @brief PUSH VALID :
                              --! リクエスタ側からレスポンダ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PULL_VALID>1でデータ転送を行う.
                              --! * PULL_VALID=0でデータ転送を行わない.
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
        COUNT_BITS          : --! @brief Flow Counter Bits :
                              --! フロー制御用カウンタのビット数を指定する.
                              integer := 32;
        BUF_DEPTH           : --! @brief Buffer Depth :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        O_VALVE_FIXED       : --! @brief Outlet Valve Fixed Mode :
                              --! 出力用バルブのモードを指定する.
                              --! * O_VALVE_FIXED=0 : フローカウンタによるフロー制
                              --!   御を行う.
                              --! * O_VALVE_FIXED=1 : 常にバルブが閉じた状態にする.
                              --! * O_VALVE_FIXED=2 : 常にバルブが開いた状態にする.
                              integer :=  0;
        O_VALVE_PRECEDE     : --! @brief Outlet Valve Precede Mode :
                              --! 出力用バルブを先行(Precede)モードでフローを制御
                              --! するかどうかを指定する.
                              --! * O_VALVE_PRECEDE=0 : 非先行モード. フローカウン
                              --!   タの加算にT_PUSH_FIN_SIZE(入力が確定(FINAL)し
                              --!   たバイト数)を使う.
                              --! * O_VALVE_PRECEDE=1 : 先行モード. フローカウンタ
                              --!   の加算に T_PUSH_RSV_SIZE(入力する予定(RESERVE)
                              --!   のバイト数)を使う.
                              integer :=  0;
        I_VALVE_FIXED       : --! @brief Intake Valve Fixed Mode :
                              --! 入力用バルブのモードを指定する.
                              --! * I_VALVE_FIXED=0 : フローカウンタによるフロー制
                              --!   御を行う.
                              --! * I_VALVE_FIXED=1 : 常にバルブが閉じた状態にする.
                              --! * I_VALVE_FIXED=2 : 常にバルブが開いた状態にする.
                              integer :=  0;
        I_VALVE_PRECEDE     : --! @brief Intake Valve Precede Mode :
                              --! 入力用バルブを先行(Precede)モードでフローを制御
                              --! するかどうかを指定する.
                              --! * I_VALVE_PRECEDE=0 : 非先行モード. 
                              --!   フローカウンタの減算にT_PULL_FIN_SIZE(出力が確
                              --!   定(FINAL)したバイト数)を使う.
                              --! * I_VALVE_PRECEDE=1 : 先行モード. 
                              --!   フローカウンタの減算に T_PULL_RSV_SIZE(出力する
                              --!   予定(RESERVE)のバイト数)を使う.
                              integer :=  0
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
    -- Intake Valve Signals from Responder.
    -------------------------------------------------------------------------------
        T_PUSH_FIN_VALID    : --! @brief Push Final Valid from responder :
                              --! T_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PUSH_FIN_LAST     : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PUSH_FIN_SIZE     : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals from Requester.
    -------------------------------------------------------------------------------
        T_PULL_FIN_VALID    : --! @brief Pull Final Valid from responder :
                              --! T_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PULL_FIN_LAST     : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PULL_FIN_SIZE     : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals to Responder.
    -------------------------------------------------------------------------------
        O_VALVE_OPEN        : --! @brief Outlet Vavle Open :
                              in  std_logic;
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
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        O_FLOW_READY        : --! @brief Outlet Valve Flow Ready :
                              --! プールバッファに O_FLOW_READY_LEVEL 以上のデータがある
                              --! ことを示す.
                              out std_logic;
        O_POOL_READY        : --! @brief Outlet Valve Pool Ready :
                              --! 先行モード(O_VALVE_PRECEDE=1)の時、プールバッファに 
                              --! O_POOL_READY_LEVEL 以上のデータがあることを示す.
                              out std_logic;
        O_FLOW_READY_LEVEL  : --! @brief Outlet Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以上の時に転送を開始する.
                              --! フローカウンタの値がこの値未満の時に転送を一時停止.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        O_POOL_READY_LEVEL  : --! @brief Outlet Valve Pool Ready Lelvel :
                              --! 先行モード(O_VALVE_PRECEDE=1)の時、T_PULL_FIN_SIZEに
                              --! よるフローカウンタの加算結果が、この値以上の時に
                              --! O_POOL_READY 信号をアサートする.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Valve Signals to Responder.
    -------------------------------------------------------------------------------
        I_VALVE_OPEN        : --! @brief Intake Vavle Open :
                              in  std_logic;
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
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        I_FLOW_READY        : --! @brief Intake Valve Flow Ready :
                              --! プールバッファに I_FLOW_READY_LEVEL 以下のデータしか無く、
                              --! データの入力が可能な事を示す.
                              out std_logic;
        I_POOL_READY        : --! @brief Intake Valve Pool Ready :
                              --! 先行モード(I_VALVE_PRECEDE=1)の時、プールバッファに 
                              --! I_POOL_READY_LEVEL以下のデータしか無いことを示す.
                              out std_logic;
        I_FLOW_READY_LEVEL  : --! @brief Intake Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以下の時に入力を開始する.
                              --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_POOL_READY_LEVEL  : --! @brief Intake Valve Pool Ready Level :
                              --! 先行モード(I_VALVE_PRECEDE=1)の時、M_PULL_FIN_SIZE に
                              --! よるフローカウンタの減算結果が、この値以下の時に
                              --! I_POOL_READY 信号をアサートする.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_POOL_SIZE         : --! @brief Intake Pool Size :
                              --! 入力用プールの総容量を指定する.
                              --! I_FLOW_SIZE を求めるのに使用する.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
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
                              in  std_logic;
        M_PUSH_FIN_LAST     : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        M_PUSH_FIN_SIZE     : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_RSV_VALID    : --! @brief Push Reserve Valid from requester :
                              --! M_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        M_PUSH_RSV_LAST     : --! @brief Push Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ入力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        M_PUSH_RSV_SIZE     : --! @brief Push Reserve Size :
                              --! レスポンダ側からの"予定された"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from requester.
    -------------------------------------------------------------------------------
        M_PULL_FIN_VALID    : --! @brief Pull Final Valid from requester :
                              --! M_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        M_PULL_FIN_LAST     : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        M_PULL_FIN_SIZE     : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_RSV_VALID    : --! @brief Pull Reserve Valid from requester :
                              --! M_PULL_RSV_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが先行(Precede)モードで無い場合は
                              --!   未使用.
                              in  std_logic;
        M_PULL_RSV_LAST     : --! @brief Pull Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        M_PULL_RSV_SIZE     : --! @brief Pull Reserve Size :
                              --! レスポンダ側からの"予定された"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief PIPE_CORE_UNIT                                                        --
-----------------------------------------------------------------------------------
component PIPE_CORE_UNIT
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
end component;
end PIPE_COMPONENTS;