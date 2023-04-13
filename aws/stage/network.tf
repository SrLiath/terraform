#Create an Elastic IP
resource "aws_eip" "stage_eip" {
  vpc = true
}

#Associate EIP with EC2 Instance
resource "aws_eip_association" "stage_eip_association" {
  instance_id   = aws_instance.stage_instance.id
  allocation_id = aws_eip.stage_eip.id
}

#Create a public subnet
resource "aws_subnet" "stage_public_subnet" {
  vpc_id     = aws_vpc.stage_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.env}_public_subnet"
  }
}

#Create a Internet Gateway
resource "aws_internet_gateway" "stage_igw" {
  vpc_id = aws_vpc.stage_vpc.id

  tags = {
    Name = "${var.env}_igw"
  }
}

#Create a route table
resource "aws_route_table" "stage_rt" {
  vpc_id = aws_vpc.stage_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stage_igw.id
  }

  tags = {
    Name = "_rt"
  }
}

#Default route to acess internet
resource "aws_route" "stage_routetointernet" {
  route_table_id            = aws_route_table.stage_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.stage_igw.id
}

#Associate public Subnet with the route
resource "aws_route_table_association" "stage_pub_association" {
  subnet_id      = aws_subnet.stage_public_subnet.id
  route_table_id = aws_route_table.stage_rt.id
}