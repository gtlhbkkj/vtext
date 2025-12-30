# MATERIAL
#
# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# AF713_H2_!_1_!_Standardausführung

BEGIN {
  RS = "\n::"
  FS = "\n"
  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  filter_series_report = arr1[2]
  port_size            = arr1[4]
  pn                   = arr1[5]
  material             = arr1[6]
  ke300x               = arr1[12]

  if (ke300x ~ /^[3][0][0]/)     # Kompletteinsat 300x
     print mt "\n" mt "Material Deckel und Innenteile:" >> TMP_DIR "/" UUID ".result.txt"
  else
     print mt "\n" mt "Material Behälter und Innenteile:" >> TMP_DIR "/" UUID ".result.txt"
}


# начинается проход по файлу данных
{
if (found == 0 && $2 ~ filter_series_search) {
   split($2, arr_f, "_!_")
   if (arr_f[2] ~ material) {
      found = 1
      print mt arr_f[3] >> TMP_DIR "/" UUID ".result.txt"

      for(i=3; i<=NF; i++) {
         if (ke300x ~ /^[3][0][0]/)     # Kompletteinsat 300x
           sub("Gehäuse und ","",$i)
         print mt $i >> TMP_DIR "/" UUID ".result.txt"
      }
   }
}
}

END {
  if (found == 0) {  # В конце, если found все еще 0
    err_msg = "NO [MATERIAL] DATA FOUND IN <p05_material.txt> FOR : [" arr1[2] "], [.." material "-]"
    print_values(filter_series_report,material,err_msg)
  }
  RS = "\n"
  FS = "[[:space:]]+"

  if (filter_series_search == "AF113_G3" && "1,3" ~ filter_material) {
     print mt "Dichtungswerkstoffe: FKM (Viton), HDPE. Gleitlager: PTFE-Basis" >> TMP_DIR "/" UUID ".result.txt"
     } else {  
     print mt "Dichtungswerkstoffe: FKM (Viton). Gleitlager: PTFE-Basis"       >> TMP_DIR "/" UUID ".result.txt"
  }
}


func print_values(fsr,material,err_msg) {
  print mt "#############################################" >> TMP_DIR "/" UUID ".result.txt"
  print mt "### " err_msg                                  >> TMP_DIR "/" UUID ".result.txt"
  print mt "### filter_series : [" fsr "]"                 >> TMP_DIR "/" UUID ".result.txt"
  print mt "### material      : [.." material "]"          >> TMP_DIR "/" UUID ".result.txt"
  print mt "#############################################" >> TMP_DIR "/" UUID ".result.txt"

  print mt "Err.code 0501 - " err_msg                      >> TMP_DIR "/" UUID ".errlog.txt"
}
