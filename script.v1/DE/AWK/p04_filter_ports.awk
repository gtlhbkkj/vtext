# Part 3 - Filter ports
#
# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"

BEGIN {
  RS = "\n::"
  FS = "\n"
  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  ps                   = arr1[4]
  port_size            = "," ps ","
  pn                   = arr1[5]
  material             = arr1[6]
  ke300x               = arr1[12]

  print mt "\n" mt "Behälteranschlüße:" >> "result.txt"
  # print_values(filter_series_search,port_size,pn,material)

  # если размер порта = 0 и 3001, 3002
#  if (ps == 0 && (arr1[12] == "3001" || arr1[12] == "3002")) {
  if (ps == 0 && ke300x ~ /^[3][0][0]/) {
     found = 1
     print mt "Filtergehäuse ist nicht im Lieferumfang" >> "result.txt"
  }

  if (ps == 0 && ke300x !~ "300") {
     found = 1
     print mt "Sondersuaführung: siehe Endnummer" >> "result.txt"
  }
}


# начинается проход по файлу данных
{
  if (found == 0 && $2 ~ filter_series_search) {
     split($2, arr_f, "_!_")
     if (arr_f[2] ~ port_size && arr_f[3] ~ pn && arr_f[4] ~ material) {
       found = 1
       for(i=3; i<=NF; i++) {
          if ($i ~ "DN_XXX_")
            gsub("DN_XXX_",find_dn(ps),$i)
          if ($i ~ "PN_XXX_")
            gsub("PN_XXX_",find_pressure(pn),$i)
          print mt $i >> "result.txt"
       }
     }
  }
}

END {
  if (found == 0) {  # В конце, если found все еще 0
    err_msg = "NO PORT DATA FOUND IN <p04_filter_ports.txt> FOR : ["arr1[2] "], [-.." ps ".-], [PN" pn "], [..." material "-]"
    print_values(arr1[2],ps,pn,material,err_msg)
  }

  # Pressure and T
  dt = 100
  if (arr1[1] ~ "SH1")
     dt = 200
  print mt "\n" mt "Auslegungsdaten: "                  >> "result.txt"
  print mt "Auslegungstemperatur: " dt " Grad C"        >> "result.txt"
  print mt "Auslegungsdruck: " find_pressure(pn) " bar" >> "result.txt"

  RS = "\n^^"
  FS = "[[:space:]]+"
}



func print_values(fsr,port_size,pn,material,err_msg) {
  print mt "#############################################" >> "result.txt"
  print mt "### " err_msg                                  >> "result.txt"
  print mt "### filter_series : [" fsr "]"                 >> "result.txt"
  print mt "### port_size     : [" port_size "]"           >> "result.txt"
  print mt "### PN            : [" pn " bar ]"             >> "result.txt"
  print mt "### material      : [" material "]"            >> "result.txt"
  print mt "#############################################" >> "result.txt"

  print mt "Err.code 0401 - " err_msg                      >> "errlog.txt"
}

func find_pressure(pn) {
arr_pn[0]="Sonderausführung. Siehe Endnummer"
arr_pn[1]="10"
arr_pn[2]="16"
arr_pn[3]="25"
arr_pn[4]="40"
arr_pn[5]="63"
arr_pn[6]="100"
arr_pn[7]="160"
arr_pn[8]="250"
arr_pn[9]="400"

 if (pn in arr_pn)
   return arr_pn[pn]
 else {
   print mt "######## PN = [" pn "] bar NOT FOUND in DB. PLS CHECK INPUT"        >> "result.txt"
   print mt "Err.code 0302 - PN = [" pn "] bar NOT FOUND in DB. PLS CHECK INPUT" >> "errlog.txt"
 }
}

func find_dn(dn) {
arr_pn[0]="Sonderausführung. Siehe Endnummer"
arr_pn[2]="DN40"
arr_pn[3]="DN50"
arr_pn[4]="DN65"
arr_pn[5]="DN80"
arr_pn[6]="DN100"
arr_pn[7]="DN125"
arr_pn[8]="DN150"
arr_pn[9]="DN200"

 if (dn in arr_pn)
   return arr_pn[dn]
 else {
   print mt "######## DN = " dn " bar NOT FOUND in DB. PLS CHECK INPUT"        >> "result.txt"
   print mt "Err.code 0302 - PN = " pn " bar NOT FOUND in DB. PLS CHECK INPUT" >> "errlog.txt"
 }
}
