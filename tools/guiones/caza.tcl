# A POR LOS ENEMIGOS. Con la tecla 0 al encender (0xE000 bit 7: no se pierden vidas); en el titulo, la barra 2 s
# despues. Un jugador que mira la tabla de los objetos (0xEB32, ocho de 6 bytes: en juego con +0 = 0xFF y +1 = 0;
# la fila en +2, la columna en +3): con uno en su fila delante, a 1-4 columnas, el boton 1 (el salto que los
# alcanza, 0x5B81); si lo tiene en su fila mas lejos, anda hacia el; si no hay ninguno en su fila, anda al azar y
# sube o baja por las escaleras. No pisa donde no hay suelo: si la casilla de debajo, dos columnas por delante, no
# es de las del suelo (0x605F: 0x21, 0x23, 0x3C, 0x27, 0x3E), da la vuelta. Nada forzado. 9000 cuadros.
keymatrixdown 0 0x01
expr {srand(3)}
proc m {a} { return [debug read memory $a] }
proc toca {} {
    keymatrixdown 8 0x01
    after time 0.05 { keymatrixup 8 0x01 }
}
proc suelo {hc hf dir} {
    set t [m [expr {0xE01A + ($hf + 3) * 64 + $hc + 2 * $dir}]]
    return [expr {[lsearch {0x21 0x23 0x3C 0x27 0x3E 33 35 60 39 62} $t] >= 0}]
}
proc anda {hc hf dir} {
    if {[suelo $hc $hf $dir]} {
        keymatrixdown 8 [expr {$dir > 0 ? 0x80 : 0x10}]
        return 1
    }
    return 0
}
proc guion {n} {
    if {$n == 1} { keymatrixup 0 0x01 }
    if {[m 0xEAB1] == 2 && ![info exists ::empezada]} {
        set ::empezada 1
        after time 2 toca
    }
    if {![info exists ::empezada] || [m 0xEAB1] != 0} { return [expr {$n >= 9000}] }
    if {[m 0xEAD3] != 2} { return [expr {$n >= 9000}] }
    set hc [m 0xEADC]
    set hf [m 0xEADD]
    set mira [m 0xEADE]
    set mejor 99
    set dx 0
    for {set k 0} {$k < 8} {incr k} {
        set b [expr {0xEB32 + 6 * $k}]
        if {[m $b] != 0xFF || [m [expr {$b + 1}]] != 0} continue
        if {([m [expr {$b + 2}]] & 0x1F) != $hf} continue
        set d [expr {([m [expr {$b + 3}]] & 0x3F) - $hc}]
        if {abs($d) < abs($mejor)} { set mejor $d }
    }
    keymatrixup 8 0xF0
    if {$mejor != 99} {
        if {($mira == 0 && $mejor >= 1 && $mejor <= 4) || ($mira != 0 && $mejor <= -1 && $mejor >= -4)} {
            if {$n % 4 == 0} { toca }
        } elseif {![anda $hc $hf [expr {$mejor > 0 ? 1 : -1}]]} {
            set mejor 99
        }
    }
    if {$mejor == 99} {
        if {![info exists ::rumbo] || $n % 90 == 0} {
            set ::rumbo [lindex {1 -1 1 -1} [expr {int(rand() * 4)}]]
            set ::vertical [lindex {0x00 0x20 0x40 0x00} [expr {int(rand() * 4)}]]
        }
        if {![anda $hc $hf $::rumbo]} { set ::rumbo [expr {-$::rumbo}] }
        if {$::vertical} { keymatrixdown 8 $::vertical }
    }
    return [expr {$n >= 9000}]
}
