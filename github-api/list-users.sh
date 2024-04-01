#!/bin/bash


#########################################
# About:This script finds the users with read access to the repository
# Input: 1) Two command line arguments are required. Organization name, and Repo name
#        2) In linux terminal command use the following commands to hide username and token:
#               export username="repo_name_goes_here"
#               export token="token_value_goes_here"  
#
# Owner: Raja Khan
#
#########################################

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token

USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
# Using local variable ensure variable is only accessible inside the function and isn't global
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    # s is for silent and -u for authentication 
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
    # 
    # jq -r: The jq command is followed by the -r option, which stands for "raw output." 
    # This option tells jq to output raw strings, without JSON quotes, for easier use in scripts and command lines.
    #
    #.[]: This part tells jq to iterate over all elements of the root object, assuming it's an array. 
    # It's a shorthand for "take each item in the array."
    # 
    # select(.permissions.pull == true): The select function filters the input array elements based on a condition. 
    # Here, it filters for objects where the pull property inside the permissions object is true. 
    # In the context of GitHub API data, this means selecting users who have read access to the repository (since 
    # having "pull" access means you can read or clone the repository).
    #
    # .login: For each object that passes the select filter, jq extracts the value of the login property. 
    # In the GitHub API context, the login property typically contains the username of a user or organization.
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the list of collaborators on the repository
    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

    # Display the list of collaborators with read access
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

function helper {
    expected_cmd_args=2
    if [ $# -ne $expected_cmd_args ]; then
        echo "Please execute the script with required command arguments."
        echo "Example: ./list-users.sh REPO_OWNER REPO_NAME"
   exit 1     
    fi
}


# Main 

helper "$@"         # "$@" passes all the cmd line args to the helper function. Without it "$#" will be zero.
echo "Listing users with read access to ${REPOOWNER}/${REPO_NAME}..."
list_users_with_read_access