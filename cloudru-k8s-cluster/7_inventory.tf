# resource "local_file" "inventory" {
#   filename = "../ansible/inventory.yml"

#   content = templatefile("./templates/inventory.tmpl", {
#     master_ip       = cloudru_evolution_compute_instance.master.network_interface[0].nat_ip_address
#     workers = [
#       for vm in cloudru_evolution_compute_instance.worker : {
#         hostname = vm.hostname
#         ip       = vm.network_interface[0].nat_ip_address
#       }
#     ]
#   })
# }
