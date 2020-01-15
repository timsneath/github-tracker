#!/bin/sh

STARSFILE=/tmp/repo-stars.$$.csv
STARS_TO_IMPORT=/tmp/repo-stars-to-import.$$.csv

/usr/lib/dart/bin/dart /usr/local/google/home/rischpater/Projects/Code/github-tracker/repo-stars.dart -r --csv-output > ${STARSFILE}
sed '/.*flutter\/flutter.*/q' ${STARSFILE} > ${STARS_TO_IMPORT}
python3 /usr/local/google/home/rischpater/Projects/Code/python-sheets-uploader/python-sheets-uploader.py --spreadsheet_key='1aWLQMtn6dOwshV1VV2-cP700355AgMnDl0N4UDUG-uk' --csv_file=${STARSFILE} --credentials=/usr/local/google/home/rischpater/Projects/Code/python-sheets-uploader/credentials.json

rm ${STARSFILE}
rm ${STARS_TO_IMPORT}

