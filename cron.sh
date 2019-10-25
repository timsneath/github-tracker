#!/bin/sh

STARSFILE=/tmp/repo-stars.$$.csv

/usr/lib/dart/bin/dart /usr/local/google/home/rischpater/Projects/Flutter/csells/github-tracker/repo-stars.dart --csv-output > ${STARSFILE}

python3 /usr/local/google/home/rischpater/Projects/Flutter/mine/python-sheets-uploader/python-sheets-uploader.py --spreadsheet_key='1kbl4iBLutedEhsJ6MjeVjTdr8mnP_MDVXqYvVBoTRgI' --csv_file=${STARSFILE} --credentials=/usr/local/google/home/rischpater/Projects/Flutter/mine/python-sheets-uploader/credentials.json
