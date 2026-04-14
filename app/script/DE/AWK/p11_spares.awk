# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# 
# ENDNUMMER 
# ::
#-4166: AF736_G3,AF936_G3,AF736_S1,AF737_S1,AF738_S1,AF736_SH1,AF737_SH1,AF738_SH1
#- 3 Abstreifer 3 x 120 ° am Umfang verteilt
#- Elementlagerung und Mitnehmer-Verbindung wie AF73/G
#- verstärkte Abstreifträger

# output1=$(gawk  -v filter_name="$myfiltername" -v my_string=$my_str

BEGIN {
  RS = "\n"
  FS = "_!_"
  n = split(my_string, arr1, ",")
  f_bez = arr1[1]
  material = arr1[6]

  result_txt = TMP_DIR "/" UUID ".result.txt"
  errlog_txt = TMP_DIR "/" UUID ".errlog.txt"
#       print mt "# STILL UNDER DEVELOPMENT // SPARE PARTS LIST: == " f_bez        >> result_txt

  delete arr_pricelist;
#  delete arr_ets01;


  # NEW BLOCK
  delete arr_et_conf;
  delete arr_headers; delete arr_spares;
  read_spares = 0     # do not start reading values until arr_headers is finalized

}


# начинается проход по файлу данных
{

#   if ($1 == "ETS01" && $2 ~ f_bez && check_material($3,material)) {
#      arr_ets01[length(arr_ets01)+1] = $4 ";" $5 ";" $6 ";" $7
#   }


   # NEW BLOCK ####################################
   if ($1 == "ET_SECTION") {
      arr_headers[$2] = $3
   }

   if ($1 == END_OF_BLOCK_ET_SECTION)
      read_spares = 1

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


}


END {

    if (f_bez == "AF724_G4") {
       print mt  >> result_txt
       print mt "-----------------------------------------------------------------------------" >> result_txt
       print mt "# STILL UNDER DEVELOPMENT // SPARE PARTS LIST:"                                >> result_txt
       print mt "# ERSATZTEILE FÜR"                >> result_txt
       print mt "# filter_name: " filter_name                >> result_txt
       print mt "# my_string: " my_string               >> result_txt
       print mt "# Filter_bez: " f_bez " /// Material: " material                >> result_txt
       print mt "-----------------------------------------------------------------------------" >> result_txt

    print mt  >> result_txt
#    print mt "Abstreifer (inkl. Abstreiferfedern):" >> result_txt
#    for (k=1; k<=length(arr_ets01); k++) {
#       split(arr_ets01[k], arr_01, ";")
#
#       if (arr_01[2] != "n/a")
#          price = arr_01[2] " EUR St/Brt"
#       else
#          price = "nicht verkaufsfähig"
#
#       str_arr_01_3 = ""
#       if (arr_01[3] != "")
#          str_arr_01_3 = " /// " arr_01[3] # Abstreifer + 4 Blattfeder
#
#       str_arr_01_4 = ""
#       if (arr_01[4] != "")
#          str_arr_01_4 = " /// " arr_01[4] # 1:71371285,4:79745365
#
#       print mt "   " arr_01[1] " /// " price str_arr_01_3 str_arr_01_4 >> result_txt
#       print_fg_link(substr(arr_01[1],1,8), 6) # SAP Mat-Nr, No of Spaces in the beginning of line
#
#       # prints all single mat-numbers with prices and links
#       print_bom(arr_01[4], 10) # 1:71371285,4:79745365 //// 10 - no of blank spaces
#
#    }




#   print mt "length of arr_et_pricelist: " length(arr_et_pricelist) >> result_txt
#   for (key in arr_et_pricelist)
#     print mt "["key"]: " arr_et_pricelist[key] >> result_txt


   # NEW SECTION ############################################
   print mt "---new block :-------------" >> result_txt
   for (i=1; i<=length(arr_headers); i++) {
      # create arr_spares_tmp[] from string in arr_spares[i]
      delete arr_spares_tmp;
      split(arr_spares[i], arr_spares_1, "_!!_")
#      print mt arr_headers[i] ":" >> result_txt
      for (i1=1; i1<=length(arr_spares_1); i1++) {
         arr_spares_tmp[i1] = arr_spares_1[i1]
#         print mt "   " arr_spares_tmp[i1] >> result_txt
      }

      print_section_of_spares(arr_headers[i])
   }
   # END OF NEW SECTION ############################################


  }  # END OF if (f_bez == "AF724_G4") {


} # END OF END SECTION

# CHECK MATERIAL DURING READING OF ET
function check_material(field3, material) {
  if (field3 == "*" || field3 ~ material)
     return 1
  return 0
}

# CHECK EXISTENCE OF LINK IN FG SHOP and PRINTING IT
function print_fg_link(mymaterial_nr, no_of_spaces)  {
   myvar = "https://shopindustrial.filtrationgroup.com/de/" mymaterial_nr ".html"
   mycmd = "curl -o /dev/null -s -w \"%{http_code}\" " myvar
   mycmd | getline result
   close(mycmd)
   if (result == 200) {
      spaces1 = ""
      for (ix=1; ix<=no_of_spaces; ix++)
        spaces1 = spaces1 " "
      print mt spaces1 myvar >> result_txt
   }
}


# prints all single mat-numbers with prices and links
function print_bom(str_to_split, no_of_spaces) {
   if (str_to_split != "") {                      # 1:71371285,4:79745365
      delete arr_tmp1; delete arr_tmp2

      spaces = ""
      for (ix=1; ix<=no_of_spaces; ix++)
        spaces = spaces " "

      print mt spaces "beinhaltet:"  >> result_txt
      split(str_to_split, arr_tmp1, ",")
      for (k_bom=1; k_bom<=length(arr_tmp1); k_bom++) {
         split(arr_tmp1[k_bom], arr_tmp2, ":")
         kol_vo = arr_tmp2[1]
         mat_nr = arr_tmp2[2]


         split(arr_et_pricelist[mat_nr], arr_et_tmp1, ";")
         et_bezeichnung = arr_et_tmp1[1]

         if (arr_et_tmp1[2] != "n/a")
            et_price = arr_et_tmp1[2] " EUR St/Brt"
         else
            et_price = "nicht verkaufsfähig"

         str_arr_et_tmp1_3 = ""
         if (arr_et_tmp1[3] != "")
            str_arr_et_tmp1_3 = " /// " arr_et_tmp1[3] # Abstreifer + 4 Blattfeder

         str_arr_et_tmp1_4 = ""
         if (arr_et_tmp1[4] != "")
            str_arr_et_tmp1_4 = " /// " arr_et_tmp1[4] # 1:71371285,4:79745365


         print mt spaces kol_vo "x["mat_nr"]: " et_bezeichnung " /// " et_price str_arr_et_tmp1_3 str_arr_et_tmp1_4 >> result_txt
         print_fg_link(mat_nr, 9) # SAP Mat-Nr, No of Spaces in the beginning of line


#         print mt spaces kol_vo "x["mat_nr"]: " arr_et_pricelist[mat_nr]  >> result_txt
#         print mt spaces kol_vo "x["mat_nr"]: " et_bezeichnung " /// " et_price  >> result_txt



      }
   }
}


function  print_section_of_spares(arr_headers_current) {
    print mt >> result_txt
    print mt arr_headers_current ":" >> result_txt

    for (k=1; k<=length(arr_spares_tmp); k++) {
       print mt arr_spares_tmp[k] >> result_txt

       split(arr_spares_tmp[k], arr_01, ";")

       if (arr_01[2] != "n/a")
          price = arr_01[2] " EUR St/Brt"
       else
          price = "nicht verkaufsfähig"

       str_arr_01_3 = ""
       if (arr_01[3] != "")
          str_arr_01_3 = " /// " arr_01[3] # Abstreifer + 4 Blattfeder

       str_arr_01_4 = ""
       if (arr_01[4] != "")
          str_arr_01_4 = " /// " arr_01[4] # 1:71371285,4:79745365

       print mt "   " arr_01[1] " /// " price str_arr_01_3 str_arr_01_4 >> result_txt
       print_fg_link(substr(arr_01[1],1,8), 6) # SAP Mat-Nr, No of Spaces in the beginning of line

       # prints all single mat-numbers with prices and links
       print_bom(arr_01[4], 6) # 1:71371285,4:79745365 //// 10 - no of blank spaces
    }
}
