#Create a new VPC in AWS
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "eCommerce-VPC"
  }
}

#AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}


# Security Group Resources
resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-alb-security-group"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-alb-security-group"
  }
}
resource "aws_security_group" "asg_security_group" {
  name        = "${var.environment}-asg-security-group"
  description = "ASG Security Group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-asg-security-group"
  }
}


/*Internet Gateway: a network device that allows traffic to flow between your VPC and the internet. 
It is a fundamental component of any VPC network.*/
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "eCommerce_internet_gateway"
  }
}

#Creating 4Subnets, 2Private, 2public
/*The public subnet will have a public IP address assigned to each instance that is launched in it, while 
the private subnet will not. This allows you to control which instances are accessible from the 
internet and which are not.*/

#2Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-public-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}
#2Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-private-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}


/*Route table for public subnets, this ensures that all instances launched in 
public subnet will have access to the internet*/
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

#Elastic IP 
/*An EIP is a public IP address that can be assigned to an instance or load balancer. EIPs can be used to 
make your instances accessible from the internet.*/
resource "aws_eip" "elastic_ip" {
  tags = {
    Name = "${var.environment}-elastic-ip"
  }
}


#AWS NAT Gateway:  
/*is a network device that allows instances in a private subnet to access the internet. 
It does this by translating the private IP addresses of the instances to public IP addresses.*/
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "eCommerce-VPC-InternetGateway"
  }
}

#AWS Route-Table:  A route table is a collection of routes that determines how traffic is routed within a VPC. 
/*In this case, the route table will route all traffic to the NAT gateway, which will then forward the traffic 
to the internet.*/
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

#Create two route table associations, one for the public subnet and one for the private subnet.
#public subnet will be associated with the public route table
resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
#Private subnet will be associated with the private route table
resource "aws_route_table_association" "private_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
/*This will ensure that instances in the public subnet can access the internet, and instances in the 
private subnet can only access resources within the VPC.*/