# README:
This document explains the processing steps performed on the Samsung accelerometer data by run_analysis.R. The "train", "test" data folders and the features.txt, activity_labels.txt files need to be in the same folder as run_analysis.R. 

#### **Initialization**: The analysis requires the following packages to be loaded: dplyr, reshape2 and sqldf

## Step 1: Reading-in the train and test data
_Note: The processing steps are exactly similar for reading both the train and test data - except for the directory name. Only the "train" processing is explained *in detail* below.

7,352 records from X_train.txt is read in without column headers and the column headers are then applied by reading-in the features.txt file. 
For each record, there are 561 columns of measurement data. The activity ID (values of 1 through 6) for each measurement record is read from y_train.txt. Finally, the individual/subject ID
corresponding to each record is read from the subject_train.txt file. This provides with 7,352 records and 563 columns (561 measurements + activity ID + subject ID).

**In a similar fashion, the "test" measurements, activity ID and subject ID are read in from 3 files in the "test" folder.**
The test data frame provides 2,947 measurement records and 563 columns (561 measurements + activity_ID + subject_ID).

The train and test datasets have the same column order/structure and are combined together using a rbind() operation. This provides a total of 10,299 records.

## Handling duplicate column names:
An analysis of the 561 measurement column names (using identifying which column names occur more than once) reveals that there are 42 measurements that occur thrice. Using the check.names=TRUE
feature, all column names are brought to a better readable form and also the duplication issue is resolved by giving duplicate columns different serial numbers.

## Step 2: Only keeping measurements of mean() and standard deviation()
Using the 'contains' search feature, only the column names containing the "mean()" or "std()" strings are kept and the rest of the measurements are discarded. This leaves us with 66 measurement columns,
an subject ID, an activity_ID and 10,299 records

## Step 3: Providing descriptive names for activity_ID:
The activity_labels.txt file is read in and is merged with the data frame available from step 2. The activity ID is used as the common field for the merge.

## Step 4: Labeling the columns with descriptive variable names:
By reading the codebook (UCI HAR Dataset.names) accompanying the Samsung data and from the Human Activity Recognition website, identified proper descriptive strings to use.
Replaced (starting) "t" with Triaxial, (starting) "f" with Frequency, "Acc" with acceleration, "Gyro" with gyroscope, "Mag" with Magnitude and finally "std" with StdDev.

## Step 5: Calculating the mean of each measurement for each activity and each subject
Starting out with a WIDE dataset containing 66 measurement columns, the "melt" function is used to convert this to a LONG form. To this long form, a group_by and
summarize() functions are applied to calculate the mean for each measurement for each activity and each subject.

Finally, the data frame is converted back to a WIDE format with 180 records (30 subjects * 6 activities = 180) and 66 measurement mean variables. This final dataset is written out to a .txt file (Tidy_Output.txt).






 
