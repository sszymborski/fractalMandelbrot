%use altreg
;xmm0 - scale
;xmm1 - cx
;xmm2 - cy      ;podane

;xmm3 - x
;xmm4 - y
;xmm5 - zx
;xmm6 - zy
;xmm7 - zx2
;xmm8 - zy2     ;uzywane

;xmm9 - iter nope
;xmm10 - min
;xmm11 - max

;rdi - tablica charow, potem w r8
;rsi - max iter, potem w r9

;r8 - tablica intow
;r9 - max iter

;r10 - px nope
;r11 - i
;r12 - nie dziala
;r13 - nie dziala
;r14 - j
;r15 - iter

section .text
global mandel

mandel:

	push rbp	; push "calling procedure" frame pointer
	mov rbp, rsp	; set new frame pointer

mov r8, rdi	;piksele
mov r9, rsi     ;skopiowanie max iter    
cvtsi2sd xmm10, r9     ;skopiowanie max iter do min
mov r10, 0
cvtsi2sd xmm11, r10      ;skopiowanie 0 do wartosci max
mov r11, 0      ;skopiowanie 0 do iteratora i
mov rax, 0

mov rdx, 0
mov rcx, 0

for1:

	cvtsi2sd xmm4, r11


mov r10, 240
cvtsi2sd xmm13, r10

    subsd xmm4, xmm13
    mulsd xmm4, xmm0
    addsd xmm4, xmm2      ;y = (i-height/2)*scale+cy

mov r14, 0			;j=0

for2:
cvtsi2sd xmm3, r14
	mov r10, 320
	cvtsi2sd xmm13, r10
    subsd xmm3, xmm13
    mulsd xmm3, xmm0
    addsd xmm3, xmm1      ;x=(j-width/2)*scale+cx

mov r15, 0			;iter=0


	mov r10, 0
cvtsi2sd xmm13, r10

    movsd xmm5, xmm13
    movsd xmm6, xmm13
    movsd xmm7, xmm13
    movsd xmm8, xmm13         ;zx = zy = zx2 = zy2 = 0

    movsd xmm15, xmm3
	mov r10, 1
	cvtsi2sd xmm13, r10 
    addsd xmm15, xmm13
    mulsd xmm15, xmm15
    movsd xmm14, xmm4
    mulsd xmm14, xmm14
    addsd xmm15, xmm14     ;(x+1)*(x+1)+y*y


mov r10, 16
cvtsi2sd xmm13, r10
mulsd xmm15, xmm13

mov r10, 1
cvtsi2sd xmm13, r10
movsd xmm14, xmm13

    ;comisd xmm15, xmm14
cvtsd2si rcx, xmm15
cvtsd2si rdx, xmm14
cmp rcx, rdx
jge next22           ;if(up<1/16)


mov r15, r9

next22:

tutaj:
for3:

    ;mulsd xmm6, xmm6
    mulsd xmm6, xmm5
mov r10, 2
cvtsi2sd xmm13, r10
    mulsd xmm6, xmm13
    addsd xmm6, xmm4      ;zy=2*zx*zy+y

    movsd xmm5, xmm7
    subsd xmm5, xmm8
    addsd xmm5, xmm3      ;zx=zx2-zy2+x

    movsd xmm7, xmm5
    mulsd xmm7, xmm5     ;zx2=zx*zx

    movsd xmm8, xmm6
    mulsd xmm8, xmm6     ;zy2=zy*zy

    add r15, 1          ;iter++

    cmp r15, r9
    jge next2           ;wyjscie z petli jesli iter >= max iter

    movsd xmm12, xmm7
    addsd xmm12, xmm8     ;zx2+zy2

mov r10, 4
cvtsi2sd xmm13, r10
    ;comisd xmm12, xmm13

cvtsd2si rcx, xmm12
cvtsd2si rdx, xmm13
cmp rcx, rdx

    jl for3             ;up<4, to petla dalej chodzi


next2:
;dotad sprawdzone i jest okej

cvtsi2sd xmm15, r15
;comisd xmm15, xmm10


cvtsd2si rcx, xmm15
cvtsd2si rdx, xmm10
cmp rcx, rdx

jge next3

movsd xmm10, xmm15		;if (iter < min) min = iter;

next3:

;comisd xmm15, xmm11

cvtsd2si rcx, xmm15
cvtsd2si rdx, xmm11
cmp rcx, rdx

jle next4

movsd xmm11, xmm15 		;if (iter > max) max = iter;

next4:

;comisd xmm10, xmm11

cvtsd2si rcx, xmm10
cvtsd2si rdx, xmm11
cmp rcx, rdx

jne next5


mov r10, 1
cvtsi2sd xmm15, r10

addsd xmm10, xmm15

next5:

cvtsi2sd xmm15, r15

movsd xmm14, xmm11
subsd xmm14, xmm15

mov r10, 255
cvtsi2sd xmm15, r10

mulsd xmm14, xmm15

movsd xmm15, xmm11
subsd xmm15, xmm10

divsd xmm14, xmm15

;teraz w xmm14 siedzi kolor na jaki sie koloruje


            
            

cvttsd2si r10, xmm14 ;jaki odcien


;add r10, 66

mov BYTE [r8+rax], r15l ;
inc rax
mov BYTE [r8+rax], r15l ;
inc rax
mov BYTE [r8+rax], r15l ;
inc rax

    add r14, 1              ;j++
    cmp r14, 640           ;porownanie j z szerokoscia
    jl for2

    add r11, 1              ;i++
    cmp r11, 480    ;porowanie i z wysokoscia
    jl for1


end:

;------------------------------------------------------------------------------

	;mov rsp, rbp	; restore original stack pointer // to niepotrzebne bo nie ma zmiennych lokalnych
	pop rbp		; restore "calling procedure" frame pointer
	ret
