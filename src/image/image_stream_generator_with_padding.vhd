-----------------------------------------------------------------------------------
--!     @file    image_stream_generator_with_padding.vhd
--!     @brief   Image Stream Generator with Padding Module
--!     @version 1.8.0
--!     @date    2019/4/5
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
--! @brief   IMAGE_STREAM_GENERATOR_WITH_PADDING :
--!          入力データに対して、指定された大きさのパディングを追加して、さらにイメ
--!          ージストリームの属性を付加して出力する.
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_GENERATOR_WITH_PADDING is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        O_PARAM         : --! @brief OUTPUT IMAGE STREAM PARAMETER :
                          --! 出力側イメージストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(32,1,1,1);
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE PARAMETER :
                          IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(32,1,1,1);
                          --! 出力側イメージストリームのパラメータを指定する.
        I_DATA_BITS     : --! @brief INPUT  STREAM DATA BIT SIZE :
                          --! 入力側のデータのビット幅を指定する.
                          --! * I_DATA_BITS = O_PARAM.DATA.ELEM_FIELD.SIZE でなけれ
                          --!   ばならない.
                          integer := 32;
        MAX_PAD_SIZE    : --! @brief MAX PADDING SIZE SIZE :
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
    -- 
    -------------------------------------------------------------------------------
        START           : --! @brief STREAM START :
                          in  std_logic;
        BUSY            : --! @brief STREAM BUSY :
                          out std_logic;
        DONE            : --! @brief STREAM DONE :
                          out std_logic;
        C_SIZE          : --! @brief INPUT C CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
        D_SIZE          : --! @brief INPUT D CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.D.SIZE;
        X_SIZE          : --! @brief INPUT IMAGE WIDTH :
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
        Y_SIZE          : --! @brief INPUT IMAGE HEIGHT :
                          in  integer range 0 to O_SHAPE.Y.MAX_SIZE := O_SHAPE.Y.SIZE;
        LEFT_PAD_SIZE   : --! @brief IMAGE WIDTH START PAD SIZE :
                          in  integer range 0 to MAX_PAD_SIZE := 0;
        RIGHT_PAD_SIZE  : --! @brief IMAGE WIDTH LAST  PAD SIZE :
                          in  integer range 0 to MAX_PAD_SIZE := 0;
        TOP_PAD_SIZE    : --! @brief IMAGE HEIGHT START PAD SIZE :
                          in  integer range 0 to MAX_PAD_SIZE := 0;
        BOTTOM_PAD_SIZE : --! @brief IMAGE HEIGHT LAST  PAD SIZE :
                          in  integer range 0 to MAX_PAD_SIZE := 0;
        PAD_DATA        : --! @brief PADDING DATA :
                          in  std_logic_vector(I_DATA_BITS    -1 downto 0);
    -------------------------------------------------------------------------------
    -- STREAM 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_DATA_BITS    -1 downto 0);
        I_VALID         : --! @brief INPUT STREAM VALID :
                          --! 入力ストリムーデータ有効信号.
                          --! I_DATA/I_STRB/I_LAST が有効であることを示す.
                          in  std_logic;
        I_READY         : --! @brief INPUT STREAM READY :
                          --! 入力ストリムーデータレディ信号.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- IMAGE STREAM 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT IMAGE STREAM DATA :
                          --! イメージストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT IMAGE STREAM DATA VALID :
                          --! 出力イメージストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE STREAM DATA READY :
                          --! 出力イメージストリームデータレディ信号.
                          in  std_logic
    );
end IMAGE_STREAM_GENERATOR_WITH_PADDING;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.UNROLLED_LOOP_COUNTER;
architecture RTL of IMAGE_STREAM_GENERATOR_WITH_PADDING is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    y_loop_start          :  std_logic;
    signal    y_loop_next           :  std_logic;
    signal    y_loop_busy           :  std_logic;
    signal    y_loop_done           :  std_logic;
    signal    y_loop_first          :  std_logic;
    signal    y_loop_last           :  std_logic;
    signal    y_loop_valid          :  std_logic_vector(O_PARAM.SHAPE.Y.SIZE-1 downto 0);
    signal    y_loop_size           :  integer range 0 to O_SHAPE.Y.MAX_SIZE + 2*MAX_PAD_SIZE;
    signal    y_pad_start           :  std_logic;
    signal    y_pad_next            :  std_logic;
    signal    y_pad_done            :  std_logic;
    signal    y_pad_busy            :  std_logic;
    signal    y_pad_size            :  integer range 0 to MAX_PAD_SIZE;
    signal    y_input_start         :  std_logic;
    signal    y_input_next          :  std_logic;
    signal    y_input_enable        :  std_logic;
    signal    y_input_size          :  integer range 0 to O_SHAPE.Y.MAX_SIZE;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    x_loop_start          :  std_logic;
    signal    x_loop_next           :  std_logic;
    signal    x_loop_busy           :  std_logic;
    signal    x_loop_done           :  std_logic;
    signal    x_loop_first          :  std_logic;
    signal    x_loop_last           :  std_logic;
    signal    x_loop_valid          :  std_logic_vector(O_PARAM.SHAPE.X.SIZE-1 downto 0);
    signal    x_loop_size           :  integer range 0 to O_SHAPE.X.MAX_SIZE + 2*MAX_PAD_SIZE;
    signal    x_pad_start           :  std_logic;
    signal    x_pad_next            :  std_logic;
    signal    x_pad_done            :  std_logic;
    signal    x_pad_busy            :  std_logic;
    signal    x_pad_size            :  integer range 0 to MAX_PAD_SIZE;
    signal    x_input_start         :  std_logic;
    signal    x_input_next          :  std_logic;
    signal    x_input_enable        :  std_logic;
    signal    x_input_size          :  integer range 0 to O_SHAPE.X.MAX_SIZE;
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
    signal    d_loop_size           :  integer range 0 to O_SHAPE.D.MAX_SIZE;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    c_loop_start          :  std_logic;
    signal    c_loop_next           :  std_logic;
    signal    c_loop_busy           :  std_logic;
    signal    c_loop_done           :  std_logic;
    signal    c_loop_first          :  std_logic;
    signal    c_loop_last           :  std_logic;
    signal    c_loop_valid          :  std_logic_vector(O_PARAM.SHAPE.C.SIZE-1 downto 0);
    signal    c_loop_size           :  integer range 0 to O_SHAPE.C.MAX_SIZE;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    input_enable          :  std_logic;
    signal    output_valid          :  std_logic;
    signal    output_ready          :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    y_loop_start <= START;
    BUSY         <= y_loop_busy;
    DONE         <= y_loop_done;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    Y_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        y_input_size  <= O_SHAPE.Y.SIZE when (O_SHAPE.Y.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else Y_SIZE;
        y_loop_size   <= y_input_size + TOP_PAD_SIZE + BOTTOM_PAD_SIZE;
        y_pad_size    <= TOP_PAD_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        y_pad_start   <= '1' when (y_loop_start   = '1' and TOP_PAD_SIZE > 0 ) else '0';
        y_input_start <= '1' when (y_loop_start   = '1' and TOP_PAD_SIZE = 0 ) or
                                  (y_pad_busy     = '1' and y_pad_done  = '1') else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        LOOP_COUNT: UNROLLED_LOOP_COUNTER                    -- 
            generic map (                                    -- 
                STRIDE          => 1                       , --
                UNROLL          => O_PARAM.SHAPE.Y.SIZE    , --
                MAX_LOOP_SIZE   => O_SHAPE.Y.MAX_SIZE  + 2*MAX_PAD_SIZE, --
                MAX_LOOP_INIT   => 0                         --
            )                                                -- 
            port map (                                       -- 
                CLK             => CLK                     , -- In  :
                RST             => RST                     , -- In  :
                CLR             => CLR                     , -- In  :
                LOOP_START      => y_loop_start            , -- In  :
                LOOP_NEXT       => y_loop_next             , -- In  :
                LOOP_SIZE       => y_loop_size             , -- In  :
                LOOP_DONE       => y_loop_done             , -- Out :
                LOOP_BUSY       => y_loop_busy             , -- Out :
                LOOP_VALID      => y_loop_valid            , -- Out :
                LOOP_FIRST      => y_loop_first            , -- Out :
                LOOP_LAST       => y_loop_last               -- Out :
            );                                               -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        PADDING_COUNT: UNROLLED_LOOP_COUNTER                 -- 
            generic map (                                    -- 
                STRIDE          => 1                       , --
                UNROLL          => O_PARAM.SHAPE.Y.SIZE    , --
                MAX_LOOP_SIZE   => MAX_PAD_SIZE            , --
                MAX_LOOP_INIT   => 0                         --
            )                                                -- 
            port map (                                       -- 
                CLK             => CLK                     , -- In  :
                RST             => RST                     , -- In  :
                CLR             => CLR                     , -- In  :
                LOOP_START      => y_pad_start             , -- In  :
                LOOP_NEXT       => y_pad_next              , -- In  :
                LOOP_SIZE       => y_pad_size              , -- In  :
                LOOP_BUSY       => y_pad_busy              , -- Out :
                LOOP_DONE       => y_pad_done                -- Out :
            );                                               -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        INPUT_COUNT: UNROLLED_LOOP_COUNTER                   -- 
            generic map (                                    -- 
                STRIDE          => 1                       , --
                UNROLL          => O_PARAM.SHAPE.Y.SIZE    , --
                MAX_LOOP_SIZE   => O_SHAPE.Y.MAX_SIZE      , --
                MAX_LOOP_INIT   => 0                         --
            )                                                -- 
            port map (                                       -- 
                CLK             => CLK                     , -- In  :
                RST             => RST                     , -- In  :
                CLR             => CLR                     , -- In  :
                LOOP_START      => y_input_start           , -- In  :
                LOOP_NEXT       => y_input_next            , -- In  :
                LOOP_SIZE       => y_input_size            , -- In  :
                LOOP_BUSY       => y_input_enable            -- Out :
            );                                               -- 
        ---------------------------------------------------------------------------
        -- y_loop_next  :
        ---------------------------------------------------------------------------
        y_loop_next  <= '1' when (x_loop_done    = '1') else '0';
        y_pad_next   <= '1' when (y_pad_busy     = '1' and y_loop_next = '1') else '0';
        y_input_next <= '1' when (y_input_enable = '1' and y_loop_next = '1') else '0';
        ---------------------------------------------------------------------------
        -- x_loop_start : 
        ---------------------------------------------------------------------------
        x_loop_start <= '1' when (y_loop_start = '1') or
                                 (y_loop_next  = '1' and y_loop_last = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    X_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        x_input_size  <= O_SHAPE.X.SIZE when (O_SHAPE.X.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else X_SIZE;
        x_loop_size   <= x_input_size + LEFT_PAD_SIZE + RIGHT_PAD_SIZE;
        x_pad_size    <= LEFT_PAD_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        x_pad_start   <= '1' when (x_loop_start = '1' and LEFT_PAD_SIZE > 0) else '0';
        x_input_start <= '1' when (x_loop_start = '1' and LEFT_PAD_SIZE = 0) or
                                  (x_pad_busy   = '1' and x_pad_done  = '1') else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        LOOP_COUNT: UNROLLED_LOOP_COUNTER                    -- 
            generic map (                                    -- 
                STRIDE          => 1                       , --
                UNROLL          => O_PARAM.SHAPE.X.SIZE    , --
                MAX_LOOP_SIZE   => O_SHAPE.X.MAX_SIZE + 2*MAX_PAD_SIZE, --
                MAX_LOOP_INIT   => 0                         --
            )                                                -- 
            port map (                                       -- 
                CLK             => CLK                     , -- In  :
                RST             => RST                     , -- In  :
                CLR             => CLR                     , -- In  :
                LOOP_START      => x_loop_start            , -- In  :
                LOOP_NEXT       => x_loop_next             , -- In  :
                LOOP_SIZE       => x_loop_size             , -- In  :
                LOOP_DONE       => x_loop_done             , -- Out :
                LOOP_BUSY       => x_loop_busy             , -- Out :
                LOOP_VALID      => x_loop_valid            , -- Out :
                LOOP_FIRST      => x_loop_first            , -- Out :
                LOOP_LAST       => x_loop_last               -- Out :
            );                                               -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        PADDING_COUNT: UNROLLED_LOOP_COUNTER                 -- 
            generic map (                                    -- 
                STRIDE          => 1                       , --
                UNROLL          => O_PARAM.SHAPE.X.SIZE    , --
                MAX_LOOP_SIZE   => MAX_PAD_SIZE            , --
                MAX_LOOP_INIT   => 0                         --
            )                                                -- 
            port map (                                       -- 
                CLK             => CLK                     , -- In  :
                RST             => RST                     , -- In  :
                CLR             => CLR                     , -- In  :
                LOOP_START      => x_pad_start             , -- In  :
                LOOP_NEXT       => x_pad_next              , -- In  :
                LOOP_SIZE       => x_pad_size              , -- In  :
                LOOP_BUSY       => x_pad_busy              , -- Out :
                LOOP_DONE       => x_pad_done                -- Out :
            );                                               -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        INPUT_COUNT: UNROLLED_LOOP_COUNTER                   -- 
            generic map (                                    -- 
                STRIDE          => 1                       , --
                UNROLL          => O_PARAM.SHAPE.X.SIZE    , --
                MAX_LOOP_SIZE   => O_SHAPE.X.MAX_SIZE      , --
                MAX_LOOP_INIT   => 0                         --
            )                                                -- 
            port map (                                       -- 
                CLK             => CLK                     , -- In  :
                RST             => RST                     , -- In  :
                CLR             => CLR                     , -- In  :
                LOOP_START      => x_input_start           , -- In  :
                LOOP_NEXT       => x_input_next            , -- In  :
                LOOP_SIZE       => x_input_size            , -- In  :
                LOOP_BUSY       => x_input_enable            -- Out :
            );                                               -- 
        ---------------------------------------------------------------------------
        -- x_loop_next  :
        ---------------------------------------------------------------------------
        x_loop_next  <= '1' when (d_loop_done  = '1') else '0';
        x_pad_next   <= '1' when (x_pad_busy     = '1' and x_loop_next = '1') else '0';
        x_input_next <= '1' when (x_input_enable = '1' and x_loop_next = '1') else '0';
        ---------------------------------------------------------------------------
        -- d_loop_start : 
        ---------------------------------------------------------------------------
        d_loop_start <= '1' when (x_loop_start = '1') or
                                 (x_loop_next  = '1' and x_loop_last = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    D_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        d_loop_size <= O_SHAPE.D.SIZE when (O_SHAPE.D.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else D_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        LOOP_COUNT: UNROLLED_LOOP_COUNTER                    -- 
            generic map (                                    -- 
                STRIDE          => 1                       , --
                UNROLL          => O_PARAM.SHAPE.D.SIZE    , --
                MAX_LOOP_SIZE   => O_SHAPE.D.MAX_SIZE      , --
                MAX_LOOP_INIT   => 0                         --
            )                                                -- 
            port map (                                       -- 
                CLK             => CLK                     , -- In  :
                RST             => RST                     , -- In  :
                CLR             => CLR                     , -- In  :
                LOOP_START      => d_loop_start            , -- In  :
                LOOP_NEXT       => d_loop_next             , -- In  :
                LOOP_SIZE       => d_loop_size             , -- In  :
                LOOP_DONE       => d_loop_done             , -- Out :
                LOOP_BUSY       => d_loop_busy             , -- Out :
                LOOP_VALID      => d_loop_valid            , -- Out :
                LOOP_FIRST      => d_loop_first            , -- Out :
                LOOP_LAST       => d_loop_last               -- Out :
            );                                               -- 
        ---------------------------------------------------------------------------
        -- d_loop_next  :
        ---------------------------------------------------------------------------
        d_loop_next  <= '1' when (c_loop_done = '1') else '0';
        ---------------------------------------------------------------------------
        -- c_loop_start : 
        ---------------------------------------------------------------------------
        c_loop_start <= '1' when (d_loop_start = '1') or
                                 (d_loop_next  = '1' and d_loop_last = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    C_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        c_loop_size <= O_SHAPE.C.SIZE when (O_SHAPE.C.DICIDE_TYPE = IMAGE_SHAPE_SIDE_DICIDE_CONSTANT) else C_SIZE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        LOOP_COUNT: UNROLLED_LOOP_COUNTER                    -- 
            generic map (                                    -- 
                STRIDE          => 1                       , --
                UNROLL          => O_PARAM.SHAPE.C.SIZE    , --
                MAX_LOOP_SIZE   => O_SHAPE.C.MAX_SIZE      , --
                MAX_LOOP_INIT   => 0                         --
            )                                                -- 
            port map (                                       -- 
                CLK             => CLK                     , -- In  :
                RST             => RST                     , -- In  :
                CLR             => CLR                     , -- In  :
                LOOP_START      => c_loop_start            , -- In  :
                LOOP_NEXT       => c_loop_next             , -- In  :
                LOOP_SIZE       => c_loop_size             , -- In  :
                LOOP_DONE       => c_loop_done             , -- Out :
                LOOP_BUSY       => c_loop_busy             , -- Out :
                LOOP_VALID      => c_loop_valid            , -- Out :
                LOOP_FIRST      => c_loop_first            , -- Out :
                LOOP_LAST       => c_loop_last               -- Out :
            );                                               -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        c_loop_next <= '1' when (output_valid = '1' and output_ready = '1') else '0';
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    input_enable <= '1' when (y_input_enable = '1' and x_input_enable = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_READY      <= '1' when (c_loop_busy = '1' and input_enable = '1' and O_READY = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    output_valid <= '1' when (c_loop_busy = '1' and input_enable = '1' and I_VALID = '1') or
                             (c_loop_busy = '1' and input_enable = '0') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_VALID      <= output_valid;
    output_ready <= O_READY;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (y_loop_valid, y_loop_first, y_loop_last, y_input_enable,
             x_loop_valid, x_loop_first, x_loop_last, x_input_enable,
             d_loop_valid, d_loop_first, d_loop_last, 
             c_loop_valid, c_loop_first, c_loop_last, I_DATA, PAD_DATA)
        variable  output_data    :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        variable  y_atrb_vector  :  IMAGE_STREAM_ATRB_VECTOR(0 to O_PARAM.SHAPE.Y.SIZE-1);
        variable  x_atrb_vector  :  IMAGE_STREAM_ATRB_VECTOR(0 to O_PARAM.SHAPE.X.SIZE-1);
        variable  d_atrb_vector  :  IMAGE_STREAM_ATRB_VECTOR(0 to O_PARAM.SHAPE.D.SIZE-1);
        variable  c_atrb_vector  :  IMAGE_STREAM_ATRB_VECTOR(0 to O_PARAM.SHAPE.C.SIZE-1);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (x_input_enable = '1' and y_input_enable = '1') then
            output_data(O_PARAM.DATA.ELEM_FIELD.HI downto O_PARAM.DATA.ELEM_FIELD.LO) := I_DATA;
        else
            output_data(O_PARAM.DATA.ELEM_FIELD.HI downto O_PARAM.DATA.ELEM_FIELD.LO) := PAD_DATA;
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        c_atrb_vector := GENERATE_IMAGE_STREAM_ATRB_VECTOR(c_loop_valid, c_loop_first, c_loop_last);
        d_atrb_vector := GENERATE_IMAGE_STREAM_ATRB_VECTOR(d_loop_valid, d_loop_first, d_loop_last);
        x_atrb_vector := GENERATE_IMAGE_STREAM_ATRB_VECTOR(x_loop_valid, x_loop_first, x_loop_last);
        y_atrb_vector := GENERATE_IMAGE_STREAM_ATRB_VECTOR(y_loop_valid, y_loop_first, y_loop_last);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        SET_ATRB_C_VECTOR_TO_IMAGE_STREAM_DATA(O_PARAM, c_atrb_vector, output_data);
        SET_ATRB_D_VECTOR_TO_IMAGE_STREAM_DATA(O_PARAM, d_atrb_vector, output_data);
        SET_ATRB_X_VECTOR_TO_IMAGE_STREAM_DATA(O_PARAM, x_atrb_vector, output_data);
        SET_ATRB_Y_VECTOR_TO_IMAGE_STREAM_DATA(O_PARAM, y_atrb_vector, output_data);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        O_DATA <= output_data;
    end process;
end RTL;
