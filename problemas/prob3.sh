#!/bin/bash
# Eduardo Gimeno

# Comprobar el numero de argumentos
if [ "$#" -ne 1 -o ! -r "$1" ]
then
	echo "Uso: $0 <fichero_lista_de_usuarios>"
	exit 1
fi

in_file="$1"

while read user
do
	id -u "$user" > /dev/null 2>&1
	if [ "$?" -eq 0 ]
	then
		if [ -d /home/"$user"/.ssh ]
		then
			perm_dir='stat -c %A /home/"$user"/.ssh'
			if [ "$perm_dir" != "drwx------" ]
			then
				echo "Permisos incorrectos $perm_dir para el directorio .ssh del usuario $user"
			fi

			for file in /home/"$user"/.ssh/*
			do
				perm_file='stat -c %A "$file"'
				if [ "$perm_file" != "-rw------" ]
				then
					echo "Permisos incorrectos $perm_file para el fichero $file del usuario $user"
				fi
			done
		fi
	else
		if [ -d /home/"$user" ]
		then
			# rm -rf /home/$user
			echo "Borrado el directorio /home/$user"
		else
			echo "El directorio /home/$user no existe"
		fi
	fi
done < "$in_file"

