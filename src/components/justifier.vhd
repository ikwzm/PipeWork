-----------------------------------------------------------------------------------
--!     @file    justifier.vhd
--!     @brief   JUSTIFIER MODULE :
--!              入力側の有効なデータをLOW側に詰めるアダプタ
--!     @version 2.0.0
--!     @date    2024/2/19
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2024 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
--! @brief   JUSTIFIER :
--!          入力側の有効なデータをLOW側に詰めるアダプタ.
--!          もともとは REDUCER の機能のひとつだったが、暖簾分けした.
-----------------------------------------------------------------------------------
entity  JUSTIFIER is
    generic (
        WORD_BITS   : --! @brief WORD BITS :
                      --! １ワードのデータのビット数を指定する.
                      integer := 8;
        STRB_BITS   : --! @brief ENABLE BITS :
                      --! ワードデータのうち有効なデータであることを示す信号(STRB)
                      --! のビット数を指定する.
                      integer := 1;
        INFO_BITS   : --! @brief INFOMATION BITS :
                      --! インフォメーション信号のビット数を指定する.
                      integer := 1;
        WORDS       : --! @brief INPUT WORD WIDTH :
                      --! 入力側のデータのワード数を指定する.
                      integer := 1;
        I_JUSTIFIED : --! @brief INPUT WORD JUSTIFIED :
                      --! 入力側の有効なデータが常にLOW側に詰められていることを
                      --! 示すフラグ.
                      --! * 常にLOW側に詰められている場合は、シフタが必要なくなる
                      --!   ため回路が簡単になる.
                      integer range 0 to 1 := 0;
        I_DVAL_ENABLE:--! @brief INPUT DATA VALID ENABLE :
                      --! ワードデータのうち有効なデータであることを示す信号として
                      --! I_DVAL 信号を使う.
                      --! * I_DVAL_ENABLE=1を指定した場合は、I_DVAL をワードデータ
                      --!   のうちの有効なデータであることを示す信号として使う.
                      --! * I_DVAL_ENABLE=0を指定した場合は、I_STRB をワードデータ
                      --!   のうちの有効なデータであることを示す信号として使う.
                      --! * I_STRB の値に関係なく I_DATA と I_STRB をキューに格納
                      --!   したい場合は I_DVAL を使うと良い.
                      integer range 0 to 1 := 0;
        PIPELINE     : --! @brief PORT PIPELINE STAGE SIZE :
                       --! パイプラインの段数を指定する.
                       --! * 前述の I_JUSTIFIED が 0 の場合は、入力側 I/F の有効
                       --!   なデータを LOW 側に詰る必要があるが、その際に遅延時間
                       --!   が増大して動作周波数が上らないことがある.
                       --!   そのような場合は PIPELINE に 1 以上を指定してパイプラ
                       --!   イン化すると動作周波数が向上する可能性がある.
                      integer := 0
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK         : --! @brief CLOCK :
                      --! クロック信号
                      in  std_logic; 
        RST         : --! @brief ASYNCRONOUSE RESET :
                      --! 非同期リセット信号.アクティブハイ.
                      in  std_logic;
        CLR         : --! @brief SYNCRONOUSE RESET :
                      --! 同期リセット信号.アクティブハイ.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_ENABLE    : --! @brief INPUT ENABLE :
                      in  std_logic;
        I_DATA      : --! @brief INPUT WORD DATA :
                      --! ワードデータ入力.
                      in  std_logic_vector(WORDS*WORD_BITS-1 downto 0);
        I_STRB      : --! @brief INPUT WORD ENABLE :
                      --! ワードストローブ信号入力.
                      in  std_logic_vector(WORDS*STRB_BITS-1 downto 0) := (others => '1');
        I_DVAL      : --! @brief INPUT WORD ENABLE :
                      --! ワード有効信号入力.
                      --! * I_DATA/I_STRB のうちどのワードをパイプラインに入れるかを示す信号.
                      --! * I_DVAL_ENABLE=1の時のみ有効.
                      --! * I_DVAL_ENABLE=0の時は I_STRB 信号の値によって、どのワードを
                      --!   パイプラインに入れるかを示す.
                      in  std_logic_vector(WORDS          -1 downto 0) := (others => '1');
        I_INFO      : --! @brief INPUT INFOMATION :
                      --! インフォメーション入力.
                      in  std_logic_vector(      INFO_BITS-1 downto 0) := (others => '0');
        I_VAL       : --! @brief INPUT WORD VALID :
                      --! 入力ワード有効信号.
                      --! * I_DATA/I_STRB/I_DVAL/I_LASTが有効であることを示す.
                      --! * I_VAL='1'and I_RDY='1'でワードデータがパイプラインに取り込まれる.
                      in  std_logic;
        I_RDY       : --! @brief INPUT WORD READY :
                      --! 入力レディ信号.
                      --! * パイプラインが次のワードデータを入力出来ることを示す.
                      --! * I_VAL='1'and I_RDY='1'でワードデータがパイプラインに取り込まれる.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT WORD DATA :
                      --! ワードデータ出力.
                      out std_logic_vector(WORDS*WORD_BITS-1 downto 0);
        O_STRB      : --! @brief OUTPUT WORD ENABLE :
                      --! ワードストローブ信号出力.
                      out std_logic_vector(WORDS*STRB_BITS-1 downto 0);
        O_DVAL      : --! @brief OUTPUT WORD ENABLE :
                      --! ワード有効信号出力.
                      out std_logic_vector(WORDS          -1 downto 0);
        O_INFO      : --! @brief OUTPUT INFOMATION :
                      --! インフォメーション出力.
                      out std_logic_vector(      INFO_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT WORD VALID :
                      --! 出力ワード有効信号.
                      --! * O_DATA/O_STRB/O_DVAL/O_LASTが有効であることを示す.
                      --! * O_VAL='1'and O_RDY='1'でワードデータがパイプラインから取り除かれる.
                      out std_logic;
        O_RDY       : --! @brief OUTPUT WORD READY :
                      --! 出力レディ信号.
                      --! * パイプラインから次のワードを取り除く準備が出来ていることを示す.
                      --! * O_VAL='1'and O_RDY='1'でワードデータがパイプラインから取り除かれる.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- Status Signals.
    -------------------------------------------------------------------------------
        BUSY        : --! @brief QUEUE BUSY :
                      --! パイプラインが動作中であることを示す信号.
                      --! * 最初にデータが入力されたときにアサートされる.
                      --! * 最後のデータが出力し終えたらネゲートされる.
                      out  std_logic
    );
end JUSTIFIER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of JUSTIFIER is
    -------------------------------------------------------------------------------
    --! @brief ワード単位でデータ/データストローブ信号/ワード有効フラグをまとめておく.
    -------------------------------------------------------------------------------
    type      WORD_TYPE     is record
              DATA          :  std_logic_vector(WORD_BITS-1 downto 0);
              STRB          :  std_logic_vector(STRB_BITS-1 downto 0);
              VAL           :  boolean;
    end record;
    -------------------------------------------------------------------------------
    --! @brief WORD TYPE の初期化時の値.
    -------------------------------------------------------------------------------
    constant  WORD_NULL     :  WORD_TYPE := (DATA => (others => '0'),
                                             STRB => (others => '0'),
                                             VAL  => FALSE);
    -------------------------------------------------------------------------------
    --! @brief WORD TYPE の配列の定義.
    -------------------------------------------------------------------------------
    type      WORD_VECTOR   is array (INTEGER range <>) of WORD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief 1ワード分のイネーブル信号がオール0であることを示す定数.
    -------------------------------------------------------------------------------
    constant  STRB_NULL     :  std_logic_vector(STRB_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --! @brief 指定されたベクタのリダクション論理和を求める.
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
                 VEC     :  WORD_VECTOR;
                 SEL     :  std_logic_vector
    )            return     WORD_TYPE
    is
        alias    i_vec   :  WORD_VECTOR     (0 to VEC'length-1) is VEC;
        alias    i_sel   :  std_logic_vector(0 to SEL'length-1) is SEL;
        variable result  :  WORD_TYPE;
        variable s_vec   :  std_logic_vector(0 to VEC'length-1);
    begin
        for n in WORD_BITS-1 downto 0 loop
            for i in i_vec'range loop
                if (i_sel'low <= i and i <= i_sel'high) then
                    s_vec(i) := i_vec(i).DATA(n) and i_sel(i);
                else
                    s_vec(i) := '0';
                end if;
            end loop;
            result.DATA(n) := or_reduce(s_vec);
        end loop;
        for n in STRB_BITS-1 downto 0 loop
            for i in i_vec'range loop
                if (i_sel'low <= i and i <= i_sel'high) then
                    s_vec(i) := i_vec(i).STRB(n) and i_sel(i);
                else
                    s_vec(i) := '0';
                end if;
            end loop;
            result.STRB(n) := or_reduce(s_vec);
        end loop;
        for i in i_vec'range loop
            if (i_sel'low <= i and i <= i_sel'high) then
                if (i_vec(i).VAL and i_sel(i) = '1') then
                    s_vec(i) := '1';
                else
                    s_vec(i) := '0';
                end if;
            else
                    s_vec(i) := '0';
            end if;
        end loop;
        result.VAL := (or_reduce(s_vec) = '1');
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ワード配列の有効なデータをLOW側に詰めたワード配列を求める関数.
    -------------------------------------------------------------------------------
    function  justify_words(
                 VEC     :  WORD_VECTOR;
                 SFT_MAX :  integer
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR     (0 to VEC'length-1) is VEC;
        variable i_val   :  std_logic_vector(0 to VEC'length-1);
        variable s_val   :  std_logic_vector(0 to SFT_MAX);
        variable s_sel   :  std_logic_vector(0 to SFT_MAX);
        variable result  :  WORD_VECTOR     (0 to VEC'length-1);
    begin
        for i in i_val'range loop
            if (i_vec(i).VAL) then
                i_val(i) := '1';
            else
                i_val(i) := '0';
            end if;
        end loop;
        for i in s_val'range loop
            if    (i < SFT_MAX and i      <= i_val'high) or
                  (i = SFT_MAX and SFT_MAX = i_val'high) then
                s_val(i) := i_val(i);
            elsif (i = SFT_MAX and SFT_MAX = 0         ) then
                s_val(i) := '1';
            elsif (i = SFT_MAX and SFT_MAX < i_val'high) then
                s_val(i) := not or_reduce(i_val(0 to SFT_MAX-1));
            else
                s_val(i) := '0';
            end if;
        end loop;
        s_sel := priority_selector(s_val);
        for i in result'range loop
            if (i + s_sel'high > i_vec'high) then
                result(i) := select_word(
                    VEC => i_vec(i to i_vec'high  ),
                    SEL => s_sel(0 to i_vec'high-i)
                );
            else
                result(i) := select_word(
                    VEC => i_vec(i to i_vec'high  ),
                    SEL => s_sel(0 to s_sel'high  )
                );
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ワード配列の有効なデータをLOW側に詰めたワード配列を求める関数.
    -------------------------------------------------------------------------------
    function  justify_words(
                 VEC     :  WORD_VECTOR
    )            return     WORD_VECTOR
    is
    begin
        return justify_words(VEC, VEC'length-1);
    end function;
begin
    -------------------------------------------------------------------------------
    -- PIPELINE = 0 の場合
    -------------------------------------------------------------------------------
    PIPELINE_EQ_0: if (PIPELINE = 0) generate
        process (I_DATA, I_STRB, I_DVAL)
            variable word_vec : WORD_VECTOR(0 to WORDS-1);
        begin
            for i in word_vec'range loop
                word_vec(i).DATA := I_DATA((i+1)*WORD_BITS-1 downto i*WORD_BITS);
                word_vec(i).STRB := I_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS);
                if (I_DVAL_ENABLE > 0) then
                    word_vec(i).VAL := (I_DVAL(i) = '1');
                else
                    word_vec(i).VAL := (I_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS) /= STRB_NULL);
                end if;
            end loop;
            if (I_JUSTIFIED     = 0) and
               (word_vec'length > 1) then
                word_vec := justify_words(word_vec);
            end if;
            for i in word_vec'range loop
                O_DATA((i+1)*WORD_BITS-1 downto i*WORD_BITS) <= word_vec(i).DATA;
                O_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS) <= word_vec(i).STRB;
                if word_vec(i).VAL then
                    O_DVAL(i) <= '1';
                else
                    O_DVAL(i) <= '0';
                end if;
            end loop;
        end process;
        O_INFO <= I_INFO;
        O_VAL  <= '1' when (I_ENABLE = '1' and I_VAL = '1') else '0';
        I_RDY  <= '1' when (I_ENABLE = '1' and O_RDY = '1') else '0';
        BUSY   <= '0';
    end generate;
    -------------------------------------------------------------------------------
    -- PIPELINE > 0 の場合
    -------------------------------------------------------------------------------
    PIPELINE_GT_0: if (PIPELINE > 0) generate
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        constant  PRE_STAGE          :  integer := 0;
        constant  FIRST_STAGE        :  integer := 1;
        constant  LAST_STAGE         :  integer := PIPELINE;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        type      STAGE_DATA_TYPE    is record
                  WORD               :  WORD_VECTOR(0 to WORDS-1);
                  INFO               :  std_logic_vector(INFO_BITS-1 downto 0);
        end record;
        constant  STAGE_DATA_NULL    :  STAGE_DATA_TYPE := (
                                            WORD => (others => WORD_NULL),
                                            INFO => (others => '0')
                                        );
        type      STAGE_DATA_VECTOR  is array (integer range <>) of STAGE_DATA_TYPE;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        type      SFT_MAX_VECTOR     is array (integer range <>) of integer;
        function  CALC_SFT_MAX_VECTOR return SFT_MAX_VECTOR is
            variable  sft_max_vec    :  SFT_MAX_VECTOR(PRE_STAGE to LAST_STAGE);
            variable  sft_max        :  integer;
            variable  remain_words   :  integer;
        begin
            sft_max := (WORDS+PIPELINE-1)/PIPELINE;
            sft_max_vec(PRE_STAGE) := 0;
            remain_words := WORDS;
            for i in LAST_STAGE downto FIRST_STAGE loop
                if (remain_words > sft_max) then
                    sft_max_vec(i) := sft_max;
                else
                    sft_max_vec(i) := remain_words;
                end if;
                remain_words := remain_words - sft_max_vec(i);
            end loop;
            return sft_max_vec;
        end function;
        constant  STAGE_SFT_MAX      :  SFT_MAX_VECTOR   (PRE_STAGE to LAST_STAGE) := CALC_SFT_MAX_VECTOR;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        signal    stage_data         :  STAGE_DATA_VECTOR(PRE_STAGE to LAST_STAGE);
        signal    stage_valid        :  std_logic_vector (PRE_STAGE to LAST_STAGE);
        signal    stage_ready        :  std_logic_vector (PRE_STAGE to LAST_STAGE);
        signal    stage_busy         :  std_logic_vector (PRE_STAGE to LAST_STAGE);
    begin
        ---------------------------------------------------------------------------
        -- PRE_STAGE
        ---------------------------------------------------------------------------
        process (I_DATA, I_STRB, I_DVAL, I_INFO)
            variable  word_vec       :  WORD_VECTOR(0 to WORDS-1);
        begin
            for i in word_vec'range loop
                word_vec(i).DATA := I_DATA((i+1)*WORD_BITS-1 downto i*WORD_BITS);
                word_vec(i).STRB := I_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS);
                if (I_DVAL_ENABLE > 0) then
                    word_vec(i).VAL := (I_DVAL(i) = '1');
                else
                    word_vec(i).VAL := (I_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS) /= STRB_NULL);
                end if;
            end loop;
            stage_data(PRE_STAGE).WORD <= word_vec;
            stage_data(PRE_STAGE).INFO <= I_INFO;
        end process;
        stage_busy (PRE_STAGE) <= '0';
        stage_valid(PRE_STAGE) <= I_VAL when (I_ENABLE = '1') else '0';
        I_RDY <= stage_ready(PRE_STAGE) when (I_ENABLE = '1') else '0';
        ---------------------------------------------------------------------------
        -- FIRST_STAGE to LAST_STAGE
        ---------------------------------------------------------------------------
        PIPELINE_STAGE: for stage in FIRST_STAGE to LAST_STAGE generate
            constant  SFT_MAX        :  integer := STAGE_SFT_MAX(stage);
            signal    q_load         :  std_logic;
            signal    q_valid        :  std_logic;
            alias     i_valid        is stage_valid(stage-1);
            alias     i_ready        is stage_ready(stage-1);
            alias     o_valid        is stage_valid(stage  );
            alias     o_ready        is stage_ready(stage  );
        begin
            -----------------------------------------------------------------------
            -- PIPEWORK.PIPELINE_REGISTER_CONTROLLER の QUEUE_SIZE=1 の場合をコピペ
            -----------------------------------------------------------------------
            o_valid <= q_valid;
            i_ready <= '1' when (q_valid = '0') or
                                (q_valid = '1' and o_ready = '1') else '0';
            q_load  <= '1' when (i_valid = '1' and i_ready = '1') else '0';
            process (CLK, RST) begin
                if    (RST = '1') then
                           q_valid <= '0';
                elsif (CLK'event and CLK = '1') then
                   if (CLR = '1') then
                           q_valid <= '0';
                   elsif (q_valid = '0') then
                       if (i_valid = '1') then
                           q_valid <= '1';
                       else
                           q_valid <= '0';
                       end if;
                   else
                       if (i_valid = '0' and o_ready = '1') then
                           q_valid <= '0';
                       else
                           q_valid <= '1';
                       end if;
                   end if;
                end if;
            end process;
            stage_busy(stage) <= q_valid;
            -----------------------------------------------------------------------
            -- stage_data(stage) :
            -----------------------------------------------------------------------
            process (CLK, RST)
                variable  word_vec   :  WORD_VECTOR(0 to WORDS-1);
            begin
                if (RST = '1') then
                        stage_data(stage) <= STAGE_DATA_NULL;
                elsif (CLK'event and CLK = '1') then
                    if (CLR = '1') then
                        stage_data(stage) <= STAGE_DATA_NULL;
                    elsif (q_load = '1') then
                        if (I_JUSTIFIED     = 0) and
                           (word_vec'length > 1) then
                            word_vec := justify_words(stage_data(stage-1).WORD, SFT_MAX);
                        else
                            word_vec := stage_data(stage-1).WORD;
                        end if;
                        stage_data(stage).WORD <= word_vec;
                        stage_data(stage).INFO <= stage_data(stage-1).INFO;
                    end if;
                end if;
            end process;
        end generate;
        ---------------------------------------------------------------------------
        -- OUTPUT
        ---------------------------------------------------------------------------
        process (stage_data) 
            variable  word_vec  : WORD_VECTOR(0 to WORDS-1);
        begin
            word_vec := stage_data(LAST_STAGE).WORD;
            for i in word_vec'range loop
                O_DATA((i+1)*WORD_BITS-1 downto i*WORD_BITS) <= word_vec(i).DATA;
                O_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS) <= word_vec(i).STRB;
                if word_vec(i).VAL then
                    O_DVAL(i) <= '1';
                else
                    O_DVAL(i) <= '0';
                end if;
            end loop;
        end process;
        O_INFO <= stage_data(LAST_STAGE).INFO;
        O_VAL  <= stage_valid(LAST_STAGE);
        stage_ready(LAST_STAGE) <= O_RDY;
        BUSY   <= or_reduce(stage_busy);
    end generate;
end RTL;
