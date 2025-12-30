BEGIN {
   print "\n"                                            >> "fin.txt"
}


{
  if ($0 ~ mt) { 
    print substr($0,24) >> "fin.txt"
  }

}


END { 
  print "-----------------------------------------------------------------------------" >> "fin.txt"

}
