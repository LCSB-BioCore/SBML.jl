#!/bin/sh
cd `dirname $0`
clang-format -style='{BasedOnStyle: Mozilla, AccessModifierOffset: -1, IndentCaseBlocks: false, PointerAlignment: Right}' -verbose -i *.cpp *.hpp
