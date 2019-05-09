-----------------------------------------------------------------------------------
--!     @file    image_slice_master_controller.vhd
--!     @brief   Image Slice Master Controller Module :
--!              メモリに格納されたイメージのうち、指定された位置の指定されたサイズ
--!              のブロックをスライスしてとりだすためのマスター制御回路.
--!     @version 1.8.0
--!     @date    2019/4/27
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
--! @brief   Image Slice Master Controller :
--!          メモリに格納されたイメージのうち、指定された位置の指定されたサイズの
--!          ブロックをスライスしてとりだすためのマスター制御回路.
-----------------------------------------------------------------------------------
entity  IMAGE_SLICE_MASTER_CONTROLLER is
    generic (
        SOURCE_SHAPE    : --! @brief SOURCE IMAGE SHAPE PARAMETER :
                          --! メモリに格納されているイメージの形(SHAPE)を指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        SLICE_SHAPE     : --! @brief OUTPUT SHAPE PARAMETER :
                          --! 取り出す(Slice)するブロックの大きさを指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        MAX_SLICE_C_POS : --! @brief MAX SLICE C POSITION :
                          integer := 0;
        MAX_SLICE_X_POS : --! @brief MAX SLICE X POSITION :
                          integer := 0;
        MAX_SLICE_Y_POS : --! @brief MAX SLICE Y POSITION :
                          integer := 0;
        ADDR_BITS       : --! @brief ADDRESS BITS :
                          --! REQ_ADDR信号のビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! REQ_SIZE信号のビット数を指定する.
                          integer := 32
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
        SOURCE_C_SIZE   : in  integer range 0 to SOURCE_SHAPE.C.MAX_SIZE := SOURCE_SHAPE.C.SIZE;
        SOURCE_X_SIZE   : in  integer range 0 to SOURCE_SHAPE.X.MAX_SIZE := SOURCE_SHAPE.X.SIZE;
        SOURCE_Y_SIZE   : in  integer range 0 to SOURCE_SHAPE.Y.MAX_SIZE := SOURCE_SHAPE.Y.SIZE;
        SLICE_C_POS     : in  integer range 0 to MAX_SLICE_C_POS         := 0;
        SLICE_X_POS     : in  integer range 0 to MAX_SLICE_X_POS         := 0;
        SLICE_Y_POS     : in  integer range 0 to MAX_SLICE_Y_POS         := 0;
        SLICE_C_SIZE    : in  integer range 0 to SLICE_SHAPE .C.MAX_SIZE := SLICE_SHAPE .C.SIZE;
        SLICE_X_SIZE    : in  integer range 0 to SLICE_SHAPE .X.MAX_SIZE := SLICE_SHAPE .X.SIZE;
        SLICE_Y_SIZE    : in  integer range 0 to SLICE_SHAPE .Y.MAX_SIZE := SLICE_SHAPE .Y.SIZE;
        ELEM_BYTES      : in  integer range 0 to SOURCE_SHAPE.ELEM_BITS/8:= SOURCE_SHAPE.ELEM_BITS/8;
        REQ_ADDR        : in  std_logic_vector(ADDR_BITS-1 downto 0);
        REQ_VALID       : in  std_logic;
        REQ_READY       : out std_logic;
        RES_NONE        : out std_logic;
        RES_ERROR       : out std_logic;
        RES_VALID       : out std_logic;
        RES_READY       : in  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
        MST_ADDR        : out std_logic_vector(ADDR_BITS-1 downto 0);
        MST_SIZE        : out std_logic_vector(SIZE_BITS-1 downto 0);
        MST_FIRST       : out std_logic;
        MST_LAST        : out std_logic;
        MST_START       : out std_logic;
        MST_BUSY        : in  std_logic;
        MST_DONE        : in  std_logic;
        MST_ERROR       : in  std_logic
    );
end IMAGE_SLICE_MASTER_CONTROLLER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.UNROLLED_LOOP_COUNTER;
architecture RTL of IMAGE_SLICE_MASTER_CONTROLLER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  MAX_ELEM_BYTES        :  integer := SOURCE_SHAPE.ELEM_BITS/8;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    y_loop_start          :  std_logic;
    signal    y_loop_next           :  std_logic;
    signal    y_loop_done           :  std_logic;
    signal    y_loop_busy           :  std_logic;
    signal    y_loop_first          :  std_logic;
    signal    y_loop_last           :  std_logic;
    signal    y_loop_term           :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    x_loop_start          :  std_logic;
    signal    x_loop_next           :  std_logic;
    signal    x_loop_done           :  std_logic;
    signal    x_loop_busy           :  std_logic;
    signal    x_loop_first          :  std_logic;
    signal    x_loop_last           :  std_logic;
    signal    x_loop_term           :  std_logic;
    signal    x_loop_size           :  integer range 0 to SLICE_SHAPE.X.MAX_SIZE;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    base_addr             :  std_logic_vector(ADDR_BITS-1 downto 0);
    signal    tran_addr             :  std_logic_vector(ADDR_BITS-1 downto 0);
    signal    tran_bytes            :  integer range 0 to MAX_ELEM_BYTES * SLICE_SHAPE .C.MAX_SIZE * SLICE_SHAPE.X.MAX_SIZE;
    signal    c_slice_bytes         :  integer range 0 to MAX_ELEM_BYTES * SLICE_SHAPE .C.MAX_SIZE;
    signal    channel_bytes         :  integer range 0 to MAX_ELEM_BYTES * SOURCE_SHAPE.C.MAX_SIZE;
    signal    width_size            :  integer range 0 to SOURCE_SHAPE.X.MAX_SIZE;
    signal    width_bytes           :  integer range 0 to SOURCE_SHAPE.X.MAX_SIZE * SOURCE_SHAPE.C.MAX_SIZE * MAX_ELEM_BYTES;
    signal    c_start_addr          :  integer range 0 to ((MAX_SLICE_C_POS                                                    ))* MAX_ELEM_BYTES;
    signal    x_start_addr          :  integer range 0 to ((MAX_SLICE_C_POS                                                    ) +
                                                           (MAX_SLICE_X_POS *                           SOURCE_SHAPE.C.MAX_SIZE))* MAX_ELEM_BYTES;
    signal    start_addr            :  integer range 0 to ((MAX_SLICE_Y_POS * SOURCE_SHAPE.X.MAX_SIZE * SOURCE_SHAPE.C.MAX_SIZE) + 
                                                           (MAX_SLICE_X_POS *                           SOURCE_SHAPE.C.MAX_SIZE) +
                                                           (MAX_SLICE_C_POS                                                    ))* MAX_ELEM_BYTES;
    signal    x_start_pos           :  integer range 0 to MAX_SLICE_X_POS;
    signal    y_start_pos           :  integer range 0 to MAX_SLICE_Y_POS;
    signal    x_continuous          :  boolean;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    type      STATE_TYPE            is ( IDLE_STATE       ,
                                         PREP0_STATE      ,
                                         PREP1_STATE      ,
                                         START_STATE      ,
                                         RUN_STATE        ,
                                         RES_SUCC_STATE   ,
                                         RES_NONE_STATE   ,
                                         RES_ERROR_STATE  );
    signal    state                 :  STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                state          <= IDLE_STATE;
                channel_bytes  <= 0;
                width_size     <= 0;
                width_bytes    <= 0;
                c_start_addr   <= 0;
                x_start_addr   <= 0;
                start_addr     <= 0;
                x_start_pos    <= 0;
                y_start_pos    <= 0;
                x_loop_size    <= 1;
                c_slice_bytes  <= 0;
                tran_bytes     <= 0;
                x_continuous   <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                state          <= IDLE_STATE;
                channel_bytes  <= 0;
                width_size     <= 0;
                width_bytes    <= 0;
                c_start_addr   <= 0;
                x_start_addr   <= 0;
                start_addr     <= 0;
                x_start_pos    <= 0;
                y_start_pos    <= 0;
                x_loop_size    <= 1;
                c_slice_bytes  <= 0;
                tran_bytes     <= 0;
                x_continuous   <= FALSE;
            else
                case state is
                    when IDLE_STATE => 
                        if (REQ_VALID = '1') then
                            state <= PREP0_STATE;
                        else
                            state <= IDLE_STATE;
                        end if;
                        channel_bytes <= SOURCE_C_SIZE * ELEM_BYTES;
                        c_slice_bytes <= SLICE_C_SIZE  * ELEM_BYTES;
                        c_start_addr  <= SLICE_C_POS   * ELEM_BYTES;
                        width_size    <= SOURCE_X_SIZE;
                        x_start_pos   <= SLICE_X_POS;
                        y_start_pos   <= SLICE_Y_POS;
                        x_loop_size   <= SLICE_X_SIZE;
                        x_continuous  <= (SLICE_C_POS = 0 and SLICE_C_SIZE = SOURCE_C_SIZE);
                    when PREP0_STATE =>
                        if (y_loop_term = '1' or x_loop_size = 0) then
                            state <= RES_NONE_STATE;
                        else
                            state <= PREP1_STATE;
                        end if;
                        if (x_continuous = TRUE) then
                            x_loop_size <= 1;
                            tran_bytes  <= x_loop_size * c_slice_bytes;
                        else
                            x_loop_size <= x_loop_size;
                            tran_bytes  <= c_slice_bytes;
                        end if;
                     -- x_start_addr <= SLICE_C_POS*ELEM_BYTES + SLICE_X_POS*(SOURCE_C_SIZE*ELEM_BYTES);
                        x_start_addr <= c_start_addr + x_start_pos * channel_bytes;
                     -- width_bytes  <= SOURCE_X_SIZE * (SOURCE_C_SIZE * ELEM_BYTES);
                        width_bytes  <= width_size    * channel_bytes;              
                    when PREP1_STATE =>
                        state        <= START_STATE;
                     -- start_addr   <= SLICE_C_POS*ELEM_BYTES + SLICE_X_POS*SOURCE_C_SIZE*ELEM_BYTES
                     --              + SLICE_Y_POS * SOURCE_X_SIZE * SOURCE_C_SIZE * ELEM_BYTES;
                        start_addr   <= x_start_addr + y_start_pos * width_bytes;
                    when START_STATE =>
                        state <= RUN_STATE;
                    when RUN_STATE =>
                        if    (y_loop_done = '1' and MST_ERROR = '1') then
                            state <= RES_ERROR_STATE;
                        elsif (y_loop_done = '1' and MST_ERROR = '0') then
                            state <= RES_SUCC_STATE;
                        else
                            state <= RUN_STATE;
                        end if;
                    when RES_SUCC_STATE =>
                        if (RES_READY = '1') then
                            state <= IDLE_STATE;
                        else
                            state <= RES_SUCC_STATE;
                        end if;
                    when RES_ERROR_STATE =>
                        if (RES_READY = '1') then
                            state <= IDLE_STATE;
                        else
                            state <= RES_ERROR_STATE;
                        end if;
                    when RES_NONE_STATE =>
                        if (RES_READY = '1') then
                            state <= IDLE_STATE;
                        else
                            state <= RES_NONE_STATE;
                        end if;
                    when others =>
                        state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REQ_READY <= '1' when (state = IDLE_STATE) else '0';
    RES_VALID <= '1' when (state = RES_SUCC_STATE ) or
                          (state = RES_NONE_STATE ) or
                          (state = RES_ERROR_STATE) else '0';
    RES_ERROR <= '1' when (state = RES_ERROR_STATE) else '0';
    RES_NONE  <= '1' when (state = RES_NONE_STATE ) else '0';
    -------------------------------------------------------------------------------
    -- base_addr : 
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                base_addr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                base_addr <= (others => '0');
            elsif (state = IDLE_STATE and REQ_VALID   = '1') then
                base_addr <= REQ_ADDR;
            elsif (state = START_STATE) then
                base_addr <= std_logic_vector(unsigned(base_addr) + start_addr );
            elsif (state = RUN_STATE  and y_loop_next = '1') then
                base_addr <= std_logic_vector(unsigned(base_addr) + width_bytes);
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    y_loop_start <= '1' when (state = IDLE_STATE and REQ_VALID = '1') else '0';
    y_loop_next  <= '1' when (x_loop_done = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    Y_LOOP_COUNT: UNROLLED_LOOP_COUNTER                      -- 
        generic map (                                        -- 
            MAX_LOOP_SIZE       => SLICE_SHAPE.Y.MAX_SIZE    --
        )                                                    -- 
        port map (                                           -- 
            CLK                 => CLK                     , --  In  :
            RST                 => RST                     , --  In  :
            CLR                 => CLR                     , --  In  :
            LOOP_START          => y_loop_start            , --  In  :
            LOOP_NEXT           => y_loop_next             , --  In  :
            LOOP_SIZE           => SLICE_Y_SIZE            , --  In  :
            LOOP_DONE           => y_loop_done             , --  Out :
            LOOP_BUSY           => y_loop_busy             , --  Out :
            LOOP_FIRST          => y_loop_first            , --  Out :
            LOOP_LAST           => y_loop_last             , --  Out :
            LOOP_TERM           => y_loop_term               --  Out :
        );                                                   -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                x_loop_start <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                x_loop_start <= '0';
            elsif (state = START_STATE) or
                  (state = RUN_STATE and y_loop_last = '0' and y_loop_next = '1' and MST_ERROR = '0') then
                x_loop_start <= '1';
            else
                x_loop_start <= '0';
            end if;
        end if;
    end process;
    x_loop_next  <= '1' when (MST_DONE = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    X_LOOP_COUNT: UNROLLED_LOOP_COUNTER                      -- 
        generic map (                                        -- 
            MAX_LOOP_SIZE       => SLICE_SHAPE.X.MAX_SIZE    --
        )                                                    -- 
        port map (                                           -- 
            CLK                 => CLK                     , --  In  :
            RST                 => RST                     , --  In  :
            CLR                 => CLR                     , --  In  :
            LOOP_START          => x_loop_start            , --  In  :
            LOOP_NEXT           => x_loop_next             , --  In  :
            LOOP_SIZE           => x_loop_size             , --  In  :
            LOOP_DONE           => x_loop_done             , --  Out :
            LOOP_BUSY           => x_loop_busy             , --  Out :
            LOOP_FIRST          => x_loop_first            , --  Out :
            LOOP_LAST           => x_loop_last             , --  Out :
            LOOP_TERM           => x_loop_term               --  Out :
        );                                                   -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                MST_START <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                MST_START <= '0';
            elsif (x_loop_start = '1') or
                  (x_loop_next  = '1' and x_loop_last = '0') then
                MST_START <= '1';
            else
                MST_START <= '0';
            end if;
        end if;
    end process;
    MST_FIRST <= y_loop_first and x_loop_first;
    MST_LAST  <= y_loop_last  and x_loop_last;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                tran_addr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                tran_addr <= (others => '0');
            elsif (x_loop_start = '1') then
                tran_addr <= base_addr;
            elsif (x_loop_next  = '1') then
                tran_addr <= std_logic_vector(unsigned(tran_addr) + channel_bytes);
            end if;
        end if;
    end process;
    MST_ADDR <= tran_addr;
    MST_SIZE <= std_logic_vector(to_unsigned(tran_bytes, SIZE_BITS));
end RTL;
