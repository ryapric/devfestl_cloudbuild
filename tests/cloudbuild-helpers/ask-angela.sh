#!/usr/bin/env bash


# Various Slack webhook URLs for different test cases
url_test='https://hooks.slack.com/services/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'
url_accounting='https://hooks.slack.com/services/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'

if [[ "$1" -eq "test" ]]; then
  url="$url_test"
else
  url="$url_accounting"
fi

# Message for the bot post
cat << EOF > angela_pls
{"text": "Hi @Angela,\n\nLook, the devs down here working on pushing out the latest feature are having a _really_ tough time getting everything to work correctly.\nWould you do us all a _huge_ favor, and let us expense a handle of drank? It would really help take the edge off for the team.\n\nThanks so much!\n- Ryan"}
EOF

# Send the message
curl \
  -X POST \
  -H 'Content-type: application/json' \
  --data @angela_pls \
  "$url"
