#!/bin/bash
USERNAME=""
PASSWORD=""

function usage() {
	echo "usage: mongoanddockerinit.sh -u <username> -p <password>"
}

while [ "$1" != "" ]; do
    case $1 in
        -u | --username ) 	shift
                                USERNAME=$1
                                ;;
	-p | --password )	shift
				PASSWORD=$1
				;;
        -h | --help ) usage
                                exit
                                ;;
        * ) usage
                                exit 1
    esac
    shift
done

if [[ $USERNAME = "" || $PASSWORD = "" ]]; then
	usage
	exit
fi

# Create a filesystem on the mounted volume\n",
sudo mkfs -t ext4 /dev/xvdh
sudo mkdir -p /data/db
sudo mount /dev/xvdh /data/db

# Setup the repository for installing mongo
cat << 'YOF' > /etc/yum.repos.d/mongodb-org-3.2.repo
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
YOF

sudo yum -y update
# Install mongo server, shell and tools
sudo yum install -y mongodb-org-server mongodb-org-shell mongodb-org-tools
# Start the server and create the admin user
sudo mongod --fork --logpath /var/log/mongod.log
sudo mongo --eval "db = db.getSiblingDB('admin'); db.createUser({ user: '$USERNAME', pwd: '$PASSWORD',  roles: [ { role: 'root', db: 'admin' } ]})"
# Restart the server with authentication
sudo mongod --shutdown
sudo mongod --fork --auth --logpath /var/log/mongod.log

# Install dotnet core: https://www.microsoft.com/net/core#linuxcentos
sudo yum install -y libunwind libicu
curl -sSL -o dotnet.tar.gz https://go.microsoft.com/fwlink/?linkid=848821
sudo mkdir -p /opt/dotnet && sudo tar zxf dotnet.tar.gz -C /opt/dotnet
sudo ln -s /opt/dotnet/dotnet /usr/local/bin

# This section currently throws an error on amazon linux
# Install docker CE: https://docs.docker.com/engine/installation/linux/docker-ce/centos/#install-docker-ce
#sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# #sudo yum-config-manager --enable docker-ce-edge
# #sudo yum-config-manager --enable docker-ce-testing
# #sudo yum-config-manager --disable docker-ce-edge
# sudo yum makecache fast
# sudo yum install docker-ce

# Install the CodeDeploy agent
sudo yum install -y ruby wget
cd /home/ec2-user
# TODO: How to parameterize this script for different regions??
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
# Print agent status
sudo service codedeploy-agent status
