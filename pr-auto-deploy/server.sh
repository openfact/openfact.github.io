set -x

export BASE_PORT="10000"
export LOCAL_IP="209.132.178.114"
export DAYS_AVAILABLE="4"

deployPr() {
  prNo=$1
  [[ $prNo =~ ^[0-9]+$ ]] ||  {
    echo -e "ouch, PR number must be a number"
    exit 1
  }
  _base="/tmp/pr$prNo"
  kill -9 `cat $_base/pid`; rm -Rf $_base &> /dev/null ; mkdir -p $_base && cd $_ &&\
  git clone --single-branch -b pages https://github.com/openfact/openfact.github.io &&\
  cd $_base/openfact.github.io &&\
  git fetch origin refs/pull/$prNo/head:pr$prNo &&\
  git checkout pr$prNo
  [[ -s $_base/pid ]] && kill -9 `cat /tmp/pr$prNo/pid`
  _actual_port=`expr $prNo + $BASE_PORT`
  mvn &> /dev/null
  nohup ruby -run -e httpd $_base/openfact.github.io/target/website -p $_actual_port &> /dev/null &
  PID=$!
  echo $PID > $_base/pid
  echo "kill -9 $PID" | at now + $[DAYS_AVAILABLE*24] hours
  curl -i -XPOST -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/openfact/openfact.github.io/issues/$prNo/comments -d '{"body":"PR was auto-deployed here: http://'$LOCAL_IP':'$_actual_port' and it will be available for '$DAYS_AVAILABLE' days."}' 1>&2
}

handleReq() {
  read token prNo
  #>&2 echo "pr = $prNo,token = $token"
  if [[ "$token" == $"$TOKEN" ]] && [[ "x$token" != "x" ]];
  then
    #echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
    #echo -e "<html><h1>openfact</h1>"
    [[ "x$prNo" != "x" ]] && {
      #echo -e "deploying PR $prNo ..."
      #echo -e "<br>it'll be shortly available on port "`expr $prNo + $BASE_PORT`
      #echo -e "<br>the instance will be auto-killed after 3 days"
      deployPr $prNo
    }
    #echo -e "</html>"
  #else
    #echo -e "HTTP/1.1 403 Forbidden\r\nContent-Type: text/html\r\n\r\n"
    #echo -e "<html><h1>wrong token</h1></html>"
  fi
}

typeset -fx handleReq
typeset -fx deployPr

echo "listening for requests on port $BASE_PORT.."
nc -w4m -lp $BASE_PORT -c handleReq
