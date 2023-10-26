#!/usr/bin/env bash

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


