; ==========================================================================
; SHINDOBADDO NANATSU NO BOUKEN - ROM de 16 KB en 0x4000
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; Etiquetas que no caen en ninguna posicion emitida del listado
; (destinos fuera del binario o dentro de una instruccion).
; ----------------------------------------------------------------------
L_413C:	equ 0x0413c
L_415C:	equ 0x0415c
L_41A2:	equ 0x041a2
L_5F50:	equ 0x05f50
L_6119:	equ 0x06119
L_6134:	equ 0x06134
L_6137:	equ 0x06137

; ----------------------------------------------------------------------
; DATOS cabecera: La cabecera del cartucho: "AB" e INIT 0x4010; lo demas, a
;   cero
;   0x4000..0x4010  (16 bytes)
DATA_cabecera:
	defb 041h,042h,010h,040h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 4000  AB.@............

; ======================================================================
; CODIGO 0x4010..0x40de  (206 bytes)
; ======================================================================


init:		; El arranque: sin interrupciones, H.KEYI y H.TIMI con un "ret", la pila, la RAM 0xE000-0xF2FF a cero, la fila 0 del teclado (0xE000), la partida y la pantalla; H.KEYI a 0x4042 y el bucle vacio
	di			;4010   ; sin interrupciones
	ld a,0c9h		;4011   ; un "ret"...
	ld (0fd9ah),a		;4013   ; ...en H.KEYI...
	ld (0fd9fh),a		;4016   ; ...y en H.TIMI
	ld sp,0f380h		;4019   ; la pila
	ld hl,0e000h		;401c   ; 0xE000...
	ld bc,01300h		;401f   ; ...0x1300 bytes...
	xor a			;4022   ; ...a cero
	call llena		;4023
	xor a			;4026   ; la fila 0 del teclado (las teclas 0-7)
	call 00141h		;4027   ; SNSMAT
	rrca			;402a   ; el 0 al bit 7, las teclas 1-7 a los bits 0-6...
	cpl			;402b   ; ...pulsada = 1
	ld (0e000h),a		;402c   ; en 0xE000
	call partida_pon		;402f   ; lo de la partida
	call pantalla_pon		;4032   ; la pantalla
	ld hl,interrupcion		;4035   ; la interrupcion (0x4042)...
	ld (0fd9bh),hl		;4038   ; ...en H.KEYI...
	ld a,0c3h		;403b   ; ...con su "jp"
	ld (0fd9ah),a		;403d
bucle_vacio:		; El bucle principal: nada; todo va en la interrupcion
	jr bucle_vacio		;4040   ; para siempre
interrupcion:		; La interrupcion (H.KEYI): KILBUF, la del VDP cortada, los mandos, las cuentas; segun 0xE001 (bit 3, bit 4) unas cosas u otras; y el registro 1 otra vez con la interrupcion del VDP
	call 0013eh		;4042   ; KILBUF: el buffer del teclado vacio
	ld bc,0c201h		;4045   ; el registro 1 a 0xC2: sin la interrupcion del VDP
	call 00047h		;4048   ; WRTVDP
	call mandos		;404b   ; los mandos
	call cuentas		;404e   ; las cuentas de cuadros
	ld a,(0e001h)		;4051   ; 0xE001 bit 3?
	and 008h		;4054
	jr z,interrupcion_sigue		;4056
	call prota_pinta		;4058
	call fondo_vram		;405b
	call marcador		;405e
	call huecos_borra		;4061
interrupcion_sigue:
	ld a,(0e001h)		;4064   ; 0xE001 bit 4?
	and 010h		;4067
	jr nz,interrupcion_otro		;4069
	call protagonista		;406b
	call enemigos		;406e
	ld a,(0e001h)		;4071
	and 008h		;4074
	jr z,interrupcion_fin		;4076
interrupcion_otro:
	call cosas33_dibuja		;4078
	call bordes		;407b
interrupcion_fin:
	call estado		;407e
	call sonido		;4081
	di			;4084   ; sin interrupciones
	ld a,0e2h		;4085   ; el registro 1 a 0xE2...
	out (099h),a		;4087   ; ...por el puerto 0x99...
	ld a,081h		;4089   ; ...registro 1
	out (099h),a		;408b
	in a,(099h)		;408d   ; el estado del VDP leido
	ret			;408f
partida_pon:		; Lo de la partida: los numeros al azar, los puntos a cero, el record a 500, la fase de salida (las teclas 1-3 al encender, en binario: 1-8) y el estado 1
	call partida_borra		;4090
	ld hl,00500h		;4093   ; el record: 500...
	ld (0e69eh),hl		;4096   ; ...en 0xE69E
	xor a			;4099
	ld (0e6a0h),a		;409a
	ld (0ead3h),a		;409d
	ld (0eb26h),a		;40a0
	inc a			;40a3   ; el estado 1 (0xEAB1)
	ld (0eab1h),a		;40a4
	jp sonido_calla		;40a7
pantalla_pon:		; La pantalla: DISSCR, las tablas de SCREEN 2 de 0x40DE en la RAM del sistema (GRPNAM...), INIGRP, registros 1 y 7, la VRAM a cero, los sprites fuera y ENASCR
	call 00041h		;40aa   ; DISSCR
	di			;40ad
	ld hl,040deh		;40ae   ; las direcciones de las tablas...
	ld de,0f3c7h		;40b1   ; ...a GRPNAM (0xF3C7)...
	ld bc,0000ah		;40b4   ; ...10 bytes
	ldir		;40b7
	call 00072h		;40b9   ; INIGRP: SCREEN 2
	ld bc,0e281h		;40bc   ; el registro 1: 0xE2
	call 00047h		;40bf
	ld bc,00187h		;40c2   ; el registro 7: 1 (el borde negro)
	call 00047h		;40c5
	ld hl,00000h		;40c8   ; la VRAM...
	ld bc,03ffeh		;40cb
	xor a			;40ce
	call 00056h		;40cf   ; ...a cero
	call sprites_fuera		;40d2   ; los sprites fuera
	ld bc,0e201h		;40d5   ; el registro 1 otra vez
	call 00047h		;40d8
	jp 00044h		;40db   ; ENASCR

; ----------------------------------------------------------------------
; DATOS tablas_screen2: Las tablas de SCREEN 2 para la RAM del sistema
;   (GRPNAM, GRPCOL, GRPCGP, GRPATR, GRPPAT): nombres 0x3800, colores 0x2000,
;   dibujos 0x0000, atributos 0x3B00, sprites 0x1800
;   0x40de..0x40e8  (10 bytes)
DATA_tablas_screen2:
	defw 03800h,02000h,00000h,03b00h,01800h	; 40de

; ======================================================================
; CODIGO 0x40e8..0x41cb  (227 bytes)
; ======================================================================


partida_borra:		; Una partida: dos numeros al azar, 0xE69A-0xE69D a cero, 0xE003 = 1, cinco vidas (0xEAE3) y la fase de salida (0xE002): las teclas 1, 2 y 3 al encender, en binario, + 1
	call azar		;40e8   ; el azar, dos veces
	call azar		;40eb
	xor a			;40ee   ; los puntos a cero
	ld (0e69ah),a		;40ef
	ld (0e69dh),a		;40f2
	ld h,a			;40f5
	ld l,a			;40f6
	ld (0e69bh),hl		;40f7
	inc a			;40fa   ; 0xE003 = 1
	ld (0e003h),a		;40fb
	ld a,005h		;40fe   ; cinco vidas
	ld (0eae3h),a		;4100
	ld a,(0e000h)		;4103   ; las teclas 1, 2 y 3 al encender...
	and 007h		;4106
	inc a			;4108   ; ...+ 1
	cp 008h		;4109   ; hasta 7
	jr c,partida_fase		;410b
	ld a,001h		;410d   ; si no, 1
partida_fase:
	ld (0e002h),a		;410f   ; la fase
	ret			;4112
mandos:		; Los mandos: la palanca del mando 1 o los cursores (0xE004); el boton 1 del mando o la barra (0xE005) y el boton 2 o GRAPH (0xE006), recien pulsados (0xE007 lo sostenido); en la demostracion, los de la lista
	ld a,001h		;4113   ; GTSTCK 1: el mando 1
	call 000d5h		;4115
	or a			;4118
	jr nz,mandos_palanca		;4119   ; quieto: los cursores
	call 000d5h		;411b
mandos_palanca:
	ld (0e004h),a		;411e   ; la palanca
	ld hl,0e007h		;4121   ; lo sostenido
	ld a,001h		;4124   ; GTTRIG 1: el boton 1 del mando
	call 000d8h		;4126
	or a			;4129
	jr nz,mandos_boton1		;412a   ; pulsado?
	call 000d8h		;412c   ; GTTRIG 0: la barra (A = 0)
	or a			;412f
	jr z,$+12		;4130   ; suelto: salta a mitad del "ld bc" de 0x413B, que alli es "res 0,(hl)"
mandos_boton1:
	bit 0,(hl)		;4132   ; ya sostenido?
	jr nz,mandos_boton2		;4134
	set 0,(hl)		;4136   ; sostenido
	ld (0e005h),a		;4138   ; recien pulsado
	ld bc,086cbh		;413b   ; (desde 0x4130, este es "res 0,(hl)": suelto)
mandos_boton2:
	ld a,003h		;413e   ; GTTRIG 3: el boton 2 del mando 1
	call 000d8h		;4140
	or a			;4143
	jr nz,mandos_boton2_va		;4144
	ld a,006h		;4146   ; la fila 6: GRAPH (bit 2)
	call 00141h		;4148   ; SNSMAT
	rra			;414b
	rra			;414c
	rra			;414d
	ccf			;414e   ; pulsado = 0xFF
	sbc a,a			;414f
	jr z,$+12		;4150   ; suelto: a mitad del "ld bc" de 0x415B ("res 1,(hl)")
mandos_boton2_va:
	bit 1,(hl)		;4152   ; ya sostenido?
	jr nz,mandos_demo		;4154
	set 1,(hl)		;4156   ; sostenido
	ld (0e006h),a		;4158   ; recien pulsado
	ld bc,08ecbh		;415b   ; (desde 0x4150, "res 1,(hl)")
mandos_demo:
	ld a,(0e001h)		;415e   ; la demostracion (0xE001: bit 6, sin el 7)?
	and 0c0h		;4161
	cp 040h		;4163
	ret nz			;4165
	ld a,(0e007h)		;4166   ; un boton la corta
	and 001h		;4169
	jr nz,demo_corta		;416b
	call botones_cero		;416d   ; los botones a 0
	ld a,(0e00bh)		;4170   ; una orden en marcha (hasta que acaba el salto o la escalera)?
	or a			;4173
	jr nz,mandos_demo_va		;4174
	ld hl,(0e009h)		;4176   ; la lista
	ld a,(0eadch)		;4179   ; la columna del protagonista (la demo va por sitios)
	cp (hl)			;417c   ; ha llegado?
	jr c,mandos_demo_espera		;417d   ; antes: hacia la derecha
	jr nz,$+35		;417f   ; despues: a mitad del "ld hl" de 0x41A1 ("ld a,7", a la izquierda)
	inc hl			;4181   ; la orden
	ld a,(hl)			;4182
	rra			;4183   ; bit 0: el boton
	ld (0e008h),a		;4184   ; la palanca
	sbc a,a			;4187
	ld (0e006h),a		;4188   ; el boton
	ld a,0ffh		;418b   ; en marcha
	ld (0e00bh),a		;418d
mandos_demo_lista:
	inc hl			;4190
	ld de,041d9h		;4191
	rst 20h			;4194   ; DCOMPR: al final de la lista?
	jr c,mandos_demo_pon		;4195
	ld hl,041cbh		;4197   ; otra vez desde el principio (0x41CB)
mandos_demo_pon:
	ld (0e009h),hl		;419a
	jr mandos_demo_va		;419d
mandos_demo_espera:
	ld a,003h		;419f   ; la palanca 3: a la derecha
	ld hl,0073eh		;41a1   ; (desde 0x417F: "ld a,7", a la izquierda)
	ld (0e008h),a		;41a4
mandos_demo_va:
	ld a,(0e008h)		;41a7   ; la palanca de la lista
	ld (0e004h),a		;41aa
	ld a,(0e017h)		;41ad   ; 0xE017?
	or a			;41b0
	ret nz			;41b1
	call azar		;41b2   ; al azar...
	rra			;41b5   ; ...el boton
	sbc a,a			;41b6
	ld (0e005h),a		;41b7
	ret			;41ba
demo_corta:		; El boton corta la demostracion: los estados a 0 y el estado 1
	xor a			;41bb   ; los estados a 0
	ld (0ead3h),a		;41bc
	ld (0eb26h),a		;41bf
	ld a,001h		;41c2
	ld (0eab1h),a		;41c4   ; el estado 1
	call sprites_fuera		;41c7   ; sin sprites
	ret			;41ca

; ----------------------------------------------------------------------
; DATOS demo_lista: Los mandos de la demostracion: (la columna a la que llega
;   el protagonista, palanca x 2 + boton); andando hacia esa columna, al
;   llegar hace lo del segundo byte
;   0x41cb..0x41d9  (14 bytes)
DATA_demo_lista:
	defb 003h,007h,012h,00ah,01fh,002h,02eh,007h,037h,002h,028h,00ah,01eh,00fh	; 41cb  ........7.(...

; ======================================================================
; CODIGO 0x41d9..0x429d  (196 bytes)
; ======================================================================


botones_cero:		; Los botones (0xE005 y 0xE006) a 0
	ld hl,00000h		;41d9
	ld (0e005h),hl		;41dc   ; los dos a 0
	ret			;41df
cuentas:		; Las cuentas de cuadros: nueve (0xE00C) de 9 a 0, y 0xE017 de 0 a 59
	ld hl,0e00ch		;41e0   ; nueve cuentas
	ld b,009h		;41e3
cuenta_una:
	dec (hl)			;41e5   ; una menos
	jp p,cuenta_sig		;41e6
	ld (hl),b			;41e9   ; por debajo de 0: otra vez
cuenta_sig:
	inc hl			;41ea
	djnz cuenta_una		;41eb
	ld hl,0e017h		;41ed   ; la de 60 cuadros
	inc (hl)			;41f0   ; una mas
	ld a,(hl)			;41f1
	cp 03ch		;41f2   ; 60?
	ret c			;41f4
	ld (hl),000h		;41f5   ; a 0
	ret			;41f7
marcador:		; El marcador, escrito en la tabla de nombres (0x3800) con el puerto 0x98: los textos de 0x429D, los puntos, las vidas, la fase, el record...
	ld hl,03800h		;41f8   ; la fila 0
	call 00053h		;41fb   ; SETWRT
	ld hl,0429dh		;41fe   ; el texto de los puntos
	ld b,005h		;4201
	call vram_b		;4203   ; cinco casillas
	ld hl,0e69dh		;4206   ; los puntos
	call numero_vram		;4209
	ld a,000h		;420c   ; un espacio
	out (098h),a		;420e
	ld a,(0eae3h)		;4210   ; las vidas...
	dec a			;4213   ; ...menos la que juega
	ld l,01ah		;4214   ; la casilla 0x1A
	call marcador_cuenta		;4216   ; hasta 8
	ld hl,042a2h		;4219   ; el texto de la ronda
	ld b,003h		;421c
	call vram_b		;421e
	ld a,(0e003h)		;4221   ; la ronda
	call bcd_vram		;4224   ; en dos cifras
	ld hl,042a5h		;4227   ; el texto de la isla
	ld b,005h		;422a
	call vram_b		;422c
	ld a,(0e002h)		;422f   ; la isla...
	or 010h		;4232   ; ...en cifra
	out (098h),a		;4234
	ld hl,042aah		;4236   ; el texto del record
	ld b,006h		;4239
	call vram_b		;423b
	ld hl,0e6a0h		;423e   ; el record
	call numero_vram		;4241
	ld a,000h		;4244   ; un espacio
	out (098h),a		;4246
	ld a,(0eb29h)		;4248   ; 0xEB29
	ld l,01bh		;424b   ; la casilla 0x1B
	call marcador_cuenta		;424d
	ld hl,042b0h		;4250   ; el texto de la fuerza
	ld b,004h		;4253
	call vram_b		;4255
	ld a,(0ead7h)		;4258   ; la fuerza (0xEAD7)...
	rra			;425b   ; ...la mitad, redondeada
	adc a,000h		;425c
	ld l,01ch		;425e   ; la casilla 0x1C
marcador_cuenta:		; Tantas casillas L como A (como mucho 7) y el resto, hasta 8, en blanco
	and 007h		;4260   ; como mucho 7
	ld c,a			;4262
	jr z,marcador_cuenta_blanco		;4263   ; ninguna?
	ld b,a			;4265   ; tantas
	ld a,l			;4266   ; la casilla
	call vram_b_a		;4267
marcador_cuenta_blanco:
	ld a,008h		;426a   ; el resto, hasta 8...
	sub c			;426c
	ld b,a			;426d
	xor a			;426e   ; ...en blanco
vram_b_a:		; B veces A a la VRAM, con espera
	out (098h),a		;426f   ; a la VRAM
	ex (sp),hl			;4271   ; espera
	ex (sp),hl			;4272
	djnz vram_b_a		;4273
	ret			;4275
numero_vram:		; Un numero BCD de tres bytes (HL hacia atras): la cifra baja del primero, las de los otros dos y un 0 (0x10 + cifra)
	ld a,(hl)			;4276   ; la cifra alta del primer byte
	and 00fh		;4277
	or 010h		;4279
	out (098h),a		;427b   ; a la VRAM
	ld b,002h		;427d   ; dos bytes mas
numero_vram_byte:
	dec hl			;427f   ; el siguiente
	ld a,(hl)			;4280
	call bcd_vram		;4281   ; sus dos cifras
	djnz numero_vram_byte		;4284
	ld a,010h		;4286   ; un 0 al final (los puntos van de 10 en 10)
	out (098h),a		;4288
	ret			;428a
bcd_vram:		; Las dos cifras de A a la VRAM (casillas 0x10 + cifra)
	push af			;428b   ; la cifra alta...
	call mitad_alta		;428c
	and 00fh		;428f
	or 010h		;4291   ; ...0x10 + cifra
	out (098h),a		;4293
	pop af			;4295
	and 00fh		;4296   ; la baja
	or 010h		;4298
	out (098h),a		;429a
	ret			;429c

; ----------------------------------------------------------------------
; DATOS marcador_textos: Los textos del marcador en casillas
;   0x429d..0x42b4  (23 bytes)
DATA_marcador_textos:
	defb 000h,002h,003h,001h,000h,006h,007h,001h,000h,005h,002h,001h,000h,000h,000h,004h	; 429d  ................
	defb 005h,001h,000h,008h,009h,00ah,001h	; 42ad

; ======================================================================
; CODIGO 0x42b4..0x453d  (649 bytes)
; ======================================================================


puntos_suma:		; Los puntos + DE (BCD) si no es la demostracion; y el record
	ld hl,0e001h		;42b4   ; la demostracion: no
	bit 6,(hl)		;42b7
	ret nz			;42b9
	ld hl,(0e69bh)		;42ba   ; los puntos (los dos bytes bajos)
	ld e,a			;42bd   ; + A
	ld d,000h		;42be
	call suma_bcd		;42c0   ; la suma BCD
	ld (0e69bh),hl		;42c3   ; apuntados
	ld hl,0e69dh		;42c6   ; el byte alto
	jr nc,record_mira		;42c9   ; sin acarreo?
	ld a,(hl)			;42cb   ; + 1 en BCD
	add a,001h		;42cc
	daa			;42ce
	ld (hl),a			;42cf
record_mira:
	ld de,0e6a0h		;42d0   ; el record
	ld b,003h		;42d3   ; tres bytes, del alto al bajo
record_cifra:
	ld a,(de)			;42d5   ; el record...
	cp (hl)			;42d6   ; ...contra los puntos
	jr c,record_nuevo		;42d7   ; menor: record nuevo
	ret nz			;42d9   ; mayor: no
	dec hl			;42da   ; el byte siguiente
	dec de			;42db
	djnz record_cifra		;42dc
	ret			;42de
record_nuevo:
	ld hl,0e69bh		;42df   ; los puntos...
	ld de,0e69eh		;42e2   ; ...al record
	ld bc,00003h		;42e5
	ldir		;42e8
	dec hl			;42ea   ; el byte alto...
	ld a,(hl)			;42eb
	and 00fh		;42ec   ; ...sin la cifra alta (no se pinta: cinco cifras y el 0)
	ld (hl),a			;42ee
	dec de			;42ef   ; y el del record
	ld a,(de)			;42f0
	and 00fh		;42f1
	ld (de),a			;42f3
	ret			;42f4
bordes:		; Si el protagonista (0xEADC) pasa de los bordes, el estado 7 u 8
	ld a,(0ead1h)		;42f5   ; la columna que se ve + 12
	add a,00ch		;42f8
	ld b,a			;42fa
	ld a,(0eadch)		;42fb   ; la del protagonista
	cp 00ch		;42fe   ; en las 12 primeras?
	jr c,bordes_izq		;4300
	cp 034h		;4302   ; en las 12 ultimas?
	jr nc,bordes_der		;4304
	sub b			;4306   ; a la izquierda de la mitad de la vista?
	jr c,estado_7		;4307
	cp 008h		;4309   ; a menos de 8 de ella: nada
	ret c			;430b
estado_8:
	ld a,008h		;430c   ; el estado 8: la vista a la derecha
	jr estado_pon		;430e
estado_7:
	ld a,007h		;4310   ; el estado 7: a la izquierda
estado_pon:
	ld (0eab1h),a		;4312
	ret			;4315
bordes_izq:
	ld a,(0ead1h)		;4316   ; ya en la primera?
	or a			;4319
	ret z			;431a
	jr estado_7		;431b
bordes_der:
	ld a,(0ead1h)		;431d   ; ya en la ultima (32)?
	cp 020h		;4320
	ret nc			;4322
	jr estado_8		;4323
estado_salta:		; Salta a la rutina del estado (HL) de la tabla DE (1 la primera); si cambia, (HL+1) = el estado y (HL+2) = 0 (su paso)
	ld a,(hl)			;4325   ; el estado
	inc hl			;4326
	cp (hl)			;4327   ; el de antes?
	jr z,estado_salta_va		;4328
	ld (hl),a			;432a   ; nuevo: apuntado...
	inc hl			;432b
	ld (hl),000h		;432c   ; ...y su paso a 0
estado_salta_va:
	dec a			;432e   ; 0: nada
	ret m			;432f
	ex de,hl			;4330
salta_tabla:		; Salta a la direccion A de la tabla HL
	add a,a			;4331   ; x 2
	ld e,a			;4332
	ld d,000h		;4333
	add hl,de			;4335
	ld a,(hl)			;4336   ; la direccion
	inc hl			;4337
	ld h,(hl)			;4338
	ld l,a			;4339   ; jp (hl)
	jp (hl)			;433a
azar:		; Un numero al azar: R, mas y xor con el anterior (0xE018)
	ld a,r		;433b   ; el registro R
	ld hl,(0e018h)		;433d   ; el anterior
	add a,h			;4340   ; + H
	xor l			;4341   ; xor L
	ld h,l			;4342
	ld l,a			;4343
	ld (0e018h),hl		;4344   ; apuntado
	ret			;4347
mitad_alta:		; A / 16 (las cuatro rotaciones)
	rrca			;4348
	rrca			;4349
	rrca			;434a
	rrca			;434b
	ret			;434c
multiplica:		; HL = DE x A (8 bits)
	ex de,hl			;434d   ; DE el multiplicando
	ld hl,00000h		;434e
	ld b,008h		;4351   ; ocho bits
multiplica_bit:
	rra			;4353   ; un bit
	jr nc,multiplica_sig		;4354
	add hl,de			;4356   ; suma
multiplica_sig:
	ex de,hl			;4357   ; DE x 2
	add hl,hl			;4358
	ex de,hl			;4359
	djnz multiplica_bit		;435a
	ret			;435c
suma_bcd:		; HL = HL + DE en BCD
	ld a,l			;435d   ; los bajos
	add a,e			;435e
	daa			;435f
	ld l,a			;4360
	ld a,h			;4361   ; los altos con el acarreo
	adc a,d			;4362
	daa			;4363
	ld h,a			;4364
	ret			;4365
llena:		; BC bytes de A desde HL (con LDIR)
	push de			;4366
	ld d,h			;4367
	ld e,l			;4368
	ld (hl),a			;4369   ; el primero
	inc de			;436a
	dec bc			;436b
	ldir		;436c   ; y los demas
	pop de			;436e
	ret			;436f
casilla_dir:		; HL = la direccion de la casilla: (D + C) x 64 + (E + B)
	ld a,d			;4370   ; la fila
	add a,c			;4371
	ld l,a			;4372
	ld h,000h		;4373   ; x 64...
	add hl,hl			;4375
	add hl,hl			;4376
	add hl,hl			;4377
	add hl,hl			;4378
	add hl,hl			;4379
	add hl,hl			;437a
	ld a,e			;437b   ; ...+ la columna
	add a,b			;437c
	or l			;437d
	ld l,a			;437e
	ret			;437f
espejo:		; BC bytes de HL a DE con los bits al reves (el espejo)
	push bc			;4380
	ld c,(hl)			;4381   ; un byte
	ld b,008h		;4382   ; ocho bits
espejo_bit:
	rr c		;4384   ; de la derecha...
	rla			;4386   ; ...a la izquierda
	djnz espejo_bit		;4387
	ld (de),a			;4389   ; el espejo
	pop bc			;438a
	inc hl			;438b
	inc de			;438c
	dec bc			;438d   ; uno menos
	ld a,b			;438e
	or c			;438f
	jr nz,espejo		;4390
	ret			;4392
espejo_sprites:		; BC sprites de 32 bytes de HL a DE en espejo: los bits al reves y las dos mitades cambiadas
	push de			;4393
	push bc			;4394
	call espejo		;4395   ; los bits al reves
	pop bc			;4398
	pop de			;4399
	xor a			;439a   ; BC x 8...
	sla c		;439b
	rl b		;439d
	rla			;439f
	sla c		;43a0
	rl b		;43a2
	rla			;43a4
	sla c		;43a5
	rl b		;43a7
	rla			;43a9
	ld c,b			;43aa   ; .../ 256: cuantas mitades
	ld b,a			;43ab
	ld hl,00010h		;43ac   ; la segunda mitad
	add hl,de			;43af
espejo_mitades:
	push bc			;43b0
	ld b,010h		;43b1   ; 16 bytes
espejo_mitad:
	ld a,(de)			;43b3   ; de la primera...
	ld c,(hl)			;43b4   ; ...y de la segunda...
	ex de,hl			;43b5
	ld (de),a			;43b6   ; ...cambiados
	ld (hl),c			;43b7
	inc hl			;43b8
	inc de			;43b9
	djnz espejo_mitad		;43ba
	ld bc,00010h		;43bc   ; el sprite siguiente
	add hl,bc			;43bf
	ex de,hl			;43c0
	add hl,bc			;43c1
	ex de,hl			;43c2
	pop bc			;43c3
	dec bc			;43c4   ; uno menos
	ld a,b			;43c5
	or c			;43c6
	jr nz,espejo_mitades		;43c7
	ret			;43c9
desempaqueta_vram:		; Desempaqueta (0x43D0) y LDIRVM
	call desempaqueta		;43ca
	jp 0005ch		;43cd
desempaqueta:		; Desempaqueta B bloques de HL a 0xE6B1: cada bloque, un byte de mascara y 8 bytes; un bit a 1 lee un byte nuevo, a 0 repite el anterior; BC = B x 8 y HL = 0xE6B1
	push de			;43d0
	push bc			;43d1
	ld de,0e6b1h		;43d2
desempaqueta_bloque:
	push bc			;43d5
	ld a,(hl)			;43d6   ; la mascara
	inc hl			;43d7
	ld c,a			;43d8
	ex af,af'			;43d9   ; el byte anterior guardado
	ld b,008h		;43da   ; ocho bytes
desempaqueta_bit:
	sla c		;43dc   ; un bit
	jr nc,desempaqueta_pon		;43de   ; a 0: el de antes
	ld a,(hl)			;43e0   ; a 1: uno nuevo
	inc hl			;43e1
desempaqueta_pon:
	ld (de),a			;43e2   ; a la RAM
	inc de			;43e3
	djnz desempaqueta_bit		;43e4
	ex af,af'			;43e6
	pop bc			;43e7
	djnz desempaqueta_bloque		;43e8
	pop hl			;43ea   ; los bloques...
	ld l,h			;43eb
	ld h,000h		;43ec
	add hl,hl			;43ee   ; ...x 8
	add hl,hl			;43ef
	add hl,hl			;43f0
	ld c,l			;43f1   ; BC
	ld b,h			;43f2
	pop de			;43f3
	ld hl,0e6b1h		;43f4   ; desde 0xE6B1
	ret			;43f7
desempaqueta_tercios:		; Desempaqueta y a los tres tercios
	call desempaqueta		;43f8
tercios:		; LDIRVM a los tres tercios (DE + 0x800 cada vez)
	ld a,003h		;43fb   ; tres
tercio:
	push af			;43fd
	push hl			;43fe
	push de			;43ff
	push bc			;4400
	call 0005ch		;4401   ; LDIRVM
	pop bc			;4404
	pop de			;4405
	pop hl			;4406
	ld a,d			;4407   ; el tercio siguiente (+ 0x800)
	add a,008h		;4408
	ld d,a			;440a
	pop af			;440b
	dec a			;440c   ; uno menos
	jr nz,tercio		;440d
	ret			;440f
espejo_vram:		; BC bytes de la VRAM (HL) a la RAM, su espejo y a los tres tercios
	push de			;4410
	push bc			;4411
	ld de,0e6a1h		;4412   ; a 0xE6A1
	call 00059h		;4415   ; LDIRMV
	pop bc			;4418
	push bc			;4419
	ld hl,0e6a1h		;441a   ; su espejo...
	ld de,0e821h		;441d   ; ...en 0xE821
	push de			;4420
	call espejo		;4421
	pop hl			;4424   ; desde ahi
	pop bc			;4425
	pop de			;4426
	jr tercios		;4427
ordenes_tercios:		; Las ordenes de casillas (0x4440) en los tres tercios
	ld b,003h		;4429   ; tres
ordenes_tercio:
	push hl			;442b
	push de			;442c
	push bc			;442d
	call ordenes_vram		;442e   ; las ordenes
	pop bc			;4431
	pop de			;4432
	pop hl			;4433
	ld a,008h		;4434   ; el tercio siguiente
	add a,d			;4436
	ld d,a			;4437
	djnz ordenes_tercio		;4438
	ret			;443a
ordenes_vram:		; Desde DE en la VRAM: parejas (valor, cuantas) hasta un 0
	ex de,hl			;443b
	call 00053h		;443c   ; SETWRT
	ex de,hl			;443f
ordenes_vram_una:
	ld a,(hl)			;4440   ; el valor
	inc hl			;4441
	or a			;4442   ; 0: se acaba
	ret z			;4443
	ld b,(hl)			;4444   ; cuantas
	inc hl			;4445
	call vram_b_a		;4446   ; a la VRAM
	jr ordenes_vram_una		;4449
vram_b:		; B bytes de HL a la VRAM, con espera
	ld a,(hl)			;444b   ; un byte
	out (098h),a		;444c
	ex (sp),hl			;444e   ; espera
	ex (sp),hl			;444f
	inc hl			;4450   ; el siguiente
	djnz vram_b		;4451
	ret			;4453
vram_b_atras:		; B bytes a la VRAM leyendo hacia atras
	dec hl			;4454
	ld a,(hl)			;4455   ; un byte hacia atras
	out (098h),a		;4456
	djnz vram_b_atras		;4458
	ret			;445a
nombres_borra:		; La tabla de nombres (0x3800, 0x300) a cero
	ld hl,03800h		;445b
	ld bc,00300h		;445e   ; 0x300 bytes
	xor a			;4461   ; a 0
	jp 00056h		;4462   ; FILVRM
sprites_fuera:		; Los atributos de los sprites (0x3B00, 128 bytes) a 0xC0: la Y fuera
	ld hl,03b00h		;4465
	ld bc,00080h		;4468   ; 128 bytes
	ld a,0c0h		;446b   ; 0xC0
	jp 00056h		;446d   ; FILVRM
fondo_vram:		; El fondo (0xE11A, desde la columna 0xEAD1) a la tabla de nombres desde la fila 4: 18 filas de 32, salvo con 0xEAD2
	ld a,(0ead2h)		;4470   ; 0xEAD2: no
	or a			;4473   ; (la vista se esta moviendo)
	ret nz			;4474
	ld hl,03880h		;4475   ; la fila 4
	call 00053h		;4478   ; SETWRT
	ld hl,0e11ah		;447b   ; el fondo en la RAM...
	ld a,(0ead1h)		;447e   ; ...desde la columna que se ve
	ld e,a			;4481   ; + la columna
	ld d,000h		;4482
	add hl,de			;4484
	ld de,00020h		;4485   ; la fila siguiente: + 32 (el fondo tiene 64 de ancho)
	ld c,012h		;4488   ; 18 filas
fondo_vram_fila:
	ld b,e			;448a   ; 32 casillas
fondo_vram_casilla:
	ld a,(hl)			;448b   ; una casilla
	inc hl			;448c
	out (098h),a		;448d   ; a la VRAM
	djnz fondo_vram_casilla		;448f
	add hl,de			;4491   ; la fila siguiente
	dec c			;4492   ; una menos
	jr nz,fondo_vram_fila		;4493
	ret			;4495
huecos_borra:		; Borra (casilla 0x20) los dos huecos de 0xEABB y 0xEABD en el fondo, tres filas de (+1) + 4 casillas cada uno; y las filas 12-14 de la pantalla de la RAM
	ld a,(0eabbh)		;4496   ; el primero?
	or a			;4499
	jr z,hueco2		;449a
	ld hl,0e158h		;449c   ; su sitio en el fondo
	ld e,a			;449f   ; + su columna
	ld d,000h		;44a0
	add hl,de			;44a2
	ld a,(0eabch)		;44a3   ; su ancho + 4
	add a,004h		;44a6
	ld c,a			;44a8   ; C casillas por fila
	ld a,040h		;44a9   ; 64 menos el ancho: a la fila siguiente
	sub c			;44ab
	ld e,a			;44ac
	ld b,c			;44ad   ; una fila
	ld a,020h		;44ae   ; la casilla 0x20
hueco1_fila1:
	ld (hl),a			;44b0
	inc hl			;44b1
	djnz hueco1_fila1		;44b2
	add hl,de			;44b4   ; la segunda
	ld b,c			;44b5
hueco1_fila2:
	ld (hl),a			;44b6
	inc hl			;44b7
	djnz hueco1_fila2		;44b8
	add hl,de			;44ba
	ld b,c			;44bb   ; la tercera
hueco1_fila3:
	ld (hl),a			;44bc
	inc hl			;44bd
	djnz hueco1_fila3		;44be
hueco2:		; El segundo
	ld a,(0eabdh)		;44c0   ; el segundo?
	or a			;44c3
	jr z,pantalla_ram_borra		;44c4
	ld hl,0e4d8h		;44c6   ; su sitio
	ld e,a			;44c9   ; + su columna
	ld d,000h		;44ca
	add hl,de			;44cc
	ld a,(0eabeh)		;44cd   ; su ancho + 4
	add a,004h		;44d0
	ld c,a			;44d2
	ld a,040h		;44d3   ; 64 menos el ancho
	sub c			;44d5
	ld e,a			;44d6
	ld b,c			;44d7   ; una fila
	ld a,020h		;44d8   ; la casilla 0x20
hueco2_fila1:
	ld (hl),a			;44da
	inc hl			;44db
	djnz hueco2_fila1		;44dc
	add hl,de			;44de
	ld b,c			;44df   ; la segunda
hueco2_fila2:
	ld (hl),a			;44e0
	inc hl			;44e1
	djnz hueco2_fila2		;44e2
	add hl,de			;44e4
	ld b,c			;44e5   ; la tercera
hueco2_fila3:
	ld (hl),a			;44e6
	inc hl			;44e7
	djnz hueco2_fila3		;44e8
pantalla_ram_borra:		; 0xE31A-0xE3D9 (tres filas de 64, las 12-14 de la pantalla de la RAM) a 0x20 con la pila: 16 "push" por vuelta, 6 vueltas
	ld hl,00000h		;44ea   ; la pila, guardada en HL'
	add hl,sp			;44ed
	exx			;44ee
	ld hl,0e3dah		;44ef   ; el final de la zona
	ld de,02020h		;44f2   ; dos casillas 0x20
	ld sp,hl			;44f5   ; la pila apunta alli
	ld b,006h		;44f6   ; 6 vueltas
pantalla_ram_borra_va:
	push de			;44f8   ; 16 "push": 32 casillas
	push de			;44f9
	push de			;44fa
	push de			;44fb
	push de			;44fc
	push de			;44fd
	push de			;44fe
	push de			;44ff
	push de			;4500
	push de			;4501
	push de			;4502
	push de			;4503
	push de			;4504
	push de			;4505
	push de			;4506
	push de			;4507
	djnz pantalla_ram_borra_va		;4508
	exx			;450a   ; la pila de vuelta
	ld sp,hl			;450b
	call tarea_4e5b		;450c   ; los sprites y lo demas
	call columnas_dibuja		;450f
	call marca_isla		;4512
	ld a,(0eacfh)		;4515   ; 0xEACF?
	or a			;4518   ; hay?
	jr z,pantalla_ram_mas		;4519
	ld a,(0e010h)		;451b   ; cada tanto
	or a			;451e
	jr nz,pantalla_ram_dibuja		;451f
	ld hl,0eacfh		;4521   ; uno menos
	dec (hl)			;4524
pantalla_ram_dibuja:
	call cosas_moviles_dibujo		;4525   ; lo dibuja
pantalla_ram_mas:
	ld a,(0eacch)		;4528   ; 0xEACC?
	or a			;452b   ; hay?
	ret z			;452c
	jp cosas_moviles		;452d   ; las mueve
estado:		; Cada cuadro: el estado general (0xEAB1) por la tabla 0x453D
	xor a			;4530   ; 0xEAD2 = 0
	ld (0ead2h),a		;4531   ; (la vista quieta)
	ld hl,0eab1h		;4534   ; el estado
	ld de,0453dh		;4537   ; la tabla
	jp estado_salta		;453a

; ----------------------------------------------------------------------
; DATOS tabla_estados: Los 8 estados generales (0xEAB1): 1 la presentacion
;   (0x454D), 2 el titulo (0x471F), 3 (0x4B21), 4 y 6 (0x4A54), 5 (0x4AB6), 7
;   y 8 el protagonista por un borde (0x5624, 0x562D)
;   0x453d..0x454d  (16 bytes)
DATA_tabla_estados:
	defw 0454dh,0471fh,04b21h,04a54h,04ab6h,04a54h,05624h,0562dh	; 453d

; ======================================================================
; CODIGO 0x454d..0x45dc  (143 bytes)
; ======================================================================


presentacion:		; El estado 1: la presentacion de CASIO: en el primer paso, la pantalla en blanco y las casillas de CASIO; despues, cada 3 cuadros, los cuatro CASIO que se juntan; al acabar, el sonido de CASIO; con el boton, el titulo
	ld hl,0eab3h		;454d   ; el paso
	ld a,(hl)			;4550
	inc (hl)			;4551
	or a			;4552   ; el primero?
	jr nz,presentacion_paso		;4553   ; no: cada 3 cuadros
	ld hl,0e001h		;4555   ; 0xE001 = 0xC0
	ld (hl),0c0h		;4558   ; (sin la demo ni la partida)
	call sonido_calla		;455a   ; el sonido callado
	call 00041h		;455d   ; DISSCR
	call nombres_borra		;4560   ; la tabla de nombres a cero
	call sprites_fuera		;4563   ; los sprites fuera
	ld hl,046b6h		;4566   ; las casillas de CASIO, empaquetadas...
	ld de,00080h		;4569   ; ...a la casilla 0x10 de cada tercio
	ld b,010h		;456c
	call desempaqueta_tercios		;456e
	ld hl,0471ah		;4571   ; y sus colores
	ld de,02080h		;4574
	call ordenes_tercios		;4577
	ld a,001h		;457a   ; el paso 1
	ld (0eab4h),a		;457c
	ld hl,0380ch		;457f   ; la linea que baja (fila 0, columna 12)...
	ld (0eab5h),hl		;4582
	ld hl,03aech		;4585   ; ...y la que sube (fila 23)
	ld (0eab7h),hl		;4588
	jp 00044h		;458b   ; ENASCR
presentacion_paso:		; Cada 3 cuadros
	cp 003h		;458e   ; 3?
	ret c			;4590
	jr nz,presentacion_espera		;4591
	ld (hl),001h		;4593   ; otra vez 1
	call presentacion_lineas		;4595   ; los de arriba y abajo
	call presentacion_lados		;4598   ; los de los lados
	ld hl,0eab4h		;459b   ; un paso mas
	inc (hl)			;459e
	ld a,(hl)			;459f
	cp 015h		;45a0   ; el 21?
	jr nc,presentacion_junta		;45a2
	cp 009h		;45a4   ; desde el 9...
	ret c			;45a6
	ld hl,(0eab5h)		;45a7   ; ...la linea de arriba baja una fila...
	ld bc,00020h		;45aa
	add hl,bc			;45ad
	ld (0eab5h),hl		;45ae
	ld hl,(0eab7h)		;45b1   ; ...y la de abajo sube
	sbc hl,bc		;45b4
	ld (0eab7h),hl		;45b6
	ret			;45b9
presentacion_junta:		; Juntos: el boton a 0, el sonido de CASIO (0xEC0D = 1) y el paso 5
	xor a			;45ba
	ld (0e005h),a		;45bb
	inc a			;45be
	ld (0ec0dh),a		;45bf   ; el sonido de CASIO
	ld a,005h		;45c2
	ld (0eab3h),a		;45c4
	ret			;45c7
presentacion_espera:		; La espera: el boton o el final del sonido (0xF5) llevan al titulo (el estado 2)
	ex de,hl			;45c8
	ld hl,0e005h		;45c9   ; el boton
	ld a,(hl)			;45cc
	ld (hl),000h		;45cd   ; gastado
	or a			;45cf
	jr nz,presentacion_fin		;45d0
	ld a,(de)			;45d2   ; (0xEC0D: 0xF5 si acabo; desde 0xEC0F)
	cp 0f5h		;45d3
	ret nz			;45d5
presentacion_fin:
	ld a,002h		;45d6   ; el estado 2: el titulo
	ld (0eab1h),a		;45d8
	ret			;45db

; ----------------------------------------------------------------------
; DATOS logotipo_casio: Las dos filas del logotipo de CASIO (0x45DD la de
;   arriba, 0x45E6 la de abajo) con un 0 delante y detras
;   0x45dc..0x45ef  (19 bytes)
DATA_logotipo_casio:
	defb 000h,010h,012h,014h,016h,018h,01ah,01ch,01eh,000h,011h,013h,015h,017h,019h,01bh	; 45dc  ................
	defb 01dh,01fh,000h	; 45ec

; ======================================================================
; CODIGO 0x45ef..0x4646  (87 bytes)
; ======================================================================


presentacion_lineas:		; Desde el paso 9: los CASIO de arriba y de abajo, cada uno con una fila en blanco (0x4646) detras, que bajan y suben hacia el centro
	ld a,(0eab4h)		;45ef   ; el paso 9?
	cp 009h		;45f2
	ret c			;45f4
	ld bc,00008h		;45f5   ; 8 casillas
	ld hl,045e6h		;45f8   ; la de abajo...
	ld de,(0eab5h)		;45fb   ; ...en la linea que baja
	push bc			;45ff
	call 0005ch		;4600   ; LDIRVM
	ld de,00020h		;4603   ; una fila arriba
	and a			;4606
	sbc hl,de		;4607
	ex de,hl			;4609
	ld hl,045ddh		;460a   ; la de arriba
	pop bc			;460d
	push bc			;460e
	call 0005ch		;460f   ; LDIRVM
	ld de,00020h		;4612   ; otra fila arriba
	and a			;4615
	sbc hl,de		;4616
	ex de,hl			;4618
	ld hl,04646h		;4619   ; una en blanco encima
	pop bc			;461c
	push bc			;461d
	call 0005ch		;461e   ; LDIRVM
	pop bc			;4621
	push bc			;4622
	ld hl,045ddh		;4623   ; el que sube: la de arriba
	ld de,(0eab7h)		;4626
	call 0005ch		;462a   ; LDIRVM
	ld de,00020h		;462d   ; una fila abajo
	add hl,de			;4630
	ex de,hl			;4631
	ld hl,045e6h		;4632   ; la de abajo
	pop bc			;4635
	push bc			;4636
	call 0005ch		;4637   ; LDIRVM
	ld de,00020h		;463a   ; otra fila abajo
	add hl,de			;463d
	ex de,hl			;463e
	ld hl,04646h		;463f   ; y una en blanco debajo
	pop bc			;4642
	jp 0005ch		;4643

; ----------------------------------------------------------------------
; DATOS fila_blanco: Ocho casillas 0: la fila en blanco detras de los CASIO
;   que suben y bajan
;   0x4646..0x464e  (8 bytes)
DATA_fila_blanco:
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 4646  ........

; ======================================================================
; CODIGO 0x464e..0x46b6  (104 bytes)
; ======================================================================


presentacion_lados:		; Los dos CASIO de los lados en las filas 11 y 12: uno entra por la derecha casilla a casilla (tantas como el paso, 9 como mucho) y el otro por la izquierda, leido desde el final
	ld a,(0eab4h)		;464e   ; el paso
	ld c,a			;4651
	cp 009h		;4652   ; 9 como mucho
	jr c,presentacion_lados_der		;4654
	ld c,009h		;4656
presentacion_lados_der:
	ld hl,03980h		;4658   ; la fila 12, desde la derecha
	ld b,a			;465b   ; la columna menos el paso
	ld a,l			;465c
	sub b			;465d
	ld l,a			;465e
	ex de,hl			;465f
	ld hl,045ddh		;4660   ; la fila de arriba del logotipo
	ld b,000h		;4663   ; C casillas
	call 0005ch		;4665   ; LDIRVM
	ld de,00020h		;4668   ; una fila abajo
	add hl,de			;466b
	ex de,hl			;466c
	ld hl,045e6h		;466d   ; la de abajo
	ld a,(0eab4h)		;4670
	cp 009h		;4673
	jr c,presentacion_lados_der2		;4675
	ld a,009h		;4677   ; 9
presentacion_lados_der2:
	ld c,a			;4679
	call 0005ch		;467a   ; LDIRVM
	ld hl,03960h		;467d   ; el otro: la fila 11
	ld a,(0eab4h)		;4680
	ld c,a			;4683   ; C casillas
	cp 009h		;4684
	jr c,presentacion_lados_izq		;4686
	sub 009h		;4688   ; pasado el 9, se mueve
	add a,l			;468a
	ld l,a			;468b
	ld c,009h		;468c
presentacion_lados_izq:
	ex de,hl			;468e
	ld hl,045e5h		;468f   ; desde el final
	ld a,l			;4692
	sub c			;4693
	jr nc,presentacion_lados_izq2		;4694
	dec h			;4696
presentacion_lados_izq2:
	ld l,a			;4697
	call 0005ch		;4698   ; LDIRVM
	ld de,00020h		;469b   ; una fila abajo
	add hl,de			;469e
	ex de,hl			;469f
	ld a,(0eab4h)		;46a0
	ld c,a			;46a3
	cp 009h		;46a4
	jr c,presentacion_lados_izq3		;46a6
	ld c,009h		;46a8   ; 9
presentacion_lados_izq3:
	ld hl,045eeh		;46aa   ; la de abajo desde el final
	ld a,l			;46ad
	sub c			;46ae
	jr nc,presentacion_lados_izq4		;46af
	dec h			;46b1
presentacion_lados_izq4:
	ld l,a			;46b2
	jp 0005ch		;46b3   ; LDIRVM

; ----------------------------------------------------------------------
; DATOS casillas_casio: Las casillas de CASIO empaquetadas (16 bloques,
;   0x43D0) y las ordenes de sus colores (0x471A)
;   0x46b6..0x471f  (105 bytes)
DATA_casillas_casio:
	defb 0beh,000h,03fh,07fh,0ffh,0f0h,0e0h,09fh,0e0h,0f0h,0ffh,07fh,03fh,000h,0beh,000h	; 46b6  ..?.........?...
	defb 0e0h,0f0h,0f8h,078h,000h,0bfh,000h,039h,079h,0f9h,0f3h,0e3h,000h,0adh,000h,03eh	; 46c6  ...x...9y......>
	defb 07fh,077h,0e3h,0adh,0e3h,0ffh,0c1h,080h,000h,0b9h,000h,003h,007h,00fh,08fh,0f7h	; 46d6  .w..............
	defb 087h,083h,0c0h,0cfh,0e7h,0e3h,000h,0b7h,000h,0feh,0ffh,007h,000h,0feh,0abh,0ffh	; 46e6  ................
	defb 007h,0ffh,0feh,000h,0bah,000h,038h,039h,0bbh,03bh,0c7h,03bh,0bbh,039h,038h,000h	; 46f6  ......89.;.;.98.
	defb 0a6h,000h,0ffh,0c1h,080h,099h,080h,0c1h,0ffh,000h,0b8h,000h,080h,0c0h,0e0h,087h	; 4706  ................
	defb 0e0h,0c0h,080h,000h,0f0h,080h,0f0h,080h,000h	; 4716  .........

; ======================================================================
; CODIGO 0x471f..0x4801  (226 bytes)
; ======================================================================


titulo:		; El estado 2: el titulo. En el primer paso, las casillas (32 bloques de 0x509E desde la 0 y 78 de 0x4801 desde la 0x20), las letras de la BIOS, los colores, el recuadro verde y los textos; despues espera el boton 256 cuadros: con el boton, la partida; si no, la demostracion
	ld a,(0eab3h)		;471f   ; el paso
	or a			;4722
	jp nz,titulo_espera		;4723
	ld (0e00bh),a		;4726   ; 0xE00B a 0
	inc a			;4729
	ld (0eab3h),a		;472a   ; el paso 1...
	ld (0e002h),a		;472d   ; ...y la fase 1
	call 00041h		;4730   ; DISSCR
	call nombres_borra		;4733   ; la tabla de nombres a cero
	ld hl,0509eh		;4736   ; 32 bloques de casillas empaquetadas...
	ld de,00000h		;4739   ; ...desde la casilla 0
	ld b,020h		;473c
	call desempaqueta_tercios		;473e   ; en los tres tercios
	ld hl,04801h		;4741   ; 78 bloques...
	ld de,00100h		;4744   ; ...desde la casilla 0x20: el nombre en kanji y kana
	ld b,04eh		;4747
	call desempaqueta_tercios		;4749
	call letras_bios		;474c   ; las letras de la BIOS
	ld hl,02000h		;474f   ; todos los colores...
	ld bc,01800h		;4752
	ld a,0f0h		;4755   ; ...blanco sobre transparente
	call 00056h		;4757
	ld hl,02100h		;475a   ; desde la casilla 0x20...
	ld bc,00268h		;475d
	push bc			;4760
	ld a,0fch		;4761   ; ...blanco sobre verde (0xFC)
	push af			;4763
	call 00056h		;4764
	ld hl,02900h		;4767   ; y en el segundo tercio
	pop af			;476a
	pop bc			;476b
	call 00056h		;476c
	ld b,009h		;476f   ; el recuadro verde: 9 filas...
	ld hl,03846h		;4771   ; ...desde la fila 2, columna 6
titulo_recuadro:
	push bc			;4774
	push hl			;4775
	ld bc,00015h		;4776   ; 21 casillas...
	ld a,020h		;4779   ; ...0x20 (verde)
	call 00056h		;477b
	pop hl			;477e
	ld bc,00020h		;477f   ; la fila siguiente
	add hl,bc			;4782
	pop bc			;4783
	djnz titulo_recuadro		;4784
	ld hl,03860h		;4786   ; el nombre (0x49AC) desde la fila 3
	ld de,049ach		;4789
	call textos_vram		;478c
	ld hl,039aah		;478f   ; en la fila 13, columna 10...
	ld a,06dh		;4792   ; ...la C en un circulo (0x6D)
	call 0004dh		;4794   ; WRTVRM
	ld de,04a1ch		;4797   ; los textos (0x4A1C)
	call textos_vram		;479a
	ld hl,039f2h		;479d   ; el record en la fila 15, columna 18
	call 00053h		;47a0   ; SETWRT
	ld hl,0e6a0h		;47a3   ; el record
	call numero_vram		;47a6
	jp 00044h		;47a9   ; ENASCR
titulo_espera:		; El boton empieza la partida; 256 cuadros sin el, la demostracion (0xE001 = 0x40); las dos, el estado 4 con cinco vidas y la lista de mandos de la demostracion desde el principio
	ld hl,0e005h		;47ac   ; el boton
	ld a,(hl)			;47af
	ld (hl),000h		;47b0   ; gastado
	or a			;47b2
	jr nz,titulo_partida		;47b3
	ld hl,0eab3h		;47b5   ; un cuadro mas
	inc (hl)			;47b8   ; aun no 256
	ret nz			;47b9
	ld a,040h		;47ba   ; la demostracion
	jr titulo_fin		;47bc
titulo_partida:
	call partida_borra		;47be   ; una partida
	xor a			;47c1   ; sin demostracion
titulo_fin:
	ld (0e001h),a		;47c2   ; 0xE001
	ld a,004h		;47c5   ; el estado 4
	ld (0eab1h),a		;47c7
	inc a			;47ca   ; cinco vidas
	ld (0eae3h),a		;47cb
	ld hl,041cbh		;47ce   ; la lista de mandos de la demostracion
	ld (0e009h),hl		;47d1
	ret			;47d4
textos_vram:		; Una lista de textos: (cuanto avanzar en la VRAM, las casillas hasta un 0)... y un 0 al final; HL la VRAM
	ld a,(de)			;47d5   ; cuanto avanzar
	inc de			;47d6
	or a			;47d7   ; 0: acaba
	ret z			;47d8
	add a,l			;47d9   ; HL + eso
	ld l,a			;47da
	jr nc,texto_casilla		;47db
	inc h			;47dd
texto_casilla:
	ld a,(de)			;47de   ; una casilla
	inc de			;47df
	or a			;47e0   ; 0: el texto siguiente
	jr z,textos_vram		;47e1
	call 0004dh		;47e3   ; WRTVRM
	inc hl			;47e6
	jr texto_casilla		;47e7
letras_bios:		; Las letras de la BIOS ("0" a "_", 0x1D3F) a las casillas 0x80 del segundo y del tercer tercio
	ld hl,01d3fh		;47e9   ; la fuente desde el "0"...
	ld de,00c00h		;47ec   ; ...a la casilla 0x80 del segundo tercio
	ld bc,00180h		;47ef   ; 0x180 bytes
	call 0005ch		;47f2   ; LDIRVM
	ld hl,01d3fh		;47f5
	ld de,01400h		;47f8   ; y del tercero
	ld bc,00180h		;47fb
	jp 0005ch		;47fe

; ----------------------------------------------------------------------
; DATOS titulo_casillas: Los dibujos de las casillas del nombre (シンドバッド
;   7つの冒険), empaquetados: 78 bloques de mascara y 8 bytes
;   0x4801..0x49ac  (427 bytes)
DATA_titulo_casillas:
	defb 080h,000h,081h,000h,001h,0bdh,000h,020h,010h,018h,00ch,000h,084h,000h,002h,098h	; 4801  ....... ........
	defb 000h,001h,000h,09fh,000h,080h,060h,038h,01ch,00ch,082h,000h,004h,0b0h,000h,001h	; 4811  ......`8........
	defb 000h,0bdh,000h,080h,0e0h,0c2h,0c1h,0c0h,0bfh,000h,040h,020h,030h,000h,080h,000h	; 4821  ..........@ 0...
	defb 086h,000h,003h,001h,087h,000h,098h,0cch,086h,0beh,000h,010h,088h,04ch,060h,000h	; 4831  .............L`.
	defb 081h,000h,040h,0c0h,001h,000h,0e8h,080h,0c0h,060h,000h,0dfh,006h,004h,00ch,018h	; 4841  ..@......`......
	defb 030h,060h,0c0h,081h,000h,001h,0afh,008h,010h,020h,060h,0c0h,080h,0feh,0c0h,0e0h	; 4851  0`....... `.....
	defb 0d8h,0ceh,0c7h,0c3h,0c0h,0a5h,001h,003h,006h,00ch,0f0h,083h,081h,001h,000h,0d4h	; 4861  ................
	defb 000h,080h,0c0h,060h,0feh,000h,008h,00ch,006h,007h,003h,000h,0f9h,061h,030h,038h	; 4871  ...`.........a08
	defb 018h,000h,001h,0e6h,080h,0f0h,060h,0c0h,080h,0e0h,000h,001h,000h,0fch,001h,007h	; 4881  ......`.........
	defb 0feh,078h,040h,000h,0c0h,080h,000h,0f4h,000h,00ch,007h,003h,000h,0f8h,001h,03eh	; 4891  .x@............>
	defb 0fch,0c0h,000h,08ah,000h,001h,000h,081h,0c0h,000h,0f8h,00ch,018h,030h,060h,000h	; 48a1  .............0`.
	defb 090h,030h,000h,0feh,001h,003h,006h,00ch,018h,070h,000h,08bh,000h,007h,006h,004h	; 48b1  .0.......p......
	defb 08ah,000h,0ffh,000h,08ah,000h,0e0h,060h,081h,000h,01fh,081h,000h,0c0h,083h,000h	; 48c1  .......`........
	defb 003h,006h,087h,000h,0ffh,090h,010h,087h,000h,080h,0e0h,030h,0bbh,000h,010h,01fh	; 48d1  ...........0....
	defb 018h,01fh,018h,09bh,000h,0ffh,000h,0ffh,000h,0bbh,000h,008h,0f8h,018h,0f8h,018h	; 48e1  ................
	defb 0bah,000h,021h,03fh,033h,032h,0bbh,000h,003h,083h,006h,00ch,018h,08fh,000h,080h	; 48f1  ..!?32..........
	defb 040h,020h,030h,0c0h,004h,000h,0fbh,000h,001h,003h,006h,00ch,01ch,018h,0e0h,0c0h	; 4901  @ 0.............
	defb 080h,000h,0f0h,031h,01fh,00eh,000h,0e0h,0f0h,0c0h,000h,0e1h,070h,018h,00ch,018h	; 4911  ...1........p...
	defb 0d0h,00ch,018h,030h,08ch,010h,030h,020h,0c0h,018h,00ch,0feh,018h,01fh,018h,000h	; 4921  ...0..0 ........
	defb 004h,007h,006h,0e6h,000h,0ffh,000h,0ffh,000h,0feh,018h,0f8h,008h,000h,020h,0f0h	; 4931  .............. .
	defb 060h,0f8h,034h,039h,034h,032h,033h,0ech,060h,0bfh,003h,07fh,063h,0fch,01eh,0ech	; 4941  `.49423.`...c...
	defb 004h,000h,0f8h,018h,084h,038h,000h,0f8h,000h,001h,007h,0fch,000h,0f0h,078h,0e0h	; 4951  .....8........x.
	defb 0c0h,000h,0f8h,030h,018h,00fh,007h,000h,0fch,040h,0c0h,080h,000h,01fh,000h,0fch	; 4961  ...0.....@......
	defb 00ch,018h,038h,0f0h,080h,000h,0dbh,007h,006h,007h,006h,007h,006h,0dbh,0ffh,000h	; 4971  ..8.............
	defb 0ffh,000h,0ffh,000h,0dbh,0e0h,060h,0e0h,060h,0e0h,020h,0f0h,033h,03fh,036h,030h	; 4981  ......`.`. .3?60
	defb 0ffh,07fh,063h,003h,006h,00ch,018h,030h,0c0h,0ffh,0f8h,008h,000h,080h,060h,038h	; 4991  ..c....0......`8
	defb 01eh,00ch,0ffh,07ch,082h,0bah,0a2h,0bah,082h,07ch,000h	; 49a1  ...|.....|.

; ----------------------------------------------------------------------
; DATOS titulo_nombre: El nombre en casillas: (cuanto avanzar, las casillas,
;   0) seis veces y un 0
;   0x49ac..0x4a1c  (112 bytes)
DATA_titulo_nombre:
	defb 007h,021h,022h,023h,024h,025h,026h,027h,028h,029h,02ah,02bh,02ch,020h,02dh,020h	; 49ac  .!"#$%&'()*+, - 
	defb 027h,028h,029h,000h,00eh,02eh,02fh,030h,020h,031h,032h,020h,033h,020h,034h,035h	; 49bc  '().../0 12 3 45
	defb 036h,037h,038h,039h,020h,033h,020h,000h,00eh,03ah,03bh,03ch,03dh,03eh,020h,03fh	; 49cc  6789 3 ..:;<=> ?
	defb 040h,020h,041h,020h,042h,020h,043h,020h,03fh,040h,020h,000h,031h,044h,045h,046h	; 49dc  @ A B C ?@ .1DEF
	defb 020h,047h,048h,049h,04ah,04bh,04ch,04dh,04eh,04fh,050h,051h,000h,011h,052h,053h	; 49ec   GHIJKLMNOPQ..RS
	defb 054h,055h,056h,057h,058h,059h,05ah,05bh,05ch,05dh,05eh,05fh,060h,000h,011h,020h	; 49fc  TUVWXYZ[\]^_`.. 
	defb 061h,020h,024h,062h,063h,064h,065h,066h,067h,068h,069h,06ah,06bh,06ch,000h,000h	; 4a0c  a $bcdefghijkl..

; ----------------------------------------------------------------------
; DATOS titulo_textos: "1986 CASIO", "HIGH SCORE", "PUSH TRIGGER 1", "OR" y
;   "SPACE KEY" en las casillas de la BIOS (0x80 + letra - 0x30; 0x1F el
;   espacio)
;   0x4a1c..0x4a54  (56 bytes)
DATA_titulo_textos:
	defb 002h,081h,089h,088h,086h,01fh,093h,091h,0a3h,099h,09fh,000h,031h,098h,099h,097h	; 4a1c  ............1...
	defb 098h,01fh,0a3h,093h,09fh,0a2h,095h,000h,038h,0a0h,0a5h,0a3h,098h,01fh,0a4h,0a2h	; 4a2c  ........8.......
	defb 099h,097h,097h,095h,0a2h,01fh,081h,000h,038h,09fh,0a2h,000h,03bh,0a3h,0a0h,091h	; 4a3c  ........8...;...
	defb 093h,095h,01fh,09bh,095h,0a9h,000h,000h	; 4a4c  ........

; ======================================================================
; CODIGO 0x4a54..0x4aa9  (85 bytes)
; ======================================================================


ronda_cartel:		; Los estados 4 y 6: el cartel ROUND (la vuelta, 0xE003) e ISLAND (la isla, 0xE002) en el centro de la pantalla; la musica de la isla (la 7 desde la segunda vuelta, la isla + 4 en la primera); despues el estado 3
	ld hl,0e001h		;4a54   ; 0xE001 sin el bit 3
	res 3,(hl)		;4a57
	call nombres_borra		;4a59   ; la pantalla en blanco
	call letras_pon		;4a5c   ; las letras
	ld de,0394ch		;4a5f   ; en la fila 10, columna 12...
	ld hl,04aa9h		;4a62   ; ...ROUND
	ld bc,00006h		;4a65
	call 0005ch		;4a68
	ld a,(0e003h)		;4a6b   ; la vuelta
	call bcd_vram		;4a6e   ; en dos cifras
	ld de,0398ch		;4a71   ; en la fila 12, columna 12...
	ld hl,04aafh		;4a74   ; ...ISLAND
	ld bc,00007h		;4a77
	call 0005ch		;4a7a
	ld a,(0e002h)		;4a7d   ; la isla...
	or 010h		;4a80   ; ...como cifra
	out (098h),a		;4a82
	ld hl,0e001h		;4a84   ; 0xE001 sin los bits 0 y 1
	ld a,(hl)			;4a87
	and 0fch		;4a88   ; sin los bits 0 y 1 (la isla sin abrir)
	ld (hl),a			;4a8a
	ld a,(0e003h)		;4a8b   ; la primera vuelta?
	dec a			;4a8e
	jr nz,ronda_musica7		;4a8f   ; otra vuelta: 7
	ld a,(0e002h)		;4a91   ; la isla + 4...
	add a,004h		;4a94
	cp 008h		;4a96   ; ...hasta 7
	jr c,ronda_musica		;4a98
ronda_musica7:
	ld a,007h		;4a9a   ; la musica 7
ronda_musica:
	ld (0eb29h),a		;4a9c   ; la musica (0xEB29)
	ld a,008h		;4a9f   ; 0xEAD3 = 8
	ld (0ead3h),a		;4aa1   ; (el protagonista llega con el pajaro)
	xor a			;4aa4   ; el estado 0
	ld (0eab1h),a		;4aa5   ; (la isla se pone en el paso siguiente)
	ret			;4aa8

; ----------------------------------------------------------------------
; DATOS textos_ronda: "ROUND " e "ISLAND " en las casillas de la BIOS (0x80 +
;   letra - 0x30)
;   0x4aa9..0x4ab6  (13 bytes)
DATA_textos_ronda:
	defb 0a2h,09fh,0a5h,09eh,094h,000h,099h,0a3h,09ch,091h,09eh,094h,000h	; 4aa9  .............

; ======================================================================
; CODIGO 0x4ab6..0x4b18  (98 bytes)
; ======================================================================


game_over:		; El estado 5: GAME OVER. Las letras, la musica 5 (0xEC25 y 0xEC30); el cartel; cuando acaba la musica, 48 cuadros o el boton, y la presentacion
	ld hl,0eab3h		;4ab6   ; el paso
	ld a,(hl)			;4ab9
	or a			;4aba
	jr nz,game_over_cartel		;4abb
	inc (hl)			;4abd   ; el paso 1
	ld a,005h		;4abe   ; la musica 5
	ld (0ec25h),a		;4ac0
	ld (0ec30h),a		;4ac3
letras_pon:		; Las letras de la BIOS y sus colores (0x2C00, 0x400 bytes de blanco)
	call letras_bios		;4ac6
	ld hl,02c00h		;4ac9   ; los colores de las letras
	ld bc,00400h		;4acc
	ld a,0f0h		;4acf   ; blanco sobre transparente
	call 00056h		;4ad1
	ret			;4ad4
game_over_cartel:
	dec a			;4ad5   ; el paso 1?
	jr nz,game_over_musica		;4ad6
	inc (hl)			;4ad8
	ld de,0398ch		;4ad9   ; en la fila 12, columna 12...
	ld hl,04b18h		;4adc   ; ...GAME OVER
	ld bc,00009h		;4adf
	call 0005ch		;4ae2   ; LDIRVM
	ld hl,0e001h		;4ae5   ; 0xE001 sin el bit 3
	res 3,(hl)		;4ae8
	ret			;4aea
game_over_musica:
	dec a			;4aeb   ; el paso 2: la musica acabada?
	jr nz,game_over_espera		;4aec
	ld a,(0ec25h)		;4aee
	or a			;4af1
	ret nz			;4af2
	inc (hl)			;4af3   ; el paso 3
	xor a			;4af4   ; la cuenta y los botones a 0
	ld (0eabah),a		;4af5
	ld (0e005h),a		;4af8
	ld (0e006h),a		;4afb
	ret			;4afe
game_over_espera:
	ld a,(0e005h)		;4aff   ; el boton?
	or a			;4b02   ; pulsado?
	jr nz,game_over_fin		;4b03
	ld a,(0e00ch)		;4b05   ; cada 10 cuadros...
	or a			;4b08   ; la cuenta 0xE00C a 0?
	ret nz			;4b09
	ld hl,0eabah		;4b0a   ; ...una mas
	inc (hl)			;4b0d
	ld a,(hl)			;4b0e   ; 48?
	cp 030h		;4b0f   ; 48?
	ret c			;4b11
game_over_fin:
	ld a,001h		;4b12   ; el estado 1: la presentacion
	ld (0eab1h),a		;4b14
	ret			;4b17

; ----------------------------------------------------------------------
; DATOS texto_game_over: "GAME OVER" en las casillas de la BIOS
;   0x4b18..0x4b21  (9 bytes)
DATA_texto_game_over:
	defb 097h,091h,09dh,095h,020h,09fh,0a6h,095h,0a2h	; 4b18  .... ....

; ======================================================================
; CODIGO 0x4b21..0x4cf8  (471 bytes)
; ======================================================================


isla_pon:		; El estado 3: la isla. Los dibujos (empaquetados: 0x509E, 0x51FF, 0x5208) y sus colores (0x52D6), los espejos de unas casillas, el fondo de la isla (0xE01A, 64 de ancho) desde la tabla de su isla (0x5496), los dos huecos (0x5411), los enemigos y las cosas de la isla; despues el marcador y ENASCR
	call 00041h		;4b21   ; DISSCR
	call sprites_fuera		;4b24   ; los sprites fuera
	ld hl,0509eh		;4b27   ; 59 bloques desde la casilla 0
	ld de,00000h		;4b2a   ; en los tres tercios
	ld b,03bh		;4b2d   ; 59 bloques
	call desempaqueta_tercios		;4b2f
	ld hl,051ffh		;4b32   ; uno a la casilla 0x3F
	ld de,001f8h		;4b35   ; la casilla 0x3F
	ld b,001h		;4b38
	call desempaqueta_tercios		;4b3a
	ld hl,05208h		;4b3d   ; 34 desde la casilla 0x40
	ld de,00200h		;4b40   ; la casilla 0x40
	ld b,022h		;4b43
	call desempaqueta_tercios		;4b45
	ld hl,052d6h		;4b48   ; los colores
	ld de,02000h		;4b4b   ; la tabla de colores
	call ordenes_tercios		;4b4e
	ld b,003h		;4b51   ; tres casillas con su espejo
	ld hl,00110h		;4b53   ; desde la casilla 0x22...
	ld de,001d8h		;4b56   ; ...su espejo en la 0x3B
	ld ix,04cf8h		;4b59   ; la lista de grupos
	call espejos_pon		;4b5d
	ld hl,00238h		;4b60   ; y seis mas
	ld de,00310h		;4b63   ; su espejo desde la 0x62
	ld b,006h		;4b66
	call espejos_pon		;4b68
	ld hl,0e01ah		;4b6b   ; el fondo (0xE01A, 0x600 bytes)...
	ld bc,00600h		;4b6e   ; 0x600 bytes
	ld a,020h		;4b71   ; ...en blanco (0x20)
	call llena		;4b73   ; llena
	ld a,(0e002h)		;4b76   ; la isla
	ld c,a			;4b79   ; en C
	ld ix,05496h		;4b7a   ; la tabla de las islas
isla_busca:		; Se salta hasta la de la isla: dos listas acabadas en 0 por isla
	dec c			;4b7e   ; la isla?
	jr z,isla_suelo		;4b7f
	inc ix		;4b81   ; la siguiente
	ld b,002h		;4b83   ; dos listas
isla_busca_byte:
	ld a,(ix+000h)		;4b85   ; un byte
	inc ix		;4b88
	or a			;4b8a   ; 0: acaba una lista
	jr nz,isla_busca_byte		;4b8b
	djnz isla_busca_byte		;4b8d
	jr isla_busca		;4b8f   ; otra isla
isla_suelo:		; Las 8 filas del suelo (0x54F7) en el fondo desde 0xE09A, cada una con su hueco de la isla
	ld hl,054f7h		;4b91   ; las filas del suelo
	ld b,008h		;4b94   ; 8
	ld de,0e09ah		;4b96   ; desde 0xE09A
isla_suelo_fila:
	push bc			;4b99
	ld a,(ix+000h)		;4b9a   ; su principio
	add a,l			;4b9d
	ld l,a			;4b9e
	jr nc,isla_suelo_copia		;4b9f
	inc h			;4ba1
isla_suelo_copia:
	ld a,020h		;4ba2   ; 32 - eso
	sub (ix+000h)		;4ba4   ; (el resto, desde el principio)
	ld c,a			;4ba7   ; C bytes
	ld b,000h		;4ba8
	ldir		;4baa   ; copiados
	ld a,020h		;4bac   ; 32 + el principio
	add a,(ix+000h)		;4bae
	add a,e			;4bb1   ; + DE: la fila siguiente
	ld e,a			;4bb2
	jr nc,isla_suelo_sig		;4bb3
	inc d			;4bb5
isla_suelo_sig:
	pop bc			;4bb6
	djnz isla_suelo_fila		;4bb7   ; una fila menos
	inc ix		;4bb9   ; la lista de las piezas
	ld de,0e45ah		;4bbb   ; las escaleras y las plataformas: desde 0xE45A, dos listas
	ld b,002h		;4bbe
isla_piezas:
	ld a,(ix+000h)		;4bc0   ; la pieza
	inc ix		;4bc3
	or a			;4bc5   ; 0: la lista siguiente
	jr z,isla_piezas_sig		;4bc6
	cp 003h		;4bc8   ; 3: una escalera
	jr z,isla_escalera		;4bca
	call plataforma		;4bcc   ; otra: una plataforma
	jr isla_piezas		;4bcf
isla_escalera:
	call escalera		;4bd1
	jr isla_piezas		;4bd4
isla_piezas_sig:
	ld a,(ix+000h)		;4bd6   ; cuanto avanzar
	add a,e			;4bd9
	ld e,a			;4bda
	jr nc,isla_piezas_va		;4bdb
	inc d			;4bdd
isla_piezas_va:
	inc ix		;4bde
	djnz isla_piezas		;4be0
	ld a,(0e002h)		;4be2   ; la isla - 1...
	dec a			;4be5   ; ...x 4
	add a,a			;4be6
	add a,a			;4be7
	ld hl,05411h		;4be8   ; la tabla de los huecos
	add a,l			;4beb   ; + la isla
	ld l,a			;4bec
	jr nc,isla_huecos		;4bed
	inc h			;4bef
isla_huecos:
	ld bc,00004h		;4bf0   ; los dos huecos (4 bytes)...
	push hl			;4bf3   ; la tabla...
	ld de,0eabbh		;4bf4   ; ...a 0xEABB
	ldir		;4bf7   ; ...copiada
	pop hl			;4bf9   ; los dos huecos dibujados
	ld de,0e218h		;4bfa   ; el primero en el fondo
	call hueco_pon		;4bfd
	ld de,0e598h		;4c00   ; el segundo
	call hueco_pon		;4c03   ; dibujado
	ld hl,0e3dah		;4c06   ; la fila de 0x21
	ld a,021h		;4c09   ; la casilla 0x21
	ld bc,00040h		;4c0b   ; una fila
	call llena		;4c0e
	ld hl,0e41ah		;4c11   ; y la de 0x24
	ld a,024h		;4c14   ; la casilla 0x24
	ld bc,00040h		;4c16
	call llena		;4c19
	ld hl,0542dh		;4c1c   ; las cosas de 0x542D
	call lista_isla		;4c1f   ; la de esta isla
	ld (0eabfh),hl		;4c22   ; 0xEABF
	call columnas_pon		;4c25   ; las columnas
	ld hl,05452h		;4c28   ; las de 0x5452
	call lista_isla		;4c2b
	ld (0eac1h),hl		;4c2e   ; 0xEAC1
	call cosas4_pon		;4c31   ; cosas de cuatro filas
	ld hl,0545eh		;4c34   ; las de 0x545E
	call lista_isla		;4c37
	call cosas8_pon		;4c3a   ; cosas de 8 + 8
	ld hl,0546ah		;4c3d   ; las de 0x546A
	call lista_isla		;4c40
	call cosas6_pon		;4c43   ; cosas de 6
	ld hl,0547ch		;4c46   ; las de 0x547C
	call lista_isla		;4c49
	ld (0eac3h),hl		;4c4c   ; 0xEAC3
	call cosas7_pon		;4c4f   ; cosas de 7
	ld hl,04f78h		;4c52   ; 0xEACD = 0x4F78
	ld (0eacdh),hl		;4c55
	xor a			;4c58   ; 0xEACC y 0xEACF a 0
	ld (0eacch),a		;4c59
	ld (0eacfh),a		;4c5c
	call azar		;4c5f   ; al azar...
	and 03fh		;4c62   ; 0-63...
	or 0c0h		;4c64   ; ...0xC0-0xFF
	ld (0eacbh),a		;4c66   ; 0xEACB
	ld de,05488h		;4c69   ; la tabla de 0x5488 por la isla
	ld hl,(0e002h)		;4c6c   ; la isla...
	dec l			;4c6f   ; ...- 1
	ld h,000h		;4c70
	add hl,de			;4c72   ; + la tabla
	ld (0eac7h),hl		;4c73   ; 0xEAC7
	ld hl,0548fh		;4c76   ; la de 0x548F
	call lista_isla		;4c79
	ld (0eac9h),hl		;4c7c   ; 0xEAC9
	xor a			;4c7f   ; la columna 0 y el estado 0
	ld (0ead1h),a		;4c80
	ld (0eab1h),a		;4c83   ; el estado 0: la partida
	call fondo_pantalla		;4c86   ; 0x5645
	call marcador		;4c89   ; el marcador
	jp 00044h		;4c8c   ; ENASCR
plataforma:		; Una plataforma: 6 filas de 4 casillas de 0x55F7 en DE (filas de 64), y DE 4 mas alla
	push de			;4c8f   ; guardados
	push bc			;4c90
	ld hl,055f7h		;4c91   ; las casillas
	ld b,006h		;4c94   ; 6 filas
plataforma_fila:
	push bc			;4c96
	ld bc,00004h		;4c97   ; 4 casillas
	ldir		;4c9a   ; copiadas
	ld a,03ch		;4c9c   ; la fila siguiente: 64 - 4
	add a,e			;4c9e
	ld e,a			;4c9f
	jr nc,plataforma_sig		;4ca0
	inc d			;4ca2
plataforma_sig:
	pop bc			;4ca3
	djnz plataforma_fila		;4ca4   ; una fila menos
	pop bc			;4ca6
	pop de			;4ca7
	ld a,004h		;4ca8   ; DE + 4
	add a,e			;4caa
	ld e,a			;4cab
	jr nc,plataforma_fin		;4cac
	inc d			;4cae
plataforma_fin:
	ret			;4caf
escalera:		; Una escalera: 6 filas de 3 casillas de 0x560F, y DE 3 mas alla
	push de			;4cb0
	push bc			;4cb1
	ld hl,0560fh		;4cb2   ; las casillas
	ld b,006h		;4cb5   ; 6 filas
escalera_fila:
	push bc			;4cb7
	ld bc,00003h		;4cb8   ; 3 casillas
	ldir		;4cbb   ; copiadas
	ld a,03dh		;4cbd   ; la fila siguiente: 64 - 3
	add a,e			;4cbf
	ld e,a			;4cc0
	jr nc,escalera_sig		;4cc1
	inc d			;4cc3
escalera_sig:
	pop bc			;4cc4
	djnz escalera_fila		;4cc5   ; una fila menos
	pop bc			;4cc7
	pop de			;4cc8
	ld a,003h		;4cc9   ; DE + 3
	add a,e			;4ccb
	ld e,a			;4ccc
	jr nc,escalera_fin		;4ccd
	inc d			;4ccf
escalera_fin:
	ret			;4cd0
espejos_pon:		; B grupos de la tabla IX: n casillas de HL con su espejo en DE, y los avances
	push bc			;4cd1   ; guardados
	push de			;4cd2
	push hl			;4cd3
	push ix		;4cd4
	ld c,(ix+000h)		;4cd6   ; cuantas
	ld b,000h		;4cd9
	call espejo_vram		;4cdb   ; con espejo, en los tres tercios
	pop ix		;4cde
	pop hl			;4ce0
	pop de			;4ce1
	ld a,(ix+000h)		;4ce2   ; cuanto avanzar en DE
	add a,e			;4ce5
	ld e,a			;4ce6
	jr nc,espejos_sig		;4ce7
	inc d			;4ce9
espejos_sig:
	inc ix		;4cea   ; la siguiente
	ld c,(ix+000h)		;4cec   ; cuanto avanzar en HL
	inc ix		;4cef
	ld b,000h		;4cf1
	add hl,bc			;4cf3   ; HL + eso
	pop bc			;4cf4
	djnz espejos_pon		;4cf5   ; un grupo menos
	ret			;4cf7

; ----------------------------------------------------------------------
; DATOS espejos_lista: Los 9 grupos de espejos_pon (cuantas casillas, cuanto
;   avanzar): 3 para las casillas 0x22 y 6 para las 0x47
;   0x4cf8..0x4d0a  (18 bytes)
DATA_espejos_lista:
	defb 010h,018h,008h,010h,008h,000h,020h,028h,018h,040h,018h,020h,008h,018h,010h,018h	; 4cf8  ...... (.@. ....
	defb 010h,000h	; 4d08

; ======================================================================
; CODIGO 0x4d0a..0x4daa  (160 bytes)
; ======================================================================


hueco_pon:		; Un hueco en el fondo (DE, filas de 64): avanza (HL) casillas; arriba 0x22, 0x23, (HL+1) casillas 0x21 y 0x3C, 0x3B; debajo 0x25, (HL+1) + 2 casillas 0x24 y 0x3D
	ld a,(hl)			;4d0a   ; cuanto avanzar
	inc hl			;4d0b
	or a			;4d0c   ; 0: nada
	jr z,hueco_fin		;4d0d
	add a,e			;4d0f   ; DE + eso
	ld e,a			;4d10
	jr nc,hueco_arriba		;4d11
	inc d			;4d13
hueco_arriba:
	push de			;4d14   ; la fila de arriba
	ld a,022h		;4d15   ; 0x22...
	ld (de),a			;4d17
	inc de			;4d18
	inc a			;4d19   ; ...0x23
	ld (de),a			;4d1a
	inc de			;4d1b
	ld b,(hl)			;4d1c   ; el ancho
	ld a,021h		;4d1d   ; 0x21
hueco_arriba_medio:
	ld (de),a			;4d1f   ; la casilla
	inc de			;4d20
	djnz hueco_arriba_medio		;4d21   ; una menos
	ld a,03ch		;4d23   ; 0x3C...
	ld (de),a			;4d25
	inc de			;4d26
	dec a			;4d27   ; ...0x3B
	ld (de),a			;4d28
	pop de			;4d29
	ld a,040h		;4d2a   ; la fila de abajo (+64)
	add a,e			;4d2c
	ld e,a			;4d2d
	jr nc,hueco_abajo		;4d2e
	inc d			;4d30
hueco_abajo:
	ld a,025h		;4d31   ; 0x25
	ld (de),a			;4d33
	inc de			;4d34
	ld b,(hl)			;4d35   ; el ancho + 2...
	inc b			;4d36
	inc b			;4d37
	ld a,024h		;4d38   ; ...de 0x24
hueco_abajo_medio:
	ld (de),a			;4d3a   ; la casilla
	inc de			;4d3b
	djnz hueco_abajo_medio		;4d3c
	ld a,03dh		;4d3e   ; 0x3D
	ld (de),a			;4d40
hueco_fin:
	inc hl			;4d41   ; la entrada siguiente
	ret			;4d42
columnas_pon:		; Las columnas de la lista HL: en cada posicion (que crece; si baja, desde 0xE41A), seis filas de 0x26 hacia abajo desde 0xE25A
	ld de,0e25ah		;4d43   ; desde 0xE25A
	ld c,000h		;4d46   ; la posicion de antes
columna_una:
	ld a,(hl)			;4d48
	or a			;4d49   ; 0: acaba
	ret z			;4d4a
	inc hl			;4d4b   ; la siguiente
	cp c			;4d4c   ; menor que la anterior?
	jr nc,columna_pon		;4d4d
	ld de,0e41ah		;4d4f   ; otra parte: desde 0xE41A
columna_pon:
	ld c,a			;4d52   ; la de ahora
	push de			;4d53
	add a,e			;4d54   ; DE + la posicion
	ld e,a			;4d55
	jr nc,columna_filas		;4d56
	inc d			;4d58
columna_filas:
	ld b,006h		;4d59   ; seis filas
columna_casilla:
	ld a,026h		;4d5b   ; 0x26
	ld (de),a			;4d5d   ; en el fondo
	ld a,040h		;4d5e   ; la fila de abajo
	add a,e			;4d60
	ld e,a			;4d61
	jr nc,columna_sig		;4d62
	inc d			;4d64
columna_sig:
	djnz columna_casilla		;4d65   ; una fila menos
	pop de			;4d67   ; otra vez desde el principio
	jr columna_una		;4d68
lista_isla:		; HL = la lista de la isla (0xE002): se salta (isla - 1) listas acabadas en 0
	ld a,(0e002h)		;4d6a   ; la isla
	ld b,a			;4d6d
lista_isla_sig:
	dec b			;4d6e   ; una menos
	ret z			;4d6f
lista_isla_byte:
	ld a,(hl)			;4d70   ; un byte
	inc hl			;4d71
	or a			;4d72   ; 0: acaba una
	jr nz,lista_isla_byte		;4d73
	jr lista_isla_sig		;4d75
cosas4_pon:		; Las cosas de la lista (fila en los bits 6-7, columna en 0-5): cuatro filas de 0x4DAA, una debajo de otra, en el fondo (0xE11A + fila x 0x1C0)
	ld a,(hl)			;4d77   ; 0: acaba
	or a			;4d78
	ret z			;4d79
	push hl			;4d7a   ; la lista guardada
	ex de,hl			;4d7b
	rlca			;4d7c   ; la fila (bits 6-7)...
	rlca			;4d7d
	and 003h		;4d7e
	ld hl,001c0h		;4d80   ; ...x 0x1C0 (7 filas de 64)
	push de			;4d83
	call multiplica		;4d84   ; HL = DE x A
	pop de			;4d87
	ld bc,0e11ah		;4d88   ; + el fondo
	add hl,bc			;4d8b
	ld a,(de)			;4d8c   ; la columna
	inc de			;4d8d
	and 03fh		;4d8e
	add a,l			;4d90   ; + la columna
	ld l,a			;4d91
	jr nc,cosas4_casillas		;4d92
	inc h			;4d94
cosas4_casillas:
	ld b,004h		;4d95   ; cuatro filas
	ld de,04daah		;4d97   ; de 0x4DAA
cosas4_fila:
	ld a,(de)			;4d9a   ; la casilla
	ld (hl),a			;4d9b   ; al fondo
	inc de			;4d9c
	ld a,040h		;4d9d   ; la de abajo
	add a,l			;4d9f
	ld l,a			;4da0
	jr nc,cosas4_sig		;4da1
	inc h			;4da3
cosas4_sig:
	djnz cosas4_fila		;4da4   ; una fila menos
	pop hl			;4da6
	inc hl			;4da7   ; la siguiente
	jr cosas4_pon		;4da8

; ----------------------------------------------------------------------
; DATOS cosas4_dibujo: Las cuatro casillas de 0x4D77, de arriba abajo
;   0x4daa..0x4dae  (4 bytes)
DATA_cosas4_dibujo:
	defb 033h,034h,034h,034h	; 4daa

; ======================================================================
; CODIGO 0x4dae..0x4de1  (51 bytes)
; ======================================================================


cosas8_pon:		; Lo mismo con 8 + 8 casillas de 0x4DE1 (dos filas) desde 0xE21A
	ld a,(hl)			;4dae   ; 0: acaba
	or a			;4daf
	ret z			;4db0
	push hl			;4db1
	ex de,hl			;4db2
	rlca			;4db3   ; la fila...
	rlca			;4db4
	and 003h		;4db5
	ld hl,001c0h		;4db7   ; ...x 0x1C0
	push de			;4dba
	call multiplica		;4dbb   ; HL = DE x A
	pop de			;4dbe
	ld bc,0e21ah		;4dbf   ; + 0xE21A
	add hl,bc			;4dc2
	ld a,(de)			;4dc3   ; la columna
	inc de			;4dc4
	and 03fh		;4dc5
	add a,l			;4dc7   ; + la columna
	ld l,a			;4dc8
	jr nc,cosas8_casillas		;4dc9
	inc h			;4dcb
cosas8_casillas:
	ld b,008h		;4dcc   ; 8 casillas
	ld de,04de1h		;4dce
	call copia_b		;4dd1   ; copiadas
	ld bc,00038h		;4dd4   ; la fila de abajo (+0x38)
	add hl,bc			;4dd7
	ld b,008h		;4dd8   ; otras 8
	call copia_b		;4dda
	pop hl			;4ddd
	inc hl			;4dde   ; la siguiente
	jr cosas8_pon		;4ddf

; ----------------------------------------------------------------------
; DATOS cosas8_dibujo: Las 16 casillas de 0x4DAE (dos filas de 8)
;   0x4de1..0x4df1  (16 bytes)
DATA_cosas8_dibujo:
	defb 03ch,03bh,020h,020h,020h,020h,022h,023h,024h,03dh,020h,020h,020h,020h,025h,024h	; 4de1  <;    "#$=    %$

; ======================================================================
; CODIGO 0x4df1..0x4e1b  (42 bytes)
; ======================================================================


cosas6_pon:		; Lo mismo con 6 casillas de 0x4E1B desde 0xE21A
	ld a,(hl)			;4df1   ; 0: acaba
	or a			;4df2
	ret z			;4df3
	push hl			;4df4
	ex de,hl			;4df5
	rlca			;4df6   ; la fila...
	rlca			;4df7
	and 003h		;4df8
	ld hl,001c0h		;4dfa   ; ...x 0x1C0
	push de			;4dfd
	call multiplica		;4dfe
	pop de			;4e01
	ld bc,0e21ah		;4e02   ; + 0xE21A
	add hl,bc			;4e05
	ld a,(de)			;4e06   ; la columna
	inc de			;4e07
	and 03fh		;4e08
	add a,l			;4e0a   ; + la columna
	ld l,a			;4e0b
	jr nc,cosas6_casillas		;4e0c
	inc h			;4e0e
cosas6_casillas:
	ld b,006h		;4e0f   ; 6 casillas
	ld de,04e1bh		;4e11
	call copia_b		;4e14   ; copiadas
	pop hl			;4e17
	inc hl			;4e18   ; la siguiente
	jr cosas6_pon		;4e19

; ----------------------------------------------------------------------
; DATOS cosas6_dibujo: Las 6 casillas de 0x4DF1
;   0x4e1b..0x4e21  (6 bytes)
DATA_cosas6_dibujo:
	defb 027h,028h,029h,028h,029h,03eh	; 4e1b

; ======================================================================
; CODIGO 0x4e21..0x4e4c  (43 bytes)
; ======================================================================


cosas7_pon:		; Lo mismo con 7 casillas de 0x4E4C desde 0xE21A
	ld a,(hl)			;4e21   ; 0: acaba
	or a			;4e22
	ret z			;4e23
	push hl			;4e24
	ex de,hl			;4e25
	ld a,(de)			;4e26   ; la fila...
	rlca			;4e27
	rlca			;4e28
	and 003h		;4e29
	ld hl,001c0h		;4e2b   ; ...x 0x1C0
	push de			;4e2e
	call multiplica		;4e2f   ; HL = DE x A
	pop de			;4e32
	ld bc,0e21ah		;4e33   ; + 0xE21A
	add hl,bc			;4e36
	ld a,(de)			;4e37   ; la columna
	inc de			;4e38
	and 03fh		;4e39
	add a,l			;4e3b   ; + la columna
	ld l,a			;4e3c
	jr nc,cosas7_casillas		;4e3d
	inc h			;4e3f
cosas7_casillas:
	ld b,007h		;4e40   ; 7 casillas
	ld de,04e4ch		;4e42
	call copia_b		;4e45   ; copiadas
	pop hl			;4e48
	inc hl			;4e49   ; la siguiente
	jr cosas7_pon		;4e4a

; ----------------------------------------------------------------------
; DATOS cosas7_dibujo: Las 7 casillas de 0x4E21 y un byte mas
;   0x4e4c..0x4e54  (8 bytes)
DATA_cosas7_dibujo:
	defb 027h,028h,029h,028h,028h,029h,03eh,0c9h	; 4e4c  '()(()>.

; ======================================================================
; CODIGO 0x4e54..0x4f78  (292 bytes)
; ======================================================================


copia_b:		; B bytes de DE a HL
	ld a,(de)			;4e54   ; un byte
	ld (hl),a			;4e55
	inc de			;4e56
	inc hl			;4e57
	djnz copia_b		;4e58   ; uno menos
	ret			;4e5a
tarea_4e5b:		; Cada cuadro (sin 0xE010): una cosa que va y viene (0xEACC: 0 espera, 1 sube, 2 espera, 3 baja) moviendo su puntero (0xEACD) de 3 en 3 cada dos cuadros
	ld a,(0e010h)		;4e5b   ; 0xE010?
	or a			;4e5e
	ret nz			;4e5f   ; (la vista moviendose)
	ld hl,0eacbh		;4e60   ; la cuenta
	ld a,(0eacch)		;4e63   ; el paso
	or a			;4e66
	jr z,tarea_4e5b_espera		;4e67
	dec a			;4e69   ; 1?
	jr z,tarea_4e5b_paso1		;4e6a
	dec a			;4e6c   ; 2?
	jr z,tarea_4e5b_paso2		;4e6d
	dec (hl)			;4e6f   ; (subiendo)
	jr z,tarea_4e5b_fin		;4e70
	ld a,(hl)			;4e72   ; cada dos cuadros...
	rra			;4e73
	ret c			;4e74
	ld hl,(0eacdh)		;4e75   ; ...3 atras
	dec hl			;4e78
	dec hl			;4e79
	dec hl			;4e7a
	ld (0eacdh),hl		;4e7b
	ret			;4e7e
tarea_4e5b_fin:
	push hl			;4e7f
	xor a			;4e80   ; el paso 0
	ld (0eacch),a		;4e81   ; (el paso 0)
	call azar		;4e84   ; una espera al azar: 0x20-0x3F
	and 01fh		;4e87
	or 020h		;4e89
	pop hl			;4e8b
	ld (hl),a			;4e8c   ; la espera
	ret			;4e8d
tarea_4e5b_paso2:
	dec (hl)			;4e8e   ; la espera
	ret nz			;4e8f   ; aun no
	ld a,009h		;4e90   ; 0xEACF = 9
	ld (0eacfh),a		;4e92
	ld a,001h		;4e95
	ld (hl),004h		;4e97   ; 4 cuadros y el paso 1
	ld (0eacch),a		;4e99
	ret			;4e9c
tarea_4e5b_paso1:
	dec (hl)			;4e9d   ; la cuenta
	jr z,tarea_4e5b_fin1		;4e9e
	ld a,(hl)			;4ea0   ; cada dos cuadros...
	rra			;4ea1
	ret nc			;4ea2
	ld hl,(0eacdh)		;4ea3   ; ...3 adelante
	inc hl			;4ea6
	inc hl			;4ea7
	inc hl			;4ea8
	ld (0eacdh),hl		;4ea9
	ret			;4eac
tarea_4e5b_fin1:
	ld a,003h		;4ead   ; el paso 3, 6 cuadros
	ld (hl),006h		;4eaf
	ld (0eacch),a		;4eb1
	ret			;4eb4
tarea_4e5b_espera:
	dec (hl)			;4eb5   ; (el paso 0)
	ret nz			;4eb6
	ld (hl),003h		;4eb7   ; 3 cuadros y el paso 2
	ld a,002h		;4eb9
	ld (0eacch),a		;4ebb
	ld hl,(0eac3h)		;4ebe   ; la lista de 0xEAC3
	ld a,(hl)			;4ec1   ; hay alguna?
	or a			;4ec2
	ret z			;4ec3   ; no: sin sonido
	ld a,003h		;4ec4   ; el sonido 3 (0xEC10)
	ld (0ec10h),a		;4ec6
	ret			;4ec9
columnas_dibuja:		; Las columnas (0xEABF): tres filas de 0x26 en la pantalla de la RAM (0xE35A, o 0xE51A la segunda parte)
	ld hl,(0eabfh)		;4eca   ; la lista
	ld ix,0e25ah		;4ecd
	ld iy,0e35ah		;4ed1   ; la pantalla de la RAM
	ld bc,00000h		;4ed5   ; la posicion de antes
columnas_dibuja_una:
	ld a,(hl)			;4ed8   ; la posicion
	or a			;4ed9   ; 0: acaba
	ret z			;4eda
	inc hl			;4edb   ; la siguiente
	cp c			;4edc   ; menor que la anterior?
	jr nc,columnas_dibuja_pon		;4edd
	ld iy,0e51ah		;4edf   ; la otra parte
columnas_dibuja_pon:
	ld c,a			;4ee3   ; la de ahora
	push iy		;4ee4
	add iy,bc		;4ee6   ; + la posicion
	ld a,026h		;4ee8   ; 0x26 en tres filas
	ld (iy-040h),a		;4eea
	ld (iy+000h),a		;4eed
	ld (iy+040h),a		;4ef0
	pop iy		;4ef3   ; el principio de la parte
	jr columnas_dibuja_una		;4ef5
cosas33_dibuja:		; Las cosas de 0xEAC1: 0x33 arriba y 0x34 en tres filas debajo, en la pantalla de la RAM (0xE19A + fila x 0x1C0, siete filas de 64)
	ld hl,(0eac1h)		;4ef7   ; la lista
cosas33_una:
	ld a,(hl)			;4efa
	or a			;4efb   ; 0: acaba
	ret z			;4efc
	push hl			;4efd
	ex de,hl			;4efe   ; la fila (bits 6-7)...
	rlca			;4eff
	rlca			;4f00
	and 003h		;4f01
	ld l,a			;4f03   ; ...x 7...
	add a,a			;4f04   ; x 2
	ld h,a			;4f05
	add a,a			;4f06   ; x 4, + x 2...
	add a,h			;4f07
	add a,l			;4f08   ; ...+ x 1: x 7
	ld l,a			;4f09
	ld h,000h		;4f0a   ; ...x 64
	add hl,hl			;4f0c
	add hl,hl			;4f0d
	add hl,hl			;4f0e
	add hl,hl			;4f0f
	add hl,hl			;4f10
	add hl,hl			;4f11
	ld bc,0e19ah		;4f12   ; + 0xE19A
	add hl,bc			;4f15
	ld a,(de)			;4f16   ; la columna
	inc de			;4f17   ; la siguiente
	and 03fh		;4f18
	add a,l			;4f1a   ; + la columna
	ld l,a			;4f1b
	jr nc,cosas33_pon		;4f1c
	inc h			;4f1e
cosas33_pon:
	push hl			;4f1f
	pop ix		;4f20   ; IX: su sitio
	ld (ix-080h),033h		;4f22   ; 0x33
	ld a,034h		;4f26   ; y 0x34 tres veces
	ld (ix-040h),a		;4f28
	ld (ix+000h),a		;4f2b
	ld (ix+040h),a		;4f2e
	pop hl			;4f31
	inc hl			;4f32   ; la siguiente
	jr cosas33_una		;4f33
cosas_moviles:		; Las cosas de 0xEAC3 que van y vienen: 3 x 3 casillas desde el puntero 0xEACD, en la pantalla de la RAM (0xE15C + fila x 0x1C0 + columna)
	ld hl,(0eac3h)		;4f35   ; la lista
cosas_moviles_una:
	ld a,(hl)			;4f38
	or a			;4f39   ; 0: acaba
	ret z			;4f3a
	push hl			;4f3b
	ex de,hl			;4f3c
	rlca			;4f3d   ; la fila...
	rlca			;4f3e
	and 003h		;4f3f
	ld l,a			;4f41   ; ...x 7 x 64 = x 0x1C0
	add a,a			;4f42
	ld h,a			;4f43
	add a,a			;4f44
	add a,h			;4f45
	add a,l			;4f46   ; + la fila: x 7
	ld l,a			;4f47
	ld h,000h		;4f48
	add hl,hl			;4f4a
	add hl,hl			;4f4b
	add hl,hl			;4f4c
	add hl,hl			;4f4d
	add hl,hl			;4f4e
	add hl,hl			;4f4f
	ld bc,0e15ch		;4f50   ; + 0xE15C
	add hl,bc			;4f53
	ld a,(de)			;4f54   ; la columna
	inc de			;4f55
	and 03fh		;4f56
	ld c,a			;4f58
	ld b,000h		;4f59
	add hl,bc			;4f5b   ; + la columna
	ex de,hl			;4f5c   ; DE: su sitio
	ld hl,(0eacdh)		;4f5d   ; sus casillas
	call tres_por_tres		;4f60   ; 3 x 3
	pop hl			;4f63
	inc hl			;4f64   ; la siguiente
	jr cosas_moviles_una		;4f65
tres_por_tres:		; 3 filas de 3 casillas de HL a DE (filas de 64)
	ld a,003h		;4f67   ; tres filas
tres_por_tres_fila:
	ld bc,00003h		;4f69   ; tres casillas
	ldir		;4f6c   ; copiadas
	ex de,hl			;4f6e
	ld bc,0003dh		;4f6f   ; la fila siguiente: 64 - 3
	add hl,bc			;4f72
	ex de,hl			;4f73
	dec a			;4f74   ; una fila menos
	jr nz,tres_por_tres_fila		;4f75
	ret			;4f77

; ----------------------------------------------------------------------
; DATOS tres_casillas: Las casillas de la cosa de tres por tres, de tres en
;   tres (0xEACD avanza o retrocede 3): 0x20 (nada) y 0x2A-0x32
;   0x4f78..0x4f87  (15 bytes)
DATA_tres_casillas:
	defb 020h,020h,020h,020h,020h,020h,02ah,02dh,030h,02bh,02eh,031h,02ch,02fh,032h	; 4f78        *-0+.1,/2

; ======================================================================
; CODIGO 0x4f87..0x4fca  (67 bytes)
; ======================================================================


cosas_moviles_dibujo:		; Las cosas de 0xEAC3, dibujadas segun su paso (0xEACF): cada paso escribe la casilla 0x3F (o 0) en unos sitios alrededor de IX (la tabla 0x4FCA), y vuelve por DE a 0x4FC6
	ld hl,(0eac3h)		;4f87   ; la lista
cosas_moviles_dibujo_una:
	ld a,(hl)			;4f8a
	or a			;4f8b   ; 0: acaba
	ret z			;4f8c
	push hl			;4f8d
	ex de,hl			;4f8e   ; la fila (bits 6-7)...
	rlca			;4f8f
	rlca			;4f90
	and 003h		;4f91
	ld l,a			;4f93   ; ...x 7 x 64 = x 0x1C0
	add a,a			;4f94
	ld h,a			;4f95
	add a,a			;4f96
	add a,h			;4f97
	add a,l			;4f98
	ld l,a			;4f99
	ld h,000h		;4f9a
	add hl,hl			;4f9c   ; x 64
	add hl,hl			;4f9d
	add hl,hl			;4f9e
	add hl,hl			;4f9f
	add hl,hl			;4fa0
	add hl,hl			;4fa1
	ld bc,0e165h		;4fa2   ; + 0xE165
	add hl,bc			;4fa5
	ld a,(de)			;4fa6   ; la columna
	and 03fh		;4fa7
	add a,l			;4fa9   ; + la columna
	ld l,a			;4faa
	jr nc,cosas_moviles_dibujo_pon		;4fab
	inc h			;4fad
cosas_moviles_dibujo_pon:
	push hl			;4fae
	pop ix		;4faf   ; IX: su sitio
	ld a,(0eacfh)		;4fb1   ; el paso, en la tabla 0x4FCA
	add a,a			;4fb4   ; x 2
	ld e,a			;4fb5
	ld d,000h		;4fb6
	ld hl,04fcah		;4fb8
	add hl,de			;4fbb
	ld a,(hl)			;4fbc   ; la rutina del paso
	inc hl			;4fbd
	ld h,(hl)			;4fbe
	ld l,a			;4fbf
	ld de,cosas_moviles_dibujo_sig		;4fc0   ; vuelve a 0x4FC6
	ld a,03fh		;4fc3   ; la casilla 0x3F
	jp (hl)			;4fc5   ; a ella
cosas_moviles_dibujo_sig:
	pop hl			;4fc6   ; la siguiente
	inc hl			;4fc7
	jr cosas_moviles_dibujo_una		;4fc8

; ----------------------------------------------------------------------
; DATOS tabla_pasos: Los nueve pasos del dibujo de 0x4F87 (0xEACF)
;   0x4fca..0x4fdc  (18 bytes)
DATA_tabla_pasos:
	defw 0503ch,05034h,0502ch,0501eh,05010h,04ffbh,04fech,04fe4h,04fdch	; 4fca

; ======================================================================
; CODIGO 0x4fdc..0x508c  (176 bytes)
; ======================================================================


paso8:		; Dos casillas (IX-6, IX-11) y de vuelta por DE
	ld (ix-006h),a		;4fdc   ; la casilla 0x3F (o 0)
	ld (ix-00bh),a		;4fdf
	ex de,hl			;4fe2   ; de vuelta
	jp (hl)			;4fe3
paso7:		; Dos casillas una fila arriba (IX-0x46, IX-0x4B)
	ld (ix-046h),a		;4fe4
	ld (ix-04bh),a		;4fe7
	ex de,hl			;4fea   ; de vuelta
	jp (hl)			;4feb
paso6:		; Dos casillas mas y las del paso 7 a 0
	ld (ix-045h),a		;4fec
	ld (ix-04ch),a		;4fef
	xor a			;4ff2   ; las del paso 7 a 0
	ld (ix-046h),a		;4ff3
	ld (ix-04bh),a		;4ff6
	ex de,hl			;4ff9   ; de vuelta
	jp (hl)			;4ffa
paso5:		; Cuatro casillas, y las del paso 6 a 0
	ld (ix-003h),a		;4ffb
	ld (ix-00dh),a		;4ffe
	ld (ix+077h),a		;5001   ; dos filas abajo
	ld (ix+07bh),a		;5004
	xor a			;5007   ; las del paso 6 a 0
	ld (ix-045h),a		;5008
	ld (ix-04ch),a		;500b
	ex de,hl			;500e   ; de vuelta
	jp (hl)			;500f
paso4:		; Cuatro casillas una fila abajo
	ld (ix+033h),a		;5010   ; una fila abajo
	ld (ix+03dh),a		;5013
	ld (ix+035h),a		;5016
	ld (ix+03bh),a		;5019
	ex de,hl			;501c   ; de vuelta
	jp (hl)			;501d
paso3:		; Cuatro casillas dos filas abajo
	ld (ix+073h),a		;501e   ; dos filas abajo
	ld (ix+07dh),a		;5021
	ld (ix+034h),a		;5024
	ld (ix+03ch),a		;5027
	ex de,hl			;502a   ; de vuelta
	jp (hl)			;502b
paso2:		; Dos casillas
	ld (ix+033h),a		;502c
	ld (ix+03dh),a		;502f
	ex de,hl			;5032   ; de vuelta
	jp (hl)			;5033
paso1:		; Dos casillas mas afuera
	ld (ix+032h),a		;5034   ; mas afuera
	ld (ix+03eh),a		;5037
	ex de,hl			;503a   ; de vuelta
	jp (hl)			;503b
paso0:		; Dos casillas tres filas abajo
	ld (ix+071h),a		;503c   ; tres filas abajo
	ld (ix+07fh),a		;503f
	ex de,hl			;5042   ; de vuelta
	jp (hl)			;5043
marca_isla:		; Con 0xE001 bit 1: una casilla de la lista de 0xEAC7 (fila en los bits 6-7, columna en 0-5) en la pantalla de la RAM: 0x38; en la isla 7, 3 x 3 casillas que cambian cada 16 cuadros (0x508C/0x5095)
	ld a,(0e001h)		;5044   ; 0xE001 bit 1?
	and 002h		;5047
	ret z			;5049
	ld hl,(0eac7h)		;504a   ; la lista
	ld a,(hl)			;504d   ; la fila y la columna
	ld b,a			;504e   ; la fila...
	and 0c0h		;504f
	ld hl,0e15ah		;5051   ; la de arriba: 0xE15A
	jr z,marca_isla_columna		;5054
	ld hl,0e31ah		;5056   ; la de en medio: 0xE31A
	cp 040h		;5059
	jr z,marca_isla_columna		;505b   ; (0x40: la de en medio)
	ld hl,0e4dah		;505d   ; la de abajo: 0xE4DA
marca_isla_columna:
	ld a,b			;5060
	and 03fh		;5061   ; + la columna
	add a,l			;5063
	ld l,a			;5064   ; en HL
	jr nc,marca_isla_va		;5065
	inc h			;5067
marca_isla_va:
	ld a,(0e002h)		;5068   ; la isla 7?
	cp 007h		;506b
	jr z,marca_isla7		;506d
	ld a,(0e001h)		;506f   ; 0xE001 bit 5?
	and 020h		;5072
	ret nz			;5074
	ld (hl),038h		;5075   ; en la pantalla de la RAM
	ret			;5077
marca_isla7:
	ex de,hl			;5078   ; DE: el sitio
	ld hl,0ead0h		;5079
	ld a,(hl)			;507c   ; cada 16 cuadros...
	inc (hl)			;507d
	and 010h		;507e
	ld hl,0508ch		;5080   ; ...uno...
	jr z,marca_isla7_pon		;5083
	ld hl,05095h		;5085   ; ...u otro
marca_isla7_pon:
	dec de			;5088   ; una columna a la izquierda
	jp tres_por_tres		;5089   ; 3 x 3 casillas

; ----------------------------------------------------------------------
; DATOS marca_isla7_dibujos: Los dos dibujos de 3 x 3 casillas de la isla 7
;   0x508c..0x509e  (18 bytes)
DATA_marca_isla7_dibujos:
	defb 080h,081h,082h,083h,084h,085h,086h,087h,088h,080h,08ah,08bh,083h,08dh,08eh,086h	; 508c  ................
	defb 090h,091h	; 509c

; ----------------------------------------------------------------------
; DATOS isla_casillas: Los dibujos y colores de las casillas de las islas,
;   empaquetados (0x509E: 59 bloques, 0x51FF: 1, 0x5208: 34) y las ordenes de
;   los colores (0x52D6)
;   0x509e..0x532d  (655 bytes)
DATA_isla_casillas:
	defb 080h,000h,0b6h,000h,020h,000h,020h,000h,0ffh,070h,088h,080h,070h,008h,088h,070h	; 509e  .... . ..p..p..p
	defb 000h,0e7h,030h,048h,080h,048h,030h,000h,099h,088h,0f8h,088h,000h,0c3h,070h,020h	; 50ae  ..0H.H0.......p 
	defb 070h,000h,0dfh,0f0h,088h,0f0h,0a0h,090h,088h,000h,0e7h,0e0h,050h,048h,050h,0e0h	; 50be  p...........PHP.
	defb 000h,0d9h,0f0h,088h,0f0h,080h,000h,0c3h,070h,088h,070h,000h,097h,088h,0a8h,0d8h	; 50ce  ........p.p.....
	defb 088h,000h,080h,000h,080h,000h,080h,000h,080h,000h,080h,000h,0ffh,070h,088h,098h	; 50de  .............p..
	defb 0a8h,0c8h,088h,070h,000h,0f3h,020h,060h,0a0h,020h,0f8h,000h,0ffh,070h,088h,008h	; 50ee  ...p.. `. ...p..
	defb 010h,060h,080h,0f8h,000h,0ffh,070h,088h,008h,030h,008h,088h,070h,000h,0fdh,010h	; 50fe  .`....p..0..p...
	defb 030h,050h,090h,0f8h,010h,000h,0ffh,0f8h,080h,0e0h,010h,008h,010h,0e0h,000h,0fbh	; 510e  0P..............
	defb 030h,040h,080h,0f0h,088h,070h,000h,0f1h,0f8h,088h,010h,020h,000h,0dbh,070h,088h	; 511e  0@...p..... ..p.
	defb 070h,088h,070h,000h,0dfh,070h,088h,078h,008h,010h,060h,000h,0efh,03ch,07eh,0efh	; 512e  p.p..p.x..`..<~.
	defb 0c7h,05ah,07eh,03ch,0ffh,078h,0ech,0e6h,0fdh,0fch,060h,07fh,03fh,0a2h,000h,0ffh	; 513e  .Z~<.x....`.?...
	defb 000h,0a2h,000h,0f0h,000h,080h,000h,080h,000h,080h,000h,080h,0ffh,083h,000h,001h	; 514e  ................
	defb 003h,0f4h,007h,01fh,03fh,07fh,0ffh,0f7h,092h,055h,0c6h,0ffh,0c6h,055h,092h,0efh	; 515e  ....?....U...U..
	defb 007h,01fh,03fh,07fh,056h,0dbh,0a5h,0cch,0ffh,0c3h,0ffh,0c3h,0bfh,000h,007h,01fh	; 516e  ..?.V...........
	defb 03fh,00fh,001h,000h,0c1h,01fh,0ffh,03fh,0c0h,0e3h,0ffh,0ffh,006h,011h,000h,010h	; 517e  ?......?........
	defb 02eh,043h,001h,080h,0ffh,000h,001h,031h,04dh,087h,003h,01fh,037h,0ffh,023h,001h	; 518e  .C.....1M...7.#.
	defb 043h,003h,006h,086h,00dh,01bh,0ffh,000h,003h,046h,02ch,078h,0fch,0feh,0fbh,0feh	; 519e  C........F,x....
	defb 073h,072h,034h,0b5h,0b7h,0b6h,0bfh,0ffh,0b6h,0f4h,076h,07ah,0dbh,0ddh,0b7h,078h	; 51ae  sr4.......vz...x
	defb 0ffh,000h,080h,040h,000h,010h,078h,0cch,000h,0ffh,001h,060h,090h,008h,000h,0c2h	; 51be  ...@..x....`....
	defb 060h,020h,0ffh,020h,000h,011h,000h,088h,080h,0c0h,060h,0f8h,03dh,07bh,0f7h,007h	; 51ce  ` . ......`.={..
	defb 0f7h,080h,0f7h,087h,0f7h,0f6h,0f4h,0f0h,080h,010h,089h,0ffh,066h,022h,0ffh,00eh	; 51de  ............f"..
	defb 011h,015h,009h,016h,020h,050h,0a0h,0f8h,071h,0ffh,077h,007h,077h,083h,077h,076h	; 51ee  .... P..q.w.w.wv
	defb 070h,0ffh,008h,051h,07ah,0b6h,0d7h,0fbh,046h,03ch,08fh,0ffh,000h,0ffh,000h,0ffh	; 51fe  p..Qz...F<......
	defb 086h,0ffh,000h,0ffh,0e6h,0ffh,000h,0ffh,000h,0ffh,080h,0ffh,0e0h,0ffh,000h,0ffh	; 520e  ................
	defb 080h,0ffh,0c0h,0ffh,000h,0bfh,0ffh,01fh,000h,0f0h,001h,000h,01ch,09fh,0ffh,01fh	; 521e  ................
	defb 07fh,0ffh,00fh,07fh,0f0h,003h,000h,0feh,000h,0fch,0ffh,01fh,07fh,007h,0c1h,000h	; 522e  ................
	defb 0c0h,000h,0ffh,0ffh,000h,0e0h,0f8h,0ffh,0fch,0c0h,0f0h,0ffh,0f8h,000h,0fch,0f0h	; 523e  ................
	defb 0f8h,0ffh,08fh,000h,0e0h,080h,0f8h,0feh,098h,0ffh,000h,0ffh,080h,0ffh,087h,0ffh	; 524e  ................
	defb 0f8h,0e0h,000h,088h,0ffh,000h,0f0h,0ffh,0f0h,0c0h,000h,0ffh,07fh,03fh,07fh,00fh	; 525e  .............?..
	defb 03fh,007h,00fh,001h,08fh,0ffh,0feh,0f8h,0f0h,080h,0ffh,07fh,03fh,07fh,00fh,03fh	; 526e  ?...........?..?
	defb 007h,00fh,001h,0fdh,0feh,07eh,07ch,05ch,01ch,018h,008h,0ffh,0ffh,0feh,0f8h,0e0h	; 527e  .....~|\........
	defb 0fch,080h,0e0h,080h,0ffh,0ffh,0efh,0e7h,0a7h,0a3h,083h,003h,001h,080h,0ffh,0bfh	; 528e  ................
	defb 000h,001h,003h,001h,007h,003h,01fh,0ffh,007h,07fh,00fh,03fh,003h,0ffh,01fh,03fh	; 529e  ...........?...?
	defb 0fch,011h,055h,05dh,0ddh,0fdh,0ffh,0feh,007h,07fh,00fh,001h,007h,001h,000h,0ffh	; 52ae  ..U]............
	defb 0f8h,0c1h,0f3h,08fh,0e7h,083h,00fh,03fh,09fh,0ffh,0efh,0aeh,0aah,08ah,008h,0ffh	; 52be  .......?........
	defb 087h,0e1h,0c3h,0f0h,007h,0e1h,083h,0c0h,0f0h,0d0h,0f0h,002h,0fdh,001h,0fah,002h	; 52ce  ................
	defb 0a0h,003h,0a0h,004h,040h,001h,0a4h,003h,060h,008h,0f0h,018h,020h,020h,0c2h,004h	; 52de  ....@...`...  ..
	defb 0c0h,00ch,0a0h,008h,062h,018h,060h,048h,050h,015h,052h,003h,0e0h,008h,070h,004h	; 52ee  ....b.`HP.R...p.
	defb 0e0h,004h,0a0h,008h,0f0h,002h,0f4h,00dh,040h,001h,020h,010h,0c0h,008h,062h,008h	; 52fe  ........@. ...b.
	defb 060h,008h,07fh,028h,0fbh,030h,05bh,028h,045h,020h,059h,010h,079h,008h,090h,020h	; 530e  `..(.0[(E Y.y.. 
	defb 020h,038h,0fbh,020h,05bh,018h,059h,010h,079h,008h,090h,008h,020h,020h,000h	; 531e   8. [.Y.y...  .

; ======================================================================
; CODIGO 0x532d..0x5348  (27 bytes)
; ======================================================================


sprites_casillas_pon:		; Las casillas de los sprites grandes: 18 bloques empaquetados (0x5348) desde la casilla 0x80 y sus colores (0x53C6); los sprites fuera
	xor a			;532d   ; 0xEAD0 = 0
	ld (0ead0h),a		;532e
	ld hl,05348h		;5331   ; 18 bloques...
	ld de,00400h		;5334   ; ...desde la casilla 0x80
	ld b,012h		;5337
	call desempaqueta_tercios		;5339
	ld hl,053c6h		;533c   ; sus colores
	ld de,02400h		;533f
	call ordenes_tercios		;5342
	jp sprites_fuera		;5345

; ----------------------------------------------------------------------
; DATOS islas_datos: Las casillas de 0x532D y sus colores (0x5348, 0x53C6);
;   los huecos de cada isla (0x5411, 4 bytes); las listas de cosas de cada
;   isla (0x542D, 0x5452, 0x545E, 0x546A, 0x547C, 0x5488, 0x548F); las filas
;   del suelo (0x5496, 0x54F7) y las piezas de 0x55F7 y 0x560F
;   0x5348..0x5624  (732 bytes)
DATA_islas_datos:
	defb 09bh,000h,001h,003h,007h,00fh,0ddh,03ch,07eh,0bdh,0dbh,07eh,05ah,09ah,000h,080h	; 5348  .......<~..~Z...
	defb 0c0h,0e0h,09fh,03fh,01eh,07fh,03fh,00fh,003h,0cch,07eh,03ch,01ch,03eh,0f9h,0e0h	; 5358  ...?..?...~<.>..
	defb 0c0h,0f0h,0f8h,0fch,038h,0bfh,001h,003h,00fh,01fh,07fh,0fch,0f0h,0bfh,0c1h,0c3h	; 5368  ....8...........
	defb 08dh,0b0h,0c2h,004h,038h,0a3h,080h,0c0h,0f0h,0fch,0d9h,000h,00ch,00fh,01fh,00fh	; 5378  ....8...........
	defb 0ddh,03ch,07eh,0bdh,0dbh,07eh,05ah,0d9h,000h,030h,0f0h,0f8h,0f0h,0ffh,003h,007h	; 5388  .<~..~Z..0......
	defb 00fh,01fh,03fh,00fh,003h,000h,0fch,07eh,03ch,07eh,07ch,038h,07ch,0ffh,0e0h,0c0h	; 5398  ..?....~<~|8|...
	defb 0e0h,0f0h,0f8h,0e0h,080h,000h,0ffh,001h,003h,007h,00fh,01fh,07fh,0fch,0f0h,0ffh	; 53a8  ................
	defb 07eh,07ch,072h,0ceh,03dh,0fbh,0e7h,09fh,0e5h,080h,0c0h,0e0h,0f0h,0fch,0f0h,00ah	; 53b8  ~|r.=...........
	defb 0f6h,003h,0f0h,001h,0a0h,002h,0f0h,008h,09ah,002h,09fh,002h,0f0h,004h,0a0h,002h	; 53c8  ................
	defb 090h,002h,09fh,002h,09ah,002h,0f0h,001h,090h,004h,09ah,002h,090h,001h,0b0h,006h	; 53d8  ................
	defb 0b9h,00ah,0b0h,005h,090h,003h,0a0h,003h,090h,005h,0f0h,002h,0f6h,003h,0f0h,001h	; 53e8  ................
	defb 0a0h,005h,090h,006h,0f0h,007h,0a9h,002h,090h,002h,09fh,003h,09bh,001h,090h,001h	; 53f8  ................
	defb 0f0h,007h,0b0h,006h,0b9h,00ah,0b0h,008h,000h,026h,016h,010h,014h,024h,016h,010h	; 5408  .........&...$..
	defb 01ch,026h,014h,010h,016h,024h,010h,014h,01eh,018h,016h,026h,014h,020h,018h,014h	; 5418  .&...$.....&. ..
	defb 018h,01eh,00ch,01ah,01ch,029h,038h,013h,020h,000h,026h,036h,013h,020h,028h,000h	; 5428  .....)8. .&6. (.
	defb 027h,036h,013h,020h,000h,027h,030h,017h,022h,02eh,000h,01ah,02bh,029h,036h,000h	; 5438  '6. .'0."...+)6.
	defb 023h,034h,017h,028h,000h,020h,01dh,02bh,032h,000h,000h,000h,02ch,000h,02ah,06bh	; 5448  #4.(. .+2...,.*k
	defb 000h,000h,052h,000h,076h,000h,056h,000h,056h,000h,06ch,000h,04ch,000h,050h,000h	; 5458  ..R.v.V.V.l.L.P.
	defb 000h,000h,070h,000h,02ah,06ch,000h,056h,000h,05ah,0a6h,000h,020h,06eh,000h,05ah	; 5468  ..p.*l.V.Z.. n.Z
	defb 06ch,000h,063h,000h,000h,000h,000h,000h,05eh,000h,027h,09bh,000h,054h,0a1h,000h	; 5478  l.c.....^.'..T..
	defb 063h,063h,0a5h,07ah,07ah,032h,026h,000h,000h,000h,000h,000h,000h,000h,000h,004h	; 5488  cc.zz2&.........
	defb 003h,003h,004h,000h,018h,004h,003h,004h,003h,004h,004h,004h,000h,002h,003h,004h	; 5498  ................
	defb 003h,004h,000h,020h,004h,003h,004h,003h,004h,000h,002h,004h,003h,003h,004h,000h	; 54a8  ... ............
	defb 01ah,003h,004h,004h,003h,003h,004h,004h,000h,002h,004h,003h,004h,004h,003h,000h	; 54b8  ................
	defb 022h,004h,004h,004h,000h,00eh,004h,004h,003h,004h,003h,004h,004h,004h,003h,003h	; 54c8  "...............
	defb 000h,018h,004h,000h,006h,003h,004h,004h,003h,004h,000h,01ch,004h,003h,003h,004h	; 54d8  ................
	defb 004h,000h,008h,003h,004h,003h,004h,003h,004h,003h,000h,020h,004h,004h,000h,06bh	; 54e8  ........... ...k
	defb 059h,05ah,056h,043h,041h,043h,041h,042h,042h,044h,044h,043h,041h,041h,041h,041h	; 54f8  YZVCACABBDDCAAAA
	defb 041h,043h,044h,042h,042h,044h,044h,06bh,05ah,05ah,05ah,058h,000h,000h,000h,058h	; 5508  ACDBBDDkZZZX...X
	defb 000h,057h,06ch,05ah,056h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h	; 5518  .WlZV@@@@@@@@@@@
	defb 040h,040h,040h,040h,040h,040h,040h,05ah,05ah,059h,058h,000h,000h,000h,000h,050h	; 5528  @@@@@@@ZZYX....P
	defb 050h,051h,052h,053h,04bh,04fh,04bh,04bh,04ch,046h,046h,047h,048h,045h,045h,063h	; 5538  PQRSKOKKLFFGHEEc
	defb 062h,046h,046h,066h,04bh,04fh,069h,05ah,05ah,05bh,05dh,05dh,06dh,000h,000h,04bh	; 5548  bFFfKOiZZ[]]m..K
	defb 04fh,04fh,04bh,04fh,04bh,04bh,04fh,04fh,04bh,04fh,04ch,046h,049h,04ah,065h,064h	; 5558  OOKOKKOOKOLFIJed
	defb 046h,066h,04fh,04fh,04bh,055h,05ah,059h,058h,05ch,070h,05fh,06eh,000h,000h,04fh	; 5568  FfOOKUZYX\p_n..O
	defb 04fh,055h,06ah,04bh,04fh,04bh,069h,054h,04bh,04fh,04bh,04fh,04dh,04eh,068h,067h	; 5578  OUjKOKiTKOKOMNhg
	defb 04bh,04fh,04bh,069h,05ah,05ah,058h,000h,000h,05ch,070h,061h,06eh,000h,000h,054h	; 5588  KOKiZZX..\pan..T
	defb 069h,05ah,059h,054h,04fh,055h,05ah,05ah,059h,054h,04bh,04fh,04bh,04fh,04bh,055h	; 5598  iZYTOUZZYTKOKOKU
	defb 06ah,04fh,04fh,05ah,058h,057h,000h,000h,000h,05eh,060h,05bh,05dh,06dh,000h,05ah	; 55a8  jOOZXW...^`[]m.Z
	defb 059h,058h,000h,05ah,05ah,05ah,059h,058h,000h,059h,055h,06ah,04bh,069h,059h,05ah	; 55b8  YX.ZZZYX.YUjKiYZ
	defb 05ah,054h,069h,05ah,000h,000h,000h,000h,05bh,05dh,06dh,05ch,060h,06eh,000h,057h	; 55c8  ZTiZ....[]m\`n.W
	defb 000h,000h,000h,057h,06ch,059h,000h,000h,000h,000h,057h,06ch,059h,058h,000h,057h	; 55d8  ...WlY....WlYX.W
	defb 06ch,05ah,059h,058h,000h,000h,000h,000h,05eh,070h,06eh,05eh,061h,06fh,000h,05bh	; 55e8  lZYX....^pn^ao.[
	defb 05dh,05dh,06dh,05ch,05fh,05fh,06fh,05ch,070h,06eh,000h,05eh,060h,05fh,06dh,000h	; 55f8  ]]m\__o\pn.^`_m.
	defb 05ch,061h,06eh,000h,05eh,060h,06fh,000h,000h,000h,05bh,06dh,000h,05ch,06eh,000h	; 5608  \an.^`o...[m.\n.
	defb 05eh,05fh,06dh,000h,05eh,06fh,000h,000h,000h,0cdh,05bh,044h	; 5618  ^_m.^o....[D

; ======================================================================
; CODIGO 0x5624..0x5680  (92 bytes)
; ======================================================================


estado_borde_izq:		; El estado 7: el protagonista sale por la izquierda: la vista una columna a la izquierda (0xEAD1), si se puede, y el fondo otra vez
	ld a,(0ead1h)		;5624   ; la columna
	dec a			;5627   ; una menos
	jp m,estado_cero		;5628   ; ya en la 0: nada
	jr vista_pon		;562b
estado_borde_der:		; El estado 8: una columna a la derecha, hasta la 0x20
	ld a,(0ead1h)		;562d   ; la columna
	inc a			;5630   ; una mas
	cp 021h		;5631   ; pasada de 0x20: nada
	jr nc,estado_cero		;5633
	ret nc			;5635   ; (nunca: ya salto)
vista_pon:
	ld (0ead1h),a		;5636   ; la columna nueva
	call fondo_pantalla		;5639   ; el fondo a la pantalla
estado_cero:
	xor a			;563c   ; el estado 0
	ld (0eab1h),a		;563d
	dec a			;5640   ; 0xEAD2 = 0xFF: no se repinta en este cuadro
	ld (0ead2h),a		;5641
	ret			;5644
fondo_pantalla:		; El fondo de la RAM (0xE09A, 64 de ancho) desde la columna 0xEAD1 a la tabla de nombres desde la fila 2: 22 filas de 32; y el registro 2 (0x0E o 0x0F segun 0xE69A)
	ld a,(0ead1h)		;5645   ; la columna
	ld hl,0e09ah		;5648   ; + el fondo
	add a,l			;564b   ; + la columna
	ld l,a			;564c
	jr nc,L_5650		;564d
	inc h			;564f
L_5650:
	ld de,03840h		;5650   ; la fila 2 de la tabla de nombres
	ld b,016h		;5653   ; 22 filas
fondo_pantalla_fila:
	push bc			;5655   ; guardados
	push de			;5656
	push hl			;5657
	ld bc,00020h		;5658   ; 32 casillas
	call 0005ch		;565b   ; LDIRVM
	pop de			;565e   ; (cambiados: DE el fondo, HL la VRAM)
	pop hl			;565f
	ld bc,00020h		;5660   ; la fila siguiente de la pantalla
	add hl,bc			;5663
	ex de,hl			;5664   ; HL el fondo, DE la VRAM
	add hl,bc			;5665   ; y la del fondo: + 64
	add hl,bc			;5666
	pop bc			;5667   ; una fila menos
	djnz fondo_pantalla_fila		;5668
	ld a,(0e69ah)		;566a   ; 0xE69A, el bit 0...
	and 001h		;566d
	or 00eh		;566f   ; ...con 0x0E: el registro 2
	ld b,a			;5671   ; el valor
	ld c,002h		;5672   ; el registro 2 (la tabla de nombres: 0x3800 o 0x3C00)
	jp 00047h		;5674   ; WRTVDP
protagonista:		; Cada cuadro: el protagonista segun su estado (0xEAD3, la tabla 0x5680)
	ld hl,0ead3h		;5677   ; su estado
	ld de,05680h		;567a   ; la tabla
	jp estado_salta		;567d

; ----------------------------------------------------------------------
; DATOS tabla_protagonista: Los 15 estados del protagonista (0xEAD3)
;   0x5680..0x569e  (30 bytes)
DATA_tabla_protagonista:
	defw 0569eh,05a17h,05b0ah,05c6ah,05e3ch,05e26h,05f13h,056abh	; 5680
	defw 05eaah,05dcbh,05768h,05d5eh,05d2fh,056dfh,05e90h	; 5690

; ======================================================================
; CODIGO 0x569e..0x5958  (698 bytes)
; ======================================================================


protagonista_parado:		; El estado del protagonista a 0 (0xEAD3, 0xEAD6, 0xEAE7) y 0x61A0
	xor a			;569e   ; sin estado
	ld (0ead3h),a		;569f
	ld (0ead6h),a		;56a2
	ld (0eae7h),a		;56a5
	jp prota_dibujos		;56a8
pajaro_se_lleva:		; Un estado: el pajaro grande se lleva al protagonista (sus dibujos en 0x5879, la musica 3); cada 6 cuadros un paso (0xEAD8) hasta 40; despues el estado 14 y los sprites fuera
	ld hl,0ead5h		;56ab   ; el paso
	ld a,(hl)			;56ae   ; el primero?
	inc (hl)			;56af
	or a			;56b0
	jr nz,pajaro_se_lleva_paso		;56b1
	ld a,003h		;56b3   ; la musica 3
	ld (0ec25h),a		;56b5
	ld (0ec30h),a		;56b8
	jp pajaro_dibujos		;56bb   ; los dibujos del pajaro
pajaro_se_lleva_paso:
	cp 006h		;56be   ; cada 6 cuadros
	ret c			;56c0
	ld (hl),001h		;56c1   ; otra vez 1
	ld hl,0ead8h		;56c3   ; un paso mas
	ld a,(hl)			;56c6
	inc (hl)			;56c7
	cp 028h		;56c8   ; 40?
	jp c,pajaro_dibuja		;56ca   ; el pajaro, dibujado
	ld a,(0ec25h)		;56cd   ; la musica acabada?
	or a			;56d0
	ret nz			;56d1
	ld a,00eh		;56d2   ; el estado 14
	ld (0ead3h),a		;56d4   ; (lo deja en la isla siguiente)
	ld a,0d0h		;56d7   ; 0xD0 en el primer sprite: los demas fuera
	ld hl,03b00h		;56d9   ; el primer sprite
	jp 0004dh		;56dc   ; WRTVRM
pajaro_trae:		; El estado del principio de la isla: el pajaro trae al protagonista (la musica 1, el estado 3, 14 en 0xEAD7); vuela 13 pasos, lo deja bajar 12 filas (0xEADD) y se va; despues el protagonista de pie en la columna 8, fila 12, y el estado 2
	ld hl,0ead5h		;56df   ; el paso
	ld a,(hl)			;56e2   ; el primero?
	inc (hl)			;56e3
	or a			;56e4
	jr nz,pajaro_trae_vuela		;56e5
	inc a			;56e7   ; la musica 1
	ld (0ec25h),a		;56e8
	ld (0ec30h),a		;56eb
	ld a,003h		;56ee   ; el estado general 3
	ld (0eab1h),a		;56f0
	ld a,00eh		;56f3   ; 0xEAD7 = 14
	ld (0ead7h),a		;56f5
	jp pajaro_dibujos		;56f8   ; los dibujos del pajaro
pajaro_trae_vuela:
	cp 006h		;56fb   ; cada 6 cuadros
	jr nz,pajaro_trae_baja		;56fd
	ld (hl),001h		;56ff   ; otra vez 1
	ld hl,0ead8h		;5701   ; un paso mas
	ld a,(hl)			;5704
	inc (hl)			;5705
	cp 00dh		;5706   ; 13?
	jp c,pajaro_dibuja		;5708
	ld a,007h		;570b   ; el paso 7
	ld (0ead5h),a		;570d   ; (cada 6 cuadros, de 7 a 12)
	ld a,001h		;5710   ; 0xEAE5 y 0xEB26 = 1
	ld (0eae5h),a		;5712
	ld (0eb26h),a		;5715
	ret			;5718
pajaro_trae_baja:
	cp 00ch		;5719   ; cada 12 cuadros
	ret c			;571b
	ld (hl),007h		;571c   ; otra vez 7
	ld hl,0ead9h		;571e   ; el pajaro, una fila arriba
	dec (hl)			;5721
	ld hl,0eaddh		;5722   ; el protagonista, una abajo
	inc (hl)			;5725
	ld a,(hl)			;5726
	cp 00ch		;5727   ; 12?
	jp c,pajaro_dibuja		;5729
	call sprites_fuera		;572c   ; abajo: los sprites fuera
	call protagonista_parado		;572f   ; el estado a 0
	ld a,008h		;5732   ; columna 8...
	ld (0eadch),a		;5734
	ld a,00ch		;5737   ; ...fila 12
	ld (0eaddh),a		;5739
	xor a			;573c
	ld (0eae5h),a		;573d
	ld (0eadeh),a		;5740
	ld a,002h		;5743   ; el estado 2
	ld (0eb26h),a		;5745   ; 0xEB26 = 2
	ld (0ead3h),a		;5748   ; de pie
	ld hl,0e001h		;574b   ; 0xE001: bit 3 si, bit 5 no
	set 3,(hl)		;574e
	res 5,(hl)		;5750
	call botones_cero		;5752   ; los botones a 0
	ld a,(0e002h)		;5755   ; la isla 7...
	cp 007h		;5758
	ret nz			;575a
	ld a,(0e001h)		;575b   ; ...con el bit 1...
	and 002h		;575e
	ret z			;5760
	xor a			;5761   ; ...las casillas de los sprites grandes
	ld (0eb26h),a		;5762   ; 0xEB26 = 0
	jp sprites_casillas_pon		;5765
pajaro_final:		; El final de la isla: el pajaro viene a por el protagonista (la musica 4); en la isla 7, otra cosa (0xEAD5 = 19)
	ld hl,0ead5h		;5768   ; el paso
	ld a,(hl)			;576b   ; el primero?
	inc (hl)			;576c
	or a			;576d
	jp nz,pajaro_final_baja		;576e
	ld a,(0e002h)		;5771   ; la isla 7?
	cp 007h		;5774
	jr nz,pajaro_final_va		;5776
	ld (hl),013h		;5778   ; el paso 19
	ld a,023h		;577a   ; columna 0x23
	ld (0eadch),a		;577c
	ld a,004h		;577f   ; la musica 4
	ld (0ec25h),a		;5781
	ld (0ec30h),a		;5784
	ld a,001h		;5787   ; 0xEAE5 = 1
	ld (0eae5h),a		;5789
	ld a,0ffh		;578c   ; mirando a la izquierda
	ld (0eadeh),a		;578e
	ld (0eae7h),a		;5791
	ret			;5794   ; (el paso 19)
pajaro_final_va:
	ld a,(0eadch)		;5795   ; el pajaro sobre el protagonista
	add a,006h		;5798
	ld (0ead8h),a		;579a   ; la columna del pajaro
	ld a,0fah		;579d   ; desde arriba
	ld (0ead9h),a		;579f   ; la fila del pajaro
	ld a,004h		;57a2   ; la musica 4
	ld (0ec25h),a		;57a4
	ld (0ec30h),a		;57a7
	jp pajaro_dibujos_va		;57aa
pajaro_final_baja:
	cp 006h		;57ad   ; cada 6 cuadros
	jr nz,pajaro_final_sube		;57af
	ld (hl),001h		;57b1
	ld a,(0eaddh)		;57b3   ; hasta la fila del protagonista
	sub 006h		;57b6   ; - 6
	ld hl,0ead9h		;57b8
	cp (hl)			;57bb   ; llegado?
	jr z,pajaro_final_coge		;57bc
	inc (hl)			;57be   ; una fila mas
	jp pajaro_dibuja		;57bf
pajaro_final_coge:
	ld a,(0ead9h)		;57c2   ; lo coge: el protagonista 6 filas debajo
	add a,006h		;57c5
	ld (0eaddh),a		;57c7
	ld a,007h		;57ca   ; el paso 7
	ld (0ead5h),a		;57cc
	ret			;57cf
pajaro_final_sube:
	cp 00ch		;57d0   ; cada 12 cuadros
	jr nz,pajaro_final_lejos		;57d2
	ld (hl),007h		;57d4
	ld hl,0ead9h		;57d6   ; sube con el
	ld a,(hl)			;57d9   ; arriba del todo?
	or a			;57da
	jr z,pajaro_final_arriba		;57db
	add a,a			;57dd   ; el signo...
	ccf			;57de
	sbc a,a			;57df
	or 001h		;57e0   ; ...+1 o -1
	add a,(hl)			;57e2   ; una fila hacia 0
	ld (hl),a			;57e3
	add a,006h		;57e4   ; el protagonista 6 filas debajo
	ld (0eaddh),a		;57e6
	jp pajaro_dibuja		;57e9
pajaro_final_arriba:
	ld hl,0ead5h		;57ec   ; el paso 13
	ld (hl),00dh		;57ef
	ret			;57f1
pajaro_final_lejos:
	cp 012h		;57f2   ; el paso 18: se va de lado
	jr nz,isla_cuenta		;57f4
	ld (hl),00dh		;57f6   ; el paso 13
	ld hl,0ead8h		;57f8   ; una columna mas...
	ld a,(0ead1h)		;57fb   ; ...fuera de la vista?
	sub (hl)			;57fe
	inc (hl)			;57ff
	cp 0d9h		;5800   ; a mas de 39?
	jp nc,pajaro_dibuja		;5802
	ld a,013h		;5805   ; fuera: el paso 19
	ld (0ead5h),a		;5807
	ld a,0d0h		;580a   ; los sprites fuera
	ld hl,03b00h		;580c   ; desde el primero
	jp 0004dh		;580f
isla_cuenta:		; El paso 19: la cuenta del final: cada vez que acaba el sonido, un punto de fuerza (0xEAD7) menos y 500 puntos (0x50 y el 0 del marcador); sin fuerza, el paso 20
	cp 013h		;5812
	jr nz,isla_siguiente		;5814
	ld (hl),013h		;5816   ; el paso 19 otra vez
	ld hl,03b18h		;5818   ; el sprite de 0x3B18 fuera
	ld a,0d0h		;581b
	call 0004dh		;581d
	ld a,(0e00eh)		;5820   ; 0xE00E (cada 4 cuadros)?
	or a			;5823
	jr nz,isla_cuenta_va		;5824
	ld hl,0eae5h		;5826   ; el dibujo 1 o 2
	ld a,(hl)			;5829
	and 001h		;582a
	inc a			;582c
	ld (hl),a			;582d
isla_cuenta_va:
	ld a,(0ec25h)		;582e   ; la musica acabada?
	or a			;5831
	ret nz			;5832
	ld hl,0ead7h		;5833   ; quedan?
	ld a,(hl)			;5836
	or a			;5837
	jr z,isla_cuenta_fin		;5838
	dec (hl)			;583a   ; una menos
	ld a,050h		;583b   ; 0x50 puntos
	call puntos_suma		;583d
	call marcador		;5840   ; el marcador
	ld a,002h		;5843   ; un sonido
	ld (0ec25h),a		;5845
	ret			;5848
isla_cuenta_fin:
	ld a,014h		;5849   ; el paso 20
	ld (0ead5h),a		;584b
	ret			;584e
isla_siguiente:		; La isla siguiente (0xE002); pasada la 7, la 1 de la vuelta siguiente (0xE003, BCD) y una vida mas (hasta 7)
	cp 032h		;584f   ; 50 o mas?
	ret c			;5851
	ld hl,0e002h		;5852   ; la isla siguiente
	inc (hl)			;5855
	ld a,(hl)			;5856
	cp 008h		;5857   ; la 8?
	jr z,vuelta_siguiente		;5859
	ld a,004h		;585b   ; el estado 4: su cartel
	ld (0eab1h),a		;585d
	ret			;5860
vuelta_siguiente:
	ld (hl),001h		;5861   ; la isla 1
	ld hl,0e003h		;5863   ; la vuelta siguiente
	ld a,(hl)			;5866   ; + 1 en BCD
	add a,001h		;5867
	daa			;5869
	ld (hl),a			;586a
	ld a,006h		;586b   ; el estado 6
	ld (0eab1h),a		;586d
	ld hl,0eae3h		;5870   ; una vida mas, hasta 7
	ld a,(hl)			;5873
	cp 007h		;5874
	ret nc			;5876
	inc (hl)			;5877
	ret			;5878
pajaro_dibujos:		; Los dibujos del pajaro grande a los sprites (0x1800-0x1BFF), desempaquetados y con su espejo; la vista a la columna 0
	xor a			;5879   ; 0xEAD9, 0xEAD8, la columna a 0
	ld (0ead9h),a		;587a
	ld (0ead8h),a		;587d
	ld (0ead1h),a		;5880
	ld a,006h		;5883   ; la fila 6
	ld (0eaddh),a		;5885
pajaro_dibujos_va:
	ld hl,0e001h		;5888   ; 0xE001 sin el bit 3
	res 3,(hl)		;588b
	xor a			;588d
	ld (0eae4h),a		;588e   ; 0xEAE4 y el dibujo a 0
	ld (0eae5h),a		;5891
	call sprites_fuera		;5894   ; los sprites fuera
	ld hl,06775h		;5897   ; 44 bloques de 0x6775...
	ld de,01800h		;589a   ; ...a 0x1800
	ld b,02ch		;589d
	push bc			;589f
	call desempaqueta_vram		;58a0   ; desempaquetados y a la VRAM
	ld hl,06877h		;58a3   ; 44 de 0x6877 a 0x1960
	ld de,01960h		;58a6
	pop bc			;58a9
	call desempaqueta_vram		;58aa
	ld hl,064aah		;58ad   ; 20 de 0x64AA a 0x1AC0
	ld de,01ac0h		;58b0
	ld b,014h		;58b3
	call desempaqueta_vram		;58b5
	ld hl,0e6b1h		;58b8   ; su espejo
	ld de,0e751h		;58bb
	ld bc,000a0h		;58be
	push de			;58c1
	push bc			;58c2
	call espejo_sprites		;58c3   ; los bits al reves y las mitades cambiadas
	pop bc			;58c6
	pop hl			;58c7
	ld de,01ac0h		;58c8   ; a 0x1AC0, encima
	call 0005ch		;58cb   ; LDIRVM
	ld hl,06721h		;58ce   ; 20 de 0x6721 a 0x1B60
	ld de,01b60h		;58d1
	ld b,014h		;58d4
	call desempaqueta_vram		;58d6
	ld hl,0e6b1h		;58d9   ; su espejo
	ld de,0e751h		;58dc
	ld bc,000a0h		;58df
	push de			;58e2
	push bc			;58e3
	call espejo_sprites		;58e4   ; los bits al reves y las mitades cambiadas
	pop bc			;58e7
	pop hl			;58e8
	ld de,01b60h		;58e9   ; a 0x1B60, encima
	jp 0005ch		;58ec
pajaro_dibuja:		; El pajaro en los sprites: sus trozos (0x5958, 0x5961, 0x596A, 0x596F) donde estan (0xEAD8 menos la columna), aleteando cada 4 cuadros; en el borde izquierdo con el bit EC (X + 32)
	ld hl,03b00h		;58ef   ; los atributos de los sprites
	call 00053h		;58f2   ; SETWRT
	ld hl,0eadbh		;58f5   ; la cuenta del aleteo
	inc (hl)			;58f8
	ld a,(hl)			;58f9
	rra			;58fa   ; cada 4 cuadros...
	rra			;58fb
	sbc a,a			;58fc   ; ...los dibujos 0 o los 0x2C (las alas)
	and 02ch		;58fd
	ld h,a			;58ff
	ld l,000h		;5900   ; sin desplazar
	ld a,(0ead1h)		;5902   ; la columna de la vista
	ld e,a			;5905
	ld a,(0ead8h)		;5906   ; la del pajaro
	sub e			;5909   ; la del pajaro en la vista
	cp 008h		;590a   ; en las 8 primeras?
	jr nc,pajaro_dibuja_x		;590c
	ld l,020h		;590e   ; X + 32 y el bit EC (color 0x80): asoma por la izquierda
pajaro_dibuja_x:
	ld e,a			;5910
	add a,a			;5911   ; x 8
	add a,a			;5912
	add a,a			;5913
	sub 010h		;5914   ; - 16: la X
	ld d,a			;5916
	ld a,e			;5917
	cp 022h		;5918   ; el primer trozo, si cabe
	jr nc,pajaro_dibuja2		;591a
	ld ix,05958h		;591c   ; el de la izquierda
	call sprites_trozo		;5920
pajaro_dibuja2:
	cp 024h		;5923   ; el segundo
	jr nc,pajaro_dibuja3		;5925
	cp 002h		;5927
	jr c,pajaro_dibuja_fin		;5929
	ld ix,05961h		;592b   ; el segundo
	call sprites_trozo		;592f
pajaro_dibuja3:
	cp 026h		;5932   ; el tercero
	jr nc,pajaro_dibuja4		;5934
	cp 004h		;5936
	jr c,pajaro_dibuja_fin		;5938
	ld ix,0596ah		;593a   ; el tercero
	call sprites_trozo		;593e
	call pajaro_cuerpo		;5941   ; y el cuerpo con el protagonista
pajaro_dibuja4:
	cp 028h		;5944   ; el cuarto
	jr nc,pajaro_dibuja_fin		;5946
	cp 006h		;5948
	jr c,pajaro_dibuja_fin		;594a
	ld ix,0596fh		;594c   ; el cuarto
	call sprites_trozo		;5950
pajaro_dibuja_fin:
	ld a,0d0h		;5953   ; 0xD0: los demas sprites fuera
	out (098h),a		;5955
	ret			;5957

; ----------------------------------------------------------------------
; DATOS pajaro_trozos: Los trozos del pajaro grande: sprites (dy, dx, dibujo,
;   color) de cada parte
;   0x5958..0x599e  (70 bytes)
DATA_pajaro_trozos:
	defb 000h,000h,015h,025h,0e0h,000h,018h,00ah,000h,0f0h,009h,011h,021h,0f0h,0f8h,028h	; 5958  ...%........!..(
	defb 00ah,000h,0e0h,005h,00dh,01dh,000h,0d0h,001h,000h,000h,000h,0ffh,000h,058h,00dh	; 5968  ..............X.
	defb 007h,000h,05ch,004h,0f7h,000h,060h,00eh,0ffh,000h,064h,00ah,00fh,000h,068h,003h	; 5978  ..\...`...d...h.
	defb 000h,0ffh,000h,06ch,00dh,0ffh,000h,070h,004h,0f7h,000h,074h,00eh,0ffh,000h,078h	; 5988  ...l...p...t...x
	defb 00ah,007h,000h,07ch,003h,000h	; 5998

; ======================================================================
; CODIGO 0x599e..0x5a84  (230 bytes)
; ======================================================================


pajaro_cuerpo:		; El cuerpo del pajaro (0x5989 o, con 0xEAE5 a 0, 0x5974) a la altura del protagonista (0xEADD x 8)
	push af			;599e
	ld ix,05989h		;599f   ; con las alas de una manera
	ld a,(0eae5h)		;59a3   ; 0xEAE5?
	or a			;59a6
	jr nz,pajaro_cuerpo_va		;59a7
	ld ix,05974h		;59a9   ; o de otra
pajaro_cuerpo_va:
	ld a,(0eaddh)		;59ad   ; la fila del protagonista...
	add a,a			;59b0   ; ...x 8
	add a,a			;59b1
	add a,a			;59b2
	ld e,a			;59b3
	dec ix		;59b4   ; (sprites_lista empieza con inc ix)
	jr sprites_lista		;59b6
sprites_trozo:		; Un trozo de sprites de la tabla IX en la VRAM (los atributos, ya con SETWRT): hasta tres a la altura E y luego la lista (dy, dx, dibujo, color) hasta un 0; H el desplazamiento del dibujo y L la columna
	push af			;59b8
	ld c,(ix+000h)		;59b9   ; el ancho
	ld a,(0ead9h)		;59bc   ; la fila (0xEAD9 x 8 - 1)
	add a,a			;59bf
	add a,a			;59c0
	add a,a			;59c1
	dec a			;59c2
	ld e,a			;59c3
	ld b,003h		;59c4   ; tres
sprites_trozo_tres:
	inc ix		;59c6
	ld a,(ix+000h)		;59c8   ; el dibujo
	or a			;59cb   ; 0: no
	jr z,sprites_trozo_sig		;59cc
	ld a,e			;59ce   ; la Y
	out (098h),a		;59cf
	ex (sp),hl			;59d1   ; espera
	ex (sp),hl			;59d2
	ld a,d			;59d3   ; la X
	add a,c			;59d4
	add a,l			;59d5
	out (098h),a		;59d6
	ld a,(ix+000h)		;59d8   ; el dibujo - 1 + H
	dec a			;59db
	add a,h			;59dc
	out (098h),a		;59dd
	nop			;59df
	ld a,l			;59e0   ; el color: L x 4 | 6
	add a,a			;59e1
	add a,a			;59e2
	or 006h		;59e3
	out (098h),a		;59e5
sprites_trozo_sig:
	ld a,010h		;59e7   ; 16 mas abajo
	add a,e			;59e9
	ld e,a			;59ea
	djnz sprites_trozo_tres		;59eb
sprites_lista:		; La lista (dy, dx, dibujo, color) hasta un 0
	inc ix		;59ed
	ld a,(ix+000h)		;59ef   ; dy
	or a			;59f2   ; 0: acaba
	jr z,sprites_lista_fin		;59f3
	add a,e			;59f5   ; la Y
	out (098h),a		;59f6
	ld a,d			;59f8   ; la X: la columna...
	add a,c			;59f9   ; ...+ el ancho...
	add a,l			;59fa   ; ...+ el desplazamiento EC
	inc ix		;59fb
	add a,(ix+000h)		;59fd   ; + dx: la X
	out (098h),a		;5a00
	inc ix		;5a02
	ld a,(ix+000h)		;5a04   ; el dibujo
	out (098h),a		;5a07
	inc ix		;5a09
	ld a,l			;5a0b   ; el color
	add a,a			;5a0c
	add a,a			;5a0d
	or (ix+000h)		;5a0e   ; | su color
	out (098h),a		;5a11
	jr sprites_lista		;5a13
sprites_lista_fin:
	pop af			;5a15
	ret			;5a16
prota_anda:		; Un estado del protagonista: en pie. El boton 1 salta (el estado 3), el boton 2 golpea (el estado 4, hacia el lado de la palanca); si no, cada 4 o 7 cuadros la palanca por la tabla 0x5A84; despues lo de siempre
	ld a,(0eae4h)		;5a17   ; 0xEAE4?
	or a			;5a1a
	jp nz,isla_acabada		;5a1b
	ld hl,0ead5h		;5a1e   ; el paso
	ld a,(hl)			;5a21
	or a			;5a22   ; el primero?
	jr nz,prota_anda_botones		;5a23
	ld (0eae1h),a		;5a25   ; 0xEAE1 y 0xEAE5 a 0
	ld (0eae5h),a		;5a28
	inc a			;5a2b   ; el paso 1
	ld (hl),a			;5a2c
prota_anda_botones:
	ld a,(0e005h)		;5a2d   ; el boton 1?
	or a			;5a30
	ld a,003h		;5a31   ; el estado 3
	jr nz,prota_estado_pon		;5a33
	ld a,(0e006h)		;5a35   ; el boton 2?
	or a			;5a38
	jr z,prota_anda_palanca		;5a39
	ld hl,0eadfh		;5a3b   ; el lado del golpe
	ld a,(0e004h)		;5a3e   ; la palanca...
	sub 002h		;5a41   ; ...a la derecha (2-4): 1; a la izquierda (6-8): 0xFF; otra: 0
	jr c,prota_golpe_recto		;5a43
	cp 003h		;5a45
	jr z,prota_golpe_recto		;5a47
	ccf			;5a49   ; el signo: 1 o 0xFF
	sbc a,a			;5a4a
	or 001h		;5a4b
	ld (hl),a			;5a4d   ; el lado
	jr prota_golpe		;5a4e
prota_golpe_recto:
	ld (hl),000h		;5a50   ; recto
prota_golpe:
	ld a,007h		;5a52   ; el dibujo 7
	ld (0eae5h),a		;5a54
	ld a,004h		;5a57   ; el estado 4
prota_estado_pon:
	ld (0ead3h),a		;5a59
	jr prota_siempre		;5a5c   ; y lo de cada cuadro
prota_anda_palanca:
	dec (hl)			;5a5e   ; la espera
	jr nz,prota_siempre		;5a5f
	ld a,(0eb26h)		;5a61   ; 0xEB26: 4 cuadros...
	or a			;5a64
	ld a,004h		;5a65
	jr nz,prota_anda_palanca_va		;5a67
	ld a,007h		;5a69   ; ...si no, 7
prota_anda_palanca_va:
	ld (hl),a			;5a6b   ; la espera
	ld a,(0e004h)		;5a6c   ; la palanca
	ld hl,05a84h		;5a6f   ; la tabla de nueve
	call salta_tabla		;5a72   ; salta
prota_siempre:		; Cada cuadro: 0x60AC, 0x6017, 0x5F8B, 0x6140 y 0x6076
	call enemigos_toca		;5a75
	call pinchos_mira		;5a78
	call suelo_mira		;5a7b
	call pajaro_toca		;5a7e
	jp meta_mira		;5a81

; ----------------------------------------------------------------------
; DATOS tabla_palanca: Las nueve direcciones de la palanca (0 quieta, 1 arriba
;   ... 8 arriba a la izquierda) del protagonista en pie
;   0x5a84..0x5a96  (18 bytes)
DATA_tabla_palanca:
	defw 05a96h,05a9ch,05ab0h,05ab9h,05ac3h,05adeh,05ae9h,05af2h,05b01h	; 5a84

; ======================================================================
; CODIGO 0x5a96..0x5cf2  (604 bytes)
; ======================================================================


palanca_quieta:		; 0: quieto (0xEAD5 = 1)
	ld a,001h		;5a96
	ld (0ead5h),a		;5a98
	ret			;5a9b
palanca_arriba:		; 1: arriba, si hay escalera (0x6064, C = 2): una fila arriba, y el estado 5
	ld c,002h		;5a9c   ; mirar arriba
	call escalera_mira		;5a9e   ; hay escalera?
	jr nz,palanca_quieta		;5aa1   ; no: quieto
sube_fila:
	or a			;5aa3   ; a mitad de casilla?
	jr nz,sube_fila_va		;5aa4
	ld hl,0eadch		;5aa6   ; si no, una columna a la izquierda
	dec (hl)			;5aa9   ; (sube por la mitad de la escalera)
sube_fila_va:
	ld hl,0eaddh		;5aaa   ; una fila arriba
	dec (hl)			;5aad
	jr escalera_estado		;5aae
palanca_arriba_der:		; 2: arriba a la derecha: la escalera o a la derecha
	ld c,002h		;5ab0
	call escalera_mira		;5ab2   ; hay escalera?
	jr nz,palanca_der		;5ab5   ; no: a la derecha
	jr sube_fila		;5ab7
palanca_der:		; 3: a la derecha (0xEADE = 0): un paso si se puede; si no, el sonido 7
	xor a			;5ab9   ; mira a la derecha
	ld (0eadeh),a		;5aba
	call paso_der		;5abd   ; un paso
	jr nc,prota_choca_sonido		;5ac0   ; no se puede: el sonido
	ret			;5ac2
palanca_abajo_der:		; 4: abajo a la derecha: la escalera hacia abajo o a la derecha
	ld c,004h		;5ac3
	call escalera_mira		;5ac5   ; hay escalera abajo?
	jr nz,palanca_der		;5ac8
baja_fila:
	or a			;5aca   ; a mitad de casilla?
	jr nz,baja_fila_va		;5acb
	ld hl,0eadch		;5acd
	dec (hl)			;5ad0   ; una columna a la izquierda
baja_fila_va:
	ld hl,0eaddh		;5ad1   ; una fila abajo
	inc (hl)			;5ad4
escalera_estado:		; El estado 5: en la escalera
	ld a,005h		;5ad5
prota_estado:
	ld (0ead3h),a		;5ad7
	ld (0eae5h),a		;5ada   ; y su dibujo
	ret			;5add
palanca_abajo:		; 5: abajo: la escalera hacia abajo o agachado (el estado 6)
	ld c,004h		;5ade   ; mirar abajo
	call escalera_mira		;5ae0
	jr z,baja_fila		;5ae3
	ld a,006h		;5ae5   ; agachado
	jr prota_estado		;5ae7
palanca_abajo_izq:		; 6: abajo a la izquierda
	ld c,004h		;5ae9
	call escalera_mira		;5aeb   ; hay escalera abajo?
	jr nz,palanca_izq		;5aee
	jr baja_fila		;5af0
palanca_izq:		; 7: a la izquierda (0xEADE = 0xFF): un paso si se puede; si no, el sonido 7
	ld a,0ffh		;5af2   ; mira a la izquierda
	ld (0eadeh),a		;5af4
	call paso_izq		;5af7   ; un paso
	ret c			;5afa   ; se puede: nada mas
prota_choca_sonido:
	ld hl,0ec0dh		;5afb   ; el sonido 7
	ld (hl),007h		;5afe
	ret			;5b00
palanca_arriba_izq:		; 8: arriba a la izquierda
	ld c,002h		;5b01
	call escalera_mira		;5b03   ; hay escalera?
	jr nz,palanca_izq		;5b06
	jr sube_fila		;5b08
prota_salta:		; El estado 3: el salto, tres pasos de 3 cuadros; en los pasos 2 y 3 mira arriba (0x5FE7); despues las cosas que coge (0x5B81) y, saltando de lado, se mueve
	ld hl,0ead5h		;5b0a   ; el paso
	ld a,(hl)			;5b0d
	inc (hl)			;5b0e   ; un cuadro mas
	or a			;5b0f   ; el primero?
	jr nz,prota_salta_paso		;5b10
	ld (hl),003h		;5b12   ; cada 3 cuadros
	inc a			;5b14   ; el dibujo 1...
	ld (0eae5h),a		;5b15
	inc a			;5b18   ; ...y el sonido 2
	ld (0ec0dh),a		;5b19
	ret			;5b1c
prota_salta_paso:
	cp 003h		;5b1d   ; 3 cuadros?
	jr c,prota_salta_coge		;5b1f
	ld (hl),001h		;5b21   ; otra vez 1
	ld hl,0eae5h		;5b23   ; el dibujo siguiente
	inc (hl)			;5b26
	ld a,(hl)			;5b27
	cp 004h		;5b28   ; el 4: acaba
	jr nc,prota_salta_fin		;5b2a
	cp 002h		;5b2c   ; el 2 o 3...
	jr c,prota_salta_coge		;5b2e
	ld a,(0eadeh)		;5b30   ; ...mira arriba a su lado...
	or 002h		;5b33
	ld b,a			;5b35
	push bc			;5b36
	call pared		;5b37   ; ...choca?
	pop bc			;5b3a
	jr c,prota_salta_choca		;5b3b
	rrc b		;5b3d   ; ...y al otro
	ccf			;5b3f
	rl b		;5b40
	call pared		;5b42
	jr c,prota_salta_choca		;5b45
prota_salta_coge:
	call coge		;5b47   ; lo que coge
	ld a,(0e010h)		;5b4a   ; 0xE010?
	or a			;5b4d   ; (la vista moviendose)
	ret nz			;5b4e
	ld hl,0eadeh		;5b4f
	ld a,(0e004h)		;5b52   ; la palanca: derecha...
	cp 003h		;5b55
	jr z,prota_salta_der		;5b57
	cp 007h		;5b59   ; ...o izquierda
	jr z,prota_salta_izq		;5b5b
	ret			;5b5d
prota_salta_der:
	ld a,(hl)			;5b5e   ; mira a la derecha?
	or a			;5b5f
	ret nz			;5b60
	call paso_der		;5b61   ; un paso
	jp prota_siempre		;5b64
prota_salta_izq:
	ld a,(hl)			;5b67   ; mira a la izquierda?
	or a			;5b68
	ret z			;5b69
	call paso_izq		;5b6a   ; un paso
	jp prota_siempre		;5b6d
prota_salta_choca:
	ld a,003h		;5b70   ; el sonido 3
	ld (0ec0dh),a		;5b72
prota_salta_fin:
	xor a			;5b75   ; de pie: el estado 2
	ld (0eae5h),a		;5b76
	ld a,002h		;5b79
	ld (0ead3h),a		;5b7b
	jp botones_cero		;5b7e
coge:		; Las ocho cosas de 0xEB32 (6 bytes): las que estan en su fila (0xEADD) y a menos de 4 columnas (0xEADC) se cogen (0x5BBD)
	ld a,(0eb26h)		;5b81   ; 0xEB26?
	or a			;5b84
	ret z			;5b85
	ld a,(0eadch)		;5b86   ; su columna...
	inc a			;5b89   ; + 1
	ld e,a			;5b8a
	ld a,(0eadeh)		;5b8b   ; ...hacia donde mira
	and 0fbh		;5b8e   ; 0 o 0xFB (-5)
	add a,e			;5b90
	ld e,a			;5b91
	ld a,(0eaddh)		;5b92   ; su fila
	ld d,a			;5b95   ; en D
	ld b,008h		;5b96   ; ocho
	ld hl,0eb32h		;5b98   ; las cosas
coge_una:
	ld c,(hl)			;5b9b   ; el primer byte
	inc hl			;5b9c
	ld a,(hl)			;5b9d   ; el segundo
	inc hl			;5b9e
	inc c			;5b9f   ; libre (0xFF)?
	jr nz,coge_sig		;5ba0
	or a			;5ba2   ; y el segundo 0?
	jr nz,coge_sig		;5ba3
	ld a,(hl)			;5ba5   ; en su fila?
	and 01fh		;5ba6
	cp d			;5ba8
	jr nz,coge_sig		;5ba9
	inc hl			;5bab
	ld a,(hl)			;5bac   ; a menos de 4?
	and 03fh		;5bad
	sub e			;5baf
	cp 004h		;5bb0
	call c,coge_si		;5bb2   ; la coge
	dec hl			;5bb5
coge_sig:
	inc hl			;5bb6   ; la siguiente (6 bytes)
	inc hl			;5bb7
	inc hl			;5bb8
	inc hl			;5bb9
	djnz coge_una		;5bba   ; una menos
	ret			;5bbc
coge_si:		; La cosa cogida: sale (0x7F); segun su numero: la 8, el sonido 4, 0xE001 bit 1 y 50 puntos; 5-7, 10 puntos; 1, 50; las otras, una menos en 0xEB29 y, a 0, se abre (0xE001 bit 0); 25 puntos
	push bc			;5bbd
	push de			;5bbe
	push hl			;5bbf
	ld a,(0ead3h)		;5bc0   ; golpeando?
	cp 004h		;5bc3
	jr z,coge_quita		;5bc5
	ld a,(0eadch)		;5bc7   ; si no, la cosa a su lado
	ld c,a			;5bca
	ld a,(0eadeh)		;5bcb
	and 0fch		;5bce
	add a,002h		;5bd0   ; + 2: delante
	add a,c			;5bd2
	and 03fh		;5bd3
	ld c,a			;5bd5   ; la columna nueva
	ld a,(hl)			;5bd6
	and 0c0h		;5bd7   ; con su fila
	or c			;5bd9
	ld (hl),a			;5bda   ; (se la queda delante)
coge_quita:
	dec hl			;5bdb
	res 5,(hl)		;5bdc   ; sin el bit 5
	dec hl			;5bde   ; fuera
	ld (hl),000h		;5bdf
	dec hl			;5be1
	ld (hl),07fh		;5be2   ; 0x7F
	ld a,b			;5be4   ; cual?
	cp 008h		;5be5
	jr nc,coge_8		;5be7
	cp 005h		;5be9
	jr nc,coge_10		;5beb
	dec a			;5bed   ; la 1: 50 puntos
	jr nz,coge_cuenta		;5bee
	ld a,050h		;5bf0
	jr coge_puntos		;5bf2
coge_cuenta:
	ld a,(0e001h)		;5bf4   ; 0xE001 bits 0-1?
	and 003h		;5bf7
	jr nz,coge_25		;5bf9   ; la isla abierta: solo los puntos
	ld hl,0eb29h		;5bfb   ; una menos
	dec (hl)			;5bfe
	jr nz,coge_25		;5bff
	ld hl,0e001h		;5c01   ; todas: 0xE001 bit 0
	set 0,(hl)		;5c04
	call vuelta_datos		;5c06   ; 0x6A17
	ld hl,0eb32h		;5c09   ; una cosa nueva en 0xEB32
	ld (hl),000h		;5c0c
	inc hl			;5c0e
	ld (hl),021h		;5c0f   ; la cosa 0x21 en su sitio...
	inc hl			;5c11
	inc hl			;5c12
	inc hl			;5c13
	ld (hl),00ch		;5c14   ; ...en la fila 12...
	inc hl			;5c16
	ld a,(0ead1h)		;5c17   ; ...y a 8 o 24 columnas de la vista, lejos del protagonista
	ld b,a			;5c1a
	ld a,(0eadch)		;5c1b
	sub b			;5c1e
	cp 010h		;5c1f   ; en la mitad izquierda?
	sbc a,a			;5c21   ; a la derecha (24) o a la izquierda (8)
	and 010h		;5c22
	add a,008h		;5c24
	add a,b			;5c26
	ld (hl),a			;5c27
	ld a,006h		;5c28   ; la musica 6
	ld (0ec25h),a		;5c2a
	ld (0ec30h),a		;5c2d
coge_25:
	ld a,025h		;5c30   ; 25 puntos
	jr coge_puntos		;5c32
coge_10:
	ld a,010h		;5c34   ; 10 puntos
	jr coge_puntos		;5c36
coge_8:
	ld hl,0ec10h		;5c38   ; el sonido 4
	ld (hl),004h		;5c3b
	ld hl,0e001h		;5c3d   ; 0xE001 bit 1
	set 1,(hl)		;5c40
	ld a,(0e002h)		;5c42   ; la isla 7?
	cp 007h		;5c45
	jr nz,coge_8_va		;5c47
	xor a			;5c49   ; 0xEB26 = 0
	ld (0eb26h),a		;5c4a
	call sprites_casillas_pon		;5c4d   ; las casillas de los sprites grandes
coge_8_va:
	call vuelta_datos		;5c50
	ld a,050h		;5c53   ; 50 puntos
	jr coge_puntos_pon		;5c55
coge_puntos:
	ld b,a			;5c57   ; los puntos
	ld hl,0ec10h		;5c58   ; el sonido 2, salvo con el 4
	ld a,(hl)			;5c5b
	cp 004h		;5c5c   ; el 4 sonando?
	ld a,b			;5c5e
	jr z,coge_puntos_pon		;5c5f
	ld (hl),002h		;5c61   ; el sonido 2
coge_puntos_pon:
	call puntos_suma		;5c63   ; a los puntos
	pop hl			;5c66
	pop de			;5c67
	pop bc			;5c68
	ret			;5c69
prota_brinco:		; Un estado del protagonista: el salto de lado (0xEADF): siete pasos de 4 cuadros con la altura de la tabla 0x5CF2 (bits 0-2: 1 sube dos, 2 sube uno, 3 baja uno, 4 baja dos; bit 3: sin avance) y un paso hacia su lado cada vez; al acabar, en pie
	ld hl,0ead5h		;5c6a   ; el paso
	ld a,(hl)			;5c6d
	inc (hl)			;5c6e   ; un cuadro mas
	or a			;5c6f   ; el primero?
	jr nz,prota_brinco_paso		;5c70
	ld (0eae0h),a		;5c72   ; 0xEAE0 = 0
	ld a,005h		;5c75   ; el sonido 5
	ld (0ec0dh),a		;5c77
	ld a,(0eadfh)		;5c7a   ; su lado...
	add a,a			;5c7d   ; ...quieto: nada
	ret z			;5c7e
	sbc a,a			;5c7f   ; a la derecha 0, a la izquierda 0xFF
	ld (0eadeh),a		;5c80
	ret			;5c83
prota_brinco_paso:
	cp 004h		;5c84   ; cada 4 cuadros
	jr c,prota_brinco_cuadro		;5c86
	ld (hl),001h		;5c88   ; otra vez 1
	ld hl,0eae0h		;5c8a   ; el paso del arco
	ld a,(hl)			;5c8d
	inc (hl)			;5c8e
	cp 007h		;5c8f   ; el 7: acaba
	jr nc,prota_brinco_fin		;5c91
	ld hl,05cf2h		;5c93   ; la altura de la tabla
	ld e,a			;5c96
	ld d,000h		;5c97
	add hl,de			;5c99   ; + el paso
	ld a,(hl)			;5c9a
	ld hl,0eaddh		;5c9b   ; la fila
	ld b,a			;5c9e   ; guardada
	and 007h		;5c9f   ; 0: igual
	jr z,prota_brinco_lado		;5ca1
	dec a			;5ca3   ; 1: dos arriba
	jr nz,prota_brinco_baja		;5ca4
	dec (hl)			;5ca6   ; una arriba...
prota_brinco_sube:
	dec (hl)			;5ca7   ; ...y otra
	jr prota_brinco_lado		;5ca8
prota_brinco_baja:
	dec a			;5caa   ; 2: una arriba
	jr z,prota_brinco_sube		;5cab
	dec a			;5cad   ; 3: una abajo
	jr nz,prota_brinco_baja1		;5cae
	inc (hl)			;5cb0   ; una abajo...
prota_brinco_baja1:
	inc (hl)			;5cb1   ; 4: dos abajo
prota_brinco_lado:
	ld a,b			;5cb2   ; sin avance?
	and 008h		;5cb3
	ld a,(0eadfh)		;5cb5   ; su lado
	jr nz,prota_brinco_sin		;5cb8
	add a,a			;5cba   ; quieto?
	jr z,prota_brinco_cuadro		;5cbb
	jr nc,prota_brinco_der		;5cbd   ; a la derecha?
	call paso_izq		;5cbf   ; dos pasos a la izquierda
prota_brinco_izq:
	call paso_izq		;5cc2
	jr prota_brinco_cuadro		;5cc5
prota_brinco_der:
	call paso_der		;5cc7   ; dos pasos a la derecha
prota_brinco_der1:
	call paso_der		;5cca
	jr prota_brinco_cuadro		;5ccd
prota_brinco_sin:
	add a,a			;5ccf   ; a la izquierda?
	jr c,prota_brinco_izq		;5cd0
	jr nz,prota_brinco_der1		;5cd2   ; a la derecha?
	jr prota_brinco_cuadro		;5cd4
prota_brinco_fin:
	xor a			;5cd6   ; 0xE00B a 0
	ld (0e00bh),a		;5cd7
	ld a,002h		;5cda   ; de pie
	ld (0ead3h),a		;5cdc
	call botones_cero		;5cdf   ; los botones a 0
	call pinchos_mira		;5ce2   ; pinchos?
prota_brinco_cuadro:
	call toca_cosas		;5ce5   ; lo que toca
	call meta_mira		;5ce8   ; la meta?
	call pajaro_toca		;5ceb   ; el pajaro?
	ret c			;5cee
	jp suelo_mira		;5cef   ; el suelo?

; ----------------------------------------------------------------------
; DATOS brinco_alturas: Las siete alturas del salto de lado (bits 0-2) y si
;   avanza (bit 3)
;   0x5cf2..0x5cf9  (7 bytes)
DATA_brinco_alturas:
	defb 009h,00ah,002h,000h,00ch,00ch,00bh	; 5cf2

; ======================================================================
; CODIGO 0x5cf9..0x5faf  (694 bytes)
; ======================================================================


toca_cosas:		; Las cosas de 0xEB32 a menos de 3 filas y 3 columnas del protagonista se cogen (0x5BBD)
	ld a,(0eb26h)		;5cf9   ; 0xEB26?
	or a			;5cfc
	ret z			;5cfd
	ld a,(0eadch)		;5cfe   ; su columna
	ld e,a			;5d01
	ld a,(0eaddh)		;5d02   ; su fila
	ld d,a			;5d05
	ld b,008h		;5d06   ; ocho
	ld hl,0eb32h		;5d08
toca_cosa:
	ld c,(hl)			;5d0b   ; el primer byte
	inc hl			;5d0c
	ld a,(hl)			;5d0d   ; el segundo
	inc hl			;5d0e
	inc c			;5d0f   ; libre?
	jr nz,toca_cosa_sig		;5d10
	or a			;5d12   ; y el segundo 0?
	jr nz,toca_cosa_sig		;5d13
	ld a,(hl)			;5d15   ; a menos de 3 filas?
	and 01fh		;5d16
	sub d			;5d18
	cp 003h		;5d19
	jr nc,toca_cosa_sig		;5d1b
	inc hl			;5d1d
	ld a,(hl)			;5d1e   ; a menos de 3 columnas?
	and 03fh		;5d1f
	sub e			;5d21
	cp 003h		;5d22
	call c,coge_si		;5d24   ; cogida
	dec hl			;5d27
toca_cosa_sig:
	inc hl			;5d28   ; la siguiente (6 bytes)
	inc hl			;5d29
	inc hl			;5d2a
	inc hl			;5d2b
	djnz toca_cosa		;5d2c   ; una menos
	ret			;5d2e
prota_cae_mar:		; Un estado: el protagonista cae al mar: a los 6 cuadros el sonido 9, a los 18 0xEAD6, a los 60 el dibujo 10 y el sonido 10; a los 100, una vida menos
	ld hl,0ead5h		;5d2f   ; un cuadro mas
	inc (hl)			;5d32
	ld a,(hl)			;5d33
	cp 006h		;5d34   ; 6?
	jr nz,prota_cae_mar_18		;5d36
	ld a,009h		;5d38   ; el sonido 9
	ld (0ec0dh),a		;5d3a
	ret			;5d3d
prota_cae_mar_18:
	cp 012h		;5d3e
	jr nz,prota_cae_mar_60		;5d40
	ld a,0ffh		;5d42   ; 0xEAD6 = 0xFF
	ld (0ead6h),a		;5d44
	ret			;5d47
prota_cae_mar_60:
	cp 03ch		;5d48
	jr nz,prota_cae_mar_100		;5d4a
	xor a			;5d4c   ; 0xEB26 a 0
	ld (0eb26h),a		;5d4d
	ld a,00ah		;5d50   ; el dibujo 10 y el sonido 10
	ld (0eae5h),a		;5d52
	ld (0ec0dh),a		;5d55
	ret			;5d58
prota_cae_mar_100:
	cp 064h		;5d59   ; 100?
	ret c			;5d5b   ; aun no
	jr vida_menos		;5d5c
prota_tocado:		; Un estado: tocado: el sonido 6, se queda quieto; 16 pasos de 6 cuadros y el estado 7; despues una vida menos
	ld hl,0ead5h		;5d5e   ; el paso
	ld a,(hl)			;5d61
	inc (hl)			;5d62   ; un cuadro mas
	or a			;5d63   ; el primero?
	jr nz,prota_tocado_paso		;5d64
	xor a			;5d66   ; 0xEAE5 y 0xEB26 a 0
	ld (0eae5h),a		;5d67
	ld (0eb26h),a		;5d6a
	cpl			;5d6d
	ld (0ead6h),a		;5d6e   ; 0xEAD6 = 0xFF
	ld a,006h		;5d71   ; el sonido 6
	ld (0ec0dh),a		;5d73
	ld a,008h		;5d76   ; 8 en 0xEAE1
	ld (0eae1h),a		;5d78
	ret			;5d7b
prota_tocado_paso:
	cp 006h		;5d7c   ; cada 6 cuadros
	ret c			;5d7e
	jr nz,prota_tocado_fin		;5d7f   ; (pasado de 6: el paso 7, esperando a 67)
	ld (hl),001h		;5d81   ; otra vez 1
	ld hl,0eae1h		;5d83   ; uno mas
	inc (hl)			;5d86
	ld a,(hl)			;5d87
	cp 010h		;5d88   ; 16?
	ret c			;5d8a
	call sprites_fuera		;5d8b   ; los sprites fuera
	ld hl,0e001h		;5d8e
	res 3,(hl)		;5d91   ; sin el bit 3
	ld hl,0ead5h		;5d93   ; el paso 7
	ld (hl),007h		;5d96
	ret			;5d98
prota_tocado_fin:
	cp 043h		;5d99   ; 67 cuadros?
	ret c			;5d9b
vida_menos:		; Una vida menos: los sprites fuera, el estado 14; en la demostracion, la presentacion; con la tecla 0 pulsada al encender (0xE000 bit 7), no se pierde; sin vidas, GAME OVER (el estado 5)
	call sprites_fuera		;5d9c
	ld a,00eh		;5d9f   ; el estado 14
	ld (0ead3h),a		;5da1
	ld hl,0e001h		;5da4   ; 0xE001 sin el bit 3
	res 3,(hl)		;5da7
	bit 6,(hl)		;5da9   ; la demostracion?
	jr nz,vida_demo		;5dab
	ld a,(0e000h)		;5dad   ; la tecla 0 al encender?
	and 080h		;5db0   ; ...pulsada: no se pierde
	ret nz			;5db2
	ld hl,0eae3h		;5db3   ; una vida menos
	dec (hl)			;5db6
	ret nz			;5db7   ; quedan
	xor a			;5db8   ; sin vidas...
	ld (0ead3h),a		;5db9
	ld a,005h		;5dbc   ; ...GAME OVER (el estado 5)
	ld (0eab1h),a		;5dbe
	ret			;5dc1
vida_demo:
	xor a			;5dc2   ; la demostracion se acaba: la presentacion
	ld (0ead3h),a		;5dc3
	inc a			;5dc6   ; el estado 1
	ld (0eab1h),a		;5dc7
	ret			;5dca
prota_rebota:		; Un estado: rebota hacia atras (el sonido 4, el dibujo 7): unos pasos al reves de donde mira; despues en pie o el estado 13
	ld hl,0ead5h		;5dcb   ; el paso
	ld a,(hl)			;5dce
	inc (hl)			;5dcf   ; un cuadro mas
	or a			;5dd0   ; el primero?
	jr nz,prota_rebota_paso		;5dd1
	ld (0e00bh),a		;5dd3   ; 0xE00B a 0
	ld a,004h		;5dd6   ; el sonido 4
	ld (0ec0dh),a		;5dd8
	ld a,007h		;5ddb   ; el dibujo 7
	ld (0eae5h),a		;5ddd
	ld a,(0eadfh)		;5de0   ; al reves de su lado
	cpl			;5de3
	ld (0eadeh),a		;5de4
	ret			;5de7
prota_rebota_paso:
	cp 005h		;5de8   ; cada 5 cuadros
	jr c,prota_rebota_cuadro		;5dea
	ld (hl),001h		;5dec   ; otra vez 1
	ld hl,0eae0h		;5dee   ; los pasos que quedan
	dec (hl)			;5df1
	jr z,prota_rebota_fin		;5df2
	ld a,(0eadfh)		;5df4   ; su lado
	add a,a			;5df7
	jr nc,prota_rebota_der		;5df8
	call paso_izq		;5dfa   ; a la izquierda
	jr prota_rebota_cuadro		;5dfd
prota_rebota_der:
	call paso_der		;5dff   ; a la derecha
	jr prota_rebota_cuadro		;5e02
prota_rebota_fin:
	ld a,(0ead7h)		;5e04   ; 0xEAD7?
	dec a			;5e07   ; sin fuerza?
	jp m,prota_estado13		;5e08   ; el estado 13
	call botones_cero		;5e0b   ; de pie
	ld a,002h		;5e0e
	ld (0ead3h),a		;5e10
prota_rebota_cuadro:
	call meta_mira		;5e13   ; la meta?
	call pajaro_toca		;5e16   ; el pajaro?
	ret c			;5e19
	call pinchos_mira		;5e1a   ; pinchos?
	jp suelo_mira		;5e1d   ; el suelo?
prota_estado13:
	ld a,00dh		;5e20
	ld (0ead3h),a		;5e22
	ret			;5e25
prota_agachado:		; El estado 6: agachado mientras la palanca siga abajo; si no, en pie
	ld a,(0e004h)		;5e26   ; la palanca abajo?
	cp 005h		;5e29
	jr z,prota_agachado_va		;5e2b
	call botones_cero		;5e2d   ; si no, en pie
	ld a,002h		;5e30
	ld (0ead3h),a		;5e32
prota_agachado_va:
	call pajaro_toca		;5e35   ; el pajaro?
	ret c			;5e38
	jp enemigos_toca		;5e39   ; los enemigos?
prota_escalera:		; El estado 5: en la escalera: cada 4 cuadros una fila arriba o abajo con la palanca; el sonido 8; arriba del todo o abajo, en pie
	call enemigos_toca		;5e3c   ; cae?
	ret c			;5e3f
	call pajaro_toca		;5e40   ; choca?
	ret c			;5e43
	ld hl,0ead5h		;5e44   ; el paso
	ld a,(hl)			;5e47
	inc (hl)			;5e48   ; un cuadro mas
	or a			;5e49   ; el primero?
	jr nz,prota_escalera_paso		;5e4a
	ld a,001h		;5e4c   ; el paso 1
	ld (0ead5h),a		;5e4e
prota_escalera_paso:
	cp 004h		;5e51   ; cada 4 cuadros
	ret c			;5e53
	ld (hl),001h		;5e54   ; otra vez 1
	ld hl,0eaddh		;5e56   ; la fila
	ld a,(0e004h)		;5e59   ; la palanca
	or a			;5e5c   ; quieta?
	jr z,prota_escalera_quieto		;5e5d
	cp 003h		;5e5f   ; derecha?
	jr z,prota_escalera_quieto		;5e61
	jr c,prota_escalera_sube		;5e63
	cp 007h		;5e65   ; izquierda?
	jr z,prota_escalera_quieto		;5e67
	jr nc,prota_escalera_sube		;5e69
	inc (hl)			;5e6b   ; abajo: una fila abajo (dos mas, una menos)
	inc (hl)			;5e6c
prota_escalera_sube:
	dec (hl)			;5e6d   ; una fila arriba
	ld hl,0eb0ah		;5e6e   ; un paso mas (el dibujo)
	inc (hl)			;5e71
	ld a,008h		;5e72   ; el sonido 8
	ld (0ec0dh),a		;5e74
prota_escalera_mira:
	ld c,003h		;5e77   ; sigue la escalera?
	call escalera_mira		;5e79
	ret z			;5e7c
	xor a			;5e7d   ; si no, en pie
	ld (0e00bh),a		;5e7e
	ld a,002h		;5e81
	ld (0ead3h),a		;5e83
	jp botones_cero		;5e86
prota_escalera_quieto:
	ld a,006h		;5e89   ; el paso 6 (sin espera la proxima vez)
	ld (0ead5h),a		;5e8b
	jr prota_escalera_mira		;5e8e
prota_espera:		; Un estado: 16 cuadros quieto (0xEAD6 = 0xFF) y el estado 9
	ld hl,0ead5h		;5e90   ; el paso
	ld a,(hl)			;5e93
	inc (hl)			;5e94   ; un cuadro mas
	or a			;5e95   ; el primero?
	jr nz,prota_espera_fin		;5e96
	cpl			;5e98   ; 0xEAD6 = 0xFF
	ld (0ead6h),a		;5e99
	ret			;5e9c
prota_espera_fin:
	cp 010h		;5e9d   ; 16?
	ret c			;5e9f
	xor a			;5ea0
	ld (0ec09h),a		;5ea1   ; 0xEC09 a 0
	ld a,009h		;5ea4   ; el estado 9
	ld (0ead3h),a		;5ea6
	ret			;5ea9
prota_sube:		; Un estado: el protagonista sube una fila cada 4 cuadros hasta la fila 2, moviendose de lado si puede; el sonido 6
	ld hl,0ead5h		;5eaa
	ld a,(hl)			;5ead   ; el primero?
	inc (hl)			;5eae   ; un cuadro mas
	or a			;5eaf
	jr nz,prota_sube_paso		;5eb0
	ld a,(0eaddh)		;5eb2   ; la fila de arriba
	dec a			;5eb5
	ld (0eae2h),a		;5eb6   ; hasta ella (0xEAE2)
	ld a,007h		;5eb9   ; el dibujo 7
	ld (0eae5h),a		;5ebb
	ld a,0ffh		;5ebe   ; 0xEAD6 = 0xFF
	ld (0ead6h),a		;5ec0
	ld hl,0eadfh		;5ec3   ; su lado al reves
	cpl			;5ec6
	ld (0eadeh),a		;5ec7
	set 1,(hl)		;5eca   ; con el bit 1: hacia un lado
	ld a,006h		;5ecc   ; el sonido 6
	ld (0ec0dh),a		;5ece
	ret			;5ed1
prota_sube_paso:
	cp 018h		;5ed2   ; 24 pasos?
	jr nc,prota_sube_fin		;5ed4
	and 003h		;5ed6   ; cada 4 cuadros
	ret nz			;5ed8
	ld hl,0eaddh		;5ed9   ; una fila arriba
	dec (hl)			;5edc
	ld a,(hl)			;5edd
	cp 002h		;5ede   ; la 2?
	jr nc,prota_sube_lado		;5ee0
	ld a,018h		;5ee2   ; si: acaba
	ld (0ead5h),a		;5ee4
prota_sube_lado:
	ld a,(0eadfh)		;5ee7
	add a,a			;5eea   ; quieto?
	ret z			;5eeb
	jr c,prota_sube_izq		;5eec   ; a la izquierda?
	call paso_der		;5eee   ; a la derecha
	jr c,prota_sube_para		;5ef1   ; pared: deja de ir de lado
	ret			;5ef3
prota_sube_izq:
	call paso_izq		;5ef4   ; a la izquierda
	ret nc			;5ef7
prota_sube_para:
	xor a			;5ef8   ; sin lado
	ld (0eadfh),a		;5ef9
	ret			;5efc
prota_sube_fin:
	ld a,009h		;5efd   ; el dibujo 9: cae
	ld (0eae5h),a		;5eff
	ld hl,0eaddh		;5f02   ; una fila abajo
	inc (hl)			;5f05
	ld a,(0eae2h)		;5f06   ; la fila de antes?
	cp (hl)			;5f09   ; por encima?
	jr nc,prota_sube_lado		;5f0a
	ld a,007h		;5f0c   ; el estado 7
	ld (0ead3h),a		;5f0e
	jr prota_cae_mira		;5f11   ; lo que hay debajo
prota_cae:		; Un estado: cae, una fila cada 4 cuadros; abajo del todo (fila 24), al mar; en una casilla de agua (0x605F), el estado 13; en las 0x28/0x29, el 12
	ld hl,0ead5h		;5f13   ; el paso
	ld a,(hl)			;5f16
	inc (hl)			;5f17   ; un cuadro mas
	or a			;5f18   ; el primero?
	jr nz,prota_cae_paso		;5f19
	ld a,009h		;5f1b   ; el dibujo 9
	ld (0eae5h),a		;5f1d
	ld a,0ffh		;5f20   ; 0xEAD6 = 0xFF
	ld (0ead6h),a		;5f22
	jr prota_cae_fila		;5f25
prota_cae_paso:
	and 003h		;5f27   ; cada 4 cuadros
	ret nz			;5f29
	ld (hl),001h		;5f2a   ; otra vez 1
prota_cae_fila:
	ld hl,0eaddh		;5f2c   ; una fila abajo
	inc (hl)			;5f2f
	ld a,(hl)			;5f30
	cp 018h		;5f31   ; abajo del todo?
	jr nc,$+29		;5f33   ; (salta a 0x5F50, a mitad del "ld hl,0x0D3E": "ld a,0x0D")
prota_cae_mira:
	ld bc,00003h		;5f35   ; la casilla bajo sus pies
	call casilla_prota		;5f38
	ld a,(hl)			;5f3b   ; cual?
	ld bc,00005h		;5f3c   ; cinco casillas...
	ld hl,0605fh		;5f3f   ; ...de 0x605F
	cpir		;5f42   ; CPIR
	jr z,$+12		;5f44   ; una de ellas: a 0x5F50 ("ld a,0x0D": el estado 13)
	cp 028h		;5f46   ; 0x28?
	jr z,prota_cae_12		;5f48
	cp 029h		;5f4a   ; 0x29?
	ret nz			;5f4c
prota_cae_12:
	ld a,00ch		;5f4d   ; el estado 12
	ld hl,00d3eh		;5f4f   ; "ld hl,0x0D3E": desde 0x5F44, sus dos ultimos bytes son "ld a,0x0D"
	ld (0ead3h),a		;5f52   ; el estado
	ret			;5f55
casilla_prota:		; HL = la casilla del fondo (0xE01A, filas de 64) en la fila del protagonista + B y su columna + C
	ld a,(0eaddh)		;5f56   ; la fila
	ld d,a			;5f59
	ld a,(0eadch)		;5f5a   ; la columna
	ld e,a			;5f5d
	call casilla_dir		;5f5e   ; (D + C) x 64 + E + B
	ld de,0e01ah		;5f61   ; + el fondo
	add hl,de			;5f64   ; + el fondo
	ret			;5f65
paso_der:		; Un paso a la derecha si no hay pared (0x5FE7) y no esta en la columna 0x3C; C si no puede
	ld b,002h		;5f66   ; a la derecha
	call pared		;5f68   ; pared?
	ret c			;5f6b
	ld hl,0eadch		;5f6c   ; la columna
	ld a,(hl)			;5f6f
	cp 03ch		;5f70   ; el borde?
	ccf			;5f72   ; C si 0x3C o mas
	ret c			;5f73
	inc (hl)			;5f74   ; una mas
	jr paso_dibujo		;5f75
paso_izq:		; Un paso a la izquierda, hasta la columna 3
	ld b,0ffh		;5f77   ; a la izquierda
	call pared		;5f79   ; pared?
	ret c			;5f7c
	ld hl,0eadch		;5f7d
	ld a,(hl)			;5f80
	cp 003h		;5f81   ; el borde?
	ret c			;5f83
	dec (hl)			;5f84   ; una menos
paso_dibujo:
	ld hl,0eb0ah		;5f85   ; el paso siguiente del dibujo
	inc (hl)			;5f88
	or a			;5f89   ; NC: hecho
	ret			;5f8a
suelo_mira:		; ¿Que tiene el protagonista alrededor? Tres filas de dos casillas contra las 10 de 0x5FAF; si una esta, salta (0x5FB9)
	ld bc,00000h		;5f8b
	call casilla_prota		;5f8e   ; desde su casilla
	ld c,003h		;5f91   ; tres filas
suelo_fila:
	ex de,hl			;5f93   ; DE la casilla
	ld b,002h		;5f94   ; dos casillas
suelo_casilla:
	push bc			;5f96
	ld a,(de)			;5f97   ; la casilla
	ld hl,05fafh		;5f98   ; las diez de 0x5FAF
	ld bc,0000ah		;5f9b
	cpir		;5f9e   ; CPIR
	pop bc			;5fa0
	jr z,$+24		;5fa1   ; una de ellas: a mitad de la instruccion de 0x5FB9
	inc de			;5fa3   ; la de al lado
	djnz suelo_casilla		;5fa4   ; una menos
	ld hl,0003eh		;5fa6   ; la fila de abajo
	add hl,de			;5fa9
	dec c			;5faa   ; una fila menos
	jr nz,suelo_fila		;5fab
	or a			;5fad   ; NC: nada
	ret			;5fae

; ----------------------------------------------------------------------
; DATOS casillas_paredes: Las diez casillas que paran al protagonista
;   0x5faf..0x5fb9  (10 bytes)
DATA_casillas_paredes:
	defb 02ah,02bh,02ch,02dh,02eh,02fh,030h,031h,032h,03fh	; 5faf  *+,-./012?

; ======================================================================
; CODIGO 0x5fb9..0x6059  (160 bytes)
; ======================================================================


prota_rebote:		; Choca: segun su fila, la parte de la isla (0, 0x40, 0x80) y la cosa de 0xEAC3 de esa parte: rebota hacia el otro lado (el estado 9)
	ld a,(0eaddh)		;5fb9   ; su fila
	ld c,000h		;5fbc   ; arriba: 0
	cp 008h		;5fbe
	jr c,prota_rebote_cosa		;5fc0
	ld c,040h		;5fc2   ; en medio: 0x40
	cp 00fh		;5fc4
	jr c,prota_rebote_cosa		;5fc6
	ld c,080h		;5fc8   ; abajo: 0x80
prota_rebote_cosa:
	ld hl,(0eac3h)		;5fca   ; la lista
prota_rebote_busca:
	ld a,(hl)			;5fcd   ; la parte (bits 6-7)
	inc hl			;5fce   ; la siguiente
	and 0c0h		;5fcf
	cp c			;5fd1   ; la suya?
	jr nz,prota_rebote_busca		;5fd2
	ld a,(hl)			;5fd4   ; su columna
	and 03fh		;5fd5
	ld b,a			;5fd7
	ld a,(0eadch)		;5fd8   ; la del protagonista
	cp b			;5fdb
	ccf			;5fdc   ; a que lado
	sbc a,a			;5fdd   ; a la izquierda (0xFF) o a la derecha (0)
	ld (0eadfh),a		;5fde
	ld a,009h		;5fe1   ; el estado 9
	ld (0ead3h),a		;5fe3
	ret			;5fe6
pared:		; ¿Hay pared al lado B (columna + B, la parte por la fila) en la lista de 0xEAC1? C si la hay
	ld c,000h		;5fe7   ; la parte
	ld a,(0eaddh)		;5fe9
	cp 002h		;5fec   ; por encima de la fila 2: no
	jr c,pared_no		;5fee
	cp 008h		;5ff0   ; la fila 8: no
	jr c,pared_mira		;5ff2
	jr z,pared_no		;5ff4
	ld c,040h		;5ff6   ; la parte del medio
	cp 00fh		;5ff8   ; la fila 15: no
	jr c,pared_mira		;5ffa
	jr z,pared_no		;5ffc
	ld c,080h		;5ffe   ; la de abajo
pared_mira:
	ld a,(0eadch)		;6000   ; la columna + B...
	add a,b			;6003
	or c			;6004   ; ...con la parte
	ld b,a			;6005
	ld hl,(0eac1h)		;6006   ; la lista
pared_busca:
	ld a,(hl)			;6009   ; una
	or a			;600a   ; 0: no hay
	jr z,pared_no		;600b
	cp b			;600d   ; la del lado?
	jr z,pared_si		;600e
	inc hl			;6010   ; la siguiente
	jr pared_busca		;6011
pared_si:
	scf			;6013   ; C: pared
	ret			;6014
pared_no:
	or a			;6015   ; NC: nada
	ret			;6016
pinchos_mira:		; Fuera de los estados 4 y 5: las dos casillas sobre las que esta, contra las de 0x6059 (el sonido 6 y el estado 7) y las de 0x605F (nada); por debajo de 0x40 tambien el 7; si no, el 12
	ld a,(0ead3h)		;6017   ; golpeando o en la escalera: nada
	cp 004h		;601a
	ret z			;601c
	cp 005h		;601d
	ret z			;601f
	ld bc,00003h		;6020   ; la casilla bajo sus pies
	call casilla_prota		;6023
	ld b,002h		;6026   ; dos
	ex de,hl			;6028   ; DE la casilla
pinchos_casilla:
	push bc			;6029
	ld a,(de)			;602a   ; la casilla
	ld bc,00006h		;602b   ; seis de 0x6059
	ld hl,06059h		;602e
	cpir		;6031   ; CPIR
	jr z,pinchos_si		;6033
	ld bc,00005h		;6035   ; cinco de 0x605F
	ld hl,0605fh		;6038
	cpir		;603b
	jr z,pinchos_sig		;603d   ; del agua: la de al lado
	cp 040h		;603f   ; 0x40 o mas
	jr nc,pinchos_si		;6041
	jr pinchos_12		;6043   ; otra: el estado 12 (cae)
pinchos_sig:
	pop bc			;6045
	inc de			;6046   ; la de al lado
	djnz pinchos_casilla		;6047   ; una menos
	ret			;6049
pinchos_si:
	ld a,006h		;604a   ; el sonido 6
	ld (0ec0dh),a		;604c
	inc a			;604f   ; el estado 7
	jr pinchos_pon		;6050
pinchos_12:
	ld a,00ch		;6052   ; el estado 12
pinchos_pon:
	ld (0ead3h),a		;6054
	pop bc			;6057   ; (fuera del bucle)
	ret			;6058

; ----------------------------------------------------------------------
; DATOS casillas_peligro: Seis casillas que tocan al protagonista (0x6059) y
;   cinco del agua (0x605F)
;   0x6059..0x6064  (11 bytes)
DATA_casillas_peligro:
	defb 000h,020h,022h,024h,026h,03bh,021h,023h,03ch,027h,03eh	; 6059  . "$&;!#<'>

; ======================================================================
; CODIGO 0x6064..0x6231  (461 bytes)
; ======================================================================


escalera_mira:		; ¿Una escalera (0x26) en la fila + C? A = 0 si en la casilla, 1 si en la de al lado; Z si esta
	ld b,000h		;6064
	call casilla_prota		;6066   ; la casilla
	ld a,(hl)			;6069
	cp 026h		;606a   ; 0x26?
	ld a,000h		;606c
	ret z			;606e
	inc hl			;606f   ; la de al lado
	ld a,(hl)			;6070
	cp 026h		;6071
	ld a,001h		;6073
	ret			;6075
meta_mira:		; Con 0xE001 bit 1: si toca la casilla 0x38 o una de 0x80-0x90 (3 filas de 2), 0xEAE4 = 0xFF y 0xE001 bit 5: la isla acabada
	ld a,(0e001h)		;6076   ; 0xE001 bit 1?
	and 002h		;6079
	ret z			;607b
	ld bc,00000h		;607c
	call casilla_prota		;607f   ; su casilla
	ld c,003h		;6082   ; tres filas
meta_fila:
	ld b,002h		;6084   ; dos casillas
meta_casilla:
	ld a,(hl)			;6086
	cp 038h		;6087   ; 0x38?
	jr z,meta_si		;6089
	cp 080h		;608b   ; 0x80-0x90?
	jr c,meta_sig		;608d
	cp 091h		;608f
	jr c,meta_si		;6091
meta_sig:
	inc hl			;6093   ; la de al lado
	djnz meta_casilla		;6094   ; una menos
	ld de,0003dh		;6096   ; la fila de abajo
	add hl,de			;6099
	dec c			;609a   ; una fila menos
	jr nz,meta_fila		;609b
	ret			;609d
meta_si:
	ld a,0ffh		;609e
	ld (0eae4h),a		;60a0   ; la isla acabada
	ld (0ead6h),a		;60a3   ; sin choques
	ld hl,0e001h		;60a6   ; 0xE001 bit 5
	set 5,(hl)		;60a9
	ret			;60ab
enemigos_toca:		; Con 0xEB26: los ocho de 0xEB32 en sus filas y a menos de 2 columnas le tocan: rebota hacia un lado y una vida en 0xEAD7 menos (la fuerza); segun cual, el estado 10, 12 o 5
	ld a,(0eb26h)		;60ac   ; 0xEB26?
	or a			;60af
	ret z			;60b0
	ld a,(0eadch)		;60b1   ; su columna
	ld e,a			;60b4
	ld a,(0eaddh)		;60b5   ; su fila - 2
	sub 002h		;60b8
	ld d,a			;60ba
	ld b,008h		;60bb   ; ocho
	ld hl,0eb32h		;60bd
enemigo_toca_uno:
	ld c,(hl)			;60c0   ; el primer byte
	inc hl			;60c1
	ld a,(hl)			;60c2   ; el segundo
	inc hl			;60c3
	inc c			;60c4   ; libre?
	jr nz,enemigo_toca_sig		;60c5
	or a			;60c7   ; y el segundo 0?
	jr nz,enemigo_toca_sig		;60c8
	ld a,(hl)			;60ca   ; en sus filas?
	and 01fh		;60cb
	sub d			;60cd
	jr c,enemigo_toca_sig		;60ce
	cp 005h		;60d0   ; de las 5 filas?
	jr nc,enemigo_toca_sig		;60d2
	inc hl			;60d4
	ld a,(hl)			;60d5   ; su columna
	and 03fh		;60d6
	sub e			;60d8
	jr z,enemigo_toca_lado		;60d9   ; encima
	cp 002h		;60db
	jr c,enemigo_toca_si		;60dd   ; a la derecha (1)
	cp 0ffh		;60df   ; a la izquierda (0xFF)?
	jr nc,enemigo_toca_si		;60e1
	dec hl			;60e3   ; (la columna)
enemigo_toca_sig:
	inc hl			;60e4   ; la siguiente (6 bytes)
	inc hl			;60e5
	inc hl			;60e6
	inc hl			;60e7
	djnz enemigo_toca_uno		;60e8   ; una menos
	or a			;60ea   ; NC: nada
	ret			;60eb
enemigo_toca_lado:
	ld a,(0eadeh)		;60ec   ; encima: al reves de donde mira
	cpl			;60ef
	rla			;60f0
enemigo_toca_si:
	sbc a,a			;60f1
	ld (0eadfh),a		;60f2   ; hacia donde rebota
	and 040h		;60f5   ; el bit 6 de la cosa: hacia el otro lado
	ld d,a			;60f7
	dec hl			;60f8
	ld a,(hl)			;60f9   ; su byte
	and 0bfh		;60fa
	or d			;60fc
	ld (hl),a			;60fd
	ld hl,0ead7h		;60fe   ; la fuerza (0xEAD7)
	ld a,b			;6101   ; cual?
	cp 008h		;6102   ; la 8: 7 pasos
	jr nc,enemigo_toca_7		;6104
	cp 005h		;6106   ; 5-7: a mitad de 0x6118 ("ld a,3")
	jr nc,$+17		;6108
	dec a			;610a   ; la 1: 9 pasos
	jr nz,enemigo_toca_5		;610b
	ld a,009h		;610d
	jr enemigo_toca_pon		;610f
enemigo_toca_5:
	ld a,005h		;6111   ; las otras: 5
	jr enemigo_toca_pon		;6113
enemigo_toca_7:
	ld a,007h		;6115
enemigo_toca_pon:
	dec (hl)			;6117   ; una menos
	ld bc,0033eh		;6118   ; (con 0x6108: "ld bc,0x033E" tapa "ld a,3")
	ld (0eae0h),a		;611b   ; los pasos del rebote
	dec (hl)			;611e   ; y otra
	bit 7,(hl)		;611f   ; a 0 como poco
	jr z,enemigo_toca_fila		;6121
	ld (hl),000h		;6123   ; a 0
enemigo_toca_fila:
	ld hl,0eaddh		;6125
	ld a,(hl)			;6128   ; su fila
	cp 009h		;6129   ; arriba (fila 8 o menos): a 0x6134, "ld (hl),5"
	jr c,$+9		;612b   ; (saltos a mitad de los "ld hl" de 0x6133 y 0x6136: "ld (hl),5" y "ld (hl),0x0C")
	cp 010h		;612d   ; en medio: a 0x6137, "ld (hl),0x0C"
	jr c,$+8		;612f
	ld (hl),013h		;6131   ; abajo: la fila 19
	ld hl,00536h		;6133   ; (desde 0x612B: "ld (hl),5" y sigue en 0x6135)
	ld hl,00c36h		;6136   ; (desde 0x612F: "ld (hl),0x0C" y sigue en 0x6138)
	ld a,00ah		;6139   ; el estado 10
prota_estado_c:
	ld (0ead3h),a		;613b
	scf			;613e   ; C: tocado
	ret			;613f
pajaro_toca:		; Con 0xEB26 y el pajaro (0xEB62): si el protagonista esta debajo, a menos de 3 columnas: en la escalera, nada; si no, rebota (el estado 9), salvo con la tecla 0 al encender
	ld a,(0eb26h)		;6140   ; 0xEB26?
	or a			;6143
	ret z			;6144
	ld a,(0eb62h)		;6145   ; el pajaro?
	or a			;6148
	ret z			;6149
	ld a,(0eadch)		;614a   ; la columna del protagonista
	dec a			;614d   ; - 1
	ld e,a			;614e
	ld a,(0eb65h)		;614f   ; la del pajaro
	and 03fh		;6152
	sub e			;6154   ; - la del protagonista
	ld e,a			;6155
	ccf			;6156   ; a la izquierda: nada
	ret nc			;6157
	cp 003h		;6158   ; a 3 o mas: nada
	ret nc			;615a
	ld a,(0eb64h)		;615b   ; la fila
	and 01fh		;615e
	sub 003h		;6160   ; - 3
	ld d,a			;6162
	ld a,(0eaddh)		;6163
	sub d			;6166   ; cuanto mas abajo
	ccf			;6167
	jr z,pajaro_toca_escalera		;6168   ; justo: mira la escalera
	ret nc			;616a
	cp 006h		;616b   ; 6?
	jr z,pajaro_toca_escalera		;616d
	ret nc			;616f
pajaro_toca_si:
	ld a,e			;6170
	cp 002h		;6171   ; a que lado
	ccf			;6173
	sbc a,a			;6174   ; 0xFF o 0
	ld (0eadfh),a		;6175   ; hacia donde rebota
	ld a,(0e000h)		;6178   ; la tecla 0 al encender: nada
	and 080h		;617b
	ret nz			;617d
	ld a,009h		;617e   ; el estado 9
	jr prota_estado_c		;6180
pajaro_toca_escalera:
	ld a,(0ead3h)		;6182
	cp 005h		;6185
	jr z,pajaro_toca_si		;6187
	or a			;6189   ; NC: nada
	ret			;618a
isla_acabada:		; La isla acabada (0xEAE4): los sprites fuera, la musica 4 y el estado 11
	call sprites_fuera		;618b
	xor a			;618e   ; 0xEB26 a 0
	ld (0eb26h),a		;618f
	ld a,004h		;6192   ; la musica 4
	ld (0ec25h),a		;6194
	ld (0ec30h),a		;6197
	ld a,00bh		;619a   ; el estado 11
	ld (0ead3h),a		;619c
	ret			;619f
prota_dibujos:		; Los dibujos del protagonista a los sprites (64 bloques de 0x63C9 en 0x1800 y su espejo en 0x1C00; 56 de 0x6501 en 0x1A00 y su espejo en 0x1E00)
	ld hl,063c9h		;61a0   ; 64 bloques...
	ld de,01800h		;61a3   ; ...a 0x1800
	ld b,040h		;61a6
	call desempaqueta_vram		;61a8   ; desempaquetados y a la VRAM
	ld hl,0e6b1h		;61ab   ; su espejo
	ld de,0e8b1h		;61ae
	ld bc,00200h		;61b1
	push de			;61b4
	push bc			;61b5
	call espejo_sprites		;61b6   ; los bits al reves y las mitades cambiadas
	pop bc			;61b9
	pop hl			;61ba
	ld de,01c00h		;61bb   ; a 0x1C00
	call 0005ch		;61be   ; LDIRVM
	ld hl,06501h		;61c1   ; 56 bloques a 0x1A00
	ld de,01a00h		;61c4
	ld b,038h		;61c7
	call desempaqueta_vram		;61c9   ; desempaquetados y a la VRAM
	ld hl,0e6b1h		;61cc   ; su espejo
	ld de,0e8b1h		;61cf
	ld bc,001c0h		;61d2
	push de			;61d5
	push bc			;61d6
	call espejo_sprites		;61d7   ; los bits al reves y las mitades cambiadas
	pop bc			;61da
	pop hl			;61db
	ld de,01e00h		;61dc   ; a 0x1E00
	call 0005ch		;61df   ; LDIRVM
	xor a			;61e2   ; 0xEAE6 a 0
	ld (0eae6h),a		;61e3
	ret			;61e6
prota_sprite:		; El sprite del protagonista
	ld hl,03b04h		;61e7   ; 0xD0 en el segundo sprite
	ld a,0d0h		;61ea   ; (el sprite 1)
	call 0004dh		;61ec   ; WRTVRM
	ld a,(0eae6h)		;61ef   ; el dibujo cargado (0xEAE6)
	ld l,a			;61f2
	ld a,(0eae5h)		;61f3   ; el que toca (0xEAE5)
	or a			;61f6
	jr z,prota_dibujo_carga		;61f7
	cp 005h		;61f9   ; 1-4: los de siempre
	ret c			;61fb
	sub 004h		;61fc   ; 5 o mas: - 4
prota_dibujo_carga:		; Si cambia el dibujo, se carga: los de 1-4 de la tabla 0x6231 (20 bloques a 0x1800 y su espejo a 0x1C00); los de 5 o mas, en 0x623B
	cp l			;61fe   ; el mismo: nada
	ret z			;61ff
	ld (0eae6h),a		;6200   ; el nuevo
	cp 005h		;6203   ; 5 o mas: a 0x623B ("jr nc,$+54")
	jr nc,$+54		;6205
	add a,a			;6207   ; x 2
	ld c,a			;6208
	ld b,000h		;6209
	ld hl,06231h		;620b   ; la tabla
	add hl,bc			;620e
	ld a,(hl)			;620f   ; la direccion
	inc hl			;6210
	ld h,(hl)			;6211
	ld l,a			;6212
	ld de,01800h		;6213   ; a 0x1800
	ld b,014h		;6216   ; 20 bloques
	call desempaqueta_vram		;6218   ; desempaquetados y a la VRAM
	ld hl,0e6b1h		;621b   ; su espejo
	ld de,0e751h		;621e
	push de			;6221
	ld bc,000a0h		;6222   ; 160 bytes (5 sprites)
	push bc			;6225
	call espejo_sprites		;6226   ; los bits al reves y las mitades cambiadas
	pop bc			;6229
	pop hl			;622a
	ld de,01c00h		;622b   ; a 0x1C00
	jp 0005ch		;622e

; ----------------------------------------------------------------------
; DATOS prota_dibujos_tabla: Los cinco dibujos del protagonista que se cargan
;   (0x61FE)
;   0x6231..0x623b  (10 bytes)
DATA_prota_dibujos_tabla:
	defw 063c9h,0660ah,0666eh,066cbh,06721h	; 6231

; ======================================================================
; CODIGO 0x623b..0x62f1  (182 bytes)
; ======================================================================


prota_dibujo_otro:		; Otro dibujo: 20 bloques de 0x66CB (o 0x6721), cada fila leida hacia atras (volteado), y su espejo
	ld hl,066cbh		;623b   ; uno...
	jr z,prota_dibujo_otro_va		;623e
	ld hl,06721h		;6240   ; ...u otro
prota_dibujo_otro_va:
	ld b,014h		;6243
	call desempaqueta		;6245   ; desempaquetado
	push hl			;6248
	ld hl,01800h		;6249   ; a 0x1800
	call 00053h		;624c
	ld hl,0e6c1h		;624f   ; volteado
	call volteado_vram		;6252
	pop hl			;6255
	ld de,0e751h		;6256   ; su espejo
	ld bc,000a0h		;6259
	push de			;625c
	call espejo_sprites		;625d
	pop hl			;6260
	ld hl,01c00h		;6261   ; a 0x1C00
	call 00053h		;6264
	ld hl,0e761h		;6267
volteado_vram:		; 10 sprites de 16 bytes leidos hacia atras (volteados) a la VRAM
	ld de,00020h		;626a
	ld c,00ah		;626d   ; 10
volteado_vram_uno:
	ld b,010h		;626f
	call vram_b_atras		;6271   ; 16 hacia atras
	add hl,de			;6274   ; el siguiente (+32)
	dec c			;6275
	jr nz,volteado_vram_uno		;6276
	ret			;6278
prota_pinta:		; El protagonista en los sprites: su Y (fila x 8 + 0xEAE1) y su X (columna - la vista, x 8); los cinco sprites del dibujo segun su estado (andando, de pie, en la escalera...) y hacia donde mira
	call prota_sprite		;6279   ; el dibujo cargado
	ld a,(0eaddh)		;627c   ; la fila...
	add a,a			;627f   ; ...x 8...
	add a,a			;6280
	add a,a			;6281
	ld c,a			;6282
	ld a,(0eae1h)		;6283   ; ...+ 0xEAE1
	add a,c			;6286
	ld (0eb09h),a		;6287   ; la Y
	ld c,000h		;628a
	ld a,(0ead1h)		;628c   ; la columna de la vista
	ld b,a			;628f
	ld a,(0eadch)		;6290   ; la del protagonista...
	sub b			;6293   ; ...menos ella...
	add a,c			;6294
	add a,a			;6295   ; ...x 8
	add a,a			;6296
	add a,a			;6297
	ld (0eb08h),a		;6298   ; la X
	ld a,(0eae5h)		;629b   ; el dibujo
	cp 006h		;629e   ; 6 o mas: a 0x630F
	jr nc,$+111		;62a0
	cp 005h		;62a2   ; 5: la escalera
	jr z,prota_pinta_escalera		;62a4
	or a			;62a6   ; 0: andando
	jr nz,prota_pinta_otro		;62a7
	ld a,(0eb0ah)		;62a9   ; el paso (0xEB0A / 2, impar o par)
	rra			;62ac
	and 001h		;62ad
	jr prota_pinta_dibujo		;62af
prota_pinta_otro:
	inc a			;62b1
prota_pinta_dibujo:
	add a,a			;62b2   ; x 24: el dibujo
	add a,a			;62b3
	add a,a			;62b4
	ld c,a			;62b5
	add a,a			;62b6
	add a,c			;62b7
	ld c,a			;62b8
	ld a,(0eadeh)		;62b9   ; a la izquierda...
	and 080h		;62bc
	jr nz,prota_pinta_pon		;62be
	ld a,c			;62c0   ; ...a la derecha, + 0x80 (el espejo)
	add a,080h		;62c1
	ld c,a			;62c3
prota_pinta_pon:
	ld ix,062f1h		;62c4   ; los cinco sprites de 0x62F1
	call sprites_cinco		;62c8
	ld a,(0eae7h)		;62cb   ; y la espada (0x6371), si no 0xEAE7
	or a			;62ce
	call z,espada		;62cf
	jp prota_vram		;62d2
prota_pinta_escalera:		; En la escalera: uno u otro dibujo cada paso, 4 puntos a la derecha (0x6300)
	ld a,(0eb0ah)		;62d5   ; el paso
	rra			;62d8
	ld c,000h		;62d9
	jr nc,prota_pinta_escalera_va		;62db
	ld c,080h		;62dd   ; el espejo
prota_pinta_escalera_va:
	ld a,(0eb08h)		;62df
	add a,004h		;62e2   ; 4 a la derecha
	ld (0eb08h),a		;62e4
	ld ix,06300h		;62e7
	call sprites_cinco		;62eb
	jp prota_vram		;62ee

; ----------------------------------------------------------------------
; DATOS prota_sprites: Los cinco sprites del protagonista (dy, dibujo, color):
;   andando (0x62F1) y en la escalera (0x6300)
;   0x62f1..0x630f  (30 bytes)
DATA_prota_sprites:
	defb 000h,000h,00dh,008h,004h,004h,0f8h,008h,00eh,000h,00ch,00ah,010h,010h,003h,000h	; 62f1  ................
	defb 000h,00dh,008h,004h,004h,000h,008h,00eh,000h,00ch,00ah,010h,010h,003h	; 6301  ..............

; ======================================================================
; CODIGO 0x630f..0x6328  (25 bytes)
; ======================================================================


prota_pinta_raro:		; Los dibujos 6 o mas: 0x6328 o, desde el 9, 0x6337
	ld ix,06328h		;630f
	cp 009h		;6313
	jr c,prota_pinta_raro_va		;6315
	ld ix,06337h		;6317
prota_pinta_raro_va:
	ld a,(0eadeh)		;631b   ; hacia donde mira
	cpl			;631e
	and 080h		;631f
	ld c,a			;6321
	call sprites_cinco		;6322
	jp prota_vram		;6325

; ----------------------------------------------------------------------
; DATOS prota_sprites2: Los sprites de los dibujos 6-8 (0x6328) y 9 o mas
;   (0x6337)
;   0x6328..0x6346  (30 bytes)
DATA_prota_sprites2:
	defb 008h,000h,00dh,008h,004h,004h,000h,008h,00eh,008h,00ch,00ah,010h,010h,003h,008h	; 6328  ................
	defb 000h,00dh,008h,004h,004h,010h,008h,00eh,008h,00ch,00ah,000h,010h,003h	; 6338  ..............

; ======================================================================
; CODIGO 0x6346..0x63a6  (96 bytes)
; ======================================================================


sprites_cinco:		; Cinco sprites de IX (dy, dibujo, color) a 0xEB0B con la Y (0xEB09) y la X (0xEB08), el dibujo + C; y 0xD0 detras
	ld hl,0eb0bh		;6346   ; la tabla de la RAM
	ld a,(0eb08h)		;6349   ; la X
	ld e,a			;634c
	ld a,(0eb09h)		;634d   ; la Y
	ld d,a			;6350
	ld b,005h		;6351   ; cinco
sprites_cinco_uno:
	ld a,(ix+000h)		;6353   ; la Y + dy
	add a,d			;6356
	ld (hl),a			;6357
	inc hl			;6358
	inc ix		;6359
	ld (hl),e			;635b   ; la X
	inc hl			;635c
	ld a,(ix+000h)		;635d   ; el dibujo + C
	add a,c			;6360
	ld (hl),a			;6361
	inc hl			;6362
	inc ix		;6363
	ld a,(ix+000h)		;6365   ; el color
	ld (hl),a			;6368
	inc hl			;6369
	inc ix		;636a
	djnz sprites_cinco_uno		;636c
	ld (hl),0d0h		;636e   ; 0xD0: los demas fuera
	ret			;6370
espada:		; La espada: un sprite mas, donde dice la tabla 0x63A6 por el dibujo (al otro lado si mira a la izquierda), dibujo + 0x14, color 11
	ld b,000h		;6371
	ld a,(0eae5h)		;6373   ; el dibujo
	or a			;6376
	jr z,espada_sprite		;6377   ; 0: en su sitio
	push hl			;6379
	dec a			;637a
	add a,a			;637b
	ld hl,063a6h		;637c   ; la tabla
	add a,l			;637f
	ld l,a			;6380
	jr nc,espada_pon		;6381
	inc h			;6383
espada_pon:
	ld b,(hl)			;6384   ; dx
	inc hl			;6385
	ld a,(0eadeh)		;6386   ; a la izquierda?
	add a,a			;6389
	jr nc,espada_dy		;638a
	ld a,b			;638c   ; al reves
	neg		;638d
	ld b,a			;638f
espada_dy:
	ld a,(hl)			;6390
	pop hl			;6391
espada_sprite:
	add a,d			;6392   ; la Y
	add a,008h		;6393
	ld (hl),a			;6395
	inc hl			;6396
	ld a,e			;6397   ; la X
	add a,b			;6398
	ld (hl),a			;6399
	inc hl			;639a
	ld a,c			;639b   ; el dibujo
	add a,014h		;639c
	ld (hl),a			;639e
	inc hl			;639f   ; color 11
	ld (hl),00bh		;63a0
	inc hl			;63a2
	ld (hl),0d0h		;63a3   ; 0xD0
	ret			;63a5

; ----------------------------------------------------------------------
; DATOS espada_sitios: Donde va la espada en cada dibujo (dx, dy)
;   0x63a6..0x63ac  (6 bytes)
DATA_espada_sitios:
	defb 000h,0e8h,010h,0f0h,010h,000h	; 63a6

; ======================================================================
; CODIGO 0x63ac..0x63c9  (29 bytes)
; ======================================================================


prota_vram:		; Los seis sprites del protagonista (0xEB0B, 24 bytes) a 0x3B04; tocado (0xEAE1), algunos con 0xD1
	ld a,(0eae1h)		;63ac   ; tocado?
	or a			;63af
	jr z,prota_vram_va		;63b0
	ld a,0d1h		;63b2   ; 0xD1 en tres
	ld (0eb0fh),a		;63b4
	ld (0eb1bh),a		;63b7
	ld (0eb1fh),a		;63ba
prota_vram_va:
	ld hl,0eb0bh		;63bd   ; los seis...
	ld de,03b04h		;63c0   ; ...a 0x3B04
	ld bc,00018h		;63c3
	jp 0005ch		;63c6   ; LDIRVM

; ----------------------------------------------------------------------
; DATOS sprites_datos: Los dibujos de los sprites empaquetados: el
;   protagonista (0x63C9, 0x6501), el pajaro (0x64AA, 0x6721, 0x6775, 0x6877)
;   y otros (0x66CB)
;   0x63c9..0x6974  (1451 bytes)
DATA_sprites_datos:
	defb 0a9h,000h,006h,000h,038h,0fch,03ch,07eh,07bh,03ch,038h,000h,080h,000h,0efh,000h	; 63c9  ....8.<~{<8.....
	defb 07ch,0deh,03eh,07eh,07ch,078h,087h,000h,006h,01eh,03eh,0eeh,07ch,0fch,0f8h,078h	; 63d9  |.>~|x....>.|..x
	defb 030h,000h,08dh,000h,040h,000h,004h,0fch,08eh,042h,020h,03ch,01ch,000h,080h,000h	; 63e9  0...@....B <....
	defb 0eeh,003h,00fh,019h,01dh,008h,000h,080h,000h,0f7h,0e0h,0f0h,0f8h,0fch,07ch,018h	; 63f9  ..............|.
	defb 000h,08fh,000h,002h,003h,007h,0c7h,0e2h,0c3h,001h,000h,001h,083h,000h,0e0h,0f0h	; 6409  ................
	defb 0e2h,0e0h,080h,000h,080h,083h,000h,0b8h,0f8h,080h,000h,08fh,000h,003h,007h,016h	; 6419  ................
	defb 01ch,080h,000h,096h,000h,003h,001h,000h,080h,000h,08ah,000h,080h,000h,0f8h,070h	; 6429  ...............p
	defb 03ch,01eh,003h,000h,0a8h,000h,006h,000h,0b1h,000h,01bh,03fh,01eh,080h,000h,0edh	; 6439  <..........?....
	defb 000h,070h,0f0h,0b8h,01eh,01ch,081h,000h,001h,0e6h,007h,00fh,01fh,00eh,000h,08fh	; 6449  .p..............
	defb 000h,040h,060h,020h,000h,0feh,080h,0c0h,080h,060h,070h,0f0h,000h,080h,000h,0eeh	; 6459  .@` .....`p.....
	defb 003h,00fh,019h,01dh,008h,000h,080h,000h,0f7h,0e0h,0f0h,0f8h,0fch,07ch,018h,000h	; 6469  .............|..
	defb 08eh,000h,002h,003h,007h,0eah,003h,001h,000h,0c0h,000h,083h,000h,0e0h,0f0h,0e3h	; 6479  ................
	defb 0e0h,080h,000h,001h,003h,083h,000h,02eh,03eh,080h,000h,083h,000h,0b8h,0f8h,080h	; 6489  ........>.......
	defb 000h,080h,000h,080h,000h,087h,000h,080h,0c0h,0e0h,0fch,070h,038h,03ch,00eh,007h	; 6499  ...........p8<..
	defb 000h,0bfh,000h,066h,0e6h,0e0h,0f0h,0f8h,078h,0f8h,01ch,006h,007h,003h,000h,081h	; 64a9  ...f....x.......
	defb 000h,00ch,0feh,01eh,07fh,0ffh,09fh,01eh,01ch,000h,08fh,000h,003h,01fh,07fh,0ffh	; 64b9  ................
	defb 0f0h,0ffh,0fch,030h,000h,08fh,000h,080h,0e0h,0f8h,0fch,0aeh,07eh,03eh,01eh,00ch	; 64c9  ...0........~>..
	defb 000h,080h,000h,0eeh,003h,00fh,019h,01dh,008h,000h,080h,000h,0f7h,0e0h,0f0h,0f8h	; 64d9  ................
	defb 0fch,07ch,018h,000h,0aeh,060h,000h,002h,003h,007h,0e0h,003h,001h,000h,083h,000h	; 64e9  .|...`..........
	defb 0e0h,0f0h,0f4h,0e0h,080h,000h,060h,000h,09ch,000h,0b8h,0f8h,000h,080h,000h,083h	; 64f9  ......`.........
	defb 000h,02eh,03eh,080h,000h,09fh,000h,001h,003h,007h,00eh,01ch,0bbh,038h,030h,070h	; 6509  ..>..........80p
	defb 060h,040h,0e0h,09ch,000h,0c0h,080h,000h,080h,000h,0aeh,000h,006h,000h,030h,078h	; 6519  `@............0x
	defb 0e8h,07ch,03ah,003h,000h,081h,000h,00ch,0feh,01eh,07fh,0dfh,0bfh,03eh,00ch,000h	; 6529  .|:..........>..
	defb 08fh,000h,003h,00fh,03fh,07eh,0b8h,07eh,07ch,030h,000h,089h,000h,0c0h,0f8h,0d6h	; 6539  ....?~.~|0......
	defb 0fch,07eh,03eh,00ch,000h,080h,000h,0eeh,003h,00fh,019h,01dh,008h,000h,080h,000h	; 6549  .~>.............
	defb 0f7h,0e0h,0f0h,0f8h,0fch,07ch,018h,000h,08eh,000h,002h,003h,087h,0e0h,003h,001h	; 6559  .....|..........
	defb 000h,083h,000h,0e0h,0f0h,0e5h,0e0h,080h,000h,030h,000h,08eh,000h,0b8h,0f8h,000h	; 6569  .........0......
	defb 080h,000h,083h,000h,02eh,03eh,080h,000h,085h,000h,010h,018h,0fch,01ch,00eh,00fh	; 6579  .....>..........
	defb 007h,003h,000h,080h,000h,09fh,000h,0c0h,0f0h,0fdh,01fh,001h,0a8h,000h,006h,000h	; 6589  ................
	defb 0fdh,000h,00eh,01fh,03fh,07dh,03ch,038h,080h,000h,0ffh,000h,070h,0f8h,0feh,0dfh	; 6599  ....?}<8....p...
	defb 03fh,01fh,01eh,085h,000h,003h,007h,0ceh,00fh,01fh,01eh,00ch,000h,086h,000h,0c0h	; 65a9  ?...............
	defb 080h,0eeh,07ch,07eh,03fh,01fh,006h,000h,080h,000h,0eeh,003h,00fh,019h,01dh,008h	; 65b9  ..|~?...........
	defb 000h,080h,000h,0f7h,0e0h,0f0h,0f8h,0fch,07ch,018h,000h,08eh,000h,002h,003h,007h	; 65c9  ........|.......
	defb 0e5h,003h,001h,000h,0c0h,000h,083h,000h,0e0h,0f0h,0e2h,0e0h,080h,000h,060h,083h	; 65d9  ..............`.
	defb 000h,02eh,03eh,080h,000h,083h,000h,017h,01fh,080h,000h,080h,000h,0fch,000h,060h	; 65e9  ..>............`
	defb 03fh,01fh,007h,000h,08fh,000h,002h,001h,003h,006h,0fch,01ch,07ch,0f8h,0f0h,0c0h	; 65f9  ?...........|...
	defb 000h,080h,000h,0bfh,0e0h,0f0h,0f8h,07ah,01fh,00fh,006h,0bdh,000h,01eh,03fh,00fh	; 6609  .......z......?.
	defb 007h,006h,0ffh,004h,008h,018h,030h,060h,0c0h,080h,000h,080h,000h,0eeh,01fh,03eh	; 6619  ......0`.......>
	defb 0feh,07ch,030h,000h,09fh,000h,00eh,01fh,03fh,07fh,0dfh,0f0h,0dfh,01eh,00ch,000h	; 6629  .|0.....?.......
	defb 09ch,000h,003h,00fh,01fh,0f8h,01dh,01eh,00fh,007h,000h,09ch,000h,0c0h,0f0h,0f8h	; 6639  ................
	defb 0f8h,0f8h,0f0h,020h,0c0h,000h,082h,000h,060h,08ch,000h,001h,000h,0a0h,006h,000h	; 6649  ... ....`.......
	defb 08ch,000h,080h,000h,08fh,000h,080h,0c0h,078h,038h,080h,000h,0fch,000h,001h,003h	; 6659  ........x8......
	defb 01eh,01ch,000h,080h,000h,0bfh,000h,0f1h,0f9h,0f8h,07ch,00eh,000h,080h,000h,0a8h	; 6669  ..........|.....
	defb 000h,080h,000h,0fch,006h,09fh,07fh,01eh,00ch,000h,081h,000h,07eh,0feh,0ffh,0fdh	; 6679  ............~...
	defb 0fch,0f8h,078h,030h,000h,080h,000h,0bfh,000h,080h,060h,040h,048h,028h,000h,080h	; 6689  ..x0......`@H(..
	defb 000h,0eeh,000h,003h,006h,007h,002h,000h,080h,000h,0f7h,0f8h,0fch,07eh,07fh,01fh	; 6699  .............~..
	defb 003h,000h,0a2h,0c0h,000h,001h,080h,000h,08fh,000h,080h,0c0h,0f8h,0fch,0eah,0f8h	; 66a9  ................
	defb 060h,000h,030h,000h,083h,000h,0b8h,0f8h,080h,000h,08fh,000h,003h,007h,016h,01ch	; 66b9  `.0.............
	defb 080h,000h,0dfh,006h,00fh,037h,01bh,03dh,03fh,007h,080h,000h,0b5h,000h,080h,0c0h	; 66c9  .....7.=?.......
	defb 0e0h,0f0h,0b0h,078h,030h,000h,080h,000h,0edh,000h,00eh,00fh,01fh,03fh,01fh,080h	; 66d9  ...x0........?..
	defb 000h,0f7h,000h,004h,08eh,0feh,0fch,0f8h,0f0h,080h,000h,0dch,001h,000h,008h,004h	; 66e9  ................
	defb 000h,080h,000h,0f7h,0f0h,0f8h,07ch,03eh,01eh,00ch,000h,0feh,018h,010h,000h,040h	; 66f9  ......|>.......@
	defb 060h,002h,000h,080h,000h,083h,000h,010h,008h,080h,000h,0fch,030h,020h,030h,0f0h	; 6709  `...........0 0.
	defb 0a0h,0c0h,080h,000h,080h,000h,080h,000h,0a8h,000h,030h,000h,0f0h,000h,001h,003h	; 6719  ..........0.....
	defb 000h,0ffh,01ch,07ch,03ch,00ch,000h,01ch,03ch,07ch,0f0h,0fch,0d8h,080h,000h,080h	; 6729  ...|<...<|......
	defb 000h,0fch,060h,0f8h,0fch,0ffh,063h,000h,080h,000h,0f0h,000h,060h,0e0h,000h,080h	; 6739  ..`...c.....`...
	defb 000h,0eeh,01fh,07fh,0cfh,0efh,043h,000h,080h,000h,0f3h,000h,080h,0c0h,0e0h,0c0h	; 6749  ......C.........
	defb 000h,08eh,000h,010h,018h,03fh,0e0h,01fh,006h,000h,0a2h,003h,000h,003h,080h,000h	; 6759  .....?..........
	defb 08fh,000h,09ch,0fch,02eh,03eh,080h,000h,080h,000h,080h,000h,080h,000h,0ffh,000h	; 6769  .....>..........
	defb 001h,003h,007h,01fh,03bh,077h,0ffh,08fh,000h,001h,003h,00fh,03fh,0bfh,0ffh,0feh	; 6779  ....;w......?...
	defb 0ffh,0efh,0dfh,0feh,000h,0f9h,000h,001h,00fh,07fh,0ffh,0fdh,0ffh,0f7h,06fh,0ffh	; 6789  ..............o.
	defb 0fch,0e3h,09fh,07fh,01fh,0dbh,000h,0e0h,0f0h,0f8h,0fch,0feh,0f3h,0feh,0cfh,03fh	; 6799  ...............?
	defb 0ffh,0dfh,03fh,080h,000h,0bdh,000h,080h,0c0h,0e0h,0f0h,0f8h,080h,000h,080h,000h	; 67a9  ..?.............
	defb 0fch,03ch,00eh,00fh,000h,003h,000h,087h,000h,001h,003h,00fh,09fh,0ffh,0efh,09fh	; 67b9  .<..............
	defb 078h,0f7h,00fh,0fch,01fh,003h,007h,01fh,07fh,0ffh,0c7h,0fch,0ffh,0fch,0f3h,0cfh	; 67c9  x...............
	defb 0c0h,0bfh,0ffh,0beh,000h,0c0h,0f0h,0cfh,03fh,0ffh,081h,0ffh,0fdh,08fh,000h,0e0h	; 67d9  ........?.......
	defb 0fch,0feh,0cfh,0ffh,0cfh,0ffh,0f7h,0e2h,0e0h,0c3h,087h,0ffh,080h,000h,083h,000h	; 67e9  ................
	defb 0c0h,0f0h,081h,000h,030h,0f7h,030h,000h,008h,01ch,03ch,078h,000h,080h,000h,080h	; 67f9  ....0.0...<x....
	defb 000h,0ffh,03fh,077h,04fh,0ffh,0afh,078h,040h,000h,080h,000h,0bfh,0ffh,0f3h,0fdh	; 6809  ..?wO..x@.......
	defb 002h,00bh,008h,02ch,0e0h,030h,00ch,000h,08fh,0ffh,07fh,00eh,060h,038h,0d8h,080h	; 6819  ...,.0......`8..
	defb 070h,0e0h,000h,0ffh,0fbh,0f7h,0e3h,0c6h,001h,00fh,003h,007h,0ffh,003h,00fh,003h	; 6829  p...............
	defb 01eh,009h,077h,03eh,0f0h,0ffh,0ffh,0efh,09fh,07fh,0ffh,0dfh,03fh,0ffh,0feh,0ffh	; 6839  ..w>........?...
	defb 0beh,0fch,0f8h,0e0h,080h,000h,09fh,0feh,0fch,0c8h,0f0h,0e0h,0c0h,080h,000h,0bfh	; 6849  ................
	defb 000h,00ch,002h,00dh,004h,016h,010h,0ffh,0cch,0f0h,0bch,029h,05bh,007h,004h,001h	; 6859  ...........)[...
	defb 087h,000h,070h,01ch,040h,0ffh,070h,080h,060h,000h,0c0h,090h,0b0h,080h,0ffh,0ffh	; 6869  ..p.@.p.`.......
	defb 07fh,01fh,03fh,003h,00fh,000h,001h,080h,000h,0f9h,0f8h,0ffh,0e7h,01fh,0ffh,0fch	; 6879  ..?.............
	defb 0ffh,073h,01fh,07fh,007h,01fh,000h,003h,000h,0c3h,000h,0ffh,0cfh,03fh,09fh,0ffh	; 6889  .s...........?..
	defb 0e7h,09fh,07eh,0fdh,003h,0beh,000h,0c0h,0f0h,0fch,0feh,0ffh,087h,0ffh,07fh,0ffh	; 6899  ..~.............
	defb 0e7h,081h,000h,0c0h,0e0h,0f0h,0feh,0ffh,080h,000h,097h,000h,080h,0c0h,0e0h,0f0h	; 68a9  ................
	defb 0f0h,01fh,000h,007h,000h,087h,000h,001h,003h,00fh,0ffh,03fh,0ffh,0c7h,03fh,0ffh	; 68b9  ...........?..?.
	defb 018h,037h,00fh,0fch,01fh,004h,00fh,01fh,07fh,0ffh,08fh,0ffh,03fh,0fch,0f3h,0cfh	; 68c9  .7..........?...
	defb 0c0h,03fh,0ffh,0feh,0f0h,0f8h,0fch,0feh,0c3h,03fh,0ffh,081h,0ffh,0feh,08fh,000h	; 68d9  .?.......?......
	defb 0e0h,0fch,0feh,0cfh,0ffh,0cfh,0ffh,0feh,0e2h,0e0h,0c0h,080h,0fch,080h,000h,080h	; 68e9  ................
	defb 000h,081h,000h,030h,0f7h,030h,000h,008h,01ch,03ch,078h,000h,080h,000h,080h,000h	; 68f9  ...0.0...<x.....
	defb 0ffh,03fh,06fh,05fh,0b7h,0efh,078h,040h,000h,080h,000h,0bfh,0ffh,0c3h,0fdh,002h	; 6909  .?o_..x@........
	defb 00bh,008h,02ch,0e0h,030h,00ch,000h,08fh,0ffh,07fh,00eh,060h,038h,0f8h,080h,070h	; 6919  ..,.0......`8..p
	defb 080h,0e0h,000h,0ffh,0fdh,0f3h,0cfh,0bbh,067h,01eh,03dh,003h,0f0h,00eh,001h,003h	; 6929  ........g.=.....
	defb 000h,086h,0ffh,03fh,0ffh,0feh,06fh,0deh,0f9h,017h,07fh,003h,000h,0fah,000h,080h	; 6939  ...?..o.........
	defb 0e0h,0f0h,0f8h,0fch,0bfh,0fch,0feh,03eh,0feh,0ffh,01fh,003h,0bfh,000h,00ch,002h	; 6949  .......>........
	defb 00dh,004h,016h,010h,0ffh,0cch,0f0h,0bch,029h,05bh,007h,004h,001h,087h,000h,070h	; 6959  ........)[.....p
	defb 01ch,040h,0ffh,070h,080h,060h,000h,0f0h,090h,0b0h,080h	; 6969  .@.p.`.....

; ======================================================================
; CODIGO 0x6974..0x697d  (9 bytes)
; ======================================================================


enemigos:		; Cada cuadro: los enemigos segun su estado (0xEB26, la tabla 0x697D: 1 ponerlos, 2 moverlos)
	ld hl,0eb26h		;6974   ; el estado
	ld de,0697dh		;6977   ; la tabla
	jp estado_salta		;697a

; ----------------------------------------------------------------------
; DATOS tabla_enemigos: Los dos estados de los enemigos (0xEB26)
;   0x697d..0x6981  (4 bytes)
DATA_tabla_enemigos:
	defw 06981h,06ad2h	; 697d  -> enemigos_pon enemigos_mueve

; ======================================================================
; CODIGO 0x6981..0x69fc  (123 bytes)
; ======================================================================


enemigos_pon:		; Los enemigos al empezar la isla: todo a cero (0xEB32, 54 bytes), lo de la vuelta y la isla (0x6A17), sus dibujos (19 bloques de 0x72B2 en la casilla 0xEC, 8 de 0x731B en la 0x90 con espejos) y sus colores; 0xEBE2 = 10 y 0xEB64-0xEB65 = 0x4C, 0x3D
	xor a			;6981   ; 0xEB26 a 0
	ld (0eb26h),a		;6982
	ld (0eb6ch),a		;6985
	ld (0ebfah),a		;6988
	ld (0ec0ch),a		;698b
	ld (0ebe3h),a		;698e
	ld hl,0eb32h		;6991   ; los ocho de 0xEB32...
	ld bc,00036h		;6994   ; ...54 bytes...
	call llena		;6997   ; ...a cero
	call vuelta_datos		;699a   ; lo de la vuelta y la isla
	call enemigos_dibujos		;699d
	call cosas_dibujos		;69a0
	ld hl,072b2h		;69a3   ; 19 bloques...
	ld de,00760h		;69a6   ; ...a la casilla 0xEC
	ld b,013h		;69a9
	call desempaqueta_tercios		;69ab
	ld hl,0731bh		;69ae   ; 8 bloques a la casilla 0x90
	ld de,00480h		;69b1
	ld b,008h		;69b4
	call desempaqueta_tercios		;69b6
	ld hl,004a0h		;69b9   ; cuatro casillas...
	ld de,004c0h		;69bc   ; ...con su espejo
	push de			;69bf
	ld bc,00020h		;69c0
	call espejo_vram		;69c3
	pop hl			;69c6
	ld de,0e6a9h		;69c7   ; volteadas
	ld b,008h		;69ca
	call volteado_tercios		;69cc
	ld hl,004e0h		;69cf
	ld de,0e6c1h		;69d2
	ld b,010h		;69d5
	call volteado_tercios		;69d7
	ld hl,004f0h		;69da
	ld de,0e841h		;69dd
	ld b,010h		;69e0
	call volteado_tercios		;69e2
	ld hl,069fch		;69e5   ; los colores
	ld de,02480h		;69e8
	call ordenes_tercios		;69eb
	ld a,00ah		;69ee   ; 0xEBE2 = 10
	ld (0ebe2h),a		;69f0
	ld hl,0eb64h		;69f3
	ld (hl),04ch		;69f6
	inc hl			;69f8
	ld (hl),03dh		;69f9
	ret			;69fb

; ----------------------------------------------------------------------
; DATOS volteado_colores: Las ordenes de los colores de las casillas volteadas
;   (0x2480)
;   0x69fc..0x69ff  (3 bytes)
DATA_volteado_colores:
	defb 0a0h,080h,000h	; 69fc

; ======================================================================
; CODIGO 0x69ff..0x6a7a  (123 bytes)
; ======================================================================


volteado_tercios:		; B bytes de DE, hacia atras, a la VRAM HL en los tres tercios
	ld a,003h		;69ff   ; tres
volteado_tercio:
	push af			;6a01
	call 00053h		;6a02   ; SETWRT
	push bc			;6a05
	push de			;6a06
	ex de,hl			;6a07
	call vram_b_atras		;6a08   ; hacia atras
	ex de,hl			;6a0b
	pop de			;6a0c
	pop bc			;6a0d
	ld a,008h		;6a0e   ; el tercio siguiente (+0x800)
	add a,h			;6a10
	ld h,a			;6a11
	pop af			;6a12
	dec a			;6a13
	jr nz,volteado_tercio		;6a14
	ret			;6a16
vuelta_datos:		; Lo de la vuelta (0xE003: la 1, la 2 y luego 3 y 4 alternas): 8 bytes de 0x6A7A a 0xEB2A; y lo de la isla en la vuelta (0x6A9A, dos bytes): cuantos (0xEB68, 0xEB69) y dos bits (0xEB6A, 0xEB6B)
	ld a,(0e003h)		;6a17   ; la vuelta
	dec a			;6a1a
	cp 002h		;6a1b   ; la 1 o la 2...
	jr c,vuelta_datos_va		;6a1d
	and 001h		;6a1f   ; ...si no, 3 o 4
	add a,002h		;6a21
vuelta_datos_va:
	add a,a			;6a23   ; x 8
	add a,a			;6a24
	add a,a			;6a25
	ld e,a			;6a26
	ld d,000h		;6a27
	ld hl,06a7ah		;6a29   ; la tabla
	add hl,de			;6a2c
	ld de,0eb2ah		;6a2d   ; a 0xEB2A
	ld bc,00008h		;6a30
	ldir		;6a33
	ld a,(0e003h)		;6a35   ; la vuelta otra vez
	dec a			;6a38
	cp 002h		;6a39
	jr c,vuelta_isla		;6a3b
	and 001h		;6a3d
	add a,002h		;6a3f
vuelta_isla:
	ld l,a			;6a41   ; x 7...
	add a,a			;6a42
	ld h,a			;6a43
	add a,a			;6a44
	add a,h			;6a45
	add a,l			;6a46
	ld l,a			;6a47
	ld a,(0e002h)		;6a48   ; ...+ la isla - 1
	dec a			;6a4b
	add a,l			;6a4c
	ld l,a			;6a4d
	ld h,000h		;6a4e
	add hl,hl			;6a50   ; x 2
	ld de,06a9ah		;6a51   ; la tabla
	add hl,de			;6a54
	ld a,(hl)			;6a55   ; la mitad alta...
	call mitad_alta		;6a56
	and 00fh		;6a59
	ld (0eb68h),a		;6a5b   ; ...a 0xEB68
	ld a,(hl)			;6a5e   ; la baja a 0xEB69
	and 00fh		;6a5f
	ld (0eb69h),a		;6a61
	inc hl			;6a64
	ld a,(hl)			;6a65   ; los bits 6-7
	and 0c0h		;6a66
	rla			;6a68
	rla			;6a69
	ld (0eb6ah),a		;6a6a   ; a 0xEB6A
	rla			;6a6d
	and 001h		;6a6e
	ld (0eb6bh),a		;6a70   ; y 0xEB6B
	call grande_dibujos		;6a73   ; 0x6E71
	call grande2_dibujos		;6a76   ; 0x71A9
	ret			;6a79

; ----------------------------------------------------------------------
; DATOS vueltas_datos: Lo de cada vuelta (0x6A7A: 4 x 8 bytes) y de cada isla
;   en cada vuelta (0x6A9A: 4 x 7 x 2 bytes)
;   0x6a7a..0x6ad2  (88 bytes)
DATA_vueltas_datos:
	defb 011h,0e0h,010h,0e0h,00fh,0e0h,011h,0e0h,012h,0e0h,010h,0e0h,00fh,0e0h,012h,0e0h	; 6a7a  ................
	defb 012h,0e0h,011h,0e0h,010h,0e0h,013h,0e0h,013h,0e0h,011h,0e0h,010h,0e0h,014h,0e0h	; 6a8a  ................
	defb 022h,090h,022h,090h,023h,050h,022h,050h,023h,090h,022h,050h,032h,050h,022h,090h	; 6a9a  ".".#P"P#."P2P".
	defb 022h,090h,022h,090h,032h,050h,031h,040h,032h,050h,032h,080h,031h,050h,022h,050h	; 6aaa  ".".2P1@2P2.1P"P
	defb 032h,080h,032h,040h,023h,090h,032h,040h,021h,090h,032h,090h,031h,040h,032h,090h	; 6aba  2.2@#.2@!.2.1@2.
	defb 031h,050h,032h,040h,031h,090h,031h,090h	; 6aca  1P2@1.1.

; ======================================================================
; CODIGO 0x6ad2..0x6bbb  (233 bytes)
; ======================================================================


enemigos_mueve:		; El estado 2: los enemigos se mueven: los de 0xEB4A (con la clase 0x6D7F), los de 0xEB38 (0x6C92), el grande de 0xEB5C o 0xEB62 (0x7173) y las cosas de 0xEB32 (0x6D88); 0x767B mueve a cada uno con su clase
	ld a,(0eb28h)		;6ad2   ; el primer cuadro?
	or a			;6ad5
	jr nz,enemigos_mueve_va		;6ad6
	inc a			;6ad8
	ld (0eb28h),a		;6ad9
	call tiro_borra		;6adc   ; 0x790A
enemigos_mueve_va:
	call tiro		;6adf   ; 0x791D
	ld hl,0ebfdh		;6ae2   ; las cuentas
	inc (hl)			;6ae5
	ld hl,0eb6ch		;6ae6
	inc (hl)			;6ae9
	ld hl,0ebe3h		;6aea
	inc (hl)			;6aed
	xor a			;6aee
	ld (0ebf6h),a		;6aef
	ld ix,0eb4ah		;6af2   ; los tres de 0xEB4A...
	ld iy,06d7fh		;6af6   ; ...con la clase 0x6D7F
	ld hl,(0eb2ch)		;6afa   ; cual se queda (0xEB2C)
	ld a,(hl)			;6afd
	inc a			;6afe
	ld c,a			;6aff
	ld b,003h		;6b00   ; tres
enemigos_tres:
	push bc			;6b02
	ld a,c			;6b03
	cp b			;6b04   ; el que se queda?
	jr nz,enemigos_tres_mueve		;6b05
	ld (0ebaeh),ix		;6b07   ; apuntado
	jr enemigos_tres_sig		;6b0b
enemigos_tres_mueve:
	call pinta_objeto		;6b0d   ; se mueve
enemigos_tres_sig:
	ld bc,00006h		;6b10   ; el siguiente (+6)
	add ix,bc		;6b13
	pop bc			;6b15
	djnz enemigos_tres		;6b16
	ld a,c			;6b18   ; alguno se queda?
	cp 004h		;6b19
	jr nc,enemigos_otros		;6b1b
	ld ix,(0ebaeh)		;6b1d   ; el que se queda
	ld hl,06d18h		;6b21   ; 3 bytes de 0x6D18...
	ld bc,00003h		;6b24
	ld a,(0e001h)		;6b27   ; ...o de 0x6D1B con la isla abierta
	and 003h		;6b2a
	jr nz,enemigos_tres_queda		;6b2c
	add hl,bc			;6b2e
enemigos_tres_queda:
	ld de,0ec06h		;6b2f   ; a 0xEC06
	ldir		;6b32
	call enemigo_queda		;6b34   ; 0x6D1E
	ld iy,06d7fh		;6b37
	call pinta_objeto		;6b3b   ; se mueve
enemigos_otros:		; Los tres de 0xEB38 con la clase 0x6C92
	ld ix,0eb38h		;6b3e
	ld iy,06c92h		;6b42
	ld hl,(0eb2ah)		;6b46   ; cual se queda (0xEB2A)
	ld a,(hl)			;6b49
	inc a			;6b4a
	ld c,a			;6b4b
	ld b,003h		;6b4c
enemigos_otros_uno:
	push bc			;6b4e
	ld a,c			;6b4f   ; el que se queda?
	cp b			;6b50
	call nz,pinta_objeto		;6b51   ; se mueve
	ld bc,00006h		;6b54   ; el siguiente (+6)
	add ix,bc		;6b57
	pop bc			;6b59
	djnz enemigos_otros_uno		;6b5a   ; uno menos
	ld a,c			;6b5c   ; alguno se queda?
	cp 004h		;6b5d
	jr nc,enemigo_grande		;6b5f
	ld ix,0eb38h		;6b61   ; el que se queda: 0xEB38...
	ld a,003h		;6b65   ; ...+ (3 - C)...
	sub c			;6b67
	add a,a			;6b68   ; ...x 6
	ld c,a			;6b69
	add a,a			;6b6a
	add a,c			;6b6b
	ld c,a			;6b6c
	add ix,bc		;6b6d
	call enemigo_cae		;6b6f   ; cae o anda
	ld iy,06c92h		;6b72
	call pinta_objeto		;6b76
enemigo_grande:		; El grande: 0xEB5C o, con 0xEB6B, 0xEB62
	ld iy,07173h		;6b79   ; la clase 0x7173
	ld a,(0eb6bh)		;6b7d   ; 0xEB6B?
	or a			;6b80
	jr nz,enemigo_grande2		;6b81
	ld ix,0eb5ch		;6b83   ; 0xEB5C
	ld a,(0e00eh)		;6b87   ; 0xE00E?
	or a			;6b8a
	call z,grande		;6b8b
	call pinta_objeto		;6b8e   ; se mueve
	jr cosas_mueve		;6b91
enemigo_grande2:
	ld ix,0eb62h		;6b93   ; 0xEB62
	ld hl,(0eb2eh)		;6b97
	ld a,(hl)			;6b9a
	cp 003h		;6b9b
	call z,grande		;6b9d
	call pinta_objeto		;6ba0
cosas_mueve:
	ld a,0ffh		;6ba3   ; 0xEBF6 = 0xFF
	ld (0ebf6h),a		;6ba5
	ld ix,0eb32h		;6ba8   ; las cosas
	ld hl,0e010h		;6bac   ; cada tanto...
	ld a,(hl)			;6baf
	or a			;6bb0
	call z,cosa		;6bb1   ; ...una nueva
	ld iy,06d88h		;6bb4   ; la clase 0x6D88
	jp pinta_objeto		;6bb8

; ----------------------------------------------------------------------
; DATOS sin_puntero: Seis bytes sin ningun puntero en la ROM (07 00 05 05 00
;   03); parecen la cola de una clase de objeto
;   0x6bbb..0x6bc1  (6 bytes)
DATA_sin_puntero:
	defb 007h,000h,005h,005h,000h,003h	; 6bbb

; ======================================================================
; CODIGO 0x6bc1..0x6c92  (209 bytes)
; ======================================================================


enemigo_cae:		; Un enemigo de 0xEB38: con el estado 0xFF cae (0x7583) y se mueve de lado; si no puede, desaparece
	ld a,(ix+000h)		;6bc1   ; 0xFF?
	inc a			;6bc4
	jr nz,enemigo_sale		;6bc5
	call casilla_enemigo		;6bc7   ; cae
	bit 6,(ix+002h)		;6bca   ; hacia donde?
	jr z,enemigo_cae_izq		;6bce
	inc (ix+003h)		;6bd0   ; a la derecha
	jr enemigo_cae_mira		;6bd3
enemigo_cae_izq:
	dec (ix+003h)		;6bd5   ; a la izquierda
enemigo_cae_mira:
	ld c,002h		;6bd8
	call hueco_borde		;6bda   ; el suelo?
	inc a			;6bdd
	jr z,enemigo_quita		;6bde
	call enemigo_puede		;6be0   ; 0x7356
	ld a,(ix+000h)		;6be3
	and 0c0h		;6be6
	ret nz			;6be8
enemigo_quita:
	ld (ix+000h),000h		;6be9   ; fuera
	ret			;6bed
enemigo_sale:		; Con el estado 1: sale si quedan (0xEB68) y si el protagonista esta arriba
	dec a			;6bee
	ret nz			;6bef
	ld a,(0eb68h)		;6bf0   ; cuantos
	ld b,a			;6bf3
	ld hl,(0eb2ah)		;6bf4
	ld a,(hl)			;6bf7
	cp b			;6bf8
	ret nc			;6bf9
	ld a,(0eaddh)		;6bfa   ; la fila del protagonista
	cp 00fh		;6bfd   ; abajo (fila 15 o mas)?
	jr nc,enemigo_sale_abajo		;6bff
	cp 008h		;6c01   ; en medio (8 o mas)?
	jr nc,enemigo_sale_medio		;6c03
	ld a,005h		;6c05   ; arriba: fila 5, por el primer hueco (0xEABB)
	ld hl,0eabbh		;6c07
	jr enemigo_sale_pon		;6c0a
enemigo_sale_medio:
	ld a,00ch		;6c0c   ; en medio: fila 12
	ld hl,07581h		;6c0e
	jr enemigo_sale_pon		;6c11
enemigo_sale_abajo:
	ld a,013h		;6c13   ; abajo: fila 19, por el segundo hueco (0xEABD)
	ld hl,0eabdh		;6c15
enemigo_sale_pon:
	ld (ix+002h),a		;6c18   ; la fila
	ld de,0eb6dh		;6c1b   ; uno y otro...
	ld a,(de)			;6c1e
	inc a			;6c1f
	ld (de),a			;6c20
	rra			;6c21   ; ...por un lado o por el otro
	ld a,(hl)			;6c22
	jr c,enemigo_sale_der		;6c23
	dec a			;6c25   ; por la izquierda del hueco...
	set 6,(ix+002h)		;6c26   ; ...hacia la derecha
	jr enemigo_sale_col		;6c2a
enemigo_sale_der:
	inc hl			;6c2c   ; por la derecha...
	add a,(hl)			;6c2d
	dec a			;6c2e
	dec a			;6c2f
	res 6,(ix+002h)		;6c30   ; ...hacia la izquierda
enemigo_sale_col:
	ld (ix+003h),a		;6c34   ; la columna
	ld a,(ix+002h)		;6c37
	call casilla_enemigo		;6c3a   ; su casilla
	ld hl,(0ebf4h)		;6c3d   ; la de debajo (+0x80: dos filas)
	ld de,00080h		;6c40
	add hl,de			;6c43
	ld a,(hl)			;6c44   ; hay suelo?
	cp 080h		;6c45
	ret nc			;6c47
	inc hl			;6c48
	ld a,(hl)			;6c49
	cp 080h		;6c4a
	ret nc			;6c4c
	ld (ix+000h),0ffh		;6c4d   ; sale: 0xFF
	ld (ix+001h),000h		;6c51
	ret			;6c55
enemigos_dibujos:		; Los dibujos de unos enemigos: 8 bloques de 0x6CBD a la casilla 0x80 y a la 0x90, con sus espejos en la 0x88 y la 0x98, y sus colores (0x6CF5)
	ld hl,06cbdh		;6c56   ; 8 bloques...
	ld de,00400h		;6c59   ; ...a la casilla 0x80
	push de			;6c5c
	ld b,008h		;6c5d
	call desempaqueta_tercios		;6c5f
	pop hl			;6c62
	ld de,00440h		;6c63
	ld bc,00040h		;6c66   ; su espejo en la 0x88
	push bc			;6c69
	call espejo_vram		;6c6a
	ld hl,06cbdh		;6c6d   ; otra vez...
	ld de,00480h		;6c70   ; ...a la 0x90
	push de			;6c73
	ld b,008h		;6c74
	call desempaqueta_tercios		;6c76
	pop hl			;6c79
	ld de,004c0h		;6c7a
	pop bc			;6c7d
	call espejo_vram		;6c7e   ; su espejo en la 0x98
	ld hl,06cf5h		;6c81   ; sus colores
	ld de,02400h		;6c84
	push hl			;6c87
	call ordenes_tercios		;6c88
	pop hl			;6c8b
	ld de,02440h		;6c8c
	jp ordenes_tercios		;6c8f

; ----------------------------------------------------------------------
; DATOS enemigos_clase1: La clase de los enemigos de 0xEB38 (0x6C92: sus
;   dibujos y movimientos), las casillas de 0x6C56 (0x6CBD), sus colores
;   (0x6CF5) y los 3 + 3 bytes de 0x6D18
;   0x6c92..0x6d1e  (140 bytes)
DATA_enemigos_clase1:
	defb 099h,06ch,0b9h,06ch,001h,004h,002h,080h,081h,082h,083h,084h,085h,086h,087h,089h	; 6c92  .l.l............
	defb 088h,08bh,08ah,08dh,08ch,08fh,08eh,090h,091h,092h,093h,094h,095h,096h,097h,099h	; 6ca2  ................
	defb 098h,09bh,09ah,09dh,09ch,09fh,09eh,0ech,0edh,0eeh,0efh,0feh,007h,00fh,03ch,07ch	; 6cb2  ..............<|
	defb 01fh,010h,01fh,0efh,01fh,00fh,007h,03fh,047h,083h,000h,086h,01fh,07fh,0ffh,09fh	; 6cc2  .......?G.......
	defb 0ffh,07fh,041h,043h,047h,04fh,0ffh,007h,00fh,03ch,07ch,01fh,010h,01fh,0dfh,0eeh	; 6cd2  ..ACGO...<|.....
	defb 0e0h,0f0h,0f8h,0c0h,0b8h,07ch,0bfh,0ffh,001h,00fh,017h,073h,0f9h,0fdh,0c6h,07ch	; 6ce2  .....|.....s...|
	defb 0feh,0fch,0feh,0a0h,007h,04ah,001h,00ah,008h,04ah,002h,00ah,001h,040h,005h,0a0h	; 6cf2  .....J...J...@..
	defb 003h,004h,005h,0a0h,00dh,040h,002h,04ah,001h,0a0h,002h,040h,006h,04ah,001h,00ah	; 6d02  .....@.J...@.J..
	defb 001h,04ah,002h,040h,004h,000h,004h,000h,003h,000h,000h,002h	; 6d12  .J.@........

; ======================================================================
; CODIGO 0x6d1e..0x6d68  (74 bytes)
; ======================================================================


enemigo_queda:		; El enemigo que se queda: anda de lado (0x7583, 0x78A4) y da la vuelta donde no puede seguir (0x7356, A = 2)
	ld a,(ix+000h)		;6d1e   ; 0xFF?
	inc a			;6d21
	jp nz,enemigo_queda_sale		;6d22
	ld a,(ix+001h)		;6d25   ; parado?
	or a			;6d28
	ret nz			;6d29
	call casilla_enemigo		;6d2a   ; cae
	call queda_huye		;6d2d   ; 0x78A4
	bit 6,(ix+002h)		;6d30   ; hacia donde?
	jr z,enemigo_queda_izq		;6d34
	inc (ix+003h)		;6d36   ; a la derecha
	call enemigo_puede		;6d39   ; puede?
	ret c			;6d3c
	cp 002h		;6d3d   ; 2: la vuelta
	ret nz			;6d3f
	dec (ix+003h)		;6d40
	res 6,(ix+002h)		;6d43
	ret			;6d47
enemigo_queda_izq:
	dec (ix+003h)		;6d48   ; a la izquierda
	call enemigo_puede		;6d4b   ; puede?
	ret c			;6d4e
	cp 002h		;6d4f   ; 2: la vuelta
	ret nz			;6d51
	inc (ix+003h)		;6d52
	set 6,(ix+002h)		;6d55
	ret			;6d59
enemigo_queda_sale:		; Si quedan (0xEB69), sale otro (0x7482)
	ld a,(0eb69h)		;6d5a   ; cuantos quedan por salir
	ld b,a			;6d5d
	ld hl,(0eb2ch)		;6d5e   ; los que hay
	ld a,(hl)			;6d61
	cp b			;6d62   ; todos?
	ret nc			;6d63
	call enemigo_nuevo		;6d64   ; sale otro
	ret			;6d67

; ----------------------------------------------------------------------
; DATOS copia_suelta: Codigo que nada llama (ningun puntero ni salto en la
;   ROM, sin ejecutar en la cobertura): desde 0x6D6A copia 3 filas de 2
;   casillas (DE en filas de 64) y desde 0x6D7B, 2 filas; como tres_por_tres
;   (0x4F67) pero de dos de ancho
;   0x6d68..0x6d7f  (23 bytes)
DATA_copia_suelta:
	defb 001h,03eh,03eh,003h,001h,002h,000h,0edh,0b0h,0ebh,001h,03eh,000h,009h,0ebh,03dh	; 6d68  .>>........>...=
	defb 020h,0f2h,0c9h,03eh,002h,018h,0edh	; 6d78

; ----------------------------------------------------------------------
; DATOS enemigos_clases: Las clases de los enemigos de 0xEB4A (0x6D7F) y de
;   las cosas de 0xEB32 (0x6D88)
;   0x6d7f..0x6dc7  (72 bytes)
DATA_enemigos_clases:
	defb 091h,06dh,0c1h,06dh,000h,006h,002h,005h,078h,0a9h,06dh,0c1h,06dh,000h,006h,002h	; 6d7f  .m.m....x.m.m...
	defb 005h,078h,0a0h,0a1h,0a2h,0a3h,0a4h,0a5h,0a0h,0a1h,0a6h,0a7h,0a8h,0a9h,0abh,0aah	; 6d8f  .x..............
	defb 0adh,0ach,0afh,0aeh,0abh,0aah,0b1h,0b0h,0b3h,0b2h,0b4h,0b5h,0b6h,0b7h,0b8h,0b9h	; 6d9f  ................
	defb 0b4h,0b5h,0bah,0bbh,0bch,0bdh,0bfh,0beh,0c1h,0c0h,0c3h,0c2h,0bfh,0beh,0c5h,0c4h	; 6daf  ................
	defb 0c7h,0c6h,0f0h,0f1h,0f2h,0f3h,0f4h,0f5h	; 6dbf  ........

; ======================================================================
; CODIGO 0x6dc7..0x6dfa  (51 bytes)
; ======================================================================


cosas_dibujos:		; Los dibujos de las cosas: 10 bloques de 0x6E06 a la casilla 0xA0 y a la 0xB4, con sus espejos (0xAA y 0xBE), y lo de 0x6DFA
	ld hl,06e06h		;6dc7   ; 10 bloques...
	ld de,00500h		;6dca   ; ...a la casilla 0xA0
	push de			;6dcd
	ld b,00ah		;6dce
	call desempaqueta_tercios		;6dd0
	pop hl			;6dd3
	ld de,00550h		;6dd4   ; su espejo en la 0xAA
	ld bc,00050h		;6dd7
	call espejo_vram		;6dda
	ld hl,06e06h		;6ddd   ; otra vez a la 0xB4
	ld de,005a0h		;6de0
	push de			;6de3
	ld b,00ah		;6de4
	call desempaqueta_tercios		;6de6
	pop hl			;6de9
	ld de,005f0h		;6dea   ; su espejo en la 0xBE
	ld bc,00050h		;6ded
	call espejo_vram		;6df0
	ld ix,06dfah		;6df3   ; 0x6DFA
	jp colores_dos		;6df7

; ----------------------------------------------------------------------
; DATOS cosas_datos: Lo de 0x781A para las cosas (0x6DFA) y sus casillas
;   empaquetadas (0x6E06)
;   0x6dfa..0x6e71  (119 bytes)
DATA_cosas_datos:
	defb 045h,06eh,000h,025h,050h,025h,05ah,06eh,0a0h,025h,0f0h,025h,0ffh,007h,00fh,01eh	; 6dfa  En.%P%Zn.%.%....
	defb 03ch,078h,0f8h,0c9h,0dfh,0e1h,0e0h,0f0h,0f8h,080h,0f9h,01fh,01eh,001h,0dfh,0ffh	; 6e0a  <x..............
	defb 000h,0dfh,078h,0fch,0fbh,0f3h,0e3h,083h,0fch,0fch,01fh,00fh,01fh,03eh,07ch,0f8h	; 6e1a  ..x..........>|.
	defb 0f2h,0f8h,084h,0bch,07ch,01eh,080h,01fh,0f9h,078h,0feh,0ffh,01fh,07fh,07eh,0eah	; 6e2a  ....|....x....~.
	defb 007h,03dh,07dh,03eh,01fh,0f8h,080h,0f0h,0f8h,0fch,0f8h,0a0h,010h,040h,002h,0a0h	; 6e3a  .=}>.........@..
	defb 009h,0a4h,004h,040h,011h,040h,003h,04ah,004h,040h,001h,0a0h,008h,040h,010h,000h	; 6e4a  ...@.@.J.@...@..
	defb 0a0h,010h,060h,002h,0a0h,009h,0a6h,004h,060h,011h,060h,003h,06ah,004h,060h,001h	; 6e5a  ..`.....`.`.j.`.
	defb 0a0h,008h,060h,010h,000h,001h,03dh	; 6e6a

; ======================================================================
; CODIGO 0x6e71..0x6eaa  (57 bytes)
; ======================================================================


grande_dibujos:		; Con 0xEB6A: los dibujos del enemigo grande (9 + 3 bloques de 0x6EB0 a la casilla 0xC8 y 0xD1, 6 de 0x6EEE a la 0xD4, y su espejo desde la 0xDA) y lo de 0x6EAA
	ld a,(0eb6ah)		;6e71   ; 0xEB6A?
	or a			;6e74
	ret z			;6e75
	ld hl,06eb0h		;6e76   ; 9 bloques...
	ld de,00640h		;6e79   ; ...a la casilla 0xC8
	ld b,009h		;6e7c
	call desempaqueta_tercios		;6e7e
	ld hl,06eb0h		;6e81   ; 3 a la 0xD1
	ld de,00688h		;6e84
	ld b,003h		;6e87
	call desempaqueta_tercios		;6e89
	ld hl,06eeeh		;6e8c   ; 6 de 0x6EEE a la 0xD4
	ld de,006a0h		;6e8f
	ld b,006h		;6e92
	call desempaqueta_tercios		;6e94
	ld hl,00640h		;6e97   ; su espejo...
	ld de,006d0h		;6e9a   ; ...desde la 0xDA
	ld bc,00090h		;6e9d
	call espejo_vram		;6ea0
	ld ix,06eaah		;6ea3   ; 0x6EAA
	jp colores_pon		;6ea7

; ----------------------------------------------------------------------
; DATOS grande_datos: Lo de 0x7829 para el grande (0x6EAA) y sus casillas
;   empaquetadas (0x6EB0, 0x6EEE)
;   0x6eaa..0x6f61  (183 bytes)
DATA_grande_datos:
	defb 01ah,06fh,040h,026h,0d0h,026h,08fh,000h,001h,00fh,01fh,007h,0ffh,008h,01ch,01ah	; 6eaa  .o@&.&..........
	defb 038h,0bdh,099h,0c3h,0ffh,08fh,000h,080h,0f0h,0f8h,0e0h,0f2h,001h,003h,01fh,03fh	; 6eba  8..............?
	defb 01fh,0ffh,0ffh,087h,0cfh,0dfh,07fh,0bfh,0deh,0e1h,0f3h,080h,0c0h,0f8h,0fch,0feh	; 6eca  ................
	defb 0b7h,0c1h,00dh,000h,001h,0e7h,0edh,0e1h,0ffh,0f8h,0f0h,0e0h,0feh,0c0h,0f8h,0feh	; 6eda  ................
	defb 0ffh,0eeh,080h,000h,0f6h,001h,003h,007h,00fh,01fh,03fh,0ffh,0ffh,087h,0cfh,0dfh	; 6eea  ..........?.....
	defb 07fh,0bfh,0dfh,0efh,0fah,080h,0c0h,0e0h,0f0h,0f8h,0fch,0b9h,03fh,01ah,003h,007h	; 6efa  ............?...
	defb 00fh,0f1h,0f0h,0f6h,0f0h,0ffh,0f6h,0ffh,07ch,03ch,0ach,080h,0c0h,0f0h,0fch,0bfh	; 6f0a  ........|<......
	defb 090h,00ch,094h,004h,090h,009h,0c0h,002h,0cah,002h,0c0h,003h,090h,001h,0cfh,003h	; 6f1a  ................
	defb 0c6h,004h,090h,001h,0c0h,002h,0cah,002h,0c0h,00ah,0a0h,001h,0c6h,002h,0cah,004h	; 6f2a  ................
	defb 0c0h,001h,0a0h,001h,0c0h,005h,0a0h,003h,090h,00ch,094h,004h,090h,009h,0c0h,005h	; 6f3a  ................
	defb 0cah,002h,090h,001h,0cfh,003h,0c6h,004h,090h,001h,0c0h,005h,0cah,002h,0c0h,007h	; 6f4a  ................
	defb 0a0h,001h,0c6h,003h,0c0h,00dh,000h	; 6f5a

; ======================================================================
; CODIGO 0x6f61..0x7173  (530 bytes)
; ======================================================================


grande:		; El enemigo grande: espera (0xEC0C); anda hacia el protagonista; si lo tiene en su fila o al lado, lo ataca (0x7A10); a veces (cada 120 cuadros, 0xEBE3) da un salto (bit 7); con la isla sin abrir, solo se mueve de lado
	ld a,(ix+000h)		;6f61   ; 0xFF?
	inc a			;6f64
	jp nz,grande_sale		;6f65
	ld a,(ix+001h)		;6f68   ; parado?
	or a			;6f6b
	ret nz			;6f6c
	ld hl,0ec0ch		;6f6d   ; la espera
	ld a,(hl)			;6f70
	or a			;6f71
	jr z,grande_mueve		;6f72
	dec (hl)			;6f74   ; un cuadro menos
	ret			;6f75
grande_mueve:
	call casilla_enemigo		;6f76   ; cae
	bit 7,(ix+002h)		;6f79   ; saltando?
	jp nz,grande_saltando		;6f7d
	ld a,(0eadch)		;6f80   ; la columna del protagonista...
	ld d,a			;6f83
	ld a,(ix+003h)		;6f84   ; ...menos la suya
	and 03fh		;6f87
	sub d			;6f89
	ld d,a			;6f8a
	ld a,(ix+002h)		;6f8b   ; la fila del protagonista...
	and 01fh		;6f8e
	ld e,a			;6f90
	ld a,(0eaddh)		;6f91   ; ...menos la suya
	sub e			;6f94
	ld e,a			;6f95
	ld a,(0e001h)		;6f96   ; la isla abierta?
	and 003h		;6f99
	jp nz,grande_cerrada		;6f9b
	ld a,(0eb29h)		;6f9e   ; 0xEB29: 3 o mas...
	cp 003h		;6fa1
	jp c,grande_cerrada		;6fa3
	cp 005h		;6fa6   ; ...salvo 5
	jp z,grande_cerrada		;6fa8
	ld a,d			;6fab   ; cerca (menos de 5)?
	cp 005h		;6fac
	jr c,grande_misma_fila		;6fae
	cp 009h		;6fb0   ; a 5-8?
	jr c,grande_cerca		;6fb2
	cp 0f8h		;6fb4   ; a -8..-5?
	jr c,grande_misma_fila		;6fb6
	cp 0fch		;6fb8
	jr c,grande_cerca		;6fba
grande_misma_fila:
	cp e			;6fbc   ; en su fila?
	jr z,grande_frente		;6fbd
	inc a			;6fbf   ; una abajo?
	cp e			;6fc0
	jr z,grande_frente		;6fc1
	neg		;6fc3   ; una arriba?
	cp e			;6fc5
	jr z,grande_frente		;6fc6
	inc a			;6fc8
	cp e			;6fc9
	jr z,grande_frente		;6fca
grande_salto:		; Cada 120 cuadros, un salto hacia el protagonista (bit 7 de +2, 0xEBE1 el lado)
	ld hl,0ebe3h		;6fcc   ; la cuenta
	ld a,(hl)			;6fcf
	cp 078h		;6fd0   ; 120?
	jr c,grande_anda		;6fd2
	xor a			;6fd4   ; otra vez
	ld (hl),a			;6fd5
	ld a,e			;6fd6   ; hacia arriba o abajo
	rla			;6fd7
	ccf			;6fd8
	sbc a,a			;6fd9
	or 001h		;6fda
	ld (0ebe1h),a		;6fdc
	set 7,(ix+002h)		;6fdf   ; salta
	ret			;6fe3
grande_anda:		; Un paso hacia su lado y 0x73C7
	bit 6,(ix+002h)		;6fe4   ; hacia donde?
	jr nz,grande_anda_der		;6fe8
	dec (ix+003h)		;6fea   ; a la izquierda
	jr grande_anda_fin		;6fed
grande_anda_der:
	inc (ix+003h)		;6fef   ; a la derecha
grande_anda_fin:
	jp grande_puede		;6ff2
grande_cerca:		; Cerca: si no hay pared (0x7462), hacia el protagonista; con 0xEB6A, ataca
	call misma_parte		;6ff5   ; pared?
	jr nz,grande_frente		;6ff8
	ld a,(0eb6ah)		;6ffa   ; 0xEB6A?
	or a			;6ffd
	jr nz,grande_ataca		;6ffe
	ld a,d			;7000
grande_lado:
	and 040h		;7001   ; el lado
	ld c,a			;7003
	ld a,(ix+002h)		;7004
	and 0bfh		;7007
	or c			;7009
	ld (ix+002h),a		;700a
	jr grande_anda		;700d
grande_ataca:
	ld a,e			;700f
	sub 003h		;7010
	ld e,a			;7012
	ld a,d			;7013
	jr nz,grande_misma_fila		;7014
	add a,a			;7016   ; el ataque
	sbc a,a			;7017
	and 003h		;7018
	xor 001h		;701a
	call tira		;701c   ; 0x7A10
	ld a,d			;701f
	cpl			;7020
	jr grande_lado		;7021
grande_frente:		; En su fila: si esta a 3 o mas, el ataque; si no, el salto
	ld a,d			;7023   ; a 3 o mas a la derecha?
	cp 003h		;7024
	jr c,grande_salto		;7026
	cp 0fdh		;7028   ; o a la izquierda?
	jr nc,grande_salto		;702a
	ld a,(0eb6ah)		;702c   ; 0xEB6A?
	or a			;702f
	jr z,grande_salto		;7030
grande_ataca2:
	ld a,e			;7032   ; hacia arriba o abajo...
	add a,a			;7033
	ccf			;7034
	sbc a,a			;7035
	and 00ch		;7036   ; ...los bits 2-3
	ld c,a			;7038
	ld a,d			;7039   ; hacia un lado...
	add a,a			;703a
	sbc a,a			;703b
	and 003h		;703c   ; ...los bits 0-1
	or c			;703e
	xor 005h		;703f   ; en diagonal hacia el protagonista
	call tira		;7041   ; tira
	jp grande_anda		;7044   ; y anda
grande_cerrada:		; Con la isla sin abrir: anda de lado, y cada 16 cuadros mira si ataca
	ld a,(0ebe0h)		;7047   ; la cuenta (0xEBE0)
	dec a			;704a
	jp p,grande_cerrada_cuenta		;704b
	call misma_parte		;704e   ; pared?
	jr nz,grande_salta_lado		;7051
	ld a,(0eb6ah)		;7053   ; 0xEB6A?
	or a			;7056
	jr z,grande_cerrada_lado		;7057
	ld a,e			;7059
	cp 003h		;705a   ; en la fila de 3?
	jr nz,grande_cerrada_mira		;705c
	ld a,d			;705e
	cp 008h		;705f
	jr c,grande_cerrada_ataca		;7061
	cp 0f8h		;7063
	jr c,grande_cerrada_lado		;7065
grande_cerrada_ataca:
	add a,a			;7067
	sbc a,a			;7068
	and 003h		;7069
	xor 001h		;706b
	call tira		;706d   ; 0x7A10
	ld a,d			;7070
	cpl			;7071
	and 040h		;7072
	ld c,a			;7074
	ld a,(ix+002h)		;7075
	and 0bfh		;7078
	or c			;707a
	ld (ix+002h),a		;707b
	ld a,010h		;707e   ; 16 cuadros
grande_cerrada_cuenta:
	ld (0ebe0h),a		;7080
	call misma_parte		;7083   ; pared?
	jr nz,grande_cerrada_anda		;7086
	call escalera_debajo		;7088   ; suelo?
	jr nz,grande_cerrada_anda		;708b
	ld a,(ix+003h)		;708d   ; tira algo: su columna...
	ld (ix+005h),a		;7090
	ld (ix+000h),037h		;7093   ; ...0x37...
	ld (ix+001h),080h		;7097   ; ...0x80
	ld a,003h		;709b   ; 3 cuadros de espera
	ld (0ec0ch),a		;709d
	ld a,(ix+002h)		;70a0
	jr c,grande_tira_fila		;70a3
	sub 00eh		;70a5
grande_tira_fila:
	add a,007h		;70a7
	and 07fh		;70a9
	ld (ix+004h),a		;70ab
	ret			;70ae
grande_salta_lado:
	ld a,e			;70af
	cpl			;70b0
	ld c,a			;70b1
	or 001h		;70b2
	ld (0ebe1h),a		;70b4
	call salto_marca		;70b7   ; 0x7843
	set 7,(ix+002h)		;70ba   ; salta
	ret			;70be
grande_cerrada_mira:
	sub 003h		;70bf   ; su fila - 3
	ld e,a			;70c1
	cp d			;70c2   ; en diagonal por abajo?
	jp z,grande_ataca2		;70c3
	neg		;70c6   ; o por arriba?
	cp d			;70c8
	jp z,grande_ataca2		;70c9
	jr grande_cerrada_anda		;70cc
grande_cerrada_lado:
	ld a,d			;70ce   ; el lado del protagonista...
	and 040h		;70cf
	ld c,a			;70d1
	ld a,(ix+002h)		;70d2   ; ...al bit 6
	and 0bfh		;70d5
	or c			;70d7
	ld (ix+002h),a		;70d8
grande_cerrada_anda:
	bit 6,(ix+002h)		;70db
	jr nz,grande_cerrada_der		;70df
	dec (ix+003h)		;70e1
	jr grande_cerrada_fin		;70e4
grande_cerrada_der:
	inc (ix+003h)		;70e6
grande_cerrada_fin:
	jp grande_puede		;70e9
grande_saltando:		; Saltando: si hay pared, vuelve; si no, sigue el salto
	call misma_parte		;70ec   ; pared?
	jr z,grande_salto_fin		;70ef
	call escalera_debajo		;70f1   ; suelo?
	jp nz,grande_anda		;70f4
	ld a,(ix+002h)		;70f7   ; su fila
	jr c,grande_salto_otro		;70fa
	ld a,(0ebe1h)		;70fc   ; hacia donde salta
	rla			;70ff
	jp c,grande_anda		;7100
	ld a,(ix+002h)		;7103   ; la fila - 7
	sub 007h		;7106
	jr grande_salto_pon		;7108
grande_salto_otro:
	ld a,(0ebe1h)		;710a   ; hacia donde
	add a,a			;710d
	jr c,grande_salto_baja		;710e
	jp nz,grande_anda		;7110
grande_salto_baja:
	ld a,(ix+002h)		;7113   ; la fila + 7
	add a,007h		;7116
grande_salto_pon:
	and 07fh		;7118   ; la fila de llegada
	ld (ix+004h),a		;711a
	ld a,(ix+003h)		;711d   ; la columna
	ld (ix+005h),a		;7120
	ld (ix+000h),037h		;7123   ; 0x37, 0x80
	ld (ix+001h),080h		;7127
	ld a,003h		;712b   ; 3 cuadros de espera
	ld (0ec0ch),a		;712d
	res 7,(ix+002h)		;7130   ; ya no salta
	ld a,(ix+003h)		;7134   ; su columna
	and 03fh		;7137
	ld b,a			;7139
	ld a,(0eadch)		;713a   ; la del protagonista
	cp b			;713d   ; a que lado?
	jr c,grande_salto_izq		;713e
	set 6,(ix+004h)		;7140   ; a la derecha
	ret			;7144
grande_salto_izq:
	res 6,(ix+004h)		;7145   ; a la izquierda
	ret			;7149
grande_salto_fin:
	res 7,(ix+002h)		;714a
	ret			;714e
grande_sale:		; Con 0xEB6A o 0xEB6B: cada 40 cuadros (0xEBE2) sale otro (0x7482)
	ld a,(0eb6ah)		;714f   ; 0xEB6A?
	or a			;7152
	jr nz,grande_sale_va		;7153
	ld a,(0eb6bh)		;7155   ; 0xEB6B?
	or a			;7158
	ret z			;7159
grande_sale_va:
	ld a,(ix+002h)		;715a   ; su fila
	and 01fh		;715d
	ld hl,0ebe2h		;715f   ; la cuenta
	jr nz,grande_sale_pon		;7162
	dec (hl)			;7164   ; un cuadro menos
	ret nz			;7165
grande_sale_pon:
	ld (hl),028h		;7166   ; 40 cuadros
	call enemigo_nuevo		;7168   ; sale
	xor a			;716b   ; las cuentas a 0
	ld (0ebe0h),a		;716c
	ld (0ebe3h),a		;716f
	ret			;7172

; ----------------------------------------------------------------------
; DATOS grande_clase: La clase del enemigo grande (0x7173)
;   0x7173..0x71a9  (54 bytes)
DATA_grande_clase:
	defb 07ch,071h,0a0h,071h,000h,009h,003h,0eah,077h,0c8h,0c9h,0cah,0cbh,0cch,0cdh,0ceh	; 7173  |q.q....w.......
	defb 0cfh,0d0h,0d1h,0d2h,0d3h,0d4h,0d5h,0d6h,0d7h,0d8h,0d9h,0dch,0dbh,0dah,0dfh,0deh	; 7183  ................
	defb 0ddh,0e2h,0e1h,0e0h,0e5h,0e4h,0e3h,0e8h,0e7h,0e6h,0ebh,0eah,0e9h,0f6h,0f7h,0f8h	; 7193  ................
	defb 0f9h,0fah,0fbh,0fch,0fdh,0feh	; 71a3

; ======================================================================
; CODIGO 0x71a9..0x71e8  (63 bytes)
; ======================================================================


grande2_dibujos:		; Con 0xEB6B: los dibujos del otro grande (18 bloques de 0x71E8 a la casilla 0xC8 y su espejo desde la 0xDA) y sus colores segun la vuelta (0x725E, 0x727A, 0x7296)
	ld a,(0eb6bh)		;71a9   ; 0xEB6B?
	or a			;71ac
	ret z			;71ad
	ld hl,071e8h		;71ae   ; 18 bloques...
	ld de,00640h		;71b1   ; ...a la casilla 0xC8
	push de			;71b4
	ld b,012h		;71b5
	call desempaqueta_tercios		;71b7
	pop hl			;71ba
	ld de,006d0h		;71bb   ; su espejo desde la 0xDA
	ld bc,00090h		;71be
	call espejo_vram		;71c1
	ld hl,0725eh		;71c4   ; los colores de la vuelta 3 o mas
	ld a,(0e003h)		;71c7   ; la vuelta
	cp 003h		;71ca
	jr nc,grande2_colores		;71cc
	cp 002h		;71ce
	jr nc,grande2_colores2		;71d0
	ld hl,0727ah		;71d2   ; la 1
	jr grande2_colores		;71d5
grande2_colores2:
	ld hl,07296h		;71d7   ; la 2
grande2_colores:
	ld de,02640h		;71da   ; los colores
	push hl			;71dd
	call ordenes_tercios		;71de
	pop hl			;71e1
	ld de,026d0h		;71e2   ; y los del espejo
	jp ordenes_tercios		;71e5

; ----------------------------------------------------------------------
; DATOS grande2_datos: Las casillas del otro grande empaquetadas (0x71E8) y
;   sus colores en cada vuelta (0x725E, 0x727A, 0x7296)
;   0x71e8..0x7356  (366 bytes)
DATA_grande2_datos:
	defb 088h,000h,001h,0ffh,038h,07ch,0fbh,0f3h,063h,067h,007h,083h,08fh,000h,080h,0c0h	; 71e8  ....8|..cg......
	defb 0e0h,0f0h,0b3h,000h,00dh,01fh,006h,000h,0e7h,083h,007h,0ffh,07fh,03fh,07eh,0fbh	; 71f8  .............?~.
	defb 0f8h,0fch,07ch,0beh,09fh,01fh,00eh,086h,000h,001h,003h,0bah,0ffh,0f7h,0f3h,0f1h	; 7208  ..|.............
	defb 0f3h,0f3h,000h,080h,0c0h,0f0h,0e0h,0c0h,088h,000h,001h,0ffh,038h,07eh,0fbh,0f3h	; 7218  ............8~..
	defb 063h,067h,0ffh,007h,09fh,000h,080h,0c0h,0e0h,0f0h,0f8h,0b7h,003h,037h,07fh,07ch	; 7228  cg...........7.|
	defb 039h,003h,0e6h,083h,007h,0fdh,0feh,0ffh,0ffh,07ch,0bch,0f8h,0f0h,0e0h,0c0h,000h	; 7238  9........|......
	defb 080h,08dh,00fh,01fh,03fh,000h,0feh,0dfh,08fh,007h,003h,001h,000h,001h,0fbh,080h	; 7248  ....?...........
	defb 0c0h,0e0h,0f0h,0f8h,0f0h,0e0h,0e0h,00ah,0e4h,004h,0e6h,002h,0e0h,010h,0e6h,002h	; 7258  ................
	defb 0e0h,026h,0e0h,00ah,0e4h,004h,0e6h,002h,0e0h,010h,0e6h,002h,0e0h,026h,000h,0e0h	; 7268  .&...........&..
	defb 048h,000h,070h,00ah,074h,004h,076h,002h,070h,010h,076h,002h,070h,026h,070h,00ah	; 7278  H.p.t.v.p.v.p&p.
	defb 074h,004h,076h,002h,070h,010h,076h,002h,070h,026h,000h,070h,048h,000h,090h,00ah	; 7288  t.v.p.v.p&.pH...
	defb 094h,004h,096h,002h,090h,010h,096h,002h,090h,026h,090h,00ah,094h,004h,096h,002h	; 7298  .........&......
	defb 090h,010h,096h,002h,090h,026h,000h,090h,048h,000h,0dfh,000h,001h,011h,008h,004h	; 72a8  .....&..H.......
	defb 000h,070h,09fh,000h,010h,020h,040h,000h,01ch,0fah,000h,004h,008h,011h,001h,000h	; 72b8  .p... @.........
	defb 0f8h,000h,040h,020h,010h,000h,0ceh,000h,001h,011h,009h,008h,08ch,000h,010h,020h	; 72c8  ..@ ........... 
	defb 0dbh,004h,000h,070h,000h,004h,008h,0dbh,040h,000h,01ch,000h,040h,010h,0f2h,008h	; 72d8  ...p....@...@...
	defb 009h,011h,001h,000h,0b0h,020h,010h,000h,08fh,000h,008h,004h,002h,001h,0c1h,000h	; 72e8  ..... ..........
	defb 010h,001h,08fh,000h,020h,040h,080h,000h,099h,000h,07eh,000h,001h,0c3h,082h,000h	; 72f8  .... @....~.....
	defb 082h,001h,098h,000h,0fch,000h,0f0h,002h,004h,008h,000h,082h,010h,000h,0f0h,080h	; 7308  ................
	defb 040h,020h,000h,0ffh,0ech,077h,0dah,06ch,0b7h,05ah,0f7h,02ch,0bdh,010h,038h,0feh	; 7318  @ ...w.l.Z.,..8.
	defb 038h,010h,000h,0bdh,001h,003h,00fh,003h,001h,000h,0bch,000h,080h,0e0h,080h,000h	; 7328  8...............
	defb 08fh,000h,0b7h,05ah,0f7h,02ch,0ffh,00ch,007h,00ah,00ch,007h,00ah,007h,00ch,0ffh	; 7338  ...Z.,..........
	defb 000h,003h,002h,00ch,017h,01ah,077h,02ch,08fh,000h,001h,002h,007h,00ch	; 7348  ......w,......

; ======================================================================
; CODIGO 0x7356..0x7454  (254 bytes)
; ======================================================================


enemigo_puede:		; ¿Puede seguir el enemigo IX? Mira tres filas de dos casillas contra las 7 de 0x7454 (paso libre) y las de debajo contra las 7 de 0x745B (suelo); C si choca (bit 5 de +2); en el borde de un hueco da la vuelta
	call casilla_enemigo		;7356   ; su casilla
	ld c,002h		;7359   ; el hueco
	call hueco_borde		;735b   ; en el borde?
	ret c			;735e
	ld hl,(0ebf4h)		;735f   ; su casilla
	ld c,003h		;7362   ; tres filas
enemigo_puede_fila:
	ld b,002h		;7364   ; dos casillas
	ex de,hl			;7366
enemigo_puede_casilla:
	push bc			;7367
	ld a,(de)			;7368
	ld bc,00007h		;7369   ; siete de 0x7454
	ld hl,07454h		;736c
	cpir		;736f   ; CPIR
	pop bc			;7371
	jr nz,enemigo_choca		;7372   ; otra: choca
	inc de			;7374
	djnz enemigo_puede_casilla		;7375
	ld hl,0003eh		;7377   ; la fila de abajo
	add hl,de			;737a
	dec c			;737b
	jr nz,enemigo_puede_fila		;737c
	ex de,hl			;737e
	ld b,002h		;737f   ; las dos de debajo
enemigo_suelo:
	push bc			;7381
	ld a,(de)			;7382
	ld bc,00007h		;7383   ; siete de 0x745B
	ld hl,0745bh		;7386
	cpir		;7389   ; CPIR
	pop bc			;738b
	jr nz,enemigo_choca		;738c
	inc de			;738e
	djnz enemigo_suelo		;738f
	res 5,(ix+002h)		;7391   ; libre
	xor a			;7395
	ret			;7396
enemigo_choca:
	cp 080h		;7397   ; 0x80 o mas: el borde
	jr nc,enemigo_vuelta		;7399
	set 5,(ix+002h)		;739b   ; choca
	scf			;739f
	ret			;73a0
enemigo_vuelta:
	dec b			;73a1
	jr nz,enemigo_vuelta_der		;73a2
	res 6,(ix+002h)		;73a4   ; a la izquierda
	dec (ix+003h)		;73a8
	jr enemigo_vuelta_mira		;73ab
enemigo_vuelta_der:
	set 6,(ix+002h)		;73ad   ; a la derecha
	inc (ix+003h)		;73b1
enemigo_vuelta_mira:
	ld a,(ix+002h)		;73b4
	push af			;73b7
	ld c,002h		;73b8   ; el hueco otra vez
	call hueco_borde		;73ba
	pop af			;73bd
	cp (ix+002h)		;73be
	ret z			;73c1
	ld (ix+000h),000h		;73c2   ; fuera
	ret			;73c6
grande_puede:		; Lo mismo para el grande: tres filas de tres casillas; las 0x22-0x23, 0x24, 0x26, 0x38-0x3A dejan pasar, las de 0x80 o mas son el borde
	call casilla_enemigo		;73c7   ; su casilla
	ld c,003h		;73ca   ; el hueco
	call hueco_borde		;73cc
	ret c			;73cf
	ld hl,(0ebf4h)		;73d0
	ld c,003h		;73d3   ; tres filas
grande_puede_fila:
	ld b,003h		;73d5   ; tres casillas
grande_puede_casilla:
	ld a,(hl)			;73d7   ; la casilla
	cp 022h		;73d8   ; 0x21 o menos: pasa
	jr c,grande_puede_sig		;73da
	cp 024h		;73dc   ; 0x24: pasa
	jr z,grande_puede_sig		;73de
	cp 026h		;73e0   ; 0x26 (escalera): pasa
	jr z,grande_puede_sig		;73e2
	cp 038h		;73e4   ; 0x27-0x37: choca
	jr c,enemigo_choca		;73e6
	cp 03bh		;73e8   ; 0x38-0x3A: pasa
	jr c,grande_puede_sig		;73ea
	cp 080h		;73ec   ; 0x3B-0x7F: choca
	jr c,enemigo_choca		;73ee
	jr grande_puede_borde		;73f0   ; 0x80 o mas: el borde
grande_puede_sig:
	inc hl			;73f2
	djnz grande_puede_casilla		;73f3
	ld de,0003dh		;73f5   ; la fila de abajo
	add hl,de			;73f8
	dec c			;73f9
	jr nz,grande_puede_fila		;73fa
	bit 7,(ix+002h)		;73fc   ; saltando?
	jr nz,grande_puede_si		;7400
	ex de,hl			;7402   ; el suelo, tres casillas
	ld b,003h		;7403
	jp enemigo_suelo		;7405
grande_puede_si:
	res 5,(ix+002h)		;7408
	xor a			;740c
	ret			;740d
grande_puede_borde:
	ld a,0ffh		;740e
	or a			;7410
	ret			;7411
hueco_borde:		; ¿Esta el enemigo IX en el borde del hueco de su parte (fila 0-8: 0xEABB; 9-16: 0x7581; 17 o mas: 0xEABD) a menos de C? Entonces da la vuelta y, sin pared, cae (0x37): C
	ld a,(ix+002h)		;7412   ; su fila
	and 01fh		;7415
	ld de,0eabbh		;7417   ; arriba: el primer hueco
	cp 009h		;741a
	jr c,hueco_borde_mira		;741c
	ld de,07581h		;741e   ; en medio: 0x7581
	cp 011h		;7421
	jr c,hueco_borde_mira		;7423
	ld de,0eabdh		;7425   ; abajo: el segundo
hueco_borde_mira:
	ld a,(de)			;7428   ; el principio del hueco
	ld b,a			;7429
	ld a,(ix+003h)		;742a   ; su columna
	and 03fh		;742d
	sub b			;742f
	jr c,hueco_borde_der		;7430
	ld b,a			;7432
	inc de			;7433   ; el ancho
	ld a,(de)			;7434
	sub c			;7435
	cp b			;7436
	ret nc			;7437
	res 6,(ix+002h)		;7438   ; a la izquierda
	dec (ix+003h)		;743c
	jr hueco_borde_cae		;743f
hueco_borde_der:
	set 6,(ix+002h)		;7441   ; a la derecha
	inc (ix+003h)		;7445
hueco_borde_cae:
	call misma_parte		;7448   ; pared?
	ld a,0ffh		;744b
	ret nz			;744d
	ld (ix+000h),037h		;744e   ; cae: 0x37
	scf			;7452
	ret			;7453

; ----------------------------------------------------------------------
; DATOS casillas_paso: Las siete casillas por las que pasan los enemigos
;   (0x7454) y las siete del suelo (0x745B)
;   0x7454..0x7462  (14 bytes)
DATA_casillas_paso:
	defb 020h,021h,026h,038h,039h,03ah,03fh,021h,023h,027h,028h,029h,03ch,03eh	; 7454   !&89:?!#'()<>

; ======================================================================
; CODIGO 0x7462..0x7581  (287 bytes)
; ======================================================================


misma_parte:		; ¿Esta el protagonista en la misma parte (de 7 filas) que el enemigo IX? Z si esta; NC/C segun este encima o debajo
	ld a,(ix+002h)		;7462   ; su fila - 3
	and 01fh		;7465
	sub 003h		;7467
	ld e,a			;7469
	ld a,(0eaddh)		;746a   ; la del protagonista - eso
	sub e			;746d
	ld e,a			;746e
	cp 007h		;746f   ; menos de 7: si
	jr c,misma_parte_si		;7471
	cp 00eh		;7473   ; 7-13: debajo
	jr c,misma_parte_no		;7475
	cp 0f9h		;7477   ; -7..-1: encima
	jr nc,misma_parte_no		;7479
	or a			;747b
	scf			;747c
	ret			;747d
misma_parte_no:
	or a			;747e
	ret			;747f
misma_parte_si:
	xor a			;7480
	ret			;7481
enemigo_nuevo:		; Un enemigo sale en IX: en una fila de la parte (por los huecos) y una columna al azar o la de un hueco; si hay otro en el sitio, no
	ld a,(ix+001h)		;7482   ; ocupado?
	or a			;7485
	ret nz			;7486
	ld a,(ix+000h)		;7487   ; 0x40?
	bit 6,a		;748a
	ret nz			;748c
	bit 5,a		;748d   ; 0x20?
	jr z,enemigo_nuevo_fila		;748f
	and 01fh		;7491
	cp 020h		;7493
	ret nc			;7495
enemigo_nuevo_fila:
	ld a,(ix+002h)		;7496
	and 01fh		;7499   ; sin fila: al azar
	jr z,enemigo_nuevo_azar		;749b
	jr enemigo_nuevo_parte		;749d
enemigo_nuevo_azar:
	call azar		;749f   ; una columna al azar
	and 03fh		;74a2
	ld (ix+003h),a		;74a4
	jr enemigo_nuevo_hueco		;74a7
enemigo_nuevo_parte:
	ld a,(ix+002h)		;74a9
	and 01fh		;74ac
	cp 008h		;74ae   ; por debajo de 8 o desde la 16...
	jp c,enemigo_nuevo_medio		;74b0
	cp 010h		;74b3
	jp nc,enemigo_nuevo_medio		;74b5
enemigo_nuevo_hueco:
	ld hl,0eabbh		;74b8   ; los huecos
	ld a,(ix+003h)		;74bb   ; su columna
	and 03fh		;74be
	cp 020h		;74c0   ; la mitad derecha?
	jr c,enemigo_nuevo_izq		;74c2
	res 6,(ix+004h)		;74c4
	ld a,(hl)			;74c8
	inc hl			;74c9
	add a,(hl)			;74ca
	sub 002h		;74cb
	ld b,a			;74cd
	inc hl			;74ce
	ld a,(hl)			;74cf
	inc hl			;74d0
	add a,(hl)			;74d1
	sub 002h		;74d2
	cp b			;74d4
	jr c,enemigo_nuevo_arriba		;74d5
	jr enemigo_nuevo_abajo		;74d7
enemigo_nuevo_izq:
	set 6,(ix+004h)		;74d9   ; hacia la derecha
	ld b,(hl)			;74dd   ; el primer hueco: columna...
	inc hl			;74de
	inc hl			;74df
	ld a,(hl)			;74e0   ; ...el segundo
	cp b			;74e1   ; cual mas a la izquierda?
	jr c,enemigo_nuevo_abajo		;74e2
enemigo_nuevo_arriba:
	ld (ix+005h),b		;74e4   ; la columna
	ld a,(ix+004h)		;74e7   ; la fila 5
	and 040h		;74ea
	or 005h		;74ec
	ld (ix+004h),a		;74ee
	jr enemigo_nuevo_mira		;74f1
enemigo_nuevo_abajo:
	ld (ix+005h),a		;74f3   ; la columna
	ld a,(ix+004h)		;74f6   ; la fila 19
	and 040h		;74f9
	or 013h		;74fb
	ld (ix+004h),a		;74fd
enemigo_nuevo_mira:		; ¿Hay ya algo en ese sitio entre las 9 de 0xEB32? Si no, sale (+1 = 0x21)
	ld hl,0eb32h		;7500   ; las cosas
	ld a,(ix+004h)		;7503   ; la fila
	and 01fh		;7506
	ld d,a			;7508
	ld a,(ix+005h)		;7509   ; la columna - 2
	and 03fh		;750c
	sub 002h		;750e
	ld e,a			;7510
	ld b,009h		;7511   ; nueve
enemigo_nuevo_una:
	ld a,(hl)			;7513   ; el estado
	inc hl			;7514   ; (+2: la fila)
	inc hl			;7515
	or a			;7516   ; libre?
	jr z,enemigo_nuevo_sig3		;7517
	ld a,(hl)			;7519   ; la fila
	and 01fh		;751a
	cp d			;751c   ; la misma?
	jr nz,enemigo_nuevo_otra		;751d
	inc hl			;751f
	ld a,(hl)			;7520   ; la columna
	dec hl			;7521
	and 03fh		;7522
	sub e			;7524   ; a menos de 5 a la derecha de la de antes - 2?
	jr c,enemigo_nuevo_otra		;7525
	cp 005h		;7527
	jr c,enemigo_nuevo_ocupado		;7529
enemigo_nuevo_otra:
	dec hl			;752b   ; el otro estado
	ld a,(hl)			;752c
	or a			;752d   ; libre?
	inc hl			;752e
	jr z,enemigo_nuevo_sig3		;752f
	inc hl			;7531
	inc hl			;7532
	ld a,(hl)			;7533   ; su segunda fila
	and 01fh		;7534
	cp d			;7536
	jr nz,enemigo_nuevo_sig2		;7537
	inc hl			;7539
	ld a,(hl)			;753a   ; su segunda columna
	and 03fh		;753b
	sub e			;753d
	jr c,enemigo_nuevo_sig		;753e
	cp 005h		;7540   ; a menos de 5?
	jr c,enemigo_nuevo_ocupado		;7542
	jr enemigo_nuevo_sig		;7544
enemigo_nuevo_sig3:
	inc hl			;7546   ; la siguiente
	inc hl			;7547
enemigo_nuevo_sig2:
	inc hl			;7548
enemigo_nuevo_sig:
	inc hl			;7549
	djnz enemigo_nuevo_una		;754a   ; una menos
	ld (ix+001h),021h		;754c   ; sale: 0x21
	ret			;7550
enemigo_nuevo_medio:
	ld a,(ix+002h)		;7551   ; la fila 12
	and 0e0h		;7554
	or 00ch		;7556
	ld (ix+004h),a		;7558
	ld a,(ix+003h)		;755b   ; la columna
	ld (ix+005h),a		;755e
	and 03fh		;7561
	cp 010h		;7563
	jr c,enemigo_nuevo_medio_der		;7565
	cp 030h		;7567
	jr c,enemigo_nuevo_mira		;7569
	res 6,(ix+004h)		;756b
	jr enemigo_nuevo_mira		;756f
enemigo_nuevo_medio_der:
	set 6,(ix+004h)		;7571
	jr enemigo_nuevo_mira		;7575
enemigo_nuevo_ocupado:
	ld a,(ix+000h)		;7577
	or a			;757a
	ret nz			;757b
	ld (ix+002h),000h		;757c
	ret			;7580

; ----------------------------------------------------------------------
; DATOS hueco_medio: El hueco de en medio (columna, ancho): ninguno
;   0x7581..0x7583  (2 bytes)
DATA_hueco_medio:
	defb 001h,03eh	; 7581

; ======================================================================
; CODIGO 0x7583..0x77d2  (591 bytes)
; ======================================================================


casilla_enemigo:		; 0xEBF4 = la casilla del fondo (0xE01A) en la fila (+2) y la columna (+3) del enemigo IX
	ld a,(ix+002h)		;7583   ; la fila...
	and 01fh		;7586
	ld l,a			;7588
	ld h,000h		;7589
	add hl,hl			;758b   ; ...x 64
	add hl,hl			;758c
	add hl,hl			;758d
	add hl,hl			;758e
	add hl,hl			;758f
	add hl,hl			;7590
	ld a,(ix+003h)		;7591   ; + la columna
	and 03fh		;7594
	or l			;7596
	ld l,a			;7597
	ld de,0e01ah		;7598   ; + el fondo
	add hl,de			;759b
	ld (0ebf4h),hl		;759c
	ret			;759f
cosa_sale:		; Con 0xE001 bits 0-1 = 1: una cosa sale (0x7482) y salta
	ld a,(0e001h)		;75a0   ; 0xE001 bits 0-1...
	and 003h		;75a3
	cp 001h		;75a5   ; ...1?
	ret nz			;75a7
	xor a			;75a8
	ld (0ebf9h),a		;75a9   ; 0xEBF9 a 0
	call enemigo_nuevo		;75ac   ; sale
	xor a			;75af
	ld (0ebfah),a		;75b0   ; 0xEBFA a 0
	set 7,(ix+002h)		;75b3   ; saltando
	ret			;75b7
cosa:		; Una cosa de 0xEB32: si esta cerca del protagonista (a menos de 10 columnas, la misma parte), va a por el; si no, anda
	ld a,(ix+000h)		;75b8   ; libre: que salga
	or a			;75bb
	jp z,cosa_sale		;75bc
	inc a			;75bf   ; 0xFF?
	ret nz			;75c0
	ld a,(ix+001h)		;75c1   ; parada?
	or a			;75c4
	ret nz			;75c5
	call casilla_enemigo		;75c6   ; su casilla
	call misma_parte		;75c9   ; la misma parte?
	jr nz,cosa_anda		;75cc
	ld a,(ix+003h)		;75ce   ; su columna
	and 03fh		;75d1
	ld d,a			;75d3
	ld a,(0eadch)		;75d4   ; la del protagonista
	sub d			;75d7
	ld d,a			;75d8
	jr nc,cosa_cerca		;75d9
	neg		;75db
cosa_cerca:
	cp 00ah		;75dd   ; a menos de 10?
	jp c,cosa_a_por		;75df
	jp cosa_anda		;75e2
cosa_anda:
	ld c,002h		;75e5   ; el hueco
	call hueco_borde		;75e7
	jr c,cosa_vuelta		;75ea
	ld hl,(0ebf4h)		;75ec   ; su casilla
	bit 6,(ix+002h)		;75ef   ; hacia donde?
	jr nz,cosa_anda_der		;75f3
	ld de,000c0h		;75f5   ; la de debajo a la izquierda (+0xC0)
	jr cosa_anda_mira		;75f8
cosa_anda_der:
	ld de,000c2h		;75fa   ; o a la derecha (+0xC2)
cosa_anda_mira:
	add hl,de			;75fd
	ld a,(hl)			;75fe   ; suelo?
	cp 020h		;75ff   ; hueco (0x20)?
	jr z,cosa_vuelta		;7601
	jr cosa_paso		;7603
cosa_vuelta:
	ld a,(ix+002h)		;7605   ; da la vuelta
	xor 040h		;7608
	ld (ix+002h),a		;760a
	jr cosa_paso		;760d
cosa_a_por:		; Cerca: hacia el protagonista; si esta encima o debajo, salta (0x37) siete filas
	call escalera_debajo		;760f   ; suelo?
	jr nz,cosa_a_por_lado		;7612
	jr c,cosa_salta_abajo		;7614
	jr cosa_salta_arriba		;7616
cosa_a_por_lado:
	ld a,(ix+003h)		;7618   ; su columna
	and 03fh		;761b
	ld e,a			;761d
	ld a,(0eadch)		;761e   ; la del protagonista
	sub e			;7621
	jr nc,cosa_a_por_izq		;7622
	set 6,(ix+002h)		;7624   ; a la derecha
	jr cosa_paso		;7628
cosa_a_por_izq:
	res 6,(ix+002h)		;762a   ; a la izquierda
	jr cosa_paso		;762e
cosa_salta_arriba:
	ld a,(ix+002h)		;7630   ; 7 filas arriba
	sub 007h		;7633
	jr cosa_salta		;7635
cosa_salta_abajo:
	ld a,(ix+002h)		;7637   ; 7 filas abajo
	add a,007h		;763a
cosa_salta:
	ld (ix+004h),a		;763c   ; la fila de llegada
	ld a,(ix+003h)		;763f   ; y la columna
	ld (ix+005h),a		;7642
	ld (ix+000h),037h		;7645   ; 0x37, 0x80: salta
	ld (ix+001h),080h		;7649
	jr cosa_fin		;764d
cosa_paso:		; Un paso de lado; en un borde (A = 2), la vuelta
	bit 6,(ix+002h)		;764f   ; hacia donde?
	jr nz,cosa_paso_der		;7653
	dec (ix+003h)		;7655   ; a la izquierda
	call enemigo_puede		;7658   ; puede?
	ret c			;765b
	cp 002h		;765c   ; 2: la vuelta
	ret nz			;765e
	jr z,cosa_fin		;765f
	inc (ix+003h)		;7661   ; vuelve
	set 6,(ix+002h)		;7664
	ret			;7668
cosa_paso_der:
	inc (ix+003h)		;7669   ; a la derecha
	call enemigo_puede		;766c   ; puede?
	ret c			;766f
	cp 002h		;7670
	ret nz			;7672
	dec (ix+003h)		;7673   ; vuelve
	res 6,(ix+002h)		;7676
cosa_fin:
	ret			;767a
pinta_objeto:		; Un objeto IX (enemigo o cosa) en la pantalla de la RAM, con su clase IY: elige el dibujo (por el estado de +0 y +1, el paso y el lado) y lo copia (IY+4 filas de IY+6 casillas) donde esta y, si salta, donde llega; despues cuenta su paso
	ld a,(ix+000h)		;767b   ; bit 7 de +0: andando
	rla			;767e
	jr c,pinta_anda		;767f
	rla			;7681   ; bit 6: cayendo
	jr c,pinta_cae		;7682
	rla			;7684   ; bit 5: saltando
	jr nc,pinta_salto		;7685
	rlca			;7687   ; el paso del salto
	rlca			;7688
	ld l,(iy+007h)		;7689   ; el dibujo del salto (IY+7)
	ld h,(iy+008h)		;768c
	and 003h		;768f
	jr pinta_dibujo_n		;7691
pinta_cae:
	ld l,(iy+002h)		;7693   ; el de caer (IY+2)
	ld h,(iy+003h)		;7696
	jr pinta_dibujo_pon		;7699
pinta_anda:
	ld a,(0eb6ch)		;769b   ; el paso de andar (cada 16 cuadros)
	and 010h		;769e
	rrca			;76a0
	rrca			;76a1
	rrca			;76a2
	rrca			;76a3
	ld c,a			;76a4
	ld a,(ix+002h)		;76a5   ; el lado
	and 040h		;76a8
	rlca			;76aa
	rlca			;76ab
	rlca			;76ac
	or c			;76ad
	ld l,(iy+000h)		;76ae   ; el de andar (IY+0)
	ld h,(iy+001h)		;76b1
pinta_dibujo_n:
	jr z,pinta_dibujo_pon		;76b4   ; el primero?
	ld c,a			;76b6
	ld a,000h		;76b7
pinta_dibujo_suma:
	add a,(iy+005h)		;76b9   ; + el tamano del dibujo (IY+5) n veces
	dec c			;76bc
	jr nz,pinta_dibujo_suma		;76bd
	ld c,a			;76bf
	ld b,000h		;76c0
	add hl,bc			;76c2
pinta_dibujo_pon:
	ld (0ec02h),hl		;76c3   ; el dibujo
pinta_salto:
	bit 5,(ix+001h)		;76c6   ; saltando (bit 5 de +1)?
	jr z,pinta_va		;76ca
	ld l,(iy+007h)		;76cc   ; el dibujo del salto
	ld h,(iy+008h)		;76cf
	ld a,(ix+001h)		;76d2
	rra			;76d5
	rra			;76d6
	rra			;76d7
	and 003h		;76d8
	jr z,pinta_salto_pon		;76da
	ld c,a			;76dc
	ld a,000h		;76dd
pinta_salto_suma:
	add a,(iy+005h)		;76df   ; + el tamano del dibujo
	dec c			;76e2   ; n veces
	jr nz,pinta_salto_suma		;76e3
	ld c,a			;76e5
	ld b,000h		;76e6
	add hl,bc			;76e8   ; + el dibujo
pinta_salto_pon:
	ld (0ec04h),hl		;76e9   ; el dibujo del salto
pinta_va:
	ld a,(0ebfdh)		;76ec   ; cada dos cuadros...
	rra			;76ef
	jr c,pinta_copia		;76f0
	bit 5,(ix+002h)		;76f2   ; ...o si choca
	ret nz			;76f6
pinta_copia:
	ld a,(ix+002h)		;76f7   ; su fila
	and 01fh		;76fa
	ld d,a			;76fc
	ld a,(ix+003h)		;76fd   ; su columna
	and 03fh		;7700
	ld e,a			;7702
	ld bc,00000h		;7703
	call casilla_dir		;7706   ; su casilla
	ld de,0e01ah		;7709   ; en el fondo
	add hl,de			;770c
	ex de,hl			;770d
	ld hl,(0ec02h)		;770e   ; el dibujo
	exx			;7711
	ld a,(ix+004h)		;7712   ; la fila de llegada
	and 01fh		;7715
	ld d,a			;7717
	ld a,(ix+005h)		;7718   ; su columna
	and 03fh		;771b
	ld e,a			;771d
	ld bc,00000h		;771e
	call casilla_dir		;7721   ; su casilla
	ld de,0e01ah		;7724
	add hl,de			;7727
	ex de,hl			;7728
	ld hl,(0ec04h)		;7729   ; el dibujo del salto
	ld b,000h		;772c
	exx			;772e
	ld b,000h		;772f
	ld a,(iy+004h)		;7731   ; cuantas filas?
	or a			;7734
	call z,pinta_fila		;7735   ; la primera
	ld c,040h		;7738   ; la fila siguiente (+64)
	ex de,hl			;773a
	add hl,bc			;773b
	ex de,hl			;773c
	exx			;773d
	ld c,040h		;773e
	ex de,hl			;7740
	add hl,bc			;7741
	ex de,hl			;7742
	exx			;7743
	call pinta_fila		;7744   ; la segunda
	ld c,040h		;7747
	ex de,hl			;7749
	add hl,bc			;774a
	ex de,hl			;774b
	exx			;774c
	ld c,040h		;774d
	ex de,hl			;774f
	add hl,bc			;7750
	ex de,hl			;7751
	exx			;7752
	call pinta_fila		;7753   ; la tercera
	bit 7,(ix+000h)		;7756   ; andando: nada mas
	ret nz			;775a
	ld a,(ix+000h)		;775b   ; la cuenta del paso
	and 01fh		;775e
	jr z,pinta_salto_cuenta		;7760
	dec (ix+000h)		;7762   ; una menos
	cp 008h		;7765   ; el 8...
	jr nz,pinta_cuenta1		;7767
	bit 7,(ix+001h)		;7769
	jr z,pinta_cuenta1		;776d
	ld (ix+001h),021h		;776f   ; ...cae: 0x21
pinta_cuenta1:
	cp 001h		;7773   ; el 1: acaba
	jr nz,pinta_salto_cuenta		;7775
	bit 6,(ix+000h)		;7777
	ld (ix+000h),000h		;777b   ; sale de la pantalla
	jr z,pinta_salto_cuenta		;777f
	ld (ix+001h),01fh		;7781   ; 0x1F
	ld (ix+002h),000h		;7785
	ret			;7789
pinta_salto_cuenta:
	ld a,(ix+001h)		;778a   ; saltando?
	bit 5,a		;778d
	jr z,pinta_salto_baja		;778f
	and 01fh		;7791
	ret z			;7793
	inc (ix+001h)		;7794   ; un paso mas
	cp 017h		;7797   ; el 23: ha llegado
	ret nz			;7799
	ld (ix+000h),0ffh		;779a   ; anda otra vez
	ld (ix+001h),000h		;779e
	ld a,(ix+004h)		;77a2   ; la fila y la columna de llegada
	ld (ix+002h),a		;77a5
	ld a,(ix+005h)		;77a8
	ld (ix+003h),a		;77ab
	ret			;77ae
pinta_salto_baja:
	and 01fh		;77af
	ret z			;77b1
	dec (ix+001h)		;77b2
	ret			;77b5
pinta_fila:		; Una fila del dibujo: la del sitio (si +0 bit 5) y la de llegada (si +1 bit 5)
	bit 5,(ix+000h)		;77b6   ; en su sitio?
	jr z,pinta_fila_llegada		;77ba
	call pinta_casillas		;77bc
pinta_fila_llegada:
	bit 5,(ix+001h)		;77bf   ; en la llegada?
	ret z			;77c3
	exx			;77c4
	call pinta_casillas		;77c5
	exx			;77c8
	ret			;77c9
pinta_casillas:		; IY+6 casillas de HL a DE
	ld c,(iy+006h)		;77ca   ; cuantas
	push de			;77cd
	ldir		;77ce
	pop de			;77d0
	ret			;77d1

; ----------------------------------------------------------------------
; DATOS pinta_dibujos: Los dibujos de los objetos (filas de casillas) de las
;   clases
;   0x77d2..0x781a  (72 bytes)
DATA_pinta_dibujos:
	defb 015h,005h,005h,011h,002h,008h,000h,002h,015h,000h,000h,015h,000h,015h,015h,000h	; 77d2  ................
	defb 015h,016h,016h,019h,025h,019h,015h,025h,0ffh,0ffh,0ffh,0ffh,091h,0ffh,0ffh,0ffh	; 77e2  ....%..%........
	defb 0ffh,097h,094h,09bh,095h,090h,099h,09ch,098h,09eh,096h,090h,09ah,090h,090h,090h	; 77f2  ................
	defb 09dh,098h,09fh,0ffh,0ffh,092h,093h,0ffh,0ffh,097h,09bh,095h,099h,09ch,09eh,096h	; 7802  ................
	defb 09ah,090h,090h,09dh,09fh,001h,001h,001h	; 7812  ........

; ======================================================================
; CODIGO 0x781a..0x7a4d  (563 bytes)
; ======================================================================


colores_dos:		; Dos grupos (6 bytes cada uno) de 0x7829
	ld b,002h		;781a   ; dos
colores_dos_uno:
	push bc			;781c
	call colores_pon		;781d
	ld bc,00006h		;7820   ; el siguiente
	add ix,bc		;7823
	pop bc			;7825
	djnz colores_dos_uno		;7826
	ret			;7828
colores_pon:		; Las ordenes de casillas IX: de (+0) a (+2) y a (+4) en los tres tercios
	ld l,(ix+000h)		;7829   ; las ordenes
	ld h,(ix+001h)		;782c
	ld e,(ix+002h)		;782f   ; el primer sitio
	ld d,(ix+003h)		;7832
	push hl			;7835
	call ordenes_tercios		;7836   ; en los tres tercios
	pop hl			;7839
	ld e,(ix+004h)		;783a   ; el segundo
	ld d,(ix+005h)		;783d
	jp ordenes_tercios		;7840
salto_marca:		; La marca del salto del grande (0xE0D9 + fila x 64, + 0x80 con C) en la columna
	ld a,(ix+002h)		;7843   ; su fila
	and 01fh		;7846
	ld l,a			;7848   ; x 64
	ld h,000h		;7849
	add hl,hl			;784b
	add hl,hl			;784c
	add hl,hl			;784d
	add hl,hl			;784e
	add hl,hl			;784f
	add hl,hl			;7850
	ld de,0e0d9h		;7851   ; + 0xE0D9
	add hl,de			;7854
	ld a,c			;7855   ; hacia arriba?
	add a,a			;7856
	jr nc,salto_marca_col		;7857
	ld de,00080h		;7859   ; + 2 filas
	add hl,de			;785c
salto_marca_col:
	ld a,(ix+003h)		;785d   ; su columna + 2
	and 03fh		;7860
	add a,002h		;7862
	ld d,a			;7864
	ld a,0ffh		;7865   ; la mejor, ninguna
	ld i,a		;7867
	ld bc,00040h		;7869   ; 64 casillas
salto_marca_busca:
	ld a,026h		;786c   ; una escalera (0x26)...
	cpdr		;786e   ; ...hacia atras
	jr nz,salto_marca_lado		;7870
	ld a,c			;7872   ; a cuanta?
	sub d			;7873
	jr nc,salto_marca_cerca		;7874
	neg		;7876
salto_marca_cerca:
	cp e			;7878   ; mas cerca?
	jr nc,salto_marca_lado		;7879
	ld e,a			;787b
	ld a,c			;787c   ; la mejor
	ld i,a		;787d
	jr salto_marca_busca		;787f
salto_marca_lado:
	ld a,i		;7881   ; la mejor esta...
	cp d			;7883
	jr nc,salto_marca_der		;7884
	res 6,(ix+002h)		;7886   ; ...a la izquierda
	ret			;788a
salto_marca_der:
	set 6,(ix+002h)		;788b   ; ...a la derecha
	ret			;788f
escalera_debajo:		; ¿Una escalera (0x26) debajo de la cosa (0xEBF4 + 0x81, o dos filas mas)? Z si la hay
	ld hl,(0ebf4h)		;7890   ; su casilla
	ld de,00081h		;7893   ; la de debajo
	add hl,de			;7896
	ld a,(hl)			;7897
	cp 026h		;7898
	ret z			;789a
	ld de,00080h		;789b   ; dos filas mas
	add hl,de			;789e
	ld a,(hl)			;789f
	cp 026h		;78a0
	scf			;78a2
	ret			;78a3
queda_huye:		; El enemigo que se queda huye del protagonista: si esta en su parte y a menos de las columnas de 0xEC06 (IY+0, IY+1, segun hacia donde mira, 0xEADE), se va al otro lado (bit 6 de +2)
	ld a,(0eadeh)		;78a4   ; hacia donde mira el protagonista
	or a			;78a7
	ex af,af'			;78a8
	ld hl,0eadeh		;78a9
	ld iy,0ec06h		;78ac   ; las distancias
	ld a,(ix+003h)		;78b0   ; su columna
	and 03fh		;78b3
	ld d,a			;78b5
	ld a,(0eadch)		;78b6   ; la del protagonista - la suya
	sub d			;78b9
	ld d,a			;78ba
	ld a,(0ead3h)		;78bb   ; en la escalera (3)?
	cp 003h		;78be
	jr z,queda_huye_escalera		;78c0
	call misma_parte		;78c2   ; en su parte?
	ret nz			;78c5
	bit 7,d		;78c6   ; a la izquierda?
	jr nz,queda_huye_otro		;78c8
	ex af,af'			;78ca
	jr z,queda_huye_d1		;78cb
	ld a,(iy+000h)		;78cd
	cp d			;78d0
	ret c			;78d1
	jp queda_huye_izq		;78d2
queda_huye_d1:
	ld a,(iy+001h)		;78d5
	cp d			;78d8
	ret c			;78d9
queda_huye_izq:
	res 6,(ix+002h)		;78da   ; se va a la izquierda
	ret			;78de
queda_huye_otro:
	ex af,af'			;78df   ; hacia donde mira el protagonista
	jr nz,queda_huye_d1b		;78e0
	ld a,d			;78e2
	cp (iy+000h)		;78e3   ; cerca?
	ret c			;78e6
	jp queda_huye_der		;78e7
queda_huye_d1b:
	ld a,(iy+001h)		;78ea
	neg		;78ed
	cp d			;78ef
	ret nc			;78f0
queda_huye_der:
	set 6,(ix+002h)		;78f1   ; se va a la derecha
	ret			;78f5
queda_huye_escalera:
	call misma_parte		;78f6   ; en su parte?
	ret nz			;78f9
	bit 7,d		;78fa   ; a la izquierda?
	jr nz,queda_huye_escalera_izq		;78fc
	ex af,af'			;78fe   ; hacia donde mira
	jr nz,queda_huye_izq		;78ff
	jp queda_huye_d1		;7901
queda_huye_escalera_izq:
	ex af,af'			;7904   ; hacia donde mira
	jr z,queda_huye_der		;7905
	jp queda_huye_d1b		;7907
tiro_borra:		; El tiro de los enemigos (0xEC09) se acaba: el dibujo 0x58 de los sprites (0x1AC0) a cero y otra vez el de 0x7A4D
	xor a			;790a   ; sin tiro
	ld (0ec09h),a		;790b
	ld hl,01ac0h		;790e   ; el dibujo 0x58
	ld bc,00020h		;7911
	call 00056h		;7914   ; FILVRM
	ld hl,07a4dh		;7917   ; el dibujo del tiro
	jp tiro_dibujo		;791a
tiro:		; El tiro de los enemigos (0xEC09: bits de direccion, fila, columna): se mueve; fuera de la pantalla se acaba; si toca al protagonista (en su misma fila, no con el dibujo 0xEAE5 6 o mas), lo tumba (estado 0x0F, 0xEADF el lado)
	ld hl,(0eb30h)		;791d   ; parado?
	ld a,(hl)			;7920
	or a			;7921
	ret nz			;7922
	ld ix,0ec09h		;7923
	ld a,(ix+000h)		;7927   ; hay tiro?
	or a			;792a
	jp z,tiro_sprite		;792b
	bit 2,(ix+000h)		;792e   ; bit 2: sube
	jr z,tiro_baja		;7932
	dec (ix+001h)		;7934
tiro_baja:
	bit 3,(ix+000h)		;7937   ; bit 3: baja
	jr z,tiro_col		;793b
	inc (ix+001h)		;793d
tiro_col:
	ld a,(ix+001h)		;7940   ; fuera por abajo?
	and 01fh		;7943
	cp 018h		;7945
	jr nc,tiro_acaba		;7947
	bit 0,(ix+000h)		;7949   ; bit 0: a la izquierda
	jr z,tiro_der		;794d
	dec (ix+002h)		;794f
tiro_der:
	bit 1,(ix+000h)		;7952   ; bit 1: a la derecha
	jr z,tiro_fuera		;7956
	inc (ix+002h)		;7958
tiro_fuera:
	ld a,(ix+002h)		;795b   ; fuera por un lado?
	cp 040h		;795e
	jr nc,tiro_acaba		;7960
	ld a,(0ead1h)		;7962   ; la columna que se ve
	ld c,a			;7965
	ld a,(ix+002h)		;7966   ; fuera de la vista?
	sub c			;7969
	jr c,tiro_oculto		;796a
	cp 020h		;796c
	jr c,tiro_toca		;796e
tiro_oculto:
	set 7,(ix+001h)		;7970   ; no se ve
	jr tiro_toca		;7974
tiro_acaba:
	ld hl,07a4dh		;7976   ; otra vez el dibujo
	call tiro_dibujo		;7979
	ld (ix+000h),000h		;797c   ; se acaba
tiro_toca:
	bit 7,(ix+001h)		;7980   ; se ve?
	jr nz,tiro_sprite		;7984
	ld a,(0ead6h)		;7986   ; el protagonista cayendo?
	or a			;7989
	jr nz,tiro_sprite		;798a
	ld a,(0eadch)		;798c   ; la columna del protagonista - 1 - la suya
	dec a			;798f
	sub (ix+002h)		;7990
	jr nc,tiro_sprite		;7993
	cp 0feh		;7995   ; a 2 o menos?
	jr c,tiro_sprite		;7997
	ld a,(0eaddh)		;7999   ; la fila
	sub (ix+001h)		;799c
	jr z,tiro_misma_fila		;799f
	jr nc,tiro_sprite		;79a1
	cp 0feh		;79a3
	jr c,tiro_sprite		;79a5
	jr tiro_golpe		;79a7
tiro_misma_fila:
	ld a,(0eae5h)		;79a9   ; en su fila: con el dibujo 6 o mas...
	cp 006h		;79ac
	jr nc,tiro_sprite		;79ae   ; ...no le da
tiro_golpe:
	ld a,(0e000h)		;79b0   ; la tecla 0 al encender (0xE000 bit 7): no le da
	and 080h		;79b3
	jr nz,tiro_sprite		;79b5
	ld a,(ix+000h)		;79b7   ; el lado del golpe
	rra			;79ba
	sbc a,a			;79bb
	ld (0eadfh),a		;79bc
	ld a,00fh		;79bf   ; tumbado: 0x0F
	ld (0ead3h),a		;79c1
	ld (ix+000h),080h		;79c4   ; el tiro se queda
tiro_sprite:		; El sprite del tiro, el primero (0x3B00): fila x 8 - 1, (columna - la que se ve) x 8, dibujo 0x58, color 6; sin tiro, Y 0xD1
	ld hl,03b00h		;79c8   ; SETWRT, el primer sprite
	call 00053h		;79cb
	ld hl,0ec09h		;79ce
	ld a,(0ead1h)		;79d1
	ld d,a			;79d4
	ld a,(hl)			;79d5   ; hay tiro?
	or a			;79d6
	jr z,tiro_sprite_no		;79d7
	inc hl			;79d9
	bit 7,(hl)		;79da   ; se ve?
	jr nz,tiro_sprite_fuera		;79dc
	ld a,(hl)			;79de   ; la Y
	and 01fh		;79df
	add a,a			;79e1
	add a,a			;79e2
	add a,a			;79e3
	dec a			;79e4
	out (098h),a		;79e5
	inc hl			;79e7
	ld a,(hl)			;79e8   ; la X
	sub d			;79e9
	add a,a			;79ea
	add a,a			;79eb
	add a,a			;79ec
	out (098h),a		;79ed
	ex (sp),hl			;79ef
	ld a,058h		;79f0   ; el dibujo 0x58
	out (098h),a		;79f2
	ex (sp),hl			;79f4
	ld a,006h		;79f5   ; color 6
	out (098h),a		;79f7
	jr tiro_sprite_fin		;79f9
tiro_sprite_no:
	inc hl			;79fb
tiro_sprite_fuera:
	res 7,(hl)		;79fc   ; 0xD1: fuera
	inc hl			;79fe
	ld a,0d1h		;79ff   ; 0xD1: la Y, fuera
	out (098h),a		;7a01   ; cuatro veces, con espera
	ex (sp),hl			;7a03
	ex (sp),hl			;7a04
	out (098h),a		;7a05
	ex (sp),hl			;7a07
	ex (sp),hl			;7a08
	out (098h),a		;7a09
	ex (sp),hl			;7a0b
	ex (sp),hl			;7a0c
	out (098h),a		;7a0d
tiro_sprite_fin:
	ret			;7a0f
tira:		; El enemigo IX tira (A = las direcciones) si no hay otro tiro y esta entre las columnas 4 y 27 de la vista: el tiro sale de su fila y su columna + 1, con el sonido 1
	push af			;7a10
	ld hl,0ec09h		;7a11   ; ya hay tiro?
	ld a,(hl)			;7a14
	or a			;7a15
	jr nz,tira_no		;7a16
	push bc			;7a18
	ld a,(0ead1h)		;7a19   ; su columna en la vista
	ld b,a			;7a1c
	ld a,(ix+003h)		;7a1d
	and 03fh		;7a20
	sub b			;7a22
	pop bc			;7a23
	cp 004h		;7a24   ; 4 a 27?
	jr c,tira_no		;7a26
	cp 01ch		;7a28
	jr nc,tira_no		;7a2a
	pop af			;7a2c   ; las direcciones
	ld (hl),a			;7a2d
	inc hl			;7a2e
	ld a,(ix+002h)		;7a2f   ; la fila
	and 01fh		;7a32
	ld (hl),a			;7a34
	inc hl			;7a35
	ld a,(ix+003h)		;7a36   ; la columna + 1
	and 03fh		;7a39
	inc a			;7a3b
	ld (hl),a			;7a3c
	ld a,001h		;7a3d   ; el sonido 1
	ld (0ec10h),a		;7a3f
	ret			;7a42
tira_no:
	pop af			;7a43
	ret			;7a44
tiro_dibujo:		; El dibujo del sprite 0x58 (0x1AC0) desde HL, empaquetado
	ld de,01ac0h		;7a45
	ld b,001h		;7a48
	jp desempaqueta_vram		;7a4a

; ----------------------------------------------------------------------
; DATOS tiro_datos: El dibujo del tiro (0x7A4D), empaquetado
;   0x7a4d..0x7a63  (22 bytes)
DATA_tiro_datos:
	defb 0ffh,008h,044h,092h,03fh,0fch,008h,052h,008h,0ffh,000h,004h,024h,01ch,078h,008h	; 7a4d  ..D.?..R....$.x.
	defb 034h,000h,094h,000h,018h,000h	; 7a5d

; ======================================================================
; CODIGO 0x7a63..0x7aa8  (69 bytes)
; ======================================================================


sonido_calla:		; Los sonidos (0xEC0D, 0xEC10, 0xEC25, 0xEC30) a 0 y GICINI
	xor a			;7a63
	ld (0ec0dh),a		;7a64
	ld (0ec10h),a		;7a67
	ld (0ec25h),a		;7a6a
	ld (0ec30h),a		;7a6d
	jp 00090h		;7a70   ; GICINI
sonido:		; Los sonidos de cada cuadro: los de 0xEC0D (tabla 0x7AA8) y 0xEC10 (0x7ABE), y las voces de 0x7AC6
	ld hl,0ec0dh		;7a73   ; los sonidos del canal A
	ld de,07aa8h		;7a76
	call estado_salta		;7a79
	ld hl,0ec10h		;7a7c   ; los del canal B
	ld de,07abeh		;7a7f
	call estado_salta		;7a82
	ld hl,07ac6h		;7a85   ; la voz 1 (canal B), desde 0xEC25
	call voz		;7a88
	ld hl,0ec25h		;7a8b   ; la voz 2 pasa a 0xEC25 (y la 1 a 0xEC1A)
	ld de,0ec1ah		;7a8e
	ld bc,00016h		;7a91
	ldir		;7a94
	ld hl,07acdh		;7a96   ; la voz 2 (canal C)
	call voz		;7a99
	ld hl,0ec2fh		;7a9c   ; y cada una a su sitio otra vez
	ld de,0ec3ah		;7a9f
	ld bc,00016h		;7aa2
	lddr		;7aa5
	ret			;7aa7

; ----------------------------------------------------------------------
; DATOS sonidos_a: Los 11 sonidos del canal A (0xEC0D, la cuenta en 0xEC0F)
;   0x7aa8..0x7abe  (22 bytes)
DATA_sonidos_a:
	defb 0d4h,07ah,00ch,07bh,038h,07bh,05eh,07bh,085h,07bh,0aeh,07bh,0f4h,07bh,02bh,07ch	; 7aa8  .z.{8{^{.{.{.{+|
	defb 05fh,07ch,089h,07ch,064h,07bh	; 7ab8

; ----------------------------------------------------------------------
; DATOS sonidos_b: Los 4 sonidos del canal B (0xEC10, la cuenta en 0xEC12)
;   0x7abe..0x7ac6  (8 bytes)
DATA_sonidos_b:
	defb 0d9h,07ch,029h,07dh,0c0h,07ch,059h,07dh	; 7abe  .|)}.|Y}

; ----------------------------------------------------------------------
; DATOS voces: Las dos voces de la musica (7 bytes): registro del tono,
;   registro del volumen, lista de musicas, volumen, y el mezclador (OR, AND):
;   canal B con 0x7E99 y canal C con 0x7EC1
;   0x7ac6..0x7ad4  (14 bytes)
DATA_voces:
	defb 002h,009h,099h,07eh,00ch,090h,0bdh,004h,00ah,0c1h,07eh,00ah,0a0h,0bbh	; 7ac6  ...~......~...

; ======================================================================
; CODIGO 0x7ad4..0x7af2  (30 bytes)
; ======================================================================


sonido_casio:		; Sonido 1, el de CASIO: los 13 primeros registros del PSG de 0x7AF2 (con la envolvente) y 13 cuadros
	ld hl,0ec0fh		;7ad4   ; la cuenta
	ld a,(hl)			;7ad7
	inc (hl)			;7ad8
	or a			;7ad9
	jr nz,sonido_casio_fin		;7ada
	ld hl,07af2h		;7adc   ; 13 registros
	ld b,00dh		;7adf   ; de 0x7AF2
	jp psg_lista		;7ae1
sonido_casio_fin:
	cp 00dh		;7ae4   ; 13 cuadros?
	ret c			;7ae6
	xor a			;7ae7   ; se acaba
	ld (0ec0dh),a		;7ae8
	ld a,004h		;7aeb   ; el registro 4 a 0x20
	ld e,020h		;7aed
	jp 00093h		;7aef

; ----------------------------------------------------------------------
; DATOS sonido_casio_regs: Los 13 registros del sonido de CASIO (registro,
;   valor)
;   0x7af2..0x7b0c  (26 bytes)
DATA_sonido_casio_regs:
	defb 000h,050h,001h,000h,002h,040h,003h,000h,004h,000h,005h,000h,007h,0b8h,008h,010h	; 7af2  .P...@..........
	defb 009h,010h,00ah,010h,00bh,0f6h,00ch,028h,00dh,000h	; 7b02  .......(..

; ======================================================================
; CODIGO 0x7b0c..0x7b22  (22 bytes)
; ======================================================================


sonido_ruido:		; Sonido 2: ruido en el canal A, que sube de 2 en 2 hasta 15
	ld hl,0ec0fh		;7b0c   ; la cuenta
	ld a,(hl)			;7b0f
	or a			;7b10
	jr nz,$+21		;7b11
	inc (hl)			;7b13
	ld de,0b781h		;7b14   ; ruido en A
	call mezclador		;7b17
	ld hl,07b22h		;7b1a   ; 0x7B22
	ld b,002h		;7b1d
	jp psg_lista		;7b1f

; ----------------------------------------------------------------------
; DATOS sonido_ruido_regs: Los registros del sonido 2
;   0x7b22..0x7b26  (4 bytes)
DATA_sonido_ruido_regs:
	defb 006h,019h,008h,000h	; 7b22

; ======================================================================
; CODIGO 0x7b26..0x7b56  (48 bytes)
; ======================================================================


sonido_ruido_sube:
	ld a,008h		;7b26   ; el volumen de A...
	call 00096h		;7b28
	add a,002h		;7b2b   ; ...+ 2
	cp 010h		;7b2d   ; 16: se acaba
	jp nc,sonido_acaba_a		;7b2f
	ld e,a			;7b32
	ld a,008h		;7b33
	jp 00093h		;7b35
sonido_choca:		; Sonido 3: tono y ruido en el canal A, que bajan de volumen cada cuadro
	ld hl,0ec0fh		;7b38   ; la cuenta
	ld a,(hl)			;7b3b
	or a			;7b3c
	jr nz,sonido_baja_a		;7b3d
	inc (hl)			;7b3f
	ld de,0b680h		;7b40   ; tono y ruido en A
	call mezclador		;7b43
	ld hl,07b56h		;7b46   ; 0x7B56
	ld b,004h		;7b49
	jp psg_lista		;7b4b
sonido_baja_a:		; El volumen del canal A uno menos; a 0, el sonido se acaba
	ld a,008h		;7b4e   ; el volumen de A
	ld hl,0ec0dh		;7b50
	jp volumen_baja		;7b53

; ----------------------------------------------------------------------
; DATOS sonido_choca_regs: Los registros del sonido 3
;   0x7b56..0x7b5e  (8 bytes)
DATA_sonido_choca_regs:
	defb 000h,05fh,001h,000h,006h,01eh,008h,00fh	; 7b56  ._......

; ======================================================================
; CODIGO 0x7b5e..0x7b7f  (33 bytes)
; ======================================================================


sonido_4:		; Sonido 4: pasa al 11
	ld a,00bh		;7b5e
	ld (0ec0dh),a		;7b60
	ret			;7b63
sonido_11:		; Sonido 11: un tono que baja de volumen cada 3 cuadros
	ld hl,0ec0fh		;7b64   ; la cuenta
	ld a,(hl)			;7b67
	inc (hl)			;7b68
	or a			;7b69
	jr nz,sonido_11_baja		;7b6a
	ld de,0be88h		;7b6c   ; tono en A
	call mezclador		;7b6f
	ld hl,07b7fh		;7b72   ; 0x7B7F
	jp psg_tres		;7b75
sonido_11_baja:
	cp 003h		;7b78   ; cada 3 cuadros...
	ret c			;7b7a
	ld (hl),001h		;7b7b   ; ...baja
	jr $-47		;7b7d

; ----------------------------------------------------------------------
; DATOS sonido_11_regs: Los registros del sonido 11
;   0x7b7f..0x7b85  (6 bytes)
DATA_sonido_11_regs:
	defb 000h,076h,001h,004h,008h,00fh	; 7b7f

; ======================================================================
; CODIGO 0x7b85..0x7ba8  (35 bytes)
; ======================================================================


sonido_5:		; Sonido 5: un tono que sube (el periodo - 8 cada cuadro) y baja de volumen
	ld hl,0ec0fh		;7b85   ; la cuenta
	ld a,(hl)			;7b88
	inc (hl)			;7b89
	or a			;7b8a
	jr nz,sonido_5_sube		;7b8b
	ld de,0be88h		;7b8d   ; tono en A
	call mezclador		;7b90
	ld hl,07ba8h		;7b93   ; 0x7BA8
	jp psg_tres		;7b96
sonido_5_sube:
	cp 002h		;7b99
	ret c			;7b9b
	ld (hl),001h		;7b9c
	ld a,001h		;7b9e   ; el periodo de A...
	ld hl,0fff8h		;7ba0   ; ...- 8
	call periodo_suma		;7ba3
	jr $-88		;7ba6   ; y baja

; ----------------------------------------------------------------------
; DATOS sonido_5_regs: Los registros del sonido 5
;   0x7ba8..0x7bae  (6 bytes)
DATA_sonido_5_regs:
	defb 000h,0a7h,001h,002h,008h,00fh	; 7ba8

; ======================================================================
; CODIGO 0x7bae..0x7bee  (64 bytes)
; ======================================================================


sonido_6:		; Sonido 6: un tono que tiembla (- 0x20, + 0x40) y baja de volumen
	ld hl,0ec0fh		;7bae   ; la cuenta
	ld a,(hl)			;7bb1
	inc (hl)			;7bb2
	or a			;7bb3
	jr nz,sonido_6_va		;7bb4
	ld de,0be88h		;7bb6   ; tono en A
	call mezclador		;7bb9
	ld hl,07beeh		;7bbc   ; 0x7BEE
	jr $+125		;7bbf
sonido_6_va:
	rra			;7bc1   ; cada dos cuadros
	ret c			;7bc2
	and 001h		;7bc3
	jr z,sonido_6_sube		;7bc5
	ld a,001h		;7bc7   ; + 0x40 al periodo...
	ld hl,00040h		;7bc9
	call periodo_suma		;7bcc
	jp sonido_baja_a		;7bcf   ; ...y baja
sonido_6_sube:
	ld a,001h		;7bd2   ; - 0x20 al periodo
	ld hl,0ffe0h		;7bd4
periodo_suma:		; El periodo del tono de los registros A-1 y A del PSG + HL
	push af			;7bd7
	call 00096h		;7bd8   ; RDPSG, el alto
	ld d,a			;7bdb
	pop af			;7bdc
	dec a			;7bdd
	push af			;7bde
	call 00096h		;7bdf   ; RDPSG, el bajo
	ld e,a			;7be2
	add hl,de			;7be3   ; + HL
	pop af			;7be4
	ld e,l			;7be5
	call 00093h		;7be6   ; WRTPSG
	inc a			;7be9
	ld e,h			;7bea
	jp 00093h		;7beb

; ----------------------------------------------------------------------
; DATOS sonido_6_regs: Los registros del sonido 6
;   0x7bee..0x7bf4  (6 bytes)
DATA_sonido_6_regs:
	defb 000h,0feh,001h,000h,008h,00ch	; 7bee

; ======================================================================
; CODIGO 0x7bf4..0x7c25  (49 bytes)
; ======================================================================


sonido_7:		; Sonido 7: tres notas cortas (0xCA, nada, 0xE3) y fuera
	ld hl,0ec0fh		;7bf4   ; la cuenta
	ld a,(hl)			;7bf7
	inc (hl)			;7bf8
	or a			;7bf9
	jr nz,sonido_7_va		;7bfa
	ld de,0be88h		;7bfc   ; tono en A
	call mezclador		;7bff
	ld hl,07c25h		;7c02   ; 0x7C25
	jr $+55		;7c05
sonido_7_va:
	cp 002h		;7c07   ; el cuadro 2: nada
	ld e,000h		;7c09
	jr z,sonido_nota_a		;7c0b
	cp 003h		;7c0d   ; el 3: 0xE3
	ld e,0e3h		;7c0f
	jr z,sonido_nota_a		;7c11
	cp 006h		;7c13   ; el 6: se acaba
	ret c			;7c15
sonido_acaba_a:		; El sonido del canal A se acaba: volumen 0
	xor a			;7c16
	ld (0ec0dh),a		;7c17
	ld a,008h		;7c1a
	ld e,000h		;7c1c
	jp 00093h		;7c1e
sonido_nota_a:		; El periodo bajo del canal A = E
	xor a			;7c21
	jp 00093h		;7c22

; ----------------------------------------------------------------------
; DATOS sonido_7_regs: Los registros del sonido 7
;   0x7c25..0x7c2b  (6 bytes)
DATA_sonido_7_regs:
	defb 000h,0cah,001h,000h,008h,00ch	; 7c25

; ======================================================================
; CODIGO 0x7c2b..0x7c59  (46 bytes)
; ======================================================================


sonido_8:		; Sonido 8: lo mismo con 0x81, nada y 0xA7
	ld hl,0ec0fh		;7c2b   ; la cuenta
	ld a,(hl)			;7c2e
	inc (hl)			;7c2f
	or a			;7c30
	jr nz,sonido_8_va		;7c31
	ld de,0be88h		;7c33   ; tono en A
	call mezclador		;7c36
	ld hl,07c59h		;7c39   ; 0x7C59
psg_tres:		; Tres registros del PSG de la lista HL (registro, valor)
	ld b,003h		;7c3c
psg_lista:		; B registros del PSG de la lista HL
	ld a,(hl)			;7c3e   ; el registro
	inc hl			;7c3f
	ld e,(hl)			;7c40   ; el valor
	inc hl			;7c41
	call 00093h		;7c42   ; WRTPSG
	djnz psg_lista		;7c45   ; uno menos
	ret			;7c47
sonido_8_va:
	cp 003h		;7c48   ; el cuadro 3: nada
	ld e,000h		;7c4a
	jr z,$-43		;7c4c
	cp 004h		;7c4e   ; el 4: 0xA7
	ld e,0a7h		;7c50
	jr z,$-49		;7c52
	cp 008h		;7c54   ; el 8: se acaba
	ret c			;7c56
	jr $-65		;7c57

; ----------------------------------------------------------------------
; DATOS sonido_8_regs: Los registros del sonido 8
;   0x7c59..0x7c5f  (6 bytes)
DATA_sonido_8_regs:
	defb 000h,081h,001h,000h,008h,00ch	; 7c59

; ======================================================================
; CODIGO 0x7c5f..0x7c83  (36 bytes)
; ======================================================================


sonido_9:		; Sonido 9: una nota grave (0x6AF) que en el cuadro 5 baja a 10 y luego cada 4 cuadros
	ld hl,0ec0fh		;7c5f   ; la cuenta
	ld a,(hl)			;7c62
	inc (hl)			;7c63
	or a			;7c64
	jr nz,sonido_9_va		;7c65
	ld de,0be88h		;7c67   ; tono en A
	call mezclador		;7c6a
	ld hl,07c83h		;7c6d   ; 0x7C83
	jr $-52		;7c70
sonido_9_va:
	cp 005h		;7c72   ; el cuadro 5: volumen 10
	jr nz,sonido_9_baja		;7c74
	ld a,008h		;7c76
	ld e,00ah		;7c78
	jp 00093h		;7c7a
sonido_9_baja:
	and 003h		;7c7d   ; cada 4 cuadros, baja
	ret nz			;7c7f
	jp sonido_baja_a		;7c80

; ----------------------------------------------------------------------
; DATOS sonido_9_regs: Los registros del sonido 9
;   0x7c83..0x7c89  (6 bytes)
DATA_sonido_9_regs:
	defb 000h,0afh,001h,006h,008h,00fh	; 7c83

; ======================================================================
; CODIGO 0x7c89..0x7cba  (49 bytes)
; ======================================================================


sonido_10:		; Sonido 10: 32 cuadros de 0x8F, 0xAA y nada, de 8 en 8
	ld hl,0ec0fh		;7c89   ; la cuenta
	ld a,(hl)			;7c8c
	inc (hl)			;7c8d
	or a			;7c8e
	jr nz,sonido_10_va		;7c8f
	ld de,0be88h		;7c91   ; tono en A
	call mezclador		;7c94
	ld hl,07cbah		;7c97   ; 0x7CBA
	jr $-94		;7c9a
sonido_10_va:
	cp 020h		;7c9c   ; 32 cuadros: se acaba
	jp nc,sonido_acaba_a		;7c9e
	and 007h		;7ca1   ; cada 8...
	jr nz,sonido_10_aa		;7ca3
	ld e,08fh		;7ca5
	jr sonido_10_nota		;7ca7
sonido_10_aa:
	cp 003h		;7ca9
	jr nz,sonido_10_nada		;7cab
	ld e,0aah		;7cad
	jr sonido_10_nota		;7caf
sonido_10_nada:
	cp 006h		;7cb1
	ret nz			;7cb3
	ld e,000h		;7cb4
sonido_10_nota:
	xor a			;7cb6
	jp 00093h		;7cb7

; ----------------------------------------------------------------------
; DATOS sonido_10_regs: Los registros del sonido 10
;   0x7cba..0x7cc0  (6 bytes)
DATA_sonido_10_regs:
	defb 000h,08fh,001h,000h,008h,00ch	; 7cba

; ======================================================================
; CODIGO 0x7cc0..0x7d21  (97 bytes)
; ======================================================================


sonido_b3:		; Sonido 3 del canal B: como el 1, con el volumen subiendo cada 4 cuadros
	ld hl,0ec12h		;7cc0   ; la cuenta
	ld a,(hl)			;7cc3
	inc (hl)			;7cc4
	or a			;7cc5
	jr z,sonido_b_empieza		;7cc6
	ld a,003h		;7cc8   ; el periodo de B - 2
	ld hl,0fffeh		;7cca
	call periodo_suma		;7ccd
	ld hl,0ec12h		;7cd0
	ld a,(hl)			;7cd3
	cp 004h		;7cd4   ; cada 4 cuadros, sube
	jr nc,sonido_b_sube		;7cd6
	ret			;7cd8
sonido_b1:		; Sonido 1 del canal B, el del tiro: tono y ruido que suben de volumen (cada 2 cuadros) y de tono; con la voz 1 sonando, nada
	ld hl,0ec12h		;7cd9   ; la cuenta
	ld a,(hl)			;7cdc
	inc (hl)			;7cdd
	or a			;7cde
	jr nz,sonido_b1_va		;7cdf
sonido_b_empieza:
	ld a,(0ec25h)		;7ce1   ; la voz 1 sonando?
	or a			;7ce4
	jr nz,sonido_acaba_b		;7ce5
	ld de,0ad80h		;7ce7   ; tono y ruido en B
	call mezclador		;7cea
	ld hl,07d21h		;7ced   ; 0x7D21
	ld b,004h		;7cf0
	jp psg_lista		;7cf2
sonido_b1_va:
	ld a,003h		;7cf5   ; el periodo de B - 2
	ld hl,0fffeh		;7cf7
	call periodo_suma		;7cfa
	ld hl,0ec12h		;7cfd
	ld a,(hl)			;7d00
	cp 002h		;7d01   ; cada 2 cuadros...
	ret c			;7d03
sonido_b_sube:
	ld (hl),001h		;7d04
	ld a,009h		;7d06   ; ...el volumen de B + 1
	call 00096h		;7d08
	inc a			;7d0b
	cp 010h		;7d0c   ; 16: se acaba
	jr nc,sonido_acaba_b		;7d0e
	ld e,a			;7d10
	ld a,009h		;7d11
	jp 00093h		;7d13
sonido_acaba_b:		; El sonido del canal B se acaba: volumen 0
	xor a			;7d16
	ld (0ec10h),a		;7d17
	ld a,009h		;7d1a
	ld e,000h		;7d1c
	jp 00093h		;7d1e

; ----------------------------------------------------------------------
; DATOS sonido_b1_regs: Los registros del sonido 1 del canal B
;   0x7d21..0x7d29  (8 bytes)
DATA_sonido_b1_regs:
	defb 002h,076h,003h,004h,006h,01fh,009h,000h	; 7d21  .v......

; ======================================================================
; CODIGO 0x7d29..0x7d4f  (38 bytes)
; ======================================================================


sonido_b2:		; Sonido 2 del canal B: dos notas (0x476 y 0x3C0) en 15 cuadros
	ld hl,0ec12h		;7d29   ; la cuenta
	ld a,(hl)			;7d2c
	inc (hl)			;7d2d
	or a			;7d2e
	jr nz,sonido_b2_va		;7d2f
	ld de,0bd90h		;7d31   ; tono en B
	call mezclador		;7d34
	ld hl,07d4fh		;7d37   ; 0x7D4F
	jp psg_tres		;7d3a
sonido_b2_va:
	cp 007h		;7d3d   ; el cuadro 7: la segunda
	ret c			;7d3f
	jr nz,sonido_b2_fin		;7d40
	ld hl,07d55h		;7d42
	ld b,002h		;7d45
	jp psg_lista		;7d47
sonido_b2_fin:
	cp 00fh		;7d4a   ; el 15: se acaba
	ret c			;7d4c
	jr $-55		;7d4d

; ----------------------------------------------------------------------
; DATOS sonido_b2_regs: Los registros del sonido 2 del canal B
;   0x7d4f..0x7d59  (10 bytes)
DATA_sonido_b2_regs:
	defb 002h,076h,003h,004h,009h,00fh,002h,0c0h,003h,003h	; 7d4f  .v........

; ======================================================================
; CODIGO 0x7d59..0x7d77  (30 bytes)
; ======================================================================


sonido_b4:		; Sonido 4 del canal B: un tono que sube (el periodo - 0x14 cada cuadro) y baja de volumen
	ld hl,0ec12h		;7d59   ; la cuenta
	ld a,(hl)			;7d5c
	or a			;7d5d
	jr nz,sonido_b4_va		;7d5e
	inc (hl)			;7d60
	ld de,0bd90h		;7d61   ; tono en B
	call mezclador		;7d64
	ld hl,07d77h		;7d67   ; 0x7D77
	jp psg_tres		;7d6a
sonido_b4_va:
	ld a,003h		;7d6d   ; el periodo de B - 0x14
	ld hl,0ffech		;7d6f
	call periodo_suma		;7d72
	jr $+8		;7d75

; ----------------------------------------------------------------------
; DATOS sonido_b4_regs: Los registros del sonido 4 del canal B
;   0x7d77..0x7d7d  (6 bytes)
DATA_sonido_b4_regs:
	defb 002h,064h,003h,000h,009h,00fh	; 7d77

; ======================================================================
; CODIGO 0x7d7d..0x7e79  (252 bytes)
; ======================================================================


sonido_baja_b:		; El volumen del canal B uno menos; a 0, se acaba
	ld a,009h		;7d7d
	ld hl,0ec10h		;7d7f
volumen_baja:		; El volumen del registro A uno menos; por debajo de 0, (HL) = 0: el sonido se acaba
	ld d,a			;7d82
	call 00096h		;7d83   ; RDPSG
	dec a			;7d86
	jp m,volumen_baja_fin		;7d87
	ld e,a			;7d8a
	ld a,d			;7d8b
	jp 00093h		;7d8c   ; WRTPSG
volumen_baja_fin:
	ld (hl),000h		;7d8f
	ret			;7d91
mezclador:		; El registro 7 del PSG (el mezclador) AND D OR E
	ld a,007h		;7d92
	call 00096h		;7d94   ; RDPSG
	and d			;7d97
	or e			;7d98
	ld e,a			;7d99
	ld a,007h		;7d9a
	jp 00093h		;7d9c   ; WRTPSG
voz:		; Una voz de la musica (cabecera HL a 0xEC13; su estado en 0xEC25: la musica, la que sonaba, el sitio en la lista, el sitio en las notas, la duracion, el volumen, la cuenta para bajarlo): si la musica cambia, la busca en la lista y empieza; si no, sigue
	ld de,0ec13h		;7d9f   ; la cabecera
	ld bc,00007h		;7da2
	ldir		;7da5
	ld a,(0ec26h)		;7da7   ; la que sonaba
	ld b,a			;7daa
	ld a,(0ec25h)		;7dab   ; la pedida
	cp b			;7dae
	jr z,voz_sigue		;7daf   ; la misma: sigue
	ld b,a			;7db1
	ld (0ec26h),a		;7db2   ; apuntada
	or a			;7db5   ; 0: calla
	jr z,voz_calla		;7db6
	xor a			;7db8   ; se acaba el sonido de B
	ld (0ec10h),a		;7db9
	ld a,(0ec17h)		;7dbc   ; el volumen
	ld (0ec2eh),a		;7dbf
	ld a,004h		;7dc2   ; 4 cuadros para bajarlo
	ld (0ec2fh),a		;7dc4
	ld de,(0ec18h)		;7dc7   ; el mezclador
	call mezclador		;7dcb
voz_busca:
	ld hl,(0ec15h)		;7dce   ; la lista de musicas
voz_busca_otra:
	dec b			;7dd1   ; la musica B-1...
	jr z,voz_trozo		;7dd2
voz_busca_trozo:
	ld e,(hl)			;7dd4   ; un trozo
	inc hl			;7dd5
	ld d,(hl)			;7dd6
	inc hl			;7dd7
	ld a,e			;7dd8   ; 0x0000 o 0xFFFF?
	cp d			;7dd9
	jr nz,voz_busca_trozo		;7dda
	or a			;7ddc
	jr z,voz_busca_otra		;7ddd
	inc a			;7ddf
	jr z,voz_busca_otra		;7de0
	jr voz_busca_trozo		;7de2
voz_trozo:
	ld e,(hl)			;7de4   ; el primer trozo
	inc hl			;7de5
	ld d,(hl)			;7de6
	inc hl			;7de7
voz_trozo_pon:
	ld (0ec27h),hl		;7de8   ; el sitio en la lista
	ex de,hl			;7deb
	ld (0ec29h),hl		;7dec   ; el sitio en las notas
	ld a,001h		;7def   ; ya
	ld (0ec2bh),a		;7df1
	ld (0ec2ch),a		;7df4
voz_sigue:
	or a			;7df7   ; sin musica
	ret z			;7df8
	call voz_nota		;7df9   ; una nota
	ret nz			;7dfc   ; sigue la nota
	ld hl,(0ec27h)		;7dfd   ; se acaba el trozo: el siguiente
	ld e,(hl)			;7e00
	inc hl			;7e01
	ld d,(hl)			;7e02
	inc hl			;7e03
	ld a,d			;7e04   ; 0xFFFF: se acaba
	and e			;7e05
	inc a			;7e06
	jr z,voz_acaba		;7e07
	ld a,d			;7e09   ; 0x0000: otra vez
	or e			;7e0a
	jr nz,voz_trozo_pon		;7e0b
	ld a,(0ec26h)		;7e0d
	ld b,a			;7e10
	jr voz_busca		;7e11
voz_acaba:
	ld (0ec25h),a		;7e13
	ld (0ec26h),a		;7e16
voz_calla:
	ld a,(0ec14h)		;7e19   ; volumen 0
	ld e,000h		;7e1c
	jp 00093h		;7e1e
voz_nota:		; Cada 4 cuadros el volumen baja uno; acabada la duracion, la nota siguiente (duracion, nota; 0 la pausa, de 0x7E79): NZ si sigue
	ld hl,0ec2fh		;7e21   ; 4 cuadros?
	dec (hl)			;7e24
	jr nz,voz_nota_dura		;7e25
	ld (hl),004h		;7e27
	ld a,(0ec14h)		;7e29   ; RDPSG el volumen...
	call 00096h		;7e2c
	dec a			;7e2f   ; ...uno menos
	jp m,voz_nota_dura		;7e30
	ld e,a			;7e33
	ld a,(0ec14h)		;7e34
	call 00093h		;7e37
voz_nota_dura:
	ld hl,0ec2ch		;7e3a   ; la duracion
	dec (hl)			;7e3d
	ret nz			;7e3e
	ld hl,(0ec29h)		;7e3f   ; las notas
	ld a,(hl)			;7e42
	or a			;7e43   ; 0: se acaba
	ret z			;7e44
	ld (0ec2ch),a		;7e45   ; la duracion
	inc hl			;7e48
	ld a,(hl)			;7e49   ; la nota
	inc hl			;7e4a
	ld (0ec29h),hl		;7e4b
	or a			;7e4e   ; pausa?
	jr z,voz_pausa		;7e4f
	ld hl,07e79h		;7e51   ; su periodo
	dec a			;7e54
	add a,a			;7e55
	ld e,a			;7e56
	ld d,000h		;7e57
	add hl,de			;7e59
	ld e,(hl)			;7e5a
	ld a,(0ec13h)		;7e5b   ; el registro del tono
	call 00093h		;7e5e
	inc hl			;7e61
	ld e,(hl)			;7e62   ; y el alto
	inc a			;7e63
	call 00093h		;7e64
	ld a,(0ec2eh)		;7e67   ; el volumen
	ld e,a			;7e6a
voz_nota_volumen:
	ld a,(0ec14h)		;7e6b
	call 00093h		;7e6e
	ld a,001h		;7e71   ; NZ
	or a			;7e73
	ret			;7e74
voz_pausa:
	ld e,000h		;7e75   ; volumen 0
	jr voz_nota_volumen		;7e77

; ----------------------------------------------------------------------
; DATOS notas_periodos: Los periodos de las 16 notas: do3, mi3, fa3, sol3,
;   la3, si3, do4, re4, mi4, fa4, sol4, la4, si4, do5, re5, la5
;   0x7e79..0x7e99  (32 bytes)
DATA_notas_periodos:
	defb 057h,003h,0a7h,002h,081h,002h,03bh,002h,0fdh,001h,0c5h,001h,0ach,001h,07dh,001h	; 7e79  W.....;.......}.
	defb 053h,001h,040h,001h,01dh,001h,0feh,000h,0e3h,000h,0d6h,000h,0beh,000h,07fh,000h	; 7e89  S.@.............

; ----------------------------------------------------------------------
; DATOS musicas_b: Las 6 musicas de la voz 1 (canal B): los trozos de cada
;   una, hasta 0xFFFF
;   0x7e99..0x7ec1  (40 bytes)
DATA_musicas_b:
	defb 069h,07fh,002h,07fh,06eh,07fh,0ffh,0ffh,0e2h,07fh,0ffh,0ffh,0f9h,07eh,002h,07fh	; 7e99  i...n........~..
	defb 00bh,07fh,02eh,07fh,0ffh,0ffh,081h,07fh,0ffh,0ffh,0f9h,07eh,002h,07fh,02eh,07fh	; 7ea9  ...........~....
	defb 0e7h,07fh,0ffh,0ffh,0f1h,07fh,0ffh,0ffh	; 7eb9  ........

; ----------------------------------------------------------------------
; DATOS musicas_c: Las 6 musicas de la voz 2 (canal C)
;   0x7ec1..0x7ef9  (56 bytes)
DATA_musicas_c:
	defb 075h,07fh,03bh,07fh,07ah,07fh,0ffh,0ffh,081h,07fh,0ffh,0ffh,03bh,07fh,03bh,07fh	; 7ec1  u.;.z.......;.;.
	defb 042h,07fh,04fh,07fh,03bh,07fh,05ch,07fh,0ffh,0ffh,0bch,07fh,0bch,07fh,0c5h,07fh	; 7ed1  B.O.;.\.........
	defb 0c5h,07fh,0ceh,07fh,0ceh,07fh,0d7h,07fh,0ffh,0ffh,03bh,07fh,03bh,07fh,05ch,07fh	; 7ee1  ..........;.;.\.
	defb 0ech,07fh,0ffh,0ffh,0f1h,07fh,0ffh,0ffh	; 7ef1  ........

; ----------------------------------------------------------------------
; DATOS musicas_notas: Los trozos: parejas (duracion en cuadros, nota) hasta
;   un 0
;   0x7ef9..0x7ffc  (259 bytes)
DATA_musicas_notas:
	defb 00ch,00eh,004h,00dh,00ch,00ch,004h,00bh,000h,00ch,009h,004h,00bh,00ch,00ch,004h	; 7ef9  ................
	defb 00dh,000h,008h,00eh,008h,00fh,008h,000h,018h,00eh,004h,009h,008h,00ah,004h,00bh	; 7f09  ................
	defb 010h,00ch,010h,009h,00ch,00dh,004h,00ch,00ch,00bh,004h,009h,00ch,007h,004h,009h	; 7f19  ................
	defb 00ch,00bh,004h,00ch,000h,005h,00ah,005h,00bh,006h,00ch,005h,00bh,005h,00ch,006h	; 7f29  ................
	defb 00dh,000h,010h,001h,00ch,002h,004h,002h,000h,010h,003h,00ch,005h,004h,005h,010h	; 7f39  ................
	defb 003h,00ch,005h,004h,005h,000h,010h,004h,00ch,006h,004h,006h,010h,004h,00ch,006h	; 7f49  ................
	defb 004h,006h,000h,005h,003h,005h,004h,006h,005h,005h,004h,005h,005h,006h,006h,000h	; 7f59  ................
	defb 010h,00eh,010h,00bh,000h,008h,00bh,010h,009h,028h,007h,000h,010h,001h,010h,002h	; 7f69  .........(......
	defb 000h,008h,001h,010h,002h,028h,001h,000h,00ah,00bh,00ah,00bh,00ah,00ch,00ah,00bh	; 7f79  .....(..........
	defb 00ah,00ch,00ah,00bh,00ah,00ch,00ah,00bh,00ah,00ch,00ah,00ch,00ah,00dh,00ah,00ch	; 7f89  ................
	defb 00ah,00dh,00ah,00ch,00ah,00dh,00ah,00ch,00ah,00dh,00ah,00dh,00ah,00eh,00ah,00dh	; 7f99  ................
	defb 00ah,00eh,00ah,00dh,00ah,00eh,00ah,00dh,00ah,00ch,00ah,00ch,00ah,00dh,00ah,00dh	; 7fa9  ................
	defb 014h,00eh,000h,00ah,007h,00ah,007h,00ah,009h,00ah,007h,000h,00ah,007h,00ah,007h	; 7fb9  ................
	defb 00ah,00ah,00ah,007h,000h,00ah,008h,00ah,008h,00ah,00bh,00ah,008h,000h,00ah,00ah	; 7fc9  ................
	defb 00ah,00ah,00ah,00bh,00ah,00bh,014h,00bh,000h,004h,010h,003h,000h,000h,010h,00eh	; 7fd9  ................
	defb 010h,007h,000h,010h,007h,010h,000h,000h,006h,001h,006h,002h,006h,004h,006h,005h	; 7fe9  ................
	defb 006h,007h,000h	; 7ff9

; ----------------------------------------------------------------------
; DATOS relleno_final: Relleno (0xFF)
;   0x7ffc..0x8000  (4 bytes)
DATA_relleno_final:
	defb 0ffh,0ffh,0ffh,0ffh	; 7ffc
