# Tennis_pong_game

Tested on Vivado 2021.1.1

Run from TCL command line from project root using command "source pong_game.tcl" to build project. 

***

This is a small "Pong" inspired tennis game I created based on a university project from my Digital System Engineering course. The game is displayed at 640x480/60Hz through VGA. The joypad buttons controls both left and right tennis paddles. The seven segment display shows the score of each player from 0-9. 

Designed and implemented using Xilinx Vivado w/ ModelSim using VHDL on a Diligent Basys3 development board (Artix7 FPGA). 

See a short video below: 

https://youtu.be/wwBXQ-vbp3Y


![IMG_0402 2](https://user-images.githubusercontent.com/76194492/156704739-a12dec2b-15c3-4d72-96e1-3c0bbe50a797.jpg)


***

## Introduction ## 

We take for granted that video games are pieces of software written to run on a variety of microprocessors found in home computers, game consoles or handheld devices. However, in the not-so-distant past, before the creation of the microprocessor, video games existed as purely discrete combinational circuits. This project hopes to recreate the experience these early video game designer may have experienced creating video game not with software, but with circuits. With the use of modern FPGA tools such as Xilinx Vivado and the Digilent Basys-3 FPGA development board featuring the Artix-7 FPGA chipset, this project will recreate the famous “Pong Game” first released in 1972 by the famous Atari Corporation. The original “Pong” game consisted of two paddles that players use to volley a ball back and forth across the screen. This Tennis themed take on “Pong”, will add a colorful tennis court background in addition to swapping out the rectangular paddles from some “bitmap” based tennis racket sprites. Furthermore, the score of the game will be displayed on a seven-segment-display as opposed to a counter at the top of the screen for simplicity sakes (See Figure 1). Through the creation of this game the topics of VGA implementation, FPGA I/O interfacing and practical experience implementing high performance signal generators on-chip with custom logics circuits will be explored. 

***

## Specifications ##

1) 640x480 resolution output through VGA.
2) 60hz screen fresh rate.
3) Two horizontal movement user-controlled paddles.
4) One ball with horizontal and vertical movement.
5) Score keeping mechanism. 

***

## Block Diagram ##

<img width="1591" alt="image" src="https://user-images.githubusercontent.com/76194492/165985842-dc74f3a9-1dd6-47e6-94f3-06dab5c7fb5f.png">

Figure 1: Tennis themed “Pong” game block design. 

***

## Theory, Design, and Implementation ##

![image](https://user-images.githubusercontent.com/76194492/165983539-a6e2bca5-0801-4ecb-9ac9-522801d1e281.png)

Figure 2: Paddle Controller / *Paddle Algorithm (See paddle_controller.vhd and paddle algorithm.vhd for details)

The Paddle Controller module (See Figure 2) receives button press inputs from the user and updates the horizontal paddle position based on a counter mechanism. This serves several purposes in the game, the most import being the paddle to ball interaction. Consequently, paddle position is relayed to the Ball Controller module which controls the point scoring mechanism in the game and will be elaborated in the Ball Controller description. The Paddle Controller also references Bitmap data stored in the ROM module pertaining to the tennis racket sprite to display on screen. Hence, based on the horizontal and vertical counter computed in the VGA sync module, this module indicates to the VGA controller module via a draw command when to display the tennis racket pixels on screen. Another function of this module is providing a mechanism to control paddle movement speed. This is accomplished by only periodically updating the position of the paddle through use a counter mechanism when the user presses a button. This limits the amount of movement from a maximum of every clock cycle to a multiple of clock cycles slowing the paddle movement speed.  This is done to increase or decrease the difficulty of the game. 

***

![image](https://user-images.githubusercontent.com/76194492/165983930-8b36a9ab-3baa-4303-8b07-d1592c75dc91.png)

Figure 3: Clock Divider (See clockdivider.vhd for details) 

The Xilinx Artix-7 chipset as implemented by Diligent on the Basys-3 board features a 100Mhz crystal oscillator. Per the game specification, the image refresh rate is 60hz and consequently to obtain a lower clock speed, without the use of Xilinx IP, a clock divider is implemented to cut down the 100Mhz default clock to 25Mhz (See Figure 3). This is accomplished using a binary counter, and outputting when the second bit position goes HIGH. This effectively divides the input clock by four since it requires four clock cycles to toggle the second bit. The 25Mhz output clock corresponds to the 60hz refresh rate because the game outputs 1 pixel per clock cycle and with 25200000 pixels (800x525x60) which is equivalent to 252000000 Hz or 25Mhz clock cycles is required. 

***

![image](https://user-images.githubusercontent.com/76194492/165984040-9cb94cb9-baea-480b-a4db-46df9870527e.png)

Figure 4: Button Debouncer (See debounce.vhd for details).

The purpose of the Button Debouncer module (See Figure 4) is to determine the current position of the four buttons used to increment the position of the paddles. Since these buttons are momentary in behavior, the input logic value of the button can oscillate erratically upon a user pressing or releasing the button. Consequently, this may communicate false button activations to the game. To remedy this problem, the Button Debouncer module determines the position of the button by only toggling the position of the button after a certain time has passed where the switch value remains constant, otherwise the button press is ignored. This is accomplished with use of counter mechanism that is continuously reset until the button value determined by an XOR gate between two consecutive timer periods is false. 

***

![image](https://user-images.githubusercontent.com/76194492/165984140-c0b0e9fe-e8f6-4d17-8a04-f0f374f399d4.png)

Figure 5: Ball Controller (See ball_controller.vhd for details)

The Ball Controller (See Figure 5) is the most complex module and performs several functions within the game. Ball movement is implemented by incrementing and decrementing a series of four counters on the clock which determine the current and previous ball pixel locations in the active regions of the screen both horizontally and vertically. The mechanism of tracking current and previous ball pixel location allows the determination of direction by considering that if the location corresponding to the horizontal or vertical position of the pixel is increasing in comparison to the previous value, then the ball must be moving to the right of the screen in the horizontal plane or down in the vertical plane. Similarly, if the location corresponding to the horizontal or vertical position of the pixel is decreasing in comparison to the previous pixel location, then the ball must be moving to the left of the screen in the horizontal plane or up in the vertical plane. This is because we map pixel location incrementing from left to right and from top to bottom as descripted in the VGA sync module per VGA protocol. Since, horizontal and vertical counters work independently, a combination of the above scenarios can occur. Consequently, when a wall or paddle is reached, the value of the current location is decremented or incremented with large offset count that inverts the relationship between current and previous pixel location values effectively changing the direction of the ball and allowing the ball to display bouncing movement behavior. Additionally, the Ball Controller establishes the speed at which the balls can move, by implementing a counter that only updates the ball movement counters after a period has passed. This is done to increase or decrease the difficulty of the game. The Paddle Controller also determines when a player achieves a point, by determining when the ball passes a vertical threshold behind the losing paddle and communicates this to the Pong module to keep game score. Furthermore, this module indicates to the VGA module through draw commands when to output ball pixels on screen.  

***

![image](https://user-images.githubusercontent.com/76194492/165984214-99857955-0300-4d26-9105-ecf94845e6a6.png)

Figure 6: Pong Controller (See Pong_controller.vhd for details)

The Pong Controller module (See Figure 6) uses a finite state machine to control the operation of the game. The module takes input from the user to either run or reset the game. Additionally, this module receives point declarations from the Ball Controller to maintain a game score. The numeric value of the score is communicated to the Seven Segment module, which output the score on the display unit found on the Diligent Basys-3 board.  

***

![image](https://user-images.githubusercontent.com/76194492/165984276-6dff176a-3351-4595-ad3f-753989806984.png)

Figure 7: VGA sync (See vga_sync.vhd for details)

The VGA sync module (See Figure 7) serves several purposes. The first function it serves is to implement two primary counters that keep track of both the total horizontal and vertical pixel count. As per the VGA protocol the monitor outputs one pixel at a time at a rate of 2520000 pixels/second moving from left to right and from top to bottom across the screen. This requires a mechanism between the monitor and the game to “start a new row” and to “start a new screen”. The protocol standard states that the “start new row” command is communicated with a 96-clock LOW pulse (H-sync) and the “start new screen” is communicated with a 2-clock LOW pulse (V-sync). To output at 640x480 resolution as per the specification of the game, an 800x525 pixel dimension is required, where the reasons for this will be elaborated later. When displaying a new image on the monitor, the H-sync and V-sync are toggled LOW for 96-clocks and 2-clocks respectively indicating a new image is to be displayed on the monitor beginning at pixel location 0x0. Subsequently, after 800 horizontal pixels have been displayed from pixel location 0x0 to 0x799, there is a 96-clock blanking period (LOW pulse) indicating to output to the next row. The process repeats 525 row iterations, when the end of the screen is reached at pixel location 524x799. At this moment, the is a 2-clock blanking period indicating to reset to pixel location 0x0 and begin displaying the next screen image and the cycle repeats. It was mentioned above that the game features an 800x525 pixel dimension to display a 640x480 resolution image. These extra pixels provide the ability to adjust the 640x480 active viewing region in the 800x525 pixel area to accommodate monitor variations. There exist four offsets that can correct the horizontal and vertical position of the viewing region, known as the horizontal front porch, horizontal back porch, vertical front porch and vertical back porch. Therefore, the second function of the VGA Sync module is to provide two additional counters to track the horizontal and vertical pixel position in the active viewing region separate from the total horizontal and vertical syncing pixel counts, where the image content pertaining to the game are displayed. These offsets are additional LOW pulses added to the active region counter that delay or advance the start point of the active region both horizontally and vertically which help reposition the image being displayed on the screen (See Figure 8). It should be noted that these delays or advances must also take into consideration the 96-clock horizontal and 2-clock vertical blanking periods to maintain row and column synchronization. Furthermore, it is also these secondary counters than enable the tennis game to keep reference the position of the tennis ball, paddle, court, and field in the game.

![image](https://user-images.githubusercontent.com/76194492/165984344-713707f6-ef8c-4125-832c-fefc0e034405.png)

Figure 8: Four adjustment areas for active screen region. 

***

![image](https://user-images.githubusercontent.com/76194492/165984414-f4c42cab-ef5d-4b6d-8659-f7acbe95acff.png)

Figure 9: VGA controller

The Diligent Basys-3 is capable of 12bit RGB color output through the onboard VGA connection. 
The VGA controller module (See Figure 9) takes draw commands from the Ball Controller, Paddle Controller and Tennis Court Algorithm Controller and output the commands in the appropriate color for each component on screen. This is accomplished through a multiplexer mechanism. 

***

![image](https://user-images.githubusercontent.com/76194492/165984502-7d2422e1-b6d9-4b38-a446-31c0aedf3258.png)

Figure 10: Tennis Racket ROM

The Tennis Racket ROM module (See Figure 10) stores the 2D representation of a tennis racket paddle. This tennis racket exists as a 31 column wide and 29 row bitwise image where HIGH bit values depict the outline of the tennis racket image. Individual rows are addressable and consequently are forwarded to the Paddle Controller module, where they are output as draw commands to the VGA Controller module to display on screen at the appropriate pixel location. This pseudo-ROM is implemented as an array. 

***

![image](https://user-images.githubusercontent.com/76194492/165984582-0c3a3b0d-7e36-42a2-9cd7-f4576928fd61.png)

Figure 11: Tennis Court Algorithm (See tennis_court_algorithm.vhd for details)

The Tennis Course Algorithm module (See Figure 11) computes the location of the tennis court lines based of the horizontal and vertical counters computed in the VGA sync module. Subsequently, this module indicates to the VGA module through draw commands the appropriate pixel location to display the court lines on screen. This module is implemented as a multiplexer. 

***

![image](https://user-images.githubusercontent.com/76194492/165984651-d314c59c-4a4f-492f-af9d-b1dd3f549315.png)

Figure 12: Seven Segment (See seven_segg.vhd for details)

The seven-segment module (See Figure 12)takes the current game score output from the Pong Controller module and display it on two of the four seven segment display units found the on the Diligent Basys-3 board. Since the data bus is shared between each of the four seven segment units, the activation of the seven-segment unit must be strobed at approximately a 10ms refresh rate to output values to each of the individual seven segment unit in the four-unit module. Achieving the desired 10ms total LED activation period (as per Diligent specifications) at the game’s 25Mhz clock frequency requires a 17bit total length binary counter (See Figure 13) where the 16th and 17th bit toggle activation of the four individual seven-segment units. This module is implemented as a multiplexer. 

![image](https://user-images.githubusercontent.com/76194492/165984751-e164fde1-b174-4142-96fa-b7332e54dd0b.png)

Figure 13: Determining Seven Segment LED refresh rate. 













