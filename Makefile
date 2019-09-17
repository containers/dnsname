GO ?= go
EPOCH_TEST_COMMIT ?= 394c06f491fe9f1c28a410e3b0b91916a5119406
DESTDIR ?=
LIBEXECDIR ?= ${PREFIX}/libexec/cni
PREFIX ?= /usr/local


FIRST_GOPATH := $(firstword $(subst :, ,$(GOPATH)))
GOPKGDIR := $(FIRST_GOPATH)/src/$(PROJECT)
GOPKGBASEDIR ?= $(shell dirname "$(GOPKGDIR)")

SELINUXOPT ?= $(shell test -x /usr/sbin/selinuxenabled && selinuxenabled && echo -Z)

GO_BUILD=$(GO) build
GOBIN := $(shell $(GO) env GOBIN)
ifeq ($(GOBIN),)
GOBIN := $(FIRST_GOPATH)/bin
endif

all: binaries

validate: install.tools gofmt .gitvalidation lint

gofmt:
	find . -name '*.go' ! -path './vendor/*' -exec gofmt -s -w {} \+
	git diff --exit-code


binaries:
	$(GO_BUILD) -o bin/dnsname github.com/containers/dnsname/plugins/meta/dnsname

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

install:
	install ${SELINUXOPT} -d -m 755 $(DESTDIR)$(LIBEXECDIR)
	install ${SELINUXOPT} -m 755 bin/dnsname $(DESTDIR)$(LIBEXECDIR)/dnsname

clean:
	rm -fr bin/

.PHONY: \
	binaries \
	gofmt \
	lint \
	validate
