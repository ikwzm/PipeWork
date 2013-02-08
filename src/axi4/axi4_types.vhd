-----------------------------------------------------------------------------------
--!     @file    axi4_types.vhd
--!     @brief   AXI4 Channel Signal Type Package.
--!     @version 1.2.1
--!     @date    2013/2/9
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012 Ichiro Kawazome
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
--! @brief AXI4 の各種タイプ/定数を定義しているパッケージ.
-----------------------------------------------------------------------------------
package AXI4_TYPES is
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのバースト長信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_ALEN_WIDTH      : integer := 8;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのバースト長信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_ALEN_TYPE       is std_logic_vector(AXI4_ALEN_WIDTH   -1 downto 0);
    constant  AXI4_ALEN_1          : AXI4_ALEN_TYPE := "00000000";
    constant  AXI4_ALEN_2          : AXI4_ALEN_TYPE := "00000001";
    constant  AXI4_ALEN_3          : AXI4_ALEN_TYPE := "00000010";
    constant  AXI4_ALEN_4          : AXI4_ALEN_TYPE := "00000011";
    constant  AXI4_ALEN_5          : AXI4_ALEN_TYPE := "00000100";
    constant  AXI4_ALEN_6          : AXI4_ALEN_TYPE := "00000101";
    constant  AXI4_ALEN_7          : AXI4_ALEN_TYPE := "00000110";
    constant  AXI4_ALEN_8          : AXI4_ALEN_TYPE := "00000111";
    constant  AXI4_ALEN_9          : AXI4_ALEN_TYPE := "00001000";
    constant  AXI4_ALEN_10         : AXI4_ALEN_TYPE := "00001001";
    constant  AXI4_ALEN_11         : AXI4_ALEN_TYPE := "00001010";
    constant  AXI4_ALEN_12         : AXI4_ALEN_TYPE := "00001011";
    constant  AXI4_ALEN_13         : AXI4_ALEN_TYPE := "00001100";
    constant  AXI4_ALEN_14         : AXI4_ALEN_TYPE := "00001101";
    constant  AXI4_ALEN_15         : AXI4_ALEN_TYPE := "00001110";
    constant  AXI4_ALEN_16         : AXI4_ALEN_TYPE := "00001111";
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルの転送サイズ信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_ASIZE_WIDTH     : integer := 3;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルの転送サイズ信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_ASIZE_TYPE      is std_logic_vector(AXI4_ASIZE_WIDTH  -1 downto 0);
    constant  AXI4_ASIZE_1BYTE     : AXI4_ASIZE_TYPE := "000";
    constant  AXI4_ASIZE_2BYTE     : AXI4_ASIZE_TYPE := "001";
    constant  AXI4_ASIZE_4BYTE     : AXI4_ASIZE_TYPE := "010";
    constant  AXI4_ASIZE_8BYTE     : AXI4_ASIZE_TYPE := "011";
    constant  AXI4_ASIZE_16BYTE    : AXI4_ASIZE_TYPE := "100";
    constant  AXI4_ASIZE_32BYTE    : AXI4_ASIZE_TYPE := "101";
    constant  AXI4_ASIZE_64BYTE    : AXI4_ASIZE_TYPE := "110";
    constant  AXI4_ASIZE_128BYTE   : AXI4_ASIZE_TYPE := "111";
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのバースト種別信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_ABURST_WIDTH    : integer := 2;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのバースト種別信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_ABURST_TYPE     is std_logic_vector(AXI4_ABURST_WIDTH -1 downto 0);
    constant  AXI4_ABURST_FIXED    : AXI4_ABURST_TYPE := "00";
    constant  AXI4_ABURST_INCR     : AXI4_ABURST_TYPE := "01";
    constant  AXI4_ABURST_WRAP     : AXI4_ABURST_TYPE := "10";
    constant  AXI4_ABURST_RESV     : AXI4_ABURST_TYPE := "11";
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルの排他アクセス信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_ALOCK_WIDTH     : integer := 2;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルの排他アクセス信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_ALOCK_TYPE      is std_logic_vector(AXI4_ALOCK_WIDTH  -1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのキャッシュ信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_ACACHE_WIDTH    : integer := 4;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのキャッシュ信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_ACACHE_TYPE     is std_logic_vector(AXI4_ACACHE_WIDTH -1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルの保護ユニットサポート信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_APROT_WIDTH     : integer := 3;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルの保護ユニットサポート信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_APROT_TYPE      is std_logic_vector(AXI4_APROT_WIDTH  -1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのQoS(Quality of Service)信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_AQOS_WIDTH      : integer := 4;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのQoS(Quality of Service)信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_AQOS_TYPE       is std_logic_vector(AXI4_AQOS_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのリージョン信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_AREGION_WIDTH   : integer := 4;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルのリージョン信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_AREGION_TYPE    is std_logic_vector(AXI4_AREGION_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    --! @brief 応答信号のビット数.
    -------------------------------------------------------------------------------
    constant  AXI4_RESP_WIDTH      : integer := 2;
    -------------------------------------------------------------------------------
    --! @brief 応答信号のタイプ.
    -------------------------------------------------------------------------------
    subtype   AXI4_RESP_TYPE       is std_logic_vector(AXI4_RESP_WIDTH   -1 downto 0);
    constant  AXI4_RESP_OKAY       : AXI4_RESP_TYPE := "00";
    constant  AXI4_RESP_EXOKAY     : AXI4_RESP_TYPE := "01";
    constant  AXI4_RESP_SLVERR     : AXI4_RESP_TYPE := "10";
    constant  AXI4_RESP_DECERR     : AXI4_RESP_TYPE := "11";
    -------------------------------------------------------------------------------
    --! @brief AXI4 ID の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_ID_MAX_WIDTH    : integer := 8;
    -------------------------------------------------------------------------------
    --! @brief AXI4 ADDR の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_ADDR_MAX_WIDTH  : integer := 64;
    -------------------------------------------------------------------------------
    --! @brief AXI4 DATA の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_DATA_MAX_WIDTH  : integer := 1024;
    -------------------------------------------------------------------------------
    --! @brief AXI4 WSTRB の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_STRB_MAX_WIDTH  : integer := AXI4_DATA_MAX_WIDTH/8;
    -------------------------------------------------------------------------------
    --! @brief AXI4 USER の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_USER_MAX_WIDTH  : integer := 32;
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネルの可変長信号のビット幅を指定するレコードタイプ.
    -------------------------------------------------------------------------------
    type      AXI4_SIGNAL_WIDTH_TYPE is record
              ID                   : integer range 1 to AXI4_ID_MAX_WIDTH;
              AWADDR               : integer range 1 to AXI4_USER_MAX_WIDTH;
              AWUSER               : integer range 1 to AXI4_USER_MAX_WIDTH;
              ARADDR               : integer range 1 to AXI4_USER_MAX_WIDTH;
              ARUSER               : integer range 1 to AXI4_USER_MAX_WIDTH;
              WDATA                : integer range 8 to AXI4_DATA_MAX_WIDTH;
              WUSER                : integer range 1 to AXI4_USER_MAX_WIDTH;
              RDATA                : integer range 8 to AXI4_DATA_MAX_WIDTH;
              RUSER                : integer range 1 to AXI4_USER_MAX_WIDTH;
              BUSER                : integer range 1 to AXI4_USER_MAX_WIDTH;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4-Stream TDEST の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_DEST_MAX_WIDTH  : integer := 32;
    -------------------------------------------------------------------------------
    --! @brief AXI4-Stream の可変長信号のビット幅を指定するレコードタイプ.
    -------------------------------------------------------------------------------
    type      AXI4_STREAM_SIGNAL_WIDTH_TYPE is record
              ID                   : integer range 1 to AXI4_ID_MAX_WIDTH;
              USER                 : integer range 1 to AXI4_USER_MAX_WIDTH;
              DEST                 : integer range 1 to AXI4_DEST_MAX_WIDTH;
              DATA                 : integer range 8 to AXI4_DATA_MAX_WIDTH;
    end record;
end package;
