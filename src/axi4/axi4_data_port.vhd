-----------------------------------------------------------------------------------
--!     @file    axi4_data_port.vhd
--!     @brief   AXI4 DATA PORT
--!     @version 1.5.5
--!     @date    2014/3/2
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2014 Ichiro Kawazome
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
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4 DATA OUTLET PORT
-----------------------------------------------------------------------------------
entity  AXI4_DATA_PORT is
    generic (
        DATA_BITS       : --! @brief DATA BITS :
                          --! I_DATA/O_DATA のビット数を指定する.
                          --! * DATA_BITSで指定できる値は 8,16,32,64,128,256,512,
                          --!   1024
                          integer := 32;
        ADDR_BITS       : --! @brief ADDRESS BITS :
                          --! ADDR のビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! O_SIZE/I_SIZE のビット数を指定する.
                          integer := 12;
        USER_BITS       : --! @brief USER INFOMATION BITS :
                          --! O_USER/I_USER のビット数を指定する.
                          integer := 1;
        ALEN_BITS       : --! @brief BURST LENGTH BITS :
                          --! ALEN のビット数を指定する.
                          integer := 12;
        USE_ASIZE       : --! @brief USE BURST SIZE :
                          --! ASIZE による Narrow transfers をサポートするか否かを
                          --! 指定する.
                          --! * USE_ASIZE=0を指定した場合、Narrow transfers をサポ
                          --!   ートしない.
                          --!   この場合、ASIZE信号は未使用.
                          --! * USE_ASIZE=1を指定した場合、Narrow transfers をサポ
                          --!   ートする. その際の１ワード毎の転送バイト数は
                          --!   ASIZE で指定される.
                          integer range 0 to 1 := 1;
        CHECK_ALEN      : --! @brief CHECK BURST LENGTH :
                          --! ALEN で指定されたバースト数とI_LASTによるバースト転送
                          --! の最後が一致するかどうかチェックするか否かを指定する.
                          --! * CHECK_ALEN=0かつUSE_ASIZE=0を指定した場合、バースト
                          --!   長をチェックしない. 
                          --! * CHECK_ALEN=1またはUSE_ASIZEを指定した場合、バースト
                          --!   長をチェックする.
                          integer range 0 to 1 := 1;
        I_REGS_SIZE     : --! @brief PORT INTAKE REGS SIZE :
                          --! 入力側に挿入するパイプラインレジスタの段数を指定する.
                          --! * I_REGS_SIZE=0を指定した場合、パイプラインレジスタは
                          --!   挿入しない.
                          --! * I_REGS_SIZE=1を指定した場合、パイプラインレジスタを
                          --!   １段挿入するが、この場合バースト転送時に１ワード転送
                          --!   毎に１サイクルのウェイトが発生する.
                          --! * I_REGS_SIZE>1を指定した場合、パイプラインレジスタを
                          --!   指定された段数挿入する. この場合、バースト転送時
                          --!   にウェイトは発生しない.
                          integer := 0;
        O_REGS_SIZE     : --! @brief PORT OUTLET REGS SIZE :
                          --! 出力側に挿入するパイプラインレジスタの段数を指定する.
                          --! * O_REGS_SIZE=0を指定した場合、パイプラインレジスタは
                          --!   挿入しない.
                          --! * O_REGS_SIZE=1を指定した場合、パイプラインレジスタを
                          --!   １段挿入するが、この場合バースト転送時に１ワード
                          --!   転送毎に１サイクルのウェイトが発生する.
                          --! * O_REGS_SIZE>1を指定した場合、パイプラインレジスタを
                          --!   指定された段数挿入する. この場合、バースト転送時
                          --!   にウェイトは発生しない.
                          integer := 0
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
        ASIZE           : --! @brief AXI4 BURST SIZE :
                          --! AXI4 によるバーストサイズを指定する.
                          in  AXI4_ASIZE_TYPE;
        ALEN            : --! @brief AXI4 BURST LENGTH :
                          --! AXI4 によるバースト数を指定する.
                          in  std_logic_vector(ALEN_BITS-1 downto 0);
        ADDR            : --! @brief START TRANSFER ADDRESS :
                          --! 出力側のアドレス.
                          --! START 信号により内部に取り込まれる.
                          in  std_logic_vector(ADDR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Port Signals.
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INTAKE PORT DATA :
                          --! ワードデータ入力.
                          in  std_logic_vector(DATA_BITS  -1 downto 0);
        I_STRB          : --! @brief INTAKE PORT DATA STROBE :
                          --! バイト単位での有効信号.
                          in  std_logic_vector(DATA_BITS/8-1 downto 0);
        I_SIZE          : --! @brief INTAKE PORT DATA SIZE :
                          --! 入力ワードデータのバイト数.
                          in  std_logic_vector(SIZE_BITS  -1 downto 0);
        I_USER          : --! @brief INTAKE PORT USER DATA :
                          --! 入力ユーザー定義信号.
                          in  std_logic_vector(USER_BITS  -1 downto 0);
        I_ERROR         : --! @brief INTAKE PORT ERROR :
                          --! エラー入力.
                          --! * 入力時にエラーが発生した事を示すフラグ.
                          in  std_logic;
        I_LAST          : --! @brief INTAKE PORT DATA LAST :
                          --! 最終ワード信号入力.
                          --! * 最後のワードデータ入力であることを示すフラグ.
                          in  std_logic;
        I_VALID         : --! @brief INTAKE PORT VALID :
                          --! 入力ワード有効信号.
                          --! * I_DATA/I_STRB/I_LAST/I_USER/I_SIZEが有効であること
                          --!   を示す.
                          --! * I_VALID='1'and I_READY='1'で上記信号がキューに取り
                          --!   込まれる.
                          in  std_logic;
        I_READY         : --! @brief INTAKE PORT READY :
                          --! 入力レディ信号.
                          --! * キューが次のワードデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'で上記信号がキューから
                          --!   取り出される.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Port Signals.
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTLET PORT DATA :
                          --! ワードデータ出力.
                          out std_logic_vector(DATA_BITS  -1 downto 0);
        O_STRB          : --! @brief OUTLET PORT DATA STROBE :
                          --! ポートへデータを出力する際のバイト単位での有効信号.
                          out std_logic_vector(DATA_BITS/8-1 downto 0);
        O_SIZE          : --! @brief OUTLET PORT DATA SIZE :
                          --! ポートへデータを出力する際のバイト数.
                          out std_logic_vector(SIZE_BITS  -1 downto 0);
        O_USER          : --! @brief OUTLET PORT USER DATA :
                          --! ポートへデータを出力する際のユーザー定義信号.
                          out std_logic_vector(USER_BITS  -1 downto 0);
        O_ERROR         : --! @brief OUTLET PORT ERROR :
                          --! エラー出力.
                          --! * エラーが発生した事を示すフラグ.
                          out std_logic;
        O_LAST          : --! @brief OUTLET PORT DATA LAST :
                          --! 最終ワード信号出力.
                          --! * 最後のワードデータ出力であることを示すフラグ.
                          out std_logic;
        O_VALID         : --! @brief OUTLET PORT VALID :
                          --! 出力ワード有効信号.
                          --! * O_DATA/O_STRB/O_LASTが有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'で上記信号がキューから取
                          --!   り出される.
                          out std_logic;
        O_READY         : --! @brief OUTLET PORT READY :
                          --! 出力レディ信号.
                          --! * キューが次のワードデータを入力出来ることを示す.
                          --! * O_VALID='1'and O_READY='1'で上記信号がキューから
                          --!   取り出される.
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
end AXI4_DATA_PORT;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.QUEUE_REGISTER;
architecture RTL of AXI4_DATA_PORT is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant STRB_BITS      : integer := DATA_BITS/8;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant REGS_LO        : integer := 0;
    constant REGS_DATA_LO   : integer := REGS_LO;
    constant REGS_DATA_HI   : integer := REGS_DATA_LO  + DATA_BITS   - 1;
    constant REGS_STRB_LO   : integer := REGS_DATA_HI  + 1;
    constant REGS_STRB_HI   : integer := REGS_STRB_LO  + DATA_BITS/8 - 1;
    constant REGS_SIZE_LO   : integer := REGS_STRB_HI  + 1;
    constant REGS_SIZE_HI   : integer := REGS_SIZE_LO  + SIZE_BITS   - 1;
    constant REGS_USER_LO   : integer := REGS_SIZE_HI  + 1;
    constant REGS_USER_HI   : integer := REGS_USER_LO  + USER_BITS   - 1;
    constant REGS_LAST_POS  : integer := REGS_USER_HI  + 1;
    constant REGS_ERROR_POS : integer := REGS_LAST_POS + 1;
    constant REGS_HI        : integer := REGS_ERROR_POS;
    constant REGS_BITS      : integer := REGS_HI       + 1;
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
    signal   i_enable   : std_logic;
    signal   o_busy     : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   l_data     : std_logic_vector(DATA_BITS-1 downto 0);
    signal   l_strb     : std_logic_vector(STRB_BITS-1 downto 0);
    signal   l_size     : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   l_user     : std_logic_vector(USER_BITS-1 downto 0);
    signal   l_error    : std_logic;
    signal   l_last     : std_logic;
    signal   l_valid    : std_logic;
    signal   l_ready    : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   m_data     : std_logic_vector(DATA_BITS-1 downto 0);
    signal   m_strb     : std_logic_vector(STRB_BITS-1 downto 0);
    signal   m_size     : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   m_user     : std_logic_vector(USER_BITS-1 downto 0);
    signal   m_error    : std_logic;
    signal   m_last     : std_logic;
    signal   m_valid    : std_logic;
    signal   m_ready    : std_logic;
    signal   m_skip     : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   n_data     : std_logic_vector(DATA_BITS-1 downto 0);
    signal   n_strb     : std_logic_vector(STRB_BITS-1 downto 0);
    signal   n_size     : std_logic_vector(SIZE_BITS-1 downto 0);
    signal   n_user     : std_logic_vector(USER_BITS-1 downto 0);
    signal   n_error    : std_logic;
    signal   n_last     : std_logic;
    signal   n_valid    : std_logic;
    signal   n_ready    : std_logic;
begin
    -------------------------------------------------------------------------------
    -- INTAKE PORT
    -------------------------------------------------------------------------------
    INTAKE_PORT: block
        signal   i_val       : std_logic;
        signal   i_rdy       : std_logic;
        signal   l_val       : std_logic_vector(I_REGS_SIZE downto 0);
        signal   i_word      : std_logic_vector(REGS_HI downto REGS_LO);
        signal   l_word      : std_logic_vector(REGS_HI downto REGS_LO);
    begin
        ---------------------------------------------------------------------------
        -- I_XXXX を i_word にセット
        ---------------------------------------------------------------------------
        i_word(REGS_DATA_HI downto REGS_DATA_LO) <= I_DATA;
        i_word(REGS_STRB_HI downto REGS_STRB_LO) <= I_STRB;
        i_word(REGS_SIZE_HI downto REGS_SIZE_LO) <= I_SIZE;
        i_word(REGS_USER_HI downto REGS_USER_LO) <= I_USER;
        i_word(REGS_LAST_POS)                    <= I_LAST;
        i_word(REGS_ERROR_POS)                   <= I_ERROR;
        i_val   <= '1' when (i_enable = '1' and I_VALID = '1') else '0';
        I_READY <= '1' when (i_enable = '1' and i_rdy   = '1') else '0';
        ---------------------------------------------------------------------------
        -- 出力レジスタ
        ---------------------------------------------------------------------------
        REGS: QUEUE_REGISTER
            generic map (
                QUEUE_SIZE  => I_REGS_SIZE , 
                DATA_BITS   => REGS_BITS   ,
                LOWPOWER    => 0                
            )
            port map (
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK         => CLK         , -- In  :
                RST         => RST         , -- In  :
                CLR         => CLR         , -- In  :
            -----------------------------------------------------------------------
            -- 入力側
            -----------------------------------------------------------------------
                I_DATA      => i_word      , -- In  :
                I_VAL       => i_val       , -- In  :
                I_RDY       => i_rdy       , -- Out :
            -----------------------------------------------------------------------
            -- 出力側
            -----------------------------------------------------------------------
                O_DATA      => open        , -- Out :
                O_VAL       => open        , -- Out :
                Q_DATA      => l_word      , -- Out :
                Q_VAL       => l_val       , -- Out :
                Q_RDY       => l_ready       -- In  :
            );
        l_valid <= l_val(0);
        l_data  <= l_word(REGS_DATA_HI downto REGS_DATA_LO);
        l_strb  <= l_word(REGS_STRB_HI downto REGS_STRB_LO);
        l_size  <= l_word(REGS_SIZE_HI downto REGS_SIZE_LO);
        l_user  <= l_word(REGS_USER_HI downto REGS_USER_LO);
        l_last  <= l_word(REGS_LAST_POS);
        l_error <= l_word(REGS_ERROR_POS);
    end block;
    -------------------------------------------------------------------------------
    -- ASIZE による Narrow transfers を行う場合.
    -------------------------------------------------------------------------------
    NARROW_XFER_T : if (USE_ASIZE /= 0) generate
        ---------------------------------------------------------------------------
        -- データのバイト数の２のべき乗値を計算する関数.
        ---------------------------------------------------------------------------
        function CALC_DATA_WIDTH(WIDTH:integer) return integer is
            variable value : integer;
        begin
            value := 0;
            while (2**(value+3) < WIDTH) loop
                value := value + 1;
            end loop;
            return value;
        end function;
        ---------------------------------------------------------------------------
        -- データのバイト数の２のべき乗値.
        ---------------------------------------------------------------------------
        constant  DATA_WIDTH        : integer := CALC_DATA_WIDTH(DATA_BITS);
        constant  DATA_WIDTH_1BYTE  : integer := 0;
        constant  DATA_WIDTH_2BYTE  : integer := 1;
        constant  DATA_WIDTH_4BYTE  : integer := 2;
        constant  DATA_WIDTH_8BYTE  : integer := 3;
        constant  DATA_WIDTH_16BYTE : integer := 4;
        constant  DATA_WIDTH_32BYTE : integer := 5;
        constant  DATA_WIDTH_64BYTE : integer := 6;
        constant  DATA_WIDTH_128BYTE: integer := 7;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  STRB_ALL0         : std_logic_vector(STRB_BITS-1 downto 0) := (others => '0');
        constant  STRB_ALL1         : std_logic_vector(STRB_BITS-1 downto 0) := (others => '1');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        type      STRB_MASK_TYPE is record
                  enable            : std_logic_vector(STRB_BITS-1 downto 0);
                  remain            : std_logic_vector(STRB_BITS-1 downto 0);
        end record;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  STRB_MASK_ALL1    : STRB_MASK_TYPE := (
                                        enable => STRB_ALL1,
                                        remain => STRB_ALL0
                                    );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        function GEN_STRB_MASK(
                      WORD_POS   : unsigned;  -- 現在の出力中のワード位置
            constant  WORD_BITS  : integer    -- ASIZEで指定された1ワードのバイト数
        )             return       STRB_MASK_TYPE
        is
            variable  STRB_MASK  : STRB_MASK_TYPE;
            constant  N          : integer := STRB_BITS/WORD_BITS;
            constant  ALL1       : std_logic_vector(WORD_BITS-1 downto 0) := (others => '1');
            constant  ALL0       : std_logic_vector(WORD_BITS-1 downto 0) := (others => '0');
        begin
            for i in 0 to N-1 loop
                if (i = WORD_POS) then
                    STRB_MASK.enable(WORD_BITS*(i+1)-1 downto WORD_BITS*i) := ALL1;
                else
                    STRB_MASK.enable(WORD_BITS*(i+1)-1 downto WORD_BITS*i) := ALL0;
                end if;
                if (i > WORD_POS) then
                    STRB_MASK.remain(WORD_BITS*(i+1)-1 downto WORD_BITS*i) := ALL1;
                else
                    STRB_MASK.remain(WORD_BITS*(i+1)-1 downto WORD_BITS*i) := ALL0;
                end if;
            end loop;
            return STRB_MASK;
        end function;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        function  GEN_STRB_MASK(
                      BYTE_POS   : unsigned;  -- 現在の出力中のバイト位置
                      WORD_WIDTH : integer ;  -- ASIZEで指定された1ワードのバイト数(2のべき乗値)
            constant  DATA_WIDTH : integer    -- データ入出力信号のバイト数(2のべき乗値)
        )             return       STRB_MASK_TYPE
        is
        begin
            case DATA_WIDTH is
                when DATA_WIDTH_2BYTE   =>
                    case WORD_WIDTH is
                        when DATA_WIDTH_1BYTE  => return GEN_STRB_MASK(BYTE_POS(0 downto 0),  1);
                        when others            => return STRB_MASK_ALL1;
                    end case;
                when DATA_WIDTH_4BYTE   =>
                    case WORD_WIDTH is
                        when DATA_WIDTH_1BYTE  => return GEN_STRB_MASK(BYTE_POS(1 downto 0),  1);
                        when DATA_WIDTH_2BYTE  => return GEN_STRB_MASK(BYTE_POS(1 downto 1),  2);
                        when others            => return STRB_MASK_ALL1;
                    end case;
                when DATA_WIDTH_8BYTE   =>                               
                    case WORD_WIDTH is
                        when DATA_WIDTH_1BYTE  => return GEN_STRB_MASK(BYTE_POS(2 downto 0),  1);
                        when DATA_WIDTH_2BYTE  => return GEN_STRB_MASK(BYTE_POS(2 downto 1),  2);
                        when DATA_WIDTH_4BYTE  => return GEN_STRB_MASK(BYTE_POS(2 downto 2),  4);
                        when others            => return STRB_MASK_ALL1;
                    end case;
                when DATA_WIDTH_16BYTE  =>                               
                    case WORD_WIDTH is
                        when DATA_WIDTH_1BYTE  => return GEN_STRB_MASK(BYTE_POS(3 downto 0),  1);
                        when DATA_WIDTH_2BYTE  => return GEN_STRB_MASK(BYTE_POS(3 downto 1),  2);
                        when DATA_WIDTH_4BYTE  => return GEN_STRB_MASK(BYTE_POS(3 downto 2),  4);
                        when DATA_WIDTH_8BYTE  => return GEN_STRB_MASK(BYTE_POS(3 downto 3),  8);
                        when others            => return STRB_MASK_ALL1;
                    end case;
                when DATA_WIDTH_32BYTE  =>                               
                    case WORD_WIDTH is
                        when DATA_WIDTH_1BYTE  => return GEN_STRB_MASK(BYTE_POS(4 downto 0),  1);
                        when DATA_WIDTH_2BYTE  => return GEN_STRB_MASK(BYTE_POS(4 downto 1),  2);
                        when DATA_WIDTH_4BYTE  => return GEN_STRB_MASK(BYTE_POS(4 downto 2),  4);
                        when DATA_WIDTH_8BYTE  => return GEN_STRB_MASK(BYTE_POS(4 downto 3),  8);
                        when DATA_WIDTH_16BYTE => return GEN_STRB_MASK(BYTE_POS(4 downto 4), 16);
                        when others            => return STRB_MASK_ALL1;
                    end case;
                when DATA_WIDTH_64BYTE  =>                               
                    case WORD_WIDTH is
                        when DATA_WIDTH_1BYTE  => return GEN_STRB_MASK(BYTE_POS(5 downto 0),  1);
                        when DATA_WIDTH_2BYTE  => return GEN_STRB_MASK(BYTE_POS(5 downto 1),  2);
                        when DATA_WIDTH_4BYTE  => return GEN_STRB_MASK(BYTE_POS(5 downto 2),  4);
                        when DATA_WIDTH_8BYTE  => return GEN_STRB_MASK(BYTE_POS(5 downto 3),  8);
                        when DATA_WIDTH_16BYTE => return GEN_STRB_MASK(BYTE_POS(5 downto 4), 16);
                        when DATA_WIDTH_32BYTE => return GEN_STRB_MASK(BYTE_POS(5 downto 5), 32);
                        when others            => return STRB_MASK_ALL1;
                    end case;
                when DATA_WIDTH_128BYTE =>
                    case WORD_WIDTH is
                        when DATA_WIDTH_1BYTE  => return GEN_STRB_MASK(BYTE_POS(6 downto 0),  1);
                        when DATA_WIDTH_2BYTE  => return GEN_STRB_MASK(BYTE_POS(6 downto 1),  2);
                        when DATA_WIDTH_4BYTE  => return GEN_STRB_MASK(BYTE_POS(6 downto 2),  4);
                        when DATA_WIDTH_8BYTE  => return GEN_STRB_MASK(BYTE_POS(6 downto 3),  8);
                        when DATA_WIDTH_16BYTE => return GEN_STRB_MASK(BYTE_POS(6 downto 4), 16);
                        when DATA_WIDTH_32BYTE => return GEN_STRB_MASK(BYTE_POS(6 downto 5), 32);
                        when DATA_WIDTH_64BYTE => return GEN_STRB_MASK(BYTE_POS(6 downto 6), 64);
                        when others            => return STRB_MASK_ALL1;
                    end case;
                when others                    => return STRB_MASK_ALL1;
            end case;
        end function;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    next_word_width : integer range 0 to    DATA_WIDTH;
        signal    curr_word_width : integer range 0 to    DATA_WIDTH;
        signal    next_word_bytes : integer range 0 to 2**DATA_WIDTH;
        signal    curr_word_bytes : integer range 0 to 2**DATA_WIDTH;
        signal    next_pos        : unsigned(DATA_WIDTH downto 0);
        signal    curr_pos        : unsigned(DATA_WIDTH downto 0);
        signal    strb_mask       : STRB_MASK_TYPE;
        signal    word_last       : boolean;
    begin
        ---------------------------------------------------------------------------
        -- next_word_bytes : 1ワードのバイト数
        -- next_word_width : 1ワードのバイト数(2のべき乗値)
        ---------------------------------------------------------------------------
        process (START, ASIZE, curr_word_bytes, curr_word_width) begin
            if (START = '1') then
                case DATA_WIDTH is
                    when DATA_WIDTH_1BYTE   =>
                                                       next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                    when DATA_WIDTH_2BYTE   =>
                        case ASIZE is
                            when AXI4_ASIZE_1BYTE   => next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                            when others             => next_word_bytes <=  2; next_word_width <= DATA_WIDTH_2BYTE;
                        end case;
                    when DATA_WIDTH_4BYTE   =>
                        case ASIZE is
                            when AXI4_ASIZE_1BYTE   => next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                            when AXI4_ASIZE_2BYTE   => next_word_bytes <=  2; next_word_width <= DATA_WIDTH_2BYTE;
                            when others             => next_word_bytes <=  4; next_word_width <= DATA_WIDTH_4BYTE;
                        end case;
                    when DATA_WIDTH_8BYTE   =>
                        case ASIZE is
                            when AXI4_ASIZE_1BYTE   => next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                            when AXI4_ASIZE_2BYTE   => next_word_bytes <=  2; next_word_width <= DATA_WIDTH_2BYTE;
                            when AXI4_ASIZE_4BYTE   => next_word_bytes <=  4; next_word_width <= DATA_WIDTH_4BYTE;
                            when others             => next_word_bytes <=  8; next_word_width <= DATA_WIDTH_8BYTE;
                        end case;
                    when DATA_WIDTH_16BYTE  =>
                        case ASIZE is
                            when AXI4_ASIZE_1BYTE   => next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                            when AXI4_ASIZE_2BYTE   => next_word_bytes <=  2; next_word_width <= DATA_WIDTH_2BYTE;
                            when AXI4_ASIZE_4BYTE   => next_word_bytes <=  4; next_word_width <= DATA_WIDTH_4BYTE;
                            when AXI4_ASIZE_8BYTE   => next_word_bytes <=  8; next_word_width <= DATA_WIDTH_8BYTE;
                            when others             => next_word_bytes <= 16; next_word_width <= DATA_WIDTH_16BYTE;
                        end case;
                    when DATA_WIDTH_32BYTE  =>
                        case ASIZE is
                            when AXI4_ASIZE_1BYTE   => next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                            when AXI4_ASIZE_2BYTE   => next_word_bytes <=  2; next_word_width <= DATA_WIDTH_2BYTE;
                            when AXI4_ASIZE_4BYTE   => next_word_bytes <=  4; next_word_width <= DATA_WIDTH_4BYTE;
                            when AXI4_ASIZE_8BYTE   => next_word_bytes <=  8; next_word_width <= DATA_WIDTH_8BYTE;
                            when AXI4_ASIZE_16BYTE  => next_word_bytes <= 16; next_word_width <= DATA_WIDTH_16BYTE;
                            when others             => next_word_bytes <= 32; next_word_width <= DATA_WIDTH_32BYTE;
                        end case;
                    when DATA_WIDTH_64BYTE  =>
                        case ASIZE is
                            when AXI4_ASIZE_1BYTE   => next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                            when AXI4_ASIZE_2BYTE   => next_word_bytes <=  2; next_word_width <= DATA_WIDTH_2BYTE;
                            when AXI4_ASIZE_4BYTE   => next_word_bytes <=  4; next_word_width <= DATA_WIDTH_4BYTE;
                            when AXI4_ASIZE_8BYTE   => next_word_bytes <=  8; next_word_width <= DATA_WIDTH_8BYTE;
                            when AXI4_ASIZE_16BYTE  => next_word_bytes <= 16; next_word_width <= DATA_WIDTH_16BYTE;
                            when AXI4_ASIZE_32BYTE  => next_word_bytes <= 32; next_word_width <= DATA_WIDTH_32BYTE;
                            when others             => next_word_bytes <= 64; next_word_width <= DATA_WIDTH_64BYTE;
                        end case;
                    when DATA_WIDTH_128BYTE =>
                        case ASIZE is
                            when AXI4_ASIZE_1BYTE   => next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                            when AXI4_ASIZE_2BYTE   => next_word_bytes <=  2; next_word_width <= DATA_WIDTH_2BYTE;
                            when AXI4_ASIZE_4BYTE   => next_word_bytes <=  4; next_word_width <= DATA_WIDTH_4BYTE;
                            when AXI4_ASIZE_8BYTE   => next_word_bytes <=  8; next_word_width <= DATA_WIDTH_8BYTE;
                            when AXI4_ASIZE_16BYTE  => next_word_bytes <= 16; next_word_width <= DATA_WIDTH_16BYTE;
                            when AXI4_ASIZE_32BYTE  => next_word_bytes <= 32; next_word_width <= DATA_WIDTH_32BYTE;
                            when AXI4_ASIZE_64BYTE  => next_word_bytes <= 64; next_word_width <= DATA_WIDTH_64BYTE;
                            when others             => next_word_bytes <=128; next_word_width <= DATA_WIDTH_128BYTE;
                        end case;
                    when others                     => next_word_bytes <=  1; next_word_width <= DATA_WIDTH_1BYTE;
                end case;
            else
                next_word_bytes <= curr_word_bytes;
                next_word_width <= curr_word_width;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- next_pos  :
        -- word_last : 
        ---------------------------------------------------------------------------
        process (ADDR, START, n_valid, n_ready, curr_pos, curr_word_bytes)
            variable temp_pos  : unsigned(DATA_WIDTH downto 0);
            variable temp_size : AXI4_ASIZE_TYPE;
        begin 
            if (START = '1') then
                for i in next_pos'range loop
                    if (i < DATA_WIDTH and ADDR(i) = '1') then
                        next_pos(i) <= '1';
                    else
                        next_pos(i) <= '0';
                    end if;
                end loop;
                word_last <= FALSE;
            elsif (n_valid = '1' and n_ready = '1') then
                temp_pos  := curr_pos + curr_word_bytes;
                if (to_01(temp_pos) >= 2**DATA_WIDTH) then
                    next_pos  <= (others => '0');
                    word_last <= TRUE;
                else
                    next_pos  <= temp_pos;
                    word_last <= FALSE;
                end if;
            else
                next_pos  <= curr_pos;
                word_last <= FALSE;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- curr_pos  :
        -- strb_mask : 
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_word_bytes <= 0;
                    curr_word_width <= 0;
                    curr_pos        <= (others => '0');
                    strb_mask       <= STRB_MASK_ALL1;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_word_bytes <= 0;
                    curr_word_width <= 0;
                    curr_pos        <= (others => '0');
                    strb_mask       <= STRB_MASK_ALL1;
                else
                    curr_word_bytes <= next_word_bytes;
                    curr_word_width <= next_word_width;
                    curr_pos        <= next_pos;
                    strb_mask       <= GEN_STRB_MASK(
                                           BYTE_POS   => next_pos,
                                           WORD_WIDTH => next_word_width,
                                           DATA_WIDTH => DATA_WIDTH
                                       );
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        m_valid <= l_valid;
        m_data  <= l_data;
        m_user  <= l_user;
        m_error <= l_error;
        m_strb  <= l_strb and strb_mask.enable;
        m_size  <= std_logic_vector(to_unsigned(count_assert_bit(l_strb),m_size'length));
        m_last  <= '1' when (l_last = '1') and
                            ((l_strb and strb_mask.remain) = STRB_ALL0) else '0';
        l_ready <= '1' when (m_ready = '1' and word_last   ) or
                            (m_ready = '1' and m_last = '1') or
                            (m_skip  = '1') else '0';
    end generate;
    -------------------------------------------------------------------------------
    -- ASIZE による Narrow transfers 行わない場合.
    -------------------------------------------------------------------------------
    NARROW_XFER_F : if (USE_ASIZE = 0) generate
        m_valid <= l_valid;
        m_data  <= l_data;
        m_strb  <= l_strb;
        m_size  <= l_size;
        m_user  <= l_user;
        m_last  <= l_last;
        m_error <= l_error;
        l_ready <= '1' when (m_ready = '1' or m_skip = '1') else '0';
    end generate;
    -------------------------------------------------------------------------------
    -- CHECK_ALEN によるバースト長のチェックを行う場合の制御部
    -------------------------------------------------------------------------------
    CHECK_ALEN_T: if (CHECK_ALEN /= 0 or USE_ASIZE /= 0) generate
        type     STATE_TYPE  is (IDLE_STATE, XFER_STATE, DUMMY_STATE, SKIP_STATE);
        signal   curr_state  : STATE_TYPE;
        signal   curr_length : std_logic_vector(ALEN'range);
    begin
        process (CLK, RST)
            variable temp_length : unsigned(curr_length'high downto 0);
            variable next_length : unsigned(curr_length'high downto 0);
            variable m_done      : boolean;
        begin
            if (RST = '1') then
                    curr_state  <= IDLE_STATE;
                    curr_length <= (others => '0');
                    n_last      <= '1';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_state  <= IDLE_STATE;
                    curr_length <= (others => '0');
                    n_last      <= '1';
                else
                    m_done := (m_last = '1' or m_error = '1');
                    case curr_state is
                        when IDLE_STATE =>
                            if (START = '1') then
                                curr_state <= XFER_STATE;
                            else
                                curr_state <= IDLE_STATE;
                            end if;
                        when XFER_STATE =>
                            if (n_valid = '1' and n_ready = '1') then
                                if    (n_last = '1' and m_done = TRUE ) then
                                    curr_state <= IDLE_STATE;
                                elsif (n_last = '0' and m_done = TRUE ) then
                                    curr_state <= DUMMY_STATE;
                                elsif (n_last = '1' and m_done = FALSE) then
                                    curr_state <= SKIP_STATE;
                                else
                                    curr_state <= XFER_STATE;
                                end if;
                            else
                                    curr_state <= XFER_STATE;
                            end if;
                        when DUMMY_STATE =>
                            if (n_valid = '1' and n_ready = '1') then
                                if (n_last = '1') then
                                    curr_state <= IDLE_STATE;
                                else
                                    curr_state <= DUMMY_STATE;
                                end if;
                            else
                                    curr_state <= DUMMY_STATE;
                            end if;
                        when SKIP_STATE =>
                            if (m_valid = '1' and m_done = TRUE) then
                                    curr_state <= IDLE_STATE;
                            else
                                    curr_state <= SKIP_STATE;
                            end if;
                        when others  =>
                            curr_state <= IDLE_STATE;
                    end case;
                end if;
                if (curr_state = IDLE_STATE and START = '1') then
                    temp_length := unsigned(ALEN);
                else
                    temp_length := unsigned(curr_length);
                end if;
                if (n_valid = '1' and n_ready = '1' and temp_length > 0) then
                    next_length := temp_length - 1;
                else
                    next_length := temp_length;
                end if;
                if (next_length = 0) then
                    n_last <= '1';
                else
                    n_last <= '0';
                end if;
                curr_length <= std_logic_vector(next_length);
            end if;
        end process;
        n_data   <= m_data;
        n_user   <= m_user;
        n_error  <= m_error;
        n_strb   <= m_strb when (curr_state = XFER_STATE ) else (others => '0');
        n_size   <= m_size when (curr_state = XFER_STATE ) else (others => '0');
        n_valid  <= '1'    when (curr_state = XFER_STATE and m_valid = '1') or
                                (curr_state = DUMMY_STATE) else '0';
        m_ready  <= '1'    when (curr_state = XFER_STATE and n_ready = '1') else '0';
        m_skip   <= '1'    when (curr_state = SKIP_STATE ) else '0';
        i_enable <= '1'    when (curr_state = XFER_STATE ) or
                                (curr_state = SKIP_STATE ) else '0';
        BUSY     <= '1'    when (curr_state = XFER_STATE ) or
                                (curr_state = DUMMY_STATE) or
                                (curr_state = SKIP_STATE ) or
                                (o_busy     = '1'        ) else '0';
    end generate;
    -------------------------------------------------------------------------------
    -- CHECK_ALEN によるバースト長のチェックを行わない場合の制御部
    -------------------------------------------------------------------------------
    CHECK_ALEN_F: if (CHECK_ALEN = 0 and USE_ASIZE = 0) generate
        type     STATE_TYPE  is (IDLE_STATE, XFER_STATE);
        signal   curr_state  : STATE_TYPE;
    begin
        process (CLK, RST)
            variable m_done : boolean;
        begin
            if (RST = '1') then
                    curr_state  <= IDLE_STATE;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_state  <= IDLE_STATE;
                else
                    m_done := (m_last = '1' or m_error = '1');
                    case curr_state is
                        when IDLE_STATE =>
                            if (START = '1') then
                                curr_state <= XFER_STATE;
                            else
                                curr_state <= IDLE_STATE;
                            end if;
                        when XFER_STATE =>
                            if (m_valid = '1' and m_ready = '1' and m_done = TRUE) then
                                curr_state <= IDLE_STATE;
                            else
                                curr_state <= XFER_STATE;
                            end if;
                        when others =>
                                curr_state <= IDLE_STATE;
                    end case;
                end if;
            end if;
        end process;
        n_data   <= m_data;
        n_user   <= m_user;
        n_last   <= m_last;
        n_error  <= m_error;
        n_strb   <= m_strb;
        n_size   <= m_size;
        n_valid  <= m_valid;
        m_ready  <= n_ready;
        m_skip   <= '0';
        i_enable <= '1' when (curr_state = XFER_STATE ) else '0';
        BUSY     <= '1' when (curr_state = XFER_STATE ) or
                             (o_busy     = '1'        ) else '0';
    end generate;
    -------------------------------------------------------------------------------
    -- OUTLET PORT
    -------------------------------------------------------------------------------
    OUTLET_PORT: block
        signal   n_word      : std_logic_vector(REGS_HI downto REGS_LO);
        signal   o_word      : std_logic_vector(REGS_HI downto REGS_LO);
        signal   o_val       : std_logic_vector(O_REGS_SIZE downto 0);
    begin
        ---------------------------------------------------------------------------
        -- n_xxxx を n_word にセット
        ---------------------------------------------------------------------------
        n_word(REGS_DATA_HI downto REGS_DATA_LO) <= n_data;
        n_word(REGS_STRB_HI downto REGS_STRB_LO) <= n_strb;
        n_word(REGS_SIZE_HI downto REGS_SIZE_LO) <= n_size;
        n_word(REGS_USER_HI downto REGS_USER_LO) <= n_user;
        n_word(REGS_LAST_POS)                    <= n_last;
        n_word(REGS_ERROR_POS)                   <= n_error;
        ---------------------------------------------------------------------------
        -- 出力レジスタ
        ---------------------------------------------------------------------------
        REGS: QUEUE_REGISTER
            generic map (
                QUEUE_SIZE  => O_REGS_SIZE , 
                DATA_BITS   => REGS_BITS   ,
                LOWPOWER    => 0                
            )
            port map (
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK         => CLK         , -- In  :
                RST         => RST         , -- In  :
                CLR         => CLR         , -- In  :
            -----------------------------------------------------------------------
            -- 入力側
            -----------------------------------------------------------------------
                I_DATA      => n_word      , -- In  :
                I_VAL       => n_valid     , -- In  :
                I_RDY       => n_ready     , -- Out :
            -----------------------------------------------------------------------
            -- 出力側
            -----------------------------------------------------------------------
                O_DATA      => open        , -- Out :
                O_VAL       => open        , -- Out :
                Q_DATA      => o_word      , -- Out :
                Q_VAL       => o_val       , -- Out :
                Q_RDY       => O_READY       -- In  :
            );
        o_busy  <= o_val(0);
        o_valid <= o_val(0);
        O_DATA  <= o_word(REGS_DATA_HI downto REGS_DATA_LO);
        O_STRB  <= o_word(REGS_STRB_HI downto REGS_STRB_LO);
        O_SIZE  <= o_word(REGS_SIZE_HI downto REGS_SIZE_LO);
        O_USER  <= o_word(REGS_USER_HI downto REGS_USER_LO);
        O_LAST  <= o_word(REGS_LAST_POS);
        O_ERROR <= o_word(REGS_ERROR_POS);
    end block;
end RTL;
