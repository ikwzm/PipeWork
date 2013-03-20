-----------------------------------------------------------------------------------
--!     @file    pool_intake_port.vhd
--!     @brief   POOL INTAKE PORT
--!     @version 1.5.0
--!     @date    2013/3/20
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
--! @brief   POOL INTAKE PORT
-----------------------------------------------------------------------------------
entity  POOL_INTAKE_PORT is
    generic (
        WORD_BITS   : --! @brief WORD BITS :
                      --! １ワードのデータのビット数を指定する.
                      integer := 8;
        ENBL_BITS   : --! @brief ENABLE BITS :
                      --! ワードデータのうち有効なデータであることを示す信号の
                      --! ビット数を指定する.
                      integer := 1;
        I_WIDTH     : --! @brief INPUT WORD WIDTH :
                      --! 入力側のデータのワード数を指定する.
                      integer := 4;
        O_WIDTH     : --! @brief OUTPUT WORD WIDTH :
                      --! 出力側のデータのワード数を指定する.
                      integer := 4;
        VAL_BITS    : --! @brief VALID BITS :
                      --! REQ_VAL、ACK_VAL のビット数を指定する.
                      integer := 1;
        SIZE_BITS   : --! @brief SIZE BITS :
                      --! 各種サイズカウンタのビット数を指定する.
                      integer := 16;
        PTR_BITS    : --! @brief BUF PTR BITS:
                      integer := 16;
        QUEUE_SIZE  : --! @brief QUEUE SIZE :
                      --! キューの大きさをワード数で指定する.
                      --! * 少なくともキューの大きさは、I_WIDTH+O_WIDTH-1以上で
                      --!   なければならない.
                      --! * ただしQUEUE_SIZE=0を指定した場合は、キューの深さは
                      --!   自動的にI_WIDTH+O_WIDTH に設定される.
                      integer := 0
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK         : --! @brief CLOCK :
                      --! クロック信号
                      in  std_logic; 
        RST         : --! @brief ASYNCRONOUSE RESET :
                      --! 非同期リセット信号.アクティブハイ.
                      in  std_logic;
        CLR         : --! @brief SYNCRONOUSE RESET :
                      --! 同期リセット信号.アクティブハイ.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 各種制御信号
    -------------------------------------------------------------------------------
        START       : --! @brief START :
                      --! 開始信号.
                      --! * この信号はSTART_PTRを内部に設定してキューを初期化する.
                      --! * 最初にデータ入力と同時にアサートしても構わない.
                      in  std_logic;
        START_PTR   : --! @brief START POOL BUFFER POINTER :
                      --! 書き込み開始ポインタ.
                      in  std_logic_vector(PTR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INTAKE WORD DATA :
                      --! ワードデータ入力.
                      in  std_logic_vector(I_WIDTH*WORD_BITS-1 downto 0);
        I_ENBL      : --! @brief INTAKE WORD ENABLE :
                      --! ワードイネーブル信号入力.
                      in  std_logic_vector(I_WIDTH*ENBL_BITS-1 downto 0);
        I_LAST      : --! @brief INTAKE WORD LAST :
                      --! 最終ワード信号入力.
                      --! * 最後の力ワードデータ入であることを示すフラグ.
                      in  std_logic;
        I_DONE      : --! @brief INTAKE TRANSFER DONE :
                      in  std_logic;
        I_ERR       : --! @brief INTAKE WORD ERROR :
                      in  std_logic;
        I_SEL       : --! @brief INTAKE VALID SELECT :
                      in  std_logic_vector(VAL_BITS-1 downto 0);
        I_VAL       : --! @brief INTAKE WORD VALID :
                      --! 入力ワード有効信号.
                      --! * I_DATA/I_ENBL/I_LAST/I_DONE/I_ERR/I_SELが有効であることを示す.
                      --! * I_VAL='1'and I_RDY='1'でワードデータがキューに取り込まれる.
                      in  std_logic;
        I_RDY       : --! @brief INTAKE WORD READY :
                      --! 入力レディ信号.
                      --! * キューが次のワードデータを入力出来ることを示す.
                      --! * I_VAL='1'and I_RDY='1'でワードデータがキューに取り込まれる.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VAL    : --! @brief PUSH VALID: 
                      --! PUSH_LAST/PUSH_ERR/PUSH_SIZEが有効であることを示す.
                      out std_logic_vector(VAL_BITS-1 downto 0);
        PUSH_LAST   : --! @brief PUSH LAST : 
                      --! 最後の転送"した事"を示すフラグ.
                      out std_logic;
        PUSH_ERR    : --! @brief PUSH ERROR : 
                      --! 転送"した事"がエラーだった事を示すフラグ.
                      out std_logic;
        PUSH_SIZE   : --! @brief PUSH SIZE :
                      --! 転送"した"バイト数を出力する.
                      out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pool Buffer Interface Signals.
    -------------------------------------------------------------------------------
        POOL_WEN    : --! @brief POOL BUFFER WRITE ENABLE :
                      --! バッファにデータをライトすることを示す.
                      out std_logic_vector(VAL_BITS-1 downto 0);
        POOL_BEN    : --! @brief POOL BUFFER BYTE ENABLE :
                      --! バッファにデータをライトする際のバイトイネーブル信号.
                      --! * POOL_WEN='1'の場合にのみ有効.
                      --! * POOL_WEN='0'の場合のこの信号の値は不定.
                      out std_logic_vector(O_WIDTH*ENBL_BITS-1 downto 0);
        POOL_DATA   : --! @brief POOL BUFFER WRITE DATA :
                      --! バッファへライトするデータを出力する.
                      out std_logic_vector(O_WIDTH*WORD_BITS-1 downto 0);
        POOL_PTR    : --! @brief POOL BUFFER WRITE POINTER :
                      --! ライト時にデータを書き込むバッファの位置を出力する.
                      out std_logic_vector(PTR_BITS-1 downto 0);
        POOL_RDY    : --! @brief POOL BUFFER WRITE READY :
                      --! バッファにデータを書き込み可能な事をを示す.
                      in  std_logic
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
architecture RTL of POOL_INTAKE_PORT is
    constant done           : std_logic := '0';
    constant flush          : std_logic := '0';
    signal   offset         : std_logic_vector(O_WIDTH-1 downto 0);
    signal   buf_busy       : std_logic;
    signal   i_ready        : std_logic;
    signal   o_size         : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   o_ben          : std_logic_vector(O_WIDTH*ENBL_BITS-1 downto 0);
    signal   o_last         : std_logic;
    signal   o_valid        : std_logic;
    signal   o_ready        : std_logic;
    signal   xfer_last      : std_logic;
    signal   xfer_error     : std_logic;
    signal   xfer_select    : std_logic_vector(VAL_BITS-1 downto 0);
    signal   write_ptr      : unsigned(PTR_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- offset : REDUCER にセットするオフセット値.
    -------------------------------------------------------------------------------
    process (START_PTR)
        function CALC_O_DATA_BYTES return integer is
            variable value : integer;
        begin
            value := 0;
            while (2**(value+3) < O_WIDTH*WORD_BITS) loop
                value := value + 1;
            end loop;
            return value;
        end function;
        constant O_DATA_BYTES : integer := CALC_O_DATA_BYTES;
        variable u_ptr        : unsigned(O_DATA_BYTES downto 0);
    begin
        for i in u_ptr'range loop
            if (i < O_DATA_BYTES and START_PTR(i) = '1') then
                u_ptr(i) := '1';
            else
                u_ptr(i) := '0';
            end if;
        end loop;
        for i in offset'range loop
            if (i < u_ptr) then
                offset(i) <= '1';
            else
                offset(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    B: REDUCER                                  -- 
        generic map (                           -- 
            WORD_BITS       => WORD_BITS      , -- 
            ENBL_BITS       => ENBL_BITS      , -- 
            I_WIDTH         => I_WIDTH        , -- 
            O_WIDTH         => O_WIDTH        , -- 
            QUEUE_SIZE      => QUEUE_SIZE     , -- 
            VALID_MIN       => 0              , -- 
            VALID_MAX       => 0              , -- 
            I_JUSTIFIED     => 0              , -- 
            FLUSH_ENABLE    => 0                -- 
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
            OFFSET          => offset         , -- In  :
            DONE            => done           , -- In  :
            FLUSH           => flush          , -- In  :
            BUSY            => buf_busy       , -- Out :
            VALID           => open           , -- Out :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_DATA          => I_DATA         , -- In  :
            I_ENBL          => I_ENBL         , -- In  :
            I_DONE          => I_LAST         , -- In  :
            I_FLUSH         => flush          , -- In  :
            I_VAL           => I_VAL          , -- In  :
            I_RDY           => i_ready        , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => POOL_DATA      , -- Out :
            O_ENBL          => o_ben          , -- Out :
            O_DONE          => o_last         , -- Out :
            O_FLUSH         => open           , -- Out :
            O_VAL           => o_valid        , -- Out :
            O_RDY           => o_ready          -- In  :
    );
    I_RDY   <= i_ready;
    o_ready <= POOL_RDY;
    -------------------------------------------------------------------------------
    -- o_size : バッファの出力側のバイト数.
    --          ここでは o_ben の'1'の数を数えている.
    -------------------------------------------------------------------------------
    process (o_ben)
        function count_assert_bit(ARG:std_logic_vector) return integer is
            variable n  : integer range 0 to ARG'length;
            variable nL : integer range 0 to ARG'length/2;
            variable nH : integer range 0 to ARG'length/2;
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
                    elsif (a = "1101") then n := 3;
                    elsif (a = "1110") then n := 3;
                    elsif (a = "1100") then n := 2;
                    elsif (a = "1011") then n := 3;
                    elsif (a = "1001") then n := 2;
                    elsif (a = "1010") then n := 2;
                    elsif (a = "1000") then n := 1;
                    elsif (a = "0111") then n := 3;
                    elsif (a = "0101") then n := 2;
                    elsif (a = "0110") then n := 2;
                    elsif (a = "0100") then n := 1;
                    elsif (a = "0011") then n := 2;
                    elsif (a = "0001") then n := 1;
                    elsif (a = "0010") then n := 1;
                    else                    n := 0;
                    end if;
                when others =>
                    nL := count_assert_bit(a(a'length  -1 downto a'length/2));
                    nH := count_assert_bit(a(a'length/2-1 downto 0         ));
                    n  := nL + nH;
            end case;
            return n;
        end function;
        variable size : integer range 0 to o_ben'length;
    begin
        size   := count_assert_bit(o_ben);
        o_size <= std_logic_vector(to_unsigned(size, o_size'length));
    end process;
    -------------------------------------------------------------------------------
    -- I_DONE/I_ERR/I_SELをレジスタに保存しておく.
    -- REDUCERを使う場合、REDUCER内部にデータが残っている時に次の START が来る可能性
    -- があるので、I_DONE/I_ERR/I_SELECTをそのまま使うわけにはいかない.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                xfer_last   <= '0';
                xfer_error  <= '0';
                xfer_select <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                xfer_last   <= '0';
                xfer_error  <= '0';
                xfer_select <= (others => '0');
            elsif (I_VAL = '1' and i_ready = '1') then
                xfer_last   <= I_DONE;
                xfer_error  <= I_ERR;
                xfer_select <= I_SEL;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- PUSH_SIZE : 何バイト書き込んだかを示す信号.
    -- PUSH_LAST : 最後のデータ書き込みであることを示す信号.
    -- PUSH_ERR  : エラーが発生したことを示す信号.
    -- PUSH_VAL  : PUSH_LAST、PUSH_ERROR、PUSH_SIZE が有効であることを示す信号.
    -------------------------------------------------------------------------------
    PUSH: block
        signal error  : boolean;
        signal last   : boolean;
        signal valid  : boolean;
    begin
        error     <= (o_valid = '1' and o_last  = '1' and xfer_error = '1');
        last      <= (o_valid = '1' and o_last  = '1' and xfer_last  = '1');
        valid     <= (o_valid = '1' and o_ready = '1');
        PUSH_VAL  <= xfer_select     when (valid) else (others => '0');
        PUSH_LAST <= '1'             when (last ) else '0';
        PUSH_ERR  <= '1'             when (error) else '0';
        PUSH_SIZE <= (others => '0') when (error) else o_size;
    end block;
    -------------------------------------------------------------------------------
    -- POOL_WEN   : 外部プールバッファへの書き込み信号.
    -------------------------------------------------------------------------------
    POOL_WEN <= xfer_select when (o_valid = '1' and o_ready = '1') else (others => '0');
    -------------------------------------------------------------------------------
    -- POOL_BEN   : 外部プールバッファへのバイトイネーブル信号.
    -------------------------------------------------------------------------------
    POOL_BEN <= o_ben;
    -------------------------------------------------------------------------------
    -- POOL_PTR   : 外部プールバッファへの書き込みポインタ.
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
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
end RTL;
