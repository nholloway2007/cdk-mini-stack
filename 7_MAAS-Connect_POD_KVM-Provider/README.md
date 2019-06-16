# Part 6 -- MAAS Connect POD on KVM Provider
###### Enable MAAS Control over Libvirt / KVM / QEMU Provider via POD method

-------
Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]
- [Part 5 MAAS Region And Rack Server on OVS Sandbox]

![CCIO Hypervisor - MAAS Libvirt POD Provider](web/drawio/maas-region-and-rack-ctl-on-ovs-sandbox.svg)

-------
#### 01. Provision Libvirt Host with maasctl ssh key & test virsh commands over ssh
````sh
lxc exec maasctl -- /bin/bash -c 'cat /var/lib/maas/.ssh/id_rsa.pub' >>~/.ssh/authorized_keys
lxc exec maasctl -- su -l maas /bin/bash -c "ssh-keyscan -H ${ministack_SUBNET}.2 >>~/.ssh/known_hosts"
lxc exec maasctl -- su -l maas /bin/bash -c "ssh -oStrictHostKeyChecking=accept-new root@${ministack_SUBNET}.2 hostname"
lxc exec maasctl -- su -l maas /bin/bash -c "virsh -c qemu+ssh://root@${ministack_SUBNET}.2/system list --all"
````

#### 02. Connect your libvirt provider as a POD in MAAS
````sh
lxc exec maasctl -- /bin/bash -c "maas admin pods create type=virsh name=master.mini-stack.maas power_address=qemu+ssh://root@${ministack_SUBNET}.2/system cpu_over_commit_ratio=10 memory_over_commit_ratio=10"
````

#### 03. Test create new VM in your virsh pod:
```sh
lxc exec maasctl -- /bin/bash -c 'maas admin pod compose 1 cores=2 memory=2048 "storage=root:32(default)"'
virsh list --all
virsh console $new_vm_id
```
NOTE: Use key conbination "Ctrl+Shift+]" to exit virsh console

-------
## Next sections
- [Part 7 Juju MAAS Cloud]
- [Part 8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[Part 0 Host System Prep]: ../0_Host_System_Prep
[Part 1 Single Port Host OVS Network]: ../1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part 2 LXD On Open vSwitch Network]: ../2_LXD-On-OVS
[Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: ../3_LXD_Network_Gateway
[Part 4 KVM On Open vSwitch]: ../4_KVM_On_Open_vSwitch
[Part 5 MAAS Region And Rack Server on OVS Sandbox]: ../5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part 6 MAAS Connect POD on KVM Provider]: ../6_MAAS-Connect_POD_KVM-Provider
[Part 7 Juju MAAS Cloud]: ../7_Juju_MAAS_Cloud
[Part 8 OpenStack Prep]: ../8_OpenStack_Deploy