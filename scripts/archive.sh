#!/bin/sh
source /home/root/scripts/config.txt

GREEN='\033[0;32m'
NC='\033[0m' # No Color

log(){
	printf "${GREEN}$1${NC}\n"
}

createPackageName(){
	log " "
	log "	Creating new package name..."
	log " "
	date_string=`date +"%Y_%m_%d-%H_%M_%S"`
	random_string=`< /dev/urandom tr -dc A-Za-z0-9 | head -c20`
	reboot_count=`cat ${reboot_count_file}`
	NEW_PACKAGE_NAME="${reboot_count}_${date_string}_${random_string}.tar"	

	log "Creating new package ${NEW_PACKAGE_NAME} ..."
	echo "0" > ${package_size_file}
	echo "${NEW_PACKAGE_NAME}" > ${package_name_file}
}

# *****
# START
# *****
if [ -z "$1" ]; then
	log "missing file prefix param"
	exit -1
fi	

FILES_PREFIX=$1

mkdir -p $data_packages_dir
mkdir -p $data_dir

# load current package datapoint count
# load current package name
CURRENT_PACKAGE_NAME=`cat $package_name_file`
CURRENT_PACKAGE_SIZE=`cat $package_size_file`

# if count > ${max_package_size} || count == null || package_name == null         -> create new package
if [ -z "${CURRENT_PACKAGE_SIZE}" ] || [ -z "${CURRENT_PACKAGE_NAME}" ] || (( "${CURRENT_PACKAGE_SIZE}" >= "${max_package_size}" )); then
   createPackageName
   PACKAGE_NAME=$NEW_PACKAGE_NAME
else
   	# else use the current package
	PACKAGE_NAME=$CURRENT_PACKAGE_NAME
fi

log "Appending files..."
log " "
count=`cat ${package_size_file}`
count=$((count+1))
echo ${count} > ${package_size_file}
log "Incremented CURRENT_PACKAGE_SIZE="${count}

PACKAGE_PATH="${data_packages_dir}/${PACKAGE_NAME}"
PACKAGE_FILES="${FILES_PREFIX}""*"
log " "
log "Package paht: "$PACKAGE_PATH
log "Package files: "$PACKAGE_FILES
log " "
log " "

cd ${data_dir}

for f in "${PACKAGE_FILES}"; do
  log "Adding files -> $f"
  tar -rvf $PACKAGE_PATH $f
done

rm -fr $PACKAGE_FILES



