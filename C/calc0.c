#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

double addition(double a, double b)
{
    return a + b;
}

double subtraction(double a, double b)
{
    return a - b;
}

double multiply(double a, double b)
{
    return a * b;
}

double divide(double a, double b)
{
    return a / b;
}

double exponent(double a, double b)
{
    double out = a;
    if (b == 0)
        out = 1;
    else if (b == 1)
        out = a;
    else
    {
        out = a;
        for (int i = b; i > 1; i--)
        {
            out *= a;
        }
    }

    return out;
}

void flush()
{
    char c;
    while ((c = getchar()) != '\n' && c != EOF)
        ;
}

int main(void)
{
    // define function pointer array, so we can call the functions by their index
    double (*func_ptr[5])(double, double) = {
        addition, subtraction, multiply, divide, exponent};

    // mode text snippets
    char *options[5][2] = {
        {"\e[38;5;40mAddition\e[0m",
         "+"},
        {"\e[38;5;4mSubtraction\e[0m",
         "-"},
        {"\e[38;5;28mMultiplication\e[0m",
         "*"},
        {"\e[38;5;6mDivision\e[0m",
         "/"},
        {"\e[38;5;58mExponentiation\e[0m",
         "^"}};

    // control variables
    uint8_t opt;
    uint8_t end;
    int err;
    double a;
    double b;

    // start of the actual program loop
    while (1)
    {
        // initialize the variables
        opt = 10;
        err = 1;
        end = 0;

        // print the menu
        // this makes it more readable than a single long string
        system("clear");
        printf("\e[4m\e[1mC\e[0m\e[4m CLI calc V1.0\e[0m\n");
        printf("choose a function\n");
        printf("\e[38;5;40m1 - Addition\e[0m   \e[38;5;28m3 - Multipl\e[0m   \e[38;5;58m5 - Exponentiation\e[0m\n");
        printf("\e[38;5;4m2 - Subtract\e[0m   \e[38;5;6m4 - Divide\e[0m\n");

        // try until they get it right
        while (opt > 5 || opt < 1)
        {
            opt = 255; // set to some nonsensical value

            printf(">>> ");             // print the prompt
            err = scanf("%hhu", &opt); // get the input

            // check if scanf had an error and flush if there was indeed one. otherwise check for out of bounds
            if (!err)
            {
                printf("\n[\e[31mERR\e[0m] Please only input numbers\n"); // print a nice looking error
                flush(); // this will flush stdin for unwanted characters
            }
            else if (opt - 1 > 4 || opt - 1 < 0)
                // another good looking error
                printf("\n[\e[31mERR\e[0m] Please only input numbers between 1 and 5\n");
        }

        printf("\nYou chose: %s\n", options[opt-1][0]);
        printf("Please give two numbers, A and B to calculate a%sb\n", options[opt - 1][1]);

        while (end < 2)
        {
            err = 1;
            printf(">>> ");
            if (end == 0)
                err = scanf("%lf", &a);
            else if (end == 1)
                err = scanf("%lf", &b);

            if (!err)
            {
                printf("\n[\e[31mERR\e[0m] Please only input numbers, not characters.\n"); // more good looking error messages
                flush(); // this will flush stdin for unwanted characters
            }
            else
                end++;
        }

        printf("a%sb = %.3lf\n", options[opt - 1][1], (*func_ptr[opt - 1])(a, b));
        printf("Press Enter to restart...\n");
        getchar();
        flush();
    }
    printf("\n");
    return EXIT_SUCCESS;
}