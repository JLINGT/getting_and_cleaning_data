# clear workspace
rm(list=ls())

# install required packages
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

# load libs
library(data.table)
library(reshape2)

# download zipped data file
zipfile <- "getdata-projectfiles-UCI HAR Dataset.zip"

if (!file.exists(zipfile)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, zipfile, method="curl")
}  

if (!file.exists("UCI HAR Dataset")) { 
  unzip(zipfile) 
}

# load activities
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# load features
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# only the measurements on the mean and standard deviation
features_extracted <- grepl("mean|std", features)

#############  Start Processing of Training Data #############################################################################

# process X_train and y_train 
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_train) = features

# only the measurements on the mean and standard deviation
X_train = X_train[,features_extracted]

# load y_train activity 
y_train[,2] = activities[y_train[,1]]
names(y_train) <- c("Activity_Index", "Activity_Type")
names(subject_train) <- "Subject"

# bind training data of y and X
data_train <- cbind(as.data.table(subject_train), y_train, X_train)

#############  End Processing of Training Data ##################################################################


#############  Start Processing of Test Data ##################################################################

# process X_test and y_test 
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(X_test) <- features

# only the measurements on the mean and standard deviation.
X_test <- X_test[, features_extracted]

# load y_test activity
y_test[,2] <- activities[y_test[,1]]
names(y_test) <- c("Activity_Index", "Activity_Type")
names(subject_test) <- "Subject"

# bind test data of y and X
data_test <- cbind(as.data.table(subject_test), y_test, X_test)

#############  End Processing of Test Data ##################################################################

# combind training data and test data
data_combined <- rbind(data_test, data_train)

# create tidy data
labels <- c("Subject", "Activity_Index", "Activity_Type")
data_labels <- setdiff(colnames(data_combined), labels)
data_melt <- melt(data_combined, id=labels, measure.vars=data_labels)
data_tidy <- dcast(data_melt, Subject + Activity_Type ~ variable, mean)
write.table(data_tidy, file="./data_tidy.txt")

#############  End Creating Tidy Data ####################################################################

