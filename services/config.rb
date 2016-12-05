## This file was auto-generated by CloudCoreo CLI
## This file was automatically generated using the CloudCoreo CLI
##
## This config.rb file exists to create and maintain services not related to compute.
## for example, a VPC might be maintained using:
##
## coreo_aws_vpc_vpc "my-vpc" do
##   action :sustain
##   cidr "12.0.0.0/16"
##   internet_gateway true
## end
##

## This file was automatically generated using the CloudCoreo CLI
##
## This config.rb file exists to create and maintain services not related to compute.
## for example, a VPC might be maintained using:
##
## coreo_aws_vpc_vpc "my-vpc" do
##   action :sustain
##   cidr "12.0.0.0/16"
##   internet_gateway true
## end
##

# # these three resources find the VPC/subnet you want to start this server in
# # they are :find so if they do not exist, this composite will throw an error
# # use this composite in conjunction with another composite (run before) like vpc-network-only
# #
coreo_aws_vpc_vpc "${VPC_NAME}" do
   action :find
   #cidr "${VPC_CIDR}"
   #internet_gateway true
   name "${VPC_NAME}"
end

coreo_aws_vpc_routetable "${PUBLIC_ROUTE_NAME}" do
   action :find
   vpc "${VPC_NAME}"
end

coreo_aws_vpc_subnet "${PUBLIC_SUBNET_NAME}" do
   action :find
   route_table "${PUBLIC_ROUTE_NAME}"
   vpc "${VPC_NAME}"
end

coreo_aws_ec2_securityGroups "${SERVER_NAME}${SUFFIX}" do
  action :sustain
  description "Server security group"
  vpc "${VPC_NAME}"
  allows [ 
          { 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => ${SERVER_INGRESS_PORTS},
            :cidrs => ${SERVER_INGRESS_CIDRS}
          },{ 
            :direction => :egress,
            :protocol => :tcp,
            :ports => ["0..65535"],
            :cidrs => ["0.0.0.0/0"]
          }
    ]
end


coreo_aws_ec2_instance "${SERVER_NAME}${SUFFIX}" do
  action :define
  image_id "${AWS_LINUX_AMI}"
  size "${SERVER_SIZE}"
  security_groups ["${SERVER_NAME}${SUFFIX}"]
  ssh_key "${SERVER_KEYPAIR}"
  associate_public_ip true
  upgrade_trigger "2"
  environment_variables [
         "ENV=my_env",
         "TEST=true",
         "CLOUD=coreo"
          ]
end

coreo_aws_ec2_autoscaling "${SERVER_NAME}${SUFFIX}" do
  action :sustain 
  minimum 1
  maximum 1
  server_definition "${SERVER_NAME}${SUFFIX}"
  subnet "${PUBLIC_SUBNET_NAME}"
end
