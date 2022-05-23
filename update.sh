#!/usr/bin/env bash

PATH_TO_SUPERVISOR_CONFIGURATIONS='/etc/supervisor/conf.d/'
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/supervisor/"
IS_UPDATED=0

#add new config files
cd $CURRENT_DIR &&
  for file in *.conf; do
    if [[ -f "$file" ]]; then
      if [[ -f ${PATH_TO_SUPERVISOR_CONFIGURATIONS}${file} ]] && [[ -z "$(diff -q ${PATH_TO_SUPERVISOR_CONFIGURATIONS}${file} ${CURRENT_DIR}${file})" ]]; then
        echo "File exist and was not modified : ${CURRENT_DIR}${file}"
      else
        cp "${CURRENT_DIR}${file}" "${PATH_TO_SUPERVISOR_CONFIGURATIONS}${file}"
        echo "File was changed : ${CURRENT_DIR}${file}"
        IS_UPDATED=1
      fi
    fi
  done

#delete old config files
cd $PATH_TO_SUPERVISOR_CONFIGURATIONS &&
  for file in *.conf; do
    if [[ -f "$file" ]]; then
      if [[ ! -f ${CURRENT_DIR}${file} ]]; then
        echo "This file are deprecated and will deleted :" "${PATH_TO_SUPERVISOR_CONFIGURATIONS}${file}"
        rm "${PATH_TO_SUPERVISOR_CONFIGURATIONS}${file}"
        IS_UPDATED=1
      fi
    fi
  done

# Reload supervisor configuration when was some changes
if [[ ${IS_UPDATED} == 1 ]]; then
  echo "Reload supervisor configuration"
  sudo service supervisor reload
fi