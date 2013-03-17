-----------------------------------------------------------------------------------
--!     @file    relay_outlet_valve.vhd
--!     @brief   RELAY OUTLET VALVE
--!     @version 0.0.1
--!     @date    2013/3/16
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
--! @brief   RELAY OUTLET VALVE :
-----------------------------------------------------------------------------------
entity  RELAY_OUTLET_VALVE is
    generic (
        VALVE_MODE      : --! @brief VALVE MODE :
                          --! 動作モードを指定する.
                          --! * VALVE_MODE=0 : バルブが常にオープンの状態になる.
                          --! * VALVE_MODE=1 : バルブが常にクローズの状態になる.
                          --! * VALVE_MODE=2 : フローカウンタの加算にPUSH_SIZEを使う.
                          --! * VALVE_MODE=3 : フローカウンタの加算にRESV_SIZEを使う.
                          integer range 0 to 3 := 2;
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
                          --! 入力(INTAKE)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! 出力(OUTLET)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        THRESHOLD_SIZE  : --! @brief THRESHOLD SIZE :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以上の時に転送を開始する.
                          --! フローカウンタの値がこの値未満の時に転送を一時停止.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        READY_ON_SIZE   : --! @brief READY ON SIZE :
                          --! VALVE_MODE=3の時、PULL_SIZEによるフローカウンタの加算
                          --! 結果が、この値以上の時に READY 信号をアサートする.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VAL        : --! @brief PUSH VALID :
                          --! PUSH_LAST/PUSH_SIZEが有効であることを示す信号.
                          in  std_logic;
        PUSH_LAST       : --! @brief PUSH LAST :
                          --! 最後の入力であることを示す信号.
                          in  std_logic;
        PUSH_SIZE       : --! @brief PUSH SIZE :
                          --! 入力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Resv Size Signals.
    -------------------------------------------------------------------------------
        RESV_VAL        : --! @brief RESV VALID :
                          --! RESV_LAST/RESV_SIZEが有効であることを示す信号.
                          in  std_logic;
        RESV_LAST       : --! @brief RESV LAST :
                          --! 最後の入力であることを示す信号.
                          in  std_logic;
        RESV_SIZE       : --! @brief RESV SIZE :
                          --! 入力する予定のバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VAL        : --! @brief PULL VALID :
                          --! PULL_LAST/PULL_SIZEが有効であることを示す信号.
                          in  std_logic;
        PULL_LAST       : --! @brief PULL LAST :
                          --! 最後の出力であることを示す信号.
                          in  std_logic;
        PULL_SIZE       : --! @brief PULL SIZE :
                          --! 出力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_PAUSE      : --! @brief FLOW OUTLET PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW OUTLET STOP :
                          --! 転送の中止を指示する信号.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW OUTLET LAST :
                          --! 入力側から最後の入力を示すフラグがあったことを示す.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW OUTLET ENABLE SIZE :
                          --! 出力可能なバイト数
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! 現在のフローカウンタの値を出力.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! 現在のフローカウンタの値が負になった事示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic;
        READY           : --! @brief VALVE READY :
                          --! 現在バルブが開いていることを示すフラグ.
                          out std_logic
    );
end RELAY_OUTLET_VALVE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.POOL_OUTLET_VALVE;
architecture RTL of RELAY_OUTLET_VALVE is
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    VALVE_MODE_0: if (VALVE_MODE /= 1 and VALVE_MODE /= 2 and VALVE_MODE /= 3) generate
        FLOW_PAUSE <= '0';
        FLOW_STOP  <= '0';
        FLOW_LAST  <= '0';
        FLOW_SIZE  <= (others => '1');
        READY      <= '1';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    VALVE_MODE_1: if (VALVE_MODE = 1) generate
        FLOW_PAUSE <= '0';
        FLOW_STOP  <= '1';
        FLOW_LAST  <= '1';
        FLOW_SIZE  <= (others => '0');
        READY      <= '0';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    VALVE_MODE_2: if (VALVE_MODE = 1) generate
        VALVE: POOL_OUTLET_VALVE
            generic map (
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
                THRESHOLD_SIZE  => THRESHOLD_SIZE  , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VAL        => PUSH_VAL        , -- In :
                PUSH_LAST       => PUSH_LAST       , -- In :
                PUSH_SIZE       => PUSH_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VAL        => PULL_VAL        , -- In :
                PULL_LAST       => PULL_LAST       , -- In :
                PULL_SIZE       => PULL_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Outlet Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_PAUSE      => FLOW_PAUSE      , -- Out:
                FLOW_STOP       => FLOW_STOP       , -- Out:
                FLOW_LAST       => FLOW_LAST       , -- Out:
                FLOW_SIZE       => FLOW_SIZE       , -- Out:
            -----------------------------------------------------------------------
            -- Flow Counter.
            -----------------------------------------------------------------------
                FLOW_COUNT      => open            , -- Out:
                FLOW_NEG        => open            , -- Out:
                PAUSED          => open              -- Out:
            );
        READY <= '1';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    VALVE_MODE_3: if (VALVE_MODE = 3) generate
        signal    paused     : std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        VALVE_0: POOL_OUTLET_VALVE                   -- 
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
                THRESHOLD_SIZE  => THRESHOLD_SIZE  , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VAL        => RESV_VAL        , -- In :
                PUSH_LAST       => RESV_LAST       , -- In :
                PUSH_SIZE       => RESV_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VAL        => PULL_VAL        , -- In :
                PULL_LAST       => PULL_LAST       , -- In :
                PULL_SIZE       => PULL_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Outlet Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_PAUSE      => FLOW_PAUSE      , -- Out:
                FLOW_STOP       => FLOW_STOP       , -- Out:
                FLOW_LAST       => FLOW_LAST       , -- Out:
                FLOW_SIZE       => FLOW_SIZE       , -- Out:
            -----------------------------------------------------------------------
            -- Flow Counter.
            -----------------------------------------------------------------------
                FLOW_COUNT      => open            , -- Out:
                FLOW_NEG        => open            , -- Out:
                PAUSED          => open              -- Out:
            );                                       --
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        VALVE_1: POOL_OUTLET_VALVE                   -- 
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
                THRESHOLD_SIZE  => READY_ON_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VAL        => PUSH_VAL        , -- In :
                PUSH_LAST       => PUSH_LAST       , -- In :
                PUSH_SIZE       => PUSH_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VAL        => PULL_VAL        , -- In :
                PULL_LAST       => PULL_LAST       , -- In :
                PULL_SIZE       => PULL_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Outlet Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_PAUSE      => flow_pause      , -- Out:
                FLOW_STOP       => open            , -- Out:
                FLOW_LAST       => open            , -- Out:
                FLOW_SIZE       => open            , -- Out:
            -----------------------------------------------------------------------
            -- Flow Counter.
            -----------------------------------------------------------------------
                FLOW_COUNT      => open            , -- Out:
                FLOW_NEG        => open            , -- Out:
                PAUSED          => paused            -- Out:
            );
        READY <= '1' when (paused = '0') else '0';
    end generate;
end RTL;
