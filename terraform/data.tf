data "aws_ssm_parameter" "jenkins_key_pair" {
  name = "/jenkins/key-pair"
}
