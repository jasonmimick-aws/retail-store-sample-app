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
  Creating cluster
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
echo "Attempting minimal viable intstall - MVI"
echo "Cluster creation commencing..."
eksctl create cluster --name "${EKS_CLUSTER_NAME}" --region "${AWS_REGION}" --fargate
eksctl utils update-cluster-logging \
	--enable-types=all \
	--region="${AWS_REGION}" \
	--cluster="${EKS_CLUSTER_NAME}"


exit 0



eksctl create cluster \
	--name "${EKS_CLUSTER_NAME}" \
	--region "${AWS_REGION}" \
	--apply

#--fargate
eksctl create nodegroup \
 --cluster "${EKS_CLUSTER_NAME}" \
 --name "${EKS_CLUSTER_NAME}-t3" \
 --apply
 --nodes "${NODES}" \
 --nodes-min "${NODES_MIN}" \
 --nodes-max "${NODES_MAX}"

eksctl utils update-cluster-logging \
	--enable-types=all \
	--region="${AWS_REGION}" \
	--cluster="${EKS_CLUSTER_NAME}"


