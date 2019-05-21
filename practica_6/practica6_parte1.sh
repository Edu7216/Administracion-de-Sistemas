#!/bin/bash
# Eduardo Gimeno

# La etiqueta de la opción -t de logger cambia según la máquina

# Obtener nº de usuarios y carga media de trabajo
# Depende de cuantos usuarios halla los campos pueden variar
if [ "user," = "$(uptime | awk '{print $5}')" ] || [ "users," = "$(uptime | awk '{print $5}')" ]
then
  uptime | awk '{print "Usuarios conectados: " $4 ", Carga media de trabajo (1m, 5m, 15m): " $8 " " $9 " " $10 " "}' | logger -p local0.info -t debian-as1
else
  uptime | awk '{print "Usuarios conectados: " $5 ", Carga media de trabajo (1m, 5m, 15m): " $9 " " $10 " " $11 " "}' | logger -p local0.info -t debian-as1
fi

# Memoria ocupada y libre, swap utilizado
free -h | awk 'NR==2 {print "Memoria ocupada: " $3 ", Memoria libre: "$4} NR==4 {print ", Swap utilizado: " $3}' | logger -p local0.info -t debian-as1

# Espacio ocupado y libre
df -h | awk 'NR==2 {print "Espacio ocupado: " $3 ", Espacio libre: "$4}' | logger -p local0.info -t debian-as1

# Nº de puertos abiertos y conexiones establecidas
puertos_abiertos="$(netstat -l | egrep -v ^unix | egrep LISTEN | wc -l)"
conexiones_establecidas="$(netstat | egrep -v ^unix | egrep ESTABLISHED | wc -l)"
echo "Numero de puertos abiertos: $puertos_abiertos, Numero de conexiones establecidas: $conexiones_establecidas" | logger -p local0.info -t debian-as1

# Nº de programas en ejecución
programas_ejecucion="$(ps -e | egrep : | wc -l)"
echo "Numero de programas en ejecucion: $programas_ejecucion" | logger -p local0.info -t debian-as1


