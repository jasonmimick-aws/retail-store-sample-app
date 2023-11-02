#!/usr/bin/env bash

# Delete IAM roles based on
# grepping input string.
# Caution:



# Function to display the confirmation prompt
function confirm() {
  while true; do
		read -p "Do you want to proceed? (YES/NO/CANCEL) " yn
		case $yn in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			[Cc]* ) exit;;
			* ) echo "Please answer YES, NO, or CANCEL.";;
		esac
	done
}

ROLE_MASK="${1}"

echo "User beware! This tool will delete all"
echo "roles matching your input string"
#echo "
#list_roles_output=`aws iam list-roles | jq -r '.Roles[] | .RoleName' | grep "${ROLE_MASK}"`
list_roles_output=$(./88-List-All-IAM-Roles-Policies.sh "${ROLE_MASK}")
roles_to_delete=("${list_roles_output}")

#echo "list_roles_output=${list_roles_output}"
echo "ROLE_MASK=${ROLE_MASK}"
echo "roles_to_delete=${roles_to_delete}"

# Example usage of the confirm function
if confirm; then
	echo "User chose YES. Executing the operation..."
	# Place your code here to execute when user confirms
	for role in ${roles_to_delete[*]}; do
		echo "Deleting Role:	${role}"
		aws iam get-role --role-name ${role}
		#aws iam delete-role --role-name ${role}
		aws iam get-role --role-name ${role}

done
else
	echo "User chose NO. Aborting the operation..."
	# Place your code here to execute when user denies
	for role in ${roles_to_delete[*]}; do
		echo "Role targetted for deletion:	${role}"
		# TODO - Add verbose/debug flag for this output
		#aws iam get-role --role-name ${role}

done
fi


