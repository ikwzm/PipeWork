-----------------------------------------------------------------------------------
--!     @file    image_window_channel_reducer.vhd
--!     @brief   Image Window Channel Reducer MODULE :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2018/1/6
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
        C_SIZE          : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! * C_SIZE に 0 を指定すると I_PARAM.SHAPE.C.SIZE と
                          --!   O_PARAM.SHAPE.C.SIZE の最大公約数がチャネル数に設定
                          --!   される.
                          --! * C_SIZE に 1 以上を指定した場合、チャネル数は C_SIZE
                          --!   の値に設定される. ただし、C_SIZE は I_PARAM.SHAPE.C.SIZE
                          --!   と O_PARAM.SHAPE.C.SIZE の最大公約数でなければならない.
                          --!   C_SIZE が I_PARAM.SHAPE.C.SIZE と O_PARAM.SHAPE.C.SIZE
                          --!   の最大公約数でない場合はチャネル数は 1 に設定される.
                          integer := 0;
        C_DONE          : --! @brief CHANNEL DONE MODE :
                          --! キューに入れるデータをチャネル毎に区切るか否かを指定する.
                          --! * C_DONE = 0 を指定すると、データは区切りなく入力する
                          --!   事ができる.但し、出力側でチャネルの区切って出力する
                          --!   ので回路が少し増える.
                          --! * C_DONE = 1 を指定すると、チャネルの最後のデータが入
                          --!   力されると、キューに残っているデータを掃き出すまで、
                          --!   一旦、データの入力を停止する.
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
        I_DONE          : --! @brief INPUT WINDOW DONE :
                          --! 最終ウィンドウ信号入力.
                          --! * 最後のウィンドウデータ入力であることを示すフラグ.
                          --! * 基本的にはDONE信号と同じ働きをするが、I_DONE信号は
                          --!   最後のウィンドウデータを入力する際に同時にアサートする.
                          --! * 最後のウィンドウデータ入力は必ず最後のチャネルを含んで
                          --!   いなければならない.
                          in  std_logic := '0';
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
        O_DONE          : --! @brief OUTPUT WORD DONE :
                          --! 最終ウィンドウ信号出力.
                          --! * 最後のウィンドウ出力であることを示すフラグ.
                          out std_logic;
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
    function  CALC_CHANNEL_SIZE return integer is
    begin
        if    (C_SIZE = 0) then
            return gcd(I_PARAM.SHAPE.C.SIZE, O_PARAM.SHAPE.C.SIZE);
        elsif (I_PARAM.SHAPE.C.SIZE mod C_SIZE = 0) and
              (O_PARAM.SHAPE.C.SIZE mod C_SIZE = 0) then
            return C_SIZE;
        else
            return 1;
        end if;
    end function;
    constant  CHANNEL_SIZE          :  integer := CALC_CHANNEL_SIZE;
    -------------------------------------------------------------------------------
    -- 内部で一単位として扱うウィンドウパラメータ
    -------------------------------------------------------------------------------
    constant  U_PARAM               :  IMAGE_WINDOW_PARAM_TYPE
                                    := NEW_IMAGE_WINDOW_PARAM(
                                         ELEM_BITS => I_PARAM.ELEM_BITS,
                                         INFO_BITS => I_PARAM.INFO_BITS,
                                         C         => NEW_IMAGE_VECTOR_RANGE(CHANNEL_SIZE),
                                         X         => I_PARAM.SHAPE.X,
                                         Y         => I_PARAM.SHAPE.Y
                                       );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  I_WINDOW_DATA_NUM     :  integer := I_PARAM.SHAPE.C.SIZE / U_PARAM.SHAPE.C.SIZE;
    signal    i_window_data         :  std_logic_vector(I_WINDOW_DATA_NUM*U_PARAM.DATA.SIZE-1 downto 0);
    signal    i_window_strb         :  std_logic_vector(I_WINDOW_DATA_NUM                  -1 downto 0);
    signal    i_window_last         :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  O_WINDOW_DATA_NUM     :  integer := O_PARAM.SHAPE.C.SIZE / U_PARAM.SHAPE.C.SIZE;
    signal    o_window_data         :  std_logic_vector(O_WINDOW_DATA_NUM*U_PARAM.DATA.SIZE-1 downto 0);
    signal    o_window_shift        :  std_logic_vector(O_WINDOW_DATA_NUM-1 downto 0);
    constant  offset                :  std_logic_vector(O_WINDOW_DATA_NUM-1 downto 0) := (others => '0');
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(I_DATA, I_DONE)
        variable  t_data            :  std_logic_vector(U_PARAM.DATA.SIZE-1 downto 0);
        variable  t_strb            :  std_logic;
        variable  c_atrb            :  IMAGE_ATRB_TYPE;
        variable  x_atrb            :  IMAGE_ATRB_TYPE;
        variable  y_atrb            :  IMAGE_ATRB_TYPE;
    begin
        for i in 0 to I_WINDOW_DATA_NUM-1 loop
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                for x_pos in U_PARAM.SHAPE.X.LO to U_PARAM.SHAPE.X.HI loop
                    for y_pos in U_PARAM.SHAPE.Y.LO to U_PARAM.SHAPE.Y.HI loop
                        SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                            PARAM   => U_PARAM,
                            C       => c_pos,
                            X       => x_pos,
                            Y       => y_pos,
                            ELEMENT => GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                           PARAM  => I_PARAM,
                                           C      => c_pos+i*U_PARAM.SHAPE.C.SIZE,
                                           X      => x_pos,
                                           Y      => y_pos,
                                           DATA   => I_DATA),
                            DATA    => t_data
                        );
                    end loop;
                end loop;
            end loop;
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                c_atrb := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                              PARAM => I_PARAM,
                              C     => c_pos+i*U_PARAM.SHAPE.C.SIZE,
                              DATA  => I_DATA
                          );
                SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                              PARAM => U_PARAM,
                              C     => c_pos,
                              ATRB  => c_atrb,
                              DATA  => t_data
                );
            end loop;
            for x_pos in U_PARAM.SHAPE.X.LO to U_PARAM.SHAPE.X.HI loop
                x_atrb := GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                              PARAM => I_PARAM,
                              X     => x_pos,
                              DATA  => I_DATA
                          );
                SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                              PARAM => U_PARAM,
                              X     => x_pos,
                              ATRB  => x_atrb,
                              DATA  => t_data
                );
            end loop;
            for y_pos in U_PARAM.SHAPE.Y.LO to U_PARAM.SHAPE.Y.HI loop
                y_atrb := GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                              PARAM => I_PARAM,
                              Y     => y_pos,
                              DATA  => I_DATA
                          );
                SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                              PARAM => U_PARAM,
                              Y     => y_pos,
                              ATRB  => y_atrb,
                              DATA  => t_data
                );
            end loop;
            if (I_PARAM.INFO_BITS > 0) then
                t_data(U_PARAM.DATA.INFO_FIELD.HI downto U_PARAM.DATA.INFO_FIELD.LO) := I_DATA(I_PARAM.DATA.INFO_FIELD.HI downto I_PARAM.DATA.INFO_FIELD.LO);
            end if;
            i_window_data((i+1)*U_PARAM.DATA.SIZE-1 downto i*U_PARAM.DATA.SIZE) <= t_data;
        end loop;
        for i in 0 to I_WINDOW_DATA_NUM-1 loop
            t_strb := '0';
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                c_atrb := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                              PARAM => I_PARAM,
                              C     => c_pos+i*U_PARAM.SHAPE.C.SIZE,
                              DATA  => I_DATA
                          );
                if c_atrb.VALID then
                     t_strb := t_strb or '1';
                end if;
                i_window_strb(i) <= t_strb;
            end loop;
        end loop;
        if (C_DONE /= 0 and IMAGE_WINDOW_DATA_IS_LAST_C(I_PARAM, I_DATA, TRUE)) or
           (I_DONE = '1') then
            i_window_last <= '1';
        else
            i_window_last <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    QUEUE: REDUCER                                  -- 
        generic map (                               -- 
            WORD_BITS       => U_PARAM.DATA.SIZE  , -- 
            STRB_BITS       => 1                  , -- 
            I_WIDTH         => I_WINDOW_DATA_NUM  , -- 
            O_WIDTH         => O_WINDOW_DATA_NUM  , -- 
            QUEUE_SIZE      => 0                  , -- 
            VALID_MIN       => 0                  , -- 
            VALID_MAX       => 0                  , --
            O_VAL_SIZE      => O_WINDOW_DATA_NUM  , -- 
            O_SHIFT_MIN     => o_window_shift'low , --
            O_SHIFT_MAX     => o_window_shift'high, --
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
            O_STRB          => open               , -- Out :
            O_DONE          => O_DONE             , -- Out :
            O_FLUSH         => open               , -- Out :
            O_VAL           => O_VALID            , -- Out :
            O_RDY           => O_READY            , -- In  :
            O_SHIFT         => o_window_shift       -- In  :
    );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(o_window_data)
        variable  outlet_data   :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        variable  channel_over  :  boolean;
        variable  o_shift       :  std_logic_vector(o_window_shift'range);
        variable  c_atrb        :  IMAGE_ATRB_TYPE;
        variable  x_atrb        :  IMAGE_ATRB_TYPE;
        variable  y_atrb        :  IMAGE_ATRB_TYPE;
    begin
        for o in 0 to O_WINDOW_DATA_NUM-1 loop
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                for x_pos in U_PARAM.SHAPE.X.LO to U_PARAM.SHAPE.X.HI loop
                    for y_pos in U_PARAM.SHAPE.Y.LO to U_PARAM.SHAPE.Y.HI loop
                        SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                            PARAM   => O_PARAM,
                            C       => c_pos+o*U_PARAM.SHAPE.C.SIZE,
                            X       => x_pos,
                            Y       => y_pos,
                            ELEMENT => GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                           PARAM  => U_PARAM,
                                           C      => c_pos,
                                           X      => x_pos,
                                           Y      => y_pos,
                                           DATA   => o_window_data((o+1)*U_PARAM.DATA.SIZE-1 downto o*U_PARAM.DATA.SIZE)),
                            DATA    => outlet_data
                        );
                    end loop;
                end loop;
            end loop;
        end loop;
        channel_over := FALSE;
        for o in 0 to O_WINDOW_DATA_NUM-1 loop
            if (channel_over = TRUE) then
                c_atrb.VALID := FALSE;
                c_atrb.START := FALSE;
                c_atrb.LAST  := TRUE;
                for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                    SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                        PARAM => O_PARAM,
                        C     => c_pos+o*U_PARAM.SHAPE.C.SIZE,
                        ATRB  => c_atrb,
                        DATA  => outlet_data
                    );
                end loop;
                o_shift(o) := '0';
            else
                for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                    c_atrb := GET_ATRB_C_FROM_IMAGE_WINDOW_DATA(
                                  PARAM => U_PARAM,
                                  C     => c_pos,
                                  DATA  => o_window_data((o+1)*U_PARAM.DATA.SIZE-1 downto o*U_PARAM.DATA.SIZE)
                              );
                    SET_ATRB_C_TO_IMAGE_WINDOW_DATA(
                        PARAM => O_PARAM,
                        C     => c_pos+o*U_PARAM.SHAPE.C.SIZE,
                        ATRB  => c_atrb,
                        DATA  => outlet_data
                    );
                    if (c_pos = U_PARAM.SHAPE.C.HI) then
                        channel_over := (c_atrb.LAST = TRUE);
                    end if;
                end loop;
                o_shift(o) := '1';
            end if;
        end loop;
        for x_pos in U_PARAM.SHAPE.X.LO to U_PARAM.SHAPE.X.HI loop
                x_atrb := GET_ATRB_X_FROM_IMAGE_WINDOW_DATA(
                              PARAM => U_PARAM,
                              X     => x_pos,
                              DATA  => o_window_data(U_PARAM.DATA.SIZE-1 downto 0)
                          );
                SET_ATRB_X_TO_IMAGE_WINDOW_DATA(
                    PARAM => O_PARAM,
                    X     => x_pos,
                    ATRB  => x_atrb,
                    DATA  => outlet_data
                );
        end loop;
        for y_pos in U_PARAM.SHAPE.Y.LO to U_PARAM.SHAPE.Y.HI loop
                y_atrb := GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                              PARAM => U_PARAM,
                              Y     => y_pos,
                              DATA  => o_window_data(U_PARAM.DATA.SIZE-1 downto 0)
                          );
                SET_ATRB_Y_TO_IMAGE_WINDOW_DATA(
                    PARAM => O_PARAM,
                    Y     => y_pos,
                    ATRB  => y_atrb,
                    DATA  => outlet_data
                );
        end loop;
        if (U_PARAM.INFO_BITS > 0) then
            outlet_data(O_PARAM.DATA.INFO_FIELD.HI downto O_PARAM.DATA.INFO_FIELD.LO) := o_window_data(U_PARAM.DATA.INFO_FIELD.HI downto U_PARAM.DATA.INFO_FIELD.LO);
        end if;
        O_DATA <= outlet_data;
        if (C_DONE = 0) then
            o_window_shift <= o_shift;
        else
            o_window_shift <= (others => '1');
        end if;
    end process;
end RTL;
