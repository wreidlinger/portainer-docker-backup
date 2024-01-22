#!/bin/bash
# # # # # # # # # # # # # # # # # # # # # # # #
#                Konfiguration                #
# # # # # # # # # # # # # # # # # # # # # # # #

# Verzeichnis, das gesichert werden soll
SOURCE_DOCKER_compose="/var/lib/docker/volumes/portainer_data/_data/compose"
SOURCE_DOCKER_CONTAINERS="/var/lib/docker/containers"
SOURCE_DOCKER_VOLUMES="/var/lib/docker/volumes"
#SOURCE_DOCKER_images=""

# Verzeichnis, in dem die Backups gespeichert werden sollen
BACKUPDIR="/home/docktainer/backup"

# Anzahl der zu behaltenden Backups
NUM_KEEP_BACKUP=10

# Aktuelles Datum und Uhrzeit
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Name für das Backup-Archiv
BACKUP_FILENAME_DOCKER_COMPOSE="${TIMESTAMP}-docker-compose.tar.gz"
BACKUP_FILENAME_DOCKER_CONTAINERS="${TIMESTAMP}-docker-containers.tar.gz"
BACKUP_FILENAME_DOCKER_VOLUMES="${TIMESTAMP}-docker-volumes.tar.gz"

# Zielserver-Informationen
#remote_user="root"
#remote_server="192.168.40.50"
#remote_dir="/opt/docker_backups"

# # # # # # # # # # # # # # # # # # # # # # # #
#           GO TIME                           #
# # # # # # # # # # # # # # # # # # # # # # # #

#remote_target="${remote_user}@${remote_server}"
BACKUP_FULLPATH_DOCKER_COMPOSE="${BACKUPDIR}/${BACKUP_FILENAME_DOCKER_COMPOSE}"
BACKUP_FULLPATH_DOCKER_CONTAINERS="${BACKUPDIR}/${BACKUP_FILENAME_DOCKER_CONTAINERS}"
BACKUP_FULLPATH_DOCKER_VOLUMES="${BACKUPDIR}/${BACKUP_FILENAME_DOCKER_VOLUMES}"


# check if backup destination is there
if [ ! -d $BACKUPDIR ]; then
        mkdir -p $BACKUPDIR
fi

# terminal message
echo -e "Stopping Docker Containers:\n"
# Docker-Container herunterfahren
#docker stop $(docker ps -q)
docker stop $(docker ps --format '{{.Names}}')

# terminal message
echo -e "\n $TIMESTAMP Start Backup Docker Compose,Containers,Volumes Data.\n"

# Erstelle das Backup-Archiv
# c-Erstellen, f-Datei, p-Rechte behalten, z-Mit gzip komprimieren
tar -cpfz "${BACKUP_FULLPATH_DOCKER_COMPOSE}" "${SOURCE_DOCKER_COMPOSE}"
tar -cpfz "${BACKUP_FULLPATH_DOCKER_CONTAINERS}" "${SOURCE_DOCKER_CONTAINERS}"
tar -cpfz "${BACKUP_FULLPATH_DOCKER_VOLUMES}" "${SOURCE_DOCKER_VOLUMES}"

# Docker-Container wieder starten
#docker start $(docker ps -a -q)
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

echo -e "\n\n$TIMESTAMP Backup Docker Data completed!\n"
#echo "Backup wurde erstellt: ${backup_fullpath} und auf ${remote_target} kopiert."
