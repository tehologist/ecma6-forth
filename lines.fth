create @             D#  4 primitive 
create !             D#  5 primitive 
create +             D#  6 primitive 
create -             D#  7 primitive 
create *             D#  8 primitive 
create &             D# 11 primitive 
create |             D# 12 primitive 
create ~             D# 13 primitive 
create dup           D# 14 primitive 
create drop          D# 15 primitive 
create swap          D# 16 primitive 
create over          D# 17 primitive 
create >             D# 22 primitive 
create =             D# 23 primitive 
create <             D# 24 primitive 
create jz            D# 20 primitive
create jmp           D# 21 primitive 
create >r            D# 18 primitive
create r>            D# 19 primitive 
create return        D#  3 primitive 
create lit           D#  1 primitive
create put_pixel     D# 26 primitive
create draw_screen   D# 27 primitive

: cp D# 3 ; // This is the location in memory of the code pointer 
: here cp @ ; 
: +! over @ + swap ! ;  
: ++ D# 1 +! ; 
: , here ! cp ++ ; 
: 0, D# 0 , ; 
: 2* dup + ; 
: 1+ D# 1 + ; 
: compile r> 1+ dup @ , >r ; 

: if compile jz here 0, ;                     immediate
: else compile jmp here 0, swap here swap ! ; immediate
: then here swap ! ;                          immediate 
: begin here ;                                immediate 
: until compile jz , ;                        immediate 

: 2dup over over ; 
: rot swap >r swap r> ;
: >= 2dup > >r = r> | ; 
: <= 2dup < >r = r> | ; 

: negate ~ 1+ ; 
: abs dup D# 0 < if negate then ; 

: screen_x D# 640 ;
: screen_y D# 480 ;

: screen_location screen_x * + ;

: black H# 000000 ; 
: white H# FFFFFF ;  

create color white , 
create background black , 
: FG color ! ; 
: BG background ! ; 

// Plot pixel ( location | ) 
: plot_pixel color @ swap put_pixel ; 

: CLEAR 
    D# 0 begin 
        background @ over put_pixel 1+ dup 
        screen_x screen_y * = 
    until drop draw_screen ; 
CLEAR

create x0 0, 
create y0 0,
: AT y0 ! x0 ! ; 

create x1 0, 
create y1 0, 
: TO y1 ! x1 ! ; 

create dx  0, 
create dy  0, 
create err 0, 
create sx  0, 
create sy  0, 
: init_line 
    x0 @ x1 @ < if D# 1 else D# -1 then sx ! 
    y0 @ y1 @ < if D# 1 else D# -1 then sy ! 
    x1 @ x0 @ - abs dup dx ! 
    y1 @ y0 @ - abs negate dup dy !  
    + err ! ;

: update_x0 dy @ >= if err dy @ +! x0 sx @ +! then ; 
: update_y0 dx @ <= if err dx @ +! y0 sy @ +! then ;  

: LINE
    init_line  
    begin 
        x0 @ y0 @ screen_location plot_pixel 
        err @ 2* dup 
        update_x0
        update_y0 
        x0 @ x1 @ = y0 @ y1 @ = & 
    until ; 

create r 0, 
: RADIUS r ! ; 
: CIRCLE 
    r @ negate dx ! D# 0 dy ! 
    D# 2 D# 2 r @ * - err !  
    begin 
        x0 @ dx @ - y0 @ dy @ + screen_location plot_pixel 
        x0 @ dy @ - y0 @ dx @ - screen_location plot_pixel 
        x0 @ dx @ + y0 @ dy @ - screen_location plot_pixel 
        x0 @ dy @ + y0 @ dx @ + screen_location plot_pixel 
        err @ r ! 
        r @ dy @ <= if 
            dy dup ++ @ 2* 1+    
            err swap +! 
        then
        r @ dx @ > err @ dy @ > | if
            dx dup ++ @ 2* 1+  
            err swap +!  
        then   
    dx @ D# 0 >= until ; 
: DRAW draw_screen ; 
: PLOT x0 @ y0 @ screen_location plot_pixel ; 
