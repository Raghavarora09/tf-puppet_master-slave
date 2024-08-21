provider "aws" {
  access_key = "****"
  secret_key = "****"
  region     = "ap-south-1"
}

resource "aws_security_group" "allow_all_tcp" {
  name        = "allow_all_tcp"
  description = "Allow all TCP traffic from anywhere"
  
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "puppet_master" {
  ami           = "ami-0c2af51e265bd5e0e" 
  instance_type = "t2.medium"
  key_name      = "puppet"
  security_groups = [aws_security_group.allow_all_tcp.name]

  user_data = <<-EOF
                #!/bin/bash
                apt-get update

                apt-get install -y wget

                PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/private-ipv4)

                echo "$PRIVATE_IP puppet" >> /etc/hosts

                wget https://apt.puppetlabs.com/puppet-release-bionic.deb
                dpkg -i puppet-release-bionic.deb
                apt-get update
                apt-get install -y puppet-master
                apt policy puppet-master

                echo 'JAVA_ARGS="-Xms512m -Xmx512m"' >> /etc/default/puppet-master

                systemctl restart puppet-master.service

                ufw allow 8140/tcp
              EOF

  tags = {
    Name = "Master"
  }
}

resource "aws_instance" "puppet_slave" {
  ami           = "ami-0c2af51e265bd5e0e" 
  instance_type = "t2.micro"
  key_name      = "puppet"
  security_groups = [aws_security_group.allow_all_tcp.name]

  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y wget

                # Retrieve the Puppet Master's private IP
                MASTER_IP=${aws_instance.puppet_master.private_ip}

                # Configure /etc/hosts with the Puppet Master's IP
                echo "$MASTER_IP puppet" >> /etc/hosts

                wget https://apt.puppetlabs.com/puppet-release-bionic.deb
                dpkg -i puppet-release-bionic.deb
                apt-get update
                apt-get install -y puppet

                systemctl start puppet
                systemctl enable puppet
              EOF

  tags = {
    Name = "Slave"
  }
}

output "master_instance_id" {
  value = aws_instance.puppet_master.id
}

output "master_private_ip" {
  value = aws_instance.puppet_master.private_ip
}

output "slave_instance_id" {
  value = aws_instance.puppet_slave.id
}

output "slave_private_ip" {
  value = aws_instance.puppet_slave.private_ip
}
