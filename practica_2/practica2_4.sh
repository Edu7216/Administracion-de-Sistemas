#!/bin/bash
# Eduardo Gimeno 721615
# Leer la tecla pulsada
echo -n "Introduzca una tecla: "
read -n1 tecla
read resto

# Switch
case "$tecla" in
  [[:digit:]] )
	echo "$tecla es un numero" ;;
  [[:alpha:]] )
	echo "$tecla es una letra" ;;
  *)
	echo "$tecla es un caracter especial" ;;
esac
  
