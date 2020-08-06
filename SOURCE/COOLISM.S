;
; "Coolism"
;
; A small musicdemo made for STNICCC 2015
;
; Code by Bod
; Gfx by Senser+Samurai
; Additional Gfx by Bod
; Music by XRWWR
; Additional Music
; by Marcer and Dark Angel
; Scrolltext by Tronic
;
max_tunes	equ	10
ball_wait	equ	11
num_intro_balls	equ	78
maxcookie	equ	128				;Maximum cookie entries to search

 	opt	o+,w-

	move.l	4(a7),a0
	move.l	#$100,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	quit1

	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	cmp.w	#2,d0
	blt.s	comp_check

	pea	hi_txt
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp

	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp

	bra	quit1

comp_check	sf	st_flag
	jsr	cookie_check

	tst.b	st_flag
	bpl	clear_bss

	pea	comp_txt
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp

	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp

	bra	quit1

hi_txt	dc.b	27,"E",07	; 07=cowbell!
	dc.b	"Sorry, colour monitors only!",13,10,13,10
	dc.b	"Press any key to exit...",0
	even

comp_txt	dc.b	27,"E",07	; 07=cowbell!
	dc.b	"Sorry, This demo only works on ST & STe",13,10,13,10
	dc.b	"Press any key to exit...",0
	even

clear_bss	moveq	#0,d0
	lea	bss_start,a0
	lea	bss_end,a1
.l1	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	cmp.l	a1,a0
	ble.s	.l1

demo_start	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,old_stack
	lea	stack,a7

	jsr	vsync

	movem.l	$fffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	move.l	$fffff8200.w,oldphys
	move.b	$fffff8260.w,oldrez
	move.b	$fffff820a.w,oldhz
	movem.l	blank,d0-d7
	movem.l	d0-d7,$fffff8240.w

	move.l	#screen_ram,d0
	clr.b	d0
	move.l	d0,screen1
	add.l	#32000+(160*56),d0
	move.l	d0,screen2
	lsr.w	#8,d0
	move.l	d0,$fffff8200.w
	clr.b	$fffff8260.w
	move.b	#2,$fffff820a.w

	jsr	silence
	moveq	#$12,d0
	jsr	ikbd
	moveq	#$1a,d0
	jsr	ikbd
	jsr	flush
	move.l	#$e0e0707,$fffff8800.w	; off

	jsr	copy_sin
	jsr	clearscreen
	jsr	shift_intro_ball
	jsr	init_intro_balls
	move.l	#intro_tb,timer_rout
	move.w	#199,timer_line
	jsr	store_ints

************** intro starts here! **************

; intro_balls!
	move.w	#1,intro_rout

	lea	intro_ball_pal,a0
	lea	intro_palbuff,a1
	moveq	#16-1,d0
	jsr	delta_fade_in

	moveq	#7-1,d0
	jsr	effect_wait

;loop1	cmp.b	#$39,kbuff
;	bne.s	loop1
;.l1	cmp.b	#$39,kbuff
;	beq.s	.l1

	lea	intro_palbuff,a0
	moveq	#16-1,d0
	jsr	delta_fade_out

	moveq	#16-1,d0
.wait_for_it1	jsr	vsync
	dbf	d0,.wait_for_it1

; credits
	clr.w	intro_rout

	move.l	screen1,d0
	lsr.w	#8,d0
	move.l	d0,$fffff8200.w

	jsr	clearscreen

	jsr	draw_credits
	move.l	#credit_tb,timer_rout
	move.w	#25-1,timer_line

	moveq	#5-1,d0
.fade_loop
	clr.l	credit_col
	clr.w	credit_col+4

.sync1	jsr	vsync
	moveq	#0,d1
	move.b	#8,$fffff8800.w
	move.b	$fffff8800.w,d1
	btst	#4,d1
	bne.s	.sync1
	and.w	#16-1,d1
	cmp.w	#16-1,d1
	blt.s	.sync1

	move.l	#credit_tab,credit_pos
	move.l	credit_pos,a0
	move.l	(a0),credit_col
	move.w	4(a0),credit_col+4

.fade_out1	jsr	vsync
.sync1_a	jsr	vsync

	moveq	#0,d1
	move.b	#8,$fffff8800.w
	move.b	$fffff8800.w,d1
	btst	#4,d1
	bne.s	.sync1_a

	and.w	#16-1,d1
	cmp.w	#16-1,d1
	bge.s	.e1_a

	addq.l	#2*3,credit_pos
	move.l	credit_pos,a0
	move.l	(a0),credit_col
	move.w	4(a0),credit_col+4

	cmp.w	#0,credit_col+4
	bgt.s	.fade_out1

.e1_a
	move.l	#credit_tab,credit_pos
	move.l	credit_pos,a0
	move.l	(a0),credit_col
	move.w	4(a0),credit_col+4


.fade_out1_a	jsr	vsync
	jsr	vsync

	addq.l	#2*3,credit_pos
	move.l	credit_pos,a0
	move.l	(a0),credit_col
	move.w	4(a0),credit_col+4

	cmp.w	#0,credit_col+4
	bgt.s	.fade_out1_a

	add.w	#30,timer_line

;	moveq	#32-1,d1
;.fade_wait	jsr	vsync
;	dbf	d1,.fade_wait

	dbf	d0,.fade_loop

;loop2	cmp.b	#$39,kbuff
;	bne.s	loop2
;.l1	cmp.b	#$39,kbuff
;	beq.s	.l1

	jsr	vsync
	movem.l	blank,d0-d7
	movem.l	d0-d7,intro_palbuff

	move.l	#intro_tb,timer_rout
	move.w	#199,timer_line

	jsr	clearscreen

	jsr	draw_intropic

	moveq	#32-8-1,d0	;16
.wait_for_it2	jsr	vsync
	dbf	d0,.wait_for_it2

.sync2	jsr	vsync
	moveq	#0,d1
	move.b	#8,$fffff8800.w
	move.b	$fffff8800.w,d1
	btst	#4,d1
	bne.s	.sync2

	and.w	#16-1,d1
	cmp.w	#16-1,d1
	blt.s	.sync2

	movem.l	whitepal2,d0-d7
	movem.l	d0-d7,intro_palbuff
	
; logo
	clr.w	intro_rout

	move.l	screen1,d0
	lsr.w	#8,d0
	move.l	d0,$fffff8200.w

	lea	intropic_pal,a0
	lea	intro_palbuff,a1
	moveq	#16-1,d0
	jsr	fade_from_white

;loop3	cmp.b	#$39,kbuff
;	bne.s	loop3
;.l1	cmp.b	#$39,kbuff
;	beq.s	.l1
;
	moveq	#10-1,d0
	jsr	effect_wait

	lea	intro_palbuff,a0
	moveq	#16-1,d0
	jsr	norm_fade_out

************** demo starts here! **************

	jsr	clearscreen

	lea	cool_logo,a0
	jsr	draw_senser_logo
	jsr	draw_lines
	jsr	draw_shadow
	jsr	draw_text

	move.l	#timer_b1,$120.w
	move.l	#vbl,$70.w

	lea	pal,a0
	lea	palbuff,a1
	moveq	#(50+16+6+4)-1,d0
	jsr	delta_fade_in

	st	scroll_flag

loop
	jsr	draw_senser
	cmp.b	#$48,kbuff
	beq	up
	cmp.b	#$50,kbuff
	beq	down
	cmp.b	#$39,kbuff
	beq	select

	cmp.b	#$01,kbuff	; esc - exit
	bne.s	loop

	st	exit_demo_flag

	lea	palbuff,a0
	moveq	#(50+16+6+4)-1,d0
	jsr	delta_fade_out

	move.l	#intro_tb,timer_rout
	move.w	#199,timer_line
	jsr	vsync
	move.l	#timer_b1,$120.w
	move.l	#intro_vbl,$70.w
	jsr	clearscreen
	jsr	vsync
	move.l	#$e0e0707,$fffff8800.w	; off
	move.l	screen1,d0
	lsr.w	#8,d0
	move.l	d0,$fffff8200.w
	jsr	draw_effect_logo

	lea	effect_logo_pal,a0
	lea	intro_palbuff,a1
	moveq	#16-1,d0
	jsr	norm_fade_in

	moveq	#5-1,d0
	jsr	effect_wait

	lea	intro_palbuff,a0
	moveq	#16-1,d0
	jsr	norm_fade_out

	jsr	vsync

	jsr	restore_ints
	move.l	#$e0e0707,$fffff8800.w	; off

	jsr	silence

	movem.l	blank,d0-d7
	movem.l	d0-d7,$fffff8240.w

	jsr	clearscreen

	moveq	#$16,d0
	jsr	ikbd
	moveq	#$8,d0
	jsr	ikbd
	jsr	flush

	jsr	vsync

	move.l	oldphys,$fffff8200.w
	move.b	oldrez,$fffff8260.w
	move.b	oldhz,$fffff820a.w

	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$fffff8240.w

quit2	move.l	old_stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#4,sp

quit1	clr.w	-(sp)
	trap	#1

up	subq.w	#1,tune_num
	cmp.w	#0,tune_num
	bpl.s	.s1
	clr.w	tune_num
	clr.w	arrow_offset
	bra.s	.e1
.s1
	moveq	#8-1,d0
.l1	jsr	vsync
	sub.w	#160,arrow_offset
	dbf	d0,.l1

.e1	jsr	flush
	bra	loop

down	addq.w	#1,tune_num
	cmp.w	#max_tunes-1,tune_num
	ble.s	.s1
	move.w	#max_tunes-1,tune_num
	move.w	#(160*8)*(max_tunes-1),arrow_offset
	bra.s	.e1
.s1
	moveq	#8-1,d0
.l1	jsr	vsync
	add.w	#160,arrow_offset
	dbf	d0,.l1

.e1	jsr	flush
	bra	loop

select	cmp.b	#$39,kbuff
	beq.s	select

	jsr	vsync
	jsr	init_deinit_music
	jsr	flush
	bra	loop

quiet	move.l	#$8080000,$fffff8800.w
	move.l	#$9090000,$fffff8800.w
	move.l	#$a0a0000,$fffff8800.w
	bra	music_return

vbl	clr.b	$fffffa1b.w
	move.b	#82,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#timer_b1,$120.w
	move.l	#hbl,$68.w
	addq.w	#1,$466+2.w
	clr.b	$fffff8260.w
	move.b	#2,$fffff820a.w
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	palbuff,d0-d7
	movem.l	d0-d7,$fffff8240.w
	jsr	do_fade

	tst.b	replay_flag
	bmi	quiet
	jsr	play
music_return

	jsr	control_logo
	jsr	clear_balls
	jsr	draw_arrows
	jsr	scroll
	jsr	draw_balls
	jsr	do_reflection
	jsr	draw_vu
	jsr	do_drive_flash
	jsr	draw_dist
	jsr	swap_screens
	movem.l	(sp)+,d0-d7/a0-a6
hbl
	rte

timer_b1
x	set	0
	rept	8
	move.l	textpalbuff+x,$fffff8240+x.w
x	set	x+4
	endr
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#timer_b2,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b2	move.w	backpalbuff,$fffff8240.w
	clr.b	$fffffa1b.w
	move.b	#34,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#timer_b3,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b3	move.w	musicpalbuff,$fffff8240+14.w
	move.w	musicpalbuff,$fffff8240+22.w
	move.w	musicpalbuff,$fffff8240+30.w
	clr.b	$fffffa1b.w
	move.b	#8,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#timer_b4,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b4	move.w	musicpalbuff+2,$fffff8240+14.w
	move.w	musicpalbuff+2,$fffff8240+22.w
	move.w	musicpalbuff+2,$fffff8240+30.w
	move.l	#timer_b5,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b5	move.w	musicpalbuff+4,$fffff8240+14.w
	move.w	musicpalbuff+4,$fffff8240+22.w
	move.w	musicpalbuff+4,$fffff8240+30.w
	move.l	#timer_b6,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b6	move.w	musicpalbuff+6,$fffff8240+14.w
	move.w	musicpalbuff+6,$fffff8240+22.w
	move.w	musicpalbuff+6,$fffff8240+30.w
	move.l	#timer_b7,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b7	move.w	musicpalbuff+8,$fffff8240+14.w
	move.w	musicpalbuff+8,$fffff8240+22.w
	move.w	musicpalbuff+8,$fffff8240+30.w
	move.l	#timer_b8,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b8	move.w	musicpalbuff+10,$fffff8240+14.w
	move.w	musicpalbuff+10,$fffff8240+22.w
	move.w	musicpalbuff+10,$fffff8240+30.w
	move.l	#timer_b9,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b9	move.w	musicpalbuff+12,$fffff8240+14.w
	move.w	musicpalbuff+12,$fffff8240+22.w
	move.w	musicpalbuff+12,$fffff8240+30.w
	move.l	#timer_b10,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b10	move.w	musicpalbuff+14,$fffff8240+14.w
	move.w	musicpalbuff+14,$fffff8240+22.w
	move.w	musicpalbuff+14,$fffff8240+30.w
	move.l	#timer_b11,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b11	move.w	musicpalbuff+16,$fffff8240+14.w
	move.w	musicpalbuff+16,$fffff8240+22.w
	move.w	musicpalbuff+16,$fffff8240+30.w
	move.l	#timer_b12,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b12	move.w	musicpalbuff+18,$fffff8240+14.w
	move.w	musicpalbuff+18,$fffff8240+22.w
	move.w	musicpalbuff+18,$fffff8240+30.w
	clr.b	$fffffa1b.w
	move.b	#9,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#lower_border,$120.w
	bclr	#0,$fffffa0f.w
	rte

lower_border	move.w	whitepalbuff,$fffff8240+14.w
	move.w	whitepalbuff,$fffff8240+22.w
	move.w	whitepalbuff,$fffff8240+30.w
	move.w	d0,-(sp)
	move.b	$fffffa21.w,d0
.l1	cmp.b	$fffffa21.w,d0
	beq.s	.l1
	clr.b	$fffff820a.w
	dcb.w	17,$4e71
	move.b	#2,$ffffff820a.w
	move.w	(sp)+,d0
	clr.b	$fffffa1b.w
	move.b	#17,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#lower_tb0,$120.w
	bclr	#0,$fffffa0f.w
	rte

lower_tb0	move.w	bottompalbuff,$fffff8240+2.w
	move.w	bottompalbuff+2,$fffff8240+16.w
	move.w	bottompalbuff+4,$fffff8240+24.w
	move.w	bottompalbuff+6,$fffff8240+4.w
	clr.b	$fffffa1b.w
	move.b	#7-2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#lower_tb1,$120.w
	bclr	#0,$fffffa0f.w
	rte

lower_tb1	move.w	textpalbuff+2,$fffff8240+2.w
	move.w	textpalbuff+16,$fffff8240+16.w
	move.w	textpalbuff+24,$fffff8240+24.w
	clr.b	$fffffa1b.w
	move.b	#9+2+8+8,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#lower_tb2,$120.w
	bclr	#0,$fffffa0f.w
	rte

lower_tb2	move.l	d0,-(sp)
	move.w	backpalbuff,d0
	swap	d0
	move.w	backpalbuff,d0
	move.l	d0,$fffff8240.w
	move.l	d0,$fffff8240+4.w
	move.l	d0,$fffff8240+8.w
	move.l	d0,$fffff8240+12.w
	move.l	d0,$fffff8240+16.w
	move.l	d0,$fffff8240+20.w
	move.l	d0,$fffff8240+24.w
	move.l	d0,$fffff8240+28.w
	move.l	(sp)+,d0
	clr.b	$fffffa1b.w
	move.b	#-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.n1,$120.w
.n1	bclr	#0,$fffffa0f.w
plain_rte	rte

intro_vbl	clr.b	$fffffa1b.w
	move.b	timer_line+1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	timer_rout,$120.w
	move.l	#hbl,$68.w
	addq.w	#1,$466+2.w
	clr.b	$fffff8260.w
	move.b	#2,$fffff820a.w
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	intro_palbuff,d0-d7
	movem.l	d0-d7,$ffffff8240.w
	jsr	do_intro_stuff

	jsr	play

	movem.l	(sp)+,d0-d7/a0-a6
	rte

intro_tb	bclr	#0,$fffffa0f.w
	rte

credit_tb
	move.l	credit_col,$fffff8242.w
	move.w	credit_col+4,$fffff8242+4.w
	clr.b	$fffffa1b.w
	move.b	#30,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#credit_tb1,$120.w
	bclr	#0,$fffffa0f.w
	rte

credit_tb1	clr.l	$fffff8242.w
	clr.w	$fffff8242+4.w
	clr.b	$fffffa1b.w
	move.b	#-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.n1,$120.w
.n1	bclr	#0,$fffffa0f.w
	rte

do_intro_stuff	moveq	#0,d0
	move.w	intro_rout,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)

.tab	dc.l	null
	dc.l	do_intro_balls

do_intro_balls	jsr	clear_intro_balls
	jsr	draw_intro_balls
	jsr	swap_screens
null	rts

draw_intro_balls
	move.l	rotate_pos,a0
	move.l	screen1,a4
	lea	8*4(a4),a4
	move.l	old_intro_ball_pos1,a5

	rept	num_intro_balls
	lea	intro_ball_gfx,a1
	move.l	a4,a2
	add.w	(a0)+,a1
	add.w	(a0)+,a2
	move.l	a2,(a5)+

	movem.l	(a1)+,d0-d7
	or.l	d0,(a2)
	or.l	d1,8(a2)
	or.l	d2,(160*1)(a2)
	or.l	d3,(160*1)+8(a2)
	or.l	d4,(160*2)(a2)
	or.l	d5,(160*2)+8(a2)
	or.l	d6,(160*3)(a2)
	or.l	d7,(160*3)+8(a2)

	movem.l	(a1)+,d0-d7
	or.l	d0,(160*4)(a2)
	or.l	d1,(160*4)+8(a2)
	or.l	d2,(160*5)(a2)
	or.l	d3,(160*5)+8(a2)
	or.l	d4,(160*6)(a2)
	or.l	d5,(160*6)+8(a2)
	or.l	d6,(160*7)(a2)
	or.l	d7,(160*7)+8(a2)

	endr
bodend
	cmp.l	#rotate_end,a0
	blt.s	.s2
	lea	rotate_tab,a0
.s2
	move.l	a0,rotate_pos

	move.l	old_intro_ball_pos1,d0
	move.l	old_intro_ball_pos2,old_intro_ball_pos1
	move.l	d0,old_intro_ball_pos2

	rts

clear_intro_balls
	moveq	#0,d0
	move.l	old_intro_ball_pos1,a0
	rept	num_intro_balls
	move.l	(a0)+,a1
	move.l	d0,(a1)
	move.l	d0,(8*1)(a1)
	move.l	d0,(160*1)(a1)
	move.l	d0,(160*1)+(8*1)(a1)
	move.l	d0,(160*2)(a1)
	move.l	d0,(160*2)+(8*1)(a1)
	move.l	d0,(160*3)(a1)
	move.l	d0,(160*3)+(8*1)(a1)
	move.l	d0,(160*4)(a1)
	move.l	d0,(160*4)+(8*1)(a1)
	move.l	d0,(160*5)(a1)
	move.l	d0,(160*5)+(8*1)(a1)
	move.l	d0,(160*6)(a1)
	move.l	d0,(160*6)+(8*1)(a1)
	move.l	d0,(160*7)(a1)
	move.l	d0,(160*7)+(8*1)(a1)
	endr
	rts

init_intro_balls	move.l	screen1,a0
	move.l	screen2,a1
	lea	old_intro_ball1,a2
	lea	old_intro_ball2,a3
	moveq	#num_intro_balls-1,d0
.l1	move.l	a0,(a2)+
	move.l	a1,(a3)+
	dbf	d0,.l1
	rts


shift_intro_ball
	lea	intro_ball,a0
	lea	intro_ball_gfx,a1
	moveq	#8-1,d0
.l1	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	dbf	d0,.l1

	lea	intro_ball_gfx,a0

	moveq	#15-1,d1
.l4	move.l	a1,a2
	moveq	#8-1,d0
.l2
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.l2
	move.l	a2,a1

	moveq	#8-1,d0
.l3
x	set	0
	rept	2
	roxr.w	x(a1)
	roxr.w	x+4(a1)
x	set	x+2
	endr

	addq.w	#8,a1
	dbf	d0,.l3
	dbf	d1,.l4
	rts

draw_vu	move.l	screen1,a1
	lea	(160*158)+(8*19)(a1),a1

	move.w	#%1000000000000000,d0
x	set	0
	rept	16
	move.w	d0,x(a1)
	move.w	d0,x+160(a1)
	move.w	d0,x+(160*2)(a1)
x	set	x+(160*3)
	endr

	moveq	#0,d0
	move.b	#8,$fffff8800.w
	move.b	$fffff8800.w,d0
	btst	#4,d0
	beq.s	.s1
	moveq	#10-1,d0
.s1	and.w	#16-1,d0
	add.w	d0,d0
	lea	bar1,a0
	add.w	d0,a0
x	set	0
	rept	2
	movem.w	(a0)+,d0-d7
	or.w	d0,x(a1)
	or.w	d0,x+(160*1)(a1)
	or.w	d0,x+(160*2)(a1)
	or.w	d1,x+(160*3)(a1)
	or.w	d1,x+(160*4)(a1)
	or.w	d1,x+(160*5)(a1)
	or.w	d2,x+(160*6)(a1)
	or.w	d2,x+(160*7)(a1)
	or.w	d2,x+(160*8)(a1)
	or.w	d3,x+(160*9)(a1)
	or.w	d3,x+(160*10)(a1)
	or.w	d3,x+(160*11)(a1)
	or.w	d4,x+(160*12)(a1)
	or.w	d4,x+(160*13)(a1)
	or.w	d4,x+(160*14)(a1)
	or.w	d5,x+(160*15)(a1)
	or.w	d5,x+(160*16)(a1)
	or.w	d5,x+(160*17)(a1)
	or.w	d6,x+(160*18)(a1)
	or.w	d6,x+(160*19)(a1)
	or.w	d6,x+(160*20)(a1)
	or.w	d7,x+(160*21)(a1)
	or.w	d7,x+(160*22)(a1)
	or.w	d7,x+(160*23)(a1)
x	set	x+(160*24)
	endr

	moveq	#0,d0
	move.b	#9,$fffff8800.w
	move.b	$fffff8800.w,d0
	btst	#4,d0
	beq.s	.s2
	moveq	#10-1,d0
.s2	and.w	#16-1,d0

	add.w	d0,d0
	lea	bar2,a0
	add.w	d0,a0
x	set	0
	rept	2
	movem.w	(a0)+,d0-d7
	or.w	d0,x(a1)
	or.w	d0,x+(160*1)(a1)
	or.w	d0,x+(160*2)(a1)
	or.w	d1,x+(160*3)(a1)
	or.w	d1,x+(160*4)(a1)
	or.w	d1,x+(160*5)(a1)
	or.w	d2,x+(160*6)(a1)
	or.w	d2,x+(160*7)(a1)
	or.w	d2,x+(160*8)(a1)
	or.w	d3,x+(160*9)(a1)
	or.w	d3,x+(160*10)(a1)
	or.w	d3,x+(160*11)(a1)
	or.w	d4,x+(160*12)(a1)
	or.w	d4,x+(160*13)(a1)
	or.w	d4,x+(160*14)(a1)
	or.w	d5,x+(160*15)(a1)
	or.w	d5,x+(160*16)(a1)
	or.w	d5,x+(160*17)(a1)
	or.w	d6,x+(160*18)(a1)
	or.w	d6,x+(160*19)(a1)
	or.w	d6,x+(160*20)(a1)
	or.w	d7,x+(160*21)(a1)
	or.w	d7,x+(160*22)(a1)
	or.w	d7,x+(160*23)(a1)
x	set	x+(160*24)
	endr

	moveq	#0,d0
	move.b	#10,$fffff8800.w
	move.b	$fffff8800.w,d0
	btst	#4,d0
	beq.s	.s3
	moveq	#10-1,d0
.s3	and.w	#16-1,d0
	add.w	d0,d0
	lea	bar3,a0
	add.w	d0,a0

x	set	0
	rept	2
	movem.w	(a0)+,d0-d7
	or.w	d0,x(a1)
	or.w	d0,x+(160*1)(a1)
	or.w	d0,x+(160*2)(a1)
	or.w	d1,x+(160*3)(a1)
	or.w	d1,x+(160*4)(a1)
	or.w	d1,x+(160*5)(a1)
	or.w	d2,x+(160*6)(a1)
	or.w	d2,x+(160*7)(a1)
	or.w	d2,x+(160*8)(a1)
	or.w	d3,x+(160*9)(a1)
	or.w	d3,x+(160*10)(a1)
	or.w	d3,x+(160*11)(a1)
	or.w	d4,x+(160*12)(a1)
	or.w	d4,x+(160*13)(a1)
	or.w	d4,x+(160*14)(a1)
	or.w	d5,x+(160*15)(a1)
	or.w	d5,x+(160*16)(a1)
	or.w	d5,x+(160*17)(a1)
	or.w	d6,x+(160*18)(a1)
	or.w	d6,x+(160*19)(a1)
	or.w	d6,x+(160*20)(a1)
	or.w	d7,x+(160*21)(a1)
	or.w	d7,x+(160*22)(a1)
	or.w	d7,x+(160*23)(a1)
x	set	x+(160*24)
	endr

	rts

do_drive_flash	tst.b	scroll_flag
	bpl.s	.e1
	moveq	#0,d0
	move.w	channel,d0
	move.b	d0,$fffff8800.w
	move.b	$fffff8800.w,d0
	btst	#4,d0	; envelope?
	beq.s	.s1
	moveq	#10-1,d0	; yes - manually set vol
.s1	and.w	#16-1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.disk_tab(pc,d0.w),a0
	jmp	(a0)

.on	move.l	#$e0e0505,$fffff8800.w
	sf	drive_flag
	rts

.dim	move.l	#$e0e0505,$fffff8800.w

;	move.w	#400-1,d0
;.l1	dbf	d0,.l1

	not.b	drive_flag
	tst.b	drive_flag
	bpl.s	.e1
	move.l	#$e0e0707,$fffff8800.w
.e1	rts

.off	move.l	#$e0e0707,$fffff8800.w
	sf	drive_flag
	rts

.disk_tab	rept	8
	dc.l	.off
	endr
	dc.l	.dim
	dc.l	.dim
	dc.l	.dim
	dc.l	.dim
	dc.l	.on
	dc.l	.on
	dc.l	.on
	dc.l	.on

do_fade	tst.b	scroll_flag
	bpl.s	fade_return

	moveq	#0,d0
	move.w	fade_rout,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)

.tab	dc.l	fade_in_balls
	dc.l	wait
	dc.l	fade_out_balls
	dc.l	inc_rout

fade_in_balls	addq.l	#2,fade_in_ball_pos
	cmp.l	#fade_in_ball_end,fade_in_ball_pos
	blt.s	.s1
	move.w	#1,fade_rout
	move.w	#(ball_wait*50)-1,fade_time
	bra.s	fade_return
.s1
	move.l	fade_in_ball_pos,a0
	move.w	(a0),textpalbuff+8

fade_return	rts

wait	subq.w	#1,fade_time
	tst.w	fade_time
	bpl.s	.s1
	move.l	#fade_out_ball_tab,fade_out_ball_pos
	move.w	#2,fade_rout
.s1	rts

fade_out_balls
	addq.l	#2,fade_out_ball_pos
	cmp.l	#fade_out_ball_end,fade_out_ball_pos
	blt.s	.s1
	move.l	#fade_in_ball_tab,fade_in_ball_pos
	move.w	#3,fade_rout
	bra.s	.e1
.s1
	move.l	fade_out_ball_pos,a0
	move.w	(a0),textpalbuff+8

.e1	rts

inc_rout	addq.w	#1,ball_rout
	cmp.w	#4-1,ball_rout
	ble.s	.s1
	clr.w	ball_rout
.s1	clr.w	fade_rout
	move.l	#ab_tab,ab_pos
	move.l	#cube_tab,cube_pos
	move.l	#eft_tab,eft_pos
	move.l	#cross_tab,cross_pos
	rts

draw_balls	moveq	#0,d0
	move.w	ball_rout,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)

.tab	dc.l	do_balls1
	dc.l	do_balls2
	dc.l	do_balls3
	dc.l	do_balls4

do_balls1	add.l	#(4*35),eft_pos
	cmp.l	#eft_tab_end,eft_pos
	blt.s	.s1
	move.l	#eft_tab,eft_pos
.s1
	move.l	eft_pos,a0
	moveq	#35-1,d6
	bra.s	do_balls

do_balls2	add.l	#(4*44),cube_pos
	cmp.l	#cube_tab_end,cube_pos
	blt.s	.s1
	move.l	#cube_tab,cube_pos
.s1
	move.l	cube_pos,a0
	moveq	#44-1,d6
	bra.s	do_balls

do_balls3	add.l	#(4*25),ab_pos
	cmp.l	#ab_tab_end,ab_pos
	blt.s	.s1
	move.l	#ab_tab,ab_pos
.s1
	move.l	ab_pos,a0
	moveq	#25-1,d6
	bra.s	do_balls

do_balls4	add.l	#(4*31),cross_pos
	cmp.l	#cross_tab_end,cross_pos
	blt.s	.s1
	move.l	#cross_tab,cross_pos
.s1
	move.l	cross_pos,a0
	moveq	#31-1,d6

do_balls	move.l	screen1,a3
	lea	(160*85)+4(a3),a3

.l1	lea	ball_gfx,a1
	move.l	a3,a2
	add.w	(a0)+,a1
	add.w	(a0)+,a2

	movem.w	(a1)+,d0-d5
	or.w	d0,(a2)
	or.w	d1,8(a2)
	or.w	d2,(160*1)(a2)
	or.w	d3,(160*1)+8(a2)
	or.w	d4,(160*2)(a2)
	or.w	d5,(160*2)+8(a2)
	movem.w	(a1)+,d0-d5
	or.w	d0,(160*3)(a2)
	or.w	d1,(160*3)+8(a2)
	or.w	d2,(160*4)(a2)
	or.w	d3,(160*4)+8(a2)
	or.w	d4,(160*5)(a2)
	or.w	d5,(160*5)+8(a2)
	movem.w	(a1)+,d0-d5
	or.w	d0,(160*6)(a2)
	or.w	d1,(160*6)+8(a2)
	or.w	d2,(160*7)(a2)
	or.w	d3,(160*7)+8(a2)
	or.w	d4,(160*8)(a2)
	or.w	d5,(160*8)+8(a2)
	movem.w	(a1)+,d0-d5
	or.w	d0,(160*9)(a2)
	or.w	d1,(160*9)+8(a2)
	or.w	d2,(160*10)(a2)
	or.w	d3,(160*10)+8(a2)
	or.w	d4,(160*11)(a2)
	or.w	d5,(160*11)+8(a2)
	movem.w	(a1)+,d0-d5
	or.w	d0,(160*12)(a2)
	or.w	d1,(160*12)+8(a2)
	or.w	d2,(160*13)(a2)
	or.w	d3,(160*13)+8(a2)
	or.w	d4,(160*14)(a2)
	or.w	d5,(160*14)+8(a2)
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	or.w	d0,(160*15)(a2)
	or.w	d1,(160*15)+8(a2)
	dbf	d6,.l1
	rts

clear_balls	moveq	#0,d0
	move.l	screen1,a1
	lea	(160*85)+4(a1),a1
x	set	0
	rept	(16*7)+9
	move.w	d0,x(a1)
	move.w	d0,x+(8*1)(a1)
	move.w	d0,x+(8*2)(a1)
	move.w	d0,x+(8*3)(a1)
	move.w	d0,x+(8*4)(a1)
	move.w	d0,x+(8*5)(a1)
	move.w	d0,x+(8*6)(a1)
	move.w	d0,x+(8*7)(a1)
x	set	x+160
	endr
	rts

draw_arrows	moveq	#0,d1
	move.l	arrow_pos1,a0
	move.w	(a0)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	lea	arrow_sin_tab,a0
	move.w	(a0)+,d0
.s1	move.l	a0,arrow_pos1

	add.w	d0,d0
	add.w	d0,d0
	lea	arrow_tab1,a0
	add.w	d0,a0
	move.l	(a0),a0
	move.l	screen1,a1
	lea	(160*118)+(8*9)(a1),a1
	add.w	arrow_offset,a1

x	set	-(160*2)
	move.l	d1,x(a1)
	move.l	d1,x+8(a1)
x	set	x+160
	move.l	d1,x(a1)
	move.l	d1,x+8(a1)
x	set	x+160
	rept	8
	move.l	(a0)+,x(a1)
	move.l	(a0)+,x+8(a1)
x	set	x+160
	endr
	move.l	d1,x(a1)
	move.l	d1,x+8(a1)
x	set	x+160
	move.l	d1,x(a1)
	move.l	d1,x+8(a1)

	move.l	arrow_pos2,a0
	move.w	(a0)+,d0
	cmp.w	#-1,d0
	bne.s	.s2
	lea	arrow_sin_tab,a0
	move.w	(a0)+,d0
.s2	move.l	a0,arrow_pos2

	add.w	d0,d0
	add.w	d0,d0
	lea	arrow_tab2,a0
	add.w	d0,a0
	move.l	(a0),a0
	move.l	screen1,a1
	lea	(160*118)+(8*17)(a1),a1
	add.w	arrow_offset,a1

x	set	-(160*2)
	move.l	d1,x(a1)
	move.l	d1,x+8(a1)
x	set	x+160
	move.l	d1,x(a1)
	move.l	d1,x+8(a1)
x	set	x+160
	rept	8
	move.l	(a0)+,x(a1)
	move.l	(a0)+,x+8(a1)
x	set	x+160
	endr
	move.l	d1,x(a1)
	move.l	d1,x+8(a1)
x	set	x+160
	move.l	d1,x(a1)
	move.l	d1,x+8(a1)
	rts

draw_dist	add.l	#2*8,sin_pos1
	cmp.l	#sin_end,sin_pos1
	blt.s	.s1
	move.l	#sin_tab,sin_pos1
.s1
	sub.l	#2*12,sin_pos2
	cmp.l	#sin_tab,sin_pos2
	bgt.s	.s2
	move.l	#sin_end,sin_pos2
.s2
	move.l	sin_pos1,a0
	move.l	sin_pos2,a1

	move.l	screen1,a4
	lea	(160*94)+(8*9)+4(a4),a4

x	set	0
	rept	112
	lea	dist_gfx,a2
	add.w	(a0),a2
	add.w	(a1),a2
	movem.l	(a2),d0-d7/a2-a3
	move.l	d0,x+(8*0)(a4)
	move.l	d1,x+(8*1)(a4)
	move.l	d2,x+(8*2)(a4)
	move.l	d3,x+(8*3)(a4)
	move.l	d4,x+(8*4)(a4)
	move.l	d5,x+(8*5)(a4)
	move.l	d6,x+(8*6)(a4)
	move.l	d7,x+(8*7)(a4)
	move.l	a2,x+(8*8)(a4)
	move.l	a3,x+(8*9)(a4)
	lea	2*8(a0),a0
	lea	2*12(a1),a1
x	set	x+160
	endr

	lea	(2*8)*11(a0),a0
	lea	(2*12)*11(a1),a1

	lea	160*123(a4),a4

x	set	0
	rept	14
	lea	dist_gfx,a2
	add.w	(a0),a2
	add.w	(a1),a2
	movem.l	(a2),d0-d7/a2-a3
	move.l	d0,x+(8*0)(a4)
	move.l	d1,x+(8*1)(a4)
	move.l	d2,x+(8*2)(a4)
	move.l	d3,x+(8*3)(a4)
	move.l	d4,x+(8*4)(a4)
	move.l	d5,x+(8*5)(a4)
	move.l	d6,x+(8*6)(a4)
	move.l	d7,x+(8*7)(a4)
	move.l	a2,x+(8*8)(a4)
	move.l	a3,x+(8*9)(a4)
	lea	2*8(a0),a0
	lea	2*12(a1),a1
x	set	x+160
	endr

	rts

scroll	tst.b	scroll_flag
	bpl	.e1

	subq.w	#1,scr_cnt
	cmp.w	#0,scr_cnt
	bgt.s	.s1
	move.w	#8,scr_cnt
	move.l	scrollpos,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#-1,d0
	bne.s	.n1
	lea	scrolltext,a0
	move.b	(a0)+,d0
.n1	move.l	a0,scrollpos
	sub.b	#$20,d0
	lsl.w	#3,d0
	lea	font,a0
	add.w	d0,a0
	lea	fontbuff,a1
x	set	0
	rept	8
	move.b	(a0)+,x(a1)
x	set	x+2
	endr
.s1
	lea	fontbuff,a0
	lea	scrollbuff,a1
	moveq	#8-1-1,d0
.l1	roxl.w	(a0)+
x	set	38
	rept	20
	roxl.w	x(a1)
x	set	x-2
	endr
	lea	40(a1),a1
	dbf	d0,.l1

.e1	lea	scrollbuff,a0
	move.l	screen1,a1
	add.l	#160*208,a1

	moveq	#8-1-1,d0
.l3
x	set	0
	rept	20
;	move.w	(a0),x(a1)
	move.w	(a0)+,x(a1)
x	set	x+8
	endr
	lea	160(a1),a1
	dbf	d0,.l3

	move.w	#%1000000000000000,d0
	move.w	#%0000000000000001,d1

	move.l	screen1,a1
	add.l	#160*207,a1

x	set	0
	rept	9
	or.w	d0,x(a1)
	or.w	d1,x+(8*19)(a1)
x	set	x+160
	endr
	rts

draw_shadow	moveq	#-1,d0
	move.w	#%1111111111111110,d1
	move.w	#%0111111111111111,d2
	move.w	#%0000000011111111,d3
	move.l	screen1,a0
	move.l	screen2,a1
	add.l	#(160*217)+2,a0
	add.l	#(160*217)+2,a1

	moveq	#5-1,d4
.l1
x	set	0
	move.w	d3,x(a0)
	move.w	d3,x(a1)
x 	set	x+8

	rept	7
	move.w	d0,x(a0)
	move.w	d0,x(a1)
x	set	x+8
	endr
	move.w	d1,x(a0)
	move.w	d1,x(a1)

	move.w	d2,x+(8*11)(a0)
	move.w	d2,x+(8*11)(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	dbf	d4,.l1
	rts

draw_lines	jsr	do_vert

do_hori	moveq	#-1,d0
	moveq	#0,d1
	move.l	screen1,a0
	move.l	screen2,a1
	add.l	#160*206,a0
	add.l	#160*206,a1

	moveq	#20-1,d2
.l1
	move.w	d0,(a0)
	move.w	d0,(a1)
	addq.w	#8,a0
	addq.w	#8,a1
	dbf	d2,.l1

	move.w	#(20*9)-1,d2
.l2
	move.w	d1,(a0)
	move.w	d1,(a1)
	addq.w	#8,a0
	addq.w	#8,a1
	dbf	d2,.l2

	moveq	#20-1,d2
.l3
	move.w	d0,(a0)
	move.w	d0,(a1)
	addq.w	#8,a0
	addq.w	#8,a1
	dbf	d2,.l3
	rts

do_vert	move.w	#%0000000000000001,d0
	move.w	#%1000000000000000,d1

	move.l	screen1,a0
	move.l	screen2,a1
	move.l	screen1,a2
	move.l	screen2,a3
	lea	(160*93)+(8*8)(a0),a0
	lea	(160*93)+(8*8)(a1),a1
	lea	(160*93)+(8*19)(a2),a2
	lea	(160*93)+(8*19)(a3),a3

	moveq	#-1,d2
	move.l	a0,a4
	move.l	a1,a5
x	set	0
	rept	14-4
	move.w	d2,x+8(a4)
	move.w	d2,x+8(a5)
	move.w	d2,x+(160*138)+8(a4)
	move.w	d2,x+(160*138)+8(a5)
x	set	x+8
	endr

	move.w	#139-1,d2
.l1
	move.w	d0,(a0)
	move.w	d0,(a1)
	move.w	d1,(a2)
	move.w	d1,(a3)

	lea	160(a0),a0
	lea	160(a1),a1
	lea	160(a2),a2
	lea	160(a3),a3
	dbf	d2,.l1
return	rts

do_reflection
	move.l	screen1,a0
	move.l	screen1,a1

	add.l	#(160*205)+4,a0
	add.l	#(160*222)+4,a1
	
x	set	0
y	set	0
	rept	11+8+8
	move.w	x(a0),y(a1)
	move.w	x+(8*1)(a0),y+(8*1)(a1)
	move.w	x+(8*2)(a0),y+(8*2)(a1)
	move.w	x+(8*3)(a0),y+(8*3)(a1)
	move.w	x+(8*4)(a0),y+(8*4)(a1)
	move.w	x+(8*5)(a0),y+(8*5)(a1)
	move.w	x+(8*6)(a0),y+(8*6)(a1)
	move.w	x+(8*7)(a0),y+(8*7)(a1)
	move.w	x+(8*8)(a0),y+(8*8)(a1)
x	set	x-(160*2)
y	set	y+160
	endr
	rts

control_logo	tst.b	exit_demo_flag
	bmi	return
	tst.b	scroll_flag
	bpl	return

	moveq	#0,d0
	move.w	logo_rout,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)

.tab	dc.l	logo_wait	; stax
	dc.l	fade_out_logo1
	dc.l	set_logo1

	dc.l	fade_in_logo2
	dc.l	logo_wait	; eft 2
	dc.l	fade_out_logo2
	dc.l	set_logo2

	dc.l	fade_in_logo1_a

fade_in_logo1	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s0
	move.w	#4-1,fade_cnt

	add.l	#2*16,fade_pos1
	cmp.l	#fade_tab1_end,fade_pos1
	blt.s	.s0
	move.l	#fade_tab1,fade_pos1
	addq.w	#1,logo_rout

	bra.s	.s1
.s0	move.l	fade_pos1,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,palbuff

.s1	rts

fade_out_logo1
	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s0
	move.w	#4-1,fade_cnt

	add.l	#2*16,fade_pos2
	cmp.l	#fade_tab2_end,fade_pos2
	blt.s	.s0
	move.l	#fade_tab2,fade_pos2
	addq.w	#1,logo_rout

	bra.s	.s1
.s0	move.l	fade_pos2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,palbuff

.s1	rts

fade_in_logo2	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s0
	move.w	#4-1,fade_cnt

	add.l	#2*16,fade_pos1
	cmp.l	#fade_tab1_end,fade_pos1
	blt.s	.s0
	move.l	#fade_tab1,fade_pos1
	addq.w	#1,logo_rout

	bra.s	.s1
.s0	move.l	fade_pos1,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,palbuff

.s1	rts

fade_out_logo2
	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s0
	move.w	#4-1,fade_cnt

	add.l	#2*16,fade_pos2
	cmp.l	#fade_tab2_end,fade_pos2
	blt.s	.s0
	move.l	#fade_tab2,fade_pos2
	addq.w	#1,logo_rout

	bra.s	.s1
.s0	move.l	fade_pos2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,palbuff

.s1	rts

fade_in_logo1_a	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s0
	move.w	#4-1,fade_cnt

	add.l	#2*16,fade_pos1
	cmp.l	#fade_tab1_end,fade_pos1
	blt.s	.s0
	move.l	#fade_tab1,fade_pos1
	clr.w	logo_rout

	bra.s	.s1
.s0	move.l	fade_pos1,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,palbuff

.s1	rts


set_logo1	move.l	#eft_top,logo_pos
	st	senser_flag
	subq.w	#1,set_cnt
	tst.w	set_cnt
	bpl.s	.s1
	sf	senser_flag
	move.w	#16,set_cnt
	addq.w	#1,logo_rout
.s1	rts


set_logo2	move.l	#cool_logo,logo_pos
	st	senser_flag
	subq.w	#1,set_cnt
	tst.w	set_cnt
	bpl.s	.s1
	sf	senser_flag
	move.w	#16,set_cnt
	addq.w	#1,logo_rout
.s1	rts

logo_wait	subq.w	#1,wait_cnt
	tst.w	wait_cnt
	bpl.s	.s1
	move.w	#50*10,wait_cnt
	addq.w	#1,logo_rout
.s1	rts

draw_senser	tst.b	senser_flag
	bpl	skip

	move.l	logo_pos,a0
draw_senser_logo
	move.l	screen1,a1
	move.l	screen2,a2
x	set	0
	rept	266
	movem.l	(a0)+,d0-d7/a3-a6
	movem.l	d0-d7/a3-a6,x(a1)
	movem.l	d0-d7/a3-a6,x(a2)
x	set	x+48
	endr
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,x(a1)
	movem.l	d0-d7,x(a2)
skip	rts

draw_text	lea	text,a0
	move.l	a0,a1
	move.l	screen1,a2
	move.l	screen2,a3
	lea	(160*101)+(8*9)(a2),a2
	lea	(160*101)+(8*9)(a3),a3
	moveq	#9-1,d1
.l2	moveq	#10-1,d0
.l1	move.l	(a0)+,(a2)
	move.l	(a1)+,(a3)
	addq.w	#8,a2
	addq.w	#8,a3
	dbf	d0,.l1
	lea	160-(8*10)(a2),a2
	lea	160-(8*10)(a3),a3
	dbf	d1,.l2

	lea	(160*8)(a2),a2
	lea	(160*8)(a3),a3

	moveq	#((8*10)+1)-1,d1
.l4	moveq	#10-1,d0
.l3	move.l	(a0)+,(a2)
	move.l	(a1)+,(a3)
	addq.w	#8,a2
	addq.w	#8,a3
	dbf	d0,.l3
	lea	160-(8*10)(a2),a2
	lea	160-(8*10)(a3),a3
	dbf	d1,.l4
	rts

init_deinit_music
	tst.b	deinit_flag
	bpl.s	.s1

	tst.b	exit_flag
	bmi	.s2

	move.w	current_tune,d0
	move.w	tune_num,d1
	cmp.w	d0,d1
	beq	.e1

	st	replay_flag
	jsr	stop
	jsr	silence

.s1	st	deinit_flag

	move.w	tune_num,d0
	mulu	#10,d0
	lea	music_table,a0
	add.w	d0,a0
	move.w	(a0)+,current_tune
	move.l	(a0)+,music_addr
	move.w	(a0)+,channel
	move.w	(a0)+,music_flag

	st	replay_flag

	tst.b	first_run_flag
	bpl.s	.s3
	move.l	#$07770777,musicpalbuff
	move.l	#$07770777,musicpalbuff+4
	move.l	#$07770777,musicpalbuff+8
	move.l	#$07770777,musicpalbuff+12
	move.l	#$07770777,musicpalbuff+16
	move.w	tune_num,d0
	add.w	d0,d0
	lea	musicpalbuff,a0
	add.w	d0,a0
	move.w	#$333,(a0)
.s3	st	first_run_flag

	jsr	start

;	move.b	#%00000001,$fffffa07.w	; timer b
;	move.b	#%00000001,$fffffa13.w	; timer b

	sf	replay_flag
.e1	rts

.s2
	jsr	stop

	jsr	silence
	rts

start
	;tst.w	music_flag
	;bmi.s	mym_start
	move.l	music_addr,a0
	moveq	#%1100,D0
	jsr	replay+4
	rts

stop	;tst.w	music_flag
	;bmi.s	mym_stop
	jsr	replay+36
	rts

play	;tst.w	music_flag
	;bmi.s	mym_play
	jsr	replay+12
mym_start
mym_stop
mym_play	rts

store_ints	st	replay_flag

	move.w	#$2700,sr
	lea	old_ints,a0
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.b	$ffffffa07.w,(a0)+
	move.b	$ffffffa09.w,(a0)+
	move.b	$ffffffa11.w,(a0)+
	move.b	$ffffffa13.w,(a0)+
	move.b	$ffffffa15.w,(a0)+
	move.b	$ffffffa17.w,(a0)+
	move.b	$ffffffa21.w,(a0)+
	move.b	$ffffffa1b.w,(a0)+
	move.b	$ffffffa0f.w,(a0)+
	move.l	#hbl,$68.w
	move.l	#intro_tb,$120.w
	move.l	#intro_vbl,$70.w
	move.l	#keyvector,$118.w
	move.b	#%00000001,$fffffa07.w	; timer b
	move.b	#%01000000,$fffffa09.w	; keyboard
	move.b	#%00000001,$fffffa13.w	; timer b
	move.b	#%01000000,$fffffa15.w	; keyboard
	bclr	#3,$fffffa17.w
	move.w	#$2300,sr

	jsr	init_deinit_music
	rts

restore_ints	st	exit_flag
	jsr	init_deinit_music
	move.w	#$2700,sr
	lea	old_ints,a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,$ffffffa07.w
	move.b	(a0)+,$ffffffa09.w
	move.b	(a0)+,$ffffffa11.w
	move.b	(a0)+,$ffffffa13.w
	move.b	(a0)+,$ffffffa15.w
	move.b	(a0)+,$ffffffa17.w
	move.b	(a0)+,$ffffffa21.w
	move.b	(a0)+,$ffffffa1b.w
	move.b	(a0)+,$ffffffa0f.w
	move.w	#$2300,sr
	move.b	#$c0,$fffffa23.w	; reset keyboard repeat
	rts


swap_screens	move.l	screen1,d0
	move.l	screen2,screen1
	move.l	d0,screen2
	lsr.w	#8,d0
	move.l	d0,$fffff8200.w
	rts

clearscreen	moveq	#0,d1
	move.l	screen1,a0
	move.l	screen2,a1
	move.w	#((32000+(160*56))/16)-1,d0
.l1	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	dbf	d0,.l1
	rts

keyvector	move.w	d0,-(sp)
	move.b	$fffffc00.w,d0
	btst	#7,d0
	beq.s	.e1
	move.b	$fffffc02.w,d0
	move.b	d0,kbuff
	bclr	#6,$fffffa11.w
.e1	move.w	(sp)+,d0
	rte

flush	btst.b	#0,$fffffc00.w
	beq.s	.s1
	move.b	$fffffc02.w,d0
	bra.s	flush
.s1	rts

ikbd	lea	$fffffc00.w,a1
.l1	move.b	(a1),d1
	btst	#1,d1
	beq.s	.l1
	move.b	d0,2(a1)
	rts

silence	move.l	#$8080000,$fffff8800.w
	move.l	#$9090000,$fffff8800.w
	move.l	#$a0a0000,$fffff8800.w
	rts

copy_sin	lea	sin_tab,a0
	lea	sin_end,a1
	move.w	#((3220*2)/4)-1,d0
.l1	move.l	(a0)+,(a1)+
	dbf	d0,.l1
	rts

vsync	move.w	d0,-(sp)
	move.w	$466+2.w,d0
.l1	cmp.w	$466+2.w,d0
	beq.s	.l1
	move.w	(sp)+,d0
	rts

draw_intropic	lea	intropic+34,a0
	move.l	screen1,a1
	move.w	#(32000/16)-1,d0
.l1	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.l1
	rts

draw_effect_logo
	lea	effect_logo,a0
	move.l	screen1,a1
	lea	160*44(a1),a1
	move.w	#((160*112)/16)-1,d0
.l1	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.l1
	rts

draw_credits	lea	credits,a0
	move.l	screen1,a1
	lea	(160*25)+(8*6)(a1),a1
	move.w	#(30*5)-1,d0
.l1
x	set	0
	rept	8
	move.l	(a0)+,x(a1)
x	set	x+8
	endr
	lea	160(a1),a1
	dbf	d0,.l1
	rts

fade_from_white	move.l	a0,a2
	move.l	a1,a3
	move.l	d0,d6
	moveq	#8-1,d5
.l2	jsr	vsync
	jsr	vsync
	move.l	a2,a0
	move.l	a3,a1
	move.l	d6,d4
.l1	move.w	(a0),d0
	move.w	(a1),d1
	and.w	#$700,d0
	and.w	#$700,d1
	cmp.w	d0,d1
	beq.s	.n1
	sub.w	#$100,d1
.n1	move.w	(a0),d0
	move.w	(a1),d2
	and.w	#$070,d0
	and.w	#$070,d2
	cmp.w	d0,d2
	beq.s	.n2
	sub.w	#$010,d2
.n2	move.w	(a0),d0
	move.w	(a1),d3
	and.w	#$007,d0
	and.w	#$007,d3
	cmp.w	d0,d3
	beq.s	.n3
	subq.w	#$001,d3
.n3	or.w	d2,d1
	or.w	d3,d1
	move.w	d1,(a1)+
	addq.w	#2,a0
	dbf	d4,.l1
	dbf	d5,.l2
	rts

norm_fade_in	move.l	a0,a2
	move.l	a1,a3
	move.l	d0,d6
	moveq	#8-1,d5
.l2	jsr	vsync
	jsr	vsync
	jsr	vsync
	move.l	a2,a0
	move.l	a3,a1
	move.l	d6,d4
.l1	move.w	(a0),d0
	move.w	(a1),d1
	and.w	#$700,d0
	and.w	#$700,d1
	cmp.w	d0,d1
	beq.s	.n1
	add.w	#$100,d1
.n1	move.w	(a0),d0
	move.w	(a1),d2
	and.w	#$070,d0
	and.w	#$070,d2
	cmp.w	d0,d2
	beq.s	.n2
	add.w	#$010,d2
.n2	move.w	(a0),d0
	move.w	(a1),d3
	and.w	#$007,d0
	and.w	#$007,d3
	cmp.w	d0,d3
	beq.s	.n3
	addq.w	#$001,d3
.n3	or.w	d2,d1
	or.w	d3,d1
	move.w	d1,(a1)+
	addq.w	#2,a0
	dbf	d4,.l1
	dbf	d5,.l2
	rts

norm_fade_out	move.w	d0,d5
	move.l	a0,a1
	moveq	#8-1,d4
.l2	jsr	vsync
	jsr	vsync
	jsr	vsync
	move.l	a1,a0
	move.w	d5,d0
.l1	move.w	(a0),d1
	and.w	#$700,d1
	cmp.w	#0,d1
	beq.s	.n1
	sub.w	#$100,d1
.n1	move.w	(a0),d2
	and.w	#$070,d2
	cmp.w	#0,d2
	beq.s	.n2
	sub.w	#$010,d2
.n2	move.w	(a0),d3
	and.w	#$007,d3
	cmp.w	#0,d3
	beq.s	.n3
	subq.w	#$001,d3
.n3	or.w	d2,d1
	or.w	d3,d1
	move.w	d1,(a0)+
	dbf	d0,.l1
	dbf	d4,.l2
	rts

effect_wait	moveq	#50-1,d1
.l1	jsr	vsync
	dbf	d1,.l1
	dbf	d0,effect_wait
	rts

delta_fade_in
	moveq	#24-1,d4
.l2	move.l	d0,d7
	jsr	vsync
	jsr	vsync
	jsr	vsync
	move.l	a0,a5
	move.l	a1,a6
.l1	move.w	(a6),d1
	andi.w	#$700,d1
	move.w	(a5),d6
	andi.w	#$700,d6
	cmp.w	d1,d6
	beq.s	.s1
	add.w	#$100,d1
	move.w	(a6),d6
	andi.w	#$f8ff,d6
	or.w	d1,d6
	move.w	d6,(a6)
	bra.s	.s2
.s1	move.w	(a6),d1
	andi.w	#$070,d1
	move.w	(a5),d6
	andi.w	#$070,d6
	cmp.w	d1,d6
	beq.s	.s3
	addi.w	#$010,d1
	move.w	(a6),d6
	andi.w	#$ff8f,d6
	or.w	d1,d6
	move.w	d6,(a6)
	bra.s	.s2
.s3	move.w	(a6),d1
	andi.w	#$007,d1
	move.w	(a5),d6
	andi.w	#$007,d6
	cmp.w	d1,d6
	beq.s	.s2
	addi.w	#$001,d1
	move.w	(a6),d6
	andi.w	#$fff8,d6
	or.w	d1,d6
	move.w	d6,(a6)
.s2	addq.w	#2,a6
	addq.w	#2,a5
	dbf	d7,.l1
	dbf	d4,.l2
	rts

delta_fade_out
	moveq	#24-1,d4
.l2	move.l	d0,d7
	jsr	vsync
	jsr	vsync
	jsr	vsync
	move.l	a0,a5
.l1	move.w	(a5),d1
	andi.w	#$700,d1
	beq.s	.s1
	sub.w	#$100,d1
	move.w	(a5),d6
	andi.w	#$f8ff,d6
	or.w	d1,d6
	move.w	d6,(a5)
	bra.s	.s2
.s1	move.w	(a5),d1
	andi.w	#$070,d1
	beq.s	.s3
	subi.w	#$010,d1
	move.w	(a5),d6
	andi.w	#$ff8f,d6
	or.w	d1,d6
	move.w	d6,(a5)
	bra.s	.s2
.s3	move.w	(a5),d1
	andi.w	#$007,d1
	beq.s	.s2
	subi.w	#$001,d1
	move.w	(a5),d6
	andi.w	#$fff8,d6
	or.w	d1,d6
	move.w	d6,(a5)
.s2	addq.w	#2,a5
	dbf	d7,.l1
	dbf	d4,.l2
	rts

;
; Cookie routine by Anders Eriksson (Evil/DHS)
; Makes sure we're running on an STe!
;
cookie_check:	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,old_sp

	move.l	$5a0.w,d0
	beq.s	.st				;Null pointer = ST
	move.l	d0,a0

	moveq	#maxcookie-1,d7
.search_mch:	tst.l	(a0)
	beq.s	.st				;Null termination of cookiejar, no _MCH found = ST

	cmp.l	#"_MCH",(a0)
	beq.s	.mch_found
	addq.l	#8,a0
	dbra	d7,.search_mch
	bra.s	.st				;Default to ST

.mch_found:	move.l	4(a0),d0
	cmp.l	#$00010000,d0
	beq.s	.ste
	cmp.l	#$00010010,d0
	beq.s	.megaste
	cmp.l	#$00020000,d0
	beq.s	.tt
	cmp.l	#$00030000,d0
	beq.s	.falcon

.st:	lea	computer_type,a1
	move.l	#"ST  ",(a1)
	bra.s	.cookie_done

.ste:	lea	computer_type,a1
	move.l	#"STe ",(a1)
	bra.s	.cookie_done

.megaste:	lea	computer_type,a1
	move.l	#"MSTe",(a1)
	bra.s	.cookie_done

.tt:	lea	computer_type,a1
	move.l	#"TT  ",(a1)
	bra.s	.cookie_done

.falcon:	;Check if we are on CT60/3
	move.l	$5a0.w,a0
	moveq	#maxcookie-1,d7
.search_ct60:
	cmp.l	#"CT60",(a0)
	beq.s	.f060
	addq.l	#8,a0
	dbra	d7,.search_ct60

.f030:	lea	computer_type,a1
	move.l	#"F030",(a1)
	bra.s	.cookie_done
.f060:	lea	computer_type,a1
	move.l	#"F060",(a1)

.cookie_done:	lea	computer_type,a1
	cmp.l	#"F030",(a1)
	beq.s	.set
	cmp.l	#"F060",(a1)
	beq.s	.set
	cmp.l	#"CT60",(a1)
	beq.s	.set
	cmp.l	#"TT  ",(a1)
	beq.s	.set
	cmp.l	#"MSTe",(a1)
	beq.s	.set

.s1	bra.s	.user

.set	st	st_flag

.user	move.l	old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	rts

	section	data

replay	incbin	replay.inl
	even
music1	incbin	sosdemos.mod
	even
music2	incbin	dentro02.mod
	even
music3	incbin	coureur.mod
	even
music4	incbin	wingslif.mod
	even
music5	incbin	stnicc15.mod
	even
music6	incbin	athousid.mod	; marcer
	even
music7	incbin	masters.mod	; dark angel
	even
music8	incbin	invaders.mod	; dark angel
	even
music9	incbin	celtic_2.mod	; dark angel
	even
music10	incbin	celtic_8.mod	; dark angel
	even

tune_num	dc.w	4	;3
arrow_offset	dc.w	(160*8)*4	;(160*8)*3

music_table	dc.w	0	; tune number
	dc.l	music1	; the music
	dc.w	2+8	; channel for drive light +8
	dc.w	0	; 0=music mon/-1=mym

	dc.w	1
	dc.l	music2	*
	dc.w	2+8
	dc.w	0

	dc.w	2
	dc.l	music3	*
	dc.w	0+8
	dc.w	0

	dc.w	3
	dc.l	music4	*
	dc.w	2+8
	dc.w	0

	dc.w	4
	dc.l	music5	*
	dc.w	1+8
	dc.w	0

	dc.w	5
	dc.l	music6	*
	dc.w	0+8
	dc.w	0

	dc.w	6
	dc.l	music7	*
	dc.w	1+8
	dc.w	0

	dc.w	7
	dc.l	music8	*
	dc.w	2+8
	dc.w	0

	dc.w	8
	dc.l	music9	*
	dc.w	0+8
	dc.w	0

	dc.w	9
	dc.l	music10	*
	dc.w	0+8
	dc.w	0

channel	dc.w	1+8

fade_in_ball_pos
	dc.l	fade_in_ball_tab
fade_out_ball_pos
	dc.l	fade_out_ball_tab

bar1	ds.w	16
	rept	16
	dc.w	%0000010000000000
	endr

bar2	ds.w	16
	rept	16
	dc.w	%0000000010000000
	endr

bar3	ds.w	16
	rept	16
	dc.w	%0000000000010000
	endr


arrow_tab1
x	set	0
	rept	16
	dc.l	arrow1+x
x	set	x+(8*8)
	endr
arrow_tab2
x	set	0
	rept	16
	dc.l	arrow2+x
x	set	x+(8*8)
	endr
arrow_pos1	dc.l	arrow_sin_tab
arrow_pos2	dc.l	arrow_mid_tab
arrow_sin_tab	dc.w	7,8,9,$A,$B,$C,$C,$D,$D,$D,$D,$D,$D,$C,$C,$B,$A,9,8
arrow_mid_tab	dc.w	7,6,4,3,2,2,1,0,0,0,0,0,01,2,3,4,5,6
	dc.w	-1
	even

logo_pos	dc.l	eft_top
wait_cnt	dc.w	50*10
wait_cnt2	dc.w	50*2
set_cnt	dc.w	16

fade_pos1	dc.l	fade_tab1
fade_tab1
	dcb.w	16,$011

	DC.W	$11,2,2,2,$122,$122,$122,$122
	DC.W	$122,$122,$100,$100,$110,$121,$120,$122

	DC.W	$11,3,3,3,$133,$233,$233,$233
	DC.W	$233,$233,$200,$200,$210,$231,$230,$233

	DC.W	$11,4,4,4,$134,$244,$244,$344
	DC.W	$344,$344,$300,$300,$310,$331,$340,$344

	DC.W	$11,4,5,5,$135,$245,$255,$355
	DC.W	$455,$455,$300,$400,$410,$431,$450,$455

	DC.W	$11,4,6,6,$136,$246,$256,$366
	DC.W	$466,$566,$300,$500,$510,$531,$560,$566

	DC.W	$11,4,6,7,$137,$247,$257,$367
	DC.W	$477,$677,$300,$500,$610,$631,$670,$676

	DC.W	$11,4,6,7,$137,$247,$257,$367
	DC.W	$477,$677,$300,$500,$710,$731,$770,$776

	DC.W	$11,4,6,7,$137,$247,$257,$367
	DC.W	$477,$677,$300,$500,$710,$731,$770,$776

fade_tab1_end

fade_pos2	dc.l	fade_tab2
fade_tab2

	DC.W	$11,4,6,7,$137,$247,$257,$367
	DC.W	$477,$677,$300,$500,$710,$731,$770,$776

	DC.W	$11,4,6,7,$137,$247,$257,$367
	DC.W	$477,$677,$300,$500,$710,$731,$770,$776

	DC.W	$11,4,6,7,$137,$247,$257,$367
	DC.W	$477,$677,$300,$500,$610,$631,$670,$676

	DC.W	$11,4,6,6,$136,$246,$256,$366
	DC.W	$466,$566,$300,$500,$510,$531,$560,$566

	DC.W	$11,4,5,5,$135,$245,$255,$355
	DC.W	$455,$455,$300,$400,$410,$431,$450,$455

	DC.W	$11,4,4,4,$134,$244,$244,$344
	DC.W	$344,$344,$300,$300,$310,$331,$340,$344

	DC.W	$11,3,3,3,$133,$233,$233,$233
	DC.W	$233,$233,$200,$200,$210,$231,$230,$233

	DC.W	$11,2,2,2,$122,$122,$122,$122
	DC.W	$122,$122,$100,$100,$110,$121,$120,$122

	dcb.w	16,$011
	dcb.w	16,$011

fade_tab2_end

;		$011

pal	DC.W	$11,4,6,7,$137,$247,$257,$367
	DC.W	$477,$677,$300,$500,$710,$731,$770,$776


; 14,22,30
textpal	dc.w	$001,$777,$000,$000,$002,$777,$000,$713
	dc.w	$543,$777,$000,$713,$432,$777,$000,$713

backpal	dc.w	$002

musicpal	dc.w	$777,$777,$777,$777,$333,$777,$777,$777,$777,$777

whitepal	dc.w	$777

fadeinpal	dc.w	$002
	dc.w	$013,$013,$013
	dc.w	$024,$024,$024
	dc.w	$035,$035,$035
	dc.w	$046,$046,$046
	dc.w	$057

fadeoutpal	dc.w	$057
	dc.w	$046,$046,$046
	dc.w	$035,$035,$035
	dc.w	$024,$024,$024
	dc.w	$013,$013,$013
	dc.w	$002

bottompal	dc.w	$555,$321,$210,$001

credit_tab
	dc.w	$222,$555,$777
	dc.w	$111,$444,$666
	dc.w	$000,$333,$555
	dc.w	$000,$222,$444
	dc.w	$000,$111,$333
	dc.w	$000,$000,$222
	dc.w	$000,$000,$111
	dc.w	$000,$000,$000

credit_pos	dc.l	credit_tab

intropic_pal	DC.W	$0,4,6,7,$137,$247,$257,$367
	DC.W	$477,$677,$300,$500,$710,$731,$770,$776

intro_ball_pal	dc.w	$000,$243,$465,$777,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

ball_gfx	incbin	ball.dat
	even
eft_pos	dc.l	eft_tab
cube_pos	dc.l	cube_tab
ab_pos	dc.l	ab_tab
cross_pos	dc.l	cross_tab
eft_tab	incbin	eft.tab
eft_tab_end	even
cube_tab	incbin	cube.tab
cube_tab_end	even
ab_tab	incbin	ab.tab
ab_tab_end	even
cross_tab	incbin	cross.tab
cross_tab_end	even

scrolltext	
	dc.b	"     FROM THE WORLD FAMOUS STNICCC 2015, EFFECT PRESENTS COOLISM, OUR MODEST MUSIC DEMO CONTRIBUTION"
	dc.b	" TO THE STNICCC 25TH ANNIVERSARY DEMO COMPETITION....       "
	dc.b	" YOU CAN USE ARROW KEYS TO NAVIGATE AND SPACEBAR TO SELECT A TUNE AND ESCAPE TO EXIT THE DEMO...       "
	dc.b	" WE ARE VERY EXCITED TO BE HERE THIS YEAR AND MEED SOME GREAT LEGENDS ON THE ATARI SCENE.  I, TRONIC, AM SITTING AT A "
	dc.b	" TABLE WITH GRAZEY AND CAL OF THE PHF, MUG UK, BAGGIO AND WIZTOM.... GWEN HAS JUST TURNED UP LOOKING A LITTLE WORSE FOR WEAR... OH AND LET US NOT FORGET FRONT6 WITH HIS SORE FINGER IS HERE TOO LISTENING TO HIS COPY AND PASTE DANCE"
	DC.B    " MUSIC PROGRAMMING SOME STM32NUCLEO BOARDS.  "
	dc.b	" IT IS GREAT TO BE HERE WITH OTHER ATARI FOLLOWERS AND ENTHUSIASTS! THERE ARE (IN)FAMOUS NAMES FROM THE PAST AND PRESENT, WANDERING AROUND CATCHING UP WITH LONG LOST FRIENDS AND MODERN FACEBOOK CONTACTS. LOTS OF"
	dc.b	" PHOTOS ARE BEING TAKEN BY PEOPLE WHO EITHER KNOW OF YOU, OR KNOW YOU. SCENERS ARE ALSO MIXING WITH THE GENUINE STARS OF THE DAY SUCH AS JOCHEN HIPPEL, ROB HUBBARD AND PETE LYON. THERE ARE ALSO SOME MISSING FACES WHO COULD NOT"
	dc.b	" ATTEND FOR A VARIETY OF REASONS, INCLUDING LOTEK (TSCC) AND 6719 (TEX), WHO WILL BE MISSED BY THEIR FRIENDS AND FANBOIS ALIKE. "
	dc.b 	" WE ARE LOOKING FORWARD TO WATCHING SOME EXCITING NEW DEMOS, LISTENING TO NEW MUSIC AND VIEWING SOME GREAT GRAPHICS!   THE SCENE LIVES ON NOW, DAY AND HOPEFULLY FOREVER!!  "
	DC.B	" IT IS GREAT TO MEET SOME OLD FRIENDS AND FINALLY PUT FACES TO THE NAMES AFTER MY SWAPPING DAYS OVER 20 YEARS AGO!  LOOKING FORWARD TO SOME CATCH UP BEERS LATER AND A GREAT ATMOSPHERE!   THESE EVENTS ARE"
	DC.B 	" VERY SPECIAL, AND I HOPE THERE WILL BE ANOTHER ONE VERY SOON.   THE CREDITS... "
	dc.b	" ALL CODE, SOME GRAPHICS, THREE D BALL OBJECTS AND DESIGN BY BOD OF EFFECT...      "
	DC.B    " COOLISM PICTURE AND LOGOS BY SAMURAI OF EFFECT...   "
	dc.b	" MUSIC IN THIS DEMO HAS BEEN COMPOSED BY XRWWR OF EFFECT, MARCER AND DARK ANGEL.    "
	DC.B	" SPECIAL THANKS TO XRWWR AND SAMURAI FOR COMING UP WITH THE GOODS WITH LITTLE TIME!  ALSO THANK YOU TO CUBE FOR COMPOSING A TUNE FOR US WHICH, UNFORTUNATELY, WE COULD NOT INCLUDE DUE TO TECHNICAL REASON.... "
	DC.B	" THAT IS ALL FOR NOW.... WE WILL BE BACK IN 2016 WITH MORE RELEASES, SO STAY TUNED... "
	DC.B	"    LET'S WARP......         "
	dc.b	-1
	even
scrollpos	dc.l	scrolltext
font	dc.l	0,0,$18181818,$181800,$6c6c0000,0,0,0,$107ed07c,$16fc1000,0,0,0,0,$18383000,0,$c1c1010,$101c0c00
	dc.l	$30380808,$8383000,$3078fc,$78300000,$18187e,$18180000,0,$18383000,$fe,0,0,$181800,$40c1830,$60c08000
	dc.l	$7cc6c6c6,$c6c67c00,$70181818,$18181800,$fc067cc0,$c0c07e00,$7cc61e06,$c6c67c00,$1e3666fe,$6060600
	dc.l	$fec0fc06,$c6c67c00,$7ec0fcc6,$c6c6fc00,$fcc60606,$6060600,$7cc6fec6,$c6c67c00,$7cc67e06,$6067c00
	dc.l	$181800,$18180000,0,0,0,0,$fe00,$fe000000,0,0,$fc067ce0,$e0e000,0,0,$3c667e66,$e6e6e600,$3c667e66
	dc.l	$e6e6fc00,$3c666060,$e6e6fc00,$7c666666,$e6e6fc00,$3c667060,$e6e6fc00,$3c667060,$e0e0e000,$3e606c66
	dc.l	$e6e6fc00,$66667e66,$e6e6e600,$7e181838,$38fefe00,$6060606,$e6fe7c00,$66667c66,$e6e6e600,$606060e0
	dc.l	$e6fe7c00,$667e6666,$e6e6e600,$7c666666,$e6e6e600,$3c6666e6,$e6e67c00,$3c667c60,$e0e0e000,$3c6666e6
	dc.l	$e6ee7e00,$3c667c66,$e6e6e600,$3e603c06,$e6e67c00,$7e181818,$38383800,$666666e6,$e6e67c00,$666666e6
	dc.l	$e6663c00,$666666e6,$fefe6400,$66663c66,$e6e6e600,$66663e06,$e6fe7c00,$f80c78c0,$c0fc7c00
text	incbin	text.dat
	even
arrow1	incbin	arrow1.dat
	even
arrow2	incbin	arrow2.dat
	even
dist_gfx	incbin	dist.dat
	even
intro_ball	dc.l	$3c000000,$46003800,$b3007c00,$b3007c00,$83007c00,$c7003800,$7e000000,$3c000000
rotate_pos	dc.l	rotate_tab
rotate_tab	incbin	eftball.tab
rotate_end	even
old_intro_ball_pos1
	dc.l	old_intro_ball1
old_intro_ball_pos2
	dc.l	old_intro_ball2
whitepal2	dcb.w	17,$777
effect_logo_pal	DC.W	0,5,$70,$770,$14,$24,$26,$36
	DC.W	$47,$37,4,2,$706,$704,$700,$777
effect_logo	incbin	effect8.dat
	even
credits	incbin	credits.dat
	even
eft_top	incbin	eft_top.dat
	even
cool_logo	incbin	cool.dat
	even
intropic	incbin	intropic.pi1
	even
sin_pos1	dc.l	sin_tab
sin_pos2	dc.l	sin_tab

sin_tab	incbin	dister.tab
sin_end
	section	bss

bss_start	ds.b	3220*2
	ds.l	250
stack	ds.l	1
old_stack	ds.l	1
ball_rout	ds.w	1
fade_rout	ds.w	1
fade_time	ds.w	1
music_flag	ds.w	1
current_tune	ds.w	1
music_addr	ds.l	1
scrollbuff	ds.w	20*8
fontbuff	ds.w	8
scr_cnt	ds.w	1
blank	ds.w	16
palbuff	ds.w	16
textpalbuff	ds.w	16
backpalbuff	ds.w	1
musicpalbuff	ds.w	10
whitepalbuff	ds.w	1
fade_in_ball_tab
	ds.w	14
fade_in_ball_end

fade_out_ball_tab
	ds.w	14
fade_out_ball_end
bottompalbuff	ds.w	4

old_intro_ball1	ds.l	num_intro_balls
old_intro_ball2	ds.l	num_intro_balls
intro_ball_gfx	ds.b	(8*8)*16
computer_type	ds.l	1
timer_rout	ds.l	1
timer_line	ds.w	1
logo_rout	ds.w	1
fade_cnt	ds.w	1
credit_col	ds.w	3
intro_rout	ds.w	1
intro_palbuff	ds.w	16

oldpal	ds.w	16
oldphys	ds.l	1
old_sp	ds.l	1
screen1	ds.l	1
screen2	ds.l	1
old_ints	ds.b	29
oldrez	ds.b	1
oldhz	ds.b	1
kbuff	ds.b	1
replay_flag	ds.b	1
deinit_flag	ds.b	1
scroll_flag	ds.b	1
first_run_flag	ds.b	1
exit_flag	ds.b	1
exit_demo_flag	ds.b	1
senser_flag	ds.b	1
drive_flag	ds.b	1
st_flag	ds.b	1
	even
	ds.b	256
screen_ram
bss_end	end