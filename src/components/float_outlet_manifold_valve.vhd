-----------------------------------------------------------------------------------
--!     @file    float_outlet_manifold_valve.vhd
--!     @brief   FLOAT OUTLET MANIFOLD VALVE
--!     @version 1.5.0
--!     @date    2013/3/31
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
--! @brief   FLOAT OUTLET MANIFOLD VALVE :
-----------------------------------------------------------------------------------
entity  FLOAT_OUTLET_MANIFOLD_VALVE is
    generic (
        PRECEDE         : --! @brief PRECEDE ENABLE :
                          --! 先行(Precede)モードでフローを制御するかどうかを指定する.
                          --! * PRECEDE=0 : 非先行モード. フローカウンタの加算に
                          --!   PUSH_FIN_SIZE(入力が確定(FINAL)したバイト数)を使う.
                          --! * PRECEDE=1 : 先行モードでは、フローカウンタの加算に 
                          --!   PUSH_RSV_SIZE(入力する予定(RESERVE)のバイト数)を使う.
                          integer range 0 to 1 := 0;
        FIXED           : --! @brief FIXED VALVE OPEN/CLOSE :
                          --! フローカウンタによるフロー制御を行わず、常にバルブが
                          --! 閉じた状態または開いた状態にするか否かを指定する.
                          --! * FIXED=0 : フローカウンタによるフロー制御を行う.
                          --! * FIXED=1 : 常にバルブが閉じた状態にする.
                          --! * FIXED=2 : 常にバルブが開いた状態にする.
                          integer range 0 to 2 := 0;
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
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以上の時に転送を開始する.
                          --! フローカウンタの値がこの値未満の時に転送を一時停止.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        POOL_READY_LEVEL: --! @brief POOL READY LEVEL :
                          --! 先行モード(PRECEDE=1)の時、PULL_FIN_SIZEによるフロー
                          --! カウンタの加算結果が、この値以上の時にPOOL_READY 信号
                          --! をアサートする.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Final Size Signals.
    -------------------------------------------------------------------------------
        PUSH_FIN_VALID  : --! @brief PUSH FINAL VALID :
                          --! PUSH_FIN_LAST/PUSH_FIN_SIZEが有効であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PUSH_FIN_LAST   : --! @brief PUSH FINAL LAST :
                          --! 最後のPUSH_FIN入力であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PUSH_FIN_SIZE   : --! @brief PUSH FINAL SIZE :
                          --! 入力が確定(FINAL)したバイト数.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Reserve Size Signals.
    -------------------------------------------------------------------------------
        PUSH_RSV_VALID  : --! @brief PUSH RESERVE VALID :
                          --! PUSH_RSV_LAST/PUSH_RSV_SIZEが有効であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic;
        PUSH_RSV_LAST   : --! @brief PUSH RESERVE LAST :
                          --! 最後のPUSH_RSV入力であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic;
        PUSH_RSV_SIZE   : --! @brief PUSH RESERVE SIZE :
                          --! 入力する予定(RESERVE)のバイト数.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VALID      : --! @brief PULL VALID :
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
        FLOW_READY      : --! @brief FLOW OUTLET READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY=1 : 再開.
                          --! * FLOW_PAUSE=0 : 一時停止.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW OUTLET PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE=0 : 再開.
                          --! * FLOW_PAUSE=1 : 一時停止.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW OUTLET STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_PAUSE=1 : 中止.
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
        FLOW_ZERO       : --! @brief FLOW COUNTER is ZERO :
                          --! 現在のフローカウンタの値が0になった事示すフラグ.
                          out std_logic;
        FLOW_POS        : --! @brief FLOW COUNTER is POSitive :
                          --! 現在のフローカウンタの値が正(>0)になった事示すフラグ.
                          out std_logic;
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! 現在のフローカウンタの値が負になった事示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic;
        POOL_COUNT      : --! @brief POOL COUNT :
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        POOL_READY      : --! @brief POOL READY :
                          --! 現在のプールカウンタがREADY_ON_SIZE以上であることを示
                          --! すフラグ.
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
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    FIXED_OPEN: if (FIXED >= 2) generate
        PAUSED     <= '0';
        FLOW_READY <= '1';
        FLOW_PAUSE <= '0';
        FLOW_STOP  <= '0';
        FLOW_LAST  <= '0';
        FLOW_ZERO  <= '0';
        FLOW_POS   <= '1';
        FLOW_NEG   <= '0';
        FLOW_SIZE  <= (others => '1');
        FLOW_COUNT <= (others => '0');
        POOL_COUNT <= (others => '0');
        POOL_READY <= '1';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    FIXED_CLOSE: if (FIXED = 1) generate
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
    NON_PRECEDING: if (FIXED = 0 and PRECEDE = 0) generate
        signal    count         : std_logic_vector(COUNT_BITS-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        FLOW_VALVE: FLOAT_OUTLET_VALVE               -- 
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
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => PUSH_FIN_VALID  , -- In :
                PUSH_LAST       => PUSH_FIN_LAST   , -- In :
                PUSH_SIZE       => PUSH_FIN_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => PULL_VALID      , -- In :
                PULL_LAST       => PULL_LAST       , -- In :
                PULL_SIZE       => PULL_SIZE       , -- In :
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
                FLOW_COUNT      => count           , -- Out:
                FLOW_ZERO       => FLOW_ZERO       , -- Out:
                FLOW_POS        => FLOW_POS        , -- Out:
                FLOW_NEG        => FLOW_NEG        , -- Out:
                PAUSED          => PAUSED            -- Out:
            );
        FLOW_COUNT <= count;
        POOL_COUNT <= count;
        POOL_READY <= '1';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PRECEDING: if (FIXED = 0 and PRECEDE /= 0) generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        FLOW_VALVE: FLOAT_OUTLET_VALVE               -- 
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
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => PUSH_RSV_VALID  , -- In :
                PUSH_LAST       => PUSH_RSV_LAST   , -- In :
                PUSH_SIZE       => PUSH_RSV_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => PULL_VALID      , -- In :
                PULL_LAST       => PULL_LAST       , -- In :
                PULL_SIZE       => PULL_SIZE       , -- In :
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
            );                                       --
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        POOL_VALVE: FLOAT_OUTLET_VALVE               -- 
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
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VALID      => PUSH_FIN_VALID  , -- In :
                PUSH_LAST       => PUSH_FIN_LAST   , -- In :
                PUSH_SIZE       => PUSH_FIN_SIZE   , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VALID      => PULL_VALID      , -- In :
                PULL_LAST       => PULL_LAST       , -- In :
                PULL_SIZE       => PULL_SIZE       , -- In :
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
                FLOW_NEG        => open            , -- Out:
                PAUSED          => open              -- Out:
            );
    end generate;
end RTL;
