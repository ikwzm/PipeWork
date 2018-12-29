-----------------------------------------------------------------------------------
--!     @file    image_window_buffer_writer.vhd
--!     @brief   Image Window Buffer Writer MODULE :
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
--! @brief   IMAGE_WINDOW_BUFFER :
--!          異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_BUFFER_WRITER is
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
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
        I_DATA          : --! @brief INPUT WINDOW DATA :
                          --! ウィンドウデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_START_C       : --! @brief INPUT WINDOW CHANNEL START :
                          --! ウィンドウがチャネルの最初であることを示す. 
                          in  std_logic;
        I_LAST_C        : --! @brief INPUT WINDOW CHANNEL LAST :
                          --! ウィンドウがチャネルの最後であることを示す. 
                          in  std_logic;
        I_START_X       : --! @brief INPUT WINDOW CHANNEL X :
                          --! ウィンドウが X方向の最初であることを示す. 
                          in  std_logic;
        I_LAST_X        : --! @brief INPUT WINDOW CHANNEL X :
                          --! ウィンドウが X方向の最後であることを示す. 
                          in  std_logic;
        I_START_Y       : --! @brief INPUT WINDOW CHANNEL Y :
                          --! ウィンドウが Y方向の最初であることを示す. 
                          in  std_logic;
        I_LAST_Y        : --! @brief INPUT WINDOW CHANNEL Y :
                          --! ウィンドウが Y方向の最後であることを示す. 
                          in  std_logic;
        I_VALID         : --! @brief INPUT WINDOW DATA VALID :
                          --! 入力ウィンドウデータ有効信号.
                          --! * I_DATA/I_START_C/I_LAST_C/I_START_X/I_LAST_Xが有効
                          --! であることを示す.
                          in  std_logic;
        I_CLEAR         : --! @brief INPUT WINDOW STATE CLEAR :
                          in  std_logic;
        I_LINE_IDLE     : --! @brief INPUT WINDOW LINE IDLE :
                          in  std_logic;
        I_LINE_START    : --! @brief INPUT WINDOW LINE START :
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_READY    : --! @brief INPUT WINDOW LINE READY :
                          out std_logic_vector(LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_LINE_VALID    : --! @brief OUTPUT LINE VALID :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        O_X_SIZE        : --! @brief OUTPUT X SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_SIZE        : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_OFFSET      : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to 2**BUF_ADDR_BITS;
        O_LINE_ATRB     : --! @brief OUTPUT LINE ATTRIBUTE :
                          out IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        O_LINE_FEED     : --! @brief OUTPUT LINE FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        O_LINE_RETURN   : --! @brief OUTPUT LINE RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
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
end IMAGE_WINDOW_BUFFER_WRITER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
architecture RTL of IMAGE_WINDOW_BUFFER_WRITER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   RAM_DATA_TYPE         is std_logic_vector(BUF_DATA_BITS-1 downto 0);
    type      RAM_DATA_VECTOR       is array(integer range <>) of RAM_DATA_TYPE;
    subtype   RAM_ADDR_TYPE         is std_logic_vector(BUF_ADDR_BITS-1 downto 0);
    type      RAM_ADDR_VECTOR       is array(integer range <>) of RAM_ADDR_TYPE;
    constant  RAM_WENA_BITS         :  integer := 1;
    subtype   RAM_WENA_TYPE         is std_logic_vector(RAM_WENA_BITS-1 downto 0);
    type      RAM_WENA_VECTOR       is array(integer range <>) of RAM_WENA_TYPE;
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
    function  NEXT_RAM_ADDR_VECTOR(
                  RAM_ADDR          :  RAM_ADDR_VECTOR;
                  BANK_SELECT       :  BANK_SELECT_VECTOR;
                  BASE_ADDR         :  integer;
                  CHANNEL_OFFSET    :  integer;
                  START_CHANNEL     :  std_logic
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
        else
            for bank in 0 to BANK_SIZE-1 loop
                next_addr_vector(bank) := std_logic_vector(unsigned(RAM_ADDR(bank)) + 1);
            end loop;
        end if;
        return next_addr_vector;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  CALC_ATRB_VALID_COUNT(
                  PARAM      :  IMAGE_WINDOW_PARAM_TYPE;
                  ATRB_VEC   :  IMAGE_ATRB_VECTOR)
                  return        integer
    is
        alias     i_atrb_vec :  IMAGE_ATRB_VECTOR(0 to ATRB_VEC'length-1) is ATRB_VEC;
        variable  count      :  integer range 0 to PARAM.SHAPE.X.SIZE;
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
    signal    base_addr             :  integer range 0 to 2**BUF_ADDR_BITS-1;
    signal    channel_offset        :  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      LINE_STATE_TYPE       is (LINE_IDLE_STATE  ,
                                        LINE_INTAKE_STATE,
                                        LINE_OUTLET_STATE);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_x_count        :  integer range 0 to ELEMENT_SIZE;
    signal    intake_channel_count  :  integer range 0 to ELEMENT_SIZE;
    signal    intake_last_atrb_c    :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI);
begin
    -------------------------------------------------------------------------------
    -- bank_select :
    -- base_addr   :
    -------------------------------------------------------------------------------
    process(CLK, RST)
        constant LINE_ALL_0 :  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    begin 
        if (RST = '1') then
                bank_select <= INIT_BANK_SELECT(I_PARAM.SHAPE.X.LO, I_PARAM.SHAPE.X.HI);
                base_addr   <= 0;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or I_LINE_IDLE = '1') then
                bank_select <= INIT_BANK_SELECT(I_PARAM.SHAPE.X.LO, I_PARAM.SHAPE.X.HI);
                base_addr   <= 0;
            else
                if (I_VALID = '1' and I_LAST_C = '1') then
                    if (IS_LAST_BANK(bank_select, I_PARAM.STRIDE.X) = TRUE) then
                        base_addr <= base_addr + channel_offset;
                    end if;
                    bank_select <= STRIDE_BANK_SELECT(bank_select, I_PARAM.STRIDE.X);
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- CHANNEL_SIZE が可変長の場合
    -------------------------------------------------------------------------------
    -- channel_offset : 
    -- O_C_OFFSET     : 
    -- O_C_SIZE       : 
    -------------------------------------------------------------------------------
    CHANNEL_SIZE_EQ_0: if (CHANNEL_SIZE = 0) generate
        signal    curr_channel_offset :  integer range 0 to 2**BUF_ADDR_BITS;
        signal    curr_channel_count  :  integer range 0 to ELEMENT_SIZE;
    begin
        channel_offset <= 1                       when (I_START_X = '1' and I_START_C = '1') else
                          curr_channel_offset + 1 when (I_START_X = '1' and I_START_C = '0') else
                          curr_channel_offset;
        process (CLK, RST)
            variable  atrb_c_vector  :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI);
        begin
            if (RST = '1') then
                    curr_channel_offset <= 0;
                    curr_channel_count  <= 0;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or I_CLEAR = '1') then
                    curr_channel_offset <= 0;
                    curr_channel_count  <= 0;
                elsif (I_VALID = '1' and I_START_Y = '1' and I_START_X = '1') then
                    curr_channel_offset <= channel_offset;
                    atrb_c_vector       := GET_ATRB_C_VECTOR_FROM_IMAGE_WINDOW_DATA(I_PARAM, I_DATA);
                    curr_channel_count  <= curr_channel_count + CALC_ATRB_VALID_COUNT(I_PARAM, atrb_c_vector);
                end if;
            end if;
        end process;
        O_C_OFFSET <= curr_channel_offset;
        O_C_SIZE   <= curr_channel_count;
    end generate;
    -------------------------------------------------------------------------------
    -- CHANNEL_SIZE が固定値の場合
    -------------------------------------------------------------------------------
    -- channel_offset :
    -- O_C_SIZE       : 
    -------------------------------------------------------------------------------
    CHANNEL_SIZE_GT_0: if (CHANNEL_SIZE > 0) generate
    begin
        channel_offset <= (CHANNEL_SIZE + I_PARAM.SHAPE.C.SIZE - 1) / I_PARAM.SHAPE.C.SIZE;
        O_C_OFFSET     <= (CHANNEL_SIZE + I_PARAM.SHAPE.C.SIZE - 1) / I_PARAM.SHAPE.C.SIZE;
        O_C_SIZE       <=  CHANNEL_SIZE;
    end generate;
    -------------------------------------------------------------------------------
    -- intake_x_count :
    -- O_X_SIZE       : 
    -------------------------------------------------------------------------------
    process(CLK, RST)
        variable  atrb_x_vector  :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI);
    begin 
        if (RST = '1') then
                intake_x_count <= 0;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or I_CLEAR = '1') then
                intake_x_count <= 0;
            elsif (I_VALID = '1' and I_START_Y = '1' and I_LAST_C = '1') then
                atrb_x_vector  := GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(I_PARAM, I_DATA);
                intake_x_count <= intake_x_count + CALC_ATRB_VALID_COUNT(I_PARAM, atrb_x_vector);
            end if;
        end if;
    end process;
    O_X_SIZE <= intake_x_count;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    L: for LINE in 0 to LINE_SIZE-1 generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    bank_data_array   :  RAM_DATA_VECTOR(0 to BANK_SIZE-1);
        signal    bank_addr_array   :  RAM_ADDR_VECTOR(0 to BANK_SIZE-1);
        signal    bank_wena_array   :  RAM_WENA_VECTOR(0 to BANK_SIZE-1);
        signal    line_state        :  LINE_STATE_TYPE;
        signal    line_atrb         :  IMAGE_ATRB_TYPE;
    begin
        ---------------------------------------------------------------------------
        -- line_state :
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    line_state <= LINE_IDLE_STATE;
                    line_atrb  <= (VALID => FALSE, START => FALSE, LAST => FALSE);
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    line_state <= LINE_IDLE_STATE;
                    line_atrb  <= (VALID => FALSE, START => FALSE, LAST => FALSE);
                else
                    case line_state is
                        when LINE_IDLE_STATE =>
                            if (I_LINE_START(LINE) = '1') then
                                line_state <= LINE_INTAKE_STATE;
                                line_atrb  <= GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(I_PARAM, LINE+I_PARAM.SHAPE.Y.LO, I_DATA);
                            else
                                line_state <= LINE_IDLE_STATE;
                            end if;
                        when LINE_INTAKE_STATE =>
                            if (I_VALID = '1' and I_LAST_X  = '1' and I_LAST_C  = '1') then
                                line_state <= LINE_OUTLET_STATE;
                            else
                                line_state <= LINE_INTAKE_STATE;
                            end if;
                        when LINE_OUTLET_STATE =>
                            if    (O_LINE_RETURN(LINE) = '1') then
                                line_state <= LINE_OUTLET_STATE;
                            elsif (O_LINE_FEED(LINE)   = '1') then
                                line_state <= LINE_IDLE_STATE;
                            else
                                line_state <= LINE_OUTLET_STATE;
                            end if;
                        when others     =>
                            line_state <= LINE_IDLE_STATE;
                    end case;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- I_LINE_READY(LINE) :
        ---------------------------------------------------------------------------
        I_LINE_READY(LINE) <= '1' when (line_state = LINE_IDLE_STATE) else '0';
        ---------------------------------------------------------------------------
        -- O_LINE_VALID (LINE) :
        -- O_lINE_ATRB(LINE) :
        ---------------------------------------------------------------------------
        O_LINE_VALID(LINE) <= '1' when (line_state = LINE_OUTLET_STATE) else '0';
        O_lINE_ATRB(LINE)  <= line_atrb;
        ---------------------------------------------------------------------------
        -- bank_wena_array :
        ---------------------------------------------------------------------------
        process(CLK, RST)
            variable  atrb_x_vec  :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI);
            variable  bank_we     :  std_logic;
        begin 
            if (RST = '1') then
                    bank_wena_array <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    bank_wena_array <= (others => (others => '0'));
                elsif (I_VALID = '1' and line_state = LINE_INTAKE_STATE) then
                    atrb_x_vec := GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(I_PARAM, I_DATA);
                    for bank in 0 to BANK_SIZE-1 loop
                        bank_we := '0';
                        for x_pos in bank_select'range loop
                            if (bank_select(x_pos)(bank) = '1' and atrb_x_vec(x_pos).VALID = TRUE) then
                                bank_we := bank_we or '1';
                            end if;
                        end loop;
                        if (bank_we = '1') then
                            bank_wena_array(bank) <= (others => '1');
                        else
                            bank_wena_array(bank) <= (others => '0');
                        end if;
                    end loop;
                else
                    bank_wena_array <= (others => (others => '0'));
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- bank_addr_array :
        ---------------------------------------------------------------------------
        process(CLK, RST)
        begin
            if (RST = '1') then
                    bank_addr_array <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or line_state = LINE_IDLE_STATE) then
                    bank_addr_array <= (others => (others => '0'));
                elsif (I_VALID = '1' and line_state = LINE_INTAKE_STATE) then
                    bank_addr_array <= NEXT_RAM_ADDR_VECTOR(
                                           RAM_ADDR       => bank_addr_array,
                                           BANK_SELECT    => bank_select    ,
                                           BASE_ADDR      => base_addr      ,
                                           CHANNEL_OFFSET => channel_offset ,
                                           START_CHANNEL  => I_START_C
                                      );
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- bank_data_array : 
        ---------------------------------------------------------------------------
        process(CLK, RST)
            constant  TEMP_PARAM :  IMAGE_WINDOW_PARAM_TYPE
                                 := NEW_IMAGE_WINDOW_PARAM(
                                        ELEM_BITS => I_PARAM.ELEM_BITS,
                                        C         => I_PARAM.SHAPE.C,
                                        X         => NEW_IMAGE_VECTOR_RANGE(1),
                                        Y         => NEW_IMAGE_VECTOR_RANGE(1)
                                    );
            variable  temp_data  :  std_logic_vector(TEMP_PARAM.DATA.SIZE-1 downto 0);
            variable  elem_data  :  std_logic_vector(TEMP_PARAM.ELEM_BITS-1 downto 0);
            variable  bank_data  :  std_logic_vector(BUF_DATA_BITS       -1 downto 0);
        begin 
            if (RST = '1') then
                    bank_data_array <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    bank_data_array <= (others => (others => '0'));
                else
                    for bank in 0 to BANK_SIZE-1 loop
                        bank_data := (others => '0');
                        temp_data := (others => '0');
                        for x_pos in I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI loop
                            if (bank_select(x_pos)(bank) = '1') then
                                for c_pos in I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI loop
                                    elem_data := GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                                     PARAM   => I_PARAM,
                                                     C       => c_pos,
                                                     X       => x_pos,
                                                     Y       => LINE+I_PARAM.SHAPE.Y.LO,
                                                     DATA    => I_DATA
                                                 );
                                    SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                                                     PARAM   => TEMP_PARAM,
                                                     C       => c_pos,
                                                     X       => 0,
                                                     Y       => 0,
                                                     ELEMENT => elem_data,
                                                     DATA    => temp_data
                                    );
                                end loop;
                                bank_data := bank_data or temp_data(TEMP_PARAM.DATA.ELEM_FIELD.HI downto TEMP_PARAM.DATA.ELEM_FIELD.LO);
                            end if;
                        end loop;
                        bank_data_array(bank) <= bank_data;
                    end loop;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- BUF_WE :
        ---------------------------------------------------------------------------
        process (bank_wena_array) begin
            for bank in 0 to BANK_SIZE-1 loop
                BUF_WE  ((LINE*BANK_SIZE+bank+1)*RAM_WENA_BITS-1 downto (LINE*BANK_SIZE+bank)*RAM_WENA_BITS) <= bank_wena_array(bank);
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- BUF_ADDR :
        ---------------------------------------------------------------------------
        process (bank_addr_array) begin
            for bank in 0 to BANK_SIZE-1 loop
                BUF_ADDR((LINE*BANK_SIZE+bank+1)*BUF_ADDR_BITS-1 downto (LINE*BANK_SIZE+bank)*BUF_ADDR_BITS) <= bank_addr_array(bank);
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- BUF_DATA :
        ---------------------------------------------------------------------------
        process (bank_data_array) begin
            for bank in 0 to BANK_SIZE-1 loop
                BUF_DATA((LINE*BANK_SIZE+bank+1)*BUF_DATA_BITS-1 downto (LINE*BANK_SIZE+bank)*BUF_DATA_BITS) <= bank_data_array(bank);
            end loop;
        end process;
    end generate;
end RTL;
