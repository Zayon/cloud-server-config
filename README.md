# My own cloud server

## Initial setup on fresh install

⚠️ Be sure to open an ssh session manually before in case it breaks

```bash
ansible-playbook \
    -i "$ip," -e "ansible_ssh_user=$username" \
    playbooks/00-initial-setup.yaml -K
```

Then follow [initial setup documentation](docs/initial-setup.md)

```bash
ansible-playbook \
    -i "$ip," -e "ansible_ssh_user=$username" \
    playbooks/01-install-software.yaml
```


