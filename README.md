# misc-scripts
**DISCLAIMER**: Make sure to understand the script functionality before usage and use at your own leisure. I am not responsible for any unintended data losses that may occur as a result of running any of these.


## backup_ebs.sh: 
Take a backup of all your existing EBS volumes and optionally delete pre-existing snapshots. By taking the backups first, we are ensuring that the subsequent deletion of pre-existing snapshots doesn't incur a data loss. From the documentation, "When you delete a snapshot, only the data not needed for any other snapshot is removed. So regardless of which prior snapshots have been deleted, all active snapshots will have access to all the information needed to restore the volume."

## migrate_ecr.sh:
When I wrote this script, there was no built-in functionality to migrate ECR repos from one AWS account to another. That seems to have changed... However, this script takes care of migrating all repos from one account to the other, including all the tags in each repo. It ignores unused and unwanted '<untagged>' tags which accumulate after many updates. If the images being migrated are large, remove the 'docker prune' line, but read the comment at the top of the file.
