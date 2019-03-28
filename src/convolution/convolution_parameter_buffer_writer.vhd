-----------------------------------------------------------------------------------
--!     @file    convolution_parameter_buffer_writer.vhd
--!     @brief   Convolution Parameter Buffer Writer Module
--!     @version 1.8.0
--!     @date    2019/3/21
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019 Ichiro Kawazome
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
use     PIPEWORK.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief Convolution Parameter Buffer Reader Module
-----------------------------------------------------------------------------------
entity  CONVOLUTION_PARAMETER_BUFFER_WRITER is
    generic (
        PARAM           : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        SHAPE           : --! @brief PARAMETER SHAPE :
                          --! ウェイトデータの形(SHAPE)を指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        BANK_SIZE       : --! バッファメモリのバンクの数を指定する.
                          --! * BANK_SIZE * BUF_DATA_BITS =
                          --!   PARAM.ELEM_BITS *
                          --!   PARAM.SHAPE.C.SIZE *
                          --!   PARAM.SHAPE.D.SIZE *
                          --!   PARAM.SHAPE.X.SIZE *
                          --!   PARAM.SHAPE.Y.SIZE でなければならない。
                          integer := 8;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK             : --! @brief CLOCK :
                          --! クロック信号
                          in  std_logic; 
        RST             : --! @brief ASYNCRONOUSE RESET :
                          --! 非同期リセット信号.アクティブハイ.
                          in  std_logic;
        CLR             : --! @brief SYNCRONOUSE RESET :
                          --! 同期リセット信号.アクティブハイ.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- 制御 I/F
    -------------------------------------------------------------------------------
        REQ_VALID       : --! @brief REQUEST VALID :
                          in  std_logic;
        REQ_READY       : --! @brief REQUEST READY :
                          out std_logic;
        C_SIZE          : --! @brief SHAPE C SIZE :
                          in  integer range 0 to SHAPE.C.MAX_SIZE := SHAPE.C.SIZE;
        D_SIZE          : --! @brief SHAPE D SIZE :
                          in  integer range 0 to SHAPE.D.MAX_SIZE := SHAPE.D.SIZE;
        RES_VALID       : --! @brief RESPONSE VALID : 
                          out std_logic;
        RES_READY       : --! @brief RESPONSE READY : 
                          in  std_logic := '1';
        RES_ADDR        : --! @brief RESPONSE BUFFER START ADDRESS :
                          out std_logic_vector(BUF_ADDR_BITS-1 downto 0);
        RES_SIZE        : --! @brief RESPONSE SIZE :
                          out std_logic_vector(BUF_ADDR_BITS   downto 0);
        BUSY            : --! @brief BUSY
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 入力 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT PARAMETER DATA :
                          in  std_logic_vector(PARAM.ELEM_BITS-1 downto 0);
        I_VALID         : --! @brief INPUT PARAMETER DATA VALID :
                          in  std_logic;
        I_READY         : --! @brief INPUT PARAMETER DATA READY :
                          out std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER WRITE DATA :
                          out std_logic_vector(BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
        BUF_WE          : --! @brief BUFFER WRITE ENABLE :
                          out std_logic_vector(PARAM.SHAPE.D.SIZE*
                                               PARAM.SHAPE.Y.SIZE*
                                               PARAM.SHAPE.X.SIZE*
                                               PARAM.SHAPE.C.SIZE     -1 downto 0);
        BUF_PUSH        : --! @brief BUFFER PUSH :
                          out std_logic;
        BUF_READY       : --! @brief BUFFER WRITE READY :
                          in  std_logic := '1'
    );
end CONVOLUTION_PARAMETER_BUFFER_WRITER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.UNROLLED_LOOP_COUNTER;
architecture RTL of CONVOLUTION_PARAMETER_BUFFER_WRITER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    function  NEW_ONE_HOT(LEN,POS:integer) return std_logic_vector is
        variable one_hot  : std_logic_vector(LEN-1 downto 0);
    begin
        for i in one_hot'range loop
            if (i = POS) then
                one_hot(i) := '1';
            else
                one_hot(i) := '0';
            end if;
        end loop;
        return one_hot;
    end function;
    function  NEW_FIRST_SELECT(LEN:integer) return std_logic_vector is
    begin
        return NEW_ONE_HOT(LEN, 0);
    end function;
    function  NEW_LAST_SELECT (LEN:integer) return std_logic_vector is
    begin
        return NEW_ONE_HOT(LEN, LEN-1);
    end function;
    function  SHIFT_SELECT(SEL:std_logic_vector) return std_logic_vector is
        variable shifted_select  : std_logic_vector(SEL'range);
    begin
        for i in shifted_select'range loop
            if (i = SEL'low) then
                shifted_select(i) := '0';
            else
                shifted_select(i) := SEL(i-1);
            end if;
        end loop;
        return shifted_select;
    end function;
    -------------------------------------------------------------------------------
    -- Output Channel Loop Control Signals
    -------------------------------------------------------------------------------
    signal    oc_loop_start         :  std_logic;
    signal    oc_loop_next          :  std_logic;
    signal    oc_loop_busy          :  std_logic;
    signal    oc_loop_done          :  std_logic;
    signal    oc_loop_first         :  std_logic;
    signal    oc_loop_last          :  std_logic;
    signal    oc_loop_valid         :  std_logic;
    signal    oc_select             :  std_logic_vector(PARAM.SHAPE.D.SIZE-1 downto 0);
    constant  OC_SELECT_FIRST       :  std_logic_vector(PARAM.SHAPE.D.SIZE-1 downto 0) := NEW_FIRST_SELECT(PARAM.SHAPE.D.SIZE);
    constant  OC_SELECT_LAST        :  std_logic_vector(PARAM.SHAPE.D.SIZE-1 downto 0) := NEW_LAST_SELECT (PARAM.SHAPE.D.SIZE);
    -------------------------------------------------------------------------------
    -- Kernel Height Loop Control Signals
    -------------------------------------------------------------------------------
    signal    ky_loop_start         :  std_logic;
    signal    ky_loop_next          :  std_logic;
    signal    ky_loop_busy          :  std_logic;
    signal    ky_loop_done          :  std_logic;
    signal    ky_loop_first         :  std_logic;
    signal    ky_loop_last          :  std_logic;
    signal    ky_loop_valid         :  std_logic;
    signal    ky_select             :  std_logic_vector(PARAM.SHAPE.Y.SIZE-1 downto 0);
    constant  KY_SELECT_FIRST       :  std_logic_vector(PARAM.SHAPE.Y.SIZE-1 downto 0) := NEW_FIRST_SELECT(PARAM.SHAPE.Y.SIZE);
    constant  KY_SELECT_LAST        :  std_logic_vector(PARAM.SHAPE.Y.SIZE-1 downto 0) := NEW_LAST_SELECT (PARAM.SHAPE.Y.SIZE);
    -------------------------------------------------------------------------------
    -- Kernel Width Loop Control Signals
    -------------------------------------------------------------------------------
    signal    kx_loop_start         :  std_logic;
    signal    kx_loop_next          :  std_logic;
    signal    kx_loop_busy          :  std_logic;
    signal    kx_loop_done          :  std_logic;
    signal    kx_loop_first         :  std_logic;
    signal    kx_loop_last          :  std_logic;
    signal    kx_loop_valid         :  std_logic;
    signal    kx_select             :  std_logic_vector(PARAM.SHAPE.X.SIZE-1 downto 0);
    constant  KX_SELECT_FIRST       :  std_logic_vector(PARAM.SHAPE.X.SIZE-1 downto 0) := NEW_FIRST_SELECT(PARAM.SHAPE.X.SIZE);
    constant  KX_SELECT_LAST        :  std_logic_vector(PARAM.SHAPE.X.SIZE-1 downto 0) := NEW_LAST_SELECT (PARAM.SHAPE.X.SIZE);
    -------------------------------------------------------------------------------
    -- Input Channel Loop Control Signals
    -------------------------------------------------------------------------------
    signal    ic_loop_start         :  std_logic;
    signal    ic_loop_next          :  std_logic;
    signal    ic_loop_busy          :  std_logic;
    signal    ic_loop_done          :  std_logic;
    signal    ic_loop_first         :  std_logic;
    signal    ic_loop_last          :  std_logic;
    signal    ic_loop_valid         :  std_logic;
    signal    ic_select             :  std_logic_vector(PARAM.SHAPE.C.SIZE-1 downto 0);
    constant  IC_SELECT_FIRST       :  std_logic_vector(PARAM.SHAPE.C.SIZE-1 downto 0) := NEW_FIRST_SELECT(PARAM.SHAPE.C.SIZE);
    constant  IC_SELECT_LAST        :  std_logic_vector(PARAM.SHAPE.C.SIZE-1 downto 0) := NEW_LAST_SELECT (PARAM.SHAPE.C.SIZE);
    -------------------------------------------------------------------------------
    -- Intake Stream Signals
    -------------------------------------------------------------------------------
    signal    intake_data           :  std_logic_vector(I_DATA'length-1 downto 0);
    signal    intake_valid          :  std_logic;
    signal    intake_ready          :  std_logic;
    -------------------------------------------------------------------------------
    -- Write Size Signals
    -------------------------------------------------------------------------------
    signal    curr_write_size       :  unsigned(BUF_ADDR_BITS   downto 0);
    signal    write_size_update     :  boolean;
    -------------------------------------------------------------------------------
    -- Write Address Signals
    -------------------------------------------------------------------------------
    signal    curr_write_addr       :  unsigned(BUF_ADDR_BITS-1 downto 0);
    signal    base_write_addr       :  unsigned(BUF_ADDR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- State Machine Signals
    -------------------------------------------------------------------------------
    type      STATE_TYPE            is (IDLE_STATE, START_STATE, RUN_STATE, RES_STATE);
    signal    state                 :  STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- State Machine
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                state    <= IDLE_STATE;
                RES_ADDR <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                state    <= IDLE_STATE;
                RES_ADDR <= (others => '0');
            else
                case state is
                    when IDLE_STATE  =>
                        if (REQ_VALID = '1') then
                            state    <= START_STATE;
                        else
                            state    <= IDLE_STATE;
                        end if;
                    when START_STATE =>
                            state    <= RUN_STATE;
                            RES_ADDR <= std_logic_vector(curr_write_addr);
                    when RUN_STATE  =>
                        if (oc_loop_done = '1') then
                            state    <= RES_STATE;
                        else
                            state    <= RUN_STATE;
                        end if;
                    when RES_STATE =>
                        if (RES_READY = '1') then
                            state    <= IDLE_STATE;
                        else
                            state    <= RES_STATE;
                        end if;
                    when others => 
                            state    <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    oc_loop_start <= '1' when (state  = START_STATE) else '0';
    BUSY          <= '1' when (state /= IDLE_STATE ) else '0';
    REQ_READY     <= '1' when (state  = IDLE_STATE ) else '0';
    RES_VALID     <= '1' when (state  = RES_STATE  ) else '0';
    RES_SIZE      <= std_logic_vector(curr_write_size);
    -------------------------------------------------------------------------------
    -- Intake Parameter 
    -------------------------------------------------------------------------------
    intake_valid <= I_VALID;
    intake_data  <= I_DATA;
    I_READY      <= intake_ready;
    -------------------------------------------------------------------------------
    -- Output Channel Loop Control
    -------------------------------------------------------------------------------
    OC_LOOP: block
        signal    oc_loop_size  :  integer range 0 to SHAPE.D.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        oc_loop_size <= SHAPE.D.SIZE when (SHAPE.D.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else D_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => 1                   , --
                MAX_LOOP_SIZE   => SHAPE.D.MAX_SIZE    , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => oc_loop_start       , -- In  :
                LOOP_NEXT       => oc_loop_next        , -- In  :
                LOOP_SIZE       => oc_loop_size        , -- In  :
                LOOP_DONE       => oc_loop_done        , -- Out :
                LOOP_BUSY       => oc_loop_busy        , -- Out :
                LOOP_VALID(0)   => oc_loop_valid       , -- Out :
                LOOP_FIRST      => oc_loop_first       , -- Out :
                LOOP_LAST       => oc_loop_last          -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- oc_loop_next  :
        ---------------------------------------------------------------------------
        oc_loop_next  <= '1' when (ky_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- ky_loop_start : 
        ---------------------------------------------------------------------------
        ky_loop_start <= '1' when (oc_loop_start = '1') or
                                  (oc_loop_next  = '1' and oc_loop_last = '0') else '0';
        ---------------------------------------------------------------------------
        -- oc_select  :
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    oc_select <= OC_SELECT_FIRST;
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1') or
                      (oc_select'length = 1) or
                      (oc_loop_start = '1') or
                      (oc_loop_next  = '1' and oc_select  = OC_SELECT_LAST) then
                    oc_select <= OC_SELECT_FIRST;
                elsif (oc_loop_next  = '1' and oc_select /= OC_SELECT_LAST) then
                    oc_select <= SHIFT_SELECT(oc_select);
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- Kernel Height Loop Control
    -------------------------------------------------------------------------------
    KY_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => 1                   , --
                MAX_LOOP_SIZE   => PARAM.SHAPE.Y.SIZE  , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => ky_loop_start       , -- In  :
                LOOP_NEXT       => ky_loop_next        , -- In  :
                LOOP_SIZE       => PARAM.SHAPE.Y.SIZE  , -- In  :
                LOOP_DONE       => ky_loop_done        , -- Out :
                LOOP_BUSY       => ky_loop_busy        , -- Out :
                LOOP_VALID(0)   => ky_loop_valid       , -- Out :
                LOOP_FIRST      => ky_loop_first       , -- Out :
                LOOP_LAST       => ky_loop_last          -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- ky_loop_next  :
        ---------------------------------------------------------------------------
        ky_loop_next  <= '1' when (kx_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- kx_loop_start : 
        ---------------------------------------------------------------------------
        kx_loop_start <= '1' when (ky_loop_start = '1') or
                                  (ky_loop_next  = '1' and ky_loop_last = '0') else '0';
        ---------------------------------------------------------------------------
        -- ky_select  :
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    ky_select <= KY_SELECT_FIRST;
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1') or
                      (ky_select'length = 1) or
                      (ky_loop_start = '1') or
                      (ky_loop_next  = '1' and ky_select  = KY_SELECT_LAST) then
                    ky_select <= KY_SELECT_FIRST;
                elsif (ky_loop_next  = '1' and ky_select /= KY_SELECT_LAST) then
                    ky_select <= SHIFT_SELECT(ky_select);
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- Kernel Width Loop Control
    -------------------------------------------------------------------------------
    KX_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => 1                   , --
                MAX_LOOP_SIZE   => PARAM.SHAPE.X.SIZE  , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => kx_loop_start       , -- In  :
                LOOP_NEXT       => kx_loop_next        , -- In  :
                LOOP_SIZE       => PARAM.SHAPE.X.SIZE  , -- In  :
                LOOP_DONE       => kx_loop_done        , -- Out :
                LOOP_BUSY       => kx_loop_busy        , -- Out :
                LOOP_VALID(0)   => kx_loop_valid       , -- Out :
                LOOP_FIRST      => kx_loop_first       , -- Out :
                LOOP_LAST       => kx_loop_last          -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- kx_loop_next  :
        ---------------------------------------------------------------------------
        kx_loop_next  <= '1' when (ic_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- ic_loop_start : 
        ---------------------------------------------------------------------------
        ic_loop_start <= '1' when (kx_loop_start = '1') or
                                  (kx_loop_next  = '1' and kx_loop_last = '0') else '0';
        ---------------------------------------------------------------------------
        -- kx_select  :
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    kx_select <= KX_SELECT_FIRST;
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1') or
                      (kx_select'length = 1) or
                      (kx_loop_start = '1') or
                      (kx_loop_next  = '1' and kx_select  = KX_SELECT_LAST) then
                    kx_select <= KX_SELECT_FIRST;
                elsif (kx_loop_next  = '1' and kx_select /= KX_SELECT_LAST) then
                    kx_select <= SHIFT_SELECT(kx_select);
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- Input Channel Loop Control
    -------------------------------------------------------------------------------
    IC_LOOP: block
        signal    ic_loop_size  :  integer range 0 to SHAPE.C.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ic_loop_size <= SHAPE.C.SIZE when (SHAPE.C.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else C_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => 1                   , --
                MAX_LOOP_SIZE   => SHAPE.C.MAX_SIZE    , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => ic_loop_start       , -- In  :
                LOOP_NEXT       => ic_loop_next        , -- In  :
                LOOP_SIZE       => ic_loop_size        , -- In  :
                LOOP_DONE       => ic_loop_done        , -- Out :
                LOOP_BUSY       => ic_loop_busy        , -- Out :
                LOOP_VALID(0)   => ic_loop_valid       , -- Out :
                LOOP_FIRST      => ic_loop_first       , -- Out :
                LOOP_LAST       => ic_loop_last          -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- ic_loop_next  :
        ---------------------------------------------------------------------------
        ic_loop_next  <= '1' when (intake_valid = '1' and intake_ready = '1') else '0';
        ---------------------------------------------------------------------------
        -- intake_ready  :
        ---------------------------------------------------------------------------
        intake_ready  <= '1' when (ic_loop_busy = '1' and BUF_READY    = '1') else '0';
        ---------------------------------------------------------------------------
        -- ic_select  :
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    ic_select <= IC_SELECT_FIRST;
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1') or
                      (ic_select'length = 1) or
                      (ic_loop_start = '1') or
                      (ic_loop_next  = '1' and ic_select  = IC_SELECT_LAST) then
                    ic_select <= IC_SELECT_FIRST;
                elsif (ic_loop_next  = '1' and ic_select /= IC_SELECT_LAST) then
                    ic_select <= SHIFT_SELECT(ic_select);
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- curr_write_addr
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_write_addr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_write_addr <= (others => '0');
            elsif (ic_loop_next = '1' and (ic_loop_last = '1' or ic_select = IC_SELECT_LAST)) then
                if (kx_loop_last = '1' and ky_loop_last = '1' and (oc_loop_last = '1' or oc_select = OC_SELECT_LAST)) then
                    curr_write_addr <= curr_write_addr + 1;
                elsif (ic_loop_last = '1') then
                    curr_write_addr <= base_write_addr;
                else
                    curr_write_addr <= curr_write_addr + 1;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- base_write_addr
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                base_write_addr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                base_write_addr <= (others => '0');
            elsif (state = START_STATE) then
                base_write_addr <= curr_write_addr;
            elsif (ic_loop_next = '1') and
                  (ic_loop_last = '1') and
                  (kx_loop_last = '1') and
                  (ky_loop_last = '1') and
                  (oc_loop_last = '1' or oc_select = OC_SELECT_LAST) then
                base_write_addr <= curr_write_addr + 1;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- write_size_update
    -- BUF_PUSH
    -------------------------------------------------------------------------------
    write_size_update <= (ic_loop_next = '1'         ) and
                         (ky_select = KY_SELECT_LAST ) and
                         (kx_select = KX_SELECT_LAST ) and
                         (oc_select = OC_SELECT_LAST or oc_loop_last = '1') and
                         (ic_select = IC_SELECT_LAST or ic_loop_last = '1');
    BUF_PUSH <= '1' when (write_size_update = TRUE) else '0';
    -------------------------------------------------------------------------------
    -- curr_write_size
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_write_size <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') or
               (state = START_STATE) then
                curr_write_size <= (others => '0');
            elsif (write_size_update = TRUE) then
                curr_write_size <= curr_write_size + 1;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- BUF_ADDR
    -- BUF_DATA
    -- BUF_WE
    -------------------------------------------------------------------------------
    process (CLK, RST)
        constant  IC_WE_SIZE :  integer := 1;
        constant  OC_WE_SIZE :  integer := IC_WE_SIZE * ic_select'length;
        constant  KX_WE_SIZE :  integer := OC_WE_SIZE * oc_select'length;
        constant  KY_WE_SIZE :  integer := KX_WE_SIZE * kx_select'length;
    begin
        if (RST = '1') then
                BUF_ADDR <= (others => '0');
                BUF_DATA <= (others => '0');
                BUF_WE   <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') or (state = IDLE_STATE) then
                BUF_ADDR <= (others => '0');
                BUF_DATA <= (others => '0');
                BUF_WE   <= (others => '0');
            else
                for BANK in 0 to BANK_SIZE-1 loop
                    BUF_ADDR((BANK+1)*BUF_ADDR_BITS-1 downto BANK*BUF_ADDR_BITS) <= std_logic_vector(curr_write_addr);
                    BUF_DATA((BANK+1)*BUF_DATA_BITS-1 downto BANK*BUF_DATA_BITS) <= intake_data;
                end loop;
                if (intake_valid = '1' and intake_ready = '1') then
                    for oc_pos in oc_select'range loop
                    for ky_pos in ky_select'range loop
                    for kx_pos in kx_select'range loop
                    for ic_pos in ic_select'range loop
                        if (oc_select(oc_pos) = '1' and ky_select(ky_pos) = '1' and kx_select(kx_pos) = '1' and ic_select(ic_pos) = '1') then
                            BUF_WE(oc_pos*OC_WE_SIZE + ky_pos*KY_WE_SIZE + kx_pos*KX_WE_SIZE + ic_pos*IC_WE_SIZE) <= '1';
                        else
                            BUF_WE(oc_pos*OC_WE_SIZE + ky_pos*KY_WE_SIZE + kx_pos*KX_WE_SIZE + ic_pos*IC_WE_SIZE) <= '0';
                        end if;
                    end loop;
                    end loop;
                    end loop;
                    end loop;
                else
                    BUF_WE <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end RTL;
