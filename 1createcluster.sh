#!/bin/bash
gcloud container clusters create g-dnscrypt-uk --num-nodes=1
gcloud container clusters get-credentials g-dnscrypt-uk
