# EL FINAL DE LA ISLA. Al encender, la tecla 0 pulsada (0xE000 bit 7: no se pierden vidas, 0x5DAD); se suelta en
# el primer cuadro. En el titulo, la barra 2 s despues. Un jugador al azar (como partida.tcl) en la isla 1 durante
# 300 cuadros en juego; despues, con el en pie (estado 2, el que mira 0xEAE4), FORZADO, 0xEAE4 = 0xFF, lo que deja el protagonista al tocar la meta (0x60A0): el
# juego sigue solo (el pajaro viene a por el, la cuenta de la fuerza, el cartel y la isla 2). Acaba 300 cuadros
# despues de llegar a la isla 2.
keymatrixdown 0 0x01
expr {srand(5)}
proc m {a} { return [debug read memory $a] }
proc toca {} {
    keymatrixdown 8 0x01
    after time 0.05 { keymatrixup 8 0x01 }
}
set ::jugados 0
proc guion {n} {
    if {$n == 1} { keymatrixup 0 0x01 }
    if {[m 0xEAB1] == 2 && ![info exists ::empezada]} {
        set ::empezada 1
        after time 2 toca
    }
    if {![info exists ::empezada]} { return 0 }
    if {[m 0xE002] == 2} {
        keymatrixup 8 0xF1
        if {![info exists ::isla2]} { set ::isla2 $n }
        return [expr {$n >= $::isla2 + 600}]
    }
    set p [m 0xEAD3]
    if {[m 0xEAB1] == 0 && [lsearch {8 14 11 0} $p] < 0 && ![info exists ::forzado]} {
        incr ::jugados
        if {$n % 30 == 0} { toca }
        if {$n % 20 == 0} {
            keymatrixup 8 0xF0
            set k [lindex {0x10 0x80 0x80 0x20 0x40 0x00 0x90} [expr {int(rand() * 7)}]]
            if {$k} { keymatrixdown 8 $k }
        }
        if {$::jugados >= 300 && $p == 2} {
            set ::forzado $n
            keymatrixup 8 0xF1
            debug write memory 0xEAE4 0xFF
        }
    }
    return [expr {$n >= 8000}]
}
