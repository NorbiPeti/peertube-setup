# Peertube setup with Ansible and Docker-Compose

## Setup

Configure your ssh connection in `inventory`.

Install Ansible:

    pip2 install ansible

Run the playbook:

    ansible-playbook --become -K peertube.yml

It will prompt for root password to escalate privileges through `sudo`.
