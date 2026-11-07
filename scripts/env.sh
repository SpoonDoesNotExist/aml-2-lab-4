#!/usr/bin/env bash
# Подключать через source из папки проекта.
# При стандартной установке yc находится в ~/yandex-cloud/bin.
if ! command -v yc >/dev/null 2>&1; then
  export PATH="$HOME/yandex-cloud/bin:$PATH"
fi
export YC_TOKEN="$(yc iam create-token)"
export YC_CLOUD_ID="$(yc config get cloud-id)"
export YC_FOLDER_ID="$(yc config get folder-id)"
# Не продолжать развёртывание с пустыми параметрами авторизации.
[[ -n "$YC_TOKEN" && -n "$YC_CLOUD_ID" && -n "$YC_FOLDER_ID" ]]
