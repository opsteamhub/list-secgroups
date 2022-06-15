#!/bin/bash

#set tcp ports numbers on array "ports"
ports=(22 3389 3306 5432 27017)

#set name of regions on array "regions"
regions=("us-east-1" "sa-east-1")

#get & print number of AWS account
myaccount=$(aws sts get-caller-identity --query Account --output text)

echo -e "Account ID: $myaccount\n"

ri=0
rlen=${#regions[@]}
while [ $ri -lt $rlen ]
do
    echo -e '\nRegion: '${regions[$ri]}
    pi=0
    plen=${#ports[@]}
    while [ $pi -lt $plen ]
    do
        echo 'Port: '${ports[$pi]}
        aws ec2 describe-security-groups \
            --filters Name=ip-permission.from-port,Values=${ports[$pi]} Name=ip-permission.to-port,Values=${ports[$pi]} Name=ip-permission.cidr,Values='0.0.0.0/0' \
            --query 'SecurityGroups[?IpPermissions[?ToPort==`'${ports[$pi]}'` && contains(IpRanges[].CidrIp, `0.0.0.0/0`)]].{GroupId: GroupId, GroupName: GroupName}' \
            --output text \
            --region ${regions[$ri]};
        let pi++
        echo -e "\n"
    done
    echo "============================="
    let ri++
done