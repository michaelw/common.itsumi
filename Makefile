# Makefile for common.itsumi Helm Library Chart

.PHONY: help lint clean deps package docs info

# Default target
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Chart variables
CHART_NAME := common.itsumi
CHART_VERSION := $(shell grep '^version:' Chart.yaml | cut -d' ' -f2)
REGISTRY := ghcr.io/michaelw

# Development targets
deps: ## Update chart dependencies
	@echo "🔄 Updating dependencies..."
	helm dependency update
	@echo "✅ Dependencies updated"

lint: deps ## Lint the chart
	@echo "🔍 Linting chart..."
	helm lint .
	@echo "✅ Chart linting completed"

package: deps lint ## Package the chart
	@echo "📦 Packaging chart..."
	helm package .
	@echo "✅ Chart packaged: $(CHART_NAME)-$(CHART_VERSION).tgz"

clean: ## Clean generated files
	@echo "🧹 Cleaning up..."
	rm -f $(CHART_NAME)-*.tgz
	rm -f /tmp/$(CHART_NAME)-*.yaml
	rm -rf charts/
	@echo "✅ Cleanup completed"

# Publishing targets
publish-ghcr: package ## Publish to GitHub Container Registry
	@echo "📤 Publishing to GHCR..."
	@echo "$$GITHUB_TOKEN" | helm registry login ghcr.io -u $$GITHUB_USERNAME --password-stdin
	helm push $(CHART_NAME)-$(CHART_VERSION).tgz oci://$(REGISTRY)
	@echo "✅ Published to $(REGISTRY)/$(CHART_NAME):$(CHART_VERSION)"

# Utility targets
info: ## Show chart information
	@echo "📊 Chart Information:"
	@echo "  Name: $(CHART_NAME)"
	@echo "  Version: $(CHART_VERSION)"
	@echo "  Type: Library Chart"
	@echo "  Registry: $(REGISTRY)"
	@echo "  Package: $(CHART_NAME)-$(CHART_VERSION).tgz"

list-templates: ## List all available templates
	@echo "📋 Available templates:"
	@grep -h "define.*common\.itsumi\." templates/*.tpl | sed 's/.*define "\([^"]*\)".*/  - \1/' | sort

example-usage: ## Show example usage
	@echo "💡 Example usage in your chart:"
	@echo ""
	@echo "# Chart.yaml"
	@echo "dependencies:"
	@echo "  - name: $(CHART_NAME)"
	@echo "    version: $(CHART_VERSION)"
	@echo "    repository: oci://$(REGISTRY)"
	@echo ""
	@echo "# templates/deployment.yaml"
	@echo "{{- include \"common.itsumi.deployments.tpl\" . }}"

version-bump: ## Bump chart version (usage: make version-bump VERSION=0.2.0)
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ VERSION not specified. Usage: make version-bump VERSION=0.2.0"; \
		exit 1; \
	fi
	@echo "📝 Bumping version to $(VERSION)..."
	@sed -i '' 's/^version:.*/version: $(VERSION)/' Chart.yaml
	@echo "✅ Version bumped to $(VERSION)"
