#!/bin/bash
# Connect to the automation webhook, and delivery important information about this instance
URL="https://3c2283a8-7f61-46b6-b542-d6eb359cee72.webhook.eus.azure-automation.net/webhooks?token=xgcAfUVdmrOOHOJjBcdPM4cqbPogEoDuAerBsVBUBdc%3d"


curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" > /tmp/info.json
curl "https://3c2283a8-7f61-46b6-b542-d6eb359cee72.webhook.eus.azure-automation.net/webhooks?token=xgcAfUVdmrOOHOJjBcdPM4cqbPogEoDuAerBsVBUBdc%3d" \
  --header "Content-Type: application/json" \
  --request POST \
  --data $(cat /tmp/info.json)
