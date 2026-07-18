# api-client-go

[![CI](https://github.com/vibexp/api-client-go/actions/workflows/ci.yml/badge.svg)](https://github.com/vibexp/api-client-go/actions/workflows/ci.yml)
[![Go Reference](https://pkg.go.dev/badge/github.com/vibexp/api-client-go.svg)](https://pkg.go.dev/github.com/vibexp/api-client-go)

Typed Go client for the VibeXP REST API.

> ⚠️ **This library is automatically generated. Do not edit it by hand.**
>
> The client is generated with [`oapi-codegen`](https://github.com/oapi-codegen/oapi-codegen)
> from the VibeXP OpenAPI specification
> ([`backend/openapi.yaml`](https://github.com/vibexp/vibexp) → Redocly bundle).
> Every tagged release is regenerated from a pinned backend ref, so a client
> version always reflects a real API contract. Hand edits to the `*.gen.go`
> files will be overwritten on the next release — change the spec in
> [`vibexp/vibexp`](https://github.com/vibexp/vibexp) instead.

Unlike the JS client ([`@vibexp/api-client`](https://github.com/vibexp/api-client-js)),
which ships a compiled npm package, the generated Go source **is committed to
this repo** — Go resolves modules from source at a git tag, so the code has to
be present at each tagged commit.

## Install

```sh
go get github.com/vibexp/api-client-go@latest   # or pin an exact version, e.g. @v0.1.0
```

Requires Go 1.24+.

## Usage

The package exposes a raw `Client` and a `ClientWithResponses` (typed, parsed
responses — one method per `operationId`).

```go
package main

import (
	"context"
	"fmt"
	"log"
	"net/http"

	vibexp "github.com/vibexp/api-client-go"
)

func main() {
	// Attach an API key (or any auth) via a request editor.
	authed := func(ctx context.Context, req *http.Request) error {
		req.Header.Set("Authorization", "Bearer "+apiKey)
		return nil
	}

	client, err := vibexp.NewClientWithResponses(
		"https://api.vibexp.io",
		vibexp.WithRequestEditorFn(authed),
	)
	if err != nil {
		log.Fatal(err)
	}

	resp, err := client.ListTeamsWithResponse(context.Background(), nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("status=%d body=%+v\n", resp.StatusCode(), resp.JSON200)
}
```

The version you pin tells you which API contract the client targets — pin exact
versions in consumers.

## Versioning & releases

Releases are **spec-driven** and automated. When the OpenAPI spec changes on
`main` in [`vibexp/vibexp`](https://github.com/vibexp/vibexp), that repo
dispatches this repo's **Release** workflow (`.github/workflows/release.yml`),
which:

1. resolves the next version (auto next-minor from the latest `v*` tag),
2. checks out `vibexp/vibexp` and regenerates the client from the spec,
3. **runs the generation gate (`go build` + `go vet`) and only proceeds if it
   passes**,
4. commits the regenerated code and pushes a `vX.Y.Z` tag.

This mirrors the JS client's spec-change → auto-publish flow. The project stays
on `v0.x` deliberately: Go's semantic import versioning would force a `/vN`
module-path suffix at `v2+`, which an auto-minor scheme would eventually cross
and break every importer.

> The Release workflow also accepts a manual **workflow_dispatch** with optional
> `version` / `backend_ref` inputs — handy for the first release, or to
> regenerate from a specific backend ref.

## Development

Generation reads the backend OpenAPI spec. Point `VIBEXP_SPEC` at a local
`backend/openapi.yaml`, or check the backend out at `spec-src/`:

```sh
git clone https://github.com/vibexp/vibexp spec-src   # provides spec-src/backend/openapi.yaml
make generate                                          # bundle spec → oapi-codegen → go mod tidy

# or against an existing checkout:
VIBEXP_SPEC=/path/to/vibexp/backend/openapi.yaml make generate

make check   # generate + go build + go vet (the same gate CI/release enforce)
```

The only hand-written sources are `doc.go`, the `oapi-codegen-*.yaml` configs,
`scripts/generate.sh` and the `Makefile`. `types.gen.go` (schema models) and
`client.gen.go` (the client) are generated — split into two files for
navigability — but committed.

## License

[MIT](./LICENSE)
