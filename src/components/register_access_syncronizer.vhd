-----------------------------------------------------------------------------------
--!     @file    register_access_syncronizer.vhd
--!     @brief   REGISTER ACCESS SYNCRONIZER MODULE :
--!              異なるクロックドメイン間でレジスタアクセスを中継するモジュール.
--!     @version 1.8.5
--!     @date    2021/5/18
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2014-2021 Ichiro Kawazome
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
--! @brief   REGISTER ACCESS SYNCRONIZER MODULE 
--!          異なるクロックドメイン間でレジスタアクセスを中継するモジュール.
--!        * 入力側のクロック(I_CLK)に同期化された入力データを 
--!          出力側クロック(O_CLK)に同期化して出力する.
--!        * 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)との関係は、
--!          ジェネリック変数I_CLK_RATEとO_CLK_RATEで指示する.
--!          詳細は O_CLK_RATE を参照.
-----------------------------------------------------------------------------------
entity  REGISTER_ACCESS_SYNCRONIZER is
    generic (
        ADDR_WIDTH  : --! @brief REGISTER ADDRESS WIDTH :
                      --! レジスタアクセスインターフェースのアドレスのビット幅を指
                      --! 定する.
                      integer := 32;
        DATA_WIDTH  : --! @brief REGISTER DATA WIDTH :
                      --! レジスタアクセスインターフェースのデータのビット幅を指定
                      --! する.
                      integer := 32;
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
        O_CLK_REGS  : --! @brief REGISTERD OUTPUT :
                      --! 出力側の各種信号(O_REQ/O_WRITE/O_WDATA/O_BEN)をレジスタ
                      --! 出力するかどうかを指定する.
                      --! * この変数は I_CLK_RATE > 0 の場合のみ有効. 
                      --!   I_CLK_RATE = 0 の場合は、常にレジスタ出力になる.
                      --! * O_CLK_REGS = 0 の場合はレジスタ出力しない.
                      --! * O_CLK_REGS = 1 の場合はレジスタ出力する.
                      integer range 0 to 1 :=  0
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号
    -------------------------------------------------------------------------------
        RST         : --! @brief RESET :
                      --! 非同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側のクロック信号/同期リセット信号
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
                      in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- 入力側のレジスタアクセスインターフェース
    -------------------------------------------------------------------------------
        I_REQ       : --! @brief INPUT REGISTER ACCESS REQUEST :
                      --! レジスタアクセス要求信号.
                      in  std_logic;
        I_SEL       : --! @brief INPUT REGISTER ACCESS SELECT :
                      --! レジスタアクセス選択信号.
                      --! * I_REQ='1'の際、この信号が'1'の時にのみレジスタアクセス
                      --!   を開始する.
                      in  std_logic := '1';
        I_WRITE     : --! @brief INPUT REGISTER WRITE ACCESS :
                      --! レジスタライトアクセス信号.
                      --! * この信号が'1'の時はライトアクセスを行う.
                      --! * この信号が'0'の時はリードアクセスを行う.
                      in  std_logic;
        I_ADDR      : --! @brief INPUT REGISTER ACCESS ADDRESS :
                      --! レジスタアクセスアドレス信号.
                      in  std_logic_vector(ADDR_WIDTH  -1 downto 0);
        I_BEN       : --! @brief INPUT REGISTER BYTE ENABLE :
                      --! レジスタアクセスバイトイネーブル信号.
                      in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
        I_WDATA     : --! @brief INPUT REGISTER ACCESS WRITE DATA :
                      --! レジスタアクセスライトデータ.
                      in  std_logic_vector(DATA_WIDTH  -1 downto 0);
        I_RDATA     : --! @brief INPUT REGISTER ACCESS READ DATA :
                      --! レジスタアクセスリードデータ.
                      out std_logic_vector(DATA_WIDTH  -1 downto 0);
        I_ACK       : --! @brief INPUT REGISTER ACCESS ACKNOWLEDGE :
                      --! レジスタアクセス応答信号.
                      out std_logic;
        I_ERR       : --! @brief INPUT REGISTER ACCESS ERROR ACKNOWLEDGE :
                      --! レジスタアクセスエラー応答信号.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側のクロック信号/同期リセット信号
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
                      in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- 出力側のレジスタアクセスインターフェース
    -------------------------------------------------------------------------------
        O_REQ       : --! @brief OUTNPUT REGISTER ACCESS REQUEST :
                      --! レジスタアクセス要求信号.
                      out std_logic;
        O_WRITE     : --! @brief OUTPUT REGISTER WRITE ACCESS :
                      --! レジスタライトアクセス信号.
                      --! * この信号が'1'の時はライトアクセスを行う.
                      --! * この信号が'0'の時はリードアクセスを行う.
                      out std_logic;
        O_ADDR      : --! @brief OUTPUT REGISTER ACCESS ADDRESS :
                      --! レジスタアクセスアドレス信号.
                      out std_logic_vector(ADDR_WIDTH  -1 downto 0);
        O_BEN       : --! @brief OUTPUT REGISTER BYTE ENABLE :
                      --! レジスタアクセスバイトイネーブル信号.
                      out std_logic_vector(DATA_WIDTH/8-1 downto 0);
        O_WDATA     : --! @brief OUTPUT REGISTER ACCESS WRITE DATA :
                      --! レジスタアクセスライトデータ.
                      out std_logic_vector(DATA_WIDTH  -1 downto 0);
        O_RDATA     : --! @brief OUTPUT REGISTER ACCESS READ DATA :
                      --! レジスタアクセスリードデータ.
                      in  std_logic_vector(DATA_WIDTH  -1 downto 0);
        O_ACK       : --! @brief OUTPUT REGISTER ACCESS ACKNOWLEDGE :
                      --! レジスタアクセス応答信号.
                      in  std_logic;
        O_ERR       : --! @brief OUTPUT REGISTER ACCESS ERROR ACKNOWLEDGE :
                      --! レジスタアクセスエラー応答信号.
                      in  std_logic
    );
end REGISTER_ACCESS_SYNCRONIZER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.SYNCRONIZER;
use     PIPEWORK.COMPONENTS.SYNCRONIZER_INPUT_PENDING_REGISTER;
architecture RTL of REGISTER_ACCESS_SYNCRONIZER is
    constant  I2O_WDATA_LO  :  integer := 0;
    constant  I2O_WDATA_HI  :  integer := I2O_WDATA_LO  + DATA_WIDTH   - 1;
    constant  I2O_BEN_LO    :  integer := I2O_WDATA_HI  + 1;
    constant  I2O_BEN_HI    :  integer := I2O_BEN_LO    + DATA_WIDTH/8 - 1;
    constant  I2O_ADDR_LO   :  integer := I2O_BEN_HI    + 1;
    constant  I2O_ADDR_HI   :  integer := I2O_ADDR_LO   + ADDR_WIDTH   - 1;
    constant  I2O_WRITE_POS :  integer := I2O_ADDR_HI   + 1;
    constant  I2O_BITS      :  integer := I2O_WRITE_POS - I2O_WDATA_LO + 1;
    signal    i2o_i_data    :  std_logic_vector(I2O_BITS-1 downto 0);
    signal    i2o_i_valid   :  std_logic;
    signal    i2o_i_ready   :  std_logic;
    signal    i2o_o_data    :  std_logic_vector(I2O_BITS-1 downto 0);
    signal    i2o_o_valid   :  std_logic;
    signal    o2i_i_rdata   :  std_logic_vector(DATA_WIDTH-1 downto 0);
    signal    o2i_i_valid   :  std_logic_vector(1 downto 0);
    signal    o2i_i_ready   :  std_logic;
    signal    o2i_o_rdata   :  std_logic_vector(DATA_WIDTH-1 downto 0);
    signal    o2i_o_valid   :  std_logic_vector(1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 入力側の制御回路
    -------------------------------------------------------------------------------
    I: block
        type     STATE_TYPE  is (IDLE_STATE, REQ_STATE, RUN_STATE);
        signal   curr_state  :  STATE_TYPE;
        signal   next_state  :  STATE_TYPE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (curr_state, I_REQ, I_SEL, i2o_i_ready, o2i_o_valid)
            variable request     : boolean;
            variable acknowledge : boolean;
        begin
            request     := (I_REQ = '1' and I_SEL = '1');
            acknowledge := (o2i_o_valid(0) = '1' or o2i_o_valid(1) = '1');
            case curr_state is
                when IDLE_STATE =>
                    if (request = TRUE) then
                        if    (acknowledge = TRUE) then
                            next_state <= IDLE_STATE;
                        elsif (i2o_i_ready = '1') then
                            next_state <= RUN_STATE;
                        else
                            next_state <= REQ_STATE;
                        end if;
                        i2o_i_valid <= '1';
                    else
                        next_state  <= IDLE_STATE;
                        i2o_i_valid <= '0';
                    end if;
                when REQ_STATE =>
                        if    (acknowledge = TRUE) then
                            next_state <= IDLE_STATE;
                        elsif (i2o_i_ready = '1' ) then
                            next_state <= RUN_STATE;
                        else
                            next_state <= REQ_STATE;
                        end if;
                        i2o_i_valid <= '1';
                when RUN_STATE =>
                        if    (acknowledge = TRUE) then
                            next_state <= IDLE_STATE;
                        else
                            next_state <= RUN_STATE;
                        end if;
                        i2o_i_valid <= '0';
                when others  =>
                        next_state  <= IDLE_STATE;
                        i2o_i_valid <= '0';
            end case;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (I_CLK, RST) begin
            if (RST = '1') then
                    curr_state <= IDLE_STATE;
            elsif (I_CLK'event and I_CLK = '1') then
                if (I_CLR = '1') then
                    curr_state <= IDLE_STATE;
                else
                    curr_state <= next_state;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        i2o_i_data(I2O_WDATA_HI downto I2O_WDATA_LO) <= I_WDATA;
        i2o_i_data(I2O_BEN_HI   downto I2O_BEN_LO  ) <= I_BEN;
        i2o_i_data(I2O_ADDR_HI  downto I2O_ADDR_LO ) <= I_ADDR;
        i2o_i_data(I2O_WRITE_POS                   ) <= I_WRITE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        I_RDATA <= o2i_o_rdata    when (I_SEL = '1') else (others => '0');
        I_ACK   <= o2i_o_valid(0) when (I_SEL = '1') else '0';
        I_ERR   <= o2i_o_valid(1) when (I_SEL = '1') else '0';
    end block;
    -------------------------------------------------------------------------------
    -- 入力側から出力側への同期回路
    -------------------------------------------------------------------------------
    I2O: SYNCRONIZER                     -- 
        generic map (                    -- 
            DATA_BITS   => I2O_BITS    , -- 
            VAL_BITS    => 1           , -- 
            I_CLK_RATE  => I_CLK_RATE  , -- 
            O_CLK_RATE  => O_CLK_RATE  , -- 
            I_CLK_FLOP  => 1           , -- 
            O_CLK_FLOP  => 1           , -- 
            I_CLK_FALL  => 0           , -- 
            O_CLK_FALL  => 0           , -- 
            O_CLK_REGS  => O_CLK_REGS    -- 
        )                                -- 
        port map (                       -- 
            RST         => RST         , -- In  :
            I_CLK       => I_CLK       , -- In  :
            I_CLR       => I_CLR       , -- In  :
            I_CKE       => I_CKE       , -- In  :
            I_DATA      => i2o_i_data  , -- In  :
            I_VAL(0)    => i2o_i_valid , -- In  :
            I_RDY       => i2o_i_ready , -- Out :
            O_CLK       => O_CLK       , -- In  :
            O_CLR       => O_CLR       , -- In  :
            O_CKE       => O_CKE       , -- In  :
            O_DATA      => i2o_o_data  , -- Out :
            O_VAL(0)    => i2o_o_valid   -- Out :
        );
    -------------------------------------------------------------------------------
    -- 出力側から入力側への同期回路
    -------------------------------------------------------------------------------
    O2I: SYNCRONIZER                     -- 
        generic map (                    -- 
            DATA_BITS   => DATA_WIDTH  , -- 
            VAL_BITS    => 2           , -- 
            I_CLK_RATE  => O_CLK_RATE  , -- 
            O_CLK_RATE  => I_CLK_RATE  , -- 
            I_CLK_FLOP  => 1           , -- 
            O_CLK_FLOP  => 1           , -- 
            I_CLK_FALL  => 0           , -- 
            O_CLK_FALL  => 0           , -- 
            O_CLK_REGS  => 0             -- 
        )                                -- 
        port map (                       -- 
            RST         => RST         , -- In  :
            I_CLK       => O_CLK       , -- In  :
            I_CLR       => O_CLR       , -- In  :
            I_CKE       => O_CKE       , -- In  :
            I_DATA      => o2i_i_rdata , -- In  :
            I_VAL       => o2i_i_valid , -- In  :
            I_RDY       => o2i_i_ready , -- Out :
            O_CLK       => I_CLK       , -- In  :
            O_CLR       => I_CLR       , -- In  :
            O_CKE       => I_CKE       , -- In  :
            O_DATA      => o2i_o_rdata , -- Out :
            O_VAL       => o2i_o_valid   -- Out :
        );
    -------------------------------------------------------------------------------
    -- 出力側の制御回路
    -------------------------------------------------------------------------------
    O: block
        constant pause       :  std_logic := '0';
        signal   req_pending :  boolean;
        signal   req_valid   :  boolean;
        signal   req_ready   :  boolean;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        req_valid <= (req_pending = FALSE and i2o_o_valid = '1') or
                     (req_pending = TRUE                       );
        req_ready <= (O_ACK = '1' or O_ERR = '1');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (O_CLK, RST) begin
            if (RST = '1') then
                    req_pending <= FALSE;
            elsif (O_CLK'event and O_CLK = '1') then
                if (O_CLR = '1') then
                    req_pending <= FALSE;
                else
                    req_pending <= (req_valid and not req_ready);
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        O_REQ   <= '1' when (req_valid) else '0';
        O_WDATA <= i2o_o_data(I2O_WDATA_HI downto I2O_WDATA_LO);
        O_BEN   <= i2o_o_data(I2O_BEN_HI   downto I2O_BEN_LO  );
        O_ADDR  <= i2o_o_data(I2O_ADDR_HI  downto I2O_ADDR_LO );
        O_WRITE <= i2o_o_data(I2O_WRITE_POS                   );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ACK_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER
            generic map (                      --
                DATA_BITS   => DATA_WIDTH    , -- 
                OPERATION   => 0               -- 
            )                                  -- 
            port map (                         -- 
                CLK         => O_CLK         , -- In  :
                RST         => RST           , -- In  :
                CLR         => O_CLR         , -- In  :
                I_DATA      => O_RDATA       , -- In  :
                I_VAL       => O_ACK         , -- In  :
                I_PAUSE     => pause         , -- In  :
                P_DATA      => open          , -- Out :
                P_VAL       => open          , -- Out :
                O_DATA      => o2i_i_rdata   , -- Out :
                O_VAL       => o2i_i_valid(0), -- Out :
                O_RDY       => o2i_i_ready     -- In  :
            );                                 -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ERR_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER
            generic map (                      --
                DATA_BITS   => 1             , -- 
                OPERATION   => 1               -- 
            )                                  -- 
            port map (                         -- 
                CLK         => O_CLK         , -- In  :
                RST         => RST           , -- In  :
                CLR         => O_CLR         , -- In  :
                I_DATA(0)   => O_ERR         , -- In  :
                I_VAL       => O_ERR         , -- In  :
                I_PAUSE     => pause         , -- In  :
                P_DATA      => open          , -- Out :
                P_VAL       => open          , -- Out :
                O_DATA      => open          , -- Out :
                O_VAL       => o2i_i_valid(1), -- Out :
                O_RDY       => o2i_i_ready     -- In  :
            );                                 -- 
    end block;
end RTL;
