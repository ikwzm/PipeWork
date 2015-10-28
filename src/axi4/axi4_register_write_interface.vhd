-----------------------------------------------------------------------------------
--!     @file    axi4_register_write_interface.vhd
--!     @brief   AXI4 Register Write Interface
--!     @version 1.5.8
--!     @date    2015/9/20
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2015 Ichiro Kawazome
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
--! @brief   AXI4 Register Write Interface.
-----------------------------------------------------------------------------------
entity  AXI4_REGISTER_WRITE_INTERFACE is
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
                          in    std_logic_vector(AXI4_ALEN_WIDTH  -1 downto 0);
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
end AXI4_REGISTER_WRITE_INTERFACE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.COMPONENTS.REDUCER;
architecture RTL of AXI4_REGISTER_WRITE_INTERFACE is
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
    -- 内部信号
    -------------------------------------------------------------------------------
    signal   xfer_req_addr      : std_logic_vector(REGS_ADDR_WIDTH-1 downto 0);
    signal   wbuf_enable        : std_logic;
    signal   wbuf_intake        : std_logic;
    signal   wbuf_busy          : std_logic;
    signal   wbuf_valid         : std_logic;
    signal   wbuf_ready         : std_logic;
    signal   wbuf_start         : std_logic;
    signal   wbuf_offset        : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
    constant wbuf_shift         : std_logic_vector(REGS_DATA_WIDTH/8   downto REGS_DATA_WIDTH/8) := "0";
    constant wbuf_flush         : std_logic := '0';
    constant wbuf_done          : std_logic := '0';
    constant regs_enable        : std_logic := '1';
    signal   regs_valid         : std_logic;
    signal   regs_ready         : std_logic;
    signal   regs_last          : std_logic;
    signal   burst_type         : AXI4_ABURST_TYPE;
    type     STATE_TYPE        is (IDLE, XFER_DATA, SKIP_ERR, RESP_ERR, RESP_OK);
    signal   curr_state         : STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- ステートマシン
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
    begin
        if (RST = '1') then
                curr_state  <= IDLE;
                AWREADY     <= '0';
                BVALID      <= '0';
                BRESP       <= AXI4_RESP_OKAY;
                BID         <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                curr_state  <= IDLE;
                AWREADY     <= '0';
                BVALID      <= '0';
                BRESP       <= AXI4_RESP_OKAY;
                BID         <= (others => '0');
            else
                case curr_state is
                    when IDLE =>
                        if (AWVALID = '1') then
                            next_state := XFER_DATA;
                        else
                            next_state := IDLE;
                        end if;
                    when XFER_DATA =>
                        if (regs_valid = '1' and REGS_ACK = '1') then
                            if    (regs_last = '1' and REGS_ERR = '1') then
                                next_state := RESP_ERR;
                            elsif (regs_last = '1' and REGS_ERR = '0') then
                                next_state := RESP_OK;
                            elsif (regs_last = '0' and REGS_ERR = '1') then
                                next_state := SKIP_ERR;
                            else
                                next_state := XFER_DATA;
                            end if;
                        else
                                next_state := XFER_DATA;
                        end if;
                    when SKIP_ERR =>
                        if (regs_valid = '1' and regs_last = '1') then
                            next_state := RESP_ERR;
                        else
                            next_state := SKIP_ERR;
                        end if;
                    when RESP_ERR =>
                        if (BREADY = '1') then
                            next_state := IDLE;
                        else
                            next_state := RESP_ERR;
                        end if;
                    when RESP_OK  =>
                        if (BREADY = '1') then
                            next_state := IDLE;
                        else
                            next_state := RESP_OK;
                        end if;
                    when others =>
                            next_state := IDLE;
                end case;
                curr_state <= next_state;
                if (next_state = IDLE) then
                    AWREADY <= '1';
                else
                    AWREADY <= '0';
                end if;
                if (next_state = RESP_OK or next_state = RESP_ERR) then
                    BVALID  <= '1';
                else
                    BVALID  <= '0';
                end if;
                if (next_state = RESP_ERR) then
                    BRESP   <= AXI4_RESP_SLVERR;
                else
                    BRESP   <= AXI4_RESP_OKAY;
                end if;
                if (curr_state = IDLE and AWVALID = '1') then
                    BID     <= AWID;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- アドレスカウンタ
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable temp_addr : unsigned(xfer_req_addr'range);
    begin
        if (RST = '1') then
                xfer_req_addr  <= (others => '0');
                burst_type <= AXI4_ABURST_FIXED;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then 
                xfer_req_addr  <= (others => '0');
                burst_type <= AXI4_ABURST_FIXED;
            elsif (curr_state = IDLE and AWVALID = '1') then
                for i in xfer_req_addr'range loop
                    if (AWADDR'low <= i and i <= AWADDR'high) then
                        xfer_req_addr(i) <= AWADDR(i);
                    else
                        xfer_req_addr(i) <= '0';
                    end if;
                end loop;
                burst_type <= AWBURST;
            elsif (burst_type = AXI4_ABURST_INCR and
                   regs_valid = '1' and regs_ready = '1') then
                for i in xfer_req_addr'range loop
                    if (i >= REGS_DATA_SIZE) then
                        temp_addr(i) := xfer_req_addr(i);
                    else
                        temp_addr(i) := '0';
                    end if;
                end loop;
                xfer_req_addr <= std_logic_vector(temp_addr + 2**REGS_DATA_SIZE);
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    REGS_ADDR   <= xfer_req_addr;
    REGS_REQ    <= '1' when (curr_state = XFER_DATA and regs_valid = '1') else '0';
    regs_ready  <= '1' when (curr_state = XFER_DATA and REGS_ACK   = '1') or
                            (curr_state = SKIP_ERR                      ) else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                wbuf_intake <= '0';
        elsif (CLK'event and CLK = '1') then
            if    (CLR = '1') then
                wbuf_intake <= '0';
            elsif (wbuf_start = '1') then
                wbuf_intake <= '1';
            elsif (curr_state = IDLE) or
                  (WVALID = '1' and WLAST = '1' and wbuf_ready = '1') then
                wbuf_intake <= '0';
            end if;
        end if;
    end process;
    wbuf_start  <= '1' when (curr_state = IDLE and AWVALID = '1' ) else '0';
    wbuf_enable <= '1' when (wbuf_start = '1' or wbuf_intake ='1') else '0';
    -------------------------------------------------------------------------------
    -- wbuf_offset : 
    -------------------------------------------------------------------------------
    process (AWADDR)
        variable addr : unsigned(REGS_DATA_SIZE downto 0);
    begin
        for i in addr'range loop
            if (i < REGS_DATA_SIZE and AWADDR(i) = '1') then
                addr(i) := '1';
            else
                addr(i) := '0';
            end if;
        end loop;
        for i in wbuf_offset'range loop
            if (i < addr) then
                wbuf_offset(i) <= '1';
            else
                wbuf_offset(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- ライトデータバッファ
    -------------------------------------------------------------------------------
    WBUF: REDUCER                                  -- 
        generic map (                              -- 
            WORD_BITS       => 8                 , -- 
            STRB_BITS       => 1                 , -- 
            I_WIDTH         => AXI4_DATA_WIDTH/8 , -- 
            O_WIDTH         => REGS_DATA_WIDTH/8 , -- 
            QUEUE_SIZE      => 0                 , -- 
            VALID_MIN       => 0                 , -- 
            VALID_MAX       => 0                 , -- 
            O_VAL_SIZE      => REGS_DATA_WIDTH/8 , -- 
            O_SHIFT_MIN     => wbuf_shift'low    , -- 
            O_SHIFT_MAX     => wbuf_shift'high   , -- 
            I_JUSTIFIED     => 0                 , -- 
            FLUSH_ENABLE    => 0                   -- 
        )                                          -- 
        port map (                                 -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK               , -- In  :
            RST             => RST               , -- In  :
            CLR             => CLR               , -- In  :
        ---------------------------------------------------------------------------
        -- 各種制御信号
        ---------------------------------------------------------------------------
            START           => wbuf_start        , -- In  :
            OFFSET          => wbuf_offset       , -- In  :
            DONE            => wbuf_done         , -- In  :
            FLUSH           => wbuf_flush        , -- In  :
            BUSY            => wbuf_busy         , -- Out :
            VALID           => open              , -- Out :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_ENABLE        => wbuf_enable       , -- In  :
            I_DATA          => WDATA             , -- In  :
            I_STRB          => WSTRB             , -- In  :
            I_DONE          => WLAST             , -- In  :
            I_FLUSH         => wbuf_flush        , -- In  :
            I_VAL           => WVALID            , -- In  :
            I_RDY           => wbuf_ready        , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_ENABLE        => regs_enable       , -- In  :
            O_DATA          => REGS_DATA         , -- Out :
            O_STRB          => REGS_BEN          , -- Out :
            O_DONE          => regs_last         , -- Out :
            O_FLUSH         => open              , -- Out :
            O_VAL           => regs_valid        , -- Out :
            O_RDY           => regs_ready        , -- In  :
            O_SHIFT         => wbuf_shift          -- In  :
    );
    WREADY <= wbuf_ready;
end RTL;
