#!/bin/bash

function archive {
  pushd .
  cd $1
  LASTDATE=$(date -d "`grep "Last-Modified:" headers.txt | sed 's/^Last-Modified: //g'`" +%s)
  curl -D headers.txt -f "https://esi.evetech.net/$1/swagger.json" | python3.5 -m json.tool --sort-keys > swagger.json
  NEWDATE=$(date -d "`grep "Last-Modified:" headers.txt | sed 's/^Last-Modified: //g'`" +%s)
  HEADERCOUNT=$(wc -l headers.txt | cut -d' ' -f1)

  if [ $HEADERCOUNT -gt 0 ]; then
    echo "$NEWDATE vs $LASTDATE"
    if [ $NEWDATE -gt $LASTDATE ];
    then
      echo "new content found for $1"
      git status --porcelain | grep "swagger.json"
      NEWSWAGGER=$?
      if [ $NEWSWAGGER -eq 0 ]; then
        git add swagger.json headers.txt
        git commit --author "ESI Archiver <archive@pizza.moe>" -m "$1 at `grep "Last-Modified:" headers.txt | sed 's/^Last-Modified: //g'`"
      else
        echo "only the headers changed"
        git checkout -- headers.txt
      fi
    else
      echo "no new content found for $1"
      git checkout -- headers.txt swagger.json
    fi
    popd
  else
    git checkout -- headers.txt swagger.json
    popd
  fi
}

archive latest
archive _latest
archive dev
archive _dev
archive legacy
archive _legacy

git push
