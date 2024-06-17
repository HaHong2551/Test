#!/bin/bash
set -xe

sudo apt update 
sudo apt install -y libcurl4
sudo apt install -y unzip software-properties-common python3 python3-pip
python3 -m pip install --upgrade pip
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
mkdir ~/.ssh
echo ${DEPLOY_KEY} | base64 --decode >> ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa