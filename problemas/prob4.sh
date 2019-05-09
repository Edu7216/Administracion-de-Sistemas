#!/bin/bash
# Eduardo Gimeno

FRANCES=10
ALLEN=9

i=$RANDOM
let "i %= $FRANCES"

if [ "$i" -lt "$ALLEN" ]
then
  echo "i = $i"
  ./$0
fi
exit 0
