#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    
    set -e

    # Pamphlet - Generates swift code which embeds resources in our server executable
    pamphlet --clean ./Resources/ ./Sources/Pamphlet/ 

    # FlynnLint - Confirms all Flynn code is concurrently safe
    FLYNNLINTSWIFTPM=./.build/checkouts/flynn/meta/FlynnLint
    FLYNNLINTLOCAL=./../../flynn/meta/FlynnLint
    
    if [ -f "${FLYNNLINTSWIFTPM}" ]; then
        ${FLYNNLINTSWIFTPM} ./.build/checkouts/Picaroon ./
    elif [ -f "${FLYNNLINTLOCAL}" ]; then
        ${FLYNNLINTLOCAL} ./.build/checkouts/Picaroon ./
    else
        echo "warning: Unable to find FlynnLint, aborting..."
    fi


    # SwiftLint - Confirms all swift code meets basic formatting standards
    if which swiftlint >/dev/null; then
      swiftlint autocorrect --path ./Sources/
      swiftlint --path ./Sources/
    else
      echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi

fi