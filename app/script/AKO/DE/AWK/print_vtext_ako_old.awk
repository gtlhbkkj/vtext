BEGIN {
  RS = "\n"
  FS = "_!_"

#получаем входные переменные mt, filter_name, errlog_txt
error_code = 0

# errlog_txt="errlog_ako.txt"
# result_txt="result_ako.txt"


# FRR143110G21B410 1K250 DT002L SG21AE01K002
# 123456789012345678901234567890123456789012

p01 = "FRZ"
p02 = "FRZ123"
p03 = "1"
p04 = "1"
p05 = "R"
p07 = "2"
p08 = "6"
p09 = "0"
p10 = "0"

p06 = "SF07S.0XX000_OGE"
p06material = "A"
p06feinheit = "08"
r01         = "D2"
r04         = "2"

# формируем вспомогательные
einsatztype  = "E:" substr(p06,2,1)
flansch_size =  substr(p02,4,2)
norm_der_flansch = substr(p02,5,1)

p02s= substr(p02,1,5)                     # FRR14
fsstr_short = p01                         # FRR    / FRB
fsstr_middle = p02s                       # FRR14  / FRB06
fsstr_long1 = fsstr_long2 = p02           # FRR143
if (p01 == "FRB") {
   fsstr_long1 = fsstr_short              # FRR143 / FRB
   fsstr_long2 = fsstr_middle             # FRR143 / FRB06
}


# проверить все ли переменные зашли

# ошибка при поиске find_error изначально присваиваем единицу, а если найдено то меняем на 0
for (i=1; i<=10; i++) 
   ferr[i] = 1
tferr[1]=  "Err. 0001 =.............= failed. No info in DB about " p01

# found p01, etc. . параметры которые ищем для скрытых полей
fp01=fp02=fp03=fp04=fp05=fp06=fp07=fp08=fp09=fp10=0

# инициализировать текстовые величины - это текст для радио кнопок
t11=t12="####  PLEASE CHECK, WHAT IS WRONG HERE ####"
}


# ТЕЛО
{
  # собираем данные для скрытых полей на базе введенного обозначения
  # !_1_! FRR = R5-8, FRZ = AF8, FRB = R8-10
  if ($2 ~ p01 && $3 ~ einsatztype) {
      t11 = $4
      t12 = $1
   }

   # !_03_! Anschlußgröße Zu- und Ablauf: - похоже что реально нужно для 2-го прохода, а сейчас только для комфортного вывода
   if ($1 == "FLANSCH_SIZE") {
        ag = $2
        split(ag,arr_ag, ";")
        for (i=1; i<=length(arr_ag); i++) {
           split(arr_ag[i],arr_agtemp, "-")
           if (arr_agtemp[1] == flansch_size)
                t13 =  arr_agtemp[2] # "Anschlußgröße Zu- und Ablauf: "
        }
   }

   # !_04_! Nenndruck + Norm der Filteranschlüsse: - похоже, что нужно только для второго прохода
   if ($1 == "NORM_DER_FLANSCH") {
        ag = $2
        split(ag,arr_ag, ";")
        for (i=1; i<=length(arr_ag); i++) {
           split(arr_ag[i],arr_agtemp, "=")
           if (arr_agtemp[1] == norm_der_flansch)
                t13 = p13 " " arr_agtemp[2]
        }
   }

   # !_05_! Lage der Hauptanschlüsse
     if ($1 == "LDH" && $2 == p03)
         tp14 = "Lage der Hauptanschlüsse : " $3

   # !_06_! Deckelverschlussart
     if ($1 == "Deckel" && $2 ~ p01 && $3 == p04)
         tp15 = "Deckelverschlussart : " $4

   # !_07_! Sonderheiten
     if ($1 == "SH" && $2 ~ fsstr_long1 && $3 == p05)
         tp16 = "Sonderheiten : " $4

   # !_10_! Wekrstoff Ausführung Geh: "B" = Beschichtet
     if ($1 == "WS_GEH" && $2 ~ fsstr_long1 && $3 == p07)
         tp17 = "Wekrstoff Ausführung Gehäuse : " $4

   # !_11_! Werkstoff Düse: "4" = Gussbronze
     if ($1 == "WDuese" && $2 ~ fsstr_long1 && $3 == p08)
         tp18 = "Wekrstoff Düse : " $4

   # !_12_! OTHER PORTS от этого зависит вентиль обр промывки
   if ($2 == "other_ports") {
       search_value = ":" fsstr_long2 ":" # для одних 5, а для других 6 символов
       if (p02 == "FRZ123")
          search_value = ":FRZ123_" p10 ":"
       if ($1 ~ search_value) {
          tp19 = "Ablass : " $3
          tp20 = "Spülleitung : " $4
          tp21 = "Entlüftung : " $5
          tp22 = "Anzeiger : " $6
       }
   }

   # Löchertext
   if ($1 ~ p02 && $2 == "Loechertext")
       tp21 = $3

   # Material Geh und Deckel:
   if ($1 ~ p02 && $2 == "Material_Geh")
       tp22 = "Material Gehäuse : " $3
   if ($1 ~ p02 && $2 == "Material_Deckel")
       tp23 = "Material Deckel : " $3

   # Material other components
   if ($1 ~ p02 && $2 == "Innenteile")
       tp24 = "Innenteile : " $3
   if ($1 ~ p02 && $2 == "Lagerbuchsen")
       tp25 = "Lagerbuchsen : " $3
   if ($1 ~ p02 && $2 == "Dichtungen")
       tp26 = "Dichtungen : " $3
   if ($1 ~ p02 && $2 == "Antriebswelleabdichtung")
       tp27 = "Antriebswelleabdichtung : " $3
   if ($1 == "Betriebsdruck" && $2 ~ fsstr_long1)
       tp28 = "Betriebsdruck : " $3
   if ($1 == "Betriebstemperatur" && $2 ~ fsstr_long1)
       tp28 = "Betriebstemperatur : " $3

}


END {

print "----------- SALES TEXT ------------"  >> result_txt
print "" p02 p03 p04 p05 p06 p07 p08 p09 p10 >> result_txt
print "" t11 >> result_txt
print "Typ : " t12 "/ " p02 p03 p04 p05 p06 p07 >> result_txt   # R5-8 / FRR143110F07
print "Nennweite : " t13  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt

print "------------------------- END OF ERROR LOG ----------------------------------" >> result_txt

}
