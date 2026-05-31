#!/bin/bash

rm myprint.txt
output1=$(gawk -f step1.awk ph_my.txt product.txt)

# формирование трех файлов
# ad.txt
# debitor.txt
# kg.txt
#output1=$(gawk -f step1.awk text4.txt)



