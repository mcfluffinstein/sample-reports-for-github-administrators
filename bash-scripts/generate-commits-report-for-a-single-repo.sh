#!/bin/bash

# If user passes argument $1 use that as the repo name
if [ -z "$1" ]
  then
    org=$org
  else
    org=$1
fi

# If user passes argument $2 use that as the org
if [ -z "$2" ]
  then
    repo=$repo
  else
    repo=$2
fi

# First, let's set the variables for the organization and repository if $1 and $2 are not passed
ORG=github
REPO=github

# Paste an access token with sufficient permissions (admin:org)
GITHUB_TOKEN=

# We'll then set the headers for the CSV file
echo "Author,Email,Date,Committer,Committer Email,Committer Date,Message,HTML_URL,Comment Count,Verification reason" > output.csv

# Finally, we'll make an API request to retrieve the commits for the repository
gh api --paginate -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GITHUB_TOKEN}" /repos/${ORG}/${REPO}/commits |

# Use jq to extract the specified values from the JSON response and create a CSV file
jq -r '.[] | [.commit.author.name, .commit.author.email, .commit.author.date, .commit.committer.name, .commit.committer.email, .commit.committer.date, .commit.message, .html_url, .commit.comment_count, .commit.verification.reason] | @csv' >> output.csv
