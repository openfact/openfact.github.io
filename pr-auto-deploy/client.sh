[ "$#" -ne 2 ] && {
  echo "usage: $0 <pr_number> <host>"
  exit 1
}

PR_NUMBER=$1
HOST=$2
BASE_PORT=10000

echo -n "$PR_DEPLOY_TOKEN $PR_NUMBER" | nc -4 -w1 $HOST $BASE_PORT
