-----------------------------------------------------------------------------------
--!     @file    pipeline_register_controller.vhd
--!     @brief   PIPELINE REGISTER CONTROLLER MODULE :
--!              パイプラインレジスタ制御モジュール
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
--! @brief   PIPELINE REGISTER CONTROLLER
--!          パイプラインレジスタ制御モジュール
-----------------------------------------------------------------------------------
entity  PIPELINE_REGISTER_CONTROLLER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数
    -------------------------------------------------------------------------------
    generic (
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
    -- レジスタ制御
    -------------------------------------------------------------------------------
        LOAD        : --! @brief REGISTER LOAD :
                      --! パイプラインレジスタロード信号.
                      --! * パイプラインレジスタにデータをロードすることを指示する
                      --!   出力信号.
                      --! * パイプラインレジスタは1〜QUEUE_SIZEまであるが、対応する
                      --!   位置の信号が'1'ならばパイプラインレジスタにロードするこ
                      --!   とを示す.
                      --! * この出力信号の範囲が1からではなく0から始まっている事に
                      --!   注意. これはQUEUE_SIZE=0の場合に対応するため.
                      --! * QUEUE_SIZE>=1 の場合、LOAD(0) は LOAD(1) と同じ値を出力
                      --!   する.
                      out std_logic_vector(QUEUE_SIZE downto 0);
        SHIFT       : --! @brief REGISTER SHIFT :
                      --! パイプラインレジスタシフト信号.
                      --! * QUEUE_SIZE>=2 のパイプラインレジスタにおいて、パイプ
                      --!   ラインレジスタの内容を出力方向にシフトすることを示す
                      --!   出力信号.
                      --! * LOAD(i)='1' and SHIFT(i)='1' でキューの i+1 の内容を
                      --!   i にロードする.
                      --! * LOAD(i)='1' and SHIFT(i)='0' で前段のパイプラインレジ
                      --!   スタからの演算結果を i にロードする.
                      --! * QUEUE_SIZE<2 の場合、SHIFT 信号は全て'0'を出力する.
                      out std_logic_vector(QUEUE_SIZE downto 0);
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
end PIPELINE_REGISTER_CONTROLLER;
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of PIPELINE_REGISTER_CONTROLLER is
begin
    -------------------------------------------------------------------------------
    --  QUEUE_SIZE=0の場合はなにもしない
    -------------------------------------------------------------------------------
    QUEUE_SIZE_EQ_0: if (QUEUE_SIZE = 0) generate
        Q_VAL    <= I_VAL;
        I_RDY    <= Q_RDY;
        VALID(0) <= I_VAL and Q_RDY;
        LOAD (0) <= I_VAL and Q_RDY;
        SHIFT(0) <= '0';
        BUSY     <= '0';
    end generate;
    -------------------------------------------------------------------------------
     -- QUEUE_SIZE=1の場合
    -------------------------------------------------------------------------------
    QUEUE_SIZE_EQ_1: if (QUEUE_SIZE = 1) generate
        signal   q_valid  : std_logic;
        signal   i_ready  : std_logic;
    begin
        Q_VAL    <= q_valid;
        I_RDY    <= i_ready;
        i_ready  <= '1' when (q_valid = '0') or
                             (q_valid = '1' and Q_RDY   = '1') else '0';
        LOAD (0) <= '1' when (I_VAL   = '1' and i_ready = '1') else '0';
        LOAD (1) <= '1' when (I_VAL   = '1' and i_ready = '1') else '0';
        SHIFT(0) <= '0';
        SHIFT(1) <= '0';
        VALID(0) <= q_valid;
        VALID(1) <= q_valid;
        BUSY     <= q_valid;
        process (CLK, RST) begin
            if    (RST = '1') then
                       q_valid <= '0';
            elsif (CLK'event and CLK = '1') then
               if (CLR = '1') then
                       q_valid <= '0';
               elsif (q_valid = '0') then
                   if (I_VAL = '1') then
                       q_valid <= '1';
                   else
                       q_valid <= '0';
                   end if;
               else
                   if (I_VAL = '0' and Q_RDY = '1') then
                       q_valid <= '0';
                   else
                       q_valid <= '1';
                   end if;
               end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
     -- QUEUE_SIZE>1の場合
    -------------------------------------------------------------------------------
    QUEUE_SIZE_GT_1: if (QUEUE_SIZE > 1) generate
        constant FIRST_OF_QUEUE     : integer := 1;
        constant LAST_OF_QUEUE      : integer := QUEUE_SIZE;
        signal   queue_data_load    : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   queue_data_shift   : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   next_queue_valid   : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   curr_queue_valid   : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
    begin
        ---------------------------------------------------------------------------
        -- next_queue_valid : 次のクロックでのキューの状態を示すフラグ.
        -- queue_data_load  : 次のクロックでcurr_queue_dataにnext_queue_dataの値を
        --                    ロードすることを示すフラグ.
        ---------------------------------------------------------------------------
        process (I_VAL, Q_RDY, curr_queue_valid) begin
            for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                -------------------------------------------------------------------
                -- 自分のキューにデータが格納されている場合...
                -------------------------------------------------------------------
                if (curr_queue_valid(i) = '1') then
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後ならば、
                    -- Q_RDY='1'で自分のキューをクリアする.
                    ---------------------------------------------------------------
                    if (i = LAST_OF_QUEUE) then
                        if (Q_RDY = '1') then
                            next_queue_valid(i) <= '0';
                        else
                            next_queue_valid(i) <= '1';
                        end if;
                        queue_data_load(i) <= '0';
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後でなくて、
                    -- かつ後ろのキューにデータが入っているならば、
                    -- Q_RDY='1'で後ろのキューのデータを自分のキューに格納する.
                    ---------------------------------------------------------------
                    elsif (curr_queue_valid(i+1) = '1') then
                        next_queue_valid(i) <= '1';
                        if (Q_RDY = '1') then
                            queue_data_load(i) <= '1';
                        else
                            queue_data_load(i) <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後でなくて、
                    -- かつ後ろのキューにデータが入っていないならば、
                    -- I_VAL='0' かつ Q_RDY='1'ならば自分のキューをクリアする. 
                    -- I_VAL='1' かつ Q_RDY='1'ならばI_DATAを自分のキューに格納する.
                    ---------------------------------------------------------------
                    else
                        if (I_VAL = '0' and Q_RDY = '1') then
                            next_queue_valid(i) <= '0';
                        else
                            next_queue_valid(i) <= '1';
                        end if;
                        if (I_VAL = '1' and Q_RDY = '1') then
                            queue_data_load(i)  <= '1';
                        else
                            queue_data_load(i)  <= '0';
                        end if;
                    end if;
                -------------------------------------------------------------------
                -- 自分のところにデータが格納されていない場合...
                -------------------------------------------------------------------
                else -- if (curr_queue_valid(i) = '0') then
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭ならば、
                    -- I_VAL='1'で自分のキューにデータを格納する.
                    ---------------------------------------------------------------
                    if    (i = FIRST_OF_QUEUE) then
                        if (I_VAL = '1') then
                            next_queue_valid(i) <= '1';
                            queue_data_load(i)  <= '1';
                        else
                            next_queue_valid(i) <= '0';
                            queue_data_load(i)  <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭なくて、
                    -- かつ前のキューにデータが格納されているならば、
                    -- I_VAL='1'かつQ_RDY='0'で自分のキューにデータを格納する.
                    ---------------------------------------------------------------
                    elsif (curr_queue_valid(i-1) = '1') then
                        if (I_VAL = '1' and Q_RDY = '0') then
                            next_queue_valid(i) <= '1';
                        else
                            next_queue_valid(i) <= '0';
                        end if;
                        if (I_VAL = '1' and Q_RDY = '0') then
                            queue_data_load(i)  <= '1';
                        else
                            queue_data_load(i)  <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭なくて、
                    -- かつ前のキューにデータが格納されていないならば、
                    -- キューは空のまま.
                    ---------------------------------------------------------------
                    else
                            next_queue_valid(i) <= '0';
                            queue_data_load(i)  <= '0';
                    end if;
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- queue_data_shift : 
        ---------------------------------------------------------------------------
        process (curr_queue_valid) begin
            for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                if    (i = LAST_OF_QUEUE) then
                    queue_data_shift(i) <= '0';
                elsif (curr_queue_valid(i+1) = '1') then
                    queue_data_shift(i) <= '1';
                else
                    queue_data_shift(i) <= '0';
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- curr_queue_valid : 現在、キューにデータが格納されていることを示すフラグ.
        -- I_RDY            : キューにデータが格納することが出来ることを示すフラグ.
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if     (RST = '1') then
                   curr_queue_valid <= (others => '0');
                   I_RDY            <= '0';
            elsif  (CLK'event and CLK = '1') then
               if (CLR = '1') then
                   curr_queue_valid <= (others => '0');
                   I_RDY            <= '0';
               else
                   curr_queue_valid <= next_queue_valid;
                   I_RDY            <= not next_queue_valid(LAST_OF_QUEUE);
               end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- 各種出力信号
        ---------------------------------------------------------------------------
        Q_VAL                      <= curr_queue_valid(FIRST_OF_QUEUE);
        VALID(0)                   <= curr_queue_valid(FIRST_OF_QUEUE);
        VALID(QUEUE_SIZE downto 1) <= curr_queue_valid;
        LOAD (0)                   <= queue_data_load (FIRST_OF_QUEUE);
        LOAD (QUEUE_SIZE downto 1) <= queue_data_load;
        SHIFT(0)                   <= queue_data_shift(FIRST_OF_QUEUE);
        SHIFT(QUEUE_SIZE downto 1) <= queue_data_shift;
        BUSY                       <= curr_queue_valid(FIRST_OF_QUEUE);
    end generate;
end RTL;

        
