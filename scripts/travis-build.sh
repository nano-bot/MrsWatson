#!/bin/bash

CONFIGURATION=$1
C_COMPILER=$2
CXX_COMPILER=$3

if [ "$CONFIGURATION" = "Formatting" ]; then
  echo "Checking code formatting"
  ERRORS_FOUND=0
  for i in $(find main source test -name "*.h" -or -name "*.c" -or -name "*.cpp"); do
    $C_COMPILER -style=LLVM -output-replacements-xml $i | grep "<replacement " > /dev/null
    if [ $? -eq 0 ]; then
      echo "File $i failed formatting"
      ERRORS_FOUND=1
    fi
  done
  if [ $ERRORS_FOUND -eq 1 ]; then
    echo "Formatting errors found!"
    echo "Please run 'clang-format -style=LLVM -i' on the above files"
  fi
  exit $ERRORS_FOUND
fi

git fetch --tags
VERSION=$(git tag -l | sort -r -n -t. -k1,1 -k2,2 -k3,3 -k4,4 | head -1)

rm -rf build
mkdir build
(cd build
  CC=$C_COMPILER CXX=$CXX_COMPILER \
  cmake -G Ninja -D CMAKE_BUILD_TYPE=$CONFIGURATION -D VERBOSE=ON -D VERSION=$VERSION .. && \
  cmake --build . --config $CONFIGURATION && \
  echo "Running 32-bit tests" && \
  ./test/mrswatsontest -r ../vendor/AudioTestData -m ./main/mrswatson && \
  echo "Running 64-bit tests" && \
  ./test/mrswatsontest64 -r ../vendor/AudioTestData -m ./main/mrswatson64 && \
  echo "Creating distribution package" && \
  cmake --build . --config $CONFIGURATION --target build_package_32 && \
  cmake --build . --config $CONFIGURATION --target build_package_64 && \
  echo
)
