#!/bin/sh

printf "Giving AppEngine time to come up...\n"
sleep 10

touch test-results

printf "Pinging healthcheck...\n"
wget -O healthcheck-ping 'https://fredcast-248816.appspot.com/api/health' || (printf "ERROR -- healthcheck endpoint unreachable! \n" >> test-results)
grep 'ok' healthcheck-ping || printf "ERROR -- Healthcheck ping failed! \n" >> test-results

printf "Trying /api/fredcast endpoint...\n"
wget -O fredcast-call 'https://fredcast-248816.appspot.com/api/fredcast' || (printf "ERROR -- FREDcast endpoint unreachable! \n" >> test-results)
grep 'DATE' fredcast-call || printf "ERROR -- FREDcast call failed! \n" >> test-results

# If all endpoints successful, check if any errors generated, show them, and fail
grep -v 'ERROR' test-results || (cat test-results && exit 1)
