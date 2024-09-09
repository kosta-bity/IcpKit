#!/usr/bin/env bash
generate() {
    local DID_DIR="$1/DidFiles"
    local GENERATED_DIR="$1/Generated"
    for DID_FILE in $DID_DIR/*.did; do
        local NAME_NOEXT="${DID_FILE%.*}"
        local NAME="${NAME_NOEXT##*/}"
        printf "Generating Types for ${NAME}..."
        swift run CodeGenerator -n "${NAME}" "${DID_FILE}"
        if [ $? -ne 0 ]; then
            echo "Failed to build/run the CodeGenerator"
            exit $?
        fi
        
        mv "$DID_DIR/${NAME}.did.swift" "${GENERATED_DIR}/${NAME}.did.swift"
    done
}

generate "Sources/DAB/Nft"
generate "Sources/DAB/Token"
