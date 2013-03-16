-----------------------------------------------------------------------------------
--!     @file    relay_components.vhd                                            --
--!     @brief   PIPEWORK RELAY COMPONENTS LIBRARY DESCRIPTION                   --
--!     @version 0.0.1                                                           --
--!     @date    2013/03/16                                                      --
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
--! @brief PIPEWORK RELAY COMPONENTS LIBRARY DESCRIPTION                         --
-----------------------------------------------------------------------------------
package RELAY_COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief RELAY_CONTROLLER                                                      --
-----------------------------------------------------------------------------------
component RELAY_CONTROLLER
    generic (
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
                          --! 入力側から出力側への転送する際の遅延サイクルを指定する.
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
    -- レスポンダ側(ライト方向)とのフロー制御信号入出力.
    -------------------------------------------------------------------------------
        TW_FLOW_PAUSE   : out   std_logic;
        TW_FLOW_STOP    : out   std_logic;
        TW_FLOW_LAST    : out   std_logic;
        TW_FLOW_SIZE    : out   std_logic_vector(SIZE_BITS-1 downto 0);
        TW_BUF_READY    : out   std_logic;
        TW_PUSH_VALID   : in    std_logic;
        TW_PUSH_LAST    : in    std_logic;
        TW_PUSH_ERROR   : in    std_logic;
        TW_PUSH_SIZE    : in    std_logic_vector(SIZE_BITS-1 downto 0);
        TW_RESV_VALID   : in    std_logic;
        TW_RESV_LAST    : in    std_logic;
        TW_RESV_ERROR   : in    std_logic;
        TW_RESV_SIZE    : in    std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- レスポンダ側(リード方向)とのフロー制御信号入出力.
    -------------------------------------------------------------------------------
        TR_FLOW_PAUSE   : out   std_logic;
        TR_FLOW_STOP    : out   std_logic;
        TR_FLOW_LAST    : out   std_logic;
        TR_FLOW_SIZE    : out   std_logic_vector(SIZE_BITS-1 downto 0);
        TR_BUF_READY    : out   std_logic;
        TR_PULL_VALID   : in    std_logic;
        TR_PULL_LAST    : in    std_logic;
        TR_PULL_ERROR   : in    std_logic;
        TR_PULL_SIZE    : in    std_logic_vector(SIZE_BITS-1 downto 0);
        TR_RESV_VALID   : in    std_logic;
        TR_RESV_LAST    : in    std_logic;
        TR_RESV_ERROR   : in    std_logic;
        TR_RESV_SIZE    : in    std_logic_vector(SIZE_BITS-1 downto 0);
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
    -- リクエスタ側(ライト方向)とのフロー制御信号入出力.
    -------------------------------------------------------------------------------
        MW_FLOW_PAUSE   : out   std_logic;
        MW_FLOW_STOP    : out   std_logic;
        MW_FLOW_LAST    : out   std_logic;
        MW_FLOW_SIZE    : out   std_logic_vector(SIZE_BITS-1 downto 0);
        MW_BUF_READY    : out   std_logic;
        MW_PULL_VALID   : in    std_logic;
        MW_PULL_LAST    : in    std_logic;
        MW_PULL_ERROR   : in    std_logic;
        MW_PULL_SIZE    : in    std_logic_vector(SIZE_BITS-1 downto 0);
        MW_RESV_VALID   : in    std_logic;
        MW_RESV_LAST    : in    std_logic;
        MW_RESV_ERROR   : in    std_logic;
        MW_RESV_SIZE    : in    std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- リクエスタ側(リード方向)とのフロー制御信号入出力.
    -------------------------------------------------------------------------------
        MR_FLOW_PAUSE   : out   std_logic;
        MR_FLOW_STOP    : out   std_logic;
        MR_FLOW_LAST    : out   std_logic;
        MR_FLOW_SIZE    : out   std_logic_vector(SIZE_BITS-1 downto 0);
        MR_BUF_READY    : out   std_logic;
        MR_PUSH_VALID   : in    std_logic;
        MR_PUSH_LAST    : in    std_logic;
        MR_PUSH_ERROR   : in    std_logic;
        MR_PUSH_SIZE    : in    std_logic_vector(SIZE_BITS-1 downto 0);
        MR_RESV_VALID   : in    std_logic;
        MR_RESV_LAST    : in    std_logic;
        MR_RESV_ERROR   : in    std_logic;
        MR_RESV_SIZE    : in    std_logic_vector(SIZE_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief RELAY_REQUESTER_INTERFACE                                             --
-----------------------------------------------------------------------------------
component RELAY_REQUESTER_INTERFACE
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
    -- Requester Request Signals.
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
    -- Requester Acknowledge Signals.
    -------------------------------------------------------------------------------
        M_ACK_VALID     : --! @brief Requester Acknowledge Valid Signal.
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
        M_ACK_NONE      : --! @brief Requester Acknowledge with None Request transfer size.
                          --! REQ_SIZE=0 の Request だった場合、この信号がアサート
                          --! される.
                          in    std_logic;
        M_ACK_SIZE      : --! @brief Requester Acknowledge transfer size.
                          --! 転送するバイト数を示す.
                          --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で示さ
                          --! れるバイト数分を加算/減算すると良い.
                          in    std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
        T_REQ_ADDR      : --! @brief Responder Request Address.
                          --! 転送開始アドレスを入力する.  
                          in    std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE      : --! @brief Responder Request Transfer Size.
                          --! 転送したいバイト数を入力する. 
                          in    std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR   : --! @brief Responder Request Buffer Pointer.
                          --! 転送時のバッファポインタを入力する.
                          in    std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE      : --! @brief Responder Request Mode Signals.
                          --! 転送開始時に指定された各種情報を入力する.
                          in    std_logic_vector(MODE_BITS-1 downto 0);
        T_REQ_VALID     : --! @brief Responder Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          in    std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
        T_RES_START     : --! @brief Request Start Signal.
                          --! 転送を開始したことを示す出力信号.
                          out   std_logic;
        T_RES_DONE      : --! @brief Transaction Done Signal.
                          --! 転送を終了したことを示す出力信号.
                          out   std_logic;
        T_RES_ERROR     : --! @brief Transaction Error Signal.
                          --! 転送を異常終了したことを示す出力信号.
                          out   std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
        VALVE_OPEN      : --!  @brief Valve Open Signal.
                          out   std_logic

    );
end component;
-----------------------------------------------------------------------------------
--! @brief RELAY_RESPONDER_INTERFACE                                             --
-----------------------------------------------------------------------------------
component RELAY_RESPONDER_INTERFACE
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
    -- Responder Request Signals.
    -------------------------------------------------------------------------------
        T_REQ_ADDR      : --! @brief Responder Request Address.
                          --! 転送開始アドレスを入力する.  
                          in    std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE      : --! @brief Responder Request Transfer Size.
                          --! 転送したいバイト数を入力する. 
                          in    std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR   : --! @brief Responder Request Buffer Pointer.
                          --! 転送時のバッファポインタを入力する.
                          in    std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE      : --! @brief Responder Request Mode Signals.
                          --! 転送開始時に指定された各種情報を入力する.
                          out   std_logic_vector(MODE_BITS-1 downto 0);
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
    -- Responder Acknowledge Signals.
    -------------------------------------------------------------------------------
        T_ACK_VALID     : --! @brief Responder Acknowledge Valid Signal.
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
                          out   std_logic;
        T_ACK_ERROR     : --! @brief Responder Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          out   std_logic;
        T_ACK_STOP      : --! @brief Responder Acknowledge with Stop operation.
                          --! トランザクションが中止された場合、この信号がアサート
                          --! される.
                          out   std_logic;
        T_ACK_SIZE      : --! @brief Responder Acknowledge transfer size.
                          --! 転送するバイト数を示す.
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
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
        M_REQ_VALID     : --! @brief Requester Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          out   std_logic;
        M_RES_START     : --! @brief Requester Start Signals.
                          --! リクエスタが処理を開始したことを示す.
                          in    std_logic;
        M_RES_DONE      : --! @brief Requester Done Signals.
                          --! リクエスタが処理を終了したことを示す.
                          in    std_logic;
        M_RES_ERROR     : --! @brief Requester Done Signals.
                          --! リクエスタが処理を終了したことを示す.
                          in    std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
        VALVE_OPEN      : --!  @brief Valve Open Signal.
                          out   std_logic

    );
end component;
-----------------------------------------------------------------------------------
--! @brief RELAY_REQUEST_SYNCRONIZER                                             --
-----------------------------------------------------------------------------------
component RELAY_REQUEST_SYNCRONIZER
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
        DELAY_CYCLE     : --! @brief DELAY CYCLE :   
                          --! 入力側から出力側への転送する際の遅延サイクルを指定する.
                          integer :=  0;
        INFO_BITS       : --! @brief REQUEST INFOMATION BITS :
                          integer :=  1;
        SIZE_BITS       : --! @brief I_SIZE/O_SIZEのビット数を指定する.
                          integer :=  8
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号
    -------------------------------------------------------------------------------
        RST             : --! @brief RESET :
                          --! 非同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側の各種信号
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
        I_REQ_VAL       : --! @brief INPUT REQUEST VALID :
                          --! I_REQ_INFOが有効であることを示す信号.
                          in  std_logic;
        I_REQ_INFO      : --! @brief INPUT REQUEST INFOMATION :
                          --! 入力側から出力側へ伝達する各種情報.
                          in  std_logic_vector(INFO_BITS-1 downto 0);
        I_STOP_VAL      : --! @brief INPUT STOP :
                          --! 入力側から出力側へ転送の中止を伝達する信号.
                          --! * 伝達の際、DELAY_CYCLE分だけ遅延される.
                          in  std_logic;
        I_PUSH_VAL      : --! @brief INPUT PUSH SIZE/LAST VALID :
                          --! I_PUSH_LAST、I_PUSH_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_PUSH_LAST、I_PUSH_SIZE、
                          --!   内容が出力側に伝達されて、O_PUSH_LAST、O_PUSH_SIZE
                          --!   から出力される.
                          --! * 伝達の際、DELAY_CYCLE分だけ遅延される.
                          in  std_logic;
        I_PUSH_LAST     : --! @brief INPUT PUSH LAST FLAG :
                          in  std_logic;
        I_PUSH_SIZE     : --! @brief INPUT PUSH SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_PULL_VAL      : --! @brief INPUT PULL SIZE/LAST VALID :
                          --! I_PULL_LAST、I_PULL_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_PULL_LAST、I_PULL_SIZE、
                          --!   内容が出力側に伝達されて、O_PULL_LAST、O_PULL_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_PULL_LAST     : --! @brief INPUT PULL LAST FLAG :
                          in  std_logic;
        I_PULL_SIZE     : --! @brief INPUT PULL SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_RSV0_VAL      : --! @brief INPUT RESERVE(0) SIZE/LAST VALID :
                          --! I_RSV0_LAST、I_RSV0_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_RSV0_LAST、I_RSV0_SIZE、
                          --!   内容が出力側に伝達されて、O_RSV0_LAST、O_RSV0_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_RSV0_LAST     : --! @brief INPUT RESERVE(0) LAST FLAG :
                          in  std_logic;
        I_RSV0_SIZE     : --! @brief INPUT RESERVE(0) SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_RSV1_VAL      : --! @brief INPUT RESERVE(1) SIZE/LAST VALID :
                          --! I_RSV1_LAST、I_RSV1_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_RSV1_LAST、I_RSV1_SIZE、
                          --!   内容が出力側に伝達されて、O_RSV1_LAST、O_RSV1_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_RSV1_LAST     : --! @brief INPUT RESERVE(1) LAST FLAG :
                          in  std_logic;
        I_RSV1_SIZE     : --! @brief INPUT RESERVE(1) SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側の各種信号
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
        O_REQ_VAL       : --! @brief OUTPUT REQUEST VALID :
                          --! O_REQ_INFOが有効であることを示す信号.
                          out std_logic;
        O_REQ_INFO      : --! @brief OUTPUT REQUEST INFOMATION :
                          --! 入力側から出力側へ伝達された各種情報.
                          out std_logic_vector(INFO_BITS-1 downto 0);
        O_STOP_VAL      : --! @brief OUTPUT STOP :
                          --! 入力側から出力側へ伝達された、転送を中止する信号.
                          --! * 伝達の際、DELAY_CYCLE分だけ遅延される.
                          out std_logic;
        O_PUSH_VAL      : --! @brief OUTPUT PUSH SIZE/LAST VALID :
                          --! O_PUSH_LAST、O_PUSH_SIZE、が有効であることを示す信号.
                          out  std_logic;
        O_PUSH_LAST     : --! @brief OUTPUT PUSH LAST FLAG :
                          out std_logic;
        O_PUSH_SIZE     : --! @brief OUTPUT PUSH SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_PULL_VAL      : --! @brief OUTPUT PULL SIZE/LAST VALID :
                          --! O_PULL_LAST、O_PULL_SIZE、が有効であることを示す信号.
                          out std_logic;
        O_PULL_LAST     : --! @brief OUTPUT PULL LAST FLAG :
                          out std_logic;
        O_PULL_SIZE     : --! @brief OUTPUT PULL SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_RSV0_VAL      : --! @brief OUTPUT RESERVE(0) SIZE/LAST VALID :
                          --! O_RSV0_LAST、O_RSV0_SIZE、が有効であることを示す信号.
                          out std_logic;
        O_RSV0_LAST     : --! @brief OUTPUT RESERVE(0) LAST FLAG :
                          out std_logic;
        O_RSV0_SIZE     : --! @brief OUTPUT RESERVE(0) SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_RSV1_VAL      : --! @brief OUTPUT RESERVE(1) SIZE/LAST VALID :
                          out std_logic;
        O_RSV1_LAST     : --! @brief OUTPUT RESERVE(1) LAST FLAG :
                          out std_logic;
        O_RSV1_SIZE     : --! @brief OUTPUT RESERVE(1) SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief RELAY_RESPONSE_SYNCRONIZER                                            --
-----------------------------------------------------------------------------------
component RELAY_RESPONSE_SYNCRONIZER
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
        DELAY_CYCLE     : --! @brief DELAY CYCLE :   
                          --! 入力側から出力側への転送する際の遅延サイクルを指定する.
                          integer :=  0;
        INFO_BITS       : --! @brief RESPONSE INFOMATION BITS :
                          integer :=  1;
        SIZE_BITS       : --! @brief I_SIZE/O_SIZEのビット数を指定する.
                          integer :=  8
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号
    -------------------------------------------------------------------------------
        RST             : --! @brief RESET :
                          --! 非同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側の各種信号
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
        I_START_VAL     : --! @brief INPUT START :
                          --! 入力側から出力側へ転送の開始を伝達する信号.
                          in  std_logic;
        I_RES_VAL       : --! @brief INPUT RESPONSE VALID :
                          --! I_RES_INFOが有効であることを示す信号.
                          --! * 伝達の際、場合によっては DELAY_CYCLE分だけ遅延される.
                          in  std_logic;
        I_RES_INFO      : --! @brief INPUT RESPONSE INFOMATION :
                          --! 入力側から出力側へ伝達する各種情報.
                          --! * 伝達の際、場合によっては DELAY_CYCLE分だけ遅延される.
                          in  std_logic_vector(INFO_BITS-1 downto 0);
        I_PUSH_VAL      : --! @brief INPUT PUSH SIZE/LAST VALID :
                          --! I_PUSH_LAST、I_PUSH_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_PUSH_LAST、I_PUSH_SIZE、
                          --!   内容が出力側に伝達されて、O_PUSH_LAST、O_PUSH_SIZE
                          --!   から出力される.
                          --! * 伝達の際、DELAY_CYCLE分だけ遅延される.
                          in  std_logic;
        I_PUSH_LAST     : --! @brief INPUT PUSH LAST FLAG :
                          in  std_logic;
        I_PUSH_SIZE     : --! @brief INPUT PUSH SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_PULL_VAL      : --! @brief INPUT PULL SIZE/LAST VALID :
                          --! I_PULL_LAST、I_PULL_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_PULL_LAST、I_PULL_SIZE、
                          --!   内容が出力側に伝達されて、O_PULL_LAST、O_PULL_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_PULL_LAST     : --! @brief INPUT PULL LAST FLAG :
                          in  std_logic;
        I_PULL_SIZE     : --! @brief INPUT PULL SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_RSV0_VAL      : --! @brief INPUT RESERVE(0) SIZE/LAST VALID :
                          --! I_RSV0_LAST、I_RSV0_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_RSV0_LAST、I_RSV0_SIZE、
                          --!   内容が出力側に伝達されて、O_RSV0_LAST、O_RSV0_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_RSV0_LAST     : --! @brief INPUT RESERVE(0) LAST FLAG :
                          in  std_logic;
        I_RSV0_SIZE     : --! @brief INPUT RESERVE(0) SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_RSV1_VAL      : --! @brief INPUT RESERVE(1) SIZE/LAST VALID :
                          --! I_RSV1_LAST、I_RSV1_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_RSV1_LAST、I_RSV1_SIZE、
                          --!   内容が出力側に伝達されて、O_RSV1_LAST、O_RSV1_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_RSV1_LAST     : --! @brief INPUT RESERVE(1) LAST FLAG :
                          in  std_logic;
        I_RSV1_SIZE     : --! @brief INPUT RESERVE(1) SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側の各種信号
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
        O_START_VAL     : --! @brief OUTPUT START :
                          --! 入力側から出力側へ転送の開始を伝達する信号.
                          out std_logic;
        O_RES_VAL       : --! @brief OUTPUT RESPONSE VALID :
                          --! O_RES_INFOが有効であることを示す信号.
                          out std_logic;
        O_RES_INFO      : --! @brief OUTPUT RESPONSE INFOMATION :
                          --! 入力側から出力側へ伝達された各種情報.
                          out std_logic_vector(INFO_BITS-1 downto 0);
        O_PUSH_VAL      : --! @brief OUTPUT PUSH SIZE/LAST VALID :
                          --! O_PUSH_LAST、O_PUSH_SIZE、が有効であることを示す信号.
                          out  std_logic;
        O_PUSH_LAST     : --! @brief OUTPUT PUSH LAST FLAG :
                          out std_logic;
        O_PUSH_SIZE     : --! @brief OUTPUT PUSH SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_PULL_VAL      : --! @brief OUTPUT PULL SIZE/LAST VALID :
                          --! O_PULL_LAST、O_PULL_SIZE、が有効であることを示す信号.
                          out std_logic;
        O_PULL_LAST     : --! @brief OUTPUT PULL LAST FLAG :
                          out std_logic;
        O_PULL_SIZE     : --! @brief OUTPUT PULL SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_RSV0_VAL      : --! @brief OUTPUT RESERVE(0) SIZE/LAST VALID :
                          --! O_RSV0_LAST、O_RSV0_SIZE、が有効であることを示す信号.
                          out std_logic;
        O_RSV0_LAST     : --! @brief OUTPUT RESERVE(0) LAST FLAG :
                          out std_logic;
        O_RSV0_SIZE     : --! @brief OUTPUT RESERVE(0) SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_RSV1_VAL      : --! @brief OUTPUT RESERVE(1) SIZE/LAST VALID :
                          out std_logic;
        O_RSV1_LAST     : --! @brief OUTPUT RESERVE(1) LAST FLAG :
                          out std_logic;
        O_RSV1_SIZE     : --! @brief OUTPUT RESERVE(1) SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0)
    );
end component;
end RELAY_COMPONENTS;
