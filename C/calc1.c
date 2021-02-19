#include <stdio.h>
#include <stdlib.h>

// Macros to define colors and get size of an array 
#define len(a) sizeof(a)/sizeof(*a)
#define END "\e[0m"
#define PURPLE "\e[0;35m"
#define CYAN "\e[0;36m"
#define WHITEUNDER "\e[4;37m"
#define ERROR "\e[1;37m[\e[1;31mERROR\e[1;37m]\e[0m"
#define WARNING "\e[1;37m[\e[1;33mWARNING\e[1;37m]\e[0m"

// Gets turned to 1 if zero division occurs 
unsigned char zeroDivision = 0;


// Fucntions used by the calculator
double absolute(double a)
{
    return (a > 0)? a : -a; 
}

double add(double a, double b)
{
    return (a + b);
}

double subtract(double a, double b)
{
    return (a - b);
}

double multiply(double a, double b)
{
    return (a * b);
}

double divide(double a, double b)
{
    // Check if user does not divide by 0
    if (absolute(b) > 0) {
        return (a / b);
    }
    zeroDivision = 1;
    return 0;
}

double power(double a, double b)
{
    // Check if b is negative and takeabsolute value of b
    unsigned char negativPow = b < 0;
    b = absolute(b);

    // 0^0 is not defined
    if (a == 0 && b == 0) {
        zeroDivision = 1;
        return 0;
    }

    // Calculate exponent manually by iterating product
    double product = 1;
    for (int _ = 0; _ < b; _++) {
        product *= a;
    }

    return (!negativPow)? product : divide(1, product);
}

// Display restart message, clear stdin and wait until enter keypress
static void wait_for_restart()
{
    char ch;
    printf("\nPress enter to restart...\n");
    while ((ch=getchar()) != '\n' && ch != EOF);
    fgetc(stdin);
}


int main()
{
    // input to get mode and notError to check for errors
    unsigned char input, notError;
    // Doubles to store calculator inputs and output
    double a, b, result;
    // Array containing `{signe, name}`
    const char *modes[][2]= {
        {PURPLE"+"END, PURPLE"Addition"END},
        {PURPLE"-"END, PURPLE"Subtraction"END},
        {PURPLE"*"END, PURPLE"Multiplication"END},
        {PURPLE"/"END, PURPLE"Division"END},
        {PURPLE"^"END, PURPLE"Exponentation"END}
    };
    // Array containing function pointers
    double (*functions[])(double, double) = {
        add, subtract, multiply, divide, power
    };


    while (1) {
        // Clear terminal
        system("clear");
        // Set zero division marker to false
        zeroDivision = 0;

        // Print start message
        printf(WHITEUNDER"C CLI calc V1.0"END"\n\n");
        printf("Choose a function\n");
        printf(CYAN"1"END" - "PURPLE"Add         "CYAN"3"END" - "PURPLE"Multiply    "CYAN"5"END" - "PURPLE"Exponentation"END"\n");
        printf(CYAN"2"END" - "PURPLE"Subtract    "CYAN"4"END" - "PURPLE"Divide      "CYAN"6"END" - "PURPLE"Quit"END"\n");
        printf(">>> ");

        // Get input and decrease it
        notError = scanf("%hhu", &input);
        input--;

        // Mode selection error handling
        if (!notError) {
            // User did not enter numbers
            printf("\n"ERROR" Please only enter whole numbers!\n");
            wait_for_restart();
            continue;
        } else if (input < -1 || input > len(functions)) {
            // User chose a function which does not exist
            printf("\n"ERROR" Please enter a number between 1 and %li\n", len(functions)+1);
            wait_for_restart();
            continue;
        } else if (input == len(functions)) {
            // User want to exit the program
            printf("Exiting program...\n");
            return 0;
        }

        // Display information of function and get all inputs
        printf("You chose: %s\n", modes[input][1]);
        printf("Please enter two numbers a and b to calculate "CYAN"a%s"CYAN"b"END"\n", modes[input][0]);

        printf("a: ");
        notError = scanf("%lf", &a);
        if (notError) {
            printf("b: ");
            notError = scanf("%lf", &b);
        }
        
        // Calculator input error handling
        if (!notError) {
            // User did not enter numbers
            printf("\n"ERROR" Please only enter numbers!\n");
            wait_for_restart();
            continue;
        }

        // Call calculator and check if user did not divide by zero
        result = functions[input](a, b);
        if (zeroDivision) {
            // User wanted to divide by zero
            printf("\n"WARNING" Please do not divide by 0!\n");
            wait_for_restart();
            continue;
        }

        // Print result
        printf(PURPLE"Result:"CYAN" %lf\n"END, result);
        wait_for_restart();
    }

    return 0;
}