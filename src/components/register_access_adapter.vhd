-----------------------------------------------------------------------------------
--!     @file    register_access_adapter.vhd
--!     @brief   REGISTER ACCESS ADAPTER MODULE :
--!              レジスタアクセスアダプタ.
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
--! @brief   REGISTER ACCESS ADAPTER MODULE 
-----------------------------------------------------------------------------------
entity  REGISTER_ACCESS_ADAPTER is
    generic (
        ADDR_WIDTH  : --! @brief REGISTER ADDRESS WIDTH :
                      --! レジスタアクセスインターフェースのアドレスのビット幅を指
                      --! 定する.
                      integer := 8;
        DATA_WIDTH  : --! @brief REGISTER DATA WIDTH :
                      --! レジスタアクセスインターフェースのデータのビット幅を指定
                      --! する.
                      integer := 32;
        WBIT_MIN    : --! @brief REGISTER WRITE BIT MIN INDEX :
                      integer := 0;
        WBIT_MAX    : --! @brief REGISTER WRITE BIT MAX INDEX :
                      integer := (2**8)*8-1;
        RBIT_MIN    : --! @brief REGISTER READ  BIT MIN INDEX :
                      integer := 0;
        RBIT_MAX    : --! @brief REGISTER READ  BIT MAX INDEX :
                      integer := (2**8)*8-1;
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
        I_REQ       : --! @brief REGISTER ACCESS REQUEST :
                      --! レジスタアクセス要求信号.
                      in  std_logic;
        I_SEL       : --! @brief INPUT REGISTER ACCESS SELECT :
                      --! レジスタアクセス選択信号.
                      --! * I_REQ='1'の際、この信号が'1'の時にのみレジスタアクセス
                      --!   を開始する.
                      in  std_logic := '1';
        I_WRITE     : --! @brief REGISTER WRITE ACCESS :
                      --! レジスタライトアクセス信号.
                      --! * この信号が'1'の時はライトアクセスを行う.
                      --! * この信号が'0'の時はリードアクセスを行う.
                      in  std_logic;
        I_ADDR      : --! @brief REGISTER ACCESS ADDRESS :
                      --! レジスタアクセスアドレス信号.
                      in  std_logic_vector(ADDR_WIDTH  -1 downto 0);
        I_BEN       : --! @brief REGISTER BYTE ENABLE :
                      --! レジスタアクセスバイトイネーブル信号.
                      in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
        I_WDATA     : --! @brief REGISTER ACCESS WRITE DATA :
                      --! レジスタアクセスライトデータ.
                      in  std_logic_vector(DATA_WIDTH  -1 downto 0);
        I_RDATA     : --! @brief REGISTER ACCESS READ DATA :
                      --! レジスタアクセスリードデータ.
                      out std_logic_vector(DATA_WIDTH  -1 downto 0);
        I_ACK       : --! @brief REGISTER ACCESS ACKNOWLEDGE :
                      --! レジスタアクセス応答信号.
                      out std_logic;
        I_ERR       : --! @brief REGISTER ACCESS ERROR ACKNOWLEDGE :
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
    -- レジスタライトデータ/ロード出力
    -------------------------------------------------------------------------------
        O_WDATA     : out std_logic_vector(WBIT_MAX downto WBIT_MIN);
        O_WLOAD     : out std_logic_vector(WBIT_MAX downto WBIT_MIN);
    -------------------------------------------------------------------------------
    -- レジスタリードデータ入力
    -------------------------------------------------------------------------------
        O_RENAB     : out std_logic_vector(RBIT_MAX downto RBIT_MIN);
        O_RDATA     : in  std_logic_vector(RBIT_MAX downto RBIT_MIN)
    );
end REGISTER_ACCESS_ADAPTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.REGISTER_ACCESS_SYNCRONIZER;
use     PIPEWORK.COMPONENTS.REGISTER_ACCESS_DECODER;
architecture RTL of REGISTER_ACCESS_ADAPTER is
    signal   regs_req   : std_logic;
    signal   regs_write : std_logic;
    signal   regs_addr  : std_logic_vector(I_ADDR 'range);
    signal   regs_ben   : std_logic_vector(I_BEN  'range);
    signal   regs_wdata : std_logic_vector(I_WDATA'range);
    signal   regs_rdata : std_logic_vector(I_RDATA'range);
    signal   regs_ack   : std_logic;
    signal   regs_err   : std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    SYNC: REGISTER_ACCESS_SYNCRONIZER    -- 
        generic map (                    -- 
            ADDR_WIDTH  => ADDR_WIDTH  , -- 
            DATA_WIDTH  => DATA_WIDTH  , -- 
            I_CLK_RATE  => I_CLK_RATE  , -- 
            O_CLK_RATE  => O_CLK_RATE  , -- 
            O_CLK_REGS  => O_CLK_REGS    -- 
        )                                -- 
        port map (                       -- 
            RST         => RST         , -- In  :
            I_CLK       => I_CLK       , -- In  :
            I_CLR       => I_CLR       , -- In  :
            I_CKE       => I_CKE       , -- In  :
            I_REQ       => I_REQ       , -- In  :
            I_SEL       => I_SEL       , -- In  :
            I_WRITE     => I_WRITE     , -- In  :
            I_ADDR      => I_ADDR      , -- In  :
            I_BEN       => I_BEN       , -- In  :
            I_WDATA     => I_WDATA     , -- In  :
            I_RDATA     => I_RDATA     , -- Out :
            I_ACK       => I_ACK       , -- Out :
            I_ERR       => I_ERR       , -- Out :
            O_CLK       => O_CLK       , -- In  :
            O_CLR       => O_CLR       , -- In  :
            O_CKE       => O_CKE       , -- In  :
            O_REQ       => regs_req    , -- Out :
            O_WRITE     => regs_write  , -- Out :
            O_ADDR      => regs_addr   , -- Out :
            O_BEN       => regs_ben    , -- Out :
            O_WDATA     => regs_wdata  , -- Out :
            O_RDATA     => regs_rdata  , -- In  :
            O_ACK       => regs_ack    , -- In  :
            O_ERR       => regs_err      -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DEC: REGISTER_ACCESS_DECODER         -- 
        generic map (                    -- 
            ADDR_WIDTH  => ADDR_WIDTH  , --
            DATA_WIDTH  => DATA_WIDTH  , --
            WBIT_MIN    => WBIT_MIN    , --
            WBIT_MAX    => WBIT_MAX    , --
            RBIT_MIN    => RBIT_MIN    , --
            RBIT_MAX    => RBIT_MAX      --
        )                                -- 
        port map (                       -- 
            REGS_REQ    => regs_req    , -- In  :
            REGS_WRITE  => regs_write  , -- In  :
            REGS_ADDR   => regs_addr   , -- In  :
            REGS_BEN    => regs_ben    , -- In  :
            REGS_WDATA  => regs_wdata  , -- In  :
            REGS_RDATA  => regs_rdata  , -- Out :
            REGS_ACK    => regs_ack    , -- Out :
            REGS_ERR    => regs_err    , -- Out :
            W_DATA      => O_WDATA     , -- Out :
            W_LOAD      => O_WLOAD     , -- Out :
            R_ENAB      => O_RENAB     , -- Out :
            R_DATA      => O_RDATA       -- In  :
        );
end RTL;
