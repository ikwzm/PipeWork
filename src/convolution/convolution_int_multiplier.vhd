-----------------------------------------------------------------------------------
--!     @file    convolution_int_multiplier.vhd
--!     @brief   Convolution Integer Multiplier Module
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
--! @brief Convolution Integer Multiplier Module
-----------------------------------------------------------------------------------
entity  CONVOLUTION_INT_MULTIPLIER is
    generic (
        I_PARAM         : --! @brief INPUT  CONVOLUTION PIPELINE IMAGE DATA PARAMETER :
                          --! パイプラインデータ入力ポートのパラメータを指定する.
                          --! * 次の条件を満していなければならない.
                          --!     I_PARAM.SHAPE = O_PARAM.SHAPE
                          --!     I_PARAM.SHAPE = W_PARAM.SHAPE
                          --!     I_PARAM.ELEM_BITS+W_PARAM.ELEM_BITS <= O_PARAM.ELEM_BITS (桁あふれに注意)
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        W_PARAM         : --! @brief INPUT  CONVOLUTION PIPELINE WEIGHT DATA PARAMETER :
                          --! パイプラインデータ入力ポートのパラメータを指定する.
                          --! * 次の条件を満していなければならない.
                          --!     W_PARAM.SHAPE = I_PARAM.SHAPE
                          --!     W_PARAM.SHAPE = O_PARAM.SHAPE
                          --!     W_PARAM.ELEM_BITS+I_PARAM.ELEM_BITS <= O_PARAM.ELEM_BITS (桁あふれに注意)
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT CONVOLUTION PIPELINE DATA PARAMETER :
                          --! パイプラインデータ出力ポートのパラメータを指定する.
                          --! * 次の条件を満していなければならない.
                          --!     O_PARAM.SHAPE = I_PARAM.SHAPE
                          --!     O_PARAM.SHAPE = W_PARAM.SHAPE
                          --!     O_PARAM.ELEM_BITS >= I_PARAM.ELEM_BITS+W_PARAM.ELEM_BITS (桁あふれに注意)
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
        I_DATA          : --! @brief INPUT CONVOLUTION PIPELINE IMAGE DATA :
                          --! パイプラインデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT CONVOLUTION PIPELINE IMAGE DATA VALID :
                          --! 入力パイプラインデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でパイプラインデータが
                          --!   取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT CONVOLUTION PIPELINE IMAGE DATA READY :
                          --! 入力パイプラインデータレディ信号.
                          --! * 次のパイプラインデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でパイプラインデータが
                          --!   取り込まれる.
                          out std_logic;
        W_DATA          : --! @brief INPUT CONVOLUTION PIPELINE WEIGHT DATA :
                          --! パイプラインデータ入力.
                          in  std_logic_vector(W_PARAM.DATA.SIZE-1 downto 0);
        W_VALID         : --! @brief INPUT CONVOLUTION PIPELINE WEIGHT DATA VALID :
                          --! 入力パイプラインデータ有効信号.
                          --! * W_DATAが有効であることを示す.
                          --! * W_VALID='1'and W_READY='1'でパイプラインデータが
                          --!   取り込まれる.
                          in  std_logic;
        W_READY         : --! @brief INPUT CONVOLUTION PIPELINE WEIGHT DATA READY :
                          --! 入力パイプラインデータレディ信号.
                          --! * 次のパイプラインデータを入力出来ることを示す.
                          --! * W_VALID='1'and W_READY='1'でパイプラインデータが
                          --!   取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT CONVOLUTION PIPELINE IMAGE DATA :
                          --! パイプラインデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT CONVOLUTION PIPELINE IMAGE DATA VALID :
                          --! 出力パイプラインデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でパイプラインデータが
                          --!   キューから取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT CONVOLUTION PIPELINE IMAGE DATA READY :
                          --! 出力パイプラインデータレディ信号.
                          --! * O_VALID='1'and O_READY='1'でパイプラインデータが
                          --!   キューから取り除かれる.
                          in  std_logic
    );
end CONVOLUTION_INT_MULTIPLIER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER;
architecture RTL of CONVOLUTION_INT_MULTIPLIER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   I_ELEM_TYPE     is std_logic_vector(I_PARAM.ELEM_BITS-1 downto 0);
    type      I_ELEM_VECTOR   is array(0 to I_PARAM.SHAPE.Y.SIZE-1,
                                       0 to I_PARAM.SHAPE.X.SIZE-1,
                                       0 to I_PARAM.SHAPE.D.SIZE-1,
                                       0 to I_PARAM.SHAPE.C.SIZE-1) of I_ELEM_TYPE;
    signal    i_element       :  I_ELEM_VECTOR;
    signal    i_c_atrb        :  IMAGE_STREAM_ATRB_VECTOR(0 to I_PARAM.SHAPE.C.SIZE-1);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   W_ELEM_TYPE     is std_logic_vector(W_PARAM.ELEM_BITS-1 downto 0);
    type      W_ELEM_VECTOR   is array(0 to W_PARAM.SHAPE.Y.SIZE-1,
                                       0 to W_PARAM.SHAPE.X.SIZE-1,
                                       0 to W_PARAM.SHAPE.D.SIZE-1,
                                       0 to W_PARAM.SHAPE.C.SIZE-1) of W_ELEM_TYPE;
    signal    w_element       :  W_ELEM_VECTOR;
    signal    w_c_atrb        :  IMAGE_STREAM_ATRB_VECTOR(0 to W_PARAM.SHAPE.C.SIZE-1);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   O_ELEM_TYPE     is std_logic_vector(O_PARAM.ELEM_BITS-1 downto 0);
    type      O_ELEM_VECTOR   is array(0 to O_PARAM.SHAPE.Y.SIZE-1,
                                       0 to O_PARAM.SHAPE.X.SIZE-1,
                                       0 to O_PARAM.SHAPE.D.SIZE-1,
                                       0 to O_PARAM.SHAPE.C.SIZE-1) of O_ELEM_TYPE;
    signal    o_element       :  O_ELEM_VECTOR;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_data          :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    signal    q_valid         :  std_logic;
    signal    q_ready         :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- i_element : 入力パイプラインイメージデータを要素ごとの配列に変換
    -- i_c_valid : 入力パイプラインイメージデータのチャネル有効信号
    -------------------------------------------------------------------------------
    process (I_DATA) begin
        for y in 0 to I_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to I_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to I_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to I_PARAM.SHAPE.C.SIZE-1 loop
            i_element(y,x,d,c) <= GET_ELEMENT_FROM_IMAGE_STREAM_DATA(I_PARAM, c, d, x, y, I_DATA);
        end loop;
        end loop;
        end loop;
        end loop;
        i_c_atrb <= GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(I_PARAM, I_DATA);
    end process;
    -------------------------------------------------------------------------------
    -- w_element : 入力パイプライン重みデータを要素ごとの配列に変換
    -- w_c_valid : 入力パイプライン重みデータのチャネル有効信号
    -------------------------------------------------------------------------------
    process (W_DATA) begin
        for y in 0 to W_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to W_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to W_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to W_PARAM.SHAPE.C.SIZE-1 loop
            w_element(y,x,d,c) <= GET_ELEMENT_FROM_IMAGE_STREAM_DATA(W_PARAM, c, d, x, y, W_DATA);
        end loop;
        end loop;
        end loop;
        end loop;
        w_c_atrb <= GET_ATRB_C_VECTOR_FROM_IMAGE_STREAM_DATA(W_PARAM, W_DATA);
    end process;
    -------------------------------------------------------------------------------
    -- o_element : 乗算結果
    -------------------------------------------------------------------------------
    process(i_element, i_c_atrb, w_element, w_c_atrb)
        variable i_elem  :  I_ELEM_TYPE;
        variable w_elem  :  W_ELEM_TYPE;
    begin
        for y in 0 to O_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to O_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to O_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
            if (i_c_atrb(c).VALID = TRUE) then
                i_elem := i_element(y,x,d,c);
            else
                i_elem := (others => '0');
            end if;
            if (w_c_atrb(c).VALID = TRUE) then
                w_elem := w_element(y,x,d,c);
            else
                w_elem := (others => '0');
            end if;
            if (SIGN) then
                o_element(y,x,d,c) <= std_logic_vector(to_01(  signed(i_elem)) *
                                                       to_01(  signed(w_elem)));
            else
                o_element(y,x,d,c) <= std_logic_vector(to_01(unsigned(i_elem)) *
                                                       to_01(unsigned(w_elem)));
            end if;
        end loop;
        end loop;
        end loop;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- q_data    : パイプラインレジスタに入力するデータ
    -------------------------------------------------------------------------------
    process (o_element, I_DATA)
        variable data :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
    begin
        for y in 0 to O_PARAM.SHAPE.Y.SIZE-1 loop
        for x in 0 to O_PARAM.SHAPE.X.SIZE-1 loop
        for d in 0 to O_PARAM.SHAPE.D.SIZE-1 loop
        for c in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
            SET_ELEMENT_TO_IMAGE_STREAM_DATA(O_PARAM, c, d, x, y, o_element(y,x,d,c), data);
        end loop;        
        end loop;        
        end loop;        
        end loop;
        if (O_PARAM.DATA.ATRB_FIELD.SIZE > 0) then
            data(O_PARAM.DATA.ATRB_FIELD.HI downto O_PARAM.DATA.ATRB_FIELD.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.HI downto I_PARAM.DATA.ATRB_FIELD.LO);
        end if;
        if (O_PARAM.DATA.INFO_FIELD.SIZE > 0) then
            data(O_PARAM.DATA.INFO_FIELD.HI downto O_PARAM.DATA.INFO_FIELD.LO) := I_DATA(I_PARAM.DATA.INFO_FIELD.HI downto I_PARAM.DATA.INFO_FIELD.LO);
        end if;
        q_data <= data;
    end process;
    -------------------------------------------------------------------------------
    -- q_valid   : 
    -------------------------------------------------------------------------------
    q_valid <= '1' when (I_VALID = '1' and W_VALID = '1') else '0';
    I_READY <= '1' when (q_valid = '1' and q_ready = '1') else '0';
    W_READY <= '1' when (q_valid = '1' and q_ready = '1') else '0';
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
