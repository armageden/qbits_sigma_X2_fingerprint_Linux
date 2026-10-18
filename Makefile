# Native task runner for the FTE3600 / Qbits Sigma X2 enablement repo.
.PHONY: help preflight docs-check verify check install-hooks

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  preflight     read-only hardware, tooling and package check' \
	  '  docs-check    validate the docs knowledge base' \
	  '  verify        inspect the fingerprint reader / fprintd state' \
	  '  check         preflight + docs-check' \
	  '  install-hooks enable the advisory pre-commit docs hook'

preflight:
	./scripts/00-preflight.sh

docs-check:
	./scripts/docs-check.sh

verify:
	./scripts/40-verify.sh

check: preflight docs-check

install-hooks:
	./scripts/install-hooks.sh
