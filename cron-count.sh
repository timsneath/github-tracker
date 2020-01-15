#!/bin/sh

QUERY='is%3Aopen+is%3Aissue+-label%3Aframework+-label%3Aengine+-label%3Atool+-label%3Aplugin+-label%3Apackage+-label%3A%22will+need+additional+triage%22+-label%3A%22%E2%98%B8+platform-web%22+-label%3A%22a%3A+desktop%22+-label%3A%22team%3A+infra%22+-label%3A%22a%3A+existing-apps%22+sort%3Aupdated-asc+-label%3A%22waiting+for+customer+response%22+'
REPO='flutter/flutter'
COUNTFILE=/tmp/repo-count.$$.csv


/usr/lib/dart/bin/dart /usr/local/google/home/rischpater/Projects/Code/github-tracker/count-query-responses.dart --repo ${REPO} --query ${QUERY} > ${COUNTFILE}
python3 /usr/local/google/home/rischpater/Projects/Code/python-sheets-uploader/python-sheets-uploader.py --spreadsheet_key='1AgPZNFsy_qDeQCpGcY8zhBHBvVuJUGfuYsDsNr0AUqw' --csv_file=${COUNTFILE} --credentials=/usr/local/google/home/rischpater/Projects/Code/python-sheets-uploader/credentials.json

# rm ${COUNTFILE}

