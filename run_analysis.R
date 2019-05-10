path = getwd()
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url , file.path(path , "datafiles.zip"))
unzip(zipfile = "datafiles.zip")


activitylabels <- fread("UCI HAR Dataset/activity_labels.txt",col.names = c("labels" , "activityname"))
features <- fread("UCI HAR Dataset/features.txt",col.names = c("index" , "featurename"))
Wanted <- grep("(mean|std)\\(\\)", features[, featurename])


measures <- features[Wanted , featurename]
measures <- gsub("[()]" , "" , measures)


                     
train <- fread("UCI HAR Dataset/train/X_train.txt")[, Wanted, with = FALSE]
data.table::setnames(train, colnames(train), measures)
trainActivities <- fread("UCI HAR Dataset/train/y_train.txt" , col.names = c("Activity"))
trainSubjects <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)
                       


test <- fread("UCI HAR Dataset/test/X_test.txt")[,Wanted , with = FALSE]
data.table::setnames(test , colnames(test) , measures)
testActivities <- fread("UCI HAR Dataset/test/y_test.txt",col.names = c("Activity"))
testSubjects <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)
                     

mergedata <- rbind(train , test)


mergedata[["Activity"]] <- factor(mergedata[, Activity]
                                 , levels = activitylabels[["labels"]]
                                 , labels = activitylabels[["activityname"]])

mergedata[["SubjectNum"]] <- as.factor(mergedata[, SubjectNum])
mergedata <- reshape2::melt(mergedata, id = c("SubjectNum", "Activity"))
mergedata <- reshape2::dcast(mergedata , SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = mergedata , file = "tidyData.txt", quote = FALSE)
