-----------------------------------------------------------------------------------
--!     @file    flex_point_types.vhd
--!     @brief   Flexable Float/Fixed Point Numeric Types Package.
--!     @version 1.8.0
--!     @date    2020/3/17
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2020 Ichiro Kawazome
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
use     ieee.numeric_std.all;
-----------------------------------------------------------------------------------
--! @brief Flex_Point の各種タイプ/定数を定義しているパッケージ.
-----------------------------------------------------------------------------------
package FLEX_POINT_TYPES is
    
    -------------------------------------------------------------------------------
    --! @brief Flex_Float_Point の指数部(exponent) のタイプの定義
    -------------------------------------------------------------------------------
    type      FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE is record
                  BITS              :  integer;  -- FIELD のビット数
                  LO                :  integer;  -- FIELD の位置の最小値
                  HI                :  integer;  -- FIELD の位置の最大値
                  MIN               :  integer;  -- 指数の最小値
                  MAX               :  integer;  -- 指数の最大値
                  BIAS              :  integer;  -- 指数部の下駄(BIAS)
    end record;
    constant  NONE_FLEX_FLOAT_POINT_EXPONENT_FIELD
                                    : FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE 
                                    := (  BITS =>  0,
                                          LO   => -1,
                                          HI   => -1,
                                          MIN  =>  0,
                                          MAX  =>  0,
                                          BIAS =>  0
                                       );
    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の指数部(exponent) のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                  MAX               :  integer;  -- 指数の最大値
                  MIN               :  integer;  -- 指数の最小値
                  BIAS              :  integer;  -- 指数部の下駄(BIAS)
                  HI                :  integer;  -- FIELD の位置の最大値
                  LO                :  integer   -- FIELD の位置の最小値
              )   return               FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE;
    function  NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                  MAX               :  integer;  -- 指数の最大値
                  MIN               :  integer;  -- 指数の最小値
                  BIAS              :  integer;  -- 指数部の下駄(BIAS)
                  LO                :  integer   -- FIELD の位置の最小値
              )   return               FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE;
    function  NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                  HI                :  integer;  -- FIELD の位置の最大値
                  LO                :  integer  -- FIELD の位置の最小値
              )   return               FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Flex Float/Fixed Point のフラグ(sign/zero/nan/inf) のタイプの定義
    -------------------------------------------------------------------------------
    type      FLEX_POINT_FLAG_FIELD_TYPE is record
                  BITS              :  integer;  -- FIELD のビット数
                  POS               :  integer;  -- FIELD の位置
    end record;
    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の符号部(sign) のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_FLAG_FIELD(POS: integer) return FLEX_POINT_FLAG_FIELD_TYPE;
    function  NONE_FLEX_POINT_FLAG_FIELD              return FLEX_POINT_FLAG_FIELD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Flex Fixed Point のタイプの定義
    -------------------------------------------------------------------------------
    type      FLEX_FIXED_POINT_FIELD_TYPE is record
                  BITS              :  integer;  -- FIELD のビット数
                  LO                :  integer;  -- FIELD の位置の最小値
                  HI                :  integer;  -- FIELD の位置の最大値
                  POINT_POS         :  integer;  -- 固定少数点の少数点位置
                  SIGN              :  boolean;  -- 符号あり/なし
    end record;
    -------------------------------------------------------------------------------
    --! @brief Flex Fixed Point のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_FIXED_POINT_FIELD(
                  HI                 :  integer;
                  LO                 :  integer;
                  POINT_POS          :  integer;
                  SIGN               :  boolean := TRUE
              )   return                FLEX_FIXED_POINT_FIELD_TYPE;
    function  NEW_FLEX_FIXED_POINT_FIELD(
                  BITS               :  integer;
                  POINT_POS          :  integer := 0;
                  SIGN               :  boolean := TRUE
              )   return                FLEX_FIXED_POINT_FIELD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Flex Point のタイプの定義
    -------------------------------------------------------------------------------
    type      FLEX_POINT_PARAM_TYPE  is record
                  BITS               :  integer;  -- FIELD のビット数
                  LO                 :  integer;  -- FIELD の位置の最小値
                  HI                 :  integer;  -- FIELD の位置の最大値
                  FRAC               :  FLEX_FIXED_POINT_FIELD_TYPE;
                  EXPO               :  FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE;
                  SIGN               :  FLEX_POINT_FLAG_FIELD_TYPE;
                  ZERO               :  FLEX_POINT_FLAG_FIELD_TYPE;
                  NAN                :  FLEX_POINT_FLAG_FIELD_TYPE;
                  INF                :  FLEX_POINT_FLAG_FIELD_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Flex Point のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_PARAM(
                  SIGN_POS           :  integer;
                  EXPO_HI            :  integer;
                  EXPO_LO            :  integer;
                  FRAC_HI            :  integer;
                  FRAC_LO            :  integer
              )   return                FLEX_POINT_PARAM_TYPE;
    function  NEW_FLEX_POINT_PARAM(
                  EXPO_HI            :  integer;
                  EXPO_LO            :  integer;
                  FRAC_HI            :  integer;
                  FRAC_LO            :  integer;
                  SIGN               :  boolean := TRUE ;
                  ZERO               :  boolean := FALSE;
                  NAN                :  boolean := FALSE;
                  INF                :  boolean := FALSE
              )   return                FLEX_POINT_PARAM_TYPE;
    function  NEW_FLEX_POINT_PARAM(
                  EXPO_MAX           :  integer;
                  EXPO_MIN           :  integer;
                  EXPO_BIAS          :  integer;
                  FRAC_HI            :  integer;
                  FRAC_LO            :  integer;
                  SIGN               :  boolean := TRUE ;
                  ZERO               :  boolean := FALSE;
                  NAN                :  boolean := FALSE;
                  INF                :  boolean := FALSE
              )   return                FLEX_POINT_PARAM_TYPE;
    function  NEW_FLEX_POINT_PARAM(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  SIGN               :  boolean := TRUE ;
                  ZERO               :  boolean := FALSE;
                  NAN                :  boolean := FALSE;
                  INF                :  boolean := FALSE
              )   return                FLEX_POINT_PARAM_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Flex_Float_Point_64 のタイプ
    -------------------------------------------------------------------------------
    constant  FLEX_FLOAT_POINT_64    :  FLEX_POINT_PARAM_TYPE
                                     := NEW_FLEX_POINT_PARAM(
                                            SIGN_POS => 63,
                                            EXPO_HI  => 62,
                                            EXPO_LO  => 52,
                                            FRAC_HI  => 51,
                                            FRAC_LO  =>  0
                                        );
    -------------------------------------------------------------------------------
    --! @brief Flex_Float_Point_32 のタイプ
    -------------------------------------------------------------------------------
    constant  FLEX_FLOAT_POINT_32    :  FLEX_POINT_PARAM_TYPE
                                     := NEW_FLEX_POINT_PARAM(
                                            SIGN_POS => 31,
                                            EXPO_HI  => 30,
                                            EXPO_LO  => 23,
                                            FRAC_HI  => 22,
                                            FRAC_LO  =>  0
                                        );
    -------------------------------------------------------------------------------
    --! @brief Flex_Float_Point_16 のタイプ
    -------------------------------------------------------------------------------
    constant  FLEX_FLOAT_POINT_16    :  FLEX_POINT_PARAM_TYPE
                                     := NEW_FLEX_POINT_PARAM(
                                            SIGN_POS => 15,
                                            EXPO_HI  => 14,
                                            EXPO_LO  => 10,
                                            FRAC_HI  =>  9,
                                            FRAC_LO  =>  0
                                        );
    -------------------------------------------------------------------------------
    --! @brief Flex Point の 仮数部(fraction) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_FRACTION(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic_vector;
    function  GET_FRACTION(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                unsigned;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Point の 指数部(exponent) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_EXPONENT(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic_vector;
    function  GET_EXPONENT(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                unsigned;
    function  GET_EXPONENT(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                integer;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Point の 符号部(sign) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_SIGN(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic;
    function  GET_SIGN(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                boolean;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Point の 符号部(zero) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ZERO(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic;
    function  GET_ZERO(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                boolean;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Point の 符号部(nan) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_NAN(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic;
    function  GET_NAN(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                boolean;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の 符号部(inf) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_INF(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic;
    function  GET_INF(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                boolean;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Point を補完したタイプを生成する関数
    -------------------------------------------------------------------------------
    function  COMPLEMENT(
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE
              )   return                FLEX_POINT_PARAM_TYPE;
        
    -------------------------------------------------------------------------------
    --! @brief Flex Point を補完したデータを生成する関数
    -------------------------------------------------------------------------------
    function  COMPLEMENT(
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_DATA        :  std_logic_vector
              )   return                std_logic_vector;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の乗算結果のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  MULTIPLY(
                  A_PARAM            :  FLEX_POINT_PARAM_TYPE;
                  B_PARAM            :  FLEX_POINT_PARAM_TYPE
              )   return                FLEX_POINT_PARAM_TYPE;
        
    -------------------------------------------------------------------------------
    --! @brief Flex Point の乗算結果のデータを生成する関数
    -------------------------------------------------------------------------------
    function  MULTIPLY(
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  A_PARAM            :  FLEX_POINT_PARAM_TYPE;
                  A_DATA             :  std_logic_vector;
                  B_PARAM            :  FLEX_POINT_PARAM_TYPE;
                  B_DATA             :  std_logic_vector
              )   return                std_logic_vector;
        
    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換の状態のタイプ
    -------------------------------------------------------------------------------
    type      FLEX_POINT_TO_FIXED_STATE_TYPE is record
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_OFFSET      :  integer;
                  MAX                :  integer;
                  SIZE               :  integer;
                  SHIFT_STATE_LO     :  integer;
                  SHIFT_STATE_HI     :  integer;
                  SIGN_STATE         :  integer;
    end record;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換の状態のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_TO_FIXED_STATE(
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE
              )   return                FLEX_POINT_TO_FIXED_STATE_TYPE;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  TO_FIXED_POINT(
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE
              )   return                FLEX_POINT_PARAM_TYPE;
        
    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換を行う関数
    -------------------------------------------------------------------------------
    function  TO_FIXED_POINT(
                  STATE_TYPE         :  FLEX_POINT_TO_FIXED_STATE_TYPE;
                  STATE              :  integer;
                  SOURCE_DATA        :  std_logic_vector;
                  TARGET_DATA        :  std_logic_vector
              )   return                std_logic_vector;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換を行う関数
    -------------------------------------------------------------------------------
    function  TO_FIXED_POINT(
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_DATA        :  std_logic_vector
              )   return                std_logic_vector;
end FLEX_POINT_TYPES;

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
package body FLEX_POINT_TYPES is
    -------------------------------------------------------------------------------
    --! @brief 整数の最小値を返す関数
    -------------------------------------------------------------------------------
    function  minimum(A,B: integer) return integer
    is
    begin
        if (A<B) then return A;
        else          return B;
        end if;
    end function;
    function  minimum(A,B,C: integer) return integer
    is
    begin
        return minimum(minimum(A,B),C);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief 整数の最大値を返す関数
    -------------------------------------------------------------------------------
    function  maximum(A,B: integer) return integer
    is
    begin
        if (A>B) then return A;
        else          return B;
        end if;
    end function;
    function  maximum(A,B,C: integer) return integer
    is
    begin
        return maximum(maximum(A,B),C);
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の指数部(exponent) のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                  MAX               :  integer;  -- 指数の最大値
                  MIN               :  integer;  -- 指数の最小値
                  BIAS              :  integer;  -- 指数部の下駄(BIAS)
                  HI                :  integer;  -- FIELD の位置の最大値
                  LO                :  integer)  -- FIELD の位置の最小値
                  return               FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE
    is
        variable  exponent_field    :  FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE;
    begin
        exponent_field.LO   := LO;
        exponent_field.HI   := HI;
        exponent_field.BITS := HI - LO + 1;
        exponent_field.MAX  := MAX;
        exponent_field.MIN  := MIN;
        exponent_field.BIAS := BIAS;
        return exponent_field;
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の指数部(exponent) のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                  MAX               :  integer;  -- 指数の最大値
                  MIN               :  integer;  -- 指数の最小値
                  BIAS              :  integer;  -- 指数部の下駄(BIAS)
                  LO                :  integer)  -- FIELD の位置の最小値
                  return               FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE
    is
        variable  bits              :  integer;
        variable  width             :  integer;
    begin
        width := MAX - MIN + 1;
        bits  := 1;
        while ((2**bits)-1 < width) loop
            bits := bits + 1;
        end loop;
        return NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
            MAX  => MAX          ,
            MIN  => MIN          ,
            BIAS => BIAS         ,
            HI   => bits + LO - 1,
            LO   => LO           
        );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の指数部(exponent) のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                  MAX               :  integer;
                  MIN               :  integer;
                  LO                :  integer)
                  return               FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE
    is
    begin
        return NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
            MAX  => MAX          ,
            MIN  => MIN          ,
            BIAS => 0 - MIN      ,
            LO   => LO           
        );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の指数部(exponent) のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                  HI                :  integer;
                  LO                :  integer)
                  return               FLEX_FLOAT_POINT_EXPONENT_FIELD_TYPE
    is
    begin
        return NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
            MIN  => -(2**(HI - LO)) + 1,
            MAX  =>  (2**(HI - LO)) - 1,
            BIAS =>  (2**(HI - LO)) - 1,
            HI   => HI                 ,
            LO   => LO                 
        );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の符号部(sign) のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_FLAG_FIELD(POS: integer) return FLEX_POINT_FLAG_FIELD_TYPE
    is
        variable flag_field : FLEX_POINT_FLAG_FIELD_TYPE;
    begin
        flag_field.POS  := POS;
        flag_field.BITS := 1;
        return flag_field;
    end function;
        
    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の符号部(sign) のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NONE_FLEX_POINT_FLAG_FIELD          return FLEX_POINT_FLAG_FIELD_TYPE
    is
        variable flag_field : FLEX_POINT_FLAG_FIELD_TYPE;
    begin
        flag_field.POS  := -1;
        flag_field.BITS := 0;
        return flag_field;
    end function;
        
    -------------------------------------------------------------------------------
    --! @brief Flex Fixed Point のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_FIXED_POINT_FIELD(
                  HI                 :  integer;
                  LO                 :  integer;
                  POINT_POS          :  integer;
                  SIGN               :  boolean := TRUE
              )   return                FLEX_FIXED_POINT_FIELD_TYPE
    is
        variable  fixed_point_field  :  FLEX_FIXED_POINT_FIELD_TYPE;
    begin
        fixed_point_field.HI         := HI;
        fixed_point_field.LO         := LO;
        fixed_point_field.POINT_POS  := POINT_POS;
        fixed_point_field.SIGN       := SIGN;
        fixed_point_field.BITS       := HI - LO + 1;
        return fixed_point_field;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Fixed Point のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_FIXED_POINT_FIELD(
                  BITS               :  integer;
                  POINT_POS          :  integer := 0;
                  SIGN               :  boolean := TRUE
              )   return                FLEX_FIXED_POINT_FIELD_TYPE
    is
    begin
        return NEW_FLEX_FIXED_POINT_FIELD(
                 HI        => BITS-1,
                 LO        => 0,
                 POINT_POS => POINT_POS,
                 SIGN      => SIGN
        );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_PARAM(
                  SIGN_POS           :  integer;
                  EXPO_HI            :  integer;
                  EXPO_LO            :  integer;
                  FRAC_HI            :  integer;
                  FRAC_LO            :  integer
              )   return                FLEX_POINT_PARAM_TYPE
    is
        variable  param              :  FLEX_POINT_PARAM_TYPE;
    begin
        param.LO   := 0;
        param.FRAC := NEW_FLEX_FIXED_POINT_FIELD(
                          HI         => FRAC_HI,
                          LO         => FRAC_LO,
                          POINT_POS  => FRAC_HI+1,
                          SIGN       => FALSE
                      );
        param.EXPO := NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                          HI         => EXPO_HI,
                          LO         => EXPO_LO
                      );
        param.SIGN := NEW_FLEX_POINT_FLAG_FIELD(POS => SIGN_POS);
        param.ZERO := NONE_FLEX_POINT_FLAG_FIELD;
        param.NAN  := NONE_FLEX_POINT_FLAG_FIELD;
        param.INF  := NONE_FLEX_POINT_FLAG_FIELD;
        param.HI   := maximum(param.FRAC.HI, param.EXPO.HI, param.SIGN.POS);
        param.BITS := param.HI - param.LO + 1;
        return param;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_PARAM(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  SIGN               :  boolean := TRUE ;
                  ZERO               :  boolean := FALSE;
                  NAN                :  boolean := FALSE;
                  INF                :  boolean := FALSE
              )   return                FLEX_POINT_PARAM_TYPE
    is
        variable  new_param          :  FLEX_POINT_PARAM_TYPE;
        variable  flag_pos           :  integer;
    begin
        new_param    := PARAM;
        if (PARAM.EXPO.BITS > 0) then
            flag_pos := maximum(PARAM.FRAC.HI, PARAM.EXPO.HI) + 1;
        else
            flag_pos := PARAM.FRAC.HI + 1;
        end if;
        if (SIGN = TRUE) then
            new_param.SIGN := NEW_FLEX_POINT_FLAG_FIELD(flag_pos);
            flag_pos       := flag_pos + 1;
        else
            new_param.SIGN := NONE_FLEX_POINT_FLAG_FIELD;
        end if;
        if (ZERO = TRUE) then
            new_param.ZERO := NEW_FLEX_POINT_FLAG_FIELD(flag_pos);
            flag_pos       := flag_pos + 1;
        else
            new_param.ZERO := NONE_FLEX_POINT_FLAG_FIELD;
        end if;
        if (NAN  = TRUE) then
            new_param.NAN  := NEW_FLEX_POINT_FLAG_FIELD(flag_pos);
            flag_pos       := flag_pos + 1;
        else
            new_param.NAN  := NONE_FLEX_POINT_FLAG_FIELD;
        end if;
        if (INF  = TRUE) then
            new_param.INF  := NEW_FLEX_POINT_FLAG_FIELD(flag_pos);
            flag_pos       := flag_pos + 1;
        else
            new_param.INF  := NONE_FLEX_POINT_FLAG_FIELD;
        end if;
        new_param.BITS := flag_pos;
        new_param.HI   := new_param.BITS + new_param.LO - 1;
        return new_param;
    end function;
        
    -------------------------------------------------------------------------------
    --! @brief Flex Point のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_PARAM(
                  EXPO_HI            :  integer;
                  EXPO_LO            :  integer;
                  FRAC_HI            :  integer;
                  FRAC_LO            :  integer;
                  SIGN               :  boolean := TRUE ;
                  ZERO               :  boolean := FALSE;
                  NAN                :  boolean := FALSE;
                  INF                :  boolean := FALSE
               )  return                FLEX_POINT_PARAM_TYPE
    is
        variable  param              :  FLEX_POINT_PARAM_TYPE;
    begin
        param.LO   := 0;
        param.FRAC := NEW_FLEX_FIXED_POINT_FIELD(
                          HI         => FRAC_HI,
                          LO         => FRAC_LO,
                          POINT_POS  => FRAC_HI+1,
                          SIGN       => FALSE
                      );
        param.EXPO := NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                          HI         => EXPO_HI,
                          LO         => EXPO_LO
                      );
        return NEW_FLEX_POINT_PARAM(param, SIGN, ZERO, NAN, INF);
    end function;
    -------------------------------------------------------------------------------
    --! @brief Flex Point のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_PARAM(
                  EXPO_MAX           :  integer;
                  EXPO_MIN           :  integer;
                  EXPO_BIAS          :  integer;
                  FRAC_HI            :  integer;
                  FRAC_LO            :  integer;
                  SIGN               :  boolean := TRUE ;
                  ZERO               :  boolean := FALSE;
                  NAN                :  boolean := FALSE;
                  INF                :  boolean := FALSE
              )   return                FLEX_POINT_PARAM_TYPE
    is
        variable  param              :  FLEX_POINT_PARAM_TYPE;
    begin
        param.LO   := 0;
        param.FRAC := NEW_FLEX_FIXED_POINT_FIELD(
                          HI         => FRAC_HI ,
                          LO         => FRAC_LO ,
                          POINT_POS  => FRAC_HI+1,
                          SIGN       => FALSE
                      );
        param.EXPO := NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                          MAX        => EXPO_MAX ,
                          MIN        => EXPO_MIN ,
                          BIAS       => EXPO_BIAS,
                          LO         => param.FRAC.HI+1
                      );
        return NEW_FLEX_POINT_PARAM(param, SIGN, ZERO, NAN, INF);
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の 仮数部(fraction) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_FRACTION(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic_vector
    is
        alias     i_data             :  std_logic_vector(PARAM.BITS     -1 downto 0) is DATA;
        variable  fraction           :  std_logic_vector(PARAM.FRAC.BITS-1 downto 0);
    begin
        fraction := i_data(PARAM.FRAC.HI downto PARAM.FRAC.LO);
        return fraction;
    end function;

    function  GET_FRACTION(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                unsigned
    is
        alias     i_data             :  std_logic_vector(PARAM.BITS     -1 downto 0) is DATA;
        variable  fraction           :  unsigned        (PARAM.FRAC.BITS-1 downto 0);
    begin
        fraction := unsigned(i_data(PARAM.FRAC.HI downto PARAM.FRAC.LO));
        return fraction;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の 指数部(exponent) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_EXPONENT(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic_vector
    is
        alias     i_data             :  std_logic_vector(PARAM.BITS     -1 downto 0) is DATA;
        variable  exponent           :  std_logic_vector(PARAM.EXPO.BITS-1 downto 0);
    begin
        exponent := i_data(PARAM.EXPO.HI downto PARAM.EXPO.LO);
        return exponent;
    end function;

    function  GET_EXPONENT(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                unsigned
    is
        variable  exponent           :  std_logic_vector(PARAM.EXPO.BITS-1 downto 0);
    begin
        exponent := GET_EXPONENT(PARAM, DATA);
        return unsigned(exponent);
    end function;

    function  GET_EXPONENT(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                integer
    is
        variable  exponent           :  unsigned(PARAM.EXPO.BITS-1 downto 0);
    begin
        exponent := GET_EXPONENT(PARAM, DATA);
        return to_integer(exponent);
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の 符号部(sign) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_SIGN(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic
    is
        alias     i_data             :  std_logic_vector(PARAM.BITS     -1 downto 0) is DATA;
        variable  fraction           :  std_logic_vector(PARAM.FRAC.BITS-1 downto 0);
    begin
        if    (PARAM.SIGN.BITS > 0   ) then
            return i_data(PARAM.SIGN.POS);
        elsif (PARAM.FRAC.SIGN = TRUE) then
            fraction := GET_FRACTION(PARAM, DATA);
            return fraction(fraction'high);
        else
            return '0';
        end if;
    end function;

    function  GET_SIGN(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                boolean
    is
        variable  sign               :  std_logic;
    begin
        sign := GET_SIGN(PARAM, DATA);
        return (sign = '1');
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Point の 符号部(zero) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_ZERO(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic
    is
        alias     i_data             :  std_logic_vector(PARAM.BITS     -1 downto 0) is DATA;
        variable  exponent           :  std_logic_vector(PARAM.EXPO.BITS-1 downto 0);
        constant  exponent_all_0     :  std_logic_vector(PARAM.EXPO.BITS-1 downto 0) := (others => '0');
        variable  fraction           :  std_logic_vector(PARAM.FRAC.BITS-1 downto 0);
        constant  fraction_all_0     :  std_logic_vector(PARAM.FRAC.BITS-1 downto 0) := (others => '0');
    begin
        if    (PARAM.ZERO.BITS > 0) then
            return i_data(PARAM.ZERO.POS);
        elsif (PARAM.EXPO.BITS > 0) then
            exponent := GET_EXPONENT(PARAM, DATA);
            fraction := GET_FRACTION(PARAM, DATA);
            if (exponent = exponent_all_0 and fraction = fraction_all_0) then
                return '1';
            else
                return '0';
            end if;
        else
            fraction := GET_FRACTION(PARAM, DATA);
            if (fraction = fraction_all_0) then
                return '1';
            else
                return '0';
            end if;
        end if;
    end function;

    function  GET_ZERO(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                boolean
    is
        variable  zero_flag          :  std_logic;
    begin
        zero_flag := GET_ZERO(PARAM, DATA);
        return (zero_flag = '1');
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の 符号部(nan) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_NAN(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic
    is
        alias     i_data             :  std_logic_vector(PARAM.BITS     -1 downto 0) is DATA;
        variable  exponent           :  std_logic_vector(PARAM.EXPO.BITS-1 downto 0);
        constant  exponent_all_1     :  std_logic_vector(PARAM.EXPO.BITS-1 downto 0) := (others => '1');
        variable  fraction           :  std_logic_vector(PARAM.FRAC.BITS-1 downto 0);
        constant  fraction_all_0     :  std_logic_vector(PARAM.FRAC.BITS-1 downto 0) := (others => '0');
    begin
        if    (PARAM.NAN.BITS /= 0) then
            return i_data(PARAM.NAN.POS);
        elsif (PARAM.EXPO.BITS > 0) then
            exponent := GET_EXPONENT(PARAM, DATA);
            fraction := GET_FRACTION(PARAM, DATA);
            if (exponent = exponent_all_1 and fraction /= fraction_all_0) then
                return '1';
            else
                return '0';
            end if;
        else
            return '0';
        end if;
    end function;
    
    function  GET_NAN(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                boolean
    is
        variable  nan_flag           :  std_logic;
    begin
        nan_flag := GET_NAN(PARAM, DATA);
        return (nan_flag = '1');
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Float Point の 符号部(inf) を取り出す関数
    -------------------------------------------------------------------------------
    function  GET_INF(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                std_logic
    is
        alias     i_data             :  std_logic_vector(PARAM.BITS     -1 downto 0) is DATA;
        variable  exponent           :  std_logic_vector(PARAM.EXPO.BITS-1 downto 0);
        constant  exponent_all_1     :  std_logic_vector(PARAM.EXPO.BITS-1 downto 0) := (others => '1');
        variable  fraction           :  std_logic_vector(PARAM.FRAC.BITS-1 downto 0);
        constant  fraction_all_0     :  std_logic_vector(PARAM.FRAC.BITS-1 downto 0) := (others => '0');
    begin
        if (PARAM.INF.BITS /= 0) then
            return i_data(PARAM.INF.POS);
        elsif (PARAM.EXPO.BITS > 0) then
            exponent := GET_EXPONENT(PARAM, DATA);
            fraction := GET_FRACTION(PARAM, DATA);
            if (exponent = exponent_all_1 and fraction = fraction_all_0) then
                return '1';
            else
                return '0';
            end if;
        else
            return '0';
        end if;
    end function;
    
    function  GET_INF(
                  PARAM              :  FLEX_POINT_PARAM_TYPE;
                  DATA               :  std_logic_vector
              )   return                boolean
    is
        variable  inf_flag           :  std_logic;
    begin
        inf_flag := GET_INF(PARAM, DATA);
        return (inf_flag = '1');
    end function;
    
    -------------------------------------------------------------------------------
    --! @brief Flex Point を補完したタイプを生成する関数
    -------------------------------------------------------------------------------
    function  COMPLEMENT(
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE
              )   return                FLEX_POINT_PARAM_TYPE
    is
        variable  target_param       :  FLEX_POINT_PARAM_TYPE;
    begin
        target_param.LO := 0;
        if   (SOURCE_PARAM.FRAC.POINT_POS > SOURCE_PARAM.FRAC.HI) then
            target_param.FRAC := NEW_FLEX_FIXED_POINT_FIELD(
                                     HI        => SOURCE_PARAM.FRAC.POINT_POS + SOURCE_PARAM.FRAC.LO,
                                     LO        => 0,
                                     POINT_POS => SOURCE_PARAM.FRAC.POINT_POS,
                                     SIGN      => FALSE
                                 );
        elsif (SOURCE_PARAM.FRAC.POINT_POS < 0) then
            target_param.FRAC := NEW_FLEX_FIXED_POINT_FIELD(
                                     HI        => SOURCE_PARAM.FRAC.HI,
                                     LO        => SOURCE_PARAM.FRAC.POINT_POS,
                                     POINT_POS => SOURCE_PARAM.FRAC.POINT_POS,
                                     SIGN      => FALSE
                                );
        else
            target_param.FRAC := NEW_FLEX_FIXED_POINT_FIELD(
                                     HI        => SOURCE_PARAM.FRAC.BITS-1,
                                     LO        => 0,
                                     POINT_POS => SOURCE_PARAM.FRAC.POINT_POS,
                                     SIGN      => FALSE
                                 );
        end if;
        if (SOURCE_PARAM.EXPO.BITS > 0) then
            target_param.EXPO := NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                                    MAX  => SOURCE_PARAM.EXPO.MAX ,
                                    MIN  => SOURCE_PARAM.EXPO.MIN ,
                                    BIAS => SOURCE_PARAM.EXPO.BIAS,
                                    HI   => target_param.FRAC.HI + 1 + SOURCE_PARAM.EXPO.BITS - 1,
                                    LO   => target_param.FRAC.HI + 1
                                );
        else
            target_param.EXPO := NONE_FLEX_FLOAT_POINT_EXPONENT_FIELD;
        end if;
        return NEW_FLEX_POINT_PARAM(
                   PARAM => target_param,
                   SIGN  => TRUE,
                   ZERO  => TRUE,
                   NAN   => TRUE,
                   INF   => TRUE
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point を補完したデータを生成する関数
    -------------------------------------------------------------------------------
    function  COMPLEMENT(
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_DATA        :  std_logic_vector
              )   return                std_logic_vector
    is
        variable  sign               :  std_logic;
        variable  zero               :  std_logic;
        variable  nan                :  std_logic;
        variable  inf                :  std_logic;
        variable  source_exponent_0  :  boolean;
        variable  source_exponent    :  std_logic_vector(SOURCE_PARAM.EXPO.BITS-1 downto 0);
        variable  source_fraction    :  std_logic_vector(SOURCE_PARAM.FRAC.BITS-1 downto 0);
        constant  exponent_all_0     :  std_logic_vector(SOURCE_PARAM.EXPO.BITS-1 downto 0) := (others => '0');
        variable  target_data        :  std_logic_vector(TARGET_PARAM.HI downto TARGET_PARAM.LO);
    begin
        if (TARGET_PARAM.INF.BITS  > 0) then
            target_data(TARGET_PARAM.INF.POS ) := GET_INF (SOURCE_PARAM, SOURCE_DATA);
        end if;
        if (TARGET_PARAM.NAN.BITS  > 0) then
            target_data(TARGET_PARAM.NAN.POS ) := GET_NAN (SOURCE_PARAM, SOURCE_DATA);
        end if;
        if (TARGET_PARAM.ZERO.BITS > 0) then
            target_data(TARGET_PARAM.ZERO.POS) := GET_ZERO(SOURCE_PARAM, SOURCE_DATA);
        end if;
        if (TARGET_PARAM.SIGN.BITS > 0) then
            target_data(TARGET_PARAM.SIGN.POS) := GET_SIGN(SOURCE_PARAM, SOURCE_DATA);
        end if;
        if (SOURCE_PARAM.EXPO.BITS > 0) then
            source_exponent := GET_EXPONENT(SOURCE_PARAM, SOURCE_DATA);
            for i in TARGET_PARAM.EXPO.HI downto TARGET_PARAM.EXPO.LO loop
                if (i-TARGET_PARAM.EXPO.LO >= source_exponent'low ) and
                   (i-TARGET_PARAM.EXPO.LO <= source_exponent'high) then
                    target_data(i) := source_exponent(i-TARGET_PARAM.EXPO.LO);
                else
                    target_data(i) := '0';
                end if;
            end loop;
            source_exponent_0 := (source_exponent = exponent_all_0);
        else
            source_exponent_0 := TRUE;
        end if;
        source_fraction := GET_FRACTION(SOURCE_PARAM, SOURCE_DATA);
        for i in TARGET_PARAM.FRAC.HI downto TARGET_PARAM.FRAC.LO loop
            if  (i = TARGET_PARAM.FRAC.POINT_POS) and
                (SOURCE_PARAM.FRAC.POINT_POS > SOURCE_PARAM.FRAC.HI) then
                if (source_exponent_0 = FALSE) then
                    target_data(i) := '1';
                else
                    target_data(i) := '0';
                end if;                    
            elsif (i-TARGET_PARAM.FRAC.LO >= source_fraction'low ) and
                  (i-TARGET_PARAM.FRAC.LO <= source_fraction'high) then
                target_data(i) := source_fraction(i-TARGET_PARAM.FRAC.LO);
            else
                target_data(i) := '0';
            end if;
        end loop;
        return target_data;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の乗算結果のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  MULTIPLY(
                  A_PARAM            :  FLEX_POINT_PARAM_TYPE;
                  B_PARAM            :  FLEX_POINT_PARAM_TYPE
              )   return                FLEX_POINT_PARAM_TYPE
    is
        constant  a                  :  FLEX_POINT_PARAM_TYPE := COMPLEMENT(A_PARAM);
        variable  b                  :  FLEX_POINT_PARAM_TYPE := COMPLEMENT(B_PARAM);
        variable  target_param       :  FLEX_POINT_PARAM_TYPE;
        variable  frac_sign          :  boolean;
        variable  frac_x_us          :  boolean;
        variable  frac_bits          :  integer;
    begin
        target_param.LO   := 0;
        if (a.EXPO.BITS = 0 and b.EXPO.BITS = 0) then
            frac_sign := a.FRAC.SIGN  or b.FRAC.SIGN;
            frac_x_us := a.FRAC.SIGN xor b.FRAC.SIGN;
        else
            frac_sign := FALSE;
            frac_x_us := FALSE;
        end if;
        if (frac_x_us = TRUE) then
            frac_bits := a.FRAC.BITS + b.FRAC.BITS + 1;
        else
            frac_bits := a.FRAC.BITS + b.FRAC.BITS;
        end if;
        target_param.FRAC := NEW_FLEX_FIXED_POINT_FIELD(
                                 HI         => frac_bits - 1,
                                 LO         => 0,
                                 POINT_POS  => a.FRAC.POINT_POS + b.FRAC.POINT_POS,
                                 SIGN       => frac_sign
                             );
        if    (a.EXPO.BITS > 0 and b.EXPO.BITS > 0) then
            target_param.EXPO := NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                                     MAX => a.EXPO.MAX + b.EXPO.MAX,
                                     MIN => a.EXPO.MIN + b.EXPO.MIN,
                                     LO  => target_param.FRAC.HI + 1
                                 );
        elsif (a.EXPO.BITS > 0 and b.EXPO.BITS = 0) then
            target_param.EXPO := NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                                     MAX => a.EXPO.MAX,
                                     MIN => a.EXPO.MIN,
                                     LO  => target_param.FRAC.HI + 1
                                 );
        elsif (a.EXPO.BITS = 0 and b.EXPO.BITS > 0) then
            target_param.EXPO := NEW_FLEX_FLOAT_POINT_EXPONENT_FIELD(
                                     MAX => b.EXPO.MAX,
                                     MIN => b.EXPO.MIN,
                                     LO  => target_param.FRAC.HI + 1
                                 );
        else
            target_param.EXPO := NONE_FLEX_FLOAT_POINT_EXPONENT_FIELD;
        end if;
        if (a.EXPO.BITS > 0 or b.EXPO.BITS > 0) then
            return NEW_FLEX_POINT_PARAM(
                       PARAM => target_param,
                       SIGN  => TRUE,
                       ZERO  => TRUE,
                       NAN   => TRUE,
                       INF   => TRUE
                   );
        else
            return NEW_FLEX_POINT_PARAM(
                       PARAM => target_param,
                       SIGN  => FALSE,
                       ZERO  => FALSE,
                       NAN   => FALSE,
                       INF   => FALSE
                   );
        end if;
    end function;

    -------------------------------------------------------------------------------
    --! @brief 乗算(unsigned x unsigned)
    -------------------------------------------------------------------------------
    function  MULT_UU(
                  T_BITS             :  integer;
                  A_DATA             :  std_logic_vector;
                  B_DATA             :  std_logic_vector
              )   return                std_logic_vector
    is
        variable  a                  :  unsigned(A_DATA'length-1 downto 0);
        variable  b                  :  unsigned(B_DATA'length-1 downto 0);
        variable  t                  :  unsigned(T_BITS       -1 downto 0);
    begin
        a := unsigned(A_DATA);
        b := unsigned(B_DATA);
        t := a * b;
        return std_logic_vector(t);
    end function;

    -------------------------------------------------------------------------------
    --! @brief 乗算(signed x unsigned)
    -------------------------------------------------------------------------------
    function  MULT_SU(
                  T_BITS             :  integer;
                  A_DATA             :  std_logic_vector;
                  B_DATA             :  std_logic_vector
              )   return                std_logic_vector
        is
        variable  a                  :  signed(A_DATA'length-1 downto 0);
        variable  b                  :  signed(B_DATA'length   downto 0);
        variable  t                  :  signed(T_BITS       -1 downto 0);
    begin
        a := signed(      A_DATA);
        b := signed("0" & B_DATA);
        t := a * b;
        return std_logic_vector(t);
    end function;

    -------------------------------------------------------------------------------
    --! @brief 乗算(signed x signed)
    -------------------------------------------------------------------------------
    function  MULT_SS(
                  T_BITS             :  integer;
                  A_DATA             :  std_logic_vector;
                  B_DATA             :  std_logic_vector
              )   return                std_logic_vector
        is
        variable  a                  :  signed(A_DATA'length-1 downto 0);
        variable  b                  :  signed(B_DATA'length-1 downto 0);
        variable  t                  :  signed(T_BITS       -1 downto 0);
    begin
        a := signed(A_DATA);
        b := signed(B_DATA);
        t := a * b;
        return std_logic_vector(t);
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の乗算結果のデータを生成する関数
    -------------------------------------------------------------------------------
    function  MULTIPLY(
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  A_PARAM            :  FLEX_POINT_PARAM_TYPE;
                  A_DATA             :  std_logic_vector;
                  B_PARAM            :  FLEX_POINT_PARAM_TYPE;
                  B_DATA             :  std_logic_vector
              )   return                std_logic_vector
    is
        constant  src_a_param        :  FLEX_POINT_PARAM_TYPE := COMPLEMENT(A_PARAM);
        constant  src_b_param        :  FLEX_POINT_PARAM_TYPE := COMPLEMENT(B_PARAM);
        variable  src_a_data         :  std_logic_vector(src_a_param.BITS      -1 downto 0);
        variable  src_b_data         :  std_logic_vector(src_b_param.BITS      -1 downto 0);
        variable  src_a_frac         :  std_logic_vector(src_a_param.FRAC.BITS -1 downto 0);
        variable  src_b_frac         :  std_logic_vector(src_b_param.FRAC.BITS -1 downto 0);
        variable  src_a_expo         :  integer range 0 to (2**src_a_param.EXPO.BITS )-1;
        variable  src_b_expo         :  integer range 0 to (2**src_b_param.EXPO.BITS )-1;
        variable  src_a_sign         :  std_logic;
        variable  src_b_sign         :  std_logic;
        variable  src_a_zero         :  std_logic;
        variable  src_b_zero         :  std_logic;
        variable  src_a_nan          :  std_logic;
        variable  src_b_nan          :  std_logic;
        variable  src_a_inf          :  std_logic;
        variable  src_b_inf          :  std_logic;
        variable  target_data        :  std_logic_vector(TARGET_PARAM.BITS     -1 downto 0);
        variable  target_frac        :  std_logic_vector(TARGET_PARAM.FRAC.BITS-1 downto 0);
        constant  target_frac_0      :  std_logic_vector(TARGET_PARAM.FRAC.BITS-1 downto 0) := (others => '0');
        variable  target_expo        :  integer range 0 to (2**TARGET_PARAM.EXPO.BITS)-1;
    begin
        -----------------------------------------------------------------------
        -- 
        -----------------------------------------------------------------------
        src_a_data := COMPLEMENT  (src_a_param, A_PARAM, A_DATA);
        src_b_data := COMPLEMENT  (src_b_param, B_PARAM, B_DATA);
        -----------------------------------------------------------------------
        -- 
        -----------------------------------------------------------------------
        src_a_frac := GET_FRACTION(src_a_param, src_a_data);
        src_b_frac := GET_FRACTION(src_b_param, src_b_data);
        if    (src_a_param.FRAC.SIGN = TRUE  and src_b_param.FRAC.SIGN = TRUE ) then
            target_frac := MULT_SS(TARGET_PARAM.FRAC.BITS, src_a_frac, src_b_frac);
        elsif (src_a_param.FRAC.SIGN = TRUE  and src_b_param.FRAC.SIGN = FALSE) then
            target_frac := MULT_SU(TARGET_PARAM.FRAC.BITS, src_a_frac, src_b_frac);
        elsif (src_a_param.FRAC.SIGN = FALSE and src_b_param.FRAC.SIGN = TRUE ) then
            target_frac := MULT_SU(TARGET_PARAM.FRAC.BITS, src_b_frac, src_a_frac);
        else
            target_frac := MULT_UU(TARGET_PARAM.FRAC.BITS, src_a_frac, src_b_frac);
        end if;
        target_data(TARGET_PARAM.FRAC.HI downto TARGET_PARAM.FRAC.LO) := target_frac;
        -----------------------------------------------------------------------
        -- 
        -----------------------------------------------------------------------
        if    (src_a_param.EXPO.BITS > 0 and src_b_param.EXPO.BITS > 0) then
            src_a_expo  := GET_EXPONENT(src_a_param, src_a_data);
            src_b_expo  := GET_EXPONENT(src_b_param, src_b_data);
            target_expo := src_a_expo + src_b_expo + 
                           (TARGET_PARAM.EXPO.BIAS - src_a_param.EXPO.BIAS - src_b_param.EXPO.BIAS);
            target_data(TARGET_PARAM.EXPO.HI downto TARGET_PARAM.EXPO.LO) := std_logic_vector(to_unsigned(target_expo, TARGET_PARAM.EXPO.BITS));
        elsif (src_a_param.EXPO.BITS > 0 and src_b_param.EXPO.BITS = 0) then
            src_a_expo  := GET_EXPONENT(src_a_param, src_a_data);
            target_expo := src_a_expo + 
                           (TARGET_PARAM.EXPO.BIAS - src_a_param.EXPO.BIAS);
            target_data(TARGET_PARAM.EXPO.HI downto TARGET_PARAM.EXPO.LO) := std_logic_vector(to_unsigned(target_expo, TARGET_PARAM.EXPO.BITS));
        elsif (src_a_param.EXPO.BITS = 0 and src_b_param.EXPO.BITS > 0) then
            target_expo := src_b_expo + 
                           (TARGET_PARAM.EXPO.BIAS - src_b_param.EXPO.BIAS);
            target_data(TARGET_PARAM.EXPO.HI downto TARGET_PARAM.EXPO.LO) := std_logic_vector(to_unsigned(target_expo, TARGET_PARAM.EXPO.BITS));
        end if;
        -----------------------------------------------------------------------
        -- 
        -----------------------------------------------------------------------
        src_a_sign := GET_SIGN(src_a_param, src_a_data);
        src_b_sign := GET_SIGN(src_b_param, src_b_data);
        target_data(TARGET_PARAM.SIGN.POS) := src_a_sign xor src_b_sign;
        -----------------------------------------------------------------------
        -- 
        -----------------------------------------------------------------------
        src_a_zero := GET_ZERO(src_a_param, src_a_data);
        src_a_nan  := GET_NAN (src_a_param, src_a_data);
        src_a_inf  := GET_INF (src_a_param, src_a_data);
        src_b_zero := GET_ZERO(src_b_param, src_b_data);
        src_b_nan  := GET_NAN (src_b_param, src_b_data);
        src_b_inf  := GET_INF (src_b_param, src_b_data);
        if    (src_a_nan  = '1') or
              (src_b_nan  = '1') or
              (src_a_zero = '1' and src_b_inf = '1') or
              (src_b_zero = '1' and src_a_inf = '1') then
            target_data(TARGET_PARAM.ZERO.POS) := '0';
            target_data(TARGET_PARAM.NAN.POS ) := '1';
            target_data(TARGET_PARAM.INF.POS ) := '0';
        elsif (src_a_inf  = '1' and src_b_inf = '1') or
              (src_a_zero = '0' and src_b_inf = '1') or
              (src_b_zero = '0' and src_a_inf = '1') then
            target_data(TARGET_PARAM.ZERO.POS) := '0';
            target_data(TARGET_PARAM.NAN.POS ) := '0';
            target_data(TARGET_PARAM.INF.POS ) := '1';
        elsif (src_a_zero = '1') or
              (src_b_zero = '1') then
            target_data(TARGET_PARAM.ZERO.POS) := '1';
            target_data(TARGET_PARAM.NAN.POS ) := '0';
            target_data(TARGET_PARAM.INF.POS ) := '0';
        else            
            target_data(TARGET_PARAM.ZERO.POS) := '0';
            target_data(TARGET_PARAM.NAN.POS ) := '0';
            target_data(TARGET_PARAM.INF.POS ) := '0';
        end if;
        -----------------------------------------------------------------------
        -- 
        -----------------------------------------------------------------------
        return target_data;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換の状態のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  NEW_FLEX_POINT_TO_FIXED_STATE(
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE
              )   return                FLEX_POINT_TO_FIXED_STATE_TYPE
    is
        variable  state_type         :  FLEX_POINT_TO_FIXED_STATE_TYPE;
        variable  target_point_pos   :  integer;
    begin
        state_type.SOURCE_PARAM   := SOURCE_PARAM;
        state_type.TARGET_PARAM   := TARGET_PARAM;
        state_type.SHIFT_STATE_LO := 0;
        state_type.SHIFT_STATE_HI := SOURCE_PARAM.EXPO.BITS-1;
        if (SOURCE_PARAM.SIGN.BITS > 0) then
            state_type.SIGN_STATE := state_type.SHIFT_STATE_HI + 1;
            state_type.MAX        := state_type.SHIFT_STATE_HI + 1;
        else
            state_type.SIGN_STATE := state_type.SHIFT_STATE_HI;
            state_type.MAX        := state_type.SHIFT_STATE_HI;
        end if;
        state_type.SIZE  := state_type.MAX + 1;
        target_point_pos := SOURCE_PARAM.FRAC.POINT_POS - SOURCE_PARAM.EXPO.MIN;
        if (target_point_pos < 0) then
            state_type.SOURCE_OFFSET := -target_point_pos;
        else
            state_type.SOURCE_OFFSET := 0;
        end if;
        return state_type;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換のタイプを生成する関数
    -------------------------------------------------------------------------------
    function  TO_FIXED_POINT(
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE
              )   return                FLEX_POINT_PARAM_TYPE
    is
        variable  target_param       :  FLEX_POINT_PARAM_TYPE;
        variable  sign               :  boolean;
        variable  fixed_hi           :  integer;
        variable  point_pos          :  integer;
        variable  offset             :  integer;
    begin
        point_pos := SOURCE_PARAM.FRAC.POINT_POS - SOURCE_PARAM.EXPO.MIN;
        offset    := 0;
        if (point_pos < 0) then
            offset    := -point_pos;
            point_pos := 0;
        end if;
        fixed_hi := point_pos + SOURCE_PARAM.EXPO.MAX + offset;
        if (fixed_hi < SOURCE_PARAM.FRAC.HI) then
            fixed_hi := SOURCE_PARAM.FRAC.HI;
        end if;
        if (SOURCE_PARAM.SIGN.BITS > 0) then
            fixed_hi := fixed_hi + 1;
            sign     := TRUE;
        else
            sign     := FALSE;
        end if;
        target_param.LO   := 0;
        target_param.FRAC := NEW_FLEX_FIXED_POINT_FIELD(
                                 HI         => fixed_hi,
                                 LO         => 0,
                                 POINT_POS  => point_pos,
                                 SIGN       => sign
                             );
        target_param.EXPO := NONE_FLEX_FLOAT_POINT_EXPONENT_FIELD;
        return NEW_FLEX_POINT_PARAM(
                   PARAM => target_param,
                   SIGN  => FALSE,
                   ZERO  => FALSE,
                   NAN   => FALSE,
                   INF   => FALSE
               );
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換を行う関数
    -------------------------------------------------------------------------------
    function  TO_FIXED_POINT(
                  STATE_TYPE         :  FLEX_POINT_TO_FIXED_STATE_TYPE;
                  STATE              :  integer;
                  SOURCE_DATA        :  std_logic_vector;
                  TARGET_DATA        :  std_logic_vector
              )   return                std_logic_vector
    is
        constant  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE := STATE_TYPE.SOURCE_PARAM;
        constant  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE := STATE_TYPE.TARGET_PARAM;
        constant  SOURCE_OFFSET      :  integer               := STATE_TYPE.SOURCE_OFFSET;
        variable  point_pos          :  integer;
        variable  source_frac        :  std_logic_vector(SOURCE_PARAM.FRAC.BITS-1 downto 0);
        variable  target_frac        :  std_logic_vector(TARGET_PARAM.FRAC.BITS-1 downto 0);
        variable  source_sign        :  boolean;
        variable  signed_frac        :  signed          (TARGET_PARAM.FRAC.BITS-1 downto 0);
        variable  new_data           :  std_logic_vector(TARGET_PARAM     .BITS-1 downto 0);
        function  FRAC_SHIFT(
                      SHIFT          :  integer;
                      EXPO           :  std_logic_vector;
                      FRAC           :  std_logic_vector
                  )   return            std_logic_vector
        is
            variable  new_frac       :  std_logic_vector(FRAC'length-1 downto 0);
        begin
            if (EXPO(SHIFT) = '1') then
                for i in FRAC'range loop
                    if (i-2**STATE >= FRAC'low and i-2**STATE <= FRAC'high) then
                        new_frac(i) := FRAC(i-2**STATE);
                    else
                        new_frac(i) := '0';
                    end if;
                end loop;
            else
                new_frac := FRAC;
            end if;
            return new_frac;
        end function;
    begin
        if (STATE = 0) then
            source_frac := GET_FRACTION(SOURCE_PARAM, SOURCE_DATA);
            for i in target_frac'range loop
                if (i-SOURCE_OFFSET >= source_frac'low and i-SOURCE_OFFSET <= source_frac'high) then
                    target_frac(i) := source_frac(i-SOURCE_OFFSET);
                else
                    target_frac(i) := '0';
                end if;
            end loop;
        else
            target_frac := GET_FRACTION(TARGET_PARAM, TARGET_DATA);
        end if;
        if    (STATE >= STATE_TYPE.SHIFT_STATE_LO and STATE <= STATE_TYPE.SHIFT_STATE_HI) then
            target_frac := FRAC_SHIFT(
                               SHIFT => STATE - STATE_TYPE.SHIFT_STATE_LO,
                               EXPO  => GET_EXPONENT(SOURCE_PARAM, SOURCE_DATA),
                               FRAC  => target_frac
                           );
        elsif (STATE  = STATE_TYPE.SIGN_STATE) then
            source_sign := GET_SIGN(SOURCE_PARAM, SOURCE_DATA);
            if (source_sign) then
                signed_frac := signed(target_frac);
                target_frac := std_logic_vector(0-signed_frac);
            end if;
        end if;
        new_data(TARGET_PARAM.FRAC.HI downto TARGET_PARAM.FRAC.LO) := target_frac;
        if (TARGET_PARAM.EXPO.BITS > 0) then
            for i in TARGET_PARAM.EXPO.LO to TARGET_PARAM.EXPO.HI loop
                new_data(i) := '0';
            end loop;
        end if;
        if (TARGET_PARAM.SIGN.BITS > 0) then
            new_data(TARGET_PARAM.SIGN.POS) := '0';
        end if;
        if (TARGET_PARAM.ZERO.BITS > 0) then
            new_data(TARGET_PARAM.SIGN.POS) := '0';
        end if;
        if (TARGET_PARAM.NAN .BITS > 0) then
            new_data(TARGET_PARAM.SIGN.POS) := '0';
        end if;
        if (TARGET_PARAM.INF.BITS  > 0) then
            new_data(TARGET_PARAM.SIGN.POS) := '0';
        end if;
        return new_data;
    end function;

    -------------------------------------------------------------------------------
    --! @brief Flex Point の固定少数点変換を行う関数
    -------------------------------------------------------------------------------
    function  TO_FIXED_POINT(
                  TARGET_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_PARAM       :  FLEX_POINT_PARAM_TYPE;
                  SOURCE_DATA        :  std_logic_vector
              )   return                std_logic_vector
    is
        constant  STATE_TYPE         :  FLEX_POINT_TO_FIXED_STATE_TYPE
                                     := NEW_FLEX_POINT_TO_FIXED_STATE(
                                            SOURCE_PARAM => SOURCE_PARAM, 
                                            TARGET_PARAM => TARGET_PARAM
                                        );
        variable  target_data        :  std_logic_vector(TARGET_PARAM.BITS-1 downto 0);
    begin
        for state in 0 to STATE_TYPE.MAX loop
            target_data := TO_FIXED_POINT(
                               STATE_TYPE   => STATE_TYPE,
                               STATE        => state,
                               SOURCE_DATA  => SOURCE_DATA,
                               TARGET_DATA  => target_data
                           );
        end loop;
        return target_data;
    end function;
end FLEX_POINT_TYPES;
