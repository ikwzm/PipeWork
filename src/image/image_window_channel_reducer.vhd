-----------------------------------------------------------------------------------
--!     @file    image_window_channel_reducer.vhd
--!     @brief   Image Window Channel Reducer MODULE :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2018/11/22
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
--! @brief   IMAGE_WINDOW_CHANNEL_REDUCER :
--!          異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_CHANNEL_REDUCER is
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
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
    -- 各種制御信号
    -------------------------------------------------------------------------------
        START           : --! @brief START :
                          --! 開始信号.
                          --! * 最初にデータ入力と同時にアサートしても構わない.
                          in  std_logic := '0';
        DONE            : --! @brief DONE :
                          --! 終了信号.
                          --! * この信号をアサートすることで、キューに残っているデータ
                          --!   を掃き出す.
                          in  std_logic := '0';
        BUSY            : --! @brief BUSY :
                          --! ビジー信号.
                          --! * 最初にデータが入力されたときにアサートされる.
                          --! * 最後のデータが出力し終えたらネゲートされる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_ENABLE        : --! @brief INPUT ENABLE :
                          --! 入力許可信号.
                          --! * この信号がアサートされている場合、キューの入力を許可する.
                          --! * この信号がネゲートされている場合、I_READY はアサートされない.
                          in  std_logic := '1';
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
        O_ENABLE        : --! @brief OUTPUT ENABLE :
                          --! 出力許可信号.
                          --! * この信号がアサートされている場合、キューの出力を許可する.
                          --! * この信号がネゲートされている場合、O_VALID はアサートされない.
                          in  std_logic := '1';
        O_DATA          : --! @brief OUTPUT WINDOW DATA :
                          --! ウィンドウデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT WINDOW DATA VALID :
                          --! 出力ウィンドウデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でウィンドウデータがキュー
                          --!   から取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT WINDOW DATA READY :
                          --! 出力ウィンドウデータレディ信号.
                          --! * キューから次のウィンドウデータを取り除く準備が出来て
                          --!   いることを示す.
                          --! * O_VALID='1'and O_READY='1'でウィンドウデータがキュー
                          --!   から取り除かれる.
                          in  std_logic
    );
end IMAGE_WINDOW_CHANNEL_REDUCER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.REDUCER;
architecture RTL of IMAGE_WINDOW_CHANNEL_REDUCER is
    -------------------------------------------------------------------------------
    -- 想定するチャネル数が可変であることを示すフラグ
    -------------------------------------------------------------------------------
    function  GEN_VARIABLE_CHANNEL_SIZE return boolean is
    begin
        return (CHANNEL_SIZE = 0) or
               (CHANNEL_SIZE mod I_PARAM.SHAPE.C.SIZE /= 0) or
               (CHANNEL_SIZE mod O_PARAM.SHAPE.C.SIZE /= 0);
    end function;
    constant  VARIABLE_CHANNEL_SIZE :  boolean := GEN_VARIABLE_CHANNEL_SIZE;
    -------------------------------------------------------------------------------
    -- 最大公約数(Greatest Common Divisor)を求める関数
    -------------------------------------------------------------------------------
    function  gcd(A,B:integer) return integer is
    begin
        if    (A < B) then
            return gcd(B, A);
        elsif (A mod B = 0) then
            return B;
        else
            return gcd(B, A mod B);
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- 内部で一単位として扱うチャネルの数を算出する関数
    -------------------------------------------------------------------------------
    function  CALC_UNIT_CHANNEL_SIZE return integer is
    begin
        if (VARIABLE_CHANNEL_SIZE = TRUE) then
            return 1;
        else
            return gcd(I_PARAM.SHAPE.C.SIZE, O_PARAM.SHAPE.C.SIZE);
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- 内部で一単位として扱うウィンドウパラメータ
    -------------------------------------------------------------------------------
    constant  T_PARAM               :  IMAGE_WINDOW_PARAM_TYPE
                                    := NEW_IMAGE_WINDOW_PARAM(
                                         ELEM_BITS => I_PARAM.ELEM_BITS,
                                         C         => NEW_IMAGE_VECTOR_RANGE(CALC_UNIT_CHANNEL_SIZE),
                                         X         => I_PARAM.SHAPE.X,
                                         Y         => I_PARAM.SHAPE.Y
                                       );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  I_WINDOW_DATA_NUM     :  integer := I_PARAM.SHAPE.C.SIZE / T_PARAM.SHAPE.C.SIZE;
    signal    i_window_data         :  std_logic_vector(I_WINDOW_DATA_NUM*T_PARAM.DATA.SIZE-1 downto 0);
    signal    i_window_strb         :  std_logic_vector(I_WINDOW_DATA_NUM                  -1 downto 0);
    signal    i_window_last         :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  O_WINDOW_DATA_NUM     :  integer := O_PARAM.SHAPE.C.SIZE / T_PARAM.SHAPE.C.SIZE;
    signal    o_window_data         :  std_logic_vector(O_WINDOW_DATA_NUM*T_PARAM.DATA.SIZE-1 downto 0);
    signal    o_window_strb         :  std_logic_vector(O_WINDOW_DATA_NUM                  -1 downto 0);
    signal    o_window_last         :  std_logic;
    constant  o_window_shift        :  std_logic_vector(O_WINDOW_DATA_NUM downto O_WINDOW_DATA_NUM) := "0";
    constant  offset                :  std_logic_vector(O_WINDOW_DATA_NUM-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(I_DATA)
        variable  t_data            :  std_logic_vector(T_PARAM.DATA.SIZE-1 downto 0);
        variable  t_last            :  std_logic;
        variable  t_strb            :  std_logic;
        variable  c_atrb            :  IMAGE_ATRB_TYPE;
    begin
        for i in 0 to I_WINDOW_DATA_NUM-1 loop
            for c_pos in T_PARAM.SHAPE.C.LO to T_PARAM.SHAPE.C.HI loop
                for x_pos in T_PARAM.SHAPE.X.LO to T_PARAM.SHAPE.X.HI loop
                    for y_pos in T_PARAM.SHAPE.Y.LO to T_PARAM.SHAPE.Y.HI loop
                        SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                            PARAM   => T_PARAM,
                            C       => c_pos,
                            X       => x_pos,
                            Y       => y_pos,
                            ELEMENT => GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                           PARAM  => I_PARAM,
                                           C      => c_pos+i*T_PARAM.SHAPE.C.SIZE,
                                           X      => x_pos,
                                           Y      => y_pos,
                                           DATA   => I_DATA),
                            DATA    => t_data
                        );
                    end loop;
                end loop;
            end loop;
            for c_pos in T_PARAM.SHAPE.C.LO to T_PARAM.SHAPE.C.HI loop
                SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                    PARAM    => T_PARAM,
                    C        => c_pos,
                    ATRB     => GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                                    PARAM => I_PARAM,
                                    C     => c_pos+i*T_PARAM.SHAPE.C.SIZE,
                                    DATA  => I_DATA),
                    DATA     => t_data
                );
            end loop;
            for x_pos in T_PARAM.SHAPE.X.LO to T_PARAM.SHAPE.X.HI loop
                SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                    PARAM    => T_PARAM,
                    X        => x_pos,
                    ATRB     => GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                                    PARAM => I_PARAM,
                                    X     => x_pos,
                                    DATA  => I_DATA),
                    DATA     => t_data
                );
            end loop;
            for y_pos in T_PARAM.SHAPE.Y.LO to T_PARAM.SHAPE.Y.HI loop
                SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                    PARAM    => T_PARAM,
                    Y        => y_pos,
                    ATRB     => GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                                    PARAM => I_PARAM,
                                    Y     => y_pos,
                                    DATA  => I_DATA),
                    DATA     => t_data
                );
            end loop;
            i_window_data((i+1)*T_PARAM.DATA.SIZE-1 downto i*T_PARAM.DATA.SIZE) <= t_data;
        end loop;
        if (VARIABLE_CHANNEL_SIZE = TRUE) then
            t_last := '0';
            for i in 0 to I_WINDOW_DATA_NUM-1 loop
                t_strb := '0';
                for c_pos in T_PARAM.SHAPE.C.LO to T_PARAM.SHAPE.C.HI loop
                    c_atrb := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                                  PARAM => I_PARAM,
                                  C     => c_pos+i*T_PARAM.SHAPE.C.SIZE,
                                  DATA  => I_DATA);
                    if c_atrb.VALID then
                        t_strb := '1';
                    end if;
                    if c_atrb.VALID and t_atrb.LAST then
                        t_last := '1';
                    end if;
                end loop;
                i_window_strb(i) <= t_strb;
            end loop;
            i_window_last <= t_last;
        else
            i_window_strb <= (others => '1');
            i_window_last <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    QUEUE: REDUCER                                  -- 
        generic map (                               -- 
            WORD_BITS       => T_PARAM.DATA.SIZE  , -- 
            STRB_BITS       => 1                  , -- 
            I_WIDTH         => I_WINDOW_DATA_NUM  , -- 
            O_WIDTH         => O_WINDOW_DATA_NUM  , -- 
            QUEUE_SIZE      => 0                  , -- 
            VALID_MIN       => 0                  , -- 
            VALID_MAX       => 0                  , --
            O_VAL_SIZE      => O_WINDOW_DATA_NUM  , -- 
            O_SHIFT_MIN     => o_shift'low        , --
            O_SHIFT_MAX     => o_shift'high       , --
            I_JUSTIFIED     => 1                  , -- 
            FLUSH_ENABLE    => 0                    -- 
        )                                           -- 
        port map (                                  -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK                , -- In  :
            RST             => RST                , -- In  :
            CLR             => CLR                , -- In  :
        ---------------------------------------------------------------------------
        -- 各種制御信号
        ---------------------------------------------------------------------------
            START           => START              , -- In  :
            OFFSET          => offset             , -- In  :
            DONE            => DONE               , -- In  :
            FLUSH           => '0'                , -- In  :
            BUSY            => BUSY               , -- Out :
            VALID           => open               , -- Out :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_ENABLE        => I_ENABLE           , -- In  :
            I_STRB          => i_window_strb      , -- In  :
            I_DATA          => i_window_data      , -- In  :
            I_DONE          => i_window_last      , -- In  :
            I_FLUSH         => '0'                , -- In  :
            I_VAL           => I_VALID            , -- In  :
            I_RDY           => I_READY            , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_ENABLE        => O_ENABLE           , -- In  :
            O_DATA          => o_window_data      , -- Out :
            O_STRB          => o_window_strb      , -- Out :
            O_DONE          => o_window_last      , -- Out :
            O_FLUSH         => open               , -- Out :
            O_VAL           => O_VALID            , -- Out :
            O_RDY           => O_READY            , -- In  :
            O_SHIFT         => o_window_shift       -- In  :
    );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(o_window_data, o_window_strb, o_window_last)
        variable  outlet_data       :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        variable  outlet_c_done     :  boolean;
        variable  outlet_c_atrb     :  IMAGE_ATRB_TYPE;
    begin
        for o in 0 to O_WINDOW_DATA_NUM-1 loop
            for c_pos in T_PARAM.SHAPE.C.LO to T_PARAM.SHAPE.C.HI loop
                for x_pos in T_PARAM.SHAPE.X.LO to T_PARAM.SHAPE.X.HI loop
                    for y_pos in T_PARAM.SHAPE.Y.LO tT O_PARAM.SHAPE.Y.HI loop
                        SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                            PARAM   => O_PARAM,
                            C       => c_pos+o*T_PARAM.SHAPE.C.SIZE,
                            X       => x_pos,
                            Y       => y_pos,
                            ELEMENT => GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                           PARAM  => T_PARAM,
                                           C      => c_pos,
                                           X      => x_pos,
                                           Y      => y_pos,
                                           DATA   => o_window_data((o+1)*T_PARAM.DATA.SIZE-1 downto o*T_PARAM.DATA.SIZE)),
                            DATA    => outlet_data
                        );
                    end loop;
                end loop;
            end loop;
        end loop;
        outlet_c_done := FALSE;
        for o in 0 to O_WINDOW_DATA_NUM-1 loop
            for c_pos in T_PARAM.SHAPE.C.LO to T_PARAM.SHAPE.C.HI loop
                outlet_c_atrb := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                                    PARAM => T_PARAM,
                                    C     => c_pos,
                                    DATA  => o_window_data((o+1)*T_PARAM.DATA.SIZE-1 downto o*T_PARAM.DATA.SIZE)
                                 );
                if (VARIABLE_CHANNEL_SIZE = TRUE) then
                    if (outlet_c_done = TRUE) then
                        outlet_c_atrb.VALID := FALSE;
                        outlet_c_atrb.FIRST := FALSE;
                        outlet_c_atrb.LAST  := TRUE;
                    elsif (o_window_strb(o)    = '1'  and o_window_last      = '1' ) and 
                          (outlet_c_atrb.VALID = TRUE and outlet_c_atrb.LAST = TRUE) then
                        outlet_c_done       := TRUE;
                    end if;
                end if;
                SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                    PARAM    => O_PARAM,
                    C        => c_pos+o*T_PARAM.SHAPE.C.SIZE,
                    ATRB     => outlet_c_atrb,
                    DATA     => outlet_data
                );
            end loop;
        end loop;
        for x_pos in T_PARAM.SHAPE.X.LO to T_PARAM.SHAPE.X.HI loop
                SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                    PARAM    => O_PARAM,
                    X        => x_pos,
                    ATRB     => GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                                    PARAM => T_PARAM,
                                    X     => x_pos,
                                    DATA  => o_window_data(T_PARAM.DATA.SIZE-1 downto 0)),
                    DATA     => outlet_data
                );
        end loop;
        for y_pos in T_PARAM.SHAPE.Y.LO to T_PARAM.SHAPE.Y.HI loop
                SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                    PARAM    => O_PARAM,
                    Y        => y_pos,
                    ATRB     => GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                                    PARAM => T_PARAM,
                                    Y     => y_pos,
                                    DATA  => o_window_data(T_PARAM.DATA.SIZE-1 downto 0)),
                    DATA     => outlet_data
                );
        end loop;
        O_DATA <= outlet_data;
    end process;
end RTL;
