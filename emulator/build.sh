#!/usr/bin/env bash
set -e

OPTS=""

function usage()
{
   progname=$(basename $0)
   cat << HEREDOC

   Usage: $progname [--num NUM] [--time TIME_STR] [--verbose] [--dry-run]

   optional arguments:
     -h, --help           show this help message and exit
     -b, --bintr          enable binary translation using system compiler
     -t, --tcc            jit-compile using tcc
     -v, --verbose        increase the verbosity of the bash script

HEREDOC
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
		-h|--help ) usage; exit; ;;
        -b|--bintr) OPTS="$OPTS -DRISCV_BINARY_TRANSLATION=ON -DRISCV_LIBTCC=OFF" ;;
        -t|--tcc  ) OPTS="$OPTS -DRISCV_BINARY_TRANSLATION=ON -DRISCV_LIBTCC=ON" ;;
		-v|--verbose ) set -x ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

mkdir -p .build
pushd .build
cmake .. -DCMAKE_BUILD_TYPE=Release $OPTS
make -j6
popd

if test -f ".build/rvmicro"; then
	ln -fs .build/rvmicro .
fi
if test -f ".build/rvnewlib"; then
	ln -fs .build/rvnewlib .
fi
ln -fs .build/rvlinux .
