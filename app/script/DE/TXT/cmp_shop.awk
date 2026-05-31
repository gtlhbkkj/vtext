# первое обращение к данным в онлайншопе

BEGIN {
  RS = "\n"
  FS = "_!_"

#  result_txt = TMP_DIR "/" UUID ".result.txt"
  result_txt = "test_AF736.txt"

  delete arr_shop;
}


# начинается проход по файлу данных
{
if (FILENAME == "shopdata.txt") {
   arr_shop[$1] = $3
} else {

   print $0 >> result_txt

   # items in paragraphs
   if ($1 ~ /^ETS/ && substr($4,1,8) ~ /^7+[0-9]{7}$/) {

      if (arr_shop[substr($4,1,8)] != "") {
         fields67 = ""
         if ($6 != "") {
            fields67 = "_!_" $6
            if ($7 != "")
               fields67 = fields67 "_!_" $7
         }
         print "-" $1 "_!_" $2 "_!_" $3 "_!_" $4 "_!_" arr_shop[substr($4,1,8)] fields67 >> result_txt
#         print "- " $5 " / " arr_shop[substr($4,1,8)] >> result_txt
      }

   # single positions except elements
   } else if ($1 ~ /^7+[0-9]{7}$/ && $2 !~ /^ETDUM9/) {

      if (arr_shop[$1] != "") {
         fields45 = ""
         if ($4 != "") {
            fields45 = "_!_" $4
            if ($5 != "")
               fields45 = fields45 "_!_" $5
         }
         print "-" $1 "_!_" $2 "_!_" arr_shop[$1] fields45 >> result_txt
#         print "- " $3 " / " arr_shop[$1] >> result_txt
      }


   }
}


} # END OF MIDDLE BLOCK


END {

}
