#! /bin/bash

WINEARCH=win32

cd ~/Downloads/Games/Bioware/Mass\ Effect\ 2/Binaries/

sg -g netblock env WINEPREFIX=/home/bro3886/.local/share/wineprefixes/ME2 wine MassEffect2
