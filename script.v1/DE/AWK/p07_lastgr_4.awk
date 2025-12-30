# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# ::
# G1 -- PN40 -- ELPN 24V -- MS/VERN
# 79751934 *** ANBAUS.KUGELH.G1 PN40MS/VERN.ELPN 24V VP
#
# ABLASSVENTIL AF711_G1,AF713_G1,AF713_GX1_!_1,2,12,13,14,15,16,17,18_!_1,2,3,4_!_1,3_!_2
# RS-VENTIL AF112_G2,AF172_G2,AF113_G3,AF173_G3_!_PORTSIZE_!_PN_!_1,3_!_2
# mit pneumatischem Schwenkantrieb mit 5/2-Wege-Magnetventil 24V DC

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
  rs_ventil            = arr1[10]

  text_ex = ""
  if (motor == 4)
    text_ex = " in ATEX Ausführung Ex II 2G T3"
}


# начинается проход по файлу данных
{
if (rs_ventil != 0 && found == 0) 
  if ($6 ~ filter_series_search) {
     split($6, arr_f, "_!_")
     if (arr_f[4] ~ material && arr_f[5] == rs_ventil) {
        found = 1
        split($2,arr_p,"--")
        _portsize = substr(arr_p[1],3,length(arr_p[1]))
        if (rs_ventil == 1)
           print mt "\n" mt "Hand-Kugelhahn " _portsize " für Rückspüllanschluss" >> "result.txt"
        else 
           print mt "\n" mt "Automatik-Kugelhahn " _portsize " für Rückspüllanschluss" text_ex  >> "result.txt"

        print mt $3 >> "result.txt"

        for (i=7; i<=NF; i++)
          print mt $i >> "result.txt"
      }
   }
}

END {
  if (rs_ventil != 0 && found == 0) {
    err_msg = "NO BACK-FLUSH VALVE DATA FOUND IN <p07_lastgr_34.txt> FOR : ["arr1[2] "], [-.." material "-], [-..." rs_ventil ".]"
    print_values(arr1[2],material,rs_ventil)
  }
  RS = "\n"
  FS = "[[:space:]]+"

}


func print_values(fsr,material,rs_ventil) {
  print mt                                                 >> "result.txt"
  print mt "#############################################" >> "result.txt"
  print mt "### " err_msg                                  >> "result.txt"
  print mt "### filter_series     : [" fsr "]"             >> "result.txt"
  print mt "### material          : [-..." material "-]"   >> "result.txt"
  print mt "### B.Flush valve     : [-..." rs_ventil ".]"  >> "result.txt"
  print mt "#############################################" >> "result.txt"

  print mt "Err.code 0704 - " err_msg                      >> "errlog.txt"
}
