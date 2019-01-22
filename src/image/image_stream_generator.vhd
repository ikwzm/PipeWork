-----------------------------------------------------------------------------------
--!     @file    image_stream_generator.vhd
--!     @brief   Image Stream Generator Module
--!     @version 1.8.0
--!     @date    2019/1/21
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
--! @brief   IMAGE_STREAM_GENERATOR :
--!          入力データに対してイメージストリームの属性を付加して出力する.
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_GENERATOR is
    generic (
        O_PARAM         : --! @brief OUTPUT IMAGE STREAM PARAMETER :
                          --! 出力側イメージストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(32,1,1,1);
        I_DATA_BITS     : --! @brief INPUT  STREAM DATA BIT SIZE :
                          --! 入力側のデータのビット幅を指定する.
                          --! * I_DATA_BITS = O_PARAM.DATA.ELEM_FIELD.SIZE でなけれ
                          --!   ばならない.
                          integer := 32;
        MAX_C_SIZE      : --! @brief MAX CHANNEL SIZE :
                          integer := 1;
        MAX_X_SIZE      : --! @brief MAX X SIZE :
                          integer := 1;
        MAX_Y_SIZE      : --! @brief MAX Y SIZE :
                          integer := 1
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
    -- SHAPE SIZE I/F
    -------------------------------------------------------------------------------
        START           : --! @brief STREAM START :
                          in  std_logic;
        BUSY            : --! @brief STREAM BUSY :
                          out std_logic;
        DONE            : --! @brief STREAM DONE :
                          out std_logic;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_C_SIZE := 1;
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to MAX_X_SIZE := 1;
        Y_SIZE          : --! @brief INPUT Y SIZE :
                          in  integer range 0 to MAX_Y_SIZE := 1;
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
end IMAGE_STREAM_GENERATOR;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_ATRB_GENERATOR;
architecture RTL of IMAGE_STREAM_GENERATOR is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    y_loop_start          :  std_logic;
    signal    y_loop_next           :  std_logic;
    signal    y_loop_busy           :  std_logic;
    signal    y_loop_term           :  std_logic;
    signal    y_loop_done           :  std_logic;
    signal    y_loop_first          :  std_logic;
    signal    y_loop_last           :  std_logic;
    signal    y_atrb_vector         :  IMAGE_STREAM_ATRB_VECTOR(O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    x_loop_start          :  std_logic;
    signal    x_loop_next           :  std_logic;
    signal    x_loop_busy           :  std_logic;
    signal    x_loop_term           :  std_logic;
    signal    x_loop_done           :  std_logic;
    signal    x_loop_first          :  std_logic;
    signal    x_loop_last           :  std_logic;
    signal    x_atrb_vector         :  IMAGE_STREAM_ATRB_VECTOR(O_PARAM.SHAPE.X.LO to O_PARAM.SHAPE.X.HI);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    c_loop_start          :  std_logic;
    signal    c_loop_next           :  std_logic;
    signal    c_loop_busy           :  std_logic;
    signal    c_loop_term           :  std_logic;
    signal    c_loop_done           :  std_logic;
    signal    c_loop_first          :  std_logic;
    signal    c_loop_last           :  std_logic;
    signal    c_atrb_vector         :  IMAGE_STREAM_ATRB_VECTOR(O_PARAM.SHAPE.C.LO to O_PARAM.SHAPE.C.HI);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    io_enable             :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- y_loop_start :
    -- BUSY         :
    -- DONE         :
    -------------------------------------------------------------------------------
    y_loop_start <= '1' when (START       = '1') else '0';
    BUSY         <= '1' when (y_loop_busy = '1') else '0';
    DONE         <= '1' when (y_loop_done = '1') else '0';
    -------------------------------------------------------------------------------
    -- Y LOOP
    -------------------------------------------------------------------------------
    Y_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ATRB_GEN: IMAGE_STREAM_ATRB_GENERATOR
            generic map (
                ATRB_SIZE       => O_PARAM.SHAPE.Y.SIZE, -- 
                STRIDE          => O_PARAM.STRIDE.Y    , --   
                MAX_SIZE        => MAX_Y_SIZE            --   
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- : In  :
                RST             => RST                 , -- : In  :
                CLR             => CLR                 , -- : In  :
                LOAD            => y_loop_start        , -- : In  :
                CHOP            => y_loop_next         , -- : In  :
                SIZE            => Y_SIZE              , -- : In  :
                ATRB            => y_atrb_vector       , -- : Out :
                START           => y_loop_first        , -- : Out :
                LAST            => y_loop_last         , -- : Out :
                TERM            => open                  -- : Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- y_loop_next  :
        ---------------------------------------------------------------------------
        y_loop_next  <= '1' when (x_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- y_loop_done  :
        ---------------------------------------------------------------------------
        y_loop_done  <= '1' when (y_loop_busy = '1' and y_loop_term = '1') or
                                 (y_loop_busy = '1' and y_loop_next = '1' and y_loop_last = '1') else '0';
        ---------------------------------------------------------------------------
        -- x_loop_busy  :
        -- x_loop_term  :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin 
            if (RST = '1') then
                    y_loop_busy <= '0';
                    y_loop_term <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    y_loop_busy <= '0';
                    y_loop_term <= '0';
                elsif (y_loop_start = '1') then
                    if (Y_SIZE = 0) then
                        y_loop_busy <= '1';
                        y_loop_term <= '1';
                    else
                        y_loop_busy <= '1';
                        y_loop_term <= '0';
                    end if;
                elsif (y_loop_busy  = '1') then
                    if (y_loop_done = '1') then
                        y_loop_busy <= '0';
                        y_loop_term <= '0';
                    else
                        y_loop_busy <= '1';
                        y_loop_term <= '0';
                    end if;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- x_loop_start : 
        ---------------------------------------------------------------------------
        x_loop_start <= '1' when (y_loop_start = '1' and Y_SIZE     /=  0 ) or
                                 (y_loop_next  = '1' and y_loop_last = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- X LOOP
    -------------------------------------------------------------------------------
    X_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ATRB_GEN: IMAGE_STREAM_ATRB_GENERATOR
            generic map (
                ATRB_SIZE       => O_PARAM.SHAPE.X.SIZE, -- 
                STRIDE          => O_PARAM.STRIDE.X    , --   
                MAX_SIZE        => MAX_X_SIZE            --   
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
        -- x_loop_next  :
        ---------------------------------------------------------------------------
        x_loop_next  <= '1' when (c_loop_done  = '1') else '0';
        ---------------------------------------------------------------------------
        -- x_loop_done  :
        ---------------------------------------------------------------------------
        x_loop_done  <= '1' when (x_loop_busy = '1' and x_loop_term = '1') or
                                 (x_loop_busy = '1' and x_loop_next = '1' and x_loop_last = '1') else '0';
        ---------------------------------------------------------------------------
        -- x_loop_busy  :
        -- x_loop_term  :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin 
            if (RST = '1') then
                    x_loop_busy <= '0';
                    x_loop_term <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    x_loop_busy <= '0';
                    x_loop_term <= '0';
                elsif (x_loop_start = '1') then
                    if (X_SIZE = 0) then
                        x_loop_busy <= '1';
                        x_loop_term <= '1';
                    else
                        x_loop_busy <= '1';
                        x_loop_term <= '0';
                    end if;
                elsif (x_loop_busy  = '1') then
                    if (x_loop_done = '1') then
                        x_loop_busy <= '0';
                        x_loop_term <= '0';
                    else
                        x_loop_busy <= '1';
                        x_loop_term <= '0';
                    end if;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- c_loop_start : 
        ---------------------------------------------------------------------------
        c_loop_start <= '1' when (x_loop_start = '1' and X_SIZE      /= 0 ) or
                                 (x_loop_next  = '1' and x_loop_last = '0') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- C LOOP
    -------------------------------------------------------------------------------
    C_LOOP: block
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ATRB_GEN: IMAGE_STREAM_ATRB_GENERATOR            -- 
            generic map (                                -- 
                ATRB_SIZE       => O_PARAM.SHAPE.C.SIZE, -- 
                STRIDE          => O_PARAM.SHAPE.C.SIZE, --   
                MAX_SIZE        => MAX_C_SIZE            --   
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- : In  :
                RST             => RST                 , -- : In  :
                CLR             => CLR                 , -- : In  :
                LOAD            => c_loop_start        , -- : In  :
                CHOP            => c_loop_next         , -- : In  :
                SIZE            => C_SIZE              , -- : In  :
                ATRB            => c_atrb_vector       , -- : Out :
                START           => c_loop_first        , -- : Out :
                LAST            => c_loop_last         , -- : Out :
                TERM            => open                  -- : Out :
            );                                           -- 
        ---------------------------------------------------------------------------
        -- c_loop_next  :
        ---------------------------------------------------------------------------
        c_loop_next  <= '1' when (io_enable = '1' and I_VALID = '1' and O_READY = '1') else '0';
        ---------------------------------------------------------------------------
        -- c_loop_done  :
        ---------------------------------------------------------------------------
        c_loop_done  <= '1' when (c_loop_busy = '1' and c_loop_term = '1') or
                                 (c_loop_busy = '1' and c_loop_next = '1' and c_loop_last = '1') else '0';
        ---------------------------------------------------------------------------
        -- c_loop_busy  :
        -- c_loop_term  :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin 
            if (RST = '1') then
                    io_enable   <= '0';
                    c_loop_busy <= '0';
                    c_loop_term <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    io_enable   <= '0';
                    c_loop_busy <= '0';
                    c_loop_term <= '0';
                elsif (c_loop_start = '1') then
                    if (C_SIZE = 0) then
                        io_enable   <= '0';
                        c_loop_busy <= '1';
                        c_loop_term <= '1';
                    else
                        io_enable   <= '1';
                        c_loop_busy <= '1';
                        c_loop_term <= '0';
                    end if;
                elsif (c_loop_busy  = '1') then
                    if (c_loop_done = '1') then
                        io_enable   <= '0';
                        c_loop_busy <= '0';
                        c_loop_term <= '0';
                    else
                        io_enable   <= '0';
                        c_loop_busy <= '1';
                        c_loop_term <= '0';
                    end if;
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_READY <= '1' when (io_enable = '1' and O_READY = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_VALID <= '1' when (io_enable = '1' and I_VALID = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (I_DATA, c_atrb_vector, x_atrb_vector, y_atrb_vector)
        variable  data :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    begin
        data(O_PARAM.DATA.ELEM_FIELD.HI downto O_PARAM.DATA.ELEM_FIELD.LO) := I_DATA;
        for c_pos in O_PARAM.SHAPE.C.LO to O_PARAM.SHAPE.C.HI loop
            SET_ATRB_C_TO_IMAGE_STREAM_DATA(O_PARAM, c_pos, c_atrb_vector(c_pos), data);
        end loop;
        for x_pos in O_PARAM.SHAPE.X.LO to O_PARAM.SHAPE.X.HI loop
            SET_ATRB_X_TO_IMAGE_STREAM_DATA(O_PARAM, x_pos, x_atrb_vector(x_pos), data);
        end loop;
        for y_pos in O_PARAM.SHAPE.Y.LO to O_PARAM.SHAPE.Y.HI loop
            SET_ATRB_Y_TO_IMAGE_STREAM_DATA(O_PARAM, y_pos, y_atrb_vector(y_pos), data);
        end loop;
        O_DATA <= data;
    end process;
end RTL;
