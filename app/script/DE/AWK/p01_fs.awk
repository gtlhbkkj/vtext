#обозначение фильтра (самая первая строка)
#"AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010,100"

BEGIN {

  RS = "\n"
  FS = "_!_"
  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  filter_series_report = arr1[2]

  if (arr1[12] == "3001")
    print mt "Komplettfiltereinsatz ohne Filtergehäuse, ohne Antrieb, auf dem Deckel montiert zur" >> TMP_DIR "/" UUID ".result.txt"
  if (arr1[12] == "3002")
    print mt "Komplettfiltereinsatz ohne Filtergehäuse, mit Antrieb, auf dem Deckel montiert zur" >> TMP_DIR "/" UUID ".result.txt"

  endnummer = ""
  if (arr1[13] != "")
     endnummer = "in Sonderausführung: Siehe Endnummer [-" arr1[13] "] unten"

  atext = ""
  if (arr1[15] == "A23")
     atext = "in ATEX Ausführung EX II 3G T3"

  if (arr1[15] == "A13")
     atext = "in ATEX Ausführung II 2G Ex h IIB T3 Gb"

  if (arr1[15] == "A14")
     atext = "in ATEX Ausführung II 2G Ex h IIB T4 Gb"

  if (arr1[15] == "A15")
     atext = "in ATEX Ausführung "
}


{
  if (found == 0 && $1 ~ filter_series_search) {
    found = 1
    print mt "Baureihe - " filter_series_report " FILTRATON GROUP " $2 >> TMP_DIR "/" UUID ".result.txt"
    if (endnummer != "") 
       print mt endnummer >> TMP_DIR "/" UUID ".result.txt"
    if (atext != "") 
       print mt atext >> TMP_DIR "/" UUID ".result.txt"
  }
}

END {
  if (found == 0) {  # В конце, если found все еще 0
    err_msg = "NO DESCRIPTION FOUND FOR SERIES : [" filter_series_search "] IN <p01_fs.txt>"
    print mt "####################################################" >> TMP_DIR "/" UUID ".result.txt"
    print mt "## " err_msg                                          >> TMP_DIR "/" UUID ".result.txt"
    print mt "####################################################" >> TMP_DIR "/" UUID ".result.txt"
    print mt "Err.code 0101 - " err_msg                             >> TMP_DIR "/" UUID ".errlog.txt"
  }
  RS = "\n"
  FS = "[[:space:]]+"
}
