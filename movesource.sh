#!/bin/bash
#
# See sample file in git and place completed file in ~/movescripts.env
# command options $1 is location of files to process
# movesource collectionofremotes.txt
#
#
# Comment this out when ready to run
#
#

if [ "$#" -ne 1 ]; then
    echo ""
    echo ""
    echo "$0 collectionofremotes.txt"
    echo ""
    echo ""
    echo "This script requires a pointer to the list of rclone remotes you wish to use in a text file"
    echo "IE."
    echo ""
    echo "source_rclone_mount:/ destination_rclone_mount:/"
    echo ""
    exit 1
fi

PROCESS_FILE=$1

export $(xargs < /root/movescript.env)

rocketpush () {

	/opt/scripts/rocketpush.sh $WEBHOOK $CHANNEL "$PROJECTNAME $1"
}

rclonededupe () {

	/usr/bin/rclone dedupe --config=$RCLONE_CONFIG $1
}

rclonecopy () {

	/usr/bin/rclone sync --config=$RCLONE_CONFIG $1 $2 --transfers=$TRANSFERS --checkers=$CHECKERS --drive-chunk-size=$DRIVE_CHUNK_SIZE  --fast-list
}

rclonemain () {

rocketpush "Starting $1 dedupe"
                rclonededupe "$1"
        rocketpush "Starting $2 dedupe"
                rclonededupe "$2"
        rocketpush "Starting copy from $1 to $2"

        rclonecopy "$1" "$2"

        if [ $? -eq 0 ]; then
                rocketpush "Finished copy from $1 to $2 *COMPLETED*"
        else
                rocketpush "Finished copy from $1 to $2 *FAILED*"
        fi

}


shutdown () {
	rocketpush "Shutting down system"
	sleep 15
	/sbin/shutdown -h now
}

# Business End of the script.

while IFS=" " read -r source destination
	do
	    rclonemain $source $destination
	done < $PROCESS_FILE

shutdown
