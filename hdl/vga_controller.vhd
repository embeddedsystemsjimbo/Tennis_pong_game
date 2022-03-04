library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_controller is
    Port ( i_clk : in std_logic; 
           i_draw_ball : in STD_LOGIC;
           i_video_enable : in std_logic; 
           i_draw_paddle_L : in std_logic;
           i_draw_paddle_R : in std_logic; 
           i_draw_court : in std_logic; 
           o_red : out STD_LOGIC_VECTOR (3 downto 0);
           o_green : out STD_LOGIC_VECTOR (3 downto 0);
           o_blue : out STD_LOGIC_VECTOR (3 downto 0)
           
           );
end vga_controller;

architecture Behavioral of vga_controller is

signal draw_select : std_logic_vector (4 downto 0) := "00000";
signal output : std_logic_vector (11 downto 0):="000000000000"; 

begin

draw_select <= i_video_enable & i_draw_ball & i_draw_paddle_L & i_draw_paddle_R & i_draw_court;  

output_display : process (draw_select, i_video_enable, i_draw_ball, i_draw_paddle_L,i_draw_paddle_R, i_draw_court) is

begin 

    case draw_select is
    
        when "11000" => output <= "111111110000";                    -- draw ball
        
        when "10100" => output <= "000000001111";                    -- draw paddle left
        
        when "10010" => output <= "011100001111";                    -- draw paddle right
            
        when "10000" => output <= "000001110000";                    -- draw background 
        
        when "10001" => output <= "111111111111";                    -- draw court lines
        
        when others => output <= "000000000000"; 
        
     end case; 

end process output_display;

o_red <= output(11 downto 8);
o_green <= output(7 downto 4);
o_blue <= output(3 downto 0);

end Behavioral;
