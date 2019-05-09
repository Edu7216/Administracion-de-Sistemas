#!/bin/bash
# Eduardo Gimeno

# Comprobar número de parámetros
if [ "$#" -lt "1" ]
then
  echo "Este script debe incluir una ip"
  exit 1
fi

# Ruta de la clave privada
keypath=/home/"$USER"/.ssh/id_as_ed25519
machine="$1"

# Comprobar si se puede establecer conexión con la máquina, si no, se aborta ejecución
ssh -q -n -i "$keypath" user@"$machine" exit
if [ "$?" -ne "0" ]
then
  echo "$machine no es accesible"
  exit 1
fi

# Para cada línea leída de la entrada estándar
while read line
do
  # Terminar ejecución
  if [ "$line" = "fin" ]
  then
    exit 0
  fi
  
  # Separar campos
  volume_group=$(echo "$line" | cut -d ',' -f 1)
  volume_logical=$(echo "$line" | cut -d ',' -f 2)
  size=$(echo "$line" | cut -d ',' -f 3)
  file_system=$(echo "$line" | cut -d ',' -f 4)
  mount_directory=$(echo "$line" | cut -d ',' -f 5)

  # Si alguno de los parámetros es cadena vacía se aborta ejecución
  if [ -z "$volume_group" -o -z "$volume_logical" -o -z "$size" ]
  then
    echo "Campo invalido"
    exit 1
  fi

  # Comprobar que existe el grupo volumen
  ssh -q -n -i "$keypath" user@"$machine" sudo vgdisplay "$volume_group" > /dev/null 2>&1

  if [ "$?" -ne "0" ]
  then
    echo "No existe un grupo volumen llamado $volume_group"
    exit 1
  fi

  # Comprobar si existe el volumen lógico
  ssh -q -n -i "$keypath" user@"$machine" sudo lvdisplay /dev/"$volume_group"/"$volume_logical" > /dev/null 2>&1
  
  # No existe el volumen lógico
  if [ "$?" -ne "0" ]
  then
    # # Si alguno de los parámetros es cadena vacía se aborta ejecución
    if [ -z "$file_system" -o -z "$mount_directory" ]
    then
      echo "Campo invalido"
      exit 1
    fi
    
    # Crear volumen lógico
    ssh -q -n -i "$keypath" user@"$machine" sudo lvcreate -L "$size" --name "$volume_logical" "$volume_group" > /dev/null 2>&1
    # Crear sistema de ficheros para el volumen lógico
    ssh -q -n -i "$keypath" user@"$machine" sudo mkfs -t "$file_system" /dev/"$volume_group"/"$volume_logical" > /dev/null 2>&1
    # Crear directorio de montaje, si no existe
    ssh -q -n -i "$keypath" user@"$machine" sudo mkdir -p "$mount_directory" > /dev/null 2>&1
    # Montar sistema de ficheros del volumen lógico 
    ssh -q -n -i "$keypath" user@"$machine" sudo mount -t "$file_system" /dev/"$volume_group"/"$volume_logical" "$mount_directory" > /dev/null 2>&1
    if [ "$?" -eq "0" ]
    then
      echo "$volume_logical ha sido creado"
    else
      echo "Error: no se ha podido crear $volume_logical"
      exit 1
    fi

    # Modificar el fichero fstab
    fstab_line="/dev/mapper/$volume_group-$volume_logical $mount_directory $file_system errors=remount-ro 0 1"
    echo "$fstab_line" | ssh -q -i "$keypath" user@"$machine" sudo tee -a /etc/fstab > /dev/null 2>&1
    if [ "$?" -eq "0" ]
    then
      echo "Fichero /etc/fstab modificado con exito"
    else
      echo "No se ha podido modificar /etc/fstab"
      exit 1
    fi
  else
    # El volumen lógico existe
    # Extender volumen lógico
    ssh -q -n -i "$keypath" user@"$machine" sudo lvextend -L+"$size" /dev/"$volume_group"/"$volume_logical" > /dev/null 2>&1
    if [ "$?" -eq "0" ]
    then
      echo "$volume_logical ha sido extendido"
    else
      echo "No se ha podido extender $volume_logical"
    fi
    
    # Extender el sistema de ficheros del volumen lógico
    ssh -q -n -i "$keypath" user@"$machine" sudo resize2fs /dev/"$volume_group"/"$volume_logical" "$size" > /dev/null 2>&1
    if [ "$?" -eq "0" ]
    then
      echo "El sistema de ficheros de $volume_logical ha sido extendido"
    else
      echo "No se ha podido extender el sistema de ficheros de $volume_logical"
    fi
  fi
done < /dev/stdin

