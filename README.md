# Peertube setup with Ansible and Docker-Compose

## Setup

Configure your ssh connection in `inventory`.

Install Python and Ansible:

    apt install python
    pip2 install ansible

Run the playbook:

    ansible-playbook --become -K peertube.yml

It will prompt for root password to escalate privileges through `sudo`.

Note: If you run this on an existing server, make sure the file `passwords/*your-server*/postgres` exists and contains the correct password. Otherwise Ansible will change the password in Peertube, and it won't be able to connect to the database.
