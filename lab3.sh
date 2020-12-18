DEFAULT_VPC_ID=vpc-d9be00b2
SECURITY_GROUP_NAME=lab3-sg
SUBNET_ID=subnet-8069cfeb   
AMAZOM_LINUX_AMI=ami-09558250a3419e7d0 

aws ec2 create-security-group  --group-name $SECURITY_GROUP_NAME --description "My security group for Lab3" --vpc-id $DEFAULT_VPC_ID
SG_ID=$(aws ec2 describe-security-groups --group-names $SECURITY_GROUP_NAME --query 'SecurityGroups[0].[GroupId]' --output text)
aws ec2 create-key-pair --key-name KeyLab3 --query 'KeyMaterial' --output text > KeyLab3.pem
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
chmod 400 KeyLab3.pem
aws ec2 run-instances --image-id $AMAZOM_LINUX_AMI --count 1 --instance-type t2.micro --key-name KeyLab3 --security-group-ids $SG_ID  --subnet-id $SUBNET_ID --user-data file://apache.sh
EC2_ID=$(aws ec2 describe-instances --query 'Reservations[0].Instances[0].[InstanceId]' --output text)
aws ec2 create-tags --resources $EC2_ID --tags Key=Role,Value=WebServer
aws ec2 create-image --instance-id  $EC2_ID --name "Lab3"
aws ec2 stop-instances --instance-ids $EC2_ID
aws ec2 run-instances --image-id ami-0a9d57097e951f261 --count 1 --instance-type t2.micro --key-name KeyLab3 --security-group-ids $SG_ID  --subnet-id $SUBNET_ID 


