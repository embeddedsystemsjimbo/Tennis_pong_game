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

entity ball_controller is
    Port ( i_clk : in std_logic;
           i_hcount : in std_logic_vector (9 downto 0);
           i_vcount : in std_logic_vector (9 downto 0);
           i_game_running : in std_logic;
           o_draw_ball : out std_logic;
           i_paddle_position_R_top : in std_logic_vector (9 downto 0);
           i_paddle_position_R_bottom : in std_logic_vector (9 downto 0);
           i_paddle_R_threshold : in std_logic_vector (9 downto 0); 
           i_paddle_position_L_top : in std_logic_vector (9 downto 0);
           i_paddle_position_L_bottom : in std_logic_vector (9 downto 0);
           i_paddle_L_threshold : in std_logic_vector (9 downto 0);
           o_right_score_trigger : out std_logic;
           o_left_score_trigger : out std_logic
  );
end ball_controller;

architecture Behavioral of ball_controller is

constant Active_Columns : integer := 640;                       --screen specifications  
constant Active_Rows : integer := 480;     

constant ball_speed : integer := 125000; 

signal hcount : integer range 0 to 2**i_hcount'length := 0;              --Preempt range to simplify synthesis
signal vcount : integer range 0 to 2**i_vcount'length := 0;              --Convert vector to integer 

signal ball_count: integer range 0 to ball_speed := 0; 

signal ball_x1: integer range 0 to Active_Columns:= 0;                    --current x position
signal ball_y1: integer range 0 to Active_Rows := 0;                      --current y signal
signal ball_x2: integer range 0 to Active_Columns:= 0;                    --next x position
signal ball_y2: integer range 0 to Active_Rows := 0;                      --next y position

signal draw : std_logic := '0';                                           --intermediate draw variable 

signal direction_change_x : std_logic :='0';            -- direction change flag---required for ball direction change logic
signal direction_change_y : std_logic :='0';

signal paddle_position_L_top: integer range 0 to 2**i_paddle_position_L_top'length := 0; 
signal paddle_position_L_bottom: integer range 0 to 2**i_paddle_position_L_bottom'length := 0; 

signal paddle_position_R_top: integer range 0 to 2**i_paddle_position_R_top'length := 0; 
signal paddle_position_R_bottom: integer range 0 to 2**i_paddle_position_R_bottom'length := 0; 

signal paddle_L_threshold : integer range 0 to 2**i_paddle_L_threshold'length := 0;
signal paddle_R_threshold : integer range 0 to 2**i_paddle_R_threshold'length := 0;

signal ball_reset : std_logic :='0'; 

signal right_player_trigger : std_logic :='0'; 
signal left_player_trigger : std_logic :='0';

signal x_start_constant : integer := 1; 
signal y_start_constant : integer := 1; 

signal start_direction_counter : std_logic_vector ( 1 downto 0 ):= "00"; 

begin

paddle_position_L_top <= to_integer(unsigned(i_paddle_position_L_top));               --convert binary ball location in x & y pixel coordinates to integer 
paddle_position_L_bottom <= to_integer(unsigned(i_paddle_position_L_bottom));              
paddle_L_threshold <= to_integer(unsigned(i_paddle_L_threshold)); 

paddle_position_R_top <= to_integer(unsigned(i_paddle_position_R_top));               
paddle_position_R_bottom <= to_integer(unsigned(i_paddle_position_R_bottom));     
paddle_R_threshold <= to_integer(unsigned(i_paddle_R_threshold));  

hcount <= to_integer(unsigned(i_hcount));               --convert i_hcount to integer and assign to internal hcount
vcount <= to_integer(unsigned(i_vcount));               --convert i_vcount to interger and assign to internal vcount

ball_speed_timer : process (i_clk)

begin
    
    if rising_edge(i_clk) then
        
        if ball_count = ball_speed then             --internal counter slows movement of ball to resonable speed, otherwise would too hard for user to track in realtime
                
            ball_count <= 0;                        --reset ball counter
            
        else
            
            ball_count <= ball_count + 1;           --increment ball count timer
        end if;
    end if; 
end process ball_speed_timer; 

random_start_direction: process (i_clk, left_player_trigger, right_player_trigger, start_direction_counter)  --2 bit counter that determines ball initial conditions. 

begin 

    if rising_edge(i_clk) then

        if (left_player_trigger ='1' or right_player_trigger ='1' ) then
    
        start_direction_counter <= start_direction_counter + 1; 
        end if; 

    
        case start_direction_counter is
    
        when "00" =>
     
            x_start_constant <= 1; 
            y_start_constant <= -1; 
    
        when "01" =>
     
            x_start_constant <= -1; 
            y_start_constant <=  1; 
    
        when "10" =>
     
            x_start_constant <= -1; 
            y_start_constant <= -1; 
    
        when "11" =>
     
            x_start_constant <= 1; 
            y_start_constant <= 1; 
        end case; 
end if; 
end process random_start_direction; 

ball_movement : process (i_clk,i_game_running, x_start_constant, y_start_constant) is
    
    begin
    
       
    if rising_edge(i_clk) then
        
        if  ball_reset = '1' or i_game_running ='0' then
            
            ball_x2 <= (Active_Columns/2) + x_start_constant;                -- when game not active set ball in middle of screen
            ball_x1 <= (Active_Columns/2);
            
            ball_y2 <= (Active_Rows/2) + y_start_constant; 
            ball_y1 <= (Active_Rows/2);
            
            ball_reset <= '0';                                               --reset ball_reset flag ie ball goes past paddle we need to reset game. 
            right_player_trigger <= '0';
            left_player_trigger <= '0';   
        else
        
            
            if ball_count = ball_speed then                 -- keep track of ball movement
                
                --Since the x2 to x1 single unit ball position transfer is done each clock cycle, if the transfer isn't skipped
                --during direction change, x1 will always be given the value of x2 before direction evalation in lines 130-177
                --making the direction change checks invalid and causing game logic errors. 
---------------------------------------------------------------------------------------------------------------------- X and Y Increment             
                if direction_change_x ='0' then          -- skip movement trasfer during directions change to maintain valid direction checks below
                                                              
                    ball_x1 <= ball_x2;                  
                                                         
                else
                    
                    direction_change_x <='0';
                end if;
                
                if direction_change_y ='0' then           -- skip movement trasfer during directions change to maintain valid direction checks below
                    
                    ball_y1 <= ball_y2; 
                
                else   
                    
                    direction_change_y <='0';
                end if;
 ----------------------------------------------------------------------------------------------------------------------  X movement evaluation
        
                if ball_x1 < ball_x2 then                       -- ball moving to the right
                    
                    if ball_x2 = Active_Columns - 1 then        --reset game if ball goes past paddle
                       right_player_trigger <= '1';             -- set point scored flag
                       ball_reset <= '1';                       -- reset ball position to starting position 
                   end if; 
                    
                    if ball_x2 = paddle_R_threshold and ball_y2 < paddle_position_R_bottom and ball_y2 > paddle_position_R_top then                                            -- ball at right paddle 
                        
                            ball_x2 <= ball_x2 - 2;              -- bounce back ball in opposite direction 
                            direction_change_x <= '1';           -- set direction change flag 
                        
                    else
                
                        ball_x2 <= ball_x2 + 1;                 -- continue movement of ball to the right
                    end if; 
                
                
                elsif ball_x1 > ball_x2 then                    -- ball moving to the left
                    
                     if ball_x2 = 0 then                        -- reset game if ball goes past paddle
                        left_player_trigger <= '1';             -- set point scored flag 
                        ball_reset <= '1';                      -- reset ball position to starting position 
                     end if;       
                    
                     if ball_x2 = paddle_L_threshold and ball_y2 < paddle_position_L_bottom and ball_y2 > paddle_position_L_top then                         -- ball at left wall                    
                  
                            ball_x2 <= ball_x2 + 2;             -- bounce ball back opposite direction 
                            direction_change_x <= '1';          -- set direction change flag 
                      
                     else
                
                        ball_x2 <= ball_x2 - 1;                 -- bounce back ball in opposite direction 
                     end if;          
                end if;  
 ----------------------------------------------------------------------------------------------------------------------  Y movement evaluation 
                
       
                if ball_y1 < ball_y2 then                       -- ball moving down
                    
                    if ball_y2 = Active_Rows - 1 then           -- ball at bottom wall                    
                
                        ball_y2 <= ball_y2 - 2;                 -- bounce ball back opposite direction 
                        direction_change_y <= '1'; 
                        
                    else           
                        
                        ball_y2 <= ball_y2 + 1;                 --continue movement of ball down 
                    end if;
                
                  
                elsif ball_y1 > ball_y2 then                    -- ball moving up
            
                    if ball_y2 = 0  then                        -- ball at upwards wall 
                
                        ball_y2 <= ball_y2 + 2;                 -- bounce back ball in opposite direction 
                        direction_change_y <= '1';              -- set direction change flag  
                    
                    else
                
                        ball_y2 <= ball_y2 - 1;                 -- continue movement of ball up 
                    end if; 
                end if; 
                
            end if; 
        end if; 
    end if; 
end process ball_movement; 
                
draw_ball : process(i_clk) is                                   -- if ball position is equal to hcount and vcount then display ball
          
begin
    if rising_edge(i_clk) then
        
        if(( ball_x2 - 3 < hcount ) and (ball_x2 + 3  > hcount)
        and (ball_y2 - 3 < vcount ) and (ball_y2 + 3 > vcount)) then
        
            draw <= '1';
        
        else
            
            draw <= '0';      
        end if;
    end if;
    
end process draw_ball; 
                      
o_draw_ball <= draw;         
o_right_score_trigger <= right_player_trigger;
o_left_score_trigger <= left_player_trigger;           

end Behavioral;
