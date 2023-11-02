#!/usr/bin/env bash

# Delete IAM policies based on
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

POLICY_MASK="${1}"

echo "User beware! This tool will delete all"
echo "policies matching your input string"
#echo "
#list_policies_output=`aws iam list-policies | jq -r '.Policies[] | .PolicyName' | grep "${POLICY_MASK}"`
list_policies_output=$(./71-List-All-IAM-Policies.sh "${POLICY_MASK}")
policies_to_delete=("${list_policies_output}")

#echo "list_policies_output=${list_policies_output}"
echo "POLICY_MASK=${POLICY_MASK}"
echo "policies_to_delete=${policies_to_delete}"

# Example usage of the confirm function
if confirm; then
	echo "User chose YES. Executing the operation..."
	# Place your code here to execute when user confirms
	for policy in ${policies_to_delete[*]}; do
		echo "Deleting Policy:	${policy}"
		aws iam get-policy --policy-name ${policy}
		#aws iam delete-policy --policy-name ${policy}
		aws iam get-policy --policy-name ${policy}

done
else
	echo "User chose NO. Aborting the operation..."
	# Place your code here to execute when user denies
	for policy in ${policies_to_delete[*]}; do
		echo "Policy targetted for deletion:	${policy}"
		# TODO - Add verbose/debug flag for this output
		#aws iam get-policy --policy-name ${policy}

done
fi


