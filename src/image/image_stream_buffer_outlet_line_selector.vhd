-----------------------------------------------------------------------------------
--!     @file    image_stream_buffer_outlet_line_selector.vhd
--!     @brief   Image Stream Buffer Outlet Line Selector Module :
--!              異なる形のイメージストリームを継ぐためのバッファの出力側ライン選択
--!              モジュール
--!     @version 1.8.0
--!     @date    2019/5/22
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
--! @brief   Image Stream Buffer Outlet Line Selector Module :
--!          異なる形のイメージストリームを継ぐためのバッファの出力側ライン選択
--!          モジュール
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_BUFFER_OUTLET_LINE_SELECTOR is
    generic (
        I_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 入力側のストリームのパラメータを指定する.
                          --! * I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          --! * I_PARAM.INFO_BITS    = 0                    でなければならない.
                          --! * I_PARAM.SHAPE.C.SIZE = O_PARAM.SHAPE.C.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.D.SIZE = O_PARAM.SHAPE.D.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.X.SIZE = O_PARAM.SHAPE.X.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! * O_PARAM.ELEM_SIZE    = I_PARAM.ELEM_SIZE    でなければならない.
                          --! * O_PARAM.INFO_BITS    = 0                    でなければならない.
                          --! * O_PARAM.SHAPE.C.SIZE = I_PARAM.SHAPE.C.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.D.SIZE = I_PARAM.SHAPE.D.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.X.SIZE = I_PARAM.SHAPE.X.SIZE でなければならない.
                          --! 出力側のストリームのパラメータを指定する.
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
        I_LINE_START    : --! @brief INPUT LINE START :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
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
        O_LAST          : --! @brief OUTPUT LINE FEED :
                          --! 最終ストリーム入力.
                          in  std_logic;
        O_FEED          : --! @brief OUTPUT LINE FEED :
                          --! ラインフィード入力.
                          in  std_logic;
        O_RETURN        : --! @brief OUTPUT LINE RETURN :
                          --! ラインリターン入力.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- ライン制御 I/F
    -------------------------------------------------------------------------------
        LINE_VALID      : --! @brief INPUT LINE VALID :
                          --! ライン有効信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        LINE_ATRB       : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        LINE_FEED       : --! @brief INPUT LINE FEED :
                          --! ラインフィード信号出力.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        LINE_RETURN     : --! @brief INPUT LINE RETURN :
                          --! ラインリターン信号出力.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          out std_logic_vector(LINE_SIZE-1 downto 0)
    );
end IMAGE_STREAM_BUFFER_OUTLET_LINE_SELECTOR;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER;
architecture RTL of IMAGE_STREAM_BUFFER_OUTLET_LINE_SELECTOR is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   LINE_SELECT_TYPE      is std_logic_vector(LINE_SIZE-1 downto 0);
    type      LINE_SELECT_VECTOR    is array(integer range <>) of LINE_SELECT_TYPE;
    signal    line_select           :  LINE_SELECT_VECTOR      (O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI);
    signal    curr_line_valid       :  LINE_SELECT_TYPE;
    signal    next_line_active      :  LINE_SELECT_TYPE;
    signal    line_outlet_start     :  boolean;
    signal    atrb_y_vector         :  IMAGE_STREAM_ATRB_VECTOR(O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI);
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
    signal    outlet_data           :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE            is (IDLE_STATE,
                                        WAIT_STATE,
                                        OUTLET_STATE,
                                        LINE_RETURN_STATE,
                                        LINE_FEED_STATE,
                                        DONE_STATE);
    signal    curr_state            :  STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- curr_state  :
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_state      <= IDLE_STATE;
                line_select     <= INIT_LINE_SELECT(O_PARAM.SHAPE.Y.LO, O_PARAM.SHAPE.Y.HI);
                curr_line_valid <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_state      <= IDLE_STATE;
                line_select     <= INIT_LINE_SELECT(O_PARAM.SHAPE.Y.LO, O_PARAM.SHAPE.Y.HI);
                curr_line_valid <= (others => '0');
            else
                case curr_state is
                    when IDLE_STATE =>
                            curr_state  <= WAIT_STATE;
                            line_select <= INIT_LINE_SELECT(O_PARAM.SHAPE.Y.LO, O_PARAM.SHAPE.Y.HI);
                            curr_line_valid <= (others => '0');
                    when WAIT_STATE =>
                        if (line_outlet_start = TRUE) then
                            curr_state  <= OUTLET_STATE;
                        else
                            curr_state  <= WAIT_STATE;
                        end if;
                        curr_line_valid <= next_line_active and LINE_VALID;
                    when OUTLET_STATE =>
                        if    (O_RETURN = '1') then
                            curr_state  <= LINE_RETURN_STATE;
                        elsif (O_FEED   = '1' and O_LAST = '0') then
                            curr_state  <= LINE_FEED_STATE;
                            line_select <= STRIDE_LINE_SELECT(line_select, O_PARAM.STRIDE.Y);
                        elsif (O_FEED   = '1' and O_LAST = '1') then
                            curr_state  <= DONE_STATE;
                            line_select <= STRIDE_LINE_SELECT(line_select, O_PARAM.STRIDE.Y);
                        else
                            curr_state  <= OUTLET_STATE;
                        end if;
                    when LINE_RETURN_STATE =>
                        curr_state  <= WAIT_STATE;
                    when LINE_FEED_STATE =>
                        curr_state  <= WAIT_STATE;
                    when DONE_STATE =>
                        curr_state  <= IDLE_STATE;
                    when others     =>
                        curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- atrb_y_vector :
    -------------------------------------------------------------------------------
    process(line_select, LINE_VALID, LINE_ATRB)
        variable  i_atrb :  std_logic_vector(IMAGE_STREAM_ATRB_BITS-1 downto 0);
        variable  y_atrb :  std_logic_vector(IMAGE_STREAM_ATRB_BITS-1 downto 0);
        variable  y_last :  boolean;
    begin
        y_last := FALSE;
        for y_pos in O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI loop
            y_atrb := (others => '0');
            for line in 0 to LINE_SIZE-1 loop
                if (line_select(y_pos)(line) = '1' and LINE_VALID(line) = '1') then
                    if (LINE_ATRB(line).VALID) then
                        i_atrb(IMAGE_STREAM_ATRB_VALID_POS) := '1';
                    else
                        i_atrb(IMAGE_STREAM_ATRB_VALID_POS) := '0';
                    end if;
                    if (LINE_ATRB(line).START) then
                        i_atrb(IMAGE_STREAM_ATRB_START_POS) := '1';
                    else
                        i_atrb(IMAGE_STREAM_ATRB_START_POS) := '0';
                    end if;
                    if (LINE_ATRB(line).LAST ) then
                        i_atrb(IMAGE_STREAM_ATRB_LAST_POS ) := '1';
                    else
                        i_atrb(IMAGE_STREAM_ATRB_LAST_POS ) := '0';
                    end if;
                    y_atrb := y_atrb or i_atrb;
                end if;
            end loop;
            atrb_y_vector(y_pos).VALID <= (y_atrb(IMAGE_STREAM_ATRB_VALID_POS) = '1');
            atrb_y_vector(y_pos).START <= (y_atrb(IMAGE_STREAM_ATRB_START_POS) = '1');
            atrb_y_vector(y_pos).LAST  <= (y_atrb(IMAGE_STREAM_ATRB_LAST_POS ) = '1' or y_last = TRUE);
            if (y_atrb(IMAGE_STREAM_ATRB_VALID_POS) = '1' and y_atrb(IMAGE_STREAM_ATRB_LAST_POS) = '1') then
                y_last := TRUE;
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- next_line_active  :
    -------------------------------------------------------------------------------
    process(line_select)
        variable line_active :  LINE_SELECT_TYPE;
    begin
        line_active := (others => '0');
        for y_pos in O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI loop
            line_active := line_active or line_select(y_pos);
        end loop;
        next_line_active <= line_active;
    end process;
    -------------------------------------------------------------------------------
    -- line_outlet_start :
    -------------------------------------------------------------------------------
    line_outlet_start <= (IMAGE_STREAM_ATRB_Y_VECTOR_IS_LAST(O_PARAM, atrb_y_vector) = TRUE) or
                         ((next_line_active and LINE_VALID) = next_line_active);
    -------------------------------------------------------------------------------
    -- I_LINE_START :
    -------------------------------------------------------------------------------
    I_LINE_START <= next_line_active when (curr_state = WAIT_STATE and line_outlet_start = TRUE) else (others => '0');
    -------------------------------------------------------------------------------
    -- LINE_FEED    :
    -- LINE_RETURN  :
    -------------------------------------------------------------------------------
    process(curr_state, curr_line_valid, next_line_active) begin
        case curr_state is
            when LINE_FEED_STATE   =>
                for line in 0 to LINE_SIZE-1 loop
                    if (curr_line_valid(line) = '1') then
                        if (next_line_active(line) = '1') then
                            LINE_FEED  (line) <= '0';
                            LINE_RETURN(line) <= '1';
                        else
                            LINE_FEED  (line) <= '1';
                            LINE_RETURN(line) <= '0';
                        end if;
                    else
                            LINE_FEED  (line) <= '0';
                            LINE_RETURN(line) <= '0';
                    end if;
                end loop;
            when LINE_RETURN_STATE =>
                LINE_RETURN <= curr_line_valid;
                LINE_FEED   <= (others => '0');
            when DONE_STATE        =>
                LINE_RETURN <= (others => '0');
                LINE_FEED   <= curr_line_valid;
            when others            =>
                LINE_RETURN <= (others => '0');
                LINE_FEED   <= (others => '0');
        end case;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (I_DATA, line_select, atrb_y_vector)
        variable  data   :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        variable  elem   :  std_logic_vector(O_PARAM.ELEM_BITS-1 downto 0);
    begin
        if (O_PARAM.DATA.ATRB_FIELD.C.SIZE > 0) then 
            data(O_PARAM.DATA.ATRB_FIELD.C.HI downto O_PARAM.DATA.ATRB_FIELD.C.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.C.HI downto I_PARAM.DATA.ATRB_FIELD.C.LO);
        end if;
        if (O_PARAM.DATA.ATRB_FIELD.D.SIZE > 0) then 
            data(O_PARAM.DATA.ATRB_FIELD.D.HI downto O_PARAM.DATA.ATRB_FIELD.D.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.D.HI downto I_PARAM.DATA.ATRB_FIELD.D.LO);
        end if;
        if (O_PARAM.DATA.ATRB_FIELD.X.SIZE > 0) then 
            data(O_PARAM.DATA.ATRB_FIELD.X.HI downto O_PARAM.DATA.ATRB_FIELD.X.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.X.HI downto I_PARAM.DATA.ATRB_FIELD.X.LO);
        end if;
        for y_pos in O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI loop
            SET_ATRB_Y_TO_IMAGE_STREAM_DATA(O_PARAM, y_pos, atrb_y_vector(y_pos), data);
        end loop;
        for c_pos in O_PARAM.SHAPE.C.LO to O_PARAM.SHAPE.C.HI loop
        for x_pos in O_PARAM.SHAPE.X.LO to O_PARAM.SHAPE.X.HI loop
        for y_pos in O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI loop
            elem := (others => '0');
            for line  in 0 to LINE_SIZE-1 loop
                if (line_select(y_pos)(line) = '1') then
                    elem := elem or GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                                        PARAM   => I_PARAM ,
                                        C       => c_pos,
                                        D       => I_PARAM.SHAPE.D.LO,
                                        X       => x_pos,
                                        Y       => line+I_PARAM.SHAPE.Y.LO,
                                        DATA    => I_DATA
                                    );
                end if;
            end loop;
            SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                    PARAM   => O_PARAM ,
                    C       => c_pos,
                    D       => O_PARAM.SHAPE.D.LO,
                    X       => x_pos,
                    Y       => y_pos,
                    ELEMENT => elem ,
                    DATA    => data
             );
        end loop;
        end loop;
        end loop;
        outlet_data <= data;
    end process;
    -------------------------------------------------------------------------------
    -- O_DATA  :
    -- O_VALID :
    -- I_READY :
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
            I_VAL       => I_VALID           , -- In  :
            I_RDY       => I_READY           , -- Out :
            Q_WORD      => O_DATA            , -- Out :
            Q_VAL       => O_VALID           , -- Out :
            Q_RDY       => O_READY           , -- In  :
            BUSY        => open                -- Out :
        );
end RTL;
