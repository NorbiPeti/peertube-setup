# Peertube setup with Ansible and Docker-Compose

## Setup

Copy `inventory.example` to `inventory`, and configure the hosts you want to work with.

Install Python and Ansible:

    apt install python
    pip2 install ansible

Run the playbook:

    ansible-playbook --become peertube.yml

Note: If you run this on an existing server, make sure the file `passwords/*your-server*/postgres` exists and contains the correct password. Otherwise Ansible will change the password in Peertube, and it won't be able to connect to the database.
