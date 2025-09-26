#!/bin/bash

echo "Testing Banking API with curl..."

# Test registration
echo "1. Testing Registration..."
curl -X POST https://challenge-api.qena.dev/api/auth/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "firstName": "asre",
    "lastName": "aser",
    "username": "asreqw2",
    "phoneNumber": "0975591723",
    "passwordHash": "Aa@12345",
    "email": "asreqw2@example.com"
  }' -v

echo -e "\n\n2. Testing Login..."
curl -X POST https://challenge-api.qena.dev/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "username": "asreqw",
    "passwordHash": "Aa@12345"
  }' -v