# misc-scripts
#DISCLAIMER: Make sure to understand the script functionality before usage and use at your own leisure. I am not responsible for any unintended data losses that may occur as a result of running any of these.


Backup.sh: Take a backup of all your existing EBS volumes and optionally delete pre-existing snapshots. By taking the backups first, we are ensuring that the subsequent deletion of pre-existing snapshots doesn't incur a data loss. From the documentation, "When you delete a snapshot, only the data not needed for any other snapshot is removed. So regardless of which prior snapshots have been deleted, all active snapshots will have access to all the information needed to restore the volume."
