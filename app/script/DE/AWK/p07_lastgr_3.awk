# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# ::
# G 1/2 -- PN400 -- HAND -- C-Stahl
# 79717406 *** KUGELH G1/2 PN400 ST HAND /// Status 79
#
# ABLASSVENTIL AF713_H2_!_1,2,12,13,14,15,16,17,18_!_9_!_1,3_!_1
# RS-VENTIL --
# KUGELH G1/2 PN400ST HAND

BEGIN {
  RS = "\n::"
  FS = "\n"
  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  motor                = arr1[3]
  ps                   = arr1[4]
  port_size            ="," ps ","
  pn                   = arr1[5]
  material             = arr1[6]
  ablass               = arr1[9]
  ke300x               = arr1[12]

  text_ex = ""
  if (motor == 4)
    text_ex = " in ATEX Ausführung Ex II 2G T3"

  if (ke300x ~ /^[3][0][0]/)     # Kompletteinsat 300x
    found = 1
}


# начинается проход по файлу данных
{
if (found == 0 && ablass != 0)
  if ($5 ~ filter_series_search) {
     split($5, arr_f, "_!_")
     if (arr_f[2] ~ port_size && arr_f[3] ~ pn && arr_f[4] ~ material && arr_f[5] == ablass  ) {
        found = 1
        split($2,arr_p,"--")
        _portsize = substr(arr_p[1],3,length(arr_p[1]))
         if (ablass == 1)
            print mt "\n" mt "Hand-Kugelhahn " _portsize " für Ablass- bzw. Entleerungsanschluss" >> TMP_DIR "/" UUID ".result.txt"
         else 
            print mt "\n" mt "Automatik-Kugelhahn " _portsize " für Ablass- bzw. Entleerungsanschluss" text_ex  >> TMP_DIR "/" UUID ".result.txt"

         print mt $3 >> TMP_DIR "/" UUID ".result.txt"

         for (i=7; i<=NF; i++)
           print mt $i >> TMP_DIR "/" UUID ".result.txt"
      }
   }
}

END {
  if (found == 0 && ablass != 0) {  # В конце, если found все еще 0
    err_msg = "NO DRAIN VALVE DATA FOUND IN <p07_lastgr_34.txt> FOR : "
    print_values(arr1[2],port_size,pn,material,ablass)
  }

   if (filter_series_search != "AF122_G1") {
      if (ke300x ~ /^[3][0][0]/ || ablass == 0)     # Kompletteinsat 300x
      print mt "\n" mt "OHNE Ablassventil"   >> TMP_DIR "/" UUID ".result.txt"
   }

  RS = "\n"
  FS = "[[:space:]]+"
}


func print_values(fsr,port_size,pn,material,ablass) {
  print mt                                                 >> TMP_DIR "/" UUID ".result.txt"
  print mt "#############################################" >> TMP_DIR "/" UUID ".result.txt"
  print mt "### " err_msg                                  >> TMP_DIR "/" UUID ".result.txt"
  print mt "### filter_series   : [" fsr "]"               >> TMP_DIR "/" UUID ".result.txt"
  print mt "### port size       : [-" port_size "..-"      >> TMP_DIR "/" UUID ".result.txt"
  print mt "### design pressure : [-.." pn ".-]"           >> TMP_DIR "/" UUID ".result.txt"
  print mt "### material        : [-..." material "-]"     >> TMP_DIR "/" UUID ".result.txt"
  print mt "### drain valve     : [-.." ablass "..]"       >> TMP_DIR "/" UUID ".result.txt"
  print mt "#############################################" >> TMP_DIR "/" UUID ".result.txt"

  print mt "Err.code 0703 - " err_msg                      >> TMP_DIR "/" UUID ".errlog.txt"
}

