library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 



entity debouncer is     
    Port ( i_clk : in  std_logic;
           i_button : in  std_logic ;
           o_button : out  std_logic
           );
end debouncer;


architecture Behavioral of debouncer is


constant debounce_counter_max : integer := 65536; 

signal debounce_counter : integer := 0; 

signal button : std_logic := '0'; 

begin


debounce_counter_algorithm : process (i_clk)
begin
    if (rising_edge(i_clk)) then
    
    
        if (button xor i_button) = '1' then                           --if the value differs between the current button position and the last button position do the following still occuring 
            
              if (debounce_counter = debounce_counter_max) then                   
                     debounce_counter <= 0;                           -- button value is still oscillation therefore reset counter and run counter until otherwise
              else
                    debounce_counter <= debounce_counter + 1;         -- button value is oscillating  therefore increment counter  and wait for button value to stabalize 
              end if;
        else
            debounce_counter <= 0;                                    --button value is stable reset counter to zero 
        end if;
        

    end if;
end process debounce_counter_algorithm;


debounce_toggle_algorithm : process (i_clk)   
begin
   if (rising_edge(i_clk)) then
   
      if (debounce_counter = debounce_counter_max) then                   -- when counter reaches MAX value toggle button value. 
         button <= not(button);                                           --toggle button position 
      end if;                                            
   
   end if;
end process debounce_toggle_algorithm;  

o_button <= button;                                                       --output button value----takes min. one counter period to output button value. 

end Behavioral;