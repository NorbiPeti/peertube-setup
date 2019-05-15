#!/bin/bash
set -e

# This script can migrate an existing default Peertube installation to docker-compose+ansible.
# Use at your own risk.

DOMAIN="peertube.social"
OLD_SERVER="migration-user@$DOMAIN"
OLD_BASE_FOLDER="/var/www/peertube"
NEW_BASE_FOLDER="/peertube/volumes"

function sync-volumes {
    mkdir -p "$NEW_BASE_FOLDER"
    mkdir -p "$NEW_BASE_FOLDER/data/"
    rsync -a --rsync-path="sudo rsync" "$OLD_SERVER:$OLD_BASE_FOLDER/storage/avatars/" "$NEW_BASE_FOLDER/data/avatars/"
    rsync -a --rsync-path="sudo rsync" "$OLD_SERVER:$OLD_BASE_FOLDER/storage/cache/" "$NEW_BASE_FOLDER/data/cache/"
    rsync -a --rsync-path="sudo rsync" "$OLD_SERVER:$OLD_BASE_FOLDER/storage/captions/" "$NEW_BASE_FOLDER/data/captions/"
    rsync -a --rsync-path="sudo rsync" "$OLD_SERVER:$OLD_BASE_FOLDER/storage/previews/" "$NEW_BASE_FOLDER/data/previews/"
    rsync -a --rsync-path="sudo rsync" "$OLD_SERVER:$OLD_BASE_FOLDER/storage/thumbnails/" "$NEW_BASE_FOLDER/data/thumbnails/"
    rsync -a --rsync-path="sudo rsync" "$OLD_SERVER:$OLD_BASE_FOLDER/storage/torrents/" "$NEW_BASE_FOLDER/data/torrents/"
    rsync -a --rsync-path="sudo rsync" "$OLD_SERVER:/var/lib/postgresql/10/main/" "$NEW_BASE_FOLDER/db/"
}

if [ "$(whoami)" != "root" ]; then
    echo "You need to run this script as root"
    exit 1
fi

if [ "$(ssh "$OLD_SERVER" sudo whoami)" != "root" ]; then
    echo "passwordless sudo needs to be available on $OLD_SERVER"
    exit 1
fi


echo "Before running this script, ensure the following:
- this script is running on the new server (migration target)
- docker-compose based setup for peertube is already installed in /peertube/
- peertube config with adjusted paths is in /peertube/volumes/config/
- set reverse dns for new server to $DOMAIN
- set DNS TTL for $DOMAIN to the minimum possible value
- videos are mounted under /mnt/external
- backups are in place and tested (ideally also of videos)
"

read -p "Continue? [y/N] " yn
if [ "$yn" != "y" ]; then
    exit
fi

# remove any existing volume files
# https://stackoverflow.com/a/790245
rm -r "$NEW_BASE_FOLDER/data/" || true
rm -r "$NEW_BASE_FOLDER/db/" || true
# dont delete this because it would take too long to sync
#rm -r "/mnt/external/*" | true

# copy volumes to local server
# we do this while the old server is still running to reduce downtime
sync-volumes

# add database config files
cp db_config/* "$NEW_BASE_FOLDER/db/"

read -p "Initial copy complete. Do you want to complete the migration now? [y/N] " yn
if [ "$yn" != "y" ]; then
    exit
fi

# shutdown peertube (it will keep seeding videos)
ssh $OLD_SERVER sudo systemctl stop peertube

# now that the old server is offline, we can do a final copy
sync-volumes

# fix permissions
chown 70:115 volumes/db/ -R
chown 999:999 volumes/data/ -R

# TODO: also need to update domain in .env and traefik.toml (maybe with sed, or just set it before we migrate)
docker-compose -f "/peertube/docker-compose.yaml" up -d

# TODO: first check that docker-compose started without errors (eg database password working)
echo "Now update the dns entries for $DOMAIN to point at the new server"
