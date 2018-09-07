#!/bin/bash

gcc -std=c99 checkVerbForms2.c ../libmorph.c ../GreekForms.c ../accent.c ../utilities.c ../augment.c ../ending.c -I.. -o checkVerbForms2
./checkVerbForms2
diff -u paradigm.txt new.txt
