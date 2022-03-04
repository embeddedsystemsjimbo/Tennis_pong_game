library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Pong_controller is
    Port ( i_clk : in STD_LOGIC;  
           i_game_start : in std_logic;
           i_right_score_trigger: in std_logic;
           i_left_score_trigger: in std_logic;
           o_game_running : out std_logic;
           o_right_score : out std_logic_vector (3 downto 0);
           o_left_score : out std_logic_vector (3 downto 0)
           );
end Pong_controller;

architecture Behavioral of Pong_controller is

signal Score_Max: integer := 9; 
signal P1_score : integer := 0;
signal P2_score : integer := 0; 

type Pong_SM is ( idle,running, p1_win, p2_win);             --create game state machine
signal var_Pong_SM : Pong_SM:= idle;                         --initial state "idle"

begin

Pong_Game_SM : process(i_clk,i_game_start, i_left_score_trigger, i_right_score_trigger) is
    
    begin
    
        if rising_edge(i_clk) then
    
            case var_Pong_SM is
    
            when idle =>
        
            if (i_game_start = '1') then
                var_Pong_SM <= running;
            end if; 
    
            when running => 
                                                                                                  -----------------------player1
                if (i_left_score_trigger = '1') then
            
                    var_Pong_SM <= P1_win;
              
                                                                                                  -----------------------player2
                elsif (i_right_score_trigger = '1') then 
                
                    var_Pong_SM <= P2_win; 
                end if; 
              
        
            when P1_win =>
             
                if( P1_score = Score_Max) then
                    
                    P1_score <= 0;
                    P2_score <= 0;
                else
                    
                    P1_score <= P1_score + 1; 
                end if;
             
                var_Pong_SM <= idle; 
        
            when p2_win=> 
             
                if( P2_score = Score_Max) then
                    
                    P2_score <= 0;
                    P1_score <= 0;
                else
                    
                    P2_score <= P2_score + 1; 
                end if;
             
                var_Pong_SM <= idle; 
                
            when others =>
             
                var_Pong_SM <= idle; 

            end case; 
        end if; 
    
    end process Pong_game_SM; 
    
o_game_running <= '1' when var_Pong_SM = running else '0';
o_left_score <= std_logic_vector(to_unsigned(P1_score, o_left_score'length)); 
o_right_score <= std_logic_vector(to_unsigned(P2_score, o_right_score'length)); 
      
end Behavioral;
