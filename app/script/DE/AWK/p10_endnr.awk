# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# 
# ENDNUMMER 
# ::
#-4166: AF736_G3,AF936_G3,AF736_S1,AF737_S1,AF738_S1,AF736_SH1,AF737_SH1,AF738_SH1
#- 3 Abstreifer 3 x 120 ° am Umfang verteilt
#- Elementlagerung und Mitnehmer-Verbindung wie AF73/G
#- verstärkte Abstreifträger

BEGIN {
  RS = "\n::"
  FS = "\n"
  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  endnr                = arr1[13]
  
  if (endnr == "")
    found = 1
}


# начинается проход по файлу данных
{
  if (found == 0 && $0 ~ endnr && $0 ~ filter_series_search) {
     found = 1
     print "\n" mt                                 >> TMP_DIR "/" UUID ".result.txt"
     print mt "[-" endnr "] Sonderausführung:" >> TMP_DIR "/" UUID ".result.txt"
     for (i=4; i<=NF; i++)
       print mt $i                                 >> TMP_DIR "/" UUID ".result.txt"
   }
}


END {
  if (found == 0) {  
    print mt                                                              >> TMP_DIR "/" UUID ".result.txt"
    print mt "### End Number [-" endnr "] NOT FOUND IN DB"                >> TMP_DIR "/" UUID ".result.txt"
    print mt "Err.code 1001 - End Number [-" endnr "] NOT FOUND IN DB"    >> TMP_DIR "/" UUID ".errlog.txt"
  }

  print mt "\n" mt "Betriebsanleitung in Deutsch, English und Französisch"                >> TMP_DIR "/" UUID ".result.txt"


  RS = "\n"
  FS = "[[:space:]]+"

}
