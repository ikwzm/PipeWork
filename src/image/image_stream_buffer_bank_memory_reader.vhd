-----------------------------------------------------------------------------------
--!     @file    image_stream_buffer_bank_memory_reader.vhd
--!     @brief   Image Stream Buffer Bank Memory Reader Module :
--!              異なる形のイメージストリームを継ぐためのバッファのバンク分割型メモ
--!              リ読み出し側モジュール
--!     @version 1.8.0
--!     @date    2019/4/11
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2019 Ichiro Kawazome
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
--! @brief   Image Stream Buffer Bank Memory Reader Module :
--!          異なる形のイメージストリームを継ぐためのバッファのバンク分割型メモリ
--!          読み出し側モジュール
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_BUFFER_BANK_MEMORY_READER is
    generic (
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          --! * O_PARAM.ELEM_BITS = I_PARAM.ELEM_BITS でなければならない.
                          --! * O_PARAM.INFO_BITS = 0 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 出力側のイメージの形(SHAPE)を指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_LINE_START    : --! @brief INPUT LINE START :
                          --! ライン開始信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_ATRB     : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.D.MAX_SIZE := O_SHAPE.D.SIZE;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
        C_OFFSET        : --! @brief OUTPUT CHANNEL BUFFER ADDRESS OFFSET :
                          in  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT STREAM DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT STREAM DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT STREAM DATA READY :
                          --! 出力ストリームデータレディ信号.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end IMAGE_STREAM_BUFFER_BANK_MEMORY_READER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_ATRB_GENERATOR;
use     PIPEWORK.COMPONENTS.UNROLLED_LOOP_COUNTER;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER;
architecture RTL of IMAGE_STREAM_BUFFER_BANK_MEMORY_READER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   RAM_DATA_TYPE         is std_logic_vector(BUF_DATA_BITS-1 downto 0);
    subtype   RAM_ADDR_TYPE         is std_logic_vector(BUF_ADDR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      BANK_DATA_TYPE        is array(0 to BANK_SIZE-1) of RAM_DATA_TYPE;
    type      BANK_ADDR_TYPE        is array(0 to BANK_SIZE-1) of RAM_ADDR_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      BUF_ADDR_TYPE         is array(0 to LINE_SIZE-1) of BANK_ADDR_TYPE;
    signal    buf_addr_array        :  BUF_ADDR_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   BANK_SELECT_TYPE      is std_logic_vector(0 to BANK_SIZE-1);
    type      BANK_SELECT_VECTOR    is array(integer range <>) of BANK_SELECT_TYPE;
    signal    curr_bank_select      :  BANK_SELECT_VECTOR(O_PARAM.SHAPE.X.LO to O_PARAM.SHAPE.X.HI);
    signal    next_bank_select      :  BANK_SELECT_VECTOR(O_PARAM.SHAPE.X.LO to O_PARAM.SHAPE.X.HI);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  INIT_BANK_SELECT(LO,HI: integer) return BANK_SELECT_VECTOR is
        variable i_vec :  BANK_SELECT_VECTOR(LO to HI);
    begin
        for i in i_vec'range loop
            for bank in 0 to BANK_SIZE-1 loop
                if (i-LO = bank) then
                    i_vec(i)(bank) := '1';
                else
                    i_vec(i)(bank) := '0';
                end if;
            end loop;
        end loop;
        return i_vec;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  STRIDE_BANK_SELECT(I_VEC: BANK_SELECT_VECTOR; STRIDE: integer) return BANK_SELECT_VECTOR is
        variable o_vec :  BANK_SELECT_VECTOR(I_VEC'range);
    begin
        for i in o_vec'range loop
            for bank in 0 to BANK_SIZE-1 loop
                o_vec(i)(bank) := I_VEC(i)((BANK_SIZE+bank-STRIDE) mod BANK_SIZE);
            end loop;
        end loop;
        return o_vec;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  IS_LAST_BANK(BANK_SELECT: BANK_SELECT_TYPE; STRIDE: integer) return boolean is
        variable last :  boolean;
    begin
        last := FALSE;
        for bank in BANK_SIZE-1 downto BANK_SIZE-STRIDE loop
            if (BANK_SELECT(bank) = '1') then
                last := TRUE;
            end if;
        end loop;
        return last;
    end function;
    function  IS_LAST_BANK(I_VEC: BANK_SELECT_VECTOR; STRIDE: integer) return boolean is
    begin
        return IS_LAST_BANK(I_VEC(I_VEC'low), STRIDE);
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   ADDR_SELECT_TYPE      is std_logic_vector(0 to BANK_SIZE-1);
    type      ADDR_SELECT_VECTOR    is array(integer range <>) of ADDR_SELECT_TYPE;
    signal    curr_addr_select      :  ADDR_SELECT_VECTOR(0 to LINE_SIZE-1);
    signal    next_addr_select      :  ADDR_SELECT_VECTOR(0 to LINE_SIZE-1);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  CALC_ADDR_SELECT(BANK_SELECT: BANK_SELECT_TYPE) return ADDR_SELECT_VECTOR is
        variable select_next_addr   :  boolean;
        variable addr_select        :  ADDR_SELECT_VECTOR(0 to LINE_SIZE-1);
    begin 
        select_next_addr := TRUE;
        for bank in 0 to BANK_SIZE-1 loop
            if (select_next_addr = TRUE and BANK_SELECT(bank) = '1') then
                select_next_addr := FALSE;
            end if;
            for line in 0 to LINE_SIZE-1 loop
                if (select_next_addr = TRUE) then
                    addr_select(line)(bank) := '1';
                else
                    addr_select(line)(bank) := '0';
                end if;
            end loop;
        end loop;
        return addr_select;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  CALC_NEXT_BANK_ADDR(
                  CURR_BANK_ADDR    :  BANK_ADDR_TYPE;
                  ADDR_SELECT       :  ADDR_SELECT_TYPE;
                  BASE_ADDR         :  unsigned;
                  NEXT_ADDR         :  unsigned;
                  START_CHANNEL     :  std_logic;
                  NEXT_CHANNEL      :  std_logic
              )   return               BANK_ADDR_TYPE
    is
        variable  next_bank_addr    :  BANK_ADDR_TYPE;
        variable  base_curr_addr    :  RAM_ADDR_TYPE;
        variable  base_next_addr    :  RAM_ADDR_TYPE;
        variable  select_next_addr  :  boolean;
    begin
        if (START_CHANNEL = '1') then
            base_curr_addr := std_logic_vector(BASE_ADDR);
            base_next_addr := std_logic_vector(NEXT_ADDR);
            for bank in 0 to BANK_SIZE-1 loop
                if (ADDR_SELECT(bank) = '1') then
                    next_bank_addr(bank) := base_next_addr;
                else
                    next_bank_addr(bank) := base_curr_addr;
                end if;
            end loop;
        elsif (NEXT_CHANNEL = '1') then
            for bank in 0 to BANK_SIZE-1 loop
                next_bank_addr(bank) := std_logic_vector(unsigned(CURR_BANK_ADDR(bank)) + 1);
            end loop;
        else
            for bank in 0 to BANK_SIZE-1 loop
                next_bank_addr(bank) := CURR_BANK_ADDR(bank);
            end loop;
        end if;
        return next_bank_addr;
    end function;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    line_atrb_vector      :  IMAGE_STREAM_ATRB_VECTOR(0 to LINE_SIZE-1);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    x_loop_start          :  std_logic;
    signal    x_loop_next           :  std_logic;
    signal    x_loop_busy           :  std_logic;
    signal    x_loop_done           :  std_logic;
    signal    x_loop_first          :  std_logic;
    signal    x_loop_last           :  std_logic;
    signal    x_atrb_vector         :  IMAGE_STREAM_ATRB_VECTOR(0 to O_PARAM.SHAPE.X.SIZE-1);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    d_loop_start          :  std_logic;
    signal    d_loop_next           :  std_logic;
    signal    d_loop_busy           :  std_logic;
    signal    d_loop_done           :  std_logic;
    signal    d_loop_first          :  std_logic;
    signal    d_loop_last           :  std_logic;
    signal    d_loop_valid          :  std_logic_vector(O_PARAM.SHAPE.D.SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    c_loop_start          :  std_logic;
    signal    c_loop_last_start     :  std_logic;
    signal    c_loop_next           :  std_logic;
    signal    c_loop_busy           :  std_logic;
    signal    c_loop_done           :  std_logic;
    signal    c_loop_first          :  std_logic;
    signal    c_loop_last           :  std_logic;
    signal    c_loop_valid          :  std_logic_vector(O_PARAM.SHAPE.C.SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    outlet_data           :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    signal    outlet_valid          :  std_logic;
    signal    outlet_ready          :  std_logic;
    signal    outlet_busy           :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- X LOOP
    -------------------------------------------------------------------------------
    X_LOOP: block
        constant  LINE_ALL_0    :  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
        signal    start_delay   :  std_logic;
        signal    x_loop_size   :  integer range 0 to O_SHAPE.X.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        x_loop_size <= O_SHAPE.X.SIZE when (O_SHAPE.X.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else X_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ATRB_GEN: IMAGE_STREAM_ATRB_GENERATOR
            generic map (
                ATRB_SIZE       => O_PARAM.SHAPE.X.SIZE, -- 
                STRIDE          => O_PARAM.STRIDE.X    , --   
                MAX_SIZE        => O_SHAPE.X.MAX_SIZE    --   
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- : In  :
                RST             => RST                 , -- : In  :
                CLR             => CLR                 , -- : In  :
                LOAD            => x_loop_start        , -- : In  :
                CHOP            => x_loop_next         , -- : In  :
                SIZE            => x_loop_size         , -- : In  :
                ATRB            => x_atrb_vector       , -- : Out :
                START           => x_loop_first        , -- : Out :
                LAST            => x_loop_last         , -- : Out :
                TERM            => open                  -- : Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- x_loop_start :
        ---------------------------------------------------------------------------
        x_loop_start <= '1' when (I_LINE_START /= LINE_ALL_0) else '0';
        ---------------------------------------------------------------------------
        -- x_loop_next  :
        ---------------------------------------------------------------------------
        x_loop_next  <= '1' when (d_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- d_loop_start : 
        ---------------------------------------------------------------------------
        d_loop_start <= '1' when (start_delay = '1') or
                                 (x_loop_next  = '1' and x_loop_last = '0') else '0';
        ---------------------------------------------------------------------------
        -- x_loop_start_delay :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin 
            if (RST = '1') then
                    start_delay <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    start_delay <= '0';
                else
                    start_delay <= x_loop_start;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- curr_bank_select  :
        -- next_bank_select  :
        -- curr_addr_select  :
        -- next_addr_select  :
        ---------------------------------------------------------------------------
        process(CLK, RST)
            variable temp_bank_select :  BANK_SELECT_VECTOR(curr_bank_select'range);
        begin 
            if (RST = '1') then
                    temp_bank_select := INIT_BANK_SELECT(O_PARAM.SHAPE.X.LO, O_PARAM.SHAPE.X.HI);
                    curr_bank_select <= temp_bank_select;
                    curr_addr_select <= CALC_ADDR_SELECT(temp_bank_select(temp_bank_select'low));
                    temp_bank_select := STRIDE_BANK_SELECT(temp_bank_select, O_PARAM.STRIDE.X);
                    next_bank_select <= temp_bank_select;
                    next_addr_select <= CALC_ADDR_SELECT(temp_bank_select(temp_bank_select'low));
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1' or x_loop_start = '1') then
                    temp_bank_select := INIT_BANK_SELECT(O_PARAM.SHAPE.X.LO, O_PARAM.SHAPE.X.HI);
                    curr_bank_select <= temp_bank_select;
                    curr_addr_select <= CALC_ADDR_SELECT(temp_bank_select(temp_bank_select'low));
                    temp_bank_select := STRIDE_BANK_SELECT(temp_bank_select, O_PARAM.STRIDE.X);
                    next_bank_select <= temp_bank_select;
                    next_addr_select <= CALC_ADDR_SELECT(temp_bank_select(temp_bank_select'low));
                elsif (x_loop_next = '1') then
                    curr_bank_select <= next_bank_select;
                    curr_addr_select <= CALC_ADDR_SELECT(next_bank_select(next_bank_select'low));
                    temp_bank_select := STRIDE_BANK_SELECT(next_bank_select, O_PARAM.STRIDE.X);
                    next_bank_select <= temp_bank_select;
                    next_addr_select <= CALC_ADDR_SELECT(temp_bank_select(temp_bank_select'low));
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- D LOOP
    -------------------------------------------------------------------------------
    D_LOOP: block
        signal    next_last     :  std_logic;
        signal    d_loop_size   :  integer range 0 to O_SHAPE.D.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        d_loop_size <= O_SHAPE.D.SIZE when (O_SHAPE.D.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else D_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => O_PARAM.SHAPE.D.SIZE, --
                MAX_LOOP_SIZE   => O_SHAPE.D.MAX_SIZE  , --
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
                LOOP_LAST       => d_loop_last         , -- Out :
                NEXT_LAST       => next_last             -- Out :
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
        ---------------------------------------------------------------------------
        -- c_loop_last_start : 
        ---------------------------------------------------------------------------
        c_loop_last_start <= '1' when (c_loop_start = '1' and next_last = '1') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- C LOOP
    -------------------------------------------------------------------------------
    C_LOOP: block
        signal    c_loop_size   :  integer range 0 to O_SHAPE.C.MAX_SIZE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        c_loop_size <= O_SHAPE.C.SIZE when (O_SHAPE.C.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else C_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => O_PARAM.SHAPE.C.SIZE, --
                MAX_LOOP_SIZE   => O_SHAPE.C.MAX_SIZE  , --
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
    L: for LINE in 0 to LINE_SIZE-1 generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    base_addr         :  unsigned(BUF_ADDR_BITS-1 downto 0);
        signal    next_addr         :  unsigned(BUF_ADDR_BITS-1 downto 0);
        signal    addr_select       :  ADDR_SELECT_TYPE;
        signal    bank_select       :  BANK_SELECT_VECTOR(curr_bank_select'range);
        signal    curr_bank_addr    :  BANK_ADDR_TYPE;
        signal    next_bank_addr    :  BANK_ADDR_TYPE;
    begin
        ---------------------------------------------------------------------------
        -- addr_select :
        -- bank_select :
        ---------------------------------------------------------------------------
        addr_select <= next_addr_select(LINE) when (x_loop_next = '1') else
                       curr_addr_select(LINE);
        bank_select <= next_bank_select       when (x_loop_next = '1') else
                       curr_bank_select      ;
        ---------------------------------------------------------------------------
        -- base_addr :
        -- next_addr : 
        ---------------------------------------------------------------------------
        process(CLK, RST) begin
            if (RST = '1') then
                    base_addr <= (others => '0');
                    next_addr <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    base_addr <= (others => '0');
                    next_addr <= (others => '0');
                elsif (x_loop_start = '1') then
                    base_addr <= (others => '0');
                    next_addr <=             to_unsigned(C_OFFSET, next_addr'length);
                elsif (c_loop_last_start = '1') and
                      (IS_LAST_BANK(bank_select, O_PARAM.STRIDE.X) = TRUE) then
                    base_addr <= next_addr;
                    next_addr <= next_addr + to_unsigned(C_OFFSET, next_addr'length);
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- next_bank_addr :
        ---------------------------------------------------------------------------
        next_bank_addr <= CALC_NEXT_BANK_ADDR(
                              CURR_BANK_ADDR => curr_bank_addr,
                              ADDR_SELECT    => addr_select   ,
                              BASE_ADDR      => base_addr     ,
                              NEXT_ADDR      => next_addr     ,
                              START_CHANNEL  => c_loop_start  ,
                              NEXT_CHANNEL   => c_loop_next   
                          );
        ---------------------------------------------------------------------------
        -- buf_addr_array(line) :
        ---------------------------------------------------------------------------
        buf_addr_array(line) <= next_bank_addr;
        ---------------------------------------------------------------------------
        -- curr_bank_addr :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin
            if (RST = '1') then
                    curr_bank_addr <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_bank_addr <= (others => (others => '0'));
                else
                    curr_bank_addr <= next_bank_addr;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- BUF_ADDR :
    -------------------------------------------------------------------------------
    process (buf_addr_array) begin
        for line in 0 to LINE_SIZE-1 loop
            for bank in 0 to BANK_SIZE-1 loop
                BUF_ADDR((line*BANK_SIZE+bank+1)*BUF_ADDR_BITS-1 downto (line*BANK_SIZE+bank)*BUF_ADDR_BITS) <= buf_addr_array(line)(bank);
            end loop;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- line_atrb_vector : 
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                line_atrb_vector <= (others => (VALID => FALSE, START => FALSE, LAST => FALSE));
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                line_atrb_vector <= (others => (VALID => FALSE, START => FALSE, LAST => FALSE));
            elsif (x_loop_start = '1') then
                for line in line_atrb_vector'range loop
                    if (I_LINE_START(line) = '1') then
                        line_atrb_vector(line) <= I_LINE_ATRB(line);
                    else
                        line_atrb_vector(line) <= (VALID => FALSE, START => FALSE, LAST => FALSE);
                    end if;
                end loop;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (x_loop_first, x_loop_last, x_atrb_vector,
             d_loop_first, d_loop_last, d_loop_valid ,
             c_loop_first, c_loop_last, c_loop_valid , curr_bank_select, BUF_DATA, line_atrb_vector)
        variable bank_data     :  std_logic_vector (BUF_DATA_BITS    -1 downto 0);
        variable o_data        :  std_logic_vector (O_PARAM.DATA.SIZE-1 downto 0);
        variable d_atrb_vector :  IMAGE_STREAM_ATRB_VECTOR(0 to O_PARAM.SHAPE.D.SIZE-1);
        variable c_atrb_vector :  IMAGE_STREAM_ATRB_VECTOR(0 to O_PARAM.SHAPE.C.SIZE-1);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for line in 0 to LINE_SIZE-1 loop
            for x_pos in curr_bank_select'range loop
                bank_data := (others => '0');
                for bank in 0 to BANK_SIZE-1 loop
                    if (curr_bank_select(x_pos)(bank) = '1') then
                        bank_data := bank_data or BUF_DATA((line*BANK_SIZE*BUF_DATA_BITS)+(bank+1)*BUF_DATA_BITS-1 downto
                                                           (line*BANK_SIZE*BUF_DATA_BITS)+(bank  )*BUF_DATA_BITS);
                    end if;
                end loop;
                for c_pos in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
                    SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                        PARAM   => O_PARAM,
                        C       => c_pos + O_PARAM.SHAPE.C.LO,
                        D       =>         O_PARAM.SHAPE.D.LO,
                        X       => x_pos,
                        Y       => line  + O_PARAM.SHAPE.Y.LO,
                        ELEMENT => bank_data((c_pos+1)*O_PARAM.ELEM_BITS-1 downto (c_pos)*O_PARAM.ELEM_BITS),
                        DATA    => o_data
                    );
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
        SET_ATRB_C_VECTOR_TO_IMAGE_STREAM_DATA(O_PARAM, c_atrb_vector   , o_data);
        SET_ATRB_D_VECTOR_TO_IMAGE_STREAM_DATA(O_PARAM, d_atrb_vector   , o_data);
        SET_ATRB_X_VECTOR_TO_IMAGE_STREAM_DATA(O_PARAM, x_atrb_vector   , o_data);
        SET_ATRB_Y_VECTOR_TO_IMAGE_STREAM_DATA(O_PARAM, line_atrb_vector, o_data);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        outlet_data <= o_data;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    QUEUE: PIPELINE_REGISTER                   -- 
        generic map (                          -- 
            QUEUE_SIZE  => QUEUE_SIZE        , --
            WORD_BITS   => O_PARAM.DATA.SIZE   -- 
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
