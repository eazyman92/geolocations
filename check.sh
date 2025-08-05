#!/bin/bash

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082)
if [ ${STATUS_CODE} -eq "200" ]; then
  echo "The status of the smoke test is passed!"
  exit 0
else
  echo "The status of the smoke test is failed!"
  exit 1
fi
