# Hosts Update

This shell script will take user input of a host name and ip address to add, update, or remove the entry for the `/etc/hosts` file. 

```
Add/update/remove entries from /etc/hosts file.

Single update:
  add HOSTNAME IP_ADDRESS
  remove HOSTNAME IP_ADDRESS
  update HOSTNAME IP_ADDRESS

Bulk update:
  bulk add FILE_NAME
  bulk remove FILE_NAME
  bulk update FILE_NAME
  
  The file should be comma delimented to show hostname,ip
```
