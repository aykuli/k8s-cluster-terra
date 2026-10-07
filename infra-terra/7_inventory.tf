resource "local_file" "inventory" {
  content = <<-EOT
k8s_cluster:
  children:
    master:
      hosts:
        ${yandex_compute_instance.master.hostname}:
          ansible_host: ${yandex_compute_instance.master.network_interface.0.nat_ip_address}
          ansible_user: ${var.ssh_user}
          ansible_become: true
    workers:
      hosts:
      %{ for vm in yandex_compute_instance.worker ~}
       ${vm["hostname"]}:
          ansible_host: ${vm.network_interface.0.nat_ip_address}
          ansible_user: ${var.ssh_user}
          ansible_become: true
      %{ endfor ~}
  EOT

  filename = "../ansible/inventory.yml"
}
