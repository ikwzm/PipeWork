-----------------------------------------------------------------------------------
--!     @file    image_window_fast_scan_buffer.vhd
--!     @brief   Image Window Fast Scan Buffer MODULE :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2018/12/7
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018 Ichiro Kawazome
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
use     PIPEWORK.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   IMAGE_WINDOW_FAST_SCAN_BUFFER :
--!          列方向のバッファ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_FAST_SCAN_BUFFER is
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          --! I_PARAM.SHAPE.C.SIZE = O_PARAM.SHAPE.C.SIZE でなければならない.
                          --! I_PARAM.SHAPE.Y.SIZE = 1 でなければならない.
                          --! I_PARAM.SHAPE.X.SIZE = I_PARAM.STRIDE.X     でなければならない.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          --! I_PARAM.SHAPE.C.SIZE = O_PARAM.SHAPE.C.SIZE でなければならない.
                          --! O_PARAM.SHAPE.Y.SIZE = 1 でなければならない.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        MEM_BANK_SIZE   : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        ID              : --! @brief SDPRAM IDENTIFIER :
                          --! どのモジュールで使われているかを示す識別番号.
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_START         : --! @brief INPUT START REQUEST :
                          --! 入力開始信号.
                          --! * I_ENABLE = '1' の時、この信号をアサートすることで
                          --!   入力を開始する.
                          in  std_logic := '1';
        I_ENABLE        : --! @brief INPUT ENABLE :
                          --! 入力開始可能信号.
                          --! * 入力開始可能状態であることを示す信号.
                          out std_logic;
        I_DATA          : --! @brief INPUT WINDOW DATA :
                          --! ウィンドウデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT WINDOW DATA VALID :
                          --! 入力ウィンドウデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でウィンドウデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT WINDOW DATA READY :
                          --! 入力ウィンドウデータレディ信号.
                          --! * キューが次のウィンドウデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でウィンドウデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_FEED          : --! @brief OUTPUT FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic := '1';
        O_RETURN        : --! @brief OUTPUT RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic := '1';
        O_DATA          : --! @brief OUTPUT WINDOW DATA :
                          --! ウィンドウデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT WINDOW DATA VALID :
                          --! 出力ウィンドウデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でウィンドウデータがキュー
                          --!   から取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT WINDOW DATA READY :
                          --! 出力ウィンドウデータレディ信号.
                          --! * キューから次のウィンドウデータを取り除く準備が出来て
                          --!   いることを示す.
                          --! * O_VALID='1'and O_READY='1'でウィンドウデータがキュー
                          --!   から取り除かれる.
                          in  std_logic
    );
end IMAGE_WINDOW_FAST_SCAN_BUFFER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture RTL of IMAGE_WINDOW_FAST_SCAN_BUFFER is
    -------------------------------------------------------------------------------
    -- メモリのバンク数
    -------------------------------------------------------------------------------
    constant  BANK_SIZE             :  integer := MEM_BANK_SIZE;
    -------------------------------------------------------------------------------
    -- メモリのビット幅
    -------------------------------------------------------------------------------
    function  CALC_BUF_WIDTH    return integer is
        variable width              :  integer;
    begin
        width := 0;
        while (2**width < (O_PARAM.SHAPE.C.SIZE * O_PARAM.ELEM_BITS)) loop
            width := width + 1;
        end loop;
        return width;
    end function;
    constant  BUF_WIDTH             :  integer := CALC_BUF_WIDTH;
    -------------------------------------------------------------------------------
    -- メモリバンク１つあたりの深さ(ビット単位)を２のべき乗値で示す
    -------------------------------------------------------------------------------
    function  CALC_BUF_DEPTH    return integer is
        variable size               :  integer;
        variable depth              :  integer;
    begin
        size := ELEMENT_SIZE*O_PARAM.ELEM_BITS;
        size := (size + BANK_SIZE - 1)/BANK_SIZE;
        depth := 0;
        while (2**depth < size) loop
            depth := depth + 1;
        end loop;
        return depth;
    end function;
    constant  BUF_DEPTH             :  integer := CALC_BUF_DEPTH;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   BANK_STATE_TYPE       is std_logic_vector(0 to BANK_SIZE-1);
    type      BANK_STATE_VECTOR     is array(integer range <>) of BANK_STATE_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  INIT_BANK_STATE(LO,HI: integer) return BANK_STATE_VECTOR is
        variable i_vec :  BANK_STATE_VECTOR(LO to HI);
    begin
        for i in i_vec'range loop
            for bank in 0 to BANK_SIZE-1 loop
                if (i-LO = bank) then
                    i_vec(i)(bank) := '1';
                else
                    i_vec(i)(bank) := '0';
                end if;
            end loop;
        end loop;
        return i_vec;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  STRIDE_BANK_STATE(I_VEC: BANK_STATE_VECTOR; STRIDE: integer) return BANK_STATE_VECTOR is
        variable o_vec :  BANK_STATE_VECTOR(I_VEC'range);
    begin
        for i in o_vec'range loop
            for bank in 0 to BANK_SIZE-1 loop
                o_vec(i)(bank) := I_VEC(i)((BANK_SIZE+bank-STRIDE) mod BANK_SIZE);
            end loop;
        end loop;
        return o_vec;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  IS_LAST_BANK(BANK_STATE: BANK_STATE_TYPE; STRIDE: integer) return boolean is
        variable last :  boolean;
    begin
        last := FALSE;
        for bank in BANK_SIZE-1 downto BANK_SIZE-STRIDE loop
            if (BANK_STATE(bank) = '1') then
                last := TRUE;
            end if;
        end loop;
        return last;
    end function;
    function  IS_LAST_BANK(I_VEC: BANK_STATE_VECTOR; STRIDE: integer) return boolean is
    begin
        return IS_LAST_BANK(I_VEC(I_VEC'low), STRIDE);
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype   BUF_DATA_TYPE         is std_logic_vector(2**BUF_WIDTH-1 downto 0);
    type      BUF_DATA_VECTOR       is array(integer range <>) of BUF_DATA_TYPE;
    subtype   BUF_ADDR_TYPE         is std_logic_vector(BUF_DEPTH-BUF_WIDTH-1 downto 0);
    type      BUF_ADDR_VECTOR       is array(integer range <>) of BUF_ADDR_TYPE;
    subtype   BUF_WENA_TYPE         is std_logic_vector(0 downto 0);
    type      BUF_WENA_VECTOR       is array(integer range <>) of BUF_WENA_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  NEXT_BUF_ADDR(
                  BUF_ADDR          :  BUF_ADDR_VECTOR;
                  BANK_STATE        :  BANK_STATE_VECTOR;
                  BASE_ADDR         :  integer;
                  CHANNEL_COUNT     :  integer;
                  START_CHANNEL     :  std_logic
              )   return               BUF_ADDR_VECTOR
    is
        variable  next_addr_vector  :  BUF_ADDR_VECTOR(BUF_ADDR'range);
        variable  base_curr_addr    :  BUF_ADDR_TYPE;
        variable  base_next_addr    :  BUF_ADDR_TYPE;
        variable  select_next_addr  :  boolean;
    begin
        if (START_CHANNEL = '1') then
            base_curr_addr := std_logic_vector(to_unsigned(BASE_ADDR                , BUF_ADDR_TYPE'length));
            base_next_addr := std_logic_vector(to_unsigned(BASE_ADDR + CHANNEL_COUNT, BUF_ADDR_TYPE'length));
            select_next_addr      := TRUE;
            for bank in next_addr_vector'range loop
                if (select_next_addr = TRUE and BANK_STATE(BANK_STATE'low)(bank) = '1') then
                    select_next_addr := FALSE;
                end if;
                if (select_next_addr = TRUE) then
                    next_addr_vector(bank) := base_next_addr;
                else
                    next_addr_vector(bank) := base_curr_addr;
                end if;
            end loop;
        else
            for bank in next_addr_vector'range loop
                next_addr_vector(bank) := std_logic_vector(unsigned(BUF_ADDR(bank)) + 1);
            end loop;
        end if;
        return next_addr_vector;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    buf_we                :  BUF_WENA_VECTOR(0 to BANK_SIZE-1);
    signal    buf_waddr             :  BUF_ADDR_VECTOR(0 to BANK_SIZE-1);
    signal    buf_wdata             :  BUF_DATA_VECTOR(0 to BANK_SIZE-1);
    signal    buf_raddr             :  BUF_ADDR_VECTOR(0 to BANK_SIZE-1);
    signal    buf_rdata             :  BUF_DATA_VECTOR(0 to BANK_SIZE-1);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_x_count        :  integer range 0 to ELEMENT_SIZE;
    signal    intake_channel_count  :  integer range 0 to ELEMENT_SIZE;
    signal    intake_last_atrb_c    :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_start_c        :  std_logic;
    signal    intake_last_c         :  std_logic;
    signal    intake_start_x        :  std_logic;
    signal    intake_last_x         :  std_logic;
    signal    intake_valid_y        :  std_logic;
    signal    intake_valid          :  std_logic;
    signal    intake_ready          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    outlet_valid          :  std_logic;
    signal    outlet_ready          :  std_logic;
    signal    outlet_start_c        :  std_logic;
    signal    outlet_last_c         :  std_logic;
    signal    outlet_start_x        :  std_logic;
    signal    outlet_last_x         :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE            is (IDLE_STATE  ,
                                        INTAKE_STATE,
                                        OUTLET_START_STATE,
                                        OUTLET_STATE,
                                        OUTLET_DONE_STATE);
    signal    curr_state            :  STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    -- curr_state :
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_state <= IDLE_STATE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_state <= IDLE_STATE;
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (I_START = '1') then
                            curr_state <= INTAKE_STATE;
                        else
                            curr_state <= IDLE_STATE;
                        end if;
                    when INTAKE_STATE =>
                        if (intake_valid = '1' and intake_ready = '1' and intake_last_x = '1' and intake_last_c = '1') then
                            curr_state <= OUTLET_START_STATE;
                        else
                            curr_state <= INTAKE_STATE;
                        end if;
                    when OUTLET_START_STATE =>
                            curr_state <= OUTLET_STATE;
                    when OUTLET_STATE =>
                        if    (O_RETURN = '1') then
                            curr_state <= OUTLET_START_STATE;
                        elsif (O_FEED   = '1') then
                            curr_state <= OUTLET_DONE_STATE;
                        else
                            curr_state <= OUTLET_STATE;
                        end if;
                    when OUTLET_DONE_STATE =>
                        curr_state <= IDLE_STATE;
                    when others     =>
                        curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- I_ENABLE       :
    -------------------------------------------------------------------------------
    I_ENABLE     <= '1' when (curr_state = IDLE_STATE  ) else '0';
    -------------------------------------------------------------------------------
    -- I_READY        :
    -- intake_ready   : 
    -------------------------------------------------------------------------------
    intake_ready <= '1' when (curr_state = INTAKE_STATE) else '0';
    I_READY      <= '1' when (curr_state = INTAKE_STATE) else '0';
    -------------------------------------------------------------------------------
    -- 入力側ブロック
    -------------------------------------------------------------------------------
    INTAKE: block
        signal    channel_count     :  integer range 0 to ELEMENT_SIZE;
        signal    base_addr         :  integer range 0 to (ELEMENT_SIZE+BANK_SIZE-1)/BANK_SIZE;
        signal    bank_state        :  BANK_STATE_VECTOR(I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI);
    begin 
        ---------------------------------------------------------------------------
        -- 入力データの各種属性
        ---------------------------------------------------------------------------
        -- intake_start_c : 
        -- intake_last_c  : 
        -- intake_start_x : 
        -- intake_last_x  : 
        -- intake_valid_y : 
        ---------------------------------------------------------------------------
        process (I_DATA) 
            variable atrb_y  :  IMAGE_ATRB_TYPE;
        begin
            if (IMAGE_WINDOW_DATA_IS_START_C(PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
                intake_start_c <= '1';
            else
                intake_start_c <= '0';
            end if;
            if (IMAGE_WINDOW_DATA_IS_LAST_C( PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
                intake_last_c  <= '1';
            else
                intake_last_c  <= '0';
            end if;
            if (IMAGE_WINDOW_DATA_IS_START_X(PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
                intake_start_x <= '1';
            else
                intake_start_x <= '0';
            end if;
            if (IMAGE_WINDOW_DATA_IS_LAST_X( PARAM => I_PARAM, DATA => I_DATA, VALID => TRUE)) then
                intake_last_x  <= '1';
            else
                intake_last_x  <= '0';
            end if;
            atrb_y := GET_ATRB_Y_FROM_IMAGE_WINDOW_DATA(
                          PARAM => I_PARAM,
                          Y     => I_PARAM.SHAPE.Y.LO,
                          DATA  => I_DATA
                      );
            if (atrb_y.VALID = TRUE) then
                intake_valid_y <= '1';
            else
                intake_valid_y <= '0';
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- intake_valid : 
        ---------------------------------------------------------------------------
        intake_valid <= '1' when (I_VALID = '1' and intake_valid_y = '1') else '0';
        ---------------------------------------------------------------------------
        -- CHANNEL_SIZE が可変長の場合
        ---------------------------------------------------------------------------
        -- channel_count        : 
        -- intake_channel_count :
        -- intake_last_atrb_c   : 
        ---------------------------------------------------------------------------
        CHANNEL_SIZE_EQ_0: if (CHANNEL_SIZE = 0) generate
        begin
            process(intake_channel_count, intake_start_x, intake_start_c) begin
                if (intake_start_x = '1') then
                    if (intake_start_c = '1') then
                        channel_count <= 1;
                    else
                        channel_count <= intake_channel_count + 1;
                    end if;
                else
                        channel_count <= intake_channel_count;
                end if;
            end process;
            process (CLK, RST) begin
                if (RST = '1') then
                        intake_channel_count <= 0;
                        intake_last_atrb_c   <= (others => (VALID => FALSE, START => FALSE, LAST => FALSE));
                elsif (CLK'event and CLK = '1') then
                    if (CLR = '1' or curr_state = IDLE_STATE) then
                        intake_channel_count <= 0;
                        intake_last_atrb_c   <= (others => (VALID => FALSE, START => FALSE, LAST => FALSE));
                    elsif (intake_valid = '1' and intake_ready = '1' and intake_start_x = '1') then
                        intake_channel_count <= channel_count;
                        if (intake_last_c = '1') then
                            intake_last_atrb_c <= GET_ATRB_C_VECTOR_FROM_IMAGE_WINDOW_DATA(I_PARAM, I_DATA);
                        end if;
                    end if;
                end if;
            end process;
        end generate;
        ---------------------------------------------------------------------------
        -- CHANNEL_SIZE が固定値の場合
        ---------------------------------------------------------------------------
        -- channel_count        : 
        -- intake_channel_count :
        -- intake_last_atrb_c   : 
        ---------------------------------------------------------------------------
        CHANNEL_SIZE_GT_0: if (CHANNEL_SIZE > 0) generate
            function CALC_CHANNEL_COUNT return integer is
            begin
                return (CHANNEL_SIZE + O_PARAM.SHAPE.C.SIZE - 1)  /  O_PARAM.SHAPE.C.SIZE;
            end function;
            function CALC_LAST_ATRB_C return IMAGE_ATRB_VECTOR is
                variable  channel_count     :  integer;
                variable  channel_last_pos  :  integer;
                variable  last_atrb_c       :  IMAGE_ATRB_VECTOR(0 to I_PARAM.SHAPE.C.SIZE-1);
            begin
                channel_count    := (CHANNEL_SIZE + O_PARAM.SHAPE.C.SIZE - 1)  /  O_PARAM.SHAPE.C.SIZE;
                channel_last_pos := (CHANNEL_SIZE + O_PARAM.SHAPE.C.SIZE - 1) mod O_PARAM.SHAPE.C.SIZE;
                for c_pos in last_atrb_c'range loop
                    last_atrb_c(c_pos).VALID := (c_pos <= channel_last_pos);
                    last_atrb_c(c_pos).LAST  := (c_pos >= channel_last_pos);
                    last_atrb_c(c_pos).START := (c_pos = 0 and channel_count = 1);
                end loop;
                return last_atrb_c;
            end function;
        begin
            channel_count        <= CALC_CHANNEL_COUNT;
            intake_channel_count <= CALC_CHANNEL_COUNT;
            intake_last_atrb_c   <= CALC_LAST_ATRB_C;
        end generate;
        ---------------------------------------------------------------------------
        -- intake_x_count :
        ---------------------------------------------------------------------------
        process(CLK, RST)
            variable  atrb_x_vector  :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI);
            function  CALC_X_COUNT(
                          PARAM      :  IMAGE_WINDOW_PARAM_TYPE;
                          ATRB_VEC   :  IMAGE_ATRB_VECTOR)
                          return        integer
            is
                alias     i_atrb_vec :  IMAGE_ATRB_VECTOR(0 to ATRB_VEC'length-1) is ATRB_VEC;
                variable  count      :  integer range 0 to PARAM.SHAPE.X.SIZE;
            begin
                if (i_atrb_vec'length = 1) then
                    if (i_atrb_vec(0).VALID = TRUE) then
                        count := 1;
                    else
                        count := 0;
                    end if;
                else
                    count := CALC_X_COUNT(PARAM, i_atrb_vec(0                   to i_atrb_vec'high/2))
                           + CALC_X_COUNT(PARAM, i_atrb_vec(i_atrb_vec'high/2+1 to i_atrb_vec'high  ));
                end if;
                return count;
            end function;
        begin 
            if (RST = '1') then
                    intake_x_count <= 0;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or curr_state = IDLE_STATE) then
                    intake_x_count <= 0;
                elsif (intake_valid = '1' and intake_ready = '1' and intake_last_c = '1') then
                    atrb_x_vector  := GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(I_PARAM, I_DATA);
                    intake_x_count <= intake_x_count + CALC_X_COUNT(I_PARAM, atrb_x_vector);
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- bank_state  :
        -- base_addr   :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin 
            if (RST = '1') then
                    bank_state  <= INIT_BANK_STATE(I_PARAM.SHAPE.X.LO, I_PARAM.SHAPE.X.HI);
                    base_addr   <= 0;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or curr_state = IDLE_STATE) then
                    bank_state  <= INIT_BANK_STATE(I_PARAM.SHAPE.X.LO, I_PARAM.SHAPE.X.HI);
                    base_addr   <= 0;
                else
                    if (intake_valid = '1' and intake_ready = '1' and intake_last_c = '1') then
                        if (IS_LAST_BANK(bank_state, I_PARAM.STRIDE.X) = TRUE) then
                            base_addr <= base_addr + channel_count;
                        end if;
                        bank_state <= STRIDE_BANK_STATE(bank_state, I_PARAM.STRIDE.X);
                    end if;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- buf_we    :
        -- buf_waddr :
        ---------------------------------------------------------------------------
        process(CLK, RST)
            variable  atrb_x_vec  :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI);
            variable  bank_we     :  std_logic_vector(0 to BANK_SIZE-1);
            variable  addr_next   :  boolean;
            variable  start_addr  :  integer range 0 to ELEMENT_SIZE;
        begin 
            if (RST = '1') then
                    buf_we    <= (others => (others => '0'));
                    buf_waddr <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    buf_we    <= (others => (others => '0'));
                    buf_waddr <= (others => (others => '0'));
                elsif (intake_valid = '1' and intake_ready = '1') then
                    atrb_x_vec := GET_ATRB_X_VECTOR_FROM_IMAGE_WINDOW_DATA(I_PARAM, I_DATA);
                    for bank in buf_we'range loop
                        bank_we(bank) := '0';
                        for x_pos in bank_state'range loop
                            if (bank_state(x_pos)(bank) = '1' and atrb_x_vec(x_pos).VALID = TRUE) then
                                bank_we(bank) := bank_we(bank) or '1';
                            end if;
                        end loop;
                        if (bank_we(bank) = '1') then
                            buf_we(bank) <= (others => '1');
                        else
                            buf_we(bank) <= (others => '0');
                        end if;
                    end loop;
                    buf_waddr <= NEXT_BUF_ADDR(
                                     BUF_ADDR      => buf_waddr     ,
                                     BANK_STATE    => bank_state    ,
                                     BASE_ADDR     => base_addr     ,
                                     CHANNEL_COUNT => channel_count ,
                                     START_CHANNEL => intake_start_c
                                 );
                else
                    buf_we <= (others => (others => '0'));
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- buf_wdata : 
        ---------------------------------------------------------------------------
        process(CLK, RST)
            constant  TMP_PARAM :  IMAGE_WINDOW_PARAM_TYPE
                                := NEW_IMAGE_WINDOW_PARAM(
                                       ELEM_BITS => I_PARAM.ELEM_BITS,
                                       C         => I_PARAM.SHAPE.C,
                                       X         => NEW_IMAGE_VECTOR_RANGE(1),
                                       Y         => NEW_IMAGE_VECTOR_RANGE(1)
                                   );
            variable  tmp_data  :  std_logic_vector(TMP_PARAM.DATA.SIZE-1 downto 0);
            variable  element   :  std_logic_vector(TMP_PARAM.ELEM_BITS-1 downto 0);
            variable  buf_data  :  BUF_DATA_TYPE;
            variable  x_sel     :  std_logic_vector(0 to I_PARAM.SHAPE.X.SIZE-1);
        begin 
            if (RST = '1') then
                    buf_wdata <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    buf_wdata <= (others => (others => '0'));
                else
                    for bank in 0 to BANK_SIZE-1 loop
                        buf_data := (others => '0');
                        tmp_data := (others => '0');
                        for x_pos in I_PARAM.SHAPE.X.LO to I_PARAM.SHAPE.X.HI loop
                            if (bank_state(x_pos)(bank) = '1') then
                                for c_pos in I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI loop
                                    element := GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                                   PARAM   => I_PARAM,
                                                   C       => c_pos,
                                                   X       => x_pos,
                                                   Y       => I_PARAM.SHAPE.Y.LO,
                                                   DATA    => I_DATA
                                                );
                                    SET_ELEMENT_TO_IMAGE_WINDOW_DATA(
                                                   PARAM   => TMP_PARAM,
                                                   C       => c_pos,
                                                   X       => 0,
                                                   Y       => 0,
                                                   ELEMENT => element,
                                                   DATA    => tmp_data
                                    );
                                end loop;
                                buf_data := buf_data or tmp_data(TMP_PARAM.DATA.ELEM_FIELD.HI downto TMP_PARAM.DATA.ELEM_FIELD.LO);
                            end if;
                        end loop;
                        buf_wdata(bank) <= buf_data;
                    end loop;
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    MEM: for i in 0 to BANK_SIZE-1 generate   -- 
        U: SDPRAM                                 -- 
            generic map (                         -- 
                DEPTH   => BUF_DEPTH            , -- メモリの深さ(ビット単位)を2のべき乗値で指定する.
                RWIDTH  => BUF_WIDTH            , -- リードデータ(RDATA)の幅(ビット数)を2のべき乗値で指定する.
                WWIDTH  => BUF_WIDTH            , -- ライトデータ(WDATA)の幅(ビット数)を2のべき乗値で指定する.
                WEBIT   => 0                    , -- ライトイネーブル信号(WE)の幅(ビット数)を2のべき乗値で指定する.
                ID      => (ID*BANK_SIZE)+i       -- どのモジュールで使われているかを示す識別番号.
            )
            port map (
                WCLK    => CLK                  , -- In  :
                WE      => buf_we(i)            , -- In  : 
                WADDR   => buf_waddr(i)         , -- In  : 
                WDATA   => buf_wdata(i)         , -- In  : 
                RCLK    => CLK                  , -- In  :
                RADDR   => buf_raddr(i)         , -- In  :
                RDATA   => buf_rdata(i)           -- Out :
            );                                    -- 
    end generate;                                 -- 
    -------------------------------------------------------------------------------
    -- 入力側ブロック
    -------------------------------------------------------------------------------
    OUTLET: block
        signal    bank_state        :  BANK_STATE_VECTOR(O_PARAM.SHAPE.X.LO to O_PARAM.SHAPE.X.HI);
        signal    base_addr         :  integer range 0 to (ELEMENT_SIZE+BANK_SIZE-1)/BANK_SIZE;
        signal    curr_buf_raddr    :  BUF_ADDR_VECTOR(0 to BANK_SIZE-1);
        signal    channel_pos     :  integer range 0 to ELEMENT_SIZE;
    begin
        ---------------------------------------------------------------------------
        -- bank_state  :
        -- base_addr   :
        ---------------------------------------------------------------------------
        process(CLK, RST) begin 
            if (RST = '1') then
                    bank_state  <= INIT_BANK_STATE(O_PARAM.SHAPE.X.LO, O_PARAM.SHAPE.X.HI);
                    base_addr   <= 0;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or curr_state = IDLE_STATE) then
                    bank_state  <= INIT_BANK_STATE(O_PARAM.SHAPE.X.LO, O_PARAM.SHAPE.X.HI);
                    base_addr   <= 0;
                else
                    if (outlet_valid = '1' and outlet_ready = '1' and outlet_last_c = '1') then
                        if (IS_LAST_BANK(bank_state, O_PARAM.STRIDE.X) = TRUE) then
                            base_addr <= base_addr + intake_channel_count;
                        end if;
                        bank_state <= STRIDE_BANK_STATE(bank_state, O_PARAM.STRIDE.X);
                    end if;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- buf_raddr :
        ---------------------------------------------------------------------------
        process (bank_state, curr_buf_raddr, base_addr, intake_channel_count, outlet_valid, outlet_ready, outlet_start_c) begin
            if (outlet_valid = '1' and outlet_ready = '1') then
                buf_raddr <= NEXT_BUF_ADDR(
                                 BUF_ADDR      => curr_buf_raddr       ,
                                 BANK_STATE    => bank_state           ,
                                 BASE_ADDR     => base_addr            ,
                                 CHANNEL_COUNT => intake_channel_count ,
                                 START_CHANNEL => outlet_start_c
                             );
            else
                buf_raddr <= curr_buf_raddr;
            end if;
        end process;
        process(CLK, RST) begin 
            if (RST = '1') then
                    curr_buf_raddr <= (others => (others => '0'));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_buf_raddr <= (others => (others => '0'));
                else
                    curr_buf_raddr <= buf_raddr;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- channel_pos    :
        -- outlet_start_c :
        -- outlet_last_c  :
        ---------------------------------------------------------------------------
        process(CLK, RST)
            variable next_pos :  integer range 0 to ELEMENT_SIZE;
        begin 
            if (RST = '1') then
                    channel_pos    <=  0 ;
                    outlet_start_c <= '1';
                    outlet_last_c  <= '1';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    channel_pos    <=  0 ;
                    outlet_start_c <= '1';
                    outlet_last_c  <= '1';
                else
                    if (curr_state = OUTLET_START_STATE) then
                        next_pos := 0;
                    elsif (outlet_valid = '1' and outlet_ready = '1') then
                        if (channel_pos >= intake_channel_count-1) then
                            next_pos := 0;
                        else
                            next_pos := channel_pos + 1;
                        end if;
                    else
                        next_pos := channel_pos;
                    end if;
                    if (next_pos = 0) then
                        outlet_start_c <= '1';
                    else
                        outlet_start_c <= '0';
                    end if;
                    if (next_pos  >= intake_channel_count-1) then
                        outlet_last_c  <= '1';
                    else
                        outlet_last_c  <= '0';
                    end if;
                    channel_pos <= next_pos;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        outlet_valid  <= '1' when (curr_state = OUTLET_STATE) else '0';
        outlet_ready  <= '1' when (O_READY = '1') else '0';
        outlet_last_x <= '1';
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_VALID <= outlet_valid;
    O_DATA  <= (others => '0');
end RTL;
