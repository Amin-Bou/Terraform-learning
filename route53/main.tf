#HOSTED ZONE
# resource "aws_route53_zone" "main_hs" {
#   name = "aminbourenane.com"
# }

# resource "aws_route53_zone" "terraform" {
#   name = "terraform.aminbourenane.com"

#   tags = {
#     Environment = "terraform"
#   }
# }

#Data source: zone

data "aws_route53_zone" "terraform" {
  name         = "aminbourenane.com"
  private_zone = false
}


#RECORD

resource "aws_route53_record" "terraform" {
  zone_id = data.aws_route53_zone.terraform.zone_id
  name    = "terraform.aminbourenane.com"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}