output "instance_id" { value = aws_instance.this.id }
output "availability_zone" { value = aws_instance.this.availability_zone }
output "public_ip" { value = aws_instance.this.public_ip }

