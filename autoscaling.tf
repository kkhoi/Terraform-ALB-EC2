resource "aws_autoscaling_group" "ec2_asg" {
  name             = "webserver_asg"
  desired_capacity = var.desired_capacity
  max_size         = 3
  min_size         = 1
  vpc_zone_identifier = aws_subnet.private_subnet[*].id

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}
