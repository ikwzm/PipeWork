-----------------------------------------------------------------------------------
--!     @file    queue_arbiter.vhd
--!     @brief   QUEUE ARBITER MODULE :
--!              キュータイプをツリー構造にした調停回路
--!     @version 1.8.3
--!     @date    2020/10/13
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2020 Ichiro Kawazome
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
--! @brief   QUEUE TREE ARBITER :
--!          キュー(ファーストインファーストアウト)方式をツリー構造にした調停回路.
--!        * 要求を到着順に許可することを特徴とする調停回路.
--!        * キュー方式が他の一般的な固定優先順位方式やラウンドロビン方式に比べて
--!          有利な点は次の二つ.
--!          * 必ず要求はいつかは許可されることが保証されている.
--!            固定優先順位方式の場合、場合によっては永久に要求が許可されることが
--!            ないことが起り得るが、キュー方式はそれがない.
--!          * 要求された順番が変わることがない.
--!            用途によっては順番が変わることで誤動作する場合があるが、
--!            キュー方式ではそれに対応できる.
--!        * 一般的な固定優先順位方式やラウンドロビン方式の調停回路と異なり、
--!          要求が到着した順番を記録しているため、
--!          回路規模は他の方式に比べて大きい傾向がある.
-----------------------------------------------------------------------------------
entity  QUEUE_TREE_ARBITER is
    generic (
        MIN_NUM     : --! @brief REQUEST MINIMUM NUMBER :
                      --! リクエストの最小番号を指定する.
                      integer := 0;
        MAX_NUM     : --! @brief REQUEST MAXIMUM NUMBER :
                      --! リクエストの最大番号を指定する.
                      integer := 7;
        NODE_NUM    : --! @brief MAX TREE NODE SIZE :
                      --! ノードの最大リクエスト数を指定する.
                      --! (MAX_NUM-MIN_NUM+1) > NODE_NUM の時、ツリー構造にする.
                      integer := 8;
        PIPELINE    : --! @brief PIPELINE CONTROL:
                      --! 各ノードの出力をレジスタ出力にすることを指定する.
                      --! PIPELINE mod 2 = 1 の時レジスタ出力にする.
                      --! ツリーの子ノードへは PIPELINE/2 の値を渡す.
                      integer := 0
    );
    port (
        CLK         : --! @brief CLOCK :
                      --! クロック信号
                      in  std_logic; 
        RST         : --! @brief ASYNCRONOUSE RESET :
                      --! 非同期リセット信号.アクティブハイ.
                      in  std_logic;
        CLR         : --! @brief SYNCRONOUSE RESET :
                      --! 同期リセット信号.アクティブハイ.
                      in  std_logic;
        ENABLE      : --! @brief ARBITORATION ENABLE :
                      --! この調停回路を有効にするかどうかを指定する.
                      --! * 幾つかの調停回路を組み合わせて使う場合、設定によっては
                      --!  この調停回路の出力を無効にしたいことがある.
                      --!  その時はこの信号を'0'にすることで簡単に出来る.
                      --! * ENABLE='1'でこの回路は調停を行う.
                      --! * ENABLE='0'でこの回路は調停を行わない.
                      --!   この場合REQUEST信号に関係なREQUEST_OおよびGRANTは'0'になる.
                      --!   リクエストキューの中身は破棄される.
                      in  std_logic := '1';
        REQUEST     : --! @brief REQUEST INPUT :
                      --! リクエスト入力.
                      in  std_logic_vector(MIN_NUM to MAX_NUM);
        GRANT       : --! @brief GRANT OUTPUT :
                      --! 調停結果出力.
                      out std_logic_vector(MIN_NUM to MAX_NUM);
        VALID       : --! @brief REQUEST QUEUE VALID :
                      --! リクエストキューに次の要求があることを示す信号.
                      --! * REQUEST_Oと異なり、リスエストキューに次の要求があると
                      --!   対応するREQUEST信号の状態に関わらずアサートされる.
                      out std_logic;
        SHIFT       : --! @brief REQUEST QUEUE SHIFT :
                      --! リクエストキューの先頭からリクエストを取り除く信号.
                      in  std_logic
    );
end     QUEUE_TREE_ARBITER;
library ieee;
use     ieee.std_logic_1164.all;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
architecture RTL of QUEUE_TREE_ARBITER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function MIN(A,B:integer) return integer is
    begin
        if (A < B) then return A;
        else            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  REQ_NUM       :  integer := (MAX_NUM - MIN_NUM  + 1);
    constant  REQ_MIN_NUM   :  integer := 0;
    constant  REQ_MAX_NUM   :  integer := REQ_NUM - 1;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  ARB_NUM       :  integer := MIN(REQ_NUM, NODE_NUM);
    constant  ARB_MIN_NUM   :  integer := 0;
    constant  ARB_MAX_NUM   :  integer := ARB_NUM - 1;
    signal    arb_request   :  std_logic_vector(ARB_MIN_NUM to ARB_MAX_NUM);
    signal    arb_grant     :  std_logic_vector(ARB_MIN_NUM to ARB_MAX_NUM);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    next_request  :  std_logic;
    signal    next_valid    :  std_logic;
    signal    next_grant    :  std_logic_vector(REQ_MIN_NUM to REQ_MAX_NUM);
    signal    node_shift    :  std_logic_vector(ARB_MIN_NUM to ARB_MAX_NUM);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component QUEUE_TREE_ARBITER is
        generic (
            MIN_NUM     : integer := 0;
            MAX_NUM     : integer := 7;
            NODE_NUM    : integer := 8;
            PIPELINE    : integer := 0
        );
        port (
            CLK         : in  std_logic; 
            RST         : in  std_logic;
            CLR         : in  std_logic;
            ENABLE      : in  std_logic := '1';
            REQUEST     : in  std_logic_vector(MIN_NUM to MAX_NUM);
            GRANT       : out std_logic_vector(MIN_NUM to MAX_NUM);
            VALID       : out std_logic;
            SHIFT       : in  std_logic
        );
    end component;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component QUEUE_ARBITER is
        generic (
            MIN_NUM     : integer := 0;
            MAX_NUM     : integer := 7
        );
        port (
            CLK         : in  std_logic; 
            RST         : in  std_logic;
            CLR         : in  std_logic;
            ENABLE      : in  std_logic := '1';
            REQUEST     : in  std_logic_vector(MIN_NUM to MAX_NUM);
            GRANT       : out std_logic_vector(MIN_NUM to MAX_NUM);
            GRANT_NUM   : out integer   range  MIN_NUM to MAX_NUM;
            REQUEST_O   : out std_logic;
            VALID       : out std_logic;
            SHIFT       : in  std_logic
        );
    end component;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    TREE: if (REQ_NUM > ARB_NUM) generate
        constant  NODE_STEP     :  integer := (REQ_NUM + NODE_NUM - 1) / NODE_NUM;
        signal    i_request     :  std_logic_vector(0 to NODE_NUM*NODE_STEP-1);
        signal    o_grant       :  std_logic_vector(0 to NODE_NUM*NODE_STEP-1);
        function  SORT_REQUEST(REQ: std_logic_vector) return std_logic_vector is
            alias    i_req : std_logic_vector(0 to REQ_NUM-1) is REQ;
            variable o_req : std_logic_vector(0 to NODE_NUM*NODE_STEP-1);
        begin
            for i in o_req'range loop
                if ((((i mod NODE_STEP) * NODE_NUM) + (i / NODE_STEP)) <= i_req'high) then
                    o_req(i) := i_req(((i mod NODE_STEP) * NODE_NUM) + (i / NODE_STEP));
                else
                    o_req(i) := '0';
                end if;
            end loop;
            return o_req;
        end function;
        function  SORT_GRANT(GNT: std_logic_vector) return std_logic_vector is
            alias    i_gnt : std_logic_vector(0 to NODE_NUM*NODE_STEP-1) is GNT;
            variable o_gnt : std_logic_vector(0 to REQ_NUM-1);
        begin
            for i in i_gnt'range loop
                if ((((i mod NODE_STEP) * NODE_NUM) + (i / NODE_STEP)) <= o_gnt'high) then
                    o_gnt(((i mod NODE_STEP) * NODE_NUM) + (i / NODE_STEP)) := i_gnt(i);
                end if;
            end loop;
            return o_gnt;
        end function;
    begin
        i_request <= SORT_REQUEST(REQUEST);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        NODE: for i in 0 to NODE_NUM-1 generate
            constant  NODE_MIN_NUM  :  integer := i*NODE_STEP;
            constant  NODE_MAX_NUM  :  integer := NODE_MIN_NUM + NODE_STEP - 1;
            signal    node_request  :  std_logic_vector(NODE_MIN_NUM to NODE_MAX_NUM);
            signal    node_grant    :  std_logic_vector(NODE_MIN_NUM to NODE_MAX_NUM);
        begin
            node_request <= i_request(NODE_MIN_NUM to NODE_MAX_NUM);
            ARB: QUEUE_TREE_ARBITER                  -- 
                generic map (                        -- 
                    MIN_NUM     => NODE_MIN_NUM    , --
                    MAX_NUM     => NODE_MAX_NUM    , --
                    NODE_NUM    => NODE_NUM        , --
                    PIPELINE    => PIPELINE/2        --
                )                                    -- 
                port map (                           -- 
                    CLK         => CLK             , -- In  :
                    RST         => RST             , -- In  :
                    CLR         => CLR             , -- In  :
                    ENABLE      => ENABLE          , -- In  :
                    REQUEST     => node_request    , -- In  :
                    GRANT       => node_grant      , -- Out :
                    VALID       => arb_request (i) , -- Out :
                    SHIFT       => node_shift  (i)   -- In  :
                );
            o_grant(NODE_MIN_NUM to NODE_MAX_NUM) <= node_grant when (arb_grant(i) ='1') else
                                                     (others => '0');
        end generate;
        next_grant <= SORT_GRANT(o_grant);
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    LEAF: if (REQ_NUM = ARB_NUM) generate
        arb_request <= REQUEST;
        next_grant  <= arb_grant;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ARB: QUEUE_ARBITER                   -- 
        generic map (                    -- 
            MIN_NUM     => ARB_MIN_NUM,  --
            MAX_NUM     => ARB_MAX_NUM   --
        )                                -- 
        port map (                       -- 
            CLK         => CLK         , -- In  :
            RST         => RST         , -- In  :
            CLR         => CLR         , -- In  :
            ENABLE      => ENABLE      , -- In  :
            REQUEST     => arb_request , -- In  :
            GRANT       => arb_grant   , -- Out :
            GRANT_NUM   => open        , -- Out :
            REQUEST_O   => next_request, -- Out :
            VALID       => next_valid  , -- Out :
            SHIFT       => SHIFT         -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_REGS: if (PIPELINE mod 2 = 1) generate
        type      STATE_TYPE        is (IDLE_STATE, REQ_STATE);
        signal    curr_state        :  STATE_TYPE;
        signal    curr_arb_grant    :  std_logic_vector(ARB_MIN_NUM to ARB_MAX_NUM);
    begin
        process(CLK, RST) begin
            if (RST = '1') then
                    curr_state     <= IDLE_STATE;
                    VALID          <= '0';
                    GRANT          <= (others => '0');
                    curr_arb_grant <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_state     <= IDLE_STATE;
                    VALID          <= '0';
                    GRANT          <= (others => '0');
                    curr_arb_grant <= (others => '0');
                else
                    case curr_state is
                        when IDLE_STATE =>
                            if (next_valid = '1') then
                                curr_state     <= REQ_STATE;
                                curr_arb_grant <= arb_grant;
                                VALID          <= '1';
                                GRANT          <= next_grant;
                            else
                                curr_state     <= IDLE_STATE;
                                curr_arb_grant <= (others => '0');
                                VALID          <= '0';
                                GRANT          <= (others => '0');
                            end if;
                        when REQ_STATE =>
                            if (SHIFT = '1') then
                                curr_state     <= IDLE_STATE;
                                curr_arb_grant <= (others => '0');
                                VALID          <= '0';
                                GRANT          <= (others => '0');
                            else
                                curr_state     <= REQ_STATE;
                                VALID          <= '1';
                            end if;
                        when others =>
                                curr_state     <= IDLE_STATE;
                                curr_arb_grant <= (others => '0');
                                VALID          <= '0';
                                GRANT          <= (others => '0');
                    end case;
                end if;
            end if;
        end process;
        node_shift <= curr_arb_grant when (curr_state = REQ_STATE and SHIFT = '1') else (others => '0');
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_COMB: if (PIPELINE mod 2 = 0) generate
        VALID      <= next_valid;
        GRANT      <= next_grant;
        node_shift <= arb_grant when (SHIFT = '1') else (others => '0');
    end generate;
    
end RTL;
