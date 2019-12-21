#!/bin/bash

## DATE
#DATE=`date -d "1 minute ago" "+%d %b %H:%M:%S"`

## Prod
#LOG=/usr/local/var/log/chinachu-operator.stdout.log

## Beta
LOG=log/chinachu-operator.stdout.log

## RECORDLOG
function record() {
  rec=`cat ${LOG} | grep "$DATE" | grep "RECORD"`
  echo $rec
  STATUS=`echo $rec | awk '{ print $5 }'`
  RECLOG=`cat ${LOG} | grep "RECORD" | sed -e 's/#\w{4}\s//' | head -n 1`
  CNT=`echo $RECLOG | wc -l`
  if [ -n $CNT ]; then
    COLOR="#dc143c"
    STATUS="RECORD"
    LOGS=$RECLOG
    slack
  fi
}

## FIN
function fin() {
  rec=`cat ${LOG} | grep "$DATE" | grep "FIN"`
  STATUS=`echo $rec | awk '{ print $5 }'`
  FINLOG=`cat ${LOG} | grep "FIN" | sed -e 's/#\w{4}\s//' | head -n 1`
  CNT=`echo $FINLOG | wc -l`
  if [ -n $CNT ]; then
    COLOR="good"
    STATUS="FIN"
    LOGS="$FINLOG"
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
