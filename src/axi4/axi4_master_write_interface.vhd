-----------------------------------------------------------------------------------
--!     @file    axi4_master_write_interface.vhd
--!     @brief   AXI4 Master Write Interface
--!     @version 1.5.0
--!     @date    2013/8/2
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
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Transfer Status Signal.
    -------------------------------------------------------------------------------
        XFER_BUSY       : --! @brief Transfer Busy.
                          --! このモジュールが未だデータの転送中であることを示す.
                          --! * QUEUE_SIZEの設定によっては、XFER_BUSY がアサートさ
                          --!   れていても、次のリクエストを受け付け可能な場合があ
                          --!   る.
                          out   std_logic;
        XFER_DONE       : --! @brief Transfer Done.
                          --! このモジュールが未だデータの転送中かつ、次のクロック
                          --! で XFER_BUSY がネゲートされる事を示す.
                          --! * ただし、XFER_BUSY のネゲート前に 必ずしもこの信号が
                          --!   アサートされるわけでは無い.
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
                          in    std_logic_vector(SIZE_BITS-1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- Pull Reserve Size Signals.
    -------------------------------------------------------------------------------
        PULL_RSV_VAL    : --! @brief Pull Reserve Valid.
                          --! PULL_RSV_LAST/PULL_RSV_ERROR/PULL_RSV_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS -1 downto 0);
        PULL_RSV_LAST   : --! @brief Pull Reserve Last.
                          --! 最後の転送"する予定"である事を示すフラグ.
                          out   std_logic;
        PULL_RSV_ERROR  : --! @brief Pull Reserve Error.
                          --! 転送"する予定"がエラーだった事を示すフラグ.
                          out   std_logic;
        PULL_RSV_SIZE   : --! @brief Pull Reserve Size.
                          --! 転送"する予定"のバイト数を出力する.
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Final Size Signals.
    -------------------------------------------------------------------------------
        PULL_FIN_VAL    : --! @brief Pull Final Valid.
                          --! PULL_FIN_LAST/PULL_FIN_ERROR/PULL_FIN_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS -1 downto 0);
        PULL_FIN_LAST   : --! @brief Pull Final Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PULL_FIN_ERROR  : --! @brief Pull Final Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PULL_FIN_SIZE   : --! @brief Pull Final Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Buffer Size Signals.
    -------------------------------------------------------------------------------
        PULL_BUF_RESET  : --! @brief Pull Buffer Counter Reset.
                          --! バッファのカウンタをリセットする信号.
                          out   std_logic_vector(VAL_BITS -1 downto 0);
        PULL_BUF_VAL    : --! @brief Pull Buffer Valid.
                          --! PULL_BUF_LAST/PULL_BUF_ERROR/PULL_BUF_SIZEが有効で
                          --! あることを示す.
                          out   std_logic_vector(VAL_BITS -1 downto 0);
        PULL_BUF_LAST   : --! @brief Pull Buffer Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PULL_BUF_ERROR  : --! @brief Pull Buffer Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PULL_BUF_SIZE   : --! @brief Pull Buffer Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
        PULL_BUF_RDY    : --! @brief Pull Buffer Valid.
                          --! バッファからデータを読み出し可能な事をを示す.
                          in    std_logic_vector(VAL_BITS -1 downto 0);
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
use     PIPEWORK.COMPONENTS.CHOPPER;
use     PIPEWORK.COMPONENTS.REDUCER;
use     PIPEWORK.COMPONENTS.QUEUE_REGISTER;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER;
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
    signal   xfer_req_addr      : std_logic_vector(AXI4_ADDR_WIDTH-1 downto 0);
    signal   xfer_req_size      : std_logic_vector(XFER_MAX_SIZE     downto 0);
    signal   xfer_req_select    : std_logic_vector(VAL_BITS       -1 downto 0);
    signal   xfer_req_valid     : std_logic;
    signal   xfer_req_ready     : std_logic;
    signal   xfer_req_next      : std_logic;
    signal   xfer_req_last      : std_logic;
    signal   xfer_req_first     : std_logic;
    signal   xfer_req_safety    : std_logic;
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
    signal   xfer_running       : std_logic;
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
    constant xfer_beat_sel      : std_logic_vector(BUF_DATA_SIZE downto BUF_DATA_SIZE) := "1";
    signal   xfer_beat_chop     : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   buf_busy           : std_logic;
    signal   buf_enable         : std_logic;
    signal   buf_select         : std_logic_vector(VAL_BITS    -1 downto 0);
    signal   buf_push_valid     : std_logic;
    signal   buf_push_ben       : std_logic_vector(BUF_DATA_WIDTH/8-1 downto 0);
    signal   buf_push_size      : std_logic_vector(BUF_DATA_SIZE      downto 0);
    signal   buf_push_last      : std_logic;
    signal   buf_push_ready     : std_logic;
    signal   buf_pull_ready     : std_logic;
    constant BUF_SEL_ALL0       : std_logic_vector(VAL_BITS    -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   data_valid         : std_logic;
    signal   data_last          : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   buf_start_ptr      : std_logic_vector(BUF_PTR_BITS-1 downto 0);
    signal   next_read_ptr      : std_logic_vector(BUF_PTR_BITS-1 downto 0);
    signal   curr_read_ptr      : std_logic_vector(BUF_PTR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   ack_queue_ready    : std_logic;
    signal   ack_queue_valid    : std_logic;
    signal   ack_queue_next     : std_logic;
    signal   ack_queue_last     : std_logic;
    signal   ack_queue_select   : std_logic_vector(VAL_BITS    -1 downto 0);
    signal   ack_queue_size     : std_logic_vector(XFER_MAX_SIZE  downto 0);
    signal   ack_queue_empty    : std_logic;
    signal   ack_queue_safety   : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    type     STATE_TYPE      is ( IDLE, WAIT_WFIRST, WAIT_WLAST, TURN_AR);
    signal   curr_state         : STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Controller.
    -------------------------------------------------------------------------------
    AW: AXI4_MASTER_ADDRESS_CHANNEL_CONTROLLER
        generic map (
            VAL_BITS        => VAL_BITS          , --
            DATA_SIZE       => AXI4_DATA_SIZE    , --
            ADDR_BITS       => AXI4_ADDR_WIDTH   , --
            SIZE_BITS       => SIZE_BITS         , --
            ALEN_BITS       => AXI4_ALEN_WIDTH   , --
            REQ_SIZE_BITS   => REQ_SIZE_BITS     , --
            REQ_SIZE_VALID  => REQ_SIZE_VALID    , --
            FLOW_VALID      => FLOW_VALID        , --
            XFER_MIN_SIZE   => XFER_MIN_SIZE     , --
            XFER_MAX_SIZE   => XFER_MAX_SIZE       --
        )
        port map (
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
            XFER_REQ_FIRST  => xfer_req_first    , -- Out :
            XFER_REQ_LAST   => xfer_req_last     , -- Out :
            XFER_REQ_NEXT   => xfer_req_next     , -- Out :
            XFER_REQ_SAFETY => xfer_req_safety   , -- Out :
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
            XFER_RUNNING    => xfer_running        -- In  :
        );
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
    -- ライトデータチャネルの状態遷移
    -------------------------------------------------------------------------------
    WDT_FSM: process(CLK, RST) begin
        if (RST = '1') then
                curr_state <= IDLE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state <= IDLE;
            else
                case curr_state is
                    ---------------------------------------------------------------
                    -- Transfer Request の受け付け待ち.
                    ---------------------------------------------------------------
                    when IDLE =>
                        if (xfer_req_valid = '1' and ack_queue_ready = '1') then
                            curr_state <= WAIT_WFIRST;
                        else
                            curr_state <= IDLE;
                        end if;
                    ---------------------------------------------------------------
                    -- AXI4 Write Data Channel に最初のデータを出力するのを待つ.
                    ---------------------------------------------------------------
                    when WAIT_WFIRST =>
                        if    (data_valid = '1' and WREADY = '1' and data_last = '1') then
                            curr_state <= TURN_AR;
                        elsif (data_valid = '1' and WREADY = '1' and data_last = '0') then
                            curr_state <= WAIT_WLAST;
                        else
                            curr_state <= WAIT_WFIRST;
                        end if;
                    ---------------------------------------------------------------
                    -- AXI4 Write Data Channel に最初のデータを出力するのを待つ.
                    ---------------------------------------------------------------
                    when WAIT_WLAST  =>
                        if    (data_valid = '1' and WREADY = '1' and data_last = '1') then
                            curr_state <= TURN_AR;
                        else
                            curr_state <= WAIT_WLAST;
                        end if;
                    ---------------------------------------------------------------
                    -- １クロック待ってから IDLE に戻る.
                    ---------------------------------------------------------------
                    when TURN_AR   =>
                            curr_state <= IDLE;
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
    -- xfer_start     : この信号がトリガーとなっていろいろと処理を開始する.
    -------------------------------------------------------------------------------
    xfer_start     <= '1' when (xfer_req_ready = '1' and xfer_req_valid = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_req_ready : Transfer Requestを受け付けることが出来ることを示すフラグ.
    -------------------------------------------------------------------------------
    xfer_req_ready <= '1' when (curr_state = IDLE and ack_queue_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_running   : データ転送中である事を示すフラグ.
    -- XFER_BUSY      : データ転送中である事を示すフラグ.
    -------------------------------------------------------------------------------
    xfer_running   <= '1' when (curr_state = WAIT_WFIRST or
                                curr_state = WAIT_WLAST  or
                                curr_state = TURN_AR     or
                                ack_queue_valid = '1' ) else '0';
    XFER_BUSY      <= xfer_running;
    -------------------------------------------------------------------------------
    -- XFER_DONE      : 次のクロックで XFER_BUSY がネゲートされることを示すフラグ.
    -------------------------------------------------------------------------------
    XFER_DONE      <= '1' when (curr_state = TURN_AR  and
                                ack_queue_empty = '1' ) else '0';
    -------------------------------------------------------------------------------
    -- buf_start_ptr  : バッファのリード開始ポインタ
    -------------------------------------------------------------------------------
    process (REQ_ADDR, REQ_BUF_PTR) begin
        for i in buf_start_ptr'range loop
            if (i < ALIGNMENT_SIZE) then
                buf_start_ptr(i) <= REQ_ADDR(i);
            else
                buf_start_ptr(i) <= REQ_BUF_PTR(i);
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- buf_push_ben   : 送信バッファに書き込むためのバイトイネーブル信号.
    -- buf_push_size  : 送信バッファに書き込むバイト数を１ビート毎に出力する.
    -- buf_push_last  : 送信バッファに書き込む最後のビートであることを示す.
    -------------------------------------------------------------------------------
    BEN: CHOPPER
        generic map (
            BURST           => 1                     ,
            MIN_PIECE       => BUF_DATA_SIZE         ,
            MAX_PIECE       => BUF_DATA_SIZE         ,
            MAX_SIZE        => XFER_MAX_SIZE         ,
            ADDR_BITS       => buf_start_ptr'length  ,
            SIZE_BITS       => xfer_req_size'length  ,
            COUNT_BITS      => 1                     ,
            PSIZE_BITS      => buf_push_size'length  ,
            GEN_VALID       => 1
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK                   , -- In  :
            RST             => RST                   , -- In  :
            CLR             => CLR                   , -- In  :
        ---------------------------------------------------------------------------
        -- 各種初期値
        ---------------------------------------------------------------------------
            ADDR            => buf_start_ptr         , -- In  :
            SIZE            => xfer_req_size         , -- In  :
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
            LAST            => buf_push_last         , -- Out :
            NEXT_NONE       => open                  , -- Out :
            NEXT_LAST       => open                  , -- Out :
        ---------------------------------------------------------------------------
        -- １ワードのバイト数
        ---------------------------------------------------------------------------
            PSIZE           => buf_push_size         , -- Out :
            NEXT_PSIZE      => open                  , -- Out :
        ---------------------------------------------------------------------------
        -- バイトイネーブル信号
        ---------------------------------------------------------------------------
            VALID           => buf_push_ben          , -- Out :
            NEXT_VALID      => open                    -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    next_read_ptr <= std_logic_vector(to_01(unsigned(curr_read_ptr)) +
                                      to_01(unsigned(buf_push_size)));
    process(CLK, RST) begin
        if (RST = '1') then
                curr_read_ptr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_read_ptr <= (others => '0');
            elsif (xfer_start = '1') then
                curr_read_ptr <= buf_start_ptr;
            elsif (xfer_beat_chop = '1') then
                curr_read_ptr <= next_read_ptr;
            end if;
        end if;
    end process;
    BUF_PTR <= buf_start_ptr   when (xfer_start     = '1') else
               next_read_ptr   when (xfer_beat_chop = '1') else
               curr_read_ptr;
    BUF_REN <= xfer_req_select when (xfer_start     = '1') else buf_select;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                buf_enable <= '0';
                buf_select <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                buf_enable <= '0';
                buf_select <= (others => '0');
            elsif (xfer_start = '1') then
                buf_enable <= '1';
                buf_select <= xfer_req_select;
            elsif (buf_push_valid = '1' and buf_push_ready = '1' and buf_push_last = '1') then
                buf_enable <= '0';
                buf_select <= (others => '0');
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    buf_pull_ready <= '1' when ((PULL_BUF_RDY and buf_select) /= BUF_SEL_ALL0) else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    buf_push_valid <= '1' when (buf_enable     = '1' and buf_pull_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    xfer_beat_chop <= '1' when (buf_push_valid = '1' and buf_push_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- 送信バッファ : 
    -------------------------------------------------------------------------------
    SBUF: block
        constant WORD_BITS      : integer := ALIGNMENT_BITS;
        constant STRB_BITS      : integer := ALIGNMENT_BITS/8;
        constant I_WIDTH        : integer :=  BUF_DATA_WIDTH/WORD_BITS;
        constant O_WIDTH        : integer := AXI4_DATA_WIDTH/WORD_BITS;
        constant i_enable       : std_logic := '1';
        constant o_enable       : std_logic := '1';
        constant done           : std_logic := '0';
        constant flush          : std_logic := '0';
        signal   offset         : std_logic_vector(O_WIDTH-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (xfer_req_addr)
            variable addr : unsigned(AXI4_DATA_SIZE-ALIGNMENT_SIZE downto 0);
        begin
            for i in addr'range loop
                if (i+ALIGNMENT_SIZE <  AXI4_DATA_SIZE    ) and
                   (i+ALIGNMENT_SIZE <= xfer_req_addr'high) and
                   (i+ALIGNMENT_SIZE >= xfer_req_addr'low ) then
                    if (xfer_req_addr(i+ALIGNMENT_SIZE) = '1') then
                        addr(i) := '1';
                    else
                        addr(i) := '0';
                    end if;
                else
                        addr(i) := '0';
                end if;
            end loop;
            for i in offset'range loop
                if (i < addr) then
                    offset(i) <= '1';
                else
                    offset(i) <= '0';
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        B: REDUCER
            generic map (
                WORD_BITS       => WORD_BITS      ,
                STRB_BITS       => STRB_BITS      ,
                I_WIDTH         => I_WIDTH        ,
                O_WIDTH         => O_WIDTH        ,
                QUEUE_SIZE      => 0              ,
                VALID_MIN       => 0              ,
                VALID_MAX       => 0              ,
                I_JUSTIFIED     => 0              ,
                FLUSH_ENABLE    => 0                     
            )
            port map (
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK            , -- In  :
                RST             => RST            , -- In  :
                CLR             => CLR            , -- In  :
            -----------------------------------------------------------------------
            -- 各種制御信号
            -----------------------------------------------------------------------
                START           => xfer_start     , -- In  :
                OFFSET          => offset         , -- In  :
                DONE            => done           , -- In  :
                FLUSH           => flush          , -- In  :
                BUSY            => buf_busy       , -- Out :
                VALID           => open           , -- Out :
            -----------------------------------------------------------------------
            -- 入力側 I/F
            -----------------------------------------------------------------------
                I_ENABLE        => i_enable       , -- In  :
                I_DATA          => BUF_DATA       , -- In  :
                I_STRB          => buf_push_ben   , -- In  :
                I_DONE          => buf_push_last  , -- In  :
                I_FLUSH         => flush          , -- In  :
                I_VAL           => buf_push_valid , -- In  :
                I_RDY           => buf_push_ready , -- Out :
            -----------------------------------------------------------------------
            -- 出力側 I/F
            -----------------------------------------------------------------------
                O_ENABLE        => o_enable       , -- In  :
                O_DATA          => WDATA          , -- Out :
                O_STRB          => WSTRB          , -- Out :
                O_DONE          => data_last      , -- Out :
                O_FLUSH         => open           , -- Out :
                O_VAL           => data_valid     , -- Out :
                O_RDY           => WREADY           -- In  :
        );
        WVALID <= data_valid;
        WLAST  <= data_last;
    end block;
    -------------------------------------------------------------------------------
    -- Non Safety(Risky) Return Response.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                risky_ack_size <= (others => '0');
                risky_ack_next <= '0';
                risky_ack_last <= '0';
                risky_ack_mode <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                risky_ack_size <= (others => '0');
                risky_ack_next <= '0';
                risky_ack_last <= '0';
                risky_ack_mode <= FALSE;
            elsif (xfer_start = '1') then
                if (xfer_req_safety = '0') then
                    risky_ack_size <= xfer_req_size;
                    risky_ack_next <= xfer_req_next;
                    risky_ack_last <= xfer_req_last;
                    risky_ack_mode <= TRUE;
                else
                    risky_ack_size <= (others => '0');
                    risky_ack_next <= '0';
                    risky_ack_last <= '0';
                    risky_ack_mode <= FALSE;
                end if;
            elsif (risky_ack_valid = '1') then
                    risky_ack_size <= (others => '0');
                    risky_ack_next <= '0';
                    risky_ack_last <= '0';
                    risky_ack_mode <= FALSE;
            end if;
        end if;
    end process;
    risky_ack_valid <= '1' when (risky_ack_mode and data_valid = '1' and data_last = '1' and WREADY = '1') else '0';
    risky_ack_error <= '0';
    -------------------------------------------------------------------------------
    -- Transfer Response Queue.
    -------------------------------------------------------------------------------
    RES: block
        constant VEC_LO         : integer := 0;
        constant VEC_SIZE_LO    : integer := VEC_LO;
        constant VEC_SIZE_HI    : integer := VEC_SIZE_LO  + XFER_MAX_SIZE;
        constant VEC_SEL_LO     : integer := VEC_SIZE_HI  + 1;
        constant VEC_SEL_HI     : integer := VEC_SEL_LO   + VAL_BITS-1;
        constant VEC_NEXT_POS   : integer := VEC_SEL_HI   + 1;
        constant VEC_LAST_POS   : integer := VEC_NEXT_POS + 1;
        constant VEC_SAFETY_POS : integer := VEC_LAST_POS + 1;
        constant VEC_HI         : integer := VEC_SAFETY_POS;
        signal   i_vec          : std_logic_vector(VEC_HI downto VEC_LO);
        signal   q_vec          : std_logic_vector(VEC_HI downto VEC_LO);
        signal   o_val          : std_logic_vector(QUEUE_SIZE downto 0);
        signal   q_val          : std_logic_vector(QUEUE_SIZE downto 0);
    begin
        i_vec(VEC_SIZE_HI downto VEC_SIZE_LO) <= xfer_req_size;
        i_vec(VEC_SEL_HI  downto VEC_SEL_LO ) <= xfer_req_select;
        i_vec(VEC_NEXT_POS)                   <= xfer_req_next;
        i_vec(VEC_LAST_POS)                   <= xfer_req_last;
        i_vec(VEC_SAFETY_POS)                 <= xfer_req_safety;
        QUEUE: QUEUE_REGISTER
            generic map (
                QUEUE_SIZE  => QUEUE_SIZE        ,
                DATA_BITS   => i_vec'length      ,
                LOWPOWER    => 1
            )
            port map (
                CLK         => CLK               , -- In  :
                RST         => RST               , -- In  :
                CLR         => CLR               , -- In  :
                I_DATA      => i_vec             , -- In  :
                I_VAL       => xfer_start        , -- In  :
                I_RDY       => ack_queue_ready   , -- Out :
                O_DATA      => open              , -- Out :
                O_VAL       => o_val             , -- Out :
                Q_DATA      => q_vec             , -- Out :
                Q_VAL       => q_val             , -- Out :
                Q_RDY       => BVALID              -- In  :
            );
        ack_queue_size   <= q_vec(VEC_SIZE_HI downto VEC_SIZE_LO);
        ack_queue_select <= q_vec(VEC_SEL_HI  downto VEC_SEL_LO);
        ack_queue_next   <= q_vec(VEC_NEXT_POS);
        ack_queue_last   <= q_vec(VEC_LAST_POS);
        ack_queue_safety <= q_vec(VEC_SAFETY_POS);
        ack_queue_valid  <= q_val(0);
        ack_queue_empty  <= '1' when (o_val(0) = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- BREADY : Write Response Ready
    -------------------------------------------------------------------------------
    BREADY  <= '1' when (ack_queue_valid = '1') else '0';
    -------------------------------------------------------------------------------
    -- Safety Return Response.
    -------------------------------------------------------------------------------
    safety_ack_mode  <= (ack_queue_safety = '1');
    safety_ack_valid <= '1' when (safety_ack_mode and ack_queue_valid = '1' and BVALID = '1') else '0';
    safety_ack_error <= '1' when (safety_ack_mode and (BRESP = AXI4_RESP_SLVERR or BRESP = AXI4_RESP_DECERR)) else '0';
    safety_ack_next  <= '1' when (safety_ack_mode and ack_queue_next = '1') else '0';
    safety_ack_last  <= '1' when (safety_ack_mode and ack_queue_last = '1') else '0';
    safety_ack_size  <= ack_queue_size when (safety_ack_mode and safety_ack_error = '0') else (others => '0');
    -------------------------------------------------------------------------------
    -- Return Response.
    -------------------------------------------------------------------------------
    xfer_ack_valid <= risky_ack_valid or safety_ack_valid;
    xfer_ack_error <= risky_ack_error or safety_ack_error;
    xfer_ack_next  <= risky_ack_next  or safety_ack_next;
    xfer_ack_last  <= risky_ack_last  or safety_ack_last;
    xfer_ack_size  <= risky_ack_size  or safety_ack_size;
    -------------------------------------------------------------------------------
    -- Pull Reserve Size and Last
    -------------------------------------------------------------------------------
    PULL_RSV_VAL   <= xfer_req_select when (xfer_start    = '1') else (others => '0');
    PULL_RSV_LAST  <= xfer_req_last;
    PULL_RSV_ERROR <= '0';
    PULL_RSV_SIZE  <= std_logic_vector(RESIZE(unsigned(xfer_req_size) , PULL_RSV_SIZE'length));
    -------------------------------------------------------------------------------
    -- Pull Final Size and Last
    -------------------------------------------------------------------------------
    PULL_FIN_VAL   <= ack_queue_select when (ack_queue_valid = '1' and BVALID = '1') else (others => '0');
    PULL_FIN_LAST  <= ack_queue_last;
    PULL_FIN_ERROR <= '1'              when (BRESP = AXI4_RESP_SLVERR or BRESP = AXI4_RESP_DECERR) else '0';
    PULL_FIN_SIZE  <= (others => '0')  when (BRESP = AXI4_RESP_SLVERR or BRESP = AXI4_RESP_DECERR) else
                      std_logic_vector(RESIZE(unsigned(ack_queue_size), PULL_FIN_SIZE'length));
    -------------------------------------------------------------------------------
    -- Pull Buffer Size and Last
    -------------------------------------------------------------------------------
    PULL_BUF_RESET <= xfer_req_select  when (xfer_start     = '1') else (others => '0');
    PULL_BUF_VAL   <= buf_select       when (xfer_beat_chop = '1') else (others => '0');
    PULL_BUF_LAST  <= buf_push_last;
    PULL_BUF_ERROR <= '0';
    PULL_BUF_SIZE  <= std_logic_vector(RESIZE(unsigned(buf_push_size) , PULL_BUF_SIZE'length));
end RTL;
