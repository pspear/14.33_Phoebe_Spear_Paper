
//load in loadmore_final_all_copy.csv

gen date_edit = date(time, "MDY")
drop if (date_edit >= date("20200311","YMD") & date_edit <= date("20200801","YMD"))


//create binary post covid marker 
gen post_covid = 1 if date_edit >= date("20200311","YMD")
replace post_covid = 0 if date_edit < date("20200301","YMD")


summarize(post_covid)


//drop if missing quality information 
drop if missing(quality)

//drop if was an online class before covid 
drop if (onlineclass == 1 & post_covid == 0) 

//clean data to be used in regression 
egen class_group = group(class)
egen grade_group = group(grade)

destring knowncasesincounty, replace ignore(",")
summarize(knowncasesincounty)

gen known_cases_post = post_covid*knowncasesincounty
summarize(known_cases_post)

drop if collegemodel == "Undetermined"

//summarize data set

tabulate type collegemodel, row 

tabout type collegemodel using college_model.tex, replace style(tex) font(bold)

table post_covid collegemodel

tabout post_covid collegemodel using college_model_covid.tex, replace style(tex) font(bold)

summarize quality difficulty 

sutex quality difficulty, minmax replace file(qual_summary.tex) title("Difficulty/Quality Summary Statistics")

by sid, sort: gen nvals = _n == 1 
count if nvals 
by tid, sort: gen nvals1 = _n == 1 
count if nvals1

encode collegemodel, generate(collegemodel_n)

//do regressions for fully online, fully/primarily/hybrid 

reg quality ib(#4).collegemodel_n##post_covid tid tnumratings class_group grade_group known_cases_post, robust cluster(sid)

lincom 1.post_covid + 1.collegemodel_n#1.post_covid
lincom 1.post_covid + 2.collegemodel_n#1.post_covid
lincom 1.post_covid + 5.collegemodel_n#1.post_covid

eststo q_fully_online


reg difficulty ib(#4).collegemodel_n##post_covid tid tnumratings class_group grade_group known_cases_post, robust cluster(sid)
lincom 1.post_covid + 1.collegemodel_n#1.post_covid
lincom 1.post_covid + 2.collegemodel_n#1.post_covid
lincom 1.post_covid + 3.collegemodel_n#1.post_covid


eststo d_fully_online


*.txt file, TeX format
esttab q_fully_online d_fully_online using quality_regression.txt, se lab title("Effect of Online Class on Quality Ratings received by Professors")  tex replace

// esttab d_fully_online d_online d_online_hybrid using difficulty_regression.txt, se lab title("Effect of Online Class on Difficulty Ratings received by Professors") mtitles("Fully Online vs. In-Person" "Fully/Primarily Online vs. In-Person" "Fully/Primarily Online vs. Hybrid/In-Person") tex replace 


