# ------ ./modules/networking/main.tf ------

# Description of the VPC
resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.environment}-vpc"
        Environment = "${var.environment}"
    }
}

# Subnets Definitions
# Internet Gateway for the public subnet
resource "aws_internet_gateway" "ig" {
    vpc_id = "${aws_vpc.vpc.id}"

    tags = {
        Name = "${var.environment}-igw"
        Environment = "${var.environment}"
    }
}

# NAT
resource "aws_nat_gateway" "nat" {
    count = "${length(var.availability_zones)}"
    allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    depends_on = [aws_internet_gateway.ig]

    tags = {
        Name = "${var.environment}-${element(var.availability_zones, count.index)}-nat"
        Environment = "${var.environment}"
    }
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
    count = "${length(var.availability_zones)}"
    vpc = true
    depends_on = [aws_internet_gateway.ig]

    tags = {
        Name = "${var.environment}-${element(var.availability_zones, count.index)}-eip"
        Environment = "${var.environment}"
    }
}



# Public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id = "${aws_vpc.vpc.id}"
    count = "${length(var.public_subnets_cidr)}"
    cidr_block = "${element(var.public_subnets_cidr, count.index)}"
    availability_zone = "${element(var.availability_zones, count.index)}"
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
        Environment = "${var.environment}"
    }
}

# Private subnet
resource "aws_subnet" "private_subnet" {
    vpc_id = "${aws_vpc.vpc.id}"
    count = "${length(var.private_subnets_cidr)}"
    cidr_block = "${element(var.private_subnets_cidr, count.index)}"
    availability_zone = "${element(var.availability_zones, count.index)}"
    map_public_ip_on_launch = false

    tags = {
        Name = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
        Environment = "${var.environment}"
    }
}

# Routing table for private subnet
resource "aws_route_table" "private" {
    count = "${length(var.availability_zones)}"
    vpc_id = "${aws_vpc.vpc.id}"

    tags = {
        Name = "${var.environment}-private-route-table"
        Environment = "${var.environment}"
    }
}

# Routing table for public subnet
resource "aws_route_table" "public" {
    count = "${length(var.availability_zones)}"
    vpc_id = "${aws_vpc.vpc.id}"

    tags = {
        Name = "${var.environment}-public-route-table"
        Environment = "${var.environment}"
    }
}

resource "aws_route" "public_internet_gateway" {
    count = "${length(var.availability_zones)}"
    # route_table_id = "${aws_route_table.public.id}"
    route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
}

resource "aws_route" "private_nat_gateway" {
    count = "${length(var.availability_zones)}"
    # route_table_id = "${aws_route_table.private.id}"
    route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
}

# Route table associations
resource "aws_route_table_association" "public" {
    count = "${length(var.public_subnets_cidr)}"
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    # route_table_id = "${aws_route_table.public.id}"
    route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
    count = "${length(var.private_subnets_cidr)}"
    subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}


################################################################################
# Private Subnet for RDS
################################################################################

# Private DB subnet
resource "aws_subnet" "private_subnet_db" {
    vpc_id = "${aws_vpc.vpc.id}"
    count = "${length(var.private_db_subnets_cidr)}"
    cidr_block = "${element(var.private_db_subnets_cidr, count.index)}"
    availability_zone = "${element(var.availability_zones, count.index)}"
    map_public_ip_on_launch = false

    tags = {
        Name = "${var.environment}-${element(var.availability_zones, count.index)}-private-db-subnet"
        Environment = "${var.environment}"
    }
}

# Routing table for private subnet
resource "aws_route_table" "private_db" {
    count = "${length(var.availability_zones)}"
    vpc_id = "${aws_vpc.vpc.id}"

    tags = {
        Name = "${var.environment}-private-route-table-db"
        Environment = "${var.environment}"
    }
}

resource "aws_route_table_association" "private_db" {
    count = "${length(var.private_db_subnets_cidr)}"
    subnet_id = "${element(aws_subnet.private_subnet_db.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.private_db.*.id, count.index)}"
}


################################################################################
# Subnet Groups for RDS
################################################################################
resource "aws_db_subnet_group" "mysubnetgroup" {
  name = "${var.subnate_group_name}-${var.environment}"
  subnet_ids = aws_subnet.private_subnet_db[*].id

  tags = {
    Environment = "${var.environment}"
  }
}
