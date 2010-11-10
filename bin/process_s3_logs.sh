#!/bin/sh

for i in *.log; do 
    echo "~/Devel/DXARTS-511/bin/s3_downloads_to_json.rb $i > $i.json"
     ~/Devel/DXARTS-511/bin/s3_downloads_to_json.rb $i > $i.json
done