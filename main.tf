provider "aws" {
  region = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.instance_name}-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Save the PEM file locally
resource "local_file" "private_key" {
  filename        = "${path.module}/${var.instance_name}.pem"
  content         = tls_private_key.example.private_key_pem
  file_permission = "0400"
}

# Launch the EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-075b06d55777be7cd" # Ubuntu 22.04 in ap-south-1
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated.key_name

  tags = {
    Name = var.instance_name
  }
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}

output "pem_file_path" {
  value = local_file.private_key.filename
}

output "instance_id" {
  value = aws_instance.example.id
}

output "instance_type" {
  value = aws_instance.example.instance_type
}
