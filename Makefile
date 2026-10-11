.PHONY: help serve check inject-public

PORT ?= 8765
HOST ?= 0.0.0.0

help:
	@echo "crypt-dashboard"
	@echo "  make serve          # local dev server on :$(PORT) (public/)"
	@echo "  make check          # syntax + secret + hygiene checks"
	@echo "  make inject-public  # bake GOOGLE_CLIENT_ID/SECRET into public/index.html"

serve:
	PORT=$(PORT) HOST=$(HOST) ./serve.sh

check:
	node scripts/check.mjs

inject-public:
	node scripts/inject-env.mjs public/index.html
