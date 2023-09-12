# Setup backups with borg and borgmatic

## Install borg and borgmatic

```
sudo rm /usr/lib/python3.11/EXTERNALLY-MANAGED
pip install --user borgmatic
```

## Initialize borg repository

```
borg init --encryption repokey ssh://pi@localhost:22/mnt/backup/path
```

Put the BORG_PASSPHRASE environment variable in /etc/environment

`sudo vim /etc/environment`

```
BORG_PASSPHRASE=Passphrase
```

## Configure bormatic

Check `$HOME/.config/borgmatic/config.yaml`

```
editor $HOME/.config/borgmatic/config.yaml
```

## Add systemd service unit and timer

The following files are needed:

* `~/.config/systemd/user/borgmatic-backup.service`
* `~/.config/systemd/user/borgmatic-backup.timer`

Running `auto-symlinks --execute` should be enough.

## Reload systemd deamon and activate timer

```
systemctl --user daemon-reload
systemctl --user enable --now borgmatic-backup.timer

# Check that the timer is activated
systemctl --user list-timers
```
