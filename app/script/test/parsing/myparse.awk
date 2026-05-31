BEGIN {

   code1 = "D2-255"
   code2 = "D2-151"
   code3 = "D2-155"
   code3 = "D2-153"

   delete myarr1;   delete myarr2;   delete myarr3;  delete myarr4;
   myc1 = myc2 = myc3 = myc4 = 0  # my counters
}

{

   # code1
   if (myc1 == 0 && $0 ~ "<tr data-number=\"" code1 "\" data-search=\"" code1) {
      myc1 = 1
   }

   if (myc1 == 1) {
      mystring1 = $0
      gsub(/^ +/,"",mystring1)
      myarr1[length(myarr1)+1] = mystring1
   }

   if (myc1 == 1 && $0 ~ "</tr>") {
     myc1 = 2
   }

   # code2
   if (myc2 == 0 && $0 ~ "<tr data-number=\"" code2 "\" data-search=\"" code2) {
      myc2 = 1
   }

   if (myc2 == 1) {
      mystring2 = $0
      gsub(/^ +/,"",mystring2)
      myarr2[length(myarr2)+1] = mystring2
   }

   if (myc2 == 1 && $0 ~ "</tr>") {
     myc2 = 2
   }




} # END OF BLOCK

END {

   delete myarr_tmp;
   # code1
   for (k=1; k<=length(myarr1); k++) {
      if (myarr1[k] ~ "<div class=\"color-black\">" ) {
         split(myarr1[k], myarr_tmp,"<div class=\"color-black\">")
         if (substr(myarr_tmp[2],1,5) ~ /[0-9]{2}:[0-9]{2}/) #{
            print code1 " - " substr(myarr_tmp[2],1,5)
         else
            print code1 " - " 
#         }
         break
      }
   }

   delete myarr_tmp;
   # code2

   for (k=1; k<=length(myarr2); k++) {
      if (myarr2[k] ~ "<div class=\"color-black\">" ) {
         split(myarr2[k], myarr_tmp,"<div class=\"color-black\">")
         if (substr(myarr_tmp[2],1,5) ~ /[0-9]{2}:[0-9]{2}/) {
            print code2 " - " substr(myarr_tmp[2],1,5)
         }
         break
      }
   }


}



