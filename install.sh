#!/bin/bash

# Check if script is run as root
if [[ $EUID == 0 ]]; then
  echo "You must NOT be a root user when running this script, please run ./install.sh" 2>&1
  exit 1
fi

# Checking if virualisation is enabled or not
if [ "$(grep -Ec '(vmx|svm)' /proc/cpuinfo)" -eq '0' ]; then
    echo "Virtualization is not enabled. If your Processor supports virtualisation, go to bios settings and enable VT-x(Virtualization Technology Extension) for Intel processor and AMD-V for AMD processor." 2>&1
    exit 1
fi

# Actual installation
sudo apt-get -qq install qemu-kvm qemu-system qemu-utils python3 python3-pip libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager -y

# Checking if libvirtd.service was enabled correctly
if [ "$(systemctl status libvirtd.service | awk 'NR==2{print $4}')" != "enabled;" ]; then 
    echo "libvirtd.service is not enabled. Please check why."
fi

# Start default network for networking
sudo virsh net-start default
sudo virsh net-autostart default
if [ "$(sudo virsh net-list --all | awk 'NR==3{print $2}')" != "active" ]; then 
    echo "Default network for virtual machines is not active. Please check why."
fi

# Add user to libvirt to Allow access to VMs
sudo usermod -aG libvirt "$USER"
sudo usermod -aG libvirt-qemu "$USER"
sudo usermod -aG kvm "$USER"
sudo usermod -aG input "$USER"
sudo usermod -aG disk "$USER"

# The End
echo "Reboot the system."