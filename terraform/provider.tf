provider "yandex" {
#  token     = var.yc_token
  service_account_key_file = "iam/key.json"
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}
