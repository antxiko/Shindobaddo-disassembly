# UNA PARTIDA, sin teclas al encender. En el titulo, la barra 2 s despues. Un jugador al azar (la palanca cada 20
# cuadros, la barra cada 30 y GRAPH, el golpe, cada 45) en la isla 1 durante 700 cuadros en juego; despues,
# FORZADO, 0xEAE4 = 0xFF: lo mismo que deja el protagonista al tocar la meta (0x60A0), y el juego sigue solo: el
# pajaro viene a por el, la cuenta de la fuerza y la isla 2. Alli, 400 cuadros mas al azar y, FORZADO, una
# sola vida (0xEAE3 = 1): el juego sigue al azar hasta perderla y GAME OVER. Acaba 400 cuadros despues.
expr {srand(5)}
proc m {a} { return [debug read memory $a] }
proc toca {} {
    keymatrixdown 8 0x01
    after time 0.05 { keymatrixup 8 0x01 }
}
proc golpe {} {
    keymatrixdown 6 0x04
    after time 0.05 { keymatrixup 6 0x04 }
}
set ::jugados 0
set ::fase 0
proc guion {n} {
    if {[m 0xEAB1] == 2 && ![info exists ::empezada]} {
        set ::empezada 1
        after time 2 toca
    }
    if {![info exists ::empezada]} { return 0 }
    if {[m 0xEAB1] == 5 && ![info exists ::fin]} { set ::fin $n }
    if {[info exists ::fin]} {
        keymatrixup 8 0xF1
        return [expr {$n >= $::fin + 400}]
    }
    set p [m 0xEAD3]
    if {[m 0xEAB1] == 0 && [lsearch {8 14 11 0} $p] < 0} {
        incr ::jugados
        if {$n % 30 == 0} { toca }
        if {$n % 45 == 0} { golpe }
        if {$n % 20 == 0} {
            keymatrixup 8 0xF0
            set k [lindex {0x10 0x80 0x80 0x20 0x40 0x00 0x90} [expr {int(rand() * 7)}]]
            if {$k} { keymatrixdown 8 $k }
        }
        if {$::fase == 0 && $::jugados >= 700} {
            set ::fase 1
            set ::jugados 0
            keymatrixup 8 0xF1
            debug write memory 0xEAE4 0xFF
        } elseif {$::fase == 1 && [m 0xE002] == 2 && $::jugados >= 400} {
            set ::fase 2
            debug write memory 0xEAE3 1
        }
    }
    return [expr {$n >= 15000}]
}
