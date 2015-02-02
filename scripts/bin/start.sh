#!/bin/sh

APP_NAME=simple-service

PIDS=$(pgrep java -lf | grep $APP_NAME | cut -d" " -f1);

if [ -n "$PIDS" ]
then
  echo "Simple-service is already running in process $PIDS";
  exit 1
fi

JETTY_HOME=/usr/local/$APP_NAME
JAR_NAME=$JETTY_HOME/$APP_NAME.jar

IFS="$(echo -e " ")"

SERVICE_NAME=$APP_NAME
SERVICE_PORT=${SERVICE_PORT:-"8080"}
HEALTHCHECK_PATH=${HEALTHCHECK_PATH:-"/healthcheck"}
START_TIMEOUT_SECONDS=${START_TIMEOUT_SECONDS:-"60"}
LOGGING_PATH=${LOGGING_PATH:-"/var/log/${SERVICE_NAME}"}
LOG_FILE=${LOGGING_PATH}/simple-service.out
ERR_FILE=${LOGGING_PATH}/simple-service.err

mkdir -p /var/encrypted/logs/${APP_NAME}

nohup java $SERVICE_JVMARGS -jar $JAR_NAME > $LOG_FILE 2> $ERR_FILE < /dev/null &

statusUrl=http://localhost:$SERVICE_PORT$HEALTHCHECK_PATH
waitTimeout=$START_TIMEOUT_SECONDS
sleepCounter=0
sleepIncrement=2

echo "Giving Simple-service $waitTimeout seconds to start successfully"
echo "Using $statusUrl to determine service status"

retVal=0

until [ `curl --write-out %{http_code} --silent --output /dev/null $statusUrl` -eq 200 ]
do
  if [ $sleepCounter -ge $waitTimeout ]
  then
    echo "Simple-service didn't start within $waitTimeout seconds."
    PIDS=$(pgrep java -lf | grep $APP_NAME | cut -d" " -f1);
    if [ -n "$PIDS" ]
	then
	  echo "Killing $PIDS";
	  echo $PIDS | xargs kill;
	else
	  echo "No running instances found";
	fi
    retVal=1
    break
  fi
  sleep $sleepIncrement
  sleepCounter=$(($sleepCounter + $sleepIncrement))
done

echo ======================================================
echo Contents of $LOG_FILE
echo ======================================================
cat $LOG_FILE
echo ====================================================== 1>&2
echo Contents of $ERR_FILE 1>&2
echo ====================================================== 1>&2
cat $ERR_FILE 1>&2

if [ $retVal -eq 1 ]
then
  echo "Starting Simple-service failed"
else
  echo "Starting Simple-service succeeded"
fi

exit $retVal
