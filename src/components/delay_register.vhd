-----------------------------------------------------------------------------------
--!     @file    delay_register.vhd
--!     @brief   DELAY REGISTER : 
--!              入力データを指定したクロックだけ遅延して出力する.
--!     @version 0.1.1
--!     @date    2012/8/26
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012 Ichiro Kawazome
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
--! @brief   DELAY REGSISTER
--!          入力データ(I_DATA)を指定したクロックだけ遅延して出力する.
-----------------------------------------------------------------------------------
entity  DELAY_REGISTER is
    generic (
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(IDATA/ODATA)のビット幅を指定する.
                      integer :=  8;
        DELAY_MAX   : --! @brief DELAY CYCLE MAXIMUM :
                      --! * 入力側データ(I_DATA)を出力側に伝達する際の遅延時間の
                      --!   最大値を出力側のクロック数単位で指定する.
                      --! * 詳細は次の DELAY_MIN を参照.
                      integer := 0;
        DELAY_MIN   : --! @brief DELAY CYCLE MINIMUM :
                      --! * 入力側データ(I_DATAを出力側に伝達する際の遅延時間の
                      --!   最小値を出力側のクロック数単位で指定する.
                      --! * DELAY_MAX >= DELAY_MINでなければならない.
                      --! * DELAY_MAX = DELAY_MIN の場合は回路が簡略化される.
                      --!   この際、DELAY_SEL 信号は参照されない.
                      --! * 遅延するクロック数が多いほど、そのぶんレジスタが
                      --!   増えることに注意.
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
    -- 制御/状態信号
    -------------------------------------------------------------------------------
        SEL         : --! @brief DELAY CYCLE SELECT :
                      --! 遅延サイクル選択信号.
                      --! * DELAY_MAX > DELAY_MIN の場合のみ有効.
                      --! * DELAY_MAX = DELAY_MIN の場合はこの信号は無視される.
                      in  std_logic_vector(DELAY_MAX   downto DELAY_MIN);
        D_VAL       : --! @brief DELAY VALID :
                      --! 対応する遅延レジスタに有効なデータが入っていることを示す.
                      out std_logic_vector(DELAY_MAX   downto 0);
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT WORD DATA :
                      --! 入力データ.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT WORD VALID :
                      --! 入力データ有効信号.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT WORD DATA :
                      --! 出力データ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT WORD VALID :
                      --! 出力データ有効信号.
                      out std_logic
    );
end DELAY_REGISTER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of DELAY_REGISTER is
    -------------------------------------------------------------------------------
    -- レジスタの配列タイプの宣言
    -------------------------------------------------------------------------------
    type     STAGE_DATA_ARRAY is array (INTEGER range <>) of std_logic_vector(DATA_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 遅延データ保持用のレジスタ
    -------------------------------------------------------------------------------
    signal   stage_data     : STAGE_DATA_ARRAY(DELAY_MAX downto 0);
    signal   stage_save     : std_logic_vector(DELAY_MAX downto 0);
begin
    -------------------------------------------------------------------------------
    -- パイプラインの先頭ステージに入力信号をセット
    -------------------------------------------------------------------------------
    stage_data(0) <= I_DATA;
    stage_save(0) <= I_VAL;
    -------------------------------------------------------------------------------
    -- 各種情報のパイプライン化.
    -------------------------------------------------------------------------------
    DELAY_MODE: if (DELAY_MAX > 0) generate
        signal   stage_data_regs : STAGE_DATA_ARRAY(DELAY_MAX downto 1);
        signal   stage_save_regs : std_logic_vector(DELAY_MAX downto 1);
    begin
        stage_data(DELAY_MAX downto 1) <= stage_data_regs(DELAY_MAX downto 1);
        stage_save(DELAY_MAX downto 1) <= stage_save_regs(DELAY_MAX downto 1);
        process (CLK, RST) begin
            if (RST = '1') then
                    stage_data_regs <= (others => (others => '0'));
                    stage_save_regs <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    stage_data_regs <= (others => (others => '0'));
                    stage_save_regs <= (others => '0');
                else
                    for i in 1 to DELAY_MAX loop
                        stage_data_regs(i) <= stage_data(i-1);
                        stage_save_regs(i) <= stage_save(i-1);
                    end loop;
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- 出力信号の生成(DELAY_MAX = DELAY_MIN の場合)
    -------------------------------------------------------------------------------
    NOT_SEL: if (DELAY_MAX = DELAY_MIN) generate
         O_VAL  <= '1' when (stage_save(DELAY_MAX) = '1') else '0';
         O_DATA <= stage_data(DELAY_MAX);
    end generate;
    -------------------------------------------------------------------------------
    -- 出力信号の生成(DELAY_MAX > DELAY_MIN の場合)
    -------------------------------------------------------------------------------
    USE_SEL: if (DELAY_MAX > DELAY_MIN) generate
         process (SEL, stage_data, stage_save) 
             variable v_data : std_logic_vector(DATA_BITS-1 downto 0);
             variable v_save : std_logic;
         begin
             v_data := (others => '0');
             v_save := '0';
             for i in DELAY_MAX downto DELAY_MIN loop
                 if (SEL(i) = '1') then
                     v_data := stage_data(i);
                     v_save := stage_save(i);
                     exit;
                 end if;
             end loop;
             O_DATA <= v_data;
             O_VAL  <= v_save;
         end process;
    end generate;
    D_VAL <= stage_save;
end RTL;
