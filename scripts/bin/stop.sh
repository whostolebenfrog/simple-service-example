#!/bin/sh

PIDS=$(pgrep java -lf | grep simple-service | cut -d" " -f1);

if [ -n "$PIDS" ]
then
  echo "Killing $PIDS";
  echo $PIDS | xargs kill;
else
  echo "No running instances found";
fi
