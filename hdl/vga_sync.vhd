library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_sync is
    Port ( i_clk : in STD_LOGIC;
           o_video_enable : out STD_LOGIC; 
           o_active_region_hcount : out std_logic_vector(9 downto 0);
           o_active_region_vcount : out std_logic_vector(9 downto 0);
           o_Hsync : out STD_LOGIC;
           o_Vsync : out STD_LOGIC);
end vga_sync;

architecture Behavioral of vga_sync is

--horizontal specifications
constant Total_Columns : integer := 800; 
constant H_Sync_Pulse : integer := 96;
constant Active_Columns : integer := 640;
constant Hfp : integer := 48;
constant Hbp : integer := 48;
 
--vertical specifications
constant Total_Rows : integer:= 525;
constant V_Sync_Pulse : integer := 2;
constant Active_Rows : integer := 480; 
constant Vfp : integer := 32;
constant Vbp : integer := 32;

signal hcount : integer range 0 to Total_Columns-1;
signal vcount : integer range 0 to Total_Rows-1; 

signal active_region_hcount : integer range 0 to Active_Columns-1;
signal active_region_vcount : integer range 0 to Active_Rows-1; 

signal H_front_porch : integer := 0; 
signal H_back_porch : integer := 0; 
signal V_front_porch : integer := 0; 
signal V_back_porch : integer := 0; 

begin

--determine accommodations for back porch and front porch for Horizontal and Vertical screen alignment offset

H_front_porch <=  H_Sync_Pulse + Hfp + Active_Columns; --96 + 48 + 640 =  784
H_back_porch <=  H_Sync_Pulse + Hbp; -- 96 + 48 = 144
V_front_porch <= V_Sync_Pulse + Vfp + Active_Rows; -- 2 + 33 + 480 = 515        2 + 32 + 480 = 514
V_back_porch <= V_Sync_Pulse + Vbp; -- 2 + 33 = 35                              2 + 32 = 34


horizontal_and_vertical_syncronization_counter : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if hcount = Total_Columns-1 then  --end of column reset column position count (hcount) to zero,  increment row count or reset row count otherwise increment column position count (hcount)
                
                hcount <= 0; 
            
                if vcount = Total_Rows-1 then   --end of row reset row position count (vcount) to zero otherwise increment row count ( vcount)
                    
                    vcount <= 0;
                
                else
                
                    vcount <= vcount + 1;       
                end if;
            
            else
                
                hcount <= hcount + 1; 
            end if;
         end if;
end process horizontal_and_vertical_syncronization_counter;
     

active_screen_region : process(i_clk)                
    
    begin
        if rising_edge(i_clk) then                                                                                                             -- Diagram 800H x 525V
            
            if hcount <= H_back_porch or hcount >= H_front_porch then       -- if hsync count is in active region output modified hcount       ------------------------------------ <  < Vsync 2 pixels
                                                                                                                                               --                                 . Vbp 32 lines 
                active_region_hcount <= 0;                                                                                                     --  .............................. . <                           
                                                                                                                                               --  .    640H x 480V             . .
            else                                                                                                                               --  .    Active Region           . .
                                                                                                                                               --  .                            . .
                active_region_hcount <= hcount - H_back_porch;                                                                                 --  .                            . .
                                                                                                                                               --  .............................. . <                       
            end if;                                                                                                                            --                                 .  vfp 32 lines 
                                                                                                                                               ------------------------------------ <
            if vcount <= V_back_porch or vcount >= V_front_porch then       -- if vsync count is in active region output modified vcount         ^ ^ Hbp 48 pixels              ^ ^ Hfp 48 pixels
                                                                                                                                             --^ ^Hsync 96 pixels
                active_region_vcount <= 0; 
            
            else
                
                active_region_vcount <= vcount - V_back_porch;     
            
            end if;
        end if; 

end process active_screen_region; 


--output Hsync and Vsync for valid area of screen
     
o_Video_enable <= '1' when ((hcount >= H_back_porch)                    --allows alignment adjustment for different monitors
                    and (hcount <= H_front_porch)                       --set enable flag if in active region of screen 
                    and (vcount >= V_back_porch) 
                    and (vcount <= V_front_porch)) else '0'; 

o_Hsync <= '0' when hcount < H_Sync_Pulse else '1';  --96 clocks         standard monitor spec. 
o_Vsync <= '0' when vcount < V_Sync_Pulse else '1';  -- 2 clocks

o_active_region_hcount <= std_logic_vector(to_unsigned(active_region_hcount, o_active_region_hcount'length)); 
o_active_region_vcount <= std_logic_vector(to_unsigned(active_region_vcount, o_active_region_vcount'length)); 

                                                                       
end Behavioral; 
     
     
     

            
                
                
                    
                    
                    
           
            
