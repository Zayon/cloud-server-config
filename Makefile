#COLORS
BLACK   := $(shell tput -Txterm setaf 0)
RED     := $(shell tput -Txterm setaf 1)
GREEN   := $(shell tput -Txterm setaf 2)
YELLOW  := $(shell tput -Txterm setaf 3)
BLUE    := $(shell tput -Txterm setaf 4)
MAGENTA := $(shell tput -Txterm setaf 5)
CYAN    := $(shell tput -Txterm setaf 6)
WHITE   := $(shell tput -Txterm setaf 7)
RESET   := $(shell tput -Txterm sgr0)

define MAKEFILE_HELP_HEADER
 ~~~~ Makefile Help ~~~~
endef
export MAKEFILE_HELP_HEADER

.DEFAULT_GOAL := help

##
## ---- Ansible ----
.PHONY: build-ansible-image
build-ansible-image: ## Build the Ansible image
	docker buildx build -t zayon/ansible:local docker-ansible


##
## ---- Misc ----
.PHONY: help
help: ## Display this help message
	@echo "${CYAN}$$MAKEFILE_HELP_HEADER${RESET}"
	@echo ""
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-25s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
	@echo ""
