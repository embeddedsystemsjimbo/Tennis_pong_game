library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity paddle_algorithm is
    generic( 
            paddle_location_interval_start : integer; 
            paddle_location_interval_end : integer
            
    ); 
    Port ( i_clk : in STD_LOGIC;
           i_hcount : in integer;
           i_vcount : in integer; 
           i_button_up : in std_logic;
           i_button_down : in std_logic; 
           i_video_enable : in std_logic; 
           i_data : in std_logic_vector (30 downto 0); 
           o_active_paddle : out std_logic;
           o_paddle_position_top : out std_logic_vector(9 downto 0); 
           o_paddle_position_bottom : out std_logic_vector(9 downto 0);
           o_address : out std_logic_vector(5 downto 0);
           o_draw : out std_logic;
           o_draw_mirror : out std_logic
           );
end paddle_algorithm;

architecture Behavioral of paddle_algorithm is

constant Total_Bitmap_Columns: integer := 31; 
constant Total_Bitmap_Rows: integer := 29; 

constant Active_Columns : integer := 640;    --screen specifications  
constant Active_Rows : integer := 480;       

constant paddle_speed : integer := 125000;   --paddle specifications 
constant paddle_height : integer := 29; 

--signal draw: std_logic := '0'; 

signal paddle_counter_en : std_logic := '0'; 
signal paddle_count : integer range 0 to paddle_speed := 0; 
signal paddle_position : integer range 0 to (Active_Rows-paddle_height-1):= 0; 

signal bitmap_hcount: integer range 0 to (Total_Bitmap_Columns -1):= 0; 
signal bitmap_vcount: integer range 0 to (Total_Bitmap_Rows -1):= 0; 

begin


paddle_counter_en <= i_button_up xor i_button_down;     -- only accept one button press (from L or R ) at a time otherwise ignore


paddle_movement : process(i_clk) is
begin
    
    if rising_edge(i_clk) then
    
        if paddle_counter_en ='1' then                  --if a button is enable paddle counter
            if paddle_count = paddle_speed then         -- roll over paddle counter if req.
                paddle_count <= 0; 
            else
                paddle_count <= paddle_count + 1;       --increment counter
            end if;
        else
            paddle_count <= 0;                          -- if no buttons are pressed do nothing 
        end if; 
    
        
        if(i_button_up ='1' and paddle_count = paddle_speed) then               --move paddle up on counter period *if paddle is already at top position do not update
            
            if(paddle_position /= 0) then                                     
                paddle_position <= paddle_position-1;
            end if;
        
        elsif(i_button_down = '1' and paddle_count= paddle_speed) then          --move paddle down on counter period *if paddle is already at bottom position do not update
            
            if paddle_position /= (Active_Rows - paddle_height - 1) then 
                paddle_position <= paddle_position + 1; 
            end if;
        end if;
     end if;
     
end process paddle_movement; 

Paddle_Bitmap_Counter : process (i_hcount,i_vcount,paddle_position) is 

    begin
        
        if((i_hcount >= paddle_location_interval_start)                    -- if hcount and vcount is in the paddle location interval 
           and (i_hcount <= paddle_location_interval_end)
           and (i_vcount >= paddle_position) 
           and (i_vcount <= paddle_position + paddle_height)) then
                
                o_active_paddle <= '1';                                       -- flag active paddle L or R --> to which paddle address/data to sent/receive from ROM
                bitmap_hcount <= i_hcount-paddle_location_interval_start;     --sent current hcount and vcount to address ROM data --> starting from zero value size of rom bit-value (31 bits)
                bitmap_vcount <= i_vcount - paddle_position; 
        else
                bitmap_hcount <= 0;
                bitmap_vcount <= 0;
                o_active_paddle <= '0';    
        end if;
        
end Process Paddle_Bitmap_Counter; 


o_address <= std_logic_vector(to_unsigned(bitmap_vcount, o_address'length));               --vcount indexes bitamp row

o_draw <= i_data(bitmap_hcount);                                                           --hcount index bit position in ( 30 downto 0 ) i_data from tennis_racket_ROM
o_draw_mirror <= i_data(30 - bitmap_hcount);                                               --creates mirrored tennis racket bit position index reversal

o_paddle_position_top <= std_logic_vector(to_unsigned(paddle_position, o_paddle_position_top'length)); 
o_paddle_position_bottom <= std_logic_vector(to_unsigned(paddle_position + paddle_height, o_paddle_position_bottom'length)); 


end Behavioral;
