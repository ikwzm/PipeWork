-----------------------------------------------------------------------------------
--!     @file    image_window_buffer_outlet.vhd
--!     @brief   Image Window Buffer Outlet Module :
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
--! @brief   IMAGE_WINDOW_BUFFER_OUTLET :
--!          異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_BUFFER_OUTLET is
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
    -- 各種サイズ
    -------------------------------------------------------------------------------
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_D_SIZE := 1;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        C_OFFSET        : --! @brief OUTPUT CHANNEL BUFFER ADDRESS OFFSET :
                          in  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_LINE_VALID    : --! @brief INPUT LINE VALID :
                          --! ライン有効信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_ATRB     : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        I_LINE_FEED     : --! @brief INPUT LINE FEED :
                          --! ラインフィード信号出力.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          out std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        I_LINE_RETURN   : --! @brief INPUT LINE RETURN :
                          --! ラインリターン信号出力.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          out std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT WINDOW DATA :
                          --! ウィンドウデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_D_ATRB        : --! @brief OUTPUT CHANNEL ATTRIBUTE :
                          out IMAGE_ATRB_VECTOR(0 to D_UNROLL-1);
        O_VALID         : --! @brief OUTPUT WINDOW DATA VALID :
                          --! 出力ウィンドウデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT WINDOW DATA READY :
                          --! 出力ウィンドウデータレディ信号.
                          in  std_logic;
        O_LAST          : --! @brief OUTPUT LINE FEED :
                          --! 最終ウィンドウ入力.
                          in  std_logic;
        O_FEED          : --! @brief OUTPUT LINE FEED :
                          --! ラインフィード入力.
                          in  std_logic;
        O_RETURN        : --! @brief OUTPUT LINE RETURN :
                          --! ラインリターン入力.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end IMAGE_WINDOW_BUFFER_OUTLET;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_READER;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_CHANNEL_REDUCER;
architecture RTL of IMAGE_WINDOW_BUFFER_OUTLET is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   LINE_SELECT_TYPE      is std_logic_vector(0 to LINE_SIZE-1);
    type      LINE_SELECT_VECTOR    is array(integer range <>) of LINE_SELECT_TYPE;
    signal    line_select           :  LINE_SELECT_VECTOR(O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI);
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
    type      STATE_TYPE            is (IDLE_STATE       ,
                                        WAIT_STATE       ,
                                        OUTLET_STATE     ,
                                        LINE_RETURN_STATE,
                                        LINE_FEED_STATE  ,
                                        DONE_STATE      );
    signal    curr_state            :  STATE_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  OUTLET_PARAM          :  IMAGE_WINDOW_PARAM_TYPE
                                    := NEW_IMAGE_WINDOW_PARAM(
                                           ELEM_BITS    => O_PARAM.ELEM_BITS,
                                           INFO_BITS    => D_UNROLL*IMAGE_ATRB_BITS,
                                           SHAPE        => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                               C => O_PARAM.SHAPE.C,
                                                               X => O_PARAM.SHAPE.X,
                                                               Y => O_PARAM.SHAPE.Y
                                                           ),
                                           STRIDE       => O_PARAM.STRIDE,
                                           BORDER_TYPE  => O_PARAM.BORDER_TYPE
                                       );
    signal    outlet_data           :  std_logic_vector(OUTLET_PARAM.DATA.SIZE-1 downto 0);
    signal    outlet_valid          :  std_logic;
    signal    outlet_ready          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  READ_DATA_PARAM       :  IMAGE_WINDOW_PARAM_TYPE
                                    := NEW_IMAGE_WINDOW_PARAM(
                                           ELEM_BITS    => O_PARAM.ELEM_BITS,
                                           INFO_BITS    => D_UNROLL*IMAGE_ATRB_BITS,
                                           SHAPE        => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                               C => O_PARAM.SHAPE.C,
                                                               X => O_PARAM.SHAPE.X,
                                                               Y => NEW_IMAGE_VECTOR_RANGE(LINE_SIZE)
                                                           ),
                                           STRIDE       => O_PARAM.STRIDE,
                                           BORDER_TYPE  => O_PARAM.BORDER_TYPE
                                       );
    signal    buf_read_data         :  std_logic_vector(READ_DATA_PARAM.DATA.SIZE-1 downto 0);
    signal    buf_read_valid        :  std_logic;
    signal    buf_read_ready        :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    line_valid            :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    line_start            :  std_logic_vector(LINE_SIZE-1 downto 0);
    signal    line_active           :  std_logic_vector(LINE_SIZE-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- curr_state  :
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_state  <= IDLE_STATE;
                line_select <= INIT_LINE_SELECT(O_PARAM.SHAPE.Y.LO, O_PARAM.SHAPE.Y.HI);
                line_active <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_state  <= IDLE_STATE;
                line_select <= INIT_LINE_SELECT(O_PARAM.SHAPE.Y.LO, O_PARAM.SHAPE.Y.HI);
                line_active <= (others => '0');
            else
                case curr_state is
                    when IDLE_STATE =>
                            curr_state  <= WAIT_STATE;
                            line_select <= INIT_LINE_SELECT(O_PARAM.SHAPE.Y.LO, O_PARAM.SHAPE.Y.HI);
                            line_active <= (others => '0');
                    when WAIT_STATE =>
                        if (line_valid /= LINE_ALL_0) then
                            line_active <= line_valid;
                            curr_state  <= OUTLET_STATE;
                        else
                            line_active <= (others => '0');
                            curr_state  <= WAIT_STATE;
                        end if;
                    when OUTLET_STATE =>
                        if    (O_RETURN = '1') then
                            curr_state <= LINE_RETURN_STATE;
                        elsif (O_FEED   = '1' and O_LAST = '0') then
                            curr_state <= LINE_FEED_STATE;
                        elsif (O_FEED   = '1' and O_LAST = '1') then
                            curr_state <= DONE_STATE;
                        else
                            curr_state <= OUTLET_STATE;
                        end if;
                    when LINE_RETURN_STATE =>
                        curr_state  <= WAIT_STATE;
                    when LINE_FEED_STATE =>
                        curr_state  <= WAIT_STATE;
                        line_select <= STRIDE_LINE_SELECT(line_select, O_PARAM.STRIDE.Y);
                    when DONE_STATE =>
                        curr_state  <= IDLE_STATE;
                        line_select <= STRIDE_LINE_SELECT(line_select, O_PARAM.STRIDE.Y);
                    when others     =>
                        curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- line_valid :
    -------------------------------------------------------------------------------
    process (I_LINE_VALID, line_select)
        variable  or_reduced_line_valid :  std_logic_vector(LINE_SIZE-1 downto 0);
    begin
        or_reduced_line_valid := (others => '0');
        for line in 0 to LINE_SIZE-1 loop
            for y_pos in O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI loop
                if line_select(y_pos)(line) = '1' and I_LINE_VALID(line) = '1' then
                    or_reduced_line_valid(line) := or_reduced_line_valid(line) or '1';
                end if;
            end loop;
        end loop;
        line_valid <= or_reduced_line_valid;
    end process;
    -------------------------------------------------------------------------------
    -- line_start :
    -------------------------------------------------------------------------------
    line_start    <= line_valid  when (curr_state = WAIT_STATE) else (others => '0');
    -------------------------------------------------------------------------------
    -- I_LINE_FEED   :
    -- I_LINE_RETURN :
    -------------------------------------------------------------------------------
    I_LINE_RETURN <= line_active when (curr_state = LINE_RETURN_STATE) else (others => '0');
    I_LINE_FEED   <= line_active when (curr_state = LINE_FEED_STATE  ) or
                                      (curr_state = DONE_STATE       ) else (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BUF_READER: IMAGE_WINDOW_BUFFER_READER       -- 
        generic map (                            -- 
            O_PARAM         => READ_DATA_PARAM , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE    , --   
            CHANNEL_SIZE    => CHANNEL_SIZE    , --   
            BANK_SIZE       => BANK_SIZE       , --   
            LINE_SIZE       => LINE_SIZE       , --   
            MAX_D_SIZE      => MAX_D_SIZE      , --
            D_STRIDE        => D_STRIDE        , --
            D_UNROLL        => D_UNROLL        , --
            BUF_ADDR_BITS   => BUF_ADDR_BITS   , --   
            BUF_DATA_BITS   => BUF_DATA_BITS     --
        )                                        -- 
        port map (                               -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_LINE_START    => line_start      , -- In  :
            I_LINE_ATRB     => I_LINE_ATRB     , -- In  :
            X_SIZE          => X_SIZE          , -- In  :
            D_SIZE          => D_SIZE          , -- In  :
            C_SIZE          => C_SIZE          , -- In  :
            C_OFFSET        => C_OFFSET        , -- In  :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => buf_read_data   , -- Out :
            O_VALID         => buf_read_valid  , -- Out :
            O_READY         => buf_read_ready  , -- Out :
        ---------------------------------------------------------------------------
        -- バッファメモリ I/F
        ---------------------------------------------------------------------------
            BUF_DATA        => BUF_DATA        , -- In  :
            BUF_ADDR        => BUF_ADDR          -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (buf_read_data, line_select)
        variable  data   :  std_logic_vector(OUTLET_PARAM.DATA.SIZE-1 downto 0);
        variable  elem   :  std_logic_vector(OUTLET_PARAM.ELEM_BITS-1 downto 0);
        variable  atrb_y :  std_logic_vector(IMAGE_ATRB_BITS       -1 downto 0);
        variable  i_atrb :  std_logic_vector(IMAGE_ATRB_BITS       -1 downto 0);
    begin
        data(OUTLET_PARAM.DATA.INFO_FIELD  .HI downto OUTLET_PARAM.DATA.INFO_FIELD  .LO) := buf_read_data(READ_DATA_PARAM.DATA.INFO_FIELD  .HI downto READ_DATA_PARAM.DATA.INFO_FIELD  .LO);
        data(OUTLET_PARAM.DATA.ATRB_C_FIELD.HI downto OUTLET_PARAM.DATA.ATRB_C_FIELD.LO) := buf_read_data(READ_DATA_PARAM.DATA.ATRB_C_FIELD.HI downto READ_DATA_PARAM.DATA.ATRB_C_FIELD.LO);
        data(OUTLET_PARAM.DATA.ATRB_X_FIELD.HI downto OUTLET_PARAM.DATA.ATRB_X_FIELD.LO) := buf_read_data(READ_DATA_PARAM.DATA.ATRB_X_FIELD.HI downto READ_DATA_PARAM.DATA.ATRB_X_FIELD.LO);
        for y_pos in OUTLET_PARAM.SHAPE.Y.LO to OUTLET_PARAM.SHAPE.Y.HI loop
            atrb_y := (others => '0');
            for line in 0 to LINE_SIZE-1 loop
                if (line_select(y_pos)(line) = '1') then
                    if (I_LINE_ATRB(line).VALID) then
                        i_atrb(IMAGE_ATRB_VALID_POS) := '1';
                    else
                        i_atrb(IMAGE_ATRB_VALID_POS) := '0';
                    end if;
                    if (I_LINE_ATRB(line).START) then
                        i_atrb(IMAGE_ATRB_START_POS) := '1';
                    else
                        i_atrb(IMAGE_ATRB_START_POS) := '0';
                    end if;
                    if (I_LINE_ATRB(line).LAST ) then
                        i_atrb(IMAGE_ATRB_LAST_POS ) := '1';
                    else
                        i_atrb(IMAGE_ATRB_LAST_POS ) := '0';
                    end if;
                    atrb_y := atrb_y or i_atrb;
                end if;
            end loop;
            SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(OUTLET_PARAM, y_pos, atrb_y, data);
        end loop;
        for c_pos in OUTLET_PARAM.SHAPE.C.LO to OUTLET_PARAM.SHAPE.C.HI loop
        for x_pos in OUTLET_PARAM.SHAPE.X.LO to OUTLET_PARAM.SHAPE.X.HI loop
        for y_pos in OUTLET_PARAM.SHAPE.Y.LO to OUTLET_PARAM.SHAPE.Y.HI loop
            elem := (others => '0');
            for line  in 0 to LINE_SIZE-1 loop
                if (line_select(y_pos)(line) = '1') then
                    elem := elem or GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                        PARAM   => READ_DATA_PARAM ,
                                        C       => c_pos,
                                        X       => x_pos,
                                        Y       => line+READ_DATA_PARAM.SHAPE.X.LO,
                                        DATA    => buf_read_data
                                    );
                end if;
            end loop;
            SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                    PARAM   => OUTLET_PARAM ,
                    C       => c_pos,
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
    outlet_valid   <= buf_read_valid;
    buf_read_ready <= outlet_ready;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_DATA(O_PARAM.DATA.ELEM_FIELD.HI downto O_PARAM.DATA.ELEM_FIELD.LO) <= outlet_data(OUTLET_PARAM.DATA.ELEM_FIELD.HI downto OUTLET_PARAM.DATA.ELEM_FIELD.LO);
    O_DATA(O_PARAM.DATA.ATRB_FIELD.HI downto O_PARAM.DATA.ATRB_FIELD.LO) <= outlet_data(OUTLET_PARAM.DATA.ATRB_FIELD.HI downto OUTLET_PARAM.DATA.ATRB_FIELD.LO);
    process(outlet_data)
        variable info :  std_logic_vector(OUTLET_PARAM.INFO_BITS-1 downto 0);
    begin
        info := outlet_data(OUTLET_PARAM.DATA.INFO_FIELD.HI downto OUTLET_PARAM.DATA.INFO_FIELD.LO);
        for d_pos in 0 to D_UNROLL-1 loop
            O_D_ATRB(d_pos).VALID <= (info(d_pos*IMAGE_ATRB_BITS+IMAGE_ATRB_VALID_POS) = '1');
            O_D_ATRB(d_pos).START <= (info(d_pos*IMAGE_ATRB_BITS+IMAGE_ATRB_START_POS) = '1');
            O_D_ATRB(d_pos).LAST  <= (info(d_pos*IMAGE_ATRB_BITS+IMAGE_ATRB_LAST_POS ) = '1');
        end loop;
    end process;
    O_VALID <= outlet_valid;
    outlet_ready <= O_READY;
end RTL;
