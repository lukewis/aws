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

sudo mongo --eval "db = db.getSiblingDB('admin'); db.createUser({ user: '$USERNAME', pwd: '$PASSWORD',  roles: [ { role: 'userAdminAnyDatabase', db: 'admin' } ]})"
