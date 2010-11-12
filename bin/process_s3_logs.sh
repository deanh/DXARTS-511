#!/bin/sh

for i in *.log; do 
    echo "$i"
    if [ ! -f $i.json ]; then
        ~/Devel/DXARTS-511/bin/s3_downloads_to_json.rb $i > $i.json
    else
        echo $i.json exists, skipping...
    fi
done