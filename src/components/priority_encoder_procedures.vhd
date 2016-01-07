-----------------------------------------------------------------------------------
--!     @file    priority_encoder_procesures
--!     @brief   Package for Generic Priority Encoder
--!     @version 1.5.9
--!     @date    2016/1/7
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2013-2015 Ichiro Kawazome
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
--! @brief Package for Generic Priority Encoder Procedures.
-----------------------------------------------------------------------------------
package PRIORITY_ENCODER_PROCEDURES is
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(簡易版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @return               エンコードした ONE-HOT のデータ.
    -------------------------------------------------------------------------------
    function  Priority_Encode_To_OneHot_Simply(
                 Data        : std_logic_vector;
                 High_to_Low : boolean
    )            return        std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(簡易版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Output      エンコードした ONE-HOT のデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Simply(
                 High_to_Low : in  boolean;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    );
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(選択版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    Min_Dec_Len 簡易版でエンコードするか、加算器を使ってエンコードす
    --!                       るかを指定する.
    --!                       Data のビット数が Min_Dec_Len 以上の時、加算器を使っ
    --!                       てエンコードする.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Output      エンコードした ONE-HOT のデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Selectable(
                 High_to_Low : in  boolean;
                 Min_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    );
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(難解版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    Min_Dec_Len 簡易版でエンコードするか、加算器を使ってエンコードす
    --!                       るかを指定する.
    --!                       Data のビット数が Min_Dec_Len 以上の時、加算器を使っ
    --!                       てエンコードする.
    --! @param    Max_Dec_Len ツリー構造にする際の１ノードで処理するビット数の最大
    --!                       値を指定する.
    --!                       Data のビット数が Max_Dec_Len 以上の時、ツリー構造に
    --!                       なる.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Output      エンコードした ONE-HOT のデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Intricately(
                 High_to_Low : in  boolean;
                 Min_Dec_Len : in  integer;
                 Max_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    );
    -------------------------------------------------------------------------------
    --! @brief バイナリのプライオリティエンコーダー(簡易版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    Binary_Len  生成するバイナリデータのビット数を指定する.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @return               エンコードしたバイナリデータ.
    -------------------------------------------------------------------------------
    function  Priority_Encode_To_Binary_Simply(
                 Data        : std_logic_vector;
                 Binary_Len  : integer;
                 High_to_Low : boolean
    )            return        std_logic_vector;
    -------------------------------------------------------------------------------
    --! @brief バイナリのプライオリティエンコーダー(簡易版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Binary_Len  生成するバイナリデータのビット数を指定する.
    --! @param    Data        入力データ.
    --! @param    Output      エンコードしたバイナリデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_Binary_Simply(
                 High_to_Low : in  boolean;
                 Binary_Len  : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    );
    -------------------------------------------------------------------------------
    --! @brief バイナリのプライオリティエンコーダー(難解版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Binary_Len  生成するバイナリデータのビット数を指定する.
    --! @param    Reduce_Len  Data を Reduce_Len で指定された数で縮退してからエンコ
    --!                       ードする.
    --! @param    Min_Dec_Len 簡易版でエンコードするか、加算器を使ってエンコードす
    --!                       るかを指定する.
    --!                       Data のビット数が Min_Dec_Len 以上の時、加算器を使っ
    --!                       てエンコードする.
    --! @param    Max_Dec_Len ツリー構造にする際の１ノードで処理するビット数の最大
    --!                       値を指定する.
    --!                       Data のビット数が Max_Dec_Len 以上の時、ツリー構造に
    --!                       なる.
    --! @param    Data        入力データ.
    --! @param    Output      エンコードしたバイナリデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_Binary_Intricately(
                 High_to_Low : in  boolean;
                 Binary_Len  : in  integer;
                 Reduce_Len  : in  integer;
                 Min_Dec_Len : in  integer;
                 Max_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    );
end package;

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
-----------------------------------------------------------------------------------
--! @brief Package for Genric Priority Encoder
-----------------------------------------------------------------------------------
package body PRIORITY_ENCODER_PROCEDURES is
    -------------------------------------------------------------------------------
    --! @brief 整数同士を比較して大きい方を返す関数.
    -------------------------------------------------------------------------------
    function  maximum(L,R:integer) return integer is
    begin
        if (L > R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 整数同士を比較して小さい方を返す関数.
    -------------------------------------------------------------------------------
    function  minimum(L,R:integer) return integer is
    begin
        if (L < R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 入力されたデータの論理和を返す関数.
    -------------------------------------------------------------------------------
    function  or_reduce(Arg : std_logic_vector) return std_logic is
        variable result : std_logic;
    begin
        result := '0';
        for i in Arg'range loop
            result := result or Arg(i);
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ビットの並びを逆順にして返す関数.
    -------------------------------------------------------------------------------
    function  reverse_vecter(
                 Data   : std_logic_vector
    )            return   std_logic_vector
    is
        variable result : std_logic_vector(Data'range);
        alias    i_data : std_logic_vector(Data'reverse_range) is Data;
    begin
        for i in result'range loop
            result(i) := i_data(i);
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief バイナリのプライオリティエンコーダー(簡易版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Binary_Len  生成するバイナリデータのビット数を指定する.
    --! @param    Data        入力データ.
    --! @param    Output      エンコードしたバイナリデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_Binary_Simply(
                 High_to_Low : in  boolean;
                 Binary_Len  : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        variable result      :     std_logic_vector(Binary_Len-1 downto 0);
    begin 
        result := (others => '0');
        if High_to_Low = TRUE then
            for i in Data'high downto Data'low loop
                if (Data(i) = '1') then
                    result := std_logic_vector(to_unsigned(i,result'length));
                    exit;
                end if;
            end loop;
        else
            for i in Data'low to Data'high loop
                if (Data(i) = '1') then
                    result := std_logic_vector(to_unsigned(i,result'length));
                    exit;
                end if;
            end loop;
        end if;
        Output := result;
        Valid  := or_reduce(Data);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief バイナリのプライオリティエンコーダー(簡易版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    Binary_Len  生成するバイナリデータのビット数を指定する.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @return               エンコードしたバイナリデータ.
    -------------------------------------------------------------------------------
    function  Priority_Encode_To_Binary_Simply(
                 Data        : std_logic_vector;
                 Binary_Len  : integer;
                 High_to_Low : boolean
    )            return        std_logic_vector
    is
        variable result      : std_logic_vector(Binary_Len-1 downto 0);
        variable valid       : std_logic;
    begin
        Priority_Encode_To_Binary_Simply(
            High_to_Low => High_to_Low,
            Binary_Len  => Binary_Len ,
            Data        => Data       ,
            Output      => result     ,
            Valid       => valid
        );
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(簡易版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Output      エンコードした ONE-HOT のデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Simply(
                 High_to_Low : in  boolean;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        variable result      :     std_logic_vector(Data'range);
    begin
        if High_to_Low = TRUE then
            for i in Data'range loop
                if (i = Data'high) then
                    result(i) := Data(i);
                else
                    result(i) := Data(i) and (not or_reduce(Data(Data'high downto i+1)));
                end if;
            end loop;
        else
            for i in Data'range loop
                if (i = Data'low) then
                    result(i) := Data(i);
                else
                    result(i) := Data(i) and (not or_reduce(Data(i-1 downto Data'low)));
                end if;
            end loop;
        end if;
        Output := result;
        Valid  := or_reduce(Data);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(簡易版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @return               エンコードした ONE-HOT のデータ.
    -------------------------------------------------------------------------------
    function  Priority_Encode_To_OneHot_Simply(
                 Data        : std_logic_vector;
                 High_to_Low : boolean
    )            return        std_logic_vector
    is
        variable result      : std_logic_vector(Data'range);
    begin
        result := (others => '0');
        if High_to_Low = TRUE then
            for i in Data'high downto Data'low loop
                if (Data(i) = '1') then
                    result(i) := '1';
                    exit;
                end if;
            end loop;
        else
            for i in Data'low to Data'high loop
                if (Data(i) = '1') then
                    result(i) := '1';
                    exit;
                end if;
            end loop;
        end if;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(加算器版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Output      エンコードした ONE-HOT のデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Using_Dec(
                 High_to_Low : in  boolean;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        variable i_data      :     std_logic_vector(Data'length-1 downto 0);
        variable t_data      :     std_logic_vector(Data'length   downto 0);
        variable d_data      :     std_logic_vector(Data'length   downto 0);
        variable r_data      :     std_logic_vector(Data'length-1 downto 0);
        variable o_data      :     std_logic_vector(Data'range);
    begin
        if High_to_Low = TRUE then
            i_data := reverse_vecter(Data);
            t_data := "0" & i_data;
            d_data := std_logic_vector(unsigned(t_data) - 1);
            r_data := i_data and not d_data(i_data'range);
            o_data := reverse_vecter(r_data);
        else
            i_data := Data;
            t_data := "0" & i_data;
            d_data := std_logic_vector(unsigned(t_data) - 1);
            r_data := i_data and not d_data(i_data'range);
            o_data := r_data;
        end if;
   --   Valid  := not t_data(d_data'high);
        Valid  := or_reduce(i_data);
        Output := o_data;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(選択版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    Min_Dec_Len 簡易版でエンコードするか、加算器を使ってエンコードす
    --!                       るかを指定する.
    --!                       Data のビット数が Min_Dec_Len 以上の時、加算器を使っ
    --!                       てエンコードする.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Output      エンコードした ONE-HOT のデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Selectable(
                 High_to_Low : in  boolean;
                 Min_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
    begin
        if Data'length >= Min_Dec_Len then
            Priority_Encode_To_OneHot_Using_Dec(
                High_to_Low => High_to_Low,
                Data        => Data       ,
                Output      => Output     ,
                Valid       => Valid
            );
        else
            Priority_Encode_To_OneHot_Simply(
                High_to_Low => High_to_Low,
                Data        => Data       ,
                Output      => Output     ,
                Valid       => Valid
            );
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ONE-HOT のプライオリティエンコーダー(難解版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    Data        入力データ.
    --! @param    Min_Dec_Len 簡易版でエンコードするか、加算器を使ってエンコードす
    --!                       るかを指定する.
    --!                       Data のビット数が Min_Dec_Len 以上の時、加算器を使っ
    --!                       てエンコードする.
    --! @param    Max_Dec_Len ツリー構造にする際の１ノードで処理するビット数の最大
    --!                       値を指定する.
    --!                       Data のビット数が Max_Dec_Len 以上の時、ツリー構造に
    --!                       なる.
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Output      エンコードした ONE-HOT のデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Intricately(
                 High_to_Low : in  boolean;
                 Min_Dec_Len : in  integer;
                 Max_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        constant Dec_Num     :     integer := (Data'length+Max_Dec_Len-1)/Max_Dec_Len;
        constant Dec_Bits    :     integer := (Data'length+Dec_Num-1)/Dec_Num;
        variable result      :     std_logic_vector(Data'range);
        alias    i_data      :     std_logic_vector(Data'length-1 downto 0) is Data;
        variable o_data      :     std_logic_vector(Data'length-1 downto 0);
        variable o_valid     :     std_logic_vector(Dec_Num-1 downto 0);
        variable onehot      :     std_logic_vector(Dec_Num-1 downto 0);
    begin
        for i in 0 to Dec_Num-1 loop
            Priority_Encode_To_OneHot_Selectable(
                High_to_Low => High_to_Low,
                Min_Dec_Len => Min_Dec_Len,
                Data        => i_data(minimum(i_data'left, (i+1)*Dec_Bits-1) downto i*Dec_Bits),
                Output      => o_data(minimum(i_data'left, (i+1)*Dec_Bits-1) downto i*Dec_Bits),
                Valid       => o_valid(i)
            );
        end loop;
        if (Dec_Num > 1) then
            Priority_Encode_To_OneHot_Intricately(
                High_to_Low => High_to_Low,
                Min_Dec_Len => Min_Dec_Len,
                Max_Dec_Len => Max_Dec_Len,
                Data        => o_valid,
                Output      => onehot,
                Valid       => Valid
            );
            if High_to_Low = TRUE then
                for i in 0 to Dec_Num-2 loop
                    if (onehot(i) = '0') then
                            o_data((i+1)*Dec_Bits-1 downto i*Dec_Bits) := (others => '0');
                    end if;
                end loop;
            else
                for i in 1 to Dec_Num-1 loop
                    if (onehot(i) = '0') then
                        if (i = Dec_Num-1) then
                            o_data(o_data'left      downto i*Dec_Bits) := (others => '0');
                        else
                            o_data((i+1)*Dec_Bits-1 downto i*Dec_Bits) := (others => '0');
                        end if;
                    end if;
                end loop;
            end if;
        else
            Valid := o_valid(0);
        end if;
        Output := o_data;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief バイナリのプライオリティエンコーダー(難解版)
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    High_to_Low 優先順位の高い方を指定する.
    --!                       TRUE で Data'High の方が優先順位が高いことを指定する.
    --!                       FALSE で Data'Low の方が優先順位が高いことを指定する.
    --! @param    Binary_Len  生成するバイナリデータのビット数を指定する.
    --! @param    Reduce_Len  Data を Reduce_Len で指定された数で縮退してからエンコ
    --!                       ードする.
    --! @param    Min_Dec_Len 簡易版でエンコードするか、加算器を使ってエンコードす
    --!                       るかを指定する.
    --!                       Data のビット数が Min_Dec_Len 以上の時、加算器を使っ
    --!                       てエンコードする.
    --! @param    Max_Dec_Len ツリー構造にする際の１ノードで処理するビット数の最大
    --!                       値を指定する.
    --!                       Data のビット数が Max_Dec_Len 以上の時、ツリー構造に
    --!                       なる.
    --! @param    Data        入力データ.
    --! @param    Output      エンコードしたバイナリデータ.
    --! @param    Valid       Data が All0 だった場合、'0' を返す.
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_Binary_Intricately(
                 High_to_Low : in  boolean;
                 Binary_Len  : in  integer;
                 Reduce_Len  : in  integer;
                 Min_Dec_Len : in  integer;
                 Max_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        subtype   BINARY_TYPE   is std_logic_vector(Binary_Len-1 downto 0);
        type      BINARY_VECTOR is array (integer range <>) of BINARY_TYPE;
        constant  Reduce_Low : integer := Data'low /Reduce_Len;
        constant  Reduce_High: integer := Data'high/Reduce_Len;
        variable  i_bin_vec  : BINARY_VECTOR   (Reduce_High downto Reduce_Low);
        variable  i_valid    : std_logic_vector(Reduce_High downto Reduce_Low);
        variable  t_valid    : std_logic_vector(Reduce_High downto Reduce_Low);
        variable  o_binary   : BINARY_TYPE;
        variable  o_valid    : std_logic;
    begin 
        for i in i_valid'range loop
            Priority_Encode_To_Binary_Simply(
                High_to_Low => High_to_Low ,
                Binary_Len  => Binary_Len  ,
                Data        => Data(minimum(Data'high, (i+1)*Reduce_Len-1) downto maximum(Data'low, i*Reduce_Len)),
                Output      => i_bin_vec(i),
                Valid       => i_valid(i)
            );
        end loop;
        Priority_Encode_To_OneHot_Intricately(
            High_to_Low => High_to_Low,
            Min_Dec_Len => Min_Dec_Len,
            Max_Dec_Len => Max_Dec_Len,
            Data        => i_valid,
            Output      => t_valid,
            Valid       => o_valid
        );
        o_binary := (others => '0');
        for i in t_valid'range loop
            if (t_valid(i) = '1') then
                o_binary := o_binary or i_bin_vec(i);
            end if;
        end loop;
        Output := o_binary;
        Valid  := o_valid;
    end procedure;
end package body;
