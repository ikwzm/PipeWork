-----------------------------------------------------------------------------------
--!     @file    pipe_flow_syncronizer.vhd
--!     @brief   PIPE FLOW SYNCRONIZER
--!              Pipe �� Requester ¦���� Responder ¦�ء��ޤ���Responder ¦����
--!              Requester¦ �ء��Ƽ�������ã����⥸�塼��.
--!     @version 0.0.1
--!     @date    2013/3/25
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
--! @brief   PIPE FLOW SYNCRONIZER
-----------------------------------------------------------------------------------
entity  PIPE_FLOW_SYNCRONIZER is
    generic (
        I_CLK_RATE      : --! @brief INPUT CLOCK RATE :
                          --! O_CLK_RATE�ȥڥ�������¦�Υ���å�(I_CLK)�Ƚ���¦��
                          --! ����å�(O_CLK)�Ȥδط�����ꤹ��.
                          --! �ܺ٤� PipeWork.Components �� SYNCRONIZER �򻲾�.
                          integer :=  1;
        O_CLK_RATE      : --! @brief OUTPUT CLOCK RATE :
                          --! I_CLK_RATE�ȥڥ�������¦�Υ���å�(I_CLK)�Ƚ���¦��
                          --! ����å�(O_CLK)�Ȥδط�����ꤹ��.
                          --! �ܺ٤� PipeWork.Components �� SYNCRONIZER �򻲾�.
                          integer :=  1;
        DELAY_CYCLE     : --! @brief DELAY CYCLE :   
                          --! ����¦�������¦�ؤ�ž������ݤ��ٱ䥵���������ꤹ��.
                          integer :=  0;
        OPEN_INFO_BITS  : --! @brief OPEN INFOMATION BITS :
                          --! I_OPEN_INFO/O_OPEN_INFO�Υӥåȿ�����ꤹ��.
                          integer :=  1;
        CLOSE_INFO_BITS : --! @brief CLOSE INFOMATION BITS :
                          --! I_CLOSE_INFO/O_CLOSE_INFO�Υӥåȿ�����ꤹ��.
                          integer :=  1;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! �Ƽ掠��������Υӥåȿ�����ꤹ��.
                          integer :=  8;
        PUSH_FIN_VALID  : --! @brief PUSH FINAL SIZE VALID :
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST �����ͭ����
                          --! ���뤫�ݤ�����ꤹ��.
                          --! * PUSH_FIN_VALID = 1 : ͭ��. 
                          --! * PUSH_FIN_VALID = 0 : ̵��. ��ϩ�Ͼ�ά�����.
                          integer :=  1;
        PUSH_FIN_DELAY  : --! @brief PUSH FINAL SIZE DELAY CYCLE :
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST ���ٱ䤹�륵
                          --! �����������ꤹ��.
                          integer :=  0;
        PUSH_RSV_VALID  : --! @brief PUSH RESERVE SIZE VALID :
                          --! PUSH_RSV_VAL/PUSH_RSV_SIZE/PUSH_RSV_LAST �����ͭ����
                          --! ���뤫�ݤ�����ꤹ��.
                          --! * PUSH_RSV_VALID = 1 : ͭ��. 
                          --! * PUSH_RSV_VALID = 0 : ̵��. ��ϩ�Ͼ�ά�����.
                          integer :=  1;
        PULL_FIN_VALID  : --! @brief PULL FINAL SIZE VALID :
                          --! PULL_FIN_VAL/PULL_FIN_SIZE/PULL_FIN_LAST �����ͭ����
                          --! ���뤫�ݤ�����ꤹ��.
                          --! * PULL_FIN_VALID = 1 : ͭ��. 
                          --! * PULL_FIN_VALID = 0 : ̵��. ��ϩ�Ͼ�ά�����.
                          integer :=  1;
        PULL_RSV_VALID  : --! @brief PULL RESERVE SIZE VALID :
                          --! PULL_RSV_VAL/PULL_RSV_SIZE/PULL_RSV_LAST �����ͭ����
                          --! ���뤫�ݤ�����ꤹ��.
                          --! * PULL_RSV_VALID = 1 : ͭ��. 
                          --! * PULL_RSV_VALID = 0 : ̵��. ��ϩ�Ͼ�ά�����.
                          integer :=  1
    );
    port (
    -------------------------------------------------------------------------------
    -- Asyncronous Reset Signal.
    -------------------------------------------------------------------------------
        RST             : --! @brief RESET :
                          --! ��Ʊ���ꥻ�åȿ���(�ϥ��������ƥ���).
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Clock and Clock Enable and Syncronous reset.
    -------------------------------------------------------------------------------
        I_CLK           : --! @brief INPUT CLOCK :
                          --! ����¦�Υ���å�����.
                          in  std_logic;
        I_CLR           : --! @brief INPUT CLEAR :
                          --! ����¦��Ʊ���ꥻ�åȿ���(�ϥ��������ƥ���).
                          in  std_logic;
        I_CKE           : --! @brief INPUT CLOCK ENABLE :
                          --! ����¦�Υ���å�(I_CLK)��Ω��꤬ͭ���Ǥ��뤳�Ȥ򼨤�����.
                          --! * ���ο���� I_CLK_RATE > 1 �λ��ˡ�I_CLK �� O_CLK ��
                          --!   ����ط��򼨤����˻��Ѥ���.
                          --! * I_CLK��Ω������OCLK��Ω������Ʊ�����˥������Ȥ�
                          --!   ��褦�����Ϥ���ʤ���Фʤ�ʤ�.
                          --! * ���ο���� I_CLK_RATE > 1 ���� O_CLK_RATE = 1�λ���
                          --!   ��ͭ��. ����ʳ���̤����.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Intake Open Signals.
    -------------------------------------------------------------------------------
        I_OPEN_VAL      : in  std_logic;
        I_OPEN_INFO     : in  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Close Signals.
    -------------------------------------------------------------------------------
        I_CLOSE_VAL     : in  std_logic;
        I_CLOSE_INFO    : in  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Push Final Size Signals.
    -------------------------------------------------------------------------------
        I_PUSH_FIN_VAL  : in  std_logic := '0';
        I_PUSH_FIN_LAST : in  std_logic := '0';
        I_PUSH_FIN_SIZE : in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Intake Push Reserve Size Signals.
    -------------------------------------------------------------------------------
        I_PUSH_RSV_VAL  : in  std_logic := '0';
        I_PUSH_RSV_LAST : in  std_logic := '0';
        I_PUSH_RSV_SIZE : in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Intake Pull Final Size Signals.
    -------------------------------------------------------------------------------
        I_PULL_FIN_VAL  : in  std_logic := '0';
        I_PULL_FIN_LAST : in  std_logic := '0';
        I_PULL_FIN_SIZE : in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Intake Pull Reserve Size Signals.
    -------------------------------------------------------------------------------
        I_PULL_RSV_VAL  : in  std_logic := '0';
        I_PULL_RSV_LAST : in  std_logic := '0';
        I_PULL_RSV_SIZE : in  std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Outlet Clock and Clock Enable and Syncronous reset.
    -------------------------------------------------------------------------------
        O_CLK           : --! @brief OUTPUT CLOCK :
                          --! ����¦�Υ���å�����.
                          in  std_logic;
        O_CLR           : --! @brief OUTPUT CLEAR :
                          --! ����¦��Ʊ���ꥻ�åȿ���(�ϥ��������ƥ���).
                          in  std_logic;
        O_CKE           : --! @brief OUTPUT CLOCK ENABLE :
                          --! ����¦�Υ���å�(O_CLK)��Ω��꤬ͭ���Ǥ��뤳�Ȥ򼨤�����.
                          --! * ���ο���� I_CLK_RATE > 1 �λ��ˡ�I_CLK �� O_CLK ��
                          --!   ����ط��򼨤����˻��Ѥ���.
                          --! * I_CLK��Ω������O_CLK��Ω������Ʊ�����˥������Ȥ�
                          --!   ��褦�����Ϥ���ʤ���Фʤ�ʤ�.
                          --! * ���ο���� O_CLK_RATE > 1 ���� I_CLK_RATE = 1�λ��Τ�
                          --!   ͭ��. ����ʳ���̤����.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Open Signals.
    -------------------------------------------------------------------------------
        O_OPEN_VAL      : out std_logic;
        O_OPEN_INFO     : out std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Close Signals.
    -------------------------------------------------------------------------------
        O_CLOSE_VAL     : out std_logic;
        O_CLOSE_INFO    : out std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Push Final Size Signals.
    -------------------------------------------------------------------------------
        O_PUSH_FIN_VAL  : out std_logic;
        O_PUSH_FIN_LAST : out std_logic;
        O_PUSH_FIN_SIZE : out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Push Reserve Size Signals.
    -------------------------------------------------------------------------------
        O_PUSH_RSV_VAL  : out std_logic;
        O_PUSH_RSV_LAST : out std_logic;
        O_PUSH_RSV_SIZE : out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Pull Final Size Signals.
    -------------------------------------------------------------------------------
        O_PULL_FIN_VAL  : out std_logic;
        O_PULL_FIN_LAST : out std_logic;
        O_PULL_FIN_SIZE : out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Pull Reserve Size Signals.
    -------------------------------------------------------------------------------
        O_PULL_RSV_VAL  : out std_logic;
        O_PULL_RSV_LAST : out std_logic;
        O_PULL_RSV_SIZE : out std_logic_vector(SIZE_BITS-1 downto 0)
    );
end PIPE_FLOW_SYNCRONIZER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.SYNCRONIZER;
use     PIPEWORK.COMPONENTS.SYNCRONIZER_INPUT_PENDING_REGISTER;
use     PIPEWORK.COMPONENTS.DELAY_REGISTER;
use     PIPEWORK.COMPONENTS.DELAY_ADJUSTER;
architecture  RTL of PIPE_FLOW_SYNCRONIZER is
    -------------------------------------------------------------------------------
    -- ���Υ⥸�塼��ǻ��Ѥ���i_valid/o_valid/i_data/o_data�ΥӥåȤγ�����Ƥ�
    -- �ݻ���������Υ����פ����.
    -------------------------------------------------------------------------------
    type      INFO_RANGE_TYPE is record
              VAL_POS           : integer;          -- i_valid/o_valid �� ????_VAL �ΥӥåȰ���
              DATA_LO           : integer;          -- i_data/o_data   �� ????_INFO �κǲ��̥ӥåȰ���
              DATA_HI           : integer;          -- i_data/o_data   �� ????_INFO �κǾ�̥ӥåȰ���
    end record;
    type      SIZE_RANGE_TYPE is record
              VAL_POS           : integer;          -- i_valid/o_valid �� ????_???_VAL �ΥӥåȰ���
              DATA_LO           : integer;          -- i_data/o_data   �� ????_???_SIZE&LAST �κǲ��̥ӥåȰ���
              DATA_HI           : integer;          -- i_data/o_data   �� ????_???_SIZE&LAST �κǾ�̥ӥåȰ���
              SIZE_LO           : integer;          -- i_data/o_data   �� ????_???_SIZE �κǲ��̥ӥåȰ���
              SIZE_HI           : integer;          -- i_data/o_data   �� ????_???_SIZE �κǾ�̥ӥåȰ���
              LAST_POS          : integer;          -- i_data/o_data   �� ????_???_LAST �ΥӥåȰ���
    end record;
    type      VEC_RANGE_TYPE is record
              VAL_LO            : integer;          -- i_valid/o_valid �κǲ��̥ӥåȰ���
              VAL_HI            : integer;          -- i_valid/o_valid �κǾ�̥ӥåȰ���
              DATA_LO           : integer;          -- i_data/o_data �κǲ��̥ӥåȰ���
              DATA_HI           : integer;          -- i_data/o_data �κǾ�̥ӥåȰ���
              OPEN_INFO         : INFO_RANGE_TYPE;  -- OPEN_INFO�γƼ�ӥåȰ���
              CLOSE_INFO        : INFO_RANGE_TYPE;  -- OPEN_INFO�γƼ�ӥåȰ���
              PUSH_FIN          : SIZE_RANGE_TYPE;  -- PUSH_FIN_XXX�γƼ�ӥåȰ���
              PUSH_RSV          : SIZE_RANGE_TYPE;  -- PUSH_RSV_XXX�γƼ�ӥåȰ���
              PULL_FIN          : SIZE_RANGE_TYPE;  -- PULL_FIN_XXX�γƼ�ӥåȰ���
              PULL_RSV          : SIZE_RANGE_TYPE;  -- PULL_RSV_XXX�γƼ�ӥåȰ���
    end record;
    -------------------------------------------------------------------------------
    -- ���Υ⥸�塼��ǻ��Ѥ���i_valid/o_valid/i_data/o_data�ΥӥåȤγ�����Ƥ�
    -- ����ؿ������.
    -------------------------------------------------------------------------------
    function  SET_VEC_RANGE return VEC_RANGE_TYPE is
        variable  v_pos         : integer;
        variable  d_pos         : integer;
        variable  v             : VEC_RANGE_TYPE;
        ---------------------------------------------------------------------------
        -- OPEN_INFO/CLOSE_INFO �Υӥåȳ�����Ƥ����ץ�������.
        ---------------------------------------------------------------------------
        procedure SET_INFO_RANGE(INFO_RANGE: inout INFO_RANGE_TYPE; BITS: in integer) is
        begin
            INFO_RANGE.VAL_POS  := v_pos;
            INFO_RANGE.DATA_LO  := d_pos;
            INFO_RANGE.DATA_HI  := d_pos + BITS-1;
            v_pos := v_pos + 1;
            d_pos := d_pos + BITS;
        end procedure;
        ---------------------------------------------------------------------------
        -- PUSH_FIN_SIZE/PUSH_RSV_SIZE/PULL_FIN_SIZE/PULL_RSV_SIZE �Υӥåȳ������
        -- �����ץ�������.
        ---------------------------------------------------------------------------
        procedure SET_SIZE_RANGE(SIZE_RANGE: inout SIZE_RANGE_TYPE; BITS: in integer) is
        begin
            SIZE_RANGE.VAL_POS  := v_pos;
            SIZE_RANGE.SIZE_LO  := d_pos;
            SIZE_RANGE.SIZE_HI  := d_pos + BITS-1;
            SIZE_RANGE.LAST_POS := d_pos + BITS;
            SIZE_RANGE.DATA_LO  := d_pos;
            SIZE_RANGE.DATA_HI  := d_pos + BITS;
            v_pos := v_pos + 1;
            d_pos := d_pos + BITS + 1;
        end procedure;
    begin
        v_pos := 0;
        d_pos := 0;
        v.VAL_LO  := v_pos;
        v.DATA_LO := d_pos;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        SET_INFO_RANGE(v.OPEN_INFO , OPEN_INFO_BITS );
        SET_INFO_RANGE(v.CLOSE_INFO, CLOSE_INFO_BITS);
        if (PUSH_FIN_VALID /= 0) then
            SET_SIZE_RANGE(v.PUSH_FIN, SIZE_BITS);
        end if;
        if (PUSH_RSV_VALID /= 0) then
            SET_SIZE_RANGE(v.PUSH_RSV, SIZE_BITS);
        end if;
        if (PULL_FIN_VALID /= 0) then
            SET_SIZE_RANGE(v.PULL_FIN, SIZE_BITS);
        end if;
        if (PULL_RSV_VALID /= 0) then
            SET_SIZE_RANGE(v.PULL_RSV, SIZE_BITS);
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        v.VAL_HI  := v_pos - 1;
        v.DATA_HI := d_pos - 1;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (PUSH_FIN_VALID = 0) then
            SET_SIZE_RANGE(v.PUSH_FIN, SIZE_BITS);
        end if;
        if (PUSH_RSV_VALID = 0) then
            SET_SIZE_RANGE(v.PUSH_RSV, SIZE_BITS);
        end if;
        if (PULL_FIN_VALID = 0) then
            SET_SIZE_RANGE(v.PULL_FIN, SIZE_BITS);
        end if;
        if (PULL_RSV_VALID = 0) then
            SET_SIZE_RANGE(v.PULL_RSV, SIZE_BITS);
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        return v;
    end function;
    -------------------------------------------------------------------------------
    -- ���Υ⥸�塼��ǻ��Ѥ���i_valid/o_valid/i_data/o_data�ΥӥåȤγ�����Ƥ�
    -- �ݻ����Ƥ������.
    -------------------------------------------------------------------------------
    constant  VEC_RANGE      : VEC_RANGE_TYPE  := SET_VEC_RANGE;
    -------------------------------------------------------------------------------
    -- �������椿��.
    -------------------------------------------------------------------------------
    signal    i_valid        : std_logic_vector(VEC_RANGE.VAL_HI  downto VEC_RANGE.VAL_LO );
    signal    i_data         : std_logic_vector(VEC_RANGE.DATA_HI downto VEC_RANGE.DATA_LO);
    signal    o_valid        : std_logic_vector(VEC_RANGE.VAL_HI  downto VEC_RANGE.VAL_LO );
    signal    o_data         : std_logic_vector(VEC_RANGE.DATA_HI downto VEC_RANGE.DATA_LO);
    constant  i_pause        : std_logic := '0';
    signal    i_ready        : std_logic;
begin
    ------------------------------------------------------------------------------
    -- I_OPEN_VAL ����� SYNCRONIZER �� I_VAL  ������.
    -- I_OPEN_INFO����� SYNCRONIZER �� I_DATA ������.
    ------------------------------------------------------------------------------
    I_OPEN_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                 --
        generic map (                                               --
            DATA_BITS   => OPEN_INFO_BITS                         , -- 
            OPERATION   => 1                                        -- 
        )                                                           -- 
        port map (                                                  -- 
            CLK         => I_CLK                                  , -- In  :
            RST         => RST                                    , -- In  :
            CLR         => I_CLR                                  , -- In  :
            I_DATA      => I_OPEN_INFO                            , -- In  :
            I_VAL       => I_OPEN_VAL                             , -- In  :
            I_PAUSE     => i_pause                                , -- In  :
            P_DATA      => open                                   , -- Out :
            P_VAL       => open                                   , -- Out :
            O_DATA      => i_data (VEC_RANGE.OPEN_INFO.DATA_HI downto VEC_RANGE.OPEN_INFO.DATA_LO),
            O_VAL       => i_valid(VEC_RANGE.OPEN_INFO.VAL_POS)   , -- Out :
            O_RDY       => i_ready                                  -- In  :
        );                                                          -- 
    ------------------------------------------------------------------------------
    -- I_CLOSE_VAL ����� SYNCRONIZER �� I_VAL   ������.
    -- I_CLOSE_INFO����� SYNCRONIZER �� I_DATA  ������.
    ------------------------------------------------------------------------------
    I_CLOSE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                               --
            DATA_BITS   => CLOSE_INFO_BITS                        , -- 
            OPERATION   => 1                                        -- 
        )                                                           -- 
        port map (                                                  -- 
            CLK         => I_CLK                                  , -- In  :
            RST         => RST                                    , -- In  :
            CLR         => I_CLR                                  , -- In  :
            I_DATA      => I_CLOSE_INFO                           , -- In  :
            I_VAL       => I_CLOSE_VAL                            , -- In  :
            I_PAUSE     => i_pause                                , -- In  :
            P_DATA      => open                                   , -- Out :
            P_VAL       => open                                   , -- Out :
            O_DATA      => i_data (VEC_RANGE.CLOSE_INFO.DATA_HI downto VEC_RANGE.CLOSE_INFO.DATA_LO),
            O_VAL       => i_valid(VEC_RANGE.CLOSE_INFO.VAL_POS)  , -- Out :
            O_RDY       => i_ready                                  -- In  :
        );                                                          -- 
    ------------------------------------------------------------------------------
    -- I_PUSH_FIN_VAL ����� SYNCRONIZER �� I_VAL  ������.
    -- I_PUSH_FIN_LAST����� SYNCRONIZER �� I_DATA ������.
    -- I_PUSH_FIN_SIZE����� SYNCRONIZER �� I_DATA ������.
    ------------------------------------------------------------------------------
    I_PUSH_FIN_REGS: if (PUSH_FIN_VALID /= 0) generate              --
        SIZE: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => SIZE_BITS                          , -- 
                OPERATION   => 2                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => I_PUSH_FIN_SIZE                    , -- In  :
                I_VAL       => I_PUSH_FIN_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PUSH_FIN.SIZE_HI downto VEC_RANGE.PUSH_FIN.SIZE_LO),
                O_VAL       => i_valid(VEC_RANGE.PUSH_FIN.VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      --
        LAST: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA(0)   => I_PUSH_FIN_LAST                    , -- In  :
                I_VAL       => I_PUSH_FIN_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PUSH_FIN.LAST_POS downto VEC_RANGE.PUSH_FIN.LAST_POS),
                O_VAL       => open                               , -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    ------------------------------------------------------------------------------
    -- I_PUSH_RSV_VAL ����� SYNCRONIZER �� I_VAL  ������.
    -- I_PUSH_RSV_LAST����� SYNCRONIZER �� I_DATA ������.
    -- I_PUSH_RSV_SIZE����� SYNCRONIZER �� I_DATA ������.
    ------------------------------------------------------------------------------
    I_PUSH_RSV_REGS: if (PUSH_RSV_VALID /= 0) generate              -- 
        SIZE: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => SIZE_BITS                          , -- 
                OPERATION   => 2                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => I_PUSH_RSV_SIZE                    , -- In  :
                I_VAL       => I_PUSH_RSV_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PUSH_RSV.SIZE_HI downto VEC_RANGE.PUSH_RSV.SIZE_LO),
                O_VAL       => i_valid(VEC_RANGE.PUSH_RSV.VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      --
        LAST: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA(0)   => I_PUSH_RSV_LAST                    , -- In  :
                I_VAL       => I_PUSH_RSV_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PUSH_RSV.LAST_POS downto VEC_RANGE.PUSH_RSV.LAST_POS),
                O_VAL       => open                               , -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    ------------------------------------------------------------------------------
    -- I_PULL_FIN_VAL ����� SYNCRONIZER �� I_VAL  ������.
    -- I_PULL_FIN_LAST����� SYNCRONIZER �� I_DATA ������.
    -- I_PULL_FIN_SIZE����� SYNCRONIZER �� I_DATA ������.
    ------------------------------------------------------------------------------
    I_PULL_FIN_REGS: if (PULL_FIN_VALID /= 0) generate              -- 
        SIZE: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => SIZE_BITS                          , -- 
                OPERATION   => 2                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => I_PULL_FIN_SIZE                    , -- In  :
                I_VAL       => I_PULL_FIN_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PULL_FIN.SIZE_HI downto VEC_RANGE.PULL_FIN.SIZE_LO),
                O_VAL       => i_valid(VEC_RANGE.PULL_FIN.VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      --
        LAST: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA(0)   => I_PULL_FIN_LAST                    , -- In  :
                I_VAL       => I_PULL_FIN_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PULL_FIN.LAST_POS downto VEC_RANGE.PULL_FIN.LAST_POS),
                O_VAL       => open                               , -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    ------------------------------------------------------------------------------
    -- I_PULL_RSV_VAL ����� SYNCRONIZER �� I_VAL  ������.
    -- I_PULL_RSV_LAST����� SYNCRONIZER �� I_DATA ������.
    -- I_PULL_RSV_SIZE����� SYNCRONIZER �� I_DATA ������.
    ------------------------------------------------------------------------------
    I_PULL_RSV_REGS: if (PULL_RSV_VALID /= 0) generate              -- 
        SIZE: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => SIZE_BITS                          , -- 
                OPERATION   => 2                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => I_PULL_RSV_SIZE                    , -- In  :
                I_VAL       => I_PULL_RSV_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PULL_RSV.SIZE_HI downto VEC_RANGE.PULL_RSV.SIZE_LO),
                O_VAL       => i_valid(VEC_RANGE.PULL_RSV.VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      --
        LAST: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA(0)   => I_PULL_RSV_LAST                    , -- In  :
                I_VAL       => I_PULL_RSV_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PULL_RSV.LAST_POS downto VEC_RANGE.PULL_RSV.LAST_POS),
                O_VAL       => open                               , -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    ------------------------------------------------------------------------------
    -- SYNC : ����¦�Ƚ���¦��Ʊ����Ȥ�⥸�塼��
    ------------------------------------------------------------------------------
    SYNC: SYNCRONIZER                                               --
        generic map (                                               --
            DATA_BITS   => i_data 'length                         , --
            VAL_BITS    => i_valid'length                         , --
            I_CLK_RATE  => I_CLK_RATE                             , --
            O_CLK_RATE  => O_CLK_RATE                             , --
            I_CLK_FLOP  => 1                                      , --
            O_CLK_FLOP  => 1                                      , --
            I_CLK_FALL  => 0                                      , --
            O_CLK_FALL  => 0                                      , --
            O_CLK_REGS  => 0                                        --
        )                                                           -- 
        port map (                                                  -- 
            RST         => RST                                    , -- In  :
            I_CLK       => I_CLK                                  , -- In  :
            I_CLR       => I_CLR                                  , -- In  :
            I_CKE       => I_CKE                                  , -- In  :
            I_DATA      => i_data                                 , -- In  :
            I_VAL       => i_valid                                , -- In  :
            I_RDY       => i_ready                                , -- Out :
            O_CLK       => O_CLK                                  , -- In  :
            O_CLR       => O_CLR                                  , -- In  :
            O_CKE       => O_CKE                                  , -- In  :
            O_DATA      => o_data                                 , -- Out :
            O_VAL       => o_valid                                  -- Out :
        );                                                          -- 
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_OPEN_VAL  <= o_valid(VEC_RANGE.OPEN_INFO.VAL_POS);
    O_OPEN_INFO <= o_data (VEC_RANGE.OPEN_INFO.DATA_HI downto VEC_RANGE.OPEN_INFO.DATA_LO);
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_PUSH_FIN_VALID: if (PUSH_FIN_VALID /= 0) generate
        signal    d_data         : std_logic_vector(VEC_RANGE.PUSH_FIN.DATA_HI downto VEC_RANGE.PUSH_FIN.DATA_LO);
        constant  DELAY_SEL      : std_logic_vector(DELAY_CYCLE downto DELAY_CYCLE) := (others => '1');
        signal    delay_valid    : std_logic_vector(DELAY_CYCLE downto 0);
    begin 
        PUSH_FIN_REGS: DELAY_REGISTER                               -- 
            generic map (                                           -- 
                DATA_BITS   => d_data'length                      , -- 
                DELAY_MAX   => DELAY_CYCLE                        , -- 
                DELAY_MIN   => DELAY_CYCLE                          -- 
            )                                                       --
            port map (                                              -- 
                CLK         => O_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => O_CLR                              , -- In  :
                SEL         => DELAY_SEL                          , -- In  :
                D_VAL       => delay_valid                        , -- Out :
                I_DATA      => o_data (VEC_RANGE.PUSH_FIN.DATA_HI downto VEC_RANGE.PUSH_FIN.DATA_LO),
                I_VAL       => o_valid(VEC_RANGE.PUSH_FIN.VAL_POS), -- In  :
                O_DATA      => d_data                             , -- Out :
                O_VAL       => O_PUSH_FIN_VAL                       -- Out :
            );                                                      --
        CLOSE_REGS: DELAY_ADJUSTER                                  -- 
            generic map (                                           -- 
                DATA_BITS   => 1                                  , -- 
                DELAY_MAX   => DELAY_CYCLE                        , -- 
                DELAY_MIN   => DELAY_CYCLE                          -- 
            )                                                       --
            port map (                                              -- 
                CLK         => O_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => O_CLR                              , -- In  :
                SEL         => DELAY_SEL                          , -- In  :
                D_VAL       => delay_valid                        , -- In  :
                I_DATA      => o_data (VEC_RANGE.CLOSE_INFO.DATA_HI downto VEC_RANGE.CLOSE_INFO.DATA_LO), -- In :
                I_VAL       => o_valid(VEC_RANGE.CLOSE_INFO.VAL_POS), -- In  :
                O_DATA      => O_CLOSE_INFO                       , -- Out :
                O_VAL       => O_CLOSE_VAL                          -- Out :
            );                                                      -- 
        O_PUSH_FIN_SIZE <= d_data(VEC_RANGE.PUSH_FIN.SIZE_HI downto VEC_RANGE.PUSH_FIN.SIZE_LO);
        O_PUSH_FIN_LAST <= d_data(VEC_RANGE.PUSH_FIN.LAST_POS);
    end generate;
    O_PUSH_FIN_NONE: if (PUSH_FIN_VALID = 0) generate
        O_PUSH_FIN_VAL  <= '0';
        O_PUSH_FIN_LAST <= '0';
        O_PUSH_FIN_SIZE <= (others => '0');
        O_CLOSE_VAL     <= o_valid(VEC_RANGE.CLOSE_INFO.VAL_POS);
        O_CLOSE_INFO    <= o_data (VEC_RANGE.CLOSE_INFO.DATA_HI downto VEC_RANGE.CLOSE_INFO.DATA_LO);
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_PUSH_RSV_VALID: if (PUSH_RSV_VALID /= 0) generate
        O_PUSH_RSV_VAL  <= o_valid(VEC_RANGE.PUSH_RSV.VAL_POS);
        O_PUSH_RSV_LAST <= o_valid(VEC_RANGE.PUSH_RSV.LAST_POS);
        O_PUSH_RSV_SIZE <= o_valid(VEC_RANGE.PUSH_RSV.SIZE_HI downto VEC_RANGE.PUSH_RSV.SIZE_LO);
    end generate;
    O_PUSH_RSV_NONE : if (PUSH_RSV_VALID  = 0) generate
        O_PUSH_RSV_VAL  <= '0';
        O_PUSH_RSV_LAST <= '0';
        O_PUSH_RSV_SIZE <= (others => '0');
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_PULL_FIN_VALID: if (PULL_FIN_VALID /= 0) generate
        O_PULL_FIN_VAL  <= o_valid(VEC_RANGE.PULL_FIN.VAL_POS);
        O_PULL_FIN_LAST <= o_valid(VEC_RANGE.PULL_FIN.LAST_POS);
        O_PULL_FIN_SIZE <= o_valid(VEC_RANGE.PULL_FIN.SIZE_HI downto VEC_RANGE.PULL_FIN.SIZE_LO);
    end generate;
    O_PULL_FIN_NONE : if (PULL_FIN_VALID  = 0) generate
        O_PULL_FIN_VAL  <= '0';
        O_PULL_FIN_LAST <= '0';
        O_PULL_FIN_SIZE <= (others => '0');
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_PULL_RSV_VALID: if (PULL_RSV_VALID /= 0) generate
        O_PULL_RSV_VAL  <= o_valid(VEC_RANGE.PULL_RSV.VAL_POS);
        O_PULL_RSV_LAST <= o_valid(VEC_RANGE.PULL_RSV.LAST_POS);
        O_PULL_RSV_SIZE <= o_valid(VEC_RANGE.PULL_RSV.SIZE_HI downto VEC_RANGE.PULL_RSV.SIZE_LO);
    end generate;
    O_PULL_RSV_NONE : if (PULL_RSV_VALID  = 0) generate
        O_PULL_RSV_VAL  <= '0';
        O_PULL_RSV_LAST <= '0';
        O_PULL_RSV_SIZE <= (others => '0');
    end generate;
end RTL;
