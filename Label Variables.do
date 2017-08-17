do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"


* label variables.

label variable ncdobyear "Year of Birth "
label variable ncdobmonth "Month of Birth"

*gen brmonth = month(ncdobmonth)
*label variable brmonth "Month stored as Time Value"
   
label variable bs_sex      "Sex 1 Male 0 Female"
replace bs_sex = 0 if bs_sex == 2
label define mf_l 1 "Male"
label define mf_l 0 "Female", add
label values bs_sex mf_l
  
label variable b_bcntyc "Place of Birth - County" 
label define cnty_l 001 "Anderson", add
label define cnty_l 002 "Andrews", add
label define cnty_l 003 "Angelina", add
label define cnty_l 004 "Aransas", add
label define cnty_l 005 "Archer", add
label define cnty_l 006 "Armstrong", add
label define cnty_l 007 "Atascosa", add
label define cnty_l 008 "Austin", add
label define cnty_l 009 "Bailey", add
label define cnty_l 010 "Bandera", add
label define cnty_l 011 "Bastrop", add
label define cnty_l 012 "Baylor", add
label define cnty_l 013 "Bee", add
label define cnty_l 014 "Bell", add
label define cnty_l 015 "Bexar", add
label define cnty_l 016 "Blanco", add
label define cnty_l 017 "Borden", add
label define cnty_l 018 "Bosque", add
label define cnty_l 019 "Bowie", add
label define cnty_l 020 "Brazoria", add
label define cnty_l 021 "Brazos", add
label define cnty_l 022 "Brewster", add
label define cnty_l 023 "Briscoe", add
label define cnty_l 024 "Brooks", add
label define cnty_l 025 "Brown", add
label define cnty_l 026 "Burleson", add
label define cnty_l 027 "Burnet", add
label define cnty_l 028 "Caldwell", add
label define cnty_l 029 "Calhoun", add
label define cnty_l 030 "Callahan", add
label define cnty_l 031 "Cameron", add
label define cnty_l 032 "Camp", add
label define cnty_l 033 "Carson", add
label define cnty_l 034 "Cass", add
label define cnty_l 035 "Castro", add
label define cnty_l 036 "Chambers", add
label define cnty_l 037 "Cherokee", add
label define cnty_l 038 "Childress", add
label define cnty_l 039 "Clay", add
label define cnty_l 040 "Cochran", add
label define cnty_l 041 "Coke", add
label define cnty_l 042 "Coleman", add
label define cnty_l 043 "Collin", add
label define cnty_l 044 "Collingsworth", add
label define cnty_l 045 "Colorado", add
label define cnty_l 046 "Comal", add
label define cnty_l 047 "Comanche", add
label define cnty_l 048 "Concho", add
label define cnty_l 049 "Cooke", add
label define cnty_l 050 "Coryell", add
label define cnty_l 051 "Cottle", add
label define cnty_l 052 "Crane", add
label define cnty_l 053 "Crockett", add
label define cnty_l 054 "Crosby", add
label define cnty_l 055 "Culberson", add
label define cnty_l 056 "Dallam", add
label define cnty_l 057 "Dallas", add
label define cnty_l 058 "Dawson", add
label define cnty_l 059 "Deaf Smith", add
label define cnty_l 060 "Delta", add
label define cnty_l 061 "Denton", add
label define cnty_l 062 "DeWitt", add
label define cnty_l 063 "Dickens", add
label define cnty_l 064 "Dimmit", add
label define cnty_l 065 "Donley", add
label define cnty_l 066 "Duval", add
label define cnty_l 067 "Eastland", add
label define cnty_l 068 "Ector", add
label define cnty_l 069 "Edwards", add
label define cnty_l 070 "Ellis", add
label define cnty_l 071 "El Paso", add
label define cnty_l 072 "Erath", add
label define cnty_l 073 "Falls", add
label define cnty_l 074 "Fannin", add
label define cnty_l 075 "Fayette", add
label define cnty_l 076 "Fisher", add
label define cnty_l 077 "Floyd", add
label define cnty_l 078 "Foard", add
label define cnty_l 079 "Fort Bend", add
label define cnty_l 080 "Franklin", add
label define cnty_l 081 "Freestone", add
label define cnty_l 082 "Frio", add
label define cnty_l 083 "Gaines", add
label define cnty_l 084 "Galveston", add
label define cnty_l 085 "Garza", add
label define cnty_l 086 "Gillespie", add
label define cnty_l 087 "Glasscock", add
label define cnty_l 088 "Goliad", add
label define cnty_l 089 "Gonzales", add
label define cnty_l 090 "Gray", add
label define cnty_l 091 "Grayson", add
label define cnty_l 092 "Gregg", add
label define cnty_l 093 "Grimes", add
label define cnty_l 094 "Guadalupe", add
label define cnty_l 095 "Hale", add
label define cnty_l 096 "Hall", add
label define cnty_l 097 "Hamilton", add
label define cnty_l 098 "Hansford", add
label define cnty_l 099 "Hardeman", add
label define cnty_l 100 "Hardin", add
label define cnty_l 101 "Harris", add
label define cnty_l 102 "Harrison", add
label define cnty_l 103 "Hartley", add
label define cnty_l 104 "Haskell", add
label define cnty_l 105 "Hays", add
label define cnty_l 106 "Hemphill", add
label define cnty_l 107 "Henderson", add
label define cnty_l 108 "Hidalgo", add
label define cnty_l 109 "Hill", add
label define cnty_l 110 "Hockley", add
label define cnty_l 111 "Hood", add
label define cnty_l 112 "Hopkins", add
label define cnty_l 113 "Houston", add
label define cnty_l 114 "Howard", add
label define cnty_l 115 "Hudspeth", add
label define cnty_l 116 "Hunt", add
label define cnty_l 117 "Hutchinson", add
label define cnty_l 118 "Irion", add
label define cnty_l 119 "Jack", add
label define cnty_l 120 "Jackson", add
label define cnty_l 121 "Jasper", add
label define cnty_l 122 "Jeff Davis", add
label define cnty_l 123 "Jefferson", add
label define cnty_l 124 "Jim Hogg", add
label define cnty_l 125 "Jim Wells", add
label define cnty_l 126 "Johnson", add
label define cnty_l 127 "Jones", add
label define cnty_l 128 "Karnes", add
label define cnty_l 129 "Kaufman", add
label define cnty_l 130 "Kendall", add
label define cnty_l 131 "Kenedy", add
label define cnty_l 132 "Kent", add
label define cnty_l 133 "Kerr", add
label define cnty_l 134 "Kimble", add
label define cnty_l 135 "King", add
label define cnty_l 136 "Kinney", add
label define cnty_l 137 "Kleberg", add
label define cnty_l 138 "Knox", add
label define cnty_l 139 "Lamar", add
label define cnty_l 140 "Lamb", add
label define cnty_l 141 "Lampasas", add
label define cnty_l 142 "La Salle", add
label define cnty_l 143 "Lavaca", add
label define cnty_l 144 "Lee", add
label define cnty_l 145 "Leon", add
label define cnty_l 146 "Liberty", add
label define cnty_l 147 "Limestone", add
label define cnty_l 148 "Lipscomb", add
label define cnty_l 149 "Live Oak", add
label define cnty_l 150 "Llano", add
label define cnty_l 151 "Loving", add
label define cnty_l 152 "Lubbock", add
label define cnty_l 153 "Lynn", add
label define cnty_l 154 "McCulloch", add
label define cnty_l 155 "McLennan", add
label define cnty_l 156 "McMullen", add
label define cnty_l 157 "Madison", add
label define cnty_l 158 "Marion", add
label define cnty_l 159 "Martin", add
label define cnty_l 160 "Mason", add
label define cnty_l 161 "Matagorda", add
label define cnty_l 162 "Maverick", add
label define cnty_l 163 "Medina", add
label define cnty_l 164 "Menard", add
label define cnty_l 165 "Midland", add
label define cnty_l 166 "Milam", add
label define cnty_l 167 "Mills", add
label define cnty_l 168 "Mitchell", add
label define cnty_l 169 "Montague", add
label define cnty_l 170 "Montgomery", add
label define cnty_l 171 "Moore", add
label define cnty_l 172 "Morris", add
label define cnty_l 173 "Motley", add
label define cnty_l 174 "Nacogdoches", add
label define cnty_l 175 "Navarro", add
label define cnty_l 176 "Newton", add
label define cnty_l 177 "Nolan", add
label define cnty_l 178 "Nueces", add
label define cnty_l 179 "Ochiltree", add
label define cnty_l 180 "Oldham", add
label define cnty_l 181 "Orange", add
label define cnty_l 182 "Palo Pinto", add
label define cnty_l 183 "Panola", add
label define cnty_l 184 "Parker", add
label define cnty_l 185 "Parmer", add
label define cnty_l 186 "Pecos", add
label define cnty_l 187 "Polk", add
label define cnty_l 188 "Potter", add
label define cnty_l 189 "Presidio", add
label define cnty_l 190 "Rains", add
label define cnty_l 191 "Randall", add
label define cnty_l 192 "Reagan", add
label define cnty_l 193 "Real", add
label define cnty_l 194 "Red River", add
label define cnty_l 195 "Reeves", add
label define cnty_l 196 "Refugio", add
label define cnty_l 197 "Roberts", add
label define cnty_l 198 "Robertson", add
label define cnty_l 199 "Rockwall", add
label define cnty_l 200 "Runnels", add
label define cnty_l 201 "Rusk", add
label define cnty_l 202 "Sabine", add
label define cnty_l 203 "San Augustine", add
label define cnty_l 204 "San Jacinto", add
label define cnty_l 205 "San Patricio", add
label define cnty_l 206 "San Saba", add
label define cnty_l 207 "Schleicher", add
label define cnty_l 208 "Scurry", add
label define cnty_l 209 "Shackelford", add
label define cnty_l 210 "Shelby", add
label define cnty_l 211 "Sherman", add
label define cnty_l 212 "Smith", add
label define cnty_l 213 "Somervell", add
label define cnty_l 214 "Starr", add
label define cnty_l 215 "Stephens", add
label define cnty_l 216 "Sterling", add
label define cnty_l 217 "Stonewall", add
label define cnty_l 218 "Sutton", add
label define cnty_l 219 "Swisher", add
label define cnty_l 220 "Tarrant", add
label define cnty_l 221 "Taylor", add
label define cnty_l 222 "Terrell", add
label define cnty_l 223 "Terry", add
label define cnty_l 224 "Throckmorton", add
label define cnty_l 225 "Titus", add
label define cnty_l 226 "Tom Green", add
label define cnty_l 227 "Travis", add
label define cnty_l 228 "Trinity", add
label define cnty_l 229 "Tyler", add
label define cnty_l 230 "Upshur", add
label define cnty_l 231 "Upton", add
label define cnty_l 232 "Uvalde", add
label define cnty_l 233 "Val Verde", add
label define cnty_l 234 "Van Zandt", add
label define cnty_l 235 "Victoria", add
label define cnty_l 236 "Walker", add
label define cnty_l 237 "Waller", add
label define cnty_l 238 "Ward", add
label define cnty_l 239 "Washington", add
label define cnty_l 240 "Webb", add
label define cnty_l 241 "Wharton", add
label define cnty_l 242 "Wheeler", add
label define cnty_l 243 "Wichita", add
label define cnty_l 244 "Wilbarger", add
label define cnty_l 245 "Willacy", add
label define cnty_l 246 "Williamson", add
label define cnty_l 247 "Wilson", add
label define cnty_l 248 "Winkler", add
label define cnty_l 249 "Wise", add
label define cnty_l 250 "Wood", add
label define cnty_l 251 "Yoakum", add
label define cnty_l 252 "Young", add
label define cnty_l 253 "Zapata", add
label define cnty_l 254 "Zavala", add
label values b_bcntyc cnty_l

label variable b_citynm "City or Town"     
label variable b_btype   "Plurality - Single, Twin, Triplet, etc."    
label variable b_bplace  "Place of Birth - Clinic/Doctor's Office" 
label define place_l 1 "Hospital"
label define place_l 2 "Licensed Birth Center", add
label define place_l 3 "Clinic/Dr.s Off", add
label define place_l 4 "Home Birth", add
label define place_l 5 "Other", add
label define place_l 9 "Not Classifiable", add
label values b_bplace place_l


label variable facname  "Name of Hospital or Birthing Center"    
label variable b_mrzip   "Mother's Residence Zip Code"     
label variable b_m_educ  "Mother's Education"    
label define meduc_l 1 "8th grade or less"
label define meduc_l 2 "9-12 G, no diploma", add
label define meduc_l 3 "High Sch. Grad", add
label define meduc_l 4 "Some College", add
label define meduc_l 5 "AA/AS Degree", add
label define meduc_l 6 "BA/BS Degree", add
label define meduc_l 7 "MA/MS Degree", add
label define meduc_l 8 "PhD/MD/JD...", add
label values b_m_educ meduc_l

label variable m_hisnot  "Hispanic Origin? No, Not Spanish, Hispanic/Latina"  
label define yn_l 1 "Yes"
label define yn_l 0 "No", add
label values m_hisnot yn_l
  
label variable m_hismex  "Hispanic Origin? Mexican, Mexican American, Chicana" 
label values m_hismex yn_l
   
label variable m_hispr   "Hispanic Origin? Puerto Rican"  
label values m_hispr yn_l

label variable m_hiscub  "Hispanic Origin? Cuban"      
label values m_hiscub yn_l

label variable m_hisoth  "Hispanic Origin? Other Spanish, Hispanic/Latina"
label values m_hisoth yn_l

label variable m_hisdes  "Hispanic Origin? Other (Specify)"    
label variable m_h_unk    "Mother of Hispanic Origin:  Unknown"    
label values m_h_unk yn_l

label variable m_rwhite  "Mother White"  
label values m_rwhite yn_l
  
label variable m_rblack  "Mother Black or African American" 
label values m_rblack yn_l
   
label variable m_ramind  "Mother American Indian or Alaska Native " 
label values m_ramind yn_l
    
label variable m_rindes  "Mother American Indian or Alaska Native (Name of tribe)"     
label variable m_rasnin   "Mother Asian Indian" 
label values m_rasnin yn_l
   
label variable m_rchina   "Mother Chinese"    
label values m_rchina yn_l

label variable m_rfilip  "Mother Filipino"     
label values m_rfilip yn_l

label variable m_rjapan   "Mother Japanese"    
label values m_rjapan yn_l

label variable m_rkorea  "Mother Korean"   
label values m_rkorea yn_l

label variable m_rviet   "Mother Vietnamese"     
label values m_rviet yn_l

label variable m_rothas  "Mother Other Asian"    
label values m_rothas yn_l
label variable m_rasdes   "Mother Other Asian (Specify)"   

label variable m_rhawai    "Mother Native Hawaiian"  
label values m_rhawai yn_l

label variable m_rguam  "Mother Guamanian or Chamorro" 
label values m_rguam yn_l
    
label variable m_rsamoa   "Mother Samoan"    
label values m_rsamoa yn_l

label variable m_rothpa  "Mother Other Pacific Islander "     
label values m_rothpa yn_l

label variable m_rpacis   "Mother Other Pacific Islander (Specify)"    
label variable m_rother  "Mother Other "     
label variable m_rotdes  "Mother Other (Specify)"     
label variable m_r_unk  "Mother's Race:  Unknown"       

label variable pc_y_n  "Prenatal Care Y/N" 
replace pc_y_n = "1" if pc_y_n == "Y"
replace pc_y_n = "0" if pc_y_n == "N"
replace pc_y_n = "" if pc_y_n == "U"
destring pc_y_n, replace
       
label variable pc_d_fir "Prenatal Care Date of First Visit (mm/dd/yyyy)"       
label variable pc_d_las "Prenatal Care Date of Last Visit (mm/dd/yyyy)"   
label variable b_no_pvs  "Prenatal Care Number of Prenatal Visits"      

label variable pay  "Principal Source of Payment for this Delivery"
label define pay_l 1 "Medicaid"
label define pay_l 2 "Private Insurance", add
label define pay_l 3 "Self-pay", add
label define pay_l 8 "Other", add
label define pay_l 9 "Unknown", add
label values pay pay_l

label variable bo_tra1 "Mother Transferred for Maternal Medical or Fetus Indications for this Delivery?"  
replace bo_tra1 = 0 if bo_tra1 == 2
replace bo_tra1 = . if bo_tra1 == 9
label values bo_tra1 yn_l
      
label variable bo_fac1 "If Transferred, Enter the Name of Facility Mother Transferred From:"      
label variable diab_pre " Diabetes Prepregnancy (Diagnosis prior to this pregnancy)"
replace diab_pre = 0 if diab_pre == 2
label values diab_pre yn_l
    
label variable diab_ges  "Diabetes Gestational (Diagnosis in this pregnancy) "
replace diab_ges = 0 if diab_ges == 2
label define yn2_l 1 "Yes"
label define yn2_l 2 "No", add
label values diab_ges yn_l

label variable brf_crhy "Hypertension  Prepregnancy (Chronic)" 
replace brf_crhy = 0 if brf_crhy == 2     
label values brf_crhy yn_l

label variable brf_pghy  "Hypertension  Gestational (PIH preeclampsia)" 
replace brf_pghy = 0 if brf_pghy == 2  
label values brf_pghy  yn_l
   
label variable brf_eclm "Hypertension  Eclampsia" 
replace brf_eclm = 0 if brf_eclm == 2
label values brf_eclm yn_l
      
label variable pre_prem "Previous Preterm Birth" 
replace pre_prem = 0 if pre_prem == 2 
label values pre_prem yn_l
     
label variable pre_poor "Other Previous Poor Pregnancy Outcome " 
replace pre_poor = 0 if pre_poor == 2
label values pre_poor yn_l
      
label variable pre_csec "Mother had Previous Cesarean Delivery. "
replace pre_csec = 0 if pre_csec == 2
label values pre_csec yn_l


label variable cerv_crc "Obstetric Procedures Cervical Cerclage"
replace cerv_crc = 0 if cerv_crc == 2
label values cerv_crc yn_l

label variable bob_toco "Obstetric Procedures Tocolysis"
replace bob_toco = 0 if bob_toco == 2
label values bob_toco yn_l


label variable ceph_suc "External Cephalic Version: Successful"
replace ceph_suc = 0 if ceph_suc == 2
label values ceph_suc yn_l

label variable ceph_fai "External Cephalic Version: Failed"
replace ceph_fai = 0 if ceph_fai == 2
label values ceph_fai  yn_l


label variable pre_rupt "Onset of Labor: Premature Rupture of the Membranes (Prolonged ? 12 hrs.)"
replace pre_rupt = 0 if pre_rupt == 2
label values pre_rupt yn_l

label variable lab_prec "Onset of Labor: Precipitous Labor (? 3 hrs.) "
replace lab_prec = 0 if lab_prec == 2
label values lab_prec yn_l

label variable lab_prol "Onset of Labor: Prolonged Labor (? 20 hrs.)"
replace lab_prol = 0 if lab_prol == 2
label values lab_prol yn_l

label variable ons_none "Onset of Labor: None of the Above"
replace ons_none = 0 if ons_none == 2
label values ons_none yn_l


label variable bob_ilbr "Characteristics of Labor and Delivery: Induction of Labor"
replace bob_ilbr = 0 if bob_ilbr == 2
label values bob_ilbr yn_l

label variable bob_albr "Characteristics of Labor and Delivery: Augmentation of Labor"
replace bob_albr = 0 if bob_albr == 2
label values bob_albr yn_l

label variable lab_nonv "Characteristics of Labor and Delivery: Non-Vertex of Labor"
replace lab_nonv = 0 if lab_nonv == 2
label values lab_nonv yn_l

label variable lab_ster "Char Labor and Del: Steroids  Lung Maturation Prior to Del"
replace lab_ster = 0 if lab_ster == 2
label values lab_ster yn_l

label variable lab_anti "Characteristics of Labor and Delivery: Antibiotics Mother During Labor"
replace lab_anti = 0 if lab_anti == 2
label values lab_anti yn_l

label variable lab_clin "Characteristics of Labor and Delivery: Chorioamnionitis or Maternal Temperature ?38C (100.4F)"
replace lab_clin = 0 if lab_clin == 2
label values lab_clin yn_l

label variable modhvy_m "Characteristics of Labor and Delivery: Moderate/Heavy Meconium Staining of the Amniotic Fluid"
replace modhvy_m = 0 if modhvy_m == 2
label values modhvy_m yn_l

label variable lab_feti "Characteristics of Labor and Delivery: Fetal Intolerance of Labor Such That One or More of the Following Actions was Taken: In-Utero Resuscitative Measures, Further Fetal Assessment or Operative Delivery"
replace lab_feti = 0 if lab_feti == 2
label values lab_feti yn_l

label variable lab_epid "Characteristics of Labor and Delivery: Epidural or Spinal Anesthesia During Labor"
replace lab_epid = 0 if lab_epid == 2
label values lab_epid yn_l

label variable del_forc "Method of Delivery: Was Delivery with Forceps Attempted but Unsuccessful?"
replace del_forc = 0 if del_forc == 2
label values del_forc yn_l

label variable del_vac "Method of Delivery: Was Delivery with Vacuum Extraction Attempted but Unsuccessful?"
replace del_vac = 0 if del_vac == 2
label values del_vac yn_l


label variable fet_pres "Fetal Presentation at Birth"
label define fet_l 1 "Cephalic"
label define fet_l 2 "Breech", add
label define fet_l 3 "Other", add
label values fet_pres fet_l

label variable final_rt "Final Route and Method of Delivery (Check One)"
label define rt_l 1 "Vaginal/Spontaneous"
label define rt_l 2 "Vaginal/Forceps", add
label define rt_l 3 "Vaginal/Vacuum", add
label define rt_l 4 "Cesarean", add
label values final_rt rt_l


label variable trial_at "If cesarean, was a trial of labor attempted:"
replace trial_at = 0 if trial_at == 2
replace trial_at = . if trial_at == 9
label values trial_at yn_l

label variable b_es_ges "Obstetric Estimate of Gestation (completed weeks)"

label variable as_vent "Abnormal Conditions: Assisted Ventilation Required Immediately Following Delivery"
replace as_vent = 0 if as_vent == 2
label values as_vent yn_l

label variable as_vent6 "Abnormal Conditions: Assisted Ventilation Required for more than 6 hours"
replace as_vent6 = 0 if as_vent == 2
label values as_vent6 yn_l

label variable adm_nicu "Abnormal Conditions: NICU Admission"
replace adm_nicu = 0 if adm_nicu == 2
label values adm_nicu  yn_l

label variable rep_ther "Abnormal Conditions: Newborn Given Surfactant Replacement Therapy"
replace rep_ther = 0 if rep_ther == 2
label values rep_ther yn_l

label variable antibiot "Abnormal Conditions: Antibiotics Received by the Newborn for Suspected Neonatal Sepsis"
replace antibiot = 0 if antibiot == 2
label values antibiot yn_l

label variable seizure "Abnormal Conditions: Seizure or Serious Neurologic Dysfunction"
replace seizure = 0 if seizure == 2
label values seizure yn_l

label variable b_injury "Abnormal Conditions: Significant Birth Injury"
replace b_injury = 0 if b_injury == 2
label values b_injury yn_l

label variable acn_none "Abnormal Conditions: None of the Above"
replace acn_none = 0 if acn_none == 2
label values acn_none yn_l


label variable bca_aeno "Congenital Anomalies: Anencephaly"
replace bca_aeno = 0 if bca_aeno == 2
label values bca_aeno yn_l

label variable bca_spin "Congenital Anomalies: Meningomyelocele/Spina Bifida"
replace bca_spin = 0 if bca_spin == 2
label values bca_spin yn_l

label variable congenhd "Congenital Anomalies: Cyanotic Congenital Heart Disease"
replace congenhd = 0 if congenhd == 2
label values congenhd yn_l

label variable bca_hern "Congenital Anomalies: Congenital Diaphragmatic Hernia"
replace bca_hern = 0 if bca_hern == 2
label values bca_hern yn_l

label variable congenom "Congenital Anomalies: Omphalocele"
replace congenom = 0 if congenom == 2
label values congenom yn_l

label variable congenga "Congenital Anomalies: Gastroschisis"
replace congenga = 0 if congenga == 2
label values congenga yn_l

label variable bca_limb "Congenital Anomalies: Limb Reduction Defect "
replace bca_limb = 0 if bca_limb == 2
label values bca_limb yn_l

label variable hypsospa "Congenital Anomalies: Hypospadias"
replace hypsospa = 0 if hypsospa == 2
label values hypsospa yn_l

label variable bo_trans "Was Infant Transferred Within 24 Hours of Delivery?"
replace bo_trans = 0 if bo_trans == 2
replace bo_trans = . if bo_trans == 9
label values bo_trans yn_l

label variable bo_facil "If Transferred, Name of Facility Infant Transferred to:"
label variable b_wt_cgr "Birth Weight Calculated in Grams"

label variable d_placty "Place of Death (check only one)"
label define dp_l 1 "Hospital Inpatient"
label define dp_l 2 "Hospital Outpatient, ER",add
label define dp_l 3 "Hospital, DOA",add
label define dp_l 4 "Hospice Facility",add
label define dp_l 5 "Nursing Home/LTC",add
label define dp_l 6 "Decedent's Home",add
label define dp_l 9 "Unknown",add
label values d_placty dp_l



label variable d_placen "Place of Death Facility Name (If not institution give street address)"
label variable neonataldeath "Neonatal Death"
label define nnd_l 1 "Died"
label define nnd_l 0 "Lived", add
label values neonataldeath nnd_l

* Create Weight Bins:

gen w500599 = 0
replace w500599 = 1 if b_wt_cgr >= 500 & b_wt_cgr <600
label variable w500599 "1 if 500 <= weight < 600"

gen w600699 = 0
replace w600699 = 1 if b_wt_cgr >=600 & b_wt_cgr<700
label variable w600699 "1 if 600 <= weight < 700"

gen w700799 = 0
replace w700799 = 1 if b_wt_cgr>=700 & b_wt_cgr<800
label variable w700799 "1 if 700 <= weight < 800"

gen w800899 = 0
replace w800899 = 1 if b_wt_cgr>=800 & b_wt_cgr<900
label variable w800899 "1 if 800 <= weight < 900"

gen w10001249 = 0
replace w10001249 = 1 if b_wt_cgr>1000 & b_wt_cgr<1250
label variable w10001249 "1 if 1000<= weight < 1250"

gen w12501499 = 0
replace w12501499 = 1 if b_wt_cgr>1250 & b_wt_cgr<1500
label variable w12501499 "1 if 1250 <= weight < 1500"

gen multiple = 0
replace multiple = 1 if b_btype > 1
label variable multipl "1 if multiple birth"

* Correct one typo

replace facname = "TEXAS HEALTH HARRIS METHODIST HOSPITAL H-E-B" if facname == "TEXAS HEALTH HARRIS METHODIST HOSPTIAL H-E-B"

* Add Fids:

merge m:1 facname using "${birthdata}fids.dta"
label variable fid "FID of birth facility"
drop if _merge == 2

drop _merge 

* Add Fids to transfers:
* The name of the facility infant transferred to is recorded in bo_facil
* If mother is transferred this is in bo_fac1

merge m:1 bo_facil using "${birthdata}transfids.dta"
label variable transfid "FID of facility transferred to"
drop if _merge == 2

drop _merge
