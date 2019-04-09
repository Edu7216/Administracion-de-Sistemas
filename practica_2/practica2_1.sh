#!/bin/bash
# Eduardo Gimeno 721615
# Leer el nombre del fichero
echo -n "Introduzca el nombre del fichero: "
read nombre

# Comprobar si existe
if [ -f "$nombre" ]
then
  # Obtener los permisos
  var=$(ls -l "$nombre")
  echo "Los permisos del archivo $nombre son: ${var:1:3}"
else
  echo "$nombre no existe"
fi 
