-----------------------------------------------------------------------------------
--!     @file    axi4_data_outlet_port.vhd
--!     @brief   AXI4 DATA OUTLET PORT
--!     @version 1.5.0
--!     @date    2013/5/13
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
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4 DATA OUTLET PORT
-----------------------------------------------------------------------------------
entity  AXI4_DATA_OUTLET_PORT is
    generic (
        PORT_DATA_BITS  : --! @brief INTAKE PORT DATA BITS :
                          --! PORT_DATA のビット数を指定する.
                          --! * PORT_DATA_BITSで指定できる値は 8,16,32,64,128,256,
                          --!   512,1024
                          integer := 32;
        POOL_DATA_BITS  : --! @brief POOL BUFFER DATA BITS :
                          --! POOL_DATA のビット数を指定する.
                          integer := 32;
        TRAN_ADDR_BITS  : --! @brief TRANSACTION ADDRESS BITS :
                          --! TRAN_ADDR のビット数を指定する.
                          integer := 32;
        TRAN_SIZE_BITS  : --! @brief TRANSACTION SIZE BITS :
                          --! TRAN_SIZE のビット数を指定する.
                          integer := 32;
        TRAN_SEL_BITS   : --! @brief TRANSACTION SELECT BITS :
                          --! TRAN_SEL、PULL_VAL、POOL_REN のビット数を指定する.
                          integer := 1;
        BURST_LEN_BITS  : --! @brief BURST LENGTH BITS :
                          --! BURST_LEN のビット数を指定する.
                          integer := 12;
        ALIGNMENT_BITS  : --! @brief ALIGNMENT BITS :
                          --! アライメント調整を行うビット数を指定する.
                          --! * ALIGNMENT_BITS=8を指定した場合、バイト単位でアライ
                          --!   メント調整する.
                          integer := 8;
        PULL_SIZE_BITS  : --! @brief PULL_SIZE BITS :
                          --! PULL_SIZE のビット数を指定する.
                          integer := 16;
        EXIT_SIZE_BITS  : --! @brief EXIT_SIZE BITS :
                          --! EXIT_SIZE のビット数を指定する.
                          integer := 16;
        POOL_PTR_BITS   : --! @brief POOL BUFFER POINTER BITS:
                          --! START_PTR、POOL_PTR のビット数を指定する.
                          integer := 16;
        USE_BURST_SIZE  : --! @brief USE BURST SIZE :
                          --! BURST_SIZE による Narrow transfers をサポートするか
                          --! 否かを指定する.
                          --! * USE_BURST_SIZE=0を指定した場合、Narrow transfers を
                          --!   サポートしない.
                          --! * USE_BURST_SIZE=1を指定した場合、Narrow transfers を
                          --!   サポートする. その際の１ワード毎の転送バイト数は
                          --!   BURST_SIZE で指定される.
                          integer range 0 to 1 := 1;
        PORT_REGS_SIZE  : --! @brief PORT REGS SIZE :
                          --! 出力側に挿入するパイプラインレジスタの段数を指定する.
                          --! * PORT_REGS_SIZE=0を指定した場合、パイプラインレジスタ
                          --!   は挿入しない.
                          --! * PORT_REGS_SIZE=1を指定した場合、パイプラインレジスタ
                          --!   を１段挿入するが、この場合バースト転送時に１ワード
                          --!   転送毎に１サイクルのウェイトが発生する.
                          --! * PORT_REGS_SIZE>1を指定した場合、パイプラインレジスタ
                          --!   を指定された段数挿入する. この場合、バースト転送時
                          --!   にウェイトは発生しない.
                          integer := 0
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
    -- Control Signals.
    -------------------------------------------------------------------------------
        TRAN_START      : --! @brief TRANSACTION START :
                          --! 開始信号.
                          --! * この信号はTRAN_ADDR/TRAN_SIZE/BURST_LEN/BURST_SIZE/
                          --!   START_PTR/XFER_LAST/XFER_SELを内部に設定して
                          --!   このモジュールを初期化した後、転送を開始する.
                          in  std_logic;
        TRAN_ADDR       : --! @brief TRANSACTION ADDRESS :
                          --! 転送開始アドレス.
                          --! * TRAN_START 信号により内部に取り込まれる.
                          in  std_logic_vector(TRAN_ADDR_BITS  -1 downto 0);
        TRAN_SIZE       : --! @brief START TRANSFER SIZE :
                          --! 転送バイト数.
                          --! * TRAN_START 信号により内部に取り込まれる.
                          in  std_logic_vector(TRAN_SIZE_BITS  -1 downto 0);
        BURST_LEN       : --! @brief Burst length.  
                          --! AXI4 バースト長.
                          --! * TRAN_START 信号により内部に取り込まれる.
                          in  std_logic_vector(BURST_LEN_BITS  -1 downto 0);
        BURST_SIZE      : --! @brief Burst size.
                          --! AXI4 バーストサイズ信号.
                          --! * TRAN_START 信号により内部に取り込まれる.
                          in  AXI4_ASIZE_TYPE;
        START_PTR       : --! @brief START POOL BUFFER POINTER :
                          --! 読み込み開始ポインタ.
                          --! * TRAN_START 信号により内部に取り込まれる.
                          in  std_logic_vector(POOL_PTR_BITS   -1 downto 0);
        TRAN_LAST       : --! @brief TRANSACTION LAST :
                          --! 最後のトランザクションであることを示すフラグ.
                          --! * TRAN_START 信号により内部に取り込まれる.
                          in  std_logic;
        TRAN_SEL        : --! @brief TRANSACTION SELECT :
                          --! 選択信号. PUSH_VAL、POOL_WENの生成に使う.
                          --! * TRAN_START 信号により内部に取り込まれる.
                          in  std_logic_vector(TRAN_SEL_BITS   -1 downto 0);
        XFER_VAL        : --! @brief TRANSFER VALID :
                          --! 転送応答信号.
                          out std_logic;
        XFER_DVAL       : --! @brief TRANSFER DATA VALID :
                          --! バッファからデータをリードする際のユニット単位での有効
                          --! 信号.
                          out std_logic_vector(POOL_DATA_BITS/8-1 downto 0);
        XFER_LAST       : --! @brief TRANSFER NONE :
                          --! 最終転送信号.
                          --! * 最後の転送であることを出力する.
                          out std_logic;
        XFER_NONE       : --! @brief TRANSFER NONE :
                          --! 転送終了信号.
                          --! * これ以上転送が無いことを出力する.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Outlet Port Signals.
    -------------------------------------------------------------------------------
        PORT_DATA       : --! @brief OUTLET PORT DATA :
                          --! ワードデータ出力.
                          out std_logic_vector(PORT_DATA_BITS-1   downto 0);
        PORT_STRB       : --! @brief OUTLET PORT DATA VALID :
                          --! ポートへデータを出力する際のユニット単位での有効信号.
                          out std_logic_vector(PORT_DATA_BITS/8-1 downto 0);
        PORT_LAST       : --! @brief OUTLET DATA LAST :
                          --! 最終ワード信号出力.
                          --! * 最後のワードデータ出力であることを示すフラグ.
                          out std_logic;
        PORT_ERROR      : --! @brief OUTLET RESPONSE :
                          --! エラーが発生したことを示すフラグ.
                          out std_logic;
        PORT_VAL        : --! @brief OUTLET PORT VALID :
                          --! 出力ワード有効信号.
                          --! * PORT_DATA/PORT_DVAL/PORT_LASTが有効であることを示す.
                          --! * PORT_VAL='1'and PORT_RDY='1'で上記信号がキューから
                          --!   取り出される.
                          out std_logic;
        PORT_RDY        : --! @brief OUTLET PORT READY :
                          --! 出力レディ信号.
                          --! * キューが次のワードデータを入力出来ることを示す.
                          --! * PORT_VAL='1'and PORT_RDY='1'で上記信号がキューから
                          --!   取り出される.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VAL        : --! @brief PULL VALID: 
                          --! PULL_LAST/PULL_SIZEが有効であることを示す.
                          out std_logic_vector(TRAN_SEL_BITS-1 downto 0);
        PULL_LAST       : --! @brief PULL LAST : 
                          --! 最後の転送"する事"を示すフラグ.
                          out std_logic;
        PULL_ERROR      : --! @brief PULL ERROR : 
                          --! エラーが発生したことを示すフラグ.
                          out std_logic;
        PULL_SIZE       : --! @brief PULL SIZE :
                          --! 転送"する"バイト数を出力する.
                          out std_logic_vector(PULL_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Size Signals.
    -------------------------------------------------------------------------------
        EXIT_VAL        : --! @brief EXIT VALID: 
                          --! EXIT_LAST/EXIT_SIZEが有効であることを示す.
                          out std_logic_vector(TRAN_SEL_BITS-1 downto 0);
        EXIT_LAST       : --! @brief EXIT LAST : 
                          --! 最後の出力"した事"を示すフラグ.
                          out std_logic;
        EXIT_ERROR      : --! @brief EXIT ERROR : 
                          --! エラーが発生したことを示すフラグ.
                          out std_logic;
        EXIT_SIZE       : --! @brief EXIT SIZE :
                          --! 出力"した"バイト数を出力する.
                          out std_logic_vector(EXIT_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pool Buffer Interface Signals.
    -------------------------------------------------------------------------------
        POOL_REN        : --! @brief POOL BUFFER READ ENABLE :
                          --! バッファからデータをリードすることを示す.
                          out std_logic_vector(TRAN_SEL_BITS-1 downto 0);
        POOL_PTR        : --! @brief POOL BUFFER WRITE POINTER :
                          --! ライト時にデータを書き込むバッファの位置を出力する.
                          out std_logic_vector(POOL_PTR_BITS-1 downto 0);
        POOL_DVAL       : --! @brief POOL BUFFER DATA VALID :
                          --! バッファからデータをリードする際のユニット単位での有効
                          --! 信号.
                          --! * POOL_REN='1'の場合にのみ有効.
                          --! * POOL_REN='0'の場合のこの信号の値は不定.
                          out std_logic_vector(POOL_DATA_BITS/8-1 downto 0);
        POOL_ERROR      : --! @brief EXIT ERROR : 
                          --! エラーが発生したことを示すフラグ.
                          in  std_logic;
        POOL_DATA       : --! @brief POOL BUFFER READ DATA :
                          --! バッファからのリードデータ入力.
                          in  std_logic_vector(POOL_DATA_BITS  -1 downto 0);
        POOL_VAL        : --! @brief POOL BUFFER WRITE READY :
                          --! バッファにデータを書き込み可能な事をを示す.
                          in  std_logic;
        POOL_RDY        : --! @brief POOL BUFFER WRITE READY :
                          --! バッファにデータを書き込み可能な事をを示す.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- Status Signals.
    -------------------------------------------------------------------------------
        BUSY            : --! @brief QUEUE BUSY :
                          --! キューが動作中であることを示す信号.
                          --! * 最初にデータが入力されたときにアサートされる.
                          --! * 最後のデータが出力し終えたらネゲートされる.
                          out  std_logic
    );
end AXI4_DATA_OUTLET_PORT;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     PIPEWORK.COMPONENTS.POOL_OUTLET_PORT;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_DATA_PORT;
architecture RTL of AXI4_DATA_OUTLET_PORT is
    -------------------------------------------------------------------------------
    -- データバスのバイト数の２のべき乗値を計算する関数.
    -------------------------------------------------------------------------------
    function CALC_DATA_SIZE(WIDTH:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**(value+3) < WIDTH) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    -------------------------------------------------------------------------------
    -- AXI4 データバスのバイト数の２のべき乗値.
    -------------------------------------------------------------------------------
    constant PORT_DATA_SIZE : integer := CALC_DATA_SIZE(PORT_DATA_BITS);
    -------------------------------------------------------------------------------
    -- レジスタインターフェース側のデータバスのバイト数の２のべき乗値.
    -------------------------------------------------------------------------------
    constant POOL_DATA_SIZE : integer := CALC_DATA_SIZE(POOL_DATA_BITS);
    -------------------------------------------------------------------------------
    -- 最大転送バイト数
    -------------------------------------------------------------------------------
    constant XFER_MAX_SIZE  : integer := BURST_LEN_BITS + PORT_DATA_SIZE;
    constant XFER_BEAT_SEL  : std_logic_vector(XFER_MAX_SIZE downto XFER_MAX_SIZE) := "1";
    -------------------------------------------------------------------------------
    -- 内部サイズビット数
    -------------------------------------------------------------------------------
    function CALC_SIZE_BITS return integer is begin
        if (POOL_DATA_BITS >= PORT_DATA_BITS) then
            return CALC_DATA_SIZE(POOL_DATA_BITS) + 1;
        else
            return CALC_DATA_SIZE(PORT_DATA_BITS) + 1;
        end if;
    end function;
    constant SIZE_BITS      : integer := CALC_SIZE_BITS;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type     SETTING_TYPE   is record
             Q_Q_SIZE       : integer;  -- Q:POOL_OUTLET_PORT の QUEUE_SIZE
             O_I_SIZE       : integer;  -- O:AXI4_DATA_PORT の I_REGS_SIZE
             O_O_SIZE       : integer;  -- O:AXI4_DATA_PORT の O_REGS_SIZE
    end record;
    function SET_SETTING return SETTING_TYPE is
        variable setting : SETTING_TYPE;
    begin
        setting.O_O_SIZE := PORT_REGS_SIZE;
        if (USE_BURST_SIZE /= 0) and 
           (PORT_DATA_BITS = ALIGNMENT_BITS) and
           (POOL_DATA_BITS = ALIGNMENT_BITS) then
            setting.Q_Q_SIZE := -1;
            setting.O_I_SIZE :=  2;
        else
            setting.Q_Q_SIZE :=  0;
            setting.O_I_SIZE :=  0;
        end if;
        return setting;
    end function;
    constant SET            : SETTING_TYPE := SET_SETTING;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant USER_LO        : integer := 0;
    constant USER_SEL_LO    : integer := USER_LO;
    constant USER_SEL_HI    : integer := USER_SEL_LO + TRAN_SEL_BITS-1;
    constant USER_DONE_POS  : integer := USER_SEL_HI + 1;
    constant USER_HI        : integer := USER_DONE_POS;
    constant USER_BITS      : integer := USER_HI - USER_LO + 1;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   i_busy         : std_logic;
    signal   i_chop         : std_logic;
    signal   i_valid        : std_logic;
    signal   i_ready        : std_logic;
    signal   i_last         : std_logic;
    signal   i_size         : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   i_ben          : std_logic_vector(POOL_DATA_BITS/8-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   o_pull_valid   : std_logic_vector(TRAN_SEL_BITS -1 downto 0);
    signal   o_pull_last    : std_logic;
    signal   o_pull_error   : std_logic;
    signal   o_pull_size    : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   q_data         : std_logic_vector(PORT_DATA_BITS  -1 downto 0);
    signal   q_strb         : std_logic_vector(PORT_DATA_BITS/8-1 downto 0);
    signal   q_size         : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   q_user         : std_logic_vector(USER_HI downto USER_LO);
    signal   q_done         : std_logic;
    signal   q_last         : std_logic;
    signal   q_error        : std_logic;
    signal   q_valid        : std_logic;
    signal   q_ready        : std_logic;
    signal   q_busy         : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   o_size         : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   o_sel          : std_logic_vector(TRAN_SEL_BITS -1 downto 0);
    signal   o_user         : std_logic_vector(USER_HI downto USER_LO);
    signal   o_done         : std_logic;
    signal   o_error        : std_logic;
    signal   o_last         : std_logic;
    signal   o_valid        : std_logic;
    signal   o_ready        : std_logic;
    signal   o_busy         : std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_valid   <= POOL_VAL;
    i_chop    <= '1' when (i_valid = '1' and i_ready = '1') else '0';
    POOL_RDY  <= i_ready;
    POOL_DVAL <= i_ben;
    XFER_VAL  <= i_chop;
    XFER_DVAL <= i_ben;
    XFER_LAST <= i_last;
    -------------------------------------------------------------------------------
    -- i_ben  : バイトイネーブル信号.
    -- i_size : １ワード毎のリードバイト数.
    -- i_last : 最後のワードであることを示すフラグ.
    -------------------------------------------------------------------------------
    BEN: CHOPPER
        generic map (
            BURST           => 1               ,
            MIN_PIECE       => POOL_DATA_SIZE  ,
            MAX_PIECE       => POOL_DATA_SIZE  ,
            MAX_SIZE        => XFER_MAX_SIZE   ,
            ADDR_BITS       => POOL_PTR_BITS   ,
            SIZE_BITS       => TRAN_SIZE_BITS  ,
            COUNT_BITS      => 1               ,
            PSIZE_BITS      => SIZE_BITS       ,
            GEN_VALID       => 1
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- 各種初期値
        ---------------------------------------------------------------------------
            ADDR            => START_PTR       , -- In  :
            SIZE            => TRAN_SIZE       , -- In  :
            SEL             => XFER_BEAT_SEL   , -- In  :
            LOAD            => TRAN_START      , -- In  :
        ---------------------------------------------------------------------------
        -- 制御信号
        ---------------------------------------------------------------------------
            CHOP            => i_chop          , -- In  :
        ---------------------------------------------------------------------------
        -- ピースカウンタ/フラグ出力
        ---------------------------------------------------------------------------
            COUNT           => open            , -- Out :
            NONE            => open            , -- Out :
            LAST            => i_last          , -- Out :
            NEXT_NONE       => XFER_NONE       , -- Out :
            NEXT_LAST       => open            , -- Out :
        ---------------------------------------------------------------------------
        -- １ワードのバイト数
        ---------------------------------------------------------------------------
            PSIZE           => i_size          , -- Out :
            NEXT_PSIZE      => open            , -- Out :
        ---------------------------------------------------------------------------
        -- バイトイネーブル信号
        ---------------------------------------------------------------------------
            VALID           => i_ben           , -- Out :
            NEXT_VALID      => open              -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    Q: POOL_OUTLET_PORT                          -- 
        generic map (                            -- 
            UNIT_BITS       => 8               , --
            WORD_BITS       => ALIGNMENT_BITS  , --
            PORT_DATA_BITS  => PORT_DATA_BITS  , --
            POOL_DATA_BITS  => POOL_DATA_BITS  , --
            PORT_PTR_BITS   => TRAN_ADDR_BITS  , --
            POOL_PTR_BITS   => POOL_PTR_BITS   , --
            SEL_BITS        => TRAN_SEL_BITS   , --
            SIZE_BITS       => SIZE_BITS       , --
            POOL_SIZE_VALID => 1               , --
            QUEUE_SIZE      => SET.Q_Q_SIZE      -- 
        )                                        -- 
        port map (                               -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            START           => TRAN_START      , -- In  :
            START_POOL_PTR  => START_PTR       , -- In  :
            START_PORT_PTR  => TRAN_ADDR       , -- In  :
            XFER_LAST       => TRAN_LAST       , -- In  :
            XFER_SEL        => TRAN_SEL        , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Port Signals.
        ---------------------------------------------------------------------------
            PORT_DATA       => q_data          , -- Out :
            PORT_DVAL       => q_strb          , -- Out :
            PORT_ERROR      => q_error         , -- Out :
            PORT_LAST       => q_last          , -- Out :
            PORT_SIZE       => q_size          , -- Out :
            PORT_VAL        => q_valid         , -- Out :
            PORT_RDY        => q_ready         , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PULL_VAL        => o_pull_valid    , -- Out :
            PULL_LAST       => o_pull_last     , -- Out :
            PULL_ERROR      => o_pull_error    , -- Out :
            PULL_SIZE       => o_pull_size     , -- Out :
        ---------------------------------------------------------------------------
        -- Pool Buffer Interface Signals.
        ---------------------------------------------------------------------------
            POOL_REN        => POOL_REN        , -- Out :
            POOL_PTR        => POOL_PTR        , -- Out :
            POOL_DATA       => POOL_DATA       , -- In  :
            POOL_ERROR      => POOL_ERROR      , -- In  :
            POOL_DVAL       => i_ben           , -- In  :
            POOL_SIZE       => i_size          , -- In  :
            POOL_LAST       => i_last          , -- In  :
            POOL_VAL        => i_valid         , -- In  :
            POOL_RDY        => i_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- Status Signals.
        ---------------------------------------------------------------------------
            BUSY            => q_busy            -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                q_user <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                q_user <= (others => '0');
            elsif (TRAN_START = '1') then
                q_user(USER_SEL_HI downto USER_SEL_LO) <= TRAN_SEL;
                q_user(USER_DONE_POS)                  <= TRAN_LAST;
            end if;
        end if;
    end process;
    q_done <= q_user(USER_DONE_POS);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O: AXI4_DATA_PORT                            -- 
        generic map (                            -- 
            DATA_BITS       => PORT_DATA_BITS  , --
            ADDR_BITS       => TRAN_ADDR_BITS  , --
            SIZE_BITS       => SIZE_BITS       , --
            USER_BITS       => USER_BITS       , --
            ALEN_BITS       => BURST_LEN_BITS  , --
            USE_ASIZE       => USE_BURST_SIZE  , --
            I_REGS_SIZE     => SET.O_I_SIZE    , --
            O_REGS_SIZE     => SET.O_O_SIZE      --
        )                                        -- 
        port map (                               -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            START           => TRAN_START      , -- In  :
            ASIZE           => BURST_SIZE      , -- In  :
            ALEN            => BURST_LEN       , -- In  :
            ADDR            => TRAN_ADDR       , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Port Signals.
        ---------------------------------------------------------------------------
            I_DATA          => q_data          , -- In  :
            I_STRB          => q_strb          , -- In  :
            I_SIZE          => q_size          , -- In  :
            I_USER          => q_user          , -- In  :
            I_LAST          => q_last          , -- In  :
            I_ERROR         => q_error         , -- In  :
            I_VALID         => q_valid         , -- In  :
            I_READY         => q_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Port Signals.
        ---------------------------------------------------------------------------
            O_DATA          => PORT_DATA       , -- Out :
            O_STRB          => PORT_STRB       , -- Out :
            O_SIZE          => o_size          , -- Out :
            O_USER          => o_user          , -- Out :
            O_ERROR         => o_error         , -- Out :
            O_LAST          => o_last          , -- Out :
            O_VALID         => o_valid         , -- Out :
            O_READY         => o_ready         , -- In  :
        ---------------------------------------------------------------------------
        -- Status Signals.
        ---------------------------------------------------------------------------
            BUSY            => o_busy            -- Out :
        );
    PORT_VAL   <= o_valid;
    PORT_LAST  <= o_last;
    PORT_ERROR <= o_error;
    o_ready    <= PORT_RDY;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PULL_VAL   <= o_pull_valid;
    PULL_ERROR <= o_pull_error;
    PULL_LAST  <= '1' when (o_pull_last = '1' and q_done = '1') else '0';
    PULL_SIZE  <= std_logic_vector(resize(unsigned(o_pull_size), PULL_SIZE_BITS));
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    o_sel      <= o_user(USER_SEL_HI downto USER_SEL_LO);
    o_done     <= o_user(USER_DONE_POS);
    EXIT_VAL   <= o_sel when (o_valid = '1' and o_ready = '1') else (others => '0');
    EXIT_ERROR <= o_error;
    EXIT_LAST  <= '1' when (o_last  = '1' and o_done = '1') else '0';
    EXIT_SIZE  <= std_logic_vector(resize(unsigned(o_size     ), EXIT_SIZE_BITS));
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BUSY <= '1' when (o_busy = '1' or q_busy = '1') else '0';
end RTL;