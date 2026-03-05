BEGIN {

#print "AF7363-1321-50200/G3 AF6016-010" >> result_txt

#f_base -    <input type="hidden" name="f_base" value="AF17363-1321-03000/G3;AF105216;20;6785">
#print json_data >>  "/home/vtext/app/script/AUS/DE/AWK/111.txt"

gsub(/[^a-zA-Z0-9:;/,\-_]/, "", json_data)

#print json_data >>  "/home/vtext/app/script/AUS/DE/AWK/111.txt"

delete arr_tmp; delete arr_tmp1; delete arr_tmp2;
split(json_data, arr_tmp1, ",")

for (i=1; i<=length(arr_tmp1); i++) {
   split(arr_tmp1[i],arr_tmp2,":")
   arr_tmp[arr_tmp2[1]] = arr_tmp2[2]
}

pos1 = arr_tmp["pos1"]
pos2 = arr_tmp["pos2"]
pos3 = arr_tmp["pos3"]
pos4 = arr_tmp["pos4"]
pos5 = arr_tmp["pos5"]
pos6 = arr_tmp["pos6"]
pos7 = arr_tmp["pos7"]
f_base = arr_tmp["f_base"]
element = arr_tmp["element"]


if (pos7 == "")
   pos7 = "0;0"

split(pos1,arr_pos1,";") # MOTOR
split(pos2,arr_pos2,";") # port size
split(pos3,arr_pos3,";") # pn16 "2:0"
split(pos4,arr_pos4,";") # dP Messung
split(pos5,arr_pos5,";") # DFVentil + Manometer
split(pos6,arr_pos6,";") # Ablass
split(pos7,arr_pos7,";") # RSV

split(f_base,arr_fb,";")
fbez = arr_fb[1]
felem = arr_fb[2]
feinheit = arr_fb[3]
price =  arr_fb[4]

if (element != "") {                    # запрос пришел из KSF
   split(element, arr_element, ";")
   element = arr_element[1]
   elem_price = arr_element[2]
} else {
   element = felem "-00" int(feinheit/10)
   if (feinheit >= 100)
     element = felem "-0" int(feinheit/10)
}


#base
split(fbez,arr_fbez,"-")
part1 = arr_fbez[1] # AF17363
part2 = arr_fbez[2] # "1321" или "221"
part3 = arr_fbez[3] # 03000/G3

part1 = substr(part1,1,length(part1)-1) arr_pos1[1]
part2 = arr_pos2[1] arr_pos3[1] substr(part2,length(part2),1)
part3 = arr_pos4[1] arr_pos5[1] arr_pos6[1] arr_pos7[1]  substr(part3, 5, length(part3)-4)

## price
fin_price = price + arr_pos1[2] + arr_pos2[2] + arr_pos3[2] + arr_pos4[2] + arr_pos5[2] + arr_pos6[2] + arr_pos7[2] + elem_price

mystring = part1 "-" part2 "-" part3 " "  element "PRICE:" fin_price

print mystring >> result_txt


}

###################################################################################

#pos1 = arr_tmp["pos1"]
#pos2 = arr_tmp["pos2"]
#pos3 = arr_tmp["pos3"]
#pos4 = arr_tmp["pos4"]
#pos5 = arr_tmp["pos5"]
#pos6 = arr_tmp["pos6"]
#pos7 = arr_tmp["pos7"]
#f_base = arr_tmp["f_base"]
#
##   print "f_base: " f_base >>  "/home/vtext/app/script/AUS/DE/AWK/111.txt"
#
## ----------------------------------
#
#split(f_base,arr_fb,";")
#fbez = arr_fb[1]
#felem = arr_fb[2]
#feinheit = arr_fb[3]
#price =  arr_fb[4]
#
#split(pos1,arr_pos1,";") # MOTOR
#split(pos2,arr_pos2,";") # port size
#split(pos3,arr_pos3,";") # pn16 "2:0"
#split(pos4,arr_pos4,";") # dP Messung
#split(pos5,arr_pos5,";") # DFVentil + Manometer
#split(pos6,arr_pos6,";") # Ablass
#split(pos7,arr_pos7,";") # RSV
#
### price
#fin_price = price + arr_pos1[2] + arr_pos2[2] + arr_pos3[2] + arr_pos4[2] + arr_pos5[2] + arr_pos6[2] + arr_pos7[2] 
#
## element
#element = felem "-00" int(feinheit/10)
#if (feinheit >= 100)
#   element = felem "-0" int(feinheit/10)
#
##base
#split(fbez,arr_fbez,"-")
#part1 = arr_fbez[1] # AF17363
#part2 = arr_fbez[2] # "1321" или "221"
#part3 = arr_fbez[3] # 03000/G3
#
#part1 = substr(part1,1,length(part1)-1) arr_pos1[1]
#part2 = arr_pos2[1] arr_pos3[1] substr(part2,length(part2),1)
#part3 = arr_pos4[1] arr_pos5[1] arr_pos6[1] arr_pos7[1]  substr(part3, 5, length(part3)-4)
#
#mystring = part1 "-" part2 "-" part3 " "  element "PRICE:" fin_price
#
#
#
#print mystring >> result_txt
#
#
#}  # END OF BEGIN



# ТЕЛО
#
#{
#}
#
#
#
#END {
#}
