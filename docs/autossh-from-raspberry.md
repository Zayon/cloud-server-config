# AutoSSH from Raspberry

`vim /etc/systemd/system/autossh-servername.service`

```
[Unit]
Description=Keep ssh tunnel to tidus
After=network.target

[Service]
User=pi
Environment="AUTOSSH_GATETIME=0"
ExecStart=/usr/bin/autossh -M 0 -f -NT -o ExitOnForwardFailure=yes -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -R 65522:127.0.0.1:22 zayon@server.ip

RestartSec=5min
Restart=always

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable --now autossh-servername.service
```

