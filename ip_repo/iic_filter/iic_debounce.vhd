-------------------------------------------------------------------------------
-- iic_debounce.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--  ***************************************************************************
--  ** DISCLAIMER OF LIABILITY                                               **
--  **                                                                       **
--  **  This file contains proprietary and confidential information of       **
--  **  Xilinx, Inc. ("Xilinx"), that is distributed under a license         **
--  **  from Xilinx, and may be used, copied and/or disclosed only           **
--  **  pursuant to the terms of a valid license agreement with Xilinx.      **
--  **                                                                       **
--  **  XILINX is PROVIDING THIS DESIGN, CODE, OR INFORMATION                **
--  **  ("MATERIALS") "AS is" WITHOUT WARRANTY OF ANY KIND, EITHER           **
--  **  EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                  **
--  **  LIMITATION, ANY WARRANTY WITH RESPECT to NONINFRINGEMENT,            **
--  **  MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx        **
--  **  does not warrant that functions included in the Materials will       **
--  **  meet the requirements of Licensee, or that the operation of the      **
--  **  Materials will be uninterrupted or error-free, or that defects       **
--  **  in the Materials will be corrected. Furthermore, Xilinx does         **
--  **  not warrant or make any representations regarding use, or the        **
--  **  results of the use, of the Materials in terms of correctness,        **
--  **  accuracy, reliability or otherwise.                                  **
--  **                                                                       **
--  **  Xilinx products are not designed or intended to be fail-safe,        **
--  **  or for use in any application requiring fail-safe performance,       **
--  **  such as life-support or safety devices or systems, Class III         **
--  **  medical devices, nuclear facilities, applications related to         **
--  **  the deployment of airbags, or any other applications that could      **
--  **  lead to death, personal injury or severe property or                 **
--  **  environmental damage (individually and collectively, "critical       **
--  **  applications"). Customer assumes the sole risk and liability         **
--  **  of any use of Xilinx products in critical applications,              **
--  **  subject only to applicable laws and regulations governing            **
--  **  limitations on product liability.                                    **
--  **                                                                       **
--  **  Copyright 2009 Xilinx, Inc.                                          **
--  **  All rights reserved.                                                 **
--  **                                                                       **
--  **  This disclaimer and copyright notice must be retained as part        **
--  **  of this file at all times.                                           **
--  ***************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library proc_common_v4_0;

-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_INERTIAL_DELAY     -- Filtering delay       
--      C_DEFAULT            -- User logic high address 
-- Definition of Ports:
--      Sysclk               -- System clock
--      Stable               -- IIC signal is Stable
--      Unstable_n           -- IIC signal is unstable
--      Noisy                -- IIC signal is Noisy
--      Clean                -- IIC signal is Clean
-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity iic_debounce is
   
   generic (
      C_INERTIAL_DELAY : integer range 0 to 255 := 6;
      C_DEFAULT        : std_logic              := '1'
      );

   port (
      Sysclk     : in std_logic;
      Rst        : in std_logic;
      Stable     : in  std_logic;
      Unstable_n : out std_logic;
      Noisy      : in  std_logic;
      Clean      : out std_logic);

end entity iic_debounce;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture RTL of iic_debounce is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";


   -- XST proceses default assignments for configuration purposes
   signal clean_cs  : std_logic := C_DEFAULT;
   signal stable_cs : std_logic := '1';
   signal debounce_ct : integer range 0 to 255;
   signal Noisy_d1 : std_logic := '1';
   signal Noisy_d2 : std_logic := '1';
   signal Noisy_d3 : std_logic := '1';
begin

   ----------------------------------------------------------------------------
   -- Input Registers Process 
   -- This process samples the incoming SDA and SCL with the system clock
   ----------------------------------------------------------------------------
   INPUT_DOUBLE_REGS : process(Sysclk)
   begin
      if Sysclk'event and Sysclk = '1' then
            Noisy_d1 <= Noisy;
            Noisy_d2 <= Noisy_d1;
            Noisy_d3 <= Noisy_d2;-- buffer async input
      end if;
   end process INPUT_DOUBLE_REGS;

   ----------------------------------------------------------------------------
   --  GEN_INERTIAL : Generate when C_INERTIAL_DELAY > 0
   ----------------------------------------------------------------------------

   GEN_INERTIAL : if (C_INERTIAL_DELAY > 0) generate

   ----------------------------------------------------------------------------
   --  GEN_INERTIAL : C_INERTIAL_DELAY > 0
   -- Inertial delay filters out pulses that are smaller in width then the
   -- specified delay. If the C_INERTIAL_DELAY is 0 then the input is passed
   -- directly to the "Clean" output signal.
   ----------------------------------------------------------------------------
      INRTL_PROCESS : process (Sysclk) is
      begin

         if ((rising_edge(Sysclk))) then
            if Rst = '1' then 
               clean_cs <= C_DEFAULT;
               debounce_ct <= C_INERTIAL_DELAY  ;
               Unstable_n  <= '1';
            elsif (clean_cs = Noisy_d3) then
               debounce_ct <= C_INERTIAL_DELAY   ;
               Unstable_n  <= '1';
            else
               if (debounce_ct > 0) then
                  debounce_ct <= debounce_ct - 1;
                  Unstable_n <= '0';
               else 
                  if Stable = '1' then
                    clean_cs <= Noisy_d3;
                    debounce_ct <= C_INERTIAL_DELAY   ;
                    Unstable_n <= '1';
                  end if;  
               end if;
            end if;
         end if;
      
      end process INRTL_PROCESS;

      s0 : Clean <= clean_cs;
   end generate GEN_INERTIAL;

   ----------------------------------------------------------------------------
   -- NO_INERTIAL : C_INERTIAL_DELAY = 0
   -- No inertial delay means output is always Stable
   ----------------------------------------------------------------------------
   NO_INERTIAL : if (C_INERTIAL_DELAY = 0) generate
      
      s0 : Clean      <= Noisy_d3;
      s1 : Unstable_n <= '1';  
                               
   end generate NO_INERTIAL;
   
end architecture RTL;
