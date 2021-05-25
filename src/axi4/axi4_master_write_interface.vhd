-----------------------------------------------------------------------------------
--!     @file    axi4_master_write_interface.vhd
--!     @brief   AXI4 Master Write Interface
--!     @version 1.8.6
--!     @date    2021/5/25
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2021 Ichiro Kawazome
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
--! @brief   AXI4 Master Write Interface
-----------------------------------------------------------------------------------
entity  AXI4_MASTER_WRITE_INTERFACE is
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
        QUEUE_SIZE      : --! @brief RESPONSE QUEUE SIZE :
                          --! レスンポンスのキューの大きさを指定する.
                          --! レスンポンスのキューの大きさは１以上. 
                          --! QUEUE_SIZE=0を指定した場合は、強制的にキューの大きさ
                          --! は１に設定される.
                          integer := 1;
        REQ_REGS        : --! @brief REQUEST REGISTER USE :
                          --! ライトトランザクションの最初のデータ出力のタイミング
                          --! を指定する.
                          --! * REQ_REGS=0でアドレスの出力と同時にデータを出力する.
                          --! * REQ_REGS=1でアドレスを出力してから１クロック後に
                          --!   データを出力する.
                          --! * REQ_REGS=1にすると動作周波数が向上する可能性がある.
                          integer range 0 to 1 := 0;
        ACK_REGS        : --! @brief COMMAND ACKNOWLEDGE SIGNALS REGSITERED OUT :
                          --! Command Acknowledge Signals の出力をレジスタ出力に
                          --! するか否かを指定する.
                          --! * ACK_REGS=0で組み合わせ出力.
                          --! * ACK_REGS=1でレジスタ出力.
                          integer range 0 to 1 := 0;
        RESP_REGS       : --! @brief RESPONSE REGISTER USE :
                          --! レスポンスの入力側にレジスタを挿入する.
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
                          out   std_logic_vector(AXI4_ALEN_WIDTH  -1 downto 0);
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
                          out   std_logic_vector(AXI4_ALOCK_WIDTH -1 downto 0);
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
                          in    std_logic_vector(AXI4_ALOCK_WIDTH -1 downto 0);
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
                          in    std_logic_vector(VAL_BITS         -1 downto 0);
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
                          in    std_logic_vector(XFER_SIZE_BITS   -1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- Pull Reserve Size Signals.
    -------------------------------------------------------------------------------
        PULL_RSV_VAL    : --! @brief Pull Reserve Valid.
                          --! PULL_RSV_LAST/PULL_RSV_ERROR/PULL_RSV_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PULL_RSV_LAST   : --! @brief Pull Reserve Last.
                          --! 最後の転送"する予定"である事を示すフラグ.
                          out   std_logic;
        PULL_RSV_ERROR  : --! @brief Pull Reserve Error.
                          --! 転送"する予定"がエラーだった事を示すフラグ.
                          out   std_logic;
        PULL_RSV_SIZE   : --! @brief Pull Reserve Size.
                          --! 転送"する予定"のバイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Final Size Signals.
    -------------------------------------------------------------------------------
        PULL_FIN_VAL    : --! @brief Pull Final Valid.
                          --! PULL_FIN_LAST/PULL_FIN_ERROR/PULL_FIN_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PULL_FIN_LAST   : --! @brief Pull Final Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PULL_FIN_ERROR  : --! @brief Pull Final Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PULL_FIN_SIZE   : --! @brief Pull Final Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Buffer Size Signals.
    -------------------------------------------------------------------------------
        PULL_BUF_RESET  : --! @brief Pull Buffer Counter Reset.
                          --! バッファのカウンタをリセットする信号.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PULL_BUF_VAL    : --! @brief Pull Buffer Valid.
                          --! PULL_BUF_LAST/PULL_BUF_ERROR/PULL_BUF_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        PULL_BUF_LAST   : --! @brief Pull Buffer Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PULL_BUF_ERROR  : --! @brief Pull Buffer Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PULL_BUF_SIZE   : --! @brief Pull Buffer Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
        PULL_BUF_RDY    : --! @brief Pull Buffer Valid.
                          --! バッファからデータを読み出し可能な事をを示す.
                          in    std_logic_vector(VAL_BITS         -1 downto 0);
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
                          out   std_logic_vector(BUF_PTR_BITS     -1 downto 0)
    );
end AXI4_MASTER_WRITE_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_TRANSFER_QUEUE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_DATA_OUTLET_PORT;
architecture RTL of AXI4_MASTER_WRITE_INTERFACE is
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
    function MIN(A,B:integer) return integer is begin
        if (A<B) then return A;
        else          return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    function MAX(A,B:integer) return integer is begin
        if (A>B) then return A;
        else          return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function CALC_AXI4_BURST_SIZE(SIZE:integer) return AXI4_ASIZE_TYPE is
    begin
        case SIZE is
            when 0      => return AXI4_ASIZE_1BYTE;
            when 1      => return AXI4_ASIZE_2BYTE;
            when 2      => return AXI4_ASIZE_4BYTE;
            when 3      => return AXI4_ASIZE_8BYTE;
            when 4      => return AXI4_ASIZE_16BYTE;
            when 5      => return AXI4_ASIZE_32BYTE;
            when 6      => return AXI4_ASIZE_64BYTE;
            when 7      => return AXI4_ASIZE_128BYTE;
            when others => return AXI4_ASIZE_128BYTE;
        end case;
    end function;
    constant AXI4_BURST_SIZE    : AXI4_ASIZE_TYPE := CALC_AXI4_BURST_SIZE(AXI4_DATA_SIZE);
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
    signal   xfer_ack_size      : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   xfer_ack_next      : std_logic;
    signal   xfer_ack_last      : std_logic;
    signal   xfer_ack_error     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   xfer_start         : std_logic;
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
    signal   req_queue_addr     : std_logic_vector(AXI4_ADDR_WIDTH-1 downto 0);
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
    constant xfer_run_addr      : std_logic_vector(AXI4_DATA_SIZE    downto 0) := (others => '0');
    constant xfer_run_ptr       : std_logic_vector(BUF_PTR_BITS   -1 downto 0) := (others => '0');
    constant xfer_run_alen      : std_logic_vector(AXI4_ALEN_WIDTH-1 downto 0) := (others => '0');
    constant xfer_run_first     : std_logic := '0';
    signal   xfer_run_select    : std_logic_vector(VAL_BITS   -1 downto 0);
    signal   xfer_run_size      : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   xfer_run_next      : std_logic;
    signal   xfer_run_last      : std_logic;
    signal   xfer_run_safety    : std_logic;
    signal   xfer_run_noack     : std_logic;
    signal   xfer_run_done      : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   risky_ack_mode     : boolean;
    signal   risky_ack_valid    : std_logic;
    signal   risky_ack_size     : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   risky_ack_next     : std_logic;
    signal   risky_ack_last     : std_logic;
    signal   risky_ack_error    : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   safety_ack_mode    : boolean;
    signal   safety_ack_valid   : std_logic;
    signal   safety_ack_size    : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   safety_ack_next    : std_logic;
    signal   safety_ack_last    : std_logic;
    signal   safety_ack_error   : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   port_busy          : std_logic;
    signal   port_select        : std_logic_vector(VAL_BITS   -1 downto 0);
    constant port_push_error    : std_logic := '0';
    signal   port_push_valid    : std_logic;
    signal   port_push_ready    : std_logic;
    signal   port_push_enable   : std_logic;
    signal   port_push_done     : std_logic;
    signal   port_pull_ready    : std_logic;
    signal   port_exit_valid    : std_logic_vector(VAL_BITS   -1 downto 0);
    signal   port_exit_last     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   res_queue_size     : std_logic_vector(XFER_MAX_SIZE downto 0);
    signal   res_queue_select   : std_logic_vector(VAL_BITS   -1 downto 0);
    signal   res_queue_busy     : std_logic_vector(VAL_BITS   -1 downto 0);
    signal   res_queue_done     : std_logic_vector(VAL_BITS   -1 downto 0);
    signal   res_queue_ready    : std_logic;
    signal   res_queue_valid    : std_logic;
    signal   res_queue_next     : std_logic;
    signal   res_queue_last     : std_logic;
    signal   res_queue_safety   : std_logic;
    signal   res_queue_noack    : std_logic;
    signal   res_queue_empty    : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   response_request   : std_logic;
    signal   response_valid     : std_logic;
    signal   response_error     : std_logic;
begin
    -------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Controller.
    -------------------------------------------------------------------------------
    AW: AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER     -- 
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
            AADDR           => AWADDR            , -- Out :
            ASIZE           => AWSIZE            , -- Out :
            ALEN            => AWLEN             , -- Out :
            AVALID          => AWVALID           , -- Out :
            AREADY          => AWREADY           , -- In  :
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
    -- AXI4 Write Address Channel Signals Output.
    -------------------------------------------------------------------------------
    AWBURST  <= REQ_BURST;
    AWLOCK   <= REQ_LOCK;
    AWCACHE  <= REQ_CACHE;
    AWPROT   <= REQ_PROT;
    AWQOS    <= REQ_QOS;
    AWREGION <= REQ_REGION;
    AWID     <= REQ_ID;
    WID      <= REQ_ID;
    -------------------------------------------------------------------------------
    -- xfer_req_ptr  : バッファのリード開始ポインタ
    -------------------------------------------------------------------------------
    process (REQ_ADDR, REQ_BUF_PTR) begin
        for i in xfer_req_ptr'range loop
            if (i < ALIGNMENT_SIZE) then
                xfer_req_ptr(i) <= REQ_ADDR(i);
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
            QUEUE_SIZE      => MIN(REQ_REGS,1)         --
        )                                              --
        port map (                                     --
            CLK             => CLK                   , -- In  :
            RST             => RST                   , -- In  :
            CLR             => CLR                   , -- In  :
            I_VALID         => xfer_req_valid        , -- In  :
            I_SEL           => xfer_req_select       , -- In  :
            I_SIZE          => xfer_req_size         , -- In  :
            I_ADDR          => xfer_req_addr         , -- In  :
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
    -- req_queue_ready : Transfer Requestを受け付けることが出来ることを示すフラグ.
    -------------------------------------------------------------------------------
    req_queue_ready <= '1' when (port_busy = '0' and res_queue_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_start       : この信号がトリガーとなっていろいろと処理を開始する.
    -------------------------------------------------------------------------------
    xfer_start      <= '1' when (req_queue_ready = '1' and req_queue_valid = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_sel_busy  : データ転送中である事を示すフラグ.
    -- xfer_sel_done  : 次のクロックで xfer_sel_busy がネゲートされることを示すフラグ.
    -------------------------------------------------------------------------------
    XFER_SEL_GEN: for i in 0 to VAL_BITS-1 generate
        xfer_sel_busy(i) <= '1' when (req_queue_busy (i) = '1') or
                                     (xfer_run_select(i) = '1') or
                                     (res_queue_busy (i) = '1') else '0';
        xfer_sel_done(i) <= '1' when (req_queue_busy (i) = '0') and
                                     (xfer_run_select(i) = '0') and
                                     (res_queue_busy (i) = '1') and
                                     (res_queue_done (i) = '1') else '0';
    end generate;
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
    -- AXI4 用データ出力ポート
    -------------------------------------------------------------------------------
    OUTLET_PORT: AXI4_DATA_OUTLET_PORT             -- 
        generic map (                              -- 
            PORT_DATA_BITS  => AXI4_DATA_WIDTH   , -- 
            POOL_DATA_BITS  =>  BUF_DATA_WIDTH   , -- 
            TRAN_ADDR_BITS  => AXI4_ADDR_WIDTH   , -- 
            TRAN_SIZE_BITS  => XFER_MAX_SIZE+1   , --
            TRAN_SEL_BITS   => VAL_BITS          , -- 
            BURST_LEN_BITS  => AXI4_ALEN_WIDTH   , -- 
            ALIGNMENT_BITS  => ALIGNMENT_BITS    , --
            PULL_SIZE_BITS  => XFER_SIZE_BITS    , --
            EXIT_SIZE_BITS  => XFER_SIZE_BITS    , --
            POOL_PTR_BITS   => BUF_PTR_BITS      , --
            TRAN_MAX_SIZE   => XFER_MAX_SIZE     , --
            USE_BURST_SIZE  => 0                 , --
            CHECK_BURST_LEN => 0                 , --
            QUEUE_SIZE      => 1                 , --
            PORT_REGS_SIZE  => 0                   --
        )                                          -- 
        port map (                                 -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK               , -- In  :
            RST             => RST               , -- In  :
            CLR             => CLR               , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            TRAN_START      => xfer_start        , -- In  :
            TRAN_ADDR       => req_queue_addr    , -- In  :
            TRAN_SIZE       => req_queue_size    , -- In  :
            BURST_LEN       => req_queue_alen    , -- In  :
            BURST_SIZE      => AXI4_BURST_SIZE   , -- In  :
            START_PTR       => req_queue_ptr     , -- In  :
            TRAN_LAST       => req_queue_last    , -- In  :
            TRAN_SEL        => req_queue_select  , -- In  :
            XFER_VAL        => open              , -- Out :
            XFER_DVAL       => open              , -- Out :
            XFER_LAST       => open              , -- Out :
            XFER_NONE       => open              , -- Out :
        ---------------------------------------------------------------------------
        -- AXI4 Outlet Port Signals.
        ---------------------------------------------------------------------------
            PORT_DATA       => WDATA             , -- Out :
            PORT_STRB       => WSTRB             , -- Out :
            PORT_LAST       => WLAST             , -- Out :
            PORT_ERROR      => open              , -- Out :
            PORT_VAL        => WVALID            , -- Out :
            PORT_RDY        => WREADY            , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PULL_VAL        => PULL_BUF_VAL      , -- Out :
            PULL_LAST       => open              , -- Out :
            PULL_XFER_LAST  => open              , -- Out :
            PULL_XFER_DONE  => PULL_BUF_LAST     , -- Out :
            PULL_ERROR      => PULL_BUF_ERROR    , -- Out :
            PULL_SIZE       => PULL_BUF_SIZE     , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Size Signals.
        ---------------------------------------------------------------------------
            EXIT_VAL        => port_exit_valid   , -- Out :
            EXIT_LAST       => port_exit_last    , -- Out :
            EXIT_XFER_LAST  => open              , -- Out :
            EXIT_XFER_DONE  => open              , -- Out :
            EXIT_ERROR      => open              , -- Out :
            EXIT_SIZE       => open              , -- Out :
        ---------------------------------------------------------------------------
        -- Pool Buffer Interface Signals.
        ---------------------------------------------------------------------------
            POOL_REN        => BUF_REN           , -- Out :
            POOL_PTR        => BUF_PTR           , -- Out :
            POOL_DATA       => BUF_DATA          , -- In  :
            POOL_ERROR      => port_push_error   , -- In  :
            POOL_VAL        => port_push_valid   , -- In  :
            POOL_RDY        => port_push_ready   , -- Out :
        ---------------------------------------------------------------------------
        -- Status Signals.
        ---------------------------------------------------------------------------
            POOL_BUSY       => port_push_enable  , -- Out :
            POOL_DONE       => port_push_done    , -- Out :
            BUSY            => port_busy           -- Out :
        );                                         -- 
    -------------------------------------------------------------------------------
    -- 転送期間中、情報を保持しておくためのレジスタ群.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- xfer_run_size  : Transfer Request Queue から取り出したサイズ情報を保持.
    -- xfer_run_select: Transfer Request Queue から取り出した選択情報を保持.
    -- xfer_run_next  : Transfer Request Queue から取り出したNEXTを保持.
    -- xfer_run_last  : Transfer Request Queue から取り出したLASTを保持.
    -- xfer_run_safety: Transfer Request Queue から取り出したSAFETYを保持.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                xfer_run_select <= (others => '0');
                xfer_run_size   <= (others => '0');
                xfer_run_next   <= '0';
                xfer_run_last   <= '0';
                xfer_run_safety <= '0';
                xfer_run_noack  <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') or
               (xfer_run_done = '1') then
                xfer_run_select <= (others => '0');
                xfer_run_size   <= (others => '0');
                xfer_run_next   <= '0';
                xfer_run_last   <= '0';
                xfer_run_safety <= '0';
                xfer_run_noack  <= '0';
            elsif (xfer_start = '1') then
                xfer_run_select <= req_queue_select;
                xfer_run_size   <= req_queue_size;
                xfer_run_next   <= req_queue_next;
                xfer_run_last   <= req_queue_last;
                xfer_run_safety <= req_queue_safety;
                xfer_run_noack  <= req_queue_noack;
            end if;
        end if;
    end process;
    xfer_run_done   <= '1' when (port_exit_valid /= SEL_ALL0) and
                                (port_exit_last   = '1'     ) else '0';
    -------------------------------------------------------------------------------
    -- port_pull_ready:
    -------------------------------------------------------------------------------
    port_pull_ready <= '1' when ((PULL_BUF_RDY and xfer_run_select) /= SEL_ALL0) else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    port_push_valid <= '1' when (port_push_enable = '1' and port_pull_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    PULL_BUF_RESET  <= req_queue_select when (xfer_start = '1') else (others => '0');
    -------------------------------------------------------------------------------
    -- Non Safety(Risky) Return Response.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- ここで言うリスキーとは、スレーブからの書き込み応答を待たずに、書き込みが成功
    -- するという前提で、処理を終えてしまうことを指す.
    -- 具体的には、すべてのライトデータを出力し終えた時点で、(スレーブからの応答を
    -- 待たずに)処理を終了する.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                risky_ack_mode <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                risky_ack_mode <= FALSE;
            elsif (xfer_start = '1') then
                risky_ack_mode <= (req_queue_safety = '0' and req_queue_noack = '0');
            elsif (risky_ack_valid = '1') then
                risky_ack_mode <= FALSE;
            end if;
        end if;
    end process;
    risky_ack_size  <= xfer_run_size when (risky_ack_mode) else (others => '0');
    risky_ack_valid <= xfer_run_done when (risky_ack_mode) else '0';
    risky_ack_next  <= xfer_run_next when (risky_ack_mode) else '0';
    risky_ack_last  <= xfer_run_last when (risky_ack_mode) else '0';
    risky_ack_error <= '0';
    -------------------------------------------------------------------------------
    -- Transfer Response Queue.
    -------------------------------------------------------------------------------
    RES_QUEUE: AXI4_MASTER_TRANSFER_QUEUE              -- 
        generic map (                                  -- 
            SEL_BITS        => VAL_BITS              , --
            SIZE_BITS       => xfer_run_size'length  , --
            ADDR_BITS       => xfer_run_addr'length  , --
            ALEN_BITS       => xfer_run_alen'length  , --
            PTR_BITS        => xfer_run_ptr 'length  , --
            QUEUE_SIZE      => MAX(QUEUE_SIZE,1)       --
        )                                              --
        port map (                                     --
            CLK             => CLK                   , -- In  :
            RST             => RST                   , -- In  :
            CLR             => CLR                   , -- In  :
            I_VALID         => xfer_run_done         , -- In  :
            I_SEL           => xfer_run_select       , -- In  :
            I_SIZE          => xfer_run_size         , -- In  :
            I_ADDR          => xfer_run_addr         , -- In  :
            I_ALEN          => xfer_run_alen         , -- In  :
            I_PTR           => xfer_run_ptr          , -- In  :
            I_NEXT          => xfer_run_next         , -- In  :
            I_LAST          => xfer_run_last         , -- In  :
            I_FIRST         => xfer_run_first        , -- In  :
            I_SAFETY        => xfer_run_safety       , -- In  :
            I_NOACK         => xfer_run_noack        , -- In  :
            I_READY         => res_queue_ready       , -- Out :
            Q_VALID         => res_queue_valid       , -- Out :
            Q_SEL           => res_queue_select      , -- Out :
            Q_SIZE          => res_queue_size        , -- Out :
            Q_ADDR          => open                  , -- Out :
            Q_ALEN          => open                  , -- Out :
            Q_PTR           => open                  , -- Out :
            Q_NEXT          => res_queue_next        , -- Out :
            Q_LAST          => res_queue_last        , -- Out :
            Q_FIRST         => open                  , -- Out :
            Q_SAFETY        => res_queue_safety      , -- Out :
            Q_NOACK         => res_queue_noack       , -- Out :
            Q_READY         => response_valid        , -- In  :
            O_VALID         => response_request      , -- Out :
            BUSY            => res_queue_busy        , -- Out :
            DONE            => res_queue_done        , -- Out :
            EMPTY           => res_queue_empty         -- Out :
        );                                             -- 
    -------------------------------------------------------------------------------
    -- Transfer Response Intake(Non Registered).
    -------------------------------------------------------------------------------
    NON_RESP_REGS: if (RESP_REGS = 0) generate
        BREADY         <= '1' when (res_queue_valid = '1') else '0';
        response_valid <= '1' when (BVALID = '1' and res_queue_valid = '1') else '0';
        response_error <= '1' when (BRESP = AXI4_RESP_SLVERR or BRESP = AXI4_RESP_DECERR) else '0';
    end generate;
    -------------------------------------------------------------------------------
    -- Transfer Response Intake(Registered).
    -------------------------------------------------------------------------------
    USE_RESP_REGS: if (RESP_REGS /= 0) generate
        subtype   RESP_STATE_TYPE is std_logic_vector(1 downto 0);
        constant  RESP_IDLE       :  RESP_STATE_TYPE := "00";
        constant  RESP_WAIT       :  RESP_STATE_TYPE := "01";
        constant  RESP_DONE       :  RESP_STATE_TYPE := "10";
        signal    resp_state      :  RESP_STATE_TYPE;
        signal    resp_data       :  AXI4_RESP_TYPE;
    begin
        BREADY         <= resp_state(0);
        response_valid <= resp_state(1);
        response_error <= '1' when (resp_data = AXI4_RESP_SLVERR or resp_data = AXI4_RESP_DECERR) else '0';
        process (CLK, RST) begin
            if (RST = '1') then
                    resp_state <= RESP_IDLE;
                    resp_data  <= AXI4_RESP_OKAY;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then 
                    resp_state <= RESP_IDLE;
                    resp_data  <= AXI4_RESP_OKAY;
                else
                    resp_data  <= BRESP;
                    case resp_state is
                        when RESP_IDLE =>
                            if (response_request = '1') then
                                resp_state <= RESP_WAIT;
                            else
                                resp_state <= RESP_IDLE;
                            end if;
                        when RESP_WAIT =>
                            if (BVALID = '1') then
                                resp_state <= RESP_DONE;
                            else
                                resp_state <= RESP_WAIT;
                            end if;
                        when RESP_DONE =>
                                resp_state <= RESP_IDLE;
                        when others    =>
                                resp_state <= RESP_IDLE;
                    end case;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- Safety Return Response.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- セーフティでは、スレーブからの書き込み応答を待って、書き込みが成功したことを
    -- 確認してから、処理を終える.
    -------------------------------------------------------------------------------
    safety_ack_mode  <= (res_queue_safety = '1' and res_queue_noack = '0' and res_queue_valid = '1');
    safety_ack_valid <= '1' when (safety_ack_mode and response_valid = '1') else '0';
    safety_ack_error <= '1' when (safety_ack_mode and response_error = '1') else '0';
    safety_ack_next  <= '1' when (safety_ack_mode and res_queue_next = '1') else '0';
    safety_ack_last  <= '1' when (safety_ack_mode and res_queue_last = '1') else '0';
    safety_ack_size  <= res_queue_size when (safety_ack_mode and safety_ack_error = '0') else (others => '0');
    -------------------------------------------------------------------------------
    -- Return Response.
    -------------------------------------------------------------------------------
    xfer_ack_valid   <= risky_ack_valid or safety_ack_valid;
    xfer_ack_error   <= risky_ack_error or safety_ack_error;
    xfer_ack_next    <= risky_ack_next  or safety_ack_next;
    xfer_ack_last    <= risky_ack_last  or safety_ack_last;
    xfer_ack_size    <= risky_ack_size  or safety_ack_size;
    -------------------------------------------------------------------------------
    -- Pull Reserve Size and Last
    -------------------------------------------------------------------------------
    PULL_RSV_VAL     <= req_queue_select when (xfer_start = '1') else SEL_ALL0;
    PULL_RSV_LAST    <= req_queue_last;
    PULL_RSV_ERROR   <= '0';
    PULL_RSV_SIZE    <= std_logic_vector(RESIZE(unsigned(req_queue_size) , PULL_RSV_SIZE'length));
    -------------------------------------------------------------------------------
    -- Pull Final Size and Last
    -------------------------------------------------------------------------------
    PULL_FIN_VAL     <= res_queue_select when (response_valid = '1') else SEL_ALL0;
    PULL_FIN_LAST    <= res_queue_last;
    PULL_FIN_ERROR   <= '1'              when (response_error = '1') else '0';
    PULL_FIN_SIZE    <= (others => '0')  when (response_error = '1') else
                        std_logic_vector(RESIZE(unsigned(res_queue_size), PULL_FIN_SIZE'length));
    -------------------------------------------------------------------------------
    -- xfer_res_error : データ転送中にエラーが発生したことを示すフラグ.
    -------------------------------------------------------------------------------
    xfer_res_error   <= res_queue_select when (response_valid = '1') and
                                              (response_error = '1') else SEL_ALL0;
end RTL;
