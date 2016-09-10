#!/usr/bin/env bash

printf '%.0s-' {1..80}
echo

URL=$1

COUNT_TESTS=0
COUNT_TESTS_FAIL=0

assertTrue() {
    testName="$3"
    pad=$(printf '%0.1s' "."{1..80})
    padlength=78

    if [ "$1" != "$2" ]; then
        printf ' %s%*.*s%s' "$3" 0 $((padlength - ${#testName} - 4)) "$pad" "Fail"
        printf ' (expected %s, assertion %s)\n' "$1" "$2"
        let "COUNT_TESTS_FAIL++"
    else
        printf ' %s%*.*s%s\n' "$3" 0 $((padlength - ${#testName} - 2)) "$pad" "Ok"
        let "COUNT_TESTS++"
    fi
}

testSet() {
    ACTUAL=$(echo "SET my-key 'my-value'" | nc server 6379 2>/dev/null | cat | sed 's/\r//g')

    assertTrue "+OK" $ACTUAL "$FUNCNAME"
}

testGet() {
    ACTUAL=$(echo "GET my-key" | nc server 6379 2>/dev/null | cat | sed 's/[8\$\r]//g' | tr -d '[[:space:]]')

    assertTrue "my-value" $ACTUAL "$FUNCNAME"
}

testSet
testGet

printf '%.0s-' {1..80}
echo
printf 'Total test: %s, fail: %s\n\n' "$COUNT_TESTS" "$COUNT_TESTS_FAIL"

if [ $COUNT_TESTS_FAIL -gt 0 ]; then
    exit 1
fi

exit 0
