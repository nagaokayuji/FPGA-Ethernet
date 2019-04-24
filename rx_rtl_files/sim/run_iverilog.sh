#!/bin/bash

if [ $# -ne 1 ]; then
  echo "err"
  exit 1
fi

topmodulename=$1
echo "iverilog -s $topmodulename $topmodulename.v ../*.v"

iverilog -s $topmodulename $topmodulename.v ../*.v
ret=$?
printf "return:\e[36m$ret \e[m\n"
if [ $ret -eq 0 ]; then
	printf "run: ./a.out\n"
	time ./a.out
	echo "............"
	echo "........done."
	exit 0
fi
