#!/bin/bash
# Eduardo Gimeno 721615
# Leer el nombre del directorio
echo -n "Introduzca el nombre de un directorio: "
read nombre

# Comprobar que es un directorio
if [ -d "$nombre" ]
then
  # Contar numero de subdirectorios
  subdir=$(find "$nombre" -mindepth 1 -type d | wc -l)
  # Contar numero de ficheros
  fich=$(find "$nombre" -mindepth 1 -type f | wc -l)
  echo "El numero de ficheros y directorios en "$nombre" es de "$fich" y "$subdir", respectivamente"
else
  echo "$nombre no es un directorio"
fi
