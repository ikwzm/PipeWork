-----------------------------------------------------------------------------------
--!     @file    pool_intake_port.vhd
--!     @brief   POOL INTAKE PORT
--!     @version 2.0.0
--!     @date    2024/2/19
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2024 Ichiro Kawazome
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
--! @brief   POOL INTAKE PORT
-----------------------------------------------------------------------------------
entity  POOL_INTAKE_PORT is
    generic (
        UNIT_BITS       : --! @brief UNIT BITS :
                          --! イネーブル信号(PORT_DVAL,POOL_DVAL)、
                          --! ポインタ(POOL_PTR)のサイズカウンタ(PUSH_SIZE)の
                          --! 基本単位をビット数で指定する.
                          --! 普通はUNIT_BITS=8(８ビット単位)にしておく.
                          integer := 8;
        WORD_BITS       : --! @brief WORD BITS :
                          --! １ワードのデータのビット数を指定する.
                          integer := 8;
        PORT_DATA_BITS  : --! @brief INTAKE PORT DATA BITS :
                          --! PORT_DATA のビット数を指定する.
                          integer := 32;
        POOL_DATA_BITS  : --! @brief POOL BUFFER DATA BITS :
                          --! POOL_DATA のビット数を指定する.
                          integer := 32;
        SEL_BITS        : --! @brief SELECT BITS :
                          --! XFER_SEL、PUSH_VAL、POOL_WEN のビット数を指定する.
                          integer := 1;
        SIZE_BITS       : --! @brief POOL_SIZE BITS :
                          --! POOL_SIZE のビット数を指定する.
                          integer := 16;
        PTR_BITS        : --! @brief POOL BUFFER POINTER BITS:
                          --! START_PTR、POOL_PTR のビット数を指定する.
                          integer := 16;
        QUEUE_SIZE      : --! @brief QUEUE SIZE :
                          --! キューの大きさをワード数で指定する.
                          --! * QUEUE_SIZE=0を指定した場合は、キューの深さは自動的に
                          --!   (PORT_DATA_BITS/WORD_BITS)+(POOL_DATA_BITS/WORD_BITS)
                          --!   に設定される.
                          integer := 0;
        PORT_PIPELINE   : --! @brief PORT PIPELINE STAGE SIZE :
                          --! 入力 PORT 側のパイプラインの段数を指定する.
                          --! * 後述の PORT_JUSTIFIED が 0 の場合は、入力 PORT 側
                          --!   の有効なデータを LOW 側に詰る必要があるが、その際に
                          --!   遅延時間が増大して動作周波数が上らないことがある.
                          --!   そのような場合は PORT_PIPELINE に 1 以上を指定して
                          --!   パイプライン化すると動作周波数が向上する可能性がある.
                          integer := 0;
        PORT_JUSTIFIED  : --! @brief PORT INPUT JUSTIFIED :
                          --! 入力 PORT 側の有効なデータが常にLOW側に詰められている
                          --! ことを示すフラグ.
                          --! * 常にLOW側に詰められている場合は 1 を指定する.
                          --! * 常にLOW側に詰められている場合は、シフタが必要なくな
                          --!   るため回路が簡単になる.
                          integer range 0 to 1 := 0
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
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
        START           : --! @brief START :
                          --! 開始信号.
                          --! * この信号はSTART_PTR/XFER_LAST/XFER_SELを内部に設定
                          --!   してこのモジュールを初期化しする.
                          --! * 最初にデータ入力と同時にアサートしても構わない.
                          in  std_logic;
        START_PTR       : --! @brief START POOL BUFFER POINTER :
                          --! 書き込み開始ポインタ.
                          --! START 信号により内部に取り込まれる.
                          in  std_logic_vector(PTR_BITS-1 downto 0);
        XFER_LAST       : --! @brief TRANSFER LAST :
                          --! 最後のトランザクションであることを示すフラグ.
                          --! START 信号により内部に取り込まれる.
                          in  std_logic;
        XFER_SEL        : --! @brief TRANSFER SELECT :
                          --! 選択信号. PUSH_VAL、POOL_WENの生成に使う.
                          --! START 信号により内部に取り込まれる.
                          in  std_logic_vector(SEL_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Port Signals.
    -------------------------------------------------------------------------------
        PORT_ENABLE     : --! @brief INTAKE PORT ENABLE :
                          --! 動作許可信号.
                          --! * この信号がアサートされた１クロック後から、キューへの入力を開始
                          --!   する(その際キューが入力可能ならばPORT_RDY信号をアサートする).
                          --! * この信号がネゲートされた１クロック後から、キューへの入力を停止
                          --!   する(その際キューの状態に拘わらずPORT_RDY信号をネゲートする).
                          in  std_logic := '1';
        PORT_DATA       : --! @brief INTAKE PORT DATA :
                          --! ワードデータ入力.
                          in  std_logic_vector(PORT_DATA_BITS-1 downto 0);
        PORT_DVAL       : --! @brief INTAKE PORT DATA VALID :
                          --! ポートからデータを入力する際のユニット単位での有効信号.
                          in  std_logic_vector(PORT_DATA_BITS/UNIT_BITS-1 downto 0);
        PORT_ERROR      : --! @brief INTAKE PORT ERROR :
                          --! データ入力中にエラーが発生したことを示すフラグ.
                          in  std_logic;
        PORT_LAST       : --! @brief INTAKE DATA LAST :
                          --! 最終ワード信号入力.
                          --! * 最後のワードデータ入力であることを示すフラグ.
                          in  std_logic;
        PORT_VAL        : --! @brief INTAKE PORT VALID :
                          --! 入力ワード有効信号.
                          --! * PORT_DATA/PORT_DVAL/PORT_LAST/PORT_ERRが有効であることを示す.
                          --! * PORT_VAL='1'and PORT_RDY='1'で上記信号がキューに取り込まれる.
                          in  std_logic;
        PORT_RDY        : --! @brief INTAKE PORT READY :
                          --! 入力レディ信号.
                          --! * キューが次のワードデータを入力出来ることを示す.
                          --! * PORT_VAL='1'and PORT_RDY='1'で上記信号がキューに取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VAL        : --! @brief PUSH VALID: 
                          --! PUSH_LAST/PUSH_ERROR/PUSH_SIZEが有効であることを示す信号.
                          out std_logic_vector(SEL_BITS-1 downto 0);
        PUSH_LAST       : --! @brief PUSH LAST : 
                          --! 最後の転送"した"ワードであることを示すフラグ.
                          out std_logic;
        PUSH_XFER_LAST  : --! @brief PUSH TRANSFER LAST :
                          --! 最後のトランザクションであることを示すフラグ.
                          out std_logic;
        PUSH_XFER_DONE  : --! @brief PUSH TRANSFER DONE :
                          --! 最後のトランザクションの最後の転送"した"ワードである
                          --! ことを示すフラグ.
                          out std_logic;
        PUSH_ERROR      : --! @brief PUSH ERROR : 
                          --! 転送"した事"がエラーだった事を示すフラグ.
                          out std_logic;
        PUSH_SIZE       : --! @brief PUSH SIZE :
                          --! 転送"した"バイト数を出力する.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pool Buffer Interface Signals.
    -------------------------------------------------------------------------------
        POOL_WEN        : --! @brief POOL BUFFER WRITE ENABLE :
                          --! バッファにデータをライトすることを示す.
                          out std_logic_vector(SEL_BITS-1 downto 0);
        POOL_DVAL       : --! @brief POOL BUFFER DATA VALID :
                          --! バッファにデータをライトする際のユニット単位での有効
                          --! 信号.
                          --! * POOL_WEN='1'の場合にのみ有効.
                          --! * POOL_WEN='0'の場合のこの信号の値は不定.
                          out std_logic_vector(POOL_DATA_BITS/UNIT_BITS-1 downto 0);
        POOL_DATA       : --! @brief POOL BUFFER WRITE DATA :
                          --! バッファへライトするデータを出力する.
                          out std_logic_vector(POOL_DATA_BITS-1 downto 0);
        POOL_PTR        : --! @brief POOL BUFFER WRITE POINTER :
                          --! ライト時にデータを書き込むバッファの位置を出力する.
                          out std_logic_vector(PTR_BITS-1 downto 0);
        POOL_RDY        : --! @brief POOL BUFFER WRITE READY :
                          --! バッファにデータを書き込み可能な事をを示す.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Status Signals.
    -------------------------------------------------------------------------------
        BUSY            : --! @brief QUEUE BUSY :
                          --! キューが動作中であることを示す信号.
                          --! * 最初にデータが入力されたときにアサートされる.
                          --! * 最後のデータが出力し終えたらネゲートされる.
                          out  std_logic
    );
end POOL_INTAKE_PORT;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.REDUCER;
use     PIPEWORK.COMPONENTS.JUSTIFIER;
architecture RTL of POOL_INTAKE_PORT is
    constant STRB_BITS      : integer   := (WORD_BITS/UNIT_BITS);
    constant PORT_WORDS     : integer   := (PORT_DATA'length/WORD_BITS);
    constant POOL_WORDS     : integer   := (POOL_DATA'length/WORD_BITS);
    constant pool_shift     : std_logic_vector(POOL_WORDS downto POOL_WORDS) := "0";
    signal   pool_offset    : std_logic_vector(POOL_WORDS-1 downto 0);
    signal   queue_enable   : std_logic;
    signal   queue_busy     : std_logic;
    signal   port_strb      : std_logic_vector(PORT_WORDS*STRB_BITS-1 downto 0);
    signal   port_ready     : std_logic;
    signal   i_busy         : std_logic;
    signal   i_done         : std_logic;
    signal   i_enable       : std_logic;
    signal   i_data         : std_logic_vector(PORT_WORDS*WORD_BITS-1 downto 0);
    signal   i_strb         : std_logic_vector(PORT_WORDS*STRB_BITS-1 downto 0);
    signal   i_last         : std_logic;
    signal   i_valid        : std_logic;
    signal   i_ready        : std_logic;
    constant o_enable       : std_logic := '1';
    signal   o_size         : std_logic_vector(PUSH_SIZE'length-1 downto 0);
    signal   o_strobe       : std_logic_vector(POOL_DVAL'length-1 downto 0);
    signal   o_error        : std_logic;
    signal   o_last         : std_logic;
    signal   o_valid        : std_logic;
    signal   o_ready        : std_logic;
    signal   i_xfer_last    : std_logic;
    signal   i_xfer_select  : std_logic_vector(SEL_BITS-1 downto 0);
    signal   o_xfer_last    : std_logic;
    signal   o_xfer_select  : std_logic_vector(SEL_BITS-1 downto 0);
    signal   write_ptr      : unsigned(PTR_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- i_xfer_last   : XFER_LAST を START 信号で一旦保存する.
    -- i_xfer_select : XFER_SEL  を START 信号で一旦保存する.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                i_xfer_last   <= '0';
                i_xfer_select <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                i_xfer_last   <= '0';
                i_xfer_select <= (others => '0');
            elsif (START = '1') then
                i_xfer_last   <= XFER_LAST;
                i_xfer_select <= XFER_SEL;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- offset        : REDUCER にセットするオフセット値.
    -------------------------------------------------------------------------------
    process (START_PTR)
        function CALC_WIDTH(BITS:integer) return integer is
            variable value : integer;
        begin
            value := 0;
            while (2**value < (BITS/UNIT_BITS)) loop
                value := value + 1;
            end loop;
            return value;
        end function;
        constant O_DATA_WIDTH : integer := CALC_WIDTH(POOL_WORDS*WORD_BITS);
        constant WORD_WIDTH   : integer := CALC_WIDTH(WORD_BITS);
        variable u_offset     : unsigned(O_DATA_WIDTH-WORD_WIDTH downto 0);
    begin
        for i in u_offset'range loop
            if (i+WORD_WIDTH <  O_DATA_WIDTH  ) and
               (i+WORD_WIDTH <= START_PTR'high) and
               (i+WORD_WIDTH >= START_PTR'low ) then
                if (START_PTR(i+WORD_WIDTH) = '1') then
                    u_offset(i) := '1';
                else
                    u_offset(i) := '0';
                end if;
            else
                    u_offset(i) := '0';
            end if;
        end loop;
        for i in pool_offset'range loop
            if (i < u_offset) then
                pool_offset(i) <= '1';
            else
                pool_offset(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- port_strb     : エラー発生時はキューにデータを入れないようにする.
    -------------------------------------------------------------------------------
    port_strb <= PORT_DVAL when (PORT_ERROR = '0') else (others => '0');
    -------------------------------------------------------------------------------
    -- i_enable      : データ入力を許可するための信号. PORT_RDY の生成に関与する.
    -------------------------------------------------------------------------------
    PORT_PIPELINE_EQ_0 : if (PORT_PIPELINE = 0) generate
        i_enable     <= '1';
        queue_enable <= PORT_ENABLE;
    end generate;
    PORT_PIPELINE_GT_0 : if (PORT_PIPELINE > 0) generate
        process(CLK, RST) begin
            if (RST = '1') then
                    i_enable <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    i_enable <= '0';
                else
                    i_enable <= PORT_ENABLE;
                end if;
            end if;
        end process;
        queue_enable <= '1' when (PORT_ENABLE = '1') or
                                 (i_busy = '1' and i_done = '0') else '0';
    end generate;
    -------------------------------------------------------------------------------
    -- 入力データの前処理
    -------------------------------------------------------------------------------
    JUST: JUSTIFIER                             -- 
        generic map (                           -- 
            WORD_BITS       => WORD_BITS      , -- 
            STRB_BITS       => STRB_BITS      , --
            INFO_BITS       => 1              , --
            WORDS           => PORT_WORDS     , -- 
            I_JUSTIFIED     => PORT_JUSTIFIED , --
            PIPELINE        => PORT_PIPELINE    --
        )                                       -- 
        port map (                              -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK            , -- In  :
            RST             => RST            , -- In  :
            CLR             => CLR            , -- In  :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_ENABLE        => i_enable       , -- In  :
            I_STRB          => port_strb      , -- In  :
            I_DATA          => PORT_DATA      , -- In  :
            I_INFO(0)       => PORT_LAST      , -- In  :
            I_VAL           => PORT_VAL       , -- In  :
            I_RDY           => port_ready     , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => i_data         , -- Out :
            O_STRB          => i_strb         , -- Out :
            O_INFO(0)       => i_last         , -- Out :
            O_VAL           => i_valid        , -- Out :
            O_RDY           => i_ready        , -- In  :
        ---------------------------------------------------------------------------
        -- Status Signals.
        ---------------------------------------------------------------------------
            BUSY            => i_busy           -- Out :
        );                                      --
    PORT_RDY <= port_ready;
    i_done   <= '1' when (i_valid = '1' and i_ready = '1' and i_last = '1') else '0';
    -------------------------------------------------------------------------------
    -- データーキュー
    -------------------------------------------------------------------------------
    QUEUE: REDUCER                              -- 
        generic map (                           -- 
            WORD_BITS       => WORD_BITS      , -- 
            STRB_BITS       => STRB_BITS      , -- 
            I_WIDTH         => PORT_WORDS     , -- 
            O_WIDTH         => POOL_WORDS     , -- 
            QUEUE_SIZE      => QUEUE_SIZE     , -- 
            VALID_MIN       => 0              , -- 
            VALID_MAX       => 0              , --
            O_VAL_SIZE      => POOL_WORDS     , -- 
            O_SHIFT_MIN     => pool_shift'low , --
            O_SHIFT_MAX     => pool_shift'high, --
            I_JUSTIFIED     => 1                --
        )                                       -- 
        port map (                              -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK            , -- In  :
            RST             => RST            , -- In  :
            CLR             => CLR            , -- In  :
        ---------------------------------------------------------------------------
        -- 各種制御信号
        ---------------------------------------------------------------------------
            START           => START          , -- In  :
            OFFSET          => pool_offset    , -- In  :
            BUSY            => queue_busy     , -- Out :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_ENABLE        => queue_enable   , -- In  :
            I_STRB          => i_strb         , -- In  :
            I_DATA          => i_data         , -- In  :
            I_DONE          => i_last         , -- In  :
            I_VAL           => i_valid        , -- In  :
            I_RDY           => i_ready        , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_ENABLE        => o_enable       , -- In  :
            O_DATA          => POOL_DATA      , -- Out :
            O_STRB          => o_strobe       , -- Out :
            O_DONE          => o_last         , -- Out :
            O_VAL           => o_valid        , -- Out :
            O_RDY           => o_ready        , -- In  :
            O_SHIFT         => pool_shift       -- In  :
        );
    o_ready  <= POOL_RDY;
    -------------------------------------------------------------------------------
    -- o_size : バッファの出力側のバイト数.
    --          ここでは o_strobe の'1'の数を数えている.
    -------------------------------------------------------------------------------
    SIZE: process (o_strobe)
        function count_assert_bit(ARG:std_logic_vector) return integer is
            variable n  : integer range 0 to ARG'length;
            variable nL : integer range 0 to ARG'length/2;
            variable nH : integer range 0 to ARG'length-ARG'length/2;
            alias    a  : std_logic_vector(ARG'length-1 downto 0) is ARG;
        begin
            case a'length is
                when 0 =>                   n := 0;
                when 1 =>
                    if    (a =    "1") then n := 1;
                    else                    n := 0;
                    end if;
                when 2 =>
                    if    (a =   "11") then n := 2;
                    elsif (a =   "01") then n := 1;
                    elsif (a =   "10") then n := 1;
                    else                    n := 0;
                    end if;
                when 4 =>
                    if    (a = "1111") then n := 4;
                    elsif (a = "1110") then n := 3;
                    elsif (a = "1101") then n := 3;
                    elsif (a = "1100") then n := 2;
                    elsif (a = "1011") then n := 3;
                    elsif (a = "1010") then n := 2;
                    elsif (a = "1001") then n := 2;
                    elsif (a = "1000") then n := 1;
                    elsif (a = "0111") then n := 3;
                    elsif (a = "0110") then n := 2;
                    elsif (a = "0101") then n := 2;
                    elsif (a = "0100") then n := 1;
                    elsif (a = "0011") then n := 2;
                    elsif (a = "0010") then n := 1;
                    elsif (a = "0001") then n := 1;
                    else                    n := 0;
                    end if;
                when others =>
                    nL := count_assert_bit(a(a'length  -1 downto a'length/2));
                    nH := count_assert_bit(a(a'length/2-1 downto 0         ));
                    n  := nL + nH;
            end case;
            return n;
        end function;
        variable v_size : integer range 0 to o_strobe'length;
    begin
        v_size := count_assert_bit(o_strobe);
        o_size <= std_logic_vector(to_unsigned(v_size, o_size'length));
    end process;
    -------------------------------------------------------------------------------
    -- PORT_ERR/i_xfer_last/i_xfer_selectをレジスタに保存しておく.
    -- REDUCERを使う場合、REDUCER 内部にデータが残っている時に次の START が来る可能
    -- 性があるので、PORT_ERR/i_xfer_last/i_xfer_select をそのまま使うわけにはいか
    -- ない.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                o_error       <= '0';
                o_xfer_last   <= '0';
                o_xfer_select <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                o_error       <= '0';
                o_xfer_last   <= '0';
                o_xfer_select <= (others => '0');
            elsif (PORT_VAL = '1' and port_ready = '1') then
                if (START = '1') then
                    o_xfer_last   <= XFER_LAST;
                    o_xfer_select <= XFER_SEL;
                else
                    o_xfer_last   <= i_xfer_last;
                    o_xfer_select <= i_xfer_select;
                end if;
                o_error <= PORT_ERROR;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- PUSH_SIZE      : 何バイト書き込んだかを示す信号.
    -- PUSH_LAST      : 最後の転送"した"ワードであることを示すフラグ.
    -- PUSH_XFER_LAST : 最後のトランザクションであることを示すフラグ.
    -- PUSH_XFER_DONE : 最後のトランザクションの最後のワードを転送"した事"を示すフラグ.
    -- PUSH_ERROR     : エラーが発生したことを示す信号.
    -- PUSH_VAL       : PUSH_LAST、PUSH_ERROR、PUSH_SIZE が有効であることを示す信号.
    -------------------------------------------------------------------------------
    PUSH: block
        signal error     : boolean;
        signal data_last : boolean;
        signal xfer_last : boolean;
        signal valid     : boolean;
    begin
        error          <= (o_valid = '1' and o_last  = '1' and o_error = '1');
        xfer_last      <= (o_valid = '1' and o_xfer_last = '1');
        data_last      <= (o_valid = '1' and o_last      = '1');
        valid          <= (o_valid = '1' and o_ready     = '1');
        PUSH_VAL       <= o_xfer_select when (valid                  ) else (others => '0');
        PUSH_LAST      <= '1'           when (data_last              ) else '0';
        PUSH_XFER_LAST <= '1'           when (xfer_last              ) else '0';
        PUSH_XFER_DONE <= '1'           when (data_last and xfer_last) else '0';
        PUSH_ERROR     <= '1'           when (error = TRUE           ) else '0';
        PUSH_SIZE      <= o_size        when (error = FALSE          ) else (others => '0');
    end block;
    -------------------------------------------------------------------------------
    -- POOL_WEN   : 外部プールバッファへの書き込み信号.
    -------------------------------------------------------------------------------
    POOL_WEN  <= o_xfer_select when (o_valid = '1' and o_ready = '1') else (others => '0');
    -------------------------------------------------------------------------------
    -- POOL_DVAL  : 外部プールバッファへのストローブ信号.
    -------------------------------------------------------------------------------
    POOL_DVAL <= o_strobe;
    -------------------------------------------------------------------------------
    -- POOL_PTR   : 外部プールバッファへの書き込みポインタ.
    -------------------------------------------------------------------------------
    PTR: process(CLK, RST) begin
        if (RST = '1') then
                write_ptr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                write_ptr <= (others => '0');
            elsif (START = '1') then
                write_ptr <= unsigned(START_PTR);
            elsif (o_valid = '1' and o_ready = '1') then
                write_ptr <= write_ptr + RESIZE(unsigned(o_size), write_ptr'length);
            end if;
        end if;
    end process;
    POOL_PTR <= std_logic_vector(write_ptr);
    -------------------------------------------------------------------------------
    -- BUSY       : 
    -------------------------------------------------------------------------------
    BUSY <= '1' when (queue_busy = '1' or i_busy = '1') else '0';
end RTL;
