-------------------------------------------------------------------------------
 -- iic_filter.vhd - entity/architecture pair
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
--  **  Copyright 2011 Xilinx, Inc.                                          **
--  **  All rights reserved.                                                 **
--  **                                                                       **
--  **  This disclaimer and copyright notice must be retained as part        **
--  **  of this file at all times.                                           **
--  ***************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--      SCL_INERTIAL_DELAY   -- SCL filtering delay 
--      SDA_INERTIAL_DELAY   -- SDA filtering delay 
-- Definition of Ports:
--      Sysclk               -- System clock
--      Scl_noisy            -- IIC SCL is noisy
--      Scl_clean            -- IIC SCL is clean
--      Sda_noisy            -- IIC SDA is Noisy
--      Sda_clean            -- IIC SDA is clean
--      Scl_noisy_out        -- Pass thru of un-filtered  signals
--      Scl_noisy_t
--      Scl_clean_in
--      Scl_clean_t
--      DBG1
--      DBG2
--      DBG3
-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

-- 03-Feb-2019 DFN Change default delay to 3; with 6 does not seem to work
--                 for LED DAC.

entity iic_filter is
   
   generic (
      SCL_INERTIAL_DELAY : integer range 0 to 255 := 3;
      SDA_INERTIAL_DELAY : integer range 0 to 255 := 3
      );

   port (
      Sysclk    : in  std_logic;
      Rst       : in  std_logic;
      Scl_noisy : in  std_logic;
      Scl_clean : out std_logic;
      Sda_noisy : in  std_logic;
      Sda_clean : out std_logic;
      Scl_noisy_out : out std_logic;
      Scl_noisy_t : out std_logic;
      Scl_clean_in : in std_logic;
      Scl_clean_t : in std_logic;
      Sda_noisy_out : out std_logic;
      Sda_noisy_t : out std_logic;
      Sda_clean_in : in std_logic;
      Sda_clean_t : in std_logic;
      DBG1 : out std_logic;
      DBG2 : out std_logic;
      DBG3 : out std_logic
      );

end entity iic_filter;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture RTL of iic_filter is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

component iic_debounce
   
   generic (
      C_INERTIAL_DELAY : integer range 0 to 255 := 3;
      C_DEFAULT        : std_logic              := '1'
      );

   port (
      Sysclk     : in std_logic;
      Rst        : in std_logic;
      Stable     : in  std_logic;
      Unstable_n : out std_logic;
      Noisy      : in  std_logic;
      Clean      : out std_logic);

end component;

   signal scl_unstable_n : std_logic;

begin

   ----------------------------------------------------------------------------
   -- The inertial delay is cross coupled between the two IIC signals to ensure
   -- that a delay in SCL because of a glitch also prevents any changes in SDA
   -- until SCL is clean. This prevents inertial delay on SCL from creating a
   -- situation whereby SCL is held high but SDA transitions low to high thus
   -- making the core think a STOP has occured. Changes on SDA do not inihibit
   -- SCL because that could alter the timing relationships for the clock
   -- edges. If other I2C devices follow the spec then SDA should be stable
   -- prior to the rising edge of SCL anyway. (Excluding noise of course)
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Assertion that reports the SCL inertial delay
   ----------------------------------------------------------------------------

   ASSERT (FALSE) REPORT "IIC filter configured for SCL inertial delay of "
      & integer'image(SCL_INERTIAL_DELAY) & " clocks."
      SEVERITY NOTE;

      INRTL_PROCESS : process (Sysclk) is
      begin

         if ((rising_edge(Sysclk))) then
           Scl_noisy_out <= Scl_clean_in;  
           Scl_noisy_t <= Scl_clean_t;  
           Sda_noisy_out <= Sda_clean_in;  
           Sda_noisy_t <= Sda_clean_t;  
           DBG1 <= Sda_noisy;
           DBG2 <= Sda_clean_t;
           DBG3 <= Sda_clean_in;
          end if;
      
      end process INRTL_PROCESS;
   
   ----------------------------------------------------------------------------
   -- Instantiating component debounce 
   ----------------------------------------------------------------------------
   
   SCL_DEBOUNCE : iic_debounce
      generic map (
         C_INERTIAL_DELAY => SCL_INERTIAL_DELAY, 
         C_DEFAULT        => '1')
      port map (
         Sysclk     => Sysclk,
         Rst        => Rst,

         Stable     => '1',
         Unstable_n => scl_unstable_n,

         Noisy      => Scl_noisy,  
         Clean      => Scl_clean); 

   ----------------------------------------------------------------------------
   -- Assertion that reports the SDA inertial delay
   ----------------------------------------------------------------------------
   
   ASSERT (FALSE) REPORT "IIC filter configured for SDA inertial delay of "
      & integer'image(SDA_INERTIAL_DELAY) & " clocks."
      SEVERITY NOTE;
   
   ----------------------------------------------------------------------------
   -- Instantiating component debounce 
   ----------------------------------------------------------------------------
   
   SDA_DEBOUNCE : iic_debounce
      generic map (
         C_INERTIAL_DELAY => SDA_INERTIAL_DELAY,  
         C_DEFAULT        => '1')
      port map (
         Sysclk     => Sysclk,
         Rst        => Rst,
         Stable     => scl_unstable_n,  
         Unstable_n => open,

         Noisy      => Sda_noisy,   
         Clean      => Sda_clean);  

end architecture RTL;
