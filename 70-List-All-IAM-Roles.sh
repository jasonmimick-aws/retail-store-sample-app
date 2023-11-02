#!/usr/bin/env bash

# Clean up all the IAM roles and policies
# created for the deployment.

ROLE_MASK="${1}"

list_roles_output=`aws iam list-roles | jq -r '.Roles[] | .RoleName' | grep "${ROLE_MASK}"`
roles=("${list_roles_output}")

#echo "list_roles_output=${list_roles_output}"
echo "${roles}"

#for role in ${roles[*]}; do
#	aws iam get-role --role-name ${role}
#done

