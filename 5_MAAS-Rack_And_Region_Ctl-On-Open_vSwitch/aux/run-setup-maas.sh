source /etc/ccio/mini-stack/profile
cat <<EOF >/tmp/run-maas-setup
#!/bin/bash 

run_maas_login () {
login-maas-cli
login_CODE="$?"
[[ ${login_CODE} == "0" ]] || echo "Login Failed"
[[ ${login_CODE} == "0" ]] || exit 1
}

find_maas_rack_id () {
primary_RACK=\$(maas admin rack-controllers read \
                                | jq ".[] | {system_id:.system_id}" \
                                | awk -F'[",]' '/system_id/{print \$4}' \
              )
}

run-maas-setup () {
maas admin maas set-config name=maas_name value=maasctl
maas admin maas set-config name=upstream_dns value=8.8.8.8
maas admin maas set-config name=enable_third_party_drivers value=true
maas admin maas set-config name=disk_erase_with_secure_erase value=false
maas admin maas set-config name=kernel_opts value='debug console=ttyS0,38400n8 console=tty0 intel_iommu=on iommu=pt kvm_intel.nested=1 net.ifnames=0 biosdevname=0 pci=noaer'

maas admin spaces create name=internal
maas admin spaces create name=external
maas admin fabric update 0 name=internal
maas admin subnet update 1 name=untagged-internal gateway_ip="${ministack_SUBNET}.1" dns_servers="${ministack_SUBNET}.10"
maas admin ipranges create type=dynamic start_ip=${ministack_SUBNET}.100 end_ip=${ministack_SUBNET}.240
maas admin vlan update internal 0 name=internal space=internal
maas admin vlan update internal untagged dhcp_on=True primary_rack=\${primary_RACK}

}

run_maas_login
find_maas_rack_id
run-maas-setup

rm /bin/run-maas-setup
echo "Finished run-maas-setup at \$(date)"

#################################################################################
# WIP
#maas admin pods create type=virsh name=mini-stack.maas power_address=qemu+ssh://root@mini-stack/system cpu_over_commit_ratio=10 memory_over_commit_ratio=10
#maas admin dnsresource-records update name=mini-stack domain=maas rrdata=${ministack_SUBNET}.2 rrtype=cname ip_addresses=${ministack_SUBNET}.2
#maas admin devices create hostname=mini-stack domain=maas mac_addresses=02:17:77:61:55:7b ip_addresses=${ministack_SUBNET}.2 ip_address=${ministack_SUBNET}.2

#rm /bin/run-maas-setup
EOF

chmod +x /tmp/run-maas-setup
lxc file push /tmp/run-maas-setup maasctl/bin/run-maas-setup
lxc snapshot maasctl pre-run-setup
lxc exec maasctl run-maas-setup
