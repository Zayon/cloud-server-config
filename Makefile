## [Nextcloud]
## Fix nextcloud indices
fix-nextcloud-indices:
	docker exec -it nextcloud occ db:add-missing-indices
.PHONY: fix-nextcloud-indices

.DEFAULT_GOAL := help
.PHONY: help

# Help target to display available targets and their descriptions.
help:
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Available targets:"
	@awk '/^## \[.*\]/ { section = substr($$0, 5, length($$0) - 5); hasSection = 1 } \
		/^[a-zA-Z\-_0-9]+:/ { \
			helpMessage = match(lastLine, /^## (.*)/); \
			if (helpMessage) { \
				target = $$1; \
				description = substr(lastLine, RSTART + 3, RLENGTH - 3); \
				if (hasSection) { \
					printf "\n \033[1;34m[%s]\033[0m\n", section; \
					hasSection = 0; \
				} \
				printf "  \033[36m%-20s\033[0m %s\n", target, description; \
			} \
		} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

