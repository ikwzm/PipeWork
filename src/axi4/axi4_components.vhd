-----------------------------------------------------------------------------------
--!     @file    axi4_components.vhd                                             --
--!     @brief   PIPEWORK AXI4 LIBRARY DESCRIPTION                               --
--!     @version 1.5.0                                                           --
--!     @date    2013/03/20                                                      --
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
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief PIPEWORK AXI4 LIBRARY DESCRIPTION                                     --
-----------------------------------------------------------------------------------
package AXI4_COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER                                --
-----------------------------------------------------------------------------------
component AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        VAL_BITS        : --! @brief VALID BITS :
                          --! REQ_VAL、ACK_VAL のビット数を指定する.
                          integer := 1;
        DATA_SIZE       : --! @brief DATA SIZE :
                          --! データバスのバイト数を"２のべき乗値"で指定する.
                          integer := 6;
        ADDR_BITS       : --! @brief ADDRESS BITS :
                          --! アドレス信号のビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! 各種SIZE信号のビット数を指定する.
                          integer := 32;
        REQ_SIZE_BITS   : --! @brief REQUEST SIZE BITS :
                          --! REQ_SIZE信号のビット数を指定する.
                          --! * REQ_SIZE信号が無効(REQ_SIZE_ENABLE=0)の場合でもエラ
                          --!   ーが発生しないように、REQ_SIZE_BITS>0にしておかなけ
                          --!   ればならない.
                          integer := 32;
        REQ_SIZE_VALID  : --! @brief REQUEST SIZE VALID :
                          --! REQ_SIZE信号を有効にするかどうかを指定する.
                          --! * REQ_SIZE_VALID=0で無効.
                          --! * REQ_SIZE_VALID>0で有効.
                          integer :=  1;
        FLOW_VALID      : --! @brief FLOW VALID :
                          --! FLOW_PAUSE、FLOW_STOP、FLOW_SIZE、FLOW_LAST信号を有効
                          --! にするかどうかを指定する.
                          --! * FLOW_VALID=0で無効.
                          --! * FLOW_VALID>0で有効.
                          integer := 1;
        XFER_MIN_SIZE   : --! @brief TRANSFER MINIMUM SIZE :
                          --! 一回の転送サイズの最小バイト数を２のべき乗で指定する.
                          integer := 4;
        XFER_MAX_SIZE   : --! @brief TRANSFER MAXIMUM SIZE :
                          --! 一回の転送サイズの最大バイト数を２のべき乗で指定する.
                          integer := 4
    );
    port(
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK             : in    std_logic;
        RST             : in    std_logic;
        CLR             : in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Address Channel Signals.
    ------------------------------------------------------------------------------
        AADDR           : out   std_logic_vector(ADDR_BITS    -1 downto 0);
        ASIZE           : out   AXI4_ASIZE_TYPE;
        ALEN            : out   AXI4_ALEN_TYPE;
        AVALID          : out   std_logic;
        AREADY          : in    std_logic;
    -------------------------------------------------------------------------------
    -- Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_ADDR        : in    std_logic_vector(ADDR_BITS    -1 downto 0);
        REQ_SIZE        : in    std_logic_vector(REQ_SIZE_BITS-1 downto 0);
        REQ_FIRST       : in    std_logic;
        REQ_LAST        : in    std_logic;
        REQ_SPECULATIVE : in    std_logic;
        REQ_SAFETY      : in    std_logic;
        REQ_VAL         : in    std_logic_vector(VAL_BITS     -1 downto 0);
        REQ_RDY         : out   std_logic;
    -------------------------------------------------------------------------------
    -- Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VAL         : out   std_logic_vector(VAL_BITS     -1 downto 0);
        ACK_NEXT        : out   std_logic;
        ACK_LAST        : out   std_logic;
        ACK_ERROR       : out   std_logic;
        ACK_STOP        : out   std_logic;
        ACK_NONE        : out   std_logic;
        ACK_SIZE        : out   std_logic_vector(SIZE_BITS    -1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_PAUSE      : in    std_logic := '0';
        FLOW_STOP       : in    std_logic := '0';
        FLOW_LAST       : in    std_logic := '1';
        FLOW_SIZE       : in    std_logic_vector(SIZE_BITS    -1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- Transfer Size Select Signals.
    -------------------------------------------------------------------------------
        XFER_SIZE_SEL   : in    std_logic_vector(XFER_MAX_SIZE   downto XFER_MIN_SIZE) := (others => '1');
    -------------------------------------------------------------------------------
    -- Transfer Request Signals.
    -------------------------------------------------------------------------------
        XFER_REQ_ADDR   : out   std_logic_vector(ADDR_BITS    -1 downto 0);
        XFER_REQ_SIZE   : out   std_logic_vector(XFER_MAX_SIZE   downto 0);
        XFER_REQ_SEL    : out   std_logic_vector(VAL_BITS     -1 downto 0);
        XFER_REQ_FIRST  : out   std_logic;
        XFER_REQ_LAST   : out   std_logic;
        XFER_REQ_NEXT   : out   std_logic;
        XFER_REQ_SAFETY : out   std_logic;
        XFER_REQ_VAL    : out   std_logic;
        XFER_REQ_RDY    : in    std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Response Signals.
    -------------------------------------------------------------------------------
        XFER_ACK_SIZE   : in    std_logic_vector(XFER_MAX_SIZE   downto 0);
        XFER_ACK_VAL    : in    std_logic;
        XFER_ACK_NEXT   : in    std_logic;
        XFER_ACK_LAST   : in    std_logic;
        XFER_ACK_ERR    : in    std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Status Signals.
    -------------------------------------------------------------------------------
        XFER_RUNNING    : in    std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_MASTER_READ_INTERFACE                                            --
-----------------------------------------------------------------------------------
component AXI4_MASTER_READ_INTERFACE
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 リードアドレスチャネルのARADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 READ DATA CHANNEL DATA WIDTH :
                          --! AXI4 リードデータチャネルのRDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびリードデータチャネルの
                          --! ID信号のビット幅.
                          integer range 1 to AXI4_ID_MAX_WIDTH;
        VAL_BITS        : --! @brief VALID BITS :
                          --! REQ_VAL、ACK_VAL のビット数を指定する.
                          integer := 1;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! 各種サイズカウンタのビット数を指定する.
                          integer := 32;
        REQ_SIZE_BITS   : --! @brief REQUEST SIZE BITS:
                          --! REQ_SIZE信号のビット数を指定する.
                          integer := 32;
        REQ_SIZE_VALID  : --! @brief REQUEST SIZE VALID :
                          --! REQ_SIZE信号を有効にするかどうかを指定する.
                          --! * REQ_SIZE_VALID=0で無効.
                          --! * REQ_SIZE_VALID>0で有効.
                          integer :=  1;
        FLOW_VALID      : --! @brief FLOW VALID :
                          --! FLOW_PAUSE、FLOW_STOP、FLOW_SIZE、FLOW_LAST信号を有効
                          --! にするかどうかを指定する.
                          --! * FLOW_VALID=0で無効.
                          --! * FLOW_VALID>0で有効.
                          integer := 1;
        BUF_DATA_WIDTH  : --! @brief BUFFER DATA WIDTH :
                          --! バッファのビット幅を指定する.
                          integer := 32;
        BUF_PTR_BITS    : --! @brief BUFFER POINTER BITS :
                          --! バッファポインタなどを表す信号のビット数を指定する.
                          integer := 8;
        XFER_MIN_SIZE   : --! @brief TRANSFER MINIMUM SIZE :
                          --! 一回の転送サイズの最小バイト数を２のべき乗で指定する.
                          integer := 4;
        XFER_MAX_SIZE   : --! @brief TRANSFER MAXIMUM SIZE :
                          --! 一回の転送サイズの最大バイト数を２のべき乗で指定する.
                          integer := 4;
        QUEUE_SIZE      : --! @brief RESPONSE QUEUE SIZE :
                          --! キューの大きさを指定する.
                          integer := 1
    );
    port(
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Read Address Channel Signals.
    ------------------------------------------------------------------------------
        ARID            : --! @brief Read address ID.
                          --! This signal is identification tag for the read
                          --! address group of singals.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        ARADDR          : --! @brief Read address.  
                          --! The read address gives the address of the first
                          --! transfer in a read burst transaction.
                          out   std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        ARLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          out   AXI4_ALEN_TYPE;
        ARSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          out   AXI4_ASIZE_TYPE;
        ARBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          out   AXI4_ABURST_TYPE;
        ARLOCK          : --! @brief Lock type.
                          --! This signal provides additional information about
                          --! the atomic characteristics of the transfer.
                          out   AXI4_ALOCK_TYPE;
        ARCACHE         : --! @brief Memory type.
                          --! This signal indicates how transactions are required
                          --! to progress through a system.
                          out   AXI4_ACACHE_TYPE;
        ARPROT          : --! @brief Protection type.
                          --! This signal indicates the privilege and security
                          --! level of the transaction, and wherther the
                          --! transaction is a data access or an instruction access.
                          out   AXI4_APROT_TYPE;
        ARQOS           : --! @brief Quality of Service, QoS.
                          --! QoS identifier sent for each read transaction.
                          out   AXI4_AQOS_TYPE;
        ARREGION        : --! @brief Region identifier.
                          --! Permits a single physical interface on a slave to be
                          --! used for multiple logical interfaces.
                          out   AXI4_AREGION_TYPE;
        ARVALID         : --! @brief Read address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          out   std_logic;
        ARREADY         : --! @brief Read address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Read Data Channel Signals.
    ------------------------------------------------------------------------------
        RID             : --! @brief Read ID tag.
                          --! This signal is the identification tag for the read
                          --! data group of signals generated by the slave.
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        RDATA           : --! @brief Read data.
                          in    std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        RRESP           : --! @brief Read response.
                          --! This signal indicates the status of the read transaction.
                          in    AXI4_RESP_TYPE;
        RLAST           : --! @brief Read last.
                          --! This signal indicates the last transfer in a read burst.
                          in    std_logic;
        RVALID          : --! @brief Read data valid.
                          --! This signal indicates that the channel is signaling
                          --! the required read data.
                          in    std_logic;
        RREADY          : --! @brief Read data ready.
                          --! This signal indicates that the master can accept the
                          --! read data and response information.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- Command Request Signals.
    -------------------------------------------------------------------------------
        XFER_SIZE_SEL   : --! @brief Max Transfer Size Select Signal.
                          --! 一回の転送サイズの最大バイト数を指定する.  
                          --! * XFER_MAX_SIZE=XFER_MIN_SIZEの場合は、この信号は無視
                          --!   される.
                          in    std_logic_vector(XFER_MAX_SIZE downto XFER_MIN_SIZE)
                          := (others => '1');
        REQ_ADDR        : --! @brief Request Address.
                          --! 転送開始アドレスを指定する.  
                          in    std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        REQ_SIZE        : --! @brief Request Transfer Size.
                          --! 転送したいバイト数を指定する. 
                          --! * REQ_SIZE_VALID=0の場合は、この信号は無視される.
                          --! * この値が後述の XFER_SIZE_SEL 信号で示される最大転送
                          --!   バイト数および FLOW_SIZE 信号で示される転送バイト数
                          --!   を越える場合は、そちらの方が優先される.
                          in    std_logic_vector(REQ_SIZE_BITS    -1 downto 0);
        REQ_ID          : --! @brief Request ID.
                          --! ARID の値を指定する.
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        REQ_BURST       : --! @brief Request Burst type.
                          --! バーストタイプを指定する.  
                          --! * このモジュールでは AXI4_ABURST_INCR と AXI4_ABURST_FIXED
                          --!   のみをサポートしている.
                          in    AXI4_ABURST_TYPE;
        REQ_LOCK        : --! @brief Request Lock type.
                          --! ARLOCK の値を指定する.
                          in    AXI4_ALOCK_TYPE;
        REQ_CACHE       : --! @brief Request Memory type.
                          --! ARCACHE の値を指定する.
                          in    AXI4_ACACHE_TYPE;
        REQ_PROT        : --! @brief Request Protection type.
                          --! ARPROT の値を指定する.
                          in    AXI4_APROT_TYPE;
        REQ_QOS         : --! @brief Request Quality of Service.
                          --! ARQOS の値を指定する.
                          in    AXI4_AQOS_TYPE;
        REQ_REGION      : --! @brief Request Region identifier.
                          --! ARREGION の値を指定する.
                          in    AXI4_AREGION_TYPE;
        REQ_BUF_PTR     : --! @brief Request Write Buffer Pointer.
                          --! ライトバッファの先頭ポインタの値を指定する.
                          --! * ライトバッファのこのポインタの位置からRDATAを書き込
                          --!   む.
                          in    std_logic_vector(BUF_PTR_BITS     -1 downto 0);
        REQ_FIRST       : --! @brief Request First Transaction.
                          --! 最初のトランザクションであることを示す.
                          --! * REQ_FIRST=1の場合、内部状態を初期化してからトランザ
                          --!   クションを開始する.
                          in    std_logic;
        REQ_LAST        : --! @brief Request Last Transaction.
                          --! 最後のトランザクションであることを示す.
                          --! * REQ_LAST=1の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_LAST 信号をア
                          --!   サートする.
                          --! * REQ_LAST=0の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_NEXT 信号をア
                          --!   サートする.
                          in    std_logic;
        REQ_SPECULATIVE : --! @brief Request Speculative Mode.
                          --! Acknowledge を返すタイミングを投機モードで行うかどう
                          --! かを指定する.
                          in    std_logic;
        REQ_SAFETY      : --! @brief Request Safety Mode.
                          --! Acknowledge を返すタイミングを安全モードで行うかどう
                          --! かを指定する.
                          --! * REQ_SAFETY=1の場合、スレーブから最初の Read Data が
                          --!   帰ってきた時点で Acknowledge を返す.
                          --! * REQ_SAFETY=0の場合、スレーブから最後の Read Data が
                          --!   帰ってきた時点で Acknowledge を返す.
                          in    std_logic;
        REQ_VAL         : --! @brief Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          in    std_logic_vector(VAL_BITS-1 downto 0);
        REQ_RDY         : --! @brief Request Ready Signal.
                          --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VAL         : --! @brief Acknowledge Valid Signal.
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
                          out   std_logic_vector(VAL_BITS-1 downto 0);
        ACK_NEXT        : --! @brief Acknowledge with need Next transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=0 の場合、
                          --! この信号がアサートされる.
                          out   std_logic;
        ACK_LAST        : --! @brief Acknowledge with Last transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=1 の場合、
                          --! この信号がアサートされる.
                          out   std_logic;
        ACK_ERROR       : --! @brief Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          out   std_logic;
        ACK_STOP        : --! @brief Acknowledge with Stop operation.
                          --! トランザクションが中止された場合、この信号がアサート
                          --! される.
                          out   std_logic;
        ACK_NONE        : --! @brief Acknowledge with None Request transfer size.
                          --! REQ_SIZE=0 の Request だった場合、この信号がアサート
                          --! される.
                          out   std_logic;
        ACK_SIZE        : --! @brief Acknowledge transfer size.
                          --! 転送するバイト数を示す.
                          --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で示さ
                          --! れるバイト数分を加算/減算すると良い.
                          out   std_logic_vector(SIZE_BITS        -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transfer Status Signal.
    -------------------------------------------------------------------------------
        XFER_BUSY       : --! @brief Transfer Busy.
                          --! このモジュールが未だデータの転送中であることを示す.
                          --! * QUEUE_SIZEの設定によっては、XFER_BUSY がアサートさ
                          --!   れていても、次のリクエストを受け付け可能な場合があ
                          --!   る.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_STOP       : --! @brief Flow Stop.
                          --! 転送中止信号.
                          --! * 転送を中止する時はこの信号をアサートする.
                          --! * 一旦アサートしたら、完全に停止するまで(XFER_BUSYが
                          --!   ネゲートされるまで)、アサートしたままにしておかなけ
                          --!   ればならない.
                          --! * ただし、一度 AXI4 に発行したトランザクションは中止
                          --!   出来ない.
                          --! * FLOW_VALID=0の場合、この信号は無視される.
                          in    std_logic := '0';
        FLOW_PAUSE      : --! @brief Flow Pause.
                          --! 転送一時中断信号.
                          --! * 転送を一時中断する時はこの信号をアサートする.
                          --! * 転送を再開したい時はこの信号をネゲートする.
                          --! * ただし、一度 AXI4 に発行したトランザクションは中断
                          --!   出来ない. あくまでも、次に発行する予定のトランザク
                          --!   ションを一時的に停めるだけ.
                          --! * 例えば FIFO の空き容量が一定値未満になった時に、こ
                          --!   の信号をアサートすると、再びネゲートするまで転送を
                          --!   中断する.
                          --! * FLOW_VALID=0の場合、この信号は無視される.
                          in    std_logic := '0';
        FLOW_LAST       : --! @brief Flow Last.
                          --! 最後の転送であることを示す.
                          --! * FLOW_PAUSE='0'の時のみ有効.
                          --! * FLOW_VALID=0の場合、この信号は無視される.
                          in    std_logic := '1';
        FLOW_SIZE       : --! @brief Flow Size.
                          --! 転送するバイト数を指定する.
                          --! * FLOW_PAUSE='0'の時のみ有効.
                          --! * 例えば FIFO の空き容量を入力すると、この容量を越え
                          --!   た転送は行わない.
                          --! * FLOW_VALID=0の場合、この信号は無視される.
                          in    std_logic_vector(SIZE_BITS        -1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- Reserve Size Signals.
    -------------------------------------------------------------------------------
        RESV_VAL        : --! @brief Reserve Valid.
                          --! RESV_LAST/RESV_ERROR/RESV_SIZEが有効であることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        RESV_LAST       : --! @brief Reserve Last.
                          --! 最後の転送"する予定"である事を示すフラグ.
                          out   std_logic;
        RESV_ERROR      : --! @brief Reserve Error.
                          --! 転送"する予定"がエラーだった事を示すフラグ.
                          out   std_logic;
        RESV_SIZE       : --! @brief Reserve Size.
                          --! 転送"する予定"のバイト数を出力する.
                          out   std_logic_vector(SIZE_BITS        -1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VAL        : --! @brief Pull Valid.
                          --! PUSH_LAST/PUSH_ERROR/PUSH_SIZEが有効であることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PUSH_LAST       : --! @brief Pull Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PUSH_ERROR      : --! @brief Reserve Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PUSH_SIZE       : --! @brief Reserve Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(SIZE_BITS        -1 downto 0);
    -------------------------------------------------------------------------------
    -- Read Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_WEN         : --! @brief Buffer Write Enable.
                          --! バッファにデータをライトすることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        BUF_BEN         : --! @brief Buffer Byte Enable.
                          --! バッファにデータをライトする際のバイトイネーブル信号.
                          --! * BUF_WEN='1'の場合にのみ有効.
                          --! * BUF_WEN='0'の場合のこの信号の値は不定.
                          out   std_logic_vector(BUF_DATA_WIDTH/8 -1 downto 0);
        BUF_DATA        : --! @brief Buffer Data.
                          --! バッファへライトするデータを出力する.
                          out   std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
        BUF_PTR         : --! @brief Buffer Write Pointer.
                          --! ライト時にデータを書き込むバッファの位置を出力する.
                          out   std_logic_vector(BUF_PTR_BITS     -1 downto 0);
        BUF_RDY         : --! @brief Buffer Write Ready.
                          --! バッファにデータを書き込み可能な事をを示す.
                          in    std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_MASTER_WRITE_INTERFACE                                           --
-----------------------------------------------------------------------------------
component AXI4_MASTER_WRITE_INTERFACE
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 ライトアドレスチャネルのAWADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 WRITE DATA CHANNEL DATA WIDTH :
                          --! AXI4 ライトデータチャネルのWDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびライトレスポンスチャネルの
                          --! ID信号のビット幅.
                          integer range 1 to AXI4_ID_MAX_WIDTH;
        VAL_BITS        : --! @brief VALID BITS :
                          --! REQ_VAL、ACK_VAL のビット数を指定する.
                          integer := 1;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! 各種サイズカウンタのビット数を指定する.
                          integer := 32;
        REQ_SIZE_BITS   : --! @brief REQUEST SIZE BITS:
                          --! REQ_SIZE信号のビット数を指定する.
                          integer := 32;
        REQ_SIZE_VALID  : --! @brief REQUEST SIZE VALID :
                          --! REQ_SIZE信号を有効にするかどうかを指定する.
                          --! * REQ_SIZE_VALID=0で無効.
                          --! * REQ_SIZE_VALID>0で有効.
                          integer :=  1;
        FLOW_VALID      : --! @brief FLOW VALID :
                          --! FLOW_PAUSE、FLOW_STOP、FLOW_SIZE、FLOW_LAST信号を有効
                          --! にするかどうかを指定する.
                          --! * FLOW_VALID=0で無効.
                          --! * FLOW_VALID>0で有効.
                          integer := 1;
        BUF_DATA_WIDTH  : --! @brief BUFFER DATA WIDTH :
                          --! バッファのビット幅を指定する.
                          integer := 32;
        BUF_PTR_BITS    : --! @brief BUFFER POINTER BITS :
                          --! バッファポインタなどを表す信号のビット数を指定する.
                          integer := 8;
        XFER_MIN_SIZE   : --! @brief TRANSFER MINIMUM SIZE :
                          --! 一回の転送サイズの最小バイト数を２のべき乗で指定する.
                          integer := 4;
        XFER_MAX_SIZE   : --! @brief TRANSFER MAXIMUM SIZE :
                          --! 一回の転送サイズの最大バイト数を２のべき乗で指定する.
                          integer := 4;
        QUEUE_SIZE      : --! @brief RESPONSE QUEUE SIZE :
                          --! キューの大きさを指定する.
                          integer := 1
    );
    port(
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Signals.
    ------------------------------------------------------------------------------
        AWID            : --! @brief Write address ID.
                          --! This signal is identification tag for the write
                          --! address group of singals.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        AWADDR          : --! @brief Write address.  
                          --! The read address gives the address of the first
                          --! transfer in a write burst transaction.
                          out   std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        AWLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          out   AXI4_ALEN_TYPE;
        AWSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          out   AXI4_ASIZE_TYPE;
        AWBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          out   AXI4_ABURST_TYPE;
        AWLOCK          : --! @brief Lock type.
                          --! This signal provides additional information about
                          --! the atomic characteristics of the transfer.
                          out   AXI4_ALOCK_TYPE;
        AWCACHE         : --! @brief Memory type.
                          --! This signal indicates how transactions are required
                          --! to progress through a system.
                          out   AXI4_ACACHE_TYPE;
        AWPROT          : --! @brief Protection type.
                          --! This signal indicates the privilege and security
                          --! level of the transaction, and wherther the
                          --! transaction is a data access or an instruction access.
                          out   AXI4_APROT_TYPE;
        AWQOS           : --! @brief Quality of Service, QoS.
                          --! QoS identifier sent for each read transaction.
                          out   AXI4_AQOS_TYPE;
        AWREGION        : --! @brief Region identifier.
                          --! Permits a single physical interface on a slave to be
                          --! used for multiple logical interfaces.
                          out   AXI4_AREGION_TYPE;
        AWVALID         : --! @brief Write address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          out   std_logic;
        AWREADY         : --! @brief Write address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Write Data Channel Signals.
    ------------------------------------------------------------------------------
        WID             : --! @brief Write ID tag.
                          --! This signal is the identification tag for the write
                          --! data transfer. Supported only AXI3.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        WDATA           : --! @brief Write data.
                          out   std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        WSTRB           : --! @brief Write strobes.
                          --! This signal indicates which byte lanes holdvalid 
                          --! data. There is one write strobe bit for each eight
                          --! bits of the write data bus.
                          out   std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
        WLAST           : --! @brief Write last.
                          --! This signal indicates the last transfer in a write burst.
                          out   std_logic;
        WVALID          : --! @brief Write valid.
                          --! This signal indicates that valid write data and
                          --! strobes are available.
                          out   std_logic;
        WREADY          : --! @brief Write ready.
                          --! This signal indicates that the slave can accept the
                          --! write data.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Write Response Channel Signals.
    ------------------------------------------------------------------------------
        BID             : --! @brief Response ID tag.
                          --! This signal is the identification tag of write
                          --! response .
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        BRESP           : --! @brief Write response.
                          --! This signal indicates the status of the write transaction.
                          in    AXI4_RESP_TYPE;
        BVALID          : --! @brief Write response valid.
                          --! This signal indicates that the channel is signaling
                          --! a valid write response.
                          in    std_logic;
        BREADY          : --! @brief Write response ready.
                          --! This signal indicates that the master can accept a
                          --! write response.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- Command Request Signals.
    -- これらの信号は Command Acknowledge Signal(ACK_VAL)がアサートされるまで変更し
    -- てはならない.
    -------------------------------------------------------------------------------
        XFER_SIZE_SEL   : --! @brief Max Transfer Size Select Signal.
                          --! 一回の転送サイズの最大バイト数を指定する.  
                          --! * XFER_MAX_SIZE=XFER_MIN_SIZEの場合は、この信号は無視
                          --!   される.
                          in    std_logic_vector(XFER_MAX_SIZE downto XFER_MIN_SIZE)
                          := (others => '1');
        REQ_ADDR        : --! @brief Request Address.
                          --! 転送開始アドレスを指定する.
                          in    std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        REQ_SIZE        : --! @brief Request Transfer Size.
                          --! 転送したいバイト数を指定する.
                          --! * REQ_SIZE_VALID=0の場合は、この信号は無視される.
                          --! * この値が後述の XFER_SIZE_SEL 信号で示される最大転送
                          --!   バイト数および FLOW_SIZE 信号で示される転送バイト数
                          --!   を越える場合は、そちらの方が優先される.
                          in    std_logic_vector(REQ_SIZE_BITS    -1 downto 0);
        REQ_ID          : --! @brief Request ID.
                          --! AWID および WID の値を指定する.  
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        REQ_BURST       : --! @brief Request Burst type.
                          --! バーストタイプを指定する.  
                          --! * このモジュールでは AXI4_ABURST_INCR と AXI4_ABURST_FIXED
                          --!   のみをサポートしている.
                          in    AXI4_ABURST_TYPE;
        REQ_LOCK        : --! @brief Request Lock type.
                          --! AWLOCK の値を指定する.
                          in    AXI4_ALOCK_TYPE;
        REQ_CACHE       : --! @brief Request Memory type.
                          --! AWCACHE の値を指定する.
                          in    AXI4_ACACHE_TYPE;
        REQ_PROT        : --! @brief Request Protection type.
                          --! AWPROT の値を指定する.
                          in    AXI4_APROT_TYPE;
        REQ_QOS         : --! @brief Request Quality of Service.
                          --! AWQOS の値を指定する.
                          in    AXI4_AQOS_TYPE;
        REQ_REGION      : --! @brief Request Region identifier.
                          --! AWREGION の値を指定する.
                          in    AXI4_AREGION_TYPE;
        REQ_BUF_PTR     : --! @brief Request Read Buffer Pointer.
                          --! リードバッファの先頭ポインタの値を指定する.  
                          --! * リードバッファのこのポインタの位置からデータを読み
                          --!   込んで、WDATAに出力する.
                          in    std_logic_vector(BUF_PTR_BITS     -1 downto 0);
        REQ_FIRST       : --! @brief Request First Transaction.
                          --! 最初のトランザクションであることを示す.  
                          --! * REQ_FIRST=1の場合、内部状態を初期化してからトランザ
                          --!   クションを開始する.
                          in    std_logic;
        REQ_LAST        : --! @brief Request Last Transaction.
                          --! 最後のトランザクションであることを示す.
                          --! * REQ_LAST=1の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_LAST 信号をア
                          --!   サートする.
                          --! * REQ_LAST=0の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_NEXT 信号をア
                          --!   サートする.
                          in    std_logic;
        REQ_SPECULATIVE : --! @brief Request Speculative Mode.
                          --! Acknowledge を返すタイミングを投機モードで行うかどう
                          --! かを指定する.
                          in    std_logic;
        REQ_SAFETY      : --! @brief Request Safety Mode.
                          --! Acknowledge を返すタイミングを安全モードで行うかどう
                          --! かを指定する.
                          --! * REQ_SAFETY=1の場合、スレーブから Write Response が
                          --!   帰ってきた時点で Acknowledge を返す.
                          --! * REQ_SAFETY=0の場合、スレーブに最後のデータを出力し
                          --!   た時点で Acknowledge を返す. 応答を待たないので、
                          --!   エラーが発生しても分からない.
                          in    std_logic;
        REQ_VAL         : --! @brief Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          in    std_logic_vector(VAL_BITS-1 downto 0);
        REQ_RDY         : --! @brief Request Ready Signal.
                          --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                          --! * QUEUE_SIZEの設定によっては、XFER_BUSY がアサートさ
                          --!   れていても、次のリクエストを受け付け可能な場合があ
                          --!   る
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VAL         : --! @brief Acknowledge Valid Signal.
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
                          out   std_logic_vector(VAL_BITS-1 downto 0);
        ACK_NEXT        : --! @brief Acknowledge with need Next transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=0 の場合、
                          --! この信号がアサートされる.
                          out   std_logic;
        ACK_LAST        : --! @brief Acknowledge with Last transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=1 の場合、
                          --! この信号がアサートされる.
                          out   std_logic;
        ACK_ERROR       : --! @brief Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          out   std_logic;
        ACK_STOP        : --! @brief Acknowledge with Stop operation.
                          --! トランザクションが中止された場合、この信号がアサート
                          --! される.
                          out   std_logic;
        ACK_NONE        : --! @brief Acknowledge with None Request transfer size.
                          --! REQ_SIZE=0 の Request だった場合、この信号がアサート
                          --! される.
                          out   std_logic;
        ACK_SIZE        : --! @brief Acknowledge transfer size.
                          --! 転送するバイト数を示す.
                          --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で示さ
                          --! れるバイト数分を加算/減算すると良い.
                          out   std_logic_vector(SIZE_BITS        -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transfer Status Signal.
    -------------------------------------------------------------------------------
        XFER_BUSY       : --! @brief Transfer Busy.
                          --! このモジュールが未だデータの転送中であることを示す.
                          --! * QUEUE_SIZEの設定によっては、XFER_BUSY がアサートさ
                          --!   れていても、次のリクエストを受け付け可能な場合があ
                          --!   る.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_STOP       : --! @brief Flow Stop.
                          --! 転送中止信号.
                          --! * 転送を中止する時はこの信号をアサートする.
                          --! * 一旦アサートしたら、完全に停止するまで(XFER_BUSYが
                          --!   ネゲートされるまで)、アサートしたままにしておかなけ
                          --!   ればならない.
                          --! * ただし、一度 AXI4 に発行したトランザクションは中止
                          --!   出来ない.
                          --! * FLOW_VALID=0の場合、この信号は無視される.
                          in    std_logic := '0';
        FLOW_PAUSE      : --! @brief Flow Pause.
                          --! 転送一時中断信号.
                          --! * 転送を一時中断する時はこの信号をアサートする.
                          --! * 転送を再開したい時はこの信号をネゲートする.
                          --! * ただし、一度 AXI4 に発行したトランザクションは中断
                          --!   出来ない. あくまでも、次に発行する予定のトランザク
                          --!   ションを一時的に停めるだけ.
                          --! * 例えば FIFO に格納されているデータのバイト数が、あ
                          --!   る一定の値未満の時にこの信号をアサートするようにし
                          --!   ておくと、再びある一定の値以上になってこの信号がネ
                          --!   ゲートされるまで、転送を中断しておける.
                          --! * FLOW_VALID=0の場合、この信号は無視される.
                          in    std_logic := '0';
        FLOW_LAST       : --! 最後の転送であることを示す.
                          --! * FLOW_PAUSE='0'の時のみ有効.
                          --! * 例えば FIFO に残っているデータで最後の時に、この信
                          --!   号をアサートしておけば、最後のデータを出力し終えた
                          --!   時点で、転送をする.
                          --! * FLOW_VALID=0の場合、この信号は無視される.
                          in    std_logic := '1';
        FLOW_SIZE       : --! @brief Flow Size.
                          --! 転送するバイト数を指定する.
                          --! * FLOW_PAUSE='0'の時のみ有効.
                          --! * 例えば FIFO に残っているデータの容量を入力しておく
                          --!   と、そのバイト数を越えた転送は行わない.
                          --! * FLOW_VALID=0の場合、この信号は無視される.
                          in    std_logic_vector(SIZE_BITS        -1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- Reserve Size Signals.
    -------------------------------------------------------------------------------
        RESV_VAL        : --! @brief Reserve Valid.
                          --! RESV_LAST/RESV_ERROR/RESV_SIZEが有効であることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        RESV_LAST       : --! @brief Reserve Last.
                          --! 最後の転送"する予定"である事を示すフラグ.
                          out   std_logic;
        RESV_ERROR      : --! @brief Reserve Error.
                          --! 転送"する予定"がエラーだった事を示すフラグ.
                          out   std_logic;
        RESV_SIZE       : --! @brief Reserve Size.
                          --! 転送"する予定"のバイト数を出力する.
                          out   std_logic_vector(SIZE_BITS        -1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VAL        : --! @brief Pull Valid.
                          --! PULL_LAST/PULL_ERROR/PULL_SIZEが有効であることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PULL_LAST       : --! @brief Pull Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PULL_ERROR      : --! @brief Reserve Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PULL_SIZE       : --! @brief Reserve Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(SIZE_BITS        -1 downto 0);
    -------------------------------------------------------------------------------
    -- Read Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_REN         : --! @brief Buffer Read Enable.
                          --! バッファからデータをリードすることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        BUF_DATA        : --! @brief Buffer Data.
                          --! バッファからリードしたデータを入力する.
                          in    std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
        BUF_PTR         : --! @brief Buffer Read Pointer.
                          --! 次にリードするデータのバッファの位置を出力する.
                          --! * この信号の１クロック後に、バッファからリードした
                          --!   データを BUF_DATA に入力すること.
                          out   std_logic_vector(BUF_PTR_BITS     -1 downto 0);
        BUF_RDY         : --! @brief Buffer Read Ready.
                          --! バッファにデータが用意出来ていることを示す.
                          --! * この信号がネゲートされていると、ライトデータチャネ
                          --!   ルからデータが出力されずに、再びアサートされるまで
                          --!   停止する.
                          --! * ただし、この信号はライトデータチャネルを制御するも
                          --!   ので、ライトアドレスチャネルを制御するものではない.
                          in    std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_REGISTER_WRITE_INTERFACE                                         --
-----------------------------------------------------------------------------------
component AXI4_REGISTER_WRITE_INTERFACE
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 ライトアドレスチャネルのAWADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 WRITE DATA CHANNEL DATA WIDTH :
                          --! AXI4 ライトデータチャネルのWDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびライトレスポンスチャネルの
                          --! ID信号のビット幅.
                          integer range 1 to AXI4_ID_MAX_WIDTH;
        REGS_ADDR_WIDTH : --! @brief REGISTER ADDRESS WIDTH :
                          --! レジスタアクセスインターフェースのアドレスのビット幅
                          --! を指定する.
                          integer := 32;
        REGS_DATA_WIDTH : --! @brief REGISTER DATA WIDTH :
                          --! レジスタアクセスインターフェースのデータのビット幅を
                          --! 指定する.
                          integer := 32
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        AWID            : --! @brief Write address ID.
                          --! This signal is identification tag for the write
                          --! address group of singals.
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        AWADDR          : --! @brief Write address.  
                          --! The read address gives the address of the first
                          --! transfer in a write burst transaction.
                          in    std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        AWLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          in    AXI4_ALEN_TYPE;
        AWSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          in    AXI4_ASIZE_TYPE;
        AWBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          in    AXI4_ABURST_TYPE;
        AWVALID         : --! @brief Write address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          in    std_logic;
        AWREADY         : --! @brief Write address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        WDATA           : --! @brief Write data.
                          in    std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        WSTRB           : --! @brief Write strobes.
                          --! This signal indicates which byte lanes holdvalid 
                          --! data. There is one write strobe bit for each eight
                          --! bits of the write data bus.
                          in    std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
        WLAST           : --! @brief Write last.
                          --! This signal indicates the last transfer in a write burst.
                          in    std_logic;
        WVALID          : --! @brief Write valid.
                          --! This signal indicates that valid write data and
                          --! strobes are available.
                          in    std_logic;
        WREADY          : --! @brief Write ready.
                          --! This signal indicates that the slave can accept the
                          --! write data.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        BID             : --! @brief Response ID tag.
                          --! This signal is the identification tag of write
                          --! response .
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        BRESP           : --! @brief Write response.
                          --! This signal indicates the status of the write transaction.
                          out   AXI4_RESP_TYPE;
        BVALID          : --! @brief Write response valid.
                          --! This signal indicates that the channel is signaling
                          --! a valid write response.
                          out   std_logic;
        BREADY          : --! @brief Write response ready.
                          --! This signal indicates that the master can accept a
                          --! write response.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- Register Write Interface.
    -------------------------------------------------------------------------------
        REGS_REQ        : --! @brief レジスタアクセス要求信号.
                          --! レジスタアクセス要求時にアサートされる.
                          --! REGS_ACK 信号がアサートされるまで、この信号はアサー
                          --! トされたまま.
                          out std_logic;
        REGS_ACK        : --! @brief レジスタアクセス応答信号.
                          in  std_logic;
        REGS_ERR        : --! @brief レジスタアクセスエラー信号.
                          --! エラーが発生した時にREGS_ACK信号と共にアサートする.
                          in  std_logic;
        REGS_ADDR       : --! @brief レジスタアドレス信号.
                          out std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
        REGS_BEN        : --! @brief バイトイネーブル信号.
                          out std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
        REGS_DATA       : --! @brief レジスタライトデータ出力信号.
                          out std_logic_vector(REGS_DATA_WIDTH  -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_REGISTER_READ_INTERFACE                                          --
-----------------------------------------------------------------------------------
component AXI4_REGISTER_READ_INTERFACE
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 リードアドレスチャネルのAWADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 WRITE DATA CHANNEL DATA WIDTH :
                          --! AXI4 リードデータチャネルのRDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびライトレスポンスチャネルの
                          --! ID信号のビット幅.
                          integer range 1 to AXI4_ID_MAX_WIDTH;
        REGS_ADDR_WIDTH : --! @brief REGISTER ADDRESS WIDTH :
                          --! レジスタアクセスインターフェースのアドレスのビット幅
                          --! を指定する.
                          integer := 32;
        REGS_DATA_WIDTH : --! @brief REGISTER DATA WIDTH :
                          --! レジスタアクセスインターフェースのデータのビット幅を
                          --! 指定する.
                          integer := 32
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        ARID            : --! @brief Read address ID.
                          --! This signal is identification tag for the read
                          --! address group of singals.
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        ARADDR          : --! @brief Read address.  
                          --! The read address gives the address of the first
                          --! transfer in a read burst transaction.
                          in    std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        ARLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          in    AXI4_ALEN_TYPE;
        ARSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          in    AXI4_ASIZE_TYPE;
        ARBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          in    AXI4_ABURST_TYPE;
        ARVALID         : --! @brief Read address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          in    std_logic;
        ARREADY         : --! @brief Read address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        RID             : --! @brief Read ID tag.
                          --! This signal is the identification tag for the read
                          --! data group of signals generated by the slave.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        RDATA           : --! @brief Read data.
                          out   std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        RRESP           : --! @brief Read response.
                          --! This signal indicates the status of the read transaction.
                          out   AXI4_RESP_TYPE;
        RLAST           : --! @brief Read last.
                          --! This signal indicates the last transfer in a read burst.
                          out   std_logic;
        RVALID          : --! @brief Read data valid.
                          --! This signal indicates that the channel is signaling
                          --! the required read data.
                          out   std_logic;
        RREADY          : --! @brief Read data ready.
                          --! This signal indicates that the master can accept the
                          --! read data and response information.
                          in    std_logic;
    -------------------------------------------------------------------------------
    -- Register Read Interface.
    -------------------------------------------------------------------------------
        REGS_REQ        : --! @brief レジスタアクセス要求信号.
                          --! レジスタアクセス要求時にアサートされる.
                          --! REGS_ACK 信号がアサートされるまで、この信号はアサー
                          --! トされたまま.
                          out std_logic;
        REGS_ACK        : --! @brief レジスタアクセス応答信号.
                          in  std_logic;
        REGS_ERR        : --! @brief レジスタアクセスエラー信号.
                          --! エラーが発生した時にREGS_ACK信号と共にアサートする.
                          in  std_logic;
        REGS_ADDR       : --! @brief レジスタアドレス信号.
                          out std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
        REGS_BEN        : --! @brief バイトイネーブル信号.
                          out std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
        REGS_DATA       : --! @brief レジスタライトデータ出力信号.
                          in  std_logic_vector(REGS_DATA_WIDTH  -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_REGISTER_INTERFACE                                               --
-----------------------------------------------------------------------------------
component AXI4_REGISTER_INTERFACE
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 リードアドレスチャネルのAWADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 WRITE DATA CHANNEL DATA WIDTH :
                          --! AXI4 リードデータチャネルのRDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびライトレスポンスチャネルの
                          --! ID信号のビット幅.
                          integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        REGS_ADDR_WIDTH : --! @brief REGISTER ADDRESS WIDTH :
                          --! レジスタアクセスインターフェースのアドレスのビット幅
                          --! を指定する.
                          integer := 32;
        REGS_DATA_WIDTH : --! @brief REGISTER DATA WIDTH :
                          --! レジスタアクセスインターフェースのデータのビット幅を
                          --! 指定する.
                          integer := 32
    );
    port(
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK             : --! @brief Global clock signal.  
                          in    std_logic;
        RST             : --! @brief Global asyncrounos reset signal, active HIGH.
                          in    std_logic;
        CLR             : --! @brief Global syncrounos reset signal, active HIGH.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Read Address Channel Signals.
    ------------------------------------------------------------------------------
        ARID            : --! @brief Read address ID.
                          --! This signal is identification tag for the read
                          --! address group of singals.
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        ARADDR          : --! @brief Read address.  
                          --! The read address gives the address of the first
                          --! transfer in a read burst transaction.
                          in    std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        ARLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          in    AXI4_ALEN_TYPE;
        ARSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          in    AXI4_ASIZE_TYPE;
        ARBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          in    AXI4_ABURST_TYPE;
        ARVALID         : --! @brief Read address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          in    std_logic;
        ARREADY         : --! @brief Read address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          out   std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Read Data Channel Signals.
    ------------------------------------------------------------------------------
        RID             : --! @brief Read ID tag.
                          --! This signal is the identification tag for the read
                          --! data group of signals generated by the slave.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        RDATA           : --! @brief Read data.
                          out   std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        RRESP           : --! @brief Read response.
                          --! This signal indicates the status of the read transaction.
                          out   AXI4_RESP_TYPE;
        RLAST           : --! @brief Read last.
                          --! This signal indicates the last transfer in a read burst.
                          out   std_logic;
        RVALID          : --! @brief Read data valid.
                          --! This signal indicates that the channel is signaling
                          --! the required read data.
                          out   std_logic;
        RREADY          : --! @brief Read data ready.
                          --! This signal indicates that the master can accept the
                          --! read data and response information.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Signals.
    ------------------------------------------------------------------------------
        AWID            : --! @brief Write address ID.
                          --! This signal is identification tag for the write
                          --! address group of singals.
                          in    std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        AWADDR          : --! @brief Write address.  
                          --! The read address gives the address of the first
                          --! transfer in a write burst transaction.
                          in    std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        AWLEN           : --! @brief Burst length.  
                          --! This signal indicates the exact number of transfer
                          --! in a burst.
                          in    AXI4_ALEN_TYPE;
        AWSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          in    AXI4_ASIZE_TYPE;
        AWBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          in    AXI4_ABURST_TYPE;
        AWVALID         : --! @brief Write address valid.
                          --! This signal indicates that the channel is signaling
                          --! valid read address and control infomation.
                          in    std_logic;
        AWREADY         : --! @brief Write address ready.
                          --! This signal indicates that the slave is ready to
                          --! accept and associated control signals.
                          out   std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Write Data Channel Signals.
    ------------------------------------------------------------------------------
        WDATA           : --! @brief Write data.
                          in    std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
        WSTRB           : --! @brief Write strobes.
                          --! This signal indicates which byte lanes holdvalid 
                          --! data. There is one write strobe bit for each eight
                          --! bits of the write data bus.
                          in    std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
        WLAST           : --! @brief Write last.
                          --! This signal indicates the last transfer in a write burst.
                          in    std_logic;
        WVALID          : --! @brief Write valid.
                          --! This signal indicates that valid write data and
                          --! strobes are available.
                          in    std_logic;
        WREADY          : --! @brief Write ready.
                          --! This signal indicates that the slave can accept the
                          --! write data.
                          out   std_logic;
    ------------------------------------------------------------------------------
    -- AXI4 Write Response Channel Signals.
    ------------------------------------------------------------------------------
        BID             : --! @brief Response ID tag.
                          --! This signal is the identification tag of write
                          --! response .
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        BRESP           : --! @brief Write response.
                          --! This signal indicates the status of the write transaction.
                          out   AXI4_RESP_TYPE;
        BVALID          : --! @brief Write response valid.
                          --! This signal indicates that the channel is signaling
                          --! a valid write response.
                          out   std_logic;
        BREADY          : --! @brief Write response ready.
                          --! This signal indicates that the master can accept a
                          --! write response.
                          in    std_logic;
    ------------------------------------------------------------------------------
    -- Register Interface.
    ------------------------------------------------------------------------------
        REGS_REQ        : --! @brief レジスタアクセス要求信号.
                          --! レジスタアクセス要求時にアサートされる.
                          --! REGS_ACK 信号がアサートされるまで、この信号はアサー
                          --! トされたまま.
                          out std_logic;
        REGS_WRITE      : --! @brief レジスタライト信号.
                          --! レジスタ書き込み時にアサートされる.
                          out std_logic;
        REGS_ACK        : --! @brief レジスタアクセス応答信号.
                          in  std_logic;
        REGS_ERR        : --! @brief レジスタアクセスエラー信号.
                          --! エラーが発生した時にREGS_ACK信号と共にアサートする.
                          in  std_logic;
        REGS_ADDR       : --! @brief レジスタアドレス信号.
                          out std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
        REGS_BEN        : --! @brief バイトイネーブル信号.
                          out std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
        REGS_WDATA      : --! @brief レジスタライトデータ出力信号.
                          out std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
        REGS_RDATA      : --! @brief レジスタリードデータ入力信号.
                          in  std_logic_vector(REGS_DATA_WIDTH  -1 downto 0)
    );
end component;
end AXI4_COMPONENTS;
