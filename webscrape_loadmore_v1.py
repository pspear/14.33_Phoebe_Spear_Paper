import requests
import csv
from bs4 import BeautifulSoup
import RMP.RMPClass as rmp
import csv
import math
import json


with open('loadmore_final_all.csv', 'w', newline='') as csvfile:
    fieldnames = ['Time', 'Quality', 'Difficulty', 'Class', 'For Credit', 'Attendance', 'Grade','Online Class', 'Tags']
    fieldnames.extend(['tDept', 'tSid', 'institution_name','tFname', 'tMiddlename', 'tLname', 'tid', 'tNumRatings', 'rating_class', 'contentType', 'categoryType', 'overall_rating'])
    fieldnames.extend(['Place', 'Type', 'Enrollment', 'Known Cases in County', 'College Model', 'University', 'sid', 'Number_of_Professors'])
    w = csv.DictWriter(csvfile, fieldnames=fieldnames)
    w.writeheader()

    mass_sids = []
    college_counter = 0
    with open('mass_college_data_w_sid.csv', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            sid = row['sid']

            if sid != '':

                school = rmp.RateMyProfScraper(sid)
                prof_list = school.createprofessorlist()
                #list of dicts in form {'professors': list of prof dicts, 'searchResultsTotal': 337, 'remaining': 317, 'type': 'alphabetical' }

                row['Number_of_Professors'] =  len(prof_list)
                print(len(prof_list))


                for prof_dict in prof_list:
                    prof_tid = prof_dict['tid']


                    #prof_url = 'https://www.ratemyprofessors.com/ShowRatings.jsp?tid=' + str(prof_tid) + '&showMyProfs=true'

                    prof_url_new = 'http://www.ratemyprofessors.com/paginate/professors/ratings?tid=' + str(prof_tid) + '&filter=&courseCode=&page='
                    #example prof url 'https://www.ratemyprofessors.com/ShowRatings.jsp?tid=103718&showMyProfs=true'

                    num_reviews = prof_dict['tNumRatings']
                    num_of_pages = math.ceil(num_reviews / 20)
                    for page in range(1, num_of_pages+1): #Change 10 to however many times you need to press "Load Next 50 Courses"
                        #params={'page': str(page)}
                        prof_url = prof_url_new + str(page)
                        next_page = requests.get(prof_url)
                        temp_jsonpage = json.loads(next_page.content)
                        reviews = temp_jsonpage['ratings']

                        #soup = BeautifulSoup(next_page.text, 'html.parser')
                        #Parse through html

                    #page = requests.get(prof_url)
                    #soup = BeautifulSoup(page.text, 'html.parser')


                        # review_info = soup.findAll(class_= 'RatingsList__RatingsUL-hn9one-1 kHITzZ')
                        # str_review_info = str(review_info)
                        # reviews = str_review_info.split('<li>')


                        for review in reviews:
                            try:
                                review_dict = {}
                                review_dict['Time'] = review["rDate"]
                                review_dict['Quality'] = review["rOverall"]
                                review_dict['Difficulty'] = review["rEasy"]
                                review_dict['Class'] = review["rClass"]
                                review_dict['For Credit'] = review['takenForCredit']
                                review_dict['Attendance'] = review['attendance']
                                review_dict['Grade'] = review['teacherGrade']
                                review_dict['Online Class'] = 1 if review['onlineClass'] == "online" else 0
                                review_dict["Tags"] = review["teacherRatingTags"]
                                review_dict.update(prof_dict)
                                review_dict.update(row)
                                w.writerow(review_dict)
                            except AttributeError:
                                continue


            college_counter+=1
            print(college_counter)
