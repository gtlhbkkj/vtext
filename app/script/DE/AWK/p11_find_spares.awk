# mystring = "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# output1=$(gawk  -v filter_name="$myfiltername" -v my_string=$my_str
# find out name of our TXT files for ET Data

BEGIN {
  RS = "\n"
  FS = "_!_"
  n = split(my_string, arr1, ",")
  f_bez = arr1[1]

  my_et_filename = ""
}


# начинается проход по файлу данных
{
   if ($1 == "READY" && $2 ~ f_bez) {
       my_et_filename = $3
   }
}


END {
   print my_et_filename

}
