# Hook up tini as the default init system for proper signal handling
# and start the adb listening server...
/sbin/tini -s adb -a -P 5037 server nodaemon &

# initial wait period to allow container to load and networking to start up - in seconds
echo "$bootwait" >> /usr/local/bin/tmp.log
sleep "$bootwait"s

# loop forever trying to connect to each device in turn
while :
do
        echo "$devicelist" >> /usr/local/bin/tmp.log
        # split the devicelist string -
        # code from https://unix.stackexchange.com/questions/463854/split-string-in-ash-shell-busybox#464017
        OLDIFS=$IFS;IFS=,
        for token in $devicelist; do
                hostname=$(echo ${token%:*})
                port=$(echo ${token#*:})
                # issue the adb connect command for each device
                echo "trying to connect to: $hostname:$port" >> /usr/local/bin/tmp.log
                adb connect $hostname:$port
        done
        IFS=$OLDIFS

        # wait for the check frequency before we start again - in seconds
        echo "$checkfreq" >> /usr/local/bin/tmp.log
        sleep "$checkfreq"s
done