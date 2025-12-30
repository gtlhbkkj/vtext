BEGIN {
  print "\n" >> TMP_DIR "/" UUID ".fin.txt"
  print "=============================================================================" >> TMP_DIR "/" UUID ".fin.txt"
  print substr(mt,1,20)                                                                >> TMP_DIR "/" UUID ".fin.txt"
  print "-----------------------------------------------------------------------------" >> TMP_DIR "/" UUID ".fin.txt"
  print "V-TEXT FOR FILTER : " filter_name                                              >> TMP_DIR "/" UUID ".fin.txt"
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
