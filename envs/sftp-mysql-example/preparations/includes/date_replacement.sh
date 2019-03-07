#!/usr/bin/env bash

function obtain_date() {
  schedule=$1
  nr_of_prev_iters=$2
  date_format=$3

  get_prev="iter.get_prev(datetime);"

  prev_iters=""
  for (( i=0; i<$nr_of_prev_iters; i++)); do
    prev_iters="$prev_iters$get_prev"
  done

  echo "from croniter import croniter; \
        from datetime import date, datetime; \
        iter = croniter('${schedule}', datetime.now()); \
        ${prev_iters} \
        print(iter.get_prev(datetime).strftime('${date_format}'))"
}

function replace_date() {
  f=$1
  TODAY_FILE=$(echo $f | sed -e "s/#today#/$DATE_TODAY/g")
  TODAY_NODASH_FILE=$(echo $f | sed -e "s/#today_nodash#/$DATE_TODAY_NODASH/g")
  YESTERDAY_FILE=$(echo $f | sed -e "s/#yesterday#/$DATE_YESTERDAY/g")
  YESTERDAY_NODASH_FILE=$(echo $f | sed -e "s/#yesterday_nodash#/$DATE_YESTERDAY_NODASH/g")
  TOMORROW_FILE=$(echo $f | sed -e "s/#tomorrow#/$DATE_TOMORROW/g")
  TOMORROW_NODASH_FILE=$(echo $f | sed -e "s/#tomorrow_nodash#/$DATE_TOMORROW_NODASH/g")
  PREV_MONTH_FILE=$(echo $f | sed -e "s/#prev_month_dash#/$PREV_MONTH/g")
  PREV_MONTH_NODASH_FILE=$(echo $f | sed -e "s/#prev_month_nodash#/$PREV_MONTH_NODASH/g")
  DS_FILE=$(echo $f | sed -e "s/#ds#/$DS/g")
  DS_NODASH_FILE=$(echo $f | sed -e "s/#ds_nodash#/$DS_NODASH/g")
  PREV_EXECUTION_FILE=$(echo $f | sed -e "s/#prev_execution#/$PREV_EXECUTION_DATE/g")
  PREV_EXECUTION_NODASH_FILE=$(echo $f | sed -e "s/#prev_execution_nodash#/$PREV_EXECUTION_DATE_NODASH/g")
  NEXT_EXECUTION_FILE=$(echo $f | sed -e "s/#next_execution#/$NEXT_EXECUTION_DATE/g")
  NEXT_EXECUTION_NODASH_FILE=$(echo $f | sed -e "s/#next_execution_nodash#/$NEXT_EXECUTION_DATE_NODASH/g")

  RENAMES="$TODAY_FILE $TODAY_NODASH_FILE $YESTERDAY_FILE $YESTERDAY_NODASH_FILE \
           $TOMORROW_FILE $TOMORROW_NODASH_FILE $DS_FILE $DS_NODASH_FILE $PREV_MONTH_FILE \
           $PREV_MONTH_NODASH_FILE $PREV_EXECUTION_NODASH_FILE \
           $NEXT_EXECUTION_FILE $NEXT_EXECUTION_NODASH_FILE"

  echo $RENAMES
}

SCHEDULE=$(grep -oP "schedule_interval=\K[^,]*" /usr/local/airflow/dags/*/*.py | head -n1 | sed -e "s/['\"]//g")

# Change Airflow schedule annotations to crontab schedule values
if [[ ${SCHEDULE} == *"@"* ]]; then
  if [[ ${SCHEDULE} == "@hourly" ]]; then
      SCHEDULE='0 * * * *'
  elif [[ ${SCHEDULE} == "@daily" ]]; then
      SCHEDULE='0 0 * * *'
  elif [[ ${SCHEDULE} == "@weekly" ]]; then
      SCHEDULE='0 0 * * 0'
  elif [[ ${SCHEDULE} == "@monthly" ]]; then
      SCHEDULE='0 0 1 * *'
  elif [[ ${SCHEDULE} == "@yearly" ]]; then
      SCHEDULE='0 0 1 1 *'
  elif [[ ${SCHEDULE} == "@once" ]]; then
      SCHEDULE='0 0 * * *'
  fi
fi

DATE_TODAY=$(date +%Y-%m-%d)
DATE_TODAY_NODASH=$(date +%Y%m%d)
DATE_YESTERDAY=$(date --date="yesterday" +%Y-%m-%d)
DATE_YESTERDAY_NODASH=$(date --date="yesterday" +%Y%m%d)
DATE_TOMORROW=$(date --date="tomorrow" +%Y-%m-%d)
DATE_TOMORROW_NODASH=$(date --date="tomorrow" +%Y%m%d)
PREV_MONTH=$(date --date="1 month ago" +%Y-%m)
PREV_MONTH_NODASH=$(date --date="1 month ago" +%Y%m)

# Most recent execution date can be determined by getting previous iteration (previous schedule date)
# of the most recent (previous) iteration of the cron schedule
DS=$(python -c "$(obtain_date "${SCHEDULE}" 1 '%Y-%m-%d')")
DS_NODASH=$(python -c "$(obtain_date "${SCHEDULE}" 1 '%Y%m%d')")

PREV_EXECUTION_DATE=$(python -c "$(obtain_date "${SCHEDULE}" 2 '%Y-%m-%d')")
PREV_EXECUTION_DATE_NODASH=$(python -c "$(obtain_date "${SCHEDULE}" 2 '%Y%m%d')")

# Most recent run date can be determined by getting the most recent (previous) iteration of the cron schedule
NEXT_EXECUTION_DATE=$(python -c "$(obtain_date "${SCHEDULE}" 0 '%Y-%m-%d')")
NEXT_EXECUTION_DATE_NODASH=$(python -c "$(obtain_date "${SCHEDULE}" 0 '%Y%m%d')")
