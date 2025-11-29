```
#==BASH=Math=Library==#

A pure BASH floating-point arithmetic library using only shell builtins; No external dependencies are required!

#-FEATURES-#
|
|- Fixed-point arithmetic with 6 decimal places of precision
|- Pure Bash** built with only bash builtins, so no external calls!
|-- **Comprehensive operations including:
  |- Basic arithmetic: add, subtract, multiply, divide
  |- Advanced functions: square root, power, absolute value
  |- Rounding: floor, ceiling, round
  |- Comparison operations


#-Usage-#

Source the library in your script:
~~~
    source math.sh
~~~

#-Basic-Operations-#

~~~
    #--Addition--#
    result=$(fp_add "3.14" "2.86")  # Returns: 6.000000

    #--Subtraction--#
    result=$(fp_sub "10.5" "3.2")   # Returns: 7.300000

    #--Multiplication--#
    result=$(fp_mul "2.5" "4.0")    # Returns: 10.000000

    # Division
    result=$(fp_div "15.0" "3.0")   # Returns: 5.000000
    ~~~

    #-Advanced-Functions-#

    ~~~
    #--Square-Root--#
    result=$(fp_sqrt "25.0")        # Returns: 5.000000

    #--Power--#
    (Integer Exponents Only!)
    result=$(fp_pow "2.0" "3")      # Returns: 8.000000

    #--Absolute-Value--#
    result=$(fp_abs "-5.5")         # Returns: 5.500000
~~~

#-Rounding-Functions-#

~~~
    #--Round-To-Nearest-Integer--#
    result=$(fp_rnd "3.7")          # Returns: 4.000000

    #--Floor--#
    (Round Down)
    result=$(fp_floor "3.7")        # Returns: 3.000000

    #--Ceiling--#
    (Round Up)
    result=$(fp_ceil "3.2")         # Returns: 4.000000
~~~

#-Comparison-#

~~~
    result=$(fp_comp "5.5" "3.2")
    # Returns: 0 (greater than)
    # Returns: 1 (less than)
    # Returns: 2 (equal to)
~~~

#-Configuration-#

The default precision is 6 decimal places. To change this, modify the `SCALE` variable at the top of `math.sh`:
(Future Commits May Allow Changing This Value With A Function!)

~~~
    SCALE=6  # Number of decimal places
~~~

#-Testing-#

Run the included test suite:

~~~
    ./test_math.sh
~~~
or:
~~~
    bash test_math.sh
~~~


#-Limitations-#
|
|- `fp_pow()` Only supports integer exponents
|- Fixed precision of 6 decimal places (configurable)
|- Large numbers may overflow bash's integer arithmetic limits
|- Unexpected string mishandling may occur!

#-Why-Use-This-#
|
|- No External Dependencies - Works on any system with Bash (Version Testing Isn't Available Yet)
|- Portable - Great for environments where `bc`, `awk`, or Python aren't available
|- Lightweight - Perfect for shell scripts that need simple math
|- Educational - Shows how to implement floating-point arithmetic in pure shell
|- Fun - Demonstrates the fundamental floating point arithmetic in computer logic.

#==License==#

MIT License - See LICENSE file for details

#==Contributing==#

Contributions welcome! Feel free to submit issues or pull requests.
Note - I'm inexperienced In GitHub, & its complexities!
```
