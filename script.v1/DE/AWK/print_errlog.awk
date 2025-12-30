BEGIN {}


{
  if ($0 ~ mt) { 
    print substr($0,24) >> "myerrlog.txt"
#  gsub($0,"",mt); print >> "myerrlog.txt"
  }

}


END {}
