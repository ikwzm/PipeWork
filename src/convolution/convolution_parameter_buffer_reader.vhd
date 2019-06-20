-----------------------------------------------------------------------------------
--!     @file    convolution_parameter_buffer_reader.vhd
--!     @brief   Convolution Parameter Buffer Reader Module
--!     @version 1.8.0
--!     @date    2019/4/11
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
entity  CONVOLUTION_PARAMETER_BUFFER_READER is
    generic (
        PARAM           : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        SHAPE           : --! @brief OUTPUT IMAGE SHAPE :
                          --! 出力側のイメージの形(SHAPE)を指定する.
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
                          integer := 8;
        QUEUE_SIZE      : --! @brief OUTPUT QUEUE SIZE :
                          --! 出力キューの大きさをワード数で指定する.
                          --! * QUEUE_SIZE=0 の場合は出力にキューが挿入されずダイレ
                          --!   クトに出力される.
                          integer := 0
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
        REQ_ADDR_LOAD   : --! @brief REQESUT BUUFER START ADDRESS VALID :
                          --! REQ_ADDR で指定されたバッファアドレスから読み込みを開
                          --! 始するか、前回ロードしたバッファアドレスから読み込みを
                          --! 開始するかを指定する.
                          --! * REQ_ADDR_LOAD='1' で REQ_ADDR で指定されたバッファ
                          --!   アドレスから読み込みを開始する.
                          --! * REQ_ADDR_LOAD='0' で 前回 REQ_ADDR_LOAD='1' で指定
                          --!   したバッファアドレスから読み込みを開始する.
                          in  std_logic := '1';
        REQ_ADDR        : --! @brief REQUEST BUFFER START ADDRESS :
                          in  std_logic_vector(BUF_ADDR_BITS-1 downto 0);
        C_SIZE          : --! @brief SHAPE C SIZE :
                          in  integer range 0 to SHAPE.C.MAX_SIZE := SHAPE.C.SIZE;
        D_SIZE          : --! @brief SHAPE D SIZE :
                          in  integer range 0 to SHAPE.D.MAX_SIZE := SHAPE.D.SIZE;
        X_SIZE          : --! @brief SHAPE X SIZE :
                          in  integer range 0 to SHAPE.X.MAX_SIZE := SHAPE.X.SIZE;
        Y_SIZE          : --! @brief SHAPE Y SIZE :
                          in  integer range 0 to SHAPE.Y.MAX_SIZE := SHAPE.Y.SIZE;
        RES_VALID       : --! @brief RESPONSE VALID : 
                          out std_logic;
        RES_READY       : --! @brief RESPONSE READY : 
                          in  std_logic := '1';
        BUSY            : --! @brief BUSY
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT PARAMETER DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT PARAMETER DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT PARAMETER DATA READY :
                          --! 出力ストリームデータレディ信号.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER READ ADDRESS :
                          out std_logic_vector(BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end CONVOLUTION_PARAMETER_BUFFER_READER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER;
use     PIPEWORK.COMPONENTS.UNROLLED_LOOP_COUNTER;
architecture RTL of CONVOLUTION_PARAMETER_BUFFER_READER is
    -------------------------------------------------------------------------------
    -- Image Height Loop Control Signals
    -------------------------------------------------------------------------------
    signal    y_loop_start          :  std_logic;
    signal    y_loop_next           :  std_logic;
    signal    y_loop_busy           :  std_logic;
    signal    y_loop_done           :  std_logic;
    signal    y_loop_first          :  std_logic;
    signal    y_loop_last           :  std_logic;
    -------------------------------------------------------------------------------
    -- Image Width Loop Control Signals
    -------------------------------------------------------------------------------
    signal    x_loop_start          :  std_logic;
    signal    x_loop_next           :  std_logic;
    signal    x_loop_busy           :  std_logic;
    signal    x_loop_done           :  std_logic;
    signal    x_loop_first          :  std_logic;
    signal    x_loop_last           :  std_logic;
    -------------------------------------------------------------------------------
    -- Output Channel Loop Control Signals
    -------------------------------------------------------------------------------
    signal    d_loop_start          :  std_logic;
    signal    d_loop_next           :  std_logic;
    signal    d_loop_busy           :  std_logic;
    signal    d_loop_done           :  std_logic;
    signal    d_loop_first          :  std_logic;
    signal    d_loop_last           :  std_logic;
    signal    d_loop_valid          :  std_logic_vector(PARAM.SHAPE.D.SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    -- Input Channel Loop Control Signals
    -------------------------------------------------------------------------------
    signal    c_loop_start          :  std_logic;
    signal    c_loop_next           :  std_logic;
    signal    c_loop_busy           :  std_logic;
    signal    c_loop_done           :  std_logic;
    signal    c_loop_first          :  std_logic;
    signal    c_loop_last           :  std_logic;
    signal    c_loop_valid          :  std_logic_vector(PARAM.SHAPE.C.SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Stream Signals
    -------------------------------------------------------------------------------
    signal    outlet_data           :  std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
    signal    outlet_valid          :  std_logic;
    signal    outlet_ready          :  std_logic;
    signal    outlet_busy           :  std_logic;
    -------------------------------------------------------------------------------
    -- State Machine Signals
    -------------------------------------------------------------------------------
    type      STATE_TYPE            is (IDLE_STATE, START_STATE, RUN_STATE, FLUSH_STATE, RES_STATE);
    signal    state                 :  STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- State Machine
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                state <= IDLE_STATE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                state <= IDLE_STATE;
            else
                case state is
                    when IDLE_STATE  =>
                        if (REQ_VALID = '1') then
                            state <= START_STATE;
                        else
                            state <= IDLE_STATE;
                        end if;
                    when START_STATE =>
                            state <= RUN_STATE;
                    when RUN_STATE  =>
                        if    (y_loop_done = '1' and outlet_busy = '0') then
                            state <= RES_STATE;
                        elsif (y_loop_done = '1' and outlet_busy = '1') then
                            state <= FLUSH_STATE;
                        else
                            state <= RUN_STATE;
                        end if;
                    when FLUSH_STATE =>
                        if (outlet_busy = '0') then
                            state <= RES_STATE;
                        else
                            state <= FLUSH_STATE;
                        end if;
                    when RES_STATE =>
                        if (RES_READY = '1') then
                            state <= IDLE_STATE;
                        else
                            state <= RES_STATE;
                        end if;
                    when others => 
                            state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    y_loop_start <= '1' when (state  = START_STATE) else '0';
    BUSY         <= '1' when (state /= IDLE_STATE ) else '0';
    REQ_READY    <= '1' when (state  = IDLE_STATE ) else '0';
    RES_VALID    <= '1' when (state  = RES_STATE  ) else '0';
    -------------------------------------------------------------------------------
    -- Image Height Loop Control
    -------------------------------------------------------------------------------
    Y_LOOP: block
        signal    y_loop_size   :  integer range 0 to SHAPE.Y.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        y_loop_size <= SHAPE.Y.SIZE when (SHAPE.Y.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else Y_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => 1                   , --
                MAX_LOOP_SIZE   => SHAPE.Y.MAX_SIZE    , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => y_loop_start        , -- In  :
                LOOP_NEXT       => y_loop_next         , -- In  :
                LOOP_SIZE       => y_loop_size         , -- In  :
                LOOP_DONE       => y_loop_done         , -- Out :
                LOOP_BUSY       => y_loop_busy         , -- Out :
                LOOP_FIRST      => y_loop_first        , -- Out :
                LOOP_LAST       => y_loop_last           -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- y_loop_next  :
        ---------------------------------------------------------------------------
        y_loop_next  <= '1' when (x_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- x_loop_start : 
        ---------------------------------------------------------------------------
        x_loop_start <= '1' when (y_loop_start = '1') or
                                 (y_loop_next  = '1' and y_loop_last = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- Image Width Loop Control
    -------------------------------------------------------------------------------
    X_LOOP: block
        signal    x_loop_size   :  integer range 0 to SHAPE.X.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        x_loop_size <= SHAPE.X.SIZE when (SHAPE.X.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else X_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => 1                   , --
                MAX_LOOP_SIZE   => SHAPE.X.MAX_SIZE    , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => x_loop_start        , -- In  :
                LOOP_NEXT       => x_loop_next         , -- In  :
                LOOP_SIZE       => x_loop_size         , -- In  :
                LOOP_DONE       => x_loop_done         , -- Out :
                LOOP_BUSY       => x_loop_busy         , -- Out :
                LOOP_FIRST      => x_loop_first        , -- Out :
                LOOP_LAST       => x_loop_last           -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- x_loop_next  :
        ---------------------------------------------------------------------------
        x_loop_next  <= '1' when (d_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- d_loop_start : 
        ---------------------------------------------------------------------------
        d_loop_start <= '1' when (x_loop_start = '1') or
                                 (x_loop_next  = '1' and x_loop_last = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- Output Channel Loop Control
    -------------------------------------------------------------------------------
    D_LOOP: block
        signal    d_loop_size   :  integer range 0 to SHAPE.D.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        d_loop_size <= SHAPE.D.SIZE when (SHAPE.D.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else D_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => PARAM.SHAPE.D.SIZE  , --
                MAX_LOOP_SIZE   => SHAPE.D.MAX_SIZE    , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => d_loop_start        , -- In  :
                LOOP_NEXT       => d_loop_next         , -- In  :
                LOOP_SIZE       => d_loop_size         , -- In  :
                LOOP_DONE       => d_loop_done         , -- Out :
                LOOP_BUSY       => d_loop_busy         , -- Out :
                LOOP_VALID      => d_loop_valid        , -- Out :
                LOOP_FIRST      => d_loop_first        , -- Out :
                LOOP_LAST       => d_loop_last           -- Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- d_loop_next  :
        ---------------------------------------------------------------------------
        d_loop_next  <= '1' when (c_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- c_loop_start : 
        ---------------------------------------------------------------------------
        c_loop_start <= '1' when (d_loop_start = '1') or
                                 (d_loop_next  = '1' and d_loop_last = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- Input Channel Loop Control Signals
    -------------------------------------------------------------------------------
    C_LOOP: block
        signal    c_loop_size   :  integer range 0 to SHAPE.C.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        c_loop_size <= SHAPE.C.SIZE when (SHAPE.C.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else C_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => PARAM.SHAPE.C.SIZE  , --
                MAX_LOOP_SIZE   => SHAPE.C.MAX_SIZE    , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => c_loop_start        , -- In  :
                LOOP_NEXT       => c_loop_next         , -- In  :
                LOOP_SIZE       => c_loop_size         , -- In  :
                LOOP_DONE       => c_loop_done         , -- Out :
                LOOP_BUSY       => c_loop_busy         , -- Out :
                LOOP_VALID      => c_loop_valid        , -- Out :
                LOOP_FIRST      => c_loop_first        , -- Out :
                LOOP_LAST       => c_loop_last           -- Out :
            );                                           --
        ---------------------------------------------------------------------------
        -- c_loop_next : 
        ---------------------------------------------------------------------------
        c_loop_next  <= '1' when (outlet_valid = '1' and outlet_ready = '1') else '0';
        ---------------------------------------------------------------------------
        -- outlet_valid :
        ---------------------------------------------------------------------------
        outlet_valid <= '1' when (c_loop_busy = '1') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    B: for BANK in 0 to BANK_SIZE-1 generate
        constant NULL_ADDR :  unsigned(BUF_ADDR_BITS-1 downto 0) := (others => '0');
        signal   curr_addr :  unsigned(BUF_ADDR_BITS-1 downto 0);
        signal   base_addr :  unsigned(BUF_ADDR_BITS-1 downto 0);
        signal   next_addr :  unsigned(BUF_ADDR_BITS-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_addr <= (others => '0');
                    base_addr <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_addr <= (others => '0');
                    base_addr <= (others => '0');
                elsif (state = IDLE_STATE) then
                    if    (REQ_VALID = '1') then
                        if (REQ_ADDR_LOAD = '1') then
                            curr_addr <= unsigned(REQ_ADDR);
                            base_addr <= unsigned(REQ_ADDR);
                        else
                            curr_addr <= base_addr;
                        end if;
                    end if;
                else
                    curr_addr <= next_addr;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        next_addr <= NULL_ADDR   when (state = IDLE_STATE) else
                     base_addr   when (outlet_valid = '1' and outlet_ready = '1' and     (c_loop_last = '1' and d_loop_last = '1')) else
                     curr_addr+1 when (outlet_valid = '1' and outlet_ready = '1' and not (c_loop_last = '1' and d_loop_last = '1')) else
                     curr_addr;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        BUF_ADDR((BANK+1)*BUF_ADDR_BITS-1 downto BANK*BUF_ADDR_BITS) <= std_logic_vector(next_addr);
    end generate;
    -------------------------------------------------------------------------------
    -- outlet_data
    -------------------------------------------------------------------------------
    process(d_loop_first, d_loop_last, d_loop_valid ,
            c_loop_first, c_loop_last, c_loop_valid , BUF_DATA)
        variable bank_data     :  std_logic_vector(BUF_DATA_BITS     -1 downto 0);
        variable output_data   :  std_logic_vector(PARAM.DATA.SIZE   -1 downto 0);
        constant ky_valid      :  std_logic_vector(PARAM.SHAPE.Y.SIZE-1 downto 0) := (others => '1');
        constant kx_valid      :  std_logic_vector(PARAM.SHAPE.X.SIZE-1 downto 0) := (others => '1');
        constant y_atrb_vector :  IMAGE_STREAM_ATRB_VECTOR(0 to PARAM.SHAPE.Y.SIZE-1) := GENERATE_IMAGE_STREAM_ATRB_VECTOR(ky_valid, '1', '1');
        constant x_atrb_vector :  IMAGE_STREAM_ATRB_VECTOR(0 to PARAM.SHAPE.X.SIZE-1) := GENERATE_IMAGE_STREAM_ATRB_VECTOR(kx_valid, '1', '1');
        variable d_atrb_vector :  IMAGE_STREAM_ATRB_VECTOR(0 to PARAM.SHAPE.D.SIZE-1);
        variable c_atrb_vector :  IMAGE_STREAM_ATRB_VECTOR(0 to PARAM.SHAPE.C.SIZE-1);
        constant C_DATA_SIZE   :  integer := 1;
        constant D_DATA_SIZE   :  integer := C_DATA_SIZE * PARAM.SHAPE.C.SIZE;
        constant X_DATA_SIZE   :  integer := D_DATA_SIZE * PARAM.SHAPE.D.SIZE;
        constant Y_DATA_SIZE   :  integer := X_DATA_SIZE * PARAM.SHAPE.X.SIZE;
    begin
        output_data := (others => '0');
        for y_pos in 0 to PARAM.SHAPE.Y.SIZE-1 loop
        for x_pos in 0 to PARAM.SHAPE.X.SIZE-1 loop
        for d_pos in 0 to PARAM.SHAPE.D.SIZE-1 loop
        for c_pos in 0 to PARAM.SHAPE.C.SIZE-1 loop
            bank_data := BUF_DATA(((y_pos*Y_DATA_SIZE)+(x_pos*X_DATA_SIZE)+(d_pos*D_DATA_SIZE)+(c_pos*C_DATA_SIZE)+1)*BUF_DATA_BITS-1 downto
                                  ((y_pos*Y_DATA_SIZE)+(x_pos*X_DATA_SIZE)+(d_pos*D_DATA_SIZE)+(c_pos*C_DATA_SIZE)  )*BUF_DATA_BITS  );
            SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                PARAM   => PARAM,
                C       => c_pos + PARAM.SHAPE.C.LO,
                D       => d_pos + PARAM.SHAPE.D.LO,
                X       => x_pos + PARAM.SHAPE.X.LO,
                Y       => y_pos + PARAM.SHAPE.Y.LO,
                ELEMENT => bank_data,
                DATA    => output_data
            );
        end loop;
        end loop;
        end loop;
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        c_atrb_vector := GENERATE_IMAGE_STREAM_ATRB_VECTOR(c_loop_valid, c_loop_first, c_loop_last);
        d_atrb_vector := GENERATE_IMAGE_STREAM_ATRB_VECTOR(d_loop_valid, d_loop_first, d_loop_last);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        SET_ATRB_C_VECTOR_TO_IMAGE_STREAM_DATA(PARAM, c_atrb_vector, output_data);
        SET_ATRB_D_VECTOR_TO_IMAGE_STREAM_DATA(PARAM, d_atrb_vector, output_data);
        SET_ATRB_X_VECTOR_TO_IMAGE_STREAM_DATA(PARAM, x_atrb_vector, output_data);
        SET_ATRB_Y_VECTOR_TO_IMAGE_STREAM_DATA(PARAM, y_atrb_vector, output_data);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        outlet_data <= output_data;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    QUEUE: PIPELINE_REGISTER                   -- 
        generic map (                          -- 
            QUEUE_SIZE  => QUEUE_SIZE        , --
            WORD_BITS   => PARAM.DATA.SIZE     -- 
        )                                      -- 
        port map (                             -- 
            CLK         => CLK               , -- In  :
            RST         => RST               , -- In  :
            CLR         => CLR               , -- In  :
            I_WORD      => outlet_data       , -- In  :
            I_VAL       => outlet_valid      , -- In  :
            I_RDY       => outlet_ready      , -- Out :
            Q_WORD      => O_DATA            , -- Out :
            Q_VAL       => O_VALID           , -- Out :
            Q_RDY       => O_READY           , -- In  :
            BUSY        => outlet_busy         -- Out :
        );
end RTL;
