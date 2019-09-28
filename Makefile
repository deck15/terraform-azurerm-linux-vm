ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: docs

CURRENT_DIR     = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TF_EXAMPLES     = $(sort $(dir $(wildcard $(CURRENT_DIR)examples/*/)))
TF_MODULES      = $(sort $(dir $(wildcard $(CURRENT_DIR)modules/*/)))
TF_DOCS_VERSION = 0.6.0-release-0.11

# Adjust your delimiter here or overwrite via make arguments
DELIM_START = <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
DELIM_CLOSE = <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

########################################################################
## Self-Documenting Makefile Help                                     ##
## https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html ##
########################################################################
.PHONY: help
help:
	@ grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: docs
docs: _update-tf-docs ## Generate all docs
	@echo "################################################################################"
	@echo "# Terraform-docs generate"
	@echo "################################################################################"
	@$(MAKE) --no-print-directory _generate-docs

.PHONY: _generate-docs
_generate-docs:
	@echo "------------------------------------------------------------"
	@echo "# Main module"
	@echo "------------------------------------------------------------"
	@if docker run --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='$(DELIM_START)' \
		-e DELIM_CLOSE='$(DELIM_CLOSE)' \
		cytopia/terraform-docs:$(TF_DOCS_VERSION) \
		terraform-docs-replace --sort-inputs-by-required --with-aggregate-type-defaults \
		md --no-required README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi

.PHONY: _update-tf-docs
_update-tf-docs:
	docker pull cytopia/terraform-docs:$(TF_DOCS_VERSION)

