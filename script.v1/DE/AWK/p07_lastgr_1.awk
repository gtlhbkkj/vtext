# DP MANOMETER
#
# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# ::
# AF713_H2_!_1,3_!_6_!_Differenzdruckschalter PiS 3192, Schaltpunkt bei 2,2 bar, statisch 450 bar 
# Schaltpunkt/ Differenzdruck: PiS 3192/2,2

BEGIN {
  RS = "\n::"
  FS = "\n"
  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  material             = arr1[6]
  dpswitch             = arr1[7]

  motor_no             = arr1[3]
  agroup               = arr1[15]
  ke300x               = arr1[12] 

  if (ke300x ~ /^[3][0][0]/)     # Kompletteinsat 300x
   found = 1

  print mt "\n" mt "Ausgestattet mit folgendem Zubehör, fertig montiert:" >> "result.txt"

  if (dpswitch == 0) {
    print mt "\n" mt "OHNE dP Schalter / dP Manometer"                     >> "result.txt"
    found = 1
  }


  a_text = ""
  if ("4,5" ~ dpswitch) {                  # PIS 3190 / 3175
    if (motor_no == 4 || agroup != "") {
         a_text = " [geeignet nur für ATEX Zone 2 !]"
         print mt "Warning - dP Manometer [-" dpswitch "....] is suitable for EX-Zone 2 only"   >> "errlog.txt"
    }
  }

}


# начинается проход по файлу данных
{
if (found == 0 && $2 ~ filter_series_search) {
   split($2, arr_f, "_!_")
   if (arr_f[2] ~ material && arr_f[3] ~ dpswitch) {
      found = 1
      print mt arr_f[4] a_text >> "result.txt"
      for(i=3; i<=NF; i++) {
         if ($i ~ "_XXX_")
            if (filter_series_search ~ "SH")
               gsub("_XXX_","200",$i)
            else
               gsub("_XXX_","80",$i)

         print mt $i >> "result.txt"
      }
   }
}
}

END {
  if (found == 0) {
    err_msg = "NO DP-SWITCH DATA FOUND IN <p07_lastgr_1.txt> FOR :"
    print_values(arr1[2],material,dpswitch)
  }

#  if (ke300x ~ /^[3][0][0]/)     # Kompletteinsat 300x
#     print mt "OHNE dP Schalter / Manometer"   >> "result.txt"


  RS = "\n"
  FS = "[[:space:]]+"

}


func print_values(fsr,material,dpswitch) {
  print mt                                                 >> "result.txt"
  print mt "#############################################" >> "result.txt"
  print mt "### " err_msg                                  >> "result.txt"
  print mt "### filter_series : [" fsr "]"                 >> "result.txt"
  print mt "### material      : [" material "]"            >> "result.txt"
  print mt "### dpswitch      : [" dpswitch "]"            >> "result.txt"
  print mt "#############################################" >> "result.txt"

  print mt "Err.code 0701 - " err_msg                      >> "errlog.txt"
}
