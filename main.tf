#creating vpc

resource "aws_vpc" "inception-vpc" {
  cidr_block       = "100.65.0.0/16"

  tags = {
    Name = "inception-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.inception-vpc.id

  tags = {
    Name = "inception-igw"
  }
}

  

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.inception-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "inception-public-rt"
  }
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.inception-managemnet-subnet.id
  route_table_id = aws_route_table.public.id
}

#subnet
resource "aws_subnet" "inception-managemnet-subnet" {

    vpc_id = aws_vpc.inception-vpc.id
    cidr_block = var.inception-managemnet-subnet
    tags = {
        Name = "inception-managemnet-subnet"
    }
  
}


resource "aws_instance" "server0" {

    ami = data.aws_ami.ubuntu.id
    instance_type = "t3a.medium"
    key_name = aws_key_pair.ec2_key.key_name
    associate_public_ip_address = true
    subnet_id = aws_subnet.inception-managemnet-subnet.id
    vpc_security_group_ids = [aws_security_group.inception_sg.id]

    tags = {
      Name = "inception_server0"

    }
  
}


resource "aws_security_group" "inception_sg" {

    name = "inception-sg"
    description = "Allowing Inbound and Outbound"
    vpc_id = aws_vpc.inception-vpc.id


    ingress  {
        description = "ssh"
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        description = "HTTP"
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {

        description = "ALL"
        protocol = "-1"  #all traffic
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "inception-sg"
    }
}