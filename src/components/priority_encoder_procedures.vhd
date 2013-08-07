-----------------------------------------------------------------------------------
--!     @file    priority_encoder_procesures
--!     @brief   Package for Generic Priority Encoder
--!     @version 1.5.1
--!     @date    2013/8/7
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
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
--! @brief Package for Generic Priority Encoder
-----------------------------------------------------------------------------------
package PRIORITY_ENCODER_PROCEDURES is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  Priority_Encode_To_Binary_Simple(
                 Data        : std_logic_vector;
                 Len         : integer;
                 High_to_Low : boolean
    )            return        std_logic_vector;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  Priority_Encode_To_OneHot_Simple(
                 Data        : std_logic_vector;
                 High_to_Low : boolean
    )            return        std_logic_vector;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot(
                 Min_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot(
                 Min_Dec_Len : in  integer;
                 Max_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot(
                 High_to_Low : in  boolean;
                 Min_Dec_Len : in  integer;
                 Max_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_Binary(
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
    --
    -------------------------------------------------------------------------------
    function  Maximum(L,R:integer) return integer is
    begin
        if (L > R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  Minimum(L,R:integer) return integer is
    begin
        if (L < R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  Or_Reduce(Arg : std_logic_vector) return std_logic is
        variable result : std_logic;
    begin
        result := '0';
        for i in Arg'range loop
            result := result or Arg(i);
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  Reverse_Vector(
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
    --
    -------------------------------------------------------------------------------
    function  Priority_Encode_To_Binary_Simple(
                 Data        : std_logic_vector;
                 Len         : integer;
                 High_to_Low : boolean
    )            return        std_logic_vector
    is
        variable result      : std_logic_vector(Len-1 downto 0);
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
        return result;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  Priority_Encode_To_OneHot_Simple(
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
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Using_Dec(
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        alias    i_data      :     std_logic_vector(Data'length-1 downto 0) is Data;
        variable t_data      :     std_logic_vector(Data'length   downto 0);
    begin
        t_data := "0" & i_data;
        t_data := std_logic_vector(unsigned(t_data) - 1);
        Valid  := not t_data(t_data'high);
        Output := i_data and not t_data(i_data'range);
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Using_Loop(
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        alias    i_data      :     std_logic_vector(Data'length-1 downto 0) is Data;
        variable t_data      :     std_logic_vector(Data'length-1 downto 0);
    begin
        for i in i_data'range loop
            if (i = 0) then
                t_data(i) := i_data(i);
            else
                t_data(i) := i_data(i) and (not Or_Reduce(i_data(i-1 downto 0)));
            end if;
        end loop;
        Valid  := Or_Reduce(i_data);
        Output := t_data;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot(
                 Min_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
    begin
        if Data'length >= Min_Dec_Len then
            Priority_Encode_To_OneHot_Using_Dec(
                Data   => Data  ,
                Output => Output,
                Valid  => Valid
            );
        else
            Priority_Encode_To_OneHot_Using_Loop(
                Data   => Data  ,
                Output => Output,
                Valid  => Valid
            );
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot(
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
            Priority_Encode_To_OneHot(
                Min_Dec_Len => Min_Dec_Len,
                Data        => i_data(Minimum(i_data'left, (i+1)*Dec_Bits-1) downto i*Dec_Bits),
                Output      => o_data(Minimum(i_data'left, (i+1)*Dec_Bits-1) downto i*Dec_Bits),
                Valid       => o_valid(i)
            );
        end loop;
        if (Dec_Num > 1) then
            Priority_Encode_To_OneHot(
                Min_Dec_Len => Min_Dec_Len,
                Max_Dec_Len => Max_Dec_Len,
                Data        => o_valid,
                Output      => onehot,
                Valid       => Valid
            );
            for i in 1 to Dec_Num-1 loop
                if (onehot(i) = '0') then
                    if (i = Dec_Num-1) then
                        o_data(o_data'left      downto i*Dec_Bits) := (others => '0');
                    else
                        o_data((i+1)*Dec_Bits-1 downto i*Dec_Bits) := (others => '0');
                    end if;
                end if;
            end loop;
        else
            Valid := o_valid(0);
        end if;
        Output := o_data;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot(
                 High_to_Low : in  boolean;
                 Min_Dec_Len : in  integer;
                 Max_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        alias    i_data      :     std_logic_vector(Data'length-1 downto 0) is Data;
        variable t_data      :     std_logic_vector(Data'length-1 downto 0);
        variable r_data      :     std_logic_vector(Data'length-1 downto 0);
        variable o_data      :     std_logic_vector(Data'range);
    begin
        if High_to_Low = TRUE then
            t_data := Reverse_Vector(i_data);
        else
            t_data := i_data;
        end if;
        Priority_Encode_To_OneHot(
            Min_Dec_Len => Min_Dec_Len,
            Max_Dec_Len => Max_Dec_Len,
            Data        => t_data,
            Output      => r_data,
            Valid       => Valid
        );
        if High_to_Low = TRUE then
            o_data := Reverse_Vector(r_data);
        else
            o_data := r_data;
        end if;
        Output := o_data;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_Binary(
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
            i_bin_vec(i) := Priority_Encode_To_Binary_Simple(
                Data        => Data(Minimum(Data'high, (i+1)*Reduce_Len-1) downto Maximum(Data'low, i*Reduce_Len)),
                Len         => Binary_Len,
                High_to_Low => High_to_Low
            );
            i_valid(i)   := Or_Reduce(
                Arg         => Data(Minimum(Data'high, (i+1)*Reduce_Len-1) downto Maximum(Data'low, i*Reduce_Len))
            );
        end loop;
        Priority_Encode_To_OneHot(
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

