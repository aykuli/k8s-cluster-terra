resource "local_file" "inventory" {
  filename = "../ansible/inventory.yml"

  content = templatefile("./templates/inventory.tmpl", {
    ansible_user    = var.ssh_user
    master_hostname = yandex_compute_instance.master.hostname
    master_ip       = yandex_compute_instance.master.network_interface.0.nat_ip_address
    workers         = [
      for vm in yandex_compute_instance.worker : {
        hostname = vm.hostname
        ip       = vm.network_interface.0.nat_ip_address
      }
    ]
  })
}
