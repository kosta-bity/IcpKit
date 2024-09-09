#!/usr/bin/env bash
DID_DIR="Tests/CodeGeneratorTests/DidFiles/"
GENERATED_DIR="Tests/CodeGeneratorTests/Generated/"
TYPE_NAMES=(TestImports LedgerCanister ICRC7 GoldNFT)
VALUE_NAMES=(EVMProviders)

generate() {
    for NAME in $@
    do
        printf "Generating ${NAME}..."
        swift run CodeGenerator $VALUE -n "${NAME}" "${DID_DIR}${NAME}.did"
        if [ $? -ne 0 ]; then
            echo "Failed to build/run the CodeGenerator"
            exit $?
        fi
        
        cp "${DID_DIR}${NAME}.did.swift" "${GENERATED_DIR}${NAME}.did.generated_swift"
        mv "${DID_DIR}${NAME}.did.swift" "${GENERATED_DIR}${NAME}.did.swift"
        echo "Moved generated file to ${GENERATED_DIR}${NAME}.did.generated_swift for equality check"
        echo "Moved generated file to ${GENERATED_DIR}${NAME}.did.swift for compilation check"
    done
}

generate "${TYPE_NAMES[@]}"
VALUE="value"
generate "${VALUE_NAMES[@]}"
