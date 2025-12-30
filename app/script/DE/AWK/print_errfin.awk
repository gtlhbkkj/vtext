BEGIN {
   print "\n"                                            >> TMP_DIR "/" UUID ".fin.txt"
}


{
  if ($0 ~ mt) { 
    print substr($0,24) >> TMP_DIR "/" UUID ".fin.txt"
  }

}


END { 
  print "-----------------------------------------------------------------------------" >> TMP_DIR "/" UUID ".fin.txt"

}
