# Output for ws2016
output "internal_ip_address_ws2016" {
 value = yandex_compute_instance.ws2016.network_interface.0.ip_address
 description = "internal_ip_address for ws2016"
}
output "external_ip_address_ws2016" {
   value = yandex_compute_instance.ws2016.network_interface.0.nat_ip_address
   description = "external_ip_address for ws2016"
}
output "yandex_vpc_subnet" {
  value       = yandex_vpc_network.network-1.id
  description = "Идентификатор подсети в которой создан инстанс"
}
output "fqdn" {
  description = "The fully qualified DNS name of this instance"
  value       = yandex_compute_instance.ws2016.*.fqdn
}
output "yandex_zone" {
  value       = yandex_compute_instance.ws2016.zone
  description = "region"
}
# Output for ubuntu_db
output "internal_ip_address_ubuntu_db" {
 value = yandex_compute_instance.ubuntu_db.network_interface.0.ip_address
 description = "internal_ip_address for ubuntu_db"
}
output "external_ip_address_ubuntu_db" {
   value = yandex_compute_instance.ubuntu_db.network_interface.0.nat_ip_address
   description = "external_ip_address for ubuntu_db"
}

output "fqdn_ubuntu_db" {
  description = "The fully qualified DNS name of this instance"
  value       = yandex_compute_instance.ubuntu_db.*.fqdn
}
output "yandex_zone_ubuntu_db" {
  value       = yandex_compute_instance.ubuntu_db.zone
  description = "region"
}


# internal addresses vms
output "internal_ip_address_vms" {
 value = yandex_compute_instance.vms[*].network_interface.0.ip_address
 description = "internal_ip_address for vms"
}

/*output "internal_ip_address_vm3" {
 value = yandex_compute_instance.vms[*].network_interface.0.ip_address
 description = "internal_ip_address for vm3"
}

output "internal_ip_address_vm4" {
 value = yandex_compute_instance.vms[*].network_interface.0.ip_address
 description = "internal_ip_address for vm4"
}
output "internal_ip_address_vm5" {
 value = yandex_compute_instance.vms[*].network_interface.0.ip_address
 description = "internal_ip_address for vm5"
}
output "internal_ip_address_vm6" {
 value = yandex_compute_instance.vms[*].network_interface.0.ip_address
 description = "internal_ip_address for vm6"
}*/
#VPC
output "subnet_id_sn1" {
  value = yandex_vpc_subnet.sn1.id
}
output "subnet_id_sn2" {
  value = yandex_vpc_subnet.sn2.id
}
output "subnet_id_sn3" {
  value = yandex_vpc_subnet.sn3.id
}
