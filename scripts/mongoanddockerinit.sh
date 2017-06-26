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
echo "[mongodb-org-3.2]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/\ngpgcheck=1\nenabled=1\ngpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc\n" > /etc/yum.repos.d/mongodb-org-3.2.repo
sudo yum -y update
# Install mongo server, shell and tools
sudo yum install -y mongodb-org-server mongodb-org-shell mongodb-org-tools
# Start the server and create the admin user
sudo mongod --fork --logpath /var/log/mongod.log
sudo mongo --eval "db = db.getSiblingDB('admin'); db.createUser({ user: '$USERNAME', pwd: '$PASSWORD',  roles: [ { role: 'userAdminAnyDatabase', db: 'admin' } ]})"
# Restart the server with authentication
sudo mongod --shutdown
sudo mongod --fork --auth --logpath /var/log/mongod.log
