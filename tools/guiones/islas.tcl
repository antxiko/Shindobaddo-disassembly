# LAS SIETE ISLAS. Al encender, las teclas 0, 2 y 3 pulsadas: el juego las lee en INIT (0x4026) y las guarda en
# 0xE000; las 2 y 3 (bits 1 y 2) eligen la isla de salida (0x4103: 6 + 1 = la 7) y la 0 (bit 7) hace que no se
# pierdan vidas (0x5DAD). Se sueltan en el primer cuadro. En el titulo, la barra 2 s despues. En cada isla, un
# jugador al azar (la palanca cada 20 cuadros, la barra cada 30) durante 500 cuadros con el protagonista en juego;
# despues, FORZADO, la isla siguiente: 0xE002 = la isla y el estado general 4, el mismo que pone el juego al
# acabar una isla (0x585B). Orden: 7, 1, 2, 3, 4, 5, 6.
keymatrixdown 0 0x0D
expr {srand(11)}
proc m {a} { return [debug read memory $a] }
proc toca {} {
    keymatrixdown 8 0x01
    after time 0.05 { keymatrixup 8 0x01 }
}
set ::orden {1 2 3 4 5 6}
set ::jugados 0
proc guion {n} {
    if {$n == 1} { keymatrixup 0 0x0D }
    if {[m 0xEAB1] == 2 && ![info exists ::empezada]} {
        set ::empezada 1
        after time 2 toca
    }
    if {![info exists ::empezada]} { return 0 }
    # en juego: el estado general 0 y el protagonista en pie, andando, saltando...
    set p [m 0xEAD3]
    if {[m 0xEAB1] == 0 && [lsearch {8 14 11 0} $p] < 0} {
        incr ::jugados
        if {$n % 30 == 0} { toca }
        if {$n % 20 == 0} {
            keymatrixup 8 0xF0
            set k [lindex {0x10 0x80 0x80 0x20 0x40 0x00 0x90} [expr {int(rand() * 7)}]]
            if {$k} { keymatrixdown 8 $k }
        }
        if {$::jugados >= 500} {
            keymatrixup 8 0xF1
            set ::jugados 0
            if {[llength $::orden] == 0} { return 1 }
            debug write memory 0xE002 [lindex $::orden 0]
            set ::orden [lrange $::orden 1 end]
            debug write memory 0xEAB1 4
        }
    }
    return [expr {$n >= 12000}]
}
