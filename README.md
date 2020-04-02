# peertube.social

This repo contains the Ansible playbook and configuration used on [peertube.social](https://peertube.social).

Use this repo to report any technical issues with peertube.social.

## Usage

Just run the following command:
```
ansible-playbook peertube.yml --ask-vault-pass
```

If you want to use this configuration for your own instance, you need to fork this repo and enter your own domain in
`prod` and in `group_vars/prod.yml`. You also need to change the encrypted variables in the latter file. After that,
you can run the playbook to deploy your instance.
