[master]
k8s-master ansible_host=${master_ip}

[workers]
%{ for i, ip in workers ~}
k8s-worker-${i + 1} ansible_host=${ip}
%{ endfor ~}

[k8s_cluster:children]
master
workers

[k8s_cluster:vars]
ansible_user=${ssh_user}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
pod_cidr=${pod_cidr}
service_cidr=${svc_cidr}
k8s_version=${k8s_version}