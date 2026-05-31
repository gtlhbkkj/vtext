# CHECKING VALIDITY OF LINKS ON FG HOME PAGE
#output1=$(gawk -v ftwrite=${file_to_write} -v TXT_DIR=${txtdir} -f $awkdir"p20_check_link.awk" $file_to_read)
# ftwrite / file to write / in TXT directory

BEGIN {
  RS = "\n"
  FS = "_!_"

}


# начинается проход по файлу данных
{
   # everzthing except filter elements
   if ($1 ~ /^7+[0-9]{7}$/ && $2 != "ETDUM994") {

      pri
   #дописываем 3 член = $3 ":OK"


   }

   # filter elements only
   if ($1 ~ /^7+[0-9]{7}$/ && $2 == "ETDUM994") {
   #дописываем 4 членом _!_OK

   }

   # READ SINGLE ITEMS FILE
#   if ($1 ~ /^ETDUM+[0-9]{3}$/ || $1 ~ /^7+[0-9]{7}$/)
#      arr_et_pricelist[$1] = $2 ";" $3 ";" $4 ";" $5


}


END {
}



# CHECK EXISTENCE OF LINK IN FG SHOP and PRINTING IT
function print_fg_link(mymaterial_nr)  {
   myvar = "https://shopindustrial.filtrationgroup.com/de/" mymaterial_nr ".html"
   mycmd = "curl -o /dev/null -s -w \"%{http_code}\" " myvar
   mycmd | getline result
   close(mycmd)
   success = 0
   if (result == 200) {
      success = 1
   }
   return success
}

