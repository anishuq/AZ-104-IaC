#!/bin/bash

az config set core.enable_broker_on_windows=false
#Disable the WAM broker on Windows to avoid issues with the 
#Azure CLI when running in a non-interactive environment.

# Check if already logged in
if ! az account show --output none 2>/dev/null; then
  echo "Not logged in. Starting device code login..."
  az login --use-device-code
  #opens the browser and prompts the user to enter a code to authenticate with Azure.
fi


az account set --subscription "ff62842a-5857-4d36-9ab5-4fe04c591ad2"

az account show --output table