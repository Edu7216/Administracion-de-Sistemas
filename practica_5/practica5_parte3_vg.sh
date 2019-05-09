#!/bin/bash
# Eduardo Gimeno

# Comprobar número de parámetros
if [ "$#" -lt "3" ]
then
  echo "Este script debe incluir una o más particiones a añadir al grupo volumen indicado"
  exit 1
fi

# Ruta de la clave privada
keypath=/home/"$USER"/.ssh/id_as_ed25519
machine="$1"
shift

# Comprobar si se puede establecer conexión con la máquina, si no, se aborta ejecución
ssh -q -n -i "$keypath" user@"$machine" exit
if [ "$?" -ne "0" ]
then
  echo "$machine no es accesible"
  exit 1
fi

volume_group="$1"
shift

# Comprobar que existe el grupo volumen
ssh -q -n -i "$keypath" user@"$machine" sudo vgdisplay "$volume_group" > /dev/null 2>&1

if [ "$?" -ne "0" ]
then
  echo "No existe un grupo volumen llamado $volume_group"
  exit 1
fi

# Para cada partición pasada como parámetro
for partition in "$@"
do
  # Comprobar que existe
  ssh -q -n -i "$keypath" user@"$machine" test -e "$partition"
  if [ "$?" -ne "0" ]
  then
    echo "La partición $partition no existe"
  fi
  
  # Crear volumen físico de la partición
  if ssh -q -n -i "$keypath" user@"$machine" sudo pvcreate -f "$partition" > /dev/null 2>&1
  then
    echo "Se ha creado el volumen físico correspondiente a $partition"
    # Extender grupo volumen con el nuevo volumen físico
    if ssh -q -n -i "$keypath" user@"$machine" sudo vgextend "$volume_group" "$partition" > /dev/null 2>&1
    then
      echo "Se ha añadido $partition al grupo volumen $volume_group"
    fi
  fi
done

# Listar volúmenes físicos del grupo volumen
echo "Lista de los volúmenes físicos que componen el volumen lógico $volume_group"
ssh -q -n -i "$keypath" user@"$machine" sudo pvscan | grep "$volume_group"


  
  
