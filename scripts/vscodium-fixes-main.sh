#!/bin/bash

echo 'Enabling official MS marketplace...'
python3 vscodium-marketplace.py
echo 'Done'
echo '=============================='

echo 'Fixing ProposedAPI errors...'
python3 vscodium-proposedapi.py
echo 'Done'
echo '=============================='
echo 'All jobs finished.'
