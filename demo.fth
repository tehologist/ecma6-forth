create @    D#  4 , primitive 
create !    D#  5 , primitive 
create +    D#  6 , primitive 
create -    D#  7 , primitive 
create *    D#  8 , primitive 
create /    D#  9 , primitive 
create %    D# 10 , primitive 
create &    D# 11 , primitive 
create |    D# 12 , primitive 
create ~    D# 13 , primitive 
create dup  D# 14 , primitive 
create drop D# 15 , primitive 
create swap D# 16 , primitive 
create over D# 17 , primitive 
create >    D# 22 , primitive 
create =    D# 23 , primitive 
create <    D# 24 , primitive 
create jz   D# 20 , primitive
create jmp  D# 21 , primitive 
create >r   D# 18 , primitive
create r>   D# 19 , primitive 
create <<   D# 33 , primitive 
create >>   D# 34 , primitive 
create return        D#  3 , primitive 
create lit           D#  1 , primitive
create put_pixel     D# 26 , primitive
create draw_screen   D# 27 , primitive
create read_key      D# 30 , primitive 
create draw_count    D# 29 , primitive 
create set_waveform  D# 31 , primitive 
create start_sound   D# 32 , primitive

: cp D# 2 ; 
: here cp @ ;
: allot cp @ + cp ! ; 
: , here D# 1 allot ! ; 
: compile r> D# 1 + dup @ , >r ; 
: if compile jz here D# 0 , ; immediate
: else compile jmp here D# 0 , swap here swap ! ; immediate
: then here swap ! ; immediate 
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
: screen_x D# 640 ;
: screen_y D# 400 ;

: negate ~ D# 1 + ; 
: screen_location screen_x * + ;

: white H# FFFFFF ;  
: black H# 000000 ; 
: b_red H# FF0000 ;
: red H# 800000 ;
: b_green H# 00FF00 ;
: green H# 008000 ; 
: b_yellow H# FFFF00 ; 
: yellow H# 808000 ; 
: b_cyan H# 00FFFF ; 
: cyan H# 008080 ; 
: b_blue H# 0000FF ;
: blue H# 000080 ; 
: b_magenta H# FF00FF ; 
: magenta H# 800080 ; 
: b_grey H# C0C0C0 ; 
: grey H# 404040 ; 
create colors white , black , b_red , red , b_green , green , 
    b_yellow , yellow , b_cyan , cyan , b_blue , blue , b_magenta , 
    magenta , b_grey , grey ,  
create color white , 
create background black , 
: FG color ! ; 
: BG background ! ; 

create seed here , 
: random seed @ D# 31421 * D# 6927 + H# FFFF & dup seed ! ; 

// Plot pixel ( location | ) 
: plot_pixel color @ swap put_pixel ; 

: total_pixels screen_x screen_y * ; 
: CLEAR 
    D# 0 begin 
        background @ over put_pixel D# 1 + dup 
        [ total_pixels ] literal = 
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

create U+0000 H# 00000000 , H# 00000000 , // (nul)
create U+0001 H# 00000000 , H# 00000000 , // (nul)
create U+0002 H# 00000000 , H# 00000000 , // (nul)
create U+0003 H# 00000000 , H# 00000000 , // (nul)
create U+0004 H# 00000000 , H# 00000000 , // (nul)
create U+0005 H# 00000000 , H# 00000000 , // (nul)
create U+0006 H# 00000000 , H# 00000000 , // (nul)
create U+0007 H# 00000000 , H# 00000000 , // (nul)
create U+0008 H# 00000000 , H# 00000000 , // (nul)
create U+0009 H# 00000000 , H# 00000000 , // (nul)
create U+000A H# 00000000 , H# 00000000 , // (nul)
create U+000B H# 00000000 , H# 00000000 , // (nul)
create U+000C H# 00000000 , H# 00000000 , // (nul)
create U+000D H# 00000000 , H# 00000000 , // (nul)
create U+000E H# 00000000 , H# 00000000 , // (nul)
create U+000F H# 00000000 , H# 00000000 , // (nul)
create U+0010 H# 00000000 , H# 00000000 , // (nul)
create U+0011 H# 00000000 , H# 00000000 , // (nul)
create U+0012 H# 00000000 , H# 00000000 , // (nul)
create U+0013 H# 00000000 , H# 00000000 , // (nul)
create U+0014 H# 00000000 , H# 00000000 , // (nul)
create U+0015 H# 00000000 , H# 00000000 , // (nul)
create U+0016 H# 00000000 , H# 00000000 , // (nul)
create U+0017 H# 00000000 , H# 00000000 , // (nul)
create U+0018 H# 00000000 , H# 00000000 , // (nul)
create U+0019 H# 00000000 , H# 00000000 , // (nul)
create U+001A H# 00000000 , H# 00000000 , // (nul)
create U+001B H# 00000000 , H# 00000000 , // (nul)
create U+001C H# 00000000 , H# 00000000 , // (nul)
create U+001D H# 00000000 , H# 00000000 , // (nul)
create U+001E H# 00000000 , H# 00000000 , // (nul)
create U+001F H# 00000000 , H# 00000000 , // (nul)
create U+0020 H# 00000000 , H# 00000000 , // (space)
create U+0021 H# 183C3C18 , H# 18001800 , // (!)
create U+0022 H# 36360000 , H# 00000000 , // (")
create U+0023 H# 36367F36 , H# 7F363600 , // (#)
create U+0024 H# 0C3E031E , H# 301F0C00 , // ($)
create U+0025 H# 00633318 , H# 0C666300 , // (%)
create U+0026 H# 1C361C6E , H# 3B336E00 , // (&)
create U+0027 H# 06060300 , H# 00000000 , // (')
create U+0028 H# 180C0606 , H# 060C1800 , // (()
create U+0029 H# 060C1818 , H# 180C0600 , // ())
create U+002A H# 00663CFF , H# 3C660000 , // (*)
create U+002B H# 000C0C3F , H# 0C0C0000 , // (+)
create U+002C H# 00000000 , H# 000C0C06 , // (,)
create U+002D H# 0000003F , H# 00000000 , // (-)
create U+002E H# 00000000 , H# 000C0C00 , // (.)
create U+002F H# 6030180C , H# 06030100 , // (/)
create U+0030 H# 3E63737B , H# 6F673E00 , // (0)
create U+0031 H# 0C0E0C0C , H# 0C0C3F00 , // (1)
create U+0032 H# 1E33301C , H# 06333F00 , // (2)
create U+0033 H# 1E33301C , H# 30331E00 , // (3)
create U+0034 H# 383C3633 , H# 7F307800 , // (4)
create U+0035 H# 3F031F30 , H# 30331E00 , // (5)
create U+0036 H# 1C06031F , H# 33331E00 , // (6)
create U+0037 H# 3F333018 , H# 0C0C0C00 , // (7)
create U+0038 H# 1E33331E , H# 33331E00 , // (8)
create U+0039 H# 1E33333E , H# 30180E00 , // (9)
create U+003A H# 000C0C00 , H# 000C0C00 , // (:)
create U+003B H# 000C0C00 , H# 000C0C06 , // (;)
create U+003C H# 180C0603 , H# 060C1800 , // (<)
create U+003D H# 00003F00 , H# 003F0000 , // (=)
create U+003E H# 060C1830 , H# 180C0600 , // (>)
create U+003F H# 1E333018 , H# 0C000C00 , // (?)
create U+0040 H# 3E637B7B , H# 7B031E00 , // (@)
create U+0041 H# 0C1E3333 , H# 3F333300 , // (A)
create U+0042 H# 3F66663E , H# 66663F00 , // (B)
create U+0043 H# 3C660303 , H# 03663C00 , // (C)
create U+0044 H# 1F366666 , H# 66361F00 , // (D)
create U+0045 H# 7F46161E , H# 16467F00 , // (E)
create U+0046 H# 7F46161E , H# 16060F00 , // (F)
create U+0047 H# 3C660303 , H# 73667C00 , // (G)
create U+0048 H# 3333333F , H# 33333300 , // (H)
create U+0049 H# 1E0C0C0C , H# 0C0C1E00 , // (I)
create U+004A H# 78303030 , H# 33331E00 , // (J)
create U+004B H# 6766361E , H# 36666700 , // (K)
create U+004C H# 0F060606 , H# 46667F00 , // (L)
create U+004D H# 63777F7F , H# 6B636300 , // (M)
create U+004E H# 63676F7B , H# 73636300 , // (N)
create U+004F H# 1C366363 , H# 63361C00 , // (O)
create U+0050 H# 3F66663E , H# 06060F00 , // (P)
create U+0051 H# 1E333333 , H# 3B1E3800 , // (Q)
create U+0052 H# 3F66663E , H# 36666700 , // (R)
create U+0053 H# 1E33070E , H# 38331E00 , // (S)
create U+0054 H# 3F2D0C0C , H# 0C0C1E00 , // (T)
create U+0055 H# 33333333 , H# 33333F00 , // (U)
create U+0056 H# 33333333 , H# 331E0C00 , // (V)
create U+0057 H# 6363636B , H# 7F776300 , // (W)
create U+0058 H# 6363361C , H# 1C366300 , // (X)
create U+0059 H# 3333331E , H# 0C0C1E00 , // (Y)
create U+005A H# 7F633118 , H# 4C667F00 , // (Z)
create U+005B H# 1E060606 , H# 06061E00 , // ([)
create U+005C H# 03060C18 , H# 30604000 , // (\)
create U+005D H# 1E181818 , H# 18181E00 , // (])
create U+005E H# 081C3663 , H# 00000000 , // (^)
create U+005F H# 00000000 , H# 000000FF , // (_)
create U+0060 H# 0C0C1800 , H# 00000000 , // (`)
create U+0061 H# 00001E30 , H# 3E336E00 , // (a)
create U+0062 H# 0706063E , H# 66663B00 , // (b)
create U+0063 H# 00001E33 , H# 03331E00 , // (c)
create U+0064 H# 3830303e , H# 33336E00 , // (d)
create U+0065 H# 00001E33 , H# 3f031E00 , // (e)
create U+0066 H# 1C36060f , H# 06060F00 , // (f)
create U+0067 H# 00006E33 , H# 333E301F , // (g)
create U+0068 H# 0706366E , H# 66666700 , // (h)
create U+0069 H# 0C000E0C , H# 0C0C1E00 , // (i)
create U+006A H# 30003030 , H# 3033331E , // (j)
create U+006B H# 07066636 , H# 1E366700 , // (k)
create U+006C H# 0E0C0C0C , H# 0C0C1E00 , // (l)
create U+006D H# 0000337F , H# 7F6B6300 , // (m)
create U+006E H# 00001F33 , H# 33333300 , // (n)
create U+006F H# 00001E33 , H# 33331E00 , // (o)
create U+0070 H# 00003B66 , H# 663E060F , // (p)
create U+0071 H# 00006E33 , H# 333E3078 , // (q)
create U+0072 H# 00003B6E , H# 66060F00 , // (r)
create U+0073 H# 00003E03 , H# 1E301F00 , // (s)
create U+0074 H# 080C3E0C , H# 0C2C1800 , // (t)
create U+0075 H# 00003333 , H# 33336E00 , // (u)
create U+0076 H# 00003333 , H# 331E0C00 , // (v)
create U+0077 H# 0000636B , H# 7F7F3600 , // (w)
create U+0078 H# 00006336 , H# 1C366300 , // (x)
create U+0079 H# 00003333 , H# 333E301F , // (y)
create U+007A H# 00003F19 , H# 0C263F00 , // (z)
create U+007B H# 380C0C07 , H# 0C0C3800 , // ({)
create U+007C H# 18181800 , H# 18181800 , // (|)
create U+007D H# 070C0C38 , H# 0C0C0700 , // (})
create U+007E H# 6E3B0000 , H# 00000000 , // (~)
create U+007F H# 00000000 , H# 00000000 , // (nul) 

create font8x8_basic 
    U+0000 , U+0001 , U+0002 , U+0003 , U+0004 , U+0005 , U+0006 , U+0007 ,  
    U+0008 , U+0009 , U+000A , U+000B , U+000C , U+000D , U+000E , U+000F , 
    U+0010 , U+0011 , U+0012 , U+0013 , U+0014 , U+0015 , U+0016 , U+0017 ,
    U+0018 , U+0019 , U+001A , U+001B , U+001C , U+001D , U+001E , U+001F ,  
    U+0020 , U+0021 , U+0022 , U+0023 , U+0024 , U+0025 , U+0026 , U+0027 ,
    U+0028 , U+0029 , U+002A , U+002B , U+002C , U+002D , U+002E , U+002F ,  
    U+0030 , U+0031 , U+0032 , U+0033 , U+0034 , U+0035 , U+0036 , U+0037 ,
    U+0038 , U+0039 , U+003A , U+003B , U+003C , U+003D , U+003E , U+003F ,  
    U+0040 , U+0041 , U+0042 , U+0043 , U+0044 , U+0045 , U+0046 , U+0047 ,
    U+0048 , U+0049 , U+004A , U+004B , U+004C , U+004D , U+004E , U+004F ,  
    U+0050 , U+0051 , U+0052 , U+0053 , U+0054 , U+0055 , U+0056 , U+0057 ,
    U+0058 , U+0059 , U+005A , U+005B , U+005C , U+005D , U+005E , U+005F ,  
    U+0060 , U+0061 , U+0062 , U+0063 , U+0064 , U+0065 , U+0066 , U+0067 ,
    U+0068 , U+0069 , U+006A , U+006B , U+006C , U+006D , U+006E , U+006F ,  
    U+0070 , U+0071 , U+0072 , U+0073 , U+0074 , U+0075 , U+0076 , U+0077 ,
    U+0078 , U+0079 , U+007A , U+007B , U+007C , U+007D , U+007E , U+007F ,  
    
: ASCII font8x8_basic + @ ; 
create CURSOR D# 0 , 
: CURSOR_AT COLUMNS * + CURSOR ! ; 
: cursor_xy CURSOR @ ROWS COLUMNS * % dup COLUMNS % swap COLUMNS / ; 
: _EMIT ASCII cursor_xy COLUMN swap ROW swap screen_location bottom_row 
    over D# 1 + @ draw_rows 
    over @ draw_rows 2drop ; 
: EMIT D# 32 _EMIT _EMIT CURSOR D# 1 +! ;
: TYPE begin swap dup @ EMIT D# 1 + swap D# 1 - dup while repeat 2drop ; 
: CR cursor_xy D# 1 + swap drop D# 0 swap CURSOR_AT ; 
: SPACE D# 32 EMIT ; 
: all D# 32 begin dup EMIT draw_screen D# 1 + dup D# 127 = until drop ; 
: test random D# 15 % abs colors + @ FG random D# 15 % abs colors + @ BG all ; 
S" Hello World 
TYPE DRAW SPACE CR 
