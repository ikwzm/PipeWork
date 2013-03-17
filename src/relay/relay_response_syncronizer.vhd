-----------------------------------------------------------------------------------
--!     @file    relay_response_syncronizer.vhd
--!     @brief   RELAY RESPONSE SYNCRONIZER
--!              Relay の Requester 側から Responder側 へ各種情報を伝達するモジュール.
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
--! @brief   RELAY RESPONSE SYNCRONIZER
-----------------------------------------------------------------------------------
entity  RELAY_RESPONSE_SYNCRONIZER is
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
        INFO_BITS       : --! @brief RESPONSE INFOMATION BITS :
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
        I_DIR           : --! @brief INPUT DIRECTION :
                          --! 転送方向(PUSH/PULL)を指定する.
                          --! * I_DIR='1' : PUSH(Responder側からRequester側へデータ転送)
                          --! * I_DIR='0' : PULL(Requester側からResponder側へデータ転送)
                          in  std_logic;
        I_START_VAL     : --! @brief INPUT START :
                          --! 入力側から出力側へ転送の開始を伝達する信号.
                          in  std_logic;
        I_RES_VAL       : --! @brief INPUT RESPONSE VALID :
                          --! I_RES_INFOが有効であることを示す信号.
                          --! * 伝達の際、場合によっては DELAY_CYCLE分だけ遅延される.
                          in  std_logic;
        I_RES_INFO      : --! @brief INPUT RESPONSE INFOMATION :
                          --! 入力側から出力側へ伝達する各種情報.
                          --! * 伝達の際、場合によっては DELAY_CYCLE分だけ遅延される.
                          in  std_logic_vector(INFO_BITS-1 downto 0);
        I_XFER_VAL      : --! @brief INPUT TRANSFER SIZE/LAST VALID :
                          --! I_XFER_LAST、I_XFER_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_XFER_LAST、I_XFER_SIZE、
                          --!   内容が出力側に伝達されて、O_XFER_LAST、O_XFER_SIZE
                          --!   から出力される.
                          --! * I_DIR='1'の場合、伝達の際にDELAY_CYCLE分だけ遅延される.
                          in  std_logic;
        I_XFER_LAST     : --! @brief INPUT TRANSFER LAST FLAG :
                          in  std_logic;
        I_XFER_SIZE     : --! @brief INPUT TRANSFER SIZE :
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_RESV_VAL      : --! @brief INPUT RESERVE SIZE/LAST VALID :
                          --! I_RESV_LAST、I_RESV_SIZE、が有効であることを示す信号.
                          --! * この信号のアサートにより I_RESV_LAST、I_RESV_SIZE、
                          --!   内容が出力側に伝達されて、O_RESV_LAST、O_RESV_SIZE
                          --!   から出力される.
                          in  std_logic;
        I_RESV_LAST     : --! @brief INPUT RESERVE LAST FLAG :
                          in  std_logic;
        I_RESV_SIZE     : --! @brief INPUT RESERVE SIZE :
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
        O_START_VAL     : --! @brief OUTPUT START :
                          --! 入力側から出力側へ転送の開始を伝達する信号.
                          out std_logic;
        O_DIR           : --! @brief INPUT DIRECTION :
                          --! 転送方向(PUSH/PULL)を出力する.
                          out std_logic;
        O_RES_VAL       : --! @brief OUTPUT RESPONSE VALID :
                          --! O_RES_INFOが有効であることを示す信号.
                          out std_logic;
        O_RES_INFO      : --! @brief OUTPUT RESPONSE INFOMATION :
                          --! 入力側から出力側へ伝達された各種情報.
                          out std_logic_vector(INFO_BITS-1 downto 0);
        O_XFER_VAL      : --! @brief OUTPUT TRANSFER SIZE/LAST VALID :
                          --! O_XFER_LAST、O_XFER_SIZE、が有効であることを示す信号.
                          out  std_logic;
        O_XFER_DIR      : --! @brief OUTPUT TRANSFER DIRECTION :
                          out std_logic;
        O_XFER_LAST     : --! @brief OUTPUT TRANSFER LAST FLAG :
                          out std_logic;
        O_XFER_SIZE     : --! @brief OUTPUT TRANSFER SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        O_RESV_VAL      : --! @brief OUTPUT RESERVE SIZE/LAST VALID :
                          --! O_RESV_LAST、O_RESV_SIZE、が有効であることを示す信号.
                          out std_logic;
        O_RESV_DIR      : --! @brief OUTPUT RESERVE DIRECTION :
                          out std_logic;
        O_RESV_LAST     : --! @brief OUTPUT RESERVE LAST FLAG :
                          out std_logic;
        O_RESV_SIZE     : --! @brief OUTPUT RESERVE SIZE :
                          out std_logic_vector(SIZE_BITS-1 downto 0)
    );
end RELAY_RESPONSE_SYNCRONIZER;
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
architecture  RTL of RELAY_RESPONSE_SYNCRONIZER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  VALID_LO      : integer   := 0;
    constant  START_VAL_POS : integer   := 0;
    constant  RES_VAL_POS   : integer   := 1;
    constant  XFER_VAL_POS  : integer   := 2;
    constant  RESV_VAL_POS  : integer   := 3;
    constant  VALID_HI      : integer   := 3;
    signal    i_valid       : std_logic_vector(VALID_HI downto VALID_LO);
    signal    o_valid       : std_logic_vector(VALID_HI downto VALID_LO);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  DATA_LO       : integer   := 0;
    constant  RES_DIR_POS   : integer   := DATA_LO       + 1;
    constant  RES_INFO_LO   : integer   := RES_DIR_POS   + 1;
    constant  RES_INFO_HI   : integer   := RES_INFO_LO   + I_RES_INFO'length  - 1;
    constant  XFER_DIR_POS  : integer   := RES_INFO_HI   + 1;
    constant  XFER_LAST_POS : integer   := XFER_DIR_POS  + 1;
    constant  XFER_SIZE_LO  : integer   := XFER_LAST_POS + 1;
    constant  XFER_SIZE_HI  : integer   := XFER_SIZE_LO  + I_XFER_SIZE'length - 1;
    constant  RESV_DIR_POS  : integer   := XFER_SIZE_HI  + 1;
    constant  RESV_LAST_POS : integer   := RESV_DIR_POS  + 1;
    constant  RESV_SIZE_LO  : integer   := RESV_LAST_POS + 1;
    constant  RESV_SIZE_HI  : integer   := RESV_SIZE_LO  + I_RESV_SIZE'length - 1;
    constant  DATA_HI       : integer   := RESV_SIZE_HI;
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
    constant  XFER_DATA_LO  : integer   := XFER_DIR_POS;
    constant  XFER_DATA_HI  : integer   := XFER_SIZE_HI;
    signal    d_data        : std_logic_vector(XFER_DATA_HI downto XFER_DATA_LO);
    signal    d_push_valid  : std_logic;
    signal    o_push_valid  : std_logic;
    signal    o_pull_valid  : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  DELAY_SEL     : std_logic_vector(DELAY_CYCLE downto DELAY_CYCLE) := (others => '1');
    signal    delay_valid   : std_logic_vector(DELAY_CYCLE downto 0);
begin
    ------------------------------------------------------------------------------
    -- I_START_VAL信号を SYNCRONIZER の I_VAL  に入力.
    ------------------------------------------------------------------------------
    I_START_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
        generic map (                                                   --
            DATA_BITS   => 1                                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA(0)   => I_DIR                                      , -- In  :
            I_VAL       => I_START_VAL                                , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (RES_DIR_POS downto RES_DIR_POS)    , -- Out :
            O_VAL       => i_valid(START_VAL_POS)                     , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- I_RES_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    -- I_RES_INFO信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_RES_INFO_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                 --
        generic map (                                                   --
            DATA_BITS   => I_RES_INFO'length                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA      => I_RES_INFO                                 , -- In  :
            I_VAL       => I_RES_VAL                                  , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (RES_INFO_HI downto RES_INFO_LO)    , -- Out :
            O_VAL       => i_valid(RES_VAL_POS)                       , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- I_XFER_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    -- I_XFER_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_XFER_SIZE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => I_XFER_SIZE'length                         , -- 
            OPERATION   => 2                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA      => I_XFER_SIZE                                , -- In  :
            I_VAL       => I_XFER_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (XFER_SIZE_HI downto XFER_SIZE_LO)  , -- Out :
            O_VAL       => i_valid(XFER_VAL_POS)                      , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              --     
    ------------------------------------------------------------------------------
    -- I_DIR       信号を SYNCRONIZER の I_DATA(XFER_DIR_POS ) に入力.
    -- I_XFER_LAST 信号を SYNCRONIZER の I_DATA(XFER_LAST_POS) に入力.
    ------------------------------------------------------------------------------
    I_XFER_FLAG_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => 2                                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA(0)   => I_DIR                                      , -- In  :
            I_DATA(1)   => I_XFER_LAST                                , -- In  :
            I_VAL       => I_XFER_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (XFER_LAST_POS downto XFER_DIR_POS) , -- Out :
            O_VAL       => open                                       , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              -- 
    ------------------------------------------------------------------------------
    -- I_RESV_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    -- I_RESV_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_RESV_SIZE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => I_RESV_SIZE'length                         , -- 
            OPERATION   => 2                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA      => I_RESV_SIZE                                , -- In  :
            I_VAL       => I_RESV_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (RESV_SIZE_HI downto RESV_SIZE_LO)  , -- Out :
            O_VAL       => i_valid(RESV_VAL_POS)                      , -- Out :
            O_RDY       => i_ready                                      -- In  :
        );                                                              --     
    ------------------------------------------------------------------------------
    -- I_DIR       信号を SYNCRONIZER の I_DATA(RESV_DIR_POS ) に入力.
    -- I_RESV_LAST 信号を SYNCRONIZER の I_DATA(RESV_LAST_POS) に入力.
    ------------------------------------------------------------------------------
    I_RESV_LAST_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                                   --
            DATA_BITS   => 2                                          , -- 
            OPERATION   => 1                                            -- 
        )                                                               -- 
        port map (                                                      -- 
            CLK         => I_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => I_CLR                                      , -- In  :
            I_DATA(0)   => I_DIR                                      , -- In  :
            I_DATA(1)   => I_RESV_LAST                                , -- In  :
            I_VAL       => I_RESV_VAL                                 , -- In  :
            I_PAUSE     => i_pause                                    , -- In  :
            P_DATA      => open                                       , -- Out :
            P_VAL       => open                                       , -- Out :
            O_DATA      => i_data (RESV_LAST_POS downto RESV_DIR_POS) , -- Out :
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
    -- d_push_valid  : d_data が有効であることを示す.
    -- d_data        : SYNCで同期をとった I_XFER_SIZE/LAST を指定したクロックだけ
    --                 遅延させて出力.
    ------------------------------------------------------------------------------
    D_XFER_SIZE_REGS: DELAY_REGISTER                                    -- 
        generic map (                                                   -- 
            DATA_BITS   => d_data'length                              , -- 
            DELAY_MAX   => DELAY_CYCLE                                , -- 
            DELAY_MIN   => DELAY_CYCLE                                  -- 
        )                                                               --
        port map (                                                      -- 
            CLK         => O_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => O_CLR                                      , -- In  :
            SEL         => DELAY_SEL                                  , -- In  :
            D_VAL       => delay_valid                                , -- Out :
            I_DATA      => o_data (XFER_DATA_HI downto XFER_DATA_LO)  , -- In  :
            I_VAL       => o_push_valid                               , -- In  :
            O_DATA      => d_data                                     , -- Out :
            O_VAL       => d_push_valid                                 -- Out :
        );                                                              --
    o_push_valid <= '1' when (o_data(XFER_DIR_POS) = '0' and o_valid(XFER_VAL_POS) = '1') else '0';
    o_pull_valid <= '1' when (o_data(XFER_DIR_POS) = '1' and o_valid(XFER_VAL_POS) = '1') else '0';
    ------------------------------------------------------------------------------
    -- O_RES_VAL   : SYNCで同期をとった I_RES_VAL  を、O_PUSH_SIZE/O_PUSH_LASTに
    --               合わせて遅延させる.
    -- O_RES_INFO  : SYNCで同期をとった I_RES_INFO を、O_PUSH_SIZE/O_PUSH_LASTに
    --               合わせて遅延させる.
    ------------------------------------------------------------------------------
    O_RES_INFO_REGS: DELAY_ADJUSTER                                     -- 
        generic map (                                                   -- 
            DATA_BITS   => O_RES_INFO'length                          , -- 
            DELAY_MAX   => DELAY_CYCLE                                , -- 
            DELAY_MIN   => DELAY_CYCLE                                  -- 
        )                                                               --
        port map (                                                      -- 
            CLK         => O_CLK                                      , -- In  :
            RST         => RST                                        , -- In  :
            CLR         => O_CLR                                      , -- In  :
            SEL         => DELAY_SEL                                  , -- In  :
            D_VAL       => delay_valid                                , -- In  :
            I_DATA      => o_data (RES_INFO_HI downto RES_INFO_LO)    , -- In  :
            I_VAL       => o_valid(RES_VAL_POS)                       , -- In  :
            O_DATA      => O_RES_INFO                                 , -- Out :
            O_VAL       => O_RES_VAL                                    -- Out :
        );                                                              -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_START_VAL <= o_valid(START_VAL_POS);
    O_DIR       <= o_data (RES_DIR_POS);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_XFER_VAL  <= '1' when (d_push_valid = '1' or o_pull_valid = '1') else '0';
    O_XFER_DIR  <= d_data (XFER_DIR_POS )                    when (d_push_valid = '1') else
                   o_data (XFER_DIR_POS );
    O_XFER_LAST <= d_data (XFER_LAST_POS)                    when (d_push_valid = '1') else
                   o_data (XFER_LAST_POS);
    O_XFER_SIZE <= d_data (XFER_SIZE_HI downto XFER_SIZE_LO) when (d_push_valid = '1') else
                   o_data (XFER_SIZE_HI downto XFER_SIZE_LO);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_RESV_VAL  <= o_valid(RESV_VAL_POS);
    O_RESV_DIR  <= o_data (RESV_DIR_POS);
    O_RESV_LAST <= o_data (RESV_LAST_POS);
    O_RESV_SIZE <= o_data (RESV_SIZE_HI downto RESV_SIZE_LO);
end RTL;
