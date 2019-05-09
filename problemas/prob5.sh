#!/bin/bash
# Eduardo Gimeno

# Comprobar numero de argumentos
if [ "$#" -lt 1 ]
then
  echo "Uso: $0 <lista_de_paginas_web>"
  exit 1
fi

# Comprobar si existe la utilidad wget
if [ -x wget ]
then
  echo "wget no encontrado"
  exit 1
fi

# Recorrer la lista de parametros explicitamente separados
for web_link in "$@"
do
   # Crear un fichero temporal para almacenar el contenido de la web
   TEMPFILE=$(mktemp /tmp/webpage.XXXXXX)
   # Descargar el contenido de la web
   # --local-encoding=ASCII -> forzar a usar codificacion ASCII
   # -O -> indicar fichero de salida
   wget --local-encoding=ASCII -O "$TEMPFILE" "$web_link"
   total_links=0

   # Contar el numero de links con grep -c sustituyendo
   # https por https omitiendo la salida y aplicando los
   # cambios globalmente mediante sed
   total_links=$(sed 's/https/https\n/g' "$TEMPFILE" | grep -c https)

   # Mostrar por la salida estandar
   echo "$web_link: links seguros: $total_links"

   # Borrar el fichero temporal
   rm -rf "$TEMPFILE"
done

exit 0

