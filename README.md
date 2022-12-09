# Proyecto Final: Escalabilidad de Algoritmos de Enrutamiento

## Alumnos:
Daniel Meza Sanabria B74786

Gian Carlo Pochet Agüero B25168

Freddy Zúñiga Cerdas A45967

Raymond Da Costa B62281

# Diferentes niveles de ejecucion

Para estas simulaciones se tienen diferentes tipos de automatizaciones, las siguientes son las posibles ejecuciones que se pueden realizar.

## Correr archivo.tcl

Al correr el archivo.tcl se generan dos archivos: out.nam y out.tr. El .nam sirve para generar una simulacion visual en entorno grafico, mientras que .tr tendra toda la informacion de la simulacion completa, que se usa para obtener las metricas.

El archivo llamado archivo.tcl puede recibir 1 o 2 argumentos, si se le pone un solo argumento este ejecutara la simulacion usando el argumento ingresado para setear el numero de nodos, por ejemplo si escribimos como argumento un 4, el numero de nodos sera 16 (en general el numero de nodos siempre sera el cuadrado del argumento ingresado). Ejemplo para obtener 100 nodos:

```{r, engine='bash', count_lines}
ns archivo.tcl 10
```

En caso de querer hacer lo mismo pero abriendo de forma automatica el archivo .nam para ver correr una simulacion grafica se, usan dos argumentos, el primero corresponde al largo para obtener el numero de nodos, igual que en el caso anterior, y el segundo argumento puede ser cualquier numero o letra. Ejemplo:

```{r, engine='bash', count_lines}
ns archivo.tcl 10 a
```

## Correr script.sh

Este script tiene dos modos de ejecucion, con argumentos y sin argumentos. En caso de correrlo sin argumentos corre multiples simulaciones que van de 25 nodos a 400 nodos, esta es una opcion mas pesada pues tiene que realizar todas las simulaciones, para correrlo solo se debe ejecutar esto en la terminal:

```{r, engine='bash', count_lines}
bash script.sh
```

Si se ejecuta con argumentos cada uno de estos corresponde a una simulacion y el valor ingresado es el largo, y al igual que antes los nodos son el cuadrado del largo. Ejemplo: esta configuracion creara tres simulaciones, la primera para 25 nodos, la segunda para 49 y la tercera para 144.

```{r, engine='bash', count_lines}
bash script.sh 5 7 12
```

Adicionalmente en cualquiera de los modos se creara una carpeta con archivos .csv para poder graficar lo relacionado con la metrica de los drops de paquetes.

