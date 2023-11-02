#!/usr/bin/env bash

# Clean up all the IAM policies
# created for the deployment.

POLICY_MASK="${1}"

list_policies_output=`aws iam list-policies | jq -r '.Policies[] | .PolicyName' | grep "${POLICY_MASK}"`
policies=("${list_policies_output}")

#echo "list_policies_output=${list_policies_output}"
echo "${policies}"

#for role in ${policies[*]}; do
#	aws iam get-role --role-name ${role}
#done

