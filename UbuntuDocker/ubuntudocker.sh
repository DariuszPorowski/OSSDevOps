#!/bin/bash

# Prepare system
sudo apt-get update -y 
sudo apt-get upgrade -y

# Install useful software
sudo apt-get install -y mc

# Configure data disks - RAID0
sudo apt-get install -y mdadm util-linux
sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdc /dev/sdd
sudo mkfs -t ext4 /dev/md0
sudo mkdir -p /datadrive
sudo mount /dev/md0 /datadrive
sudo chmod go+w /datadrive
sudo fstrim /datadrive
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
echo '/dev/md0 /datadrive ext4 defaults,nofail,nobootwait,discard 0 0' | sudo tee -a /etc/fstab

# Install Docker & Docker Compose
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install -y docker-ce
sudo apt-get install -y docker-compose 

# Configure Docker
sudo groupadd docker
sudo usermod -aG docker $USER
if [ $(lsb_release -cs) != "trust" ]; then
	sudo systemctl enable docker
fi

# Install Azure CLI 2.0
sudo apt-get install -y libssl-dev libffi-dev python-dev build-essential
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
sudo apt-get install apt-transport-https
sudo apt-get update -y
sudo apt-get install -y azure-cli

# Install .NET Core
echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/dotnetdev.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
sudo apt-get update -y
sudo apt-get install -y dotnet-dev-1.0.4

# Install PowerShell
if [ $(lsb_release -cs) == "xenial" ]; then
	curl -sSLO https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.1/powershell_6.0.0-beta.1-1ubuntu1.16.04.1_amd64.deb
	sudo dpkg -i powershell_6.0.0-beta.1-1ubuntu1.16.04.1_amd64.deb
fi

if [ $(lsb_release -cs) == "trust" ]; then
	curl -sSLO https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.1/powershell_6.0.0-beta.1-1ubuntu1.14.04.1_amd64.deb
	sudo dpkg -i powershell_6.0.0-beta.1-1ubuntu1.14.04.1_amd64.deb
fi
sudo apt-get install -y -f

# Install Azure Storage File driver for Docker
AZUREFILE_DOCKER_VOLUME_DRIVER_VERSION="$1"
sudo apt-get install -y cifs-utils
sudo curl -sSLo /usr/bin/azurefile-dockervolumedriver https://github.com/Azure/azurefile-dockervolumedriver/releases/download/$AZUREFILE_DOCKER_VOLUME_DRIVER_VERSION/azurefile-dockervolumedriver
sudo chmod +x /usr/bin/azurefile-dockervolumedriver
sudo curl -sSLo /etc/default/azurefile-dockervolumedriver https://raw.githubusercontent.com/Azure/azurefile-dockervolumedriver/master/contrib/init/systemd/azurefile-dockervolumedriver.default
sudo curl -sSLo /etc/systemd/system/azurefile-dockervolumedriver.service https://raw.githubusercontent.com/Azure/azurefile-dockervolumedriver/master/contrib/init/systemd/azurefile-dockervolumedriver.service

# Configure Azure Storage File driver for Docker
AZURE_STORAGE_ACCOUNT="$2"
AZURE_STORAGE_ACCOUNT_KEY="$3"
azuredefault=$(</etc/default/azurefile-dockervolumedriver)
azuredefault=${azuredefault/youraccount/$AZURE_STORAGE_ACCOUNT}
azuredefault=${azuredefault/yourkey/$AZURE_STORAGE_ACCOUNT_KEY}
echo "$azuredefault" | sudo tee /etc/default/azurefile-dockervolumedriver

# Finalize
sudo systemctl daemon-reload
sudo systemctl enable azurefile-dockervolumedriver
sudo systemctl start azurefile-dockervolumedriver
sudo service docker restart