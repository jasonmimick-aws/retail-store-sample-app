#!/usr/bin/env bash
echo "This needs to get fixed, the node-type failed - TODO/ Find minimal cost
deployment and maybe even build this out to _prove_ it"

exit 1
eksctl create cluster \
	--name "${EKS_CLUSTER_NAME}" \
	--region "${AWS_REGION}" \

#--fargate
eksctl create nodegroup \
 --cluster "${EKS_CLUSTER_NAME}" \
 --name "${EKS_CLUSTER_NAME}-t3" \
 --node-type t3.micro \
 --node-ami auto \
 --nodes 10 \
 --nodes-min 5 \
 --nodes-max 20

eksctl utils update-cluster-logging \
	--enable-types=all \
	--region="${AWS_REGION}" \
	--cluster="${EKS_CLUSTER_NAME}"


