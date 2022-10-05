#!/bin/bash -
################################################################################
# Description:
#     Create managed app zip file
#
# Usage:
#
#     - Log in to Azure using the Azure CLI and set subscription
#     - bash ./azure/forecasting/script-dev/package_managed_app_zip.sh
#           Args:
#               <zip file name>: name of the zip file to place package (optional)
#                   default: managedapp.zip

################################################################################

ROOT=$(dirname $(dirname $(realpath $0)) )
APP_CONTENTS=${ROOT}/app_contents
ORIG_PWD=$(pwd)
echo "ROOT: ${ROOT}"
echo "APP_CONTENTS: ${APP_CONTENTS}" 
echo "ORIG_PWD: ${ORIG_PWD}"

managed_app_zip="$1"

if [[ -z $managed_app_zip ]]; then
    managed_app_zip=managedapp.zip
fi

cd "${APP_CONTENTS}"

zip -r "${managed_app_zip}" \
    "mainTemplate.json" \
    "viewDefinition.json" \
    "createUiDefinition.json"

mv "${managed_app_zip}" "${ROOT}/${managed_app_zip}"

cd ${ORIG_PWD}
