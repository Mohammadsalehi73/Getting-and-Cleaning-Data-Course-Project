# Load Packages and get the Data

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url, file.path(getwd(), "dataFiles.zip"))

unzip(zipfile = "dataFiles.zip")


# Load the documents of activity labels and features

activityLabels <- fread(file.path(getwd(), "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))

features <- fread(file.path(getwd(), "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))

#Mean and Standard deviation for For the column featureNames

features_F <- grep("(mean|std)\\(\\)", features[, featureNames])

measure <- features[features_F, featureNames]

#Just Delate "()"
measure <- gsub('[()]', '', measure)



# Load train datasets

trainX <- fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[, features_F, with = FALSE]

data.table::setnames(trainX, colnames(trainX), measure)

trainY <- fread(file.path(getwd(), "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))

trainSubjects <- fread(file.path(getwd(), "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))

#Combination of the documents
train <- cbind(trainSubjects, trainY, trainX)



# Load test datasets

testX <- fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[, features_F, with = FALSE]

data.table::setnames(testX, colnames(testX), measure)

testY <- fread(file.path(getwd(), "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))

testSubjects <- fread(file.path(getwd(), "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))

test <- cbind(testSubjects, testY, testX)


# Merge datasets

merged <- rbind(train, test)



#Step 5. Creation of a second tidy dataset

merged[["Activity"]] <- factor (merged[, Activity], levels = activityLabels [["classLabels"]], labels = activityLabels[["activityName"]])
merged[["SubjectNum"]] <- as.factor(merged[, SubjectNum])
merged <- reshape2::melt(data = merged, id = c("SubjectNum", "Activity"))
merged <- reshape2::dcast(data = merged, SubjectNum + Activity  ~ variable, fun.aggregate = mean)

data.table::fwrite(x = merged, file = "tidyData.txt", quote = FALSE)
