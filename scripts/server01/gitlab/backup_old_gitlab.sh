#!/bin/bash

echo -e "Start gitlab auto backup procedure"
echo -e "Init shell script"


# 設定路徑與標籤
GITLAB_CONTAINER_BACKUP_PATH="/var/opt/gitlab/backups"
GITLAB_LOCAL_BACKUP_PATH="/home/gitlab/daily_backup/gitlab"
GITLAB_MOUNT_CONFIG_PATH="/home/gitlab/config"
DATE_ID="$(date +'%Y%m%d_%H%M%S')"
TAR_PRE_STRING="backup_"
TAR_POST_STRING=".tar"
NAS_BACKUP_PATH="/mnt/devops_backup/gitlab"

# 設定最大容許檔案數
FILE_MAX="3"


function backupandupload() {

	# Define folder path
	echo "Now date ID is $DATE_ID"
	save_file_path=$GITLAB_LOCAL_BACKUP_PATH/$DATE_ID
	mkdir $save_file_path

	# 執行 CONFIG 備份
	tar cvf $GITLAB_LOCAL_BACKUP_PATH/$DATE_ID/gitlab-config-$(date +%s).tar $GITLAB_MOUNT_CONFIG_PATH

	# 執行 DATA 備份並將 DATA 複製回本機端
	docker exec -t old-gitlab gitlab-backup create
	backup_name="$(docker exec -t old-gitlab ls -A1 $GITLAB_CONTAINER_BACKUP_PATH/ | sort -n | tail -n 1)"
	real_file_name=$(printf $backup_name | tr -d '\r')
	container_backup_file=$GITLAB_CONTAINER_BACKUP_PATH/$real_file_name
	docker cp old-gitlab:$container_backup_file $GITLAB_LOCAL_BACKUP_PATH/$DATE_ID/

	# 進行資料夾壓縮
	tar_file=$TAR_PRE_STRING$DATE_ID$TAR_POST_STRING
	echo "Set up tar file name is $tar_file"
	
	tar_file_path=$GITLAB_LOCAL_BACKUP_PATH/$tar_file
	tar cvf $tar_file_path -C $save_file_path . 

	# 刪除資料夾
	rm $GITLAB_LOCAL_BACKUP_PATH/$DATE_ID -rf
	
	# 將壓縮檔上傳至 NAS
	rsync -zvr $tar_file_path $NAS_BACKUP_PATH/
}

function checkfilestodelete() {

	# 先計算總數量
	number="$(ls -la $1 | grep '.tar' | wc -l)"
	echo "Exist backup files $number"

	# 計算超過的量
	del="$((number-FILE_MAX))"
	echo "Expect delete files are $del"

	# 判斷有沒有大於0
	if [[ "$del" -gt "0" ]]
	then
		echo "Exist files greater then $FILE_MAX , need to delete"
		find $1 -name "*.tar" | sort -n | head -n "$del" | xargs rm -rf
		echo "Delete finish"
	else
		echo "Exist files smaller then $FILE_MAX , no action"
	fi
}

function checkcontainertodelete() {

	# 先計算總數量
	number=$(docker exec old-gitlab sh -c "ls -la $GITLAB_CONTAINER_BACKUP_PATH | grep .tar | wc -l")
        echo "Container exists backup files $number"

        # 計算超過的量
        del="$((number-FILE_MAX))"
        echo "Expect delete files are $del"

        # 判斷有沒有大於0
        if [[ "$del" -gt "0" ]]
        then
        	echo "Container exists files greater then $FILE_MAX , need to delete"
		docker exec old-gitlab sh -c "find $GITLAB_CONTAINER_BACKUP_PATH -name '*.tar' | sort -n | head -n $del | xargs rm -rf"
		echo "Delete finish"
        else
                echo "Exist files smaller then $FILE_MAX , no action"
        fi
}

backupandupload
checkfilestodelete "$GITLAB_LOCAL_BACKUP_PATH"
checkfilestodelete "$NAS_BACKUP_PATH"
checkcontainertodelete
