#! /bin/bash

export WINEARCH=win32

cd /home/bro3886/Downloads/Games/BioWare/Mass\ Effect\ 2/Binaries/
echo $PWD
env WINEPREFIX=/home/bro3886/.local/share/wineprefixes/ME2 wine MassEffect2.exe
