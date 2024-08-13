#!/usr/bin/env bash
NAMES=(LedgerCanister ICRC7 GoldNFT)
DID_DIR="Tests/CodeGeneratorTests/DidFiles/"
GENERATED_DIR="Tests/CodeGeneratorTests/Generated/"
for NAME in "${NAMES[@]}"
do
    printf "Generating ${NAME}..."
    swift run CodeGenerator -n "${NAME}" "${DID_DIR}${NAME}.did"
    if [ $? -ne 0 ]; then
        echo "Failed to build CodeGenerator"
        exit $?
    fi
    
    cp "${DID_DIR}${NAME}.did.swift" "${GENERATED_DIR}${NAME}.generated_swift"
    mv "${DID_DIR}${NAME}.did.swift" "${GENERATED_DIR}${NAME}.swift"
    echo "Moved generated file to ${GENERATED_DIR}${NAME}.generated_swift for equality check"
    echo "Moved generated file to ${GENERATED_DIR}${NAME}.swift for compilation check"
done
