#backend "s3"
terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "roomy-bucket-s3"
    region     = "ru-central1-a"
    key        = "states/terraform.tfstate"
    access_key = ""
    secret_key = ""

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
#Vm App Server windows server 2016 / 2vCPU, 4 RAM, External address (Public) и Internal address.
resource "yandex_compute_instance" "ws2016" {
  name     = "${terraform.workspace}-appserver"
  hostname = "ws2016"
  zone     = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = var.ws2016_img
      name        = "ws2016"
      type        = "network-nvme"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sn1.id
    nat       = true
#    nat_ip_address     = var.nat_ip_address
#    nat_ip_address     = yandex_vpc_address.ext_addr.external_ipv4_address[0].address
    ip_address = "192.168.1.20"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
#Vm DB Server Ubuntu Postgres/ 2vCPU, 4 RAM.
resource "yandex_compute_instance" "ubuntu_db" {
  name     = "${terraform.workspace}-dbserver"
  hostname = "ubuntudb"
  zone     = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu_db_img
      name        = "ubuntudb"
      type        = "network-nvme"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sn1.id
    nat       = true
#    nat_ip_address     = var.nat_ip_address
#    nat_ip_address     = yandex_vpc_address.ext_addr.external_ipv4_address[0].address
    ip_address = "192.168.1.30"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


#Vms "win1", "win2", "win3".
resource "yandex_compute_instance" "vms" {
  count    = local.win_count[terraform.workspace]
  name     = "${terraform.workspace}-${var.win[count.index]}"
  hostname = var.win[count.index]
  zone     = "ru-central1-a"

  resources {
    cores  = local.win_cores[terraform.workspace]
    memory = local.win_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.win10_img
      name        = var.win[count.index]
      type        = "network-hdd"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sn1.id
    ip_address         = var.win_ip_address[count.index]
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
#Vms "deb1", "deb2", "deb3".
resource "yandex_compute_instance" "vms_deb" {
  count    = local.ubuntu_count[terraform.workspace]
  name     = "${terraform.workspace}-${var.deb[count.index]}"
  hostname = var.deb[count.index]
  zone     = "ru-central1-a"

  resources {
    cores  = local.ubuntu_cores[terraform.workspace]
    memory = local.ubuntu_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu_host_img
      name        = var.deb[count.index]
      type        = "network-hdd"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sn1.id
    ip_address         = var.ubuntu_ip_address[count.index]
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
#VPC create
resource "yandex_vpc_network" "network-1" {
  folder_id   = var.yc_folder_id
  name = "network1"
  description = "network1"
}

resource "yandex_vpc_subnet" "sn1" {
  folder_id      = var.yc_folder_id
  name           = "sn1"
  description    = "subnet sn1 "
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  route_table_id = yandex_vpc_route_table.roomy-rt-a.id
  v4_cidr_blocks = ["192.168.1.0/24"]

  depends_on = [
    yandex_vpc_network.network-1
  ]
}
resource "yandex_vpc_subnet" "sn2" {
  folder_id      = var.yc_folder_id
  name           = "sn2"
  description    = "subnet sn2 "
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.2.0/24"]

  depends_on = [
    yandex_vpc_network.network-1
  ]
}
resource "yandex_vpc_subnet" "sn3" {
  folder_id      = var.yc_folder_id
  name           = "sn3"
  description    = "subnet sn3 "
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.3.0/24"]

  depends_on = [
    yandex_vpc_network.network-1
  ]
}
#Route table for internet for vms over nat instance (proxynginx)
resource "yandex_vpc_route_table" "roomy-rt-a" {
  network_id = "${yandex_vpc_network.network-1.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.1.100"
  }
}
#locals vars
locals {

  win_count = {
   dev = 3
   test  = 3
  }
  ubuntu_count = {
   dev = 2
   test  = 2
  }

  win_cores = {
    dev = 2
    test  = 2
  }
  win_memory = {
    dev = 2
    test  = 2
  }
  ubuntu_cores = {
    dev = 2
    test  = 2
  }
  ubuntu_memory = {
    dev = 2
    test  = 2
  }

}