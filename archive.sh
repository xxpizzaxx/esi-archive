#!/bin/bash

function archive {
  pushd .
  cd $1
  curl -f "https://esi.tech.ccp.is/$1/swagger.json" | python3.5 -m json.tool --sort-keys > swagger.json && git add swagger.json && git commit --author "ESI archive bot <archive@pizza.moe>" -m "checked in new $1 definition"
  popd
}

archive latest
archive _latest
archive dev
archive legacy

git push
