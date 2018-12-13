-----------------------------------------------------------------------------------
--!     @file    image_window_buffer_intake.vhd
--!     @brief   Image Window Buffer Intake MODULE :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2018/12/13
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
entity  IMAGE_WINDOW_BUFFER_INTAKE is
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE でなければならない.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE でなければならない.
                          --! O_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
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
        I_DATA          : --! @brief INPUT WINDOW DATA :
                          --! ウィンドウデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT WINDOW DATA VALID :
                          --! 入力ウィンドウデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でウィンドウデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT WINDOW DATA READY :
                          --! 入力ウィンドウデータレディ信号.
                          --! * キューが次のウィンドウデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でウィンドウデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_VALID         : --! @brief OUTPUT VALID :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        O_C_SIZE        : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_X_SIZE        : --! @brief OUTPUT X SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_Y_ATRB        : --! @brief OUTPUT ATTRIBUTE Y :
                          out IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        O_FEED          : --! @brief OUTPUT FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        O_RETURN        : --! @brief OUTPUT RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER WRITE DATA :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
        BUF_WE          : --! @brief BUFFER WRITE ENABLE :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE              -1 downto 0)
    );
end IMAGE_WINDOW_BUFFER_INTAKE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_WRITER;
architecture RTL of IMAGE_WINDOW_BUFFER_INTAKE is
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
    constant  INTAKE_PARAM          :  IMAGE_WINDOW_PARAM_TYPE
                                    := NEW_IMAGE_WINDOW_PARAM(
                                           ELEM_BITS    => I_PARAM.ELEM_BITS,
                                           SHAPE        => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                               C => I_PARAM.SHAPE.C,
                                                               X => I_PARAM.SHAPE.X,
                                                               Y => NEW_IMAGE_VECTOR_RANGE(LINE_SIZE)
                                                           ),
                                           STRIDE       => I_PARAM.STRIDE,
                                           BORDER_TYPE  => I_PARAM.BORDER_TYPE
                                       );
    signal    intake_data           :  std_logic_vector(INTAKE_PARAM.DATA.SIZE-1 downto 0);
    signal    intake_start_c        :  std_logic;
    signal    intake_last_c         :  std_logic;
    signal    intake_start_x        :  std_logic;
    signal    intake_last_x         :  std_logic;
    signal    intake_start_y        :  std_logic;
    signal    intake_last_y         :  std_logic;
    signal    intake_valid          :  std_logic;
    signal    intake_ready          :  std_logic;
    signal    intake_clear          :  std_logic;
    signal    intake_line_idle      :  std_logic;
    signal    intake_line_start     :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    intake_line_ready     :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    intake_line_valid     :  std_logic_vector(LINE_SIZE-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 入力データの各種属性
    -------------------------------------------------------------------------------
    -- intake_start_c    : 
    -- intake_last_c     : 
    -- intake_start_x    : 
    -- intake_last_x     : 
    -------------------------------------------------------------------------------
    process (I_DATA) 
        variable atrb_y  :  IMAGE_ATRB_TYPE;
    begin
        if (IMAGE_WINDOW_DATA_IS_START_C(PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_start_c <= '1';
        else
            intake_start_c <= '0';
        end if;
        if (IMAGE_WINDOW_DATA_IS_LAST_C( PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_last_c  <= '1';
        else
            intake_last_c  <= '0';
        end if;
        if (IMAGE_WINDOW_DATA_IS_START_X(PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_start_x <= '1';
        else
            intake_start_x <= '0';
        end if;
        if (IMAGE_WINDOW_DATA_IS_LAST_X( PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_last_x  <= '1';
        else
            intake_last_x  <= '0';
        end if;
        if (IMAGE_WINDOW_DATA_IS_START_Y(PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_start_y <= '1';
        else
            intake_start_y <= '0';
        end if;
        if (IMAGE_WINDOW_DATA_IS_LAST_Y( PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
            intake_last_y  <= '1';
        else
            intake_last_y  <= '0';
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
                        if (intake_line_start /= LINE_ALL_0) then
                            curr_state <= INTAKE_STATE;
                        else
                            curr_state <= WAIT_STATE;
                        end if;
                    when INTAKE_STATE =>
                        if (I_VALID = '1' and intake_ready = '1' and intake_last_x  = '1' and intake_last_c  = '1') then
                            if (intake_last_y = '1') then
                                curr_state <= FLUSH_STATE;
                            else
                                curr_state <= WAIT_STATE;
                            end if;
                        else
                                curr_state <= INTAKE_STATE;
                        end if;
                    when FLUSH_STATE =>
                        if (intake_line_ready = LINE_ALL_1) then
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
    --
    -------------------------------------------------------------------------------
    intake_ready <= '1' when (curr_state = INTAKE_STATE) else '0';
    I_READY      <= '1' when (curr_state = INTAKE_STATE) else '0';
    -------------------------------------------------------------------------------
    -- intake_line_valid :
    -------------------------------------------------------------------------------
    process (I_DATA, line_select)
        variable  atrb_y_vector  :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI);
        variable  line_valid     :  std_logic_vector(LINE_SIZE-1 downto 0);
    begin
        atrb_y_vector := GET_ATRB_Y_VECTOR_FROM_IMAGE_WINDOW_DATA(I_PARAM, I_DATA);
        line_valid    := (others => '0');
        for line in 0 to LINE_SIZE-1 loop
            for y_pos in I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI loop
                if line_select(y_pos)(line) = '1' and atrb_y_vector(y_pos).VALID then
                    line_valid(line) := line_valid(line) or '1';
                end if;
            end loop;
        end loop;
        intake_line_valid <= line_valid;
    end process;
    -------------------------------------------------------------------------------
    -- intake_line_start :
    -------------------------------------------------------------------------------
    process (curr_state, I_VALID, intake_line_valid, intake_line_ready)
        variable line_pause :  std_logic_vector(LINE_SIZE-1 downto 0);
        variable line_start :  std_logic_vector(LINE_SIZE-1 downto 0);
    begin
        for line in 0 to LINE_SIZE-1 loop
            if    (intake_line_valid(line) = '1' and intake_line_ready(line) = '1') then
                line_pause(line) := '0';
                line_start(line) := '1';
            elsif (intake_line_valid(line) = '1' and intake_line_ready(line) = '0') then
                line_pause(line) := '1';
                line_start(line) := '0';
            else
                line_pause(line) := '0';
                line_start(line) := '0';
            end if;
        end loop;
        if (curr_state = WAIT_STATE and I_VALID = '1' and line_pause = LINE_ALL_0) then
            intake_line_start <= line_start;
        else
            intake_line_start <= (others => '0');
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
                if (I_VALID = '1' and intake_ready = '1' and intake_last_x = '1' and intake_last_c = '1') then
                    line_select <= STRIDE_LINE_SELECT(line_select, I_PARAM.STRIDE.Y);
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- intake_clear     :
    -------------------------------------------------------------------------------
    intake_clear     <= '1' when (curr_state = IDLE_STATE) else '0';
    -------------------------------------------------------------------------------
    -- intake_line_idle :
    -------------------------------------------------------------------------------
    intake_line_idle <= '1' when (curr_state = WAIT_STATE) else '0';
    -------------------------------------------------------------------------------
    -- intake_valid     :
    -------------------------------------------------------------------------------
    intake_valid     <= '1' when (curr_state = INTAKE_STATE and I_VALID = '1') else '0';
    -------------------------------------------------------------------------------
    -- intake_data  :
    -------------------------------------------------------------------------------
    process (I_DATA, line_select)
        variable  data   :  std_logic_vector(INTAKE_PARAM.DATA.SIZE-1 downto 0);
        variable  elem   :  std_logic_vector(INTAKE_PARAM.ELEM_BITS-1 downto 0);
        variable  atrb_x :  std_logic_vector(IMAGE_ATRB_BITS       -1 downto 0);
        variable  atrb_y :  std_logic_vector(IMAGE_ATRB_BITS       -1 downto 0);
        variable  atrb_c :  std_logic_vector(IMAGE_ATRB_BITS       -1 downto 0);
        variable  i_atrb :  std_logic_vector(IMAGE_ATRB_BITS       -1 downto 0);
    begin
        for c_pos in 0 to INTAKE_PARAM.SHAPE.C.SIZE-1 loop
            atrb_c := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(I_PARAM, c_pos+I_PARAM.SHAPE.C.LO, I_DATA);
            SET_ATRB_C_TO_IMAGE_WINDOW_DATA(INTAKE_PARAM, c_pos+INTAKE_PARAM.SHAPE.C.LO, atrb_c, data);
        end loop;
        for x_pos in 0 to INTAKE_PARAM.SHAPE.X.SIZE-1 loop
            atrb_x := GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(I_PARAM, x_pos+I_PARAM.SHAPE.X.LO, I_DATA);
            SET_ATRB_X_TO_IMAGE_WINDOW_DATA(INTAKE_PARAM, x_pos+INTAKE_PARAM.SHAPE.X.LO, atrb_x, data);
        end loop;
        for line in 0 to LINE_SIZE-1 loop
            if (LINE_SIZE > 1) then
                atrb_y := (others => '0');
                for y_pos in I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI loop
                    if (line_select(y_pos)(line) = '1') then
                        i_atrb := GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(I_PARAM, y_pos, I_DATA);
                        atrb_y := atrb_y or i_atrb;
                    end if;
                end loop;
            else
                atrb_y := GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(I_PARAM, line+I_PARAM.SHAPE.Y.LO, I_DATA);
            end if;
            SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(INTAKE_PARAM, line+INTAKE_PARAM.SHAPE.Y.LO, atrb_y, data);
        end loop;
        for c_pos in 0 to INTAKE_PARAM.SHAPE.C.SIZE-1 loop
            for x_pos in 0 to INTAKE_PARAM.SHAPE.X.SIZE-1 loop
                for line  in 0 to LINE_SIZE-1 loop
                    if (LINE_SIZE > 1) then
                        elem := (others => '0');
                        for y_pos in I_PARAM.SHAPE.Y.LO to I_PARAM.SHAPE.Y.HI loop
                            if (line_select(y_pos)(line) = '1') then
                                elem := elem or GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                                    PARAM   => I_PARAM ,
                                                    C       => c_pos+I_PARAM.SHAPE.C.LO,
                                                    X       => x_pos+I_PARAM.SHAPE.X.LO,
                                                    Y       => y_pos,
                                                    DATA    => I_DATA
                                                );
                            end if;
                        end loop;
                    else
                        elem := GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                                    PARAM   => I_PARAM ,
                                                    C       => c_pos+I_PARAM.SHAPE.C.LO,
                                                    X       => x_pos+I_PARAM.SHAPE.X.LO,
                                                    Y       => line +I_PARAM.SHAPE.Y.LO,
                                                    DATA    => I_DATA
                                                );
                    end if;
                    SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                        PARAM   => INTAKE_PARAM ,
                        C       => c_pos+INTAKE_PARAM.SHAPE.C.LO,
                        X       => x_pos+INTAKE_PARAM.SHAPE.X.LO,
                        Y       => line +INTAKE_PARAM.SHAPE.Y.LO,
                        ELEMENT => elem    ,
                        DATA    => data
                    );
                end loop;
            end loop;
        end loop;
        intake_data <= data;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BUF_WRITER:  IMAGE_WINDOW_BUFFER_WRITER          -- 
        generic map (                                -- 
            I_PARAM         => INTAKE_PARAM        , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE        , -- 
            CHANNEL_SIZE    => CHANNEL_SIZE        , --   
            BANK_SIZE       => BANK_SIZE           , --   
            LINE_SIZE       => LINE_SIZE           , --   
            BUF_ADDR_BITS   => BUF_ADDR_BITS       , --   
            BUF_DATA_BITS   => BUF_DATA_BITS         --   
        )                                            -- 
        port map (                                   -- 
        -------------------------------------------------------------------------------
        -- クロック&リセット信号
        -------------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        -------------------------------------------------------------------------------
        -- 入力側 I/F
        -------------------------------------------------------------------------------
            I_DATA          => intake_data         , -- In  :
            I_START_C       => intake_start_c      , -- In  :
            I_LAST_C        => intake_last_c       , -- In  :
            I_START_X       => intake_start_x      , -- In  :
            I_LAST_X        => intake_last_x       , -- In  :
            I_START_Y       => intake_start_y      , -- In  :
            I_LAST_Y        => intake_last_y       , -- In  :
            I_VALID         => intake_valid        , -- In  :
            I_CLEAR         => intake_clear        , -- In  :
            I_LINE_IDLE     => intake_line_idle    , -- In  :
            I_LINE_START    => intake_line_start   , -- In  :
            I_LINE_READY    => intake_line_ready   , -- Out :
        -------------------------------------------------------------------------------
        -- 出力側 I/F
        -------------------------------------------------------------------------------
            O_VALID         => O_VALID             , -- Out :
            O_C_SIZE        => O_C_SIZE            , -- Out :
            O_X_SIZE        => O_X_SIZE            , -- Out :
            O_Y_ATRB        => O_Y_ATRB            , -- Out :
            O_FEED          => O_FEED              , -- In  :
            O_RETURN        => O_RETURN            , -- In  :
        -------------------------------------------------------------------------------
        -- バッファ I/F
        -------------------------------------------------------------------------------
            BUF_DATA        => BUF_DATA            , -- Out :
            BUF_ADDR        => BUF_ADDR            , -- Out :
            BUF_WE          => BUF_WE                -- Out :
        );
end RTL;
