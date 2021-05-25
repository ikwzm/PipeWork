-----------------------------------------------------------------------------------
--!     @file    axi4_slave_read_interface.vhd
--!     @brief   AXI4 Slave Read Interface
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
                          integer := 4;
        XFER_SIZE_BITS  : --! @brief TRANSFER SIZE BITS :
                          --! 各種サイズカウンタのビット数を指定する.
                          integer := 32;
        VAL_BITS        : --! @brief VALID BITS :
                          --! XFER_BUSY、XFER_DONE、PULL_FIN_VAL、PULL_RSV_VAL信号の
                          --! ビット数を指定する.
                          integer := 1;
        BUF_DATA_WIDTH  : --! @brief BUFFER DATA WIDTH :
                          --! バッファのビット幅を指定する.
                          integer := 32;
        BUF_PTR_BITS    : --! @brief BUFFER POINTER BITS :
                          --! バッファポインタなどを表す信号のビット数を指定する.
                          integer := 8;
        ALIGNMENT_BITS  : --! @brief ALIGNMENT BITS :
                          --! アライメントサイズのビット数を指定する.
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
                          in    std_logic_vector(AXI4_ALEN_WIDTH  -1 downto 0);
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
                          out   std_logic_vector(AXI4_ADDR_WIDTH-1 downto 0);
        REQ_SIZE        : --! @brief Request Size.
                          --! 転送要求バイト数を指定する.  
                          out   std_logic_vector(XFER_SIZE_BITS -1 downto 0);
        REQ_ID          : --! @brief Request ID.
                          --! ARID の値を指定する.
                          out   std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        REQ_BURST       : --! @brief Request Burst type.
                          --! バーストタイプを指定する.  
                          --! * このモジュールでは AXI4_ABURST_INCR と AXI4_ABURST_FIXED
                          --!   のみをサポートしている.
                          out   AXI4_ABURST_TYPE;
        REQ_VAL         : --! @brief Request Valid Signal.
                          --! 上記の各種リクエスト信号が有効であることを示す.
                          --! * この信号のアサートでもってトランザクションを開始する.
                          --! * 一度この信号をアサートすると Acknowledge を返すまで、
                          --!   この信号はアサートされなくてはならない.
                          out   std_logic;
        REQ_START       : --! @brief Request Start Signal.
                          --! REQ_VAL信号がアサートされた最初のサイクルだけアサート
                          --! される.
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
                          in    std_logic_vector(XFER_SIZE_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transfer Control Signal.
    -------------------------------------------------------------------------------
        XFER_START      : --! @brief Transfer Start.
                          --! データ転送開始を指示する信号.
                          --! * 下記の各種リクエスト信号が有効であることを示す.
                          in    std_logic;
        XFER_LAST       : --! @brief Transfer Last.
                          --! 最後の転送であることを指示する信号.
                          --! * XFER_START 信号がアサートされている時のみ有効.
                          in    std_logic;
        XFER_SEL        : --! @brief Transfer Select.
                          --! XFER_BUSY、XFER_DONE、PULL_FIN_VAL、PULL_RSV_VAL 信号
                          --! の生成パターンを指定する.
                          --! * XFER_START 信号がアサートされている時のみ有効.
                          in    std_logic_vector(VAL_BITS         -1 downto 0);
        XFER_BUF_PTR    : --! @brief Transfer Write Buffer Pointer.
                          --! ライトバッファの先頭ポインタの値を指定する.
                          --! * XFER_START 信号がアサートされている時のみ有効.
                          --! * ライトバッファのこのポインタの位置からRDATAを書き込
                          --!   む.
                          in    std_logic_vector(BUF_PTR_BITS     -1 downto 0);
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
        BUF_REN         : --! @brief Buffer Write Enable.
                          --! バッファにデータをライトすることを示す.
                          out   std_logic_vector(VAL_BITS         -1 downto 0);
        BUF_DATA        : --! @brief Buffer Data.
                          --! バッファへライトするデータを出力する.
                          in    std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
        BUF_PTR         : --! @brief Buffer Write Pointer.
                          --! ライト時にデータを書き込むバッファの位置を出力する.
                          out   std_logic_vector(BUF_PTR_BITS     -1 downto 0)
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
use     PIPEWORK.AXI4_COMPONENTS.AXI4_DATA_OUTLET_PORT;
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
    constant AXI4_DATA_SIZE     : integer := CALC_DATA_SIZE(AXI4_DATA_WIDTH);
    -------------------------------------------------------------------------------
    -- 最大転送バイト数
    -------------------------------------------------------------------------------
    constant XFER_MAX_SIZE      : integer := AXI4_ALEN_WIDTH + AXI4_DATA_SIZE;
    -------------------------------------------------------------------------------
    -- 内部信号
    -------------------------------------------------------------------------------
    signal   xfer_req_addr      : std_logic_vector(AXI4_ADDR_WIDTH-1 downto 0);
    signal   xfer_req_size      : std_logic_vector(XFER_MAX_SIZE     downto 0);
    signal   identifier         : std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
    signal   burst_type         : AXI4_ABURST_TYPE;
    signal   burst_length       : std_logic_vector(AXI4_ALEN_WIDTH-1 downto 0);
    signal   word_size          : AXI4_ASIZE_TYPE;
    signal   intake_valid       : std_logic;
    signal   intake_ready       : std_logic;
    signal   intake_error       : std_logic;
    signal   xfer_none          : std_logic;
    signal   port_busy          : std_logic;
    signal   outlet_busy        : std_logic;
    signal   outlet_done        : std_logic;
    signal   curr_select        : std_logic_vector(VAL_BITS-1 downto 0);
    constant PULL_BUF_RDY_ALL0  : std_logic_vector(VAL_BITS-1 downto 0) := (others => '0');
    signal   outlet_error       : std_logic;
    signal   exit_valid         : std_logic_vector(VAL_BITS-1 downto 0);
    signal   exit_error         : std_logic;
    signal   exit_xfer_done     : std_logic;
    signal   exit_size          : std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    signal   size_error         : boolean;
    type     STATE_TYPE        is (IDLE_STATE, REQ_STATE, ACK_STATE, ERR_STATE, TURN_AR);
    signal   curr_state         : STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- ステートマシン
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
    begin
        if (RST = '1') then
                curr_state <= IDLE_STATE;
                ARREADY    <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state <= IDLE_STATE;
                ARREADY    <= '0';
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (REQ_RDY = '1' and ARVALID = '1') then
                            next_state := REQ_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                    when REQ_STATE =>
                        if (size_error = FALSE) then
                            next_state := ACK_STATE;
                        else
                            next_state := ERR_STATE;
                        end if;
                    when ACK_STATE =>
                        if (ACK_VAL = '1') then
                            next_state := TURN_AR;
                        else
                            next_state := ACK_STATE;
                        end if;
                    when ERR_STATE =>
                            next_state := TURN_AR;
                    when TURN_AR =>
                        if (port_busy = '0') then
                            next_state := IDLE_STATE;
                        else
                            next_state := TURN_AR;
                        end if;
                    when others =>
                            next_state := IDLE_STATE;
                end case;
                curr_state <= next_state;
                if (next_state = REQ_STATE) then
                    ARREADY <= '1';
                else
                    ARREADY <= '0';
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    intake_error <= '1' when (curr_state = ERR_STATE) else '0';
    intake_valid <= '1' when ((PULL_BUF_RDY and curr_select) /= PULL_BUF_RDY_ALL0) or
                             (curr_state = ERR_STATE) else '0';
    -------------------------------------------------------------------------------
    -- ARVALID='1' and ARREADY='1'の時に、各種情報をレジスタに保存しておく.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                identifier    <= (others => '0');
                burst_length  <= (others => '0');
                burst_type    <= AXI4_ABURST_FIXED;
                word_size     <= AXI4_ASIZE_1BYTE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                identifier    <= (others => '0');
                burst_length  <= (others => '0');
                burst_type    <= AXI4_ABURST_FIXED;
                word_size     <= AXI4_ASIZE_1BYTE;
            elsif (curr_state = IDLE_STATE and ARVALID = '1' and REQ_RDY = '1') then
                burst_length  <= ARLEN;
                burst_type    <= ARBURST;
                word_size     <= ARSIZE;
                identifier    <= ARID;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- xfer_req_addr : 転送要求アドレス.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                xfer_req_addr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                xfer_req_addr <= (others => '0');
            elsif (curr_state = IDLE_STATE and ARVALID = '1' and REQ_RDY = '1') then
                for i in xfer_req_addr'range loop
                    if (ARADDR'low <= i and i <= ARADDR'high) then
                        xfer_req_addr(i) <= ARADDR(i);
                    else
                        xfer_req_addr(i) <= '0';
                    end if;
                end loop;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- xfer_req_size : リードするバイト数.
    -------------------------------------------------------------------------------
    process (xfer_req_addr, burst_length, word_size)
        constant u_zero      : unsigned(              6 downto 0) := (6 downto 0 => '0');
        variable u_addr      : unsigned(              6 downto 0);
        variable dt_len      : unsigned(AXI4_ALEN_WIDTH downto 0);
        variable others_size : unsigned(XFER_MAX_SIZE   downto 0);
        variable first_size  : unsigned(              6 downto 0);
    begin
        dt_len := RESIZE(to_01(unsigned(burst_length )), dt_len'length);
        u_addr := RESIZE(to_01(unsigned(xfer_req_addr)), u_addr'length);
        if    (word_size = AXI4_ASIZE_128BYTE and AXI4_DATA_WIDTH >= 128*8) then
            first_size  := RESIZE(     not u_addr(6 downto 0),  first_size'length);
            others_size := RESIZE(dt_len & u_zero(6 downto 0), others_size'length);
        elsif (word_size = AXI4_ASIZE_64BYTE  and AXI4_DATA_WIDTH >=  64*8) then
            first_size  := RESIZE(     not u_addr(5 downto 0),  first_size'length);
            others_size := RESIZE(dt_len & u_zero(5 downto 0), others_size'length);
        elsif (word_size = AXI4_ASIZE_32BYTE  and AXI4_DATA_WIDTH >=  32*8) then
            first_size  := RESIZE(     not u_addr(4 downto 0),  first_size'length);
            others_size := RESIZE(dt_len & u_zero(4 downto 0), others_size'length);
        elsif (word_size = AXI4_ASIZE_16BYTE  and AXI4_DATA_WIDTH >=  16*8) then
            first_size  := RESIZE(     not u_addr(3 downto 0),  first_size'length);
            others_size := RESIZE(dt_len & u_zero(3 downto 0), others_size'length);
        elsif (word_size = AXI4_ASIZE_8BYTE   and AXI4_DATA_WIDTH >=   8*8) then
            first_size  := RESIZE(     not u_addr(2 downto 0),  first_size'length);
            others_size := RESIZE(dt_len & u_zero(2 downto 0), others_size'length);
        elsif (word_size = AXI4_ASIZE_4BYTE   and AXI4_DATA_WIDTH >=   4*8) then
            first_size  := RESIZE(     not u_addr(1 downto 0),  first_size'length);
            others_size := RESIZE(dt_len & u_zero(1 downto 0), others_size'length);
        elsif (word_size = AXI4_ASIZE_2BYTE   and AXI4_DATA_WIDTH >=   2*8) then
            first_size  := RESIZE(     not u_addr(0 downto 0),  first_size'length);
            others_size := RESIZE(dt_len & u_zero(0 downto 0), others_size'length);
        else
            first_size  := (others => '0');
            others_size := RESIZE(dt_len                     , others_size'length);
        end if;
        xfer_req_size <= std_logic_vector(others_size + first_size + 1);
    end process;
    -------------------------------------------------------------------------------
    -- 不正なサイズを指定された事を示すフラグ.
    -------------------------------------------------------------------------------
    size_error <= (word_size = AXI4_ASIZE_128BYTE and AXI4_DATA_WIDTH < 128*8) or
                  (word_size = AXI4_ASIZE_64BYTE  and AXI4_DATA_WIDTH <  64*8) or
                  (word_size = AXI4_ASIZE_32BYTE  and AXI4_DATA_WIDTH <  32*8) or
                  (word_size = AXI4_ASIZE_16BYTE  and AXI4_DATA_WIDTH <  16*8) or
                  (word_size = AXI4_ASIZE_8BYTE   and AXI4_DATA_WIDTH <   8*8) or
                  (word_size = AXI4_ASIZE_4BYTE   and AXI4_DATA_WIDTH <   4*8) or
                  (word_size = AXI4_ASIZE_2BYTE   and AXI4_DATA_WIDTH <   2*8);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REQ_START   <= '1' when (curr_state = REQ_STATE and size_error = FALSE) else '0';
    REQ_VAL     <= '1' when (curr_state = REQ_STATE and size_error = FALSE) or
                            (curr_state = ACK_STATE                       ) else '0';
    REQ_ADDR    <= xfer_req_addr;
    REQ_SIZE    <= std_logic_vector(resize(unsigned(xfer_req_size),XFER_SIZE_BITS));
    REQ_ID      <= identifier;
    REQ_BURST   <= burst_type;
    -------------------------------------------------------------------------------
    -- AXI4 用データ出力ポート
    -------------------------------------------------------------------------------
    OUTLET_PORT: AXI4_DATA_OUTLET_PORT           -- 
        generic map (                            -- 
            PORT_DATA_BITS  => AXI4_DATA_WIDTH , -- 
            POOL_DATA_BITS  =>  BUF_DATA_WIDTH , -- 
            TRAN_ADDR_BITS  => AXI4_ADDR_WIDTH , -- 
            TRAN_SIZE_BITS  => XFER_MAX_SIZE+1 , --
            TRAN_SEL_BITS   => XFER_SEL'length , -- 
            BURST_LEN_BITS  => AXI4_ALEN_WIDTH , -- 
            ALIGNMENT_BITS  => ALIGNMENT_BITS  , --
            PULL_SIZE_BITS  => XFER_SIZE_BITS  , --
            EXIT_SIZE_BITS  => XFER_SIZE_BITS  , --
            POOL_PTR_BITS   => BUF_PTR_BITS    , --
            TRAN_MAX_SIZE   => XFER_MAX_SIZE   , --
            USE_BURST_SIZE  => 1               , --
            CHECK_BURST_LEN => 1               , --
            QUEUE_SIZE      => 1               , --
            PORT_REGS_SIZE  => 0                 --
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
            TRAN_START      => XFER_START      , -- In  :
            TRAN_ADDR       => xfer_req_addr   , -- In  :
            TRAN_SIZE       => xfer_req_size   , -- In  :
            BURST_LEN       => burst_length    , -- In  :
            BURST_SIZE      => word_size       , -- In  :
            START_PTR       => XFER_BUF_PTR    , -- In  :
            TRAN_LAST       => XFER_LAST       , -- In  :
            TRAN_SEL        => XFER_SEL        , -- In  :
            XFER_VAL        => open            , -- Out :
            XFER_DVAL       => open            , -- Out :
            XFER_LAST       => open            , -- Out :
            XFER_NONE       => xfer_none       , -- Out :
        ---------------------------------------------------------------------------
        -- AXI4 Outlet Port Signals.
        ---------------------------------------------------------------------------
            PORT_DATA       => RDATA           , -- Out :
            PORT_STRB       => open            , -- Out :
            PORT_LAST       => RLAST           , -- Out :
            PORT_ERROR      => outlet_error    , -- Out :
            PORT_VAL        => RVALID          , -- Out :
            PORT_RDY        => RREADY          , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PULL_VAL        => PULL_BUF_VAL    , -- Out :
            PULL_LAST       => open            , -- Out :
            PULL_XFER_LAST  => open            , -- Out :
            PULL_XFER_DONE  => PULL_BUF_LAST   , -- Out :
            PULL_ERROR      => PULL_BUF_ERROR  , -- Out :
            PULL_SIZE       => PULL_BUF_SIZE   , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Size Signals.
        ---------------------------------------------------------------------------
            EXIT_VAL        => exit_valid      , -- Out :
            EXIT_LAST       => open            , -- Out :
            EXIT_XFER_LAST  => open            , -- Out :
            EXIT_XFER_DONE  => exit_xfer_done  , -- Out :
            EXIT_ERROR      => exit_error      , -- Out :
            EXIT_SIZE       => exit_size       , -- Out :
        ---------------------------------------------------------------------------
        -- Pool Buffer Interface Signals.
        ---------------------------------------------------------------------------
            POOL_REN        => BUF_REN         , -- Out :
            POOL_PTR        => BUF_PTR         , -- Out :
            POOL_DATA       => BUF_DATA        , -- In  :
            POOL_ERROR      => intake_error    , -- In  :
            POOL_VAL        => intake_valid    , -- In  :
            POOL_RDY        => intake_ready    , -- Out :
        ---------------------------------------------------------------------------
        -- Status Signals.
        ---------------------------------------------------------------------------
            POOL_BUSY       => outlet_busy     , -- Out :
            POOL_DONE       => outlet_done     , -- Out :
            BUSY            => port_busy         -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    VAL_BIT_GT_1: if (VAL_BITS > 1) generate
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_select <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_select <= (others => '0');
                elsif (XFER_START = '1') then
                    curr_select <= XFER_SEL;
                end if;
            end if;
        end process;
    end generate;
    VAL_BIT_LE_1: if (VAL_BITS <= 1) generate
        curr_select <= (others => '1');
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    XFER_BUSY  <= curr_select  when (outlet_busy  = '1') else (others => '0');
    XFER_DONE  <= curr_select  when (outlet_done  = '1') else (others => '0');
    XFER_ERROR <= (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    RID   <= identifier;
    RRESP <= AXI4_RESP_SLVERR when (outlet_error = '1') else AXI4_RESP_OKAY;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PULL_FIN_VAL   <= exit_valid;
    PULL_FIN_LAST  <= exit_xfer_done;
    PULL_FIN_ERROR <= exit_error;
    PULL_FIN_SIZE  <= exit_size;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PULL_RSV_VAL   <= exit_valid;
    PULL_RSV_LAST  <= exit_xfer_done;
    PULL_RSV_ERROR <= exit_error;
    PULL_RSV_SIZE  <= exit_size;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PULL_BUF_RESET <= XFER_SEL when (XFER_START = '1') else (others => '0');
end RTL;
