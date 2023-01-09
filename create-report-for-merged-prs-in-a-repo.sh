#!/bin/bash

# Generates a report in .csv format for all merged PRs for a repo
# This requires GitHub CLI: https://github.com/cli

# Set variables for org slug and date

org=ORG
date=2022-01-01

# Prompt for repo slug

if [ -z "$1" ]
  then
    echo "No repo slug supplied"
    exit 1
  else 
    echo "Fetching merged PRs for $org/$1"
    repo=$1
fi

# Set the headers for the .csv file

echo "Number,MergedAt,URL" > /tmp/merged-prs-for-${repo}.csv

queryString="is:merged repo:$org/$repo merged:>=${date}"

# Get a list of repos assigned to the team and their permissions using GraphQL API

query=$(gh api graphql -f query="query SearchMergedPrs {
  search(query: \"${queryString}\", type: ISSUE, first: 100) {
    edges {
      node {
        ... on PullRequest {
          number
          mergedAt
          url
        }
      }
    }
  }
  rateLimit {
    resetAt
    remaining
  }
}")

# Format the result and output to .csv file

echo $query | jq -r '.data.search.edges[] | [.node.number, .node.mergedAt, .node.url] | @csv' >> /tmp/merged-prs-for-${repo}.csv
