resource "aws_key_pair" "my_key" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/my-key-pair.pub")  # Local public key to use for EC2 instance
}

resource "aws_instance" "AzureAgent" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key.key_name

  network_interface {
    device_index          = 0
    associate_public_ip_address = true  
    subnet_id            = aws_subnet.my_subnet.id
    security_groups      = [aws_security_group.my_security_group.name]
  }

  tags = {
    Name = "AzureAgent"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip } ansible_user=ec2-user  >> ~/Project/Agent.inv"
    ansible-playbook -i ../Agent.inv ../Playbook/Agent.yaml
  }
}