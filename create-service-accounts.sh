#!/bin/bash
set -e
export ORGANIZATION_ID=
export GROUP_NAME="hordify-backups@hordify.me"
export GROUP_DIR="/accounts/_hordify-backups"
export SERVICE_DIR="/accounts/_hordify-backups/services"

mkdir -p "$SERVICE_DIR"

if [ ! -f $GROUP_DIR/members.csv ]; then
    echo "Group Email [Required],Member Email,Member Type,Member Role" >$GROUP_DIR/members.csv
fi

project_init() {
    export PROJECT=$1
    export ACCOUNT_DIR=/accounts/$PROJECT

    if [ ! -d /accounts/$PROJECT ]; then
        gcloud projects create $PROJECT --organization=$ORGANIZATION_ID && mkdir -p /accounts/$PROJECT

    fi

    gcloud config set project $PROJECT

    if [ ! -f $ACCOUNT_DIR/.gdrive_enabled ]; then
        gcloud services enable drive.googleapis.com && touch $ACCOUNT_DIR/.gdrive_enabled
    fi
}

create_service() {
    SERVICE_NAME=$PROJECT-$1
    SERVICE_EMAIL=$SERVICE_NAME@$PROJECT.iam.gserviceaccount.com

    SERVICE_NUM_DIR=$SERVICE_DIR/$1
    mkdir -p $SERVICE_NUM_DIR
    SERVICE_JSON=$SERVICE_NUM_DIR/$SERVICE_NAME.json

    if [ ! -f $SERVICE_JSON ]; then
        gcloud iam service-accounts create $SERVICE_NAME --display-name $SERVICE_NAME &&
            gcloud iam service-accounts keys create $SERVICE_JSON --iam-account $SERVICE_EMAIL &&
            chmod 777 $SERVICE_JSON &&
            chown 1000:1000 $SERVICE_JSON

        chown 1000:1000 -R /accounts
        chmod 777 -R /accounts

        echo "$GROUP_NAME,$SERVICE_EMAIL,USER,MEMBER" >>$GROUP_DIR/members.csv
    fi
}

main() {
    for project_num in {1..33}; do
        project_init "hordify-backups-$project_num"

        for service_num in {1..99}; do
            create_service $service_num
        done
    done
}

main
