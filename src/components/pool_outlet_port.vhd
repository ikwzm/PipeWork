-----------------------------------------------------------------------------------
--!     @file    pool_outlet_port.vhd
--!     @brief   POOL OUTLET PORT
--!     @version 1.8.0
--!     @date    2010/5/9
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2019 Ichiro Kawazome
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
--! @brief   POOL OUTLET PORT
-----------------------------------------------------------------------------------
entity  POOL_OUTLET_PORT is
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
        PORT_DATA_BITS  : --! @brief OUTLET PORT DATA BITS :
                          --! PORT_DATA のビット数を指定する.
                          integer := 32;
        POOL_DATA_BITS  : --! @brief POOL BUFFER DATA BITS :
                          --! POOL_DATA のビット数を指定する.
                          integer := 32;
        PORT_PTR_BITS   : --! @brief PORT POINTER BITS:
                          --! START_PORT_PTR のビット数を指定する.
                          integer := 16;
        POOL_PTR_BITS   : --! @brief POOL BUFFER POINTER BITS:
                          --! START_POOL_PTR、POOL_PTR のビット数を指定する.
                          integer := 16;
        SEL_BITS        : --! @brief SELECT BITS :
                          --! XFER_SEL、PUSH_VAL、POOL_WEN のビット数を指定する.
                          integer := 1;
        SIZE_BITS       : --! @brief PORT_SIZE BITS :
                          --! PORT_SIZE のビット数を指定する.
                          integer := 16;
        POOL_SIZE_VALID : --! @brief POOL_SIZE VALID :
                          --! POOL_SIZE が有効が有効かどうかを指定する.
                          --! * POOL_SIZE_VALID=0の場合、POOL_SIZE 信号は無効。
                          --!   この場合、入力ユニット数は POOL_DVAL 信号から生成さ
                          --!   れる.
                          integer := 1;
        QUEUE_SIZE      : --! @brief QUEUE SIZE :
                          --! キューの大きさをワード数で指定する.
                          --! * QUEUE_SIZE<0 かつ PORT_DATA_BITS=WORD_BITS かつ
                          --!   POOL_DATA_BITS=WORD_BITS の場合、キューは生成しない.
                          --! * QUEUE_SIZE=0を指定した場合は、キューの深さは自動的に
                          --!   (PORT_DATA_BITS/WORD_BITS)+(POOL_DATA_BITS/WORD_BITS)
                          --!   に設定される.
                          integer := 0;
        POOL_JUSTIFIED  : --! @brief POOL BUFFER INPUT INPUT JUSTIFIED :
                          --! 入力 POOL 側の有効なデータが常にLOW側に詰められている
                          --! ことを示すフラグ.
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
        START_POOL_PTR  : --! @brief START POOL BUFFER POINTER :
                          --! 書き込み開始ポインタ.
                          --! START 信号により内部に取り込まれる.
                          in  std_logic_vector(POOL_PTR_BITS-1 downto 0);
        START_PORT_PTR  : --! @brief START PORT POINTER :
                          --! 書き込み開始ポインタ.
                          --! START 信号により内部に取り込まれる.
                          in  std_logic_vector(PORT_PTR_BITS-1 downto 0);
        XFER_LAST       : --! @brief TRANSFER LAST :
                          --! 最後のトランザクションであることを示すフラグ.
                          --! START 信号により内部に取り込まれる.
                          in  std_logic;
        XFER_SEL        : --! @brief TRANSFER SELECT :
                          --! 選択信号. PUSH_VAL、POOL_WENの生成に使う.
                          --! START 信号により内部に取り込まれる.
                          in  std_logic_vector(SEL_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Port Signals.
    -------------------------------------------------------------------------------
        PORT_DATA       : --! @brief OUTLET PORT DATA :
                          --! ワードデータ出力.
                          out std_logic_vector(PORT_DATA_BITS-1 downto 0);
        PORT_DVAL       : --! @brief OUTLET PORT DATA VALID :
                          --! ポートからデータを出力する際のユニット単位での有効信号.
                          out std_logic_vector(PORT_DATA_BITS/UNIT_BITS-1 downto 0);
        PORT_LAST       : --! @brief OUTLET DATA LAST :
                          --! 最終ワード信号出力.
                          --! * 最後のワードデータ出力であることを示すフラグ.
                          out std_logic;
        PORT_ERROR      : --! @brief OUTLET ERROR :
                          --! エラー出力
                          --! * エラーが発生したことをし示すフラグ.
                          out std_logic;
        PORT_SIZE       : --! @brief OUTLET DATA SIZE :
                          --! 出力バイト数
                          --! * ポートからのデータの出力ユニット数.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
        PORT_VAL        : --! @brief OUTLET PORT VALID :
                          --! 出力ワード有効信号.
                          --! * PORT_DATA/PORT_DVAL/PORT_LAST/PORT_SIZEが有効である
                          --!   ことを示す.
                          out std_logic;
        PORT_RDY        : --! @brief OUTLET PORT READY :
                          --! 出力レディ信号.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VAL        : --! @brief PULL VALID: 
                          --! PULL_LAST/PULL_ERR/PULL_SIZEが有効であることを示す.
                          out std_logic_vector(SEL_BITS-1 downto 0);
        PULL_LAST       : --! @brief PULL LAST : 
                          --! 最後の入力"した事"を示すフラグ.
                          out std_logic;
        PULL_XFER_LAST  : --! @brief PULL TRANSFER LAST :
                          --! 最後のトランザクションであることを示すフラグ.
                          out std_logic;
        PULL_XFER_DONE  : --! @brief PULL TRANSFER DONE :
                          --! 最後のトランザクションの最後の転送"した"ワードである
                          --! ことを示すフラグ.
                          out std_logic;
        PULL_ERROR      : --! @brief PULL ERROR : 
                          --! エラーが発生したことをし示すフラグ.
                          out std_logic;
        PULL_SIZE       : --! @brief PUSH SIZE :
                          --! 入力"した"バイト数を出力する.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pool Buffer Interface Signals.
    -------------------------------------------------------------------------------
        POOL_REN        : --! @brief POOL BUFFER READ ENABLE :
                          --! バッファからデータをリードすることを示す.
                          out std_logic_vector(SEL_BITS-1 downto 0);
        POOL_PTR        : --! @brief POOL BUFFER WRITE POINTER :
                          --! リード時にデータをリードするバッファの位置を出力する.
                          out std_logic_vector(POOL_PTR_BITS-1 downto 0);
        POOL_DATA       : --! @brief POOL BUFFER WRITE DATA :
                          --! バッファからリードされたデータを入力する.
                          in  std_logic_vector(POOL_DATA_BITS-1 downto 0);
        POOL_DVAL       : --! @brief POOL BUFFER DATA VALID :
                          --! バッファからデータをリードする際のユニット単位での
                          --! 有効信号.
                          in  std_logic_vector(POOL_DATA_BITS/UNIT_BITS-1 downto 0);
        POOL_SIZE       : --! @brief POOL BUFFER DATA SIZE :
                          --! 入力バイト数
                          --! * バッファからのデータの入力ユニット数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        POOL_ERROR      : --! @brief POOL BUFFER ERROR :
                          --! データ転送中にエラーが発生したことを示すフラグ.
                          in  std_logic;
        POOL_LAST       : --! @brief POOL BUFFER DATA LAST :
                          --! 最後の入力データであることを示す.
                          in  std_logic;
        POOL_VAL        : --! @brief POOL BUFFER DATA VALID :
                          --! バッファからリードしたデータが有効である事を示す信号.
                          in  std_logic;
        POOL_RDY        : --! @brief POOL BUFFER WRITE READY :
                          --! バッファからデータを読み込み可能な事をを示す.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- Status Signals.
    -------------------------------------------------------------------------------
        POOL_BUSY       : --! @brief POOL BUFFER BUSY :
                          --! バッファからデータリード中であることを示す信号.
                          --! * START信号がアサートされたときにアサートされる.
                          --! * 最後のデータが入力されたネゲートされる.
                          out std_logic;
        POOL_DONE       : --! @brief POOL BUFFER DONE :
                          --! 次のクロックで POOL_BUSY がネゲートされることを示す.
                          out std_logic;
        BUSY            : --! @brief QUEUE BUSY :
                          --! キューが動作中であることを示す信号.
                          --! * START信号がアサートされたときにアサートされる.
                          --! * 最後のデータが出力し終えたらネゲートされる.
                          out std_logic
    );
end POOL_OUTLET_PORT;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.REDUCER;
architecture RTL of POOL_OUTLET_PORT is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
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
                elsif (a =   "10") then n := 1;
                elsif (a =   "01") then n := 1;
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
                nL := count_assert_bit(a(a'length/2-1 downto a'low     ));
                nH := count_assert_bit(a(a'high       downto a'length/2));
                n  := nL + nH;
        end case;
        return n;
    end function;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    regs_busy     : std_logic;
    signal    intake_running: boolean;
    signal    intake_enable : std_logic;
    signal    intake_valid  : std_logic;
    signal    intake_ready  : std_logic;
    signal    intake_last   : std_logic;
    signal    intake_select : std_logic_vector( SEL_BITS-1 downto 0);
    signal    intake_strobe : std_logic_vector(POOL_DATA_BITS/UNIT_BITS-1 downto 0);
    signal    intake_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    constant  outlet_enable : std_logic := '1';
    signal    outlet_valid  : std_logic;
    signal    outlet_ready  : std_logic;
    signal    outlet_last   : std_logic;
    signal    outlet_error  : std_logic;
    signal    outlet_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    outlet_strobe : std_logic_vector(PORT_DATA_BITS/UNIT_BITS-1 downto 0);
    constant  SEL_ALL0      : std_logic_vector(SEL_BITS -1 downto 0) := (others => '0');
    constant  SEL_ALL1      : std_logic_vector(SEL_BITS -1 downto 0) := (others => '1');
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    INTAKE_CTRL: block
        signal   next_read_ptr    : std_logic_vector(POOL_PTR_BITS-1 downto 0);
        signal   curr_read_ptr    : std_logic_vector(POOL_PTR_BITS-1 downto 0);
        signal   curr_select      : std_logic_vector(SEL_BITS -1 downto 0);
        signal   curr_xfer_last   : boolean;
        signal   intake_done      : boolean;
        signal   intake_continue  : boolean;
        signal   intake_chop      : std_logic;
        signal   strb_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        strb_size       <= std_logic_vector(to_unsigned(count_assert_bit(intake_strobe), SIZE_BITS));
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        intake_valid    <= POOL_VAL;
        intake_strobe   <= POOL_DVAL when (POOL_ERROR = '0') else (others => '0');
        intake_size     <= strb_size when (POOL_SIZE_VALID = 0) else
                           POOL_SIZE when (POOL_ERROR = '0') else
                           (others => '0');
        intake_last     <= '1' when (POOL_LAST = '1' or  POOL_ERROR   = '1') else '0';
        intake_enable   <= '1' when (START     = '1' or  intake_continue   ) else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        intake_chop     <= '1' when (intake_valid = '1' and intake_ready = '1') else '0';
        intake_done     <= (intake_running = TRUE  and intake_chop = '1' and intake_last = '1');
        intake_continue <= (intake_running = TRUE  and not intake_done);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (curr_read_ptr, intake_size)
            variable u_intake_size   : unsigned(  intake_size'range);
            variable u_add_ptr       : unsigned(next_read_ptr'range);
            variable u_curr_read_ptr : unsigned(next_read_ptr'range);
        begin
            u_curr_read_ptr := to_01(unsigned(curr_read_ptr));
            u_intake_size   := to_01(unsigned(intake_size  ));
            u_add_ptr       := resize(u_intake_size, u_add_ptr'length);
            next_read_ptr   <= std_logic_vector(u_curr_read_ptr + u_add_ptr);
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process(CLK, RST) begin
            if (RST = '1') then
                    intake_running <= FALSE;
                    curr_xfer_last <= FALSE;
                    curr_select    <= (others => '0');
                    curr_read_ptr  <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then 
                    intake_running <= FALSE;
                    curr_xfer_last <= FALSE;
                    curr_select    <= (others => '0');
                    curr_read_ptr  <= (others => '0');
                elsif (START = '1') then
                    intake_running <= TRUE;
                    curr_xfer_last <= (XFER_LAST = '1');
                    curr_select    <= XFER_SEL;
                    curr_read_ptr  <= START_POOL_PTR;
                else
                    intake_running <= intake_continue;
                    if (intake_chop = '1' ) then
                        curr_read_ptr <= next_read_ptr;
                    end if;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        intake_select <= curr_select when (SEL_BITS > 1) else SEL_ALL1;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        POOL_BUSY <= '1' when (intake_running = TRUE) else '0';
        POOL_DONE <= '1' when (intake_done    = TRUE) else '0';
        POOL_PTR  <= START_POOL_PTR when (START       = '1') else
                     next_read_ptr  when (intake_chop = '1') else
                     curr_read_ptr;
        POOL_REN  <= XFER_SEL       when (START = '1' and SEL_BITS > 1) else
                     SEL_ALL1       when (START = '1' and SEL_BITS = 1) else
                     intake_select  when (intake_continue             ) else
                     SEL_ALL0;
        BUSY      <= '1' when (intake_running = TRUE or regs_busy = '1') else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        PULL_VAL       <= intake_select when (intake_chop = '1') else SEL_ALL0;
        PULL_LAST      <= '1' when (POOL_LAST = '1') else '0';
        PULL_XFER_LAST <= '1' when (curr_xfer_last ) else '0';
        PULL_XFER_DONE <= '1' when (POOL_LAST = '1') and
                                   (curr_xfer_last ) else '0';
        PULL_ERROR     <= POOL_ERROR;
        PULL_SIZE      <= intake_size;
    end block;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ADJ_ALIGN: if (QUEUE_SIZE >= 0) or
                  (POOL_DATA_BITS /= WORD_BITS) or
                  (PORT_DATA_BITS /= WORD_BITS) generate
        function  Q_SIZE return integer is begin
            if (QUEUE_SIZE >= 0) then
                return QUEUE_SIZE;
            else
                return 0;
            end if;
        end function;
        constant  STRB_BITS     : integer   := WORD_BITS/UNIT_BITS;
        constant  I_WORDS       : integer   := POOL_DATA_BITS/WORD_BITS;
        constant  O_WORDS       : integer   := PORT_DATA_BITS/WORD_BITS;
        constant  flush         : std_logic := '0';
        constant  done          : std_logic := '0';
        constant  o_shift       : std_logic_vector(O_WORDS   downto O_WORDS) := "0";
        signal    offset        : std_logic_vector(O_WORDS-1 downto 0);
        signal    error_flag    : boolean;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (START_PORT_PTR)
            function CALC_WIDTH(BITS:integer) return integer is
                variable value : integer;
            begin
                value := 0;
                while (2**value < (BITS/UNIT_BITS)) loop
                    value := value + 1;
                end loop;
                return value;
            end function;
            constant O_DATA_WIDTH : integer := CALC_WIDTH(O_WORDS*WORD_BITS);
            constant WORD_WIDTH   : integer := CALC_WIDTH(WORD_BITS);
            variable u_offset     : unsigned(O_DATA_WIDTH-WORD_WIDTH downto 0);
        begin
            for i in u_offset'range loop
                if (i+WORD_WIDTH <  O_DATA_WIDTH       ) and
                   (i+WORD_WIDTH <= START_PORT_PTR'high) and
                   (i+WORD_WIDTH >= START_PORT_PTR'low ) then
                    if (START_PORT_PTR(i+WORD_WIDTH) = '1') then
                        u_offset(i) := '1';
                    else
                        u_offset(i) := '0';
                    end if;
                else
                        u_offset(i) := '0';
                end if;
            end loop;
            for i in offset'range loop
                if (i < u_offset) then
                    offset(i) <= '1';
                else
                    offset(i) <= '0';
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process(CLK, RST) begin
            if (RST = '1') then
                    error_flag <= FALSE;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then 
                    error_flag <= FALSE;
                elsif (intake_valid = '1' and intake_ready = '1' and POOL_ERROR  = '1') then
                    error_flag <= TRUE;
                elsif (outlet_valid = '1' and outlet_ready = '1' and outlet_last = '1') then
                    error_flag <= FALSE;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        QUEUE: REDUCER                              -- 
            generic map (                           -- 
                WORD_BITS       => WORD_BITS      , -- 
                STRB_BITS       => STRB_BITS      , -- 
                I_WIDTH         => I_WORDS        , -- 
                O_WIDTH         => O_WORDS        , -- 
                QUEUE_SIZE      => Q_SIZE         , -- 
                VALID_MIN       => 0              , -- 
                VALID_MAX       => 0              , -- 
                O_VAL_SIZE      => O_WORDS        , -- 
                O_SHIFT_MIN     => o_shift'low    , --
                O_SHIFT_MAX     => o_shift'high   , --
                I_JUSTIFIED     => POOL_JUSTIFIED , -- 
                FLUSH_ENABLE    => 0                -- 
            )                                       -- 
            port map (                              -- 
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK            , -- In  :
                RST             => RST            , -- In  :
                CLR             => CLR            , -- In  :
            -----------------------------------------------------------------------
            -- 各種制御信号
            -----------------------------------------------------------------------
                START           => START          , -- In  :
                OFFSET          => offset         , -- In  :
                DONE            => done           , -- In  :
                FLUSH           => flush          , -- In  :
                BUSY            => regs_busy      , -- Out :
                VALID           => open           , -- Out :
            -----------------------------------------------------------------------
            -- 入力側 I/F
            -----------------------------------------------------------------------
                I_ENABLE        => intake_enable  , -- In  :
                I_STRB          => intake_strobe  , -- In  :
                I_DATA          => POOL_DATA      , -- In  :
                I_DONE          => intake_last    , -- In  :
                I_FLUSH         => flush          , -- In  :
                I_VAL           => intake_valid   , -- In  :
                I_RDY           => intake_ready   , -- Out :
            -----------------------------------------------------------------------
            -- 出力側 I/F
            -----------------------------------------------------------------------
                O_ENABLE        => outlet_enable  , -- In  :
                O_DATA          => PORT_DATA      , -- Out :
                O_STRB          => outlet_strobe  , -- Out :
                O_DONE          => outlet_last    , -- Out :
                O_FLUSH         => open           , -- Out :
                O_VAL           => outlet_valid   , -- Out :
                O_RDY           => outlet_ready   , -- In  :
                O_SHIFT         => o_shift          -- In  :
        );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        outlet_error <= '1' when (error_flag and outlet_last = '1') else '0';
        outlet_size  <= std_logic_vector(to_unsigned(count_assert_bit(outlet_strobe), outlet_size'length));
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    NON_ALIGN: if (QUEUE_SIZE < 0) and 
                  (POOL_DATA_BITS = WORD_BITS) and
                  (PORT_DATA_BITS = WORD_BITS) generate
    begin
        PORT_DATA    <= POOL_DATA;
        outlet_error <= POOL_ERROR;
        outlet_strobe<= intake_strobe;
        outlet_last  <= intake_last;
        outlet_valid <= intake_valid;
        outlet_size  <= intake_size;
        intake_ready <= '1' when (intake_running and outlet_ready = '1') else '0';
        regs_busy    <= '0';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    POOL_RDY     <= intake_ready;
    PORT_SIZE    <= outlet_size;
    PORT_DVAL    <= outlet_strobe;
    PORT_LAST    <= outlet_last;
    PORT_ERROR   <= outlet_error;
    PORT_VAL     <= outlet_valid;
    outlet_ready <= PORT_RDY;
end RTL;
