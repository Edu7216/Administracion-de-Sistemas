#!/bin/bash
# Eduardo Gimeno 721615
# Comprobar que el usuario que ejecuta el script tenga UID 0,
# es decir, durante la ejecución del script sea superusuario
if [ "$UID" != "0" ]
then
  echo "Este script necesita privilegios de administracion"
  exit 1
fi

# Comprobar numero de argumentos
if [ "$#" != "2" ]
then
  echo "Numero incorrecto de parametros"
  exit 1
fi

# Comprobar que la opcion sea añadir o borrar
if [ "$1" != "-a" -a "$1" != "-s" ]
then
  echo "Opcion invalida" 1>&2
  exit 1
fi

# Crear directorio por los backup
mkdir -p /extra/backup > /dev/null 2>&1

# Leer el fichero
cat "$2" | while read line
do
  # Obtener los tres campos
  iduser=$(echo "$line" | cut -d ',' -f 1)
  password=$(echo "$line" | cut -d ',' -f 2)
  username=$(echo "$line" | cut -d ',' -f 3)

  # Si hay que borrar
  if [ "$1" = "-s" ]
  then
    # Comprobar que el usuario existe
    if id "$iduser" > /dev/null 2>&1
    then
      # Obtener su home del fichero passwd
      homeuser=$(cat /etc/passwd | grep "$iduser" | cut -d ':' -f 6)
      # Fecha actual
      ad=$(date "+%Y-%m-%d")
      # Seprar el home del usuario en dos partes, homeuser2 contendrá el nombre del usuario sin "/"
      # homeuser1 todo lo anterior, necesario para crear el tar
      homeuser1="${homeuser%/*}"
      homeuser2="${homeuser##*/}"
      # Indicar que la cuenta del usuario expira en la fecha actual
      usermod -e "$ad" "$iduser" > /dev/null 2>&1
      # Crear el tar
      if tar cf "/extra/backup/${iduser}.tar" -C "$homeuser1" "$homeuser2" > /dev/null 2>&1
      then
        # Borrar la cuenta del usuario
	userdel -r "$iduser" > /dev/null 2>&1
      fi
    fi
  else
    # Comprobar que los campos no sean nulos
    if [ -z "$iduser" -o -z "$password" -o -z "$username" ]
    then
      echo "Campo invalido"
      exit 1
    fi
    
    # Crear la nueva cuenta de usuario
    if useradd -m -K UID_MIN=1815 -c "$username" -k /etc/skel -U "$iduser" > /dev/null 2>&1
    then
      # Establecer la contraseña
      echo "$iduser:$password" | chpasswd > /dev/null 2>&1
      # Establecer la caducidad de la contraseña
      if chage -m 30 "$iduser" > /dev/null 2>&1
      then
	echo "$username ha sido creado"
      fi
    else
      echo "El usuario $iduser ya existe"
    fi
  fi
done
