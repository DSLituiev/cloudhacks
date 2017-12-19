
usage(){
echo "A tool that monitors a docker container execution"
echo "and sends an email with container logs when finished"
echo ""
echo "make sure to set your emails in the script"
echo ""
echo "USAGE:"
echo "bash aws-monitor-docker.sh [container_id]"
}

if [ "${#array[@]}" -lt 1 ]
then
    usage
    exit 1
fi

EMAILFROM=
EMAILTO=
STEP=$((60*2))

containerid=$1
NAME=$(docker inspect --format '{{.Name}}' ${containerid})

while true; do
        check=`docker inspect -f '{{.State.Running}}' $containerid`
        if [ "$check" == "true" ]
        then
                echo -e "$(date)\t${containerid}\t$NAME\tstill running"
                sleep $STEP
        else
                echo -e "$(date)\tdone"
                log=`docker logs $containerid 2>&1 | tail -n 100`

                aws ses send-email \
                        --from $EMAILFROM \
                        --destination ToAddresses=$EMAILTO \
                        --message Subject={Data="Container $NAME completed"},Body={Text={Data="'""$log""'"}}
                break
        fi

done
