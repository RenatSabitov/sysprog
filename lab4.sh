#!/bin/bash

# Функция для вывода помощи
show_help() {
  echo "Использование: $0 [-u | --users] [-p | --processes] [-h | --help] [-l PATH | --log PATH] [-e PATH | --errors PATH]"
  echo "  -u, --users       Вывести перечень пользователей и их домашних директорий."
  echo "  -p, --processes   Вывести перечень запущенных процессов."
  echo "  -h, --help        Вывести справку."
  echo "  -l PATH, --log PATH   Перенаправить вывод в файл по заданному пути."
  echo "  -e PATH, --errors PATH  Перенаправить вывод ошибок в файл."
  exit 0
}

# Функция для вывода пользователей
list_users() {
  if [[ -n $log_path ]]; then
    exec > "$log_path"
  fi

  getent passwd | awk -F: '{print $1 "\t" $6}' | sort
}

# Функция для вывода процессов
list_processes() {
  if [[ -n $log_path ]]; then
    exec > "$log_path"
  fi

  ps -eo pid,cmd --sort=pid
}

# Переменные для хранения параметров
log_path=""
error_path=""

# Обработка аргументов
while getopts ":uphl:e:-:" opt; do
  case $opt in
    u)
      action="users"
      ;;
    p)
      action="processes"
      ;;
    h)
      show_help
      ;;
    l)
      log_path="$OPTARG"
      ;;
    e)
      error_path="$OPTARG"
      ;;
    -)
      case "${OPTARG}" in
        users)
          action="users"
          ;;
        processes)
          action="processes"
          ;;
        help)
          show_help
          ;;
        log)
          log_path="${!OPTIND}"; OPTIND=$((OPTIND + 1))
          ;;
        errors)
          error_path="${!OPTIND}"; OPTIND=$((OPTIND + 1))
          ;;
        *)
          echo "Неизвестный параметр --${OPTARG}" >&2
          exit 1
          ;;
      esac
      ;;
    \?)
      echo "Неизвестный параметр -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Параметр -$OPTARG требует аргумент." >&2
      exit 1
      ;;
  esac
done

# Перенаправление ошибок
if [[ -n $error_path ]]; then
  exec 2> "$error_path"
fi

trap "echo 'КРИТИЧЕСКАЯ ОШИБКА' >&2" DEBUG

# Выполнение соответствующей функции
case $action in
  users)
    list_users
    ;;
  processes)
    list_processes
    ;;
  *)
    show_help
    ;;
esac
