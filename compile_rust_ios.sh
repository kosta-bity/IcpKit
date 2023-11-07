#!/usr/bin/env bash
BINARIES_DIR=Binaries
HEADERS_DIR=Sources/Rust/bls12381/include

rm -rf $BINARIES_DIR

# RELEASE
cargo build --release --target aarch64-apple-ios --target-dir $BINARIES_DIR
cargo build --release --target aarch64-apple-ios-sim --target-dir $BINARIES_DIR

rm -rf $BINARIES_DIR/release

xcodebuild -create-xcframework \
    -library $BINARIES_DIR/aarch64-apple-ios/release/libbls12381.a -headers $HEADERS_DIR \
    -library $BINARIES_DIR/aarch64-apple-ios-sim/release/libbls12381.a -headers $HEADERS_DIR \
    -output $BINARIES_DIR/xcframeworks/Bls12381.xcframework


# DEBUG
#cargo build --target aarch64-apple-ios --target-dir $BINARIES_DIR
#cargo build --target aarch64-apple-ios-sim --target-dir $BINARIES_DIR

#rm -rf $BINARIES_DIR/debug

#xcodebuild -create-xcframework \
    -library $BINARIES_DIR/aarch64-apple-ios/debug/libbls12381.a -headers $HEADERS_DIR \
    -library $BINARIES_DIR/aarch64-apple-ios-sim/debug/libbls12381.a -headers $HEADERS_DIR \
    -output $BINARIES_DIR/xcframeworks/Bls12381.debug.xcframework


