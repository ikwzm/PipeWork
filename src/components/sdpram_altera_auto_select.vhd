-----------------------------------------------------------------------------------
--!     @file    sdpram_altera_auto_select.vhd
--!     @brief   Synchronous Dual Port RAM Model for Altera FPGA.
--!     @version 1.5.9
--!     @date    2016/3/13
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2016 Ichiro Kawazome
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
architecture ALTERA_AUTO_SELECT of SDPRAM is
    component altsyncram 
        generic (
            width_a                                :  integer;
            widthad_a                              :  integer;
            numwords_a                             :  integer;
            outdata_reg_a                          :  string ;
            address_aclr_a                         :  string ;
            outdata_aclr_a                         :  string ;
            indata_aclr_a                          :  string ;
            wrcontrol_aclr_a                       :  string ;
            byteena_aclr_a                         :  string ;
            width_byteena_a                        :  integer;
            clock_enable_input_a                   :  string ;
            clock_enable_output_a                  :  string ;
            clock_enable_core_a                    :  string ;
            read_during_write_mode_port_a          :  string ;
            width_b                                :  integer;
            widthad_b                              :  integer;
            numwords_b                             :  integer;
            rdcontrol_reg_b                        :  string ;
            address_reg_b                          :  string ;
            outdata_reg_b                          :  string ;
            outdata_aclr_b                         :  string ;
            rdcontrol_aclr_b                       :  string ;
            indata_reg_b                           :  string ;
            wrcontrol_wraddress_reg_b              :  string ;
            byteena_reg_b                          :  string ;
            indata_aclr_b                          :  string ;
            wrcontrol_aclr_b                       :  string ;
            address_aclr_b                         :  string ;
            byteena_aclr_b                         :  string ;
            width_byteena_b                        :  integer;
            clock_enable_input_b                   :  string ;
            clock_enable_output_b                  :  string ;
            clock_enable_core_b                    :  string ;
            read_during_write_mode_port_b          :  string ;
            enable_ecc                             :  string ;
            width_eccstatus                        :  integer;
            ecc_pipeline_stage_enabled             :  string ;
            operation_mode                         :  string ;
            byte_size                              :  integer;
            read_during_write_mode_mixed_ports     :  string ;
            ram_block_type                         :  string ;
            init_file                              :  string ;
            init_file_layout                       :  string ;
            maximum_depth                          :  integer;
            intended_device_family                 :  string ;
            power_up_uninitialized                 :  string ;
            implement_in_les                       :  string ;
            sim_show_memory_data_in_port_b_layout  :  string ;
            lpm_hint                               :  string ;
            lpm_type                               :  string 
        );
        port (
            wren_a            : in  std_logic;
            wren_b            : in  std_logic;
            rden_a            : in  std_logic;
            rden_b            : in  std_logic;
            data_a            : in  std_logic_vector(width_a   - 1 downto 0);
            data_b            : in  std_logic_vector(width_b   - 1 downto 0);
            address_a         : in  std_logic_vector(widthad_a - 1 downto 0);
            address_b         : in  std_logic_vector(widthad_b - 1 downto 0);
            clock0            : in  std_logic;
            clock1            : in  std_logic;
            clocken0          : in  std_logic;
            clocken1          : in  std_logic;
            clocken2          : in  std_logic;
            clocken3          : in  std_logic;
            aclr0             : in  std_logic;
            aclr1             : in  std_logic;
            addressstall_a    : in  std_logic;
            addressstall_b    : in  std_logic;
            byteena_a         : in  std_logic_vector(width_byteena_a-1 downto 0);
            byteena_b         : in  std_logic_vector(width_byteena_b-1 downto 0);
            q_a               : out std_logic_vector(width_a - 1       downto 0);
            q_b               : out std_logic_vector(width_b - 1       downto 0);
            eccstatus         : out std_logic_vector(width_eccstatus-1 downto 0)
        );
    end component;
    constant sig0       : std_logic := '0';
    constant sig1       : std_logic := '1';
    constant data_b     : std_logic_vector(2**(RWIDTH  )-1 downto 0) := (others => '0');
    constant byteena_b  : std_logic_vector(2**(RWIDTH-3)-1 downto 0) := (others => '1');
    signal   wren       : std_logic;
    signal   byteena    : std_logic_vector(2**(WWIDTH-3)-1 downto 0);
begin
    process (WE)
        constant BE_LEN  : integer := 2**(WWIDTH-WEBIT-3);
        constant BE_ALL1 : std_logic_vector(BE_LEN-1 downto 0) := (others => '1');
        constant BE_ALL0 : std_logic_vector(BE_LEN-1 downto 0) := (others => '0');
        constant WE_ALL0 : std_logic_vector(WE'range) := (others => '0');
    begin
        if (WE /= WE_ALL0) then
            wren <= '1';
        else
            wren <= '0';
        end if;
        for i in WE'range loop
            if (WE(i) = '1') then
                byteena(BE_LEN*(i+1)-1 downto BE_LEN*i) <= BE_ALL1;
            else
                byteena(BE_LEN*(i+1)-1 downto BE_LEN*i) <= BE_ALL0;
            end if;
        end loop;
    end process;

    RAM:altsyncram
        generic map(
            width_a                                => 2**WWIDTH,
            widthad_a                              => (DEPTH-WWIDTH),
            numwords_a                             => 2**(DEPTH-WWIDTH),
            outdata_reg_a                          => "UNREGISTERED",
            address_aclr_a                         => "NONE",
            outdata_aclr_a                         => "NONE",
            indata_aclr_a                          => "NONE",
            wrcontrol_aclr_a                       => "NONE",
            byteena_aclr_a                         => "NONE",
            width_byteena_a                        => byteena'length,
            clock_enable_input_a                   => "NORMAL",
            clock_enable_output_a                  => "NORMAL",
            clock_enable_core_a                    => "USE_INPUT_CLKEN",
            read_during_write_mode_port_a          => "NEW_DATA_NO_NBE_READ",
            width_b                                => 2**RWIDTH,
            widthad_b                              => (DEPTH-RWIDTH),
            numwords_b                             => 2**(DEPTH-RWIDTH),
            rdcontrol_reg_b                        => "CLOCK1",
            address_reg_b                          => "CLOCK1",
            outdata_reg_b                          => "UNREGISTERED",
            outdata_aclr_b                         => "NONE",
            rdcontrol_aclr_b                       => "NONE",
            indata_reg_b                           => "CLOCK1",
            wrcontrol_wraddress_reg_b              => "CLOCK1",
            byteena_reg_b                          => "CLOCK1",
            indata_aclr_b                          => "NONE",
            wrcontrol_aclr_b                       => "NONE",
            address_aclr_b                         => "NONE",
            byteena_aclr_b                         => "NONE",
            width_byteena_b                        => byteena_b'length,
            clock_enable_input_b                   => "NORMAL",
            clock_enable_output_b                  => "NORMAL",
            clock_enable_core_b                    => "USE_INPUT_CLKEN",
            read_during_write_mode_port_b          => "NEW_DATA_NO_NBE_READ",
            enable_ecc                             => "FALSE",
            width_eccstatus                        => 3,
            ecc_pipeline_stage_enabled             => "FALSE",
            operation_mode                         => "DUAL_PORT",
            byte_size                              => 8,
            read_during_write_mode_mixed_ports     => "DONT_CARE",
            ram_block_type                         => "AUTO",
            init_file                              => "UNUSED",
            init_file_layout                       => "UNUSED",
            maximum_depth                          => 0,
            intended_device_family                 => "stratix v",
            power_up_uninitialized                 => "FALSE",
            implement_in_les                       => "OFF",
            sim_show_memory_data_in_port_b_layout  => "OFF",
            lpm_hint                               => "UNUSED",
            lpm_type                               => "altsyncram"
        )
        port map (
            wren_a            => wren,
            wren_b            => sig0,
            rden_a            => sig1,
            rden_b            => sig1,
            data_a            => WDATA,
            data_b            => data_b,
            address_a         => WADDR,
            address_b         => RADDR,
            clock0            => WCLK,
            clock1            => RCLK,
            clocken0          => sig1,
            clocken1          => sig1,
            clocken2          => sig1,
            clocken3          => sig1,
            aclr0             => sig0,
            aclr1             => sig0,
            addressstall_a    => sig0,
            addressstall_b    => sig0,
            byteena_a         => byteena,
            byteena_b         => byteena_b,
            q_a               => open,
            q_b               => RDATA,
            eccstatus         => open
        );
end ALTERA_AUTO_SELECT;
