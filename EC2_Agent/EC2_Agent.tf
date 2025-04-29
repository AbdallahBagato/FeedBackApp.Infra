resource "aws_key_pair" "my_key" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/my-key-pair.pub")  # Local public key to use for EC2 instance
}

resource "aws_instance" "AzureAgent" {
  ami           = "ami-0e449927258d45bc4"  # Example Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key.key_name
  
  associate_public_ip_address = true  
  subnet_id            = aws_subnet.Zone1.id
  security_groups      = [aws_security_group.eks_sg.id]

  tags = {
    Name = "AzureAgent"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip } ansible_user=ec2-user  > ~/Project/Agent.inv  && ansible-playbook -i ../Agent.inv ../Playbook/Agent.yaml  --ssh-extra-args='-o StrictHostKeyChecking=no'"
  }
}