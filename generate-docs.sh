#!/bin/sh

docker run --rm \
  -v $(PWD):/data \
  cytopia/terraform-docs:0.6.0-release-0.11 \
  terraform-docs-replace-012 --sort-inputs-by-required --with-aggregate-type-defaults md README.md
