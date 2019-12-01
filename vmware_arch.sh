sudo modprobe -a vmw_vmci vmmon vmnet
sudo systemctl restart vmware-networks-configuration.service
sudo vmware-networks --start
vmware-usbarbitrator
