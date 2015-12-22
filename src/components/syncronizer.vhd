-----------------------------------------------------------------------------------
--!     @file    syncronizer.vhd
--!     @brief   SYNCRONIZER MODULE :
--!              異なるクロックで動作するパスを継ぐアダプタのクロック同期化モジュール.
--!     @version 1.5.9
--!     @date    2015/12/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2015 Ichiro Kawazome
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
--! @brief   SYNCRONIZER
--!          異なるクロックで動作するパスを継ぐアダプタのクロック同期化部分.
--!        * 入力側のクロック(I_CLK)に同期化された入力データを 
--!          出力側クロック(O_CLK)に同期化して出力する.
--!        * 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)との関係は、
--!          ジェネリック変数I_CLK_RATEとO_CLK_RATEで指示する.
--!          詳細は O_CLK_RATE を参照.
-----------------------------------------------------------------------------------
entity  SYNCRONIZER is
    generic (
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(IDATA/ODATA)のビット幅を指定する.
                      integer :=  8;
        VAL_BITS    : --! @brief VALID BITS :
                      --! データ有効信号(IVAL/OVAL)のビット幅を指定する.
                      integer :=  1;
        I_CLK_RATE  : --! @brief INPUT CLOCK RATE :
                      --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側のクロッ
                      --! ク(O_CLK)との関係を指定する. 詳細は O_CLK_RATE を参照.
                      integer :=  1;
        O_CLK_RATE  : --! @brief OUTPUT CLOCK RATE :
                      --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側のクロッ
                      --! ク(O_CLK)との関係を指定する.
                      --! * I_CLK_RATE = 0 かつ O_CLK_RATE = 0 の場合は I_CLK と 
                      --!   O_CLK は非同期.
                      --! * I_CLK_RATE = 1 かつ O_CLK_RATE = 1 の場合は I_CLK と 
                      --!   O_CLK は完全に同期している.
                      --! * I_CLK_RATE > 1 かつ O_CLK_RATE = 1 の場合は I_CLK は 
                      --!   O_CLK のI_CLK_RATE倍の周波数.
                      --!   ただし I_CLK の立上りは O_CLK の立上りと一致している.
                      --! * I_CLK_RATE = 1 かつ O_CLK_RATE > 1 の場合は O_CLK は 
                      --!   I_CLK の O_CLK_RATE倍の周波数.
                      --!   ただし I_CLK の立上りは O_CLK の立上りと一致している.
                      --! * 例1)I_CLK_RATE=1 & O_CLK_RATE=1          \n
                      --!       I_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --!       O_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --! * 例2)I_CLK_RATE=2 & O_CLK_RATE=1          \n
                      --!       I_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --!       O_CLK _|~~~|___|~~~|___|~~~|___|~~~  \n
                      --!       I_CKE ~~~|___|~~~|___|~~~|___|~~~|_  \n
                      --! * 例3)I_CLK_RATE=3 & O_CLK_RATE=1          \n
                      --!       I_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --!       O_CLK _|~~~~~|_____|~~~~~|_____|~~~  \n
                      --!       I_CKE ~~~|_______|~~~|_______|~~~|_  \n
                      --! * 例4)I_CLK_RATE=1 & O_CLK_RATE=2          \n
                      --!       I_CLK _|~~~|___|~~~|___|~~~|___|~~~  \n
                      --!       O_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --!       O_CKE ~~~|___|~~~|___|~~~|___|~~~|_  \n
                      integer :=  1;
        I_CLK_FLOP  : --! @brief INPUT CLOCK FLOPPING :
                      --! 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)が非同期
                      --! の場合に、出力側のFFからの制御信号を入力側のFFで叩く段数
                      --! を指定する.
                      --! * FFで叩くのはメタステーブルの発生による誤動作を防ぐため.
                      --!   メタステーブルの意味が分からない人は、この変数を変更す
                      --!   るのはやめたほうがよい。
                      integer range 0 to 2 := 2;
        O_CLK_FLOP  : --! @brief OUTPUT CLOCK FLOPPING :
                      --! 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)が非同期
                      --! の場合に、入力側のFFからの制御信号を出力側のFFで叩く段数
                      --! を指定する.
                      --! * FFで叩くのはメタステーブルの発生による誤動作を防ぐため.
                      --!   メタステーブルの意味が分からない人は、この変数を変更す
                      --!   るのはやめたほうがよい.
                      integer range 0 to 2 := 2;
        I_CLK_FALL  : --! @brief USE INPUT CLOCK FALL :
                      --! 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)が非同期
                      --! の場合に、入力側のクロック(I_CLK)の立ち下がりを使うかどう
                      --! かを指定する.
                      --! * この変数は後方互換性のために存在する. 現在は未使用.
                      --! * I_CLK_FALL = 0 の場合は使わない.
                      --! * I_CLK_FALL = 1 の場合は使う.
                      integer range 0 to 1 :=  0;
        O_CLK_FALL  : --! @brief USE OUTPUT CLOCK FALL :
                      --! 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)が非同期
                      --! の場合に、出力側のクロック(OCLK)の立ち下がりを使うかどう
                      --! かを指定する.
                      --! * O_CLK_FALL = 0 の場合は使わない.
                      --! * O_CLK_FALL = 1 の場合は使う.
                      integer range 0 to 1 :=  0;
        O_CLK_REGS  : --! @brief REGISTERD OUTPUT :
                      --! 出力側の各種信号(O_VAL/O_DATA)をレジスタ出力するかどうか
                      --! を指定する.
                      --! * この変数は I_CLK_RATE > 0 の場合のみ有効. 
                      --!   I_CLK_RATE = 0 の場合は、常にレジスタ出力になる.
                      --! * O_CLK_REGS = 0 の場合はレジスタ出力しない.
                      --! * O_CLK_REGS = 1 の場合はレジスタ出力する.
                      integer range 0 to 1 :=  0
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号
    -------------------------------------------------------------------------------
        RST         : --! @brief RESET :
                      --! 非同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側のクロック信号/同期リセット信号
    -------------------------------------------------------------------------------
        I_CLK       : --! @brief INPUT CLOCK :
                      --! 入力側のクロック信号.
                      in  std_logic;
        I_CLR       : --! @brief INPUT CLEAR :
                      --! 入力側の同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側の制御信号
    -------------------------------------------------------------------------------
        I_CKE       : --! @brief INPUT CLOCK ENABLE :
                      --! 入力側のクロック(I_CLK)の立上りが有効であることを示す信号.
                      --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の位相
                      --!   関係を示す時に使用する.
                      --! * I_CLKの立上り時とOCLKの立上り時が同じ時にアサートするよ
                      --!   うに入力されなければならない.
                      --! * この信号は I_CLK_RATE > 1 かつ O_CLK_RATE = 1の時のみ有
                      --!   効. それ以外は未使用.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側のデータ信号/有効信号/可能信号
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT DATA :
                      --! 入力データ.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT VALID :
                      --! 入力有効信号.
                      --! * この信号がアサートされている時はI_DATAに有効なデータが
                      --!   入力されていなければならない。
                      in  std_logic_vector(VAL_BITS -1 downto 0);
        I_RDY       : --! @brief INPUT READY :
                      --! 入力可能信号.
                      --! * この信号がアサートされている場合にのみ、I_VAL,I_DATAを
                      --!   受け付けて、出力側に転送する.
                      --! * この信号がネゲートされている場合は、I_VAL,I_DATAは無視
                      --!   される.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側のクロック
    -------------------------------------------------------------------------------
        O_CLK       : --! @brief OUTPUT CLK :
                      --! 出力側のクロック信号.
                      in  std_logic;
        O_CLR       : --! @brief OUTPUT CLEAR :
                      --! 出力側の同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 出力側の制御信号
    -------------------------------------------------------------------------------
        O_CKE       : --! @brief OUTPUT CLOCK ENABLE :
                      --! 出力側のクロック(O_CLK)の立上りが有効であることを示す信号.
                      --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の位相
                      --!   関係を示す時に使用する.
                      --! * I_CLKの立上り時とO_CLKの立上り時が同じ時にアサートする
                      --!   ように入力されなければならない.
                      --! * この信号は O_CLK_RATE > 1 かつ I_CLK_RATE = 1の時のみ有
                      --!   効. それ以外は未使用.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 出力側のデータ信号/有効信号
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT DATA :
                      --! 出力データ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT VALID :
                      --! 出力有効信号.
                      --! * この信号がアサートされている時はODATAに有効なデータが出
                      --!   力されていることを示す.
                      out std_logic_vector(VAL_BITS -1 downto 0)
    );
end SYNCRONIZER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of SYNCRONIZER is
    signal    sync_req  : std_logic;
    signal    sync_ack  : std_logic;
    signal    sync_load : std_logic;
    signal    sync_valid: std_logic_vector(VAL_BITS -1 downto 0);
    signal    sync_data : std_logic_vector(DATA_BITS-1 downto 0);
    constant  VAL_ALL_0 : std_logic_vector(VAL_BITS -1 downto 0) := (others => '0');
begin
    -------------------------------------------------------------------------------
    -- 同期化ブロック(I_CLKとO_CLKが非同期の場合)
    -------------------------------------------------------------------------------
    --    I_CLKとO_CLKが非同期の場合は、入力ブロックと出力ブロックの間に同期化のた
    --    めのしくみが必要になる。
    -------------------------------------------------------------------------------
    ASYNC:if (I_CLK_RATE = 0 or O_CLK_RATE = 0) generate
        ---------------------------------------------------------------------------
        -- 入力側の回路
        ---------------------------------------------------------------------------
        I_BLK: block
            signal   curr_state     : std_logic_vector(1 downto 0);
            signal   next_state     : std_logic_vector(1 downto 0);
            signal   sync_start     : std_logic;
            signal   sync_ready     : std_logic;
            signal   sync_ack_i     : std_logic;
            signal   sync_ack_1     : std_logic;
            signal   sync_ack_2     : std_logic;
        begin
            -----------------------------------------------------------------------
            -- curr_state : 出力側と同期をとるためのステートマシーン
            -----------------------------------------------------------------------
            next_state(0) <= '1' when (curr_state = "00" and sync_start = '1') or
                                      (curr_state = "01") or
                                      (curr_state = "11" and sync_start = '0') else '0';
            next_state(1) <= '1' when (curr_state = "01" and sync_ack_i = '1') or
                                      (curr_state = "11") or
                                      (curr_state = "10" and sync_ack_i = '1') else '0';
            process (I_CLK, RST) begin
                if     (RST   = '1') then  curr_state <= (others => '0');
                elsif  (I_CLK'event and I_CLK = '1') then
                    if (I_CLR = '1') then curr_state <= (others => '0');
                    else                  curr_state <= next_state;
                    end if;
                end if;
            end process;
            -----------------------------------------------------------------------
            -- sync_ack_i : 出力側からの sync_ack 信号を FF で叩く
            -----------------------------------------------------------------------
            sync_ack_i <= sync_ack   when (I_CLK_FLOP = 0) else
                          sync_ack_1 when (I_CLK_FLOP = 1) else
                          sync_ack_2;
            process (I_CLK, RST) begin
                if (RST = '1') then
                        sync_ack_1 <= '0';
                        sync_ack_2 <= '0';
                elsif  (I_CLK'event and I_CLK = '1') then
                    if (I_CLR = '1') then
                        sync_ack_1 <= '0';
                        sync_ack_2 <= '0';
                    else
                        sync_ack_1 <= sync_ack;
                        sync_ack_2 <= sync_ack_1;
                    end if;
                end if;
            end process;
            -----------------------------------------------------------------------
            -- sync_req   : 出力側に送る同期信号
            -----------------------------------------------------------------------
            sync_req   <= curr_state(0);
            -----------------------------------------------------------------------
            -- sync_ready : curr_state が起動可能であることを示す信号
            -----------------------------------------------------------------------
            sync_ready <= '1' when (curr_state = "00") or (curr_state = "11") else '0';
            -----------------------------------------------------------------------
            -- sync_start : curr_state を起動する信号
            -----------------------------------------------------------------------
            sync_start <= '1' when (I_VAL /= VAL_ALL_0) else '0';
            -----------------------------------------------------------------------
            -- sync_valid : 出力側に転送する有効信号.
            -- sync_data  : 出力側に転送するデータ.
            -----------------------------------------------------------------------
            process (I_CLK, RST) begin
                if (RST = '1') then 
                        sync_valid <= (others => '0');
                        sync_data  <= (others => '0');
                elsif  (I_CLK'event and I_CLK = '1') then
                    if (I_CLR = '1') then 
                        sync_valid <= (others => '0');
                        sync_data  <= (others => '0');
                    elsif (sync_ready = '1') then
                        sync_valid <= I_VAL;
                        sync_data  <= I_DATA;
                    end if;
                end if;
            end process;
            -----------------------------------------------------------------------
            -- I_RDY      : 入力可能であることを示す信号.
            -----------------------------------------------------------------------
            I_RDY <= sync_ready;
        end block;
        ---------------------------------------------------------------------------
        -- 出力側の回路
        ---------------------------------------------------------------------------
        O_BLK: block
            signal   curr_state     : std_logic_vector(1 downto 0);
            signal   next_state     : std_logic_vector(1 downto 0);
            signal   sync_req_i     : std_logic;
            signal   sync_req_1     : std_logic;
            signal   sync_req_2     : std_logic;
        begin
            -----------------------------------------------------------------------
            -- sync_req_i : 入力側からの sync_req 信号を FF で叩く
            -----------------------------------------------------------------------
            sync_req_i <= sync_req   when (O_CLK_FLOP = 0) else
                          sync_req_1 when (O_CLK_FLOP = 1) else
                          sync_req_2;
            REQ1F: if (O_CLK_FALL > 0 and O_CLK_FLOP = 1) generate
                process (O_CLK, RST) begin
                    if     (RST   = '1') then sync_req_1 <= '0';
                    elsif  (O_CLK'event and O_CLK = '0') then
                        if (O_CLR = '1') then sync_req_1 <= '0';
                        else                  sync_req_1 <= sync_req;
                        end if;
                    end if;
                end process;
            end generate;
            REQ1R: if (O_CLK_FALL = 0 or O_CLK_FLOP /= 1) generate
                process (O_CLK, RST) begin
                    if     (RST   = '1') then sync_req_1 <= '0';
                    elsif  (O_CLK'event and O_CLK = '1') then
                        if (O_CLR = '1') then sync_req_1 <= '0';
                        else                  sync_req_1 <= sync_req;
                        end if;
                    end if;
                end process;
            end generate;
            REQ2F: if (O_CLK_FALL > 0) generate
                process (O_CLK, RST) begin
                    if     (RST   = '1') then sync_req_2 <= '0';
                    elsif  (O_CLK'event and O_CLK = '0') then
                        if (O_CLR = '1') then sync_req_2 <= '0';
                        else                  sync_req_2 <= sync_req_1;
                        end if;
                    end if;
                end process;
            end generate;
            REQ2R: if (O_CLK_FALL = 0) generate
                process (O_CLK, RST) begin
                    if     (RST   = '1') then sync_req_2 <= '0';
                    elsif  (O_CLK'event and O_CLK = '1') then
                        if (O_CLR = '1') then sync_req_2 <= '0';
                        else                  sync_req_2 <= sync_req_1;
                        end if;
                    end if;
                end process;
            end generate;
            -----------------------------------------------------------------------
            -- curr_state : 送り側と同期をとるためのステートマシーン
            -----------------------------------------------------------------------
            next_state(0) <= '1' when (curr_state = "00" and sync_req_i = '1') or
                                      (curr_state = "01") or
                                      (curr_state = "11" and sync_req_i = '1') else '0';
            next_state(1) <= '1' when (curr_state = "01") or
                                      (curr_state = "11") else '0';
            OCF:if (O_CLK_FALL > 0 and O_CLK_FLOP = 0) generate
                process (O_CLK, RST) begin
                    if     (RST   = '1') then curr_state <= (others => '0');
                    elsif  (O_CLK'event and O_CLK = '0') then
                        if (O_CLR = '1') then curr_state <= (others => '0');
                        else                  curr_state <= next_state;
                        end if;
                    end if;
                end process;
            end generate;
            OCR:if (O_CLK_FALL = 0 or O_CLK_FLOP > 0) generate
                process (O_CLK, RST) begin
                    if     (RST   = '1') then curr_state <= (others => '0');
                    elsif  (O_CLK'event and O_CLK = '1') then
                        if (O_CLR = '1') then curr_state <= (others => '0');
                        else                  curr_state <= next_state;
                        end if;
                    end if;
                end process;
            end generate;
            -----------------------------------------------------------------------
            -- sync_ack  : 入力側に送る同期信号
            -----------------------------------------------------------------------
            sync_ack  <= curr_state(1);
            -----------------------------------------------------------------------
            -- sync_load : 出力側のロード信号
            -----------------------------------------------------------------------
            sync_load <= '1' when (curr_state = "01" or curr_state = "10") else '0';
        end block;
    end generate; -- ASYNC: if (I_CLK_RATE = 0 or O_CLK_RATE = 0) generate
    -------------------------------------------------------------------------------
    -- 同期化ブロック(I_CLKとO_CLKが同期している場合)
    -------------------------------------------------------------------------------
    --    I_CLKとO_CLKが同期している場合はほとんどの信号はスルーで出力側に転送される
    -------------------------------------------------------------------------------
    SYNC:if (I_CLK_RATE > 0 and O_CLK_RATE > 0) generate
        I_RDY      <= '1' when (I_CKE = '1' or I_CLK_RATE = 1) else '0';
        sync_valid <= I_VAL;
        sync_data  <= I_DATA;
        sync_req   <= '0';
        sync_ack   <= '0';
        sync_load  <= '1' when (O_CKE = '1' or O_CLK_RATE = 1) else '0';
    end generate; -- SYNC: if (I_CLK_RATE > 0 and O_CLK_RATE > 0) generate
    -------------------------------------------------------------------------------
    -- 出力側ブロック(レジスタ出力の場合)
    -------------------------------------------------------------------------------
    O_REG:if (I_CLK_RATE = 0 or O_CLK_RATE = 0 or O_CLK_REGS /= 0) generate
        process (O_CLK, RST) begin
            if (RST = '1') then 
                    O_VAL  <= (others => '0');
                    O_DATA <= (others => '0');
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1') then
                    O_VAL  <= (others => '0');
                    O_DATA <= (others => '0');
                elsif (sync_load = '1') then
                    O_VAL  <= sync_valid;
                    O_DATA <= sync_data;
                else
                    O_VAL  <= (others => '0');
                end if;
            end if;
        end process;
    end generate; 
    -------------------------------------------------------------------------------
    -- 出力側ブロック(レジスタ出力でない場合)
    -------------------------------------------------------------------------------
    O_CMB:if (I_CLK_RATE > 0 and O_CLK_RATE > 0 and O_CLK_REGS = 0) generate
        O_VAL  <= sync_valid when (sync_load = '1') else (others => '0');
        O_DATA <= sync_data;
    end generate; 
end RTL;
