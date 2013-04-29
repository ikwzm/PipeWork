-----------------------------------------------------------------------------------
--!     @file    components.vhd                                                  --
--!     @brief   PIPEWORK COMPONENT LIBRARY DESCRIPTION                          --
--!     @version 1.5.0                                                           --
--!     @date    2013/04/29                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2013 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
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
-----------------------------------------------------------------------------------
--! @brief PIPEWORK COMPONENT LIBRARY DESCRIPTION                                --
-----------------------------------------------------------------------------------
package COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief CHOPPER                                                               --
-----------------------------------------------------------------------------------
component CHOPPER
    -------------------------------------------------------------------------------
    -- ジェネリック変数
    -------------------------------------------------------------------------------
    generic (
        BURST       : --! @brief BURST MODE : 
                      --! バースト転送に対応するかを指定する.
                      --! * 1:バースト転送に対応する.
                      --!   0:バースト転送に対応しない.
                      --! * バースト転送に対応する場合は、CHOP信号をアサートする度に 
                      --!   PIECE_COUNT や各種出力信号が更新される.
                      --! * バースト転送に対応しない場合は、カウンタの初期値は１に設
                      --!   定され、CHOP信号が一回アサートされた時点でカウンタは停止
                      --!   する. つまり、最初のピースのサイズしか生成されない.
                      --! * 当然 BURST=0 の方が回路規模は小さくなる.
                      integer range 0 to 1 := 1;
        MIN_PIECE   : --! @brief MINIMUM PIECE SIZE :
                      --! １ピースの大きさの最小値を2のべき乗値で指定する.
                      --! * 例えば、大きさの単位がバイトの場合次のようになる.
                      --!   0=1バイト、1=2バイト、2=4バイト、3=8バイト
                      integer := 6;
        MAX_PIECE   : --! @brief MAXIMUM PIECE SIZE :
                      --! １ピースの大きさの最大値を2のべき乗値で指定する.
                      --! * 例えば、大きさの単位がバイトの場合次のようになる.
                      --!   0=1バイト、1=2バイト、2=4バイト、3=8バイト
                      --! * MAX_PIECE > MIN_PIECE の場合、１ピースの大きさを 
                      --!   SEL 信号によって選択することができる.
                      --!   SEL信号の対応するビットを'1'に設定して他のビットを'0'に
                      --!   設定することによって１ピースの大きさを指定する.
                      --! * MAX_PIECE = MIN_PIECE の場合、１ピースの大きさは 
                      --!   MIN_PIECEの値になる.
                      --!   この場合は SEL 信号は使用されない.
                      --! * MAX_PIECE と MIN_PIECE の差が大きいほど、回路規模は
                      --!   大きくなる。
                      integer := 6;
        MAX_SIZE    : --! @brief MAXIMUM SIZE :
                      --! 想定している最大の大きさを2のべき乗値で指定する.
                      --! * この回路内で、MAX_SIZE-MIN_PIECEのビット幅のカウンタを
                      --!   生成する。
                      integer := 9;
        ADDR_BITS   : --! @brief BLOCK ADDRESS BITS :
                      --! ブロックの先頭アドレスを指定する信号(ADDR信号)の
                      --! ビット幅を指定する.
                      integer := 9;
        SIZE_BITS   : --! @brief BLOCK SIZE BITS :
                      --! ブロックの大きさを指定する信号(SIZE信号)のビット幅を
                      --! 指定する.
                      integer := 9;
        COUNT_BITS  : --! @brief OUTPUT COUNT BITS :
                      --! 出力するカウンタ信号(COUNT)のビット幅を指定する.
                      --! * 出力するカウンタのビット幅は、想定している最大の大きさ
                      --!   (MAX_SIZE)-１ピースの大きさの最小値(MIN_PIECE)以上で
                      --!   なければならない.
                      --! * カウンタ信号(COUNT)を使わない場合は、エラボレーション時
                      --!   にエラーが発生しないように1以上の値を指定しておく.
                      integer := 9;
        PSIZE_BITS  : --! @brief OUTPUT PIECE SIZE BITS :
                      --! 出力するピースサイズ(PSIZE,NEXT_PSIZE)のビット幅を指定する.
                      --! * ピースサイズのビット幅は、MAX_PIECE(１ピースのサイズを
                      --!   表現できるビット数)以上でなければならない.
                      integer := 9;
        GEN_VALID   : --! @brief GENERATE VALID FLAG :
                      --! ピース有効信号(VALID/NEXT_VALID)を生成するかどうかを指定する.
                      --! * GEN_VALIDが０以外の場合は、ピース有効信号を生成する.
                      --! * GEN_VALIDが０の場合は、ピース有効信号はALL'1'になる.
                      --! * GEN_VALIDが０以外でも、この回路の上位階層で
                      --!   ピース有効をopenにしても論理上は問題ないが、
                      --!   論理合成ツールによっては、コンパイルに膨大な時間を
                      --!   要することがある.
                      --!   その場合はこの変数を０にすることで解決出来る場合がある.
                      integer range 0 to 1 := 1
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
    -- 各種初期値
    -------------------------------------------------------------------------------
        ADDR        : --! @brief BLOCK ADDRESS :
                      --! ブロックの先頭アドレス.
                      --! * LOAD信号のアサート時に内部に保存される.
                      --! * 入力はADDR_BITSで示されるビット数あるが、実際に使用され
                      --!   るのは、1ピース分の下位ビットだけ.
                      in  std_logic_vector(ADDR_BITS-1 downto 0);
        SIZE        : --! @brief BLOCK SIZE :
                      --! ブロックの大きさ.
                      --! * LOAD信号のアサート時に内部に保存される.
                      in  std_logic_vector(SIZE_BITS-1 downto 0);
        SEL         : --! @brief PIECE SIZE SELECT :
                      --! １ピースの大きさを選択するための信号.
                      --! * LOAD信号のアサート時に内部に保存される.
                      --! * １ピースの大きさに対応するビットのみ'1'をセットし、他の
                      --!   ビットは'0'をセットすることで１ピースの大きさを選択する.
                      --! * もしSEL信号のうち複数のビットに'1'が設定されていた場合は
                      --!   もっとも最小値に近い値(MIN_PIECEの値)が選ばれる。
                      --! * この信号は MAX_PIECE > MIN_PIECE の場合にのみ使用される.
                      --! * この信号は MAX_PIECE = MIN_PIECE の場合は無視される.
                      in  std_logic_vector(MAX_PIECE downto MIN_PIECE);
        LOAD        : --! @brief LOAD :
                      --! ADDR,SIZE,SELを内部にロードするための信号.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 制御信号
    -------------------------------------------------------------------------------
        CHOP        : --! @brief CHOP ENABLE :
                      --! ブロックをピースに分割する信号.
                      --! * この信号のアサートによって、ピースカウンタ、各種フラグ、
                      --!   ピースサイズを更新され、次のクロックでこれらの信号が
                      --!   出力される.
                      --! * LOAD信号と同時にアサートされた場合はLOADの方が優先され、
                      --!   CHOP信号は無視される.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- ピースカウンタ/フラグ出力
    -------------------------------------------------------------------------------
        COUNT       : --! @brief PIECE COUNT :
                      --! 残りのピースの数.
                      --! * CHOP信号のアサートによりカウントダウンする.
                      out std_logic_vector(COUNT_BITS-1 downto 0);
        NONE        : --! @brief NONE PIECE FLAG :
                      --! 残りのピースの数が０になったことを示すフラグ.
                      --! * COUNT=0 で'1'が出力される.
                      out std_logic;
        LAST        : --! @brief LAST PIECE FLAG :
                      --! 残りのピースの数が１になったことを示すフラグ.
                      --! * COUNT=1 で'1'が出力される.
                      --! * 最後のピースであることを示す.
                      out std_logic;
        NEXT_NONE   : --! @brief NONE PIECE FLAG(NEXT CYCLE) :
                      --! 次のクロックで残りのピースの数が０になることを示すフラグ.
                      out std_logic;
        NEXT_LAST   : --! @brief LAST PIECE FLAG(NEXT CYCYE) :
                      --! 次のクロックで残りのピースの数が１になることを示すフラグ.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- ピースサイズ(1ピースの容量)出力
    -------------------------------------------------------------------------------
        PSIZE       : --! @brief PIECE SIZE :
                      --! 現在のピースの大きさを示す.
                      out std_logic_vector(PSIZE_BITS-1 downto 0);
        NEXT_PSIZE  : --! @brief PIECE SIZE(NEXT CYCLE)
                      --! 次のクロックでのピースの大きさを示す.
                      out std_logic_vector(PSIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- ピース有効出力
    -------------------------------------------------------------------------------
        VALID       : --! @brief PIECE VALID FLAG :
                      --! ピース有効信号.
                      --! * 例えば、ADDR=0x0002、SIZE=11、１ピースのサイズ=4の場合、
                      --!   "1100"、"1111"、"1111"、"0001" を生成する.
                      --! * GEN_VALIDが０以外の場合にのみ有効な値を生成する.
                      --! * GEN_VALIDが０の場合は常に ALL'1' を生成する.
                      out std_logic_vector(2**(MAX_PIECE)-1 downto 0);
        NEXT_VALID  : --! @brief PIECE VALID FALG(NEXT CYCLE)
                      --! 次のクロックでのピース有効信号
                      out std_logic_vector(2**(MAX_PIECE)-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief REDUCER                                                               --
-----------------------------------------------------------------------------------
component REDUCER
    generic (
        WORD_BITS   : --! @brief WORD BITS :
                      --! １ワードのデータのビット数を指定する.
                      integer := 8;
        STRB_BITS   : --! @brief ENABLE BITS :
                      --! ワードデータのうち有効なデータであることを示す信号(STRB)
                      --! のビット数を指定する.
                      integer := 1;
        I_WIDTH     : --! @brief INPUT WORD WIDTH :
                      --! 入力側のデータのワード数を指定する.
                      integer := 4;
        O_WIDTH     : --! @brief OUTPUT WORD WIDTH :
                      --! 出力側のデータのワード数を指定する.
                      integer := 4;
        QUEUE_SIZE  : --! @brief QUEUE SIZE :
                      --! キューの大きさをワード数で指定する.
                      --! * QUEUE_SIZE=0を指定した場合は、キューの深さは自動的に
                      --!   O_WIDTH+I_WIDTH+I_WIDTH-1 に設定される.
                      --! * QUEUE_SIZE<O_WIDTH+I_WIDTH-1の場合は、キューの深さは
                      --!   自動的にO_WIDTH+I_WIDTH-1に設定される.
                      integer := 0;
        VALID_MIN   : --! @brief BUFFER VALID MINIMUM NUMBER :
                      --! VALID信号の配列の最小値を指定する.
                      integer := 0;
        VALID_MAX   : --! @brief BUFFER VALID MAXIMUM NUMBER :
                      --! VALID信号の配列の最大値を指定する.
                      integer := 0;
        I_JUSTIFIED : --! @brief INPUT WORD JUSTIFIED :
                      --! 入力側の有効なデータが常にLOW側に詰められていることを
                      --! 示すフラグ.
                      --! * 常にLOW側に詰められている場合は、シフタが必要なくなる
                      --!   ため回路が簡単になる.
                      integer range 0 to 1 := 0;
        FLUSH_ENABLE: --! @brief FLUSH ENABLE :
                      --! FLUSH/I_FLUSHによるフラッシュ処理を有効にするかどうかを
                      --! 指定する.
                      --! * FLUSHとDONEとの違いは、DONEは最後のデータの出力時に
                      --!   キューの状態をすべてクリアするのに対して、
                      --!   FLUSHは最後のデータの出力時にSTRBだけをクリアしてVALは
                      --!   クリアしない.
                      --!   そのため次の入力データは、最後のデータの次のワード位置
                      --!   から格納される.
                      --! * フラッシュ処理を行わない場合は、0を指定すると回路が若干
                      --!   簡単になる.
                      integer range 0 to 1 := 1
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
                      --! * この信号はOFFSETを内部に設定してキューを初期化する.
                      --! * 最初にデータ入力と同時にアサートしても構わない.
                      in  std_logic := '0';
        OFFSET      : --! @brief OFFSET :
                      --! 最初のワードの出力位置を指定する.
                      --! * START信号がアサートされた時のみ有効.
                      --! * O_WIDTH>I_WIDTHの場合、最初のワードデータを出力する際の
                      --!   オフセットを設定できる.
                      --! * 例えばWORD_BITS=8、I_WIDTH=1(1バイト入力)、O_WIDTH=4(4バイト出力)の場合、
                      --!   OFFSET="0000"に設定すると、最初に入力したバイトデータは
                      --!   1バイト目から出力される.    
                      --!   OFFSET="0001"に設定すると、最初に入力したバイトデータは
                      --!   2バイト目から出力される.    
                      --!   OFFSET="0011"に設定すると、最初に入力したバイトデータは
                      --!   3バイト目から出力される.    
                      --!   OFFSET="0111"に設定すると、最初に入力したバイトデータは
                      --!   4バイト目から出力される.    
                      in  std_logic_vector(O_WIDTH-1 downto 0) := (others => '0');
        DONE        : --! @brief DONE :
                      --! 終了信号.
                      --! * この信号をアサートすることで、キューに残っているデータ
                      --!   を掃き出す.
                      --!   その際、最後のワードと同時にO_DONE信号がアサートされる.
                      --! * FLUSH信号との違いは、FLUSH_ENABLEの項を参照.
                      in  std_logic := '0';
        FLUSH       : --! @brief FLUSH :
                      --! フラッシュ信号.
                      --! * この信号をアサートすることで、キューに残っているデータ
                      --!   を掃き出す.
                      --!   その際、最後のワードと同時にO_FLUSH信号がアサートされる.
                      --! * DONE信号との違いは、FLUSH_ENABLEの項を参照.
                      in  std_logic := '0';
        BUSY        : --! @brief BUSY :
                      --! ビジー信号.
                      --! * 最初にデータが入力されたときにアサートされる.
                      --! * 最後のデータが出力し終えたらネゲートされる.
                      out std_logic;
        VALID       : --! @brief QUEUE VALID FLAG :
                      --! キュー有効信号.
                      --! * 対応するインデックスのキューに有効なワードが入って
                      --!   いるかどうかを示すフラグ.
                      out std_logic_vector(VALID_MAX downto VALID_MIN);
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_ENABLE    : --! @brief INPUT ENABLE :
                      --! 入力許可信号.
                      --! * この信号がアサートされている場合、キューの入力を許可する.
                      --! * この信号がネゲートされている場合、I_RDY アサートされない.
                      in  std_logic := '1';
        I_DATA      : --! @brief INPUT WORD DATA :
                      --! ワードデータ入力.
                      in  std_logic_vector(I_WIDTH*WORD_BITS-1 downto 0);
        I_STRB      : --! @brief INPUT WORD ENABLE :
                      --! ワードストローブ信号入力.
                      in  std_logic_vector(I_WIDTH*STRB_BITS-1 downto 0);
        I_DONE      : --! @brief INPUT WORD DONE :
                      --! 最終ワード信号入力.
                      --! * 最後の力ワードデータ入であることを示すフラグ.
                      --! * 基本的にはDONE信号と同じ働きをするが、I_DONE信号は
                      --!   最後のワードデータを入力する際に同時にアサートする.
                      --! * I_FLUSH信号との違いはFLUSH_ENABLEの項を参照.
                      in  std_logic := '0';
        I_FLUSH     : --! @brief INPUT WORD FLUSH :
                      --! 最終ワード信号入力.
                      --! * 最後のワードデータ入力であることを示すフラグ.
                      --! * 基本的にはFLUSH信号と同じ働きをするが、I_FLUSH信号は
                      --!   最後のワードデータを入力する際に同時にアサートする.
                      --! * I_DONE信号との違いはFLUSH_ENABLEの項を参照.
                      in  std_logic := '0';
        I_VAL       : --! @brief INPUT WORD VALID :
                      --! 入力ワード有効信号.
                      --! * I_DATA/I_STRB/I_DONE/I_FLUSHが有効であることを示す.
                      --! * I_VAL='1'and I_RDY='1'でワードデータがキューに取り込まれる.
                      in  std_logic;
        I_RDY       : --! @brief INPUT WORD READY :
                      --! 入力レディ信号.
                      --! * キューが次のワードデータを入力出来ることを示す.
                      --! * I_VAL='1'and I_RDY='1'でワードデータがキューに取り込まれる.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_ENABLE    : --! @brief OUTPUT ENABLE :
                      --! 出力許可信号.
                      --! * この信号がアサートされている場合、キューの出力を許可する.
                      --! * この信号がネゲートされている場合、O_VAL アサートされない.
                      in  std_logic := '1';
        O_DATA      : --! @brief OUTPUT WORD DATA :
                      --! ワードデータ出力.
                      out std_logic_vector(O_WIDTH*WORD_BITS-1 downto 0);
        O_STRB      : --! @brief OUTPUT WORD ENABLE :
                      --! ワードストローブ信号出力.
                      out std_logic_vector(O_WIDTH*STRB_BITS-1 downto 0);
        O_DONE      : --! @brief OUTPUT WORD DONE :
                      --! 最終ワード信号出力.
                      --! * 最後のワードデータ出力であることを示すフラグ.
                      --! * O_FLUSH信号との違いはFLUSH_ENABLEの項を参照.
                      out std_logic;
        O_FLUSH     : --! @brief OUTPUT WORD FLUSH :
                      --! 最終ワード信号出力.
                      --! * 最後のワードデータ出力であることを示すフラグ.
                      --! * O_DONE信号との違いはFLUSH_ENABLEの項を参照.
                      out std_logic;
        O_VAL       : --! @brief OUTPUT WORD VALID :
                      --! 出力ワード有効信号.
                      --! * O_DATA/O_STRB/O_DONE/O_FLUSHが有効であることを示す.
                      --! * O_VAL='1'and O_RDY='1'でワードデータがキューから取り除かれる.
                      out std_logic;
        O_RDY       : --! @brief OUTPUT WORD READY :
                      --! 出力レディ信号.
                      --! * キューから次のワードを取り除く準備が出来ていることを示す.
                      --! * O_VAL='1'and O_RDY='1'でワードデータがキューから取り除かれる.
                      in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief QUEUE_ARBITER                                                         --
-----------------------------------------------------------------------------------
component QUEUE_ARBITER
    generic (
        MIN_NUM     : --! @brief REQUEST MINIMUM NUMBER :
                      --! リクエストの最小番号を指定する.
                      integer := 0;
        MAX_NUM     : --! @brief REQUEST MAXIMUM NUMBER :
                      --! リクエストの最大番号を指定する.
                      integer := 7
    );
    port (
        CLK         : --! @brief CLOCK :
                      --! クロック信号
                      in  std_logic; 
        RST         : --! @brief ASYNCRONOUSE RESET :
                      --! 非同期リセット信号.アクティブハイ.
                      in  std_logic;
        CLR         : --! @brief SYNCRONOUSE RESET :
                      --! 同期リセット信号.アクティブハイ.
                      in  std_logic;
        ENABLE      : --! @brief ARBITORATION ENABLE :
                      --! この調停回路を有効にするかどうかを指定する.
                      --! * 幾つかの調停回路を組み合わせて使う場合、設定によっては
                      --!  この調停回路の出力を無効にしたいことがある.
                      --!  その時はこの信号を'0'にすることで簡単に出来る.
                      --! * ENABLE='1'でこの回路は調停を行う.
                      --! * ENABLE='0'でこの回路は調停を行わない.
                      --!   この場合REQUEST信号に関係なREQUEST_OおよびGRANTは'0'になる.
                      --!   リクエストキューの中身は破棄される.
                      in  std_logic := '1';
        REQUEST     : --! @brief REQUEST INPUT :
                      --! リクエスト入力.
                      in  std_logic_vector(MIN_NUM to MAX_NUM);
        GRANT       : --! @brief GRANT OUTPUT :
                      --! 調停結果出力.
                      out std_logic_vector(MIN_NUM to MAX_NUM);
        GRANT_NUM   : --! @brief GRANT NUMBER :
                      --! 許可番号.
                      --! * ただしリクエストキューに次の要求が無い場合でも、
                      --!   なんらかの番号を出力してしまう.
                      out integer   range  MIN_NUM to MAX_NUM;
        REQUEST_O   : --! @brief REQUEST OUTOUT :
                      --! リクエストキューに次の要求があることを示す信号.
                      --! * VALIDと異なり、リクエストキューに次の要求があっても、
                      --!   対応するREQUEST信号が'0'の場合はアサートされない.
                      out std_logic;
        VALID       : --! @brief REQUEST QUEUE VALID :
                      --! リクエストキューに次の要求があることを示す信号.
                      --! * REQUEST_Oと異なり、リスエストキューに次の要求があると
                      --!   対応するREQUEST信号の状態に関わらずアサートされる.
                      out std_logic;
        SHIFT       : --! @brief REQUEST QUEUE SHIFT :
                      --! リクエストキューの先頭からリクエストを取り除く信号.
                      in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief DELAY_REGISTER                                                        --
-----------------------------------------------------------------------------------
component DELAY_REGISTER
    generic (
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(IDATA/ODATA)のビット幅を指定する.
                      integer :=  8;
        DELAY_MAX   : --! @brief DELAY CYCLE MAXIMUM :
                      --! * 入力側データ(I_DATA)を出力側に伝達する際の遅延時間の
                      --!   最大値を出力側のクロック数単位で指定する.
                      --! * 詳細は次の DELAY_MIN を参照.
                      integer := 0;
        DELAY_MIN   : --! @brief DELAY CYCLE MINIMUM :
                      --! * 入力側データ(I_DATAを出力側に伝達する際の遅延時間の
                      --!   最小値を出力側のクロック数単位で指定する.
                      --! * DELAY_MAX >= DELAY_MINでなければならない.
                      --! * DELAY_MAX = DELAY_MIN の場合は回路が簡略化される.
                      --!   この際、DELAY_SEL 信号は参照されない.
                      --! * 遅延するクロック数が多いほど、そのぶんレジスタが
                      --!   増えることに注意.
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
    -- 制御/状態信号
    -------------------------------------------------------------------------------
        SEL         : --! @brief DELAY CYCLE SELECT :
                      --! 遅延サイクル選択信号.
                      --! * DELAY_MAX > DELAY_MIN の場合のみ有効.
                      --! * DELAY_MAX = DELAY_MIN の場合はこの信号は無視される.
                      in  std_logic_vector(DELAY_MAX   downto DELAY_MIN);
        D_VAL       : --! @brief DELAY VALID :
                      --! 対応する遅延レジスタに有効なデータが入っていることを示す.
                      out std_logic_vector(DELAY_MAX   downto 0);
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT WORD DATA :
                      --! 入力データ.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT WORD VALID :
                      --! 入力データ有効信号.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT WORD DATA :
                      --! 出力データ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT WORD VALID :
                      --! 出力データ有効信号.
                      out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief DELAY_ADJUSTER                                                        --
-----------------------------------------------------------------------------------
component DELAY_ADJUSTER
    generic (
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(IDATA/ODATA)のビット幅を指定する.
                      integer :=  8;
        DELAY_MAX   : --! @brief DELAY CYCLE MAXIMUM :
                      --! * 入力側データ(I_DATA)を出力側に伝達する際の遅延時間の
                      --!   最大値を出力側のクロック数単位で指定する.
                      --! * 詳細は次の DELAY_MIN を参照.
                      integer := 0;
        DELAY_MIN   : --! @brief DELAY CYCLE MINIMUM :
                      --! * 入力側データ(I_DATAを出力側に伝達する際の遅延時間の
                      --!   最小値を出力側のクロック数単位で指定する.
                      --! * DELAY_MAX >= DELAY_MINでなければならない.
                      --! * DELAY_MAX = DELAY_MIN の場合は回路が簡略化される.
                      --!   この際、DELAY_SEL 信号は参照されない.
                      --! * 遅延するクロック数が多いほど、そのぶんレジスタが
                      --!   増えることに注意.
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
    -- 制御/状態信号
    -------------------------------------------------------------------------------
        SEL         : --! @brief DELAY CYCLE SELECT :
                      --! 遅延サイクル選択信号.
                      --! * DELAY_MAX > DELAY_MIN の場合のみ有効.
                      --! * DELAY_MAX = DELAY_MIN の場合はこの信号は無視される.
                      in  std_logic_vector(DELAY_MAX   downto DELAY_MIN);
        D_VAL       : --! @brief DELAY VALID :
                      --! DELAY_REGISTERからの状態入力.
                      --! 対応する遅延レジスタに有効なデータが入っていることを示す.
                      in  std_logic_vector(DELAY_MAX   downto 0);
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT WORD DATA :
                      --! 入力データ.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT WORD VALID :
                      --! 入力データ有効信号.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT WORD DATA :
                      --! 出力データ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT WORD VALID :
                      --! 出力データ有効信号.
                      out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief QUEUE_REGISTER                                                        --
-----------------------------------------------------------------------------------
component QUEUE_REGISTER
    -------------------------------------------------------------------------------
    -- ジェネリック変数
    -------------------------------------------------------------------------------
    generic (
        QUEUE_SIZE  : --! @brief QUEUE SIZE :
                      --! キューの大きさをワード数で指定する.
                      integer := 1;
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(I_DATA/O_DATA/Q_DATA)のビット幅を指定する.
                      integer :=  32;
        LOWPOWER    : --! @brief LOW POWER MODE :
                      --! キューのレジスタに不必要なロードを行わないことにより、
                      --! レジスタが不必要にトグルすることを防いで消費電力を
                      --! 下げるようにする.
                      --! ただし、回路が若干増える.
                      integer range 0 to 1 := 1
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
    -- 入力側
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT DATA  :
                      --! 入力データ信号.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT DATA VALID :
                      --! 入力データ有効信号.
                      in  std_logic;
        I_RDY       : --! @brief INPUT READY :
                      --! 入力可能信号.
                      --! キューが空いていて、入力データを受け付けることが可能で
                      --! あることを示す信号.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT DATA :
                      --! 出力データ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT DATA VALID :
                      --! キューレジスタに有効なデータが入っている事を示すフラグ.
                      --! * キューレジスタは1〜QUEUE_SIZEまであるが、対応する位置の
                      --!   フラグが'1'ならば有効なデータが入っている事を示す.
                      --! * この出力信号の範囲が1からではなく0から始まっている事に
                      --!   注意. これはQUEUE_SIZE=0の場合に対応するため.
                      --!   QUEUE_SIZE>0の場合は、O_VAL(0)はO_VAL(1)と同じ.
                      out std_logic_vector(QUEUE_SIZE  downto 0);
        Q_DATA      : --! @brief OUTPUT REGISTERD DATA :
                      --! レジスタ出力の出力データ.
                      --! 出力データ(O_DATA)をクロックで叩いたもの.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        Q_VAL       : --! @brief OUTPUT REGISTERD DATA VALID :
                      --! キューレジスタに有効なデータが入っている事を示すフラグ.
                      --! O_VALをクロックで叩いたもの.
                      --! * キューレジスタは1〜QUEUE_SIZEまであるが、対応する位置の
                      --!   フラグが'1'ならば有効なデータが入っている事を示す.
                      --! * この出力信号の範囲が1からではなく0から始まっている事に
                      --!   注意. これはQUEUE_SIZE=0の場合に対応するため.
                      --!   QUEUE_SIZE>0の場合は、Q_VAL(0)はQ_VAL(1)と同じ.
                      out std_logic_vector(QUEUE_SIZE  downto 0);
        Q_RDY       : --! @brief OUTPUT READY :
                      --! 出力可能信号.
                      in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief SYNCRONIZER                                                           --
-----------------------------------------------------------------------------------
component SYNCRONIZER
    generic (
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(IDATA/ODATA)のビット幅を指定する.
                      integer :=  8;
        VAL_BITS    : --! @brief VALID BITS :
                      --! データ有効信号(IVAL/OVAL)のビット幅を指定する.
                      integer :=  1;
        I_CLK_RATE  : --! @brief INPUT CLOCK RATE :
                      --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側のクロッ
                      --! ク(O_CLK)との関係を指定する. 詳細は O_CLK_RATE を参照.
                      integer :=  1;
        O_CLK_RATE  : --! @brief OUTPUT CLOCK RATE :
                      --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側のクロッ
                      --! ク(O_CLK)との関係を指定する.
                      --! * I_CLK_RATE = 0 かつ O_CLK_RATE = 0 の場合は I_CLK と 
                      --!   O_CLK は非同期.
                      --! * I_CLK_RATE = 1 かつ O_CLK_RATE = 1 の場合は I_CLK と 
                      --!   O_CLK は完全に同期している.
                      --! * I_CLK_RATE > 1 かつ O_CLK_RATE = 1 の場合は I_CLK は 
                      --!   O_CLK のI_CLK_RATE倍の周波数.
                      --!   ただし I_CLK の立上りは O_CLK の立上りと一致している.
                      --! * I_CLK_RATE = 1 かつ O_CLK_RATE > 1 の場合は O_CLK は 
                      --!   I_CLK の O_CLK_RATE倍の周波数.
                      --!   ただし I_CLK の立上りは O_CLK の立上りと一致している.
                      --! * 例1)I_CLK_RATE=1 & O_CLK_RATE=1          \n
                      --!       I_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --!       O_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --! * 例2)I_CLK_RATE=2 & O_CLK_RATE=1          \n
                      --!       I_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --!       O_CLK _|~~~|___|~~~|___|~~~|___|~~~  \n
                      --!       I_CKE ~~~|___|~~~|___|~~~|___|~~~|_  \n
                      --! * 例3)I_CLK_RATE=3 & O_CLK_RATE=1          \n
                      --!       I_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --!       O_CLK _|~~~~~|_____|~~~~~|_____|~~~  \n
                      --!       I_CKE ~~~|_______|~~~|_______|~~~|_  \n
                      --! * 例4)I_CLK_RATE=1 & O_CLK_RATE=2          \n
                      --!       I_CLK _|~~~|___|~~~|___|~~~|___|~~~  \n
                      --!       O_CLK _|~|_|~|_|~|_|~|_|~|_|~|_|~|_  \n
                      --!       O_CKE ~~~|___|~~~|___|~~~|___|~~~|_  \n
                      integer :=  1;
        I_CLK_FLOP  : --! @brief INPUT CLOCK FLOPPING :
                      --! 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)が非同期
                      --! の場合に、出力側のFFからの制御信号を入力側のFFで叩く段数
                      --! を指定する.
                      --! * FFで叩くのはメタステーブルの発生による誤動作を防ぐため.
                      --!   メタステーブルの意味が分からない人は、この変数を変更す
                      --!   るのはやめたほうがよい。
                      integer range 0 to 1 := 1;
        O_CLK_FLOP  : --! @brief OUTPUT CLOCK FLOPPING :
                      --! 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)が非同期
                      --! の場合に、入力側のFFからの制御信号を出力側のFFで叩く段数
                      --! を指定する.
                      --! * FFで叩くのはメタステーブルの発生による誤動作を防ぐため.
                      --!   メタステーブルの意味が分からない人は、この変数を変更す
                      --!   るのはやめたほうがよい.
                      integer range 0 to 1 := 1;
        I_CLK_FALL  : --! @brief USE INPUT CLOCK FALL :
                      --! 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)が非同期
                      --! の場合に、入力側のクロック(I_CLK)の立ち下がりを使うかどう
                      --! かを指定する.
                      --! * この変数は後方互換性のために存在する. 現在は未使用.
                      --! * I_CLK_FALL = 0 の場合は使わない.
                      --! * I_CLK_FALL = 1 の場合は使う.
                      integer range 0 to 1 :=  0;
        O_CLK_FALL  : --! @brief USE OUTPUT CLOCK FALL :
                      --! 入力側のクロック(I_CLK)と出力側のクロック(O_CLK)が非同期
                      --! の場合に、出力側のクロック(OCLK)の立ち下がりを使うかどう
                      --! かを指定する.
                      --! * O_CLK_FALL = 0 の場合は使わない.
                      --! * O_CLK_FALL = 1 の場合は使う.
                      integer range 0 to 1 :=  0;
        O_CLK_REGS  : --! @brief REGISTERD OUTPUT :
                      --! 出力側の各種信号(O_VAL/O_DATA)をレジスタ出力するかどうか
                      --! を指定する.
                      --! * この変数は I_CLK_RATE > 0 の場合のみ有効. 
                      --!   I_CLK_RATE = 0 の場合は、常にレジスタ出力になる.
                      --! * O_CLK_REGS = 0 の場合はレジスタ出力しない.
                      --! * O_CLK_REGS = 1 の場合はレジスタ出力する.
                      integer range 0 to 1 :=  0
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号
    -------------------------------------------------------------------------------
        RST         : --! @brief RESET :
                      --! 非同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側のクロック信号/同期リセット信号
    -------------------------------------------------------------------------------
        I_CLK       : --! @brief INPUT CLOCK :
                      --! 入力側のクロック信号.
                      in  std_logic;
        I_CLR       : --! @brief INPUT CLEAR :
                      --! 入力側の同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側の制御信号
    -------------------------------------------------------------------------------
        I_CKE       : --! @brief INPUT CLOCK ENABLE :
                      --! 入力側のクロック(I_CLK)の立上りが有効であることを示す信号.
                      --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の位相
                      --!   関係を示す時に使用する.
                      --! * I_CLKの立上り時とOCLKの立上り時が同じ時にアサートするよ
                      --!   うに入力されなければならない.
                      --! * この信号は I_CLK_RATE > 1 かつ O_CLK_RATE = 1の時のみ有
                      --!   効. それ以外は未使用.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側のデータ信号/有効信号/可能信号
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT DATA :
                      --! 入力データ.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT VALID :
                      --! 入力有効信号.
                      --! * この信号がアサートされている時はI_DATAに有効なデータが
                      --!   入力されていなければならない。
                      in  std_logic_vector(VAL_BITS -1 downto 0);
        I_RDY       : --! @brief INPUT READY :
                      --! 入力可能信号.
                      --! * この信号がアサートされている場合にのみ、I_VAL,I_DATAを
                      --!   受け付けて、出力側に転送する.
                      --! * この信号がネゲートされている場合は、I_VAL,I_DATAは無視
                      --!   される.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側のクロック
    -------------------------------------------------------------------------------
        O_CLK       : --! @brief OUTPUT CLK :
                      --! 出力側のクロック信号.
                      in  std_logic;
        O_CLR       : --! @brief OUTPUT CLEAR :
                      --! 出力側の同期リセット信号(ハイ・アクティブ).
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 出力側の制御信号
    -------------------------------------------------------------------------------
        O_CKE       : --! @brief OUTPUT CLOCK ENABLE :
                      --! 出力側のクロック(O_CLK)の立上りが有効であることを示す信号.
                      --! * この信号は I_CLK_RATE > 1 の時に、I_CLK と O_CLK の位相
                      --!   関係を示す時に使用する.
                      --! * I_CLKの立上り時とO_CLKの立上り時が同じ時にアサートする
                      --!   ように入力されなければならない.
                      --! * この信号は O_CLK_RATE > 1 かつ I_CLK_RATE = 1の時のみ有
                      --!   効. それ以外は未使用.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 出力側のデータ信号/有効信号
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT DATA :
                      --! 出力データ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT VALID :
                      --! 出力有効信号.
                      --! * この信号がアサートされている時はODATAに有効なデータが出
                      --!   力されていることを示す.
                      out std_logic_vector(VAL_BITS -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief SYNCRONIZER_INPUT_PENDING_REGISTER                                    --
-----------------------------------------------------------------------------------
component SYNCRONIZER_INPUT_PENDING_REGISTER
    generic (
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(IDATA/ODATA)のビット幅を指定する.
                      integer :=  8;
        OPERATION   : --! @brief PENDING OPERATION :
                      --! ペンディング(出力待ち)時に次のIVALがアサートされた時に
                      --! データをどう扱うを指定する.
                      --! * OPERATION = 0 の場合は常に新しい入力データで上書きされる. 
                      --! * OPERATION = 1 の場合は入力データ(IDATA)と
                      --!   ペンディングデータとをビット単位で論理和して
                      --!   新しいペンディングデータとする.
                      --!   主に入力データがフラグ等の場合に使用する.
                      --! * OPERATION = 2 の場合は入力データ(IDATA)と
                      --!   ペンディングデータとを加算して
                      --!   新しいペンディングデータとする.
                      --!   主に入力データがカウンタ等の場合に使用する.
                      integer range 0 to 2 := 0
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT DATA :
                      --! 入力データ.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT VALID :
                      --! 入力有効信号.
                      --! * この信号がアサートされている時はI_DATAに有効なデータが
                      --!   入力されていなければならない。
                      in  std_logic;
        I_PAUSE     : --! @brief INPUT PAUSE :
                      --! * 入力側の情報(I_VAL,I_DATA)を、出力側(O_VAL,O_DATA)に
                      --!   出力するのを一時的に中断する。
                      --! * この信号がアサートされている間に入力された入力側の情報(
                      --!   I_VAL,I_DATA)は、出力側(O_VAL,O_DATA)には出力されず、
                      --!   ペンディングレジスタに保持される。
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側(PENDING) I/F
    -------------------------------------------------------------------------------
        P_DATA      : --! @brief PENDING DATA :
                      --! 現在ペンディング中のデータ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        P_VAL       : --! @brief PENDING VALID :
                      --! 現在ペンディング中のデータがあることを示すフラグ.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT DATA :
                      --! 出力データ.
                      --! * SYNCRONIZERのI_DATAに接続する.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT VALID :
                      --! 出力有効信号.
                      --! * SYNCRONIZERのI_VALに接続する.
                      --! * この信号がアサートされている時はO_DATAに有効なデータが
                      --!   出力されていることを示す.
                      out std_logic;
        O_RDY       : --! @brief OUTPUT READY :
                      --! 出力許可信号.
                      --! * SYNCRONIZERのI_RDYに接続する.
                      in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief SDPRAM                                                                --
-----------------------------------------------------------------------------------
component SDPRAM
    generic (
        DEPTH   : --! @brief SDPRAM DEPTH :
                  --! メモリの深さ(ビット単位)を2のべき乗値で指定する.
                  --! 例 DEPTH=10 => 2**10=1024bit
                  integer := 10;
        RWIDTH  : --! @brief SDPRAM READ DATA PORT WIDTH :
                  --! リードデータ(RDATA)の幅(ビット数)を2のべき乗値で指定する.
                  --! 例 RWIDTH=5 => 2**5=32bit
                  integer := 5;   
        WWIDTH  : --! @brief SDPRAM WRITE DATA PORT WIDTH :
                  --! ライトデータ(WDATA)の幅(ビット数)を2のべき乗値で指定する.
                  integer := 6;   
        WEBIT   : --! @brief SDPRAM WRITE ENABLE WIDTH :
                  --! ライトイネーブル信号(WE)の幅(ビット数)を2のべき乗値で指定する.
                  --! 例 WEBIT=0 => 2**0=1bit
                  --!    WEBIT=2 => 2**2=4bit
                  integer := 0;
        ID      : --! @brief SDPRAM IDENTIFIER :
                  --! どのモジュールで使われているかを示す識別番号.
                  integer := 0 
    );
    port (
        WCLK    : --! @brief WRITE CLOCK :
                  --! ライトクロック信号
                  in  std_logic;
        WE      : --! @brief WRITE ENABLE :
                  --! ライトイネーブル信号
                  in  std_logic_vector(2**WEBIT-1 downto 0);
        WADDR   : --! @brief WRITE ADDRESS :
                  --! ライトアドレス信号
                  in  std_logic_vector(DEPTH-1 downto WWIDTH);
        WDATA   : --! @brief WRITE DATA :
                  --! ライトデータ信号
                  in  std_logic_vector(2**WWIDTH-1 downto 0);
        RCLK    : --! @brief READ CLOCK :
                  --! リードクロック信号
                  in  std_logic;
        RADDR   : --! @brief READ ADDRESS :
                  --! リードアドレス信号
                  in  std_logic_vector(DEPTH-1 downto RWIDTH);
        RDATA   : --! @brief READ DATA :
                  --! リードデータ信号
                  out std_logic_vector(2**RWIDTH-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief COUNT_DOWN_REGISTER                                                   --
-----------------------------------------------------------------------------------
component COUNT_DOWN_REGISTER
    generic (
        VALID       : --! @brief COUNTER VALID :
                      --! このカウンターを有効にするかどうかを指定する.
                      --! * VALID=0 : このカウンターは常に無効.
                      --! * VALID=1 : このカウンターは常に有効.
                      integer range 0 to 1 := 1;
        BITS        : --! @brief  COUNTER BITS :
                      --! カウンターのビット数を指定する.
                      --! * BIT=0の場合、このカウンターは常に無効になる.
                      integer := 32;
        REGS_BITS   : --! @brief REGISTER ACCESS INTERFACE BITS :
                      --! レジスタアクセスインターフェースのビット数を指定する.
                      integer := 32
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
    -- レジスタアクセスインターフェース
    -------------------------------------------------------------------------------
        REGS_WEN    : --! @brief REGISTER WRITE ENABLE :
                      --! カウンタレジスタ書き込み制御信号.
                      --! * 書き込みを行うビットに'1'をセットする.  
                      --!   この信号に１がセットされたビットの位置に、REGS_DINの値
                      --!   がカウンタレジスタにセットされる.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_WDATA  : --! @brief REGISTER WRITE DATA :
                      --! カウンタレジスタ書き込みデータ.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_RDATA  : --! @brief REGISTER READ DATA :
                      --! カウンタレジスタ読み出しデータ.
                      out std_logic_vector(REGS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- カウントインターフェース
    -------------------------------------------------------------------------------
        DN_ENA      : --! @brief COUNT DOWN ENABLE :
                      --! カウントダウン許可信号.
                      --! * この信号が'1'の場合、DN_VAL信号およびDN_SIZE信号による
                      --!   カウントダウンが許可される.
                      --! * この信号が'1'の場合、REGS_WEN信号およびREGS_WDATA信号に
                      --!   よるレジスタ書き込みは無視される.
                      --! * この信号が'0'の場合、DN_VAL信号およびDN_SIZE信号による
                      --!   カウントダウンは無視される.
                      in  std_logic;
        DN_VAL      : --! @brief COUNT DOWN SIZE VALID :
                      --! カウントダウン有効信号.
                      --! * この信号が'1'の場合、DN_SIZEで指定された数だけカウンタ
                      --!   ーの値がアップする.
                      in  std_logic;
        DN_SIZE     : --! @brief COUNT DOWN SIZE :
                      --! カウントダウンサイズ信号.
                      in  std_logic_vector;
    -------------------------------------------------------------------------------
    -- カウンター出力
    -------------------------------------------------------------------------------
        COUNTER     : --! @brief COUNTER OUTPUT :
                      --! カウンタの値を出力.
                      out std_logic_vector;
        ZERO        : --! @brief COUNTER ZERO FLAG :
                      --! カウンタの値が0になったことを示すフラグ.
                      out std_logic;
        NEG         : --! @brief COUNTER ZERO FLAG :
                      --! カウンタの値が負になりそうだったことを示すフラグ.
                      --! * このフラグはDN_ENA信号が'1'の時のみ有効.
                      --! * このフラグはDN_ENA信号が'0'の時はクリアされる.
                      out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief COUNT_UP_REGISTER                                                     --
-----------------------------------------------------------------------------------
component COUNT_UP_REGISTER
    generic (
        VALID       : --! @brief COUNTER VALID :
                      --! このカウンターを有効にするかどうかを指定する.
                      --! * VALID=0 : このカウンターは常に無効.
                      --! * VALID=1 : このカウンターは常に有効.
                      integer range 0 to 1 := 1;
        BITS        : --! @brief  COUNTER BITS :
                      --! カウンターのビット数を指定する.
                      --! * BIT=0の場合、このカウンターは常に無効になる.
                      integer := 32;
        REGS_BITS   : --! @brief REGISTER ACCESS INTERFACE BITS :
                      --! レジスタアクセスインターフェースのビット数を指定する.
                      integer := 32
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
    -- レジスタアクセスインターフェース
    -------------------------------------------------------------------------------
        REGS_WEN    : --! @brief REGISTER WRITE ENABLE :
                      --! カウンタレジスタ書き込み制御信号.
                      --! * 書き込みを行うビットに'1'をセットする.  
                      --!   この信号に１がセットされたビットの位置に、REGS_DINの値
                      --!   がカウンタレジスタにセットされる.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_WDATA  : --! @brief REGISTER WRITE DATA :
                      --! カウンタレジスタ書き込みデータ.
                      in  std_logic_vector(REGS_BITS-1 downto 0);
        REGS_RDATA  : --! @brief REGISTER READ DATA :
                      --! カウンタレジスタ読み出しデータ.
                      out std_logic_vector(REGS_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- カウントインターフェース
    -------------------------------------------------------------------------------
        UP_ENA      : --! @brief COUNT UP ENABLE :
                      --! カウントアップ許可信号.
                      --! * この信号が'1'の場合、UP_VAL信号およびUP_SIZE信号による
                      --!   カウントアップが許可される.
                      --! * この信号が'1'の場合、REGS_WEN信号およびREGS_WDATA信号に
                      --!   よるレジスタ書き込みは無視される.
                      --! * この信号が'0'の場合、UP_VAL信号およびUP_SIZE信号による
                      --!   カウントアップは無視される.
                      in  std_logic;
        UP_VAL      : --! @brief COUNT UP SIZE VALID :
                      --! カウントアップ有効信号.
                      --! * この信号が'1'の場合、UP_SIZEで指定された数だけカウンタ
                      --!   ーの値がアップする.
                      in  std_logic;
        UP_BEN      : --! @brief COUNT UP BIT ENABLE :
                      --! カウントアップビット有効信号.
                      --! * この信号が'1'の位置のビットのみ、カウンタアップを有効に
                      --!   する.
                      in  std_logic_vector;
        UP_SIZE     : --! @brief COUNT UP SIZE :
                      --! カウントアップサイズ信号.
                      in  std_logic_vector;
    -------------------------------------------------------------------------------
    -- カウンター出力
    -------------------------------------------------------------------------------
        COUNTER     : --! @brief COUNTER OUTPUT :
                      --! カウンタの値を出力.
                      out std_logic_vector
    );
end component;
-----------------------------------------------------------------------------------
--! @brief POOL_INTAKE_PORT                                                      --
-----------------------------------------------------------------------------------
component POOL_INTAKE_PORT
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
                          --! * 少なくともキューの大きさは、(PORT_DATA_BITS/WORD_BITS)+
                          --!   (POOL_DATA_BITS/WORD_BITS)-1以上でなければならない.
                          --! * QUEUE_SIZE=0を指定した場合はキューの深さは自動的に
                          --!   (PORT_DATA_BITS/WORD_BITS)+(POOL_DATA_BITS/WORD_BITS)
                          --!   に設定される.
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
                          --! * この信号がアサートされている場合、キューの入出力を
                          --!   許可する.
                          --! * この信号がネゲートされている場合、PORT_RDY はアサー
                          --!   トされない.
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
                          --! PUSH_LAST/PUSH_ERR/PUSH_SIZEが有効であることを示す.
                          out std_logic_vector(SEL_BITS-1 downto 0);
        PUSH_LAST       : --! @brief PUSH LAST : 
                          --! 最後の転送"した事"を示すフラグ.
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
end component;
-----------------------------------------------------------------------------------
--! @brief FLOAT_INTAKE_VALVE                                                    --
-----------------------------------------------------------------------------------
component FLOAT_INTAKE_VALVE
    generic (
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! 内部カウンタのビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! サイズ信号のビット数を指定する.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
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
        RESET           : --! @brief RESET REQUEST :
                          --! 強制的に内部状態をリセットする事を指示する信号.
                          in  std_logic;
        PAUSE           : --! @brief PAUSE REQUEST :
                          --! 強制的にフローを一時的に停止する事を指示する信号.
                          in  std_logic;
        STOP            : --! @brief STOP  REQUEST :
                          --! 強制的にフローを中止する事を指示する信号.
                          in  std_logic;
        INTAKE_OPEN     : --! @brief INTAKE VALVE OPEN FLAG :
                          --! 入力(INTAKE)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! 出力(OUTLET)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        POOL_SIZE       : --! @brief POOL SIZE :
                          --! プールの大きさをバイト数で指定する.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以下の時に出力を開始する.
                          --! フローカウンタの値がこの値を越えた時に出力を一時停止.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VALID      : --! @brief PUSH VALID :
                          --! PUSH_LAST/PUSH_SIZEが有効であることを示す信号.
                          in  std_logic;
        PUSH_LAST       : --! @brief PUSH LAST :
                          --! 最後の入力であることを示す信号.
                          in  std_logic;
        PUSH_SIZE       : --! @brief PUSH SIZE :
                          --! 入力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VALID      : --! @brief PULL VALID :
                          --! PULL_LAST/PULL_SIZEが有効であることを示す信号.
                          in  std_logic;
        PULL_LAST       : --! @brief PULL LAST :
                          --! 最後の出力であることを示す信号.
                          in  std_logic;
        PULL_SIZE       : --! @brief PULL SIZE :
                          --! 出力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW INTAKE READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY='1' : 再開.
                          --! * FLOW_PAUSE='0' : 一時停止.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以下の時に
                          --!   '1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL を越えた時に
                          --!   '0'を出力する.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW INTAKE PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE='0' : 再開.
                          --! * FLOW_PAUSE='1' : 一時停止.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以下の時に
                          --!   '0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL を越えた時に
                          --!   '1'を出力する.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW INTAKE STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_STOP='1' : 中止を指示.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW INTAKE LAST :
                          --! INTAKE側では未使用. 常に'0'が出力.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW INTAKE ENABLE SIZE :
                          --! 入力可能なバイト数
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter Signals.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! 現在のフローカウンタの値を出力.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_ZERO       : --! @brief FLOW COUNTER is ZERO :
                          --! フローカウンタの値が0になったことを示すフラグ.
                          out std_logic;
        FLOW_POS        : --! @brief FLOW COUNTER is POSitive :
                          --! フローカウンタの値が正(>0)になったことを示すフラグ.
                          out std_logic;
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! フローカウンタの値が負(<0)になったことを示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief FLOAT_INTAKE_MANIFOLD_VALVE                                           --
-----------------------------------------------------------------------------------
component FLOAT_INTAKE_MANIFOLD_VALVE
    generic (
        PRECEDE         : --! @brief PRECEDE ENABLE :
                          --! 先行(Precede)モードでフローを制御するかどうかを指定する.
                          --! * PRECEDE=0 : 非先行モード. フローカウンタの減算に
                          --!   PULL_FIN_SIZE(出力が確定(FINAL)したバイト数)を使う.
                          --! * PRECEDE=1 : 先行モードでは、フローカウンタの減算に 
                          --!   PULL_RSV_SIZE(出力する予定(RESERVE)のバイト数)を使う.
                          integer range 0 to 1 := 0;
        FIXED           : --! @brief FIXED VALVE OPEN/CLOSE :
                          --! フローカウンタによるフロー制御を行わず、常にバルブが
                          --! 閉じた状態または開いた状態にするか否かを指定する.
                          --! * FIXED=0 : フローカウンタによるフロー制御を行う.
                          --! * FIXED=1 : 常にバルブが閉じた状態にする.
                          --! * FIXED=2 : 常にバルブが開いた状態にする.
                          integer range 0 to 2 := 0;
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! 内部カウンタのビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! サイズ信号のビット数を指定する.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
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
        RESET           : --! @brief RESET REQUEST :
                          --! 強制的に内部状態をリセットする事を指示する信号.
                          in  std_logic;
        PAUSE           : --! @brief PAUSE REQUEST :
                          --! 強制的にフローを一時的に停止する事を指示する信号.
                          in  std_logic;
        STOP            : --! @brief STOP  REQUEST :
                          --! 強制的にフローを中止する事を指示する信号.
                          in  std_logic;
        INTAKE_OPEN     : --! @brief INTAKE VALVE OPEN FLAG :
                          --! 入力(INTAKE)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! 出力(OUTLET)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        POOL_SIZE       : --! @brief POOL SIZE :
                          --! プールの大きさをバイト数で指定する.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以下の時に入力を開始する.
                          --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        POOL_READY_LEVEL: --! @brief POOL READY LEVEL :
                          --! 先行モード(PRECEDE=1)の時、PULL_FIN_SIZEによるプール
                          --! カウンタの減算結果が、この値以下の時にPOOL_READY 信号
                          --! をアサートする.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VALID      : --! @brief PUSH VALID :
                          --! PUSH_LAST/PUSH_SIZEが有効であることを示す信号.
                          in  std_logic;
        PUSH_LAST       : --! @brief PUSH LAST :
                          --! 最後のPUSH入力であることを示す信号.
                          in  std_logic;
        PUSH_SIZE       : --! @brief PUSH SIZE :
                          --! 入力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Final Size Signals.
    -------------------------------------------------------------------------------
        PULL_FIN_VALID  : --! @brief PULL FINAL VALID :
                          --! PULL_FIN_LAST/PULL_FIN_SIZEが有効であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PULL_FIN_LAST   : --! @brief PULL FINAL LAST :
                          --! 最後のPULL_FIN入力であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PULL_FIN_SIZE   : --! @brief PUSH RESERVE SIZE :
                          --! 出力が確定(FINAL)したバイト数.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Reserve Size Signals.
    -------------------------------------------------------------------------------
        PULL_RSV_VALID  : --! @brief PULL RESERVE VALID :
                          --! PULL_RSV_LAST/PULL_RSV_SIZEが有効であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic;
        PULL_RSV_LAST   : --! @brief PULL RESERVE LAST :
                          --! 最後のPULL_RSV入力であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic;
        PULL_RSV_SIZE   : --! @brief PULL RESERVE SIZE :
                          --! 出力する予定(RESERVE)のバイト数.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW INTAKE READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY='1' : 再開.
                          --! * FLOW_READY='0' : 一時停止.
                          --! * バルブが開固定(FIXED=2)の時は常に'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常に'0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以下の時に
                          --!   '1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL を越えた時に
                          --!   '0'を出力する.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW INTAKE PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE='0' : 再開.
                          --! * FLOW_PAUSE='1' : 一時停止.
                          --! * バルブが開固定(FIXED=2)の時は常に'0'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常に'1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以下の時に
                          --!   '0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL を越えた時に
                          --!   '1'を出力する.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW INTAKE STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_PAUSE=1 : 中止.
                          --! * バルブが開固定(FIXED=2)の時は常に'0'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常に'1'を出力する.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW INTAKE LAST :
                          --! INTAKE側では未使用. 常に'0'を出力.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW INTAKE ENABLE SIZE :
                          --! 入力可能なバイト数
                          --! * バルブが開固定(FIXED=2)の時は常にALL'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常にALL'0'を出力する.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! 現在のフローカウンタの値を出力.
                          --! * バルブが開固定(FIXED=2)の時は常にALL'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常にALL'0'を出力する.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_ZERO       : --! @brief FLOW COUNTER is ZERO :
                          --! フローカウンタの値が0になったことを示すフラグ.
                          out std_logic;
        FLOW_POS        : --! @brief FLOW COUNTER is POSitive :
                          --! フローカウンタの値が正(>0)になったことを示すフラグ.
                          out std_logic;
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! フローカウンタの値が負(<0)になったことを示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic;
        POOL_COUNT      : --! @brief POOL COUNT :
                          --! 現在のプールカウンタの値を出力.
                          --! * バルブが非先行モード(PRECEDE=0)の場合はFLOW_COUNTと
                          --!   同じ値を出力する.
                          --! * バルブが開固定(FIXED=2)の時は常にALL'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常にALL'0'を出力する.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        POOL_READY      : --! @brief POOL READY :
                          --! プールカウンタの値が POOL_READY_LEVEL 以下であること
                          --! を示すフラグ.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は常に'1'を出
                          --!   力する.
                          --! * バルブが開固定(FIXED=2)の時は常に'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常に'0'を出力する.
                          out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief FLOAT_OUTLET_VALVE                                                    --
-----------------------------------------------------------------------------------
component FLOAT_OUTLET_VALVE
    generic (
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! 内部カウンタのビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! サイズ信号のビット数を指定する.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
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
        RESET           : --! @brief RESET REQUEST :
                          --! 強制的に内部状態をリセットする事を指示する信号.
                          in  std_logic;
        PAUSE           : --! @brief PAUSE REQUEST :
                          --! 強制的にフローを一時的に停止する事を指示する信号.
                          in  std_logic;
        STOP            : --! @brief STOP  REQUEST :
                          --! 強制的にフローを中止する事を指示する信号.
                          in  std_logic;
        INTAKE_OPEN     : --! @brief INTAKE VALVE OPEN FLAG :
                          --! 入力(INTAKE)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! 出力(OUTLET)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以上の時に転送を開始する.
                          --! フローカウンタの値がこの値未満の時に転送を一時停止.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Size Signals.
    -------------------------------------------------------------------------------
        PUSH_VALID      : --! @brief PUSH VALID :
                          --! PUSH_LAST/PUSH_SIZEが有効であることを示す信号.
                          in  std_logic;
        PUSH_LAST       : --! @brief PUSH LAST :
                          --! 最後の入力であることを示す信号.
                          in  std_logic;
        PUSH_SIZE       : --! @brief PUSH SIZE :
                          --! 入力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VALID      : --! @brief PULL VALID :
                          --! PULL_LAST/PULL_SIZEが有効であることを示す信号.
                          in  std_logic;
        PULL_LAST       : --! @brief PULL LAST :
                          --! 最後の出力であることを示す信号.
                          in  std_logic;
        PULL_SIZE       : --! @brief PULL SIZE :
                          --! 出力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW OUTLET READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY='1' : 再開.
                          --! * FLOW_READY='0' : 一時停止.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以上の時に
                          --!   '1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 未満の時に
                          --!   '0'を出力する.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW OUTLET PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE='0' : 再開.
                          --! * FLOW_PAUSE='1' : 一時停止.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以上の時に
                          --!   '0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 未満の時に
                          --!   '1'を出力する.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW OUTLET STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_STOP='1' : 中止を指示.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW OUTLET LAST :
                          --! 入力側から最後の入力を示すフラグがあったことを示す.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW OUTLET ENABLE SIZE :
                          --! 出力可能なバイト数
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter Signals.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! 現在のフローカウンタの値を出力.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_ZERO       : --! @brief FLOW COUNTER is ZERO :
                          --! フローカウンタの値が0になったことを示すフラグ.
                          out std_logic;
        FLOW_POS        : --! @brief FLOW COUNTER is POSitive :
                          --! フローカウンタの値が正(>0)になったことを示すフラグ.
                          out std_logic;
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! フローカウンタの値が負(<0)になったことを示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief FLOAT_OUTLET_MANIFOLD_VALVE                                           --
-----------------------------------------------------------------------------------
component FLOAT_OUTLET_MANIFOLD_VALVE
    generic (
        PRECEDE         : --! @brief PRECEDE ENABLE :
                          --! 先行(Precede)モードでフローを制御するかどうかを指定する.
                          --! * PRECEDE=0 : 非先行モード. フローカウンタの加算に
                          --!   PUSH_FIN_SIZE(入力が確定(FINAL)したバイト数)を使う.
                          --! * PRECEDE=1 : 先行モードでは、フローカウンタの加算に 
                          --!   PUSH_RSV_SIZE(入力する予定(RESERVE)のバイト数)を使う.
                          integer range 0 to 1 := 0;
        FIXED           : --! @brief FIXED VALVE OPEN/CLOSE :
                          --! フローカウンタによるフロー制御を行わず、常にバルブが
                          --! 閉じた状態または開いた状態にするか否かを指定する.
                          --! * FIXED=0 : フローカウンタによるフロー制御を行う.
                          --! * FIXED=1 : 常にバルブが閉じた状態にする.
                          --! * FIXED=2 : 常にバルブが開いた状態にする.
                          integer range 0 to 2 := 0;
        COUNT_BITS      : --! @brief COUNTER BITS :
                          --! 内部カウンタのビット数を指定する.
                          integer := 32;
        SIZE_BITS       : --! @brief SIZE BITS :
                          --! サイズ信号のビット数を指定する.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
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
        RESET           : --! @brief RESET REQUEST :
                          --! 強制的に内部状態をリセットする事を指示する信号.
                          in  std_logic;
        PAUSE           : --! @brief PAUSE REQUEST :
                          --! 強制的にフローを一時的に停止する事を指示する信号.
                          in  std_logic;
        STOP            : --! @brief STOP  REQUEST :
                          --! 強制的にフローを中止する事を指示する信号.
                          in  std_logic;
        INTAKE_OPEN     : --! @brief INTAKE VALVE OPEN FLAG :
                          --! 入力(INTAKE)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        OUTLET_OPEN     : --! @brief OUTLET VALVE OPEN FLAG :
                          --! 出力(OUTLET)側のバルブが開いている事を示すフラグ.
                          in  std_logic;
        FLOW_READY_LEVEL: --! @brief FLOW READY LEVEL :
                          --! 一時停止する/しないを指示するための閾値.
                          --! フローカウンタの値がこの値以上の時に転送を開始する.
                          --! フローカウンタの値がこの値未満の時に転送を一時停止.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
        POOL_READY_LEVEL: --! @brief POOL READY LEVEL :
                          --! 先行モード(PRECEDE=1)の時、PULL_FIN_SIZEによるフロー
                          --! カウンタの加算結果が、この値以上の時にPOOL_READY 信号
                          --! をアサートする.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Final Size Signals.
    -------------------------------------------------------------------------------
        PUSH_FIN_VALID  : --! @brief PUSH FINAL VALID :
                          --! PUSH_FIN_LAST/PUSH_FIN_SIZEが有効であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PUSH_FIN_LAST   : --! @brief PUSH FINAL LAST :
                          --! 最後のPUSH_FIN入力であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic;
        PUSH_FIN_SIZE   : --! @brief PUSH FINAL SIZE :
                          --! 入力が確定(FINAL)したバイト数.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Push Reserve Size Signals.
    -------------------------------------------------------------------------------
        PUSH_RSV_VALID  : --! @brief PUSH RESERVE VALID :
                          --! PUSH_RSV_LAST/PUSH_RSV_SIZEが有効であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic;
        PUSH_RSV_LAST   : --! @brief PUSH RESERVE LAST :
                          --! 最後のPUSH_RSV入力であることを示す信号.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic;
        PUSH_RSV_SIZE   : --! @brief PUSH RESERVE SIZE :
                          --! 入力する予定(RESERVE)のバイト数.
                          --! * バルブが固定(Fixed)モードの場合は未使用.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は未使用.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pull Size Signals.
    -------------------------------------------------------------------------------
        PULL_VALID      : --! @brief PULL VALID :
                          --! PULL_LAST/PULL_SIZEが有効であることを示す信号.
                          in  std_logic;
        PULL_LAST       : --! @brief PULL LAST :
                          --! 最後の出力であることを示す信号.
                          in  std_logic;
        PULL_SIZE       : --! @brief PULL SIZE :
                          --! 出力したバイト数.
                          in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      : --! @brief FLOW OUTLET READY :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_READY='1' : 再開.
                          --! * FLOW_READY='0' : 一時停止.
                          --! * バルブが開固定(FIXED=2)の時は常に'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常に'0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以上の時に
                          --!   '1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 未満の時に
                          --!   '0'を出力する.
                          out std_logic;
        FLOW_PAUSE      : --! @brief FLOW OUTLET PAUSE :
                          --! 転送を一時的に止めたり、再開することを指示する信号.
                          --! * FLOW_PAUSE='0' : 再開.
                          --! * FLOW_PAUSE='1' : 一時停止.
                          --! * バルブが開固定(FIXED=2)の時は常に'0'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常に'1'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 以上の時に
                          --!   '0'を出力する.
                          --! * フローカウンタの値が FLOW_READY_LEVEL 未満の時に
                          --!   '1'を出力する.
                          out std_logic;
        FLOW_STOP       : --! @brief FLOW OUTLET STOP :
                          --! 転送の中止を指示する信号.
                          --! * FLOW_PAUSE=1 : 中止.
                          --! * バルブが開固定(FIXED=2)の時は常に'0'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常に'1'を出力する.
                          out std_logic;
        FLOW_LAST       : --! @brief FLOW OUTLET LAST :
                          --! 入力側から最後の入力を示すフラグがあったことを示す.
                          out std_logic;
        FLOW_SIZE       : --! @brief FLOW OUTLET ENABLE SIZE :
                          --! 出力可能なバイト数
                          --! * バルブが開固定(FIXED=2)の時は常にALL'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常にALL'0'を出力する.
                          out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Flow Counter.
    -------------------------------------------------------------------------------
        FLOW_COUNT      : --! @brief FLOW COUNTER :
                          --! 現在のフローカウンタの値を出力.
                          --! * バルブが開固定(FIXED=2)の時は常にALL'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常にALL'0'を出力する.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        FLOW_ZERO       : --! @brief FLOW COUNTER is ZERO :
                          --! フローカウンタの値が0になったことを示すフラグ.
                          out std_logic;
        FLOW_POS        : --! @brief FLOW COUNTER is POSitive :
                          --! フローカウンタの値が正(>0)になったことを示すフラグ.
                          out std_logic;
        FLOW_NEG        : --! @brief FLOW COUNTER is NEGative :
                          --! フローカウンタの値が負(<0)になったことを示すフラグ.
                          out std_logic;
        PAUSED          : --! @brief PAUSE FLAG :
                          --! 現在一時停止中であることを示すフラグ.
                          out std_logic;
        POOL_COUNT      : --! @brief POOL COUNT :
                          --! 現在のプールカウンタの値を出力.
                          --! * バルブが非先行モード(PRECEDE=0)の場合はFLOW_COUNTと
                          --!   同じ値を出力する.
                          --! * バルブが開固定(FIXED=2)の時は常にALL'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常にALL'0'を出力する.
                          out std_logic_vector(COUNT_BITS-1 downto 0);
        POOL_READY      : --! @brief POOL READY :
                          --! プールカウンタの値が POOL_READY_LEVEL 以上であること
                          --! を示すフラグ.
                          --! * バルブが非先行モード(PRECEDE=0)の場合は常に'1'を出
                          --!   力する.
                          --! * バルブが開固定(FIXED=2)の時は常に'1'を出力する.
                          --! * バルブが閉固定(FIXED=1)の時は常に'0'を出力する.
                          out std_logic
    );
end component;
end COMPONENTS;
