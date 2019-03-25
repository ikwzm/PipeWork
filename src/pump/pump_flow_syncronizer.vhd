-----------------------------------------------------------------------------------
--!     @file    pump_flow_syncronizer.vhd
--!     @brief   PUMP FLOW SYNCRONIZER
--!              PUMPの入力側と出力側の間で各種情報を伝達するモジュール. 
--!     @version 1.8.0
--!     @date    2019/3/25
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
--! @brief   PIPE FLOW SYNCRONIZER
-----------------------------------------------------------------------------------
entity  PUMP_FLOW_SYNCRONIZER is
    generic (
        I_CLK_RATE      : --! @brief INPUT CLOCK RATE :
                          --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        O_CLK_RATE      : --! @brief OUTPUT CLOCK RATE :
                          --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        OPEN_INFO_BITS  : --! @brief OPEN INFOMATION BITS :
                          --! I_OPEN_INFO/O_OPEN_INFOのビット数を指定する.
                          integer :=  1;
        CLOSE_INFO_BITS : --! @brief CLOSE INFOMATION BITS :
                          --! I_CLOSE_INFO/O_CLOSE_INFOのビット数を指定する.
                          integer :=  1;
        EVENT_SIZE      : --! @brief EVENT SIZE
                          --! イベントの数を指定する.
                          integer :=  1;
        XFER_SIZE_BITS  : --! @brief SIZE BITS :
                          --! 各種サイズ信号のビット数を指定する.
                          integer :=  8;
        PUSH_FIN_VALID  : --! @brief PUSH FINAL SIZE VALID :
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PUSH_FIN_VALID = 1 : 有効. 
                          --! * PUSH_FIN_VALID = 0 : 無効. 回路は省略される.
                          integer range 0 to 1 := 1;
        PUSH_FIN_DELAY  : --! @brief PUSH FINAL SIZE DELAY CYCLE :
                          --! PUSH_FIN_VAL/PUSH_FIN_SIZE/PUSH_FIN_LAST を遅延するサ
                          --! イクル数を指定する.
                          integer :=  0;
        PUSH_RSV_VALID  : --! @brief PUSH RESERVE SIZE VALID :
                          --! PUSH_RSV_VAL/PUSH_RSV_SIZE/PUSH_RSV_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PUSH_RSV_VALID = 1 : 有効. 
                          --! * PUSH_RSV_VALID = 0 : 無効. 回路は省略される.
                          integer range 0 to 1 := 1;
        PULL_FIN_VALID  : --! @brief PULL FINAL SIZE VALID :
                          --! PULL_FIN_VAL/PULL_FIN_SIZE/PULL_FIN_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PULL_FIN_VALID = 1 : 有効. 
                          --! * PULL_FIN_VALID = 0 : 無効. 回路は省略される.
                          integer range 0 to 1 := 1;
        PULL_RSV_VALID  : --! @brief PULL RESERVE SIZE VALID :
                          --! PULL_RSV_VAL/PULL_RSV_SIZE/PULL_RSV_LAST 信号を有効に
                          --! するか否かを指定する.
                          --! * PULL_RSV_VALID = 1 : 有効. 
                          --! * PULL_RSV_VALID = 0 : 無効. 回路は省略される.
                          integer range 0 to 1 := 1
    );
    port (
    -------------------------------------------------------------------------------
    -- Asyncronous Reset Signal.
    -------------------------------------------------------------------------------
        RST             : --! @brief RESET :
                          --! 非同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Input Clock and Clock Enable and Syncronous reset.
    -------------------------------------------------------------------------------
        I_CLK           : --! @brief INPUT CLOCK :
                          --! 入力側のクロック信号.
                          in  std_logic;
        I_CLR           : --! @brief INPUT CLEAR :
                          --! 入力側の同期リセット信号(ハイ・アクティブ).
                          in  std_logic := '0';
        I_CKE           : --! @brief INPUT CLOCK ENABLE :
                          --! 入力側のクロック(I_CLK)の立上りが有効であることを示す信号.
                          --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の
                          --!   位相関係を示す時に使用する.
                          --! * I_CLKの立上り時とOCLKの立上り時が同じ時にアサートす
                          --!   るように入力されなければならない.
                          --! * この信号は I_CLK_RATE > 1 かつ O_CLK_RATE = 1の時の
                          --!   み有効. それ以外は未使用.
                          in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- 入力側からのOPEN(トランザクションの開始)を指示する信号.
    -------------------------------------------------------------------------------
        I_OPEN_VAL      : --! @brief INPUT OPEN VALID :
                          --! 入力側からのOPEN(トランザクションの開始)を指示する信号.
                          --! * I_OPEN_INFO が有効であることを示す.
                          in  std_logic := '0';
        I_OPEN_INFO     : --! @brief INPUT OPEN INFOMATION DATA :
                          --! OPEN(トランザクションの開始)時に出力側に伝達する各種
                          --! 情報入力.
                          --! * I_OPEN_VALがアサートされている時のみ有効.
                          in  std_logic_vector(OPEN_INFO_BITS -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのCLOSE(トランザクションの終了)を指示する信号.
    -------------------------------------------------------------------------------
        I_CLOSE_VAL     : --! @brief INPUT CLOSE VALID :
                          --! 入力側からのCLOSE(トランザクションの終了)を指示する信号.
                          --! * I_CLOSE_INFO が有効であることを示す.
                          in  std_logic := '0';
        I_CLOSE_INFO    : --! @brief INPUT CLOSE INFOMATION DATA :
                          --! CLOSE(トランザクションの終了)時に出力側に伝達する各種
                          --! 情報入力.
                          --! * I_CLOSE_VALがアサートされている時のみ有効.
                          in  std_logic_vector(CLOSE_INFO_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのイベントを通知する信号.
    -------------------------------------------------------------------------------
        I_EVENT         : --! @brief INPUT EVENT
                          in  std_logic_vector(EVENT_SIZE     -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのPUSH_FIN(入力側から出力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PUSH_FIN_VAL  : --! @brief INPUT PUSH FINAL VALID :
                          --! * I_PUSH_FIN_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PUSH_FIN_LAST : --! @brief INPUT PUSH FINAL LAST FLAG :
                          --! 入力側から出力側へ最後の"確定した"転送であることを示す.
                          in  std_logic := '0';
        I_PUSH_FIN_SIZE : --! @brief INPUT PUSH FINAL SIZE :
                          --! 入力側から出力側への転送が"確定した"バイト数を入力.
                          in  std_logic_vector(XFER_SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのPUSH_RSV(入力側から出力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PUSH_RSV_VAL  : --! @brief INPUT PUSH RESERVE VALID :
                          --! * I_PUSH_RSV_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PUSH_RSV_LAST : --! @brief INPUT PUSH RESERVE LAST FLAG :
                          --! 入力側から出力側へ最後の"予定された"転送であることを示す.
                          in  std_logic := '0';
        I_PUSH_RSV_SIZE : --! @brief INPUT PUSH RESERVE SIZE :
                          --! 入力側から出力側への転送が"予定された"バイト数を入力.
                          in  std_logic_vector(XFER_SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのPULL_FIN(出力側から入力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PULL_FIN_VAL  : --! @brief INPUT PULL FINAL VALID :
                          --! * I_PULL_FIN_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PULL_FIN_LAST : --! @brief INPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"確定した"転送であることを示す.
                          in  std_logic := '0';
        I_PULL_FIN_SIZE : --! @brief INPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送が"確定した"バイト数を入力.
                          in  std_logic_vector(XFER_SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 入力側からのPULL_RSV(出力側から入力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        I_PULL_RSV_VAL  : --! @brief INPUT PULL RESERVE VALID :
                          --! * I_PULL_RSV_LAST/SIZE が有効であることを示す.
                          in  std_logic := '0';
        I_PULL_RSV_LAST : --! @brief INPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"予定された"転送であることを示す.
                          in  std_logic := '0';
        I_PULL_RSV_SIZE : --! @brief INPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送"が予定された"バイト数を入力.
                          in  std_logic_vector(XFER_SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Output Clock and Clock Enable and Syncronous reset.
    -------------------------------------------------------------------------------
        O_CLK           : --! @brief OUTPUT CLOCK :
                          --! 入力側のクロック信号.
                          in  std_logic;
        O_CLR           : --! @brief OUTPUT CLEAR :
                          --! 入力側の同期リセット信号(ハイ・アクティブ).
                          in  std_logic;
        O_CKE           : --! @brief OUTPUT CLOCK ENABLE :
                          --! 出力側のクロック(O_CLK)の立上りが有効であることを示す信号.
                          --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の
                          --!   位相関係を示す時に使用する.
                          --! * I_CLKの立上り時とO_CLKの立上り時が同じ時にアサートす
                          --!   るように入力されなければならない.
                          --! * この信号は O_CLK_RATE > 1 かつ I_CLK_RATE = 1の時のみ
                          --!   有効. それ以外は未使用.
                          in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- 出力側へのOPEN(トランザクションの開始)を指示する信号.
    -------------------------------------------------------------------------------
        O_OPEN_VAL      : --! @brief OUTPUT OPEN VALID :
                          --! 出力側へのOPEN(トランザクションの開始)を指示する信号.
                          --! * O_OPEN_INFO が有効であることを示す.
                          out std_logic;
        O_OPEN_INFO     : --! @brief OUTPUT OPEN INFOMATION DATA :
                          --! OPEN(トランザクションの開始)時に出力側に伝達する各種
                          --! 情報出力.
                          --! * I_OPEN_VALがアサートされている時のみ有効.
                          out std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのCLOSE(トランザクションの終了)を指示する信号.
    -------------------------------------------------------------------------------
        O_CLOSE_VAL     : --! @brief OUTPUT CLOSE VALID :
                          --! 出力側へCLOSE(トランザクションの終了)を指示する信号.
                          --! * O_CLOSE_VAL/INFO は O_PUSH_FIN_XXX の出力タイミング
                          --!   に合わせて出力される.
                          out std_logic;
        O_CLOSE_INFO    : --! @brief OUTPUT CLOSE INFOMATION DATA :
                          --! CLOSE(トランザクションの終了)時に出力側に伝達する各種
                          --! 情報出力.
                          --! * I_CLOSE_VALがアサートされている時のみ有効.
                          out std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのイベントを通知する信号.
    -------------------------------------------------------------------------------
        O_EVENT         : --! @brief OUTPUT EVENT
                          out std_logic_vector(EVENT_SIZE     -1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのPUSH_FIN(入力側から出力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PUSH_FIN_VAL  : --! @brief OUTPUT PUSH FINAL VALID :
                          --! * O_PUSH_FIN_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PUSH_FIN_LAST : --! @brief OUTPUT PUSH FINAL LAST FLAG :
                          --! 入力側から出力側へ最後の"確定した"転送であることを示す.
                          out std_logic;
        O_PUSH_FIN_SIZE : --! @brief OUTPUT PUSH FINAL SIZE :
                          --! 入力側から出力側への転送が"確定した"バイト数を出力.
                          out std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのPUSH_RSV(入力側から出力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PUSH_RSV_VAL  : --! @brief OUTPUT PUSH RESERVE VALID :
                          --! * O_PUSH_RSV_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PUSH_RSV_LAST : --! @brief OUTPUT PUSH RESERVE LAST FLAG :
                          --! 入力側から出力側へ最後の"予定された"転送であることを示す.
                          out std_logic;
        O_PUSH_RSV_SIZE : --! @brief OUTPUT PUSH RESERVE SIZE :
                          --! 入力側から出力側への転送が"予定された"バイト数を出力.
                          out std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのPULL_FIN(出力側から入力側への転送"が確定した"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PULL_FIN_VAL  : --! @brief OUTPUT PULL FINAL VALID :
                          --! * O_PULL_FIN_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PULL_FIN_LAST : --! @brief OUTPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"確定した"転送であることを示す.
                          out std_logic;
        O_PULL_FIN_SIZE : --! @brief OUTPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送が"確定した"バイト数を出力.
                          out std_logic_vector(XFER_SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側へのPULL_RSV(出力側から入力側への転送"が予定された"バイト数)信号.
    -------------------------------------------------------------------------------
        O_PULL_RSV_VAL  : --! @brief OUTPUT PULL RESERVE VALID :
                          --! * O_PULL_RSV_LAST/SIZE が有効であることを示す.
                          out std_logic;
        O_PULL_RSV_LAST : --! @brief OUTPUT PULL FINAL LAST FLAG :
                          --! 出力側から入力側への最後の"予定された"転送であることを示す.
                          out std_logic;
        O_PULL_RSV_SIZE : --! @brief OUTPUT PULL FINAL SIZE :
                          --! 出力側から入力側への転送"が予定された"バイト数を出力.
                          out std_logic_vector(XFER_SIZE_BITS-1 downto 0)
    );
end PUMP_FLOW_SYNCRONIZER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.SYNCRONIZER;
use     PIPEWORK.COMPONENTS.SYNCRONIZER_INPUT_PENDING_REGISTER;
use     PIPEWORK.COMPONENTS.DELAY_REGISTER;
use     PIPEWORK.COMPONENTS.DELAY_ADJUSTER;
architecture  RTL of PUMP_FLOW_SYNCRONIZER is
    -------------------------------------------------------------------------------
    -- このモジュールで使用するi_valid/o_valid/i_data/o_dataのビットの割り当てを
    -- 保持する定数のタイプの宣言.
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    --! @brief OPEN_INFO/CLOSE_INFO の i_valid/o_valid/i_data/o_dataのビットの
    --!        割り当てを保持する定数の型.
    -------------------------------------------------------------------------------
    type      INFO_RANGE_TYPE is record
              VAL_POS           : integer;          -- i_valid/o_valid の *_VAL のビット位置
              DATA_LO           : integer;          -- i_data/o_data   の *_INFO の最下位ビット位置
              DATA_HI           : integer;          -- i_data/o_data   の *_INFO の最上位ビット位置
    end record;
    type      INFO_RANGE_VECTOR is array (integer range <>) of INFO_RANGE_TYPE;
    -------------------------------------------------------------------------------
    --! @brief PUSH_FIN_XXX/PUSH_RSV_XXX/PULL_FIN_XXX/PULL_RSV_XXX の 
    --!        i_valid/o_valid/i_data/o_dataのビットの割り当てを保持する定数の型.
    -------------------------------------------------------------------------------
    type      SIZE_RANGE_TYPE is record
              VAL_POS           : integer;          -- i_valid/o_valid の *_VAL のビット位置
              DATA_LO           : integer;          -- i_data/o_data   の *_SIZE&LAST の最下位ビット位置
              DATA_HI           : integer;          -- i_data/o_data   の *_SIZE&LAST の最上位ビット位置
              SIZE_LO           : integer;          -- i_data/o_data   の *_SIZE の最下位ビット位置
              SIZE_HI           : integer;          -- i_data/o_data   の *_SIZE の最上位ビット位置
              LAST_POS          : integer;          -- i_data/o_data   の *_LAST のビット位置
    end record;
    -------------------------------------------------------------------------------
    --! @brief i_valid/o_valid/i_data/o_dataのビットの割り当てを保持する定数の型.
    -------------------------------------------------------------------------------
    type      VEC_RANGE_TYPE is record
              VAL_LO            : integer;          -- i_valid/o_valid の最下位ビット位置
              VAL_HI            : integer;          -- i_valid/o_valid の最上位ビット位置
              DATA_LO           : integer;          -- i_data/o_data の最下位ビット位置
              DATA_HI           : integer;          -- i_data/o_data の最上位ビット位置
              OPEN_INFO         : INFO_RANGE_TYPE;  -- OPEN_INFOの各種ビット位置
              CLOSE_INFO        : INFO_RANGE_TYPE;  -- CLOSE_INFOの各種ビット位置
              EVENT             : INFO_RANGE_VECTOR(EVENT_SIZE-1 downto 0);
              PUSH_FIN          : SIZE_RANGE_TYPE;  -- PUSH_FIN_XXXの各種ビット位置
              PUSH_RSV          : SIZE_RANGE_TYPE;  -- PUSH_RSV_XXXの各種ビット位置
              PULL_FIN          : SIZE_RANGE_TYPE;  -- PULL_FIN_XXXの各種ビット位置
              PULL_RSV          : SIZE_RANGE_TYPE;  -- PULL_RSV_XXXの各種ビット位置
    end record;
    -------------------------------------------------------------------------------
    --! @brief このモジュールで使用するi_valid/o_valid/i_data/o_dataのビットの
    --         割り当てを決める関数.
    -------------------------------------------------------------------------------
    function  SET_VEC_RANGE return VEC_RANGE_TYPE is
        variable  v_pos         : integer;
        variable  d_pos         : integer;
        variable  v             : VEC_RANGE_TYPE;
        ---------------------------------------------------------------------------
        --! @brief OPEN_INFO/CLOSE_INFO のビット割り当てを決めるプロシージャ.
        ---------------------------------------------------------------------------
        procedure SET_INFO_RANGE(INFO_RANGE: inout INFO_RANGE_TYPE; BITS: in integer) is
        begin
            INFO_RANGE.VAL_POS  := v_pos;
            INFO_RANGE.DATA_LO  := d_pos;
            INFO_RANGE.DATA_HI  := d_pos + BITS-1;
            v_pos := v_pos + 1;
            d_pos := d_pos + BITS;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief PUSH_FIN_SIZE/PUSH_RSV_SIZE/PULL_FIN_SIZE/PULL_RSV_SIZE の
        --!        ビット割り当てを決めるプロシージャ.
        ---------------------------------------------------------------------------
        procedure SET_SIZE_RANGE(SIZE_RANGE: inout SIZE_RANGE_TYPE; BITS: in integer) is
        begin
            SIZE_RANGE.VAL_POS  := v_pos;
            SIZE_RANGE.SIZE_LO  := d_pos;
            SIZE_RANGE.SIZE_HI  := d_pos + BITS-1;
            SIZE_RANGE.LAST_POS := d_pos + BITS;
            SIZE_RANGE.DATA_LO  := d_pos;
            SIZE_RANGE.DATA_HI  := d_pos + BITS;
            v_pos := v_pos + 1;
            d_pos := d_pos + BITS + 1;
        end procedure;
    begin
        v_pos := 0;
        d_pos := 0;
        v.VAL_LO  := v_pos;
        v.DATA_LO := d_pos;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SET_INFO_RANGE(v.OPEN_INFO , OPEN_INFO_BITS );
        SET_INFO_RANGE(v.CLOSE_INFO, CLOSE_INFO_BITS);
        for i in 0 to EVENT_SIZE-1 loop
            SET_INFO_RANGE(v.EVENT(i), 1);
        end loop;
        if (PUSH_FIN_VALID /= 0) then
            SET_SIZE_RANGE(v.PUSH_FIN, XFER_SIZE_BITS);
        end if;
        if (PUSH_RSV_VALID /= 0) then
            SET_SIZE_RANGE(v.PUSH_RSV, XFER_SIZE_BITS);
        end if;
        if (PULL_FIN_VALID /= 0) then
            SET_SIZE_RANGE(v.PULL_FIN, XFER_SIZE_BITS);
        end if;
        if (PULL_RSV_VALID /= 0) then
            SET_SIZE_RANGE(v.PULL_RSV, XFER_SIZE_BITS);
        end if;
        ---------------------------------------------------------------------------
        -- この段階で必要な分のビット割り当ては終了.
        ---------------------------------------------------------------------------
        v.VAL_HI  := v_pos - 1;
        v.DATA_HI := d_pos - 1;
        ---------------------------------------------------------------------------
        -- 後は必要無いが、放っておくのも気持ち悪いので、ダミーの値をセット.
        ---------------------------------------------------------------------------
        if (PUSH_FIN_VALID = 0) then
            SET_SIZE_RANGE(v.PUSH_FIN, XFER_SIZE_BITS);
        end if;
        if (PUSH_RSV_VALID = 0) then
            SET_SIZE_RANGE(v.PUSH_RSV, XFER_SIZE_BITS);
        end if;
        if (PULL_FIN_VALID = 0) then
            SET_SIZE_RANGE(v.PULL_FIN, XFER_SIZE_BITS);
        end if;
        if (PULL_RSV_VALID = 0) then
            SET_SIZE_RANGE(v.PULL_RSV, XFER_SIZE_BITS);
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        return v;
    end function;
    -------------------------------------------------------------------------------
    --! @brief このモジュールで使用するi_valid/o_valid/i_data/o_data のビットの
    --!        割り当てを保持している定数.
    -------------------------------------------------------------------------------
    constant  VEC_RANGE      : VEC_RANGE_TYPE  := SET_VEC_RANGE;
    -------------------------------------------------------------------------------
    -- 内部信号たち.
    -------------------------------------------------------------------------------
    signal    i_valid        : std_logic_vector(VEC_RANGE.VAL_HI  downto VEC_RANGE.VAL_LO );
    signal    i_data         : std_logic_vector(VEC_RANGE.DATA_HI downto VEC_RANGE.DATA_LO);
    signal    o_valid        : std_logic_vector(VEC_RANGE.VAL_HI  downto VEC_RANGE.VAL_LO );
    signal    o_data         : std_logic_vector(VEC_RANGE.DATA_HI downto VEC_RANGE.DATA_LO);
    constant  i_pause        : std_logic := '0';
    signal    i_ready        : std_logic;
begin
    ------------------------------------------------------------------------------
    --! @brief I_OPEN_VAL/I_OPEN_INFO 入力レジスタ.
    --! * I_OPEN_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    --! * I_OPEN_INFO信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_OPEN_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                 --
        generic map (                                               --
            DATA_BITS   => OPEN_INFO_BITS                         , -- 
            OPERATION   => 1                                        -- 
        )                                                           -- 
        port map (                                                  -- 
            CLK         => I_CLK                                  , -- In  :
            RST         => RST                                    , -- In  :
            CLR         => I_CLR                                  , -- In  :
            I_DATA      => I_OPEN_INFO                            , -- In  :
            I_VAL       => I_OPEN_VAL                             , -- In  :
            I_PAUSE     => i_pause                                , -- In  :
            P_DATA      => open                                   , -- Out :
            P_VAL       => open                                   , -- Out :
            O_DATA      => i_data (VEC_RANGE.OPEN_INFO.DATA_HI downto VEC_RANGE.OPEN_INFO.DATA_LO),
            O_VAL       => i_valid(VEC_RANGE.OPEN_INFO.VAL_POS)   , -- Out :
            O_RDY       => i_ready                                  -- In  :
        );                                                          -- 
    ------------------------------------------------------------------------------
    --! @brief I_CLOSE_VAL/I_CLOSE_INFO 入力レジスタ.
    --! * I_CLOSE_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    --! * I_CLOSE_INFO信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_CLOSE_REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                --
        generic map (                                               --
            DATA_BITS   => CLOSE_INFO_BITS                        , -- 
            OPERATION   => 1                                        -- 
        )                                                           -- 
        port map (                                                  -- 
            CLK         => I_CLK                                  , -- In  :
            RST         => RST                                    , -- In  :
            CLR         => I_CLR                                  , -- In  :
            I_DATA      => I_CLOSE_INFO                           , -- In  :
            I_VAL       => I_CLOSE_VAL                            , -- In  :
            I_PAUSE     => i_pause                                , -- In  :
            P_DATA      => open                                   , -- Out :
            P_VAL       => open                                   , -- Out :
            O_DATA      => i_data (VEC_RANGE.CLOSE_INFO.DATA_HI downto VEC_RANGE.CLOSE_INFO.DATA_LO),
            O_VAL       => i_valid(VEC_RANGE.CLOSE_INFO.VAL_POS)  , -- Out :
            O_RDY       => i_ready                                  -- In  :
        );                                                          -- 
    ------------------------------------------------------------------------------
    --! @brief I_EVENT 入力レジスタ.
    --! * I_EVENT 信号を SYNCRONIZER の I_VAL/I_DATA に入力.
    ------------------------------------------------------------------------------
    I_EVENT_N: for i in 0 to EVENT_SIZE-1 generate
        REGS: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => "1"                                , -- In  :
                I_VAL       => I_EVENT(i)                         , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.EVENT(i).DATA_HI downto VEC_RANGE.EVENT(i).DATA_LO),
                O_VAL       => i_valid(VEC_RANGE.EVENT(i).VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;
    ------------------------------------------------------------------------------
    --! @brief I_PUSH_FIN_VAL/I_PUSH_FIN_LAST/I_PUSH_FIN_SIZE 入力レジスタ.
    --! * I_PUSH_FIN_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    --! * I_PUSH_FIN_LAST信号を SYNCRONIZER の I_DATA に入力.
    --! * I_PUSH_FIN_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_PUSH_FIN_REGS: if (PUSH_FIN_VALID /= 0) generate              --
        SIZE: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => XFER_SIZE_BITS                     , -- 
                OPERATION   => 2                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => I_PUSH_FIN_SIZE                    , -- In  :
                I_VAL       => I_PUSH_FIN_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PUSH_FIN.SIZE_HI downto VEC_RANGE.PUSH_FIN.SIZE_LO),
                O_VAL       => i_valid(VEC_RANGE.PUSH_FIN.VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      --
        LAST: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA(0)   => I_PUSH_FIN_LAST                    , -- In  :
                I_VAL       => I_PUSH_FIN_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PUSH_FIN.LAST_POS downto VEC_RANGE.PUSH_FIN.LAST_POS),
                O_VAL       => open                               , -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    ------------------------------------------------------------------------------
    --! @brief I_PUSH_RSV_VAL/I_PUSH_RSV_LAST/I_PUSH_RSV_SIZE 入力レジスタ.
    --! * I_PUSH_RSV_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    --! * I_PUSH_RSV_LAST信号を SYNCRONIZER の I_DATA に入力.
    --! * I_PUSH_RSV_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_PUSH_RSV_REGS: if (PUSH_RSV_VALID /= 0) generate              -- 
        SIZE: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => XFER_SIZE_BITS                     , -- 
                OPERATION   => 2                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => I_PUSH_RSV_SIZE                    , -- In  :
                I_VAL       => I_PUSH_RSV_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PUSH_RSV.SIZE_HI downto VEC_RANGE.PUSH_RSV.SIZE_LO),
                O_VAL       => i_valid(VEC_RANGE.PUSH_RSV.VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      --
        LAST: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA(0)   => I_PUSH_RSV_LAST                    , -- In  :
                I_VAL       => I_PUSH_RSV_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PUSH_RSV.LAST_POS downto VEC_RANGE.PUSH_RSV.LAST_POS),
                O_VAL       => open                               , -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    ------------------------------------------------------------------------------
    --! @brief I_PULL_FIN_VAL/I_PULL_FIN_LAST/I_PULL_FIN_SIZE 入力レジスタ.
    --! * I_PULL_FIN_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    --! * I_PULL_FIN_LAST信号を SYNCRONIZER の I_DATA に入力.
    --! * I_PULL_FIN_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_PULL_FIN_REGS: if (PULL_FIN_VALID /= 0) generate              -- 
        SIZE: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => XFER_SIZE_BITS                     , -- 
                OPERATION   => 2                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => I_PULL_FIN_SIZE                    , -- In  :
                I_VAL       => I_PULL_FIN_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PULL_FIN.SIZE_HI downto VEC_RANGE.PULL_FIN.SIZE_LO),
                O_VAL       => i_valid(VEC_RANGE.PULL_FIN.VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      --
        LAST: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA(0)   => I_PULL_FIN_LAST                    , -- In  :
                I_VAL       => I_PULL_FIN_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PULL_FIN.LAST_POS downto VEC_RANGE.PULL_FIN.LAST_POS),
                O_VAL       => open                               , -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    ------------------------------------------------------------------------------
    --! @brief I_PULL_RSV_VAL/I_PULL_RSV_LAST/I_PULL_RSV_SIZE 入力レジスタ.    
    --! * I_PULL_RSV_VAL 信号を SYNCRONIZER の I_VAL  に入力.
    --! * I_PULL_RSV_LAST信号を SYNCRONIZER の I_DATA に入力.
    --! * I_PULL_RSV_SIZE信号を SYNCRONIZER の I_DATA に入力.
    ------------------------------------------------------------------------------
    I_PULL_RSV_REGS: if (PULL_RSV_VALID /= 0) generate              -- 
        SIZE: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => XFER_SIZE_BITS                     , -- 
                OPERATION   => 2                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA      => I_PULL_RSV_SIZE                    , -- In  :
                I_VAL       => I_PULL_RSV_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PULL_RSV.SIZE_HI downto VEC_RANGE.PULL_RSV.SIZE_LO),
                O_VAL       => i_valid(VEC_RANGE.PULL_RSV.VAL_POS), -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      --
        LAST: SYNCRONIZER_INPUT_PENDING_REGISTER                    --
            generic map (                                           --
                DATA_BITS   => 1                                  , -- 
                OPERATION   => 1                                    -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => I_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => I_CLR                              , -- In  :
                I_DATA(0)   => I_PULL_RSV_LAST                    , -- In  :
                I_VAL       => I_PULL_RSV_VAL                     , -- In  :
                I_PAUSE     => i_pause                            , -- In  :
                P_DATA      => open                               , -- Out :
                P_VAL       => open                               , -- Out :
                O_DATA      => i_data (VEC_RANGE.PULL_RSV.LAST_POS downto VEC_RANGE.PULL_RSV.LAST_POS),
                O_VAL       => open                               , -- Out :
                O_RDY       => i_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    ------------------------------------------------------------------------------
    --! @brief 入力側と出力側で同期する.
    ------------------------------------------------------------------------------
    SYNC: SYNCRONIZER                                               --
        generic map (                                               --
            DATA_BITS   => i_data 'length                         , --
            VAL_BITS    => i_valid'length                         , --
            I_CLK_RATE  => I_CLK_RATE                             , --
            O_CLK_RATE  => O_CLK_RATE                             , --
            I_CLK_FLOP  => 1                                      , --
            O_CLK_FLOP  => 1                                      , --
            I_CLK_FALL  => 0                                      , --
            O_CLK_FALL  => 0                                      , --
            O_CLK_REGS  => 0                                        --
        )                                                           -- 
        port map (                                                  -- 
            RST         => RST                                    , -- In  :
            I_CLK       => I_CLK                                  , -- In  :
            I_CLR       => I_CLR                                  , -- In  :
            I_CKE       => I_CKE                                  , -- In  :
            I_DATA      => i_data                                 , -- In  :
            I_VAL       => i_valid                                , -- In  :
            I_RDY       => i_ready                                , -- Out :
            O_CLK       => O_CLK                                  , -- In  :
            O_CLR       => O_CLR                                  , -- In  :
            O_CKE       => O_CKE                                  , -- In  :
            O_DATA      => o_data                                 , -- Out :
            O_VAL       => o_valid                                  -- Out :
        );                                                          -- 
    ------------------------------------------------------------------------------
    --! @brief O_OPEN_VAL/O_OPEN_INFO を出力. 
    ------------------------------------------------------------------------------
    O_OPEN_VAL  <= o_valid(VEC_RANGE.OPEN_INFO.VAL_POS);
    O_OPEN_INFO <= o_data (VEC_RANGE.OPEN_INFO.DATA_HI downto VEC_RANGE.OPEN_INFO.DATA_LO);
    ------------------------------------------------------------------------------
    --! @brief O_EVENT を出力. 
    ------------------------------------------------------------------------------
    O_EVENT_N : for i in 0 to EVENT_SIZE-1 generate
        O_EVENT(i) <= '1' when (o_valid(VEC_RANGE.EVENT(i).VAL_POS) = '1') else '0';
    end generate;
    ------------------------------------------------------------------------------
    --! @brief O_PUSH_FIN_XXX/O_CLOSE_VAL/O_CLOSE_INFO を出力.
    --! * PUSH_FIN_VALID /= 0 の場合は、O_PUSH_FIN は PUSH_FIN_DELAY で指定された
    --!   サイクル分だけ遅延して出力する.     
    --!   その際 O_CLOSE_VAL/INFO は O_PUSH_FIN の出力タイミングに合わせて出力.
    --! * PUSH_FIN_VALID  = 0 の場合は、O_PUSH_FIN は全て'0'を出力.
    ------------------------------------------------------------------------------
    O_PUSH_FIN_VALID: if (PUSH_FIN_VALID /= 0) generate
        signal    d_data         : std_logic_vector(VEC_RANGE.PUSH_FIN.DATA_HI downto VEC_RANGE.PUSH_FIN.DATA_LO);
        constant  DELAY_SEL      : std_logic_vector(PUSH_FIN_DELAY downto PUSH_FIN_DELAY) := (others => '1');
        signal    delay_valid    : std_logic_vector(PUSH_FIN_DELAY downto 0);
    begin 
        PUSH_FIN_REGS: DELAY_REGISTER                               -- 
            generic map (                                           -- 
                DATA_BITS   => d_data'length                      , -- 
                DELAY_MAX   => PUSH_FIN_DELAY                     , -- 
                DELAY_MIN   => PUSH_FIN_DELAY                       -- 
            )                                                       --
            port map (                                              -- 
                CLK         => O_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => O_CLR                              , -- In  :
                SEL         => DELAY_SEL                          , -- In  :
                D_VAL       => delay_valid                        , -- Out :
                I_DATA      => o_data (VEC_RANGE.PUSH_FIN.DATA_HI downto VEC_RANGE.PUSH_FIN.DATA_LO),
                I_VAL       => o_valid(VEC_RANGE.PUSH_FIN.VAL_POS), -- In  :
                O_DATA      => d_data                             , -- Out :
                O_VAL       => O_PUSH_FIN_VAL                       -- Out :
            );                                                      --
        CLOSE_REGS: DELAY_ADJUSTER                                  -- 
            generic map (                                           -- 
                DATA_BITS   => CLOSE_INFO_BITS                    , -- 
                DELAY_MAX   => PUSH_FIN_DELAY                     , -- 
                DELAY_MIN   => PUSH_FIN_DELAY                       -- 
            )                                                       --
            port map (                                              -- 
                CLK         => O_CLK                              , -- In  :
                RST         => RST                                , -- In  :
                CLR         => O_CLR                              , -- In  :
                SEL         => DELAY_SEL                          , -- In  :
                D_VAL       => delay_valid                        , -- In  :
                I_DATA      => o_data (VEC_RANGE.CLOSE_INFO.DATA_HI downto VEC_RANGE.CLOSE_INFO.DATA_LO), -- In :
                I_VAL       => o_valid(VEC_RANGE.CLOSE_INFO.VAL_POS), -- In  :
                O_DATA      => O_CLOSE_INFO                       , -- Out :
                O_VAL       => O_CLOSE_VAL                          -- Out :
            );                                                      -- 
        O_PUSH_FIN_SIZE <= d_data(VEC_RANGE.PUSH_FIN.SIZE_HI downto VEC_RANGE.PUSH_FIN.SIZE_LO);
        O_PUSH_FIN_LAST <= d_data(VEC_RANGE.PUSH_FIN.LAST_POS);
    end generate;
    O_PUSH_FIN_NONE: if (PUSH_FIN_VALID = 0) generate
        O_PUSH_FIN_VAL  <= '0';
        O_PUSH_FIN_LAST <= '0';
        O_PUSH_FIN_SIZE <= (others => '0');
        O_CLOSE_VAL     <= o_valid(VEC_RANGE.CLOSE_INFO.VAL_POS);
        O_CLOSE_INFO    <= o_data (VEC_RANGE.CLOSE_INFO.DATA_HI downto VEC_RANGE.CLOSE_INFO.DATA_LO);
    end generate;
    -------------------------------------------------------------------------------
    --! @brief O_PUSH_RSV_VAL/LAST/SIZE を出力.
    -------------------------------------------------------------------------------
    O_PUSH_RSV_VALID: if (PUSH_RSV_VALID /= 0) generate
        O_PUSH_RSV_VAL  <= o_valid(VEC_RANGE.PUSH_RSV.VAL_POS);
        O_PUSH_RSV_LAST <= o_data (VEC_RANGE.PUSH_RSV.LAST_POS);
        O_PUSH_RSV_SIZE <= o_data (VEC_RANGE.PUSH_RSV.SIZE_HI downto VEC_RANGE.PUSH_RSV.SIZE_LO);
    end generate;
    O_PUSH_RSV_NONE : if (PUSH_RSV_VALID  = 0) generate
        O_PUSH_RSV_VAL  <= '0';
        O_PUSH_RSV_LAST <= '0';
        O_PUSH_RSV_SIZE <= (others => '0');
    end generate;
    -------------------------------------------------------------------------------
    --! @brief O_PULL_FIN_VAL/LAST/SIZE を出力.
    -------------------------------------------------------------------------------
    O_PULL_FIN_VALID: if (PULL_FIN_VALID /= 0) generate
        O_PULL_FIN_VAL  <= o_valid(VEC_RANGE.PULL_FIN.VAL_POS);
        O_PULL_FIN_LAST <= o_data (VEC_RANGE.PULL_FIN.LAST_POS);
        O_PULL_FIN_SIZE <= o_data (VEC_RANGE.PULL_FIN.SIZE_HI downto VEC_RANGE.PULL_FIN.SIZE_LO);
    end generate;
    O_PULL_FIN_NONE : if (PULL_FIN_VALID  = 0) generate
        O_PULL_FIN_VAL  <= '0';
        O_PULL_FIN_LAST <= '0';
        O_PULL_FIN_SIZE <= (others => '0');
    end generate;
    -------------------------------------------------------------------------------
    --! @brief O_PULL_RSV_VAL/LAST/SIZE を出力.
    -------------------------------------------------------------------------------
    O_PULL_RSV_VALID: if (PULL_RSV_VALID /= 0) generate
        O_PULL_RSV_VAL  <= o_valid(VEC_RANGE.PULL_RSV.VAL_POS);
        O_PULL_RSV_LAST <= o_data (VEC_RANGE.PULL_RSV.LAST_POS);
        O_PULL_RSV_SIZE <= o_data (VEC_RANGE.PULL_RSV.SIZE_HI downto VEC_RANGE.PULL_RSV.SIZE_LO);
    end generate;
    O_PULL_RSV_NONE : if (PULL_RSV_VALID  = 0) generate
        O_PULL_RSV_VAL  <= '0';
        O_PULL_RSV_LAST <= '0';
        O_PULL_RSV_SIZE <= (others => '0');
    end generate;
end RTL;
