-----------------------------------------------------------------------------------
--!     @file    image_window_buffer.vhd
--!     @brief   Image Window Buffer Module :
--!              異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
--!     @version 1.8.0
--!     @date    2019/1/7
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2019 Ichiro Kawazome
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
--! @brief   IMAGE_WINDOW_BUFFER :
--!          異なるチャネル数のイメージウィンドウのデータを継ぐためのアダプタ
-----------------------------------------------------------------------------------
entity  IMAGE_WINDOW_BUFFER is
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        MAX_D_SIZE      : --! @brief MAX OUTPUT CHANNEL SIZE :
                          integer := 1;
        D_STRIDE        : --! @brief OUTPUT CHANNEL STRIDE SIZE :
                          integer := 1;
        D_UNROLL        : --! @brief OUTPUT CHANNEL UNROLL SIZE :
                          integer := 1;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 0;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 0;
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
    -- 
    -------------------------------------------------------------------------------
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_D_SIZE := 1;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
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
        O_D_ATRB        : --! @brief OUTPUT CHANNEL ATTRIBUTE :
                          out IMAGE_ATRB_VECTOR(0 to D_UNROLL-1);
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
end IMAGE_WINDOW_BUFFER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_CHANNEL_REDUCER;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_INTAKE_LINE_SELECTOR;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_OUTLET_LINE_SELECTOR;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_WINDOW_BUFFER_BANK_MEMORY;
architecture RTL of IMAGE_WINDOW_BUFFER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    type      PARAM_TYPE            is record
                  BANK_SIZE         :  integer;
                  LINE_SIZE         :  integer;
                  CHAN_SIZE         :  integer;
                  USE_BANK          :  boolean;
                  I_CHAN_ENABLE     :  boolean;
                  I_CHAN_PARAM      :  IMAGE_WINDOW_PARAM_TYPE;
                  I_CHAN_SIZE       :  integer;
                  I_CHAN_DONE       :  integer;
                  I_LINE_ENABLE     :  boolean;
                  I_LINE_PARAM      :  IMAGE_WINDOW_PARAM_TYPE;
                  I_LINE_QUEUE      :  integer;
                  O_LINE_ENABLE     :  boolean;
                  O_LINE_PARAM      :  IMAGE_WINDOW_PARAM_TYPE;
                  O_LINE_QUEUE      :  integer;
                  O_CHAN_ENABLE     :  boolean;
                  O_CHAN_PARAM      :  IMAGE_WINDOW_PARAM_TYPE;
                  O_CHAN_SIZE       :  integer;
                  O_CHAN_DONE       :  integer;
                  O_EXIT_PARAM      :  IMAGE_WINDOW_PARAM_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! 最大公約数(Greatest Common Divisor)を求める関数
    -------------------------------------------------------------------------------
    function  gcd(A,B:integer) return integer is
    begin
        if    (A < B) then
            return gcd(B, A);
        elsif (A mod B = 0) then
            return B;
        else
            return gcd(B, A mod B);
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! 最小公倍数(Least Common Multiple)を求める関数
    -------------------------------------------------------------------------------
    function  lcm(A,B:integer) return integer is
        variable g_c_d : integer;
    begin
        g_c_d := gcd(A,B);
        return g_c_d*(A/g_c_d)*(B/g_c_d);
    end function;
    -------------------------------------------------------------------------------
    --! @brief 整数の最小値を求める関数.
    -------------------------------------------------------------------------------
    function  minimum(L,R : integer) return integer is
    begin
        if (L < R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 整数の最大値を求める関数.
    -------------------------------------------------------------------------------
    function  maximum(L,R : integer) return integer is
    begin
        if (L > R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  INIT_PARAM return PARAM_TYPE is
        variable  param             :  PARAM_TYPE;
        variable  lcm_shape_c_size  :  integer;
        variable  lcm_shape_x_size  :  integer;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        lcm_shape_c_size   := lcm(I_PARAM.SHAPE.C.SIZE, O_PARAM.SHAPE.C.SIZE);
        param.CHAN_SIZE    := lcm_shape_c_size;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (BANK_SIZE = 0) then
            lcm_shape_x_size := lcm(I_PARAM.SHAPE.X.SIZE, O_PARAM.SHAPE.X.SIZE);
            param.BANK_SIZE  := 1;
            while (param.BANK_SIZE < lcm_shape_x_size) loop
                param.BANK_SIZE := 2*param.BANK_SIZE;
            end loop;
        else
            param.BANK_SIZE := BANK_SIZE;
        end if;
        param.USE_BANK := TRUE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        if (LINE_SIZE = 0) then
            param.LINE_SIZE := maximum((I_PARAM.SHAPE.Y.SIZE+O_PARAM.SHAPE.Y.SIZE),
                                       maximum((I_PARAM.SHAPE.Y.SIZE+I_PARAM.STRIDE.Y),
                                               (O_PARAM.SHAPE.Y.SIZE+O_PARAM.STRIDE.Y)));
        else
            param.LINE_SIZE := LINE_SIZE;
        end if;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.I_CHAN_ENABLE:= (I_PARAM.SHAPE.C.SIZE /= lcm_shape_c_size);
        param.I_CHAN_PARAM := NEW_IMAGE_WINDOW_PARAM(
                                  ELEM_BITS   => I_PARAM.ELEM_BITS,
                                  SHAPE       => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                     C => NEW_IMAGE_VECTOR_RANGE(lcm_shape_c_size),
                                                     X => I_PARAM.SHAPE.X,
                                                     Y => I_PARAM.SHAPE.Y
                                                 ),
                                  STRIDE      => I_PARAM.STRIDE,
                                  BORDER_TYPE => I_PARAM.BORDER_TYPE
                              );
        param.I_CHAN_SIZE  := 0;
        param.I_CHAN_DONE  := 0;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.I_LINE_ENABLE:= TRUE;
        param.I_LINE_PARAM := NEW_IMAGE_WINDOW_PARAM(
                                  ELEM_BITS   => param.I_CHAN_PARAM.ELEM_BITS,
                                  SHAPE       => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                     C => param.I_CHAN_PARAM.SHAPE.C,
                                                     X => param.I_CHAN_PARAM.SHAPE.X,
                                                     Y => NEW_IMAGE_VECTOR_RANGE(param.LINE_SIZE)
                                                 ),
                                  STRIDE      => param.I_CHAN_PARAM.STRIDE,
                                  BORDER_TYPE => param.I_CHAN_PARAM.BORDER_TYPE
                              );
        param.I_LINE_QUEUE := 2;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.O_EXIT_PARAM := NEW_IMAGE_WINDOW_PARAM(
                                  ELEM_BITS   => O_PARAM.ELEM_BITS,
                                  INFO_BITS   => D_UNROLL*IMAGE_ATRB_BITS,
                                  SHAPE       => O_PARAM.SHAPE,
                                  STRIDE      => O_PARAM.STRIDE,
                                  BORDER_TYPE => O_PARAM.BORDER_TYPE
                              );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.O_CHAN_ENABLE:= (O_PARAM.SHAPE.C.SIZE /= lcm_shape_c_size);
        param.O_CHAN_PARAM := NEW_IMAGE_WINDOW_PARAM(
                                  ELEM_BITS   => param.O_EXIT_PARAM.ELEM_BITS,
                                  INFO_BITS   => param.O_EXIT_PARAM.INFO_BITS,
                                  SHAPE       => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                     C => NEW_IMAGE_VECTOR_RANGE(lcm_shape_c_size),
                                                     X => param.O_EXIT_PARAM.SHAPE.X,
                                                     Y => param.O_EXIT_PARAM.SHAPE.Y
                                                 ),
                                  STRIDE      => param.O_EXIT_PARAM.STRIDE,
                                  BORDER_TYPE => param.O_EXIT_PARAM.BORDER_TYPE
                              );
        param.O_CHAN_SIZE  := 0;
        param.O_CHAN_DONE  := 0;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        param.O_LINE_ENABLE:= TRUE;
        param.O_LINE_PARAM := NEW_IMAGE_WINDOW_PARAM(
                                  ELEM_BITS   => param.O_CHAN_PARAM.ELEM_BITS,
                                  INFO_BITS   => param.O_CHAN_PARAM.INFO_BITS,
                                  SHAPE       => NEW_IMAGE_WINDOW_SHAPE_PARAM(
                                                     C => param.O_CHAN_PARAM.SHAPE.C,
                                                     X => param.O_CHAN_PARAM.SHAPE.X,
                                                     Y => NEW_IMAGE_VECTOR_RANGE(param.LINE_SIZE)
                                                 ),
                                  STRIDE      => param.O_CHAN_PARAM.STRIDE,
                                  BORDER_TYPE => param.O_CHAN_PARAM.BORDER_TYPE
                              );
        param.O_LINE_QUEUE := 2;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  PARAM                 :  PARAM_TYPE := INIT_PARAM;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    line_atrb             :  IMAGE_ATRB_VECTOR(PARAM.LINE_SIZE-1 downto 0);
    signal    line_valid            :  std_logic_vector (PARAM.LINE_SIZE-1 downto 0);
    signal    line_feed             :  std_logic_vector (PARAM.LINE_SIZE-1 downto 0);
    signal    line_return           :  std_logic_vector (PARAM.LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    i_chan_data           :  std_logic_vector (PARAM.I_CHAN_PARAM.DATA.SIZE-1 downto 0);
    signal    i_chan_valid          :  std_logic;
    signal    i_chan_ready          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    i_line_data           :  std_logic_vector (PARAM.I_LINE_PARAM.DATA.SIZE-1 downto 0);
    signal    i_line_valid          :  std_logic;
    signal    i_line_ready          :  std_logic;
    signal    i_line_enable         :  std_logic;
    signal    i_line_start          :  std_logic_vector (PARAM.LINE_SIZE-1 downto 0);
    signal    i_line_done           :  std_logic_vector (PARAM.LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    o_line_data           :  std_logic_vector (PARAM.O_LINE_PARAM.DATA.SIZE-1 downto 0);
    signal    o_line_valid          :  std_logic;
    signal    o_line_ready          :  std_logic;
    signal    o_line_start          :  std_logic_vector (PARAM.LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    o_chan_data           :  std_logic_vector (PARAM.O_CHAN_PARAM.DATA.SIZE-1 downto 0);
    signal    o_chan_valid          :  std_logic;
    signal    o_chan_ready          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    o_exit_data           :  std_logic_vector (PARAM.O_EXIT_PARAM.DATA.SIZE-1 downto 0);
    signal    o_exit_d_atrb         :  IMAGE_ATRB_VECTOR(0 to D_UNROLL-1);
    signal    o_exit_valid          :  std_logic;
    signal    o_exit_ready          :  std_logic;
    signal    o_exit_line_last      :  std_logic;
    signal    o_exit_frame_last     :  std_logic;
    signal    o_exit_feed           :  std_logic;
    signal    o_exit_return         :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- INTAKE_CHANNEL_REDUCER
    -------------------------------------------------------------------------------
    I_CHAN: if (PARAM.I_CHAN_ENABLE = TRUE) generate
        REDUCER: IMAGE_WINDOW_CHANNEL_REDUCER
            generic map (                                -- 
                I_PARAM         => I_PARAM             , -- 
                O_PARAM         => PARAM.I_CHAN_PARAM  , -- 
                C_SIZE          => PARAM.I_CHAN_SIZE   , --   
                C_DONE          => PARAM.I_CHAN_DONE     --   
            )                                            -- 
            port map (                                   -- 
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
            -----------------------------------------------------------------------
            -- 入力側 Window I/F
            -----------------------------------------------------------------------
                I_DATA          => I_DATA              , -- In  :
                I_VALID         => I_VALID             , -- In  :
                I_READY         => I_READY             , -- Out :
            -----------------------------------------------------------------------
            -- 出力側 Window I/F
            -----------------------------------------------------------------------
                O_DATA          => i_chan_data         , -- Out :
                O_VALID         => i_chan_valid        , -- Out :
                O_READY         => i_chan_ready          -- In  :
            );                                           -- 
    end generate;
    I_CHAN_NONE: if (PARAM.I_CHAN_ENABLE = FALSE) generate
        i_chan_data  <= I_DATA;
        i_chan_valid <= I_VALID;
        I_READY <= i_chan_ready;
    end generate;
    -------------------------------------------------------------------------------
    -- INTAKE_LINE_SELECTOR :
    -------------------------------------------------------------------------------
    I_LINE: if (PARAM.I_LINE_ENABLE = TRUE) generate
    begin 
        SELECTOR: IMAGE_WINDOW_BUFFER_INTAKE_LINE_SELECTOR
            generic map (                                -- 
                I_PARAM         => PARAM.I_CHAN_PARAM  , -- 
                O_PARAM         => PARAM.I_LINE_PARAM  , -- 
                LINE_SIZE       => PARAM.LINE_SIZE     , --   
                QUEUE_SIZE      => PARAM.I_LINE_QUEUE    --   
            )                                            -- 
            port map (                                   -- 
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
            -----------------------------------------------------------------------
            -- 入力側 I/F
            -----------------------------------------------------------------------
                I_DATA          => i_chan_data         , -- In  :
                I_VALID         => i_chan_valid        , -- In  :
                I_READY         => i_chan_ready        , -- Out :
            -----------------------------------------------------------------------
            -- 出力側 Window I/F
            -----------------------------------------------------------------------
                O_ENABLE        => i_line_enable       , -- Out :
                O_LINE_START    => i_line_start        , -- Out :
                O_LINE_DONE     => i_line_done         , -- Out :
                O_DATA          => i_line_data         , -- Out :
                O_VALID         => i_line_valid        , -- Out :
                O_READY         => i_line_ready        , -- In  :
            -----------------------------------------------------------------------
            -- ライン制御 I/F
            -----------------------------------------------------------------------
                LINE_VALID      => line_valid          , -- Out :
                LINE_ATRB       => line_atrb           , -- Out :
                LINE_FEED       => line_feed           , -- In  :
                LINE_RETURN     => line_return           -- In  :
            );                                           -- 
    end generate;                                        -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BANK: if (PARAM.USE_BANK = TRUE) generate
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        MEM: IMAGE_WINDOW_BUFFER_BANK_MEMORY             -- 
            generic map (                                -- 
                I_PARAM         => PARAM.I_LINE_PARAM  , -- 
                O_PARAM         => PARAM.O_LINE_PARAM  , --   
                ELEMENT_SIZE    => ELEMENT_SIZE        , --   
                CHANNEL_SIZE    => CHANNEL_SIZE        , --   
                BANK_SIZE       => PARAM.BANK_SIZE     , --   
                LINE_SIZE       => PARAM.LINE_SIZE     , --   
                MAX_D_SIZE      => MAX_D_SIZE          , --   
                D_STRIDE        => D_STRIDE            , --   
                D_UNROLL        => D_UNROLL            , --   
                ID              => ID                    --   
            )                                            -- 
            port map (                                   -- 
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
            -----------------------------------------------------------------------
            -- 入力側 制御 I/F
            -----------------------------------------------------------------------
                I_ENABLE        => i_line_enable       , -- In  :
                I_LINE_START    => i_line_start        , -- In  :
                I_LINE_DONE     => i_line_done         , -- Out :
            -----------------------------------------------------------------------
            -- 入力側 ウィンドウ I/F
            -----------------------------------------------------------------------
                I_DATA          => i_line_data         , -- In  :
                I_VALID         => i_line_valid        , -- In  :
                I_READY         => i_line_ready        , -- Out :
            -----------------------------------------------------------------------
            -- 出力側 制御 I/F
            -----------------------------------------------------------------------
                O_LINE_START    => o_line_start        , -- In  :
                O_LINE_ATRB     => line_atrb           , -- In  :
                D_SIZE          => D_SIZE              , -- In  :
            -----------------------------------------------------------------------
            -- 出力側 ウィンドウ I/F
            -----------------------------------------------------------------------
                O_DATA          => o_line_data         , -- Out :
                O_VALID         => o_line_valid        , -- Out :
                O_READY         => o_line_ready          -- In  :
            );
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_LINE: if (PARAM.O_LINE_ENABLE = TRUE) generate
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        SELECTOR: IMAGE_WINDOW_BUFFER_OUTLET_LINE_SELECTOR
            generic map (                                --
                I_PARAM         => PARAM.O_LINE_PARAM  , -- 
                O_PARAM         => PARAM.O_CHAN_PARAM  , -- 
                LINE_SIZE       => PARAM.LINE_SIZE     , -- 
                QUEUE_SIZE      => PARAM.O_LINE_QUEUE    -- 
            )                                            -- 
            port map (                                   -- 
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
            -----------------------------------------------------------------------
            -- 入力側 I/F
            -----------------------------------------------------------------------
                I_LINE_START    => o_line_start        , -- Out :
                I_DATA          => o_line_data         , -- In  :
                I_VALID         => o_line_valid        , -- In  :
                I_READY         => o_line_ready        , -- Out :
            -----------------------------------------------------------------------
            -- 出力側 I/F
            -----------------------------------------------------------------------
                O_DATA          => o_chan_data         , -- Out :
                O_VALID         => o_chan_valid        , -- Out :
                O_READY         => o_chan_ready        , -- In  :
                O_LAST          => o_exit_frame_last   , -- In  :
                O_FEED          => o_exit_feed         , -- In  :
                O_RETURN        => o_exit_return       , -- In  :
            -----------------------------------------------------------------------
            -- ライン制御 I/F
            -----------------------------------------------------------------------
                LINE_VALID      => line_valid          , -- In  :
                LINE_ATRB       => line_atrb           , -- In  :
                LINE_FEED       => line_feed           , -- Out :
                LINE_RETURN     => line_return           -- Out :
         );                                              --
    end generate;
    -------------------------------------------------------------------------------
    -- OUTLET_CHANNEL_REDUCER
    -------------------------------------------------------------------------------
    O_CHAN: if (PARAM.O_CHAN_ENABLE = TRUE) generate
        REDUCER: IMAGE_WINDOW_CHANNEL_REDUCER
            generic map (                                -- 
                I_PARAM         => PARAM.O_CHAN_PARAM  , -- 
                O_PARAM         => PARAM.O_EXIT_PARAM  , -- 
                C_SIZE          => PARAM.O_CHAN_SIZE   , --   
                C_DONE          => PARAM.O_CHAN_DONE     --   
            )                                            -- 
            port map (                                   -- 
            -----------------------------------------------------------------------
            -- クロック&リセット信号
            -----------------------------------------------------------------------
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => CLR                 , -- In  :
            -----------------------------------------------------------------------
            -- 入力側 Window I/F
            -----------------------------------------------------------------------
                I_DATA          => o_chan_data         , -- In  :
                I_VALID         => o_chan_valid        , -- In  :
                I_READY         => o_chan_ready        , -- Out :
            -----------------------------------------------------------------------
            -- 出力側 Window I/F
            -----------------------------------------------------------------------
                O_DATA          => o_exit_data         , -- Out :
                O_VALID         => o_exit_valid        , -- Out :
                O_READY         => o_exit_ready          -- In  :
            );                                           -- 
    end generate;
    O_CHAN_NONE: if (PARAM.O_CHAN_ENABLE = FALSE) generate
        o_exit_data  <= o_chan_data ;
        o_exit_valid <= o_chan_valid;
        o_chan_ready <= o_exit_ready;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (o_exit_data)
        alias info :  std_logic_vector(PARAM.O_EXIT_PARAM.DATA.INFO_FIELD.SIZE-1 downto 0) is o_exit_data(PARAM.O_EXIT_PARAM.DATA.INFO_FIELD.HI downto PARAM.O_EXIT_PARAM.DATA.INFO_FIELD.LO);
        alias elem :  std_logic_vector(PARAM.O_EXIT_PARAM.DATA.ELEM_FIELD.SIZE-1 downto 0) is o_exit_data(PARAM.O_EXIT_PARAM.DATA.ELEM_FIELD.HI downto PARAM.O_EXIT_PARAM.DATA.ELEM_FIELD.LO);
        alias atrb :  std_logic_vector(PARAM.O_EXIT_PARAM.DATA.ATRB_FIELD.SIZE-1 downto 0) is o_exit_data(PARAM.O_EXIT_PARAM.DATA.ATRB_FIELD.HI downto PARAM.O_EXIT_PARAM.DATA.ATRB_FIELD.LO);
    begin
        O_DATA(O_PARAM.DATA.ELEM_FIELD.HI downto O_PARAM.DATA.ELEM_FIELD.LO) <= elem;
        O_DATA(O_PARAM.DATA.ATRB_FIELD.HI downto O_PARAM.DATA.ATRB_FIELD.LO) <= atrb;
        for d_pos in 0 to D_UNROLL-1 loop
            o_exit_d_atrb(d_pos).VALID <= (info(d_pos*IMAGE_ATRB_BITS + IMAGE_ATRB_VALID_POS) = '1');
            o_exit_d_atrb(d_pos).START <= (info(d_pos*IMAGE_ATRB_BITS + IMAGE_ATRB_START_POS) = '1');
            o_exit_d_atrb(d_pos).LAST  <= (info(d_pos*IMAGE_ATRB_BITS + IMAGE_ATRB_LAST_POS ) = '1');
        end loop;
    end process;
    O_D_ATRB <= o_exit_d_atrb;
    O_VALID  <= o_exit_valid;
    o_exit_ready  <= O_READY;
    o_exit_line_last  <= '1' when (IMAGE_WINDOW_DATA_IS_LAST_C(PARAM.O_EXIT_PARAM, o_exit_data)) and
                                  (IMAGE_WINDOW_DATA_IS_LAST_X(PARAM.O_EXIT_PARAM, o_exit_data)) and
                                  (o_exit_d_atrb(o_exit_d_atrb'high).LAST                      ) and
                                  (o_exit_valid = '1' and o_exit_ready = '1'                   ) else '0';
    o_exit_frame_last <= '1' when (o_exit_line_last = '1'                                      ) and
                                  (IMAGE_WINDOW_DATA_IS_LAST_Y(PARAM.O_EXIT_PARAM, o_exit_data)) else '0';
    o_exit_feed       <= '1' when (o_exit_line_last = '1' and O_FEED   = '1') else '0';
    o_exit_return     <= '1' when (o_exit_line_last = '1' and O_RETURN = '1') else '0';

end RTL;
