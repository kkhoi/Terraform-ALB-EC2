resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
#Launch Template for EC2
resource "aws_launch_template" "web_template" {
  name_prefix   = "webserver"
  image_id      = var.ami
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  key_name = "devops"

  network_interfaces {
    security_groups             = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = false
  }

  user_data = base64encode(file("install_webserver.sh"))
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}
