-----------------------------------------------------------------------------------
--!     @file    axi4_master_read_interface.vhd
--!     @brief   AXI4 Master Read Interface
--!     @version 1.8.2
--!     @date    2020/10/7
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2020 Ichiro Kawazome
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
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4 Master Read Interface
-----------------------------------------------------------------------------------
entity  AXI4_MASTER_READ_INTERFACE is
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
                          integer := 4;
        VAL_BITS        : --! @brief VALID BITS :
                          --! REQ_VAL、ACK_VAL のビット数を指定する.
                          integer := 1;
        REQ_SIZE_BITS   : --! @brief REQUEST SIZE BITS:
                          --! REQ_SIZE信号のビット数を指定する.
                          integer := 32;
        REQ_SIZE_VALID  : --! @brief REQUEST SIZE VALID :
                          --! REQ_SIZE信号を有効にするかどうかを指定する.
                          --! * REQ_SIZE_VALID=0で無効.
                          --! * REQ_SIZE_VALID=1で有効.
                          integer range 0 to 1 :=  1;
        FLOW_VALID      : --! @brief FLOW VALID :
                          --! FLOW_PAUSE、FLOW_STOP、FLOW_SIZE、FLOW_LAST信号を有効
                          --! にするかどうかを指定する.
                          --! * FLOW_VALID=0で無効.
                          --! * FLOW_VALID=1で有効.
                          integer range 0 to 1 := 1;
        BUF_DATA_WIDTH  : --! @brief BUFFER DATA WIDTH :
                          --! バッファのビット幅を指定する.
                          integer := 32;
        BUF_PTR_BITS    : --! @brief BUFFER POINTER BITS :
                          --! バッファポインタなどを表す信号のビット数を指定する.
                          integer := 8;
        ALIGNMENT_BITS  : --! @brief ALIGNMENT BITS :
                          --! アライメントサイズのビット数を指定する.
                          integer := 8;
        XFER_SIZE_BITS  : --! @brief Transfer Size Bits :
                          --! １回の転送バイト数入出力信号(ACK_SIZE/FLOW_SIZE/
                          --! PULL_SIZE/PUSH_SIZEなど)のビット幅を指定する.
                          integer := 12;
        XFER_MIN_SIZE   : --! @brief TRANSFER MINIMUM SIZE :
                          --! 一回の転送サイズの最小バイト数を２のべき乗で指定する.
                          integer := 4;
        XFER_MAX_SIZE   : --! @brief TRANSFER MAXIMUM SIZE :
                          --! 一回の転送サイズの最大バイト数を２のべき乗で指定する.
                          integer := 4;
        QUEUE_SIZE      : --! @brief TRANSACTION QUEUE SIZE :
                          --! キューの大きさを指定する.
                          integer := 1;
        RDATA_REGS      : --! @brief RDATA REGISTER TYPE :
                          --! RDATA/RRESP/RLAST/RVALID の入力をどうするか指定する.
                          --! * RDATA_REGS=0 スルー入力(レジスタは通さない).
                          --! * RDATA_REGS=1 １段だけレジスタを通す. 
                          --!   ただしバースト転送時には１サイクル毎にウェイトが入る.
                          --! * RDATA_REGS=2 ２段のレジスタを通す.
                          --! * RDATA_REGS=3 ３段のレジスタを通す.
                          --!   このモードの場合、必ずRDATA/RRESPは一つのレジスタ
                          --!   で受けるので外部インターフェース向き.
                          integer := 0;
        ACK_REGS        : --! @brief COMMAND ACKNOWLEDGE SIGNALS REGSITERED OUT :
                          --! Command Acknowledge Signals の出力をレジスタ出力に
                          --! するか否かを指定する.
                          --! * ACK_REGS=0で組み合わせ出力.
                          --! * ACK_REGS=1でレジスタ出力.
                          integer range 0 to 1 := 0
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
                          out   std_logic_vector(AXI4_ALEN_WIDTH  -1 downto 0);
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
                          out   std_logic_vector(AXI4_ALOCK_WIDTH -1 downto 0);
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
                          in    std_logic_vector(AXI4_ALOCK_WIDTH -1 downto 0);
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
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
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
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transfer Status Signal.
    -------------------------------------------------------------------------------
        XFER_BUSY       : --! @brief Transfer Busy.
                          --! このモジュールが未だデータの転送中であることを示す.
                          --! * QUEUE_SIZEの設定によっては、XFER_BUSY がアサートさ
                          --!   れていても、次のリクエストを受け付け可能な場合があ
                          --!   る.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        XFER_ERROR      : --! @brief Transfer Error.
                          --! データの転送中にエラーが発生した事を示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        XFER_DONE       : --! @brief Transfer Done.
                          --! このモジュールが未だデータの転送中かつ、次のクロック
                          --! で XFER_BUSY がネゲートされる事を示す.
                          --! * ただし、XFER_BUSY のネゲート前に 必ずしもこの信号が
                          --!   アサートされるわけでは無い.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
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
                          in    std_logic_vector(XFER_SIZE_BITS   -1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- Push Reserve Size Signals.
    -------------------------------------------------------------------------------
        PUSH_RSV_VAL    : --! @brief Push Reserve Valid.
                          --! PUSH_RSV_LAST/PUSH_RSV_ERROR/PUSH_RSV_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS -1 downto 0);
        PUSH_RSV_LAST   : --! @brief Push Reserve Last.
                          --! 最後の転送"する予定"である事を示すフラグ.
                          out   std_logic;
        PUSH_RSV_ERROR  : --! @brief Push Reserve Error.
                          --! 転送"する予定"がエラーだった事を示すフラグ.
                          out   std_logic;
        PUSH_RSV_SIZE   : --! @brief Push Reserve Size.
                          --! 転送"する予定"のバイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Final Size Signals.
    -------------------------------------------------------------------------------
        PUSH_FIN_VAL    : --! @brief Push Final Valid.
                          --! PUSH_FIN_LAST/PUSH_FIN_ERROR/PUSH_FIN_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PUSH_FIN_LAST   : --! @brief Push Final Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PUSH_FIN_ERROR  : --! @brief Push Final Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PUSH_FIN_SIZE   : --! @brief Push Final Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Buffer Size Signals.
    -------------------------------------------------------------------------------
        PUSH_BUF_RESET  : --! @brief Push Buffer Counter Reset.
                          --! バッファのカウンタをリセットする信号.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PUSH_BUF_VAL    : --! @brief Push Buffer Valid.
                          --! PUSH_BUF_LAST/PUSH_BUF_ERROR/PUSH_BUF_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PUSH_BUF_LAST   : --! @brief Push Buffer Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PUSH_BUF_ERROR  : --! @brief Push Buffer Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PUSH_BUF_SIZE   : --! @brief Push Buffer Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
        PUSH_BUF_RDY    : --! @brief Push Buffer Ready.
                          --! バッファにデータを書き込み可能な事をを示す.
                          in    std_logic_vector(VAL_BITS         -1 downto 0);
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
                          out   std_logic_vector(BUF_PTR_BITS     -1 downto 0)
    );
end AXI4_MASTER_READ_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     PIPEWORK.COMPONENTS.QUEUE_REGISTER;
use     PIPEWORK.COMPONENTS.QUEUE_RECEIVER;
use     PIPEWORK.COMPONENTS.POOL_INTAKE_PORT;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_TRANSFER_QUEUE;
architecture RTL of AXI4_MASTER_READ_INTERFACE is
    -------------------------------------------------------------------------------
    -- データバスのバイト数の２のべき乗値を計算する.
    -------------------------------------------------------------------------------
    function CALC_DATA_SIZE(WIDTH:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**(value+3) < WIDTH) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    constant AXI4_DATA_SIZE     : integer := CALC_DATA_SIZE(AXI4_DATA_WIDTH);
    constant BUF_DATA_SIZE      : integer := CALC_DATA_SIZE( BUF_DATA_WIDTH);
    constant ALIGNMENT_SIZE     : integer := CALC_DATA_SIZE(ALIGNMENT_BITS );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_req_addr      : std_logic_vector(AXI4_ADDR_WIDTH-1 downto 0);
    signal   xfer_req_size      : std_logic_vector(XFER_MAX_SIZE     downto 0);
    signal   xfer_req_alen      : std_logic_vector(AXI4_ALEN_WIDTH-1 downto 0);
    signal   xfer_req_select    : std_logic_vector(VAL_BITS       -1 downto 0);
    signal   xfer_req_ptr       : std_logic_vector(BUF_PTR_BITS   -1 downto 0);
    signal   xfer_req_valid     : std_logic;
    signal   xfer_req_ready     : std_logic;
    signal   xfer_req_next      : std_logic;
    signal   xfer_req_last      : std_logic;
    signal   xfer_req_first     : std_logic;
    signal   xfer_req_safety    : std_logic;
    signal   xfer_req_noack     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_ack_valid     : std_logic;
    signal   xfer_ack_size      : std_logic_vector(XFER_MAX_SIZE  downto 0);
    signal   xfer_ack_next      : std_logic;
    signal   xfer_ack_last      : std_logic;
    signal   xfer_ack_error     : std_logic;
    signal   xfer_run_busy      : std_logic_vector(VAL_BITS    -1 downto 0);
    signal   xfer_safety        : std_logic;
    signal   xfer_noack         : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_start         : std_logic;
    signal   xfer_sel_valid     : std_logic_vector(VAL_BITS-1 downto 0);
    signal   xfer_sel_busy      : std_logic_vector(VAL_BITS-1 downto 0);
    signal   xfer_sel_done      : std_logic_vector(VAL_BITS-1 downto 0);
    signal   xfer_sel_error     : std_logic_vector(VAL_BITS-1 downto 0);
    signal   xfer_res_error     : std_logic_vector(VAL_BITS-1 downto 0);
    signal   xfer_reg_error     : std_logic_vector(VAL_BITS-1 downto 0);
    constant SEL_ALL0           : std_logic_vector(VAL_BITS-1 downto 0) := (others => '0');
    constant SEL_ALL1           : std_logic_vector(VAL_BITS-1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   req_queue_addr     : std_logic_vector(AXI4_DATA_SIZE    downto 0);
    signal   req_queue_size     : std_logic_vector(XFER_MAX_SIZE     downto 0);
    signal   req_queue_ptr      : std_logic_vector(BUF_PTR_BITS   -1 downto 0);
    signal   req_queue_alen     : std_logic_vector(AXI4_ALEN_WIDTH-1 downto 0);
    signal   req_queue_next     : std_logic;
    signal   req_queue_last     : std_logic;
    signal   req_queue_first    : std_logic;
    signal   req_queue_safety   : std_logic;
    signal   req_queue_noack    : std_logic;
    signal   req_queue_empty    : std_logic;
    signal   req_queue_valid    : std_logic;
    signal   req_queue_ready    : std_logic;
    signal   req_queue_select   : std_logic_vector(VAL_BITS-1 downto 0);
    signal   req_queue_busy     : std_logic_vector(VAL_BITS-1 downto 0);
    signal   req_queue_done     : std_logic_vector(VAL_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant xfer_beat_sel      : std_logic_vector(AXI4_DATA_SIZE downto AXI4_DATA_SIZE) := "1";
    signal   xfer_beat_chop     : std_logic;
    signal   xfer_beat_last     : std_logic;
    signal   xfer_beat_size     : std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   read_data          : std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
    signal   read_data_ben      : std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
    signal   read_data_resp     : std_logic_vector(AXI4_RESP_WIDTH  -1 downto 0);
    signal   read_data_last     : std_logic;
    signal   read_data_valid    : std_logic;
    signal   read_data_ready    : std_logic;
    signal   read_data_error    : std_logic;
    signal   response_error     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   outlet_valid       : std_logic_vector(VAL_BITS         -1 downto 0);
    signal   outlet_error       : std_logic;
    signal   outlet_last        : std_logic;
    signal   outlet_xfer_done   : std_logic;
    signal   outlet_size        : std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    signal   outlet_ready       : std_logic;
    constant port_enable        : std_logic := '1';
    signal   port_busy          : std_logic;
    signal   port_done          : std_logic;
    signal   port_ready_or_done : boolean;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    type     STATE_TYPE        is ( IDLE, WAIT_RFIRST, WAIT_RLAST, TURN_AR );
    signal   curr_state         : STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- AXI4 Read Address Channel Controller.
    -------------------------------------------------------------------------------
    AR: AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER     -- 
        generic map (                              -- 
            VAL_BITS        => VAL_BITS          , --
            DATA_SIZE       => AXI4_DATA_SIZE    , --
            ADDR_BITS       => AXI4_ADDR_WIDTH   , --
            ALEN_BITS       => AXI4_ALEN_WIDTH   , --
            REQ_SIZE_BITS   => REQ_SIZE_BITS     , --
            REQ_SIZE_VALID  => REQ_SIZE_VALID    , --
            FLOW_VALID      => FLOW_VALID        , --
            XFER_SIZE_BITS  => XFER_SIZE_BITS    , --
            XFER_MIN_SIZE   => XFER_MIN_SIZE     , --
            XFER_MAX_SIZE   => XFER_MAX_SIZE     , --
            ACK_REGS        => ACK_REGS            -- 
        )                                          -- 
        port map (                                 -- 
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK             => CLK               , -- In  :
            RST             => RST               , -- In  :
            CLR             => CLR               , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Address Channel Signals.
        --------------------------------------------------------------------------
            AADDR           => ARADDR            , -- Out :
            ASIZE           => ARSIZE            , -- Out :
            ALEN            => ARLEN             , -- Out :
            AVALID          => ARVALID           , -- Out :
            AREADY          => ARREADY           , -- In  :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_ADDR        => REQ_ADDR          , -- In  :
            REQ_SIZE        => REQ_SIZE          , -- In  :
            REQ_FIRST       => REQ_FIRST         , -- In  :
            REQ_LAST        => REQ_LAST          , -- In  :
            REQ_SPECULATIVE => REQ_SPECULATIVE   , -- In  :
            REQ_SAFETY      => REQ_SAFETY        , -- In  :
            REQ_VAL         => REQ_VAL           , -- In  :
            REQ_RDY         => REQ_RDY           , -- Out :
        ---------------------------------------------------------------------------
        -- Command Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL         => ACK_VAL           , -- Out :
            ACK_NEXT        => ACK_NEXT          , -- Out :
            ACK_LAST        => ACK_LAST          , -- Out :
            ACK_ERROR       => ACK_ERROR         , -- Out :
            ACK_STOP        => ACK_STOP          , -- Out :
            ACK_NONE        => ACK_NONE          , -- Out :
            ACK_SIZE        => ACK_SIZE          , -- Out :
        ---------------------------------------------------------------------------
        -- Transfer Control Signals.
        ---------------------------------------------------------------------------
            FLOW_PAUSE      => FLOW_PAUSE        , -- In  :
            FLOW_STOP       => FLOW_STOP         , -- In  :
            FLOW_LAST       => FLOW_LAST         , -- In  :
            FLOW_SIZE       => FLOW_SIZE         , -- In  :
        ---------------------------------------------------------------------------
        -- Transfer Size Select Signals.
        ---------------------------------------------------------------------------
            XFER_SIZE_SEL   => XFER_SIZE_SEL     , -- In  :
        ---------------------------------------------------------------------------
        -- Transfer Request Signals. 
        ---------------------------------------------------------------------------
            XFER_REQ_ADDR   => xfer_req_addr     , -- Out : 
            XFER_REQ_SIZE   => xfer_req_size     , -- Out :
            XFER_REQ_ALEN   => xfer_req_alen     , -- Out :
            XFER_REQ_FIRST  => xfer_req_first    , -- Out :
            XFER_REQ_LAST   => xfer_req_last     , -- Out :
            XFER_REQ_NEXT   => xfer_req_next     , -- Out :
            XFER_REQ_SAFETY => xfer_req_safety   , -- Out :
            XFER_REQ_NOACK  => xfer_req_noack    , -- Out :
            XFER_REQ_SEL    => xfer_req_select   , -- Out :
            XFER_REQ_VAL    => xfer_req_valid    , -- Out :
            XFER_REQ_RDY    => xfer_req_ready    , -- In  :
        ---------------------------------------------------------------------------
        -- Transfer Response Signals.
        ---------------------------------------------------------------------------
            XFER_ACK_SIZE   => xfer_ack_size     , -- In  :
            XFER_ACK_VAL    => xfer_ack_valid    , -- In  :
            XFER_ACK_NEXT   => xfer_ack_next     , -- In  :
            XFER_ACK_LAST   => xfer_ack_last     , -- In  :
            XFER_ACK_ERR    => xfer_ack_error    , -- In  :
        ---------------------------------------------------------------------------
        -- Transfer Status Signals.
        ---------------------------------------------------------------------------
            XFER_BUSY       => xfer_sel_busy     , -- In  :
            XFER_DONE       => xfer_sel_done     , -- In  :
            XFER_ERROR      => xfer_sel_error      -- In  :
        );                                         -- 
    -------------------------------------------------------------------------------
    -- AXI4 Read Address Channel Signals Output.
    -------------------------------------------------------------------------------
    ARBURST  <= REQ_BURST;
    ARLOCK   <= REQ_LOCK;
    ARCACHE  <= REQ_CACHE;
    ARPROT   <= REQ_PROT;
    ARQOS    <= REQ_QOS;
    ARREGION <= REQ_REGION;
    ARID     <= REQ_ID;
    -------------------------------------------------------------------------------
    -- xfer_req_ptr  : バッファのライト開始ポインタ
    -------------------------------------------------------------------------------
    process (xfer_req_addr, REQ_BUF_PTR) begin
        for i in xfer_req_ptr'range loop
            if (i < ALIGNMENT_SIZE) then
                xfer_req_ptr(i) <= xfer_req_addr(i);
            else
                xfer_req_ptr(i) <= REQ_BUF_PTR(i);
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- Transfer Request Queue.
    -------------------------------------------------------------------------------
    REQ_QUEUE: AXI4_MASTER_TRANSFER_QUEUE              -- 
        generic map (                                  -- 
            SEL_BITS        => VAL_BITS              , --
            SIZE_BITS       => req_queue_size'length , --
            ADDR_BITS       => req_queue_addr'length , --
            ALEN_BITS       => req_queue_alen'length , --
            PTR_BITS        => req_queue_ptr 'length , --
            QUEUE_SIZE      => QUEUE_SIZE              --
        )                                              --
        port map (                                     --
            CLK             => CLK                   , -- In  :
            RST             => RST                   , -- In  :
            CLR             => CLR                   , -- In  :
            I_VALID         => xfer_req_valid        , -- In  :
            I_SEL           => xfer_req_select       , -- In  :
            I_SIZE          => xfer_req_size         , -- In  :
            I_ADDR          => xfer_req_addr(req_queue_addr'range), -- In  :
            I_ALEN          => xfer_req_alen         , -- In  :
            I_PTR           => xfer_req_ptr          , -- In  :
            I_NEXT          => xfer_req_next         , -- In  :
            I_LAST          => xfer_req_last         , -- In  :
            I_FIRST         => xfer_req_first        , -- In  :
            I_SAFETY        => xfer_req_safety       , -- In  :
            I_NOACK         => xfer_req_noack        , -- In  :
            I_READY         => xfer_req_ready        , -- Out :
            Q_VALID         => req_queue_valid       , -- Out :
            Q_SEL           => req_queue_select      , -- Out :
            Q_SIZE          => req_queue_size        , -- Out :
            Q_ADDR          => req_queue_addr        , -- Out :
            Q_ALEN          => req_queue_alen        , -- Out :
            Q_PTR           => req_queue_ptr         , -- Out :
            Q_NEXT          => req_queue_next        , -- Out :
            Q_LAST          => req_queue_last        , -- Out :
            Q_FIRST         => req_queue_first       , -- Out :
            Q_SAFETY        => req_queue_safety      , -- Out :
            Q_NOACK         => req_queue_noack       , -- Out :
            Q_READY         => req_queue_ready       , -- In  :
            BUSY            => req_queue_busy        , -- Out :
            DONE            => req_queue_done        , -- Out :
            EMPTY           => req_queue_empty         -- Out :
        );                                             -- 
    -------------------------------------------------------------------------------
    -- read_data_ben : AXI4 Read Data Channel はバイトイネーブル信号が無いので、
    --                 ここで作っておく.
    -------------------------------------------------------------------------------
    BEN: CHOPPER                                       -- 
        generic map (                                  -- 
            BURST           => 1                     , --           
            MIN_PIECE       => AXI4_DATA_SIZE        , -- 
            MAX_PIECE       => AXI4_DATA_SIZE        , -- 
            MAX_SIZE        => XFER_MAX_SIZE         , -- 
            ADDR_BITS       => req_queue_addr'length , -- 
            SIZE_BITS       => req_queue_size'length , -- 
            COUNT_BITS      => 1                     , -- 
            PSIZE_BITS      => xfer_beat_size'length , -- 
            GEN_VALID       => 1                       -- 
        )                                              -- 
        port map (                                     -- 
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK                   , -- In  :
            RST             => RST                   , -- In  :
            CLR             => CLR                   , -- In  :
        ---------------------------------------------------------------------------
        -- 各種初期値
        ---------------------------------------------------------------------------
            ADDR            => req_queue_addr        , -- In  :
            SIZE            => req_queue_size        , -- In  :
            SEL             => xfer_beat_sel         , -- In  :
            LOAD            => xfer_start            , -- In  :
        ---------------------------------------------------------------------------
        -- 制御信号
        ---------------------------------------------------------------------------
            CHOP            => xfer_beat_chop        , -- In  :
        ---------------------------------------------------------------------------
        -- ピースカウンタ/フラグ出力
        ---------------------------------------------------------------------------
            COUNT           => open                  , -- Out :
            NONE            => open                  , -- Out :
            LAST            => xfer_beat_last        , -- Out :
            NEXT_NONE       => open                  , -- Out :
            NEXT_LAST       => open                  , -- Out :
        ---------------------------------------------------------------------------
        -- １ワードのバイト数
        ---------------------------------------------------------------------------
            PSIZE           => xfer_beat_size        , -- Out :
            NEXT_PSIZE      => open                  , -- Out :
        ---------------------------------------------------------------------------
        -- バイトイネーブル信号
        ---------------------------------------------------------------------------
            VALID           => read_data_ben         , -- Out :
            NEXT_VALID      => open                    -- Out :
        );                                             -- 
    -------------------------------------------------------------------------------
    -- curr_state     : 応答側の状態遷移
    -- xfer_ack_size  : Transfer Request Queue から取り出したサイズ情報を保持.
    -- xfer_ack_next  : Transfer Request Queue から取り出したNEXTを保持.
    -- xfer_ack_last  : Transfer Request Queue から取り出したLASTを保持.
    -- xfer_run_busy  : Transfer Request Queue から取り出した選択情報を保持.
    -- xfer_safety    : Transfer Request Queue から取り出したSAFETYを保持.
    -- xfer_noack     : Transfer Request Queue から取り出したNOACKを保持.
    -------------------------------------------------------------------------------
    ACK_FSM: process(CLK, RST) begin
        if (RST = '1') then
                curr_state    <= IDLE;
                xfer_ack_size <= (others => '0');
                xfer_ack_next <= '0';
                xfer_ack_last <= '0';
                xfer_run_busy <= (others => '0');
                xfer_safety   <= '0';
                xfer_noack    <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state    <= IDLE;
                xfer_ack_size <= (others => '0');
                xfer_ack_next <= '0';
                xfer_ack_last <= '0';
                xfer_run_busy <= (others => '0');
                xfer_safety   <= '0';
                xfer_noack    <= '0';
            else
                case curr_state is
                    ---------------------------------------------------------------
                    -- Transfer Request Queue から Request を取り出す.
                    ---------------------------------------------------------------
                    when IDLE        =>
                        if (req_queue_valid = '1') then
                            if (req_queue_noack = '0') then
                                xfer_ack_size <= req_queue_size;
                                xfer_ack_next <= req_queue_next;
                                xfer_ack_last <= req_queue_last;
                            else
                                xfer_ack_size <= (others => '0');
                                xfer_ack_next <= '0';
                                xfer_ack_last <= '0';
                            end if;
                            xfer_run_busy <= req_queue_select;
                            xfer_safety   <= req_queue_safety;
                            xfer_noack    <= req_queue_noack;
                            curr_state    <= WAIT_RFIRST;
                        else
                            xfer_run_busy <= (others => '0');
                            curr_state    <= IDLE;
                        end if;
                    ---------------------------------------------------------------
                    -- AXI4 Read Data Channel から最初の RVALID が来るのを待つ.
                    ---------------------------------------------------------------
                    when WAIT_RFIRST =>
                        if    (read_data_valid = '1' and read_data_ready = '1' and read_data_last = '1') then
                            curr_state <= TURN_AR;
                        elsif (read_data_valid = '1' and read_data_ready = '1' and read_data_last = '0') then
                            curr_state <= WAIT_RLAST;
                        else
                            curr_state <= WAIT_RFIRST;
                        end if;
                    ---------------------------------------------------------------
                    -- AXI4 Read Data Channel から最後の RVALID が来るのを待つ.
                    ---------------------------------------------------------------
                    when WAIT_RLAST  =>
                        if    (read_data_valid = '1' and read_data_ready = '1' and read_data_last = '1') then
                            curr_state <= TURN_AR;
                        else
                            curr_state <= WAIT_RLAST;
                        end if;
                    ---------------------------------------------------------------
                    -- INTAKE_PORTにデータが残っていないことを確認してから IDLE に戻る.
                    ---------------------------------------------------------------
                    when TURN_AR     =>
                        if (port_ready_or_done) then
                            xfer_ack_size <= (others => '0');
                            xfer_ack_next <= '0';
                            xfer_ack_last <= '0';
                            xfer_run_busy <= (others => '0');
                            xfer_safety   <= '0';
                            xfer_noack    <= '0';
                            curr_state    <= IDLE;
                        else
                            curr_state    <= TURN_AR;
                        end if;
                    ---------------------------------------------------------------
                    -- 念のため.
                    ---------------------------------------------------------------
                    when others      =>
                            curr_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- xfer_sel_valid  : req_queue_select を データ転送中の間保持しておく. ただし、
    --                   VAL_BIT=0 の場合は常に"1"にしておいて回路を簡略化する.
    -------------------------------------------------------------------------------
    xfer_sel_valid  <= xfer_run_busy when (VAL_BITS > 1) else (others => '1');
    -------------------------------------------------------------------------------
    -- xfer_sel_busy   : データ転送中である事を示すフラグ.
    -- xfer_sel_done   : 次のクロックで XFER_BUSY がネゲートされることを示すフラグ.
    --                   このモジュールでは、XFER_BUSY がネゲートする前に 必ずしも 
    --                   XFER_DONE がアサートされるわけでは無い.
    --                   全てのデータリードが終了した後で、最後のデータを出力する時
    --                   にのみ XFER_DONE はアサートされる.
    -------------------------------------------------------------------------------
    process (curr_state, port_ready_or_done,
             req_queue_busy, req_queue_done, xfer_run_busy)
        variable req_queue_empty : boolean;
        variable xfer_run_done   : boolean;
    begin
        xfer_run_done := (curr_state = TURN_AR and port_ready_or_done);
        for i in 0 to VAL_BITS-1 loop
            req_queue_empty := not (req_queue_busy(i) = '1' and req_queue_done(i) = '0');
            if (xfer_run_busy(i) = '1' and req_queue_empty and xfer_run_done) then
                xfer_sel_done(i) <= '1';
            else
                xfer_sel_done(i) <= '0';
            end if;
            if (xfer_run_busy(i) = '1' or req_queue_busy(i) = '1') then
                xfer_sel_busy(i) <= '1';
            else
                xfer_sel_busy(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- xfer_reg_error : データ転送中にエラーが発生した事を xfer_sel_busy = '1' の間
    --                  保持しておくためのレジスタ.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                xfer_reg_error <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                xfer_reg_error <= (others => '0');
            else
                for i in 0 to VAL_BITS-1 loop
                    if    (xfer_sel_busy(i) = '0' or xfer_sel_done(i) = '1') then
                        xfer_reg_error(i) <= '0';
                    elsif (xfer_res_error(i) = '1') then
                        xfer_reg_error(i) <= '1';
                    end if;
                end loop;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- xfer_sel_error : データ転送中にエラーが発生した事を示すフラグ.
    -------------------------------------------------------------------------------
    xfer_sel_error <= (xfer_res_error or xfer_reg_error) and xfer_sel_busy;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    XFER_BUSY  <= xfer_sel_busy;
    XFER_DONE  <= xfer_sel_done;
    XFER_ERROR <= xfer_sel_error;
    -------------------------------------------------------------------------------
    -- req_queue_ready : Transfer Request Queue から情報を取り出すための信号.
    -------------------------------------------------------------------------------
    req_queue_ready <= '1' when (curr_state = IDLE) else '0';
    -------------------------------------------------------------------------------
    -- xfer_start      : この信号がトリガーとなっていろいろと処理を開始する.
    -------------------------------------------------------------------------------
    xfer_start      <= '1' when (curr_state = IDLE and req_queue_valid = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_beat_chop  : バイトイネーブル信号生成用のトリガー信号.
    -------------------------------------------------------------------------------
    xfer_beat_chop  <= '1' when (read_data_valid = '1' and read_data_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_ack_valid  : 
    -------------------------------------------------------------------------------
    xfer_ack_valid  <= '1' when (xfer_noack = '0') and 
                                ((xfer_safety = '0' and curr_state = WAIT_RFIRST                ) or
                                 (xfer_safety = '1' and curr_state = WAIT_RFIRST and read_data_last = '1') or
                                 (xfer_safety = '1' and curr_state = WAIT_RLAST  and read_data_last = '1')) and
                                (read_data_valid = '1' and read_data_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_ack_error  : 
    -------------------------------------------------------------------------------
    xfer_ack_error  <= '1' when (xfer_noack = '0') and 
                                (read_data_error = '1' or response_error = '1') else '0';
    -------------------------------------------------------------------------------
    -- response_error  : 
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                response_error <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or xfer_start = '1') then 
                response_error <= '0';
            elsif (read_data_error = '1') then
                response_error <= '1';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- xfer_res_error : データ転送中にエラーが発生したことを示すフラグ.
    -------------------------------------------------------------------------------
    xfer_res_error <= xfer_sel_valid when (read_data_ready = '1') and
                                          (read_data_valid = '1') and
                                          (read_data_error = '1') else SEL_ALL0;
    -------------------------------------------------------------------------------
    -- AXI4 Read Data Channel を一度バッファで受ける
    -------------------------------------------------------------------------------
    -- read_data       : RDATA  を一度バッファで受けた信号
    -- read_data_valid : RVALID を一度バッファで受けた信号
    -- read_data_last  : RLAST  を一度バッファで受けた信号
    -- read_data_resp  : RRESP  を一度バッファで受けた信号
    -- read_data_error : RRESP をデコードしてエラーを示していたことを示す信号
    -- RREADY          : AXI4 Read Data Channel の レディ信号出力
    -------------------------------------------------------------------------------
    RDATA_BUF: block
        constant DATA_LO     :  integer := 0;
        constant DATA_HI     :  integer := DATA_LO + AXI4_DATA_WIDTH-1;
        constant RESP_LO     :  integer := DATA_HI + 1;
        constant RESP_HI     :  integer := RESP_LO + AXI4_RESP_WIDTH-1;
        constant LAST_POS    :  integer := RESP_HI + 1;
        constant WORD_LO     :  integer := 0;
        constant WORD_HI     :  integer := LAST_POS;
        signal   i_word      :  std_logic_vector(WORD_HI downto WORD_LO);
        signal   q_word      :  std_logic_vector(WORD_HI downto WORD_LO);
        signal   enable      :  std_logic;
        signal   i_valid     :  std_logic;
        signal   i_ready     :  std_logic;
        signal   next_enable :  std_logic;
        signal   curr_enable :  std_logic;
    begin
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        next_enable <= '1' when (curr_enable = '0' and xfer_start = '1') or
                                (curr_enable = '1' and not (RVALID = '1' and RLAST = '1' and i_ready = '1')) else '0';
        process (CLK, RST) begin
            if     (RST = '1') then curr_enable <= '0';
            elsif  (CLK'event and CLK = '1') then
                if (CLR = '1') then curr_enable <= '0';
                else                curr_enable <= next_enable;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- RXXXX を i_word にセット
        ---------------------------------------------------------------------------
        i_word(DATA_HI downto DATA_LO) <= RDATA;
        i_word(RESP_HI downto RESP_LO) <= RRESP;
        i_word(LAST_POS)               <= RLAST;
        ---------------------------------------------------------------------------
        -- 入力レジスタ(QUEUE_REGISTERを使う場合)
        ---------------------------------------------------------------------------
        USE_REGS: if (RDATA_REGS < 3) generate
            signal  q_valid     :  std_logic_vector(RDATA_REGS downto 0);
        begin 
            Q: QUEUE_REGISTER                        -- 
                generic map (                        -- 
                    QUEUE_SIZE  => RDATA_REGS      , -- 
                    DATA_BITS   => i_word'length   , -- 
                    LOWPOWER    => 0                 -- 
                )                                    -- 
                port map (                           -- 
                -----------------------------------------------------------------------
                -- クロック&リセット信号
                -----------------------------------------------------------------------
                    CLK         => CLK             , -- In  :
                    RST         => RST             , -- In  :
                    CLR         => CLR             , -- In  :
                -----------------------------------------------------------------------
                -- 入力側
                -----------------------------------------------------------------------
                    I_DATA      => i_word          , -- In  :
                    I_VAL       => i_valid         , -- In  :
                    I_RDY       => i_ready         , -- Out :
                -----------------------------------------------------------------------
                -- 出力側
                -----------------------------------------------------------------------
                    O_DATA      => open            , -- Out :
                    O_VAL       => open            , -- Out :
                    Q_DATA      => q_word          , -- Out :
                    Q_VAL       => q_valid         , -- Out :
                    Q_RDY       => read_data_ready   -- In  :
                );                                   --
            i_valid <= '1' when (curr_enable = '1' and RVALID  = '1') else '0';
            RREADY  <= '1' when (curr_enable = '1' and i_ready = '1') else '0';
            read_data_valid <= q_valid(0);
        end generate;
        ---------------------------------------------------------------------------
        -- 入力レジスタ(QUEUE_RECEIVERを使う場合)
        ---------------------------------------------------------------------------
        USE_RECV: if (RDATA_REGS >= 3) generate      -- 
            Q: QUEUE_RECEIVER                        -- 
                generic map (                        -- 
                    QUEUE_SIZE  => RDATA_REGS-1    , -- 
                    DATA_BITS   => i_word'length     -- 
                )                                    -- 
                port map (                           -- 
                -----------------------------------------------------------------------
                -- クロック&リセット信号
                -----------------------------------------------------------------------
                    CLK         => CLK             , -- In  :
                    RST         => RST             , -- In  :
                    CLR         => CLR             , -- In  :
                -----------------------------------------------------------------------
                -- 入力側
                -----------------------------------------------------------------------
                    I_ENABLE    => next_enable     , -- In  :
                    I_DATA      => i_word          , -- In  :
                    I_VAL       => i_valid         , -- In  :
                    I_RDY       => i_ready         , -- Out :
                -----------------------------------------------------------------------
                -- 出力側
                -----------------------------------------------------------------------
                    O_DATA      => q_word          , -- Out :
                    O_VAL       => read_data_valid , -- Out :
                    O_RDY       => read_data_ready   -- In  :
                );                                   --
            i_valid <= RVALID;                       -- 
            RREADY  <= i_ready;                      -- 
        end generate;                                -- 
        ---------------------------------------------------------------------------
        -- q_word を read_data_xxxx にセット
        ---------------------------------------------------------------------------
        read_data       <= q_word(DATA_HI downto DATA_LO);
        read_data_resp  <= q_word(RESP_HI downto RESP_LO);
        read_data_last  <= q_word(LAST_POS);
        read_data_error <= '1' when (read_data_resp = AXI4_RESP_SLVERR) or
                                    (read_data_resp = AXI4_RESP_DECERR) else '0';
    end block;
    -------------------------------------------------------------------------------
    -- 入力ポート : 外部のリードバッファに書き込む前に、一旦このモジュールで受けて、
    --              バス幅の変換やバイトレーンの調整を行う.
    -------------------------------------------------------------------------------
    INTAKE_PORT: POOL_INTAKE_PORT                    -- 
        generic map (                                --
            UNIT_BITS       => 8                   , -- 
            WORD_BITS       => ALIGNMENT_BITS      , --
            PORT_DATA_BITS  => AXI4_DATA_WIDTH     , --
            POOL_DATA_BITS  => BUF_DATA_WIDTH      , -- 
            SEL_BITS        => VAL_BITS            , -- 
            SIZE_BITS       => XFER_SIZE_BITS      , --
            PTR_BITS        => BUF_PTR_BITS        , -- 
            QUEUE_SIZE      => 0                     -- 
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In :
            RST             => RST                 , -- In :
            CLR             => CLR                 , -- In :
        ---------------------------------------------------------------------------
        -- 各種制御信号
        ---------------------------------------------------------------------------
            START           => xfer_start          , -- In :
            START_PTR       => req_queue_ptr       , -- In :
            XFER_LAST       => req_queue_last      , -- In :
            XFER_SEL        => req_queue_select    , -- In :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            PORT_ENABLE     => port_enable         , -- In :
            PORT_DATA       => read_data           , -- In :
            PORT_LAST       => read_data_last      , -- In :
            PORT_DVAL       => read_data_ben       , -- In :
            PORT_ERROR      => read_data_error     , -- In :
            PORT_VAL        => read_data_valid     , -- In :
            PORT_RDY        => read_data_ready     , -- Out:
        ---------------------------------------------------------------------------
        -- Push Size Signals.
        ---------------------------------------------------------------------------
            PUSH_VAL        => outlet_valid        , -- Out:
            PUSH_LAST       => outlet_last         , -- Out:
            PUSH_XFER_LAST  => open                , -- Out:
            PUSH_XFER_DONE  => outlet_xfer_done    , -- Out:
            PUSH_ERROR      => outlet_error        , -- Out:
            PUSH_SIZE       => outlet_size         , -- Out:
        ---------------------------------------------------------------------------
        -- Pool Buffer Interface Signals.
        ---------------------------------------------------------------------------
            POOL_WEN        => BUF_WEN             , -- Out:
            POOL_DVAL       => BUF_BEN             , -- Out:
            POOL_DATA       => BUF_DATA            , -- Out:
            POOL_PTR        => BUF_PTR             , -- Out:
            POOL_RDY        => outlet_ready        , -- In :
        ---------------------------------------------------------------------------
        -- Status Signals.
        ---------------------------------------------------------------------------
            BUSY            => port_busy             -- Out:
        );                                           -- 
    -------------------------------------------------------------------------------
    -- outlet_ready  : バッファにデータを書き込む用意が出来ているかどうかを示す信号.
    -------------------------------------------------------------------------------
    outlet_ready <= '1' when ((xfer_sel_valid and PUSH_BUF_RDY) /= SEL_ALL0) else '0';
    -------------------------------------------------------------------------------
    -- port_done     : INTAKE_PORT が'次のクロックで'ビジー状態から開放されることを示す信号.
    -------------------------------------------------------------------------------
    port_done    <= '1' when (outlet_valid /= SEL_ALL0 and outlet_last = '1') else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    port_ready_or_done <= (port_busy = '0') or
                          (port_busy = '1' and port_done = '1');
    -------------------------------------------------------------------------------
    -- PUSH_RSV_SIZE : 何バイト書き込む予定かを示す信号.
    -- PUSH_RSV_LAST : 最後のデータを書き込む予定であることを示す信号.
    -- PUSH_RSV_ERROR: エラーが発生したことを示す信号.
    -- PUSH_RSV_VAL  : PUSH_RSV_LAST、PUSH_RSV_ERROR、PUSH_RSV_SIZE が有効であることを示す信号.
    -------------------------------------------------------------------------------
    PUSH_RSV: block
        signal enable : boolean;
        signal error  : boolean;
        signal last   : boolean;
        signal valid  : boolean;
    begin
        enable <= (curr_state = WAIT_RFIRST);
        error  <= (enable and read_data_error = '1');
        last   <= (enable and xfer_ack_last   = '1');
        valid  <= (enable and read_data_valid = '1' and read_data_ready = '1');
        PUSH_RSV_VAL   <= xfer_sel_valid  when (valid) else (others => '0');
        PUSH_RSV_LAST  <= '1'             when (last ) else '0';
        PUSH_RSV_ERROR <= '1'             when (error) else '0';
        PUSH_RSV_SIZE  <= (others => '0') when (enable = FALSE or error = TRUE) else
                          std_logic_vector(RESIZE(unsigned(xfer_ack_size), PUSH_RSV_SIZE'length));
    end block;
    -------------------------------------------------------------------------------
    -- PUSH_FIN_SIZE : 何バイト書き込んだかを示す信号.
    -- PUSH_FIN_LAST : 最後のデータを書き込んだことを示す信号.
    -- PUSH_FIN_ERROR: エラーが発生したことを示す信号.
    -- PUSH_FIN_VAL  : PUSH_RSV_LAST、PUSH_RSV_ERROR、PUSH_RSV_SIZE が有効であることを示す信号.
    -------------------------------------------------------------------------------
    PUSH_FIN: block
    begin 
        PUSH_FIN_VAL   <= outlet_valid;
        PUSH_FIN_LAST  <= outlet_xfer_done;
        PUSH_FIN_ERROR <= outlet_error;
        PUSH_FIN_SIZE  <= outlet_size;
    end block;
    -------------------------------------------------------------------------------
    -- PUSH_BUF_SIZE : 何バイト書き込んだかを示す信号.
    -- PUSH_BUF_LAST : 最後のデータを書き込んだことを示す信号.
    -- PUSH_BUF_ERROR: エラーが発生したことを示す信号.
    -- PUSH_BUF_VAL  : PUSH_RSV_LAST、PUSH_RSV_ERROR、PUSH_RSV_SIZE が有効であることを示す信号.
    -- PUSH_BUF_RESET: バッファカウンタをリセットする信号
    -------------------------------------------------------------------------------
    PUSH_BUF: block
    begin
        PUSH_BUF_RESET <= req_queue_select when (xfer_start = '1') else (others => '0');
        PUSH_BUF_VAL   <= outlet_valid;
        PUSH_BUF_LAST  <= outlet_xfer_done;
        PUSH_BUF_ERROR <= outlet_error;
        PUSH_BUF_SIZE  <= outlet_size;
    end block;
end RTL;

