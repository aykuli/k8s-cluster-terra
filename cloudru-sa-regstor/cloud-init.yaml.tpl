#cloud-config
users:
  - name: ${vm_user}
    ssh-authorized-keys:
      - ${ssh_public_key}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    # Сгенерируйте пароль командой
    # Linux: mkpasswd -m sha-512 "YourPassword123!"
    passwd: "<YOUR_PASSWORD>"
    lock_passwd: false
hostname: ${vm_name}
manage_etc_hosts: true
