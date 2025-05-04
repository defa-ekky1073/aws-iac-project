data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [var.security_group_id]
  key_name                = var.key_name
  associate_public_ip_address = var.associate_public_ip
  iam_instance_profile    = var.iam_instance_profile
  
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }
  
  user_data = <<-EOF
              #!/bin/bash
              echo 'Installing system updates...'
              apt-get update -y
              apt-get upgrade -y
              
              echo 'Installing Python and essential packages...'
              apt-get install -y python3 python3-pip python3-boto3 nginx
              
              echo "EC2 instance setup completed"
              EOF

  tags = {
    Name    = "${var.project}-app-server"
    Project = var.project
  }
}

# Generate inventory file for Ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    app_server_public_ip = aws_instance.app_server.public_ip
    app_server_private_ip = aws_instance.app_server.private_ip
    ssh_key_path = var.ssh_key_path
  })
  filename = "${path.module}/../../../ansible/inventory.ini"
  
  depends_on = [aws_instance.app_server]
}