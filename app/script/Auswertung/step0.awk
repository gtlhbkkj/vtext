# формирование трех файлов
# ad.txt
# kg.txt
# debitor.txt

BEGIN {
  RS = "\n"
  FS = ";"

}


# начинается проход по файлу данных
{

  if (FILENAME == "text4.txt")
     if ($1 != "")
        arr_all[$1] = $2 ";" $3 ";" $4

}


END {

   delete arr_debitor; delete arr_kg; delete arr_ad; 

   for (key in arr_all) {
       debitor = key
       split(arr_all[debitor], arr_key, ";")

       if (key != "" && arr_debitor[debitor] == "") {

          d_name = arr_key[1]
          kg     = arr_key[2]
          ad     = arr_key[3]
          if (ad == "")
              print k " / " arr_all[debitor] >> "ad.txt"


          ad_nr = check_in_arr_ad(ad)
          if (ad_nr == 0) {
             ad_nr = length(arr_ad)+1
             arr_ad[ad_nr] = ad
          }


          kg_nr = check_in_arr_kg(kg)
          if (kg_nr == 0) {
             kg_nr = length(arr_kg)+1
             arr_kg[kg_nr] = kg
          }

          arr_debitor[debitor] = d_name ";" ad_nr ";" kg_nr

       }

    }


    # PRINT
    for (i=1; i<=length(arr_ad); i++)
       print i ": " arr_ad[i] >> "ad.txt"

    for (i=1; i<=length(arr_kg); i++)
       print i ": " arr_kg[i] >> "kg.txt"

    for (key in arr_debitor)
       print key ";" arr_debitor[key] >> "debitor.txt"

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
