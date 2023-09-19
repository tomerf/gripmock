#!/bin/bash

if [ "$1" = "" ]; then
	echo "Version is empty"
	exit 0
fi

go build ../.

docker build --secret id=github,src=./.netrc -t "secful/gripmock:$1" .
