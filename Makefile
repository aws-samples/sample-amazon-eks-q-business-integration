KNOWN_TARGETS = users
ARGS := $(filter-out $(KNOWN_TARGETS),$(MAKECMDGOALS))
.DEFAULT: ;: do nothing

.SUFFIXES:
.PHONY: users
users: ## Create users in AWS Managed Microsoft AD for Amazon Q Business
	./setup.sh users $(ARGS)

.PHONY: help
help: ## Display this help.
		@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##Cloudformation Deployment Steps
.PHONY: backend
backend: ## Create Terrrform Remote state backend resources(bucket and DynamoDB)
	./setup.sh backend

.PHONY: deploy
deploy: ## Create the Blog architeture resources using Terrrform
	./setup.sh deploy

.PHONY: deployapp
deployapp: ## Deploy Sample application on EKS cluster
	./setup.sh deployapp


.PHONY: fluentbit
fluentbit: ## Deploy Fluent Bit for exporting Application logs to Amazon S3.
	./setup.sh fluentbit



.PHONY: output
output: ## Show the terraform resource output
	./setup.sh output

.PHONY: output_app_url
output_app_url: ## Fetch the Amazon Q Business Web URL
	./setup.sh output_app_url

.PHONY: simulation
simulation: ## Deploy resources in Kubernetes Cluster for Simulation
	./setup.sh simulation


.PHONY: sync
sync: ## Sync Amazon Q Business Backend data Stores to get and index the latest logs
	./setup.sh sync


.PHONY: cleanup
cleanup: ## Cleanup everything 
	./setup.sh cleanup


