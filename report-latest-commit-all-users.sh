#!/bin/bash

# This script generates a report for the latest commits for all users in an organization.
# Requires the GitHub CLI: https://github.com/cli/cli

# If $1 is passed use as org
if [ -z "$1" ]
  then
    org=$org
  else
    org=$1
fi

# Write the headers to the CSV file
echo "Organization,Username,Latest Commit SHA,Date" > results.csv

# Get a list of org members and repos. Save to files.
gh api --paginate /orgs/${org}/members| jq '.[].login' >> tmp/members-list.txt

# Read the members list and make a request for each member
while read -r member; do
    # Make a GET request to the GitHub API to get the latest commit by the member
    result=$(gh api -X GET --paginate search/commits -f q="author:$member sort:author-date" | jq '.items[0]')
    # Get the commit sha
    sha=$(echo $result | jq '.sha')
    date=$(echo $result | jq '.commit.author.date')
    url=$(echo $result | jq '.html_url')
    # Print the result
    # if commits has a value print to results.csv
    if [ -z "$result" ]
      then
        echo "$org,$member,N/A,N/A,N/A" >> results.csv
      else
        echo "$org,$member,$sha,$url,$date" >> results.csv
    fi
    # sleep to prevent rate limiting
    sleep 1
done < tmp/members-list.txt

# Remove the temporary files
rm tmp/members-list.txt

echo "Done!"
