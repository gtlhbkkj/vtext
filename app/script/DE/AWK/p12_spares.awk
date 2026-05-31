# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
#  output1=$(gawk -v filter_name="$myfiltername" -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p12_spares.awk" $file_path)


BEGIN {
  RS = "\n"
  FS = "_!_"
  n = split(my_string, arr1, ",")
  f_bez = arr1[1]
  material = arr1[6]

#  result_txt = TMP_DIR "/" UUID ".result.txt"
  result_txt = TMP_DIR "/" UUID ".html.txt"

#  result_txt = TMP_DIR "/" UUID ".html.txt"
  errlog_txt = TMP_DIR "/" UUID ".errlog.txt"

  delete arr_pricelist;


  # NEW BLOCK
  delete arr_et_conf; delete arr_shop;
  delete arr_headers; delete arr_spares;
  read_spares = 0     # do not start reading values until arr_headers is finalized
  ez_nummer = ""

#  print "11111111111-p12" > "/home/vtext/app/script/DE/AWK/111.txt"


}


# начинается проход по файлу данных
{

  # upload shop data
  if (FILENAME ~ "shopdata.txt") {
     arr_shop[$1] = $3
  }

  if (FILENAME !~ "shopdata.txt") {

      # NEW BLOCK ####################################
      if ($1 == "ET_SECTION") {
         arr_headers[$2] = $3
      }

      if ($1 == "END_OF_BLOCK_ET_SECTION")
         read_spares = 1

      if ($1 == "EZ" && $2 ~ f_bez && check_material($3,material)) {
          ez_nummer = $4
      }


      # read values into arr_spares[]
      if (read_spares == 1) {
         for (i=1; i<=length(arr_headers); i++) {

            field1 = "ETS0" i
            if (i>=10)
               field1 = "ETS" i

            if ($1 == field1 && $2 ~ f_bez && check_material($3,material)) {
                if (arr_spares[i] == "")
                    arr_spares[i] = $4 ";" $5 ";" $6 ";" $7
                else
                    arr_spares[i] = arr_spares[i] "_!!_" $4 ";" $5 ";" $6 ";" $7
            }
         }
      }
      # END OF NEW BLOCK ####################################

      # READ SINGLE ITEMS FILE
      if ($1 ~ /^ETDUM+[0-9]{3}$/ || $1 ~ /^7+[0-9]{7}$/)
         arr_et_pricelist[$1] = $2 ";" $3 ";" $4 ";" $5

  } #END OF  if (FILENAME != "shopdata.txt") {

}


END {

#    if (f_bez == "AF713_G1" || f_bez == "AF724_G4" || f_bez == "AF736_G3" ) {
       print "<table class=\"table table-striped\"><tbody>" >> result_txt
       print "<tr><th><B><H4># ERSATZTEILE FÜR"                >> result_txt
       print "<BR># " filter_name                 >> result_txt
       print "<BR># Ersatzteilzeichnung: " ez_nummer "</H4></B></th></tr>"                >> result_txt


   # NEW SECTION ############################################
   delete arr_section_of_spares

#   print "<table class=\"table table-striped\"><tbody>" >> result_txt

   for (i=1; i<=length(arr_headers); i++) {
      # create arr_spares_tmp[] from string in arr_spares[i]
      delete arr_spares_tmp;
      split(arr_spares[i], arr_spares_1, "_!!_")
#      print mt arr_headers[i] ":" >> result_txt
      for (i1=1; i1<=length(arr_spares_1); i1++) {
         arr_spares_tmp[i1] = arr_spares_1[i1]
#         print mt "   " arr_spares_tmp[i1] >> result_txt
      }

#      print "<table class=\"table table-striped\"><tbody>" >> result_txt
      print "<tr><td><B>" toupper(arr_headers[i]) "</B></td></tr>" >> result_txt
      print "<tr><td><pre>" >> result_txt

      print_section_of_spares(arr_headers[i])

      print  "</pre></td></tr>" >> result_txt
#      print "</tbody></table>" >> result_txt

   }
   # END OF NEW SECTION ############################################
   print "</tbody></table>" >> result_txt


#  }  # END OF if (f_bez == "AF724_G4") {


} # END OF END SECTION


# CHECK MATERIAL DURING READING OF ET
function check_material(field3, material) {
  if (field3 == "*" || field3 ~ material)
     return 1
  return 0
}



# mystr = "70308163 *** AF 736/936.-..51/G3 GERUEST"
function add_link_to_string(mystr) {
   mat_nr_tmp = substr(mystr,1,8)
   if (arr_shop[mat_nr_tmp] != "") {
      myvar = "https://shopindustrial.filtrationgroup.com/de/" mat_nr_tmp ".html"
      myvar_link = "<a href=\"" myvar "\">" mat_nr_tmp "</a>"
      str_to_return = "["myvar_link"]: " substr(mystr,14)
   } else if (mat_nr_tmp ~ "ETDU") {
      str_to_return = "[_DUMMY__]: " substr(mystr,14)
   } else {
      str_to_return = "["mat_nr_tmp"]: " substr(mystr,14)
   }
   return str_to_return
}

function  print_section_of_spares(arr_headers_current) {

    for (k=1; k<=length(arr_spares_tmp); k++) {
       split(arr_spares_tmp[k], arr_01, ";")

       if (arr_01[2] != "n/a")
          price = "<font color=\"blue\">" arr_01[2] " EUR St/Brt"  "</font>"
       else
          price = "<font color=\"red\">" "nicht verkaufsfähig"  "</font>"

       str_arr_01_3 = ""
       if (arr_01[3] != "")
          str_arr_01_3 = " /// " arr_01[3] # Abstreifer + 4 Blattfeder

       str_arr_01_4 = ""
       if (arr_01[4] != "")
          str_arr_01_4 = " /// " arr_01[4] # 1:71371285,4:79745365

       new_arr_01 = add_link_to_string(arr_01[1])
       print "<B>" new_arr_01 " /// " toupper(price str_arr_01_3 str_arr_01_4) "</B>" >> result_txt

#       print "HERE WE ARE / arr_01[1]: " arr_01[1] >> result_txt
       if (substr(arr_01[1],1,8) ~ "ETDUM9") {
#             print "HERE WE ARE" >> result_txt
             print_separate_mat_number("ELEMENT:"substr(arr_01[1],1,8), 3)
             print "." >> result_txt
       }









#       print_fg_link(substr(arr_01[1],1,8), 3) # SAP Mat-Nr, No of Spaces in the beginning of line
       # prints all single mat-numbers with prices and links
       sap_mat_nr = substr(arr_spares_tmp[k],1,8)
#       arr_section_of_spares[sap_mat_nr] = arr_01[4]
#       delete arr_pass_number;
       pass_number = 1
#       arr_pass_number[pass_number] = sap_mat_nr
#       print mt "arr_pass_number["pass_number"]:" arr_pass_number[pass_number]  " /// " sap_mat_nr  " /// " arr_section_of_spares[sap_mat_nr] >> result_txt


       # НАЧАЛО ПРОБЛЕМЫ
       length_arr = split(arr_01[4], arr_sap_mat_nr, ",") # кол-во членов в массиве для себя, для кода это не нужно
#       print mt "arr_01[4]:" arr_01[4] " /// number of arr members: " length_arr >> result_txt    # вывожу на печать для себя

       # for print_bom_2 - string
       mystring = arr_01[4]
       if (mystring != "") { # если кол-во членов в массиве больше нуля то запускаем рекурсивную функцию

         split(mystring, arr_mystring, ",")
         for (k2=1; k2<=length(arr_mystring); k2++) {
             mystring1 = arr_mystring[k2]
#             print mt "========== Print section of spares, mystring = " mystring1 >> result_txt
             print_specification(mystring1)   # print BOM
         }


       print "." >> result_txt

       }
    }
#print  "</pre></td></tr>" >> result_txt
#print "</tbody></table>" >> result_txt
}



# print Stüli complex way
function print_specification(mystr) {

    mat_nr = print_separate_mat_number(mystr, 3)  # 3 - kolvo probelov
    mystr1 = find_mystr1(mat_nr)                  # returns "1:71234569,12x72323133,"

    # pass nr 1
    length_1 = split(mystr1, arr_mystr1, ",")
    for (m1=1; m1<=length_1; m1++) {
        mat_nr = print_separate_mat_number(arr_mystr1[m1], 6)  # 6 - kolvo probelov
        mystr1 = find_mystr1(mat_nr)                  # returns "1:71234569,12x72323133,"

        # pass nr 2
         length_2 = split(mystr1, arr_mystr2, ",")
         for (m2=1; m2<=length_2; m2++) {
            mat_nr = print_separate_mat_number(arr_mystr2[m2], 9)  # 9 - kolvo probelov
            mystr1 = find_mystr1(mat_nr)                  # returns "1:71234569,12x72323133,"

            # pass nr 3
            length_3 = split(mystr1, arr_mystr3, ",")
            for (m3=1; m3<=length_3; m3++) {
                mat_nr = print_separate_mat_number(arr_mystr3[m3], 12)  # 9 - kolvo probelov
                mystr1 = find_mystr1(mat_nr)                  # returns "1:71234569,12x72323133,"

                # pass nr 4
                length_4 = split(mystr1, arr_mystr4, ",")
                for (m4=1; m4<=length_4; m4++) {
                    mat_nr = print_separate_mat_number(arr_mystr4[m4], 15)  # 15 - kolvo probelov
                    mystr1 = find_mystr1(mat_nr)                  # returns "1:71234569,12x72323133,"

                   # pass nr 5
                   length_5 = split(mystr1, arr_mystr5, ",")
                   for (m5=1; m5<=length_5; m5++) {
                       mat_nr = print_separate_mat_number(arr_mystr5[m5], 18)  # 18 - kolvo probelov
                       mystr1 = find_mystr1(mat_nr)                  # returns "1:71234569,12x72323133,"

                   }
                }
            }
        }
    }
 }

# вытаскивает строку материала и возвращает строку со спецификацией
function find_mystr1(mat_nr) {
    split(arr_et_pricelist[mat_nr], arr_et_tmp1, ";")
    return arr_et_tmp1[4]            # "1:71234569,12x72323133,"
}



function print_separate_mat_number(tmp_value, no_of_spaces) {
    split(tmp_value, arr_tmp10, ":")
    kol_vo = arr_tmp10[1]      # это количество штук, например 1
    mat_nr = arr_tmp10[2]      # это 8-значный номер, типа "71371285"
    if (mat_nr != "") {

       split(arr_et_pricelist[mat_nr], arr_et_tmp1, ";")
       et_bezeichnung = arr_et_tmp1[1]

       if (arr_et_tmp1[2] != "n/a")
          et_price = "<font color=\"blue\">" arr_et_tmp1[2] " EUR St/Brt" "</font>"
       else
          et_price = "<font color=\"red\">" "nicht verkaufsfähig" "</font>"

       str_arr_et_tmp1_3 = ""
       if (arr_et_tmp1[3] != "")
          str_arr_et_tmp1_3 = " /// " arr_et_tmp1[3] # Abstreifer + 4 Blattfeder

       str_arr_et_tmp1_4 = ""
       if (arr_et_tmp1[4] != "")
          str_arr_et_tmp1_4 = " /// " arr_et_tmp1[4] # 1:71371285,4:79745365

       mat_nr_to_print = mat_nr
       if (mat_nr ~ "ETDUM")
          mat_nr_to_print = "_DUMMY__"

#       print calc_spaces(no_of_spaces) kol_vo "x["mat_nr_to_print"]: " et_bezeichnung " /// " et_price str_arr_et_tmp1_3 str_arr_et_tmp1_4 >> result_txt
#       print_fg_link(mat_nr, no_of_spaces) # SAP Mat-Nr, No of Spaces in the beginning of line

################################################################################
#       позже отредактировать ЛИНК
#       if check_fg_link {
#       print mat_nr_to_print " - " arr_shop[mat_nr_to_print] >> result_txt


       if (arr_tmp10[1] != "ELEMENT") {  # 9. ELEMENTE / для элементов это не печатаем

          if (arr_shop[mat_nr_to_print] != "") {
             myvar = "https://shopindustrial.filtrationgroup.com/de/" mat_nr_to_print ".html"
             myvar_link = "<a href=\"" myvar "\">" mat_nr_to_print "</a>"
             print calc_spaces(no_of_spaces) kol_vo "x["myvar_link"]: " et_bezeichnung " /// " et_price str_arr_et_tmp1_3 str_arr_et_tmp1_4 >> result_txt
          } else {
             print calc_spaces(no_of_spaces) kol_vo "x["mat_nr_to_print"]: " et_bezeichnung " /// " et_price str_arr_et_tmp1_3 str_arr_et_tmp1_4 >> result_txt
          }

       }

################################################################################

       if (mat_nr ~ "ETDUM9") {
          print calc_spaces(no_of_spaces + 3) "Verfügbare Filterelemente:" >> result_txt

          delete arr_tmp_10; delete arr_tmp_11;
          sort_filter_elements(mat_nr)

          if (length(arr_tmp_11) >= 1) {

#             for (k2=1; k2<=length(arr_tmp_11); k2++) {
#                split(arr_tmp_11[k2], arr_tmp_10, ";")
#                mat_nr_tmp = add_link_to_string(arr_tmp_10[1]) # проверяем есть ли он в онлайн шопе
#                print calc_spaces(no_of_spaces+3) mat_nr_tmp  arr_tmp_10[2] " /// " arr_tmp_10[3] >> result_txt
#             }


          # попытка распечатать элементы в колонках
          # длина колонки равно 40 символов 
          length_arr = length(arr_tmp_11)
          if (length_arr >= 1) {

             no_of_columns = 4
             column_width = 30

             for (k2=1; k2<=length_arr; k2++) {
                delta_space = 0
                string1 = calc_spaces(no_of_spaces+3)

                for (k3=no_of_columns; k3>=1; k3--) {
                   mycounter = k2*no_of_columns-k3+1
                   if (mycounter <= length_arr) {
                      split(arr_tmp_11[mycounter], arr_tmp_10, ";")
                      mat_nr_tmp = add_link_to_string(arr_tmp_10[1]) # проверяем есть ли он в онлайн шопе
                      string1 = string1 calc_spaces(delta_space) mat_nr_tmp  arr_tmp_10[2]
                      delta_space = column_width - length(arr_tmp_10[1] arr_tmp_10[2])   # на сколько н>
#                      print "k2="k2 " / k3="k3 " / mycounter=" mycounter " - " string1 >> result_txt
                   }
                }

                print string1 >> result_txt

                if (arr_tmp_11[mycounter] == "")
                   break
             }
          }



          } else {
                print calc_spaces(no_of_spaces+3) "Array of filter elements is empty" >> result_txt
          }



       }
    }

    return mat_nr
}


function calc_spaces(no_of_spaces) {
    spaces = ""
    for (ix=1; ix<=no_of_spaces; ix++)
      spaces = spaces " "
    return spaces
}




# сортирует элементы в массив arr_tmp11
function sort_filter_elements(mat_nr) {
   # копируем из ассоциативного массива в обычный в виде 72427708;AF6016-005;OK
#   for (key in arr_et_pricelist) {
#       if (arr_et_pricelist[key] ~ mat_nr) {
#          split(arr_et_pricelist[key], arr_tmp_10, ";")
#          arr_tmp_11[length(arr_tmp_11)+1] = key ";" arr_tmp_10[2] ";" arr_tmp_10[3]
#       }
#   }
   for (key in arr_et_pricelist) {
      split(arr_et_pricelist[key], arr_tmp_10, ";")
      if (arr_tmp_10[1] ~ mat_nr) {
#         arr_tmp_11[length(arr_tmp_11)+1] = key ";" arr_tmp_10[2] ";" arr_tmp_10[3]
         arr_tmp_11[length(arr_tmp_11)+1] = key ";" arr_tmp_10[2]
      }
   }

   delete arr_tmp_10;

   # sort
   for (k1=1; k1<length(arr_tmp_11); k1++) {
       for (k2=1; k2<=length(arr_tmp_11)-k1; k2++) {

          split(arr_tmp_11[k2], arr_t_01, ";")       # 72427708;AF6016-005;OK
          split(arr_t_01[2], arr_t_01_end, "-")      # AF6016-005 или AF6016-005 SP
          split(arr_t_01_end[2], arr_t_01_end, "SP") # 005 или 005 SP
          min_value1 = "" arr_t_01_end[1]            # принудительное преобразование в строку

          split(arr_tmp_11[k2+1], arr_t_02, ";")     # 72427708;AF6016-005;OK
          split(arr_t_02[2], arr_t_02_end, "-")      # AF6016-005 или AF6016-005 SP
          split(arr_t_02_end[2], arr_t_02_end, "SP") # 005 или 005 SP
          min_value2 = arr_t_02_end[1]
#       print mt calc_spaces(no_of_spaces) k1 ": " arr_tmp_11[k1] " - " min_value1 " /// " arr_tmp_11[k1+1] " - " min_value2 >> result_txt

          if (min_value1 > min_value2) {
             temp_value = arr_tmp_11[k2]
             arr_tmp_11[k2] = arr_tmp_11[k2+1]
             arr_tmp_11[k2+1] = temp_value
          }
       }
   }

}



# CHECK EXISTENCE OF LINK IN FG SHOP and PRINTING IT
#function print_fg_link(mymaterial_nr, no_of_spaces)  {
#   myvar = "https://shopindustrial.filtrationgroup.com/de/" mymaterial_nr ".html"
#   mycmd = "curl -o /dev/null -s -w \"%{http_code}\" " myvar
#   mycmd | getline result
#   close(mycmd)
#   if (result == 200) {
#      spaces1 = ""
#      for (ix=1; ix<=no_of_spaces; ix++)
#        spaces1 = spaces1 " "
#      print spaces1 myvar >> result_txt
#   }
#}
