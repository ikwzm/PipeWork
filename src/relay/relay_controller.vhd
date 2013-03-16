-----------------------------------------------------------------------------------
--!     @file    relay_controller.vhd
--!     @brief   RELAY CONTROLLER
--!     @version 0.0.1
--!     @date    2013/3/16
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
--! @brief   RELAY CONTROLLER
-----------------------------------------------------------------------------------
entity  RELAY_CONTROLLER is
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
end RELAY_CONTROLLER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.RELAY_COMPONENTS.RELAY_REQUESTER_INTERFACE;
use     PIPEWORK.RELAY_COMPONENTS.RELAY_RESPONDER_INTERFACE;
use     PIPEWORK.RELAY_COMPONENTS.RELAY_REQUEST_SYNCRONIZER;
use     PIPEWORK.RELAY_COMPONENTS.RELAY_RESPONSE_SYNCRONIZER;
architecture RTL of RELAY_CONTROLLER is
begin
end RTL;
