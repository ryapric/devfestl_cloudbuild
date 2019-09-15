#!/usr/bin/env bash

# Run tests against the live deployment, rolling back the AppEngine version if
# any fail

# printf "Giving AppEngine time to come up...\n"
# sleep 10

# Provide dummy line to test-results, so final grep will pass successfully
printf "\n" >> test-results

printf "Pinging healthcheck...\n"
curl -fsS -o healthcheck-ping 'https://fredcast-248816.appspot.com/api/health'|| (printf "ERROR -- healthcheck endpoint unreachable! \n" >> test-results)
grep 'ok' healthcheck-ping || printf "ERROR -- Healthcheck ping failed! \n" >> test-results

printf "Trying /api/fredcast endpoint...\n"
curl -fsS -o fredcast-call 'https://fredcast-248816.appspot.com/api/fredcast' || (printf "ERROR -- FREDcast endpoint unreachable! \n" >> test-results)
grep 'DATE' fredcast-call || printf "ERROR -- FREDcast call failed! \n" >> test-results

# If all endpoints successful, check if any errors generated, show them,
# rollback AppEngine, and fail the build
# === Add -v flag to grep, or change endpoint name in source, to force-trigger ===
if grep 'ERROR' test-results; then
  printf "ERROR: Live test(s) failed; rolling back to previous AppEngine version...\n"
  APPENGINE_OLDSTABLE=$(gcloud app versions list --sort-by='~VERSION' | awk 'NR == 3 { print $2 }')
  gcloud app services set-traffic default --splits "${APPENGINE_OLDSTABLE}"=1 --quiet
  exit 1
else
  printf "All live tests passed!\n"
fi
