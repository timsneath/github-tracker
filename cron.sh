#!/bin/sh

STARSFILE=/tmp/repo-stars.$$.csv
STARS_TO_IMPORT=/tmp/repo-stars-to-import.$$.csv

/usr/lib/dart/bin/dart /usr/local/google/home/rischpater/Projects/Flutter/mine/github-tracker/repo-stars.dart --csv-output > ${STARSFILE}
sed '/.*flutter\/flutter.*/q' ${STARSFILE} > ${STARS_TO_IMPORT}
python3 /usr/local/google/home/rischpater/Projects/Flutter/mine/python-sheets-uploader/python-sheets-uploader.py --spreadsheet_key='1kbl4iBLutedEhsJ6MjeVjTdr8mnP_MDVXqYvVBoTRgI' --csv_file=${STARS_TO_IMPORT} --credentials=/usr/local/google/home/rischpater/Projects/Flutter/mine/python-sheets-uploader/credentials.json

rm ${STARSFILE}
rm ${STARS_TO_IMPORT}

