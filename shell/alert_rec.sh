#!/bin/bash

## DATE
#DATE=$(date -d "1 minute ago" "+%d %b %H:%M:%S")
#DATE=$(date -d "1 minute ago" "+%d %b %H:%M:%S")

## Prod
#LOG=/usr/local/var/log/chinachu-operator.stdout.log

## Beta
LOG=log/chinachu-operator.stdout.log

## RECORDLOG
function record() {

  while read i; do
    field2=$(echo ${i} | grep "RECORD" | awk '{print $2}')
    if [ -n "${field2}" ]; then
      echo ${field2}
    fi
  done
}
#tail -n 0 -F ${LOG} | record
#exit

## FIN
function fin() {
  rec=$(cat ${LOG} | grep "$DATE" | grep "FIN")
  STATUS=$(echo $rec | awk '{ print $5 }')
  FINLOG=$(cat ${LOG} | grep "$DATE" | grep "FIN" | sed -e 's/#\w{4}\s//' | tail -n 1)
  cnt=$(echo $FINLOG | wc -l)
  if [ $cnt -eq 1 ]; then
    COLOR="good"
    STATUS="FIN"
    LOGS=$FINLOG
    slack
  fi
}

function slack() {
  URL=$(cat .env | grep "SLACK_URL" | sed -e 's/SLACK_URL=//')

  json=$(
    cat <<EOS
  {
    "attachments": [
      {
        "fallback": "REC",
        "color": "${COLOR}",
        "title": "Chinachu Dashboard",
        "title_link": "http://192.168.2.100:20772/#!/dashboard/top/",
        "fields": [
          {
            "title": "ステータス",
            "value": "${STATUS}"
          },
          {
            "title": "ログ",
            "value": "${LOGS}"
          }
        ]
      }
    ]
  }
EOS
  )
  curl -X POST -H 'Content-type: application/json' -d "$json" "$URL"
}


fin
