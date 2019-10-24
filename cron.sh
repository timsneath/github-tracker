#!/bin/sh

STARSFILE=/tmp/repo-stars.$$.csv

/usr/lib/dart/bin/dart /usr/local/google/home/rischpater/Projects/Flutter/csells/github-tracker/repo-stars.dart --csv-output > ${STARSFILE}
