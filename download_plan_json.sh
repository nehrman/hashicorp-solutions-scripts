#!/bin/bash
TFE_WORKSPACE_NAME=""
TFE_ORG_TOKEN=""
TFE_USER_TOKEN=""
TFE_URL=""
TFE_ORG=""


TFE_WORKSPACE_ID="$(curl -v -H "Authorization: Bearer ${TFE_ORG_TOKEN}" -H "Content-Type: application/vnd.api+json" "${TFE_URL}/api/v2/organizations/${TFE_ORG}/workspaces/${TFE_WORKSPACE_NAME}" | jq -r '.data.id')"
echo "Workspace ID: " $TFE_WORKSPACE_ID

TFE_RUN_ID=$(curl -v -H "Authorization: Bearer ${TFE_ORG_TOKEN}" -H "Content-Type: application/vnd.api+json" ${TFE_URL}/api/v2/workspaces/${TFE_WORKSPACE_ID}/runs | python3 -c "import sys, json; print(json.load(sys.stdin)['data'][0]['id'])")
echo "Run ID: " $TFE_RUN_ID

download_plan="true"

if [ "$download_plan" = "true" ]
    then
        echo "Getting the result of the Terraform Plan."
            plan_result=$(curl -s --header "Authorization: Bearer ${TFE_USER_TOKEN}" --header "Content-Type: application/vnd.api+json" ${TFE_URL}/api/v2/runs/${TFE_RUN_ID}?include=plan)
            plan_json_url=$(echo $plan_result | python3 -c "import sys, json; print(json.load(sys.stdin)['included'][0]['links']['json-output'])")
        echo "Plan Json Output:"
            curl -s -H "Authorization: Bearer ${TFE_USER_TOKEN}" -H "Content-Type: application/vnd.api+json" --location ${TFE_URL}/$plan_json_url | jq . > json-output.json
fi
