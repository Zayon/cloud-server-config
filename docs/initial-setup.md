# Initial setup

## Setup swap en RAID10

```
# List devices to know which are the swap ones
lsblk
# Disable all swap devices
sudo swapoff -a
# Check
lsblk

sudo mdadm --create --verbose /dev/md4 --level=10 --raid-devices=4 /dev/sda4 /dev/sdb4 /dev/sdc4 /dev/sdd4
# Note the device UUID !!
sudo mkswap /dev/md4

# Remove old swap lines except one and replace the uuid
sudo vim /etc/fstab

# Reactivate swap
sudo swapon -a
```


## Clean /etc/sudoers.d/

```
sudo su
cd /etc/sudoers.d/
ls -la

# Remove any file that may have been added by cloud provider
```

## Allow user to run sudo without password

```
sudo visudo
```

```
# Added manually
zayon ALL=(ALL) NOPASSWD:ALL
```

## Remove all groups from debian user

```
sudo gpasswd -d debian sudo
sudo gpasswd -d debian adm
sudo gpasswd -d debian cdrom
sudo gpasswd -d debian dialout
sudo gpasswd -d debian audio
sudo gpasswd -d debian video
sudo gpasswd -d debian plugdev
sudo gpasswd -d debian floppy
sudo gpasswd -d debian dip
```

Removing it from sudo group make it impossible to login from ssh

