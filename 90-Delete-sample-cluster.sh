#!/usr/bin/env bash

# Function to display the confirmation prompt
function dont_confirm() {
  while true; do
		read -p "Do you want to proceed? (YES/NO/CANCEL) " yn
		case $yn in
			[Yy]* ) return 1;;
			[Nn]* ) return 0;;
			[Cc]* ) exit 1;;
			* ) echo "Please answer YES, NO, or CANCEL.";;
		esac
	done
}



#NODES="${NODES:-7}"
#NODES_MIN="${NODES_MIN:-5}"
#NODES_MAX="${NODES_MAX:-11}"

cat << CLUSTER_INFO
  Deleting cluster
	AWS_REGION=${AWS_REGION}
	EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME}

CLUSTER_INFO

if dont_confirm; then
	echo "User chose NO. Aborting the operation..."
	exit 1
else
	echo "User chose Yes."
	#echo "exit 0"
	#exit 0
fi
echo "Termination commencing for cluster '"${EKS_CLUSTER_NAME}"' of type 'minimal viable intstall - MVI'"
echo "Cluster termination commencing..."
eksctl delete cluster --name "${EKS_CLUSTER_NAME}" --region "${AWS_REGION}"

exit 0



