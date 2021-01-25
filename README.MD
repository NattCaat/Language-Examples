# Language Examples of a simple calculator app
This repo houses an example every program in every language i can use or people have submitted. Pull Requests are appreciated. 
If you have a different way of writing the program, don't delete the existing ones, please just add a new file. 

**Do not submit binaries, any PR subitting a binary will be ignored**

Any file named `calc0.*` or `Calc0.*` was made by the creator of the repository. Anything with an index greater than 0 was submitted via PR.
If you (for some reason) have a bigger project structure, put it in a folder named `calcX` where X is the index.

This is also a very easy way to start learning pretty much any programming language.

## Requirements
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

**Required**
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