#!/usr/bin/env bash

# This will check the status of 5 recent Cloud Build failures, and if it's a
# LOT, then it will ping Angela in accounting to ask if we can expense some
# drank.


# Various Slack webhook URLs for different test cases
url_test='https://hooks.slack.com/services/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'
url_accounting='https://hooks.slack.com/services/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'

if [[ "$1" -eq "test" ]]; then
  url="$url_test"
else
  url="$url_accounting"
fi


# Get last 5 build statuses from gcloud
gcloud builds list --sort-by='~CREATE_TIME' | awk 'NR>1 && NR<=(5+1) && $6 != "" { print $6 }' > build_status

# === Uncomment to force-trigger Slack post ===
printf "FAILURE\nFAILURE\nFAILURE\nFAILURE\nFAILURE\n" > build_status

# If latest run was a failure, AND all past 5 runs were failures, then post to
# Slack
if grep 'FAILURE' <(head -n1 build_status) && [[ $(wc -l <(uniq build_status) | awk '{ print $1 }') -eq 1 ]]; then

  # Message for the bot post
  echo '{"text": "Hi @Angela,\n\nLook, the devs down here working on pushing out the latest feature are having a _really_ tough time getting everything to work correctly.\nWould you do us all a _huge_ favor, and let us expense a handle of drank? It would really help take the edge off for the team.\n\nThanks so much!\n- Ryan"}' > angela_pls

  # Send the message
  curl \
    -X POST \
    -H 'Content-type: application/json' \
    --data @angela_pls \
    "$url"

  printf "Ok, look, you guys are REALLY not getting it. I'll ask Angela in accounting if we can expense some spirit juice.\n"
  exit 1

fi

printf "Build logs look pretty good! No need to bother Angela with anything... yet.\n"
exit 0
