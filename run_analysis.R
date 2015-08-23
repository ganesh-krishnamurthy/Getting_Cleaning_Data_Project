#########################################################################################
## run_analysis.R - This script is the project submission for Coursera/Johns Hopkins   ##
## "Getting and Cleaning Data". All the steps taken to manipulate the data are clearly ##
## defined in steps. ##
## Author: Ganesh Krishnamurthy ##
## Creation date: 08/19/2015 ##
#########################################################################################

#####################################################
## Step 0: Initialize the environment ##
#####################################################

## Load necessary packages
library(dplyr); library(reshape2); library(sqldf)

####################################################
## Step 1.A: Load the training data into a data frame. Apply variables names, get the activity ID and ##
## also the subject ID for each measurement record. Output of this step is the "train" dataframe ##
####################################################

## Load the records in X_train: This is a file without header record
train<-read.table("./train/X_train.txt", header=FALSE)
dim(train) # 7,352 records and 561 columns
head(train[,1:10])

## Load the variable (column) names for each measurement from the "Features" file
features_DF<-read.table("features.txt", header=FALSE, stringsAsFactors = FALSE) ## Initially load to a data frame
dim(features_DF) ## 561 records and 2 columns
## Assign column names of train using the V2 column of the features data frame
names(train)<-features_DF$V2

## Load the corresponding target/Y/"Activity" (codes for Walking, standing, sitting etc)
## from Y_train
train_Y<-read.table("./train/y_train.txt", header=FALSE)
dim(train_Y) # 7,352 records and 1 column
## Assign a column name to the activity
train_Y<-rename(train_Y, Activity_ID=V1)

## Load the Subject/Person_ID of the individual observed/measured for each record
train_subject<-read.table("./train/subject_train.txt", header=FALSE)
dim(train_subject) # 7,352 records and 1 column
## Assign a variable name for the person identifier
train_subject<-rename(train_subject, Subject_ID=V1)

## Put together (i.e., column-bind) the measurements, the activity and the subject_ID
train<-cbind(train_subject, train_Y, train)
dim(train) ## 7,352 records and 563 columns (561 measurements + subjectID + activityID)

############################################################
## Step 1.B: Prepare the TEST dataframe using the same processing steps as used ##
## in creating the TRAIN (step 1 - above). ##
############################################################

test<-read.table("./test/X_test.txt", header=FALSE)
dim(test) # 2,947 records and 561 columns
head(test[,1:10])
names(test)<-features_DF$V2

## Load the corresponding target/Y/"Activity" (codes for Walking, standing, sitting etc)
## from y_test.txt
test_Y<-read.table("./test/y_test.txt", header=FALSE)
dim(test_Y) # 2,947 records and 1 column
test_Y<-rename(test_Y, Activity_ID=V1)

## Load the Subject/Person_ID of the individual observed/measured for each record
test_subject<-read.table("./test/subject_test.txt", header=FALSE)
dim(test_subject) # 2,947 records and 1 column
test_subject<-rename(test_subject, Subject_ID=V1)

## Put together (i.e., column-bind) the measurements, the activity and the subject_ID
test<-cbind(test_subject, test_Y, test)
dim(test) ## 2,947 records and 563 columns (561 measurements + subjectID + activityID)

#########################################################
## Step 1.C: Stack the TRAIN and TEST datasets together ##
#########################################################
together_DF<-rbind(train, test)
dim(together_DF) ## 10,299 records and 563 columns

##########################################################
## Handle duplicate column names: There are 42 column names that repeat 3 ##
## times each. This is a sign of bad column naming convention. Using the check.names ##
## option to create distinct and acceptable (removes paranthesis and ",") column names. ##
##########################################################

## Investigation of duplicate columns
sqldf('select V2, count(*) from features_DF group by V2 having count(*) > 1')

## Convert to acceptable column names 
together_DF<-data.frame(together_DF, check.names = TRUE)

########################################################
## Step 2: Identify columns containing mean() and std() ##
## for measurements and only extract such columns ##
########################################################
mean_std_DF<-select(together_DF, Subject_ID, Activity_ID, contains(".mean."), contains(".std."))
dim(mean_std_DF) ## 10,299 records and 68 columns (2 ID + 66 mean/std measurements)

###########################################################
## Step 3: Providing descriptive names for the Activity_ID ##
###########################################################

## Read in the Activity_Labels.txt file
activity_labels<-read.table("activity_labels.txt", header=FALSE, stringsAsFactors = FALSE)
dim(activity_labels) ## 6 records and 2 columns
names(activity_labels)<-c("Activity_ID", "Activity")

## Merge the activity label with the Activity_ID column of the measurement dataframe mean_std_DF
mean_std_DF<-merge(activity_labels, mean_std_DF, by.x="Activity_ID", by.y="Activity_ID")
## Drop the Activity_ID column going forward
mean_std_DF<-select(mean_std_DF, -Activity_ID)

############################################################
## Step 4: Labeling the columns with descriptive variable names ##
############################################################

## Names starting with "t" are replaced with "Triaxial". Starting with "f" are replaced with #
## "Frequency". The word "Acc" is replaced with "Acceleration". The word "Gyro" is replaced
## with "Gyroscope". The word "Mag" is replaced with "Magnitude". Finally ".std." is
## replaced with ".StdDev."
names(mean_std_DF)<-gsub("^t","Triaxial", names(mean_std_DF))
names(mean_std_DF)<-gsub("^f","Frequency", names(mean_std_DF))
names(mean_std_DF)<-gsub("Acc","Acceleration", names(mean_std_DF))
names(mean_std_DF)<-gsub("Gyro","Gyroscope", names(mean_std_DF))
names(mean_std_DF)<-gsub("Mag","Magnitude", names(mean_std_DF))
names(mean_std_DF)<-gsub(".std.",".StdDev.", names(mean_std_DF))

#############################################################
## Step 5: Calculating the average of each variable for each activity and each subject. ##
## Create a output tidy dataset and write to a .txt file. ##
#############################################################

## Currently there are 30 subjects (rows), 6 activities (rows) with 66 measurements (columns). Reshape the
## dataset to contain 30 subjects (rows),  6 activities (rows) and 66 measurements (rows) and measurement_value (1 column).
## This reshaping is done for convenience in a upcoming group_by-summarize statement for calculating
## the mean of each column
rshp_DF<-melt(mean_std_DF, id=c("Subject_ID", "Activity"), measure.vars=3:68, na.rm=TRUE)
dim(rshp_DF) ## 679,734 records and 4 columns
## Give a proper name to the measurement column
names(rshp_DF)[3]<-"Measurement_Type"

## Group by subject_ID, activity and measurement_Type
rshp_DF_grp<-group_by(rshp_DF, Subject_ID, Activity, Measurement_Type)

## Calculate the mean of each measurement for each activity and subject
final_mean_DF<-summarize(rshp_DF_grp, Mean_val=mean(value, na.rm=TRUE))
dim(final_mean_DF) ## 11,880 records and 4 columns

## Cast back to a wide frame for the output dataset
output_tidy_DF<-dcast(final_mean_DF, Subject_ID + Activity ~ Measurement_Type, value.var="Mean_val")
dim(output_tidy_DF) ## 180 (30 subjects * 6 activities) records and 68 columns (Subject ID, Activity and 66 mean measurements)

## Write out a .txt file and suppressing the row names
write.table(output_tidy_DF, file="Tidy_Output.txt", row.names=FALSE)

## Check the contents of the file that was written to make sure it is readable back in by R
output_check<-read.table("Tidy_Output.txt", header=TRUE)
dim(output_check) ## 180 records and 68 columns - as expected. Passed the check.
