-----------------------------------------------------------------------------------
--!     @file    axi4_slave_read_interface.vhd
--!     @brief   AXI4 Slave Read Interface
--!     @version 1.5.0
--!     @date    2013/4/16
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
--! @brief   AXI4 Slave Read Interface.
-----------------------------------------------------------------------------------
entity  AXI4_SLAVE_READ_INTERFACE is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 ライトアドレスチャネルのAWADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 READ DATA CHANNEL DATA WIDTH :
                          --! AXI4 ライトデータチャネルのWDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびライトレスポンスチャネルの
                          --! ID信号のビット幅.
                          integer range 1 to AXI4_ID_MAX_WIDTH;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! 各種サイズカウンタのビット数を指定する.
                          integer := 32;
        BUF_DATA_WIDTH  : --! @brief BUFFER DATA WIDTH :
                          --! バッファのビット幅を指定する.
                          integer := 32;
        BUF_PTR_BITS    : --! @brief BUFFER POINTER BITS :
                          --! バッファポインタなどを表す信号のビット数を指定する.
                          integer := 8
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
    -------------------------------------------------------------------------------
    -- Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_ADDR        : --! @brief Request Address.
                          --! 転送開始アドレスを指定する.  
                          out   std_logic_vector(AXI4_ADDR_WIDTH  -1 downto 0);
        REQ_ID          : --! @brief Request ID.
                          --! ARID の値を指定する.
                          out   std_logic_vector(AXI4_ID_WIDTH    -1 downto 0);
        REQ_BURST       : --! @brief Request Burst type.
                          --! バーストタイプを指定する.  
                          --! * このモジュールでは AXI4_ABURST_INCR と AXI4_ABURST_FIXED
                          --!   のみをサポートしている.
                          out   AXI4_ABURST_TYPE;
        REQ_BUF_PTR     : --! @brief Request Write Buffer Pointer.
                          --! ライトバッファの先頭ポインタの値を指定する.
                          --! * ライトバッファのこのポインタの位置からRDATAを書き込
                          --!   む.
                          out   std_logic_vector(BUF_PTR_BITS     -1 downto 0);
        REQ_FIRST       : --! @brief Request First Transaction.
                          --! 最初のトランザクションであることを示す.
                          --! * REQ_FIRST=1の場合、内部状態を初期化してからトランザ
                          --!   クションを開始する.
                          out   std_logic;
        REQ_LAST        : --! @brief Request Last Transaction.
                          --! 最後のトランザクションであることを示す.
                          --! * REQ_LAST=1の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_LAST 信号をア
                          --!   サートする.
                          --! * REQ_LAST=0の場合、Acknowledge を返す際に、すべての
                          --!   トランザクションが終了していると、ACK_NEXT 信号をア
                          --!   サートする.
                          out   std_logic;
        REQ_VAL         : --! @brief Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          out   std_logic;
        REQ_RDY         : --! @brief Request Ready Signal.
                          --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                          in    std_logic;
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
                          in    std_logic;
        ACK_NEXT        : --! @brief Acknowledge with need Next transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=0 の場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        ACK_LAST        : --! @brief Acknowledge with Last transaction.
                          --! すべてのトランザクションが終了かつ REQ_LAST=1 の場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        ACK_ERROR       : --! @brief Acknowledge with Error.
                          --! トランザクション中になんらかのエラーが発生した場合、
                          --! この信号がアサートされる.
                          in    std_logic;
        ACK_SIZE        : --! @brief Acknowledge transfer size.
                          --! 転送するバイト数を示す.
                          --! REQ_ADDR、REQ_SIZE、REQ_BUF_PTRなどは、この信号で示さ
                          --! れるバイト数分を加算/減算すると良い.
                          in    std_logic_vector(SIZE_BITS        -1 downto 0);
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
        VALVE_OPEN      : --! @brief Valve Open.
                          out   std_logic;
    -------------------------------------------------------------------------------
    -- Reserve Size Signals.
    -------------------------------------------------------------------------------
        RESV_VAL        : --! @brief Reserve Valid.
                          --! RESV_LAST/RESV_ERROR/RESV_SIZEが有効であることを示す.
                          out   std_logic;
        RESV_LAST       : --! @brief Reserve Last.
                          --! 最後の転送"する予定"である事を示すフラグ.
                          out   std_logic;
        RESV_ERROR      : --! @brief Reserve Error.
                          --! 転送"する予定"がエラーだった事を示すフラグ.
                          out   std_logic;
        RESV_SIZE       : --! @brief Reserve Size.
                          --! 転送"する予定"のバイト数を出力する.
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PULL_VAL        : --! @brief Pull Valid.
                          --! PULL_LAST/PULL_ERROR/PULL_SIZEが有効であることを示す.
                          out   std_logic;
        PULL_LAST       : --! @brief Pull Last.
                          --! 最後の転送"した事"を示すフラグ.
                          out   std_logic;
        PULL_ERROR      : --! @brief Reserve Error.
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out   std_logic;
        PULL_SIZE       : --! @brief Reserve Size.
                          --! 転送"した"バイト数を出力する.
                          out   std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Read Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_REN         : --! @brief Buffer Write Enable.
                          --! バッファにデータをライトすることを示す.
                          out   std_logic;
        BUF_BEN         : --! @brief Buffer Byte Enable.
                          --! バッファにデータをライトする際のバイトイネーブル信号.
                          --! * BUF_WEN='1'の場合にのみ有効.
                          --! * BUF_WEN='0'の場合のこの信号の値は不定.
                          out   std_logic_vector(BUF_DATA_WIDTH/8 -1 downto 0);
        BUF_DATA        : --! @brief Buffer Data.
                          --! バッファへライトするデータを出力する.
                          in    std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
        BUF_PTR         : --! @brief Buffer Write Pointer.
                          --! ライト時にデータを書き込むバッファの位置を出力する.
                          out   std_logic_vector(BUF_PTR_BITS     -1 downto 0);
        BUF_RDY         : --! @brief Buffer Write Ready.
                          --! バッファにデータを書き込み可能な事をを示す.
                          in    std_logic
    );
end AXI4_SLAVE_READ_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     PIPEWORK.COMPONENTS.POOL_OUTLET_PORT;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_DATA_PORT;
architecture RTL of AXI4_SLAVE_READ_INTERFACE is
    -------------------------------------------------------------------------------
    -- データバスのバイト数の２のべき乗値を計算する関数.
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
    -------------------------------------------------------------------------------
    -- AXI4 データバスのバイト数の２のべき乗値.
    -------------------------------------------------------------------------------
    constant AXI4_DATA_SIZE : integer := CALC_DATA_SIZE(AXI4_DATA_WIDTH);
    -------------------------------------------------------------------------------
    -- レジスタインターフェース側のデータバスのバイト数の２のべき乗値.
    -------------------------------------------------------------------------------
    constant BUF_DATA_SIZE  : integer := CALC_DATA_SIZE( BUF_DATA_WIDTH);
    -------------------------------------------------------------------------------
    -- 最大転送バイト数
    -------------------------------------------------------------------------------
    constant XFER_MAX_SIZE  : integer := AXI4_ALEN_WIDTH + AXI4_DATA_SIZE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   x_start        : std_logic;
    signal   x_size         : std_logic_vector(XFER_MAX_SIZE  downto 0);
    signal   x_ptr          : std_logic_vector(BUF_PTR_BITS-1 downto 0);
    signal   x_last         : std_logic;
    constant x_xfer_sel     : std_logic_vector(0 downto 0) := "1";
    constant x_beat_sel     : std_logic_vector(XFER_MAX_SIZE downto XFER_MAX_SIZE) := "1";
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   i_busy         : std_logic;
    signal   i_chop         : std_logic;
    signal   i_valid        : std_logic;
    signal   i_ready        : std_logic;
    signal   i_error        : std_logic;
    signal   i_last         : std_logic;
    signal   i_none         : std_logic;
    signal   i_size         : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   i_ben          : std_logic_vector(BUF_DATA_WIDTH/8-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   o_pull_valid   : std_logic;
    signal   o_pull_last    : std_logic;
    signal   o_pull_error   : std_logic;
    signal   o_pull_size    : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   r_data         : std_logic_vector(AXI4_DATA_WIDTH  -1 downto 0);
    signal   r_strb         : std_logic_vector(AXI4_DATA_WIDTH/8-1 downto 0);
    signal   r_size         : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   r_user         : std_logic_vector(0 downto 0);
    signal   r_last         : std_logic;
    signal   r_error        : std_logic;
    signal   r_valid        : std_logic;
    signal   r_ready        : std_logic;
    signal   r_busy         : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   o_error        : std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PULL_VAL   <= o_pull_valid;
    PULL_LAST  <= o_pull_last;
    PULL_ERROR <= o_pull_error;
    PULL_SIZE  <= o_pull_size;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    RESV_VAL   <= o_pull_valid;
    RESV_LAST  <= o_pull_last;
    RESV_ERROR <= o_pull_error;
    RESV_SIZE  <= o_pull_size;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_chop     <= '1' when (i_valid = '1' and i_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- i_ben  : バイトイネーブル信号.
    -- i_size : １ワード毎のリードバイト数.
    -- i_last : 最後のワードであることを示すフラグ.
    -------------------------------------------------------------------------------
    BEN: CHOPPER
        generic map (
            BURST           => 1               ,
            MIN_PIECE       => BUF_DATA_SIZE   ,
            MAX_PIECE       => BUF_DATA_SIZE   ,
            MAX_SIZE        => XFER_MAX_SIZE   ,
            ADDR_BITS       => x_ptr'length    ,
            SIZE_BITS       => x_size'length   ,
            COUNT_BITS      => 1               ,
            PSIZE_BITS      => i_size'length   ,
            GEN_VALID       => 1
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- 各種初期値
        ---------------------------------------------------------------------------
            ADDR            => x_ptr           , -- In  :
            SIZE            => x_size          , -- In  :
            SEL             => x_beat_sel      , -- In  :
            LOAD            => x_start         , -- In  :
        ---------------------------------------------------------------------------
        -- 制御信号
        ---------------------------------------------------------------------------
            CHOP            => i_chop          , -- In  :
        ---------------------------------------------------------------------------
        -- ピースカウンタ/フラグ出力
        ---------------------------------------------------------------------------
            COUNT           => open            , -- Out :
            NONE            => open            , -- Out :
            LAST            => i_last          , -- Out :
            NEXT_NONE       => i_none          , -- Out :
            NEXT_LAST       => open            , -- Out :
        ---------------------------------------------------------------------------
        -- １ワードのバイト数
        ---------------------------------------------------------------------------
            PSIZE           => i_size          , -- Out :
            NEXT_PSIZE      => open            , -- Out :
        ---------------------------------------------------------------------------
        -- バイトイネーブル信号
        ---------------------------------------------------------------------------
            VALID           => i_ben           , -- Out :
            NEXT_VALID      => open              -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O: POOL_OUTLET_PORT                          -- 
        generic map (                            -- 
            UNIT_BITS       => 8               , --
            WORD_BITS       => 8               , --
            PORT_DATA_BITS  => AXI4_DATA_WIDTH , --
            POOL_DATA_BITS  => BUF_DATA_WIDTH  , --
            PORT_PTR_BITS   => AXI4_ADDR_WIDTH , --
            POOL_PTR_BITS   => BUF_PTR_BITS    , --
            SEL_BITS        => 1               , --
            SIZE_BITS       => SIZE_BITS       , --
            POOL_SIZE_VALID => 1               , --
            QUEUE_SIZE      => 0                 -- 
        )                                        -- 
        port map (                               -- 
        -------------------------------------------------------------------------------
        -- クロック&リセット信号
        -------------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        -------------------------------------------------------------------------------
        -- Control Signals.
        -------------------------------------------------------------------------------
            START           => x_start         , -- In  :
            START_POOL_PTR  => x_ptr           , -- In  :
            START_PORT_PTR  => ARADDR          , -- In  :
            XFER_LAST       => x_last          , -- In  :
            XFER_SEL        => x_xfer_sel      , -- In  :
        -------------------------------------------------------------------------------
        -- Outlet Port Signals.
        -------------------------------------------------------------------------------
            PORT_DATA       => r_data          , -- Out :
            PORT_DVAL       => r_strb          , -- Out :
            PORT_ERROR      => r_error         , -- Out :
            PORT_LAST       => r_last          , -- Out :
            PORT_SIZE       => r_size          , -- Out :
            PORT_VAL        => r_valid         , -- Out :
            PORT_RDY        => r_ready         , -- In  :
        -------------------------------------------------------------------------------
        -- Pull Size Signals.
        -------------------------------------------------------------------------------
            PULL_VAL(0)     => o_pull_valid    , -- Out :
            PULL_LAST       => o_pull_last     , -- Out :
            PULL_ERROR      => o_pull_error    , -- Out :
            PULL_SIZE       => o_pull_size     , -- Out :
        -------------------------------------------------------------------------------
        -- Pool Buffer Interface Signals.
        -------------------------------------------------------------------------------
            POOL_REN(0)     => BUF_REN         , -- Out :
            POOL_PTR        => BUF_PTR         , -- Out :
            POOL_DATA       => BUF_DATA        , -- In  :
            POOL_ERROR      => i_error         , -- In  :
            POOL_DVAL       => i_ben           , -- In  :
            POOL_SIZE       => i_size          , -- In  :
            POOL_LAST       => i_last          , -- In  :
            POOL_VAL        => i_valid         , -- In  :
            POOL_RDY        => i_ready         , -- Out :
        -------------------------------------------------------------------------------
        -- Status Signals.
        -------------------------------------------------------------------------------
            BUSY            => i_busy            -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    R: AXI4_DATA_PORT                            -- 
        generic map (                            -- 
            DATA_BITS       => AXI4_DATA_WIDTH , --
            ADDR_BITS       => AXI4_ADDR_WIDTH , --
            SIZE_BITS       => SIZE_BITS       , --
            USER_BITS       => 1               , --
            ALEN_BITS       => AXI4_ALEN_WIDTH , --
            USE_ASIZE       => 1               , --
            I_REGS_SIZE     => 0               , --
            O_REGS_SIZE     => 0                 --
        )                                        -- 
        port map (                               -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            START           => x_start         , -- In  :
            ASIZE           => ARSIZE          , -- In  :
            ALEN            => ARLEN           , -- In  :
            ADDR            => ARADDR          , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Port Signals.
        ---------------------------------------------------------------------------
            I_DATA          => r_data          , -- In  :
            I_STRB          => r_strb          , -- In  :
            I_SIZE          => r_size          , -- In  :
            I_USER          => r_user          , -- In  :
            I_LAST          => r_last          , -- In  :
            I_ERROR         => r_error         , -- In  :
            I_VALID         => r_valid         , -- In  :
            I_READY         => r_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Port Signals.
        ---------------------------------------------------------------------------
            O_DATA          => RDATA           , -- Out :
            O_STRB          => open            , -- Out :
            O_SIZE          => open            , -- Out :
            O_USER          => open            , -- Out :
            O_ERROR         => o_error         , -- Out :
            O_LAST          => RLAST           , -- Out :
            O_VALID         => RVALID          , -- Out :
            O_READY         => RREADY          , -- In  :
        ---------------------------------------------------------------------------
        -- Status Signals.
        ---------------------------------------------------------------------------
            BUSY            => r_busy            -- Out :
        );
    RRESP <= AXI4_RESP_SLVERR when (o_error = '1') else AXI4_RESP_OKAY;
end RTL;
