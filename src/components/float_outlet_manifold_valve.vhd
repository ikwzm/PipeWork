-----------------------------------------------------------------------------------
--!     @file    float_outlet_manifold_valve.vhd
--!     @brief   FLOAT OUTLET MANIFOLD VALVE
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
--! @brief   FLOAT OUTLET MANIFOLD VALVE :
-----------------------------------------------------------------------------------
entity  FLOAT_OUTLET_MANIFOLD_VALVE is
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
        USE_PUSH_RSV    : --! @brief USE PUSH RESERVE SIGNALS :
                          --! フローカウンタの加算に PUSH_RSV_SIZE を使うか 
                          --! PUSH_FIX_SIZE を使うかを指定する.
                          --! * USE_PUSH_RSV=1 : フローカウンタの加算にPUSH_RSV_SIZE
                          --!   (入力する予定(RESERVE)のバイト数)を使う.
                          --! * USE_PUSH_RSV=0 : フローカウンタの加算にPUSH_FIN_SIZE
                          --!   (入力が確定(FINAL)したバイト数)を使う.
                          integer range 0 to 1 := 0;
        USE_POOL_PULL   : --! @brief USE POOL PULL SIGNALS :
                          --! プールカウンタの減算に FLOW_PULL_SIZE を使うか 
                          --! POOL_PULL_SIZE を使うかを指定する.
                          --! * USE_POOL_PULL=1 : フローカウンタの加算に
                          --!   POOL_PULL_SIZEを使う.
                          --! * USE_POOL_PULL=0 : プールカウンタの減算に
                          --!   FLOW_PULL_SIZEを使う.
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
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以上の時に転送を開始する.
                          --! フローカウンタの値がこの値未満の時に転送を一時停止.
                          in  std_logic_vector(COUNT_BITS-1 downto 0);
        POOL_READY_LEVEL: --! @brief POOL READY LEVEL :
                          --! PUSH_FIN_SIZEによるフローカウンタの加算結果が、この値
                          --! 以上の時にPOOL_READY 信号をアサートする.
                          in  std_logic_vector(COUNT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Final Size Signals.
    -------------------------------------------------------------------------------
        PUSH_FIN_VALID  : --! @brief PUSH FINAL VALID :
                          --! PUSH_FIN_LAST/PUSH_FIN_SIZEが有効であることを示す信号.
                          --! * 栓が固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PUSH_FIN_LAST   : --! @brief PUSH FINAL LAST :
                          --! 最後のPUSH_FIN入力であることを示す信号.
                          --! * 栓が固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PUSH_FIN_SIZE   : --! @brief PUSH FINAL SIZE :
                          --! 入力が確定(FINAL)したバイト数.
                          --! * 栓が固定(Fixed)モードの場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Reserve Size Signals.
    -------------------------------------------------------------------------------
        PUSH_RSV_VALID  : --! @brief PUSH RESERVE VALID :
                          --! PUSH_RSV_LAST/PUSH_RSV_SIZEが有効であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * USE_PUSH_RSV=0 の場合は未使用.
                          in  std_logic;
        PUSH_RSV_LAST   : --! @brief PUSH RESERVE LAST :
                          --! 最後のPUSH_RSV入力であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * USE_PUSH_RSV=0 の場合は未使用.
                          in  std_logic;
        PUSH_RSV_SIZE   : --! @brief PUSH RESERVE SIZE :
                          --! 入力する予定(RESERVE)のバイト数.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * USE_PUSH_RSV=0 の場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Flow Pull Size Signals.
    -------------------------------------------------------------------------------
        FLOW_PULL_VALID : --! @brief FLOW PULL VALID :
                          --! FLOW_PULL_LAST/FLOW_PULL_SIZEが有効であることを示す信号.
                          in  std_logic;
        FLOW_PULL_LAST  : --! @brief FLOW PULL LAST :
                          --! 最後の出力であることを示す信号.
                          in  std_logic;
        FLOW_PULL_SIZE  : --! @brief FLOW PULL SIZE :
                          --! 出力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW OUTLET READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY='1' : 再開.
                          --! * FLOW_READY='0' : 一時停止.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常に'0'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常に'1'を
                          --!   出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以上の時に
                          --!   '1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 未満の時に
                          --!   '0'を出力する.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW OUTLET PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE='0' : 再開.
                          --! * FLOW_PAUSE='1' : 一時停止.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常に'1'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常に'0'を
                          --!   出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以上の時に
                          --!   '0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 未満の時に
                          --!   '1'を出力する.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW OUTLET STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_PAUSE=1 : 中止.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常に'1'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常に'0'を
                          --!   出力する.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW OUTLET LAST :
                          --! 入力側から最後の入力を示すフラグがあったことを示す.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW OUTLET ENABLE SIZE :
                          --! 出力可能なバイト数
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常にALL'0'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_FLOW_OPEN=1)の時は常にALL'1'を
                          --!   出力する.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Flow Counter.
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
    -- Outlet Pool Size Signals.
    -------------------------------------------------------------------------------
        POOL_PULL_RESET : --! @brief POOL PULL RESET :
                          --! POOL COUNTER の値をリセットすることを指示する信号.
                          --! * この信号をアサートすることにより、FLOW COUNTER の値
                          --!   を POOL COUNTER にセットする.
                          --! * POOL COUNTER をリセットすることにより、再送、再出力
                          --!   に対応することが出来る.
                          in  std_logic;
        POOL_PULL_VALID : --! @brief POOL PULL VALID :
                          --! POOL_PULL_SIZEが有効であることを示す信号.
                          in  std_logic;
        POOL_PULL_LAST  : --! @brief POOL PULL LAST :
                          --! 最後のPOOL_PULL入力であることを示す信号.
                          in  std_logic;
        POOL_PULL_SIZE  : --! @brief FLOW PULL SIZE :
                          --! 出力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Pool Counter.
    -------------------------------------------------------------------------------
        POOL_COUNT      : --! @brief POOL COUNT :
                          --! 現在のプールカウンタの値を出力.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常にALL'0'を出力
                          --!   する.
                          --! * バルブが開固定(FIXED_POOL_OPEN=1)の時は常にALL'1'を
                          --!   出力する.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        POOL_READY      : --! @brief POOL READY :
                          --! プールカウンタの値が POOL_READY_LEVEL 以上であること
                          --! を示すフラグ.
                          --! * バルブが閉固定(FIXED_CLOSE=1)の時は常に'0'を出力す
                          --!   る.
                          --! * バルブが開固定(FIXED_POOL_OPEN=1)の時は常に'1'を出
                          --!   力する.
                          out std_logic
    );
end FLOAT_OUTLET_MANIFOLD_VALVE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.FLOAT_OUTLET_VALVE;
architecture RTL of FLOAT_OUTLET_MANIFOLD_VALVE is
    signal    outlet_ready  : std_logic;
    signal    outlet_pause  : std_logic;
    signal    outlet_stop   : std_logic;
    signal    outlet_last   : std_logic;
    signal    outlet_size   : std_logic_vector(SIZE_BITS -1 downto 0);
    signal    outlet_count  : std_logic_vector(COUNT_BITS-1 downto 0);
    signal    outlet_zero   : std_logic;
    signal    outlet_pos    : std_logic;
    signal    outlet_neg    : std_logic;
    signal    outlet_paused : std_logic;
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
    GEN_USE_PUSH_RSV    : if (FIXED_CLOSE      = 0) and
                             (FIXED_FLOW_OPEN  = 0) and
                             (USE_PUSH_RSV    /= 0) generate
        VALVE: FLOAT_OUTLET_VALVE                    -- 
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
                FLOW_READY_LEVEL=> FLOW_READY_LEVEL, -- In :
            -----------------------------------------------------------------------
            -- Flow Counter Load Signals.
            -----------------------------------------------------------------------
                LOAD            => NULL_LOAD       , -- In :
                LOAD_COUNT      => NULL_COUNT      , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => PUSH_RSV_VALID  , -- In :
                PUSH_LAST       => PUSH_RSV_LAST   , -- In :
                PUSH_SIZE       => PUSH_RSV_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => FLOW_PULL_VALID , -- In :
                PULL_LAST       => FLOW_PULL_LAST  , -- In :
                PULL_SIZE       => FLOW_PULL_SIZE  , -- In :
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
    GEN_NO_USE_PUSH_RSV : if (FIXED_CLOSE      = 0) and
                             (FIXED_FLOW_OPEN  = 0) and
                             (USE_PUSH_RSV     = 0) generate
        FLOW_READY <= outlet_ready;
        FLOW_PAUSE <= outlet_pause;
        FLOW_STOP  <= outlet_stop;
        FLOW_LAST  <= outlet_last;
        FLOW_SIZE  <= outlet_size;
        FLOW_COUNT <= outlet_count;
        FLOW_ZERO  <= outlet_zero;
        FLOW_POS   <= outlet_pos;
        FLOW_NEG   <= outlet_neg;
        PAUSED     <= outlet_paused;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_NON_FIXED_CLOSE : if (FIXED_CLOSE = 0) generate
        VALVE: FLOAT_OUTLET_VALVE                    -- 
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
                FLOW_READY_LEVEL=> FLOW_READY_LEVEL, -- In :
            -----------------------------------------------------------------------
            -- Flow Counter Load Signals.
            -----------------------------------------------------------------------
                LOAD            => NULL_LOAD       , -- In :
                LOAD_COUNT      => NULL_COUNT      , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => PUSH_FIN_VALID  , -- In :
                PUSH_LAST       => PUSH_FIN_LAST   , -- In :
                PUSH_SIZE       => PUSH_FIN_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => FLOW_PULL_VALID , -- In :
                PULL_LAST       => FLOW_PULL_LAST  , -- In :
                PULL_SIZE       => FLOW_PULL_SIZE  , -- In :
            -----------------------------------------------------------------------
            -- Outlet Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_READY      => outlet_ready    , -- Out:
                FLOW_PAUSE      => outlet_pause    , -- Out:
                FLOW_STOP       => outlet_stop     , -- Out:
                FLOW_LAST       => outlet_last     , -- Out:
                FLOW_SIZE       => outlet_size     , -- Out:
            -----------------------------------------------------------------------
            -- Flow Counter.
            -----------------------------------------------------------------------
                FLOW_COUNT      => outlet_count    , -- Out:
                FLOW_ZERO       => outlet_zero     , -- Out:
                FLOW_POS        => outlet_pos      , -- Out:
                FLOW_NEG        => outlet_neg      , -- Out:
                PAUSED          => outlet_paused     -- Out:
            );
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    GEN_USE_POOL_PULL   : if (FIXED_CLOSE      = 0) and
                             (FIXED_POOL_OPEN  = 0) and
                             (USE_POOL_PULL   /= 0) generate
        VALVE: FLOAT_OUTLET_VALVE                    -- 
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
                FLOW_READY_LEVEL=> POOL_READY_LEVEL, -- In :
            -----------------------------------------------------------------------
            -- Flow Counter Load Signals.
            -----------------------------------------------------------------------
                LOAD            => POOL_PULL_RESET , -- In :
                LOAD_COUNT      => outlet_count    , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => PUSH_FIN_VALID  , -- In :
                PUSH_LAST       => PUSH_FIN_LAST   , -- In :
                PUSH_SIZE       => PUSH_FIN_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => POOL_PULL_VALID , -- In :
                PULL_LAST       => POOL_PULL_LAST  , -- In :
                PULL_SIZE       => POOL_PULL_SIZE  , -- In :
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
                             (USE_POOL_PULL    = 0) generate
        POOL_READY <= outlet_ready;
        POOL_COUNT <= outlet_count;
    end generate;
end RTL;
