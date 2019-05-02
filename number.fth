create @             D#  4 primitive 
create !             D#  5 primitive 
create +             D#  6 primitive 
create -             D#  7 primitive 
create *             D#  8 primitive 
create /             D#  9 primitive 
create %             D# 10 primitive 
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
create <<            D# 33 primitive 
create >>            D# 34 primitive 
create ^             D# 35 primitive 
create exit          D#  3 primitive 

: cp D# 3 ; // This is the location in memory of the code pointer 
: here cp @ ; 
: +! over @ + swap ! ;  
: ++ D# 1 +! ; 
: , here ! cp ++ ; 
: 0, D# 0 , ; 
: 2* dup + ; 
: 4* 2* 2* ; 
: 1+ D# 1 + ; 
: 1- D# 1 - ; 
: 0< D# 0 < ; 
: compile r> 1+ dup @ , >r ; 

: if compile jz here 0, ;                     immediate
: else compile jmp here 0, swap here swap ! ; immediate
: then here swap ! ;                          immediate 
: begin here ;                                immediate 
: until compile jz , ;                        immediate 
: while compile jz here D# 0 , swap ; immediate
: repeat compile jmp , here swap ! ; immediate 

: 2dup over over ; 
: 2drop drop drop ; 
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

: DRAW draw_screen ; 
: ROW D# 3 << ; 
: COLUMN D# 3 << ; 
: ROWS screen_y D# 1 ROW / ; 
: COLUMNS screen_x D# 1 COLUMN / ; 
: one_row screen_x ; 

: draw_byte // ( location byte )
    D# 0 >r begin  
        dup D# 1 & if 
            over color @ swap put_pixel 
        else
            over background @ swap put_pixel 
        then D# 1 >> swap D# 1 + swap 
    r> D# 1 + dup >r D# 7 = until r> drop 2drop ;  

: get_bytes // ( value ) 
    dup H# FF & swap 
    D# 8 >> dup H# FF & swap 
    D# 8 >> dup H# FF & swap 
    D# 8 >> H# FF & ; 

: draw_bytes // ( location value ) 
    swap >r get_bytes 
    r> swap over swap 
    draw_byte one_row + 
    swap over swap 
    draw_byte one_row +
    swap over swap 
    draw_byte one_row +
    swap draw_byte ;  

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
: total_columns ROWS COLUMNS * ; 
: cursor_xy CURSOR @ total_columns % dup COLUMNS % swap COLUMNS / ; 
: EMIT 
    2* cursor_xy COLUMN swap ROW swap screen_location 
    swap 2dup 
    font8x8_basic ASCII draw_bytes 
    swap one_row 4* + swap 
    D# 1 + font8x8_basic ASCII draw_bytes 
    CURSOR ++ ; 
: COUNT dup @ swap D# 1 + swap ; 
: TYPE begin swap dup @ EMIT D# 1 + swap D# 1 - dup while repeat 2drop ; 
: CR cursor_xy D# 1 + swap drop D# 0 swap CURSOR_AT ; 
: SPACE D# 32 EMIT ; 
: A D# 65 EMIT ; 
S" Hello World 
TYPE DRAW SPACE CR 
: DIGIT D# 9 over < D# 7 & + D# 48 + ; 
: EXTRACT 2dup / rot % DIGIT ; 
create HLD 0, 
create BASE D# 10 , 
: PAD here D# 80 + ; 
: <# PAD HLD ! ; 
: HOLD HLD @ 1- dup HLD ! ! ; 
: # BASE @ EXTRACT HOLD ; 
: #S begin # dup while repeat ; 
: SIGN 0< if D# 45 HOLD then ; 
: #> drop HLD @ PAD over - ; 
: str dup >r abs <# #S r> SIGN #> ; 
: U. <# #S #> SPACE TYPE ; 
: . BASE @ D# 10 ^ if U. exit then str SPACE TYPE ; 
: HEX D# 16 BASE ! ; 
: DECIMAL D# 10 BASE ! ; 
: ? @ . ; 
D# -1234324 . DRAW 

