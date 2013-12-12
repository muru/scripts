#! /bin/bash

export WINEARCH=win32

cd /home/bro3886/Downloads/Games/EA\ Games/Mass\ Effect\ 3/Binaries/Win32
echo $PWD
env WINEPREFIX=/home/bro3886/.local/share/wineprefixes/me3 wine MassEffect3.exe
