resource "aws_instance" "cheap_worker" {
  count                     = local.LENGTH
  ami                       = "ami-074df373d6bafa625"
  instance_type             = "t3.micro"
  vpc_security_group_ids    =  [aws_security_group.allow_ssh_single_server.id]
  tags                      = {
    Name                    = element(var.COMPONENTS, count.index)
  }
}

resource "aws_ec2_tag" "name-tag" {
   count                     = local.LENGTH
   resource_id               = element(aws_instance.cheap_worker.*.public_ip, count.index)
   key                       = "Name"
   value                     = element(var.COMPONENTS, count.index)
 }

resource "aws_security_group" "allow_ssh_single_server" {
    name            = "allow_ssh_single_server"
    description     = "allow_ssh_single_server"
    
    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}




resource "aws_route53_record" "records" {
  count                     = local.LENGTH
  name                      = element(var.COMPONENTS, count.index)
  type                      = "A"
  zone_id                   = "Z04058843B1ZOXKPWHN2J"
  ttl                       = 300
  records                   = [element(aws_instance.cheap_worker.*.private_ip, count.index)]
}



locals {
  LENGTH    = length(var.COMPONENTS)
}


resource "local_file" "inventory-file" {
  content     = "[FRONTEND]\n${aws_instance.instances.*.private_ip[9]}\n[PAYMENT]\n${aws_instance.instances.*.private_ip[8]}\n[SHIPPING]\n${aws_instance.instances.*.private_ip[7]}\n[USER]\n${aws_instance.instances.*.private_ip[6]}\n[CATALOGUE]\n${aws_instance.instances.*.private_ip[5]}\n[CART]\n${aws_instance.instances.*.private_ip[4]}\n[REDIS]\n${aws_instance.instances.*.private_ip[3]}\n[RABBITMQ]\n${aws_instance.instances.*.private_ip[2]}\n[MONGODB]\n${aws_instance.instances.*.private_ip[1]}\n[MYSQL]\n${aws_instance.instances.*.private_ip[0]}\n"
  filename    = "/tmp/inv-roboshop-${var.ENV}"
}