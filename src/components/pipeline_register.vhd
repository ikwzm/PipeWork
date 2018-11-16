-----------------------------------------------------------------------------------
--!     @file    pipeline_register.vhd
--!     @brief   PIPELINE REGISTER MODULE :
--!              パイプラインレジスタモジュール
--!     @version 1.7.0
--!     @date    2018/6/14
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
-----------------------------------------------------------------------------------
--! @brief   PIPELINE REGISTER 
--!          パイプラインレジスタモジュール
-----------------------------------------------------------------------------------
entity  PIPELINE_REGISTER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数
    -------------------------------------------------------------------------------
    generic (
        WORD_BITS   : --! @brief WORD BITS :
                      --! １ワードのビット数を指定する.
                      integer := 8;
        QUEUE_SIZE  : --! @brief QUEUE SIZE :
                      --! キューの大きさを指定する.
                      integer := 1
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
    -- 入力側
    -------------------------------------------------------------------------------
        I_WORD      : --! @brief INPUT WORD :
                      --! パイプラインレジスタ入力ワード信号.
                      --! * 前段のパイプラインレジスタからのワード入力信号.
                      in  std_logic_vector(WORD_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT VALID :
                      --! パイプラインレジスタ入力有効信号.
                      --! * 前段のパイプラインレジスタから、入力が有効であることを
                      --!   示す入力信号.
                      in  std_logic;
        I_RDY       : --! @brief INPUT READY :
                      --! パイプラインレジスタ入力可能信号.
                      --! * 前段のパイプラインレジスタへ、キューが空いていて入力を
                      --!   受け付けることが可能であることを示す出力信号.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側
    -------------------------------------------------------------------------------
        Q_WORD      : --! @brief OUTPUT WORD :
                      --! パイプラインレジスタ出力ワード信号.
                      --! * 後段のパイプラインレジスタへのワード出力信号.
                      out std_logic_vector(WORD_BITS-1 downto 0);
        Q_VAL       : --! @brief OUTPUT VALID :
                      --! パイプラインレジスタ出力有効信号.
                      --! * 後段のパイプラインレジスタへ、有効なデータが入っている
                      --!   事を示す出力信号.
                      out std_logic;
        Q_RDY       : --! @brief OUTPUT READY :
                      --! パイプラインレジスタ出力可能信号
                      --! * 後段のパイプラインレジスタから、入力を受け付けることが
                      --!   可能であることを示す入力信号.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- ステータス
    -------------------------------------------------------------------------------
        VALID       : --! @brief QUEUE VALID :
                      --! パイプラインレジスタ有効信号.
                      --! * パイプラインレジスタに有効なデータが入っていることを示
                      --!   す信号.
                      --! * この出力信号の範囲が1からではなく0から始まっている事に
                      --!   注意. これはQUEUE_SIZE=0の場合に対応するため.
                      --! * QUEUE_SIZE>=1 の場合、VALID(0) は VALID(1) と同じ値を出
                      --!   力する.
                      out std_logic_vector(QUEUE_SIZE downto 0);
        BUSY        : --! @brief QUEUE BUSY  :
                      out std_logic
    );
end PIPELINE_REGISTER;
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER_CONTROLLER;
architecture RTL of PIPELINE_REGISTER is
    signal    queue_load    :  std_logic_vector(QUEUE_SIZE downto 0);
    signal    queue_shift   :  std_logic_vector(QUEUE_SIZE downto 0);
begin
    -------------------------------------------------------------------------------
    --  QUEUE_SIZE=0の場合
    -------------------------------------------------------------------------------
    QUEUE_SIZE_EQ_0: if (QUEUE_SIZE = 0) generate
        Q_WORD <= I_WORD;
    end generate;
    -------------------------------------------------------------------------------
     -- QUEUE_SIZE=1の場合
    -------------------------------------------------------------------------------
    QUEUE_SIZE_EQ_1: if (QUEUE_SIZE = 1) generate
        process (CLK, RST) begin
            if (RST = '1') then
                    Q_WORD <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    Q_WORD <= (others => '0');
                elsif (queue_load(0) = '1') then
                    Q_WORD <= I_WORD;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
     -- QUEUE_SIZE>1の場合
    -------------------------------------------------------------------------------
    QUEUE_SIZE_GT_1: if (QUEUE_SIZE > 1) generate
        type      WORD_VECTOR    is array (integer range <>) of std_logic_vector(WORD_BITS-1 downto 0);
        constant  FIRST_OF_QUEUE :  integer := 1;
        constant  LAST_OF_QUEUE  :  integer := QUEUE_SIZE;
        signal    queue_word     :  WORD_VECTOR(LAST_OF_QUEUE downto FIRST_OF_QUEUE);
    begin
        process (CLK, RST) begin
            if (RST = '1') then
                    queue_word <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    queue_word <= (others => (others => '0'));
                else
                    for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                        if (queue_load(i) = '1') then
                            if (i < LAST_OF_QUEUE and queue_shift(i) = '1') then
                                queue_word(i) <= queue_word(i+1);
                            else
                                queue_word(i) <= I_WORD;
                            end if;
                        end if;
                    end loop;
                end if;
            end if;
        end process;
        Q_WORD <= queue_word(1);
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    CTRL: PIPELINE_REGISTER_CONTROLLER
        generic map (
            QUEUE_SIZE  => QUEUE_SIZE
        )
        port map (
            CLK         => CLK         , -- In  :
            RST         => RST         , -- In  :
            CLR         => CLR         , -- In  :
            I_VAL       => I_VAL       , -- In  :
            I_RDY       => I_RDY       , -- Out :
            Q_VAL       => Q_VAL       , -- Out :
            Q_RDY       => Q_RDY       , -- In  :
            LOAD        => queue_load  , -- Out :
            SHIFT       => queue_shift , -- Out :
            VALID       => VALID       , -- Out :
            BUSY        => BUSY          -- Out :
        );
end RTL;
