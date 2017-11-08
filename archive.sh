#!/bin/bash

function archive {
  pushd .
  cd $1
  LASTDATE=$(date -d "`grep "Last-Modified:" headers.txt | sed 's/^Last-Modified: //g'`" +%s)
  curl -D headers.txt -f "https://esi.tech.ccp.is/$1/swagger.json" | python3.5 -m json.tool --sort-keys > swagger.json
  NEWDATE=$(date -d "`grep "Last-Modified:" headers.txt | sed 's/^Last-Modified: //g'`" +%s)

  echo "$NEWDATE vs $LASTDATE"
  if [ $NEWDATE -gt $LASTDATE ];
  then
    echo "new content found for $1"
    git add swagger.json headers.txt
    git commit --author "ESI Archiver <archive@pizza.moe>" -m "new $1 swagger definition at `grep "Last-Modified:" headers.txt | sed 's/^Last-Modified: //g'`"
  else
    echo "no new content found for $1"
    git checkout -- headers.txt swagger.json
  fi
  popd
}

archive latest
archive _latest
archive dev
archive legacy

git push
