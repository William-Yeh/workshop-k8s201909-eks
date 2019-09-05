#!/bin/bash
#
# @see https://github.com/pahud/amazon-eks-workshop/blob/master/00-getting-started/create-eks-with-eksctl.md
#

cleanup() {
  rm -rf awscli-bundle
  rm -f awscli-bundle.zip
}


echo "==> Installing aws cli..."
cleanup
rm -rf awscli-bundle*
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws


echo "==> Installing kubectl..."
curl https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/kubectl -o kubectl
chmod +x $_
sudo mv $_ /usr/local/bin/


echo "==> Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin


echo "==> Installing aws-iam-authenticator..."
curl https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator -o aws-iam-authenticator 
chmod +x $_
sudo mv $_ /usr/local/bin/


echo "==> Installing skaffold..."
curl https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 -o skaffold
chmod +x $_
sudo mv $_ /usr/local/bin/


echo "==> Done."
