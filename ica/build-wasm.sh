#!/bin/bash

WASM_IBC_PROJECT="ibc-tutorial-wasm"
PATH_TUTORIAL="$HOME/code/$WASM_IBC_PROJECT"

IBC_REFLECT_WASM="$PATH_TUTORIAL/demos/reflect/ibc-reflect/"
REFLECT_WASM="$PATH_TUTORIAL/demos/reflect/reflect/"

IBC_REFLECT_SEND_WASM="$PATH_TUTORIAL/demos/reflect/ibc-reflect-send/"

cd $IBC_REFLECT_WASM
make all

cd $IBC_REFLECT_SEND_WASM
make all

cd $REFLECT_WASM
make all