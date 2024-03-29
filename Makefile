REGION:=us-east-1

ifneq ($(wildcard .env),)
	include .env
endif

.PHONY: build
build: podman is_podman_running
	podman build . -t skopeo-aws

.PHONY: run
run: podman is_podman_running
	@if [[ -z '$(ACCOUNT)' ]]; then \
		echo to fix the issue, run the command: ; \
		echo cp default.env .env ; \
		echo and modify the ACCOUNT field ; \
		echo If you want your current accout, take it from ; \
		echo 'aws sts get-caller-identity --output json | jq .Account' ; \
		echo ; \
		echo ACCOUNT is not set ; \
		exit 1 ; \
	fi

	$(info to connect to the aws ecr registry, run the command:)
	$(info export DOCKER_BASE=docker://${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com)
	$(info  aws ecr get-login-password --region ${REGION} | skopeo login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com)
	podman run --rm -it --entrypoint bash -v /remote/home/.aws:/root/.aws skopeo-aws

.PHONY: set_account
set_account:
	@read -p "hey" ACCOUNT && echo ACCOUNT=$$ACCOUNT > .env

.PHONY: is_podman_running
is_podman_running: podman
	@podman machine info -f '{{.Host.MachineState}}' 2>/dev/null | grep -q Running || { echo "Podman machine is not running but is '$(shell podman machine info -f '{{.Host.MachineState}}')', run 'podman machine start'."; exit 1; }

.PHONY: podman
podman:
	@command -v podman >/dev/null 2>&1 || { echo "Podman not found, install podman."; exit 1; }
