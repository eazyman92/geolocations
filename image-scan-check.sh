#!/bin/bash

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
