library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tennis_racket_ROM is
    Port ( 
            i_clk : in std_logic;
            i_enable: in std_logic;  
            i_address : in STD_LOGIC_VECTOR (5 downto 0);
            o_data : out STD_LOGIC_VECTOR (30 downto 0)
          );
end tennis_racket_ROM;

architecture Behavioral of tennis_racket_ROM is

 type rom_type is array ( 0 to 28 ) of std_logic_vector(30 downto 0);
 
 constant my_Rom : rom_type := 
 (
    
    "0000011111110000000000000000000", -- 31 bits wide , 29 rows tall 
    "0000111000111100000000000000000",
    "0001101100101110000000000000000",
    "0011010011001011000000000000000",
    "0110110011001101100000000000000",
    "0111001100110011100000000000000",
    "0101001100110010110000000000000",
    "0100110011001100010000000000000",
    "0100110011001100011000000000000",
    "0101001100110011011000000000000",
    "0110001100110011001000000000000",
    "0010110011001100101000000000000",
    "0011010011001100101000000000000",
    "0001101100110011001100000000000",
    "0000110100110011011100000000000",
    "0000011100001100111100000000000",
    "0000001111000001110110000000000",
    "0000000011111111100110000000000",
    "0000000000000111110011000000000",
    "0000000000000000011111000000000",
    "0000000000000000000111110000000",
    "0000000000000000000011111000000",
    "0000000000000000000001111100000",
    "0000000000000000000000111110000", 
    "0000000000000000000000011111000", 
    "0000000000000000000000001111100", 
    "0000000000000000000000000111110", 
    "0000000000000000000000000011110", 
    "0000000000000000000000000001110" 
    
    );


begin

ROM : process(i_clk, i_address, i_enable) is

    begin
    
    if( rising_edge(i_clk) and i_enable ='1') then
    
    o_data <= my_Rom(to_integer(unsigned(i_address)));          
        
    end if; 
    


end process ROM; 




end Behavioral;
