-----------------------------------------------------------------------------------
--!     @file    image_stream_buffer_bank_memory_writer.vhd
--!     @brief   Image Stream Buffer Bank Memory Writer Module :
--!              異なる形のイメージストリームを継ぐためのバッファのバンク分割型メモ
--!              リ書込み側モジュール
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
--! @brief   Image Stream Buffer Bank Memory Writer Module :
--!          異なる形のイメージストリームを継ぐためのバッファのバンク分割型メモリ
--!          書込み側モジュール
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_BUFFER_BANK_MEMORY_WRITER is
    generic (
        I_PARAM         : --! @brief INPUT  STREAM PARAMETER :
                          --! 入力側のストリームのパラメータを指定する.
                          --! * I_PARAM.SHAPE.D.SIZE = 1 でなければならない.
                          --! * I_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        I_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 入力側のイメージの形(SHAPE)を指定する.
                          --! * このモジュールでは I_SHAPE.C のみを使用する.
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
        BUF_ADDR_BITS   : --! メモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! メモリのデータのビット幅を指定する.
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
        I_ENABLE        : --! @brief INPUT STREAM ENABLE :
                          in  std_logic;
        I_LINE_START    : --! @brief INPUT STREAM LINE START :
                          --  ラインの入力を開始することを示す.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_DONE     : --! @brief INPUT STREAM LINE DONE :
                          --  ラインの入力が終了したことを示す.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        I_DATA          : --! @brief INPUT STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          in  std_logic;
        I_READY         : --! @brief INPUT STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_X_SIZE        : --! @brief OUTPUT X SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_SIZE        : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_OFFSET      : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- バッファ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER WRITE DATA :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
        BUF_WE          : --! @brief BUFFER WRITE ENABLE :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE              -1 downto 0)
    );
end IMAGE_STREAM_BUFFER_BANK_MEMORY_WRITER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
architecture RTL of IMAGE_STREAM_BUFFER_BANK_MEMORY_WRITER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   RAM_DATA_TYPE         is std_logic_vector(BUF_DATA_BITS-1 downto 0);
    subtype   RAM_ADDR_TYPE         is std_logic_vector(BUF_ADDR_BITS-1 downto 0);
    constant  BUF_WENA_BITS         :  integer := 1;
    subtype   RAM_WENA_TYPE         is std_logic_vector(BUF_WENA_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      BANK_DATA_TYPE        is array(0 to BANK_SIZE-1) of RAM_DATA_TYPE;
    type      BANK_ADDR_TYPE        is array(0 to BANK_SIZE-1) of RAM_ADDR_TYPE;
    type      BANK_WENA_TYPE        is array(0 to BANK_SIZE-1) of RAM_WENA_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      BUF_DATA_TYPE         is array(0 to LINE_SIZE-1) of BANK_DATA_TYPE;
    type      BUF_ADDR_TYPE         is array(0 to LINE_SIZE-1) of BANK_ADDR_TYPE;
    type      BUF_WENA_TYPE         is array(0 to LINE_SIZE-1) of BANK_WENA_TYPE;
    signal    buf_data_array        :  BUF_DATA_TYPE;
    signal    buf_addr_array        :  BUF_ADDR_TYPE;
    signal    buf_wena_array        :  BUF_WENA_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   BANK_SELECT_TYPE      is std_logic_vector(0 to BANK_SIZE-1);
    type      BANK_SELECT_VECTOR    is array(integer range <>) of BANK_SELECT_TYPE;
    signal    bank_select           :  BANK_SELECT_VECTOR(I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI);
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
    function  CALC_NEXT_BANK_ADDR(
                  CURR_BANK_ADDR    :  BANK_ADDR_TYPE;
                  BANK_SELECT       :  BANK_SELECT_VECTOR;
                  BASE_ADDR         :  unsigned;
                  CHANNEL_OFFSET    :  integer;
                  START_CHANNEL     :  std_logic
              )   return               BANK_ADDR_TYPE
    is
        variable  next_bank_addr    :  BANK_ADDR_TYPE;
        variable  base_curr_addr    :  RAM_ADDR_TYPE;
        variable  base_next_addr    :  RAM_ADDR_TYPE;
        variable  select_next_addr  :  boolean;
    begin
        if (START_CHANNEL = '1') then
            base_curr_addr := std_logic_vector(BASE_ADDR                 );
            base_next_addr := std_logic_vector(BASE_ADDR + CHANNEL_OFFSET);
            select_next_addr      := TRUE;
            for bank in 0 to BANK_SIZE-1 loop
                if (select_next_addr = TRUE and BANK_SELECT(BANK_SELECT'low)(bank) = '1') then
                    select_next_addr := FALSE;
                end if;
                if (select_next_addr = TRUE) then
                    next_bank_addr(bank) := base_next_addr;
                else
                    next_bank_addr(bank) := base_curr_addr;
                end if;
            end loop;
        else
            for bank in 0 to BANK_SIZE-1 loop
                next_bank_addr(bank) := std_logic_vector(unsigned(CURR_BANK_ADDR(bank)) + 1);
            end loop;
        end if;
        return next_bank_addr;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  CALC_ATRB_VALID_COUNT(
                  PARAM      :  IMAGE_STREAM_PARAM_TYPE;
                  ATRB_VEC   :  IMAGE_STREAM_ATRB_VECTOR)
                  return        integer
    is
        alias     i_atrb_vec :  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_VEC'length-1) is ATRB_VEC;
        variable  count      :  integer range 0 to ATRB_VEC'length;
    begin
        if (i_atrb_vec'length = 1) then
            if (i_atrb_vec(0).VALID = TRUE) then
                count := 1;
            else
                count := 0;
            end if;
        else
            count := CALC_ATRB_VALID_COUNT(PARAM, i_atrb_vec(0                   to i_atrb_vec'high/2))
                   + CALC_ATRB_VALID_COUNT(PARAM, i_atrb_vec(i_atrb_vec'high/2+1 to i_atrb_vec'high  ));
        end if;
        return count;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  LINE_ALL_0            :  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    signal    intake_line_busy      :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    intake_line_done      :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    intake_line_start     :  std_logic_vector(LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    base_addr             :  unsigned(BUF_ADDR_BITS-1 downto 0);
    signal    channel_offset        :  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_c_start        :  std_logic;
    signal    intake_c_last         :  std_logic;
    signal    intake_x_start        :  std_logic;
    signal    intake_x_last         :  std_logic;
    signal    intake_y_start        :  std_logic;
    signal    intake_y_last         :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_ready          :  std_logic;
    signal    intake_x_count        :  integer range 0 to ELEMENT_SIZE;
    signal    intake_channel_count  :  integer range 0 to ELEMENT_SIZE;
    signal    intake_last_atrb_c    :  IMAGE_STREAM_ATRB_VECTOR(I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI);
begin
    -------------------------------------------------------------------------------
    -- 入力データの各種属性
    -------------------------------------------------------------------------------
    -- intake_c_start    : 
    -- intake_c_last     : 
    -- intake_x_start    : 
    -- intake_x_last     : 
    -- intake_y_start    : 
    -- intake_y_last     : 
    -------------------------------------------------------------------------------
    process (I_DATA) 
        variable atrb_y  :  IMAGE_STREAM_ATRB_TYPE;
    begin
        if (IMAGE_STREAM_DATA_IS_START_C(PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_c_start <= '1';
        else
            intake_c_start <= '0';
        end if;
        if (IMAGE_STREAM_DATA_IS_LAST_C( PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_c_last  <= '1';
        else
            intake_c_last  <= '0';
        end if;
        if (IMAGE_STREAM_DATA_IS_START_X(PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_x_start <= '1';
        else
            intake_x_start <= '0';
        end if;
        if (IMAGE_STREAM_DATA_IS_LAST_X( PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_x_last  <= '1';
        else
            intake_x_last  <= '0';
        end if;
        intake_y_start <= '0';
        intake_y_last  <= '0';
        for line in I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI loop
            atrb_y := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(PARAM => I_PARAM, Y => line, DATA => I_DATA);
            if (atrb_y.VALID and atrb_y.START) then
                intake_y_start <= '1';
            end if;
            if (atrb_y.VALID and atrb_y.LAST ) then
                intake_y_last  <= '1';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- intake_ready : 入力可能であることを示す.
    -- I_READY      : 入力可能であることを示す.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin 
        if (RST = '1') then
                intake_ready <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                intake_ready <= '0';
            elsif (intake_ready <= '0' and I_LINE_START /= LINE_ALL_0) then
                intake_ready <= '1';
            elsif (I_VALID = '1' and intake_ready = '1' and intake_x_last = '1' and intake_c_last = '1') then
                intake_ready <= '0';
            end if;
        end if;
    end process;
    I_READY <= intake_ready;
    -------------------------------------------------------------------------------
    -- bank_select  : バンク選択信号
    -- base_addr    : ベースアドレス
    -------------------------------------------------------------------------------
    process(CLK, RST) begin 
        if (RST = '1') then
                bank_select  <= INIT_BANK_SELECT(I_PARAM.SHAPE.X.LO, I_PARAM.SHAPE.X.HI);
                base_addr    <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or I_LINE_START /= LINE_ALL_0) then
                bank_select  <= INIT_BANK_SELECT(I_PARAM.SHAPE.X.LO, I_PARAM.SHAPE.X.HI);
                base_addr    <= (others => '0');
            else
                if (I_VALID = '1' and intake_ready = '1' and intake_c_last = '1') then
                    if (IS_LAST_BANK(bank_select, I_PARAM.STRIDE.X) = TRUE) then
                        base_addr <= base_addr + channel_offset;
                    end if;
                    bank_select <= STRIDE_BANK_SELECT(bank_select, I_PARAM.STRIDE.X);
                end if;
            end if;
        end if;
    end process;
    I_READY <= intake_ready;
    -------------------------------------------------------------------------------
    -- I_SHAPE.C.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT でない場合
    -------------------------------------------------------------------------------
    -- channel_offset : 
    -- O_C_OFFSET     : 
    -- O_C_SIZE       : 
    -------------------------------------------------------------------------------
    I_SHAPE_C_AUTO: if (I_SHAPE.C.DICIDE_TYPE /= IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) generate
        signal    curr_channel_offset :  integer range 0 to 2**BUF_ADDR_BITS;
        signal    curr_channel_count  :  integer range 0 to ELEMENT_SIZE;
    begin
        channel_offset <= 1                       when (intake_x_start = '1' and intake_c_start = '1') else
                          curr_channel_offset + 1 when (intake_x_start = '1' and intake_c_start = '0') else
                          curr_channel_offset;
        process (CLK, RST)
            variable  atrb_c_vector  :  IMAGE_STREAM_ATRB_VECTOR(I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI);
        begin
            if (RST = '1') then
                    curr_channel_offset <= 0;
                    curr_channel_count  <= 0;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or I_ENABLE = '0') then
                    curr_channel_offset <= 0;
                    curr_channel_count  <= 0;
                elsif (I_VALID = '1' and intake_ready = '1' and intake_y_start = '1' and intake_x_start = '1') then
                    curr_channel_offset <= channel_offset;
                    atrb_c_vector       := GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(I_PARAM, I_DATA);
                    curr_channel_count  <= curr_channel_count + CALC_ATRB_VALID_COUNT(I_PARAM, atrb_c_vector);
                end if;
            end if;
        end process;
        O_C_OFFSET <= curr_channel_offset;
        O_C_SIZE   <= curr_channel_count;
    end generate;
    -------------------------------------------------------------------------------
    -- I_SHAPE.C.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT の場合
    -------------------------------------------------------------------------------
    -- channel_offset :
    -- O_C_SIZE       : 
    -------------------------------------------------------------------------------
    I_SHAPE_C_CONSTANT: if (I_SHAPE.C.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) generate
    begin
        channel_offset <= (I_SHAPE.C.SIZE + I_PARAM.SHAPE.C.SIZE - 1) / I_PARAM.SHAPE.C.SIZE;
        O_C_OFFSET     <= (I_SHAPE.C.SIZE + I_PARAM.SHAPE.C.SIZE - 1) / I_PARAM.SHAPE.C.SIZE;
        O_C_SIZE       <=  I_SHAPE.C.SIZE;
    end generate;
    -------------------------------------------------------------------------------
    -- intake_x_count :
    -- O_X_SIZE       : 
    -------------------------------------------------------------------------------
    process(CLK, RST)
        variable  atrb_x_vector  :  IMAGE_STREAM_ATRB_VECTOR(I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI);
    begin 
        if (RST = '1') then
                intake_x_count <= 0;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or I_ENABLE = '0') then
                intake_x_count <= 0;
            elsif (I_VALID = '1' and intake_ready = '1' and intake_y_start = '1' and intake_c_last = '1') then
                atrb_x_vector  := GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(I_PARAM, I_DATA);
                intake_x_count <= intake_x_count + CALC_ATRB_VALID_COUNT(I_PARAM, atrb_x_vector);
            end if;
        end if;
    end process;
    O_X_SIZE <= intake_x_count;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    L: for line in 0 to LINE_SIZE-1 generate
    begin
        ---------------------------------------------------------------------------
        -- intake_line_start(line)  :
        ---------------------------------------------------------------------------
        intake_line_start(line) <= '1' when (intake_line_busy(line) = '0') and
                                            (I_LINE_START /= LINE_ALL_0  ) and
                                            (I_LINE_START(line)     = '1') else '0';
        ---------------------------------------------------------------------------
        -- intake_line_done(line)   :
        -- I_LINE_DONE(line)        :
        ---------------------------------------------------------------------------
        intake_line_done(line)  <= '1' when (intake_line_busy(line) = '1'               ) and
                                            (I_VALID       = '1' and intake_ready  = '1') and
                                            (intake_x_last = '1' and intake_c_last = '1') else '0';
        I_LINE_DONE(line) <= intake_line_done(line);
        ---------------------------------------------------------------------------
        -- intake_line_busy(line)   :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin 
            if (RST = '1') then
                    intake_line_busy(line) <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    intake_line_busy(line) <= '0';
                elsif (intake_line_start(line) = '1') then
                    intake_line_busy(line) <= '1';
                elsif (intake_line_done(line)  = '1') then
                    intake_line_busy(line) <= '0';
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- buf_wena_array :
        ---------------------------------------------------------------------------
        process(CLK, RST)
            variable  atrb_x_vec    :  IMAGE_STREAM_ATRB_VECTOR(I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI);
            variable  bank_we       :  std_logic;
        begin 
            if (RST = '1') then
                    buf_wena_array(line) <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    buf_wena_array(line) <= (others => (others => '0'));
                elsif (I_VALID = '1' and intake_ready = '1' and intake_line_busy(line) = '1') then
                    atrb_x_vec := GET_ATRB_X_VECTOR_FROM_IMAGE_STREAM_DATA(I_PARAM, I_DATA);
                    for bank in 0 to BANK_SIZE-1 loop
                        bank_we := '0';
                        for x_pos in bank_select'range loop
                            if (bank_select(x_pos)(bank) = '1' and atrb_x_vec(x_pos).VALID = TRUE) then
                                bank_we := bank_we or '1';
                            end if;
                        end loop;
                        if (bank_we = '1') then
                            buf_wena_array(line)(bank) <= (others => '1');
                        else
                            buf_wena_array(line)(bank) <= (others => '0');
                        end if;
                    end loop;
                else
                    buf_wena_array(line) <= (others => (others => '0'));
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- bank_addr_array :
        ---------------------------------------------------------------------------
        process(CLK, RST)
        begin
            if (RST = '1') then
                    buf_addr_array(line) <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or intake_line_busy(line) = '0') then
                    buf_addr_array(line) <= (others => (others => '0'));
                elsif (I_VALID = '1' and intake_ready = '1') then
                    buf_addr_array(line) <= CALC_NEXT_BANK_ADDR(
                                                CURR_BANK_ADDR => buf_addr_array(line),
                                                BANK_SELECT    => bank_select         ,
                                                BASE_ADDR      => base_addr           ,
                                                CHANNEL_OFFSET => channel_offset      ,
                                                START_CHANNEL  => intake_c_start
                                            );
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- bank_addr_array :
        ---------------------------------------------------------------------------
        process(CLK, RST)
            constant  TEMP_PARAM :  IMAGE_STREAM_PARAM_TYPE
                                 := NEW_IMAGE_STREAM_PARAM(
                                        ELEM_BITS => I_PARAM.ELEM_BITS,
                                        C         => I_PARAM.SHAPE.C,
                                        X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                        Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1)
                                    );
            variable  temp_data  :  std_logic_vector(TEMP_PARAM.DATA.SIZE-1 downto 0);
            variable  elem_data  :  std_logic_vector(TEMP_PARAM.ELEM_BITS-1 downto 0);
            variable  bank_data  :  std_logic_vector(BUF_DATA_BITS       -1 downto 0);
        begin 
            if (RST = '1') then
                    buf_data_array(line) <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    buf_data_array(line) <= (others => (others => '0'));
                else
                    for bank in 0 to BANK_SIZE-1 loop
                        bank_data := (others => '0');
                        temp_data := (others => '0');
                        for x_pos in I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI loop
                            if (bank_select(x_pos)(bank) = '1') then
                                for c_pos in I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI loop
                                    elem_data := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                                                     PARAM   => I_PARAM,
                                                     C       => c_pos,
                                                     D       => I_PARAM.SHAPE.D.LO,
                                                     X       => x_pos,
                                                     Y       => line+I_PARAM.SHAPE.Y.LO,
                                                     DATA    => I_DATA
                                                 );
                                    SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                                                     PARAM   => TEMP_PARAM,
                                                     C       => c_pos,
                                                     D       => I_PARAM.SHAPE.D.LO,
                                                     X       => 0,
                                                     Y       => 0,
                                                     ELEMENT => elem_data,
                                                     DATA    => temp_data
                                    );
                                end loop;
                                bank_data := bank_data or temp_data(TEMP_PARAM.DATA.ELEM_FIELD.HI downto TEMP_PARAM.DATA.ELEM_FIELD.LO);
                            end if;
                        end loop;
                        buf_data_array(line)(bank) <= bank_data;
                    end loop;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- BUF_WE :
    -------------------------------------------------------------------------------
    process (buf_wena_array) begin
        for line in 0 to LINE_SIZE-1 loop
            for bank in 0 to BANK_SIZE-1 loop
                BUF_WE  ((line*BANK_SIZE+bank+1)*BUF_WENA_BITS-1 downto (line*BANK_SIZE+bank)*BUF_WENA_BITS) <= buf_wena_array(line)(bank);
            end loop;
        end loop;
    end process;
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
    -- BUF_DATA :
    -------------------------------------------------------------------------------
    process (buf_data_array) begin
        for line in 0 to LINE_SIZE-1 loop
            for bank in 0 to BANK_SIZE-1 loop
                BUF_DATA((line*BANK_SIZE+bank+1)*BUF_DATA_BITS-1 downto (line*BANK_SIZE+bank)*BUF_DATA_BITS) <= buf_data_array(line)(bank);
            end loop;
        end loop;
    end process;
end RTL;
