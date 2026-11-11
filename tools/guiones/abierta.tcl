# LA MUSICA 6, la de la isla abierta (todas las cosas cogidas, 0x5C28), FORZADA: ningun guion al azar coge las
# cosas. Con la tecla 0 al encender y sin tocar nada mas que la barra en el titulo; con el protagonista en pie en
# la isla 1, 0xEC25 = 0xEC30 = 6, lo mismo que escribe el juego en 0x5C2A. Acaba 900 cuadros despues.
keymatrixdown 0 0x01
proc m {a} { return [debug read memory $a] }
proc toca {} {
    keymatrixdown 8 0x01
    after time 0.05 { keymatrixup 8 0x01 }
}
proc guion {n} {
    if {$n == 1} { keymatrixup 0 0x01 }
    if {[m 0xEAB1] == 2 && ![info exists ::empezada]} {
        set ::empezada 1
        after time 2 toca
    }
    if {[info exists ::empezada] && ![info exists ::puesta] && [m 0xEAB1] == 0 && [m 0xEAD3] == 2 && [m 0xEC25] == 0} {
        set ::puesta $n
        debug write memory 0xEC25 6
        debug write memory 0xEC30 6
    }
    if {[info exists ::puesta]} { return [expr {$n >= $::puesta + 900}] }
    return [expr {$n >= 4000}]
}
