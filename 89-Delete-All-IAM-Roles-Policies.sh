#!/usr/bin/env bash

# Clean up all the IAM roles and policies
# created for the deployment.

ROLE_MASK="${1}"

#list_roles_output=`aws iam list-roles | jq -r '.Roles[] | .RoleName' | grep "${ROLE_MASK}"`
list_roles_output=$(./88-List-All-IAM-Roles-Policies.sh "${ROLE_MASK}")
roles_to_delete=("${list_roles_output}")

#echo "list_roles_output=${list_roles_output}"
#echo "roles_to_delete=${roles_to_delete}"

for role in ${roles_to_delete[*]}; do
	echo "deleting role---->${role}"
	aws iam get-role --role-name ${role}
	aws iam delete-role --role-name ${role}
	aws iam get-role --role-name ${role}

done

