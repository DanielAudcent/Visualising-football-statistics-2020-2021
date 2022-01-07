#Load packages required
library(ggplot2)
library(plyr)
library(dplyr)
library(data.table)
library(grid)
library(gridExtra)
library(png)
library(tidyr)

library(ggimg)
# ggimg citation {,
#  title = {ggimg: Graphics Layers for Plotting Image Data with ggplot2},
#  author = {Taylor B. Arnold},
#  year = {2020},
#  note = {R package version 0.1.0},
#  url = {https://github.com/statsmaths/ggmaptile},
#}

# NOTICE:
# I do not own any of the data files which has been used during this project.
# The data files provided during this project, are the property of the following websites:
# FBREF - link: https://fbref.com/en
# Understat - link: https://understat.com
# TransferMarkt - link: https://www.transfermarkt.co.uk

########################################################################################################################
############ Data Loader ###############################################################################################
########################################################################################################################

## Pre load all the data files required
message("Data is being loaded...")

#Set working directory to Parent folder, create variable node points for subfolders
setwd("C://Users/Daniel/Desktop/MSc Data Science/Semester 2/Fundamentals to Information visualisation/Assignment1/")

base_loc <- getwd()
images_folder <- file.path(base_loc, "Team Logos/")
FBRef_folder <- file.path(base_loc, "Data/FBRef/")
TM_folder <- file.path(base_loc, "Data/TransferMarkt/")
wf_folder <- file.path(base_loc, "Data/worldfootball.net/")
Understat_folder <- file.path(base_loc, "Data/Understat/")

# Read in data files containing league tables at end of season from FBRef:
EPL_table_2017_2 <- read.csv(file.path(FBRef_folder,"EPL_League_table_2017.csv"), header = TRUE)
EPL_table_2018_2 <- read.csv(file.path(FBRef_folder,"EPL_League_table_2018.csv"), header = TRUE)
EPL_table_2019_2 <- read.csv(file.path(FBRef_folder,"EPL_League_table_2019.csv"), header = TRUE)
EPL_table_2020_2 <- read.csv(file.path(FBRef_folder,"EPL_League_table_2020.csv"), header = TRUE)

# Read in other FBRef files required:
Squad_G_SC <- read.csv(file.path(FBRef_folder,"Squad_Goal_and_Shot_Creation_2020.csv" ), header = TRUE)
Standard_squad_stats <- read.csv(file.path(FBRef_folder,"Standard_Squad_Stats_2020.csv" ), header = TRUE)

# Read in club value data files extracted from TransferMarkt:
Club_values_2017_1 <-  read.csv(file.path(TM_folder,"Club_values_2017-10-15.csv" ), header = TRUE)
Club_values_2017_2 <-  read.csv(file.path(TM_folder,"Club_values_2018-01-15.csv" ), header = TRUE)
Club_values_2018_1 <-  read.csv(file.path(TM_folder,"Club_values_2018-10-15.csv" ), header = TRUE)
Club_values_2018_2 <-  read.csv(file.path(TM_folder,"Club_values_2019-01-15.csv" ), header = TRUE)
Club_values_2019_1 <-  read.csv(file.path(TM_folder,"Club_values_2019-10-15.csv" ), header = TRUE)
Club_values_2019_2 <-  read.csv(file.path(TM_folder,"Club_values_2020-01-15.csv" ), header = TRUE)
Club_values_2020_1 <-  read.csv(file.path(TM_folder,"Club_values_2020-10-15.csv" ), header = TRUE)
Club_values_2020_2 <-  read.csv(file.path(TM_folder,"Club_values_2021-01-15.csv" ), header = TRUE)

# Understat data files to be read in containing stats for all teams, as separate list of dataframes for each year
#2016 stats
setpath <- file.path(Understat_folder,"2016/")
files <- list.files(path=setpath, pattern="*.csv", full.names = TRUE)
team_stats_2016 <- lapply((files), data.table::fread)
names(team_stats_2016) <- basename(gsub("\\.csv$", "", files))

#2017 stats
setpath <- file.path(Understat_folder,"2017/")
files <- list.files(path=setpath, pattern="*.csv", full.names = TRUE)
team_stats_2017 <- lapply((files), data.table::fread)
names(team_stats_2017) <- basename(gsub("\\.csv$", "", files))

#2018 stats
setpath <- file.path(Understat_folder,"2018/")
files <- list.files(path=setpath, pattern="*.csv", full.names = TRUE)
team_stats_2018 <- lapply((files), data.table::fread)
names(team_stats_2018) <- basename(gsub("\\.csv$", "", files))

#2019 stats
setpath <- file.path(Understat_folder,"2019/")
files <- list.files(path=setpath, pattern="*.csv", full.names = TRUE)
team_stats_2019 <- lapply((files), data.table::fread)
names(team_stats_2019) <- basename(gsub("\\.csv$", "", files))

#2020 stats
setpath <- file.path(Understat_folder,"2020/")
files <- list.files(path=setpath, pattern="*.csv", full.names = TRUE)
team_stats_2020 <- lapply((files), data.table::fread)
names(team_stats_2020) <- basename(gsub("\\.csv$", "", files))

# Read in data files containing league tables at specific points in seasons from worldfootball.net:
EPL_table_2017_1 <- read.delim(file.path(wf_folder,"2017-2018_matchweek23.txt"), sep = ",", header = TRUE)
EPL_table_2018_1 <- read.delim(file.path(wf_folder,"2018-2019_matchweek22.txt"), sep = ",", header = TRUE)
EPL_table_2019_1 <- read.delim(file.path(wf_folder,"2019-2020_matchweek22.txt"), sep = ",", header = TRUE)
EPL_table_2020_1 <- read.delim(file.path(wf_folder,"2020-2021_matchweek17.txt"), sep = ",", header = TRUE)

# if need to remove any data files, this can be done here manually after finished working with them:
#remove(list=c("data_1","data_2", "data_3"))

########################################################################################################################
######## Data Manipulation #############################################################################################
########################################################################################################################

#Extract the names of all clubs for each season, obtain a list of all distinct clubs
club_names20 = as.character(EPL_table_2020_2$Squad)
club_names19 = as.character(EPL_table_2019_2$Squad)
club_names18 = as.character(EPL_table_2018_2$Squad)
club_names17 = as.character(EPL_table_2017_2$Squad)
distinct_club_names = unique(c(club_names17, club_names18, club_names19, club_names20))

# Make team names consistent across all dataframes (e.g Manchester Utd -> Manchester United)
distinct_club_names[2] = "Manchester United"
distinct_club_names[9] = "Leicester"
distinct_club_names[10] = "Newcastle United"
distinct_club_names[20] = "West Bromwich Albion"
distinct_club_names[21] = "Wolverhampton Wanderers"
distinct_club_names[24] = "Sheffield United"
club_names20[9] = "Leeds United"

# Assign each teams appropriate colour and logo
team_colors = c("Manchester City" = "#6CABDD",
                "Manchester United"="#DA291C",
                "Tottenham"="snow",
                "Liverpool"="#c8102E",
                "Chelsea"="#034694",
                "Arsenal"="#EF0107",
                "Burnley"="#6C1D45",
                "Everton" ="#003399",
                "Leicester" ="#003090",
                "Newcastle United"="#241F20",
                "Crystal Palace"="#1B458F",
                "Bournemouth"="#DA291C",
                "West Ham" ="#7A263A",
                "Watford"="#FBEE23",
                "Brighton"="#0057B8",
                "Huddersfield" ="#0E63AD",
                "Southampton" ="#D71920",
                "Swansea City"="#121212",
                "Stoke City"="#E03A3E",
                "West Bromwich Albion"="#122F67",
                "Wolverhampton Wanderers"="#FDB913",
                "Cardiff City"="#0070b5",
                "Fulham" ="snow",
                "Sheffield United" ="#ee2737",
                "Aston Villa"="#670e36",
                "Norwich City" ="#FFF200",
                "Leeds United"="snow")

team_logos = c("Manchester City" = file.path(images_folder,"Manchester_City.PNG"),
               "Manchester United"= file.path(images_folder,"Manchester_United.PNG"),
               "Tottenham"= file.path(images_folder,"Tottenham_Hotspur.PNG"),
               "Liverpool"= file.path(images_folder,"Liverpool.PNG"),
               "Chelsea"= file.path(images_folder,"Chelsea.PNG"),
               "Arsenal"= file.path(images_folder,"Arsenal.PNG"),
               "Burnley"= file.path(images_folder,"Burnley.PNG"),
               "Everton" = file.path(images_folder,"Everton.PNG"),
               "Leicester" = file.path(images_folder,"Leicester.PNG"),
               "Newcastle United"= file.path(images_folder,"Newcastle_United.PNG"),
               "Crystal Palace"= file.path(images_folder,"Crystal_Palace.PNG"),
               "Bournemouth"= file.path(images_folder,"Bournemouth.PNG"),
               "West Ham" = file.path(images_folder,"West_Ham.PNG"),
               "Watford"= file.path(images_folder,"Watford.PNG"),
               "Brighton"= file.path(images_folder,"Brighton_And_Hove_Albion.PNG"),
               "Huddersfield" = file.path(images_folder,"Huddersfield.PNG"),
               "Southampton" = file.path(images_folder,"Southampton.PNG"),
               "Swansea City"= file.path(images_folder,"Swansea_City.PNG"),
               "Stoke City"= file.path(images_folder,"Stoke_City.PNG"),
               "West Bromwich Albion"= file.path(images_folder,"West_Bromwich_Albion.PNG"),
               "Wolverhampton Wanderers"= file.path(images_folder,"Wolverhampton_Wanderers.PNG"),
               "Cardiff City"= file.path(images_folder,"Cardiff_City.PNG"),
               "Fulham" = file.path(images_folder,"Fulham.PNG"),
               "Sheffield United" = file.path(images_folder,"Sheffield_United.PNG"),
               "Aston Villa"= file.path(images_folder,"Aston_Villa.PNG"),
               "Norwich City" = file.path(images_folder,"Norwich.PNG"),
               "Leeds United"= file.path(images_folder,"Leeds_United.PNG"))

team_logos_df <- data.frame("club_name" = names(team_logos), "img_path" = team_logos)

## Question 1 preparation
#Creating a new dataframe with all information necessary for Q1's plot
# e.g {Team_name, Expected_points, Points, Points_difference }

club_names19 = c()
club_names20 = c()
points_2020 = c()
xpoints_2020 = c()
points_2019 = c()
xpoints_2019 = c()

for (i in seq(1,length(names(team_stats_2020)),1)){
  club_names20[i] <- gsub("_"," ",substr(names(team_stats_2020[i]), 1, nchar(names(team_stats_2020[i]))-5))
  points_2020[i] <- sum(team_stats_2020[[i]]$pts)
  xpoints_2020[i] <- sum(team_stats_2020[[i]]$xpts)
  }

for (i in seq(1,length(names(team_stats_2019)),1)){
  club_names19[i] <- gsub("_"," ",substr(names(team_stats_2019[i]), 1, nchar(names(team_stats_2019[i]))-5))
  points_2019[i] <- sum(team_stats_2019[[i]]$pts)
  xpoints_2019[i] <- sum(team_stats_2019[[i]]$xpts)
}


x <- data.frame(club_names19, xpoints_2019, points_2019)
y <- data.frame(club_names20, xpoints_2020, points_2020)
colnames(x)[1] = "club_name"
colnames(y)[1] = "club_name"
levels(y$club_name)[9] <- "Leeds United"
z <- merge(x, y, by= "club_name", all= TRUE)

z$points_diff_2019 <- z$points_2019 - z$xpoints_2019
z$points_diff_2020 <- z$points_2020 - z$xpoints_2020
z$xpoints_diff <- (z$points_diff_2020 - z$points_diff_2019)

# Question 2 preparation
# Create a dataframe containing all info required for Q2's plot 
# {club_name, avg_possession, Goals, Expected_goals, Goal_Creating_Actions,GCA_per_90_mins, Points }
poss90 <- Standard_squad_stats[,4]
Gls <- Standard_squad_stats[,5]
xG <- Standard_squad_stats[,17]
GCA <- Squad_G_SC[,12]
GCA90 <- Squad_G_SC[,13]

sorted_epl_table_2020 <- arrange(EPL_table_2020_2, Squad)

Q2 <- data.frame("club_names" = club_names20, "avg_poss" = poss90,"Goals" =  Gls, xG, GCA, GCA90, "Pts" = points_2020)
Q2$GA <- sorted_epl_table_2020[,8]
levels(Q2$club_names)[9] <- "Leeds United"


#Create individual subsets of possession groups for further analysis from dataset
#Setup classification groups for variables to be investigated
GCA_classes <- c("less than 40","40 to 59", "60 to 79", "more than 89")
Gls_classes <- c("less than 30", "30 to 45", "more than 45")
GA_classes <- c("less than 30", "30 to 39", "40 to 50", "more than 50")
GCA_class_values <- c(0,39,59,79,Inf)
Gls_class_values <- c(0,29,45, Inf)
GA_class_values <- c(0,29,39,50, Inf)

##NOTE: time dependant, could create a function to accomplish the following more concisely
#Group1: Poss > 55:
poss_gt_55 <- data.table(Q2[which(Q2$avg_poss > 55),])
poss_gt_55$GCA_class <- cut(poss_gt_55$GCA, GCA_class_values,GCA_classes)
summary.possgt55 <- data.frame("class" = GCA_classes,
                               "counts" = c(sum(poss_gt_55$GCA_class==GCA_classes[1]),
                                            sum(poss_gt_55$GCA_class==GCA_classes[2]),
                                            sum(poss_gt_55$GCA_class==GCA_classes[3]),
                                            sum(poss_gt_55$GCA_class==GCA_classes[4])))
summary.possgt55$prop <- (summary.possgt55$counts/sum(summary.possgt55$counts))*100

poss_gt_55$Gls_class <- cut(poss_gt_55$Goals, Gls_class_values, Gls_classes)
summary.possgt55gls <- data.frame("class" = Gls_classes,
                                  "counts" = c(sum(poss_gt_55$Gls_class==Gls_classes[1]),
                                               sum(poss_gt_55$Gls_class==Gls_classes[2]),
                                               sum(poss_gt_55$Gls_class==Gls_classes[3])))
summary.possgt55gls$prop <- (summary.possgt55gls$counts/sum(summary.possgt55gls$counts))*100

poss_gt_55$GA_class <- cut(poss_gt_55$GA, GA_class_values,GA_classes)
summary.possgt55ga <- data.frame("class" = GA_classes,
                                  "counts" = c(sum(poss_gt_55$GA_class==GA_classes[1]),
                                               sum(poss_gt_55$GA_class==GA_classes[2]),
                                               sum(poss_gt_55$GA_class==GA_classes[3]),
                                               sum(poss_gt_55$GA_class==GA_classes[4])))
summary.possgt55ga$prop <- (summary.possgt55ga$counts/sum(summary.possgt55ga$counts))*100


#Group2: 45 < Poss < 55
poss_gt45_lt55 <- data.table(Q2[which(Q2$avg_poss < 55 & Q2$avg_poss > 45),])
poss_gt45_lt55$GCA_class <- cut(poss_gt45_lt55$GCA, GCA_class_values,GCA_classes)
summary.possgt45lt55 <- data.frame("class" = GCA_classes,
                               "counts" = c(sum(poss_gt45_lt55$GCA_class==GCA_classes[1]),
                                            sum(poss_gt45_lt55$GCA_class==GCA_classes[2]),
                                            sum(poss_gt45_lt55$GCA_class==GCA_classes[3]),
                                            sum(poss_gt45_lt55$GCA_class==GCA_classes[4])))
summary.possgt45lt55$prop <- (summary.possgt45lt55$counts/sum(summary.possgt45lt55$counts))*100

poss_gt45_lt55$Gls_class <- cut(poss_gt45_lt55$Goals, Gls_class_values, Gls_classes)
summary.possgt45lt55gls <- data.frame("class" = Gls_classes,
                                  "counts" = c(sum(poss_gt45_lt55$Gls_class==Gls_classes[1]),
                                               sum(poss_gt45_lt55$Gls_class==Gls_classes[2]),
                                               sum(poss_gt45_lt55$Gls_class==Gls_classes[3])))
summary.possgt45lt55$prop <- (summary.possgt45lt55$counts/sum(summary.possgt45lt55$counts))*100

poss_gt45_lt55$GA_class <- cut(poss_gt45_lt55$GA, GA_class_values,GA_classes)
summary.possgt45lt55ga <- data.frame("class" = GA_classes,
                                 "counts" = c(sum(poss_gt45_lt55$GA_class==GA_classes[1]),
                                              sum(poss_gt45_lt55$GA_class==GA_classes[2]),
                                              sum(poss_gt45_lt55$GA_class==GA_classes[3]),
                                              sum(poss_gt45_lt55$GA_class==GA_classes[4])))
summary.possgt45lt55ga$prop <- (summary.possgt45lt55ga$counts/sum(summary.possgt45lt55ga$counts))*100

#Group3: Poss < 45
poss_lt_45 <- data.table(Q2[which(Q2$avg_poss < 45),])
poss_lt_45$GCA_class <- cut(poss_lt_45$GCA, GCA_class_values,GCA_classes)
summary.poss_lt_45 <- data.frame("class" = GCA_classes,
                               "counts" = c(sum(poss_lt_45$GCA_class==GCA_classes[1]),
                                            sum(poss_lt_45$GCA_class==GCA_classes[2]),
                                            sum(poss_lt_45$GCA_class==GCA_classes[3]),
                                            sum(poss_lt_45$GCA_class==GCA_classes[4])))
summary.poss_lt_45$prop <- (summary.poss_lt_45$counts/sum(summary.poss_lt_45$counts))*100

poss_lt_45$Gls_class <- cut(poss_lt_45$Goals, Gls_class_values, Gls_classes)
summary.poss_lt_45gls <- data.frame("class" = Gls_classes,
                                  "counts" = c(sum(poss_lt_45$Gls_class==Gls_classes[1]),
                                               sum(poss_lt_45$Gls_class==Gls_classes[2]),
                                               sum(poss_lt_45$Gls_class==Gls_classes[3])))
summary.poss_lt_45gls$prop <- (summary.poss_lt_45gls$counts/sum(summary.poss_lt_45gls$counts))*100

poss_lt_45$GA_class <- cut(poss_lt_45$GA, GA_class_values,GA_classes)
summary.poss_lt_45ga <- data.frame("class" = GA_classes,
                                 "counts" = c(sum(poss_lt_45$GA_class==GA_classes[1]),
                                              sum(poss_lt_45$GA_class==GA_classes[2]),
                                              sum(poss_lt_45$GA_class==GA_classes[3]),
                                              sum(poss_lt_45$GA_class==GA_classes[4])))
summary.poss_lt_45ga$prop <- (summary.poss_lt_45ga$counts/sum(summary.poss_lt_45ga$counts))*100

# refactor class levels for each possession group to ensure legend remains consistent
summary.possgt55$class <- factor(summary.possgt55$class, levels = GCA_classes)
summary.possgt45lt55$class <- factor(summary.possgt45lt55$class, levels = GCA_classes)
summary.poss_lt_45$class <- factor(summary.poss_lt_45$class, levels = GCA_classes)

summary.possgt55gls$class <- factor(summary.possgt55gls$class, levels = Gls_classes)
summary.possgt45lt55gls$class <- factor(summary.possgt45lt55gls$class, levels = Gls_classes)
summary.poss_lt_45gls$class <- factor(summary.poss_lt_45gls$class, levels = Gls_classes)

summary.possgt55ga$class <- factor(summary.possgt55ga$class, levels = GA_classes)
summary.possgt45lt55ga$class <- factor(summary.possgt45lt55ga$class, levels = GA_classes)
summary.poss_lt_45ga$class <- factor(summary.poss_lt_45ga$class, levels = GA_classes)

# Question 3 preparation
# Building a dataframe containing all the required information for Q3
# {Team_name, Club_value, Expected_goals_against,Goals_against, Expected_goals, Goals, expected_points, Points}

ordered_Club_values_2020_2 <- arrange(Club_values_2020_2, Club.Name)

y$current_value <- ordered_Club_values_2020_2$Current.club.value..mil.
y$club_value_20210115 <- ordered_Club_values_2020_2$Club.value.at.2021.01.15..mil.
y$GF <- Standard_squad_stats$Gls
y$xG <- Standard_squad_stats$xG

xGA_2020 <- c()
for (i in seq(1,20,1)){
  xGA_2020[i] <- Reduce("+",team_stats_2020[[i]][[3]])
}

y$xGA <- xGA_2020
y2 <- merge(y, team_logos_df, by = "club_name")
y2$img_path <- as.character(y2$img_path)
avg_current_val <- sum(y2$current_value)/20
levels(y2$club_name)[9] <- "Leeds United"

# Question 4 preparation
# Building two dataframes with all time series information for Q4
# {Team_name,Team_logo_path,val_17_1, val_17_2, ... etc. }
# {Team_name, Team_logo_path, Pos_17_1, Pos_17_2, ... etc.}

Club_values_2017_1 <- Club_values_2017_1[order(as.character(Club_values_2017_1$Club.Name)),]
Club_values_2017_2 <- Club_values_2017_2[order(as.character(Club_values_2017_2$Club.Name)),]
Club_values_2018_1 <- Club_values_2018_1[order(as.character(Club_values_2018_1$Club.Name)),]
Club_values_2018_2 <- Club_values_2018_2[order(as.character(Club_values_2018_2$Club.Name)),]
Club_values_2019_1 <- Club_values_2019_1[order(as.character(Club_values_2019_1$Club.Name)),]
Club_values_2019_2 <- Club_values_2019_2[order(as.character(Club_values_2019_2$Club.Name)),]
Club_values_2020_1 <- Club_values_2020_1[order(as.character(Club_values_2020_1$Club.Name)),]
Club_values_2020_2 <- Club_values_2020_2[order(as.character(Club_values_2020_2$Club.Name)),]

Q4.1 <- data.frame("club_name" = club_names20,
                   "date1" = rank(-Club_values_2017_1$Club.value.at.2017.10.15..mil.),
                   "date2" = rank(-Club_values_2017_2$Club.value.at.2018.01.15..mil.),
                   "date3" = rank(-Club_values_2018_1$Club.value.at.2018.10.15..mil.),
                   "date4" = rank(-Club_values_2018_2$Club.value.at.2019.01.15..mil.),
                   "date5" = rank(-Club_values_2019_1$Club.value.at.2019.10.15..mil.),
                   "date6" = rank(-Club_values_2019_2$Club.value.at.2020.01.15..mil.),
                   "date7" = rank(-Club_values_2020_1$Club.value.at.2020.10.15..mil.),
                   "date8" = rank(-Club_values_2020_2$Club.value.at.2021.01.15..mil.))

levels(Q4.1$club_name)[9] <- "Leeds United"

Q4.1 %>% pivot_longer(-club_name, names_to = "Date", values_to = "Rank") -> Q4.1
Q4.1 <- merge(Q4.1, team_logos_df, by = "club_name")

# Question 5 preparation
# Build the dataframe with all variables needed
# {team_name,P_diff_16, P_diff_17, P_diff_18, P_diff_19, P_diff_20, max_P_diff, min_P_diff, Median }

club_names16 = c()
club_names17 = c()
club_names18 = c()
points_2016 = c()
xpoints_2016 = c()
points_2017 = c()
xpoints_2017 = c()
points_2018 = c()
xpoints_2018 = c()

for (i in seq(1,length(names(team_stats_2018)),1)){
  club_names18[i] <- gsub("_"," ",substr(names(team_stats_2018[i]), 1, nchar(names(team_stats_2018[i]))-5))
  points_2018[i] <- sum(team_stats_2018[[i]]$pts)
  xpoints_2018[i] <- sum(team_stats_2018[[i]]$xpts)
}
w <- data.frame(club_names18, xpoints_2018, points_2018)

for (i in seq(1,length(names(team_stats_2017)),1)){
  club_names17[i] <- gsub("_"," ",substr(names(team_stats_2017[i]), 1, nchar(names(team_stats_2017[i]))-5))
  points_2017[i] <- sum(team_stats_2017[[i]]$pts)
  xpoints_2017[i] <- sum(team_stats_2017[[i]]$xpts)
}
v <- data.frame(club_names17, xpoints_2017, points_2017)
  
for (i in seq(1,length(names(team_stats_2016)),1)){
  club_names16[i] <- gsub("_"," ",substr(names(team_stats_2016[i]), 1, nchar(names(team_stats_2016[i]))-5))
  points_2016[i] <- sum(team_stats_2016[[i]]$pts)
  xpoints_2016[i] <- sum(team_stats_2016[[i]]$xpts)
}
u <- data.frame(club_names16, xpoints_2016, points_2016)

colnames(u)[1] = "club_name"
colnames(v)[1] = "club_name"
colnames(w)[1] = "club_name"

Q5 <- Reduce(function(x,y) merge(x, y, by= "club_name", all= TRUE), list(u,v,w,x,y[,1:3]))

Q5$pts_diff16 <- Q5$xpoints_2016 - Q5$points_2016
Q5$pts_diff17 <- Q5$xpoints_2017 - Q5$points_2017
Q5$pts_diff18 <- Q5$xpoints_2018 - Q5$points_2018
Q5$pts_diff19 <- Q5$xpoints_2019 - Q5$points_2019
Q5$pts_diff20 <- Q5$xpoints_2020 - Q5$points_2020

for (i in seq(1,length(Q5$club_name),1)){
  values <- c(Q5[i,12], Q5[i,13], Q5[i,14], Q5[i,15], Q5[i,16])
  Q5$maxp[i] <- max(values, na.rm = TRUE)
  Q5$minp[i] <- min(values, na.rm = TRUE)
  Q5$avgp[i] <- median(values, na.rm = TRUE)
}

Q5 %>% pivot_longer(cols = 17:18, names_to = "stat", values_to = "Value") -> Q5

# Question 6 preparation
# Final dataset to be formatted as:
# {team_name, finishing_pos, count}

Q6 <- Reduce(function(x,y) merge(x, y, by= "club_name", all= TRUE), list(u,v,w,x))
Q6 <- Q6[-c(2,4,6,8)]

Q6$pos_16 <- rank(-Q6$points_2016, ties.method = "min", na.last = "keep")
Q6$pos_17 <- rank(-Q6$points_2017, ties.method = "min", na.last = "keep")
Q6$pos_18 <- rank(-Q6$points_2018, ties.method = "min", na.last = "keep")
Q6$pos_19 <- rank(-Q6$points_2019, ties.method = "min", na.last = "keep")

Q6 %>% pivot_longer(cols = 6:9, names_to = "Season", values_to = "Position") -> Q6

Q6.counts <- as.data.frame(table(Q6$club_name, Q6$Position, exclude = NULL))


########################################################################################################################
######## Basic Analysis and Visualisation ##############################################################################
#######################################################################################################################

# [1.0]   Question 1 Visualisation
Q1plot1 <- z %>%
            filter(!is.na(points_2019)) %>%
              filter(!is.na(points_2020)) %>%
                mutate(Colour = ifelse(xpoints_diff > 0, "lawngreen", "red")) %>%
                  ggplot(aes(x = points_diff_2019, y = points_diff_2020, size = abs(xpoints_diff), colour = Colour)) + 
                    geom_point(pch = 21, colour = "black", aes(size = abs(xpoints_diff)), stroke=2) +
                      geom_point() +
                        scale_color_identity() +
                          scale_size(range = c(min(abs(z$xpoints_diff), na.rm = TRUE), max(abs(z$xpoints_diff), na.rm = TRUE)), breaks = c(5,10, 15),labels = c("5","10","15+"), guide_legend(title="Change in difference between xPts and Pts", label.position = "top", direction = "horizontal")) +
                            geom_text(aes(label = club_name, size = 0.5), color = "black", hjust=-0.1, vjust=-0.5, show.legend = FALSE) +
                              ylim(-20,15) +  ylab("Difference between xPts & Pts so far in 2020") +
                                xlim(-15, 30) + xlab("Difference between xPts & Pts at the end of 2019") +
                                  theme(legend.position="bottom", plot.title = element_text(hjust = 0.5)) +
                                    ggtitle("Comparison of all EPL teams points and xP in the 2019 and 2020 seasons")
                  
# [2.0]   Question 2 Visualisations
# [2.1] Bar chart plot
 Q2plot1 <-ggplot(data = Q2, aes(x = reorder(club_names, avg_poss), y = avg_poss, fill = club_names))+
            geom_bar(stat = "identity", colour = "black", size = 1) +
              geom_abline(intercept = 45, slope = 0, linetype = "dashed", size = 0.5) +
                geom_abline(intercept = 55, slope = 0, linetype = "dashed", size = 0.5) +
                  xlab("") +
                    ggtitle("Average possession over all matches for each EPL club in the 2020 season") +
                      scale_y_continuous("Average possession per match (%)", expand = expansion(mult = c(0, .1)), limits = c(0,70), breaks = seq(30,70,by=5)) +
                        theme(axis.text.x = element_text(angle = 70, hjust = 1), legend.position = "none", plot.title = element_text(hjust = 0.25)) +
                          scale_fill_manual(values = team_colors)

# [2.2]   Pie chart for poss>55
mycols <- c("#868686FF", "#0073C2FF", "#EFC000FF", "#CD534CFF")

Q2plot2.1 <- ggplot(data = summary.possgt55, aes(x = "", y = counts, fill = class, drop = TRUE)) +
            geom_bar(width = 1, stat = "identity", color = "white") + labs(fill = "Goal Creating Actions (GCA)") +
              coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession > 55%") +
                geom_text(data = subset(summary.possgt55, counts != 0), aes(label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                  scale_fill_manual(values = mycols) +
                    theme_void() +  theme(plot.title = element_text(size = 12, hjust = 1, vjust = -6), legend.position = "none")

# [2.2]   Donut chart for 45<poss<55
Q2plot2.2 <- ggplot(data = summary.possgt45lt55, aes(x = 2, y = counts, fill = class, drop = TRUE)) +
            geom_bar(stat = "identity", color = "white") + labs(fill = "Goal Creating Actions (GCA)") +
              coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession between 45% and 55%") +
                geom_text(data = subset(summary.possgt45lt55, counts != 0), aes( label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                  scale_fill_manual(values = mycols) +
                    theme_void() +
                      theme(plot.title = element_text(size = 16, hjust = 0.5, vjust = -25), legend.position = "top", legend.box="horizontal", legend.title = element_text(size = 14), legend.text = element_text(size = 12)) +
                        guides(fill = guide_legend(title.position = "top", title.hjust = 0.5)) +
                          xlim(0.5, 2.5)


# [2.2]   Donut chart for poss<45
Q2plot2.3 <- ggplot(data = summary.poss_lt_45, aes(x = 2, y = counts, fill = class, drop = TRUE)) +
            geom_bar(stat = "identity", color = "white") + labs(fill = "Goal Creating Actions (GCA)") +
              coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession less than 45%") +
                geom_text(data = subset(summary.poss_lt_45, counts != 0), aes( label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                  scale_fill_manual(values = mycols) +
                    theme_void() +
                      theme(plot.title = element_text(size = 12, hjust = 1, vjust = -6), legend.position = "none") + 
                        xlim(0.5, 2.5)

# [2.2]   Grouped
lay <- rbind(c(1,1,3,NA),
             c(1,1,2,NA))
Q2plot2 <- gridExtra::grid.arrange(Q2plot2.2, Q2plot2.1, Q2plot2.3, layout_matrix = lay)


# [2.3]   Pie chart plot for poss>55

Q2plot3.1 <- ggplot(data = summary.possgt55gls, aes(x = "", y = counts, fill = class, drop = TRUE)) +
              geom_bar(width = 1, stat = "identity", color = "white") + labs(fill = "Goals scored") +
                coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession > 55%") +
                  geom_text(data = subset(summary.possgt55gls, counts != 0), aes(label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                    scale_fill_manual(values = mycols) +
                      theme_void() +
                        theme(plot.title = element_text(size = 12, hjust = 1, vjust = -6), legend.position = "none")

# [2.3]   Donut chart for 45<poss<55
Q2plot3.2 <- ggplot(data = summary.possgt45lt55gls, aes(x = 2, y = counts, fill = class, drop = TRUE)) +
              geom_bar(stat = "identity", color = "white") + labs(fill = "Goals scored") +
                coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession between 45% and 55%") +
                  geom_text(data = subset(summary.possgt45lt55gls, counts != 0), aes( label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                    scale_fill_manual(values = mycols) +
                      theme_void() +
                        theme(plot.title = element_text(size = 16, hjust = 0.5, vjust = -25), legend.position = "top", legend.box="horizontal", legend.title = element_text(size = 14), legend.text = element_text(size = 12)) +
                          guides(fill = guide_legend(title.position = "top", title.hjust = 0.5)) +
                            xlim(0.5, 2.5)


# [2.3]   Donut chart for poss<45
Q2plot3.3 <- ggplot(data = summary.poss_lt_45gls, aes(x = 2, y = counts, fill = class, drop = TRUE)) +
              geom_bar(stat = "identity", color = "white") + labs(fill = "Goals scored") +
                coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession less than 45%") +
                  geom_text(data = subset(summary.poss_lt_45gls, counts != 0), aes( label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                    scale_fill_manual(values = mycols) +
                      theme_void() +
                        theme(plot.title = element_text(size = 12, hjust = 1, vjust = -6), legend.position = "none") + 
                          xlim(0.5, 2.5)

# [2.3]   Grouped
lay <- rbind(c(1,1,3,NA),
             c(1,1,2,NA))
Q2plot3 <- gridExtra::grid.arrange(Q2plot3.2, Q2plot3.1, Q2plot3.3, layout_matrix = lay)

# [2.4]   Pie chart for poss>55

Q2plot4.1 <- ggplot(data = summary.possgt55ga, aes(x = "", y = counts, fill = class, drop = TRUE)) +
              geom_bar(width = 1, stat = "identity", color = "white") + labs(fill = "Goals conceded") +
                coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession > 55%") +
                  geom_text(data = subset(summary.possgt55ga, counts != 0), aes(label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                    scale_fill_manual(values = mycols) +
                      theme_void() +
                        theme(plot.title = element_text(size = 12, hjust = 1, vjust = -6), legend.position = "none")

# [2.4]   Donut chart for 45<poss<55
Q2plot4.2 <- ggplot(data = summary.possgt45lt55ga, aes(x = 2, y = counts, fill = class, drop = TRUE)) +
              geom_bar(stat = "identity", color = "white") + labs(fill = "Goals conceded") +
                coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession between 45% and 55%") +
                  geom_text(data = subset(summary.possgt45lt55ga, counts != 0), aes( label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                    scale_fill_manual(values = mycols) +
                      theme_void() +
                        theme(plot.title = element_text(size = 16, hjust = 0.5, vjust = -25), legend.position = "top", legend.box="horizontal", legend.title = element_text(size = 14), legend.text = element_text(size = 12)) +
                          guides(fill = guide_legend(title.position = "top", title.hjust = 0.5)) +
                            xlim(0.5, 2.5)


# [2.4]   Donut chart for poss<45
Q2plot4.3 <- ggplot(data = summary.poss_lt_45ga, aes(x = 2, y = counts, fill = class, drop = TRUE)) +
              geom_bar(stat = "identity", color = "white") + labs(fill = "Goals conceded") +
                coord_polar(theta = "y", start = 0) + ggtitle("Teams with average possession less than 45%") +
                  geom_text(data = subset(summary.poss_lt_45ga, counts != 0), aes( label = counts), position = position_stack(vjust = 0.5), color = "white", size = 6) +
                    scale_fill_manual(values = mycols) +
                      theme_void() +
                        theme(plot.title = element_text(size = 12, hjust = 1, vjust = -6), legend.position = "none") + 
                          xlim(0.5, 2.5)

# [2.4]   Grouped
lay <- rbind(c(1,1,3,NA),
             c(1,1,2,NA))
Q2plot4 <- gridExtra::grid.arrange(Q2plot4.2, Q2plot4.1, Q2plot4.3, layout_matrix = lay)


# [3.0]   Question 3 Visualisations
# [3.1] Line plot with team logos for club values
asp_ratio <- 1.618
Q3plot1 <- ggplot(data = y2, aes(x = reorder(club_name, -points_2020), y = current_value, group=1)) +
            geom_line(aes(linetype = "solid"), size = 1) +   
              geom_point_img(aes(img = img_path), size = 0.8) +
                geom_abline( aes(intercept = avg_current_val, slope = 0, linetype = "dashed"), show.legend = FALSE) +
                  theme(aspect.ratio = 1/asp_ratio, legend.position = c(0.8, 0.8),legend.background = element_blank(), plot.title = element_text(hjust = 0.5)) +
                    scale_x_discrete(labels = seq(1,20,1)) +
                      labs(x = "Current position in EPL standings", y = "Current club value (£ M)") +
                        scale_y_continuous(breaks = seq(100, 1075, by = 75)) +
                          scale_linetype_manual(name = NULL, labels = c("Average value of all EPL clubs", "Current club values"), values = c("dashed" = 3, "solid" = 1)) +
                            ggtitle("A comparison of the current EPL club values against the current standings in the 2020 season")

# [3.2] Radial chart for xG and xGA
Q3plot2.1 <- ggplot(data=y2,  aes(x=club_name, y=xG, fill = club_name)) + 
            geom_bar(stat = "identity", colour = "black") + 
              ylim(0,65) + 
                ggtitle("xG for all EPL teams for the season 2020-21")  + 
                  theme(plot.title = element_text(color = "black", size = 14, hjust = 0.5),
                        axis.text.x = element_text(color = "black", size = 6),
                        axis.title.x = element_blank(),
                        axis.title.y = element_blank(),
                        axis.text.y = element_blank(),
                        axis.ticks.y = element_blank(),
                        legend.position = "none") +
                    geom_hline(aes(yintercept = sum(xG)/20), lwd=1, lty=2) + 
                      scale_fill_manual(values = team_colors) +
                        coord_polar()

Q3plot2.2 <- ggplot(data=y2,  aes(x=club_name, y=xGA, fill = club_name)) + 
              geom_bar(stat = "identity", colour = "black", show.legend =  FALSE) + 
                ylim(0,65) + 
                  ggtitle("xGA for all EPL teams for the season 2020-21")  + 
                    theme(plot.title = element_text(color = "black", size = 14, hjust = 0.5),
                          axis.text.x = element_text(color = "black", size = 6),
                          axis.title.x = element_blank(),
                          axis.title.y = element_blank(),
                          axis.text.y = element_blank(),
                          axis.ticks.y = element_blank()) +
                        geom_hline(aes(yintercept = sum(xGA)/20, linetype = "Mean value of all teams"), lwd = 1) + 
                          scale_fill_manual(values = team_colors) +
                            scale_linetype_manual(name = "", values = 2, guide = guide_legend()) +
                              theme(legend.position = c(-0.025,0.925),legend.key = element_blank(), legend.background = element_rect(colour = "grey")) +
                                coord_polar()

lay2 <- rbind(c(1,2),
              c(1,2))
Q3plot2 <- gridExtra::grid.arrange(Q3plot2.1, Q3plot2.2, layout_matrix = lay2)

# [4.0] Time series line graph for Club values

Q4plot1 <- ggplot(data = Q4.1, aes(x = Date, y = Rank, group = club_name, color = club_name)) +
            geom_line(size = 1.25) +          
              geom_point_img(aes(img = img_path), size = 0.5) +
                scale_y_reverse(lim = c(20,1), breaks = seq(20,1, by = -1)) +
                  scale_color_manual(values = team_colors) +
                    ylab("EPL Club value ranking") +
                      xlab("Date of club value estimation") +
                        ggtitle("EPL Clubs value rankings for over the course of the past four seasons") +
                        scale_x_discrete(labels = c("15/10/2017","15/01/2018","15/10/2018","15/01/2019","15/10/2019","15/01/2020","15/10/2020","15/01/2021")) +
                            theme(legend.position = "none",
                                  panel.grid.minor = element_blank(),
                                  panel.grid.major = element_blank(),
                                  plot.title = element_text(hjust = 0.5, size = 16))

# [5.0] min/max/median boxplot for Expected points - Actual points
BGimage <- png::readPNG(file.path(images_folder, "BG_image.PNG"))

Q5plot1 <- ggplot(data = Q5, aes(x = reorder(club_name, avgp), y = Value, group = club_name)) +
            annotation_custom(rasterGrob(BGimage,width = unit(1,"npc"),height = unit(1,"npc")), -Inf, Inf, -Inf, Inf) +
              geom_point(size = 2.5, aes(colour = "Min/Max values")) +
                geom_line(size = 0.5) +
                  geom_point(shape = 3, aes(y = avgp, colour = "Median values"), size = 2.5) +
                    geom_hline(yintercept = 0, linetype = "dotted") +
                      theme(axis.text.x = element_text(angle = 70, hjust = 1),legend.background = element_blank(),legend.position = c(0.1,0.9), legend.key = element_blank(), plot.title = element_text(hjust = 0.25)) +
                        scale_y_continuous(breaks = seq(-30,30,5)) +
                          scale_colour_manual(name = "", values = c("grey","black"), labels = c("Median value", "min/max values")) +
                             xlab("Team name") +
                              ylab("Expected points - Actual points") +
                                ggtitle("Box plot showing the range of difference between the xP and actual points for each EPL club over the recent 5 seasons")


# [6.0] heatmap plot of league position of finishing position for last 5 seasons
Q6_colours <- c("#FFFFFF", "#C0C0C0", "#888888", "#606060", "#181818")

Q6plot <- ggplot(data = subset(Q6.counts, !is.na(Var2)), mapping = aes(x = Var2, y = Var1, fill = factor(Freq))) +
            geom_tile() +
              scale_x_discrete(limits = rev(levels(Q6.counts$Var2))) +
                scale_fill_manual(name = "# times finished in position", values = Q6_colours) +
                  xlab("Position in EPL table") +
                    ylab("EPL team name") +
                      theme(plot.title = element_text(hjust = 0.25, size = 13), legend.direction = "horizontal", legend.key = element_rect(colour = "black", size = 1)) +
                        ggtitle("Heat map for the number of times a team finishes in a specific position over the last four seasons in the EPL")






