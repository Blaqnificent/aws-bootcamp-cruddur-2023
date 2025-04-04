#!/bin/bash

set -e  # Exit on error

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

# Enable AWS CLI auto prompt permanently
echo "✨ Making AWS_CLI_AUTO_PROMPT persistent..."
SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if ! grep -q "AWS_CLI_AUTO_PROMPT" "$SHELL_RC"; then
    echo 'export AWS_CLI_AUTO_PROMPT=on-partial' >> "$SHELL_RC"
    echo "✅ Added AWS_CLI_AUTO_PROMPT to $SHELL_RC"
else
    echo "ℹ️  AWS_CLI_AUTO_PROMPT already set in $SHELL_RC"
fi

# Apply the change to the current session
export AWS_CLI_AUTO_PROMPT=on-partial

# Start login
echo "🔐 Logging in with default profile..."
aws sso login

echo "🎉 AWS CLI is ready to go with SSO and auto-prompt!"
