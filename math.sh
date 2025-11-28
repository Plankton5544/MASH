#!/bin/bash
# BASH Script Attempt to use builtins only for advanced floating point arithmetic

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


