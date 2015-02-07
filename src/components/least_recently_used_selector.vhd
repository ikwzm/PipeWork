-----------------------------------------------------------------------------------
--!     @file    least_recently_used_selector.vhd
--!     @brief   Least-Recently-Used Selector :
--!              最も過去に選択したエントリを選択するモジュール.
--!     @version 1.5.8
--!     @date    2015/2/7
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2014-2015 Ichiro Kawazome
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
--! @brief   LEAST_RECENTLY_USED_SELECTOR :
--           最も過去に選択したエントリを選択するモジュール.
-----------------------------------------------------------------------------------
entity  LEAST_RECENTLY_USED_SELECTOR is
    generic (
        ENTRY_SIZE  : --! @brief ENTRY SIZE :
                      --! エントリの数を指定する.
                      integer := 4
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
    -- エントリ指定信号
    -------------------------------------------------------------------------------
        I_SEL       : --! @brief INPUT SELECTED ENTRY :
                      --! 選択したエントリを One-Hot で指定する.
                      --! * 選択したエントリに対応したビット位置に'1'に設定する.
                      --! * 同時に複数のエントリを指定することは出来ない.
                      in  std_logic_vector(ENTRY_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    -- エントリ出力信号
    -------------------------------------------------------------------------------
        O_SEL       : --! @brief OUTPUT LEAST RECENTLY USED ENTRY :
                      --! 最も過去に選択したエントリを出力.
                      --! * 最も過去に選択したエントリのビット位置に'1'が出力される.
                      --! * 同時に複数のエントリが選択されることはない.
                      out std_logic_vector(ENTRY_SIZE-1 downto 0);
        Q_SEL       : --! @brief REGISTERD OUTPUT LEAST RECENTLY USED ENTRY :
                      --! 最も過去に選択したエントリを出力.
                      --! * O_SEL信号を一度レジスタで叩いた結果を出力する.
                      out std_logic_vector(ENTRY_SIZE-1 downto 0)
    );
end LEAST_RECENTLY_USED_SELECTOR;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of LEAST_RECENTLY_USED_SELECTOR is
begin
    -------------------------------------------------------------------------------
    -- エントリ数が１しかない場合...
    -------------------------------------------------------------------------------
    ONE_SET: if (ENTRY_SIZE = 1) generate
        Q_SEL(0) <= '1';
        O_SEL(0) <= '1';
    end generate;
    -------------------------------------------------------------------------------
    -- エントリ数が２以上の場合は最も過去に選択したエントリを選択する
    -------------------------------------------------------------------------------
    -- エントリ数が４の場合の動作例
    --
    -- I_SEL(0)                     0               0                1
    -- I_SEL(1)                     1               0                0
    -- I_SEL(2)                     0               0                0
    -- I_SEL(3)                     0               1                0
    --                 +-----+      |  +-----+      |  +-----+       |  +-----+
    -- HIT_FLAG_TYPE   |0 1 2|      |  |0 1 2|      |  |0 1 2|       |  |0 1 2|
    --                 +-----+      V  +-----+      V  +-----+       V  +-----+
    -- curr_hit_flag(0)|1 1 1|<-LRU 0  |1 1 1|<-LRU 0  |1 1 1|<-LRU+-1->|0 0 0|
    -- curr_hit_flag(1)|0 1 1|---+--1->|0 0 0|      0  |0 0 1|     | 0  |0 1 1|
    -- curr_hit_flag(2)|0 0 1|   |  0  |0 1 1|      0  |0 1 1|     | 0  |1 1 1|<-LRU
    -- curr_hit_flag(3)|0 0 0|   |  0  |0 0 1|---+--1->|0 0 0|     | 0  |0 0 1|
    --                 +-----+   |     +-----+   |     +-----+     |    +-----+
    --                           |               |                 |
    -- sel_hit_flag              +----> 0 1 1    +----> 0 0 1      +---> 1 1 1 
    --
    -- O_SEL(0)         1               1               1                0
    -- O_SEL(1)         0               0               0                0
    -- O_SEL(2)         0               0               0                1
    -- O_SEL(3)         0               0               0                0
    -------------------------------------------------------------------------------
    ANY_SET: if (ENTRY_SIZE > 1) generate
        ---------------------------------------------------------------------------
        -- フラグのタイプを宣言.
        ---------------------------------------------------------------------------
        subtype  HIT_FLAG_TYPE   is std_logic_vector(0 to ENTRY_SIZE-2);
        type     HIT_FLAG_VECTOR is array (0 to ENTRY_SIZE-1) of HIT_FLAG_TYPE;
        ---------------------------------------------------------------------------
        -- フラグの初期値を生成する関数.
        ---------------------------------------------------------------------------
        function MAKE_INIT_HIT_FLAG return HIT_FLAG_VECTOR is
            variable init_hit_flag : HIT_FLAG_VECTOR;
        begin
            for i in HIT_FLAG_VECTOR'range loop
                for j in HIT_FLAG_TYPE'range loop
                    if (j >= i) then
                        init_hit_flag(i)(j) := '1';
                    else
                        init_hit_flag(i)(j) := '0';
                    end if;
                end loop;
            end loop;
            return init_hit_flag;
        end function;
        ---------------------------------------------------------------------------
        -- フラグの初期値定数.
        ---------------------------------------------------------------------------
        constant INIT_HIT_FLAG   : HIT_FLAG_VECTOR := MAKE_INIT_HIT_FLAG;
        ---------------------------------------------------------------------------
        -- フラグ信号.
        ---------------------------------------------------------------------------
        signal   curr_hit_flag   : HIT_FLAG_VECTOR;
        signal   next_hit_flag   : HIT_FLAG_VECTOR;
        ---------------------------------------------------------------------------
        -- 指定されたベクタのリダクション論理和を求める関数.
        ---------------------------------------------------------------------------
        function  or_reduce(Arg : std_logic_vector) return std_logic is
            variable result : std_logic;
        begin
            result := '0';
            for i in Arg'range loop
                result := result or Arg(i);
            end loop;
            return result;
        end function;
    begin
        ---------------------------------------------------------------------------
        -- 各エントリのフラグを更新する.
        ---------------------------------------------------------------------------
        process (curr_hit_flag, I_SEL, CLR)
            variable  sel_hit_flag  : HIT_FLAG_TYPE;
            variable  hit_vec       : std_logic_vector(HIT_FLAG_VECTOR'range);
        begin
            if (CLR = '1') then
                next_hit_flag <= INIT_HIT_FLAG;
            else
                -------------------------------------------------------------------
                -- I_SEL で指定されたエントリのフラグを求める.
                -------------------------------------------------------------------
                for j in HIT_FLAG_TYPE'range loop
                    for i in HIT_FLAG_VECTOR'range loop
                        if (I_SEL(i) = '1') then
                            hit_vec(i) := curr_hit_flag(i)(j);
                        else
                            hit_vec(i) := '0';
                        end if;
                    end loop;
                    sel_hit_flag(j) := or_reduce(hit_vec);
                end loop;
                -------------------------------------------------------------------
                -- 各エントリのフラグを更新する.
                -------------------------------------------------------------------
                for i in HIT_FLAG_VECTOR'range loop
                    for j in HIT_FLAG_TYPE'range loop
                        if    (I_SEL(i) = '1') then
                            next_hit_flag(i)(j) <= '0';
                        elsif (sel_hit_flag(j) = '0') then
                            next_hit_flag(i)(j) <= curr_hit_flag(i)(j);
                        elsif (j < HIT_FLAG_TYPE'high) then
                            next_hit_flag(i)(j) <= curr_hit_flag(i)(j+1);
                        else
                            next_hit_flag(i)(j) <= '1';
                        end if;
                    end loop;
                end loop;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- 各エントリのフラグの更新結果をレジスタに保持.
        ---------------------------------------------------------------------------
        process(CLK, RST) begin
            if (RST = '1') then
                curr_hit_flag <= INIT_HIT_FLAG;
            elsif (CLK'event and CLK = '1') then
                curr_hit_flag <= next_hit_flag;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- 最も過去に選択したエントリを出力.
        ---------------------------------------------------------------------------
        SEL: for i in 0 to ENTRY_SIZE-1 generate
            O_SEL(i) <= next_hit_flag(i)(0);
            Q_SEL(i) <= curr_hit_flag(i)(0);
        end generate;
    end generate;
end RTL;
