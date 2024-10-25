#!/usr/bin/env bash

## Copyright Vitalii B. aka varrkan82
#
# Run "rate -h" to view usage instructions

if ! which jq &>/dev/null; then
  echo "Install 'jq' first. Exiting!"
  return 1
fi

usage() {
  cat << EOF
Usage:

rate [-h | --help] [-l | --list] [DATE] [CURRENCY_CODE]

  -l | --list - List available NBU currencies
  -h | --help - view this help

Default currency is USD.
Default date is current.

Use 'rate' to get USD rate to UAH on a current date,
  or use 'rate YYYYmmdd' to get USD rate to UAH on a exact date,
  or use 'rate CURRENCY_CODE' to get a rate for an exact currency on a current date,
  or 'rate YYYYmmdd CURRENCY_CODE' to get a rate for exact currency on exact date (CURRENCY_CODE is case insensitive and 3 letters long).
  See https://en.wikipedia.org/wiki/ISO_4217 (Not all of a codes are supported.)
EOF
}

rate() {
  if [[ $# -gt 2 ]]; then
    echo -e "WRONG number of arguments\n"
    usage
    return 1
  else
    case $1 in
      -l | --list)
        echo -e "List of supported currencies:\n"
        curl -s 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange\?valcode&json' | jq -r '.[] | "\(.cc) | \(.txt)"' | sort -k3 | column
        return 0
        ;;
      -h | --help)
        usage
        return 0
        ;;
      *)
        if [[ $# -eq 1 ]] && [[ $1 =~ [0-9]{8} ]]; then
          local DATE=$1
        elif [[ $# -eq 1 ]] && [[ $1 =~ [a-zA-Z]{3} ]]; then
          local DATE
          DATE=$(date +'%Y%m%d')
          local CURRENCY
          CURRENCY="$(echo $1 | tr '[:lower:]' '[:upper:]')"
        elif [[ $# -eq 1 ]] && [[ ${#1} -ne 3 ]] && [[ ${#1} -ne 8 ]]; then
          echo -e "\nWRONG lenght of a single argument.\n"
          usage
          return 1
        elif [[ $# -eq 2 ]]; then
          local DATE=$1
          local CURRENCY
          CURRENCY="$(echo $2 | tr '[:lower:]' '[:upper:]')"
        elif [[ $# -lt 1 ]]; then
          local RATE_DATE
          RATE_DATE="$(date +'%Y%m%d')"
          local CURR="USD"
        elif [[ ${#CURRENCY} -ne 3 ]]; then
          echo "WRONG Currency code! Use a correct one! Run 'rate -l' to list available codes."
          usage
          return 1
        elif [[ ${#DATE} -ne 8 ]]; then
          echo "WRONG date length! Use a correct one! Date should be pass as 'YYYYmmdd'."
          usage
          return 1
        else
          return 1
        fi
        local RATE_DATE="${DATE:=$(date +'%Y%m%d')}"
        local CURR="${CURRENCY:=USD}"
        ;;
    esac
  fi

  local JSONRATE
  JSONRATE=$(curl -s "https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?valcode=${CURR}&date=${RATE_DATE}&json")
  local JSONTEXT
  JSONTEXT=$( echo ${JSONRATE} | jq -r '.[].txt')
  if [[ $(echo "${JSONRATE}" | jq -r '.[].exchangedate') != $(date -d $RATE_DATE +'%d.%m.%Y') || ${CURR} != $(echo "${JSONRATE}" | jq -r '.[].cc') ]]; then
    echo "Wrong Date or no such Currency code!"
    usage
    return 1
  else
    echo -e "Курс $JSONTEXT до Української гривні на дату $(date -d $RATE_DATE +'%d.%m.%Y'):\n\t $(echo "${JSONRATE}" | jq -r '.[].rate' | tr "." ",") Гривень за ${JSONTEXT}\n"
    echo -e "$CURR to UAH rate at date $(date -d $RATE_DATE +'%d.%m.%Y'):\n\t $(echo "${JSONRATE}" | jq -r '.[].rate' | tr "." ",") UAH for ${CURR}"
  fi

}

rate "$@"

exit 0
