-----------------------------------------------------------------------------------
--!     @file    axi4_register_read_interface.vhd
--!     @brief   AXI4 Register Read Interface
--!     @version 1.3.1
--!     @date    2013/2/13
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
--! @brief   AXI4 Register Read Interface.
-----------------------------------------------------------------------------------
entity  AXI4_REGISTER_READ_INTERFACE is
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
        REGS_REQ        : --! @breif レジスタアクセス要求信号.
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
end AXI4_REGISTER_READ_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.COMPONENTS.REDUCER;
use     PIPEWORK.COMPONENTS.CHOPPER;
architecture RTL of AXI4_REGISTER_READ_INTERFACE is
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
    -- レジスタインターフェース側のデータバスのバイト数の２のべき乗値.
    -------------------------------------------------------------------------------
    constant REGS_DATA_SIZE     : integer := CALC_DATA_SIZE(REGS_DATA_WIDTH);
    -------------------------------------------------------------------------------
    -- 最大転送バイト数
    -------------------------------------------------------------------------------
    constant XFER_MAX_SIZE      : integer := AXI4_ALEN_WIDTH + AXI4_DATA_SIZE;
    -------------------------------------------------------------------------------
    -- 内部信号
    -------------------------------------------------------------------------------
    signal   xfer_start         : std_logic;
    signal   xfer_error         : std_logic;
    signal   xfer_prepare       : std_logic;
    signal   xfer_req_addr      : std_logic_vector(REGS_ADDR_WIDTH-1 downto 0);
    signal   xfer_req_size      : std_logic_vector(XFER_MAX_SIZE     downto 0);
    signal   identifier         : std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
    signal   burst_type         : AXI4_ABURST_TYPE;
    signal   burst_length       : AXI4_ALEN_TYPE;
    signal   word_size          : AXI4_ASIZE_TYPE;
    signal   xfer_beat_load     : std_logic;
    signal   xfer_beat_chop     : std_logic;
    signal   xfer_beat_valid    : std_logic;
    signal   xfer_beat_ready    : std_logic;
    signal   xfer_beat_last     : std_logic;
    signal   xfer_beat_done     : std_logic;
    signal   xfer_beat_none     : std_logic;
    signal   xfer_beat_ben      : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
    signal   xfer_beat_size     : std_logic_vector(REGS_DATA_SIZE downto 0);
    constant xfer_beat_sel      : std_logic_vector(REGS_DATA_SIZE downto REGS_DATA_SIZE) := "1";
    signal   rbuf_busy          : std_logic;
    signal   size_error         : boolean;
    type     STATE_TYPE        is (IDLE, PREPARE, XFER_DATA, TURN_AR);
    signal   curr_state         : STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- ステートマシン
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
    begin
        if (RST = '1') then
                curr_state <= IDLE;
                ARREADY    <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state <= IDLE;
                ARREADY    <= '0';
            else
                case curr_state is
                    when IDLE =>
                        if (ARVALID = '1') then
                            next_state := PREPARE;
                        else
                            next_state := IDLE;
                        end if;
                    when PREPARE =>
                            next_state := XFER_DATA;
                    when XFER_DATA =>
                        if (xfer_beat_chop = '1' and xfer_beat_done = '1') then
                            next_state := TURN_AR;
                        else
                            next_state := XFER_DATA;
                        end if;
                    when TURN_AR =>
                        if (rbuf_busy = '0') then
                            next_state := IDLE;
                        else
                            next_state := TURN_AR;
                        end if;
                    when others =>
                            next_state := IDLE;
                end case;
                curr_state <= next_state;
                if (next_state = IDLE) then
                    ARREADY <= '1';
                else
                    ARREADY <= '0';
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- xfer_start    : この信号がトリガーとなっていろいろと処理を開始する.
    -------------------------------------------------------------------------------
    xfer_prepare <= '1' when (curr_state = PREPARE) else '0';
    xfer_start   <= '1' when (curr_state = PREPARE and size_error = FALSE) else '0';
    xfer_error   <= '1' when (curr_state = PREPARE and size_error = TRUE ) else '0';
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
            elsif (curr_state = IDLE and ARVALID = '1') then
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
            elsif (curr_state = IDLE and ARVALID = '1') then
                for i in xfer_req_addr'range loop
                    if (ARADDR'low <= i and i <= ARADDR'high) then
                        xfer_req_addr(i) <= ARADDR(i);
                    else
                        xfer_req_addr(i) <= '0';
                    end if;
                end loop;
            elsif (burst_type = AXI4_ABURST_INCR and xfer_beat_chop = '1') then
                xfer_req_addr <= std_logic_vector(unsigned(xfer_req_addr) + unsigned(xfer_beat_size));
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
    REGS_ADDR       <= xfer_req_addr;
    REGS_BEN        <= xfer_beat_ben;
    REGS_REQ        <= '1' when (curr_state = XFER_DATA and xfer_beat_ready = '1') else '0';
    xfer_beat_valid <= '1' when (curr_state = XFER_DATA and REGS_ACK        = '1') else '0';
    xfer_beat_chop  <= '1' when (xfer_beat_valid = '1'  and xfer_beat_ready = '1') else '0';
    xfer_beat_done  <= '1' when (xfer_beat_last  = '1'  or  REGS_ERR        = '1') else '0';
    -------------------------------------------------------------------------------
    -- xfer_beat_ben  : バイトイネーブル信号.
    -- xfer_beat_size : １ワード毎のリードバイト数.
    -- xfer_beat_last : 最後のワードであることを示すフラグ.
    -------------------------------------------------------------------------------
    BEN: CHOPPER
        generic map (
            BURST           => 1                     ,
            MIN_PIECE       => REGS_DATA_SIZE        ,
            MAX_PIECE       => REGS_DATA_SIZE        ,
            MAX_SIZE        => XFER_MAX_SIZE         ,
            ADDR_BITS       => xfer_req_addr'length  ,
            SIZE_BITS       => xfer_req_size'length  ,
            COUNT_BITS      => 1                     ,
            PSIZE_BITS      => xfer_beat_size'length ,
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
            ADDR            => xfer_req_addr         , -- In  :
            SIZE            => xfer_req_size         , -- In  :
            SEL             => xfer_beat_sel         , -- In  :
            LOAD            => xfer_prepare          , -- In  :
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
            NEXT_NONE       => xfer_beat_none        , -- Out :
            NEXT_LAST       => open                  , -- Out :
        ---------------------------------------------------------------------------
        -- １ワードのバイト数
        ---------------------------------------------------------------------------
            PSIZE           => xfer_beat_size        , -- Out :
            NEXT_PSIZE      => open                  , -- Out :
        ---------------------------------------------------------------------------
        -- バイトイネーブル信号
        ---------------------------------------------------------------------------
            VALID           => xfer_beat_ben         , -- Out :
            NEXT_VALID      => open                    -- Out :
        );
    -------------------------------------------------------------------------------
    -- リードバッファ
    -------------------------------------------------------------------------------
    RBUF: block
        constant WORD_BITS      : integer := 8;
        constant ENBL_BITS      : integer := 1;
        constant I_WIDTH        : integer := REGS_DATA_WIDTH/WORD_BITS;
        constant O_WIDTH        : integer := AXI4_DATA_WIDTH/WORD_BITS;
        constant done           : std_logic := '0';
        constant flush          : std_logic := '0';
        signal   offset         : std_logic_vector(O_WIDTH-1 downto 0);
        signal   init_pos       : unsigned(AXI4_DATA_SIZE downto 0);
        signal   curr_pos       : unsigned(AXI4_DATA_SIZE downto 0);
        signal   next_pos       : unsigned(AXI4_DATA_SIZE downto 0);
        signal   word_bytes     : integer range 1 to 128;
        signal   word_last      : boolean;
        signal   r_resp         : AXI4_RESP_TYPE;
        signal   r_valid        : std_logic;
        signal   r_last         : std_logic;
        signal   r_busy         : std_logic;
        signal   r_length       : unsigned(AXI4_ALEN_WIDTH-1 downto 0);
        signal   r_state        : std_logic_vector(1 downto 0);
        constant R_IDLE         : std_logic_vector(1 downto 0) := "00";
        constant R_XFER         : std_logic_vector(1 downto 0) := "11";
        constant R_SKIP         : std_logic_vector(1 downto 0) := "01";
        constant R_DONE         : std_logic_vector(1 downto 0) := "10";
        signal   b_valid        : std_logic;
        signal   b_ready        : std_logic;
        signal   b_done         : std_logic;
        signal   b_clear        : std_logic;
    begin
        ---------------------------------------------------------------------------
        -- リードバッファ用のステートマシン.
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    r_state <= R_IDLE;
                    r_resp  <= AXI4_RESP_OKAY;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then 
                    r_state <= R_IDLE;
                    r_resp  <= AXI4_RESP_OKAY;
                else
                    case r_state is
                        when R_IDLE =>
                            if    (xfer_start = '1') then
                                r_state <= R_XFER;
                                r_resp  <= AXI4_RESP_OKAY;
                            elsif (xfer_error = '1') then
                                r_state <= R_SKIP;
                                r_resp  <= AXI4_RESP_SLVERR;
                            else
                                r_state <= R_IDLE;
                                r_resp  <= AXI4_RESP_OKAY;
                            end if;
                        when R_XFER =>
                            if    (r_valid = '1' and RREADY = '1' and r_last = '1') then
                                r_state <= R_DONE;
                            elsif (r_valid = '1' and RREADY = '1' and b_done = '1') then
                                r_state <= R_SKIP;
                            else
                                r_state <= R_XFER;
                            end if;
                        when R_SKIP =>
                            if    (r_valid = '1' and RREADY = '1' and r_last = '1') then
                                r_state <= R_DONE;
                            else
                                r_state <= R_SKIP;
                            end if;
                        when R_DONE =>
                                r_state <= R_IDLE;
                        when others =>
                                r_state <= R_IDLE;
                    end case;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- リードバッファが動作中であることを示すフラグ.  
        -- curr_state が TURN_AR から抜け出して IDLE に戻るめに使う.  
        -- １クロック早めに(r_state = R_DONE を含んでいない)この信号をネゲートして
        -- いること注意.
        ---------------------------------------------------------------------------
        rbuf_busy <= '1' when (r_state = R_XFER or r_state = R_SKIP) else '0';
        ---------------------------------------------------------------------------
        -- 転送の最後に B:REDUCER を初期化してしまうためのクリア信号.
        -- これが無いと、B:REDUCER 内部にデータが残ってしまう.
        ---------------------------------------------------------------------------
        b_clear   <= '1' when (r_state = R_DONE or CLR = '1') else '0';
        ---------------------------------------------------------------------------
        -- RVALID の内部信号
        ---------------------------------------------------------------------------
        r_valid   <= '1' when (r_state = R_XFER and b_valid = '1') or
                              (r_state = R_SKIP) else '0';
        ---------------------------------------------------------------------------
        -- r_length : バースト長カウンタ.
        -- r_last   : 最後の転送である事を示すフラグ.
        ---------------------------------------------------------------------------
        process (CLK, RST)
            variable next_length : unsigned(AXI4_ALEN_WIDTH-1 downto 0);
        begin
            if (RST = '1') then
                    r_length <= (others => '0');
                    r_last   <= '1';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then 
                    r_length <= (others => '0');
                    r_last   <= '1';
                else
                    if    (xfer_prepare = '1') then
                        next_length := unsigned(burst_length);
                    elsif (r_valid = '1' and RREADY = '1' and r_last = '0') then
                        next_length := r_length - 1;
                    else
                        next_length := r_length;
                    end if;
                    if (next_length > 0) then
                        r_length <= next_length;
                        r_last   <= '0';
                    else
                        r_length <= (others => '0');
                        r_last   <= '1';
                    end if;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- init_pos : 出力するバイト位置(curr_pos)の初期値.
        -- offset   : バッファの使用開始時に設定するオフセット量.
        ---------------------------------------------------------------------------
        process (xfer_req_addr)
            variable addr : unsigned(AXI4_DATA_SIZE downto 0);
        begin
            for i in addr'range loop
                if (i < AXI4_DATA_SIZE and xfer_req_addr(i) = '1') then
                    addr(i) := '1';
                else
                    addr(i) := '0';
                end if;
            end loop;
            init_pos <= addr;
            for i in offset'range loop
                if (i < addr) then
                    offset(i) <= '1';
                else
                    offset(i) <= '0';
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- curr_pos   : 現在出力しているバイト位置.
        -- word_bytes : 一回の転送で何バイト転送するかを示す.
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_pos   <= (others => '0');
                    word_bytes <= 1;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then 
                    curr_pos   <= (others => '0');
                    word_bytes <= 1;
                elsif (xfer_prepare = '1') then
                    curr_pos   <= init_pos;
                    case word_size is
                        when AXI4_ASIZE_128BYTE => word_bytes <= 128;
                        when AXI4_ASIZE_64BYTE  => word_bytes <=  64;
                        when AXI4_ASIZE_32BYTE  => word_bytes <=  32;
                        when AXI4_ASIZE_16BYTE  => word_bytes <=  16;
                        when AXI4_ASIZE_8BYTE   => word_bytes <=   8;
                        when AXI4_ASIZE_4BYTE   => word_bytes <=   4;
                        when AXI4_ASIZE_2BYTE   => word_bytes <=   2;
                        when AXI4_ASIZE_1BYTE   => word_bytes <=   1;
                        when others             => word_bytes <=   1;
                    end case;
                else
                    curr_pos   <= next_pos;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- next_pos  : 次に出力する予定のバイト位置.
        -- word_last : バイト位置が１ワードの最後の位置であることを示すフラグ.
        ---------------------------------------------------------------------------
        process(curr_pos, word_bytes, r_valid, RREADY)
            variable temp_pos : unsigned(AXI4_DATA_SIZE downto 0);
        begin
            if (r_valid = '1' and RREADY = '1') then
                temp_pos := curr_pos + word_bytes;
            else
                temp_pos := curr_pos;
            end if;
            if (to_01(temp_pos) >= 2**AXI4_DATA_SIZE) then
                next_pos  <= (others => '0');
                word_last <= TRUE;
            else
                next_pos  <= temp_pos;
                word_last <= FALSE;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- B:REDUCER からデータを取り出すための信号.
        ---------------------------------------------------------------------------
        b_ready <= '1' when (r_valid = '1' and RREADY = '1' and word_last) else '0';
        ---------------------------------------------------------------------------
        -- 内部バッファ 兼 幅変換 兼 バイトレーン調整 回路
        ---------------------------------------------------------------------------
        B: REDUCER
            generic map (
                WORD_BITS       => WORD_BITS      ,
                ENBL_BITS       => ENBL_BITS      ,
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
                CLR             => b_clear        , -- In  :
            -----------------------------------------------------------------------
            -- 各種制御信号
            -----------------------------------------------------------------------
                START           => xfer_start     , -- In  :
                OFFSET          => offset         , -- In  :
                DONE            => done           , -- In  :
                FLUSH           => flush          , -- In  :
                BUSY            => r_busy         , -- Out :
                VALID           => open           , -- Out :
            -----------------------------------------------------------------------
            -- 入力側 I/F
            -----------------------------------------------------------------------
                I_DATA          => REGS_DATA      , -- In  :
                I_ENBL          => xfer_beat_ben  , -- In  :
                I_DONE          => xfer_beat_done , -- In  :
                I_FLUSH         => flush          , -- In  :
                I_VAL           => xfer_beat_valid, -- In  :
                I_RDY           => xfer_beat_ready, -- Out :
            -----------------------------------------------------------------------
            -- 出力側 I/F
            -----------------------------------------------------------------------
                O_DATA          => RDATA          , -- Out :
                O_ENBL          => open           , -- Out :
                O_DONE          => b_done         , -- Out :
                O_FLUSH         => open           , -- Out :
                O_VAL           => b_valid        , -- Out :
                O_RDY           => b_ready          -- In  :
        );
        RVALID <= r_valid;
        RLAST  <= r_last;
        RRESP  <= r_resp;
        RID    <= identifier;
    end block;
end RTL;
