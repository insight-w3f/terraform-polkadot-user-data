
resource "aws_instance" "standard" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data     = module.standard.user_data

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 2
  }
}

module "standard" {
  source         = "../.."
  driver_type    = "standard"
  cloud_provider = "aws"
}

resource "random_pet" "nitro" {
  length = 2
}

resource "aws_instance" "nitro" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  user_data     = module.nitro.user_data

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 2
  }
}

module "nitro" {
  source         = "../.."
  driver_type    = "nitro"
  cloud_provider = "aws"
}
