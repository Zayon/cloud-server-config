# Import files from old server

## Instal rsync on both servers

```
sudo apt install rsync
```

## Check command with dry run

```
rsync -avP --dry-run /path/to/source/folder/ username@new_server:/path/to/destination/folder/
```

Then rerun without `--dry-run`

