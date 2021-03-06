			DEVICE ZXSPECTRUM48			; sjasmplus directive for SAVESNA at end

Stack_Top:		    EQU 0xFF00
Code_Start:		    EQU 0x8000

			        ORG Code_Start

SEED1               EQU 23670
SEED2               EQU 23671
coords_x:           EQU 23677
coords_y:           EQU 23678
CHARS:              EQU 23606
prcc_addr:          EQU 23681

                    JR init_routine
adjust:             DEFB 6
posx:               DEFB 0
posy:               DEFB 50
init_routine:
                    LD A,(SEED1)
                    LD L,A
                    LD A,(SEED2)
                    LD H,A
string_main_loop:
                    ; Parche por modificacion que hace la ROM.
                    LD A, (posx)
                    LD (coords_x), A
                    LD A, (posy)
                    LD (coords_y), A

                    LD A,(HL) ; busco el primer caracter de la cadena.
                    CP 0 ; si es cero...
                    RET Z ; ...salgo

                    ; Comienzo ciclo principal.
                    LD (prcc_addr), A
                    PUSH HL
                    CALL char_print
                    LD A, (adjust)
                    LD C, A
                    LD B, 0
                    LD HL, posx
sum_adj_2_hl:
                    INC (HL)
                    DEC BC
                    LD A,B
                    OR C
                    JR NZ, sum_adj_2_hl ; ciclo para sumar el ajuste al contenido de HL
                    POP HL
                    INC HL ; Incremento HL para el proximo caracter de la cadena.
                    JR string_main_loop

char_print:
                    LD   HL,(prcc_addr)
                    LD   H, 0
                    LD   DE,(coords_x)
                    PUSH DE
                    LD   DE,(CHARS)
                    ADD  HL,HL
                    ADD  HL,HL
                    ADD  HL,HL
                    ADD  HL,DE
                    POP  DE
                    LD B, 8
loop_3:
                    LD   A,(HL)
                    PUSH BC
                    LD B, 8
loop_2:
                    PUSH BC
                    RLA
                    JR NC,loop_1
                    LD B,D
                    LD C,E
                    PUSH DE
                    PUSH HL
                    PUSH AF
                    CALL $22E5  ; Ojo que modifica el contenido de coords_x y coords_y
                    POP  AF
                    POP  HL
                    POP  DE
loop_1:
                    INC  E
                    POP  BC
                    DJNZ loop_2
                    DEC  D
                    POP  BC
                    INC  HL
                    LD   A, 248
                    ADD  A,E
                    LD   E,A
                    DJNZ loop_3
                    RET

Code_Length:		EQU $-Code_Start+1

                    SAVESNA "char6bytes.sna", Code_Start
