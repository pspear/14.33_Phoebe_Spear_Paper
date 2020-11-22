library(tidyverse)
library(gganimate)
library(foreign)
library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)

c_data <- read.csv("~/Desktop/MIT_20-21/14.33/WebScrape/loadmore_final_all.csv")

# create the treated variable
#data <-subset(c_data, c_data$College.Model == "Fully online" | c_data$College.Model == "Primarily in person",
#              select=Time:Number_of_Professors)
data <- c_data[!(c_data$College.Model == "Other" | c_data$College.Model == "Undetermined"),]

data$time <- as.Date(data$Time, "%m/%d/%Y")
data$month <- month(data$time)
data$year <- year(data$time)

data_bymonth <- aggregate(x = cbind(data$Quality,data$Difficulty) , by = list(month = data$month, year = data$year, model = data$College.Model), data=data, FUN=mean, na.rm=TRUE)
names(data_bymonth) <- c("month","year", "model", "quality", "difficulty")

data_bymonth$treated <- factor(if_else(data_bymonth$model %in% c("Fully online", "Primarily online"),1,0)) 


data_bymonth %>% 
  group_by(month,year,model) %>% 
  summarize(quality=mean(quality)) -> data_bymonth_model

data_bymonth %>% 
  group_by(month,year,treated) %>% 
  summarize(quality=mean(quality)) -> data_sum_treated


data_bymonth_model$ym <- as.yearmon(paste(data_bymonth_model$year, data_bymonth_model$month), "%Y %m")
data_bymonth_model$treated <- factor(if_else(data_bymonth_model$model %in% c("Fully online", "Primarily online"),1, 0)) 

data_sum_treated$ym <- as.yearmon(paste(data_sum_treated$year, data_sum_treated$month), "%Y %m")

ggplot() + geom_line(data=data_bymonth_model,aes(x=ym,y=quality,group=model,color=model),
                   size=.5,alpha=0.5) + # plot the individual lines
  #geom_line(data=data_sum_treated,aes(x=ym,y=quality,group=treated,color=treated),
            #size=1, alpha=1) + # plot the averages for each group
  geom_vline(xintercept = as.yearmon(ymd("2020-03-10")), color = "black",size=.5) + # intervention point
  geom_vline(xintercept = as.yearmon(ymd("2020-08-1")), color = "black",size=.5) + # intervention point
  scale_x_yearmon() +
  #scale_x_continuous("Month", expand = c(0,0)) + 
 # scale_color_manual(values=c("red","blue"), # label our groups
 #                    labels=c("Control Average","Treatment Average", "other", "other")) +
  labs(title="College Quality Rankings - Monthly Aggregate",
       subtitle="",
       x="Time",
       y="Quality") +
  theme_minimal() +
  theme(axis.text.y = element_blank(),
        legend.title = element_blank(),
        legend.position = "bottom") 
ggsave("plot_online.png", plot = p3)

#repeat for difficulty 


data_bymonth %>% 
  group_by(month,year,model) %>% 
  summarize(difficulty=mean(difficulty)) -> data_bymonth_model

data_bymonth %>% 
  group_by(month,year,treated) %>% 
  summarize(difficulty=mean(difficulty)) -> data_sum_treated


data_bymonth_model$ym <- as.yearmon(paste(data_bymonth_model$year, data_bymonth_model$month), "%Y %m")
data_bymonth_model$treated <- factor(if_else(data_bymonth_model$model %in% c("Fully online", "Primarily online"),1, 0)) 

data_sum_treated$ym <- as.yearmon(paste(data_sum_treated$year, data_sum_treated$month), "%Y %m")

ggplot() + geom_line(data=data_bymonth_model,aes(x=ym,y=difficulty,group=model,color=model),
                     size=.5,alpha=0.5) + # plot the individual lines
  geom_vline(xintercept = as.yearmon(ymd("2020-03-10")), color = "black",size=.5) + # intervention point
  geom_vline(xintercept = as.yearmon(ymd("2020-08-1")), color = "black",size=.5) + # intervention point
  scale_x_yearmon() +
  labs(title="College Difficulty Rankings - Monthly Aggregate",
       subtitle="",
       x="Time",
       y="Difficulty") +
  theme_minimal() +
  theme(axis.text.y = element_blank(),
        legend.title = element_blank(),
        legend.position = "bottom") 
ggsave("plot_online.png", plot = p3)