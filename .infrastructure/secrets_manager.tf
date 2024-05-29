resource "aws_secretsmanager_secret" "secret_key_base" {
  name                    = "${local.name}-phoenix-secret-key-base"
  description             = "Secret key base for Phoenix apps"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "secret_key_base" {
  secret_id     = aws_secretsmanager_secret.secret_key_base.id
  secret_string = random_password.secret_key_base.result
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  subnet_ids          = module.vpc.private_subnets

  tags = {
    Name = "secretsmanager-endpoint"
  }
}
