#!/bin/bash

  # Define colors for the output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


  printf "Verifying dependencies...\n"

  # Check if terraform is installed
  if ! command -v terraform &> /dev/null; then
    printf "${RED}Error: Terraform is not installed. Please install Terraform. ${NC}\n"
    exit 1
  fi

  # Check if kubectl is installed
  if ! command -v kubectl &> /dev/null; then
    printf "${RED}Error: kubectl is not installed. Please install kubectl.${NC}\n"
    exit 1
  fi

  # Check if aws is installed
  if ! command -v aws &> /dev/null; then
    printf "${RED}Error: AWS CLI is not installed. Please install AWS CLI.${NC}\n"
    exit 1
  fi

  # Check if the AWS CLI is logged in
  if ! aws sts get-caller-identity &> /dev/null; then
    printf "${RED}Error: AWS CLI is not logged in. Please configure your AWS credentials.${NC}\n"
    exit 1
  fi

  printf "${GREEN}Dependencies verified.${NC}\n"