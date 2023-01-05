#!/bin/bash

# Generates a report in .csv format of the permissions of all repositories assigned to a team
# This requires GitHub CLI: https://github.com/cli

# Check that user passed org slug and team slug as arguments

if [ -z "$1" ] || [ -z "$2" ]
  then
    echo "Error: Please enter a org slug as argument 1 and an team slug as argument 2."
    echo "Example: ./graphql-repo-permissions-report.sh org-a team-a"
    exit
fi

# Set variables for org slug and team slug

org=$1
team=$2

# Set the headers for the .csv file

echo "Organization,Repository,Permission" > /tmp/repo-permissions-report-team-${team}.csv

# Get a list of repos assigned to the team and their permissions using GraphQL API

query=$(gh api graphql --paginate -f query="query {
  organization(login: \"${org}\") {
    team(slug: \"${team}\") {
      name
      repositories(first: 100) {
        edges {
          permission
          node {
            name
          }
        }
      }
    }
  }
}")

# Format the result and output to .csv file

echo $query | jq -r '.data.organization.team.repositories.edges[] | [.permission, .node.name] | @csv' | awk -F "," -v ORG="$org" '{print ORG "," $2 "," $1}' >> /tmp/repo-permissions-report-team-${team}.csv
