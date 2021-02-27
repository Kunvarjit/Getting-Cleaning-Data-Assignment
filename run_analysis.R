## Load the reshape2 Library:
library(reshape2)

fName <- "getdata_dataset.zip"


## Downloading and Unzipping the Data:
if (!file.exists(fName))
{   fURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fURL, fName, method = "curl")
}

if(!file.exists("UCI HAR Dataset"))
{   unzip(fName)
}


## Loading Activity Labels and Features:
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[, 2] <- as.character(actLabels[, 2])
feat <- read.table("UCI HAR Dataset/features.txt")
feat[, 2] <- as.character(feat[, 2])


## Extracting the Mean and Standard Deviation Data:
feat2 <- grep(".*mean.*|.*std.*", feat[, 2])
feat2.names <- feat[feat2, 2]
feat2.names <- gsub("-mean", "Mean", feat2.names)
feat2.names <- gsub("-std", "Standard_Deviation", feat2.names)
feat2.names <- gsub("[-()]", "", feat2.names)


## Loading the Data
train <- read.table("UCI HAR Dataset/train/X_train.txt")[feat2]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[feat2]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)


## Merging Data and Adding Labels
mergedData <- rbind(train, test)
colnames(mergedData) <- c("subject", "activity", feat2.names)


## Converting Activities and Subjects into Factors:
mergedData$activity <- factor(mergedData$activity, levels = actLabels[, 1], labels = actLabels[, 2])
mergedData$subject <- as.factor(mergedData$subject)

meltedData <- melt(mergedData, id = c("subject", "activity"))
meanData <- dcast(meltedData, subject + activity ~ variable, mean)

write.table(meanData, "tidy.txt", row.names = FALSE, quote = FALSE)
