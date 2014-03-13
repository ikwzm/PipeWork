-----------------------------------------------------------------------------------
--!     @file    float_intake_manifold_valve.vhd
--!     @brief   FLOAT INTAKE MANIFOLD VALVE
--!     @version 1.5.4
--!     @date    2014/2/20
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2014 Ichiro Kawazome
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
--! @brief   FLOAT INTAKE MANIFOLD VALVE :
-----------------------------------------------------------------------------------
entity  FLOAT_INTAKE_MANIFOLD_VALVE is
    generic (
        FIXED_CLOSE     : --! @brief FIXED VALVE CLOSE :
                          --! フローカウンタによるフロー制御を行わず、常に栓が閉じ
                          --! た状態にするか否かを指定する.
                          --! * FIXED_CLOSE=1 : 常に栓が閉じた状態にする.
                          --! * FIXED_CLOSE=0 : 栓の状態は他の変数に依存する.
                          integer range 0 to 1 := 0;
        FIXED_FLOW_OPEN : --! @brief FIXED VALVE FLOE OPEN :
                          --! フローカウンタによるフロー制御を行わず、常にフロー栓
                          --! が開いた状態にするか否かを指定する.
                          --! * FIXED_FLOW_OPEN=1 : 常にフロー栓が開いた状態にする.
                          --! * FIXED_FLOW_OPEN=0 : フロー栓の状態は他の変数に依存
                          --!   する.
                          integer range 0 to 1 := 0;
        FIXED_POOL_OPEN : --! @brief FIXED VALVE POOL OPEN :
                          --! プールカウンタによるフロー制御を行わず、常にプール栓
                          --! が開いた状態にするか否かを指定する.
                          --! * FIXED_POOL_OPEN=1 : 常にプール栓が開いた状態にする.
                          --! * FIXED_POOL_OPEN=0 : プール栓の状態は他の変数に依存
                          --!   する.
                          integer range 0 to 1 := 0;
        USE_PULL_RSV    : --! @brief USE PULL RESERVE SIGNALS :
                          --! フローカウンタの減算に PULL_RSV_SIZE を使うか 
                          --! PULL_FIX_SIZE を使うかを指定する.
                          --! * USE_PULL_RSV=1 : フローカウンタの減算にPULL_RSV_SIZE
                          --!   (入力する予定(RESERVE)のバイト数)を使う.
                          --! * USE_PULL_RSV=0 : フローカウンタの減算にPULL_FIN_SIZE
                          --!   (入力が確定(FINAL)したバイト数)を使う.
                          integer range 0 to 1 := 0;
        USE_POOL_PUSH   : --! @brief USE POOL PUSH SIGNALS :
                          --! プールカウンタの加算に FLOW_PUSH_SIZE を使うか 
                          --! POOL_PUSH_SIZE を使うかを指定する.
                          --! * USE_POOL_PUSH=1 : フローカウンタの加算に
                          --!   POOL_PUSH_SIZEを使う.
                          --! * USE_POOL_PUSH=0 : プールカウンタの加算に
                          --!   FLOW_PUSH_SIZEを使う.
                          integer range 0 to 1 := 1;
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! 内部カウンタのビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! サイズ信号のビット数を指定する.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
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
        RESET           : --! @brief RESET REQUEST :
                          --! 強制的に内部状態をリセットする事を指示する信号.
                          in  std_logic;
        PAUSE           : --! @brief PAUSE REQUEST :
                          --! 強制的にフローを一時的に停止する事を指示する信号.
                          in  std_logic;
        STOP            : --! @brief STOP  REQUEST :
                          --! 強制的にフローを中止する事を指示する信号.
                          in  std_logic;
        INTAKE_OPEN     : --! @brief INTAKE VALVE OPEN FLAG :
                          --! 入力(INTAKE)側の栓が開いている事を示すフラグ.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! 出力(OUTLET)側の栓が開いている事を示すフラグ.
                          in  std_logic;
        POOL_SIZE       : --! @brief POOL SIZE :
                          --! プールの大きさをバイト数で指定する.
                          in  std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以下の時に入力を開始する.
                          --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                          in  std_logic_vector(COUNT_BITS-1 downto 0);
        POOL_READY_LEVEL: --! @brief POOL READY LEVEL :
                          --! PULL_FIN_SIZEによるプールカウンタの減算結果が、この値
                          --! 以下の時にPOOL_READY 信号をアサートする.
                          in  std_logic_vector(COUNT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Final Size Signals.
    -------------------------------------------------------------------------------
        PULL_FIN_VALID  : --! @brief PULL FINAL VALID :
                          --! PULL_FIN_LAST/PULL_FIN_SIZEが有効であることを示す信号.
                          --! * 栓が固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PULL_FIN_LAST   : --! @brief PULL FINAL LAST :
                          --! 最後のPULL_FIN入力であることを示す信号.
                          --! * 栓が固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PULL_FIN_SIZE   : --! @brief PUSH RESERVE SIZE :
                          --! 出力が確定(FINAL)したバイト数.
                          --! * 栓が固定(Fixed)モードの場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Reserve Size Signals.
    -------------------------------------------------------------------------------
        PULL_RSV_VALID  : --! @brief PULL RESERVE VALID :
                          --! PULL_RSV_LAST/PULL_RSV_SIZEが有効であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * USE_PULL_RSV=0 の場合は未使用.
                          in  std_logic;
        PULL_RSV_LAST   : --! @brief PULL RESERVE LAST :
                          --! 最後のPULL_RSV入力であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * USE_PULL_RSV=0 の場合は未使用.
                          in  std_logic;
        PULL_RSV_SIZE   : --! @brief PULL RESERVE SIZE :
                          --! 出力する予定(RESERVE)のバイト数.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * USE_PULL_RSV=0 の場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Flow Push Size Signals.
    -------------------------------------------------------------------------------
        FLOW_PUSH_VALID : --! @brief FLOW PUSH VALID :
                          --! FLOW_PUSH_LAST/FLOW_PUSH_SIZEが有効であることを示す信号.
                          in  std_logic;
        FLOW_PUSH_LAST  : --! @brief FLOW PUSH LAST :
                          --! 最後の入力であることを示す信号.
                          in  std_logic;
        FLOW_PUSH_SIZE  : --! @brief FLOW PUSH SIZE :
                          --! 入力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW INTAKE READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY='1' : 再開.
                          --! * FLOW_READY='0' : 一時停止.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常に'0'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常に'1'を
                          --!   出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以下の時に
                          --!   '1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL を越えた時に
                          --!   '0'を出力する.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW INTAKE PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE='0' : 再開.
                          --! * FLOW_PAUSE='1' : 一時停止.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常に'1'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常に'0'を
                          --!   出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以下の時に
                          --!   '0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL を越えた時に
                          --!   '1'を出力する.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW INTAKE STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_PAUSE=1 : 中止.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常に'1'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常に'0'を
                          --!   出力する.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW INTAKE LAST :
                          --! INTAKE側では未使用. 常に'0'を出力.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW INTAKE ENABLE SIZE :
                          --! 入力可能なバイト数
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常にALL'0'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常にALL'1'を
                          --!   出力する.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Flow Counter.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! 現在のフローカウンタの値を出力.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常にALL'0'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常にALL'1'を
                          --!   出力する.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_ZERO       : --! @brief FLOW COUNTER is ZERO :
                          --! フローカウンタの値が0になったことを示すフラグ.
                          out std_logic;
        FLOW_POS        : --! @brief FLOW COUNTER is POSitive :
                          --! フローカウンタの値が正(>0)になったことを示すフラグ.
                          out std_logic;
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! フローカウンタの値が負(<0)になったことを示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- Intake Pool Size Signals.
    -------------------------------------------------------------------------------
        POOL_PUSH_RESET : --! @brief POOL PUSH RESET :
                          --! POOL COUNTER の値をリセットすることを指示する信号.
                          --! * この信号をアサートすることにより、FLOW COUNTER の値
                          --!   を POOL COUNTER にセットする.
                          --! * POOL COUNTER をリセットすることにより、再送、再出力
                          --!   に対応することが出来る.
                          in  std_logic;
        POOL_PUSH_VALID : --! @brief POOL PUSH VALID :
                          --! POOL_PUSH_SIZEが有効であることを示す信号.
                          in  std_logic;
        POOL_PUSH_LAST  : --! @brief POOL PUSH LAST :
                          --! 最後のPOOL_PUSH入力であることを示す信号.
                          in  std_logic;
        POOL_PUSH_SIZE  : --! @brief FLOW PUSH SIZE :
                          --! 入力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Pool Counter.
    -------------------------------------------------------------------------------
        POOL_COUNT      : --! @brief POOL COUNT :
                          --! 現在のプールカウンタの値を出力.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常にALL'0'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_POOL_OPEN=1)の時は常にALL'1'を
                          --!   出力する.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        POOL_READY      : --! @brief POOL READY :
                          --! プールカウンタの値が POOL_READY_LEVEL 以下であること
                          --! を示すフラグ.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常に'0'を出力す
                          --!   る.
                          --! * バルブが開固定(FIXED_POOL_OPEN=1)の時は常に'1'を出
                          --!   力する.
                          out std_logic
    );
end FLOAT_INTAKE_MANIFOLD_VALVE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.FLOAT_INTAKE_VALVE;
architecture RTL of FLOAT_INTAKE_MANIFOLD_VALVE is
    signal    intake_ready  : std_logic;
    signal    intake_pause  : std_logic;
    signal    intake_stop   : std_logic;
    signal    intake_last   : std_logic;
    signal    intake_size   : std_logic_vector(SIZE_BITS -1 downto 0);
    signal    intake_count  : std_logic_vector(COUNT_BITS-1 downto 0);
    signal    intake_zero   : std_logic;
    signal    intake_pos    : std_logic;
    signal    intake_neg    : std_logic;
    signal    intake_paused : std_logic;
    constant  NULL_LOAD     : std_logic := '0';
    constant  NULL_COUNT    : std_logic_vector(COUNT_BITS-1 downto 0) := (others => '0');
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_FIXED_CLOSE     : if (FIXED_CLOSE /= 0) generate
        PAUSED     <= '0';
        FLOW_READY <= '0';
        FLOW_PAUSE <= '1';
        FLOW_STOP  <= '1';
        FLOW_LAST  <= '1';
        FLOW_ZERO  <= '1';
        FLOW_POS   <= '0';
        FLOW_NEG   <= '0';
        FLOW_SIZE  <= (others => '0');
        FLOW_COUNT <= (others => '0');
        POOL_COUNT <= (others => '0');
        POOL_READY <= '0';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_FIXED_FLOW_OPEN : if (FIXED_CLOSE = 0 and FIXED_FLOW_OPEN /= 0) generate
        PAUSED     <= '0';
        FLOW_READY <= '1';
        FLOW_PAUSE <= '0';
        FLOW_STOP  <= '0';
        FLOW_LAST  <= '0';
        FLOW_ZERO  <= '0';
        FLOW_POS   <= '1';
        FLOW_NEG   <= '0';
        FLOW_SIZE  <= (others => '1');
        FLOW_COUNT <= (others => '1');
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_FIXED_POOL_OPEN : if (FIXED_CLOSE = 0 and FIXED_POOL_OPEN /= 0) generate
        POOL_COUNT <= (others => '1');
        POOL_READY <= '1';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_USE_PULL_RSV    : if (FIXED_CLOSE      = 0) and
                             (FIXED_FLOW_OPEN  = 0) and
                             (USE_PULL_RSV    /= 0) generate
        VALVE: FLOAT_INTAKE_VALVE                    -- 
            generic map (                            -- 
                COUNT_BITS      => COUNT_BITS      , -- 
                SIZE_BITS       => SIZE_BITS         -- 
            )                                        -- 
            port map (                               -- 
            -----------------------------------------------------------------------
            -- Clock & Reset Signals.
            -----------------------------------------------------------------------
                CLK             => CLK             , -- In :
                RST             => RST             , -- In :
                CLR             => CLR             , -- In :
            -----------------------------------------------------------------------
            -- Control Signals.
            -----------------------------------------------------------------------
                RESET           => RESET           , -- In :
                PAUSE           => PAUSE           , -- In :
                STOP            => STOP            , -- In :
                INTAKE_OPEN     => INTAKE_OPEN     , -- In :
                OUTLET_OPEN     => OUTLET_OPEN     , -- In :
                POOL_SIZE       => POOL_SIZE       , -- In :
                FLOW_READY_LEVEL=> FLOW_READY_LEVEL, -- In :
            -----------------------------------------------------------------------
            -- Flow Counter Load Signals.
            -----------------------------------------------------------------------
                LOAD            => NULL_LOAD       , -- In :
                LOAD_COUNT      => NULL_COUNT      , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => FLOW_PUSH_VALID , -- In :
                PUSH_LAST       => FLOW_PUSH_LAST  , -- In :
                PUSH_SIZE       => FLOW_PUSH_SIZE  , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => PULL_RSV_VALID  , -- In :
                PULL_LAST       => PULL_RSV_LAST   , -- In :
                PULL_SIZE       => PULL_RSV_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Outlet Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_READY      => FLOW_READY      , -- Out:
                FLOW_PAUSE      => FLOW_PAUSE      , -- Out:
                FLOW_STOP       => FLOW_STOP       , -- Out:
                FLOW_LAST       => FLOW_LAST       , -- Out:
                FLOW_SIZE       => FLOW_SIZE       , -- Out:
            -----------------------------------------------------------------------
            -- Flow Counter.
            -----------------------------------------------------------------------
                FLOW_COUNT      => FLOW_COUNT      , -- Out:
                FLOW_ZERO       => FLOW_ZERO       , -- Out:
                FLOW_POS        => FLOW_POS        , -- Out:
                FLOW_NEG        => FLOW_NEG        , -- Out:
                PAUSED          => PAUSED            -- Out:
            );
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_NO_USE_PULL_RSV : if (FIXED_CLOSE      = 0) and
                             (FIXED_FLOW_OPEN  = 0) and
                             (USE_PULL_RSV     = 0) generate
        FLOW_READY <= intake_ready;
        FLOW_PAUSE <= intake_pause;
        FLOW_STOP  <= intake_stop;
        FLOW_LAST  <= intake_last;
        FLOW_SIZE  <= intake_size;
        FLOW_COUNT <= intake_count;
        FLOW_ZERO  <= intake_zero;
        FLOW_POS   <= intake_pos;
        FLOW_NEG   <= intake_neg;
        PAUSED     <= intake_paused;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_NON_FIXED_CLOSE : if (FIXED_CLOSE = 0) generate
        VALVE: FLOAT_INTAKE_VALVE                        -- 
            generic map (                            -- 
                COUNT_BITS      => COUNT_BITS      , -- 
                SIZE_BITS       => SIZE_BITS         -- 
            )                                        -- 
            port map (                               -- 
            -----------------------------------------------------------------------
            -- Clock & Reset Signals.
            -----------------------------------------------------------------------
                CLK             => CLK             , -- In :
                RST             => RST             , -- In :
                CLR             => CLR             , -- In :
            -----------------------------------------------------------------------
            -- Control Signals.
            -----------------------------------------------------------------------
                RESET           => RESET           , -- In :
                PAUSE           => PAUSE           , -- In :
                STOP            => STOP            , -- In :
                INTAKE_OPEN     => INTAKE_OPEN     , -- In :
                OUTLET_OPEN     => OUTLET_OPEN     , -- In :
                POOL_SIZE       => POOL_SIZE       , -- In :
                FLOW_READY_LEVEL=> FLOW_READY_LEVEL, -- In :
            -----------------------------------------------------------------------
            -- Flow Counter Load Signals.
            -----------------------------------------------------------------------
                LOAD            => NULL_LOAD       , -- In :
                LOAD_COUNT      => NULL_COUNT      , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => FLOW_PUSH_VALID , -- In :
                PUSH_LAST       => FLOW_PUSH_LAST  , -- In :
                PUSH_SIZE       => FLOW_PUSH_SIZE  , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => PULL_FIN_VALID  , -- In :
                PULL_LAST       => PULL_FIN_LAST   , -- In :
                PULL_SIZE       => PULL_FIN_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Outlet Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_READY      => intake_ready    , -- Out:
                FLOW_PAUSE      => intake_pause    , -- Out:
                FLOW_STOP       => intake_stop     , -- Out:
                FLOW_LAST       => intake_last     , -- Out:
                FLOW_SIZE       => intake_size     , -- Out:
            -----------------------------------------------------------------------
            -- Flow Counter.
            -----------------------------------------------------------------------
                FLOW_COUNT      => intake_count    , -- Out:
                FLOW_ZERO       => intake_zero     , -- Out:
                FLOW_POS        => intake_pos      , -- Out:
                FLOW_NEG        => intake_neg      , -- Out:
                PAUSED          => intake_paused     -- Out:
            );
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_USE_POOL_PUSH   : if (FIXED_CLOSE      = 0) and
                             (FIXED_POOL_OPEN  = 0) and
                             (USE_POOL_PUSH   /= 0) generate
        VALVE: FLOAT_INTAKE_VALVE                   -- 
            generic map (                            -- 
                COUNT_BITS      => COUNT_BITS      , -- 
                SIZE_BITS       => SIZE_BITS         -- 
            )                                        -- 
            port map (                               -- 
            -----------------------------------------------------------------------
            -- Clock & Reset Signals.
            -----------------------------------------------------------------------
                CLK             => CLK             , -- In :
                RST             => RST             , -- In :
                CLR             => CLR             , -- In :
            -----------------------------------------------------------------------
            -- Control Signals.
            -----------------------------------------------------------------------
                RESET           => RESET           , -- In :
                PAUSE           => PAUSE           , -- In :
                STOP            => STOP            , -- In :
                INTAKE_OPEN     => INTAKE_OPEN     , -- In :
                OUTLET_OPEN     => OUTLET_OPEN     , -- In :
                POOL_SIZE       => POOL_SIZE       , -- In :
                FLOW_READY_LEVEL=> POOL_READY_LEVEL, -- In :
            -----------------------------------------------------------------------
            -- Flow Counter Load Signals.
            -----------------------------------------------------------------------
                LOAD            => POOL_PUSH_RESET , -- In :
                LOAD_COUNT      => intake_count    , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => POOL_PUSH_VALID , -- In :
                PUSH_LAST       => POOL_PUSH_LAST  , -- In :
                PUSH_SIZE       => POOL_PUSH_SIZE  , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => PULL_FIN_VALID  , -- In :
                PULL_LAST       => PULL_FIN_LAST   , -- In :
                PULL_SIZE       => PULL_FIN_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Outlet Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_READY      => POOL_READY      , -- Out:
                FLOW_PAUSE      => open            , -- Out:
                FLOW_STOP       => open            , -- Out:
                FLOW_LAST       => open            , -- Out:
                FLOW_SIZE       => open            , -- Out:
            -----------------------------------------------------------------------
            -- Flow Counter.
            -----------------------------------------------------------------------
                FLOW_COUNT      => POOL_COUNT      , -- Out:
                FLOW_ZERO       => open            , -- Out:
                FLOW_POS        => open            , -- Out:
                FLOW_NEG        => open            , -- Out:
                PAUSED          => open              -- Out:
            );
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_NO_USE_POOL_PULL: if (FIXED_CLOSE      = 0) and
                             (FIXED_POOL_OPEN  = 0) and
                             (USE_POOL_PUSH    = 0) generate
        POOL_READY <= intake_ready;
        POOL_COUNT <= intake_count;
    end generate;
end RTL;
