-----------------------------------------------------------------------------------
--!     @file    image_slice_range_generator.vhd
--!     @brief   Image Slice Range Generator Module :
--!              メモリに格納されたイメージのうち、指定された位置の指定されたサイズ
--!              のブロックをスライスしてとりだすために、読み出す位置、読み出すサイ
--!              ズ、パディングするサイズを生成するモジュール.
--!     @version 1.8.0
--!     @date    2019/4/8
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
--! @brief   Image Slice Range Generator :
--!          メモリに格納されたイメージのうち、指定された位置の指定されたサイズのブ
--!          ロックをスライスしてとりだすために、読み出す位置、読み出すサイズ、パデ
--!          ィングするサイズを生成するモジュール.
-----------------------------------------------------------------------------------
entity  IMAGE_SLICE_RANGE_GENERATOR is
    generic (
        SOURCE_SHAPE        : --! @brief SOURCE IMAGE SHAPE PARAMETER :
                              --! メモリに格納されているイメージの形(SHAPE)を指定する.
                              IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        SLICE_SHAPE         : --! @brief OUTPUT SHAPE PARAMETER :
                              --! 取り出す(Slice)するブロックの大きさを指定する.
                              IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        MIN_SLICE_X_POS     : --! @brief MIN SLICE X POSITION :
                              integer := 0;
        MAX_SLICE_X_POS     : --! @brief MAX SLICE X POSITION :
                              integer := 0;
        MIN_SLICE_Y_POS     : --! @brief MIN SLICE Y POSITION :
                              integer := 0;
        MAX_SLICE_Y_POS     : --! @brief MAX SLICE Y POSITION :
                              integer := 0;
        MAX_PAD_L_SIZE      : --! @brief MAX PADDING LEFT   SIZE :
                              integer := 0;
        MAX_PAD_R_SIZE      : --! @brief MAX PADDING RIGHT  SIZE :
                              integer := 0;
        MAX_PAD_T_SIZE      : --! @brief MAX PADDING TOP    SIZE :
                              integer := 0;
        MAX_PAD_B_SIZE      : --! @brief MAX PADDING BOTTOM SIZE :
                              integer := 0;
        MAX_KERNEL_L_SIZE   : --! @brief MAX KERNEL  LEFT   SIZE :
                              integer := 0;
        MAX_KERNEL_R_SIZE   : --! @brief MAX KERNEL  RIGHT  SIZE :
                              integer := 0;
        MAX_KERNEL_T_SIZE   : --! @brief MAX KERNEL  TOP    SIZE :
                              integer := 0;
        MAX_KERNEL_B_SIZE   : --! @brief MAX KERNEL  BOTTOM SIZE :
                              integer := 0
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK                 : --! @brief CLOCK :
                              --! クロック信号
                              in  std_logic; 
        RST                 : --! @brief ASYNCRONOUSE RESET :
                              --! 非同期リセット信号.アクティブハイ.
                              in  std_logic;
        CLR                 : --! @brief SYNCRONOUSE RESET :
                              --! 同期リセット信号.アクティブハイ.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- 計算に必要な情報
    -- これらの信号の値は計算中は変更してはならない.
    -------------------------------------------------------------------------------
        SOURCE_X_SIZE       : --! @brief INPUT IMAGE X SIZE :
                              --! メモリに格納されたイメージの X 方向の画素数.
                              in  integer range 0 to SOURCE_SHAPE.X.MAX_SIZE := SOURCE_SHAPE.X.SIZE;
        SOURCE_Y_SIZE       : --! @brief INPUT IMAGE Y SIZE :
                              --! メモリに格納されたイメージの Y 方向の画素数.
                              in  integer range 0 to SOURCE_SHAPE.Y.MAX_SIZE := SOURCE_SHAPE.Y.SIZE;
        KERNEL_L_SIZE       : --! @brief KERNEL LEFT   SIZE :
                              --! 畳み込みのために左側(-X方向)に余分に読む画素数.
                              in  integer range 0 to MAX_KERNEL_L_SIZE := 0;
        KERNEL_R_SIZE       : --! @brief KERNEL RIGHT  SIZE :
                              --! 畳み込みのために右側(+X方向)に余分に読む画素数.
                              in  integer range 0 to MAX_KERNEL_R_SIZE := 0;
        KERNEL_T_SIZE       : --! @brief KERNEL TOP    SIZE :
                              --! 畳み込みのために上側(-Y方向)に余分に読む画素数.
                              in  integer range 0 to MAX_KERNEL_T_SIZE := 0;
        KERNEL_B_SIZE       : --! @brief KERNEL BOTTOM SIZE :
                              --! 畳み込みのために下側(+Y方向)に余分に読む画素数.
                              in  integer range 0 to MAX_KERNEL_B_SIZE := 0;
    -------------------------------------------------------------------------------
    -- 計算開始信号
    -------------------------------------------------------------------------------
        REQ_START_X_POS     : --! @brief SLICE IMAGE START X POSITION :
                              --! メモリから読み出す際の X 方向のスタート位置.
                              --! * マージンがある場合はこの値に負の値を指定する.
                              --! * ただし、畳み込みのために左側(-X方向)に余分に読
                              --!   む画素がある場合、マージンからその分引く.
                              --! * 例) start_x_pos <= 0-(margin_left_size - kernel_left_size);
                              in  integer range MIN_SLICE_X_POS to MAX_SLICE_X_POS := MIN_SLICE_X_POS;
        REQ_START_Y_POS     : --! @brief SLICE IMAGE START Y POSITION :
                              --! メモリから読み出す際の Y 方向のスタート位置.
                              --! * マージンがある場合はこの値に負の値を指定する.
                              --! * ただし、畳み込みのために上側(-Y方向)に余分に読
                              --!   む画素がある場合、マージンからその分引く.
                              --! * 例) start_y_pos <= 0-(margin_top_size - kernel_top_size);
                              in  integer range MIN_SLICE_Y_POS to MAX_SLICE_Y_POS := MIN_SLICE_Y_POS;
        REQ_SLICE_X_SIZE    : --! @brief SLICE IMAGE SLICE X SIZE :
                              --! メモリから読み出すイメージの X 方向の画素数.
                              --! * ここで指定する画素数は、畳み込みのために余分に読
                              --!   み込む画素数は含まれない.
                              in  integer range 0 to SLICE_SHAPE.X.MAX_SIZE  := SLICE_SHAPE.X.SIZE;
        REQ_SLICE_Y_SIZE    : --! @brief SLICE IMAGE SLICE Y SIZE :
                              --! メモリから読み出すイメージの Y 方向の画素数.
                              --! * ここで指定する画素数は、畳み込みのために余分に読
                              --!   み込む画素数は含まれない.
                              in  integer range 0 to SLICE_SHAPE.Y.MAX_SIZE  := SLICE_SHAPE.Y.SIZE;
        REQ_VALID           : --! @brief REQUEST VALID :
                              --! 計算開始を要求する信号.
                              in  std_logic;
        REQ_READY           : --! @brief REQUEST READY :
                              --! 計算開始要求に対する応答信号.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- 計算結果
    -------------------------------------------------------------------------------
        RES_START_X_POS     : --! @brief SLICE IMAGE START X POSITION :
                              --! メモリから読み出す際の X 方向のスタート位置.
                              --! * 畳み込みで余分に読む画素分も含む.
                              --! * REQ_START_X_POS が負の場合(左側にマージンがある
                              --!   場合)は、その分は RES_PAD_L_SIZEに回され、
                              --!   RES_START_X_POS は必ず0以上の値になる.
                              out integer range 0 to MAX_SLICE_X_POS;
        RES_START_Y_POS     : --! @brief SLICE IMAGE START Y POSITION :
                              --! メモリから読み出す際の Y 方向のスタート位置.
                              --! * 畳み込みで余分に読む画素分も含む.
                              --! * REQ_START_Y_POS が負の場合(上側にマージンがある
                              --!   場合)は、その分は RES_PAD_T_SIZEに回され、
                              --!   RES_START_Y_POS は必ず0以上の値になる.
                              out integer range 0 to MAX_SLICE_Y_POS;
        RES_SLICE_X_SIZE    : --! @brief SLICE IMAGE SLICE X SIZE :
                              --! メモリから読み出すイメージの X 方向の画素数.
                              --! * 畳み込みで余分に読む画素分も含む.
                              out integer range 0 to SLICE_SHAPE.X.MAX_SIZE;
        RES_SLICE_Y_SIZE    : --! @brief SLICE IMAGE SLICE Y SIZE :
                              --! メモリから読み出すイメージの Y 方向の画素数.
                              --! * 畳み込みで余分に読む画素分も含む.
                              out integer range 0 to SLICE_SHAPE.Y.MAX_SIZE;
        RES_PAD_L_SIZE      : --! @brief PADDING LEFT   SIZE :
                              --! メモリから読み出した後に左側(-X方向)にパディングする画素数.
                              out integer range 0 to MAX_PAD_L_SIZE;
        RES_PAD_R_SIZE      : --! @brief PADDING RIGHT  SIZE :
                              --! メモリから読み出した後に右側(+X方向)にパディングする画素数.
                              out integer range 0 to MAX_PAD_R_SIZE;
        RES_PAD_T_SIZE      : --! @brief PADDING TOP    SIZE :
                              --! メモリから読み出した後に上側(-Y方向)にパディングする画素数.
                              out integer range 0 to MAX_PAD_T_SIZE;
        RES_PAD_B_SIZE      : --! @brief PADDING BOTTOM SIZE :
                              --! メモリから読み出した後に下側(+Y方向)にパディングする画素数.
                              out integer range 0 to MAX_PAD_B_SIZE;
        RES_NEXT_X_POS      : --! @brief SLICE IMAGE END X POSITION :
                              --! メモリから読み出す際の X 方向の次のスタート位置.
                              --! * 畳み込みで余分に読む画素分は含まれない.
                              out integer range MIN_SLICE_X_POS to MAX_SLICE_X_POS;
        RES_NEXT_Y_POS      : --! @brief SLICE IMAGE END Y POSITION :
                              --! メモリから読み出す際の Y 方向の次のスタート位置.
                              --! * 畳み込みで余分に読む画素分は含まれない.
                              out integer range MIN_SLICE_Y_POS to MAX_SLICE_Y_POS;
        RES_VALID           : --! @brief RESPONSE VALID :
                              out std_logic;
        RES_READY           : --! @brief RESPONSE READY :
                              in  std_logic
    );
end IMAGE_SLICE_RANGE_GENERATOR;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
architecture RTL of IMAGE_SLICE_RANGE_GENERATOR is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  MAX(A,B: integer) return integer is
    begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function CALC_SIGNED_BITS(SIZE:integer) return integer is
        variable bits : integer;
    begin
        bits := 1;
        while (2**bits < SIZE) loop
            bits := bits + 1;
        end loop;
        return bits + 1;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  X_START_POS_BITS      :  integer := CALC_SIGNED_BITS(MAX(abs(MIN_SLICE_X_POS),abs(MAX_SLICE_X_POS)));
    constant  X_START_ZERO          :  signed(X_START_POS_BITS-1 downto 0) := (others => '0');
    signal    x_start_pos           :  signed(X_START_POS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  X_END_POS_BITS        :  integer :=  CALC_SIGNED_BITS(MAX_SLICE_X_POS+SLICE_SHAPE.X.MAX_SIZE);
    constant  X_END_ZERO            :  signed(X_END_POS_BITS-1 downto 0) := (others => '0');
    signal    x_end_pos             :  signed(X_END_POS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  Y_START_POS_BITS      :  integer :=  CALC_SIGNED_BITS(MAX(abs(MIN_SLICE_Y_POS),abs(MAX_SLICE_Y_POS)));
    constant  Y_START_ZERO          :  signed(Y_START_POS_BITS-1 downto 0) := (others => '0');
    signal    y_start_pos           :  signed(Y_START_POS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  Y_END_POS_BITS        :  integer :=  CALC_SIGNED_BITS(MAX_SLICE_Y_POS+SLICE_SHAPE.Y.MAX_SIZE);
    constant  Y_END_ZERO            :  signed(Y_END_POS_BITS-1 downto 0) := (others => '0');
    signal    y_end_pos             :  signed(Y_END_POS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    left_pad_size         :  integer range 0 to MAX_PAD_L_SIZE;
    signal    right_pad_size        :  integer range 0 to MAX_PAD_R_SIZE;
    signal    top_pad_size          :  integer range 0 to MAX_PAD_T_SIZE;
    signal    bottom_pad_size       :  integer range 0 to MAX_PAD_B_SIZE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE            is (IDLE_STATE,
                                        PHASE1_STATE,
                                        PHASE2_STATE,
                                        KERNEL1_STATE,
                                        KERNEL2_STATE,
                                        RES_STATE);
    signal    state                 :  STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable  diff_left   :  signed(X_START_POS_BITS-1 downto 0);
        variable  diff_right  :  signed(X_END_POS_BITS  -1 downto 0);
        variable  diff_top    :  signed(Y_START_POS_BITS-1 downto 0);
        variable  diff_bottom :  signed(Y_END_POS_BITS  -1 downto 0);
    begin
        if (RST = '1') then
                state            <= IDLE_STATE;
                x_start_pos      <= X_START_ZERO;
                x_end_pos        <= X_END_ZERO;
                y_start_pos      <= Y_START_ZERO;
                y_end_pos        <= Y_END_ZERO;
                left_pad_size    <= 0;
                right_pad_size   <= 0;
                top_pad_size     <= 0;
                bottom_pad_size  <= 0;
                RES_NEXT_X_POS   <= 0;
                RES_NEXT_Y_POS   <= 0;
                RES_START_X_POS  <= 0;
                RES_START_Y_POS  <= 0;
                RES_SLICE_X_SIZE <= 0;
                RES_SLICE_Y_SIZE <= 0;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                state            <= IDLE_STATE;
                x_start_pos      <= X_START_ZERO;
                x_end_pos        <= X_END_ZERO;
                y_start_pos      <= Y_START_ZERO;
                y_end_pos        <= Y_END_ZERO;
                left_pad_size    <= 0;
                right_pad_size   <= 0;
                top_pad_size     <= 0;
                bottom_pad_size  <= 0;
                RES_NEXT_X_POS   <= 0;
                RES_NEXT_Y_POS   <= 0;
                RES_START_X_POS  <= 0;
                RES_START_Y_POS  <= 0;
                RES_SLICE_X_SIZE <= 0;
                RES_SLICE_Y_SIZE <= 0;
            else
                case state is
                    when IDLE_STATE =>
                        if (REQ_VALID = '1') then
                            state           <= PHASE1_STATE;
                            x_start_pos     <= to_signed(REQ_START_X_POS, X_START_POS_BITS);
                            x_end_pos       <= to_signed(REQ_START_X_POS, X_END_POS_BITS  ) + to_signed(REQ_SLICE_X_SIZE, X_END_POS_BITS);
                            y_start_pos     <= to_signed(REQ_START_Y_POS, Y_START_POS_BITS);
                            y_end_pos       <= to_signed(REQ_START_Y_POS, Y_END_POS_BITS  ) + to_signed(REQ_SLICE_Y_SIZE, Y_END_POS_BITS);
                            left_pad_size   <= 0;
                            right_pad_size  <= 0;
                            top_pad_size    <= 0;
                            bottom_pad_size <= 0;
                        else
                            state           <= IDLE_STATE;
                        end if;
                    when PHASE1_STATE =>
                        state <= PHASE2_STATE;
                        diff_left   := X_START_ZERO - x_start_pos;
                        diff_right  := x_end_pos    - to_signed(SOURCE_X_SIZE, X_END_POS_BITS);
                        diff_top    := Y_START_ZERO - y_start_pos;
                        diff_bottom := y_end_pos    - to_signed(SOURCE_Y_SIZE, Y_END_POS_BITS);
                        if (diff_left   >= 0) then
                            x_start_pos     <= X_START_ZERO;
                            left_pad_size   <= left_pad_size   + to_integer(diff_left);
                        end if;
                        if (diff_right  >= 0) then
                            x_end_pos       <= to_signed(SOURCE_X_SIZE, X_END_POS_BITS);
                            right_pad_size  <= right_pad_size  + to_integer(diff_right);
                        end if;
                        if (diff_top    >= 0) then
                            y_start_pos     <= Y_START_ZERO;
                            top_pad_size    <= top_pad_size    + to_integer(diff_top);
                        end if;
                        if (diff_bottom >= 0) then
                            y_end_pos       <= to_signed(SOURCE_Y_SIZE, Y_END_POS_BITS);
                            bottom_pad_size <= bottom_pad_size + to_integer(diff_bottom);
                        end if;
                    when PHASE2_STATE =>
                        RES_NEXT_X_POS <= to_integer(x_end_pos);
                        RES_NEXT_Y_POS <= to_integer(y_end_pos);
                        if (MAX_KERNEL_L_SIZE = 0 and MAX_KERNEL_R_SIZE = 0 and MAX_KERNEL_T_SIZE = 0 and MAX_KERNEL_B_SIZE = 0) then
                            state <= RES_STATE;
                            RES_START_X_POS  <= to_integer(x_start_pos);
                            RES_SLICE_X_SIZE <= to_integer(x_end_pos - x_start_pos);
                            RES_START_Y_POS  <= to_integer(y_start_pos);
                            RES_SLICE_Y_SIZE <= to_integer(y_end_pos - y_start_pos);
                        else
                            state <= KERNEL1_STATE;
                            x_start_pos <= x_start_pos - to_signed(KERNEL_L_SIZE, X_START_POS_BITS);
                            x_end_pos   <= x_end_pos   + to_signed(KERNEL_R_SIZE, X_END_POS_BITS  );
                            y_start_pos <= y_start_pos - to_signed(KERNEL_T_SIZE, Y_START_POS_BITS);
                            y_end_pos   <= y_end_pos   + to_signed(KERNEL_B_SIZE, Y_END_POS_BITS  );
                        end if;
                    when KERNEL1_STATE =>
                        state <= KERNEL2_STATE;
                        diff_left   := X_START_ZERO - x_start_pos;
                        diff_right  := x_end_pos    - to_signed(SOURCE_X_SIZE, X_END_POS_BITS);
                        diff_top    := Y_START_ZERO - y_start_pos;
                        diff_bottom := y_end_pos    - to_signed(SOURCE_Y_SIZE, Y_END_POS_BITS);
                        if (diff_left   >= 0) then
                            x_start_pos     <= X_START_ZERO;
                            left_pad_size   <= left_pad_size   + to_integer(diff_left);
                        end if;
                        if (diff_right  >= 0) then
                            x_end_pos       <= to_signed(SOURCE_X_SIZE, X_END_POS_BITS);
                            right_pad_size  <= right_pad_size  + to_integer(diff_right);
                        end if;
                        if (diff_top    >= 0) then
                            y_start_pos     <= Y_START_ZERO;
                            top_pad_size    <= top_pad_size    + to_integer(diff_top);
                        end if;
                        if (diff_bottom >= 0) then
                            y_end_pos       <= to_signed(SOURCE_Y_SIZE, Y_END_POS_BITS);
                            bottom_pad_size <= bottom_pad_size + to_integer(diff_bottom);
                        end if;
                    when KERNEL2_STATE =>
                        state <= RES_STATE;
                        RES_START_X_POS  <= to_integer(x_start_pos);
                        RES_SLICE_X_SIZE <= to_integer(x_end_pos - x_start_pos);
                        RES_START_Y_POS  <= to_integer(y_start_pos);
                        RES_SLICE_Y_SIZE <= to_integer(y_end_pos - y_start_pos);
                    when RES_STATE   =>
                        if (RES_READY = '1') then
                            state <= IDLE_STATE;
                        else
                            state <= RES_STATE;
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
    REQ_READY      <= '1' when (state = IDLE_STATE) else '0';
    RES_VALID      <= '1' when (state = RES_STATE ) else '0';
    RES_PAD_L_SIZE <= left_pad_size  ;
    RES_PAD_R_SIZE <= right_pad_size ;
    RES_PAD_T_SIZE <= top_pad_size   ;
    RES_PAD_B_SIZE <= bottom_pad_size;
end RTL;
