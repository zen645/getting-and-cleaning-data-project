library(dplyr)
library(tidyr)

# Download zip file in current directory
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileURL, "UCI HAR Dataset.zip", mode = "wb")

# Unzip file in current directory
unzip("UCI HAR Dataset.zip")

## Set working directory to new folder
setwd("C:/Users/C8BK/Documents/UCI HAR Dataset")


## 1. Merge the training and test data sets
## Read in the features data

features <- tbl_df(read.table('./features.txt',header=FALSE, stringsAsFactors = FALSE))
features$V2 <- gsub("[()]","",features$V2)
features$V2 <- gsub("-mean","Mean",features$V2)
features$V2 <- gsub("-std","StdDev",features$V2)
features$V2 <- gsub("Acc","Accel",features$V2)
features$V2 <- gsub("BodyBody","Body",features$V2)
feature_wide <- spread(features,V1,V2)
activityType <- tbl_df(read.table('./activity_labels.txt',header=FALSE))
subjectTrain <- tbl_df(read.table('./train/subject_train.txt',header=FALSE))
x_Train <- tbl_df(read.table('./train/x_train.txt',header=FALSE))
y_Train <- tbl_df(read.table('./train/y_train.txt',header=FALSE))

## Clean up data and column names
colnames(activityType) <- c("Activity_Index","Activity_Type")
colnames(subjectTrain) <- "subjectid"
colnames(x_Train) <- feature_wide[1,]
colnames(y_Train) <- "Activity_Index"
colnames(features) <- c("Feature_id","Activity_measure")

## Merge the Training data sets into one
training_dt <- cbind(subjectTrain,y_Train,x_Train)

## Read in the test data sets
subjectTest <- tbl_df(read.table('./test/subject_test.txt',header = FALSE))
x_Test <- tbl_df(read.table('./test/x_test.txt',header=FALSE))
y_Test <- tbl_df(read.table('./test/y_test.txt',header=FALSE))

##CLean up data and column names
colnames(subjectTest) <- "subjectid"
colnames(x_Test) <- feature_wide[1,]
colnames(y_Test) <- "Activity_Index"

## Merge the Test data sets into one 
test_dt <- cbind(subjectTest,y_Test,x_Test)

## Final Data Set
final_dt <- rbind(training_dt,test_dt)


## 2. Extracts only the measurements on the mean and standard deviation for each measurement.

## Remove duplicated column names
final_dt <- final_dt[, !duplicated(colnames(final_dt))]
final_clean <- select(final_dt,subjectid, Activity_Index, contains("mean"), contains("std"))


## 3. Use descriptive activity names to name the activities in the data set
final_clean <- merge(final_clean,activityType, by = "Activity_Index", all.x = TRUE)

## 4. Label the column names with descriptive activity names
## See lines 19 - 23 for the clean up of column names
## and below
final_cleanup <- select(final_clean,c(subjectid, Activity_Type,`tBodyAccelMean-X`:`fBodyGyroJerkMagStdDev`))

## 5. From the data set in step 4, creates a second, independent tidy data set with the 
## average of each variable for each activity and each subject.

## Re-organize the data
group_clean_up <- select(final_cleanup,c(subjectid, Activity_Type,`tBodyAccelMean-X`:`fBodyGyroJerkMagStdDev`))

## Group the data for summarization
final_group <- group_by(group_clean_up,subjectid,Activity_Type)

## Use the summarize all to average out the data for all the columns based on the Activity Type
final_summary <- summarize_all(final_group,funs(mean))

write_xlsx(final_summary,"Final_Summary.xlsx")
