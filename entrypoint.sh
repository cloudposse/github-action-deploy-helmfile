#!/bin/bash -l

set -e

export APPLICATION_HELMFILE=$(pwd)/${HELMFILE_PATH}/${HELMFILE}

DEBUG_ARGS=""

if [[ "${HELM_DEBUG}" == "true" ]]; then
#	helmfile --namespace ${NAMESPACE} --environment ${ENVIRONMENT} --file /deploy/helmfile.yaml template
	DEBUG_ARGS=" --debug"
fi

if [[ "${OPERATION}" == "deploy" ]]; then

	OPERATION_COMMAND="helmfile --namespace ${NAMESPACE} --environment ${ENVIRONMENT} --file /deploy/helmfile.yaml $DEBUG_ARGS apply"
	echo "Executing: ${OPERATION_COMMAND}"
	${OPERATION_COMMAND}

	RELEASES=$(helmfile --namespace ${NAMESPACE} --environment ${ENVIRONMENT} --file /deploy/helmfile.yaml list --output json | jq .[].name -r)
	for RELEASE in ${RELEASES}
  do
  	ENTRYPOINT=$(kubectl --namespace ${NAMESPACE} get -l release=${RELEASE} ingress --output=jsonpath='{.items[*].metadata.annotations.outputs\.platform\.cloudposse\.com/webapp-url}')
  	if [[ "${ENTRYPOINT}" != "" ]]; then
  		echo "::set-output name=webapp-url::${ENTRYPOINT}"
  	fi
  done



elif [[ "${OPERATION}" == "destroy" ]]; then

	set +e
	kubectl get ns ${NAMESPACE}
	NAMESPACE_EXISTS=$?
	set -e

	if [[ ${NAMESPACE_EXISTS} -eq 0  ]]; then
		OPERATION_COMMAND="helmfile --namespace ${NAMESPACE} --environment ${ENVIRONMENT} --file /deploy/helmfile.yaml $DEBUG_ARGS destroy"
		echo "Executing: ${OPERATION_COMMAND}"
		${OPERATION_COMMAND}

		RELEASES_COUNTS=$(helm --namespace ${NAMESPACE} list --output json | jq 'length')

    if [[ "${RELEASES_COUNTS}" == "0" ]]; then
    	kubectl delete ns ${NAMESPACE}
    fi
	fi
fi


