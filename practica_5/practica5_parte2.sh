#!/bin/bash
# Eduardo Gimeno

# Comprobar número de parámetros
if [ "$#" != "1" ]
then
  echo "Numero incorrecto de parametros"
  exit 1
fi

# Ruta de la clave privada
keypath=/home/"$USER"/.ssh/id_as_ed25519

# Comprobar si se puede establecer conexión con la máquina, si no, se aborta ejecución
ssh -q -n -i "$keypath" user@"$1" exit
if [ "$?" -ne 0 ]
then
  echo "$1 no es accesible"
  exit 1
fi

# Obtener discos duros disponibles y sus tamaños de bloques
echo "Discos duros disponibles y sus tamaños de bloques en $1"
ssh -q -n -i "$keypath" user@"$1" sudo sfdisk -s
echo -e "\n"

# Particiones y sus tamaños
echo "Particiones y sus tamaños en $1"
ssh -q -n -i "$keypath" user@"$1" sudo sfdisk -l
echo -e "\n"

# Información de montaje de sistemas de ficheros
echo "Información de montaje de sistemas de ficheros en $1"
ssh -q -n -i "$keypath" user@"$1" sudo df -hT | sed '/^tmpfs/ d'
