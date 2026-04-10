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

  delete arr_ets01;

}


# начинается проход по файлу данных
{

   if ($1 == "ETS01" && $2 ~ f_bez && check_material($3,material)) {
      arr_ets01[length(arr_ets01)+1] = $4 ";" $5 ";" $6 ";" $7
   }

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
    print mt "Abstreifer (inkl. Abstreiferfedern):" >> result_txt
    for (k=1; k<=length(arr_ets01); k++) {
       split(arr_ets01[k], arr_01, ";")

       if (arr_01[2] != "n/a")
          price = arr_01[2] " EUR St/Brt"
       else
          price = "nicht verkaufsfähig"

       str_arr_01_3 = ""
       if (arr_01[3] != "")
          str_arr_01_3 = " /// " arr_01[3] 

       str_arr_01_4 = ""
       if (arr_01[4] != "")
          str_arr_01_4 = " /// " arr_01[4] 

       print mt "   " arr_01[1] " /// " price str_arr_01_3 str_arr_01_4 >> result_txt

#
#       print mt "   " arr_01[1] " /// " price " /// " arr_01[3] " /// " arr_01[4] >> result_txt
       print_fg_link(substr(arr_01[1],1,8), 6) # SAP Mat-Nr, No of Spaces in the beginning of line
    }

    }  # END OF if (f_bez == "AF724_G4") {


}

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
      spaces = ""
      for (ix=1; ix<=no_of_spaces; ix++)
        spaces = spaces " "
      print mt spaces myvar >> result_txt
   }
}
