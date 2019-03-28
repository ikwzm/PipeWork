-----------------------------------------------------------------------------------
--!     @file    convolution_int_adder_tree.vhd
--!     @brief   Convolution Integer Adder Tree Module
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
--! @brief Convolution Integer Adder Tree
-----------------------------------------------------------------------------------
entity  CONVOLUTION_INT_ADDER_TREE is
    generic (
        I_PARAM         : --! @brief INPUT  PIPELINE DATA PARAMETER :
                          --! パイプラインデータ入力ポートのパラメータを指定する.
                          --! * 次の条件を満していなければならない.
                          --!     I_PARAM.SHAPE.C.SIZE >= O_PARAM.SHAPE.C.SIZE
                          --!     I_PARAM.SHAPE.D.SIZE  = O_PARAM.SHAPE.D.SIZE
                          --!     I_PARAM.SHAPE.X.SIZE  = O_PARAM.SHAPE.X.SIZE
                          --!     I_PARAM.SHAPE.Y.SIZE  = O_PARAM.SHAPE.Y.SIZE
                          --!     I_PARAM.ELEM_BITS    <= O_PARAM.ELEM_BITS (桁あふれに注意)
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,2,1,1);
        O_PARAM         : --! @brief OUTPUT PIPELINE DATA PARAMETER :
                          --! パイプラインデータ出力ポートのパラメータを指定する.
                          --! * 次の条件を満していなければならない.
                          --!     O_PARAM.SHAPE.C.SIZE <= I_PARAM.SHAPE.C.SIZE
                          --!     O_PARAM.SHAPE.D.SIZE  = I_PARAM.SHAPE.D.SIZE
                          --!     O_PARAM.SHAPE.X.SIZE  = I_PARAM.SHAPE.X.SIZE
                          --!     O_PARAM.SHAPE.Y.SIZE >= I_PARAM.SHAPE.Y.SIZE
                          --!     O_PARAM.ELEM_BITS    >= I_PARAM.ELEM_BITS (桁あふれに注意)
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
end CONVOLUTION_INT_ADDER_TREE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER;
architecture RTL of CONVOLUTION_INT_ADDER_TREE is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component CONVOLUTION_INT_ADDER
        generic (
            I_PARAM     : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,2,1,1);
            O_PARAM     : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
            QUEUE_SIZE  : integer := 2;
            SIGN        : boolean := TRUE
        );
        port (
            CLK         : in  std_logic; 
            RST         : in  std_logic;
            CLR         : in  std_logic;
            I_DATA      : in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
            I_VALID     : in  std_logic;
            I_READY     : out std_logic;
            O_DATA      : out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
            O_VALID     : out std_logic;
            O_READY     : in  std_logic
        );
    end component;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component CONVOLUTION_INT_ADDER_TREE
        generic (
            I_PARAM     : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,2,1,1);
            O_PARAM     : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
            QUEUE_SIZE  : integer := 2;
            SIGN        : boolean := TRUE
        );
        port (
            CLK         : in  std_logic; 
            RST         : in  std_logic;
            CLR         : in  std_logic;
            I_DATA      : in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
            I_VALID     : in  std_logic;
            I_READY     : out std_logic;
            O_DATA      : out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
            O_VALID     : out std_logic;
            O_READY     : in  std_logic
        );
    end component;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ROOT: if (I_PARAM.SHAPE.C.SIZE = O_PARAM.SHAPE.C.SIZE) generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (I_DATA)
            variable data   :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
            variable i_elem :  std_logic_vector(I_PARAM.ELEM_BITS-1 downto 0);
            variable o_elem :  std_logic_vector(O_PARAM.ELEM_BITS-1 downto 0);
        begin
            for y in 0 to O_PARAM.SHAPE.Y.SIZE-1 loop
            for x in 0 to O_PARAM.SHAPE.X.SIZE-1 loop
            for d in 0 to O_PARAM.SHAPE.D.SIZE-1 loop
            for c in 0 to O_PARAM.SHAPE.C.SIZE-1 loop
                i_elem := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(I_PARAM, c, d, x, y, I_DATA);
                if (SIGN) then
                    o_elem := std_logic_vector(resize(to_01(  signed(i_elem)), O_PARAM.ELEM_BITS));
                else
                    o_elem := std_logic_vector(resize(to_01(unsigned(i_elem)), O_PARAM.ELEM_BITS));
                end if;
                SET_ELEMENT_TO_IMAGE_STREAM_DATA(O_PARAM, c, d, x, y, o_elem, data);
            end loop;
            end loop;
            end loop;
            end loop;
            if (O_PARAM.DATA.ATRB_FIELD.SIZE > 0) then
                data(O_PARAM.DATA.ATRB_FIELD.HI downto O_PARAM.DATA.ATRB_FIELD.LO) := I_DATA(I_PARAM.DATA.ATRB_FIELD.HI downto I_PARAM.DATA.ATRB_FIELD.LO);
            end if;
            if (O_PARAM.INFO_BITS > 0) then
                data(O_PARAM.DATA.INFO_FIELD.HI downto O_PARAM.DATA.INFO_FIELD.LO) := I_DATA(I_PARAM.DATA.INFO_FIELD.HI downto I_PARAM.DATA.INFO_FIELD.LO);
            end if;
            O_DATA <= data;
        end process;
        O_VALID <= I_VALID;
        I_READY <= O_READY;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    TREE: if (I_PARAM.SHAPE.C.SIZE > O_PARAM.SHAPE.C.SIZE) generate
        constant  T_ELEM_BITS     :  integer := I_PARAM.ELEM_BITS+1;
        constant  T_SHAPE_C_SIZE  :  integer := (I_PARAM.SHAPE.C.SIZE + 1) / 2;
        constant  T_PARAM         :  IMAGE_STREAM_PARAM_TYPE 
                                  := NEW_IMAGE_STREAM_PARAM(
                                         ELEM_BITS => T_ELEM_BITS         ,
                                         INFO_BITS => I_PARAM.INFO_BITS   ,
                                         C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(T_SHAPE_C_SIZE),
                                         D         => I_PARAM.SHAPE.D,
                                         X         => I_PARAM.SHAPE.X,
                                         Y         => I_PARAM.SHAPE.Y
                                     );
        signal    t_data          :  std_logic_vector(T_PARAM.DATA.SIZE-1 downto 0);
        signal    t_valid         :  std_logic;
        signal    t_ready         :  std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ADDER: CONVOLUTION_INT_ADDER               -- 
            generic map (                          -- 
                I_PARAM     => I_PARAM           , -- 
                O_PARAM     => T_PARAM           , -- 
                QUEUE_SIZE  => QUEUE_SIZE        , -- 
                SIGN        => SIGN                -- 
            )                                      -- 
            port map (                             -- 
                CLK         => CLK               , -- In  :
                RST         => RST               , -- In  :
                CLR         => CLR               , -- In  :
                I_DATA      => I_DATA            , -- In  :
                I_VALID     => I_VALID           , -- In  :
                I_READY     => I_READY           , -- Out :
                O_DATA      => t_data            , -- Out :
                O_VALID     => t_valid           , -- Out :
                O_READY     => t_ready             -- In  :
            );                                     -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        NEXT_LEVEL: CONVOLUTION_INT_ADDER_TREE     -- 
            generic map (                          -- 
                I_PARAM     => T_PARAM           , -- 
                O_PARAM     => O_PARAM           , -- 
                QUEUE_SIZE  => QUEUE_SIZE        , -- 
                SIGN        => SIGN                -- 
            )                                      -- 
            port map (                             -- 
                CLK         => CLK               , -- In  :
                RST         => RST               , -- In  :
                CLR         => CLR               , -- In  :
                I_DATA      => t_data            , -- In  :
                I_VALID     => t_valid           , -- In  :
                I_READY     => t_ready           , -- Out :
                O_DATA      => O_DATA            , -- Out :
                O_VALID     => O_VALID           , -- Out :
                O_READY     => O_READY             -- In  :
            );
    end generate;
end RTL;
