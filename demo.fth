create _@    D#  4 primitive 
create _!    D#  5 primitive 
create _+    D#  6 primitive 
create _-    D#  7 primitive 
create _*    D#  8 primitive 
create _/    D#  9 primitive 
create _%    D# 10 primitive 
create _&    D# 11 primitive 
create _|    D# 12 primitive 
create _~    D# 13 primitive 
create _dup  D# 14 primitive 
create _drop D# 15 primitive 
create _swap D# 16 primitive 
create _over D# 17 primitive 
create _>    D# 22 primitive 
create _=    D# 23 primitive 
create _<    D# 24 primitive 
create jz   D# 20 primitive
create jmp  D# 21 primitive 
create >r   D# 18 primitive
create r>   D# 19 primitive 
create _<<   D# 33 primitive 
create _>>   D# 34 primitive 
create return        D#  3 primitive 
create lit           D#  1 primitive
create put_pixel     D# 26 primitive
create draw_screen   D# 27 primitive
create read_key      D# 30 primitive 
create draw_count    D# 29 primitive 
create set_waveform  D# 31 primitive 
create start_sound   D# 32 primitive

: state D# 2 ; 
: [ D# 0 state _! ; immediate 
: ] D# -1 state _! ; 
: cp D# 3 ; 
: here cp _@ ;
: allot cp _@ _+ cp _! ; 
: , here D# 1 allot _! ; 
: compile r> D# 1 _+ _dup _@ , >r ; 
: if compile jz here D# 0 , ; immediate
: else compile jmp here D# 0 , _swap here _swap _! ; immediate
: then here _swap _! ; immediate 

: @ state _@ if compile _@ else _@ then ; immediate 
: ! state @ if compile _! else _! then ; immediate 
: + state @ if compile _+ else _+ then ; immediate 
: - state @ if compile _- else _- then ; immediate 
: * state @ if compile _* else _* then ; immediate 
: / state @ if compile _/ else _/ then ; immediate 
: % state @ if compile _% else _% then ; immediate 
: & state @ if compile _& else _& then ; immediate 
: | state @ if compile _| else _| then ; immediate 
: ~ state @ if compile _~ else _~ then ; immediate 
: dup state @ if compile _dup else _dup then ; immediate 
: drop state @ if compile _drop else _drop then ; immediate 
: swap state @ if compile _swap else _swap then ;  immediate 
: over state @ if compile _over else _over then ; immediate 
: > state @ if compile _> else _> then ; immediate 
: = state @ if compile _= else _= then ; immediate 
: < state @ if compile _< else _< then ; immediate 
: << state @ if compile _<< else _<< then ; immediate 
: >> state @ if compile _>> else _>> then ; immediate 

: begin here ; immediate 
: again compile jmp , ; immediate 
: until compile jz , ; immediate
: while compile jz here D# 0 , swap ; immediate
: repeat compile jmp , here swap ! ; immediate
: literal compile lit , ; immediate 
: abs dup D# 0 < if ~ D# 1 + then ; 
: 2dup over over ; 
: rot swap >r swap r> ;
: -rot rot rot ;  
: 2over >r >r 2dup r> rot r> rot ;  
: 2drop drop drop ; 
: >= 2dup > >r = r> | ; 
: <= 2dup < >r = r> | ; 
: negate ~ D# 1 + ; 

: screen_x D# 640 ;
: screen_y D# 480 ;

: screen_location screen_x * + ;

: black H# 000000 ; 
: blue H# 000080 ; 
: red H# 800000 ; 
: magenta H# 800080 ; 
: green H# 008000 ; 
: cyan H# 008080 ; 
: yellow H# 808000 ; 
: white H# FFFFFF ;  

: grey H# 404040 ; 
: b_blue H# 0000FF ;
: b_red H# FF0000 ;
: b_magenta H# FF00FF ; 
: b_green H# 00FF00 ;
: b_cyan H# 00FFFF ; 
: b_yellow H# FFFF00 ; 
: b_grey H# C0C0C0 ; 

create colors 
    black , blue , red , magenta , green , cyan , yellow , white , 
    grey , b_blue , b_red , b_magenta , b_green , b_cyan , b_yellow , b_grey ,     

create color white , 
create background black , 
: FG color ! ; 
: BG background ! ; 

create seed here , 
: random seed @ D# 31421 * D# 6927 + H# FFFF & dup seed ! ; 

// Plot pixel ( location | ) 
: plot_pixel color @ swap put_pixel ; 

// : total_pixels screen_x screen_y * ; 
: CLEAR 
    D# 0 begin 
        background @ over put_pixel D# 1 + dup 
        [ screen_x screen_y * ] literal = 
    until drop draw_screen ; 
CLEAR

create x0 D# 0 , 
create y0 D# 0 ,
: AT y0 ! x0 ! ; 

create x1 D# 0 , 
create y1 D# 0 , 
: TO y1 ! x1 ! ; 

create dx  D# 0 , 
create dy  D# 0 , 
create err D# 0 , 
create _sx D# 0 , 
create _sy D# 0 , 
: sx _sx @ ; 
: sy _sy @ ; 
: +! over @ + swap ! ; 
: init_line 
    x0 @ x1 @ < if D# 1 else D# -1 then _sx ! 
    y0 @ y1 @ < if D# 1 else D# -1 then _sy ! 
    x1 @ x0 @ - abs dup dx ! 
    y1 @ y0 @ - abs negate dup dy !  
    + err ! ;

: update_x0 dy @ >= if err dy @ +! x0 sx +! then ; 
: update_y0 dx @ <= if err dx @ +! y0 sy +! then ;  

: LINE
    init_line  
    begin 
        x0 @ y0 @ screen_location plot_pixel 
        err @ D# 1 << dup 
        update_x0
        update_y0 
        x0 @ x1 @ = y0 @ y1 @ = & 
    until ; 

create r D# 0 , 
: RADIUS r ! ; 
: CIRCLE 
    r @ negate dx ! D# 0 dy ! 
    D# 2 D# 2 r @ * - err !  
    begin 
        x0 @ dx @ - y0 @ dy @ + screen_location plot_pixel 
        x0 @ dy @ - y0 @ dx @ - screen_location plot_pixel 
        x0 @ dx @ + y0 @ dy @ - screen_location plot_pixel 
        x0 @ dy @ + y0 @ dx @ + screen_location plot_pixel 
        err @ RADIUS 
        r @ dy @ <= if 
            dy dup D# 1 +! @ D# 1 << D# 1 +   
            err swap +! 
        then
        r @ dx @ > err @ dy @ > | if
            dx dup D# 1 +! @ D# 1 << D# 1 +  
            err swap +!  
        then   
    dx @ D# 0 < while repeat ; 
: DRAW draw_screen ; 
: PLOT x0 @ y0 @ screen_location plot_pixel ; 
: ROW D# 3 << ; 
: COLUMN D# 3 << ; 
: ROWS screen_y D# 1 ROW / ; 
: COLUMNS screen_x D# 1 COLUMN / ; 
: one_row screen_x ;
: bottom_row one_row D# 7 * + ; 

: draw_row over swap D# 0 >r begin 
    dup D# 1 & if 
        over color @ swap put_pixel
    else 
        over background @ swap put_pixel 
    then D# 1 >> swap D# 1 + swap 
    r> D# 1 + dup >r D# 8 = until 
    r> drop 2drop one_row - ; 

: draw_rows D# 0 >r begin 
    dup >r H# FF & draw_row r> D# 8 >> 
    r> D# 1 + dup >r D# 4 = until r> drop drop ;     

// ASCII Character set 
create font8x8_basic
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul) 
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul) 
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul) 
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul) 
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul) 
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul) 
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul) 
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul) 
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (nul)
    H# 00000000 , H# 00000000 , // (space)
    H# 183C3C18 , H# 18001800 , // (!)
    H# 36360000 , H# 00000000 , // (")
    H# 36367F36 , H# 7F363600 , // (#) 
    H# 0C3E031E , H# 301F0C00 , // ($)
    H# 00633318 , H# 0C666300 , // (%)
    H# 1C361C6E , H# 3B336E00 , // (&)
    H# 06060300 , H# 00000000 , // (')
    H# 180C0606 , H# 060C1800 , // (()
    H# 060C1818 , H# 180C0600 , // ())
    H# 00663CFF , H# 3C660000 , // (*) 
    H# 000C0C3F , H# 0C0C0000 , // (+)
    H# 00000000 , H# 000C0C06 , // (,)
    H# 0000003F , H# 00000000 , // (-) 
    H# 00000000 , H# 000C0C00 , // (.)
    H# 6030180C , H# 06030100 , // (/)
    H# 3E63737B , H# 6F673E00 , // (0)
    H# 0C0E0C0C , H# 0C0C3F00 , // (1) 
    H# 1E33301C , H# 06333F00 , // (2)
    H# 1E33301C , H# 30331E00 , // (3)
    H# 383C3633 , H# 7F307800 , // (4)
    H# 3F031F30 , H# 30331E00 , // (5) 
    H# 1C06031F , H# 33331E00 , // (6)
    H# 3F333018 , H# 0C0C0C00 , // (7) 
    H# 1E33331E , H# 33331E00 , // (8) 
    H# 1E33333E , H# 30180E00 , // (9) 
    H# 000C0C00 , H# 000C0C00 , // (:)
    H# 000C0C00 , H# 000C0C06 , // (;)
    H# 180C0603 , H# 060C1800 , // (<)
    H# 00003F00 , H# 003F0000 , // (=) 
    H# 060C1830 , H# 180C0600 , // (>)
    H# 1E333018 , H# 0C000C00 , // (?) 
    H# 3E637B7B , H# 7B031E00 , // (@)
    H# 0C1E3333 , H# 3F333300 , // (A)
    H# 3F66663E , H# 66663F00 , // (B) 
    H# 3C660303 , H# 03663C00 , // (C)
    H# 1F366666 , H# 66361F00 , // (D) 
    H# 7F46161E , H# 16467F00 , // (E) 
    H# 7F46161E , H# 16060F00 , // (F) 
    H# 3C660303 , H# 73667C00 , // (G)
    H# 3333333F , H# 33333300 , // (H) 
    H# 1E0C0C0C , H# 0C0C1E00 , // (I) 
    H# 78303030 , H# 33331E00 , // (J)
    H# 6766361E , H# 36666700 , // (K) 
    H# 0F060606 , H# 46667F00 , // (L) 
    H# 63777F7F , H# 6B636300 , // (M) 
    H# 63676F7B , H# 73636300 , // (N) 
    H# 1C366363 , H# 63361C00 , // (O)
    H# 3F66663E , H# 06060F00 , // (P) 
    H# 1E333333 , H# 3B1E3800 , // (Q) 
    H# 3F66663E , H# 36666700 , // (R) 
    H# 1E33070E , H# 38331E00 , // (S) 
    H# 3F2D0C0C , H# 0C0C1E00 , // (T) 
    H# 33333333 , H# 33333F00 , // (U)
    H# 33333333 , H# 331E0C00 , // (V)
    H# 6363636B , H# 7F776300 , // (W)
    H# 6363361C , H# 1C366300 , // (X)
    H# 3333331E , H# 0C0C1E00 , // (Y) 
    H# 7F633118 , H# 4C667F00 , // (Z) 
    H# 1E060606 , H# 06061E00 , // ([) 
    H# 03060C18 , H# 30604000 , // (\)
    H# 1E181818 , H# 18181E00 , // (]) 
    H# 081C3663 , H# 00000000 , // (^)
    H# 00000000 , H# 000000FF , // (_)
    H# 0C0C1800 , H# 00000000 , // (`)
    H# 00001E30 , H# 3E336E00 , // (a) 
    H# 0706063E , H# 66663B00 , // (b) 
    H# 00001E33 , H# 03331E00 , // (c) 
    H# 3830303e , H# 33336E00 , // (d) 
    H# 00001E33 , H# 3f031E00 , // (e) 
    H# 1C36060f , H# 06060F00 , // (f)
    H# 00006E33 , H# 333E301F , // (g) 
    H# 0706366E , H# 66666700 , // (h) 
    H# 0C000E0C , H# 0C0C1E00 , // (i)
    H# 30003030 , H# 3033331E , // (j)
    H# 07066636 , H# 1E366700 , // (k)
    H# 0E0C0C0C , H# 0C0C1E00 , // (l) 
    H# 0000337F , H# 7F6B6300 , // (m) 
    H# 00001F33 , H# 33333300 , // (n) 
    H# 00001E33 , H# 33331E00 , // (o) 
    H# 00003B66 , H# 663E060F , // (p)
    H# 00006E33 , H# 333E3078 , // (q) 
    H# 00003B6E , H# 66060F00 , // (r)
    H# 00003E03 , H# 1E301F00 , // (s) 
    H# 080C3E0C , H# 0C2C1800 , // (t)
    H# 00003333 , H# 33336E00 , // (u)
    H# 00003333 , H# 331E0C00 , // (v)
    H# 0000636B , H# 7F7F3600 , // (w)
    H# 00006336 , H# 1C366300 , // (x)
    H# 00003333 , H# 333E301F , // (y)
    H# 00003F19 , H# 0C263F00 , // (z) 
    H# 380C0C07 , H# 0C0C3800 , // ({)
    H# 18181800 , H# 18181800 , // (|)
    H# 070C0C38 , H# 0C0C0700 , // (})
    H# 6E3B0000 , H# 00000000 , // (~)
    H# 00000000 , H# 00000000 , // (nul) 

: ASCII  + @ ; 
create CURSOR D# 0 , 
: CURSOR_AT COLUMNS * + CURSOR ! ; 
: cursor_xy CURSOR @ [ ROWS COLUMNS * ] literal % dup COLUMNS % swap COLUMNS / ; 
: _EMIT D# 1 << cursor_xy COLUMN swap ROW swap screen_location bottom_row 
    over D# 1 + font8x8_basic ASCII draw_rows 
    over font8x8_basic ASCII draw_rows 2drop ; 
: EMIT _EMIT CURSOR D# 1 +! ; 
: COUNT dup @ swap D# 1 + swap ; 
: TYPE begin swap dup @ EMIT D# 1 + swap D# 1 - dup while repeat 2drop ; 
: SCONSTANT dup , begin swap dup @ , D# 1 + swap D# 1 - dup while repeat 2drop ; 
: CR cursor_xy D# 1 + swap drop D# 0 swap CURSOR_AT ; 
: SPACE D# 32 EMIT ; 
: INVERT color @ background @ color ! background ! ; 
: all D# 32 begin INVERT dup EMIT draw_screen D# 1 + dup D# 127 = until drop ; 
: test random D# 15 % colors + @ FG random D# 15 % colors + @ BG all ; 
S" Hello World 
TYPE DRAW SPACE CR 
S" Hello constant 
create hello SCONSTANT 
: test_constant D# 0 begin hello COUNT TYPE DRAW CR D# 1 + dup D# 5 = until drop ; 

: PAUSE draw_count + begin draw_count over < draw_screen while repeat drop ; 
: 1/10ths D# 6 * ; 
: 1/20ths D# 3 * ; 

create SCALE 
    D# 130813 , D# 138591 , D# 146832 , D# 155563 , D# 164814 , D# 174614 , 
    D# 184997 , D# 195998 , D# 207652 , D# 220000 , D# 233082 , D# 246942 , 
    D# 261626 , D# 277183 , D# 293665 , D# 311127 , D# 329628 , D# 349228 , 
    D# 369994 , D# 391995 , D# 415305 , D# 440000 , D# 466164 , D# 493883 ,   
    D# 523251 , D# 554365 , D# 587330 , D# 622254 , D# 659255 , D# 698456 , 
    D# 739989 , D# 783991 , D# 830609 , D# 880000 , D# 932328 , D# 987767 ,   
: scale_start SCALE D# 12 + ;     // C4 

: BEEP [ scale_start ] literal + @ D# 2 set_waveform D# 80 swap dup >r D# 50 * start_sound r> 1/20ths PAUSE ; 
: gustav 
    D# 20 D# 0 BEEP D# 20 D# 2 BEEP D# 10 D# 3 BEEP D# 10 D# 2 BEEP D# 20 D# 0 BEEP 
    D# 20 D# 0 BEEP D# 20 D# 2 BEEP D# 10 D# 3 BEEP D# 10 D# 2 BEEP D# 20 D# 0 BEEP 
    D# 20 D# 3 BEEP D# 20 D# 5 BEEP D# 40 D# 7 BEEP 
    D# 20 D# 3 BEEP D# 20 D# 5 BEEP D# 40 D# 7 BEEP 
    D# 15 D# 7 BEEP D#  5 D# 8 BEEP D# 10 D# 7 BEEP D# 10 D# 5 BEEP D# 10 D# 3 BEEP 
    D# 10 D# 2 BEEP D# 20 D# 0 BEEP 
    D# 15 D# 7 BEEP D#  5 D# 8 BEEP D# 10 D# 7 BEEP D# 10 D# 5 BEEP D# 10 D# 3 BEEP 
    D# 10 D# 2 BEEP D# 20 D# 0 BEEP 
    D# 20 D# 0 BEEP D# 20 D# -5 BEEP D# 40 D# 0 BEEP 
    D# 20 D# 0 BEEP D# 20 D# -5 BEEP D# 40 D# 0 BEEP ; 
  
: { here D# 4 + compile lit , compile jmp here D# 0 , ; immediate 
: } compile return here swap ! ; immediate 
: do r> drop D# 1 - >r ; 
: testdo { D# 65 EMIT draw_screen } do ; 
create marker D# 0 , 
: MARK here marker ! ; 
: FORGET marker @ cp ! ; 

S" A 
drop @ CR EMIT DRAW  
