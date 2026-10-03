# Служебный трафик кластера и узлов (применяется к кластеру & узлам)
resource "yandex_vpc_security_group" "ayn-sg" {
  name        = "${var.cluster_name}-sg"
  description = "Rules for self-managed Kubernetes"
  network_id  = yandex_vpc_network.ayn-net.id


  # Разрешаю весь трафик между нодами, находящимися в этой группе.
  # Это обеспечит работу kube-proxy, CoreDNS, NodePort внутри кластера и DirectRouting.
  ingress {
    protocol          = "ANY"
    description       = "Allow all internal traffic between cluster nodes"
    predefined_target = "self_security_group"
  }
  # --- SSH ---
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = [var.sg.admin_cidr]
    port           = 22
    description    = "Allow SSH from admin IP"
  }

  # --- Simple App on port 80 ---
  ingress {
    description    = "HTTP simple app https://github.com/aykuli/simple-app"
    port           = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # --- Kubernetes control plane ---
  ingress {
    description    = "API server"
    port           = 6443
    protocol       = "TCP"
    v4_cidr_blocks = [var.sg.admin_cidr, "10.0.0.0/16"]
  }
  
  # --- etcd/kubectl/scheduller/controller manager 
  # Порты ниже также защищены правилом "self_security_group"
  # Явное указание для документирования.
  
  ingress {
    description    = "etcd"
    from_port      = 2379
    to_port        = 2380
    protocol       = "TCP"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description    = "kubelet API"
    port           = 10250
    protocol       = "TCP"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description    = "kube-scheduler"
    port           = 10259
    protocol       = "TCP"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description    = "kube-controller-manager"
    port           = 10257
    protocol       = "TCP"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  # --- Сеть подов (Flannel VXLAN) ---
  ingress {
    description    = "Flannel VXLAN overlay traffic"
    port           = 8472 # то ли 8472, то ли 4789
    protocol       = "UDP"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  # --- NodePort ---
  ingress {
    description    = "NodePort"
    from_port      = 30000
    to_port        = 32767
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # --- ICMP ---
  ingress {
    description    = "ICMP"
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow to download from Internet whatever"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
