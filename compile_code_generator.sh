#!/usr/bin/env bash
swift build -c release --product CodeGenerator
echo Built executable:
echo $(swift build -c release --show-bin-path)/CodeGenerator
