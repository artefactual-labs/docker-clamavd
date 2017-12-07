#!/bin/bash
set -m

freshclam -d &
clamd &

pids=`jobs -p`

exitcode=0

function terminate() {
    trap "" CHLD

    for pid in $pids; do
        if ! kill -0 $pid 2>/dev/null; then
            wait $pid
            exitcode=$?
        fi
    done

    kill $pids 2>/dev/null
}

# set clamd values according to user params. set default using parameter expansion if unset or null
sed -i -e 's/^MaxFileSize 25M$/MaxFileSize '${CLAMAV_MAX_FILE_SIZE:-25}'M/' '/etc/clamav/clamd.conf'
sed -i -e 's/^MaxScanSize 100M$/MaxScanSize '${CLAMAV_MAX_SCAN_SIZE:-100}'M/' '/etc/clamav/clamd.conf'
sed -i -e 's/^StreamMaxLength 25M$/StreamMaxLength '${CLAMAV_MAX_STREAM_LENGTH:-100}'M/' '/etc/clamav/clamd.conf'

trap terminate CHLD
wait

exit $exitcode
