-----------------------------------------------------------------------------------
--!     @file    image_window_fast_scan_buffer.vhd
--!     @brief   Image Window Fast Scan Buffer MODULE :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2018/12/4
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
    -- 各種制御信号
    -------------------------------------------------------------------------------
        START           : --! @brief START :
                          --! 開始信号.
                          --! * 最初にデータ入力と同時にアサートしても構わない.
                          in  std_logic := '0';
        DONE            : --! @brief DONE :
                          --! 終了信号.
                          --! * この信号をアサートすることで、キューに残っているデータ
                          --!   を掃き出す.
                          in  std_logic := '0';
        BUSY            : --! @brief BUSY :
                          --! ビジー信号.
                          --! * 最初にデータが入力されたときにアサートされる.
                          --! * 最後のデータが出力し終えたらネゲートされる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_ENABLE        : --! @brief INPUT ENABLE :
                          --! 入力許可信号.
                          --! * この信号がアサートされている場合、キューの入力を許可する.
                          --! * この信号がネゲートされている場合、I_READY はアサートされない.
                          in  std_logic := '1';
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
        O_ENABLE        : --! @brief OUTPUT ENABLE :
                          --! 出力許可信号.
                          --! * この信号がアサートされている場合、キューの出力を許可する.
                          --! * この信号がネゲートされている場合、O_VALID はアサートされない.
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
    subtype   BUF_DATA_TYPE         is std_logic_vector(2**BUF_WIDTH-1 downto 0);
    type      BUF_DATA_VECTOR       is array(integer range <>) of BUF_DATA_TYPE;
    subtype   BUF_ADDR_TYPE         is std_logic_vector(BUF_DEPTH-BUF_WIDTH-1 downto 0);
    type      BUF_ADDR_VECTOR       is array(integer range <>) of BUF_ADDR_TYPE;
    subtype   BUF_SIZE_TYPE         is std_logic_vector(BUF_DEPTH-BUF_WIDTH   downto 0);
    type      BUF_SIZE_VECTOR       is array(integer range <>) of BUF_SIZE_TYPE;
    subtype   BUF_WENA_TYPE         is std_logic_vector(0 downto 0);
    type      BUF_WENA_VECTOR       is array(integer range <>) of BUF_WENA_TYPE;
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
    signal    wr_addr               :  BUF_SIZE_TYPE;
    signal    wr_bank_state         :  std_logic_vector(0 to   BANK_SIZE-1);
    signal    wr_bank_active        :  std_logic_vector(0 to 2*BANK_SIZE-1);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    channel_count         :  BUF_SIZE_TYPE;
    signal    channel_atrb_last     :  IMAGE_ATRB_VECTOR(I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_channel_size   :  BUF_SIZE_TYPE;
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
    signal    outlet_last_c         :  std_logic;
    signal    outlet_last_x         :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE            is (IDLE_STATE,
                                        WAIT_STATE,
                                        STORE_STATE,
                                        FLUSH_STATE,
                                        DONE_STATE);
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
                        if (I_ENABLE = '1') then
                            curr_state <= WAIT_STATE;
                        else
                            curr_state <= IDLE_STATE;
                        end if;
                    when WAIT_STATE =>
                        if (intake_valid = '1' and intake_ready = '1' and intake_start_x = '1') then
                            curr_state <= STORE_STATE;
                        else
                            curr_state <= WAIT_STATE;
                        end if;
                    when STORE_STATE =>
                        if (intake_valid = '1' and intake_ready = '1' and intake_last_x = '1' and intake_last_c = '1') then
                            curr_state <= FLUSH_STATE;
                        else
                            curr_state <= STORE_STATE;
                        end if;
                    when FLUSH_STATE =>
                        if (outlet_valid = '1' and outlet_ready = '1' and outlet_last_x = '1' and outlet_last_c = '1') then
                            curr_state <= DONE_STATE;
                        else
                            curr_state <= FLUSH_STATE;
                        end if;
                    when DONE_STATE =>
                        curr_state <= IDLE_STATE;
                    when others     =>
                        curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    intake_ready <= '1' when (curr_state = WAIT_STATE or curr_state = STORE_STATE) else '0';
    I_READY      <= intake_ready;
    
    -------------------------------------------------------------------------------
    -- intake_start_c : 
    -- intake_last_c  : 
    -- intake_start_x : 
    -- intake_last_x  : 
    -- intake_valid_y : 
    -------------------------------------------------------------------------------
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
    -------------------------------------------------------------------------------
    -- intake_valid : 
    -------------------------------------------------------------------------------
    intake_valid <= '1' when (I_VALID = '1' and intake_valid_y = '1') else '0';
    -------------------------------------------------------------------------------
    -- intake_channel_size : 
    -- channel_count       :
    -- channel_atrb_last   : 
    -------------------------------------------------------------------------------
    CHANNEL_SIZE_EQ_0: if (CHANNEL_SIZE = 0) generate
    begin
        process(channel_count, intake_start_x, intake_start_c) begin
            if (intake_start_x = '1') then
                if (intake_start_c = '1') then
                    intake_channel_size <= std_logic_vector(to_unsigned(1, intake_channel_size'length));
                else
                    intake_channel_size <= std_logic_vector(unsigned(channel_count)+1);
                end if;
            else
                    intake_channel_size <= channel_count;
            end if;
        end process;
        process (CLK, RST) begin
            if (RST = '1') then
                    channel_count     <= std_logic_vector(to_unsigned(0, channel_count'length));
                    channel_atrb_last <= (others => (VALID => FALSE, START => FALSE, LAST => FALSE));
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    channel_count     <= std_logic_vector(to_unsigned(0, channel_count'length));
                    channel_atrb_last <= (others => (VALID => FALSE, START => FALSE, LAST => FALSE));
                elsif (intake_valid = '1' and intake_ready = '1' and intake_start_x = '1') then
                    channel_count     <= intake_channel_size;
                    if (intake_last_c = '1') then
                        channel_atrb_last <= GET_ATRB_C_VECTOR_FROM_IMAGE_WINDOW_DATA(I_PARAM, I_DATA);
                    end if;
                end if;
            end if;
        end process;
    end generate;
    CHANNEL_SIZE_GT_0: if (CHANNEL_SIZE > 0) generate
        function CALC_CHANNEL_COUNT return BUF_SIZE_TYPE is
            variable  channel_count     :  integer;
        begin
            channel_count := (CHANNEL_SIZE + O_PARAM.SHAPE.C.SIZE - 1) / O_PARAM.SHAPE.C.SIZE;
            return std_logic_vector(to_unsigned(channel_count, BUF_SIZE_TYPE'length));
        end function;
        function CALC_CHANNEL_ATRB_LAST return IMAGE_ATRB_VECTOR is
            variable  channel_count     :  integer;
            variable  channel_atrb_last :  IMAGE_ATRB_VECTOR(0 to I_PARAM.SHAPE.C.SIZE-1);
            variable  channel_last_pos  :  integer;
        begin
            channel_count    := (CHANNEL_SIZE + O_PARAM.SHAPE.C.SIZE - 1)  /  O_PARAM.SHAPE.C.SIZE;
            channel_last_pos := (CHANNEL_SIZE + O_PARAM.SHAPE.C.SIZE - 1) mod O_PARAM.SHAPE.C.SIZE;
            for c_pos in channel_atrb_last'range loop
                channel_atrb_last(c_pos).VALID := (c_pos <= channel_last_pos);
                channel_atrb_last(c_pos).LAST  := (c_pos >= channel_last_pos);
                channel_atrb_last(c_pos).START := (c_pos = 0 and channel_count = 1);
            end loop;
            return channel_atrb_last;
        end function;
    begin
        intake_channel_size <= channel_count;
        channel_count       <= CALC_CHANNEL_COUNT;
        channel_atrb_last   <= CALC_CHANNEL_ATRB_LAST;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(CLK, RST)
        constant  BANK_ALL_0       :  std_logic_vector(0 to   BANK_SIZE-1) := (others => '0');
        variable  curr_bank_state  :  std_logic_vector(0 to 2*BANK_SIZE-1);
        variable  shft_bank_state  :  std_logic_vector(0 to 2*BANK_SIZE-1);
        variable  next_bank_state  :  std_logic_vector(0 to   BANK_SIZE-1);
        function  next_bank_active(bank_state: std_logic_vector) return std_logic_vector is
            variable bank_active   :  std_logic_vector(0 to 2*BANK_SIZE-1);
            variable bank_on       :  std_logic;
        begin
            for i in bank_active'range loop
                bank_on := '0';
                for n in 0 to I_PARAM.SHAPE.X.SIZE-1 loop
                    if ((i-n) >= 0 and (i-n) <= BANK_SIZE-1) then
                        bank_on := bank_on or bank_state(i-n);
                    end if;
                end loop;
                bank_active(i) := bank_on;
            end loop;
            return bank_active;
        end function;
    begin 
        if (RST = '1') then
                next_bank_state := (0 to 0 => '1', others => '0');
                wr_bank_state   <= next_bank_state;
                wr_bank_active  <= next_bank_active(next_bank_state);
                wr_addr         <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or curr_state = IDLE_STATE) then
                next_bank_state := (0 to 0 => '1', others => '0');
                wr_bank_state   <= next_bank_state;
                wr_bank_active  <= next_bank_active(next_bank_state);
                wr_addr         <= (others => '0');
            else
                if (intake_valid = '1' and intake_ready = '1' and intake_last_c = '1') then
                    for i in curr_bank_state'range loop
                        if (i >= wr_bank_state'low and i <= wr_bank_state'high) then
                            curr_bank_state(i) := wr_bank_state(i);
                        else
                            curr_bank_state(i) := '0';
                        end if;
                    end loop;
                    for i in shft_bank_state'range loop
                        if (i-I_PARAM.STRIDE.X >= curr_bank_state'low and i-I_PARAM.STRIDE.X <= curr_bank_state'high) then
                            shft_bank_state(i) := curr_bank_state(i-I_PARAM.STRIDE.X);
                        else
                            shft_bank_state(i) := '0';
                        end if;
                    end loop;
                    if (shft_bank_state(wr_bank_state'range) = BANK_ALL_0) then
                        next_bank_state := shft_bank_state(BANK_SIZE to 2*BANK_SIZE-1);
                        wr_addr <= std_logic_vector(unsigned(wr_addr) + unsigned(intake_channel_size));
                    else
                        next_bank_state := shft_bank_state(0         to BANK_SIZE  -1);
                    end if;
                    wr_bank_state  <= next_bank_state;
                    wr_bank_active <= next_bank_active(next_bank_state);
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(CLK, RST)
        variable  init_waddr  :  BUF_SIZE_TYPE;
    begin 
        if (RST = '1') then
                buf_waddr <= (others => (others => '0'));
                buf_we    <= (others => (others => '0'));
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                buf_waddr <= (others => (others => '0'));
                buf_we    <= (others => (others => '0'));
            elsif (intake_valid = '1' and intake_ready = '1') then
                for i in buf_waddr'range loop
                    if (intake_start_c = '1') then
                        if    (wr_bank_active(i) = '1') then
                            init_waddr := std_logic_vector(unsigned(wr_addr));
                        else
                            init_waddr := std_logic_vector(unsigned(wr_addr) + unsigned(intake_channel_size));
                        end if;
                        buf_waddr(i) <= init_waddr(BUF_ADDR_TYPE'range);
                    else
                        buf_waddr(i) <= std_logic_vector(unsigned(buf_waddr(i)) + 1);
                    end if;
                end loop;
                for i in buf_we'range loop
                    if (wr_bank_active(i) = '1' or wr_bank_active(i+BANK_SIZE) = '1') then
                        buf_we(i) <= (others => '1');
                    else
                        buf_we(i) <= (others => '0');
                    end if;
                end loop;
            else
                buf_we    <= (others => (others => '0'));
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
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
                    for x_pos in 0 to I_PARAM.SHAPE.X.SIZE-1 loop
                        if ((bank-x_pos) >= wr_bank_state'low) then
                            x_sel(x_pos) := wr_bank_state(bank-x_pos);
                        else
                            x_sel(x_pos) := wr_bank_state(bank-x_pos+wr_bank_state'high+1);
                        end if;
                    end loop;
                    buf_data := (others => '0');
                    for x_pos in 0 to I_PARAM.SHAPE.X.SIZE-1 loop
                        if (x_sel(x_pos) = '1') then
                            for c_pos in I_PARAM.SHAPE.C.LO to I_PARAM.SHAPE.C.HI loop
                                element := GET_ELEMENT_FROM_IMAGE_WINDOW_DATA(
                                               PARAM   => I_PARAM,
                                               C       => c_pos,
                                               X       => x_pos + I_PARAM.SHAPE.X.LO,
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
    --
    -------------------------------------------------------------------------------
    outlet_valid  <= '1' when (curr_state = FLUSH_STATE) else '0';
    outlet_ready  <= '1' when (O_READY = '1') else '0';
    outlet_last_c <= '1';
    outlet_last_x <= '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_VALID <= outlet_valid;
    O_DATA  <= (others => '0');
end RTL;
