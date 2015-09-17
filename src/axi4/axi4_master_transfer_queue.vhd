-----------------------------------------------------------------------------------
--!     @file    axi4_master_transfer_queue.vhd
--!     @brief   AXI4 Master Transfer Queue
--!     @version 1.5.6
--!     @date    2014/9/27
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
-----------------------------------------------------------------------------------
--! @brief   AXI4 Master Transfer Queue
-----------------------------------------------------------------------------------
entity  AXI4_MASTER_TRANSFER_QUEUE is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SEL_BITS        : --! @brief SELECT BITS :
                          --! I_SEL、O_SEL のビット数を指定する.
                          integer := 1;
        SIZE_BITS       : --! @brief SIZE BITS:
                          --! I_SIZE、O_SIZE信号のビット数を指定する.
                          integer := 32;
        ADDR_BITS       : --! @brief ADDR BITS:
                          --! I_ADDR、O_ADDR信号のビット数を指定する.
                          integer := 32;
        ALEN_BITS       : --! @brief ALEN BITS:
                          --! I_ALEN、O_ALEN信号のビット数を指定する.
                          integer := 32;
        PTR_BITS        : --! @brief PTR BITS:
                          --! I_PTR、O_PTR信号のビット数を指定する.
                          integer := 32;
        QUEUE_SIZE      : --! @brief RESPONSE QUEUE SIZE :
                          --! キューの大きさを指定する.
                          integer := 1
    );
    port(
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK             : in    std_logic;
        RST             : in    std_logic;
        CLR             : in    std_logic;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
        I_VALID         : in    std_logic;
        I_SEL           : in    std_logic_vector( SEL_BITS-1 downto 0);
        I_SIZE          : in    std_logic_vector(SIZE_BITS-1 downto 0);
        I_ADDR          : in    std_logic_vector(ADDR_BITS-1 downto 0);
        I_ALEN          : in    std_logic_vector(ALEN_BITS-1 downto 0);
        I_PTR           : in    std_logic_vector( PTR_BITS-1 downto 0);
        I_NEXT          : in    std_logic;
        I_LAST          : in    std_logic;
        I_FIRST         : in    std_logic;
        I_SAFETY        : in    std_logic;
        I_NOACK         : in    std_logic;
        I_READY         : out   std_logic;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
        Q_VALID         : out   std_logic;
        Q_SEL           : out   std_logic_vector( SEL_BITS-1 downto 0);
        Q_SIZE          : out   std_logic_vector(SIZE_BITS-1 downto 0);
        Q_ADDR          : out   std_logic_vector(ADDR_BITS-1 downto 0);
        Q_ALEN          : out   std_logic_vector(ALEN_BITS-1 downto 0);
        Q_PTR           : out   std_logic_vector( PTR_BITS-1 downto 0);
        Q_NEXT          : out   std_logic;
        Q_LAST          : out   std_logic;
        Q_FIRST         : out   std_logic;
        Q_SAFETY        : out   std_logic;
        Q_NOACK         : out   std_logic;
        Q_READY         : in    std_logic;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
        O_VALID         : out   std_logic;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
        BUSY            : out   std_logic_vector( SEL_BITS-1 downto 0);
        DONE            : out   std_logic_vector( SEL_BITS-1 downto 0);
        EMPTY           : out   std_logic
    );
end AXI4_MASTER_TRANSFER_QUEUE;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of AXI4_MASTER_TRANSFER_QUEUE is
begin
    -------------------------------------------------------------------------------
    --  QUEUE_SIZE=0の場合はなにもしない
    -------------------------------------------------------------------------------
    QUEUE_SIZE_EQ_0: if (QUEUE_SIZE = 0) generate
        Q_SEL    <= I_SEL;
        Q_SIZE   <= I_SIZE;
        Q_ADDR   <= I_ADDR;
        Q_ALEN   <= I_ALEN;
        Q_PTR    <= I_PTR;
        Q_NEXT   <= I_NEXT;
        Q_LAST   <= I_LAST;
        Q_FIRST  <= I_FIRST;
        Q_SAFETY <= I_SAFETY;
        Q_NOACK  <= I_NOACK;
        Q_VALID  <= I_VALID;
        O_VALID  <= I_VALID;
        I_READY  <= Q_READY;
     ------------------------------------------------------------------------------
     -- 各種フラグを次の様にするとコンビネーションループが生じてしまう.
     ------------------------------------------------------------------------------
     -- BUSY     <= I_SEL when (I_VALID = '1' and Q_READY = '1') else (others => '0');
     -- DONE     <= I_SEL when (I_VALID = '1' and Q_READY = '1') else (others => '0');
     -- EMPTY    <= '1'   when (Q_READY = '1') else '0';
        BUSY     <= (others => '0');
        DONE     <= (others => '0');
        EMPTY    <= '1';
    end generate;
    -------------------------------------------------------------------------------
    -- QUEUE_SIZE>0の場合
    -------------------------------------------------------------------------------
    QUEUE_SIZE_GT_0: if (QUEUE_SIZE > 0) generate
        type     QUEUE_DATA_TYPE    is record
                     SEL            :  std_logic_vector( SEL_BITS-1 downto 0);
                     SIZE           :  std_logic_vector(SIZE_BITS-1 downto 0);
                     ADDR           :  std_logic_vector(ADDR_BITS-1 downto 0);
                     ALEN           :  std_logic_vector(ALEN_BITS-1 downto 0);
                     PTR            :  std_logic_vector( PTR_BITS-1 downto 0);
                     INFO           :  std_logic_vector(          4 downto 0);
        end record;
        constant QUEUE_DATA_NULL    :  QUEUE_DATA_TYPE := (
                     SEL            => (others => '0'),
                     SIZE           => (others => '0'),
                     ADDR           => (others => '0'),
                     ALEN           => (others => '0'),
                     PTR            => (others => '0'),
                     INFO           => (others => '0')
        );
        type     QUEUE_DATA_VECTOR is array (natural range <>) of QUEUE_DATA_TYPE;
        constant FIRST_OF_QUEUE     : integer := 1;
        constant LAST_OF_QUEUE      : integer := QUEUE_SIZE;
        signal   next_queue_data    : QUEUE_DATA_VECTOR(LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   curr_queue_data    : QUEUE_DATA_VECTOR(LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   queue_data_load    : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   next_queue_valid   : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   curr_queue_valid   : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        constant VALID_ALL_0        : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        -- next_queue_valid : 次のクロックでのキューの状態を示すフラグ.
        -- queue_data_load  : 次のクロックでcurr_queue_dataにnext_queue_dataの値を
        --                    ロードすることを示すフラグ.
        ---------------------------------------------------------------------------
        process (I_VALID, Q_READY, curr_queue_valid) begin
            for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                -------------------------------------------------------------------
                -- 自分のキューにデータが格納されている場合...
                -------------------------------------------------------------------
                if (curr_queue_valid(i) = '1') then
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後ならば、
                    -- Q_READY='1'で自分のキューをクリアする.
                    ---------------------------------------------------------------
                    if (i = LAST_OF_QUEUE) then
                        if (Q_READY = '1') then
                            next_queue_valid(i) <= '0';
                        else
                            next_queue_valid(i) <= '1';
                        end if;
                        queue_data_load(i) <= '0';
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後でなくて、
                    -- かつ後ろのキューにデータが入っているならば、
                    -- Q_READY='1'で後ろのキューのデータを自分のキューに格納する.
                    ---------------------------------------------------------------
                    elsif (curr_queue_valid(i+1) = '1') then
                        next_queue_valid(i) <= '1';
                        if (Q_READY = '1') then
                            queue_data_load(i) <= '1';
                        else
                            queue_data_load(i) <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後でなくて、
                    -- かつ後ろのキューにデータが入っていないならば、
                    -- I_VALID='0' かつ Q_READY='1'ならば自分のキューをクリアする. 
                    -- I_VALID='1' かつ Q_READY='1'ならばI_DATAを自分のキューに格納する.
                    ---------------------------------------------------------------
                    else
                        if (I_VALID = '0' and Q_READY = '1') then
                            next_queue_valid(i) <= '0';
                        else
                            next_queue_valid(i) <= '1';
                        end if;
                        if (I_VALID = '1' and Q_READY = '1') then
                            queue_data_load(i)  <= '1';
                        else
                            queue_data_load(i)  <= '0';
                        end if;
                    end if;
                -------------------------------------------------------------------
                -- 自分のところにデータが格納されていない場合...
                -------------------------------------------------------------------
                else -- if (curr_queue_valid(i) = '0') then
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭ならば、
                    -- I_VALID='1'で自分のキューにデータを格納する.
                    ---------------------------------------------------------------
                    if    (i = FIRST_OF_QUEUE) then
                        if (I_VALID = '1') then
                            next_queue_valid(i) <= '1';
                            queue_data_load(i)  <= '1';
                        else
                            next_queue_valid(i) <= '0';
                            queue_data_load(i)  <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭なくて、
                    -- かつ前のキューにデータが格納されているならば、
                    -- I_VALID='1'かつQ_READY='0'で自分のキューにデータを格納する.
                    ---------------------------------------------------------------
                    elsif (curr_queue_valid(i-1) = '1') then
                        if (I_VALID = '1' and Q_READY = '0') then
                            next_queue_valid(i) <= '1';
                        else
                            next_queue_valid(i) <= '0';
                        end if;
                        if (I_VALID = '1' and Q_READY = '0') then
                            queue_data_load(i)  <= '1';
                        else
                            queue_data_load(i)  <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭なくて、
                    -- かつ前のキューにデータが格納されていないならば、
                    -- キューは空のまま.
                    ---------------------------------------------------------------
                    else
                            next_queue_valid(i) <= '0';
                            queue_data_load(i)  <= '0';
                    end if;
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- next_queue_data  : 次のクロックでキューに格納されるデータ.
        ---------------------------------------------------------------------------
        process (I_SEL , I_SIZE, I_ADDR , I_ALEN  , I_PTR  ,
                 I_NEXT, I_LAST, I_FIRST, I_SAFETY, I_NOACK, 
                 queue_data_load, curr_queue_data, curr_queue_valid)
            variable i_data : QUEUE_DATA_TYPE;
        begin
            i_data.SEL     := I_SEL;
            i_data.SIZE    := I_SIZE;
            i_data.ADDR    := I_ADDR;
            i_data.ALEN    := I_ALEN;
            i_data.PTR     := I_PTR;
            i_data.INFO(0) := I_NEXT;
            i_data.INFO(1) := I_LAST;
            i_data.INFO(2) := I_FIRST;
            i_data.INFO(3) := I_SAFETY;
            i_data.INFO(4) := I_NOACK;
            for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                if (queue_data_load(i) = '1') then
                    if    (i = LAST_OF_QUEUE) then
                        next_queue_data(i) <= i_data;
                    elsif (curr_queue_valid(i+1) = '1') then
                        next_queue_data(i) <= curr_queue_data(i+1);
                    else
                        next_queue_data(i) <= i_data;
                    end if;
                else
                        next_queue_data(i) <= curr_queue_data(i);
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- curr_queue_data  : 現在、キューに格納されているデータ.
        -- curr_queue_valid : 現在、キューにデータが格納されていることを示すフラグ.
        -- I_READY          : キューにデータが格納することが出来ることを示すフラグ.
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if     (RST = '1') then
                   curr_queue_data  <= (others => QUEUE_DATA_NULL);
                   curr_queue_valid <= (others => '0');
                   I_READY          <= '0';
            elsif  (CLK'event and CLK = '1') then
               if (CLR = '1') then
                   curr_queue_data  <= (others => QUEUE_DATA_NULL);
                   curr_queue_valid <= (others => '0');
                   I_READY          <= '0';
               else
                   curr_queue_data  <= next_queue_data;
                   curr_queue_valid <= next_queue_valid;
                   I_READY          <= not next_queue_valid(LAST_OF_QUEUE);
               end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        SEL_BITS_GT_1: if (SEL_BITS > 1) generate
            process (curr_queue_valid, curr_queue_data, next_queue_valid, next_queue_data)
                variable curr_valid : std_logic;
                variable next_valid : std_logic;
                function make_sel_valid(V:std_logic_vector;Q:QUEUE_DATA_VECTOR;N:integer) return std_logic is
                    variable  valid : std_logic;
                begin
                    valid := '0';
                    for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                        if (V(i) = '1' and Q(i).SEL(N) = '1') then
                            valid := '1';
                        end if;
                    end loop;
                    return valid;
                end function;
            begin
                for i in BUSY'range loop
                    curr_valid := make_sel_valid(curr_queue_valid, curr_queue_data, i);
                    next_valid := make_sel_valid(next_queue_valid, next_queue_data, i);
                    BUSY(i) <= curr_valid;
                    DONE(i) <= curr_valid and not next_valid;
                end loop;
            end process;
        end generate;
        SEL_BITS_EQ_1: if (SEL_BITS = 1) generate
            BUSY(0) <= '1' when (curr_queue_valid /= VALID_ALL_0) else '0';
            DONE(0) <= '1' when (curr_queue_valid /= VALID_ALL_0) and
                                (next_queue_valid  = VALID_ALL_0) else '0';
        end generate;
        ---------------------------------------------------------------------------
        -- 各種出力信号
        ---------------------------------------------------------------------------
        Q_SEL    <= curr_queue_data (FIRST_OF_QUEUE).SEL  when (SEL_BITS > 1) else (others => '1');
        Q_SIZE   <= curr_queue_data (FIRST_OF_QUEUE).SIZE;
        Q_ADDR   <= curr_queue_data (FIRST_OF_QUEUE).ADDR;
        Q_ALEN   <= curr_queue_data (FIRST_OF_QUEUE).ALEN;
        Q_PTR    <= curr_queue_data (FIRST_OF_QUEUE).PTR;
        Q_NEXT   <= curr_queue_data (FIRST_OF_QUEUE).INFO(0);
        Q_LAST   <= curr_queue_data (FIRST_OF_QUEUE).INFO(1);
        Q_FIRST  <= curr_queue_data (FIRST_OF_QUEUE).INFO(2);
        Q_SAFETY <= curr_queue_data (FIRST_OF_QUEUE).INFO(3);
        Q_NOACK  <= curr_queue_data (FIRST_OF_QUEUE).INFO(4);
        Q_VALID  <= curr_queue_valid(FIRST_OF_QUEUE);
        O_VALID  <= next_queue_valid(FIRST_OF_QUEUE);
        EMPTY    <= '1' when (curr_queue_valid = VALID_ALL_0) else '0';
    end generate;
end RTL;
