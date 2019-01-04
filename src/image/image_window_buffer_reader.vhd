-----------------------------------------------------------------------------------
--!     @file    image_window_buffer_reader.vhd
--!     @brief   Image Window Buffer Reader Module :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2018/12/27
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018 Ichiro Kawazome
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
--! @brief   IMAGE_WINDOW_BUFFER_READER :
--!          異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_BUFFER_READER is
    generic (
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        MAX_D_SIZE      : --! @brief MAX OUTPUT CHANNEL SIZE :
                          integer := 1;
        D_STRIDE        : --! @brief OUTPUT CHANNEL STRIDE SIZE :
                          integer := 1;
        D_UNROLL        : --! @brief OUTPUT CHANNEL UNROLL SIZE :
                          integer := 1;
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_LINE_START    : --! @brief INPUT LINE START :
                          --! ライン開始信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_ATRB     : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_D_SIZE := 1;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        C_OFFSET        : --! @brief OUTPUT CHANNEL BUFFER ADDRESS OFFSET :
                          in  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT WINDOW DATA :
                          --! ウィンドウデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT WINDOW DATA VALID :
                          --! 出力ウィンドウデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT WINDOW DATA READY :
                          --! 出力ウィンドウデータレディ信号.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end IMAGE_WINDOW_BUFFER_READER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_ATRB_GENERATOR;
use     PIPEWORK.COMPONENTS.UNROLLED_LOOP_COUNTER;
use     PIPEWORK.COMPONENTS.QUEUE_REGISTER;
architecture RTL of IMAGE_WINDOW_BUFFER_READER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   RAM_DATA_TYPE         is std_logic_vector(BUF_DATA_BITS-1 downto 0);
    type      RAM_DATA_VECTOR       is array(integer range <>) of RAM_DATA_TYPE;
    subtype   RAM_ADDR_TYPE         is std_logic_vector(BUF_ADDR_BITS-1 downto 0);
    type      RAM_ADDR_VECTOR       is array(integer range <>) of RAM_ADDR_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   BANK_SELECT_TYPE      is std_logic_vector(0 to BANK_SIZE-1);
    type      BANK_SELECT_VECTOR    is array(integer range <>) of BANK_SELECT_TYPE;
    signal    bank_select           :  BANK_SELECT_VECTOR(O_PARAM.SHAPE.X.LO to O_PARAM.SHAPE.X.HI);
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
    function  NEXT_RAM_ADDR_VECTOR(
                  RAM_ADDR          :  RAM_ADDR_VECTOR;
                  BANK_SELECT       :  BANK_SELECT_VECTOR;
                  BASE_ADDR         :  integer;
                  CHANNEL_OFFSET    :  integer;
                  START_CHANNEL     :  std_logic;
                  NEXT_CHANNEL      :  std_logic
              )   return               RAM_ADDR_VECTOR
    is
        variable  next_addr_vector  :  RAM_ADDR_VECTOR(0 to BANK_SIZE-1);
        variable  base_curr_addr    :  RAM_ADDR_TYPE;
        variable  base_next_addr    :  RAM_ADDR_TYPE;
        variable  select_next_addr  :  boolean;
    begin
        if (START_CHANNEL = '1') then
            base_curr_addr := std_logic_vector(to_unsigned(BASE_ADDR                 , RAM_ADDR_TYPE'length));
            base_next_addr := std_logic_vector(to_unsigned(BASE_ADDR + CHANNEL_OFFSET, RAM_ADDR_TYPE'length));
            select_next_addr      := TRUE;
            for bank in 0 to BANK_SIZE-1 loop
                if (select_next_addr = TRUE and BANK_SELECT(BANK_SELECT'low)(bank) = '1') then
                    select_next_addr := FALSE;
                end if;
                if (select_next_addr = TRUE) then
                    next_addr_vector(bank) := base_next_addr;
                else
                    next_addr_vector(bank) := base_curr_addr;
                end if;
            end loop;
        elsif (NEXT_CHANNEL = '1') then
            for bank in 0 to BANK_SIZE-1 loop
                next_addr_vector(bank) := std_logic_vector(unsigned(RAM_ADDR(bank)) + 1);
            end loop;
        else
            for bank in 0 to BANK_SIZE-1 loop
                next_addr_vector(bank) := RAM_ADDR(bank);
            end loop;
        end if;
        return next_addr_vector;
    end function;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    line_atrb_vector      :  IMAGE_ATRB_VECTOR(0 to LINE_SIZE-1);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    x_loop_start          :  std_logic;
    signal    x_loop_next           :  std_logic;
    signal    x_loop_busy           :  std_logic;
    signal    x_loop_done           :  std_logic;
    signal    x_loop_first          :  std_logic;
    signal    x_loop_last           :  std_logic;
    signal    x_atrb_vector         :  IMAGE_ATRB_VECTOR(O_PARAM.SHAPE.X.LO to O_PARAM.SHAPE.X.HI);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    d_loop_start          :  std_logic;
    signal    d_loop_next           :  std_logic;
    signal    d_loop_busy           :  std_logic;
    signal    d_loop_done           :  std_logic;
    signal    d_loop_first          :  std_logic;
    signal    d_loop_last           :  std_logic;
    signal    d_loop_valid          :  std_logic_vector(D_UNROLL-1 downto 0);
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
begin
    -------------------------------------------------------------------------------
    -- X LOOP
    -------------------------------------------------------------------------------
    X_LOOP: block
        constant  LINE_ALL_0    :  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
        signal    start_delay   :  std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ATRB_GEN: IMAGE_ATRB_GENERATOR
            generic map (
                ATRB_SIZE       => O_PARAM.SHAPE.X.SIZE, -- 
                STRIDE          => O_PARAM.STRIDE.X    , --   
                MAX_SIZE        => ELEMENT_SIZE          --   
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- : In  :
                RST             => RST                 , -- : In  :
                CLR             => CLR                 , -- : In  :
                LOAD            => x_loop_start        , -- : In  :
                CHOP            => x_loop_next         , -- : In  :
                SIZE            => X_SIZE              , -- : In  :
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
        -- bank_select  :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin 
            if (RST = '1') then
                    bank_select <= INIT_BANK_SELECT(O_PARAM.SHAPE.X.LO, O_PARAM.SHAPE.X.HI);
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1' or x_loop_start = '1') then
                    bank_select <= INIT_BANK_SELECT(O_PARAM.SHAPE.X.LO, O_PARAM.SHAPE.X.HI);
                elsif (x_loop_next = '1') then
                    bank_select <= STRIDE_BANK_SELECT(bank_select, O_PARAM.STRIDE.X);
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- D LOOP
    -------------------------------------------------------------------------------
    D_LOOP: block
        signal    next_last     :  std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => D_STRIDE            , --
                UNROLL          => D_UNROLL            , --
                MAX_LOOP_SIZE   => MAX_D_SIZE          , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => d_loop_start        , -- In  :
                LOOP_NEXT       => d_loop_next         , -- In  :
                LOOP_SIZE       => D_SIZE              , -- In  :
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
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        COUNT: UNROLLED_LOOP_COUNTER                     -- 
            generic map (                                -- 
                STRIDE          => 1                   , --
                UNROLL          => O_PARAM.SHAPE.C.SIZE, --
                MAX_LOOP_SIZE   => ELEMENT_SIZE        , --
                MAX_LOOP_INIT   => 0                     --
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
                LOOP_START      => c_loop_start        , -- In  :
                LOOP_NEXT       => c_loop_next         , -- In  :
                LOOP_SIZE       => C_SIZE              , -- In  :
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
        -- c_loop_done :
        ---------------------------------------------------------------------------
        c_loop_done  <= '1' when (c_loop_next = '1'  and c_loop_last  = '1') else '0';
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
        signal    base_addr         :  integer range 0 to 2**BUF_ADDR_BITS-1;
        signal    channel_offset    :  integer range 0 to 2**BUF_ADDR_BITS;
        signal    curr_bank_addr    :  RAM_ADDR_VECTOR(0 to BANK_SIZE-1);
        signal    next_bank_addr    :  RAM_ADDR_VECTOR(0 to BANK_SIZE-1);
    begin
        ---------------------------------------------------------------------------
        -- base_addr      :
        -- channel_offset : 
        ---------------------------------------------------------------------------
        process(CLK, RST) begin
            if (RST = '1') then
                    base_addr      <= 0;
                    channel_offset <= 0;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    base_addr      <= 0;
                    channel_offset <= 0;
                elsif (x_loop_start = '1') then
                    base_addr      <= 0;
                    channel_offset <= C_OFFSET;
                elsif (c_loop_last_start = '1') and
                      (IS_LAST_BANK(bank_select, O_PARAM.STRIDE.X) = TRUE) then
                    base_addr <= base_addr + channel_offset;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- next_bank_addr :
        ---------------------------------------------------------------------------
        next_bank_addr <= NEXT_RAM_ADDR_VECTOR(
                              RAM_ADDR       => curr_bank_addr,
                              BANK_SELECT    => bank_select   ,
                              BASE_ADDR      => base_addr     ,
                              CHANNEL_OFFSET => channel_offset,
                              START_CHANNEL  => c_loop_start  ,
                              NEXT_CHANNEL   => c_loop_next   
                          );
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
        ---------------------------------------------------------------------------
        -- BUF_ADDR :
        ---------------------------------------------------------------------------
        process (next_bank_addr) begin
            for bank in 0 to BANK_SIZE-1 loop
                BUF_ADDR((LINE*BANK_SIZE+bank+1)*BUF_ADDR_BITS-1 downto (LINE*BANK_SIZE+bank)*BUF_ADDR_BITS) <= next_bank_addr(bank);
            end loop;
        end process;
    end generate;
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
             c_loop_first, c_loop_last, c_loop_valid , bank_select, BUF_DATA, line_atrb_vector)
        variable bank_data  :  std_logic_vector (BUF_DATA_BITS    -1 downto 0);
        variable o_data     :  std_logic_vector (O_PARAM.DATA.SIZE-1 downto 0);
        variable d_atrb     :  IMAGE_ATRB_VECTOR(0 to D_UNROLL-1);
        variable c_atrb     :  IMAGE_ATRB_VECTOR(0 to O_PARAM.SHAPE.C.SIZE-1);
        function GEN_ATRB_VECTOR(LOOP_VALID: std_logic_vector; LOOP_FIRST, LOOP_LAST: std_logic) return IMAGE_ATRB_VECTOR is
            variable  atrb_vector  :  IMAGE_ATRB_VECTOR(0 to LOOP_VALID'length-1);
            variable  first        :  std_logic;
            variable  last         :  std_logic;
        begin
            first := LOOP_FIRST;
            for i in atrb_vector'low to atrb_vector'high loop
                if (first = '1') then
                    atrb_vector(i).START := TRUE;
                    if (LOOP_VALID(i) = '1') then
                        first := '0';
                    end if;
                else
                    atrb_vector(i).START := FALSE;
                end if;
                atrb_vector(i).VALID := (LOOP_VALID(i) = '1');
            end loop;
            last := LOOP_LAST;
            for i in atrb_vector'high downto atrb_vector'low loop
                if (last = '1') then
                    atrb_vector(i).LAST := TRUE;
                    if (LOOP_VALID(i) = '1') then
                        last := '0';
                    end if;
                else
                    atrb_vector(i).LAST := FALSE;
                end if;
            end loop;
            return atrb_vector;
        end function;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for line in 0 to LINE_SIZE-1 loop
            for x_pos in bank_select'range loop
                bank_data := (others => '0');
                for bank in 0 to BANK_SIZE-1 loop
                    if (bank_select(x_pos)(bank) = '1') then
                        bank_data := bank_data or BUF_DATA((line*BANK_SIZE*BUF_DATA_BITS)+(bank+1)*BUF_DATA_BITS-1 downto
                                                           (line*BANK_SIZE*BUF_DATA_BITS)+(bank  )*BUF_DATA_BITS);
                    end if;
                end loop;
                for c_pos in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
                    SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                        PARAM   => O_PARAM,
                        C       => c_pos + O_PARAM.SHAPE.C.LO,
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
        for line in 0 to LINE_SIZE-1 loop
            SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                PARAM   => O_PARAM,
                Y       => line + O_PARAM.SHAPE.Y.LO,
                ATRB    => line_atrb_vector(line),
                DATA    => o_data
            );
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for x_pos in 0 to O_PARAM.SHAPE.X.SIZE-1 loop
            SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                PARAM   => O_PARAM,
                X       => x_pos + O_PARAM.SHAPE.X.LO,
                ATRB    => x_atrb_vector(x_pos),
                DATA    => o_data
            );
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        d_atrb := GEN_ATRB_VECTOR(d_loop_valid, d_loop_first, d_loop_last);
        for d_pos in 0 to D_UNROLL-1 loop
            if d_atrb(d_pos).VALID then
                o_data(O_PARAM.DATA.INFO_FIELD.LO+(d_pos*IMAGE_ATRB_BITS)+IMAGE_ATRB_VALID_POS) := '1';
            else
                o_data(O_PARAM.DATA.INFO_FIELD.LO+(d_pos*IMAGE_ATRB_BITS)+IMAGE_ATRB_VALID_POS) := '0';
            end if;
            if d_atrb(d_pos).START then
                o_data(O_PARAM.DATA.INFO_FIELD.LO+(d_pos*IMAGE_ATRB_BITS)+IMAGE_ATRB_START_POS) := '1';
            else
                o_data(O_PARAM.DATA.INFO_FIELD.LO+(d_pos*IMAGE_ATRB_BITS)+IMAGE_ATRB_START_POS) := '0';
            end if;
            if d_atrb(d_pos).LAST  then
                o_data(O_PARAM.DATA.INFO_FIELD.LO+(d_pos*IMAGE_ATRB_BITS)+IMAGE_ATRB_LAST_POS ) := '1';
            else
                o_data(O_PARAM.DATA.INFO_FIELD.LO+(d_pos*IMAGE_ATRB_BITS)+IMAGE_ATRB_LAST_POS ) := '0';
            end if;
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        c_atrb := GEN_ATRB_VECTOR(c_loop_valid, c_loop_first, c_loop_last);
        for c_pos in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
            SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                PARAM => O_PARAM,
                C     => c_pos + O_PARAM.SHAPE.C.LO,
                ATRB  => c_atrb(c_pos),
                DATA  => o_data
            );
        end loop;
        outlet_data <= o_data;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    OUTLET: block
        constant   QUEUE_SIZE :  integer := 2;
        signal     q_valid    :  std_logic_vector(QUEUE_SIZE downto 0);
    begin 
        QUEUE: QUEUE_REGISTER                      -- 
            generic map (                          -- 
                QUEUE_SIZE  => QUEUE_SIZE        , --
                DATA_BITS   => O_PARAM.DATA.SIZE   -- 
            )                                      -- 
            port map (                             -- 
                CLK         => CLK               , -- In  :
                RST         => RST               , -- In  :
                CLR         => CLR               , -- In  :
                I_DATA      => outlet_data       , -- In  :
                I_VAL       => outlet_valid      , -- In  :
                I_RDY       => outlet_ready      , -- Out :
                Q_DATA      => O_DATA            , -- Out :
                Q_VAL       => q_valid           , -- Out :
                Q_RDY       => O_READY             -- In  :
            );
        O_VALID <= q_valid(0);
    end block;
end RTL;
