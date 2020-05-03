#!/bin/bash
#aws ec2 describe-volumes --output text  | awk -F"\t" '$1=="INSTANCES" {print $5}'
#account_id=`aws sts get-caller-identity --output text | awk '{print $1}'`

#aws ec2 describe-snapshots --owner-ids self --query 'Snapshots[*].{Id:SnapshotId}' --output text
#The above line is for experimentation with different ways to parse it

#This script takes a snapshot of all your existing EBS volumes, then deletes the old, pre-existing ones so you get a fresh copy
#Data loss is not expected because the backups are taken first, and if you delete the old snapshots upon which the new ones are 
#dependent, even if you 'deleted' them, you can still boot a full volume from the new ones. 
#See https://docs.aws.amazon.com/cli/latest/reference/ec2/delete-snapshot.html for more information. Contact me for questions at aakhan95@hotmail.com

echo "This script backs up all active volumes. Would you also like to delete all pre-existing vol snapshots? (y/n)"
read input

declare -a prev_snaps=($(aws ec2 describe-snapshots --owner-ids self --query 'Snapshots[*].{Id:SnapshotId}' --output text))


function backup_volumes() {
    declare -a my_volumes=($(aws ec2 describe-volumes --query 'Volumes[*].{ID:VolumeId}' --output text))
    delete_old="TRUE"
    for item in "${my_volumes[@]}"; do
	  aws ec2 create-snapshot --volume-id $item
	  if [ $? -ne 0 ]; then
             delete_old="FALSE"
	  fi;
    done

    printf "\nSnapshot of all active volumes taken\n"
}

function delete_old_snaps() {
    if [ $delete_old == "TRUE" ]; then
	for snap in "${prev_snaps[@]}"; do
	     aws ec2 delete-snapshot --snapshot-id $snap
	done
    fi;

    printf "\nAll previous snapshots have been deleted\n"
}

backup_volumes
if [ $input == "y" || $input == "yes" ]; then
	delete_old_snaps
fi;
