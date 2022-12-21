#!/bin/bash

# If user passes argument $1 use that as the repo name
if [ -z "$1" ]
  then
    repo=$repo
  else
    repo=$1
fi

# First, let's set the variables for the organization, repository, and access token
ORG=
REPO=
GITHUB_TOKEN=

# We'll then set the headers for the CSV file
echo "Author,Email,Date,Committer,Committer Email,Committer Date,Message,HTML_URL,Comment Count,Verification reason" > output.csv

# Finally, we'll make an API request to retrieve the commits for the repository
curl \
     -H "Accept: application/vnd.github.v3+json" \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     https://api.github.com/repos/${ORG}/${REPO}/commits |

# Use jq to extract the specified values from the JSON response and create a CSV file
jq -r '.[] | [.commit.author.name, .commit.author.email, .commit.author.date, .commit.committer.name, .commit.committer.email, .commit.committer.date, .commit.message, .html_url, .commit.comment_count, .commit.verification.reason] | @csv' >> output.csv
