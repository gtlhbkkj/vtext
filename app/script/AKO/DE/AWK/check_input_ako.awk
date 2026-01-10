BEGIN {
  print "-----------------------------------------------------------------------------" >> errlog_txt
  print "<B>" mt "CHECK LOG FOR FILTER : [" filter_name  "]</B>"                                      >> errlog_txt
  print "-----------------------------------------------------------------------------" >> errlog_txt

  RS = "\n"
  FS = "_!_"


#получаем входные переменные mt, filter_name, result_txt

error_code = 0

################################################
# 1. Убираем двойные пробелы. 
################################################
#убираем все кроме заглавных букв цифр и пробелов плюсов и минусов

gsub(/[^A-Za-z0-9 \-\+]/,"",filter_name)
gsub(/[ ]{2,}/," ",filter_name)
no_of_parts = split(filter_name,parts," ")

# FRR143110G21B410 1K250 DT002L SG21AE01K002
# 123456789012345678901234567890123456789012

# проверить 
# формат ввода Einsatz
# "S"+p06 == s01, если он введен

if (length(parts[1]) < 6) {
  print "Err. 0001 - FILTER NAME IS TOO SHORT, PLS ENTER AT LEAST 6 CHARACTERS" >> errlog_txt
  error_code = 1
  exit
}

arr_input_str[1] = p01 = substr(parts[1],1,3)    # FRR
arr_input_str[2] = substr(parts[1],4,2)
p02s= substr(parts[1],1,5)              # FRR14
p02 = substr(parts[1],1,6)              # FRR143
arr_input_str[3] = arr_input_str[4] = p03 = substr(parts[1],7,1);  # 1 = Lage der HA 
arr_input_str[5] = p04 = substr(parts[1],8,1);  # 1 = Deckelverschlussart
arr_input_str[6] = p05 = substr(parts[1],9,1);  # 0 = Sonderheiten 
p06 = substr(parts[1],10,3);  # G21 = Einsatz
arr_input_str[7] = p07 = substr(parts[1],13,1) # B
arr_input_str[8] = p08 = substr(parts[1],14,1) # 4
#p09 = substr(parts[1],15,1) # 1
arr_input_str[9] = p09 = substr(parts[1],15,2) # 0

if (length(p09) == 1)
    p09 = "00"



if (p06 != "" && p06 !~ /^(F|G)[0-9]{2}$/) {
  print "Err. 0002 - FILTER INSERT NAME [" p06 "] IS WRONG" >> errlog_txt
  error_code = 1
  exit
}

# добавили переменные
flansch_size   = substr(parts[1],4,2)     # [14]
norm_der_flansch = substr(parts[1],6,1)  # [3] или [W]

fsstr_short = p01                         # FRR    / FRB
fsstr_middle = p02s                       # FRR14  / FRB06
fsstr_long1 = fsstr_long2 = p02           # FRR143
if (p01 == "FRB" || p01 == "FRN" ) {
   fsstr_long1 = fsstr_short              # FRR143 / FRB
   fsstr_long2 = fsstr_middle             # FRR143 / FRB06
}
smotor = motor = ""
fsstr_m_einsatz = p02
if (p01 == "FRB" || p01 == "FRN" )
   fsstr_m_einsatz = fsstr_long2 "_" p06


# r01 = substr(parts[3],1,2)  # DT
# r02 = substr(parts[3],3,1)  # 0
# r03 = substr(parts[3],4,1)  # 0
# r04 = substr(parts[3],5,1)  # 2
# r05 = substr(parts[3],6,1)  # L
# r06 = substr(parts[3],7,1)  # X

# ошибка при поиске find_error изначально присваиваем единицу, а если найдено то меняем на 0
for (i=1; i<=13; i++)
   ferr[i] = 1
tferr[1]=  "Check 0003 =Filter Series identification=: [" p01 "]"
tferr[2]=  "Check 0004 =CHECK_FLANSCHE= [" fsstr_long2 "]"
tferr[3]=  "Check 0005 =CHECK feasibility (LdH) Lage der Hauptanschlüsse=: " p02 "["p03"]" p04 p05 p06
tferr[4]=  "Check 0006 =CHECK Info zur (LdH) Lage der Hauptanschlüsse=: " p02 " ["p03"]" p04 p05 p06
tferr[5]=  "Check 0007 =CHECK Deckelverschlussart=: "  p02 p03 "["p04"]" p05 p06
tferr[6]=  "Check 0008 =CHECK Sonderheiten=: "  p02 p03 p04  "["p05"]" p06 p07 p08
tferr[7]=  "Check 0009 =CHECK Wekrstoff Ausführung Geh=: " p02 p03 p04 p05 p06 "["p07"]"
tferr[8]=  "Check 0010 =CHECK Werkstoff Düse=: " p02 p03 p04 p05 p06 p07 "["p08"]" p09
tferr[9]=  "Check 0011 =CHECK Einsatz 1x RUN=: " p02 p03 p04 p05 "["p06"]"
tferr[10]= "Check 0012 =CHECK Einsatz 2x RUN=: " p02 p03 p04 p05 "["p06"]"
tferr[11]= "Check 0013 =CHECK Endnummer=: " p02 p03 p04 p05 p06 p07 p08 "["p09"]"
tferr[12]= "Check 0014 =CHECK Sondermotor=: " p02 p03 p04 p05 p06 p07 p08 "["p09"]"
tferr[13]= "Check 0015 =CHECK Standardmotor=: " p02 p03 p04 p05 p06 p07 p08 p09

# 1 величина - это номер ошибки tferr[i]
arr_radio[1] = "1__p01__Filter Series:"
arr_radio[2] = "2__p02__Anschlüsse und Nennweiten:"
arr_radio[3] = "3__p03__Lage der Hauptanschlüsse:"
arr_radio[4] = "5__p04__Deckelverschlussart:"
arr_radio[5] = "6__p05__Sonderheiten:"
arr_radio[6] = "10__p06__Filtereinsatz:"
arr_radio[7] = "7__p07__Ausführung Gehäuse:"
arr_radio[8] = "8__p08__Werkstoff Düse:"

str_log[1] = "# !_1_! Filter indentification FRR = R5-8, FRZ = AF8, FRB = R8-10"
str_log[2] = "# !_03+04_! Check feasibility of Anschlüssgröße and Norm:"
str_log[3] = "# !_03_! Anschlußgröße Zu- und Ablauf: - похоже, что нужно только для второго прохода"
str_log[4] = "# !_04_! Nenndruck + Norm der Filteranschlüsse: - похоже, что нужно только для второго прохода"
str_log[5] = "# !_05-1_! Check feasibility Lage der Hauptanschlüsse"
str_log[6] = "# !_06_! Deckelverschlussart"
str_log[7] = "# !_07_! Sonderheiten"
str_log[8] = "# !_10_! Wekrstoff Ausführung Geh: z.B. \"B\" = Beschichtet"
str_log[9] = "# !_11_! Werkstoff Düse: z.B. "4" = Gussbronze"
str_log[10] = "# !_12_! Check Einsatz. First run"
str_log[11] = "# !_13_! Check Einsatz. Second run"
str_log[12] = "# !_14_! Check Endnummer / Konstruktionsmerkmale"
str_log[13] = "# !_15_! Check Sondermotor"
str_log[14] = "# !_16_! Check Standardmotor"
# если есть зондер мотор то сначала проверяем его  информацию
# если их нет то проверяем стандартный мотор
# вентиль проверять нет возможности


# инициализировать текстовые величины - это текст для радио кнопок
tp01=tp02=tp03=tp04=tp05=tp06=tp07=tp08=tp09=tp10=""
tr01=tr02=tr03=tr04=tr05=tr06=""

# found radio p01, etc. -- параметры кот ищем для радиокнопок
#frp01=frp02=frp03=frp04=frp05=frp06=frp07=frp08=frp09=frp10=0
#frr01=frr02=frr03=frr04=frr05=frr06=0

einsatztype = "E:" substr(p06,1,1)
if (substr(p06,1,1) == "")
   einsatztype = "E:X"

if (p01 == "FRN")
   einsatztype = "E:G"



}
# END OF BEGIN BLOCK


# ТЕЛО
{
  # собираем данные для скрытых полей на базе введенного обозначения
  # !_1_! FRR = R5-8, FRZ = AF8, FRB = R8-10
  if (ferr[1] == 1 && p01 != "" && $2 ~ p01 && $3 ~ einsatztype) {
      ferr[1] = 0
      tp01 = $4
      print_found(str_log[1], tferr[1], "p01 = [" p01 "]; Einsatz = [" einsatztype "]",tp01)
   }

   # !_03+04_! Check feasibility of Anschlüssgröße and Norm:
   if (ferr[2] == 1 && $1 == "CHECK_FLANSCHE" && $2 ~ fsstr_long2) {
       ferr[2] = 0
       print_found(str_log[2], tferr[2], "{$2 ~ fsstr_long2} = [" fsstr_long2 "]" ,$0)
   }

   # !_03_! Anschlußgröße Zu- und Ablauf: - похоже что реально нужно для 2-го прохода, а сейчас только для комфортного вывода
   if (ferr[2] == 0 && $1 == "FLANSCH_SIZE") {
        ag = $2
        split(ag,arr_ag, ";")
        for (i=1; i<=length(arr_ag); i++) {
           split(arr_ag[i],arr_agtemp, "-")
           if (arr_agtemp[1] == flansch_size) {
                tp02 = "Anschlußgröße Zu- und Ablauf: " arr_agtemp[2]
                print_found(str_log[3], tferr[2], "FLANSCH_SIZE", tp02)
           }
        }
   }

   # !_04_! Nenndruck + Norm der Filteranschlüsse: - похоже, что нужно только для второго прохода
   if ( ferr[2] == 0 && $1 == "NORM_DER_FLANSCH") {
        ag = $2
        split(ag,arr_ag, ";")
        for (i=1; i<=length(arr_ag); i++) {
           split(arr_ag[i],arr_agtemp, "=")
           if (arr_agtemp[1] == norm_der_flansch) {
                tp02 = tp02 " " arr_agtemp[2]
                print_found(str_log[4], tferr[2], "NORM_DER_FLANSCH", tp02)
           }
        }
   }

   # !_05-1_! CHECK feasibility Lage der Hauptanschlüsse
   if (ferr[3]==1 && p03 != "" && $1 == "CF_LDH" && $2 ~ p01 && $3 ~ p03) {
      ferr[3] = 0
      print_found(str_log[5], tferr[3], "$1 == CF_LDH; $2 ~ p01 / ["p01"]; $3 ~ p03 / ["p03"]" ,$0)
   }

   # !_05_! Lage der Hauptanschlüsse
     if (ferr[3] == 0 && p03 != "" && $1 == "LDH" && $2 == p03) {
         ferr[4] = 0
         tp03 = "Lage der Hauptanschlüsse : " $3
         arr_radio[3] = "HIDDEN-" arr_radio[3]  # раз мы его выше нашли в DB. То прячем / не выводим в радио блоке
         print_found(str_log[5], tferr[4], "$1 == LDH; $2 == p03 / ["p03"]" ,tp03)
      }

   # !_06_! Deckelverschlussart
     if (ferr[5] == 1 && p04 != "" && $1 == "Deckel" && $2 ~ p01 && $3 == p04) {
         ferr[5] = 0
         tp04 = "Deckelverschlussart : " $4
         arr_radio[4] = "HIDDEN-" arr_radio[4]
         print_found(str_log[6], tferr[5], "$1 == \"Deckel\"; $2 ~ p01 / ["p01"]; $3 == p04 / ["p04"]" ,tp04)
      }

   # !_07_! Sonderheiten
     if (ferr[6] == 1 && p05 != "" && $1 == "SH" && $2 ~ fsstr_long1 && $3 == p05) {   # у FRB fsstr_long1 = “FRB”
         ferr[6] = 0
         tp05 = "Sonderheiten : " $4
         arr_radio[5] = "HIDDEN-" arr_radio[5]
         print_found(str_log[7], tferr[6], "$1 == \"SH\"; $2 ~ fsstr_long1 / ["fsstr_long1"]; $3 == p05 / ["p05"]" ,tp05)
      }

   # !_10_! Wekrstoff Ausführung Geh: "B" = Beschichtet
     if (ferr[7] == 1 && p07 != "" && $1 == "WS_GEH" && $2 ~ fsstr_long1 && $3 == p07) {   # у FRB fsstr_long1 = “FRB”
         ferr[7] = 0
         tp07 = "Wekrstoff Ausführung Geh : " $4
         arr_radio[7] = "HIDDEN-" arr_radio[6]
         print_found(str_log[8], tferr[7], "$1 == \"WS_GEH\"; $2 ~ fsstr_long1 / ["fsstr_long1"]; $3 == p07 / ["p07"]" ,tp07)
      }

   # !_11_! Werkstoff Düse: "4" = Gussbronze
     if (ferr[8] == 1 && p08 != "" && $1 == "WDuese" && $2 ~ fsstr_long1 && $3 == p08) {   # у FRB fsstr_long1 = “FRB”
         ferr[8] = 0
         tp08 = "Wekrstoff Düse : " $4
         arr_radio[8] = "HIDDEN-" arr_radio[7]
         print_found(str_log[9], tferr[8], "$1 == \"WDuese\"; $2 ~ fsstr_long1 / ["fsstr_long1"]; $3 == p08 / ["p08"]" ,tp08)
      }

   # END-NUMMER
     if (p09 != "" && p09 != "00" && $1 == "END_NR" && $2 == p09 && $3 ~ p01 && ($4 ~ p06 || $4 == "ALL")) { # fsstr_long2 FRB = 5 cимв. / остальные 6
        ferr[11] = 0
        print_found(str_log[12], tferr[11], "END_NR == ["p09"]" ,$0)
        if ($0 ~ "MOTOR") {
            split($5,arr_5,";")
            for (i=1; i<= length(arr_5); i++) {
               if (arr_5[i] ~ "MOTOR") {
                  split(arr_5[i],arr_arr_5,"__")
                  smotor = arr_arr_5[2]
                  ferr[13] = 0
               }
            }
            print_found(str_log[12], tferr[11], "END_NR == ["p09"]; Sondermotor = [" smotor "]" ,$0)
        }
     }

   # EINSATZ_BEZ первый проход
     if (p06 !="" && ferr[9] == 1 && $1 == "EINSATZ_BEZ_3Z" && $2 ~ fsstr_long2 && $3 ~ p06) { # fsstr_long2 FRB = 5 cимв. / остальные 6
        ferr[9] = 0
        print_found(str_log[10], tferr[9], "$1 == \"EINSATZ_BEZ_3Z\"; $2 ~ fsstr_long2 / ["fsstr_long2"]; $3 ~ p06 / ["p06"]" ,$0)
     }

   # EINSATZ_BEZ второй проход
   # берем все Einsatz кот соответст FRR143 напр.
     if (ferr[10] == 1 && $1 == "EINSATZ_BEZ" && $2 ~ fsstr_long2) {  # fsstr_long2 FRB = 5 cимволов / остальные 6
        if (tp06 == "")
           tp06 = $3
        else
           tp06 = tp06 "," $3

        print_found(str_log[11], tferr[10], "$1 == \"EINSATZ_BEZ\"; $2 ~ fsstr_long2 / ["fsstr_long2"]" ,tp06)
      # tp06 = "SF07S.0XX000_OPT,SF07A.01E000_OPT,SF07A.07E000_PT2,SF07A.07EW00_PT2,SG20A.01E002_OPT,SG20A.07E002_OPT
     }

   # !__! # ПРОВЕРКА ЗОНДЕРМОТОРА ЕСЛИ ОН ЕСТЬ
     if (smotor != "" && ferr[12] == 1 && $2 == "Antrieb" && $3 ~ smotor) {
#          print "ferr[12] = " ferr[12] >>  errlog_txt
         ferr[12] = 0
         print_found(str_log[13], tferr[12], "Sonderantrieb = ["smotor"]", $3)
      }

   # !__! # ПРОВЕРКА ОБЫЧНОГО МОТОРА ЕСЛИ ОН ЕСТЬ В СПИСКЕ
     if (smotor == "" && ferr[13] == 1 && $2 == "Antrieb" && $1 ~ fsstr_m_einsatz) {   # FRB, FRN = FRB08_F05
         ferr[13] = 0
         motor = substr($3,1,8)
         print_found(str_log[14], tferr[13], "Standardmotor for ["fsstr_m_einsatz"]", $3)
      }

  # ------- добавить проверку величин из 4 гр SG21AE01K002, если он введен ------ !!!!!!!!!!!!!!!!
  if ($1 == "ELEMENT_TYPE1")
      ts02 = $2
  if ($1 == "ELEMENT_TYPE2")
      ts04 = $2
  if ($1 == "MATERIAL_GK")
      ts05 = $2
  if ($1 == "OPT_PT2_PT3")
      ts06 = $2
  if ($1 == "GEWEBE_NR")
      tq02 = $2
  if ($1 == "DPM_OPTIONS")
      tr01 = $2
  if ($1 == "RS_VENTIL_OPTIONS")
      tr04 = $2
  if ($1 == "EL_STEUERUNG_OPTIONS")
      tr05 = $2

  # !_05-2_! CHECK Lage der Hauptanschlüsse for RADIO-Buttons
  # CF_LDH_RADIO_!_FRR=1;FRZ=1,8;FRB=1,2,3,4,5,6,7,8,9
  if ($1 == "CF_LDH_RADIO") {
        radio_ldh = $2
        split(radio_ldh, arr_radio_ldh, ";")
  }

  # !_05_! Lage der Hauptanschlüsse
  if (p03 == "" && $1 == "LDH") {
     for (i=1; i<=length(arr_radio_ldh); i++)  {
        split(arr_radio_ldh[i], arr_ldh_values, "=")
        if (arr_ldh_values[1] == p01 && arr_ldh_values[2] ~ $2) {
            arr_radio[3] = arr_radio[3] "!" $2 "=" $3
        }
     }
  }

  # !_06_! Deckelverschlussart
  if (p04 == "" && $1 == "Deckel" && $2 ~ p01) {
      arr_radio[4] = arr_radio[4] "!" $3 "=" $4

   }

  # !_07_! Sonderheiten
  if (p05 == "" && $1 == "SH" && $2 ~ fsstr_long1) {
      arr_radio[5] = arr_radio[5] "!" $3 "=" $4
   }

  # !_10_! Wekrstoff Ausführung Geh: "B" = Beschichtet
  if (p07 == "" && $1 == "WS_GEH" && $2 ~ fsstr_long1) {        # для одних 3, а для других 6 символов
      arr_radio[7] = arr_radio[7] "!" $3 "=" $4
   }


  # !_11_! Werkstoff Düse: "4" = Gussbronze 
  if (p08 == "" && $1 == "WDuese" && $2 ~ fsstr_long1) {          # для одних 3, а для других 6 символов
      arr_radio[8] = arr_radio[8] "!" $3 "=" $4
  }

  # !_11_! Werkstoff Düse: "4" = Gussbronze 
  if (p08 == "" && $1 == "WDuese" && $2 ~ fsstr_long1) {          # для одних 3, а для других 6 символов
      arr_radio[8] = arr_radio[8] "!" $3 "=" $4
  }



} # END OF BODY


# to01 - описание текста к скрытой кнопке
# p02 - значение величины к скрытой кнопке

END {

# !_05-1_! CHECK feasibility Lage der Hauptanschlüsse /// CF_LDH
if (p03 == "")
   ferr[3] = ferr[4] = 0

# !_06_! Deckelverschlussart
if (p04 == "")
   ferr[5] = 0

# !_07_! Sonderheiten
if (p05 == "")
   ferr[6] = 0

# !_EINSATZ 1x RUN - не нужен
if (p06 == "")
   ferr[9] = 0

# !_10_! Wekrstoff Ausführung Geh: "B" = Beschichtet
if (p07 == "")
   ferr[7] = 0

# !_11_! Werkstoff Düse: "4" = Gussbronze
if (p08 == "")
   ferr[8] = 0

# EINSATZ_BEZ второй проход
# берем все Einsatz кот соответст FRR143 напр.
if (tp06 != "")
   ferr[10] = 0

# берем все Einsatz кот соответст FRR143 напр.
if (length(p09) < 2 || p09 == "00")
   ferr[11] = 0

# MOtor
if (smotor == "")
   ferr[12] = 0

if (smotor != "")
   ferr[13] = 0



if (error_code == 1)
  exit


  arr_hidden[1] = "p01!" p01 "!" tp01
  arr_hidden[2] = "p02!" p02 "!" tp02
  arr_hidden[3] = "p03!" p03 "!" tp03
  arr_hidden[4] = "p04!" p04 "!" tp04
  arr_hidden[5] = "p05!" p05 "!" tp05
  arr_hidden[6] = "p06!" p06 "!" tp06
  arr_hidden[7] = "p07!" p07 "!" tp07
  arr_hidden[8] = "p08!" p08 "!" tp08
  arr_hidden[9] = "p09!" p09 "!Endnummer / Konstruktionsmerkmale"
#  arr_hidden[9] = "p09!" p09 "!" tp09
#  arr_hidden[10]= "p10" "!" p10 "!" tp10


  print "-\n-\n-----------------------------------------------------------------------------" >> errlog_txt
  print "<B>"mt "ERROR LOG FOR FILTER : [" filter_name "]</B>"                                 >> errlog_txt
  print "-----------------------------------------------------------------------------" >> errlog_txt

# Условия проверки if (arr_input_str[i] =! "" && fer[i] = 1) { print tferr[i]} >> “xxxxxxxxxxxx”
  # arr_radio[1] = "1__p01__Filter Series:"
  # проверка  наличия значения для радиокнопок
  for (i=1; i<=2; i++) {
     if (ferr[i] == 1) {
        print "FAILED: " tferr[i]  >>  errlog_txt
        error_code = 1
      }
 }
  for (i=3; i<=13; i++) {
    if (arr_radio[i] !~ "HIDDEN" && i != 6) {  # 6  -  Einsatz
      if (split(arr_radio[i],x,"!") == 1) {
        split(arr_radio[i],e,"__")
        print "FAILED: " tferr[e[1]]  >>  errlog_txt
        error_code = 1
      }
    }
  }


print "\n" >> errlog_txt
for (i=1; i<=13; i++) {
   if (ferr[i] == 1) {
      print "FAILED : ["i"] - " tferr[i] >> errlog_txt
      error_code = 1
   }
}

if (error_code == 1)
  exit


  # продолжить нижнюю строку .........................
  print_html("p01","p02","p03",p01,p02,p03,tp01,tp02,tp03)

  print "------------------------- END OF ERROR LOG ----------------------------------" >> errlog_txt
}


function print_html(kp01,kp02,kp03,p01,p02,p03,tp01,tp02,tp03) {
# допустим посетитель ввел только "FRR1031"
# print "<!DOCTYPE html><html><head></head><body>************************"      >> result_txt
print "<code><h3>You have selected the following configuration: </h3>"  >> result_txt
print "Input string : <B>" filter_name "</B><BR>" >> result_txt

  for (i=0; i<length(arr_hidden); i++) {
    split(arr_hidden[i],ar,"!")
        if (ar[2] != "")
           print "<B>" ar[2] "</B> - " ar[3] "<BR>" >> result_txt
  }

# строим HTML форму с радио кнопками
print "<h3>Please select the rest: </h3>"  >> result_txt

print "<form action=\"/process-form\" method=\"post\">"  >> result_txt

  for (i=0; i<length(arr_hidden); i++) {
    split(arr_hidden[i],ar,"!")
        if (ar[2] != "") {
           print "<input type=\"hidden\" name=\""ar[1]"\" value=\""ar[2]"\">" >> result_txt
#           printf "<input type=\"hidden\" name=\""ar[1]"\" value=\""ar[2]"\">" >> result_txt
        }
  }

print_einsatz_radio(p06,tp06,ts02,ts04,ts05,tq02)
print_lastgr_radio(tr01,tr04,tr05)

  for (i=3; i<10; i++) {
    # 6 = EInsatz

    delete my_array
    if (arr_radio[i] !~ "HIDDEN" && i != 6) {
#      print "\n\n----------------" arr_radio[i] "------------------\n\n" >> errlog_txt
      split(arr_radio[i],bez,":")  # "10__p09__Spülleitung:"
      split(bez[1],names,"__")
      split(bez[2],values,"!")
      print "  <p><u>" names[3] "</u></p>"                     >> result_txt
      checked = " checked"
      for (k=2; k<=length(values); k++) {
        split(values[k],singlevalues,"=")
        sub("="," - ",values[k])
        value = singlevalues[1]
#        print "    <input type=\"radio\" id=\"" value  "\" name=\""names[2]"\" value=\"" value "\"" checked ">" >> result_txt
#        print "    <label for=\"" value "\">" values[k] "</label>" >> result_txt

        # удаляем дубликаты значений
        if (!(value in my_array)) {
            print "    <input type=\"radio\" id=\"" value  "\" name=\""names[2]"\" value=\"" value "\"" checked ">    <label for=\"" value "\">" values[k] "</label>" >> result_txt
            checked = ""
            my_array[value]
        }
      }
    }
  }


print "<BR><input type=\"submit\" value=\"SEND\">" >> result_txt
print "</form> </code>"                                 >> result_txt
# print "</body></html>"                          >> result_txt
return ""

}

# выводим на ХТМЛ всё что касается вставки в радио разделд HTML страницы
function print_einsatz_radio(p06,tp06,ts02,ts04,ts05,tq02) {
  # p06 = G21 или F07, etc из введенной строки
  # tp06 = SF07S.0XX000_OPT,SF07A.01E000_OPT,SF07A.07E000_PT2,SF07A.07EW00_PT2,SG20A.01E002_OPT,SG20A.07E002_OPT,SF071.EXX000_OPT,SG20S.0XX002_OPT
  # ts02 = SF-Eigendruckelement;SG-Fremddruckelement
  # ts04 = S-Spaltfilterelement;A-Filterelement plissiert;1-Filterelement glattbespannt
  # ts05 = A-Edelstahl 1.4571;C-C-Stahl 1.0038;D-Edelstahl 1.4439;E-Edelstahl 1.4301
  # tq02 = 08 = 25 µm;10 = 35 µm;12 = 50 µm;14 = 60 µm;16 = 80 µm;17 = 80 µm;18 = 100 µm;20 = 100 µm;21 = 150 µm;24 = 200 µm
  split(tp06,arr_e_bez1,",")
  split(ts02,arr_e_typ1,";")
  split(ts04,arr_e_typ2,";")
  split(ts05,arr_e_typ3,";")
  split(tq02,arr_e_typ4,";")



  # выбрасываем неподходящие 
  if (p06 != "") {
    k = 1
     for (i=1; i<= length(arr_e_bez1); i++) {
       if (p06 != "" && arr_e_bez1[i] ~ p06) {
         arr_e_bez[k] = arr_e_bez1[i]
         k++
       }
     }
  } else { 
     for (i=1; i<= length(arr_e_bez1); i++) {
       arr_e_bez[i] = arr_e_bez1[i]
     }
  }

  if (length(arr_e_bez) == 0) {
     print "Err. 000X - NO SUITABLE FILTER INSERTS FOUND FOR [" p06 "]" >> result_txt
     error_code = 1
     exit
  }

  xx1 = "Filtereinsätze, angelegt wie folgt:"
  print "  <hr size=\"1\">  <p><u>" xx1 "</u></p>"                     >> result_txt
  checked = " checked"
  for (i=1; i<= length(arr_e_bez); i++) {
    value = arr_e_bez[i]
    e_typ1 = "EINSATZ TYP UNBEKANNT"
    for (k=1; k<= length(arr_e_typ1); k++) {
       if (substr(arr_e_typ1[k],1,2) == substr(arr_e_bez[i],1,2))
          e_typ1 = arr_e_typ1[k]
    }
    for (k=1; k<= length(arr_e_typ2); k++) {
       if (substr(arr_e_typ2[k],1,1) == substr(arr_e_bez[i],5,1))
          e_typ2 = arr_e_typ2[k]
    }

    pt_text = " ohne Gewebe /// "
    if (substr(arr_e_bez[i],14,3) == "PT2")
        pt_text = "mit zusätzliche PT+2 /// "
    if (substr(arr_e_bez[i],14,3) == "OPT" && substr(arr_e_bez[i],5,1) != "S")
        pt_text = "Standard Plissiertiefe /// "


    wasser_text = ""
    if (substr(arr_e_bez[i],10,1) == "W")
        wasser_text = "Sonder/Wasserausführung"


    xx2 = "<B>" substr(arr_e_bez[i],1,4) "</B>" substr(arr_e_bez[i],5) " : " e_typ1 " /// " e_typ2 " /// " pt_text wasser_text
#    print "  <div>"                                     >> result_txt
#    print "    <input type=\"radio\" id=\"" value "\" name=\"p06\" value=\"" value "\"" checked ">" >> result_txt
#    print "    <label for=\"" value "\">"  xx2 "</label>" >> result_txt
#    print "  </div>"                              >> result_txt

    print "    <input type=\"radio\" id=\"" value "\" name=\"p06\" value=\"" value "\"" checked "><label for=\"" value "\">"  xx2 "</label>" >> result_txt
    checked = ""
  }

  xx1 = "Material Grundkörper:"
  print "   <p><u>" xx1 "</u></p>"                     >> result_txt
  checked = " checked"
  for (i=1; i<= length(arr_e_typ3); i++) {
    value = substr(arr_e_typ3[i],1,1)
    sub("-"," - ",arr_e_typ3[i])
#    print "  <div>"                                     >> result_txt
#    print "    <input type=\"radio\" id=\"" value "\" name=\"p06material\" value=\"" value "\"" checked ">" >> result_txt
#    print "    <label for=\"" value "\">"  arr_e_typ3[i] "</label>" >> result_txt
#    print "  </div>"                              >> result_txt
    print "    <input type=\"radio\" id=\"" value "\" name=\"p06material\" value=\"" value "\"" checked ">    <label for=\"" value "\">"  arr_e_typ3[i] "</label>" >> result_txt
    checked = ""
  }

  xx1 = "Filterfeinheit:"
  print "   <p><u>" xx1 "</u></p>"                     >> result_txt
  checked = " checked"
  for (i=1; i<= length(arr_e_typ4); i++) {
    value = substr(arr_e_typ4[i],1,2)
#    print "  <div>"                                     >> result_txt
#    print "    <input type=\"radio\" id=\"" value "\" name=\"p06feinheit\" value=\"" value "\"" checked ">" >> result_txt
#    print "    <label for=\"" value "\">" "GEW."  arr_e_typ4[i] "</label>" >> result_txt
#    print "  </div>"                              >> result_txt
    print "    <input type=\"radio\" id=\"" value "\" name=\"p06feinheit\" value=\"" value "\"" checked ">    <label for=\"" value "\">" "GEW."  arr_e_typ4[i] "</label>" >> result_txt
    checked = ""
  }

  print " <hr size=\"1\">"                                >> result_txt
}


# выводим на ХТМЛ всё что касается Einsatz в радио разделд HTML страницы
function print_lastgr_radio(tr01,tr04,tr05) {
  split(tr01,arr_lastgr1,";") #"DPM_OPTIONS"
  split(tr04,arr_lastgr2,";") #"RS_VENTIL_OPTIONS"
  split(tr05,arr_lastgr3,";") #"EL_STEUERUNG_OPTIONS"

  xx1 = "DP Messung:"
  print "   <p><u>" xx1 "</u></p>"                     >> result_txt
  checked = " checked"
  for (i=1; i<= length(arr_lastgr1); i++) {
    value = substr(arr_lastgr1[i],1,2)
    sub("-"," - ",arr_lastgr1[i])
#    print "  <div>"                                     >> result_txt
#    print "    <input type=\"radio\" id=\"" value "\" name=\"r01\" value=\"" value "\"" checked ">" >> result_txt
#    print "    <label for=\"" value "\">"  arr_lastgr1[i] "</label>" >> result_txt
#    print "  </div>"                              >> result_txt
    print "    <input type=\"radio\" id=\"" value "\" name=\"r01\" value=\"" value "\"" checked ">    <label for=\"" value "\">"  arr_lastgr1[i] "</label>" >> result_txt
    checked = ""
  }

  xx1 = "Spüllventile:"
  print "   <p><u>" xx1 "</u></p>"                     >> result_txt
  checked = " checked"
  for (i=1; i<= length(arr_lastgr2); i++) {
    value = substr(arr_lastgr2[i],1,1)
    sub("-"," - ",arr_lastgr2[i])
#    print "  <div>"                                     >> result_txt
#    print "    <input type=\"radio\" id=\"" value "\" name=\"r04\" value=\"" value "\"" checked ">" >> result_txt
#    print "    <label for=\"" value "\">"  arr_lastgr2[i] "</label>" >> result_txt
#    print "  </div>"                              >> result_txt
    print "    <input type=\"radio\" id=\"" value "\" name=\"r04\" value=\"" value "\"" checked ">    <label for=\"" value "\">"  arr_lastgr2[i] "</label>" >> result_txt
    checked = ""
  }

  xx1 = "Steuerung:"
  print "   <p><u>" xx1 "</u></p>"                     >> result_txt
  checked = " checked"
  for (i=1; i<= length(arr_lastgr3); i++) {
    value = substr(arr_lastgr3[i],1,1)
    sub("-"," - ",arr_lastgr3[i])
#    print "  <div>"                                     >> result_txt
#    print "    <input type=\"radio\" id=\"" value "\" name=\"r05\" value=\"" value "\"" checked ">" >> result_txt
#    print "    <label for=\"" value "\">"  arr_lastgr3[i] "</label>" >> result_txt
#    print "  </div>"                              >> result_txt
    print "    <input type=\"radio\" id=\"" value "\" name=\"r05\" value=\"" value "\"" checked ">    <label for=\"" value "\">"  arr_lastgr3[i] "</label>" >> result_txt
    checked = ""
  }




  print " <hr size=\"1\">"                                >> result_txt

}




# print_found(str_log[1], tferr[1], "p01 = [" p01 "] /// Einsatz = [" einsatztype "]",tp01)
function print_found(str1, str2, str3, str4) {
  print "<B>"str1 "</B>"                           >> errlog_txt
  print "SUCCESS !!     : " str2 " /// passed"     >> errlog_txt
  print "Searched values: " str3                   >> errlog_txt
  print "Values found   : " str4                   >> errlog_txt
  print "...................................................." >> errlog_txt
}
