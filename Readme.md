# Puppet Master-Slave Setup on AWS

This Terraform script sets up a Puppet Master and Slave configuration on AWS EC2 instances.

## Overview

The script creates:
1. An AWS Security Group allowing all TCP traffic
2. A Puppet Master EC2 instance
3. A Puppet Slave EC2 instance

## Prerequisites

- AWS account
- Terraform installed
- AWS CLI configured with your credentials

## Usage

1. Clone this repository
2. Update the `provider` block with your AWS credentials:
   ```hcl
   provider "aws" {
     region     = "ap-south-1"
     access_key = "YOUR_ACCESS_KEY"
     secret_key = "YOUR_SECRET_KEY"
   }
3. Replace "puppet" in the key_name fields with your EC2 key pair name
4. Run terraform init to initialize Terraform
5. Run terraform apply to create the infrastructure
6. After creation, Terraform will output the instance IDs and public IPs

## Cleanup
To remove all created resources:
1. Run terraform destroy.
2. Confirm by typing 'yes' when prompted

## Security Notes

1. The security group allows all TCP traffic from anywhere. This is not recommended for production use. Restrict the ingress and egress rules to only necessary ports and IP ranges.

2. AWS credentials are hardcoded in the script. For better security:
   - Use AWS CLI profiles
   - Use environment variables
   - Use IAM roles for EC2 instances

3. The script uses a public AMI. Always verify the integrity and source of AMIs before use.

4. User data scripts are used to set up the instances. These scripts are not encrypted and may be visible in the EC2 console.

5. The Puppet Master's Java args are set to use 512MB of memory. Adjust this based on your needs and instance size.

6. The script opens port 8140 on the Puppet Master. Ensure this port is necessary and restrict access if possible.

7. Consider using HTTPS for Puppet communication and setting up proper certificates.

8. The current setup doesn't include any authentication between Master and Slave. Implement proper authentication mechanisms for production use.

## Customization

- Adjust the instance types (`t2.medium` for Master, `t2.micro` for Slave) as needed
- Modify the AMI ID if you want to use a different base image
- Add more security group rules or EC2 instances as required

Always review and test the script thoroughly before using it in any production environment.