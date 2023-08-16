#!/bin/bash
# Script to fetch commit data for a specific user in a repository.

# Define variables
org=mcfluffs-sandbox
repo=testrepo
username=mcfluffinstein
output_file="${username}-commits-in-${repo}.csv"

# Check if gh command is installed
if ! command -v gh &> /dev/null
then
    echo "gh command not found. Please install it before running this script."
    exit 1
fi

# Parse command line arguments
if [ $# -eq 3 ]
then
    org=$1
    repo=$2
    username=$3
else
    echo "Usage: $0 <org> <repo> <username>"
    exit 1
fi

# Calculate the date 3 months ago in this format YYYY-MM-DD
date=$(date -v-3m +%Y-%m-%d)

# Set headers of CSV file
echo "Author,Email,Date,Committer,Committer Email,Message" > "$output_file"

# Retrieve the commits for the repository using the gh command
gh api -X GET search/commits -f q="repo:${org}/${repo} author:${username} author-date:>${date}" | \

# Use JQ to parse the JSON response and write the results to a CSV file
jq -r '.items[] | [.author.login, .commit.author.email, .commit.author.date, .commit.committer.name, .commit.committer.email, .commit.message] | @csv' >> "$output_file"
