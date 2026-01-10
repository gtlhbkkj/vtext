BEGIN {
  if (length(p09) < 2 || p09 == "null")
     p09 = "00"

  print "-----------------------------------------------------------------------------" >> errlog_txt
  print "CHECK LOG FOR: [" p02 p03 p04 p05 substr(p06,2,3) p07 p08 p09 "]"                          >> errlog_txt
  print "-----------------------------------------------------------------------------" >> errlog_txt
  print "\nscanning <data-01.txt>\n"     >> errlog_txt

  RS = "\n"
  FS = "_!_"

#получаем входные переменные  txtdir
datafile2 = txtdir "data_02.txt"
error_code = 0

# errlog_txt="errlog_ako.txt"
# result_txt="result_ako.txt"


# FRR143110G21B410 1K250 DT002L SG21AE01K002
# 123456789012345678901234567890123456789012

#p01 = "FRZ"
#p02 = "FRZ123"
#p03 = "1"
#p04 = "1"
#p05 = "R"
#p07 = "2"
#p08 = "6"
#p09 = "0"  # проверить что получаем на входе
#p10 = "0"  # проверить что получаем на входе

#p06 = "SF07A.07EW00_PT2"
#p06material = "A"
#p06feinheit = "08"
#r01         = "D2"
#r04         = "2"
#r05         = "L"

# проверить все ли переменные зашли


# формируем вспомогательные
fs_einsatz = substr(p06,2,3)              # F07
einsatztypereal  = substr(p06,2,1)
einsatztype  = "E:" substr(p06,2,1)
flansch_size =  substr(p02,4,2)
norm_der_flansch = substr(p02,6,1)


p02s= substr(p02,1,5)                     # FRR14
fsstr_short = p01                         # FRR    / FRB
fsstr_middle = p02s                       # FRR14  / FRB06
fsstr_long1 = fsstr_long2 = p02           # FRR143

fsstr_short = p01                         # FRR    / FRB
fsstr_middle = p02s                       # FRR14  / FRB06
fsstr_long1 = fsstr_long2 = p02           # FRR143

fsstr_m_einsatz = p02
fsstr_zeichnung = p02 "_" p03 "_" substr(p06,2,1)

if (p01 == "FRB" || p01 == "FRN" ) {
   fsstr_long1 = fsstr_short              # FRR143 / FRB
   fsstr_long2 = fsstr_middle             # FRR143 / FRB06
   fsstr_m_einsatz = fsstr_long2 "_" substr(p06,2,3)
   fsstr_zeichnung = p01 "_" p03
}

motor = ""

#print "\n\n\n------------- fsstr_m_einsatz " fsstr_m_einsatz "\n\n\n">> errlog_txt

# ошибка при поиске find_error изначально присваиваем единицу, а если найдено то меняем на 0
for (i=1; i<=10; i++)
   ferr[i] = 1

tferr[1]= "Check 2001. OTHER_PORTS [" fsstr_m_einsatz "]"
tferr[2]= "Check 2002. Grunddatentext zum Antrieb "
tferr[3]= "Check 2003. Mat-Nr RS Ventil "
tferr[4]= "Check 2004. Grunddatentext RS Ventil "
tferr[5]= "Check 2005. Grunddatentext DP Messung "
tferr[6]= "Check 2006. EINSATZ, FILTERFRLÄCHE, RS MENGE, RS ZEIT"



# инициализировать текстовые величины - это текст для радио кнопок
t11=="______________NOT FOUND IN DB_______________"
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
      print_found("$2 ~ p01 / ["p01"]; $3 ~ einsatztype / ["einsatztype"]","t11 = ["t11"]\nt12 = ["t12"]")
   }


   # !_03_! Anschlußgröße Zu- und Ablauf: - похоже что реально нужно для 2-го прохода, а сейчас только для комфортного вывода
   if ($1 == "FLANSCH_SIZE") {
        ag = $2
        split(ag,arr_ag, ";")
        for (i=1; i<=length(arr_ag); i++) {
           split(arr_ag[i],arr_agtemp, "-")
           if (arr_agtemp[1] == flansch_size) {
                t13 =  arr_agtemp[2] # "Anschlußgröße Zu- und Ablauf: "
                print_found("FLANSCH_SIZE","tmp = [" ag "]\nt13 = ["t13"]")
           }
        }
   }

   # !_04_! Nenndruck + Norm der Filteranschlüsse: - похоже, что нужно только для второго прохода
   if ($1 == "NORM_DER_FLANSCH") {
        ag = $2
        split(ag,arr_ag, ";")
        for (i=1; i<=length(arr_ag); i++) {
           split(arr_ag[i],arr_agtemp, "=")
           if (arr_agtemp[1] == norm_der_flansch) {
                t13 = t13 " " arr_agtemp[2]
                print_found("NORM_DER_FLANSCH","tmp = [" ag "]\nt13 = ["t13"]")
           }
        }
   }

  # !_05_! Lage der Hauptanschlüsse
     if ($1 == "LDH" && $2 == p03) {
         t14 = $3
         print_found("LDH ["p02"];["p03"]","t14 = Lage der Hauptanschlüsse: ["t14"]")
     }

   # !_06_! Deckelverschlussart
     if ($1 == "Deckel" && $2 ~ p01 && $3 == p04) {
         t15 =  $4
         print_found("Deckel ["p02"];["p04"]","t15 = Deckelverschlussart: ["t15"]")
     }

   # !_07_! Sonderheiten
     if ($1 == "SH" && $2 ~ fsstr_long1 && $3 == p05) {
         t16 = $4
         print_found("SH ["p02"]","t16 = Sonderheiten: ["t16"]")
     }

   # !_10_! Wekrstoff Ausführung Geh: "B" = Beschichtet
     if ($1 == "WS_GEH" && $2 ~ fsstr_long1 && $3 == p07) {
         t17 =  $4
         print_found("WS_GEH ["p02"]","t17 = Wekrstoff Ausführung Gehäuse: ["t17"]")
     }

   # !_11_! Werkstoff Düse: "4" = Gussbronze
     if ($1 == "WDuese" && $2 ~ fsstr_long1 && $3 == p08) {
         t18 = $4
         print_found("WDuese ["p02"]; ["p08"]","t18 = Wekrstoff Düse : ["t18"]")
     }

   # !_12_! OTHER PORTS от этого зависит вентиль обр промывки
   if (ferr[1] == 1 && $2 == "other_ports" && $1 ~ fsstr_m_einsatz) {
          t19 = $3    # ABLASS
          t20 = $4    # "Spülleitung: "
          rsventil_size = $4
          t21 =  $5   # "Entlüftung: "
          t22 =  $6   # "Anzeiger: "
          ferr[1] = 0
          print_found(tferr[1],"t19 = Ablass: ["t19"]\nt20 = Spülleitung: ["t20"]\nt21 = Entlüftung: ["t21"]\nt22 = Anzeiger: ["t22"]")
   }

   # Löchertext
   if ($1 ~ fsstr_long1 && $2 == "Loechertext") {
       t23 = $3
       print_found("Loechertext ["p02"]","t23 = ["t23"]")
   }

   # Material Geh und Deckel:
   if ($1 ~ fsstr_long1 && $2 == "Material_Geh") {
       t24 =  $3  # "Gehäuse: "
       print_found("Material_Geh ["p02"]","t24 / Gehäuse: ["t24"]")
   }

   if ($1 ~ fsstr_long1 && $2 == "Material_Deckel") {
       t25 = $3  # "Deckel: "
       print_found("Material_Deckel ["p02"]","t25 / Deckel: ["t25"]")
   }

   # Material other components
   if ($1 ~ p01 && $2 == "Innenteile") {
       t26 = $3 # "Innenteile: "
       print_found("Innenteile ["p01"]","t26 / Innenteile: ["t26"]")
   }

   if ($1 ~ p01 && $2 == "Lagerbuchsen") {
       t27 = $3 # "Lagerbuchsen: "
       print_found("Lagerbuchsen ["p02"]","t27 / Lagerbuchsen: ["t27"]")
   }

   if ($1 ~ p01 && $2 == "Dichtungen") {
       t28 =  $3 # "Dichtungen: "
       print_found("Dichtungen ["p02"]","t28 / Dichtungen: ["t28"]")
   }

   if ($1 ~ p01 && $2 == "Antriebswelleabdichtung") {
       t29 = $3 # "Antriebswelleabdichtung: "
       print_found("Antriebswellenabdichtung ["p02"]","t29 / Antriebswelleabdichtung: ["t29"]")
   }

   if ($1 ~ p01 && $2 == "Aussengrund") {
       t30 = $3
       print_found("Aussengrund ["fsstr_long1"]","t30 = ["t30"]")
   }

   if ($1 == "Betriebsdruck" && $2 ~ fsstr_long1) {
       t31 = $3  # "Betriebsdruck : "
       print_found("["fsstr_long1"]","t31 / Betriebsdruck : ["t31"]")
   }

   if ($1 == "Betriebtemperatur" && $2 ~ p01) {
       t32 = $3 # "Betriebstemperatur : "
       print_found("["fsstr_long1"]","t32 / Betriebstemperatur : ["t32"]")
   }

   # Andere Daten
   if ($1 ~ fsstr_m_einsatz && $2 == "Inhalt") {
       t33 = $3 # "Behälterinhalt: "
       print_found("["fsstr_m_einsatz"]","t33 / Behälterinhalt: ["t33"]")
   }

   if ($1 ~ fsstr_m_einsatz && $2 == "Gewicht") {
       t34 = $3 # "Filtergewicht: "
       print_found("["fsstr_m_einsatz"]","t34 / Filtergewicht: ["t34"]")
   }

   if ($1 ~ fsstr_zeichnung && $2 == "Zeichnung") {
       t35 = $3 # "Angebotszeichnung: "
       print_found("["fsstr_zeichnung"]","t35 / Angebotszeichnung: ["t35"]")
   }


   # END-NUMMER
     if (p09 != "00" && $1 == "END_NR" && $2 == p09 && $3 ~ p01 && ($4 ~ substr(p06,2,3) || $4 == "ALL")) { # fss>
        print_found("END_NR ["p09"]",$0)

        if ($0 ~ "MOTOR") {
            split($5,arr_5,";")
            for (i=1; i<= length(arr_5); i++) {
               if (arr_5[i] ~ "MOTOR") {
                  split(arr_5[i],arr_arr_5,"__")
                  motor = arr_arr_5[2]
                  print_found("END_NR ["p09"]", "Sonderantrieb = [" motor "]")
               }
            }
        }

        if ($0 ~ "RSVENTIL") {
            split($5,arr_5,";")
            for (i=1; i<= length(arr_5); i++) {
               if (arr_5[i] ~ "RSVENTIL") {
                  split(arr_5[i],arr_arr_5,"__")
                  rsventil_size = arr_arr_5[2]
                  print_found("END_NR ["p09"]", "Sonderausführung RS Ventil Size = [" rsventil_size"]")
               }
            }
        }

     } # END-NUMMER


   # RS - Ventile
   if (ferr[3] == 1 && r04 != 0 && $1 ~ "RS_VENTIL" && $2 == r04 && $3 == rsventil_size) {
       ferr[3] == 0
       t41 = $4
       split(t41,arr_t41,"__")
       print_found("RS_VENTIL ["$3"]", "RS Ventil Mat-Nr = [" $4 "]")
   }

   # DP Messung
   if ($1 ~ "DP_MESSUNG" && $2 == r01) {
       t42 = $3
       split(t42,arr_t42,"__")
       print_found("DP_MESSUNG ["$2"]", "DP MESSUNG Mat-Nr = [" $3 "]")
   }

   # EL STEUERUNG
   if ($1 ~ "EL_STEUERUNG" && $2 == r05) {
       t43 = $3
       print_found("EL_STEUERUNG ["$2"]", $3)
   }

   # Antrieb  Standard
   if (motor == "" && $1 ~ fsstr_m_einsatz && $2 == "Antrieb") {
       t44 = $3
       motor = substr($3,1,8)
       print_found("ANTRIEB ZUM ["$1"]", "Standardantrieb = [" $3 "]")
   }

   # ELEMENT_TYPE2
   if ($1 ~ "ELEMENT_TYPE2") {
       t45 = $2
       print_found("ELEMENT_TYPE2", "ELEMENT_TYPE2 = [" t45 "]")
   }

   # Einsatz
   if ($1 == "OPT_PT2_PT3") {
       t51 = $2
       print_found("OPT_PT2_PT3", "OPT_PT2_PT3 = [" $2 "]")
   }

   if ($1 == "MATERIAL_GK") {
       t52 = $2
       print_found("MATERIAL_GK", "MATERIAL_GK = [" $2 "]")
   }

   if ($1 == "GEWEBE_NR") {
       t53 = $2
       print_found("GEWEBE_NR", "GEWEBE_NR = [" $2 "]")
   }

   if (ferr[6] == 1 && $1 == "EINSATZ_FL_RS" && $2 ~ fs_einsatz) {
       ferr[6] = 0
       einsatz_flaeche = $3
       einsatz_rsmenge = $4
       print_found("EINSATZ_FL_RS", "["$3"] / ["$4"]")
   }


################## <data-2.txt>


   if (ffn == 0 && FILENAME == datafile2) {
      ffn = 1
      RS = "\n::"
      FS = "\n"
      print "\nscanning <data-02.txt>\n"     >> errlog_txt
   }

   # Antrieb FULL
   if (ferr[2] == 1 && $2 ~ motor && FILENAME == datafile2) {
       t44_full = $0
       ferr[2] = 0
       print_found(tferr[2] "["motor"]", "t44 = [" $2 "]")
   }

   # RS - Ventile FULL
   if (ferr[4] == 1 && $3 ~ substr(arr_t41[2],1,8) && FILENAME == datafile2) {
       t41_full = ""
       ferr[4] = 0
       for (i=1; i<=NF; i++)
          t41_full = t41_full $i ";"
       print_found(tferr[4] ": ["rsventil_size"]", "t41 = [" arr_t41[2] "]")
   }

   # DP MESSUNG FULL
   if (ferr[5] == 1 && r01 != "00" && $0 ~ substr(arr_t42[2],1,8) && FILENAME == datafile2) {
       t42_full = ""
       ferr[5] = 0
       for (i=1; i<=NF; i++) {
          if (t42_full == "")
             t42_full = $i
          else
             t42_full = t42_full ";" $i 
       }
       print_found(tferr[5] ": ["r01"]", "t42 = [" substr(t42_full,1,50)"]")
   }
}


END {
# если нет сливного вентиля
if (r04 == 0 || t41 != "" )
  ferr[3] = ferr[4] = 0

# dP Messung
if (r01 == "00")
  ferr[5] = 0

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
if (r04 != 0) {
  rs_text = "mit 1x Rückspüllventil"
  if (substr(p06,2,1) == "G")
     rs_text = "mit 2x Rückspüllventile"
  split(r41,arr_r41,"__")
  split(t41_full,arr_t41_full,";")
  split(t42_full,arr_t42_full,";")
}


print "----------- SALES TEXT ------------"   >> result_txt
print p02 p03 p04 p05 substr(p06,2,3) p07 p08 p09 p10 " " group2 " " group3 " " einsatz_long >> result_txt
print t11 >> result_txt
print "Typ : " t12 " / [" p02 p03 p04 p05 substr(p06,2,3) "] Nennweite: "  t13  >> result_txt
print "\nBehälteranschlüsse:"  >> result_txt
print "Anschlußgröße Zu- und Ablauf: "  t13 >> result_txt
print "Ablass: " t19      >> result_txt
print "Spülleitung: " t20  >> result_txt
print "Entlüftung: " t21  >> result_txt
print "Anzeiger: " t22  >> result_txt
print t23 >> result_txt               # "Loechertext"

print "\nMaterial: "  >> result_txt
print "Gehäuse: " t24 >> result_txt
print "Deckel: " t25  >> result_txt
print "Innenteile: " t26  >> result_txt
print "Lagerbuchsen: " t27  >> result_txt
print "Dichtungen: " t28  >> result_txt
print "Antriebswelleabdichtung: " t29 >> result_txt
print "\n" t30  >> result_txt          # "Aussengrund"
print "Wekrstoff Ausführung Gehäuse: " t17 >> result_txt
print "Wekrstoff Düse : " t18 >> result_txt

print "\nLage der Hauptanschlüsse: " t14  >> result_txt
print "Deckelverschlussart: " t15  >> result_txt
print "Sonderheiten: " t16 >> result_txt

print "\nAuslegungsdaten:"  >> result_txt
print "Betriebsdruck : " t31  >> result_txt
print  "Betriebstemperatur : " t32  >> result_txt

print "\nAndere Daten:"  >> result_txt
print "Behälterinhalt: " t33  >> result_txt
print "Filtergewicht: " t34 >> result_txt
print "Angebotszeichnung: " t35 >> result_txt

print "\nFiltereinsatz:"  >> result_txt
print "Einsatz: " einsatz_short  >> result_txt
print "Einsatztyp: " t_el_type  >> result_txt
print "Material Grundkörper: " mat_gk >> result_txt
print "Filterfeinheit: " t_gew_f >> result_txt
print "Filterfläche: " einsatz_flaeche >> result_txt
print "Rückspülmenge / Rückspülzeit: " einsatz_rsmenge >> result_txt
print "Druckverlust: ca. 0,1 bar (sauber) / 0,5 bar (verschmutzt)"  >> result_txt
print "Autom. Rückspülung bei: 0,5 bar (Empfehlung)"  >> result_txt


print "\nAntrieb:" t44_full  >> result_txt

print "\nRückspüllventil:"  >> result_txt
if (t41 != "") {
   #print "RS_VENTIL - "  r04 " - " rsventil_size  " - " search_value >> result_txt
   print rs_text  >> result_txt
   #print "" t41  >> result_txt
   print arr_t41[1]  >> result_txt
   for (i=3; i<=length(arr_t41_full); i++) {
      print "" arr_t41_full[i] >> result_txt
   }
} else
   print "OHNE Rückspüllventil\n"  >> result_txt

print "DP Messung:"  >> result_txt
#print t42 >> result_txt
print arr_t42[1]  >> result_txt
print arr_t42[2]  >> result_txt
for (i=2; i<=length(arr_t42_full); i++) {
   print "" arr_t42_full[i] >> result_txt
}

print "\nElektrische Steuerung:"  >> result_txt
print "" t43  >> result_txt

print "\nFilterbehälter ausgelegt für ungefährliche Flüssigkeiten (Gruppe 2)" >> result_txt
print "im Sinne der Druckgeräterichtlinie DGRL 2014/68/EU Art. 3 Abs.3" >> result_txt


print "\nDokumentation:"  >> result_txt
print "- Auslegungs-/Berechnungs-Unterlagen gemäß Druckgeräterichtlinie PED 2014/68/EU Art. 3 Abs. 3"  >> result_txt
print "- Materialzeugnisse 3.1 (EN10204) für drucktragende Bauteile"  >> result_txt
print "- Werkszeugnis 2.2 über Endprüfung incl. Dichtheitsprüfung"  >> result_txt
print "- Betriebsanleitung in Deutsch, Englisch und Französisch." >> result_txt
print "____________\n\n\n"  >> result_txt

print "------- END OF SALES TEXT ---------------------\n\n" >> result_txt

# PRINT ERROR LOG
k = 0
 for (i=1; i<=10; i++) {
   if (ferr[i] == 1 && tferr[i] != "") {
       if (k == 0) {
           k = 1
           print "------------ ERROR LOG  ---------------------" >> result_txt
       }
       print "FAILED: " tferr[i] >> result_txt
   }
}
if (k == 1)
    print "--------------- END OF ERROR LOG ---------------------\n\n" >> result_txt

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
    if (arr_matgk_detail[1] == p06material) {
       t_matgk = arr_matgk_detail[2]
    }
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


# print_found(str_log[1], tferr[1], "p01 = [" p01 "] /// Einsatz = [" einsatztype "]",tp01)
function print_found(str1, str2) {
  print "Looking for   : " str1               >> errlog_txt
  print "Values found  : " str2               >> errlog_txt
  print "...................................................." >> errlog_txt
}


