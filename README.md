# My own cloud server

## Initial setup on fresh install

⚠️ Be sure to open an ssh session manually before in case it breaks

First build the image: `make build-ansible-image`

```bash
./ansible <user> <ip> playbooks/00-initial-setup.yaml -K
```

Then follow [initial setup documentation](docs/initial-setup.md)

```bash
./ansible <user> <ip> playbooks/01-install-software.yaml
```


