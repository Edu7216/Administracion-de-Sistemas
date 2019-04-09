#!/bin/bash
# Eduardo Gimeno 721615
# Bucle para comprobar la lista de argumentos explicitamente 
# separados (evitar problemas espacios)
for param in "$@"
do
  # Comprobar si es un fichero
  if [ -f "$param" ]
  then
    more "$param"
  else
    echo "$param no es un fichero"
  fi
done
