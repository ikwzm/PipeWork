-----------------------------------------------------------------------------------
--!     @file    convolution_int_accumulator.vhd
--!     @brief   Convolution Integer Accumulator Module
--!     @version 1.8.0
--!     @date    2019/3/21
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
--! @brief Convolution Integer Accumulator Module
-----------------------------------------------------------------------------------
entity  CONVOLUTION_INT_ACCUMULATOR is
    generic (
        I_PARAM         : --! @brief INPUT  PIPELINE DATA PARAMETER :
                          --! パイプラインデータ入力ポートのパラメータを指定する.
                          --! * 次の条件を満していなければならない.
                          --!     I_PARAM.SHAPE = O_PARAM.SHAPE
                          --!     I_PARAM.SHAPE = B_PARAM.SHAPE
                          --!     I_PARAM.ELEM_BITS <= O_PARAM.ELEM_BITS (桁あふれに注意)
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT PIPELINE DATA PARAMETER :
                          --! パイプラインデータ出力ポートのパラメータを指定する.
                          --! * 次の条件を満していなければならない.
                          --!     O_PARAM.SHAPE = I_PARAM.SHAPE
                          --!     O_PARAM.SHAPE = B_PARAM.SHAPE
                          --!     O_PARAM.ELEM_BITS >= I_PARAM.ELEM_BITS (桁あふれに注意)
                          --!     O_PARAM.ELEM_BITS >= B_PARAM.ELEM_BITS (桁あふれに注意)
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        B_PARAM         : --! @brief INPUT PIPELINE BIAS DATA PARAMETER :
                          --! バイアスデータ入力ポートのパラメータを指定する.
                          --! * 次の条件を満していなければならない.
                          --!     B_PARAM.SHAPE = I_PARAM.SHAPE
                          --!     B_PARAM.SHAPE = O_PARAM.SHAPE
                          --!     B_PARAM.ELEM_BITS <= O_PARAM.ELEM_BITS (桁あふれに注意)
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        QUEUE_SIZE      : --! パイプラインレジスタの深さを指定する.
                          --! * QUEUE_SIZE=0 の場合は出力にキューが挿入されずダイレ
                          --!   クトに出力される.
                          integer := 2;
        SIGN            : --! 演算時の正負符号の有無を指定する.
                          --! * SIGN=TRUE  の場合、符号有り(  signed)で計算する.
                          --! * SIGN=FALSE の場合、符号無し(unsigned)で計算する.
                          boolean := TRUE
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
        I_DATA          : --! @brief INPUT CONVOLUTION PIPELINE DATA :
                          --! パイプラインデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT CONVOLUTION PIPELINE DATA VALID :
                          --! 入力パイプラインデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でパイプラインデータが
                          --!   取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT CONVOLUTION PIPELINE DATA READY :
                          --! 入力パイプラインデータレディ信号.
                          --! * 次のパイプラインデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でパイプラインデータが
                          --!   取り込まれる.
                          out std_logic;
        B_DATA          : --! @brief INPUT CONVOLUTION PIPELINE BIAS DATA :
                          --! バイアスデータ入力.
                          in  std_logic_vector(B_PARAM.DATA.SIZE-1 downto 0);
        B_VALID         : --! @brief INPUT CONVOLUTION PIPELINE BIAS DATA VALID :
                          --! 入力バイアスデータ有効信号.
                          --! * B_DATAが有効であることを示す.
                          --! * B_VALID='1'and B_READY='1'でバイアスデータが
                          --!   取り込まれる.
                          in  std_logic;
        B_READY         : --! @brief INPUT CONVOLUTION PIPELINE BIAS DATA READY :
                          --! 入力バイアスデータレディ信号.
                          --! * 次のバイアスデータを入力出来ることを示す.
                          --! * B_VALID='1'and B_READY='1'でバイアスデータが
                          --!   取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT CONVOLUTION PIPELINE DATA :
                          --! パイプラインデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT CONVOLUTION PIPELINE DATA VALID :
                          --! 出力パイプラインデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でパイプラインデータが
                          --!   キューから取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT CONVOLUTION PIPELINE DATA READY :
                          --! 出力パイプラインデータレディ信号.
                          --! * O_VALID='1'and O_READY='1'でパイプラインデータが
                          --!   キューから取り除かれる.
                          in  std_logic
    );
end CONVOLUTION_INT_ACCUMULATOR;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER;
architecture RTL of CONVOLUTION_INT_ACCUMULATOR is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   I_ELEM_TYPE     is std_logic_vector(I_PARAM.ELEM_BITS-1 downto 0);
    type      I_ELEM_VECTOR   is array(0 to I_PARAM.SHAPE.Y.SIZE-1,
                                       0 to I_PARAM.SHAPE.X.SIZE-1,
                                       0 to I_PARAM.SHAPE.D.SIZE-1,
                                       0 to I_PARAM.SHAPE.C.SIZE-1) of I_ELEM_TYPE;
    signal    i_element       :  I_ELEM_VECTOR;
    signal    i_c_valid       :  std_logic_vector(I_PARAM.SHAPE.C.SIZE-1 downto 0);
    signal    i_c_start       :  std_logic;
    signal    i_c_last        :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   B_ELEM_TYPE     is std_logic_vector(B_PARAM.ELEM_BITS-1 downto 0);
    type      B_ELEM_VECTOR   is array(0 to B_PARAM.SHAPE.Y.SIZE-1,
                                       0 to B_PARAM.SHAPE.X.SIZE-1,
                                       0 to B_PARAM.SHAPE.D.SIZE-1,
                                       0 to B_PARAM.SHAPE.C.SIZE-1) of B_ELEM_TYPE;
    signal    b_element       :  B_ELEM_VECTOR;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   O_ELEM_TYPE     is std_logic_vector(O_PARAM.ELEM_BITS-1 downto 0);
    type      O_ELEM_VECTOR   is array(0 to O_PARAM.SHAPE.Y.SIZE-1,
                                       0 to O_PARAM.SHAPE.X.SIZE-1,
                                       0 to O_PARAM.SHAPE.D.SIZE-1,
                                       0 to O_PARAM.SHAPE.C.SIZE-1) of O_ELEM_TYPE;
    function  O_ELEM_NULL     return O_ELEM_VECTOR is
        variable elem         :  O_ELEM_VECTOR;
    begin
        for y in 0 to O_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to O_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to O_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
            elem(y,x,d,c) := (others => '0');
        end loop;
        end loop;
        end loop;
        end loop;
        return elem;
    end function;
    signal    q_element       :  O_ELEM_VECTOR;
    signal    a_element       :  O_ELEM_VECTOR;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_c_valid       :  std_logic_vector(O_PARAM.SHAPE.C.SIZE-1 downto 0);
    signal    a_c_valid       :  std_logic_vector(O_PARAM.SHAPE.C.SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    a_valid         :  std_logic;
    signal    a_ready         :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_data          :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    signal    q_valid         :  std_logic;
    signal    q_ready         :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- i_element : 入力パイプラインデータを要素ごとの配列に変換
    -- i_c_valid : 入力パイプラインデータのチャネル有効信号
    -- i_c_start : 入力パイプラインデータの最初のチャネルデータであることを示す信号
    -- i_c_last  : 入力パイプラインデータの最後のチャネルデータであることを示す信号
    -------------------------------------------------------------------------------
    process (I_DATA)
        variable c_atrb :  IMAGE_STREAM_ATRB_TYPE;
    begin
        for y in 0 to I_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to I_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to I_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to I_PARAM.SHAPE.C.SIZE-1 loop
            i_element(y,x,d,c) <= GET_ELEMENT_FROM_IMAGE_STREAM_DATA(I_PARAM, c, d, x, y, I_DATA);
        end loop;
        end loop;
        end loop;
        end loop;
        for c_pos in 0 to I_PARAM.SHAPE.C.SIZE-1 loop
            c_atrb := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(I_PARAM, c_pos + I_PARAM.SHAPE.C.LO, I_DATA);
            if (c_atrb.VALID) then
                i_c_valid(c_pos) <= '1';
            else
                i_c_valid(c_pos) <= '0';
            end if;
        end loop;
        if (IMAGE_STREAM_DATA_IS_START_C(I_PARAM, I_DATA, FALSE)) then
            i_c_start <= '1';
        else
            i_c_start <= '0';
        end if;
        if (IMAGE_STREAM_DATA_IS_LAST_C (I_PARAM, I_DATA, FALSE)) then
            i_c_last  <= '1';
        else
            i_c_last  <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- b_element : バイアスデータを要素ごとの配列に変換
    -------------------------------------------------------------------------------
    process (B_DATA) begin
        for y in 0 to B_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to B_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to B_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to B_PARAM.SHAPE.C.SIZE-1 loop
            b_element(y,x,d,c) <= GET_ELEMENT_FROM_IMAGE_STREAM_DATA(B_PARAM, c, d, x, y, B_DATA);
        end loop;
        end loop;
        end loop;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- a_valid : 積算結果が有効であることを示す信号
    --           入力パイプラインデータの最初のチャネル入力の時はバイアスデータ入力
    --           も有効でなければならない.
    -------------------------------------------------------------------------------
    a_valid  <= '1' when (i_c_start = '1' and I_VALID = '1' and B_VALID = '1') or
                         (i_c_start = '0' and I_VALID = '1'                  ) else '0';
    -------------------------------------------------------------------------------
    -- a_ready : 積算結果がレジスタにロード可能な状態であることを示す信号
    --           入力パイプラインデータの最後のチャネル入力の時は積算結果をパイプラ
    --           インレジスタにもロードしなければならない.
    -------------------------------------------------------------------------------
    a_ready  <= '1' when (i_c_last  = '1' and q_ready = '1') or
                         (i_c_last  = '0'                  ) else '0';
    -------------------------------------------------------------------------------
    -- q_valid : 積算結果をパイプラインレジスタにロードすることを示す信号.
    --           入力パイプラインデータの最後のチャネル入力の時は積算結果をパイプラ
    --           インレジスタにロードしなければならない.
    -------------------------------------------------------------------------------
    q_valid  <= '1' when (i_c_last  = '1' and a_valid = '1') else '0';
    -------------------------------------------------------------------------------
    -- I_READY : 入力パイプラインデータレディ信号
    -------------------------------------------------------------------------------
    I_READY  <= '1' when (                    a_valid = '1' and a_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- B_READY : 入力バイアスデータレディ信号
    --           バイアスデータは入力パイプラインデータの最初のチャネル入力の時のみ有効.
    -------------------------------------------------------------------------------
    B_READY  <= '1' when (i_c_start = '1' and a_valid = '1' and a_ready = '1') else '0';
    -------------------------------------------------------------------------------
    -- a_element : 積算結果
    -------------------------------------------------------------------------------
    process (i_element, b_element, q_element, i_c_start, i_c_valid)
        variable bias  :  std_logic_vector(O_PARAM.ELEM_BITS-1 downto 0);
        variable data  :  std_logic_vector(O_PARAM.ELEM_BITS-1 downto 0);
    begin
        for y in 0 to O_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to O_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to O_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
            if (SIGN) then
                if (i_c_start = '1') then
                    bias := std_logic_vector(resize(to_01(  signed(b_element(y,x,d,c))), O_PARAM.ELEM_BITS));
                else
                    bias := std_logic_vector(resize(to_01(  signed(q_element(y,x,d,c))), O_PARAM.ELEM_BITS));
                end if;
                if (i_c_valid(c) = '1') then
                    data := std_logic_vector(resize(to_01(  signed(i_element(y,x,d,c))), O_PARAM.ELEM_BITS));
                else
                    data := (others => '0');
                end if;
                a_element(y,x,d,c) <= std_logic_vector(  signed(data) +   signed(bias));
            else
                if (i_c_start = '1') then
                    bias := std_logic_vector(resize(to_01(unsigned(b_element(y,x,d,c))), O_PARAM.ELEM_BITS));
                else
                    bias := std_logic_vector(resize(to_01(unsigned(q_element(y,x,d,c))), O_PARAM.ELEM_BITS));
                end if;
                if (i_c_valid(c) = '1') then
                    data := std_logic_vector(resize(to_01(unsigned(i_element(y,x,d,c))), O_PARAM.ELEM_BITS));
                else
                    data := (others => '0');
                end if;
                a_element(y,x,d,c) <= std_logic_vector(unsigned(data) + unsigned(bias));
            end if;
        end loop;
        end loop;
        end loop;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- a_c_valid : チャネル有効情報
    -------------------------------------------------------------------------------
    a_c_valid <= i_c_valid when (i_c_start = '1') else i_c_valid or q_c_valid;
    -------------------------------------------------------------------------------
    -- q_element : 積算結果を保持するレジスタ
    -- q_c_valid : チャネル有効情報を保持するレジスタ
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                q_element <= O_ELEM_NULL;
                q_c_valid <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                q_element <= O_ELEM_NULL;
                q_c_valid <= (others => '0');
            elsif (a_valid = '1' and a_ready = '1') then
                q_element <= a_element;
                q_c_valid <= a_c_valid;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- q_data    : パイプラインレジスタに入力するデータ
    -------------------------------------------------------------------------------
    process(a_element, I_DATA, a_c_valid)
        variable data     :  std_logic_vector(O_PARAM.DATA.SIZE   -1 downto 0);
        variable c_atrb   :  IMAGE_STREAM_ATRB_VECTOR(0 to O_PARAM.SHAPE.C.SIZE-1);
        variable c_start  :  boolean;
        variable c_last   :  boolean;
    begin
        for y in 0 to O_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to O_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to O_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
            SET_ELEMENT_TO_IMAGE_STREAM_DATA(O_PARAM, c, d, x, y, a_element(y,x,d,c), data);
        end loop;        
        end loop;        
        end loop;        
        end loop;
        for c in c_atrb'low to c_atrb'high loop
            c_atrb(c).VALID := (a_c_valid(c) = '1');
        end loop;
        c_start := TRUE;
        for c in c_atrb'low to c_atrb'high loop
            c_atrb(c).START := c_start;
            if (c_atrb(c).VALID) then
                c_start := FALSE;
            end if;
        end loop;
        c_last := TRUE;
        for c in c_atrb'high to c_atrb'low loop
            c_atrb(c).LAST := c_last;
            if (c_atrb(c).VALID) then
                c_last := FALSE;
            end if;
        end loop;
        for c in c_atrb'low to c_atrb'high loop
            SET_ATRB_C_TO_IMAGE_STREAM_DATA(O_PARAM, c + O_PARAM.SHAPE.C.LO, c_atrb(c), data);
        end loop;
        if (O_PARAM.DATA.ATRB_FIELD.D.SIZE > 0) then
            data(O_PARAM.DATA.ATRB_FIELD.D.HI downto O_PARAM.DATA.ATRB_FIELD.D.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.D.HI downto I_PARAM.DATA.ATRB_FIELD.D.LO);
        end if;
        if (O_PARAM.DATA.ATRB_FIELD.X.SIZE > 0) then
            data(O_PARAM.DATA.ATRB_FIELD.X.HI downto O_PARAM.DATA.ATRB_FIELD.X.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.X.HI downto I_PARAM.DATA.ATRB_FIELD.X.LO);
        end if;
        if (O_PARAM.DATA.ATRB_FIELD.Y.SIZE > 0) then
            data(O_PARAM.DATA.ATRB_FIELD.Y.HI downto O_PARAM.DATA.ATRB_FIELD.Y.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.Y.HI downto I_PARAM.DATA.ATRB_FIELD.Y.LO);
        end if;
        if (O_PARAM.INFO_BITS > 0) then
            data(O_PARAM.DATA.INFO_FIELD.HI   downto O_PARAM.DATA.INFO_FIELD.LO  ) := I_DATA(I_PARAM.DATA.INFO_FIELD.HI   downto I_PARAM.DATA.INFO_FIELD.LO  );
        end if;
        q_data <= data;
    end process;
    -------------------------------------------------------------------------------
    -- パイプラインレジスタ
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
            I_WORD      => q_data            , -- In  :
            I_VAL       => q_valid           , -- In  :
            I_RDY       => q_ready           , -- Out :
            Q_WORD      => O_DATA            , -- Out :
            Q_VAL       => O_VALID           , -- Out :
            Q_RDY       => O_READY           , -- In  :
            BUSY        => open                -- Out :
        );                                     -- 
end RTL;
