#!/bin/bash
aws_account="$1"
report_date="$(date +%Y-%m-%d)"
input_dir="/tmp/"
input_file=$report_date"-IAMUserReport.csv"
access_key_file=$report_date"-accessKeysReport.csv"
output_file=$report_date"-IAMUserReport-cleaned.csv"

# Generate IAM credential report
aws iam generate-credential-report --profile $aws_account

# Download report to local CSV file
aws iam get-credential-report --profile devops --output text --query Content | base64 -d > test.csv

# Refresh report if generated on the same day
> $input_dir$input_file

# Set "," as the field separator using $IFS. Reads a csv file of IAM user names and appends the csv with corresponding access key ID
while IFS=',' read -r iamUser delim
do
  aws iam list-access-keys --profile $aws_account --user-name "$iamUser" | jq '.AccessKeyMetadata[].AccessKeyId'| sed s/'"'// | sed s/'"'// | haste |paste -sd ',' >> $input_dir$input_file
done < "$input_dir$output_file"

paste -d , $input_dir$input_file $input_dir$accessKeyFile > $inputDir$outPutFile
