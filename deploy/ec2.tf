resource "aws_instance" "instances" {
  count                     = local.LENGTH
  ami                       = "ami-074df373d6bafa625"
  instance_type             = "t3.micro"
  vpc_security_group_ids    =  ["sg-04371d9790f1294b1"]
  tags                      = {
    Name                    = element(var.COMPONENTS, count.index)
  }
}


resource "aws_route53_record" "records" {
  count                     = local.LENGTH
  name                      = element(var.COMPONENTS, count.index)
  type                      = "A"
  zone_id                   = "Z00620242Y7LFBGQOS2W8"
  ttl                       = 300
  records                   = [element(aws_instance.instances.*.private_ip, count.index)]
}



resource "null_resource" "run-shell-scripting" {
  depends_on                = [aws_route53_record.records]
  count                     = local.LENGTH
  provisioner "remote-exec" {
    connection {
      host                  = element(aws_instance.instances.*.public_ip, count.index)
      user                  = "centos"
      password              = "DevOps321"
    }

    inline = [
    "cd /home/centos",
    "rm -rf *",
    "git clone https://DevOps-Batches@dev.azure.com/DevOps-Batches/DevOps57/_git/shell-scripting",
    "cd shell-scripting/roboshop",
    "git pull",
    "sudo make ${element(var.COMPONENTS, count.index)}"
    ]
  }
}


resource "local_file" "inventory-file" {
  content     = "[FRONTEND]\n${aws_instance.instances.*.private_ip[9]}\n[PAYMENT]\n${aws_instance.instances.*.private_ip[8]}\n[SHIPPING]\n${aws_instance.instances.*.private_ip[7]}\n[USER]\n${aws_instance.instances.*.private_ip[6]}\n[CATALOGUE]\n${aws_instance.instances.*.private_ip[5]}\n[CART]\n${aws_instance.instances.*.private_ip[4]}\n[REDIS]\n${aws_instance.instances.*.private_ip[3]}\n[RABBITMQ]\n${aws_instance.instances.*.private_ip[2]}\n[MONGODB]\n${aws_instance.instances.*.private_ip[1]}\n[MYSQL]\n${aws_instance.instances.*.private_ip[0]}\n"
  filename    = "/tmp/inv-roboshop"
}

locals {
  LENGTH    = length(var.COMPONENTS)
}