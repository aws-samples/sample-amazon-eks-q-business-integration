#!/bin/bash
PROJECT_DIR="$(cd "$(dirname "$0")"; pwd)"

# Replace with your Terraform installation path
export PATH=$PATH:/usr/local/bin:/opt/homebrew/bin/
fname=$2
lname=$3


# Check if required arguments are provided
if [ "$#" -eq 0 -o  "$#" -gt 3 ]; then
    echo "Usage: $0 <sync>"
    exit 1
fi

# Setup terraform backend for tfstate in s3
backend() {
    echo "Setting up terrafrom remote baceknd"
    cd $PROJECT_DIR/remote-state-backend/
    terraform init 
    terraform apply --auto-approve
}
# Setup Blog Architecture AWS Resources using terraform
deploy() {
    echo "Setting up terrafrom remote baceknd"
    cd $PROJECT_DIR/
    echo "Creating AWS Resources for Blog"
    terraform init
    terraform plan
    terraform apply -auto-approve
}

# Deploying Smaple application on EKS CLuster
deployapp() {
    cd $PROJECT_DIR/
    configure_kubectl="$(terraform output --raw configure_kubectl)"
    echo $configure_kubectl
    eval $configure_kubectl
    #kubectl apply -f https://raw.githubusercontent.com/aws-containers/retail-store-sample-app/main/dist/kubernetes/deploy.yaml
    kubectl apply -f deploy.yaml
    kubectl wait --for=condition=available deployments --all
    simulation_file="$PROJECT_DIR/simulation/simulation.yaml"
    Kubectl apply -f "$simulation_file"
    if [ $? -ne 0 ]; then
        echo "Failed to apply $yaml_file"
        exit 1
    fi
}

# Deploying fluent bit using helm to export application logs to s3
fluentbit() {
    configure_kubectl="$(terraform output --raw configure_kubectl)"
    echo $configure_kubectl
    eval $configure_kubectl
    helm repo add eks https://aws.github.io/eks-charts
    helm upgrade fluentbit eks/aws-for-fluent-bit --install -f s3-fluentbit-values.yaml
    if [ $? -ne 0 ]; then
        echo "Failed to apply $yaml_file"
        exit 1
    fi
}

# Creating users in AWS Managed Active Directory
users() {
    directory_id="$(terraform output --raw directory_id)"
    local f_name="${fname}"
    local l_name="${lname}"
    echo "Creating ${f_name} ${l_name} in AWS Managed Active Directory"
    if [ -z "f_name" ] || [ -z "l_name" ]; then
    echo "Please provide both first name and last name as arguments."
    exit 1
    fi
    domain="$(aws ds describe-directories --directory-id ${directory_id} --query 'DirectoryDescriptions[0].Name' --output text)"
    echo "Directory ID is : ${directory_id}"
        aws ds-data create-user --directory-id "${directory_id}" \
    --sam-account-name ${f_name} \
    --email-address ${f_name}.${l_name}\@${domain} \
    --given-name ${f_name} \
    --surname ${l_name} \
    --output text
    if [ $? -ne 0 ]; then
        echo "Failed to apply $yaml_file"
        exit 1
    fi
}

sync() {
    application_id="$(terraform output --raw amazonq_business_application_id)"
    echo "Application ID is : ${application_id}"
    data_source_id="$(terraform output --raw amazonq_business_ds_id)"
    echo "Data Source ID is : ${data_source_id}"
    index_id="$(terraform output --raw amazonq_business_index_id | awk -F '|' '{print $2}')"
    echo "Index ID is : ${index_id}"
    
# Start data source sync job in Amazon QuickSight
aws qbusiness start-data-source-sync-job \
    --application-id "${application_id}" \
    --data-source-id "${data_source_id}" \
    --index-id "${index_id}"
}

output() {
  cd $PROJECT_DIR/
  terraform output
}

output_app_url() {
  cd $PROJECT_DIR/
  terraform output --raw amazonq_business_web_url
}

#cleanup() {
#    configure_kubectl="$(terraform output --raw configure_kubectl)"
#    echo $configure_kubectl
#    eval $configure_kubectl
#    echo "Deleting Sample Application from Amazon EKS"
#    kubectl delete -f https://raw.githubusercontent.com/aws-containers/retail-store-sample-app/main/dist/kubernetes/deploy.yaml
#    echo "Deleting Simulation Resources from Amazon EKS"
#    simulation_file="$PROJECT_DIR/simulation/simulation.yaml"
#    Kubectl delete -f "$simulation_file"
#    echo "Deleting Terraform Resources"
#    cd $PROJECT_DIR/
#    terraform destroy --auto-approve
#    echo "Deleting Remote State Backend Resources"
#    cd $PROJECT_DIR/remote-state-backend
#    terraform init
#    terraform plan
#    terraform destroy --auto-approve

#}

cleanup() {
    # Colors for better visibility
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    # Configure kubectl
    configure_kubectl="$(terraform output --raw configure_kubectl)"
    echo -e "${YELLOW}Configuring kubectl...${NC}"
    eval $configure_kubectl

    # Delete K8s resources first
    echo -e "${YELLOW}Deleting Sample Application from Amazon EKS${NC}"
    kubectl delete -f https://raw.githubusercontent.com/aws-containers/retail-store-sample-app/main/dist/kubernetes/deploy.yaml

    echo -e "${YELLOW}Deleting Simulation Resources from Amazon EKS${NC}"
    simulation_file="$PROJECT_DIR/simulation/simulation.yaml"
    kubectl delete -f "$simulation_file"

    # Function to delete terraform resources one by one
    delete_terraform_resources() {
        local working_dir=$1
        cd "$working_dir"
        
        echo -e "${YELLOW}Listing Terraform resources in: ${working_dir}${NC}"
        terraform state list > tf_resources.txt
        
        if [ -s tf_resources.txt ]; then
            echo -e "${GREEN}Found the following resources:${NC}"
            cat tf_resources.txt | nl
            
            total_resources=$(wc -l < tf_resources.txt)
            current=1

            while IFS= read -r resource; do
                echo -e "\n${YELLOW}[$current/$total_resources] Destroying: $resource${NC}"
                
                terraform destroy -target="$resource" -auto-approve
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Successfully destroyed $resource${NC}"
                else
                    echo -e "${RED}Failed to destroy $resource${NC}"
                    echo -e "${YELLOW}Do you want to continue? (y/n): ${NC}"
                    read continue_choice
                    if [[ "$continue_choice" != "y" ]]; then
                        exit 1
                    fi
                fi
                ((current++))
            done < tf_resources.txt
            
            rm tf_resources.txt
        else
            echo -e "${RED}No resources found in Terraform state${NC}"
        fi
    }

    # Delete main project resources
    echo -e "${GREEN}=== Deleting Main Project Resources ===${NC}"
    cd "$PROJECT_DIR/"
    terraform init
    delete_terraform_resources "$PROJECT_DIR"

    # Delete remote state backend resources
    echo -e "${GREEN}=== Deleting Remote State Backend Resources ===${NC}"
    cd "$PROJECT_DIR/remote-state-backend"
    terraform init
    delete_terraform_resources "$PROJECT_DIR/remote-state-backend"

    echo -e "${GREEN}Cleanup completed!${NC}"
}


function_name="$1"

# Check if the function exists
if declare -f "$function_name" > /dev/null; then
  # Call the function
  "$function_name"
else
  echo "Function '$function_name' not found"
  exit 1
fi
