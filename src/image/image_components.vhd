-----------------------------------------------------------------------------------
--!     @file    image_components.vhd                                            --
--!     @brief   PIPEWORK IMAGE COMPONENTS LIBRARY DESCRIPTION                   --
--!     @version 1.8.0                                                           --
--!     @date    2018/12/30                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2018 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
--      All rights reserved.                                                     --
--                                                                               --
--      Redistribution and use in source and binary forms, with or without       --
--      modification, are permitted provided that the following conditions       --
--      are met:                                                                 --
--                                                                               --
--        1. Redistributions of source code must retain the above copyright      --
--           notice, this list of conditions and the following disclaimer.       --
--                                                                               --
--        2. Redistributions in binary form must reproduce the above copyright   --
--           notice, this list of conditions and the following disclaimer in     --
--           the documentation and/or other materials provided with the          --
--           distribution.                                                       --
--                                                                               --
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT    --
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,    --
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT         --
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    --
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY    --
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      --
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE    --
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.     --
--                                                                               --
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief PIPEWORK IMAGE COMPONENTS LIBRARY DESCRIPTION                         --
-----------------------------------------------------------------------------------
package IMAGE_COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief IMAGE_ATRB_GENERATOR                                                  --
-----------------------------------------------------------------------------------
component IMAGE_ATRB_GENERATOR
    generic (
        ATRB_SIZE       : --! @brief ATTRIBUTE VECTOR SIZE :
                          integer := 1;
        STRIDE          : --! @brief STRIDE SIZE SIZE :
                          integer := 1;
        MAX_SIZE        : --! @brief MAX SIZE :
                          integer := 8;
        MAX_START_BORDER: --! @brief MAX START BORDER SIZE :
                          integer := 0;
        MAX_LAST_BORDER : --! @brief MAX LAST  BORDER SIZE :
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
    -- 入力 I/F
    -------------------------------------------------------------------------------
        LOAD            : --! @brief LOAD :
                          in  std_logic;
        CHOP            : --! @brief COUNT ENABLE :
                          in  std_logic;
        SIZE            : --! @brief SIZE :
                          in  integer range 0 to MAX_SIZE;
        START_BORDER    : --! @brief START BORDER SIZE :
                          in  integer range 0 to MAX_START_BORDER := 0;
        LAST_BORDER     : --! @brief LAST  BORDER SIZE :
                          in  integer range 0 to MAX_LAST_BORDER  := 0;
    -------------------------------------------------------------------------------
    -- 出力 I/F
    -------------------------------------------------------------------------------
        ATRB            : --! @brief OUTPUT ATTRIBUTE VECTOR:
                          --! 属性出力.
                          out IMAGE_ATRB_VECTOR(0 to ATRB_SIZE-1);
        START           : --! @brief OUTPUT START :
                          --! 現在の出力が最初の出力であることを示す.
                          out std_logic;
        LAST            : --! @brief OUTPUT LAST :
                          --! 現在の出力が最後の出力であることを示す.
                          out std_logic;
        TERM            : --! @brief OUTPUT TERMINATE :
                          --! 現在の最終位置が負になっていることを示す.
                          out std_logic;
        NEXT_ATRB       : --! @brief OUTPUT ATTRIBUTE VECTOR(NEXT CYCLE) :
                          --! 次のクロックでの属性出力.
                          out IMAGE_ATRB_VECTOR(0 to ATRB_SIZE-1);
        NEXT_START      : --! @brief OUTPUT START(NEXT CYCLE) :
                          --! 次のクロックでの出力が最初の出力であることを示す.
                          out std_logic;
        NEXT_LAST       : --! @brief OUTPUT LAST(NEXT_CYCLE) :
                          --! 次のクロックでの出力が最後の出力であることを示す.
                          out std_logic;
        NEXT_TERM       : --! @brief OUTPUT TERMINATE(NEXT_CYCLE) :
                          --! 次のクロックでの最終位置が負になっていることを示す.
                          out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_WINDOW_CHANNEL_REDUCER                                          --
-----------------------------------------------------------------------------------
component IMAGE_WINDOW_CHANNEL_REDUCER
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
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
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_WINDOW_BUFFER                                                   --
-----------------------------------------------------------------------------------
component IMAGE_WINDOW_BUFFER
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
        MEM_BANK_SIZE   : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        MEM_LINE_SIZE   : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
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
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_WINDOW_BUFFER_WRITER                                            --
-----------------------------------------------------------------------------------
component IMAGE_WINDOW_BUFFER_WRITER
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          --! I_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        BUF_ADDR_BITS   : --! メモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! メモリのデータのビット幅を指定する.
                          integer := 8
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
        I_DATA          : --! @brief INPUT WINDOW DATA :
                          --! ウィンドウデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_START_C       : --! @brief INPUT WINDOW CHANNEL START :
                          --! ウィンドウがチャネルの最初であることを示す. 
                          in  std_logic;
        I_LAST_C        : --! @brief INPUT WINDOW CHANNEL LAST :
                          --! ウィンドウがチャネルの最後であることを示す. 
                          in  std_logic;
        I_START_X       : --! @brief INPUT WINDOW CHANNEL X :
                          --! ウィンドウが X方向の最初であることを示す. 
                          in  std_logic;
        I_LAST_X        : --! @brief INPUT WINDOW CHANNEL X :
                          --! ウィンドウが X方向の最後であることを示す. 
                          in  std_logic;
        I_START_Y       : --! @brief INPUT WINDOW CHANNEL Y :
                          --! ウィンドウが Y方向の最初であることを示す. 
                          in  std_logic;
        I_LAST_Y        : --! @brief INPUT WINDOW CHANNEL Y :
                          --! ウィンドウが Y方向の最後であることを示す. 
                          in  std_logic;
        I_VALID         : --! @brief INPUT WINDOW DATA VALID :
                          --! 入力ウィンドウデータ有効信号.
                          --! * I_DATA/I_START_C/I_LAST_C/I_START_X/I_LAST_Xが有効
                          --! であることを示す.
                          in  std_logic;
        I_CLEAR         : --! @brief INPUT WINDOW STATE CLEAR :
                          in  std_logic;
        I_LINE_IDLE     : --! @brief INPUT WINDOW LINE IDLE :
                          in  std_logic;
        I_LINE_START    : --! @brief INPUT WINDOW LINE START :
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_READY    : --! @brief INPUT WINDOW LINE READY :
                          out std_logic_vector(LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_LINE_VALID    : --! @brief OUTPUT LINE VALID :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        O_X_SIZE        : --! @brief OUTPUT X SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_SIZE        : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_OFFSET      : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to 2**BUF_ADDR_BITS;
        O_LINE_ATRB     : --! @brief OUTPUT LINE ATTRIBUTE :
                          out IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        O_LINE_FEED     : --! @brief OUTPUT LINE FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        O_LINE_RETURN   : --! @brief OUTPUT LINE RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- バッファ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER WRITE DATA :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
        BUF_WE          : --! @brief BUFFER WRITE ENABLE :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE              -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_WINDOW_BUFFER_READER                                            --
-----------------------------------------------------------------------------------
component IMAGE_WINDOW_BUFFER_READER
    generic (
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        MAX_D_SIZE      : --! @brief MAX OUTPUT CHANNEL SIZE :
                          integer := 1;
        D_STRIDE        : --! @brief OUTPUT CHANNEL STRIDE SIZE :
                          integer := 1;
        D_UNROLL        : --! @brief OUTPUT CHANNEL UNROLL SIZE :
                          integer := 1;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8
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
        I_LINE_START    : --! @brief INPUT LINE START :
                          --! ライン開始信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_ATRB     : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_D_SIZE := 1;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        C_OFFSET        : --! @brief OUTPUT CHANNEL BUFFER ADDRESS OFFSET :
                          in  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT WINDOW DATA :
                          --! ウィンドウデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT WINDOW DATA VALID :
                          --! 出力ウィンドウデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT WINDOW DATA READY :
                          --! 出力ウィンドウデータレディ信号.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_WINDOW_BUFFER_INTAKE                                            --
-----------------------------------------------------------------------------------
component IMAGE_WINDOW_BUFFER_INTAKE
    generic (
        I_PARAM         : --! @brief INPUT  WINDOW PARAMETER :
                          --! 入力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8
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
        O_LINE_VALID    : --! @brief OUTPUT LINE VALID :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        O_X_SIZE        : --! @brief OUTPUT X SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_SIZE        : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_OFFSET      : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to 2**BUF_ADDR_BITS;
        O_LINE_ATRB     : --! @brief OUTPUT LINE ATTRIBUTE :
                          --! ライン属性出力.
                          out IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        O_LINE_FEED     : --! @brief OUTPUT LINE FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        O_LINE_RETURN   : --! @brief OUTPUT LINE RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER WRITE DATA :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
        BUF_WE          : --! @brief BUFFER WRITE ENABLE :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE              -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_WINDOW_BUFFER_OUTLET                                            --
-----------------------------------------------------------------------------------
component IMAGE_WINDOW_BUFFER_OUTLET
    generic (
        O_PARAM         : --! @brief OUTPUT WINDOW PARAMETER :
                          --! 出力側のウィンドウのパラメータを指定する.
                          IMAGE_WINDOW_PARAM_TYPE := NEW_IMAGE_WINDOW_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        MAX_D_SIZE      : --! @brief MAX OUTPUT CHANNEL SIZE :
                          integer := 1;
        D_STRIDE        : --! @brief OUTPUT CHANNEL STRIDE SIZE :
                          integer := 1;
        D_UNROLL        : --! @brief OUTPUT CHANNEL UNROLL SIZE :
                          integer := 1;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8
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
    -- 各種サイズ
    -------------------------------------------------------------------------------
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_D_SIZE := 1;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to ELEMENT_SIZE;
        C_OFFSET        : --! @brief OUTPUT CHANNEL BUFFER ADDRESS OFFSET :
                          in  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_LINE_VALID    : --! @brief INPUT LINE VALID :
                          --! ライン有効信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_ATRB     : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        I_LINE_FEED     : --! @brief INPUT LINE FEED :
                          --! ラインフィード信号出力.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          out std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        I_LINE_RETURN   : --! @brief INPUT LINE RETURN :
                          --! ラインリターン信号出力.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          out std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT WINDOW DATA :
                          --! ウィンドウデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_D_ATRB        : --! @brief OUTPUT CHANNEL ATTRIBUTE :
                          out IMAGE_ATRB_VECTOR(0 to D_UNROLL-1);
        O_VALID         : --! @brief OUTPUT WINDOW DATA VALID :
                          --! 出力ウィンドウデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT WINDOW DATA READY :
                          --! 出力ウィンドウデータレディ信号.
                          in  std_logic;
        O_LAST          : --! @brief OUTPUT LINE FEED :
                          --! 最終ウィンドウ入力.
                          in  std_logic;
        O_FEED          : --! @brief OUTPUT LINE FEED :
                          --! ラインフィード入力.
                          in  std_logic;
        O_RETURN        : --! @brief OUTPUT LINE RETURN :
                          --! ラインリターン入力.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end component;
end IMAGE_COMPONENTS;
