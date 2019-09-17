GO ?= go
EPOCH_TEST_COMMIT ?= 394c06f491fe9f1c28a410e3b0b91916a5119406

FIRST_GOPATH := $(firstword $(subst :, ,$(GOPATH)))
GOPKGDIR := $(FIRST_GOPATH)/src/$(PROJECT)
GOPKGBASEDIR ?= $(shell dirname "$(GOPKGDIR)")

GO_BUILD=$(GO) build
GOBIN := $(shell $(GO) env GOBIN)
ifeq ($(GOBIN),)
GOBIN := $(FIRST_GOPATH)/bin
endif

validate: gofmt .gitvalidation lint

gofmt:
	find . -name '*.go' ! -path './vendor/*' -exec gofmt -s -w {} \+
	git diff --exit-code


.PHONY: .gitvalidation
.gitvalidation:
	GIT_CHECK_EXCLUDE="./vendor" $(GOBIN)/git-validation -v -run DCO,short-subject,dangling-whitespace -range $(EPOCH_TEST_COMMIT)..$(HEAD)

.PHONY: install.tools
install.tools: .install.gitvalidation .install.ginkgo .install.golangci-lint

lint: .install.golangci-lint
	$(GOBIN)/golangci-lint run --tests=false

define go-get
	env GO111MODULE=off \
		$(GO) get -u ${1}
endef

.install.ginkgo:
	if [ ! -x "$(GOBIN)/ginkgo" ]; then \
		$(call go-get,github.com/onsi/ginkgo); \
	fi

.install.gitvalidation:
	if [ ! -x "$(GOBIN)/git-validation" ]; then \
		$(call go-get,github.com/vbatts/git-validation); \
	fi

.install.golangci-lint:
	if [ ! -x "$(GOBIN)/golangci-lint" ]; then \
		curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(GOBIN)/ v1.17.1; \
	fi


.PHONY: \
	gofmt \
	lint \
	validate
