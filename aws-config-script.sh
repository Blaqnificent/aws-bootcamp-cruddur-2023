#!/bin/bash

set -e  # Exit on any error

PROFILE_NAME="blaqnificent-admin"

echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

# Detect system architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" ]]; then
    AWS_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
else
    AWS_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
fi

echo "⬇️  Downloading AWS CLI for $ARCH..."
curl "$AWS_URL" -o "awscliv2.zip"

echo "📦 Unzipping AWS CLI..."
unzip -q awscliv2.zip

echo "⚙️  Installing AWS CLI..."
sudo ./aws/install

# Verify install
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI installation failed"
    exit 1
fi

echo "🧹 Cleaning up..."
rm -rf aws awscliv2.zip

# Enable AWS CLI auto prompt
export AWS_CLI_AUTO_PROMPT="on-partial"

# Configure AWS SSO with named profile
echo "🛠️  Setting up profile [$PROFILE_NAME]..."
aws configure set sso_start_url https://d-91671e396c.awsapps.com/start --profile $PROFILE_NAME
aws configure set sso_region us-west-1 --profile $PROFILE_NAME
aws configure set sso_account_id 144772165212 --profile $PROFILE_NAME
aws configure set sso_role_name AdministratorAccess --profile $PROFILE_NAME
aws configure set region us-west-1 --profile $PROFILE_NAME

# Make this profile the default
echo "🎯 Setting [$PROFILE_NAME] as the default profile..."
aws configure set profile.default.sso_start_url https://d-91671e396c.awsapps.com/start
aws configure set profile.default.sso_region us-west-1
aws configure set profile.default.sso_account_id 144772165212
aws configure set profile.default.sso_role_name AdministratorAccess
aws configure set region us-west-1

# Start SSO login
echo "🔐 Logging in with default profile ([$PROFILE_NAME])..."
aws sso login

echo "🎉 AWS CLI is ready to use without --profile!"
