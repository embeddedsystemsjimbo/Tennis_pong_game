library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity paddle_controller is
    Port ( i_clk : in STD_LOGIC;
           i_hcount : in std_logic_vector (9 downto 0);
           i_vcount : in std_logic_vector (9 downto 0); 
           i_button_up_left : in std_logic;
           i_button_down_left : in std_logic;
           i_button_up_right : in std_logic;
           i_button_down_right : in std_logic;
           i_video_enable : in std_logic; 
           i_data : in std_logic_vector (30 downto 0); 
           o_enable_ROM : out std_logic; 
           o_paddle_position_L_top : out std_logic_vector (9 downto 0);
           o_paddle_position_L_bottom : out std_logic_vector (9 downto 0);
           o_paddle_L_threshold : out std_logic_vector (9 downto 0);
           o_paddle_position_R_top : out std_logic_vector (9 downto 0);
           o_paddle_position_R_bottom : out std_logic_vector (9 downto 0);
           o_paddle_R_threshold : out std_logic_vector (9 downto 0);
           o_draw_paddle_L : out std_logic;
           o_draw_paddle_R : out std_logic; 
           --o_active_paddle_L : out std_logic;
           --o_active_paddle_R : out std_logic; 
           o_address : out std_logic_vector (5 downto 0)
           --bitmap_hcount_L : out integer;
           --bitmap_vcount_L : out integer;
           --bitmap_hcount_R : out integer;
           --bitmap_vcount_R : out integer
           );

end paddle_controller;

architecture Behavioral of paddle_controller is

constant Active_Columns : integer := 640;    --screen specifications  
constant Active_Rows : integer := 480; 

constant left_player_paddle_location_start : integer := 0;                      -- paddle dimensions on the horizontal plane ie. pixel thickness
constant left_player_paddle_location_end : integer := 30; 
constant right_player_paddle_location_start : integer := Active_Columns - 30 - 1; --609
constant right_player_paddle_location_end : integer := Active_Columns - 1;   -- 639

signal button_up_left :std_logic := '0'; 
signal button_down_left :std_logic := '0'; 
signal button_up_right :std_logic := '0'; 
signal button_down_right :std_logic := '0'; 

signal hcount : integer range 0 to 2**i_hcount'length := 0;                            -- Preempt range to simplify synthesis
signal vcount : integer range 0 to 2**i_vcount'length := 0;                            -- convert vector to integer 

signal address_L : std_logic_vector (5 downto 0) :="000000";  
signal address_R : std_logic_vector (5 downto 0) :="000000";  

signal active_paddle_L : std_logic :='0'; 
signal active_paddle_R : std_logic :='0'; 

signal draw_paddle_L : std_logic := '0'; 
signal draw_paddle_mirror_L :std_logic := '0'; 

signal draw_paddle_R :std_logic := '0'; 
signal draw_paddle_mirror_R :std_logic := '0'; 

begin

button_up_left <= i_button_up_left;                  --2        --assign joystick buttons in correct orientation 
button_down_left <= i_button_down_left;              --4
button_up_right <= i_button_up_right;                --1
button_down_right <= i_button_down_right;            --3

-- horizontal threshold where the ball needs to pass to score a point, this is the inner position of the left and right paddle, ie towards centre of screen.
o_paddle_L_threshold <= std_logic_vector(to_unsigned(left_player_paddle_location_end, o_paddle_L_threshold'length)); 
o_paddle_R_threshold <= std_logic_vector(to_unsigned(right_player_paddle_location_start, o_paddle_R_threshold'length)); 

hcount <= to_integer(unsigned(i_hcount));               --convert i_hcount to integer and assign to internal hcount
vcount <= to_integer(unsigned(i_vcount));               --convert i_vcount to interger and assign to internal vcount


paddle_left_instance : entity work.paddle_algorithm
    generic map (
     paddle_location_interval_start => left_player_paddle_location_start,
     paddle_location_interval_end => left_player_paddle_location_end

     )
     port map(
           i_clk => i_clk,
           i_hcount => hcount, 
           i_vcount => vcount, 
           i_button_up => button_up_left, 
           i_button_down => button_down_left,
           i_video_enable => i_video_enable,
           i_data => i_data,
           o_active_paddle=> active_paddle_L,
           o_paddle_position_top => o_paddle_position_L_top,
           o_paddle_position_bottom => o_paddle_position_L_bottom,
           o_address => address_L,
           o_draw => draw_paddle_L,
           o_draw_mirror => draw_paddle_mirror_L 
           ); 
     
paddle_right_instance : entity work.paddle_algorithm
    generic map (
     paddle_location_interval_start => right_player_paddle_location_start,
     paddle_location_interval_end => right_player_paddle_location_end
   
     )
     port map(
           i_clk => i_clk,
           i_hcount => hcount, 
           i_vcount => vcount, 
           i_button_up => button_up_right, 
           i_button_down => button_down_right,
           i_video_enable => i_video_enable,
           i_data => i_data,
           o_active_paddle=> active_paddle_R,
           o_paddle_position_top => o_paddle_position_R_top,
           o_paddle_position_bottom => o_paddle_position_R_bottom,
           o_address => address_R,
           o_draw => draw_paddle_R,
           o_draw_mirror => draw_paddle_mirror_R 
           ); 

ROM_selection : process(i_clk,active_paddle_L, active_paddle_R,address_L ,address_R)

    begin
    
    if rising_edge(i_clk) then
        
        if (active_paddle_L ='1') then 
 
            o_address <= address_L;
            o_enable_ROM <= '1'; 
        
        elsif (active_paddle_R ='1') then 
           
            o_address <= address_R; 
            o_enable_ROM <= '1'; 
        
        else
            o_address <= "000000";
            o_enable_ROM <= '0'; 
        end if; 
    end if; 
   
end process ROM_selection; 

o_draw_paddle_L <= draw_paddle_L;
o_draw_paddle_R <= draw_paddle_mirror_R;


end Behavioral;
