#token
variable "yc_token" {

   default = ""
}

# ID облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yc_cloud_id" {
  default = "b1g33m4odcr440ndgbq4"
}

# Folder облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yc_folder_id" {
  default = "b1gc2ut4o44to2p9i1j3"
}

# ID образа
# ID compute image list
variable "ubuntu_db_img" {
  default = "fd80d7fnvf399b1c207j"
}
variable "ubuntu_host_img" {
  default = "fd80d7fnvf399b1c207j"
}
variable "ws2016_img" {
  default = "fd8pp7jr22omin7783hg"
}
variable "win10_img" {
  default = "fd8oau3n808ngsvtfi4q"
}
variable "win" {
  type = list(string)
  default = ["win1", "win2", "win3"]
}
variable "deb" {
  type = list(string)
  default = ["deb1", "deb2"]
}

# IP address should be already reserved in web UI
# IP address should be already reserved in web UI
variable "nat_ip_address" {
  description = "Public IP address for instance to access the internet over NAT"
  type        = string
  default     = ""
}

/*variable "ip_address" {
  description = "The private IP address to assign to the instance. If empty, the address will be automatically assigned from the specified subnet"
  type        = string
  default     = ""
}*/
variable "win_ip_address" {
  type = list(string)
  default = ["192.168.1.3", "192.168.1.4", "192.168.1.5"]
}
variable "ubuntu_ip_address" {
  type = list(string)
  default = ["192.168.1.6", "192.168.1.7", "192.168.1.8"]
}