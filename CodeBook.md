# Code book for the "Tidy Data" created from the original "Human Activity Recognition Using Smartphones" data set
Author: Ganesh Krishnamurthy

## Bibliographic citation:
This code book was adapted from the original code book that came with the Samsung data. The original code book is available in http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.names

**Source of original data**: 
Jorge L. Reyes-Ortiz(1,2), Davide Anguita(1), Alessandro Ghio(1), Luca Oneto(1) and Xavier Parra(2)
1 - Smartlab - Non-Linear Complex Systems Laboratory
DITEN - Università  degli Studi di Genova, Genoa (I-16145), Italy. 
2 - CETpD - Technical Research Centre for Dependency Care and Autonomous Living
Universitat Politècnica de Catalunya (BarcelonaTech). Vilanova i la Geltrú (08800), Spain
activityrecognition '@' smartlab.ws 

## Data Set Information of __Original__ Data:
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, the 3-axial linear acceleration and 3-axial angular velocity were captured at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually.  

## Processing applied to the original data:
- The train and test observations were combined together
- Information about the target variable (activity: Walking, Standing etc) and the subject/individual ID (30 participants) were added to the measurement dataset to create a single dataset
- Descriptive column names/labels have been provided where possible.
**The full set of processing applied to the original data is available in run_analysis.R and is explained in README.md**

## Summary variables calculated from original data:
- Of the 561 measurements for each subject in the original dataset, only the measurements corresponding to the MEAN and Standard Deviation were considered
- For *each* of these 66 measurements (35 means + 31 standard deviations = 66 measurements), the MEAN was calculated per subject per activity

## Data set information of the tidy data:
- There are 30 participants and each participant (subject_ID) was measured doing 6 activities (walking, walking upstairs, walking downstairs, sitting, standing, laying). So, there are 180 records/observation
- For participant and activity, the MEAN of each measurement was calculated. So, there are 66 mean measurements for each participant-activity combination
- The data is kept in the WIDE format

## Attribute information:
For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 66-feature vector with time and frequency domain variables. *Note: These are the MEANs of the measurements for each subject and each activity*
- Its activity label. 
- An identifier of the subject who carried out the experiment.

## Units:
- The units used for the accelerations (total and body) are 'g's (gravity of earth -> 9.80665 m/seg2).
- The gyroscope units are rad/seg.
- Features are normalized and bounded within [-1,1].