-----------------------------------------------------------------------------------
--!     @file    axi4_register_read_interface.vhd
--!     @brief   AXI4 Register Read Interface
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
--! @brief   AXI4 Register Read Interface.
-----------------------------------------------------------------------------------
entity  AXI4_REGISTER_READ_INTERFACE is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_LITE       : --! @brief AIX4-Lite MODE :
                          --! AXI4-Lite モード
                          integer range 0 to 1 := 0;
        AXI4_ADDR_WIDTH : --! @brief AIX4 ADDRESS CHANNEL ADDR WIDTH :
                          --! AXI4 リードアドレスチャネルのAWADDR信号のビット幅.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        AXI4_DATA_WIDTH : --! @brief AXI4 WRITE DATA CHANNEL DATA WIDTH :
                          --! AXI4 リードデータチャネルのRDATA信号のビット幅.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        AXI4_ID_WIDTH   : --! @brief AXI4 ID WIDTH :
                          --! AXI4 アドレスチャネルおよびライトレスポンスチャネルの
                          --! ID信号のビット幅.
                          integer := 4;
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
                          in    std_logic_vector(AXI4_ALEN_WIDTH  -1 downto 0) := (others => '0');
        ARSIZE          : --! @brief Burst size.
                          --! This signal indicates the size of each transfer in
                          --! the burst.
                          in    AXI4_ASIZE_TYPE  := (others => '0');
        ARBURST         : --! @brief Burst type.
                          --! The burst type and size infomation determine how
                          --! the address for each transfer within the burst is
                          --! calculated.
                          in    AXI4_ABURST_TYPE := (others => '0');
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
end AXI4_REGISTER_READ_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_DATA_OUTLET_PORT;
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
    -- アライメントのビット数
    -------------------------------------------------------------------------------
    function CALC_ALIGNMENT_BITS return integer is begin
        if (AXI4_DATA_WIDTH <= REGS_DATA_WIDTH) then
            return AXI4_DATA_WIDTH;
        else
            return REGS_DATA_WIDTH;
        end if;
    end function;
    constant ALIGNMENT_BITS     : integer := CALC_ALIGNMENT_BITS;
    -------------------------------------------------------------------------------
    -- デフォルトの WORD_SIZE
    -------------------------------------------------------------------------------
    function CALC_DEFAULT_WORD_SIZE return AXI4_ASIZE_TYPE is begin
        if    (AXI4_DATA_WIDTH >= 128*8) then return AXI4_ASIZE_128BYTE;
        elsif (AXI4_DATA_WIDTH >=  64*8) then return AXI4_ASIZE_64BYTE;
        elsif (AXI4_DATA_WIDTH >=  32*8) then return AXI4_ASIZE_32BYTE;
        elsif (AXI4_DATA_WIDTH >=  16*8) then return AXI4_ASIZE_16BYTE;
        elsif (AXI4_DATA_WIDTH >=   8*8) then return AXI4_ASIZE_8BYTE;
        elsif (AXI4_DATA_WIDTH >=   4*8) then return AXI4_ASIZE_4BYTE;
        elsif (AXI4_DATA_WIDTH >=   2*8) then return AXI4_ASIZE_2BYTE;
        else                                  return AXI4_ASIZE_1BYTE;
        end if;
    end function;
    constant DEFAULT_WORD_SIZE  : AXI4_ASIZE_TYPE := CALC_DEFAULT_WORD_SIZE;
    -------------------------------------------------------------------------------
    -- USE_BURST_SIZE
    -------------------------------------------------------------------------------
    function USE_BURST_SIZE  return integer is begin
        if (AXI4_LITE = 0) then return 1;
        else                    return 0;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- CHECK_BURST_LEN
    -------------------------------------------------------------------------------
    function CHECK_BURST_LEN return integer is begin
        if (AXI4_LITE = 0) then return 1;
        else                    return 0;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- PORT_QUEUE_SIZE
    -------------------------------------------------------------------------------
    function PORT_QUEUE_SIZE return integer is begin
        if (AXI4_LITE = 0) then return 1;
        else                    return 0;
        end if;
    end function;
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
    signal   burst_length       : std_logic_vector(AXI4_ALEN_WIDTH-1 downto 0);
    signal   word_size          : AXI4_ASIZE_TYPE;
    signal   xfer_beat_chop     : std_logic;
    signal   xfer_beat_valid    : std_logic;
    signal   xfer_beat_ready    : std_logic;
    signal   xfer_beat_last     : std_logic;
    signal   xfer_beat_error    : std_logic;
    signal   xfer_beat_done     : std_logic;
    signal   xfer_beat_none     : std_logic;
    signal   xfer_beat_ben      : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
    signal   xfer_beat_size     : std_logic_vector(REGS_DATA_SIZE downto 0);
    signal   rbuf_busy          : std_logic;
    signal   outlet_error       : std_logic;
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
    -- identifier : ARVALID='1' and ARREADY='1'の時に、ARIDをレジスタに保存しておく.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                identifier <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                identifier <= (others => '0');
            elsif (curr_state = IDLE and ARVALID = '1') then
                identifier <= ARID;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- AXI4_LITE = 0 の場合
    -- burst_length : ARVALID='1' and ARREADY='1'の時に、ARLEN   をレジスタに保存しておく.
    -- burst_type   : ARVALID='1' and ARREADY='1'の時に、ARBURST をレジスタに保存しておく.
    -- word_size    : ARVALID='1' and ARREADY='1'の時に、ARSIZE  をレジスタに保存しておく.
    -------------------------------------------------------------------------------
    AXI4_LITE_F: if (AXI4_LITE = 0) generate
        process (CLK, RST) begin
            if (RST = '1') then
                    burst_length <= (others => '0');
                    burst_type   <= AXI4_ABURST_FIXED;
                    word_size    <= DEFAULT_WORD_SIZE;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then 
                    burst_length <= (others => '0');
                    burst_type   <= AXI4_ABURST_FIXED;
                    word_size    <= DEFAULT_WORD_SIZE;
                elsif (curr_state = IDLE and ARVALID = '1') then
                    burst_length <= ARLEN;
                    burst_type   <= ARBURST;
                    word_size    <= ARSIZE;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- AXI4_LITE /= 0 の場合
    -- burst_length : 0
    -- burst_type   : AXI4_ABURST_FIXED
    -- word_size    : AXI4_DATA_WIDTH に基づいたサイズ
    -------------------------------------------------------------------------------
    AXI4_LITE_T: if (AXI4_LITE /= 0) generate
    begin 
        burst_length <= (others => '0');
        burst_type   <= AXI4_ABURST_FIXED;
        word_size    <= DEFAULT_WORD_SIZE;
    end generate;
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
            elsif ((AXI4_LITE /= 0 and REGS_DATA_SIZE < AXI4_DATA_SIZE) or
                   (AXI4_LITE  = 0 and burst_type = AXI4_ABURST_INCR  )) and
                  (xfer_beat_chop = '1') then
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
    xfer_beat_done  <= '1' when (xfer_beat_last = '1' or xfer_beat_error = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    OUTLET_PORT: AXI4_DATA_OUTLET_PORT           -- 
        generic map (                            -- 
            PORT_DATA_BITS  => AXI4_DATA_WIDTH , -- 
            POOL_DATA_BITS  => REGS_DATA_WIDTH , -- 
            TRAN_ADDR_BITS  => REGS_ADDR_WIDTH , -- 
            TRAN_SIZE_BITS  => XFER_MAX_SIZE+1 , --
            TRAN_SEL_BITS   => 1               , -- 
            BURST_LEN_BITS  => AXI4_ALEN_WIDTH , -- 
            ALIGNMENT_BITS  => ALIGNMENT_BITS  , --
            PULL_SIZE_BITS  => REGS_DATA_SIZE+1, --
            EXIT_SIZE_BITS  => REGS_DATA_SIZE+1, --
            POOL_PTR_BITS   => REGS_ADDR_WIDTH , --
            TRAN_MAX_SIZE   => XFER_MAX_SIZE   , --
            USE_BURST_SIZE  => USE_BURST_SIZE  , --
            CHECK_BURST_LEN => CHECK_BURST_LEN , --
            QUEUE_SIZE      => PORT_QUEUE_SIZE , -- 
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
            TRAN_START      => xfer_start      , -- In  :
            TRAN_ADDR       => xfer_req_addr   , -- In  :
            TRAN_SIZE       => xfer_req_size   , -- In  :
            BURST_LEN       => burst_length    , -- In  :
            BURST_SIZE      => word_size       , -- In  :
            START_PTR       => xfer_req_addr   , -- In  :
            TRAN_LAST       => '1'             , -- In  :
            TRAN_SEL        => "1"             , -- In  :
            XFER_VAL        => open            , -- Out :
            XFER_DVAL       => xfer_beat_ben   , -- Out :
            XFER_LAST       => open            , -- Out :
            XFER_NONE       => xfer_beat_none  , -- Out :
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
            PULL_VAL(0)     => xfer_beat_chop  , -- Out :
            PULL_LAST       => xfer_beat_last  , -- Out :
            PULL_XFER_LAST  => open            , -- Out :
            PULL_XFER_DONE  => open            , -- Out :
            PULL_ERROR      => xfer_beat_error , -- Out :
            PULL_SIZE       => xfer_beat_size  , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Size Signals.
        ---------------------------------------------------------------------------
            EXIT_VAL        => open            , -- Out :
            EXIT_LAST       => open            , -- Out :
            EXIT_XFER_LAST  => open            , -- Out :
            EXIT_XFER_DONE  => open            , -- Out :
            EXIT_ERROR      => open            , -- Out :
            EXIT_SIZE       => open            , -- Out :
        ---------------------------------------------------------------------------
        -- Pool Buffer Interface Signals.
        ---------------------------------------------------------------------------
            POOL_REN        => open            , -- Out :
            POOL_PTR        => open            , -- Out :
            POOL_ERROR      => REGS_ERR        , -- In  :
            POOL_DATA       => REGS_DATA       , -- In  :
            POOL_VAL        => xfer_beat_valid , -- In  :
            POOL_RDY        => xfer_beat_ready , -- Out :
        ---------------------------------------------------------------------------
        -- Status Signals.
        ---------------------------------------------------------------------------
            BUSY            => rbuf_busy         -- Out :
        );
    RID   <= identifier;
    RRESP <= AXI4_RESP_SLVERR when (outlet_error = '1') else AXI4_RESP_OKAY;
end RTL;
