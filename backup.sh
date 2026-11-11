#!/bin/bash

# This checks if the number of arguments is correct
# If the number of arguments is incorrect ( $# != 2) print error message and exit
if [[ $# != 2 ]]
then
  echo "backup.sh target_directory_name destination_directory_name"
  exit
fi

# This checks if argument 1 and argument 2 are valid directory paths
if [[ ! -d $1 ]] || [[ ! -d $2 ]]
then
  echo "Invalid directory path provided"
  exit
fi

# Store the arguments in variables.
targetDirectory=$1
destinationDirectory=$2

# Display the values of the two command line arguments in the terminal 
echo "Target directory: $targetDirectory"
echo "Destination directory: $destinationDirectory"

# Define a variable called currentTS as the current timestamp, expressed in seconds
currentTS=$(date +%s)

# Create a variable that contains the name of the compressed file
backupFileName="backup-${currentTS}.tar.gz"

# We're going to:
  # 1: Go into the target directory
  # 2: Create the backup file
  # 3: Move the backup file to the destination directory

# To make things easier, we will define some useful variables

# Define a variable called origAbsPath with the absolute path of the current directory as the variable's value
origAbsPath=$(pwd)

# Define a variable called destAbsPath whose value equals the absolute path of the destination directory
cd "$destinationDirectory" || exit
destDirAbsPath=$(pwd)

# Change directories from the current working directory to the target directory targetDirectory
cd "$origAbsPath" || exit
cd "$targetDirectory" || exit


#  Find files that have been updated within the past 24 hours

yesterdayTS=$(($currentTS - 24 * 60 * 60))

declare -a toBackup  # Declare a Bash array named toBackup

for file in *  # Iterate over all files and directories in the current folder
do
  if [[ `date -r "$file" +%s` -gt $yesterdayTS ]] # If The file's modification timestamp is greater than the timestamp from 24 hours ago (so the file was modified within the last 24 hours)
  then
    toBackup+=("$file") # Add the file to the toBackup array
  fi
done

# Compress and archive the files in the toBackup array into a single compressed file named backupFileName
tar -czvf "$backupFileName" "${toBackup[@]}"

# Move the compressed backup file to the destination directory
mv "$backupFileName" "$destDirAbsPath"

