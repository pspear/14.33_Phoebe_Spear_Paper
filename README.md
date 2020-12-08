# 14.33_Phoebe_Spear_Paper
Online instruction does not have a significant effect on college student perception of teachers 

mass_college_data_w_sid.csv: This is data from The Chronicle of Higher Education on the models of education (fully online, primarily online, hybrid, in person) chosen by colleges. 
This csv is limited to information on schools in MA with an added column showing the sid (school ID) given to the school by rate my professor.  

webscrape_loadmore_v1.py: This script utilizes the RMP class, and the college data (mass_college_data_w_sid.csv) to web-scrape rate my professor and return review data in the form of loadmore_final)all_copy.csv

loadmore_final_all_copy.csv: This is a csv where each row is a review, and each column is an attribute of the review. The review attributes are all relevant review-level, and professor-levle information from rate my profoessor.com combined with the information about the colleges
from the Chronicle of Higher Education data. 

rmp_analysis.do: This stata script produces all the tables (runs all the regressions) in the paper. 

14.33_diff_in_diff_graph.R: This script produces figures 1 and 2 in the paper which are plots of the quality and difficulty ratings over-time. It utilizes the loadmore_final_all.csv data. 



