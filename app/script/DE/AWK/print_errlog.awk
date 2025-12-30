BEGIN {}


{
  if ($0 ~ mt) { 
    print substr($0,24) >> TMP_DIR "/" UUID ".myerrlog.txt"
#  gsub($0,"",mt); print >> TMP_DIR "/" UUID ".myerrlog.txt"
  }

}


END {}
