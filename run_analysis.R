# url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(url)
# consider we downloded the data and set the working directory in a way to include our data, then proceed below script.


file.path(getwd(), "getdata_projectfiles_UCI HAR Dataset.zip")

unzip(zipfile = "getdata_projectfiles_UCI HAR Dataset.zip")


# Load txt files of the activity labels and features 

activityLabels <- read.table(file.path(getwd(), "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))

NewfeaturesFile <- read.table(file.path(getwd(), "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))

# Extract only the data on mean and standard deviation
WantedRows <- grep(".*mean.*|.*std.*", NewfeaturesFile [,2])
featuresWanted.names <- NewfeaturesFile [WantedRows,2]
mean_match = gsub('-mean', 'Mean', featuresWanted.names)
std_match = gsub('-std', 'Std', featuresWanted.names)
redundentRemove <- gsub('[-()]', '', featuresWanted.names)


# Now load the datasets
train <- read.table(file.path(getwd(),"UCI HAR Dataset/train/X_train.txt"))
trainActivities <- read.table(file.path(getwd(),"UCI HAR Dataset/train/Y_train.txt"))
trainSubjects <- read.table(file.path(getwd(),"UCI HAR Dataset/train/subject_train.txt"))
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table(file.path(getwd(),"UCI HAR Dataset/test/X_test.txt"))
testActivities <- read.table(file.path(getwd(),"UCI HAR Dataset/test/Y_test.txt"))
testSubjects <- read.table(file.path(getwd(),"UCI HAR Dataset/test/subject_test.txt"))
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
mergedData <- rbind(train, test)
colnames(mergedData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
mergedData$activity <- factor(mergedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
mergedData$subject <- as.factor(mergedData$subject)

mergedData.melted <- melt(mergedData, id = c("subject", "activity"))
mergedData.mean <- dcast(mergedData.melted, subject + activity ~ variable, mean)

write.table(mergedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
