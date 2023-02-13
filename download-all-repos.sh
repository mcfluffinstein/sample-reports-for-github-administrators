#!/bin/bash

# This script downloads a repo archive for all repos in an organization.
# Requires the GitHub CLI https://github.com/cli and JQ https://stedolan.github.io/jq/

# Paste your access token.
token=""

# If $1 is passed use as org
if [ -z "$1" ]
  then
    org=$org
  else
    org=$1
fi

# Set stamp variable

stamp=`date +%s`

# Get a list of repos in the org and save to a file.
mkdir tmp && touch tmp/repos.txt
gh api --paginate /orgs/${org}/repos | jq -r '.[].name' > tmp/repos.txt

# Loop for all the repos from the org-repos.txt file
while read -r repo; do
    echo 'Downloading archive for: '$repo'...'
    # Request to download the repo archive https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#download-a-repository-archive-zip.
    status_code=$(curl -s -o "tmp/${repo}-${stamp}.archive.zip" -w "%{http_code}" -H "Authorization: bearer $token" -LJO https://api.github.com/repos/$org/$repo/zipball)
    if [ $status_code -eq 200 ]; then
      echo "OK: Archive for $repo was successfully downloaded."
    elif [ $status_code -eq 404 ]; then
      echo "ERROR: $status_code archive for $repo was not found. Possibly empty?"
      rm "tmp/${repo}-${stamp}.archive.zip"
    else
      echo "ERROR: Archive for $repo failed with a $status_code status code."
      rm "tmp/${repo}-${stamp}.archive.zip"
    fi
    # Sleep to prevent rate limiting
    sleep 2
done < tmp/repos.txt

# Remove the temporary files
rm tmp/repos.txt

echo "Done!"
