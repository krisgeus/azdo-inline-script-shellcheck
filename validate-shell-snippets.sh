#!/bin/sh

# usage() {
#   echo "usage: ${BASH_SOURCE[0]} [-h|--help] [options] "
#   echo "  -h|--help                          display usage"
#   echo "  -s|--subscription subscription_id  GUID of the subscription to check"
#   echo "  -e|--environment environment       specify environment to use"
#   echo "  -t|--team team_name				 specify the name of the team"
#   exit 21
# }

# function read_arguments() {
#   while [[ $# -gt 0 ]]
#   do
#       key="${1}"
#       case ${key} in
#       -s|--subscription)
#           SUBSCRIPTION_ID="${2}"
#           shift # past argument
#           shift # past value
#           ;;
#       -e|--environment)
#           ENVIRONMENT="${2}"
#           shift # past argument
#           shift # past value
#           ;;
#       -t|--team)
#           TEAM_NAME="${2}"
#           shift # past argument
#           shift # past value
#           ;;
#       -h|--help)
#           usage
#           ;;
#       *)  # unknown option
#           echo "WARNING: Skipping unknown commandline argument: '${key}'"
#           shift # past argument
#           ;;
#       esac
#   done
# }

function main() {
  echo "$@"

  # if [ -z "$SUBSCRIPTION_ID" ]
  # then
  #   echo "SUBSCRIPTION is required. Please provide a valid subscription GUID"
  #   exit 22
  # fi
  # if [ -z "$ENVIRONMENT" ]
  # then
  #   echo "ENVIRONMENT is required. Please provide a valid environment (ddev, dprd or uprd)"
  #   exit 23
  # fi
  # if [ -z "$TEAM_NAME" ]
  # then
  #   echo "TEAM is required. Please provide a valid team name"
  #   exit 24
  # fi
  # terraform init
  # terraform plan -refresh-only -var="team_name=${TEAM_NAME}" -var="environment=${ENVIRONMENT}" -var="subscription_id=${SUBSCRIPTION_ID}"

  yq -r -0 ".steps[.task].inputs | select(.inlineScript) | .inlineScript" "$@" | \
    sed -e 's/---//g' | \
    xargs -0 -I{} sh -c 'echo "Checking bash script snippet $1"; echo "$1" | sed -r -e "s/\{\{[ ]?/\{/g" -e "s/[ ]?\}\}/\}/g"  | /bin/shellcheck -s bash -S warning -' sh {}
}

main "$@"

