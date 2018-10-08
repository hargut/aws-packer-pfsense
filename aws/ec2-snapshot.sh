#!/bin/bash

TIMESTAMP="$(date +%Y%M%d_%H%M%S)"

if [[ ${1} == "" ]]; then
	echo "Usage: ${0} qemu|vbox"
	exit 1
else
	BUILDER=${1}
fi

PROFILE="playground"

# print command for configuring the aws profile 
echo "aws configure --profile ${PROFILE}"

BUCKET="ec2-vm-import-3284a153f2ed"
IMAGE="$(ls -1tr ../output-${BUILDER}/ | tail -n1)"

echo "Copy image to S3 Bucket ..."
aws s3 cp --profile ${PROFILE} ../output-${BUILDER}/${IMAGE} s3://${BUCKET}/${IMAGE}

IMAGEFORMAT="$(echo ${IMAGE} | rev | cut -d "." -f1 | rev)"
IMPORTSNAPSHOT="import-snapshot_${TIMESTAMP}.json"

cp import-snapshot.json ${IMPORTSNAPSHOT}
sed -i s/FORMAT_PLACEHODLER/${IMAGEFORMAT}/g ${IMPORTSNAPSHOT}
sed -i s/BUCKET_PLACEHODLER/${BUCKET}/g ${IMPORTSNAPSHOT}
sed -i s/IMAGE_PLACEHODLER/${IMAGE}/g ${IMPORTSNAPSHOT}

echo "Import image as EC2 snapshot ..."
# print output to stdout, capture ImporTaskId
IMPORTTASKID=$(aws ec2 --profile ${PROFILE} import-snapshot --disk-container file://${IMPORTSNAPSHOT} | tee /dev/tty | grep ImportTaskId | cut -d \" -f 4)

# print command for following snapshot import status
echo aws ec2 --profile ${PROFILE} describe-import-snapshot-tasks --import-task-id ${IMPORTTASKID}

rm ${IMPORTSNAPSHOT}
