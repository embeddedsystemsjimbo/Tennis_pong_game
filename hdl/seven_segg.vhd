library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_segg is
   Port ( i_clk : in std_logic; 
          i_right_score : in std_logic_vector ( 3 downto 0 );
          i_left_score : in std_logic_vector ( 3 downto 0 );
          o_LED : out std_logic_vector ( 6 downto 0 ); 
          o_anode_activate: out std_logic_vector ( 3 downto 0)

);
end seven_segg;

architecture Behavioral of seven_segg is

signal LED_activation_counter : std_logic_vector (1 downto 0);
signal LED_pattern_BCD : std_logic_vector (3 downto 0); 
signal refresh_counter: std_logic_vector (18 downto 0); 

begin

seven_segment_refresh : process (i_clk)

    begin
    
    if rising_edge(i_clk) then
    
        refresh_counter <= refresh_counter + 1;                 -- increment LED counter 
    
    end if; 

end process seven_segment_refresh;

LED_activation_counter <= refresh_counter (18 downto 17);      --@ 60mHz we required 150 000 clock cycles for 2.5ms refresh period per 7segg LED 

seven_segment_pattern : process(LED_pattern_BCD)

begin
         
    case LED_pattern_BCD is
    
    when "0000" => o_LED <= "0000001"; -- "0"     --note low active 
    when "0001" => o_LED <= "1001111"; -- "1" 
    when "0010" => o_LED <= "0010010"; -- "2" 
    when "0011" => o_LED <= "0000110"; -- "3" 
    when "0100" => o_LED <= "1001100"; -- "4" 
    when "0101" => o_LED <= "0100100"; -- "5" 
    when "0110" => o_LED <= "0100000"; -- "6" 
    when "0111" => o_LED <= "0001111"; -- "7" 
    when "1000" => o_LED <= "0000000"; -- "8"     
    when "1001" => o_LED <= "0000100"; -- "9" 
    when "1111" => o_LED <= "1111111"; -- "off" 
    when others => o_LED <= "0000001"; -- "0"  
    end case;
    
end process seven_segment_pattern;

seven_segment_selection : process (LED_activation_counter, i_left_score, i_right_score)

    begin
    
    case LED_activation_counter is
    
    when "00" =>
    
        o_anode_activate<= "0111";           -- low active 
                                             -- activate LED1 and Deactivate LED2, LED3, LED4
        LED_pattern_BCD <= i_left_score;
                                            
    when "01" =>
    
        o_anode_activate<= "1011"; 
                                             -- activate LED2 and Deactivate LED1, LED3, LED4
        LED_pattern_BCD<= "1111";            -- hard code off
        
    when "10" =>
    
        o_anode_activate<= "1101"; 
                                             -- activate LED3 and Deactivate LED2, LED1, LED4
        LED_pattern_BCD<= "1111";            -- hard code off
        
    when "11" =>
    
        o_anode_activate<= "1110";           -- low active 
                                             -- activate LED4 and Deactivate LED2, LED3, LED1
        LED_pattern_BCD<= i_right_score;   
    end case;
    
end process seven_segment_selection;
    
end Behavioral;
