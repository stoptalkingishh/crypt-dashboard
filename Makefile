.PHONY: help serve check inject-public inject-secure

PORT ?= 8765
HOST ?= 0.0.0.0

help:
	@echo "crypt-dashboard"
	@echo "  make serve          # local dev server on :$(PORT) (public/ and secure/)"
	@echo "  make check          # syntax + secret + hygiene checks"
	@echo "  make inject-public  # bake GOOGLE_CLIENT_ID/SECRET into public/index.html"
	@echo "  make inject-secure  # bake GOOGLE_CLIENT_ID/SECRET into secure/index.html"

serve:
	PORT=$(PORT) HOST=$(HOST) ./serve.sh

check:
	node scripts/check.mjs

inject-public:
	node scripts/inject-env.mjs public/index.html

inject-secure:
	node scripts/inject-env.mjs secure/index.html
