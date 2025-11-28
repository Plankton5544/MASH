#!/bin/bash
source math.sh

echo "====== FLOAT ROUNDING TESTS ======"
test_rounding() {
    local fn="$1"
    local input="$2"
    local expected="$(float $(int $3))"

    # call your function dynamically
    local actual="$($fn "$input")"

    if [[ "$actual" == "$expected" ]]; then
        printf "%-12s %-8s OK\n" "$fn($input)" "$actual"
    else
        printf "%-12s expected %-8s got %-8s  FAIL\n" "$fn($input)" "$expected" "$actual"
    fi
}


echo
echo "--- floor ---"
test_rounding fp_floor  "3.7"   "3"
test_rounding fp_floor  "-3.7"  "-4"
test_rounding fp_floor  "2.0"   "2"

echo
echo "--- ceil ---"
test_rounding fp_ceil   "3.2"   "4"
test_rounding fp_ceil   "-3.2"  "-3"
test_rounding fp_ceil   "7.0"   "7"

echo
echo "--- round ---"
test_rounding fp_rnd  "3.2"   "3"
test_rounding fp_rnd  "3.5"   "4"
test_rounding fp_rnd  "3.6"   "4"
test_rounding fp_rnd  "-3.2"  "-3"
test_rounding fp_rnd  "-3.5"  "-4"
test_rounding fp_rnd  "-3.6"  "-4"

