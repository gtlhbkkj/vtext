BEGIN {
split(filter_name, arr_tmp, "PRICE:")
filter_name = arr_tmp[1]
str_price = arr_tmp[2]

  print "\n" >> TMP_DIR "/" UUID ".fin.txt"
  print "=============================================================================" >> TMP_DIR "/" UUID ".fin.txt"
  print substr(mt,1,20)                                                                >> TMP_DIR "/" UUID ".fin.txt"
  print "-----------------------------------------------------------------------------" >> TMP_DIR "/" UUID ".fin.txt"
  print "V-TEXT FOR FILTER : " filter_name                                              >> TMP_DIR "/" UUID ".fin.txt"
  # добавляем цену если она не пустая
  if (str_price != "")
    print "Listenpreis: " str_price ",- EUR St/Brt"  >> TMP_DIR "/" UUID ".fin.txt"
  print "-----------------------------------------------------------------------------" >> TMP_DIR "/" UUID ".fin.txt"
}


{
  if ($0 ~ mt) { 
    print substr($0,24)                   >> TMP_DIR "/" UUID ".fin.txt"
  }
}


END {
  print "-----------------------------------------------------------------------------" >> TMP_DIR "/" UUID ".fin.txt"
}
