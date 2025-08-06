# Makefile for common.itsumi Helm Library Chart

.PHONY: help lint test clean deps package docs info

# Default target
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Chart variables
REGISTRY := ghcr.io/michaelw
CHART_NAME := common.itsumi
CHART_VERSION := $(shell grep '^version:' Chart.yaml | cut -d' ' -f2)
CHART_PACKAGE = $(CHART_NAME)-$(CHART_VERSION).tgz

# Development targets
deps: ## Update chart dependencies
	@echo "🔄 Updating dependencies..."
	helm dependency update
	@echo "✅ Dependencies updated"

lint: deps ## Lint the chart
	@echo "🔍 Linting chart..."
	helm lint .
	@echo "✅ Chart linting completed"

test: lint ## Test the chart

package: deps lint ## Package the chart
	@echo "📦 Packaging chart..."
	helm package .
	test -f $(CHART_PACKAGE)
	@echo "✅ Chart packaged: $(CHART_PACKAGE)"

clean: ## Clean generated files
	@echo "🧹 Cleaning up..."
	rm -f $(CHART_NAME)-*.tgz
	rm -rf charts/
	@echo "✅ Cleanup completed"

# Utility targets
info: ## Show chart information
	@echo "📊 Chart Information:"
	@echo "  Name: $(CHART_NAME)"
	@echo "  Version: $(CHART_VERSION)"
	@echo "  Type: Library Chart"
	@echo "  Registry: $(REGISTRY)"
	@echo "  Package: $(CHART_PACKAGE)"

list-templates: ## List all available templates
	@echo "📋 Available templates:"
	@grep -h "define.*common\.itsumi\." templates/*.tpl | sed 's/.*define "\([^"]*\)".*/  - \1/' | sort

# Publishing targets
publish: package ## Publish to Container Registry
	@echo "📤 Publishing to $(REGISTRY)..."
	@echo "$(GITHUB_TOKEN)" | helm registry login ghcr.io -u "$(GITHUB_USERNAME)" --password-stdin
	helm push $(CHART_PACKAGE) oci://$(REGISTRY)
	@echo "✅ Published to $(REGISTRY)/$(CHART_NAME):$(CHART_VERSION)"
