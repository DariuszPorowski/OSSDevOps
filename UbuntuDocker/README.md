# Linux VM with Docker on Azure (automation example)

## Overview
This example delivers **Linux** Virtual Machine with Docker on Azure based on [ARM Template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/) for Azure resources delivery and [Custom Script Extension for Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/extensions-features) for operating system configuration inside Virtual Machine. Combine two DevOps practices **Infrastructure as Code** and **Configuration Management** extremely reduce delivery time and reduces human errors.

## Assumptions
* OS for Virtual Machine is **Ubuntu Linux**
* VM has two additional data disks attached ([Azure Managed Disks](https://docs.microsoft.com/en-us/azure/storage/storage-managed-disks-overview))
* CSE is stored as blob on Azure Storage without any public access

## VM Configuration
On OS site, script configures and install several technologies:
* Configure data disks as software RAID0
* Install [Docker](https://docs.docker.com/engine/docker-overview/) & [Docker Compose](https://docs.docker.com/compose/overview/)
* Install [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/overview)
* Install [.NET Core](https://www.microsoft.com/net/core/platform)
* Install [PowerShell](https://github.com/PowerShell/PowerShell)
* Install [Azure Storage File driver for Docker](https://azure.microsoft.com/en-us/blog/persistent-docker-volumes-with-azure-file-storage)