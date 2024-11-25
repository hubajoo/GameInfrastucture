#!/bin/bash

  printf "Verifying dependencies...\n"

  # Check if terraform is installed
  if ! command -v terraform &> /dev/null; then
    printf "Error: Terraform is not installed. Please install Terraform."
    exit 1
  fi

  # Check if kubectl is installed
  if ! command -v kubectl &> /dev/null; then
    printf "Error: kubectl is not installed. Please install kubectl."
    exit 1
  fi

  # Check if aws is installed
  if ! command -v aws &> /dev/null; then
    printf "Error: AWS CLI is not installed. Please install AWS CLI."
    exit 1
  fi

  # Check if base64 is installed
  if ! command -v base64 &> /dev/null; then
    printf "Error: base64 is not installed. Please install base64."
    exit 1
  fi

  # Check if the AWS CLI is logged in
  if ! aws sts get-caller-identity &> /dev/null; then
    printf "Error: AWS CLI is not logged in. Please configure your AWS credentials."
    exit 1
  fi

  printf "Dependencies verified.\n"