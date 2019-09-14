#!/usr/bin/env python3

import requests
import json
import sys

ask_angela = '''
Hi @Angela,

Look, the devs down here working on pushing out the latest feature are having a
_really_ tough time getting everything to work correctly. Would you do us all a
_huge_ favor, and let us expense a handle of Jose Cuervo? It would really help
take the edge off for the team.

Thanks so much!
- Ryan
'''

url_main = 'https://hooks.slack.com/services/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'
url_test = 'https://hooks.slack.com/services/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'

url = url_test if len(sys.argv) > 1 and sys.argv[1] == 'test' else url_main

requests.post(
    url = url,
    data = json.dumps({'text': ask_angela})
)
