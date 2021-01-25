# How to learn any programming language (or start with it)
Many people asked me: how do i learn a programming language? 
My answer usually is: start by reading documentation and trying to figure things out.

That approach is not always the best, so i made a small exercise that can teach the basics of pretty much every language.

## The Exercise
Make a small calculator app that can handle basic functions like addition, subtraction, multiplication, division and exponentiation and has a CLI interface like this:

```none
{Language} CLI calc V1.0
choose a function
1 - Add        3 - Multiply   5 - Exponentiation
2 - Subtract   4 - Divide
>>> 5

{function} - Please choose two numbers a and b to calculate {expression}
a: {num_a}
b: {num_b}
result: {result}
Press enter to restart...
```

**Requirements**
- It must have the above interface
- it must use functions/methods
- builtins are not allowed unless it is to interact with the terminal
- it must have a loop that waits for enter to restart
- it must handle keyboard interrupts without error
- it must not error out 
- it must have comments

**Optional**
- use as few if-statements as possible
- make it efficient (space, time, length)
- make it fancy (color, slight UI change, whatever)
- add docstrings
- do it in as few formatted lines as possible

