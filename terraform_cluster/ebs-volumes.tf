resource "aws_ebs_volume" "postgres_volume" {
  availability_zone = "eu-central-1a"
  size              = 4  # Size in GiB
  type              = "io1"
  iops              = 100

  tags = {
    Name = "postgres-volume"
  }
}

output "postgres_volume_id" {
  value = aws_ebs_volume.postgres_volume.id
}