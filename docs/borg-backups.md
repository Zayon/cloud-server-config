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
