#!/bin/bash

### este valor se agrega para guardar todos los .tr de las simulaciones por si
### se desea analizarlos despues para obtener las metricas. Para guardar los
### tr se pone en 1 la variable
GUARDAR_TR=0
### si se desea ingresar los valores de la simulacion en este archivo
### se modifica largo() y no se meten argumentos al script por terminal
largo=(5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)

crear_directorio() {
    if [ -d $1 ]; then
        rm -r $1 ## destruye la carpeta resultados con todo su contenido
        mkdir $1 ## crea una carpeta resultados vacia
    else
        mkdir $1 ## crea una carperta resultados vacia
    fi
}

### se ejecuta si se agregan los parametros por la terminal, cada parametro
### sera el largo deseado
if [ $# -ge 1 ]; then
    largo=()
    for val in "$@"
    do
        largo+=($val)
    done
fi



### para crear la carpeta de resultados
crear_directorio "./resultados"
### crea una carpeta para los tr si queremos guardarlos
if [ $GUARDAR_TR -eq 1 ]; then
    crear_directorio "./archivos_tr"
fi


encabezado_para_tasa_perdida=0
for i in ${!largo[@]}; do
    ### calcula los nodos totales
    nodos_totales=$((${largo[$i]} * ${largo[$i]}))
    titulo="segmentacion_${nodos_totales}_nodos"
    ### corre la simulacion para cada valor del array largo
    ns archivo.tcl ${largo[$i]}
    ### respalda el .tr creado para usarse luego
    if [ $GUARDAR_TR -eq 1 ]; then
        cp out.tr "./archivos_tr/nodos_totales_${nodos_totales}.tr"
    fi
    
    ### extrae el porcentaje de drop por nodo en caso de existir
    awk -f segmentacion_drop_nodos.awk out.tr | sort -n > ./resultados/$titulo
    contenido=`cat ./resultados/$titulo`
    ### crea el csv si hay drop o borra el archivo intermedio
    if [ ${#contenido} -ne 0 ]; then
        echo "IGNORAR,NODO,PORCENTAJE_DEL_DROP_TOTAL" > ./resultados/encabezado
        ### crear csv
        sed -i "s|,|.|g" ./resultados/$titulo
        sed -i "s|;|,|g" ./resultados/$titulo
        echo "creando segmentacion csv"
        cat ./resultados/encabezado ./resultados/$titulo > ./resultados/${titulo}.csv
        rm ./resultados/$titulo ./resultados/encabezado
        #mv ./resultados/$titulo ./resultados/${titulo}.csv
    else
        rm ./resultados/$titulo
    fi
    
        
    
    ### copia la salida del script awk en la variable linea
    linea=`awk -f tasa_perdida_paquetes.awk out.tr`
    

    ### si linea esta vacia, lo que indica que no hay perdida de paquetes no hace nada
    ### pero si existe perdida de paquetes ejecuta este if 
    if [ ${#linea} -ne 0 ]; then
        ### guarda el contenido de linea en un archivo intermedio
        echo $linea > ./resultados/archivo
        ### sustituye comas y puntos para luego poder crear un csv 
        sed -i "s|,|.|g" ./resultados/archivo
        sed -i "s|;|,|g" ./resultados/archivo
        ### guarda el resultado del archivo procesado en una variable data
        data=`cat ./resultados/archivo`
        encabezado="NODOS_TOTALES,PAQUETES_TOTALES,PAQUETES_DROPEADOS,PORCENTAJE_DROP"
        ### agrega a la variable el numero de nodos
        data="${nodos_totales},${data}"
        ### llena el csv con los datos obtenidos y formateados en la variable data
        if [ $encabezado_para_tasa_perdida -eq 0 ]; then
            echo $encabezado > ./resultados/tasa_perdida_paquetes.csv
            encabezado_para_tasa_perdida=1 # para que solo lo ejecute una vez
        fi
        echo $data >> ./resultados/tasa_perdida_paquetes.csv
        ### borra el archivo intermedio
        rm ./resultados/archivo        
    fi
    
done

