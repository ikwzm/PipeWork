-----------------------------------------------------------------------------------
--!     @file    pci_target_select.vhd
--!     @brief   PCI Target Select Package.
--!              PCI/PCI-Express において、アドレス、コマンドなどを解析して
--!              ターゲットを選択するモジュール、
--!              および解析に必要な情報を記述するディスクリプタのタイプ宣言を
--!              まとめたパッケージ.
--!     @version 0.0.1
--!     @date    2013/2/24
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
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
--! @brief   PCI Target Select Package.
--!          PCI/PCI-Express において、アドレス、コマンドなどを解析して
--!          ターゲットを選択するモジュール、および解析に必要な情報を記述する
--!          ディスクリプタのタイプ宣言をまとめたパッケージ.
-----------------------------------------------------------------------------------
package  PCI_TARGET_SELECT is
    -------------------------------------------------------------------------------
    --! @brief PCI のアクセスタイプ.
    -------------------------------------------------------------------------------
    type      PCI_ACCESS_TYPE is (
              PCI_NO_ACCESS,                  -- PCI アクセスは行なわない
              PCI_IO_ACCESS,                  -- PCI I/O アクセス
              PCI_MEM_ACCESS,                 -- PCI メモリアクセス
              PCI_CONFIG_TYPE0_ACCESS,        -- PCI コンフィギュレーションタイプ０
              PCI_TO_PCI_IO_STREAM,           -- PCI to PCI I/O ストリーム
              PCI_TO_PCI_MEM_STREAM,          -- PCI to PCI メモリストリーム
              PCI_TO_PCI_CONFIG_TYPE0_STREAM, -- PCI to PCI コンフィギュレーションアクセス
              PCI_TO_PCI_CONFIG_TYPE1_STREAM  -- PCI to PCI コンフィギュレーションアクセス
    );
    -------------------------------------------------------------------------------
    --! @brief PCI のアドレスデコード長.
    -------------------------------------------------------------------------------
    type      PCI_DECODE_TYPE is (
              PCI_DECODE_ADDR32,              -- 32bit アドレスデコード
              PCI_DECODE_ADDR64,              -- 64bit アドレスデコード
              PCI_DECODE_ADDR16               -- 16bit アドレスデコード
    );
    -------------------------------------------------------------------------------
    --! @brief PCI のベースアドレスの型.
    -------------------------------------------------------------------------------
    subtype   PCI_BASE_ADDR_TYPE  is std_logic_vector(63 downto 4);
    -------------------------------------------------------------------------------
    --! @brief PCI のターゲット選択を指定するための構造体.
    -------------------------------------------------------------------------------
    type      PCI_TARGET_SELECT_ENTRY_TYPE is record
        ---------------------------------------------------------------------------
        --! @brief PCIのアクセスタイプ.
        ---------------------------------------------------------------------------
              AccessType   : PCI_ACCESS_TYPE;
        ---------------------------------------------------------------------------
        --! @brief デコードする/しないの指定.
        ---------------------------------------------------------------------------
              DecodeEnable : boolean;
        ---------------------------------------------------------------------------
        --! @brief 拡張64BIT転送する/しないの指定.
        ---------------------------------------------------------------------------
              Ex64Enable   : boolean;
        ---------------------------------------------------------------------------
        --! @brief プリフェッチする/しないの指定.
        ---------------------------------------------------------------------------
              Prefechable  : boolean;
        ---------------------------------------------------------------------------
        --! @brief ベースアドレスレジスタのアドレスデコード長.
        ---------------------------------------------------------------------------
              DecodeType   : PCI_DECODE_TYPE;
        ---------------------------------------------------------------------------
        --! @brief ベースアドレスレジスタの値
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! * AccessType の種類によって働きが異なる.
        --! * AccessType が PCI_IO_ACCESS または PCI_MEM_ACCESS の場合、
        --!   ベースアドレスレジスタの値になる.
        --! * AccessType が PCI_CONFIG_TYPE0_ACCESS の場合、
        --!   BaseAddr(15 downto 8)が対応するファンクション番号を示す.
        --!   BaseAddr(8)はファンクション番号0 〜 BaseAddr(15)はファンクション番号7.
        --! * AccessType が PCI_TO_PCI_CONFIG_TYPE0_STREAM または 
        --!   PCI_TO_PCI_CONFIG_TYPE1_STREAM の場合、
        --!   BaseAddr(15 downto  8) が２次バス番号、
        --!   BaseAddr(23 downto 16) が従属バス番号となる.
        --! * AccessType が PCI_TO_PCI_IO_STREAM  の場合、
        --!   BaseAddr(31 downto 12)が開始アドレスになる.
        --! * AccessType が PCI_TO_PCI_MEM_STREAM の場合、
        --!   BaseAddr(63 downto 20)が開始アドレスになる.
        ---------------------------------------------------------------------------
              BaseAddr     : PCI_BASE_ADDR_TYPE;
        ---------------------------------------------------------------------------
        --! @brief アドレスデコードの際に必要な情報
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! * AccessType の種類によって働きが異なる.
        --! * AccessType が PCI_IO_ACCESS または PCI_MEM_ACCESS の場合、
        --!   アドレス比較/マッピング時使うマスク値になる. 
        --! * AccessType が PCI_TO_PCI_IO_STREAM  の場合、
        --!   Mask(31 downto 12)がリミットアドレスになる.
        --! * AccessType が PCI_TO_PCI_MEM_STREAM の場合、
        --!   Mask(63 downto 20)がリミットアドレスになる.
        ---------------------------------------------------------------------------
              Mask         : PCI_BASE_ADDR_TYPE;
        ---------------------------------------------------------------------------
        --! @brief PCIベースアドレスレジスタの番号.
        ---------------------------------------------------------------------------
              BaseAddrRegs : integer range 0 to 7;
    end record;
    -------------------------------------------------------------------------------
    --! @brief PCI_TARGET_SELECT_ENTRY_TYPE のNULL値.
    -------------------------------------------------------------------------------
    constant  PCI_TARGET_SELECT_ENTRY_NULL : PCI_TARGET_SELECT_ENTRY_TYPE := (
              AccessType   => PCI_NO_ACCESS    ,
              DecodeEnable => FALSE            ,
              Ex64Enable   => FALSE            ,
              Prefechable  => FALSE            ,
              DecodeType   => PCI_DECODE_ADDR32,
              BaseAddr     => (others => '0')  ,
              Mask         => (others => '0')  ,
              BaseAddrRegs => 0
    );        
    -------------------------------------------------------------------------------
    --! @brief PCI_TARGET_SELECT_ENTRY_TYPE の配列タイプ
    -------------------------------------------------------------------------------
    type      PCI_TARGET_SELECT_TABLE is array (INTEGER range <>) of PCI_TARGET_SELECT_ENTRY_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PCI_TARGET_ENTRY_CHECKER のコンポーネント宣言
    -------------------------------------------------------------------------------
    component PCI_TARGET_SELECT_ENTRY_CHECKER
        generic (
            USE_BAR_HIT : integer := 0;
            PCI_TO_PCI  : integer := 0;
            PCI_EXPRESS : integer := 0
        );
        port (
            T_BAR_HIT   : in  std_logic_vector;
            T_ADDR      : in  std_logic_vector;
            T_AD64      : in  std_logic;
            T_IO        : in  std_logic;
            T_MEM       : in  std_logic;
            T_CFG0      : in  std_logic;
            T_CFG1      : in  std_logic;
            HIT         : out std_logic;
            ENA64       : out std_logic;
            LEVEL       : out integer range 0 to 1;
            ENTRY       : in  PCI_TARGET_SELECT_ENTRY_TYPE;
            MEM_ENA     : in  std_logic;
            IO_ENA      : in  std_logic;
            PRIMARY     : in  std_logic
        );
    end component;
    -------------------------------------------------------------------------------
    --! @brief PCI_TARGET_SELECTER のコンポーネント宣言
    -------------------------------------------------------------------------------
    component PCI_TARGET_SELECTER
        generic (
            ENABLE      : integer := 1;
            FORCE       : integer := 0;
            USE_BAR_HIT : integer := 0;
            PCI_TO_PCI  : integer := 0;
            PCI_EXPRESS : integer := 0;
            TARGET_MIN  : integer := 0;
            TARGET_MAX  : integer := 0
        );
        port (
            T_BAR_HIT   : in  std_logic_vector;
            T_ADDR      : in  std_logic_vector;
            T_AD64      : in  std_logic;       
            T_IO        : in  std_logic;       
            T_MEM       : in  std_logic;       
            T_CFG0      : in  std_logic;       
            T_CFG1      : in  std_logic;       
            HIT         : out std_logic;
            ENA64       : out std_logic;       
            HIT_SEL     : out std_logic_vector       (TARGET_MIN to TARGET_MAX);
            TARGET_SEL  : in  PCI_TARGET_SELECT_TABLE(TARGET_MIN to TARGET_MAX);
            MEM_ENA     : in  std_logic;       
            IO_ENA      : in  std_logic;       
            PRIMARY     : in  std_logic        
        );
    end component;
end PCI_TARGET_SELECT;
-----------------------------------------------------------------------------------
--! @brief PCI Target Select Entry Checker Module.
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PipeWork;
use     PipeWork.PCI_TARGET_SELECT.all;
entity  PCI_TARGET_SELECT_ENTRY_CHECKER is
    generic (
        USE_BAR_HIT : integer := 0;                     --! 1=T_BAR_HITを使う.0=使わない.
        PCI_TO_PCI  : integer := 0;                     --! 1=PCI-PCIブリッジ機構を使う.
        PCI_EXPRESS : integer := 0                      --! 1=PCI-Expressモード.0=PCIモード.
    );
    port (
    -------------------------------------------------------------------------------
    -- PCI/PCI-Expressからの入力情報
    -------------------------------------------------------------------------------
        T_BAR_HIT   : in  std_logic_vector;             --! ベースアドレスレジスタヒット信号
        T_ADDR      : in  std_logic_vector;             --! アドレス
        T_AD64      : in  std_logic;                    --! Address Size(0=32bit/1=64bit)
        T_IO        : in  std_logic;                    --! I/O Access
        T_MEM       : in  std_logic;                    --! Memory Access
        T_CFG0      : in  std_logic;                    --! Type0 Configuration Access
        T_CFG1      : in  std_logic;                    --! Type1 Configuration Access
    -------------------------------------------------------------------------------
    -- 解析結果出力
    -------------------------------------------------------------------------------
        HIT         : out std_logic;                    --! デコードヒット信号
        ENA64       : out std_logic;                    --! 拡張64bit転送許可信号
        LEVEL       : out integer range 0 to 1;         --! デコードレベル
    -------------------------------------------------------------------------------
    -- 設定入力
    -------------------------------------------------------------------------------
        ENTRY       : in  PCI_TARGET_SELECT_ENTRY_TYPE; --! ターゲット選択記述.
        MEM_ENA     : in  std_logic;                    --! メモリアクセス許可信号
        IO_ENA      : in  std_logic;                    --! I/Oアクセス許可信号
        PRIMARY     : in  std_logic                     --! １次バス側/２次バス側
    );
end PCI_TARGET_SELECT_ENTRY_CHECKER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PipeWork;
use     PipeWork.PCI_TARGET_SELECT.all;
architecture RTL of PCI_TARGET_SELECT_ENTRY_CHECKER is
    signal      address_hit   : boolean;
    signal      cycle_hit     : boolean;
    signal      decode_enable : boolean;
    signal      ex64_enable   : boolean;
    signal      decode_level  : integer range 0 to 1;
begin
    -------------------------------------------------------------------------------
    --! @brief 各種デコード信号の生成
    -------------------------------------------------------------------------------
    --! * ここでは、T_BAR_HIT, T_ADDR, T_IO, T_MEM, T_CFG0, T_CFG1, ENTRY, IO_ENA, 
    --!   MEM_ENA をチェックして cycle_hit、address_hit、decode_enableのデコードヒ
    --!   ット信号、および ex64_enable、decode_levelのデコード属性信号を生成する.
    -------------------------------------------------------------------------------
    DECODE: process (ENTRY, IO_ENA, MEM_ENA, PRIMARY,
                     T_ADDR, T_BAR_HIT, T_AD64, T_IO, T_MEM, T_CFG0, T_CFG1)
        ---------------------------------------------------------------------------
        -- このプロセスで使用されるテンポラリ変数の定義
        ---------------------------------------------------------------------------
        variable    u_addr        : unsigned(T_ADDR'range);
        variable    u_base        : unsigned(PCI_BASE_ADDR_TYPE'range);
        variable    u_mask        : unsigned(PCI_BASE_ADDR_TYPE'range);
        variable    hit           : boolean;
        variable    bus_num       : unsigned(7 downto 0);
        variable    sec_bus_num   : unsigned(7 downto 0);
        variable    sub_bus_num   : unsigned(7 downto 0);
        ---------------------------------------------------------------------------
        --! @brief アドレスを比較する関数
        ---------------------------------------------------------------------------
        function    COMPARE_ADDR(
                        ADDR      : std_logic_vector;
                        BAR_HIT   : std_logic_vector;
                        AD64      : std_logic;
                        ENTRY     : PCI_TARGET_SELECT_ENTRY_TYPE)
                        return      boolean
        is 
        begin
            if    (USE_BAR_HIT /= 0) then
                for i in BAR_HIT'range loop
                    if (BAR_HIT(i) = '1' and i = ENTRY.BaseAddrRegs) then
                        return TRUE;
                    end if;
                end loop;
                return FALSE;
            elsif (ENTRY.AccessType = PCI_MEM_ACCESS   ) and 
                  (ENTRY.DecodeType = PCI_DECODE_ADDR64) and
                  (AD64             = '1'              ) and
                  (ADDR'high       >= 32               ) then
                for i in 4 to 63 loop
                    if (ENTRY.Mask(i) = '1') then
                        if (i >  ADDR'high and ENTRY.BaseAddr(i) /= '0'    ) or
                           (i <= ADDR'high and ENTRY.BaseAddr(i) /= ADDR(i)) then
                            return FALSE;
                        end if;
                    end if;
                end loop;
            else
                for i in 4 to 31 loop
                    if (ENTRY.Mask(i) = '1') then
                        if (ENTRY.BaseAddr(i) /= ADDR(i)) then
                            return FALSE;
                        end if;
                    end if;
                end loop;
            end if;
            return TRUE;
        end COMPARE_ADDR;
        ---------------------------------------------------------------------------
        --! @breif ファンクション番号を比較する関数
        ---------------------------------------------------------------------------
        function    COMPARE_FUNC(
                        ADDR      : std_logic_vector;
                        ENTRY     : PCI_TARGET_SELECT_ENTRY_TYPE)
                        return      boolean
        is 
            variable    func      : unsigned(2 downto 0);
        begin
            if (PCI_EXPRESS /= 0) then
                func := unsigned(ADDR(18 downto 16));
            else
                func := unsigned(ADDR(10 downto  8));
            end if;
            for i in 0 to 7 loop
                if (i = func and ENTRY.BaseAddr(i+8) = '1') then
                    return TRUE;
                end if;
            end loop;
            return FALSE;
        end COMPARE_FUNC;
    begin
        ---------------------------------------------------------------------------
        -- I/O アクセスの場合は、アドレスを比較するが、拡張64BIT転送は禁止
        ---------------------------------------------------------------------------
        if (ENTRY.AccessType = PCI_IO_ACCESS) then
            address_hit   <= COMPARE_ADDR(T_ADDR, T_BAR_HIT, T_AD64, ENTRY);
            decode_enable <= ENTRY.DecodeEnable;
            decode_level  <= 1;
            cycle_hit     <= (USE_BAR_HIT /= 0 or (T_IO = '1' and IO_ENA  = '1'));
            ex64_enable   <= FALSE;
        ---------------------------------------------------------------------------
        -- MEMORYアクセスの場合は、アドレスを比較し、拡張64BIT転送も場合に
        -- よっては許可する。
        -- 拡張64BIT転送を許可する条件は次の通り
        --   1. ENTRY.Ex64Enableによって拡張64BIT転送が許可されていること
        --   2. メモリサイクルであること
        --   3. 要求されたメモリアクセスの種類がリニアアクセスであること
        --   4. アドレスが64BITワード境界から始まっていること
        ---------------------------------------------------------------------------
        elsif (ENTRY.AccessType = PCI_MEM_ACCESS) then
            address_hit   <= COMPARE_ADDR(T_ADDR, T_BAR_HIT, T_AD64, ENTRY);
            decode_enable <= ENTRY.DecodeEnable;
            decode_level  <= 1;
            cycle_hit     <= (USE_BAR_HIT /= 0 or (T_MEM = '1' and MEM_ENA = '1'));
            ex64_enable   <= (ENTRY.Ex64Enable             ) and
                             (T_MEM = '1' and MEM_ENA = '1') and
                             (T_ADDR(2 downto 0)= "000"    );
        ---------------------------------------------------------------------------
        -- TYPE0 CONFIG アクセスの場合は、サイクルの種類のチェックとファンクション
        -- 番号の比較を行なう。拡張64BIT転送は禁止。
        ---------------------------------------------------------------------------
        elsif (ENTRY.AccessType = PCI_CONFIG_TYPE0_ACCESS) then
            address_hit   <= COMPARE_FUNC(T_ADDR, ENTRY);
            decode_enable <= ENTRY.DecodeEnable;
            decode_level  <= 1;
            cycle_hit     <= (T_CFG0 = '1');
            ex64_enable   <= FALSE;
        ---------------------------------------------------------------------------
        -- PCI(CONFIG TYPE1) -> PCI(CONFIG TYPE0)アクセスの場合、バス番号
        -- (PCIの場合はT_ADDR(23 downto 16)、PCI-Expressの場合はT_ADDR(31 downto 24))
        -- と２次バス番号(DESC.BaseAddr(15 downto 8))を比較する。
        ---------------------------------------------------------------------------
        elsif (PCI_TO_PCI =  1 ) and
              (PRIMARY    = '1') and
              (ENTRY.AccessType = PCI_TO_PCI_CONFIG_TYPE0_STREAM) then
            u_addr := to_01(unsigned(T_ADDR        ),'0');
            u_base := to_01(unsigned(ENTRY.BaseAddr),'0');
            if (PCI_EXPRESS /= 0) then
                bus_num   := u_addr(31 downto 24);
            else
                bus_num   := u_addr(23 downto 16);
            end if;
            sec_bus_num   := u_base(15 downto  8);
            address_hit   <= (bus_num = sec_bus_num);
            decode_enable <= ENTRY.DecodeEnable;
            decode_level  <= 1;
            cycle_hit     <= (T_CFG1 = '1');
            ex64_enable   <= FALSE;
        ---------------------------------------------------------------------------
        -- PCI(CONFIG TYPE1) -> PCI(CONFIG TYPE1)アクセスの場合、バス番号
        -- (PCIの場合はT_ADDR(23 downto 16)、PCI-Expressの場合はT_ADDR(31 downto 24))
        -- と２次バス番号(DESC.BaseAddr(15 downto 8))と
        -- 従属バス番号DESC.BaseAddr(23 downto 16)を比較する。
        ---------------------------------------------------------------------------
        elsif (PCI_TO_PCI =  1 ) and
              (PRIMARY    = '1') and
              (ENTRY.AccessType = PCI_TO_PCI_CONFIG_TYPE1_STREAM) then
            u_addr := to_01(unsigned(T_ADDR        ),'0');
            u_base := to_01(unsigned(ENTRY.BaseAddr),'0');
            if (PCI_EXPRESS /= 0) then
                bus_num   := u_addr(31 downto 24);
            else
                bus_num   := u_addr(23 downto 16);
            end if;
            sec_bus_num   := u_base(15 downto  8);
            sub_bus_num   := u_base(23 downto 16);
            address_hit   <= (bus_num >  sec_bus_num) and
                             (bus_num <= sub_bus_num);
            decode_enable <= ENTRY.DecodeEnable;
            decode_level  <= 1;
            cycle_hit     <= (T_CFG1 = '1');
            ex64_enable   <= FALSE;
        ---------------------------------------------------------------------------
        -- PCI to PCI I/O アクセスの場合、T_ADDR(31 downto 12) がリミットアドレス
        -- (DESC.Mask(31 downto 12)) とベースアドレス(DESC.BaseAddr(31 downto 12)) 
        -- の範囲内にあるかどうかを調べる。
        ---------------------------------------------------------------------------
        elsif (PCI_TO_PCI = 1) and
              (ENTRY.AccessType = PCI_TO_PCI_IO_STREAM) then
            u_addr := to_01(unsigned(T_ADDR        ),'0');
            u_base := to_01(unsigned(ENTRY.BaseAddr),'0');
            u_mask := to_01(unsigned(ENTRY.Mask    ),'0');
            hit := (u_addr(31 downto 12) >= u_base(31 downto 12)) and
                   (u_addr(31 downto 12) <= u_mask(31 downto 12)) ;
            address_hit   <= (PRIMARY = '1' and hit = TRUE ) or
                             (PRIMARY = '0' and hit = FALSE) ;
            decode_enable <= ENTRY.DecodeEnable;
            decode_level  <= 0;
            cycle_hit     <= (T_IO = '1' and IO_ENA = '1');
            ex64_enable   <= FALSE;
        ---------------------------------------------------------------------------
        -- PCI to PCI メモリアクセス(64bitアドレスデコード)の場合、
        -- T_ADDR(63or31 downto 20) が リミットアドレス(DESC.Mask(63 downto 20))と
        -- ベースアドレス(DESC.BaseAddr(63 downto 20))の範囲内にあるかどうかを調べる。
        ---------------------------------------------------------------------------
        elsif (PCI_TO_PCI = 1) and
              (ENTRY.AccessType = PCI_TO_PCI_MEM_STREAM) and
              (ENTRY.DecodeType = PCI_DECODE_ADDR64    ) then
            u_addr := to_01(unsigned(T_ADDR        ),'0');
            u_base := to_01(unsigned(ENTRY.BaseAddr),'0');
            u_mask := to_01(unsigned(ENTRY.Mask    ),'0');
            if (T_AD64 = '1' and T_ADDR'high >= 32) then
                hit := (u_addr(63 downto 20) >= u_base(63 downto 20)) and
                       (u_addr(63 downto 20) <= u_mask(63 downto 20));
            else
                hit := (u_mask(63 downto 32) = 0) and
                       (u_addr(31 downto 20) >= u_base(31 downto 20)) and
                       (u_addr(31 downto 20) <= u_mask(31 downto 20));
            end if;
            address_hit   <= (PRIMARY = '1' and hit = TRUE ) or
                             (PRIMARY = '0' and hit = FALSE) ;
            decode_enable <= ENTRY.DecodeEnable;
            decode_level  <= 0;
            cycle_hit     <= (T_MEM = '1' and MEM_ENA = '1');
            ex64_enable   <= (ENTRY.Ex64Enable              ) and
                             (T_MEM = '1' and MEM_ENA = '1') and
                             (T_ADDR(2 downto 0) = "000"   );
        ---------------------------------------------------------------------------
        -- PCI to PCI メモリアクセス(32bitアドレスデコードの場合、
        -- T_ADDR(63or31 downto 20) が リミットアドレス(DESC.Mask(31 downto 20))と
        -- ベースアドレス(DESC.BaseAddr(31 downto 20))の範囲内にあるかどうかを調べる。
        ---------------------------------------------------------------------------
        elsif (PCI_TO_PCI = 1) and
              (ENTRY.AccessType  = PCI_TO_PCI_MEM_STREAM) and
              (ENTRY.DecodeType /= PCI_DECODE_ADDR64    ) then
            u_addr := to_01(unsigned(T_ADDR        ),'0');
            u_base := to_01(unsigned(ENTRY.BaseAddr),'0');
            u_mask := to_01(unsigned(ENTRY.Mask    ),'0');
            if (T_AD64 = '1' and T_ADDR'high >= 32) then
                hit := (u_addr(u_addr'high downto 32) = 0) and
                       (u_addr(31 downto 20) >= u_base(31 downto 20)) and
                       (u_addr(31 downto 20) <= u_mask(31 downto 20));
            else
                hit := (u_addr(31 downto 20) >= u_base(31 downto 20)) and
                       (u_addr(31 downto 20) <= u_mask(31 downto 20));
            end if;
            address_hit   <= (PRIMARY = '1' and hit = TRUE ) or
                             (PRIMARY = '0' and hit = FALSE) ;
            decode_enable <= ENTRY.DecodeEnable;
            decode_level  <= 0;
            cycle_hit     <= (T_MEM = '1' and MEM_ENA = '1');
            ex64_enable   <= (ENTRY.Ex64Enable              ) and
                             (T_MEM = '1' and MEM_ENA = '1') and
                             (T_ADDR(2 downto 0) = "000"   );
        ---------------------------------------------------------------------------
        -- その他の場合はすべて FALSE にする
        ---------------------------------------------------------------------------
        else
            decode_enable <= FALSE;
            decode_level  <= 1;
            cycle_hit     <= FALSE;
            address_hit   <= FALSE;
            ex64_enable   <= FALSE;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 各種デコード信号の生成
    -------------------------------------------------------------------------------
    HIT   <= '1' when (decode_enable and cycle_hit and address_hit) else '0';
    ENA64 <= '1' when (ex64_enable) else '0';
    LEVEL <= decode_level;
end RTL;
-----------------------------------------------------------------------------------
--! @brief PCI Target Selecter Module.
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PipeWork;
use     PipeWork.PCI_TARGET_SELECT.all;
entity  PCI_TARGET_SELECTER is
    generic (
        ENABLE      : integer := 1;                     --! 1=このモジュールを有効化.
        FORCE       : integer := 0;                     --! 1=アドレス解析をせずにアクセス種だけ決定.
        USE_BAR_HIT : integer := 0;                     --! 1=T_BAR_HITを使う.0=使わない.
        PCI_TO_PCI  : integer := 0;                     --! 1=PCI-PCIブリッジ機構を使う.
        PCI_EXPRESS : integer := 0;                     --! 1=PCI-Expressモード.0=PCIモード.
        TARGET_MIN  : integer := 0;                     --! TARGET_SELの最小引数値.
        TARGET_MAX  : integer := 0                      --! TARGET_SELの最大引数値.
    );
    port (
    -------------------------------------------------------------------------------
    -- PCI/PCI-Expressからの入力情報
    -------------------------------------------------------------------------------
        T_BAR_HIT   : in  std_logic_vector;             --! ベースアドレスレジスタヒット信号
        T_ADDR      : in  std_logic_vector;             --! アドレス
        T_AD64      : in  std_logic;                    --! Address Size(0=32bit/1=64bit)
        T_IO        : in  std_logic;                    --! I/O Access
        T_MEM       : in  std_logic;                    --! Memory Access
        T_CFG0      : in  std_logic;                    --! Type0 Configuration Access
        T_CFG1      : in  std_logic;                    --! Type1 Configuration Access
    -------------------------------------------------------------------------------
    -- 解析結果出力
    -------------------------------------------------------------------------------
        HIT         : out std_logic;                    --! デコードヒット信号
        ENA64       : out std_logic;                    --! 拡張64bit転送許可信号
        HIT_SEL     : out std_logic_vector       (TARGET_MIN to TARGET_MAX);
    -------------------------------------------------------------------------------
    -- 設定入力
    -------------------------------------------------------------------------------
        TARGET_SEL  : in  PCI_TARGET_SELECT_TABLE(TARGET_MIN to TARGET_MAX);
        MEM_ENA     : in  std_logic;                    --! メモリアクセス許可信号
        IO_ENA      : in  std_logic;                    --! I/Oアクセス許可信号
        PRIMARY     : in  std_logic                     --! １次バス側/２次バス側
    );
end PCI_TARGET_SELECTER;
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PCI_TARGET_SELECT.all;
architecture RTL of PCI_TARGET_SELECTER is
    type        DEC_LEVEL_VECTOR is array (integer range <>) of integer range 0 to 1;
    signal      decode_hit       : std_logic_vector(TARGET_SEL'range);
    signal      decode_sel       : std_logic_vector(TARGET_SEL'range);
    signal      decode_ena64     : std_logic_vector(TARGET_SEL'range);
    signal      decode_level     : DEC_LEVEL_VECTOR(TARGET_SEL'range);
    constant    DECODE_ALL0      : std_logic_vector(TARGET_SEL'range) := (others => '0');
begin
    -------------------------------------------------------------------------------
    -- decode_hit   : TARGET_SELの各エントリ毎のHIT信号を配列にしたもの.
    -- decode_level : TARGET_SELの各エントリ毎のLEVEL信号を配列にしたもの.
    -- decode_ena64 : TARGET_SELの各エントリ毎のENA64信号を配列にしたもの.
    -------------------------------------------------------------------------------
    ENTRY: for i in TARGET_SEL'range generate
        CHECKER: PCI_TARGET_SELECT_ENTRY_CHECKER    -- 
            generic map (                           -- 
                USE_BAR_HIT => USE_BAR_HIT,         -- T_BAR_HITを使うか否かを指定.
                PCI_TO_PCI  => PCI_TO_PCI ,         -- PCI-PCIブリッジ機構を使うか否かを指定.
                PCI_EXPRESS => PCI_EXPRESS          -- PCI-Expressモード/PCIモードを指定.
            )                                       -- 
            port map (                              -- 
                T_BAR_HIT   => T_BAR_HIT,           -- In  : ベースアドレスレジスタヒット信号
                T_ADDR      => T_ADDR,              -- In  : アドレス
                T_AD64      => T_AD64,              -- In  : Address Size(0=32bit/1=64bit)
                T_IO        => T_IO,                -- In  : I/O Access
                T_MEM       => T_MEM,               -- In  : Memory Access
                T_CFG0      => T_CFG0,              -- In  : Type0 Configuration Access
                T_CFG1      => T_CFG1,              -- In  : Type1 Configuration Access
                HIT         => decode_hit(i),       -- Out : デコードヒット信号
                LEVEL       => decode_level(i),     -- Out : デコードレベル
                ENA64       => decode_ena64(i),     -- Out : 拡張64bit転送許可信号
                ENTRY       => TARGET_SEL(i),       -- In  : ターゲット選択記述
                MEM_ENA     => MEM_ENA,             -- In  : メモリアクセス許可信号
                IO_ENA      => IO_ENA,              -- In  : I/Oアクセス許可信号
                PRIMARY     => PRIMARY              -- In  : １次バス側/２次バス側
            );
    end generate;
    -------------------------------------------------------------------------------
    -- HIT          : 上記のデコード回路で生成された TARGET_SEL ごとの decode_hit
    --                信号を集計して、どれかにヒットすれば'1'になる.
    -------------------------------------------------------------------------------
    process (decode_hit, PRIMARY, TARGET_SEL, T_IO, T_MEM, T_CFG0, T_CFG1) 
        variable mem_hit_mask : std_logic_vector(TARGET_SEL'range);
        variable mem_hit      : std_logic_vector(TARGET_SEL'range);
        variable oth_hit      : std_logic_vector(TARGET_SEL'range);
        constant none_hit     : std_logic_vector(TARGET_SEL'range) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        -- そもそも ENABLE=0 の場合は HIT 信号がアサートされることはない.
        ---------------------------------------------------------------------------
        if    (ENABLE = 0) then
            HIT <= '0';
        ---------------------------------------------------------------------------
        -- TARGET_SELに指定されたアクセス条件に関わらず、常にリクエストを受け付ける
        -- 場合(FORCE /= 0)は、各アクセス信号のいずれかがアサートされて入れば、
        -- HIT 信号をアサートする.
        ---------------------------------------------------------------------------
        elsif (FORCE /= 0) then
            if (T_MEM = '1' or T_IO = '1' or T_CFG0 = '1' or T_CFG1 = '1') then
                HIT <= '1';
            else
                HIT <= '0';
            end if;
        ---------------------------------------------------------------------------
        -- PCI-PCIバスブリッジでない場合(PCI_TO_PCI=0)または、PCI-PCIバスブリッジで
        -- も１次バス側(PRIMARY=1)の場合は、単純に decode_hit配列のどれかが'1'に
        -- なっていれば、HIT 信号をアサートする.
        ---------------------------------------------------------------------------
        elsif (PCI_TO_PCI = 0 or PRIMARY = '1') then
            if (decode_hit /= none_hit) then
                HIT <= '1';
            else
                HIT <= '0';
            end if;
        ---------------------------------------------------------------------------
        -- PCI-PCIバスブリッジにおいて、２次バス側(PRIMARY=0)の場合は、アップストリ
        -- ームメモリトランザクション(２次バス側から１次バス側へのメモリトランザク
        -- ション)で、メモリマップドI/O空間"以外"とプリフェッチ可能メモリ空間"以外"
        -- の両方で decode_hit信号がアサートされてなければ HIT 信号をアサートして
        -- はならない。
        ---------------------------------------------------------------------------
        else
            for i in TARGET_SEL'range loop
                if (TARGET_SEL(i).AccessType = PCI_TO_PCI_MEM_STREAM) then
                    mem_hit_mask(i) := '1';
                else
                    mem_hit_mask(i) := '0';
                end if;
            end loop;
            mem_hit := decode_hit and     mem_hit_mask;
            oth_hit := decode_hit and not mem_hit_mask;
            if ((mem_hit = mem_hit_mask) or (oth_hit /= none_hit)) then
                HIT <= '1';
            else
                HIT <= '0';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- decode_sel   : 上記のデコード回路で生成された TARGET_SEL ごとの decode_hit
    --                信号、decode_level信号を集計して、最も適する TARGET_SEL の
    --                エントリのみ'1'をセットし、それ以外は'0'クリアした配列.
    -------------------------------------------------------------------------------
    process (decode_hit, decode_level)
        type     HIT_VECTOR is array (integer range <>) of boolean;
        type     SEL_VECTOR is array (integer range <>) of std_logic_vector(TARGET_SEL'range);
        variable lv_hit     : HIT_VECTOR(0 to 1);
        variable lv_sel     : SEL_VECTOR(0 to 1);
        variable sel        : std_logic_vector(TARGET_SEL'range); 
    begin
        ---------------------------------------------------------------------------
        -- TARGET_SELに指定されたアクセス条件に関わらず、常にリクエストを受け付ける
        -- 場合(FORCE /= 0)は、TARGET_SELの最も若い番号が選択される.
        ---------------------------------------------------------------------------
        if    (FORCE /= 0) then
            for i in decode_sel'low to decode_sel'high loop
                if (i = TARGET_SEL'low) then
                    decode_sel(i) <= '1';
                else
                    decode_sel(i) <= '0';
                end if;
            end loop;
        ---------------------------------------------------------------------------
        -- PCI-PCIバスブリッジでない場合(PCI_TO_PCI=0)は、TARGET_SELの最も若い番号
        -- から順にチェックして最初に該当した番号が選択される.
        ---------------------------------------------------------------------------
        elsif (PCI_TO_PCI = 0) then
            sel := (others => '0');
            for i in decode_sel'low to decode_sel'high loop
                if (decode_hit(i) = '1') then
                    sel(i) := '1';
                    exit;
                end if;
            end loop;
            decode_sel <= sel;
        ---------------------------------------------------------------------------
        -- PCI-PCIバスブリッジの場合(PCI_TO_PCI=1の場合)は、decode_level信号で示さ
        -- れるデコードレベルの高いものを優先的に選択する。
        ---------------------------------------------------------------------------
        else
            sel := (others => '0');
            for level in 1 downto 0 loop
                lv_hit(level) := FALSE;
                lv_sel(level) := (others => '0');
                for i in decode_sel'low to decode_sel'high loop
                    if (decode_hit(i) = '1' and decode_level(i) = level) then
                        lv_hit(level)    := TRUE;
                        lv_sel(level)(i) := '1';
                        exit;
                    end if;
                end loop;
            end loop;
            for level in 1 downto 0 loop
                if (lv_hit(level)) then
                    sel := lv_sel(level);
                    exit;
                end if;
            end loop;
            decode_sel <= sel;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- HIT_SEL      : decode_sel信号の結果を出力.
    -------------------------------------------------------------------------------
    HIT_SEL <= decode_sel;
    -------------------------------------------------------------------------------
    -- ENA64        : 
    -------------------------------------------------------------------------------
    ENA64   <= '1' when ((decode_sel and decode_ena64) /= DECODE_ALL0) else '0';
end RTL;
