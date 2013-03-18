-----------------------------------------------------------------------------------
--!     @file    float_intake_manifold_valve.vhd
--!     @brief   FLOAT INTAKE MANIFOLD VALVE
--!     @version 1.4.0
--!     @date    2013/3/18
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
--! @brief   FLOAT INTAKE MANIFOLD VALVE :
-----------------------------------------------------------------------------------
entity  FLOAT_INTAKE_MANIFOLD_VALVE is
    generic (
        PRECEDE         : --! @brief PRECEDE ENABLE :
                          --! ���(Precede)�⡼�ɤǥե������椹�뤫�ɤ�������ꤹ��.
                          --! * PRECEDE=0 : ����ԥ⡼��. �ե������󥿤θ�����
                          --!   PULL_FIN_SIZE(���Ϥ�����(FINAL)�����Х��ȿ�)��Ȥ�.
                          --! * PRECEDE=1 : ��ԥ⡼�ɤǤϡ��ե������󥿤θ����� 
                          --!   PULL_RSV_SIZE(���Ϥ���ͽ��(RESERVE)�ΥХ��ȿ�)��Ȥ�.
                          integer range 0 to 1 := 0;
        FIXED           : --! @brief FIXED VALVE OPEN/CLOSE :
                          --! �ե������󥿤ˤ��ե������Ԥ鷺����˥Х�֤�
                          --! �Ĥ������֤ޤ��ϳ��������֤ˤ��뤫�ݤ�����ꤹ��.
                          --! * FIXED=0 : �ե������󥿤ˤ��ե������Ԥ�.
                          --! * FIXED=1 : ��˥Х�֤��Ĥ������֤ˤ���.
                          --! * FIXED=2 : ��˥Х�֤����������֤ˤ���.
                          integer range 0 to 2 := 0;
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! ���������󥿤Υӥåȿ�����ꤹ��.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! ����������Υӥåȿ�����ꤹ��.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief CLOCK :
                          --! ����å�����
                          in  std_logic; 
        RST             : --! @brief ASYNCRONOUSE RESET :
                          --! ��Ʊ���ꥻ�åȿ���.�����ƥ��֥ϥ�.
                          in  std_logic;
        CLR             : --! @brief SYNCRONOUSE RESET :
                          --! Ʊ���ꥻ�åȿ���.�����ƥ��֥ϥ�.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Control Signals.
    -------------------------------------------------------------------------------
        RESET           : --! @brief RESET REQUEST :
                          --! ����Ū���������֤�ꥻ�åȤ������ؼ����뿮��.
                          in  std_logic;
        PAUSE           : --! @brief PAUSE REQUEST :
                          --! ����Ū�˥ե�����Ū����ߤ������ؼ����뿮��.
                          in  std_logic;
        STOP            : --! @brief STOP  REQUEST :
                          --! ����Ū�˥ե�����ߤ������ؼ����뿮��.
                          in  std_logic;
        INTAKE_OPEN     : --! @brief INTAKE VALVE OPEN FLAG :
                          --! ����(INTAKE)¦�ΥХ�֤������Ƥ�����򼨤��ե饰.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! ����(OUTLET)¦�ΥХ�֤������Ƥ�����򼨤��ե饰.
                          in  std_logic;
        POOL_SIZE       : --! @brief POOL SIZE :
                          --! �ס�����礭����Х��ȿ��ǻ��ꤹ��.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! �����ߤ���/���ʤ���ؼ����뤿�������.
                          --! �ե������󥿤��ͤ������Ͱʲ��λ������Ϥ򳫻Ϥ���.
                          --! �ե������󥿤��ͤ������ͤ�ۤ����������Ϥ������.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        POOL_READY_LEVLE: --! @brief POOL READY LEVEL :
                          --! ��ԥ⡼��(PRECEDE=1)�λ���PULL_FIN_SIZE�ˤ��ե�
                          --! �����󥿤θ�����̤��������Ͱʲ��λ���POOL_READY ����
                          --! �򥢥����Ȥ���.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VAL        : --! @brief PUSH VALID :
                          --! PUSH_LAST/PUSH_SIZE��ͭ���Ǥ��뤳�Ȥ򼨤�����.
                          in  std_logic;
        PUSH_LAST       : --! @brief PUSH LAST :
                          --! �Ǹ��PUSH���ϤǤ��뤳�Ȥ򼨤�����.
                          in  std_logic;
        PUSH_SIZE       : --! @brief PUSH SIZE :
                          --! ���Ϥ����Х��ȿ�.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Final Size Signals.
    -------------------------------------------------------------------------------
        PULL_FIN_VAL    : --! @brief PULL FINAL VALID :
                          --! PULL_FIN_LAST/PULL_FIN_SIZE��ͭ���Ǥ��뤳�Ȥ򼨤�����.
                          in  std_logic;
        PULL_FIN_LAST   : --! @brief PULL FINAL LAST :
                          --! �Ǹ��PULL_FIN���ϤǤ��뤳�Ȥ򼨤�����.
                          in  std_logic;
        PULL_FIN_SIZE   : --! @brief PUSH RESERVE SIZE :
                          --! ���Ϥ�����(FINAL)�����Х��ȿ�.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Reserve Size Signals.
    -------------------------------------------------------------------------------
        PULL_RSV_VAL    : --! @brief PULL RESERVE VALID :
                          --! PULL_RSV_LAST/PULL_RSV_SIZE��ͭ���Ǥ��뤳�Ȥ򼨤�����.
                          in  std_logic;
        PULL_RSV_LAST   : --! @brief PULL RESERVE LAST :
                          --! �Ǹ��PULL_RSV���ϤǤ��뤳�Ȥ򼨤�����.
                          in  std_logic;
        PULL_RSV_SIZE   : --! @brief PULL RESERVE SIZE :
                          --! ���Ϥ���ͽ��(RESERVE)�ΥХ��ȿ�.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW INTAKE READY :
                          --! ž������Ū�˻ߤ᤿�ꡢ�Ƴ����뤳�Ȥ�ؼ����뿮��.
                          --! * FLOW_READY=1 : �Ƴ�.
                          --! * FLOW_PAUSE=0 : ������.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW INTAKE PAUSE :
                          --! ž������Ū�˻ߤ᤿�ꡢ�Ƴ����뤳�Ȥ�ؼ����뿮��.
                          --! * FLOW_PAUSE=0 : �Ƴ�.
                          --! * FLOW_PAUSE=1 : ������.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW INTAKE STOP :
                          --! ž������ߤ�ؼ����뿮��.
                          --! * FLOW_PAUSE=1 : ���.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW INTAKE LAST :
                          --! ����¦����Ǹ�����Ϥ򼨤��ե饰�����ä����Ȥ򼨤�.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW INTAKE ENABLE SIZE :
                          --! ���ϲ�ǽ�ʥХ��ȿ�
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! ���ߤΥե������󥿤��ͤ����.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! ���ߤΥե������󥿤��ͤ���ˤʤä��������ե饰.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! ���߰�������Ǥ��뤳�Ȥ򼨤��ե饰.
                          out std_logic;
        POOL_COUNT      : --! @brief POOL COUNT :
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        POOL_READY      : --! @brief POOL READY :
                          --! ���ߤΥס��륫���󥿤�READY_ON_SIZE�ʾ�Ǥ��뤳�Ȥ�
                          --! ���ե饰.
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
        FLOW_VALVE: FLOAT_INTAKE_VALVE               -- 
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
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VAL        => PUSH_VAL        , -- In :
                PUSH_LAST       => PUSH_LAST       , -- In :
                PUSH_SIZE       => PUSH_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VAL        => PULL_FIN_VAL    , -- In :
                PULL_LAST       => PULL_FIN_LAST   , -- In :
                PULL_SIZE       => PULL_FIN_SIZE   , -- In :
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
        FLOW_VALVE: FLOAT_INTAKE_VALVE               -- 
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
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VAL        => PUSH_VAL        , -- In :
                PUSH_LAST       => PUSH_LAST       , -- In :
                PUSH_SIZE       => PUSH_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VAL        => PULL_RSV_VAL    , -- In :
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
                FLOW_NEG        => FLOW_NEG        , -- Out:
                PAUSED          => PAUSED            -- Out:
            );                                       --
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        POOL_VALVE: FLOAT_INTAKE_VALVE               -- 
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
            -- Push Size Signals.
            -----------------------------------------------------------------------
                PUSH_VAL        => PUSH_VAL        , -- In :
                PUSH_LAST       => PUSH_LAST       , -- In :
                PUSH_SIZE       => PUSH_SIZE       , -- In :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
                PULL_VAL        => PULL_FIX_VAL    , -- In :
                PULL_LAST       => PULL_FIX_LAST   , -- In :
                PULL_SIZE       => PULL_FIX_SIZE   , -- In :
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
