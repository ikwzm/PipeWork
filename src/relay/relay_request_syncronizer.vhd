-----------------------------------------------------------------------------------
--!     @file    relay_request_syncronizer.vhd
--!     @brief   RELAY REQUEST SYNCRONIZER
--!              Relay の Responder 側から Requester側 へ各種情報を伝達するモジュール.
--!     @version 0.0.1
--!     @date    2013/3/14
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
--! @brief   RELAY REQUEST SYNCRONIZER
-----------------------------------------------------------------------------------
entity  RELAY_REQUEST_SYNCRONIZER is
    generic (
        I_CLK_RATE      : --! @brief INPUT CLOCK RATE :
                          --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        O_CLK_RATE      : --! @brief OUTPUT CLOCK RATE :
                          --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        DELAY_CYCLE     : --! @brief DELAY CYCLE :   
                          --! 入力側から出力側への転送する際の遅延サイクルを指定する.
                          integer :=  0;
        INFO_BITS       : --! @brief REQUEST INFOMATION BITS :
                          integer :=  1;
        SIZE_BITS       : --! @brief I_SIZE/O_SIZEのビット数を指定する.
                          integer :=  8
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号
    -------------------------------------------------------------------------------
        RST             : --! @brief RESET :
                          --! 非同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側の各種信号
    -------------------------------------------------------------------------------
        I_CLK           : --! @brief INPUT CLOCK :
                          --! 入力側のクロック信号.
                          in  std_logic;
        I_CLR           : --! @brief INPUT CLEAR :
                          --! 入力側の同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
        I_CKE           : --! @brief INPUT CLOCK ENABLE :
                          --! 入力側のクロック(I_CLK)の立上りが有効であることを示す信号.
                          --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の
                          --!   位相関係を示す時に使用する.
                          --! * I_CLKの立上り時とOCLKの立上り時が同じ時にアサートす
                          --!   るように入力されなければならない.
                          --! * この信号は I_CLK_RATE > 1 かつ O_CLK_RATE = 1の時の
                          --!   み有効. それ以外は未使用.
                          in  std_logic;
        I_REQ_VAL       : --! @brief INPUT REQUEST VALID :
                          --! I_REQ_INFOが有効であることを示す信号.
                          in  std_logic;
        I_REQ_INFO      : --! @brief INPUT REQUEST INFOMATION :
                          --! 入力側から出力側へ伝達する各種情報.
                          in  std_logic_vector(INFO_BITS-1 downto 0);
        I_STOP_VAL      : --! @brief INPUT STOP :
                          --! 入力側から出力側へ転送の中止を伝達する信号.
                          --! * 伝達の際、DELAY_CYCLE分だけ遅延される.
                          in  std_logic;
        I_PUSH_VAL      : --! @brief INPUT PUSH SIZE/LAST VALID :
                          --! I_PUSH_LAST、I_PUSH_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_PUSH_LAST、I_PUSH_SIZE、
                          --!   内容が出力側に伝達されて、O_PUSH_LAST、O_PUSH_SIZE
                          --!   から出力される.
                          --! * 伝達の際、DELAY_CYCLE分だけ遅延される.
                          in  std_logic;
        I_PUSH_LAST     : --! @brief INPUT PUSH LAST FLAG :
                          in  std_logic;
        I_PUSH_SIZE     : --! @brief INPUT PUSH SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_PULL_VAL      : --! @brief INPUT PULL SIZE/LAST VALID :
                          --! I_PULL_LAST、I_PULL_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_PULL_LAST、I_PULL_SIZE、
                          --!   内容が出力側に伝達されて、O_PULL_LAST、O_PULL_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_PULL_LAST     : --! @brief INPUT PULL LAST FLAG :
                          in  std_logic;
        I_PULL_SIZE     : --! @brief INPUT PULL SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_RSV0_VAL      : --! @brief INPUT RESERVE(0) SIZE/LAST VALID :
                          --! I_RSV0_LAST、I_RSV0_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_RSV0_LAST、I_RSV0_SIZE、
                          --!   内容が出力側に伝達されて、O_RSV0_LAST、O_RSV0_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_RSV0_LAST     : --! @brief INPUT RESERVE(0) LAST FLAG :
                          in  std_logic;
        I_RSV0_SIZE     : --! @brief INPUT RESERVE(0) SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_RSV1_VAL      : --! @brief INPUT RESERVE(1) SIZE/LAST VALID :
                          --! I_RSV1_LAST、I_RSV1_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_RSV1_LAST、I_RSV1_SIZE、
                          --!   内容が出力側に伝達されて、O_RSV1_LAST、O_RSV1_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_RSV1_LAST     : --! @brief INPUT RESERVE(1) LAST FLAG :
                          in  std_logic;
        I_RSV1_SIZE     : --! @brief INPUT RESERVE(1) SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側の各種信号
    -------------------------------------------------------------------------------
        O_CLK           : --! @brief OUTPUT CLOCK :
                          --! 入力側のクロック信号.
                          in  std_logic;
        O_CLR           : --! @brief OUTPUT CLEAR :
                          --! 入力側の同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
        O_CKE           : --! @brief OUTPUT CLOCK ENABLE :
                          --! 出力側のクロック(O_CLK)の立上りが有効であることを示す信号.
                          --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の
                          --!   位相関係を示す時に使用する.
                          --! * I_CLKの立上り時とO_CLKの立上り時が同じ時にアサートす
                          --!   るように入力されなければならない.
                          --! * この信号は O_CLK_RATE > 1 かつ I_CLK_RATE = 1の時のみ
                          --!   有効. それ以外は未使用.
                          in  std_logic;
        O_REQ_VAL       : --! @brief OUTPUT REQUEST VALID :
                          --! O_REQ_INFOが有効であることを示す信号.
                          out std_logic;
        O_REQ_INFO      : --! @brief OUTPUT REQUEST INFOMATION :
                          --! 入力側から出力側へ伝達された各種情報.
                          out std_logic_vector(INFO_BITS-1 downto 0);
        O_STOP_VAL      : --! @brief OUTPUT STOP :
                          --! 入力側から出力側へ伝達された、転送を中止する信号.
                          --! * 伝達の際、DELAY_CYCLE分だけ遅延される.
                          out std_logic;
        O_PUSH_VAL      : --! @brief OUTPUT PUSH SIZE/LAST VALID :
                          --! O_PUSH_LAST、O_PUSH_SIZE、が有効であることを示す信号.
                          out  std_logic;
        O_PUSH_LAST     : --! @brief OUTPUT PUSH LAST FLAG :
                          out std_logic;
        O_PUSH_SIZE     : --! @brief OUTPUT PUSH SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_PULL_VAL      : --! @brief OUTPUT PULL SIZE/LAST VALID :
                          --! O_PULL_LAST、O_PULL_SIZE、が有効であることを示す信号.
                          out std_logic;
        O_PULL_LAST     : --! @brief OUTPUT PULL LAST FLAG :
                          out std_logic;
        O_PULL_SIZE     : --! @brief OUTPUT PULL SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_RSV0_VAL      : --! @brief OUTPUT RESERVE(0) SIZE/LAST VALID :
                          --! O_RSV0_LAST、O_RSV0_SIZE、が有効であることを示す信号.
                          out std_logic;
        O_RSV0_LAST     : --! @brief OUTPUT RESERVE(0) LAST FLAG :
                          out std_logic;
        O_RSV0_SIZE     : --! @brief OUTPUT RESERVE(0) SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_RSV1_VAL      : --! @brief OUTPUT RESERVE(1) SIZE/LAST VALID :
                          out std_logic;
        O_RSV1_LAST     : --! @brief OUTPUT RESERVE(1) LAST FLAG :
                          out std_logic;
        O_RSV1_SIZE     : --! @brief OUTPUT RESERVE(1) SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0)
    );
end RELAY_REQUEST_SYNCRONIZER;
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
architecture  RTL of RELAY_REQUEST_SYNCRONIZER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  VALID_LO      : integer   := 0;
    constant  REQ_VAL_POS   : integer   := 0;
    constant  STOP_VAL_POS  : integer   := 1;
    constant  PUSH_VAL_POS  : integer   := 2;
    constant  PULL_VAL_POS  : integer   := 3;
    constant  RSV0_VAL_POS  : integer   := 4;
    constant  RSV1_VAL_POS  : integer   := 5;
    constant  VALID_HI      : integer   := 5;
    signal    i_valid       : std_logic_vector(VALID_HI downto VALID_LO);
    signal    o_valid       : std_logic_vector(VALID_HI downto VALID_LO);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  DATA_LO       : integer   := 0;
    constant  REQ_INFO_LO   : integer   := DATA_LO       + 1;
    constant  REQ_INFO_HI   : integer   := REQ_INFO_LO   + I_REQ_INFO'length  - 1;
    constant  PUSH_LAST_POS : integer   := REQ_INFO_HI   + 1;
    constant  PUSH_SIZE_LO  : integer   := PUSH_LAST_POS + 1;
    constant  PUSH_SIZE_HI  : integer   := PUSH_SIZE_LO  + I_PUSH_SIZE'length - 1;
    constant  PULL_LAST_POS : integer   := PUSH_SIZE_HI  + 1;
    constant  PULL_SIZE_LO  : integer   := PULL_LAST_POS + 1;
    constant  PULL_SIZE_HI  : integer   := PULL_SIZE_LO  + I_PULL_SIZE'length - 1;
    constant  RSV0_LAST_POS : integer   := PULL_SIZE_HI  + 1;
    constant  RSV0_SIZE_LO  : integer   := RSV0_LAST_POS + 1;
    constant  RSV0_SIZE_HI  : integer   := RSV0_SIZE_LO  + I_RSV0_SIZE'length - 1;
    constant  RSV1_LAST_POS : integer   := RSV0_SIZE_HI  + 1;
    constant  RSV1_SIZE_LO  : integer   := RSV1_LAST_POS + 1;
    constant  RSV1_SIZE_HI  : integer   := RSV1_SIZE_LO  + I_RSV1_SIZE'length - 1;
    constant  DATA_HI       : integer   := RSV1_SIZE_HI;
    signal    i_data        : std_logic_vector(DATA_HI downto DATA_LO);
    signal    o_data        : std_logic_vector(DATA_HI downto DATA_LO);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  sig0          : std_logic := '0';
    constant  i_pause       : std_logic := '0';
    signal    i_ready       : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  PUSH_DATA_LO  : integer   := PUSH_LAST_POS;
    constant  PUSH_DATA_HI  : integer   := PUSH_SIZE_HI;
    signal    d_push_data   : std_logic_vector(PUSH_DATA_HI downto PUSH_DATA_LO);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  DELAY_SEL     : std_logic_vector(DELAY_CYCLE downto DELAY_CYCLE) := (others => '1');
    signal    d_valid       : std_logic_vector(DELAY_CYCLE downto 0);
begin
    ------------------------------------------------------------------------------
    -- I_REQ_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    -- I_REQ_INFO信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_REQ_INFO_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                 --
        generic map (                                                   --
            DATA_BITS   => I_REQ_INFO'length                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA      => I_REQ_INFO                                 , -- In  :
            I_VAL       => I_REQ_VAL                                  , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (REQ_INFO_HI downto REQ_INFO_LO)    , -- Out :
            O_VAL       => i_valid(REQ_VAL_POS)                       , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- I_STOP_VAL信号を SYNCRONIZER の I_VAL  に入力.
    ------------------------------------------------------------------------------
    I_STOP_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                     --
        generic map (                                                   --
            DATA_BITS   => 1                                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA(0)   => I_STOP_VAL                                 , -- In  :
            I_VAL       => I_STOP_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => open                                       , -- Out :
            O_VAL       => i_valid(STOP_VAL_POS)                      , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- I_PUSH_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    -- I_PUSH_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_PUSH_SIZE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => I_PUSH_SIZE'length                         , -- 
            OPERATION   => 2                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA      => I_PUSH_SIZE                                , -- In  :
            I_VAL       => I_PUSH_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (PUSH_SIZE_HI downto PUSH_SIZE_LO)  , -- Out :
            O_VAL       => i_valid(PUSH_VAL_POS)                      , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              --     
    ------------------------------------------------------------------------------
    -- I_PUSH_LAST信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_PUSH_LAST_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => 1                                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA(0)   => I_PUSH_LAST                                , -- In  :
            I_VAL       => I_PUSH_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (PUSH_LAST_POS downto PUSH_LAST_POS), -- Out :
            O_VAL       => open                                       , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- I_PULL_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    -- I_PULL_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_PULL_SIZE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => I_PULL_SIZE'length                         , -- 
            OPERATION   => 2                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA      => I_PULL_SIZE                                , -- In  :
            I_VAL       => I_PULL_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (PULL_SIZE_HI downto PULL_SIZE_LO)  , -- Out :
            O_VAL       => i_valid(PULL_VAL_POS)                      , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              --     
    ------------------------------------------------------------------------------
    -- I_PULL_LAST信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_PULL_LAST_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => 1                                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA(0)   => I_PULL_LAST                                , -- In  :
            I_VAL       => I_PULL_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (PULL_LAST_POS downto PULL_LAST_POS), -- Out :
            O_VAL       => open                                       , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- I_RSV0_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    -- I_RSV0_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_RSV0_SIZE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => I_RSV0_SIZE'length                         , -- 
            OPERATION   => 2                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA      => I_RSV0_SIZE                                , -- In  :
            I_VAL       => I_RSV0_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (RSV0_SIZE_HI downto RSV0_SIZE_LO)  , -- Out :
            O_VAL       => i_valid(RSV0_VAL_POS)                      , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              --     
    ------------------------------------------------------------------------------
    -- I_RSV0_LAST信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_RSV0_LAST_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => 1                                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA(0)   => I_RSV0_LAST                                , -- In  :
            I_VAL       => I_RSV0_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (RSV0_LAST_POS downto RSV0_LAST_POS), -- Out :
            O_VAL       => open                                       , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- I_RSV1_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    -- I_RSV1_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_RSV1_SIZE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => I_RSV1_SIZE'length                         , -- 
            OPERATION   => 2                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA      => I_RSV1_SIZE                                , -- In  :
            I_VAL       => I_RSV1_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (RSV1_SIZE_HI downto RSV1_SIZE_LO)  , -- Out :
            O_VAL       => i_valid(RSV1_VAL_POS)                      , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              --     
    ------------------------------------------------------------------------------
    -- I_RSV1_LAST信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_RSV1_LAST_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => 1                                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA(0)   => I_RSV1_LAST                                , -- In  :
            I_VAL       => I_RSV1_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (RSV1_LAST_POS downto RSV1_LAST_POS), -- Out :
            O_VAL       => open                                       , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- SYNC : 入力側と出力側で同期をとるモジュール
    ------------------------------------------------------------------------------
    SYNC: SYNCRONIZER                                                   --
        generic map (                                                   --
            DATA_BITS   => i_data 'length                             , --
            VAL_BITS    => i_valid'length                             , --
            I_CLK_RATE  => I_CLK_RATE                                 , --
            O_CLK_RATE  => O_CLK_RATE                                 , --
            I_CLK_FLOP  => 1                                          , --
            O_CLK_FLOP  => 1                                          , --
            I_CLK_FALL  => 0                                          , --
            O_CLK_FALL  => 0                                          , --
            O_CLK_REGS  => 0                                            --
        )                                                               -- 
        port map (                                                      -- 
            RST         => RST                                        , -- In  :
            I_CLK       => I_CLK                                      , -- In  :
            I_CLR       => I_CLR                                      , -- In  :
            I_CKE       => I_CKE                                      , -- In  :
            I_DATA      => i_data                                     , -- In  :
            I_VAL       => i_valid                                    , -- In  :
            I_RDY       => i_ready                                    , -- Out :
            O_CLK       => O_CLK                                      , -- In  :
            O_CLR       => O_CLR                                      , -- In  :
            O_CKE       => O_CKE                                      , -- In  :
            O_DATA      => o_data                                     , -- Out :
            O_VAL       => o_valid                                      -- Out :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- O_PUSH_VAL  : O_PUSH_SIZE/O_PUSH_LASTが有効であることを示す.
    -- O_PUSH_SIZE : SYNCで同期をとった PUSH_SIZE を指定したクロックだけ遅延させて出力.
    -- O_PUSH_LAST : SYNCで同期をとった PUSH_LAST を指定したクロックだけ遅延させて出力.
    ------------------------------------------------------------------------------
    O_PUSH_SIZE_REGS: DELAY_REGISTER                                    -- 
        generic map (                                                   -- 
            DATA_BITS   => d_push_data'length                         , -- 
            DELAY_MAX   => DELAY_CYCLE                                , -- 
            DELAY_MIN   => DELAY_CYCLE                                  -- 
        )                                                               --
        port map (                                                      -- 
            CLK         => O_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => O_CLR                                      , -- In  :
            SEL         => DELAY_SEL                                  , -- In  :
            D_VAL       => d_valid                                    , -- Out :
            I_DATA      => o_data (PUSH_DATA_HI downto PUSH_DATA_LO)  , -- In  :
            I_VAL       => o_valid(PUSH_VAL_POS)                      , -- In  :
            O_DATA      => d_push_data                                , -- Out :
            O_VAL       => O_PUSH_VAL                                   -- Out :
        );                                                              -- 
    O_PUSH_SIZE <= d_push_data(PUSH_SIZE_HI downto PUSH_SIZE_LO);       -- 
    O_PUSH_LAST <= d_push_data(PUSH_LAST_POS);                          --
    ------------------------------------------------------------------------------
    -- O_STOP_VAL  : SYNCで同期をとった I_STOP_VAL を、O_PUSH_SIZE/O_PUSH_LASTに
    --               合わせて遅延させる.
    ------------------------------------------------------------------------------
    O_STOP_REGS: DELAY_ADJUSTER                                         -- 
        generic map (                                                   -- 
            DATA_BITS   => 1                                          , -- 
            DELAY_MAX   => DELAY_CYCLE                                , -- 
            DELAY_MIN   => DELAY_CYCLE                                  -- 
        )                                                               --
        port map (                                                      -- 
            CLK         => O_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => O_CLR                                      , -- In  :
            SEL         => DELAY_SEL                                  , -- In  :
            D_VAL       => d_valid                                    , -- In  :
            I_DATA(0)   => sig0                                       , -- In  :
            I_VAL       => o_valid(STOP_VAL_POS)                      , -- In  :
            O_DATA      => open                                       , -- Out :
            O_VAL       => O_STOP_VAL                                   -- Out :
        );                                                              -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_REQ_VAL   <= o_valid(REQ_VAL_POS);
    O_REQ_INFO  <= o_data (REQ_INFO_HI  downto REQ_INFO_LO );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_PULL_VAL  <= o_valid(PULL_VAL_POS);
    O_PULL_LAST <= o_data (PULL_LAST_POS);
    O_PULL_SIZE <= o_data (PULL_SIZE_HI downto PULL_SIZE_LO);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_RSV0_VAL  <= o_valid(RSV0_VAL_POS);
    O_RSV0_LAST <= o_data (RSV0_LAST_POS);
    O_RSV0_SIZE <= o_data (RSV0_SIZE_HI downto RSV0_SIZE_LO);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_RSV1_VAL  <= o_valid(RSV1_VAL_POS);
    O_RSV1_LAST <= o_data (RSV1_LAST_POS);
    O_RSV1_SIZE <= o_data (RSV1_SIZE_HI downto RSV1_SIZE_LO);
end RTL;
