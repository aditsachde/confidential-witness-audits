#!/bin/bash

set -e

# Fetch admin activity logs
gcloud logging read "logName=projects/$PROJECT/logs/cloudaudit.googleapis.com%2Factivity" --freshness="400d" --format=json > admin_activity.json

# Fetch the public key so we don't need to trust the key served by the witness
gcloud kms keys versions get-public-key projects/$PROJECT/locations/us-east5/keyRings/witness-keyring/cryptoKeys/witness-key/cryptoKeyVersions/1 > public_key.pem

# Fetch the IP address of the witness
gcloud compute addresses list --format=json > ip_addresses.json

# Get details about the trusted workload pool
gcloud iam workload-identity-pools providers describe attestation-verifier --workload-identity-pool="trusted-workload-pool" --location="global" --format=json > attestation_verifier_provider.json

# Get the projects in the organization to link the project to the organization id
gcloud projects list --format=json > organization_projects.json

gcloud organizations get-iam-policy $(gcloud projects list --format=json | jq -r ".[] | select(.name == \"$PROJECT\") | .parent.id") --format=json > organization_iam_policy.json

# Get the project IAM polices
gcloud projects get-iam-policy $PROJECT --format=json > project_iam_policy.json

# Get the IAM polices on the keyring
gcloud kms keyrings get-iam-policy projects/$PROJECT/locations/us-east5/keyRings/witness-keyring --format=json > keyring_iam_policy.json

# Get the IAM polices on the key
gcloud kms keys get-iam-policy projects/$PROJECT/locations/us-east5/keyRings/witness-keyring/cryptoKeys/witness-key --format=json > key_iam_policy.json

