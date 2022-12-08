# archivo.tcl

### ESTE VALOR ES EL QUE SE CAMBIA PARA AUMENTAR LA ESCALA
### BASICAMENTE CREA UNA CUADRICULA DE largo x largo
set largo 10
set MAX_VAL [expr $largo ** 2]



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

# Define a 'finish' procedure
proc finish {} {
    global ns nf
    $ns flush-trace

    # Close the NAM trace file
    close $nf

    # Execute NAM on the trace file
    exec nam out.nam &
    exit 0
}





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


$ns run
