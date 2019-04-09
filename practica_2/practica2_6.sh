#!/bin/bash
# Eduardo Gimeno 721615

cuenta=0

# Comprobar si ya existe un directorio del tipo binXXX
if find /home/"$USER"/bin[[:alnum:]][[:alnum:]][[:alnum:]] -maxdepth 1 -type d > /dev/null 2>&1
then
  # Obtener el menos recientemente modificado
  nom=$(stat -c %n%Y /home/"$USER"/bin[[:alnum:]][[:alnum:]][[:alnum:]] | tail -n 1)
  nom=${nom::-10}
else 
  # Crear el directorio
  nom=$(mktemp -d -q /home/"$USER"/binXXX)
  echo "Se ha creado el directorio $nom"
fi

echo "Directorio destino de copia: $nom"

# Para cada fichero en el directorio actual
for fichero in ./*
do
  # Comprobar que sea ejecutable
  if [ -x "$fichero" -a -f "$fichero" ]
  then
    # Copiarlo al directorio destino
    if cp "$fichero" "$nom"
    then
      echo "$fichero ha sido copiado a $nom"
      cuenta=$((cuenta += 1))
    else
      echo "$fichero no ha podido ser copiado a $nom"
    fi
  fi
done

# Mostrar el numero de ejecutables copiados
if [ "$cuenta" -gt 0 ]
then
  echo "Se han copiado $cuenta archivos"
else
  echo "No se ha copiado ningun archivo"
fi
 

