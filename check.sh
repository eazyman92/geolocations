#!/bin/bash

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082 -L)
if [ ${STATUS_CODE} -eq "200" ]; then
  echo "The status of the smoke test is passed!"
  exit 0
else
  echo "The status of the smoke test is failed!"
  exit 1
fi

echo "=============================================================="
echo "CHECKING FOR HIGH AND/OR CRITICAL VULNERABILITIES IN THE IMAGE"
echo "=============================================================="

grep -E "HIGH|CRITICAL" image-report.html > /dev/null
if [ $? -ne 0 ]; then
  echo "================================="
  echo "Docker Image has no vulnerability"
  echo "================================="

else
  echo "=============================="
  echo "Docker Image has vulnerability"
  echo "=============================="
fi
  
