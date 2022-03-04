library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tennis_court_algorithm is
    Port ( i_clk : in STD_LOGIC;
           i_hcount : in std_logic_vector (9 downto 0);
           i_vcount : in std_logic_vector (9 downto 0);
           o_draw_court : out STD_LOGIC
           );
end tennis_court_algorithm;

architecture Behavioral of tennis_court_algorithm is

constant Active_Columns : integer := 640;    --screen specifications  
constant Active_Rows : integer := 480;     

constant left_line: integer := 40;
constant inner_left_line: integer := 180;
constant inner_right_line: integer := 460; 
constant right_line: integer := 600;

constant top_line:integer := 40;
constant bottom_line: integer := 440;
constant inner_top_line: integer := 80;
constant inner_bottom_line: integer := 400;

constant center_line_vertical: integer := 320;
constant center_line_horizontal: integer := 240; 
constant line_thickness: integer := 5; 

signal hcount : integer range 0 to 2**i_hcount'length := 0;             -- Preempt range to simplify synthesis
signal vcount : integer range 0 to 2**i_vcount'length := 0;             -- Convert vector to integer 
 
signal draw : std_logic := '0'; 

begin

hcount <= to_integer(unsigned(i_hcount));               --convert i_hcount to integer and assign to internal hcount
vcount <= to_integer(unsigned(i_vcount));               --convert i_vcount to interger and assign to internal vcount
                   
draw_court : process(i_clk) is                          --draw tennis court within parameters 
          
begin
    if rising_edge(i_clk) then
        
        if(
        (((hcount > left_line) and (hcount < left_line + line_thickness) and (vcount > top_line) and (vcount < bottom_line)) or ((hcount > right_line - line_thickness) and (hcount < right_line) and (vcount > top_line) and (vcount < bottom_line)))  --vertical line
        or (((vcount > top_line) and (vcount < top_line + line_thickness) and (hcount > left_line) and (hcount < right_line)) or ((vcount > bottom_line - line_thickness) and (vcount < bottom_line) and (hcount > left_line) and (hcount < right_line)))  -- horizontal 
        or ((hcount > center_line_vertical - line_thickness) and (hcount < center_line_vertical + line_thickness)) -- net vertical center 
        or ((vcount > center_line_horizontal - line_thickness/2) and (vcount < center_line_horizontal + line_thickness/2) and (hcount > inner_left_line) and (hcount < inner_right_line )) -- horizontal center
        or (((hcount > inner_left_line) and (hcount < inner_left_line + line_thickness) and (vcount > inner_top_line) and (vcount < inner_bottom_line)) or ((hcount > inner_right_line- line_thickness) and (hcount < inner_right_line) and (vcount > inner_top_line) and (vcount < inner_bottom_line))) --inner vertical 
        or (((vcount > inner_top_line) and (vcount < inner_top_line + line_thickness) and (hcount > left_line) and (hcount < right_line)) or ((vcount > inner_bottom_line - line_thickness) and (vcount < inner_bottom_line) and (hcount > left_line) and (hcount < right_line))) --inner horizontal 
        ) then
       
            draw <= '1';
        
        else
            
            draw <= '0';      
        end if;
    end if;
    
end process draw_court; 
                      
o_draw_court <= draw;                                  

end Behavioral;
