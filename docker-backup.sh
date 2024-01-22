#!/bin/bash

# define, source directories to backup
SOURCE_DOCKER_COMPOSE="/var/lib/docker/volumes/portainer_data/_data/compose"
SOURCE_DOCKER_CONTAINERS="/var/lib/docker/containers"
SOURCE_DOCKER_VOLUMES="/var/lib/docker/volumes"
#SOURCE_DOCKER_images=""
echo -e "\n[] Set source directories:"
echo -e "Docker Compose Data:    "$SOURCE_DOCKER_COMPOSE""
echo -e "Docker Containers Data: "$SOURCE_DOCKER_CONTAINERS""
echo -e "Docker Volumes Data:    "$SOURCE_DOCKER_VOLUMES""

# define, main backup destination location
BACKUPDIR="/home/docktainer/backup"
echo -e "\n\n[] Set backup directory: $BACKUPDIR"

# define number of local backups to keep
NUM_KEEP_BACKUP=10

# define current date/time in a specific format
# example data: 2024-01-22_14-07-23
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# define names for the backup archives
BACKUP_FILENAME_DOCKER_COMPOSE="${TIMESTAMP}-docker-compose.tar.gz"
BACKUP_FILENAME_DOCKER_CONTAINERS="${TIMESTAMP}-docker-containers.tar.gz"
BACKUP_FILENAME_DOCKER_VOLUMES="${TIMESTAMP}-docker-volumes.tar.gz"

# Zielserver-Informationen
#remote_user="root"
#remote_server="192.168.40.50"
#remote_dir="/opt/docker_backups"
#remote_target="${remote_user}@${remote_server}"

# build full path for the backup archives
BACKUP_FULLPATH_DOCKER_COMPOSE="${BACKUPDIR}/${BACKUP_FILENAME_DOCKER_COMPOSE}"
BACKUP_FULLPATH_DOCKER_CONTAINERS="${BACKUPDIR}/${BACKUP_FILENAME_DOCKER_CONTAINERS}"
BACKUP_FULLPATH_DOCKER_VOLUMES="${BACKUPDIR}/${BACKUP_FILENAME_DOCKER_VOLUMES}"


# check if backup destination is there
if [ ! -d $BACKUPDIR ]; then
        mkdir -p $BACKUPDIR
fi

# terminal message
echo -e "\n[] Stopping Docker Containers:\n"
# shut down all current running docker containers
#docker stop $(docker ps -q)
docker stop $(docker ps --format '{{.Names}}')

# terminal message
echo -e "\n[] Start Backup Docker (Compose/Containers/Volumes) Data.\n"

# create the comporessed backup archive files
# c-Erstellen, p-Rechte behalten, f-Datei, z-Mit gzip komprimieren
# --absolute-names
# Don't strip leading slashes from file names when creating archives.
tar cfz "${BACKUP_FULLPATH_DOCKER_COMPOSE}" --absolute-names "${SOURCE_DOCKER_COMPOSE}"
tar cfz "${BACKUP_FULLPATH_DOCKER_CONTAINERS}" --absolute-names "${SOURCE_DOCKER_CONTAINERS}"
tar cfz "${BACKUP_FULLPATH_DOCKER_VOLUMES}" --absolute-names "${SOURCE_DOCKER_VOLUMES}"

# restart ALL Docker-Container
# missing improvement, restart only container not stopped bevor executing the line:
# >>docker stop $(docker ps --format '{{.Names}}')
echo -e "\n[] Starting Docker Containers:\n"
docker start $(docker ps -a --format '{{.Names}}')

 
# Komprimiere das Backup-Archiv
#gzip "${backup_fullpath}"
#backup_fullpath="${backup_fullpath}.gz"

# Kopiere das Backup auf den Zielserver mit SCP ohne Passwort
#scp "${backup_fullpath}" "${remote_target}:$remote_dir/"
# Lösche ältere lokale Backups mit `find`
#find "$BACKUPDIR" -type f -name "*-backup.tar.gz" -mtime +$keep_backups -exec rm {} \;
# Lösche ältere remote Backups mit `find`
#ssh "${remote_target}" "find ${remote_dir} -type f -name '*-backup.tar.gz' -mtime +$keep_backups -exec rm {} \;"

# terminal message
echo -e "\n[] Backup Docker Data completed!\n"
