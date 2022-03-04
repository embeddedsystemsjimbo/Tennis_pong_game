library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clockdivider is
    Port ( input_clk : in STD_LOGIC;     -- 60hz refresh rate required 25mhz clock   --> 60 screen refreshes / s X 800 H. pixels x 525 V. pixels = 25200000 clocks cycles. 
           clr : in STD_LOGIC;
           o_clk25 : out STD_LOGIC);
        

end clockdivider;

architecture Behavioral of clockdivider is

signal q : std_logic_vector(3 downto 0); --total 4bit value allows clock division down to 12.5mhz (100mhz input clk) 

begin 

process(input_clk,clr)
begin
    if clr = '1' then
        q <= "0000";
    elsif rising_edge(input_clk) then
        q <= q + 1;
    end if;
 end process; 

--clk50 <=q(0) because the 1st bit position toggles between two values 0 to 1 when incremented resulting in a half clock output vs input. 
--clk25 <=q(1) because to toggle the 2nd bit position we must first toggle the 1st bit position. This results in a quarter clock output vs input.
--clk12.5 <=q(2) because to toggle the 3rd bit position we need toggle both the 1st and 2nd bit positions. This results in an eighth clock output vs input.  
--clk6.25mhz <=q(3) "   "

o_clk25 <= q(1);       --25mhz   


end Behavioral; 

