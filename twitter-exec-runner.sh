# show help when not enough arguments are supplied
if [ $# -lt 1 ]; then
  me=`basename $0`
  echo "$me runs twitter-exec periodically, all parameters are directly propagated to twitter-exec"
  echo ""
  ./twitter-exec.sh "$@"
  exit -1
fi

while [ true ]; do
  ./twitter-exec.sh "$@"
  sleep 65 # sleep 65 seconds to ensure we do not hit the Twitter API limit.
done
