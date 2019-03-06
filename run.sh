#!/bin/bash

if ! [ -f $OPENGROK_INSTANCE_BASE/deploy ]; then
  mkdir -p $OPENGROK_INSTANCE_BASE/{src,data,etc}

  $OPENGROK_INSTANCE_BASE/bin/OpenGrok deploy
  touch $OPENGROK_INSTANCE_BASE/deploy

  mv /etc/readonly_configuration.xml $OPENGROK_INSTANCE_BASE/etc/
fi

#export JAVA_OPTS="-Xmx8192m -server"
export JAVA_OPTS="-server"
export OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256"
export READ_XML_CONFIGURATION="$OPENGROK_INSTANCE_BASE/etc/readonly_configuration.xml"

sysctl -w fs.inotify.max_user_watches=8192000

service tomcat8 start

# first-time index
echo "** Running first-time indexing"
$OPENGROK_INSTANCE_BASE/bin/OpenGrok index

# ... and we keep running the indexer to keep the container on
echo "** Waiting for source updates..."
touch $OPENGROK_INSTANCE_BASE/reindex

if [ $INOTIFY_NOT_RECURSIVE ]; then
  INOTIFY_CMDLINE="inotifywait -m -e CLOSE_WRITE $OPENGROK_INSTANCE_BASE/reindex"
else
  INOTIFY_CMDLINE="inotifywait -mr -e CLOSE_WRITE $OPENGROK_INSTANCE_BASE/src"
fi

$INOTIFY_CMDLINE | while read f; do
  printf "*** %s\n" "$f"
  echo "*** Updating index"
  $OPENGROK_INSTANCE_BASE/bin/OpenGrok index
done
