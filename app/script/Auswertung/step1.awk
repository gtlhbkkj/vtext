
BEGIN {
  RS = "\n"
  FS = "_!_"

  delete arr_product; delete arr_ph_my;
  counter = 0
  result_txt = "myprint.txt"


#  name = "AF7363-1321-00000/G3"
#  znak = "~"
#  maska = "^AF726[0-9]"
#
#  if (name znak maska)
#     print "match" >> result_txt
#  else
#     print " does not match" >> result_txt


}


# начинается проход по файлу данных
{

  # upload shop data
  if (FILENAME ~ "ph_my.txt") {
     if ($3 != "")
       arr_ph_my[length(arr_ph_my)+1] = $1 "_!_" $2 "_!_" $3
  }

  if (FILENAME ~ "product.txt" && counter == 0) {
     RS = "\n"
     FS = ";"
     counter = 1
  }

  if (FILENAME ~ "product.txt") {
     arr_product[$1] = $2
  }


}


END {

   err_counter = 0

   length_arr_ph_my = length(arr_ph_my)
   for (k=1; k<=length_arr_ph_my; k++) {
     split(arr_ph_my[k], arr_ph_1, "_!_")
     ph_my_nr   = arr_ph_1[1]
     ph_my_name = arr_ph_1[2]
     ph_my_re   = arr_ph_1[3]
     print arr_ph_my[k] >> result_txt

     nr_of_re = split(ph_my_re, arr_regex, ",")

     split(arr_regex[1],arr_re1,":")
     split(arr_regex[2],arr_re2,":")

#     print "1. " nr_of_re " ///  RE1: " arr_re1[2] " // RE2: " arr_re2[2] >> result_txt
#     print "arr_regex[1]: " arr_regex[1] >> result_txt
#     print "arr_regex[2]: " arr_regex[2] >> result_txt

     for (key in arr_product) {

        if (nr_of_re == 1) {

           if (arr_product[key] ~ arr_re1[2])
              print key " *** " arr_product[key] >> result_txt

        } else if (nr_of_re == 2) {

           if (arr_product[key] ~ arr_re1[2] && arr_product[key] !~ arr_re2[2])
              print key " *** " arr_product[key] >> result_txt


        } else {
        err_counter++
        }

   } # END OF for (k=1; k<=length_arr_ph_my; k++)


     print "" >> result_txt
   }
   print "Number of Errors: "err_counter >> result_txt

}




function check_in_arr_ad(a) {
   for (x1=1; x1<=length(arr_ad); x1++) {
     if (arr_ad[x1] == a)
         return x1
   }

   return 0
}

function check_in_arr_kg(a) {
   for (x1=1; x1<=length(arr_kg); x1++) {
     if (arr_kg[x1] == a)
         return x1
   }

   return 0
}
