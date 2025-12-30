BEGIN {
  RS = "\n"
  FS = "_!_"

#получаем входные переменные  txtdir
datafile2 = txtdir "data_02.txt"
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
p09 = "0"  # проверить что получаем на входе
p10 = "0"  # проверить что получаем на входе

p06 = "SF07A.07EW00_PT2"
p06material = "A"
p06feinheit = "08"
r01         = "D2"
r04         = "2"
r05         = "L"

# формируем вспомогательные
einsatztypereal  = substr(p06,2,1)
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
tferr[1]=  "Err. 2001. Motor [" t44 "] NOT FOUND in DB data_02.txt"
tferr[2]=  "Err. 2002. RS Ventil [" t41 "] NOT FOUND in DB data_02.txt"
tferr[3]=  "Err. 2003. DP Messung [" t42 "] NOT FOUND in DB data_02.txt"


# инициализировать текстовые величины - это текст для радио кнопок
t11=="####  PLEASE CHECK, WHAT IS WRONG HERE ####"
t12=t13=t14=t15=t16=t17=t18=t19=t20=t21=t22=t23=t24=t25=t26=t27=t28=t29=t30=t31=t32=t33=t34=t35=t11
t41=t42=t43=t44=t45=t51=t52=t53=t54=t55=t11
arr_t41[1]=""  # RS Ventil

# переход на следующий файл данных
ffn = 0

}


# ТЕЛО
{

  # собираем данные для скрытых полей на базе введенного обозначения
  # !_1_! FRR = R5-8, FRZ = AF8, FRB = R8-10
  if ($2 ~ p01 && $3 ~ einsatztype) {
      t11 = $4
      t12 = $1
      found = 1
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
                t13 = t13 " " arr_agtemp[2]
        }
   }

  # !_05_! Lage der Hauptanschlüsse
     if ($1 == "LDH" && $2 == p03)
         t14 = "Lage der Hauptanschlüsse: " $3

   # !_06_! Deckelverschlussart
     if ($1 == "Deckel" && $2 ~ p01 && $3 == p04)
         t15 = "Deckelverschlussart: " $4

   # !_07_! Sonderheiten
     if ($1 == "SH" && $2 ~ fsstr_long1 && $3 == p05)
         t16 = "Sonderheiten: " $4

   # !_10_! Wekrstoff Ausführung Geh: "B" = Beschichtet
     if ($1 == "WS_GEH" && $2 ~ fsstr_long1 && $3 == p07)
         t17 = "Wekrstoff Ausführung Gehäuse: " $4

   # !_11_! Werkstoff Düse: "4" = Gussbronze
     if ($1 == "WDuese" && $2 ~ fsstr_long1 && $3 == p08)
         t18 = "Wekrstoff Düse : " $4

   # !_12_! OTHER PORTS от этого зависит вентиль обр промывки
   if ($2 == "other_ports") {
       search_value = ":" fsstr_long2 ":" # для одних 5, а для других 6 символов
       if (p02 == "FRZ123")
          search_value = ":FRZ123_" p10 ":"
       if ($1 ~ search_value) {
          t19 = "Ablass: " $3
          t20 = "Spülleitung: " $4
          rsventil_size = $4
          t21 = "Entlüftung: " $5
          t22 = "Anzeiger: " $6
       }
   }

   # Löchertext
   if ($1 ~ p02 && $2 == "Loechertext")
       t23 = $3

   # Material Geh und Deckel:
   if ($1 ~ p02 && $2 == "Material_Geh")
       t24 = "Gehäuse: " $3
   if ($1 ~ p02 && $2 == "Material_Deckel")
       t25 = "Deckel: " $3


   # Material other components
   if ($1 ~ p02 && $2 == "Innenteile")
       t26 = "Innenteile: " $3
   if ($1 ~ p02 && $2 == "Lagerbuchsen")
       t27 = "Lagerbuchsen: " $3
   if ($1 ~ p02 && $2 == "Dichtungen")
       t28 = "Dichtungen : " $3
   if ($1 ~ p02 && $2 == "Antriebswelleabdichtung")
       t29 = "Antriebswelleabdichtung : " $3
   if ($1 ~ fsstr_long1 && $2 == "Aussengrund")
       t30 = $3

   if ($1 == "Betriebsdruck" && $2 ~ fsstr_long1)
       t31 = "Betriebsdruck : " $3
   if ($1 == "Betriebtemperatur" && $2 ~ fsstr_long1)
       t32 = "Betriebstemperatur : " $3

   # Andere Daten
   if ($1 ~ fsstr_long2 && $2 == "Inhalt")
       t33 = "Behälterinhalt: " $3
   if ($1 ~ fsstr_long2 && $2 == "Gewicht")
       t34 = "Filtergewicht: " $3

   if ($1 ~ fsstr_long2 && $2 == substr(p06,2,1) && $3 == "Zeichnung")
       t35 = "Angebotszeichnung: " $3

   # RS - Ventile
   if ($1 ~ "RS_VENTIL" && $2 == r04 && $3 == rsventil_size) {
       t41 = $4
       split(t41,arr_t41,"__")
   }

   # DP Messung
   if ($1 ~ "DP_MESSUNG" && $2 == r01) {
       t42 = $3
       split(t42,arr_t42,"__")
   }

   # EL STEUERUNG
   if ($1 ~ "EL_STEUERUNG" && $2 == r05)
       t43 = $3

   # Antrieb
   if ($1 ~ fsstr_long2 && $2 == "Antrieb")
       t44 = $3

   # ELEMENT_TYPE2
   if ($1 ~ "ELEMENT_TYPE2")
       t45 = $2

   # Einsatz
   if ($1 == "OPT_PT2_PT3")
       t51 = $2

   if ($1 == "MATERIAL_GK")
       t52 = $2

   if ($1 == "GEWEBE_NR")
       t53 = $2



   if (ffn == 0 && FILENAME == datafile2) {
      ffn = 1
      RS = "\n::"
      FS = "\n"
   }

   # Antrieb FULL
   if (ferr[1] == 1 && $2 ~ substr(t44,1,8) && FILENAME == datafile2) {
       t44_full = $0
       ferr[1] = 0
   }

   # RS - Ventile FULL
   if (ferr[2] == 1 && $0 ~ substr(arr_t41[2],1,8) && FILENAME == datafile2) {
       t41_full = ""
       ferr[2] = 0
       for (i=1; i<=NF; i++)
          t41_full = t41_full $i ";"
   }

   # DP MESSUNG FULL
   if (ferr[3] == 1 && $0 ~ substr(arr_t42[2],1,8) && FILENAME == datafile2) {
       t42_full = ""
       ferr[3] = 0
       for (i=1; i<=NF; i++)
          t42_full = t42_full $i ";"
   }
}


END {
r_string = define_einsatz(p06,p06material,p06feinheit,t51,t52,t53,t45)
split(r_string,arr_r_string,";")
group2 = arr_r_string[1]
einsatz_short = arr_r_string[2]
einsatz_long = arr_r_string[3]
t_el_type = arr_r_string[4]
mat_gk = arr_r_string[5]
t_gew_f = arr_r_string[6]

group3 = r01 "00" r04 r05

# RS Ventil
rs_text = "mit 1x Rückspüllventil"
if (substr(p06,2,1) == "G")
   rs_text = "mit 2x Rückspüllventile"
split(r41,arr_r41,"__")
split(t41_full,arr_t41_full,";")
split(t42_full,arr_t42_full,";")


print "----------- SALES TEXT ------------"   >> result_txt
print "" p02 p03 p04 p05 substr(p06,2,3) p07 p08 p09 p10 " " group2 " " group3 " " einsatz_long >> result_txt
print "" t11 >> result_txt
print "Typ : " t12 "/ " p02 p03 p04 p05 substr(p06,2,3) >> result_txt   # R5-8 / FRR143110F07
print "Nennweite: "  t13  >> result_txt
print "\nMaterial: "  >> result_txt
print "" t24 "\n" t25 "\n" t26 "\n" t27 "\n" t30  >> result_txt
print "\nBehälteranschlüsse:"  >> result_txt
print "Anschlußgröße Zu- und Ablauf :"  t13 >> result_txt
print "" t19 "\n" t20 "\n" t21 "\n" t22 "\n" t23 >> result_txt
print "" "\n" t14 "\n" t15 "\n" t16 "\n" t17 "\n" t18 >> result_txt
print "\nAuslegungsdaten:"  >> result_txt
print "" t31 "\n" t32  >> result_txt
print "\nAndere Daten"  >> result_txt
print "" t33 "\n" t34 "\n" t35 >> result_txt
print "\nFiltereinsatz:"  >> result_txt
print "Einsatz: " einsatz_short  >> result_txt
print "Einsatztyp: " t_el_type  >> result_txt
print "Material Grundkörper: " mat_gk >> result_txt
print "Filterfeinheit: " t_gew_f >> result_txt
print "\nAntrieb:"  >> result_txt
print "" t44  >> result_txt
print "" t44_full  >> result_txt
print "\nRückspüllventil:"  >> result_txt
print "" rs_text  >> result_txt
print "" t41  >> result_txt
print "" arr_t41[1]  >> result_txt
for (i=3; i<=length(arr_t41_full); i++) {
   print "" arr_t41_full[i] >> result_txt
}

print "\nDP Messung:"  >> result_txt
print "" t42 >> result_txt
print "" arr_t42[1]  >> result_txt
for (i=2; i<=length(arr_t42_full); i++) {
   print "" arr_t42_full[i] >> result_txt
}


print "\nElektrische Steuerung:"  >> result_txt
print "" t43  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt
print ""  >> result_txt

print "------- END OF SALES TEXT ---------------------" >> result_txt

# PRINT ERROR LOG
k = 0
 for (i=1; i<=3; i++) {
   if (ferr[i] == 1) {
       if (k == 0) {
           k = 1
           print "------------ ERROR LOG  ---------------------" >> result_txt
       }
       print tferr[i] >> result_txt
   }
}
if (k == 1)
    print "--------------- END OF ERROR LOG ---------------------" >> result_txt

}

# вычисляем полные данные EINSATZ
function define_einsatz(p06,p06material,p06feinheit,t51,t52,t53,t45) {
# p06 = "SF07S.0XX000_OGE"
# p06material = "A"
# p06feinheit = "08"
# t51 = OGE=ohne Gewebe,OPT=Standard Plissiertiefe,PT2=mit zusätzliche PT+2,PT3=mit zusätzliche PT+3
# t52 = A-Edelstahl 1.4571;C-C-Stahl 1.0038;D-Edelstahl 1.4439;E-Edelstahl 1.4301
# t53 = 08 = 25 µm;10 = 35 µm;12 = 50 µm;14 = 60 µm;16 = 80 µm;17 = 80 µm;18 = 100 µm;20 = 100 µm;21

t_pt1=t_pt2=t_gew_nr=t_gew_f=t_matgk=t_etz1=t_el_type=""

split(p06,arr_p06_,"_")
pt = arr_p06_[2]

# ELEMENT_TYPE2
split(t45,arr_el_type,";")
for (i=1; i<= length(arr_el_type); i++) {
    split(arr_el_type[i],arr_el_type_detail,"-")
    if (arr_el_type_detail[1] == substr(p06,5,1))
       t_el_type = arr_el_type_detail[2]
}


# GEWEBE
split(t53,arr_gewebe,";")
for (i=1; i<= length(arr_gewebe); i++) {
    split(arr_gewebe[i],arr_gewebe_detail," = ")
    if (arr_gewebe_detail[1] == p06feinheit) {
       t_gew_nr = arr_gewebe_detail[1]
       t_gew_f  = arr_gewebe_detail[2]
    }
}

# PT
split(t51,arr_pt,",")
for (i=1; i<= length(arr_pt); i++) {
    split(arr_pt[i],arr_pt_detail,"=")
    if (arr_pt_detail[1] == pt)
       t_pt1 = arr_pt_detail[2]
}

if (pt == "OPT")
   t_pt2 = " KOMPLETT MONTIERT"
if (pt == "PT2")
   t_pt2 = " KOMPLETT MONTIERT PT+2"
if (pt == "PT3")
   t_pt2 = " KOMPLETT MONTIERT PT+3"

# MATERIAL GK
split(t52,arr_matgk,";")
for (i=1; i<= length(arr_matgk); i++) {
    split(arr_matgk[i],arr_matgk_detail,"-")
    if (arr_matgk_detail[1] == p06material)
       t_matgk = arr_matgk_detail[2]
}

# GROUP 2
if (substr(p06,5,1) == "S")
  gr2_1 = "SA"
else
  gr2_1 = substr(p06,8,2)

gr2_2 = t_gew_nr
gr2_3 = "0"
group2 = gr2_1 gr2_2 gr2_3


# EINSATZ
split(arr_p06_[1],arr_p06_dot,".")
p06part1 = arr_p06_dot[1]
p06part2 = arr_p06_dot[2]
if (p06part2 ~ "XX") 
   sub("XX",t_gew_nr,p06part2)
else
   t_etz1 = "GEW.NR " t_gew_nr t_pt2

einsatz_short = p06part1 p06material p06part2 # SG21AE01K002
einsatz_long  = einsatz_short " " t_etz1      # SG21AE01K002 GEW.NR 14 KOMPL MONT PT+2
return_string = group2 ";" einsatz_short ";" einsatz_long ";" t_el_type ";" t_matgk ";" t_gew_f

# FRR143110G21B410 1K250 DT002L SG21AE01K002
# 123456789012345678901234567890123456789012

# ЗДЕСЬ ЕЩЕ ДОЛЖНЫ БЫТЬ ДАННЫЕ ПО ПЛОЩАДИ И ПО РАСХОДУ ЖТИ НА ОБР ПРОМЫВКУ


return return_string
}
