# ecma6-forth
Low level forth like language for experimenting with animation and graphics

# useage
Open up index.html file in web browser, must support ecmascript-6

Drag demo.fth to text window on left and hit compile button

In text input field below text box on the left can input commands to be executed just type and press enter 

D# 0 D# 0 AT D# 100 D# 100 TO LINE DRAW 

red BG CLEAR

green FG D# 10 RADIUS CIRCLE DRAW

all

D# 40 D# 40 CURSOR_AT test 

# strings

S" word will take the remaining line and copy it into the vm leaving count and memory location on top of the stack, example below

S" Hello World

TYPE SPACE DRAW 
