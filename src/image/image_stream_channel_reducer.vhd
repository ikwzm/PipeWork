-----------------------------------------------------------------------------------
--!     @file    image_stream_channel_reducer.vhd
--!     @brief   Image Stream Channel Reducer MODULE :
--!              異なるチャネル数のイメージストリームを継ぐためのアダプタ
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
--! @brief   IMAGE_STREAM_CHANNEL_REDUCER :
--!          異なるチャネル数のイメージストリームを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_CHANNEL_REDUCER is
    generic (
        I_PARAM         : --! @brief INPUT  STREAM PARAMETER :
                          --! 入力側のイメージストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のイメージストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
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
        I_DATA          : --! @brief INPUT IMAGE STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_DONE          : --! @brief INPUT IMAGE STREAM DONE :
                          --! 最終ストリーム信号入力.
                          --! * 最後のストリームデータ入力であることを示すフラグ.
                          --! * 基本的にはDONE信号と同じ働きをするが、I_DONE信号は
                          --!   最後のストリームデータを入力する際に同時にアサートする.
                          --! * 最後のストリームデータ入力は必ず最後のチャネルを含んで
                          --!   いなければならない.
                          in  std_logic := '0';
        I_VALID         : --! @brief INPUT IMAGE STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT IMAGE STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
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
        O_DATA          : --! @brief OUTPUT IMAGE STREAM DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_DONE          : --! @brief OUTPUT IMAGE STREAM DONE :
                          --! 最終ストリーム信号出力.
                          --! * 最後のストリーム出力であることを示すフラグ.
                          out std_logic;
        O_VALID         : --! @brief OUTPUT IMAGE STREAM DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でストリームデータがキュー
                          --!   から取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE STREAM DATA READY :
                          --! 出力ストリームデータレディ信号.
                          --! * キューから次のストリームデータを取り除く準備が出来て
                          --!   いることを示す.
                          --! * O_VALID='1'and O_READY='1'でストリームデータがキュー
                          --!   から取り除かれる.
                          in  std_logic
    );
end IMAGE_STREAM_CHANNEL_REDUCER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
architecture RTL of IMAGE_STREAM_CHANNEL_REDUCER is
    -------------------------------------------------------------------------------
    --! @brief 各種内部パラメータ
    -------------------------------------------------------------------------------
    constant  QUEUE_SIZE    :  integer   :=  0 ;
    constant  I_JUSTIFIED   :  integer   :=  1 ;
    constant  FLUSH_ENABLE  :  integer   :=  0 ;
    constant  FLUSH         :  std_logic := '0';
    constant  I_FLUSH       :  std_logic := '0';
    -------------------------------------------------------------------------------
    --! @brief 最大公約数(Greatest Common Divisor)を求める関数
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
    --! @brief 内部で一単位として扱うチャネルの数を算出する関数
    -------------------------------------------------------------------------------
    function  CALC_CHANNEL_SIZE(SIZE: integer) return integer is
    begin
        if    (SIZE = 0) then
            return gcd(I_PARAM.SHAPE.C.SIZE, O_PARAM.SHAPE.C.SIZE);
        elsif (I_PARAM.SHAPE.C.SIZE mod SIZE = 0) and
              (O_PARAM.SHAPE.C.SIZE mod SIZE = 0) then
            return SIZE;
        else
            return 1;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 内部で一単位として扱うチャネルの数
    -------------------------------------------------------------------------------
    constant  CHANNEL_SIZE  :  integer := CALC_CHANNEL_SIZE(C_SIZE);
    -------------------------------------------------------------------------------
    --! @brief 整数の最小値を求める関数.
    -------------------------------------------------------------------------------
    function  minimum(L,R : integer) return integer is
    begin
        if (L < R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- 内部で一単位として扱うストリームパラメータ
    -------------------------------------------------------------------------------
    constant  U_PARAM       :  IMAGE_STREAM_PARAM_TYPE
                            := NEW_IMAGE_STREAM_PARAM(
                                   ELEM_BITS => I_PARAM.ELEM_BITS,
                                   INFO_BITS => I_PARAM.INFO_BITS,
                                   C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(CHANNEL_SIZE),
                                   D         => I_PARAM.SHAPE.D,
                                   X         => I_PARAM.SHAPE.X,
                                   Y         => I_PARAM.SHAPE.Y
                               );
    constant  WORD_BITS     :  integer := U_PARAM.DATA.SIZE;
    -------------------------------------------------------------------------------
    --! @brief 入力側のワード数
    -------------------------------------------------------------------------------
    constant  I_WIDTH       :  integer := I_PARAM.SHAPE.C.SIZE / U_PARAM.SHAPE.C.SIZE;
    -------------------------------------------------------------------------------
    --! @brief 出力側のワード数
    -------------------------------------------------------------------------------
    constant  O_WIDTH       :  integer := O_PARAM.SHAPE.C.SIZE / U_PARAM.SHAPE.C.SIZE;
    constant  offset        :  std_logic_vector (O_WIDTH-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --! @brief ワード単位でデータ/データストローブ信号/ワード有効フラグをまとめておく.
    -------------------------------------------------------------------------------
    type      WORD_TYPE     is record
              DATA          :  std_logic_vector(WORD_BITS-1 downto 0);
              LAST          :  boolean;
              VAL           :  boolean;
    end record;
    -------------------------------------------------------------------------------
    --! @brief WORD TYPE の初期化時の値.
    -------------------------------------------------------------------------------
    constant  WORD_NULL     :  WORD_TYPE := (DATA => (others => '0'),
                                             LAST => FALSE,
                                             VAL  => FALSE);
    -------------------------------------------------------------------------------
    --! @brief WORD TYPE の配列の定義.
    -------------------------------------------------------------------------------
    type      WORD_VECTOR  is array (INTEGER range <>) of WORD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief 指定されたベクタのリダクション論理和を求める関数.
    -------------------------------------------------------------------------------
    function  or_reduce(Arg : std_logic_vector) return std_logic is
        variable result : std_logic;
    begin
        result := '0';
        for i in Arg'range loop
            result := result or Arg(i);
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 入力信号のうち最も低い位置の'1'だけを取り出す関数.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- 例) Data(0 to 3) = "1110" => SEL(0 to 3) = "1000"
    --     Data(0 to 3) = "0111" => SEL(0 to 3) = "0100"
    --     Data(0 to 3) = "0011" => SEL(0 to 3) = "0010"
    --     Data(0 to 3) = "0001" => SEL(0 to 3) = "0001"
    --     Data(0 to 3) = "0000" => SEL(0 to 3) = "0000"
    --     Data(0 to 3) = "0101" => SEL(0 to 3) = "0101" <- このような入力は禁止
    -------------------------------------------------------------------------------
    function  priority_selector(
                 Data    : std_logic_vector
    )            return    std_logic_vector
    is
        variable result  : std_logic_vector(Data'range);
    begin
        for i in Data'range loop
            if (i = Data'low) then
                result(i) := Data(i);
            else
                result(i) := Data(i) and (not Data(i-1));
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ワードの配列からSELで指定されたワードを選択する関数.
    -------------------------------------------------------------------------------
    function  select_word(
                 WORDS   :  WORD_VECTOR;
                 SEL     :  std_logic_vector
    )            return     WORD_TYPE
    is
        alias    i_words :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        alias    i_sel   :  std_logic_vector(0 to   SEL'length-1) is SEL;
        variable result  :  WORD_TYPE;
        variable s_vec   :  std_logic_vector(0 to WORDS'length-1);
    begin
        for n in WORD_BITS-1 downto 0 loop
            for i in i_words'range loop
                if (i_sel'low <= i and i <= i_sel'high) then
                    s_vec(i) := i_words(i).DATA(n) and i_sel(i);
                else
                    s_vec(i) := '0';
                end if;
            end loop;
            result.DATA(n) := or_reduce(s_vec);
        end loop;
        for i in i_words'range loop
            if (i_sel'low <= i and i <= i_sel'high) then
                if (i_words(i).VAL and i_sel(i) = '1') then
                    s_vec(i) := '1';
                else
                    s_vec(i) := '0';
                end if;
            else
                    s_vec(i) := '0';
            end if;
        end loop;
        result.VAL  := (or_reduce(s_vec) = '1');
        for i in i_words'range loop
            if (i_sel'low <= i and i <= i_sel'high) then
                if (i_words(i).LAST and i_sel(i) = '1') then
                    s_vec(i) := '1';
                else
                    s_vec(i) := '0';
                end if;
            else
                    s_vec(i) := '0';
            end if;
        end loop;
        result.LAST := (or_reduce(s_vec) = '1');
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューの最後にワードを追加した新しいキューを求める関数.
    -------------------------------------------------------------------------------
    function  append_words(
                 QUEUE   :  WORD_VECTOR;
                 WORDS   :  WORD_VECTOR
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        variable i_val   :  std_logic_vector(0 to WORDS'length-1);
        variable i_sel   :  std_logic_vector(0 to WORDS'length-1);
        type     bv      is array (INTEGER range <>) of boolean;
        variable q_val   :  bv(QUEUE'low to QUEUE'high);
        variable result  :  WORD_VECTOR     (QUEUE'range);
    begin
        for q in QUEUE'range loop
            q_val(q) := QUEUE(q).VAL;
        end loop;
        for q in QUEUE'range loop 
            if (q_val(q) = FALSE) then
                for i in i_val'range loop
                    if (q-i-1 >= QUEUE'low) then
                        if (q_val(q-i-1)) then
                            i_val(i) := '1';
                        else
                            i_val(i) := '0';
                        end if;
                    else
                            i_val(i) := '1';
                    end if;
                end loop;
                i_sel := priority_selector(i_val);
                result(q) := select_word(WORDS=>i_vec, SEL=>i_sel);
            else
                result(q) := QUEUE(q);
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief o_shift信号からONE-HOTのセレクト信号を生成する関数.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- 例) SHIFT(3 downto 0)="0000" => SEL(0 to 4)=(0=>'1',1=>'0',2=>'0',3=>'0',4=>'0')
    --     SHIFT(3 downto 0)="0001" => SEL(0 to 4)=(0=>'0',1=>'1',2=>'0',3=>'0',4=>'0')
    --     SHIFT(3 downto 0)="0011" => SEL(0 to 4)=(0=>'0',1=>'0',2=>'1',3=>'0',4=>'0')
    --     SHIFT(3 downto 0)="0111" => SEL(0 to 4)=(0=>'0',1=>'0',2=>'0',3=>'1',4=>'0')
    --     SHIFT(3 downto 0)="1111" => SEL(0 to 4)=(0=>'0',1=>'0',2=>'0',3=>'0',4=>'1')
    -------------------------------------------------------------------------------
    function  shift_to_selector(
                 SHIFT   :  std_logic_vector;
                 MIN     :  integer;
                 MAX     :  integer
    )            return     std_logic_vector
    is
        variable result  :  std_logic_vector(MIN to MAX);
    begin
        for i in result'range loop
            if    (i < SHIFT'low ) then
                    result(i) := '0';
            elsif (i = SHIFT'low ) then
                if (SHIFT(i) = '0') then
                    result(i) := '1';
                else
                    result(i) := '0';
                end if;
            elsif (i <= SHIFT'high) then
                if (SHIFT(i) = '0' and SHIFT(i-1) = '1') then
                    result(i) := '1';
                else
                    result(i) := '0';
                end if;
            elsif (i = SHIFT'high+1) then
                if (SHIFT(i-1) = '1') then
                    result(i) := '1';
                else
                    result(i) := '0';
                end if;
            else
                    result(i) := '0';
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ワード配列の有効なデータをLOW側に詰めたワード配列を求める関数.
    -------------------------------------------------------------------------------
    function  justify_words(
                 WORDS   :  WORD_VECTOR
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        variable i_val   :  std_logic_vector(0 to WORDS'length-1);
        variable s_vec   :  WORD_VECTOR     (0 to WORDS'length-1);
        variable s_sel   :  std_logic_vector(0 to WORDS'length-1);
        variable result  :  WORD_VECTOR     (0 to WORDS'length-1);
    begin
        for i in i_vec'range loop
            if (i_vec(i).VAL) then
                i_val(i) := '1';
            else
                i_val(i) := '0';
            end if;
        end loop;
        s_sel := priority_selector(i_val);
        for i in result'range loop
            result(i) := select_word(
                WORDS => i_vec(i to WORDS'length-1  ),
                SEL   => s_sel(0 to WORDS'length-i-1)
            );
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューを指定した分だけLOW側にシフトした新しいキューを求める関数.
    -------------------------------------------------------------------------------
    function  shift_words(
                 WORDS   :  WORD_VECTOR;
                 SHIFT   :  std_logic_vector
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        variable i_sel   :  std_logic_vector(0 to SHIFT'high  +1);
        variable result  :  WORD_VECTOR     (0 to WORDS'length-1);
    begin
        i_sel := shift_to_selector(SHIFT, i_sel'low, i_sel'high);
        for i in result'range loop
            result(i) := select_word(
                WORDS => i_vec(i to minimum(i+i_sel'high,i_vec'high)),
                SEL   => i_sel
            );
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューから指定した分だけキューに残して残りを削除したキューを求める関数.
    -------------------------------------------------------------------------------
    function  flush_words(
                 WORDS   :  WORD_VECTOR;
                 SHIFT   :  std_logic_vector
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR(0 to WORDS'length-1) is WORDS;
        variable result  :  WORD_VECTOR(0 to WORDS'length-1);
    begin
        for i in result'range loop
            if    (i <  SHIFT'low ) then
                result(i).VAL := i_vec(i).VAL;
            elsif (i <= SHIFT'high) then
                result(i).VAL := i_vec(i).VAL and (SHIFT(i) = '1');
            else
                result(i).VAL := FALSE;
            end if;
            result(i).DATA := (others => '0');
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューに入っているワード数がSHIFTで指定された数未満かどうかを求める関数
    -------------------------------------------------------------------------------
    function  words_less_than_shift_size(
                 WORDS   :  WORD_VECTOR;
                 SHIFT   :  std_logic_vector
    )            return     boolean
    is
        alias    i_vec   :  WORD_VECTOR(0 to WORDS'length-1) is WORDS;
        variable result  :  boolean;
    begin
        result := FALSE;
        for i in SHIFT'high downto i_vec'low loop
            if (i < SHIFT'low) then
                if (i_vec(i).VAL = FALSE) then
                    result := TRUE;
                end if;
            else
                if (i_vec(i).VAL = FALSE and SHIFT(i) = '1') then
                    result := TRUE;
                end if;
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューに入っているワード数がSHIFTで指定された数を越えているかどうかを求める関数
    -------------------------------------------------------------------------------
    function  words_more_than_shift_size(
                 WORDS   :  WORD_VECTOR;
                 SHIFT   :  std_logic_vector
    )            return     boolean
    is
        alias    i_vec   :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        variable i_sel   :  std_logic_vector(0 to SHIFT'high  +1);
        variable result  :  boolean;
    begin
        i_sel  := shift_to_selector(SHIFT, i_sel'low, i_sel'high);
        result := FALSE;
        for i in i_vec'range loop
            if (i_sel'low <= i and i <= i_sel'high) then
                if (i_sel(i) = '1' and i_vec(i).VAL) then
                    result := TRUE;
                end if;
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューのサイズを計算する関数.
    -------------------------------------------------------------------------------
    function  QUEUE_DEPTH return integer is begin
        if (QUEUE_SIZE > 0) then
            if (QUEUE_SIZE >= O_WIDTH+I_WIDTH-1) then
                return QUEUE_SIZE;
            else
                assert (QUEUE_SIZE >= I_WIDTH+O_WIDTH-1)
                    report "require QUEUE_SIZE >= I_WIDTH+O_WIDTH-1" severity WARNING;
                return O_WIDTH+I_WIDTH-1;
            end if;
        else
                return O_WIDTH+I_WIDTH+I_WIDTH-1;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 現在のキューの状態.
    -------------------------------------------------------------------------------
    signal    curr_queue    :  WORD_VECTOR(0 to QUEUE_DEPTH-1);
    -------------------------------------------------------------------------------
    --! @brief 出力時にキューから取り出す数.
    -------------------------------------------------------------------------------
    signal    o_shift       :  std_logic_vector(O_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief 出力側の Channel Attribute.
    -------------------------------------------------------------------------------
    type      C_ATRB_VECTOR is array (integer range <>,integer range <>) of IMAGE_STREAM_ATRB_TYPE;
    signal    o_c_atrb      :  C_ATRB_VECTOR(0 to O_WIDTH-1, 0 to U_PARAM.SHAPE.C.SIZE-1);
    -------------------------------------------------------------------------------
    --! @brief FLUSH 出力フラグ.
    -------------------------------------------------------------------------------
    signal    flush_output  : std_logic;
    -------------------------------------------------------------------------------
    --! @brief FLUSH 保留フラグ.
    -------------------------------------------------------------------------------
    signal    flush_pending : std_logic;
    -------------------------------------------------------------------------------
    --! @brief DONE 出力フラグ.
    -------------------------------------------------------------------------------
    signal    done_output   : std_logic;
    -------------------------------------------------------------------------------
    --! @brief DONE 保留フラグ.
    -------------------------------------------------------------------------------
    signal    done_pending  : std_logic;
    -------------------------------------------------------------------------------
    --! @brief O_VALID信号を内部で使うための信号.
    -------------------------------------------------------------------------------
    signal    outlet_valid  : std_logic;
    -------------------------------------------------------------------------------
    --! @brief I_READY信号を内部で使うための信号.
    -------------------------------------------------------------------------------
    signal    intake_ready  : std_logic;
    -------------------------------------------------------------------------------
    --! @brief BUSY信号を内部で使うための信号.
    -------------------------------------------------------------------------------
    signal    curr_busy     : std_logic;
    -------------------------------------------------------------------------------
    --! @brief 入力データを生成する関数.
    -------------------------------------------------------------------------------
    function  i_data_to_words(I_DATA: std_logic_vector) return WORD_VECTOR is
        variable  words             :  WORD_VECTOR(0 to I_WIDTH-1);
        variable  t_data            :  std_logic_vector(U_PARAM.DATA.SIZE-1 downto 0);
        variable  c_atrb            :  IMAGE_STREAM_ATRB_TYPE;
        variable  d_atrb            :  IMAGE_STREAM_ATRB_TYPE;
        variable  x_atrb            :  IMAGE_STREAM_ATRB_TYPE;
        variable  y_atrb            :  IMAGE_STREAM_ATRB_TYPE;
        variable  t_valid           :  boolean;
        variable  t_last            :  boolean;
    begin 
        for i in 0 to I_WIDTH-1 loop
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
            for d_pos in U_PARAM.SHAPE.D.LO to U_PARAM.SHAPE.D.HI loop
            for x_pos in U_PARAM.SHAPE.X.LO to U_PARAM.SHAPE.X.HI loop
            for y_pos in U_PARAM.SHAPE.Y.LO to U_PARAM.SHAPE.Y.HI loop
                SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                    PARAM   => U_PARAM,
                    C       => c_pos,
                    D       => d_pos,
                    X       => x_pos,
                    Y       => y_pos,
                    ELEMENT => GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                                   PARAM  => I_PARAM,
                                   C      => c_pos+i*U_PARAM.SHAPE.C.SIZE,
                                   D      => d_pos,
                                   X      => x_pos,
                                   Y      => y_pos,
                                   DATA   => I_DATA),
                    DATA    => t_data
                );
            end loop;
            end loop;
            end loop;
            end loop;
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                c_atrb := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                              PARAM => I_PARAM,
                              C     => c_pos+i*U_PARAM.SHAPE.C.SIZE,
                              DATA  => I_DATA
                          );
                SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                              PARAM => U_PARAM,
                              C     => c_pos,
                              ATRB  => c_atrb,
                              DATA  => t_data
                );
            end loop;
            for d_pos in U_PARAM.SHAPE.D.LO to U_PARAM.SHAPE.D.HI loop
                d_atrb := GET_ATRB_D_FROM_IMAGE_STREAM_DATA(
                              PARAM => I_PARAM,
                              D     => d_pos,
                              DATA  => I_DATA
                          );
                SET_ATRB_D_TO_IMAGE_STREAM_DATA(
                              PARAM => U_PARAM,
                              D     => d_pos,
                              ATRB  => d_atrb,
                              DATA  => t_data
                );
            end loop;
            for x_pos in U_PARAM.SHAPE.X.LO to U_PARAM.SHAPE.X.HI loop
                x_atrb := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                              PARAM => I_PARAM,
                              X     => x_pos,
                              DATA  => I_DATA
                          );
                SET_ATRB_X_TO_IMAGE_STREAM_DATA(
                              PARAM => U_PARAM,
                              X     => x_pos,
                              ATRB  => x_atrb,
                              DATA  => t_data
                );
            end loop;
            for y_pos in U_PARAM.SHAPE.Y.LO to U_PARAM.SHAPE.Y.HI loop
                y_atrb := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                              PARAM => I_PARAM,
                              Y     => y_pos,
                              DATA  => I_DATA
                          );
                SET_ATRB_Y_TO_IMAGE_STREAM_DATA(
                              PARAM => U_PARAM,
                              Y     => y_pos,
                              ATRB  => y_atrb,
                              DATA  => t_data
                );
            end loop;
            if (I_PARAM.INFO_BITS > 0) then
                t_data(U_PARAM.DATA.INFO_FIELD.HI downto U_PARAM.DATA.INFO_FIELD.LO) := I_DATA(I_PARAM.DATA.INFO_FIELD.HI downto I_PARAM.DATA.INFO_FIELD.LO);
            end if;
            t_valid := FALSE;
            t_last  := FALSE;
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                c_atrb := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                              PARAM => I_PARAM,
                              C     => c_pos+i*U_PARAM.SHAPE.C.SIZE,
                              DATA  => I_DATA
                          );
                if c_atrb.VALID then
                    t_valid := TRUE;
                end if;
                if c_atrb.LAST  then
                    t_last  := TRUE;
                end if;
            end loop;
            words(i).DATA := t_data;
            words(i).VAL  := t_valid;
            words(i).LAST := t_last;
        end loop;
        return words;
    end function;
begin
    -------------------------------------------------------------------------------
    -- メインプロセス
    -------------------------------------------------------------------------------
    process (CLK, RST) 
        variable    in_words          : WORD_VECTOR(0 to I_WIDTH-1);
        variable    next_queue        : WORD_VECTOR(curr_queue'range);
        variable    shift             : std_logic_vector(O_WIDTH-1 downto 0);
        variable    next_valid_output : boolean;
        variable    next_last_output  : boolean;
        variable    next_flush_output : std_logic;
        variable    next_flush_pending: std_logic;
        variable    next_flush_fall   : std_logic;
        variable    next_done_output  : std_logic;
        variable    next_done_pending : std_logic;
        variable    next_done_fall    : std_logic;
        variable    pending_flag      : boolean;
        variable    flush_output_done : boolean;
        variable    flush_output_last : boolean;
    begin
        if (RST = '1') then
                curr_queue    <= (others => WORD_NULL);
                o_shift       <= (others => '0');
                flush_output  <= '0';
                flush_pending <= '0';
                done_output   <= '0';
                done_pending  <= '0';
                intake_ready       <= '0';
                outlet_valid       <= '0';
                curr_busy     <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_queue    <= (others => WORD_NULL);
                o_shift       <= (others => '0');
                flush_output  <= '0';
                flush_pending <= '0';
                done_output   <= '0';
                done_pending  <= '0';
                intake_ready       <= '0';
                outlet_valid       <= '0';
                curr_busy     <= '0';
            else
                -------------------------------------------------------------------
                -- 次のクロックでのキューの状態を示す変数に現在のキューの状態をセット.
                -------------------------------------------------------------------
                next_queue := curr_queue;
                -------------------------------------------------------------------
                -- キュー初期化時は、OFFSETで指定された分だけ、あらかじめキューに
                -- ダミーのデータを入れておく.
                -------------------------------------------------------------------
                if (START = '1') then
                    for i in next_queue'range loop
                        if (i < O_WIDTH-1) then
                            next_queue(i).VAL := (OFFSET(i) = '1');
                        else
                            next_queue(i).VAL := FALSE;
                        end if;
                        next_queue(i).DATA := (others => '0');
                        next_queue(i).LAST := FALSE;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- データ入力時は、キューに入力されたワードを追加する.
                -------------------------------------------------------------------
                if (I_VALID = '1' and intake_ready = '1') then
                    in_words := i_data_to_words(I_DATA);
                    if (I_JUSTIFIED     = 0) and
                       (in_words'length > 1) then
                        in_words := justify_words(in_words);
                    end if;
                    next_queue := append_words(next_queue, in_words);
                end if;
                -------------------------------------------------------------------
                -- C_DONE=0 の場合はキューに複数分のチャネルが入っている可能性があ
                -- るため、シフトする値はキューの先頭から探索する必要がある.
                -- 探索結果は o_shift レジスタに格納されている.
                -------------------------------------------------------------------
                -- C_DONE=1 の場合はキューにひとつ分のチャネルしか入っていないので
                -- O_WIDTH 分 シフトするようにして回路を簡略化する.
                -------------------------------------------------------------------
                if (C_DONE = 0) then
                    shift := o_shift;
                else
                    shift := (others => '1');
                end if;
                -------------------------------------------------------------------
                -- データ出力時は、キューの先頭から shift で指定された分だけ、
                -- データを取り除く.
                -------------------------------------------------------------------
                if (outlet_valid = '1' and O_READY = '1') then
                    if (FLUSH_ENABLE >  0 ) and
                       (flush_output = '1') then
                        flush_output_last :=     words_less_than_shift_size(next_queue, shift);
                        flush_output_done := not words_more_than_shift_size(next_queue, shift);
                    else
                        flush_output_last := FALSE;
                        flush_output_done := FALSE;
                    end if;
                    if (flush_output_last) then
                        next_queue := flush_words(next_queue, shift);
                    else
                        next_queue := shift_words(next_queue, shift);
                    end if;
                else
                        flush_output_last := FALSE;
                        flush_output_done := FALSE;
                end if;
                -------------------------------------------------------------------
                -- 次のクロックでのキューの状態をレジスタに保持
                -------------------------------------------------------------------
                curr_queue <= next_queue;
                -------------------------------------------------------------------
                --
                -------------------------------------------------------------------
                next_valid_output := FALSE;
                next_last_output  := FALSE;
                pending_flag      := FALSE;
                for o in 0 to O_WIDTH-1 loop
                    if next_last_output then
                        for c_pos in 0 to U_PARAM.SHAPE.C.SIZE-1 loop
                            o_c_atrb(o,c_pos).VALID <= FALSE;
                            o_c_atrb(o,c_pos).LAST  <= TRUE;
                            o_c_atrb(o,c_pos).START <= FALSE;
                        end loop;
                        o_shift(o)        <= '0';
                        next_valid_output := TRUE;
                        pending_flag      := next_queue(o).VAL;
                    else
                        for c_pos in 0 to U_PARAM.SHAPE.C.SIZE-1 loop
                            o_c_atrb(o,c_pos) <= GET_ATRB_C_FROM_IMAGE_STREAM_DATA(U_PARAM, c_pos, next_queue(o).DATA);
                        end loop;
                        o_shift(o)        <= '1';
                        next_valid_output := next_queue(o).VAL;
                        next_last_output  := next_queue(o).LAST;
                        pending_flag      := FALSE;
                    end if;
                end loop;
                -------------------------------------------------------------------
                -- 次のクロックでのキューの状態でO_WIDTHの位置にデータが入って
                -- いるか否かをチェック.
                -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                -- この位置にデータがある場合は、O_DONE、O_FLUSH はまだアサートせ
                -- ずに、一旦ペンディングしておく.
                -------------------------------------------------------------------
                if (next_queue'high >= O_WIDTH) then
                    if (C_DONE /= 0) then
                        pending_flag := (next_queue(O_WIDTH).VAL);
                    else
                        pending_flag := (pending_flag or next_queue(O_WIDTH).VAL);
                    end if;
                else
                    pending_flag := FALSE;
                end if;
                -------------------------------------------------------------------
                -- FLUSH制御
                -------------------------------------------------------------------
                if    (FLUSH_ENABLE = 0) then
                        next_flush_output  := '0';
                        next_flush_pending := '0';
                        next_flush_fall    := '0';
                elsif (flush_output = '1') then
                    if (flush_output_done) then
                        next_flush_output  := '0';
                        next_flush_pending := '0';
                        next_flush_fall    := '1';
                    else
                        next_flush_output  := '1';
                        next_flush_pending := '0';
                        next_flush_fall    := '0';
                    end if;
                elsif (flush_pending = '1') or
                      (FLUSH         = '1') or
                      (I_VALID = '1' and intake_ready = '1' and I_FLUSH = '1') then
                    if (pending_flag) then
                        next_flush_output  := '0';
                        next_flush_pending := '1';
                        next_flush_fall    := '0';
                    else
                        next_flush_output  := '1';
                        next_flush_pending := '0';
                        next_flush_fall    := '0';
                    end if;
                else
                        next_flush_output  := '0';
                        next_flush_pending := '0';
                        next_flush_fall    := '0';
                end if;
                flush_output  <= next_flush_output;
                flush_pending <= next_flush_pending;
                -------------------------------------------------------------------
                -- DONE制御
                -------------------------------------------------------------------
                if    (done_output = '1') then
                    if (next_queue(next_queue'low).VAL = FALSE) then
                        next_done_output   := '0';
                        next_done_pending  := '0';
                        next_done_fall     := '1';
                    else
                        next_done_output   := '1';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                    end if;
                elsif (done_pending = '1') or
                      (DONE         = '1') or
                      (I_VALID = '1' and intake_ready = '1' and I_DONE = '1') or
                      (I_VALID = '1' and intake_ready = '1' and C_DONE /= 0 and IMAGE_STREAM_DATA_IS_LAST_C(I_PARAM, I_DATA, TRUE)) then
                    if (pending_flag) then
                        next_done_output   := '0';
                        next_done_pending  := '1';
                        next_done_fall     := '0';
                    else
                        next_done_output   := '1';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                    end if;
                else
                        next_done_output   := '0';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                end if;
                done_output   <= next_done_output;
                done_pending  <= next_done_pending;
                -------------------------------------------------------------------
                -- 出力有効信号の生成.
                -------------------------------------------------------------------
                if (O_ENABLE = '1') and
                   ((next_done_output  = '1') or
                    (next_flush_output = '1') or
                    (next_valid_output = TRUE)) then
                    outlet_valid <= '1';
                else
                    outlet_valid <= '0';
                end if;
                -------------------------------------------------------------------
                -- 入力可能信号の生成.
                -------------------------------------------------------------------
                if (I_ENABLE = '1') and 
                   (next_done_output  = '0' and next_done_pending  = '0') and
                   (next_flush_output = '0' and next_flush_pending = '0') and
                   (next_queue(next_queue'length-I_WIDTH).VAL = FALSE) then
                    intake_ready <= '1';
                else
                    intake_ready <= '0';
                end if;
                -------------------------------------------------------------------
                -- 現在処理中であることを示すフラグ.
                -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                -- 最初に入力があった時点で'1'になり、O_DONEまたはO_FLUSHが出力完了
                -- した時点で'0'になる。
                -------------------------------------------------------------------
                if (curr_busy = '1') then
                    if (next_flush_fall = '1') or
                       (next_done_fall  = '1') then
                        curr_busy <= '0';
                    else
                        curr_busy <= '1';
                    end if;
                else
                    if (I_VALID = '1' and intake_ready = '1') then
                        curr_busy <= '1';
                    else
                        curr_busy <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O_DONE  <= done_output;
    O_VALID <= outlet_valid;
    I_READY <= intake_ready;
    BUSY    <= curr_busy;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(curr_queue, o_c_atrb)
        variable  outlet_data   :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for o in 0 to O_WIDTH-1 loop
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
            for d_pos in U_PARAM.SHAPE.D.LO to U_PARAM.SHAPE.D.HI loop
            for x_pos in U_PARAM.SHAPE.X.LO to U_PARAM.SHAPE.X.HI loop
            for y_pos in U_PARAM.SHAPE.Y.LO to U_PARAM.SHAPE.Y.HI loop
                SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                    PARAM   => O_PARAM,
                    C       => c_pos+o*U_PARAM.SHAPE.C.SIZE,
                    D       => d_pos,
                    X       => x_pos,
                    Y       => y_pos,
                    ELEMENT => GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                                   PARAM  => U_PARAM,
                                   C      => c_pos,
                                   D      => d_pos,
                                   X      => x_pos,
                                   Y      => y_pos,
                                   DATA   => curr_queue(o).DATA
                               ),
                    DATA    => outlet_data
                );
            end loop;
            end loop;
            end loop;
            end loop;
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        for o in 0 to O_WIDTH-1 loop
            for c_pos in U_PARAM.SHAPE.C.LO to U_PARAM.SHAPE.C.HI loop
                SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                    PARAM => O_PARAM,
                    C     => c_pos+o*U_PARAM.SHAPE.C.SIZE,
                    ATRB  => o_c_atrb(o,c_pos),
                    DATA  => outlet_data
                );
            end loop;
        end loop;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (O_PARAM.DATA.ATRB_FIELD.D.SIZE > 0) then
            outlet_data(O_PARAM.DATA.ATRB_FIELD.D.HI downto O_PARAM.DATA.ATRB_FIELD.D.LO) := curr_queue(curr_queue'low).DATA(U_PARAM.DATA.ATRB_FIELD.D.HI downto U_PARAM.DATA.ATRB_FIELD.D.LO);
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (O_PARAM.DATA.ATRB_FIELD.X.SIZE > 0) then
            outlet_data(O_PARAM.DATA.ATRB_FIELD.X.HI downto O_PARAM.DATA.ATRB_FIELD.X.LO) := curr_queue(curr_queue'low).DATA(U_PARAM.DATA.ATRB_FIELD.X.HI downto U_PARAM.DATA.ATRB_FIELD.X.LO);
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (O_PARAM.DATA.ATRB_FIELD.Y.SIZE > 0) then
            outlet_data(O_PARAM.DATA.ATRB_FIELD.Y.HI downto O_PARAM.DATA.ATRB_FIELD.Y.LO) := curr_queue(curr_queue'low).DATA(U_PARAM.DATA.ATRB_FIELD.Y.HI downto U_PARAM.DATA.ATRB_FIELD.Y.LO);
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (O_PARAM.DATA.INFO_FIELD.SIZE > 0) then
            outlet_data(O_PARAM.DATA.INFO_FIELD.HI   downto O_PARAM.DATA.INFO_FIELD.LO  ) := curr_queue(curr_queue'low).DATA(U_PARAM.DATA.INFO_FIELD.HI   downto U_PARAM.DATA.INFO_FIELD.LO  );
        end if;
        O_DATA <= outlet_data;
    end process;
end RTL;
