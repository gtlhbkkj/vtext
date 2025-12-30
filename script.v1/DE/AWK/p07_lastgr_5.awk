# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
#
# BYPASS, BESONDERHEITEN

BEGIN {
  n = split(my_string, arr1, ",")
  filter_series_search = arr1[1]
  bypass               = arr1[11]

  # Print Bypass TEXT
  if (bypass == 1) {
     if ("AF713_H2,AF724_G4" ~ arr[1]) {
       print "\n" mt                >> "result.txt"
       print mt "mit Bypass 20 bar" >> "result.txt"
     } else {
       print "\n" mt                >> "result.txt"
       print mt "######## IS BYPASS POSSIBLE WITH " arr[1] " FILTER ?"        >> "result.txt"   
       print mt "Err.code 0705 - IS BYPASS POSSIBLE WITH " arr[1] " FILTER ?" >> "errlog.txt"
     }

     if (bypass > 1) {
       print "\n" mt                >> "result.txt"
       print mt "######## UNKNOWN VALUE FOR BYPASS [-...." arr[11] "-]"        >> "result.txt"
       print mt "Err.code 0706 - UNKNOWN VALUE FOR BYPASS [-...." arr[11] "-]" >> "errlog.txt"
     }
  }

  # Print Besonderheiten TEXT
  if (filter_series_search == "AF713/GX2") {
    print "\n" mt 
    print "\n" mt "[-/GX2] Ausführung:"  >> "result.txt"
    print mt "Wellenabdichtung mit Sperrflüssigkeitsadapter (2x Anschlüsse mit Gewinde M8x1)" >> "result.txt"
    print mt "Sperrflüssigkeitskammer werkseitig mit wasserfreier Vaseline befüllt und mit Verschlussschrauben verschlossen"  >> "result.txt"
  }
}


# начинается проход по файлу данных
#{
#}

#END {}
