#!/bin/bash

if [ $# -ne 1 ]; then
  echo "err"
  exit 1
fi

topmodulename=$1
echo "$topmodulename"
topmodulefilename=$topmodulename.v
echo "$topmodulefilename"

echo "iverilog -s $topmodulename $topmodulename.v ../*.v"
iverilog -s $topmodulename $topmodulename.v ../*.v
