# archivo.tcl

### ESTE VALOR ES EL QUE SE CAMBIA PARA AUMENTAR LA ESCALA
### BASICAMENTE CREA UNA CUADRICULA DE largo x largo
### AHORA ES UNA VARIABLE QUE ENTRA COMO ARGUMENTO DESDE
### LA TERMINAL, ADEMAS SE PUEDE ESCOGER SI SE CORRE O NO
### LA SIMULACION GRAFICA, PARA ELLO SE ESCRIBE COMO SEGUNDO
### ARGUMENTO CUALQUIER VALOR.
### ESTE ES EL COMANDO EN LA TERMINAL SIN SIMULACION GRAFICA:
###             ns archivo.tcl <numero>
### ESTE ES EL COMANDO EN LA TERMINAL CON SIMULACION GRAFICA
###             ns archivo.tcl <numero> <numero/letra/string>

set largo [lindex $argv 0]
set MAX_VAL [expr $largo ** 2]
if {$argc == 2} {
    set run_simulation 1
} else {
    set run_simulation 0
}

# Define a 'finish' procedure
proc finish { run_simulation } {
    global ns nf tracefile
    $ns flush-trace

    # Close the NAM trace file
    close $nf

    # Execute NAM on the trace file
    if { $run_simulation == 1 } {
        puts "Simulacion grafica activada"
        exec nam out.nam &
    } else {
        puts "Se ejecuto el script sin simulacion grafica"
    }
    exit 0
}

proc round_2_decimal {x} {
    return [expr {double(round(100*$x))/100}]
}

proc distancia {x1 x2 y1 y2} {
    set d [expr {sqrt( ($x1 - $x2) ** 2 + ($y1 - $y2) ** 2)} ]
    set result [round_2_decimal $d]
    return $result
}

proc delay_link {x1 x2 y1 y2} {
    set val [distancia $x1 $x2 $y1 $y2]
    return [expr {$val * 10}]
}

# Create a simulator object
set ns [new Simulator]

# Define different colors
# for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

# Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#crear archivo trace
set tracefile [open out.tr w]
$ns trace-all $tracefile



### crea todos los nodos de la cuadricula
for {set k 0} {$k < $MAX_VAL} {incr k} {
    set n($k) [$ns node]
}


### crea las coordenadas x para los nodos en el terreno
set index 0
for {set k 0} {$k < $largo} {incr k} {
    for {set j 0} {$j < $largo} {incr j} {
        set x([expr $index]) [expr $j]
        set index [expr $index + 1]
    }
}

## crea el vector de coordenadas y para los nodos del terreno
for {set k 0} {$k < $MAX_VAL} {incr k} {
    set y($k) [expr $k / $largo]
}


## crea los links que enlazan el arbol, segun las distancias de la
## cuadricula para los nodos se crea un delay que es proporcional
## a dichas distancias
set value 0
for {set j 1} {$j < $MAX_VAL} {incr j} {
    set h [expr {($j - 1) / 2}]
    set d [delay_link $x($j) $x($h) $y($j) $y($h)]
    $ns duplex-link $n($j) $n($h) 2Mb [expr $d]ms DropTail
}


## crear los vectores de fuente y destino para el trafico

for {set k 0} {$k < $MAX_VAL} {incr k} {
    set destino($k) $k
    if { $k == 0 } {
        set fuente($k) [expr {$MAX_VAL - 1}]
    } else {
        set fuente($k) 0
    }
}

for {set k 0} {$k < $MAX_VAL} {incr k} {
    set udp([expr $k]) [new Agent/UDP]
    $udp([expr $k]) set class_ $k
    set value $fuente($k)
    $ns attach-agent $n($value) $udp([expr $k])

    set cbr([expr $k]) [new Application/Traffic/CBR]
    $cbr([expr $k]) set packetSize_ 100
    $cbr([expr $k]) set interval_ 0.01
    $cbr([expr $k]) attach-agent $udp([expr $k])

    set null([expr $k]) [new Agent/Null]
    $ns attach-agent $n($destino($k)) $null([expr $k])

    $ns connect $udp($k) $null($k)

    if { $k == 0 } {
        $ns at 0.5 "$cbr($k) start"
        $ns at 2.5 "$cbr($k) stop"
    } else {
        $ns at 2.6 "$cbr($k) start"
        $ns at 4.5 "$cbr($k) stop"
    }
}

$ns at 100.0 "finish $run_simulation"
$ns run

