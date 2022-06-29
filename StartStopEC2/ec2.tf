#Grabbing latest Linux 2 AMI
data "aws_ami" "linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Demo EC2 Deploy
resource "aws_instance" "demo-ec2" {
  ami                    = data.aws_ami.linux2.id
  instance_type          = var.instance_type["type1"]
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags                   = merge({ Name = "${var.name-prefix}-ec2" }, { Auto-StartStop-Enabled = "true" })

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    tags                  = { Name = "${var.name-prefix}-ebs" }
  }
}