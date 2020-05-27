# peertube.social

This repo contains the Ansible playbook and configuration used on [peertube.social](https://peertube.social).

Use this repo to report any technical issues with peertube.social.

## Usage

Just run one of the following commands:
```
# deploy to test.peertube.social
ansible-playbook -i test peertube.yml --ask-vault-pass
# deploy to peertube.social
ansible-playbook -i prod peertube.yml --ask-vault-pass
```

If you want to use this configuration for your own instance, you need to fork this repo and enter your own domain in
`prod` and in `group_vars/prod.yml`. You also need to change the encrypted variables in the latter file. After that,
you can run the playbook to deploy your instance.

## File Overview

- `peertube.yml`: The Ansible playbook, configures the server and copies config files
- `files/docker-daemon.json`: Configuration for Docker, to limit stored logs
- `files/local-production.json`: Peertube configuration, things like custom css, about page, transcoding options, etc
- `templates/docker-compose.yml.j2`: List of Docker images and their versions
- `templates/env.j2`: Various environment variables
- `templates/nginx.conf.j2`: Config for the nginx reverse proxy
- `templates/peertube-production.yaml.j2`: Peertube config, things like ports, email server, redundancy settings, etc