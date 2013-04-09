-----------------------------------------------------------------------------------
--!     @file    pump_flow_syncronizer.vhd
--!     @brief   PUMP FLOW SYNCRONIZER
--!              PUMPの入力側と出力側の間で各種情報を伝達するモジュール
--!     @version 1.5.0
--!     @date    2013/4/2
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
--! @brief   PUMP FLOW SYNCRONIZER :
-----------------------------------------------------------------------------------
entity  PUMP_FLOW_SYNCRONIZER is
    generic (
        I_CLK_RATE  : --! @brief INPUT CLOCK RATE :
                      --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側のクロッ
                      --! ク(O_CLK)との関係を指定する.
                      --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                      integer :=  1;
        O_CLK_RATE  : --! @brief OUTPUT CLOCK RATE :
                      --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側のクロッ
                      --! ク(O_CLK)との関係を指定する.
                      --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                      integer :=  1;
        DELAY_CYCLE : --! @brief DELAY CYCLE :
                      --! 入力側から出力側への転送する際の遅延サイクルを指定する.
                      integer :=  0;
        SIZE_BITS   : --! @brief I_SIZE/O_SIZEのビット数を指定する.
                      integer :=  8
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号
    -------------------------------------------------------------------------------
        RST         : --! @brief RESET :
                      --! 非同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側の各種信号
    -------------------------------------------------------------------------------
        I_CLK       : --! @brief INPUT CLOCK :
                      --! 入力側のクロック信号.
                      in  std_logic;
        I_CLR       : --! @brief INPUT CLEAR :
                      --! 入力側の同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
        I_CKE       : --! @brief INPUT CLOCK ENABLE :
                      --! 入力側のクロック(I_CLK)の立上りが有効であることを示す信号.
                      --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の位相
                      --!   関係を示す時に使用する.
                      --! * I_CLKの立上り時とOCLKの立上り時が同じ時にアサートするよ
                      --!   うに入力されなければならない.
                      --! * この信号は I_CLK_RATE > 1 かつ O_CLK_RATE = 1の時のみ有
                      --!   効. それ以外は未使用.
                      in  std_logic;
        I_OPEN      : --! @brief INPUT OPEN FLAG :
                      --! 入力側のバルブが開いていることを示すフラグ.
                      in  std_logic;
        I_VAL       : --! @brief INPUT SIZE/LAST VALID :
                      --! I_LAST、I_SIZEが有効であることを示す信号.
                      --! この信号のアサートによりI_LAST、I_SIZEの内容が出力側に伝達
                      --! されて、O_LAST、O_SIZEから出力される.
                      in  std_logic;
        I_LAST      : --! @brief INPUT LAST FLAG :
                      --! 最後の転送であることを示すフラグを入力.
                      in  std_logic;
        I_SIZE      : --! @brief INPUT SIZE :
                      --! 転送バイト数を入力.
                      in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側の各種信号
    -------------------------------------------------------------------------------
        O_CLK       : --! @brief OUTPUT CLK :
                      --! 出力側のクロック信号.
                      in  std_logic;
        O_CLR       : --! @brief OUTPUT CLEAR :
                      --! 出力側の同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
        O_CKE       : --! @brief OUTPUT CLOCK ENABLE :
                      --! 出力側のクロック(O_CLK)の立上りが有効であることを示す信号.
                      --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の位相
                      --!   関係を示す時に使用する.
                      --! * I_CLKの立上り時とO_CLKの立上り時が同じ時にアサートする
                      --!   ように入力されなければならない.
                      --! * この信号は O_CLK_RATE > 1 かつ I_CLK_RATE = 1の時のみ有
                      --!   効. それ以外は未使用.
                      in  std_logic;
        O_OPEN      : --! @brief OUTPUT OPEN FLAG :
                      --! 入力側のバルブが開いていることを示すフラグ.
                      out std_logic;
        O_VAL       : --! @brief OUTPUT SIZE/LAST VALID :
                      --! O_LAST、O_SIZEが有効であることを示す信号.
                      out std_logic;
        O_LAST      : --! @brief OUTPUT LAST FLAG :
                      --! 最後の転送であることを示すフラグを出力.
                      out std_logic;
        O_SIZE      : --! @brief INPUT SIZE :
                      --! 転送バイト数を出力.
                      out std_logic_vector(SIZE_BITS-1 downto 0)
    );
end PUMP_FLOW_SYNCRONIZER;
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
architecture RTL of PUMP_FLOW_SYNCRONIZER is
    constant VALID_LO   : integer   := 0;
    constant VALID_POS  : integer   := 0;
    constant OPEN_POS   : integer   := 1;
    constant CLOSE_POS  : integer   := 2;
    constant VALID_HI   : integer   := 2;
    constant DATA_LO    : integer   := 0;
    constant SIZE_LO    : integer   := 0;
    constant SIZE_HI    : integer   := SIZE_LO + SIZE_BITS - 1;
    constant LAST_POS   : integer   := SIZE_HI + 1;
    constant DATA_HI    : integer   := LAST_POS;
    constant sig0       : std_logic := '0';
    constant i_pause    : std_logic := '0';
    signal   i_data     : std_logic_vector( DATA_HI downto  DATA_LO);
    signal   i_valid    : std_logic_vector(VALID_HI downto VALID_LO);
    signal   i_ready    : std_logic;
    signal   i_open_q   : std_logic;
    signal   i_open_val : std_logic;
    signal   i_close_val: std_logic;
    signal   o_data     : std_logic_vector( DATA_HI downto  DATA_LO);
    signal   o_valid    : std_logic_vector(VALID_HI downto VALID_LO);
    signal   o_open_q   : std_logic;
    signal   o_open_val : std_logic;
    signal   o_close_val: std_logic;
    constant DELAY_SEL  : std_logic_vector(DELAY_CYCLE downto DELAY_CYCLE) := (others => '1');
    signal   d_valid    : std_logic_vector(DELAY_CYCLE downto 0);
    signal   d_data     : std_logic_vector( DATA_HI downto  DATA_LO);
begin
    ------------------------------------------------------------------------------
    -- i_open_val  : I_OPENの立ち上がりを示す.
    -- i_close_val : I_OPENの立ち下がりを示す.
    ------------------------------------------------------------------------------
    process (I_CLK, RST) begin
        if (RST = '1') then
                i_open_q <= '0';
        elsif (I_CLK'event and I_CLK = '1') then
            if (I_CLR = '1') then
                i_open_q <= '0';
            else
                i_open_q <= i_open;
            end if;
        end if;
    end process;
    i_open_val  <= '1' when (i_open_q = '0' and I_OPEN = '1') else '0';
    i_close_val <= '1' when (i_open_q = '1' and I_OPEN = '0') else '0';
    ------------------------------------------------------------------------------
    -- i_valid(OPEN_POS) : i_open_val 信号を SYNCRONIZER の I_VAL に入力する.
    ------------------------------------------------------------------------------
    I_OPEN_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER
        generic map (                          --
            DATA_BITS   => 1                 , -- 
            OPERATION   => 1                   -- 
        )                                      -- 
        port map (                             -- 
            CLK         => I_CLK             , -- In  :
            RST         => RST               , -- In  :
            CLR         => I_CLR             , -- In  :
            I_DATA(0)   => sig0              , -- In  :
            I_VAL       => i_open_val        , -- In  :
            I_PAUSE     => i_pause           , -- In  :
            P_DATA      => open              , -- Out :
            P_VAL       => open              , -- Out :
            O_DATA      => open              , -- Out :
            O_VAL       => i_valid(OPEN_POS) , -- Out :
            O_RDY       => i_ready             -- In  :
        );                                     -- 
    ------------------------------------------------------------------------------
    -- i_valid(CLOSE_POS): i_close_val 信号を SYNCRONIZER の I_VAL に入力する.
    ------------------------------------------------------------------------------
    I_CLOSE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER
        generic map (                          --
            DATA_BITS   => 1                 , -- 
            OPERATION   => 1                   -- 
        )                                      -- 
        port map (                             -- 
            CLK         => I_CLK             , -- In  :
            RST         => RST               , -- In  :
            CLR         => I_CLR             , -- In  :
            I_DATA(0)   => sig0              , -- In  :
            I_VAL       => i_close_val       , -- In  :
            I_PAUSE     => i_pause           , -- In  :
            P_DATA      => open              , -- Out :
            P_VAL       => open              , -- Out :
            O_DATA      => open              , -- Out :
            O_VAL       => i_valid(CLOSE_POS), -- Out :
            O_RDY       => i_ready             -- In  :
        );                                     -- 
    ------------------------------------------------------------------------------
    -- i_valid(VALID_POS) : I_VAL 信号を SYNCRONIZER の I_VAL に入力する.
    -- i_data(SIZE'range) : I_SIZE信号を SYNCRONIZER の I_DATA に入力する.
    ------------------------------------------------------------------------------
    I_SIZE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER
        generic map (                          --
            DATA_BITS   => SIZE_BITS         , -- 
            OPERATION   => 2                   -- 
        )                                      --
        port map (                             --
            CLK         => I_CLK             , -- In  :
            RST         => RST               , -- In  :
            CLR         => I_CLR             , -- In  :
            I_DATA      => I_SIZE            , -- In  :
            I_VAL       => I_VAL             , -- In  :
            I_PAUSE     => i_pause           , -- In  :
            P_DATA      => open              , -- Out :
            P_VAL       => open              , -- Out :
            O_DATA      => i_data (SIZE_HI downto SIZE_LO),
            O_VAL       => i_valid(VALID_POS), -- Out :
            O_RDY       => i_ready             -- In  :
        );                                     -- 
    ------------------------------------------------------------------------------
    -- i_data(LAST_POS) : I_LAST信号を SYNCRONIZER の I_DATA に入力する.
    ------------------------------------------------------------------------------
    I_LAST_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER
        generic map (                          --
            DATA_BITS   => 1                 , -- 
            OPERATION   => 1                   -- 
        )                                      -- 
        port map (                             -- 
            CLK         => I_CLK             , -- In  :
            RST         => RST               , -- In  :
            CLR         => I_CLR             , -- In  :
            I_DATA(0)   => I_LAST            , -- In  :
            I_VAL       => I_VAL             , -- In  :
            I_PAUSE     => i_pause           , -- In  :
            P_DATA      => open              , -- Out :
            P_VAL       => open              , -- Out :
            O_DATA(0)   => i_data (LAST_POS) , -- Out :
            O_VAL       => open              , -- Out :
            O_RDY       => i_ready             -- In  :
        );                                     -- 
    ------------------------------------------------------------------------------
    -- SYNC : 入力側と出力側で同期をとるモジュール
    ------------------------------------------------------------------------------
    SYNC: SYNCRONIZER
        generic map (                          --
            DATA_BITS   => i_data 'length    , --
            VAL_BITS    => i_valid'length    , --
            I_CLK_RATE  => I_CLK_RATE        , --
            O_CLK_RATE  => O_CLK_RATE        , --
            I_CLK_FLOP  => 1                 , --
            O_CLK_FLOP  => 1                 , --
            I_CLK_FALL  => 0                 , --
            O_CLK_FALL  => 0                 , --
            O_CLK_REGS  => 0                   --
        )                                      -- 
        port map (                             -- 
            RST         => RST               , -- In  :
            I_CLK       => I_CLK             , -- In  :
            I_CLR       => I_CLR             , -- In  :
            I_CKE       => I_CKE             , -- In  :
            I_DATA      => i_data            , -- In  :
            I_VAL       => i_valid           , -- In  :
            I_RDY       => i_ready           , -- Out :
            O_CLK       => O_CLK             , -- In  :
            O_CLR       => O_CLR             , -- In  :
            O_CKE       => O_CKE             , -- In  :
            O_DATA      => o_data            , -- Out :
            O_VAL       => o_valid             -- Out :
        );                                     -- 
    ------------------------------------------------------------------------------
    -- O_SIZE : SYNCで同期をとった SIZE を指定したクロックだけ遅延させて出力
    -- O_LAST : SYNCで同期をとった LAST を指定したクロックだけ遅延させて出力
    ------------------------------------------------------------------------------
    O_SIZE_REGS: DELAY_REGISTER
        generic map (                          -- 
            DATA_BITS   => o_data'length     , -- 
            DELAY_MAX   => DELAY_CYCLE       , -- 
            DELAY_MIN   => DELAY_CYCLE         -- 
        )                                      --
        port map (                             -- 
            CLK         => O_CLK             , -- In  :
            RST         => RST               , -- In  :
            CLR         => O_CLR             , -- In  :
            SEL         => DELAY_SEL         , -- In  :
            D_VAL       => d_valid           , -- Out :
            I_DATA      => o_data            , -- In  :
            I_VAL       => o_valid(VALID_POS), -- In  :
            O_DATA      => d_data            , -- Out :
            O_VAL       => O_VAL               -- Out :
        );
    O_SIZE <= d_data(SIZE_HI downto SIZE_LO);
    O_LAST <= d_data(LAST_POS);
    ------------------------------------------------------------------------------
    -- o_close_val : SYNCで同期をとった i_clock_val を、O_SIZE/O_LASTに合わせて
    --               遅延させる.
    ------------------------------------------------------------------------------
    O_CLOSE_REGS: DELAY_ADJUSTER
        generic map (                          -- 
            DATA_BITS   => 1                 , -- 
            DELAY_MAX   => DELAY_CYCLE       , -- 
            DELAY_MIN   => DELAY_CYCLE         -- 
        )                                      --
        port map (                             -- 
            CLK         => O_CLK             , -- In  :
            RST         => RST               , -- In  :
            CLR         => O_CLR             , -- In  :
            SEL         => DELAY_SEL         , -- In  :
            D_VAL       => d_valid           , -- In  :
            I_DATA(0)   => sig0              , -- In  :
            I_VAL       => o_valid(CLOSE_POS), -- In  :
            O_DATA      => open              , -- Out :
            O_VAL       => o_close_val         -- Out :
        );
    ------------------------------------------------------------------------------
    -- o_open_val : SYNCで同期をとった i_open_val 信号.
    --              o_close_val とは異なり O_SIZE/O_LASTに合わせて遅延させない.
    ------------------------------------------------------------------------------
    o_open_val  <= '1' when (o_valid(OPEN_POS)  = '1') else '0';
    ------------------------------------------------------------------------------
    -- O_OPEN : 入力側のバルブが開いていることを示すフラグ.
    ------------------------------------------------------------------------------
    process (O_CLK, RST) begin
        if (RST = '1') then
                o_open_q <= '0';
        elsif (O_CLK'event and O_CLK = '1') then
            if    (O_CLR = '1' or o_close_val = '1') then
                o_open_q <= '0';
            elsif (o_open_val = '1') then
                o_open_q <= '1';
            end if;
        end if;
    end process;
    O_OPEN <= '1' when (o_open_q = '1' and o_close_val = '0') or
                       (o_open_val = '1') else '0';
end RTL;
