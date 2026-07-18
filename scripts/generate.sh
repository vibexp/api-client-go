#!/usr/bin/env bash
#
# Regenerate the VibeXP Go client from the backend OpenAPI spec.
#
# The spec lives in github.com/vibexp/vibexp (backend/openapi.yaml, a multi-file
# spec assembled from paths/ + schemas/). We Redocly-bundle it to a single file
# first because kin-openapi (oapi-codegen's parser) does not resolve that layout
# natively — the same two-step the backend uses for its server codegen.
#
# Point VIBEXP_SPEC at a local backend/openapi.yaml, or check the backend repo
# out at spec-src/ (the CI/release workflows do the latter):
#
#   git clone https://github.com/vibexp/vibexp spec-src
#   ./scripts/generate.sh
#
#   # or against an existing checkout:
#   VIBEXP_SPEC=/path/to/vibexp/backend/openapi.yaml ./scripts/generate.sh
#
set -euo pipefail
cd "$(dirname "$0")/.."

SPEC="${VIBEXP_SPEC:-spec-src/backend/openapi.yaml}"
REDOCLY_VERSION="2.32.0"
OAPI_CODEGEN_VERSION="v2.7.1"

if [ ! -f "$SPEC" ]; then
  echo "❌ spec not found: $SPEC" >&2
  echo "   Set VIBEXP_SPEC or check the backend out at spec-src/." >&2
  exit 1
fi

echo "📦 Bundling spec: $SPEC"
npx --yes "@redocly/cli@${REDOCLY_VERSION}" bundle "$SPEC" -o openapi.bundled.yaml

echo "⚙️  Generating models (oapi-codegen ${OAPI_CODEGEN_VERSION}) -> types.gen.go"
go run "github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@${OAPI_CODEGEN_VERSION}" \
  -config oapi-codegen-types.yaml openapi.bundled.yaml

echo "⚙️  Generating client -> client.gen.go"
go run "github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@${OAPI_CODEGEN_VERSION}" \
  -config oapi-codegen-client.yaml openapi.bundled.yaml

echo "🧹 go mod tidy"
go mod tidy

echo "✅ Generated types.gen.go + client.gen.go"
