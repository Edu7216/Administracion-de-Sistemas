#!/bin/bash
# Eduardo Gimeno 721615
# Comprobar el numero de argumentos
if [ "$#" -gt 1 -o "$#" -eq 0 ]
then
  echo "Sintaxis: practica2_3.sh <nombre_archivo>"
else
  # Comprobar si existe
  if [ -f "$1" ]
  then
    # Cambiar los permisos
    chmod u=rwx,g=rx "$1"
    stat --format "%A" "$1"
  else
	echo "$1 no existe"
  fi
fi
