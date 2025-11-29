#!/bin/bash

SCALE=6
MULT=$((10**SCALE))


int() {
  local n="$1"
  local neg=0
  [[ "$n" == -* ]] && neg=1 && n="${n:1}"
  local int=${n%%.*}
  local frac=${n#*.}
  [[ "$frac" == "$n" ]] && frac=""

  while [[ ${#frac} -lt $SCALE ]]; do
    frac="${frac}0"
  done
  frac=${frac:0:SCALE}

  local out=$((10#$int * MULT + 10#$frac))
  [[ $neg -eq 1 ]] && out=$(( -out))
  echo $out
}

float() {
  local n="$1"
  local neg=0
  [[ "$n" -lt 0 ]] && neg=1 && n=$(( -n ))

  local int=$((n / MULT))
  local frac=$((n % MULT))

  local frac_str="$frac"
  while [[ ${#frac_str} -lt $SCALE ]]; do
    frac_str="0$frac_str"
  done

  [[ $neg -eq 1 ]] && echo "-$int.$frac_str" || echo "$int.$frac_str"
}

fp_pi() { echo "3.141593"; }

fp_add() {
  local a=$(int "$1")
  local b=$(int "$2")
  local out=$((a+b))
  out=$(float $out)
  echo $out
}

fp_sub() {
  local a=$(int "$1")
  local b=$(int "$2")
  local out=$((a-b))
  out=$(float $out)
  echo $out
}

fp_mul() {
  local a=$(int "$1")
  local b=$(int "$2")
  local out=$(( (a*b) / MULT ))
  out=$(float $out)
  echo $out
}

fp_div() {
  local a=$(int "$1")
  local b=$(int "$2")

  if [[ $b -eq 0 ]]; then
    echo "Division By Zero!"
    return
  fi

  local out=$(( (a * MULT) / b ))
  out=$(float $out)
  echo $out
}

fp_comp() {
  local a=$(int "$1")
  local b=$(int "$2")

  if [[ $a -eq $b ]]; then
    local out=2 #Equal To
  elif [[ $a -gt $b ]]; then
    local out=0 #Greater Than
  elif [[ $a -lt $b ]]; then
    local out=1 #Less Than
  fi
  echo $out
}

fp_abs() {
  local n=$(int "$1")
  [[ $n -lt 0 ]] && n=$(( -n ))
  local out=$(float $n)
  echo $out
}

fp_sqrt() {
  local n=$(int "$1")

  if [[ $n -lt 0 ]]; then
    echo "< 1 Rooted!"
    return
  fi

  local g=$((n/2))
  local prev=0
  local tolerance=1  # integer tolerance for stopping

  while [[ $(( g - prev )) -gt $tolerance ]] || [[ $(( prev - g)) -gt $tolerance ]]; do
    prev=$g
    # Newton-Raphson: guess = (guess + n/guess) / 2
    g=$(( (g + (n * MULT) / g) / 2 ))
  done

    local out=$(float $g)
    echo $out
}

fp_pow() {
  ##=ONLY=SUPPORTS=INTS=EXP=##
    local base="$1"
    local exp="$2"

    if [ "$exp" -eq 0 ]; then
        echo "1.0"
        return 0
    fi

    if [ "$exp" -eq 1 ]; then
        echo "$base"
        return 0
    fi

    local abs_exp=$exp
    if [ $exp -lt 0 ]; then
        abs_exp=$((-exp))  # Make positive
    fi

    local result="$base"

    for ((i=1; i<abs_exp; i++)); do
        result=$(fp_mul "$result" "$base")
    done

    if [ $exp -lt 0 ]; then
        result=$(fp_div "1" "$result")
    fi

    out=$result
    echo $out
}

fp_rnd() {
    local n=$(int "$1")
    local half=$(( MULT / 2 ))

    if (( n >= 0 )); then
        n=$(( n + half ))
    else
        n=$(( n - half ))
    fi

    local i=$(( n / MULT ))

    out=$(float $((i * MULT)))
    echo $out
}


fp_floor() {
    local n=$(int "$1")
    local i=$(( n / MULT ))

    if (( n < 0 && n % MULT != 0 )); then
        ((i--))
    fi

    echo "$(float $((i * MULT)))"
}

fp_ceil() {
    local n=$(int "$1")
    local i=$(( n / MULT ))

    if (( n > 0 && n % MULT != 0 )); then
        ((i++))
    fi

    out=$(float $((i * MULT)))
    echo "$out"
}

fp_max() {
  for argument in "${@#}"; do
    local temp=$(int "$argument")
    if [[ $temp -gt $prev ]]; then
      local prev=$temp
    fi
  done

  out=$(float $prev)
  echo "$out"
}

fp_min() {
  prev=$(int $1)
  for argument in "${@#}"; do
    local temp=$(int "$argument")
    if [[ $temp -lt $prev ]]; then
      local prev=$temp
    fi
  done

  out=$(float $prev)
  echo "$out"
}

fp_strip() {
    local num="$1"
    # Remove trailing zeros after decimal
    if [[ "${num: -1}" == "0" ]] && [[ "$num" == *.* ]]; then
      out="${num%?}"
      if [[ "${num: -1}" == "0" ]]; then
        fp_strip "$out" > /dev/null
      fi
    else
      out="$num"
    fi

    echo "$out"
}

fp_cos() {
    local x="$1"  # Input angle in RADIANS

    local PI=$(fp_pi)
    local TWO_PI=$(fp_mul $PI 2)
    local HALF_PI=$(fp_div $PI 2)

    # Step 2: Normalize x to range [0, 2π) using modulo
    # Keep subtracting/adding 2π until in range
    while [[ $(fp_comp "$x" "$TWO_PI") -eq 0 ]] || [[ $(fp_comp "$x" "$TWO_PI") -eq 2 ]]; do
        x=$(fp_sub "$x" "$TWO_PI")
    done

    while [[ $(fp_comp "$x" "0.000000") -eq 1 ]]; do
        x=$(fp_add "$x" "$TWO_PI")
    done

    # Step 3: Use symmetry to reduce to [0, π/2]
    local sign="1.000000"

    # If x > π, use cos(x) = cos(2π - x)
    if [[ $(fp_comp "$x" "$PI") -eq 0 ]] || [[ $(fp_comp "$x" "$PI") -eq 2 ]]; then
        x=$(fp_sub "$TWO_PI" "$x")
    fi

    # If x > π/2, use cos(x) = -cos(π - x)
    if [[ $(fp_comp "$x" "$HALF_PI") -eq 0 ]] || [[ $(fp_comp "$x" "$HALF_PI") -eq 2 ]]; then
        x=$(fp_sub "$PI" "$x")
        sign="-1.000000"
    fi

    # Step 4: Taylor series calculation
    # cos(x) = 1 - x²/2! + x⁴/4! - x⁶/6! + x⁸/8! - x¹⁰/10! + ...

    local x_squared=$(fp_mul "$x" "$x")
    local term="1.000000"
    local sum="1.000000"
    local n=0

    # Term 1
    n=2
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "2.000000")  # 2! = 2
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 2
    n=4
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "12.000000")  # 3*4 = 12
    term=$(fp_mul "$term" "-1.000000")  # Flip sign
    sum=$(fp_add "$sum" "$term")

    # Term 3
    n=6
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "30.000000")  # 5*6 = 30
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 4
    n=8
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "56.000000")  # 7*8 = 56
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 5
    n=10
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "90.000000")  # 9*10 = 90
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 6
    n=12
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "132.000000")  # 11*12 = 132
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 7
    n=14
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "182.000000")  # 13*14 = 182
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 8
    n=16
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "240.000000")  # 15*16 = 240
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Step 5: Apply sign from symmetry
    local out=$(fp_mul "$sum" "$sign")

    echo "$out"
}

fp_sin() {
    local x="$1"  # Input angle in RADIANS

    local PI=$(fp_pi)
    local TWO_PI=$(fp_mul $PI 2)
    local HALF_PI=$(fp_div $PI 2)

    # Step 2: Normalize x to range [0, 2π)
    while [[ $(fp_comp "$x" "$TWO_PI") -eq 0 ]] || [[ $(fp_comp "$x" "$TWO_PI") -eq 2 ]]; do
        x=$(fp_sub "$x" "$TWO_PI")
    done

    while [[ $(fp_comp "$x" "0.000000") -eq 1 ]]; do
        x=$(fp_add "$x" "$TWO_PI")
    done

    # Step 3: Use symmetry to reduce to [0, π/2]
    local sign="1.000000"

    # If x > π, use sin(x) = -sin(x - π)
    if [[ $(fp_comp "$x" "$PI") -eq 0 ]] || [[ $(fp_comp "$x" "$PI") -eq 2 ]]; then
        x=$(fp_sub "$x" "$PI")
        sign="-1.000000"
    fi

    # If x > π/2, use sin(x) = sin(π - x)
    if [[ $(fp_comp "$x" "$HALF_PI") -eq 0 ]] || [[ $(fp_comp "$x" "$HALF_PI") -eq 2 ]]; then
        x=$(fp_sub "$PI" "$x")
    fi

    # Step 4: Taylor series calculation
    # sin(x) = x - x³/3! + x⁵/5! - x⁷/7! + x⁹/9! - x¹¹/11! + ...

    local x_squared=$(fp_mul "$x" "$x")
    local term="$x"          # First term is x (not 1 like cosine!)
    local sum="$x"

    # Term 1
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "6.000000")  # 3! = 6
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 2
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "20.000000")  # 4*5 = 20
    term=$(fp_mul "$term" "-1.000000")  # Flip sign
    sum=$(fp_add "$sum" "$term")

    # Term 3
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "42.000000")  # 6*7 = 42
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 4
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "72.000000")  # 8*9 = 72
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 5
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "110.000000")  # 10*11 = 110
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 6
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "156.000000")  # 12*13 = 156
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 7
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "210.000000")  # 14*15 = 210
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    # Term 8
    term=$(fp_mul "$term" "$x_squared")
    term=$(fp_div "$term" "272.000000")  # 16*17 = 272
    term=$(fp_mul "$term" "-1.000000")
    sum=$(fp_add "$sum" "$term")

    local out=$(fp_mul "$sum" "$sign")

    echo "$out"
}

