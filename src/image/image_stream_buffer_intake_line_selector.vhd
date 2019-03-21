-----------------------------------------------------------------------------------
--!     @file    image_stream_buffer_intake_line_selector.vhd
--!     @brief   Image Stream Buffer Intake Line Selector Module :
--!              異なる形のイメージストリームを継ぐためのバッファの入力側ライン選択
--!              モジュール
--!     @version 1.8.0
--!     @date    2019/3/21
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
--! @brief   Image Stream Buffer Intake Line Selector Module :
--!          異なる形のイメージストリームを継ぐためのバッファの入力側ライン選択
--!          モジュール
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_BUFFER_INTAKE_LINE_SELECTOR is
    generic (
        I_PARAM         : --! @brief INPUT  STREAM PARAMETER :
                          --! 入力側のストリームのパラメータを指定する.
                          --! * I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          --! * I_PARAM.INFO_BITS    = 0                    でなければならない.
                          --! * I_PARAM.SHAPE.C.SIZE = O_PARAM.SHAPE.C.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.D.SIZE = O_PARAM.SHAPE.D.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.X.SIZE = O_PARAM.SHAPE.X.SIZE でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          --! * O_PARAM.ELEM_SIZE    = I_PARAM.ELEM_SIZE    でなければならない.
                          --! * O_PARAM.INFO_BITS    = 0                    でなければならない.
                          --! * O_PARAM.SHAPE.C.SIZE = I_PARAM.SHAPE.C.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.D.SIZE = I_PARAM.SHAPE.D.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.X.SIZE = I_PARAM.SHAPE.X.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
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
        I_DATA          : --! @brief INPUT STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 Stream I/F
    -------------------------------------------------------------------------------
        O_ENABLE        : --! @brief OUTPUT ENABLE :
                          --! 出力許可信号.
                          out std_logic;
        O_LINE_START    : --! @brief OUTPUT LINE VALID :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        O_LINE_DONE     : --! @brief OUTPUT LINE DONE :
                          --! ライン有効信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        O_DATA          : --! @brief OUTPUT IMAGE STREAM DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT IMAGE STREAM DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE STREAM DATA READY :
                          --! 出力ストリームデータレディ信号.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- ライン制御 I/F
    -------------------------------------------------------------------------------
        LINE_VALID      : --! @brief OUTPUT LINE VALID :
                          --! ライン出力有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        LINE_ATRB       : --! @brief OUTPUT LINE ATTRIBUTE :
                          --! ライン属性出力.
                          out IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        LINE_FEED       : --! @brief OUTPUT LINE FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        LINE_RETURN     : --! @brief OUTPUT LINE RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0')
    );
end IMAGE_STREAM_BUFFER_INTAKE_LINE_SELECTOR;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER;
architecture RTL of IMAGE_STREAM_BUFFER_INTAKE_LINE_SELECTOR is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   LINE_SELECT_TYPE      is std_logic_vector(0 to LINE_SIZE-1);
    type      LINE_SELECT_VECTOR    is array(integer range <>) of LINE_SELECT_TYPE;
    signal    line_select           :  LINE_SELECT_VECTOR(I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI);
    constant  LINE_ALL_1            :  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
    constant  LINE_ALL_0            :  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  INIT_LINE_SELECT(LO,HI: integer) return LINE_SELECT_VECTOR is
        variable i_vec :  LINE_SELECT_VECTOR(LO to HI);
    begin
        for i in i_vec'range loop
            for line in 0 to LINE_SIZE-1 loop
                if (i-LO = line) then
                    i_vec(i)(line) := '1';
                else
                    i_vec(i)(line) := '0';
                end if;
            end loop;
        end loop;
        return i_vec;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  STRIDE_LINE_SELECT(I_VEC: LINE_SELECT_VECTOR; STRIDE: integer) return LINE_SELECT_VECTOR is
        variable o_vec :  LINE_SELECT_VECTOR(I_VEC'range);
    begin
        for i in o_vec'range loop
            for line in 0 to LINE_SIZE-1 loop
                o_vec(i)(line) := I_VEC(i)((LINE_SIZE+line-STRIDE) mod LINE_SIZE);
            end loop;
        end loop;
        return o_vec;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE            is (IDLE_STATE  ,
                                        WAIT_STATE  ,
                                        INTAKE_STATE,
                                        FLUSH_STATE);
    signal    curr_state            :  STATE_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_c_start        :  std_logic;
    signal    intake_c_last         :  std_logic;
    signal    intake_x_start        :  std_logic;
    signal    intake_x_last         :  std_logic;
    signal    intake_y_start        :  std_logic;
    signal    intake_y_last         :  std_logic;
    signal    intake_valid          :  std_logic;
    signal    intake_ready          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    line_start            :  std_logic_vector        (LINE_SIZE-1 downto 0);
    signal    line_ready            :  std_logic_vector        (LINE_SIZE-1 downto 0);
    signal    line_intake_valid     :  std_logic_vector        (LINE_SIZE-1 downto 0);
    signal    line_intake_atrb      :  IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    outlet_data           :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    signal    outlet_valid          :  std_logic;
    signal    outlet_ready          :  std_logic;
    signal    outlet_busy           :  std_logic;
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
    process (I_DATA) begin
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
        if (IMAGE_STREAM_DATA_IS_START_Y(PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_y_start <= '1';
        else
            intake_y_start <= '0';
        end if;
        if (IMAGE_STREAM_DATA_IS_LAST_Y( PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_y_last  <= '1';
        else
            intake_y_last  <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- curr_state  :
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_state <= IDLE_STATE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_state <= IDLE_STATE;
            else
                case curr_state is
                    when IDLE_STATE =>
                            curr_state <= WAIT_STATE;
                    when WAIT_STATE =>
                        if (line_start /= LINE_ALL_0) then
                            curr_state <= INTAKE_STATE;
                        else
                            curr_state <= WAIT_STATE;
                        end if;
                    when INTAKE_STATE =>
                        if (intake_valid = '1' and intake_ready = '1' and intake_x_last  = '1' and intake_c_last  = '1') then
                            if (intake_y_last = '1') then
                                curr_state <= FLUSH_STATE;
                            else
                                curr_state <= WAIT_STATE;
                            end if;
                        else
                                curr_state <= INTAKE_STATE;
                        end if;
                    when FLUSH_STATE =>
                        if (line_ready = LINE_ALL_1 and outlet_busy = '0') then
                            curr_state <= IDLE_STATE;
                        else
                            curr_state <= FLUSH_STATE;
                        end if;
                    when others     =>
                            curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- intake_valid :
    -- intake_ready :
    -- I_READY      :
    -------------------------------------------------------------------------------
    intake_valid <= '1' when (I_VALID = '1') else '0';
    intake_ready <= '1' when (curr_state = INTAKE_STATE and outlet_ready = '1') else '0';
    I_READY      <= '1' when (curr_state = INTAKE_STATE and outlet_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- line_intake_valid :
    -------------------------------------------------------------------------------
    process (I_DATA, line_select)
        variable  atrb_y_vector  :  IMAGE_STREAM_ATRB_VECTOR(I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI);
        variable  line_in_valid  :  std_logic_vector(LINE_SIZE-1 downto 0);
    begin
        atrb_y_vector := GET_ATRB_Y_VECTOR_FROM_IMAGE_STREAM_DATA(I_PARAM, I_DATA);
        line_in_valid := (others => '0');
        for line in 0 to LINE_SIZE-1 loop
            for y_pos in I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI loop
                if line_select(y_pos)(line) = '1' and atrb_y_vector(y_pos).VALID then
                    line_in_valid(line) := line_in_valid(line) or '1';
                end if;
            end loop;
        end loop;
        line_intake_valid <= line_in_valid;
    end process;
    -------------------------------------------------------------------------------
    -- line_start :
    -------------------------------------------------------------------------------
    process (curr_state, intake_valid, line_intake_valid, line_ready)
        variable line_intake_pause :  std_logic_vector(LINE_SIZE-1 downto 0);
        variable line_intake_start :  std_logic_vector(LINE_SIZE-1 downto 0);
    begin
        for line in 0 to LINE_SIZE-1 loop
            if    (line_intake_valid(line) = '1' and line_ready(line) = '1') then
                line_intake_pause(line) := '0';
                line_intake_start(line) := '1';
            elsif (line_intake_valid(line) = '1' and line_ready(line) = '0') then
                line_intake_pause(line) := '1';
                line_intake_start(line) := '0';
            else
                line_intake_pause(line) := '0';
                line_intake_start(line) := '0';
            end if;
        end loop;
        if (curr_state = WAIT_STATE and intake_valid = '1' and line_intake_pause = LINE_ALL_0) then
            line_start <= line_intake_start;
        else
            line_start <= (others => '0');
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- line_select  :
    -------------------------------------------------------------------------------
    process(CLK, RST) begin 
        if (RST = '1') then
                line_select <= INIT_LINE_SELECT(I_PARAM.SHAPE.Y.LO, I_PARAM.SHAPE.Y.HI);
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or curr_state = IDLE_STATE) then
                line_select <= INIT_LINE_SELECT(I_PARAM.SHAPE.Y.LO, I_PARAM.SHAPE.Y.HI);
            else
                if (intake_valid = '1' and intake_ready = '1' and intake_x_last = '1' and intake_c_last = '1') then
                    line_select <= STRIDE_LINE_SELECT(line_select, I_PARAM.STRIDE.Y);
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    L: for line in 0 to LINE_SIZE-1 generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        type      LINE_STATE_TYPE   is (LINE_IDLE_STATE   ,
                                        LINE_INTAKE_STATE ,
                                        LINE_OUTLET_STATE );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    line_state        :  LINE_STATE_TYPE;
        signal    atrb              :  IMAGE_STREAM_ATRB_TYPE;
    begin
        ---------------------------------------------------------------------------
        -- line_state :
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    line_state <= LINE_IDLE_STATE;
                    atrb       <= (VALID => FALSE, START => FALSE, LAST => FALSE);
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    line_state <= LINE_IDLE_STATE;
                    atrb       <= (VALID => FALSE, START => FALSE, LAST => FALSE);
                else
                    case line_state is
                        when LINE_IDLE_STATE =>
                            if (line_start(line) = '1') then
                                line_state <= LINE_INTAKE_STATE;
                                atrb       <= line_intake_atrb(line);
                            else
                                line_state <= LINE_IDLE_STATE;
                            end if;
                        when LINE_INTAKE_STATE =>
                            if (O_LINE_DONE(line) = '1') then
                                line_state <= LINE_OUTLET_STATE;
                            else
                                line_state <= LINE_INTAKE_STATE;
                            end if;
                        when LINE_OUTLET_STATE =>
                            if    (LINE_RETURN(LINE) = '1') then
                                line_state <= LINE_OUTLET_STATE;
                            elsif (LINE_FEED(LINE)   = '1') then
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
        -- line_ready(line) :
        ---------------------------------------------------------------------------
        line_ready(line) <= '1' when (line_state = LINE_IDLE_STATE) else '0';
        ---------------------------------------------------------------------------
        -- LINE_VALID(line) :
        -- LINE_ATRB (line) :
        ---------------------------------------------------------------------------
        LINE_VALID(line) <= '1' when (line_state = LINE_OUTLET_STATE) else '0';
        LINE_ATRB (line) <= atrb;
    end generate;
    -------------------------------------------------------------------------------
    -- outlet_valid     :
    -------------------------------------------------------------------------------
    outlet_valid <= '1' when (curr_state = INTAKE_STATE and intake_valid = '1') else '0';
    -------------------------------------------------------------------------------
    -- outlet_data      :
    -- line_intake_atrb : 
    -------------------------------------------------------------------------------
    process (I_DATA, line_select)
        variable  data   :  std_logic_vector(O_PARAM.DATA.SIZE     -1 downto 0);
        variable  elem   :  std_logic_vector(O_PARAM.ELEM_BITS     -1 downto 0);
        variable  i_atrb :  std_logic_vector(IMAGE_STREAM_ATRB_BITS-1 downto 0);
        variable  y_atrb :  std_logic_vector(IMAGE_STREAM_ATRB_BITS-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (O_PARAM.DATA.ATRB_FIELD.C.SIZE > 0) then
            data(O_PARAM.DATA.ATRB_FIELD.C.HI downto O_PARAM.DATA.ATRB_FIELD.C.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.C.HI downto I_PARAM.DATA.ATRB_FIELD.C.LO);
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (O_PARAM.DATA.ATRB_FIELD.X.SIZE > 0) then
            data(O_PARAM.DATA.ATRB_FIELD.X.HI downto O_PARAM.DATA.ATRB_FIELD.X.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.X.HI downto I_PARAM.DATA.ATRB_FIELD.X.LO);
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for line in 0 to LINE_SIZE-1 loop
            if (LINE_SIZE > 1) then
                y_atrb := (others => '0');
                for y_pos in I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI loop
                    if (line_select(y_pos)(line) = '1') then
                        i_atrb := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(I_PARAM, y_pos, I_DATA);
                        y_atrb := y_atrb or i_atrb;
                    end if;
                end loop;
            else
                y_atrb := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(I_PARAM, line+I_PARAM.SHAPE.Y.LO, I_DATA);
            end if;
            SET_ATRB_Y_TO_IMAGE_STREAM_DATA(O_PARAM, line+O_PARAM.SHAPE.Y.LO, y_atrb, data);
            line_intake_atrb(line).VALID <= (y_atrb(IMAGE_STREAM_ATRB_VALID_POS) = '1');
            line_intake_atrb(line).START <= (y_atrb(IMAGE_STREAM_ATRB_START_POS) = '1');
            line_intake_atrb(line).LAST  <= (y_atrb(IMAGE_STREAM_ATRB_LAST_POS ) = '1');
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for c_pos in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
            for x_pos in 0 to O_PARAM.SHAPE.X.SIZE-1 loop
                for line  in 0 to LINE_SIZE-1 loop
                    if (LINE_SIZE > 1) then
                        elem := (others => '0');
                        for y_pos in I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI loop
                            if (line_select(y_pos)(line) = '1') then
                                elem := elem or GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                                                    PARAM   => I_PARAM ,
                                                    C       => c_pos+I_PARAM.SHAPE.C.LO,
                                                    D       =>       I_PARAM.SHAPE.D.LO,
                                                    X       => x_pos+I_PARAM.SHAPE.X.LO,
                                                    Y       => y_pos,
                                                    DATA    => I_DATA
                                                );
                            end if;
                        end loop;
                    else
                        elem := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                                                    PARAM   => I_PARAM ,
                                                    C       => c_pos+I_PARAM.SHAPE.C.LO,
                                                    D       =>       I_PARAM.SHAPE.D.LO,
                                                    X       => x_pos+I_PARAM.SHAPE.X.LO,
                                                    Y       => line +I_PARAM.SHAPE.Y.LO,
                                                    DATA    => I_DATA
                                                );
                    end if;
                    SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                        PARAM   => O_PARAM ,
                        C       => c_pos+O_PARAM.SHAPE.C.LO,
                        D       =>       O_PARAM.SHAPE.D.LO,
                        X       => x_pos+O_PARAM.SHAPE.X.LO,
                        Y       => line +O_PARAM.SHAPE.Y.LO,
                        ELEMENT => elem    ,
                        DATA    => data
                    );
                end loop;
            end loop;
        end loop;
        outlet_data <= data;
    end process;
    -------------------------------------------------------------------------------
    -- O_DATA       :
    -- O_VALID      :
    -- outlet_ready :
    -- outlet_busy  :
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
    -------------------------------------------------------------------------------
    -- O_LINE_START :
    -------------------------------------------------------------------------------
    QUEUE_SIZE_GT_0: if (QUEUE_SIZE > 0) generate
        process (CLK, RST) begin
            if (RST = '1') then
                    O_LINE_START <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    O_LINE_START <= (others => '0');
                else
                    O_LINE_START <= line_start;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- O_LINE_START : 
    -------------------------------------------------------------------------------
    QUEUE_SIZE_EQ_0: if (QUEUE_SIZE = 0) generate
        O_LINE_START <= line_start;
    end generate;
    -------------------------------------------------------------------------------
    -- O_ENABLE     : 
    -------------------------------------------------------------------------------
    O_ENABLE <= '1' when (curr_state /= IDLE_STATE) else '0';
end RTL;
