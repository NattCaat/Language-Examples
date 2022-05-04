/*
Running the program:
    Running the following command creates several java classes
     ________________________________________________
    |                                                |
    | $ javac Calc1.java                             |
    |________________________________________________|
    The wanted main class is stored in "Calc1.class"
    ________________________________________________
    |                                                |
    | $ java Calc1                                   |
    |________________________________________________|
    You could try interpreting the different class files, but they won't run
    because they obviously don't have a main method
*/

import java.util.Scanner;


// Abstract class containing information about operator
abstract class Operator {
    private String sign;
    private String name;
    // Constructor
    Operator(String sign, String name) {
        this.sign = sign;
        this.name = name;
    }
    // Getters
    public String getSign() {
        return this.sign;
    }
    public String getName() {
        return this.name;
    }
    // Abstract method containing calculation of the operator
    public abstract double calculate(double a, double b);
}

// Main class of program
public class Calc1 {
    // Some constant strings
    final static String VERSION = "1.0";
    final static String ERROR = "\033[1m[\033[31mERROR\033[37m]\033[0m";

    // Array containing Operator objects. Abstract method "calculate" gets defined there
    private static Operator operators[] = new Operator[] {
        new Operator("+", "Addition") {
            public double calculate(double a, double b) {
                return a + b;
            }
        },
        new Operator("-", "Subtraction") {
            public double calculate(double a, double b) {
                return a - b;
            }
        },
        new Operator("*", "Multiplication") {
            public double calculate(double a, double b) {
                return a * b; 
            }
        },
        new Operator("/", "Division") {
            public double calculate(double a, double b) {
                return a / b;
            }
        },
        new Operator("^", "Exponentation") {
            public double calculate(double a, double b) {
                // Handle special case: Exponent is 0
                if (b == 0) {
                    return (a == 0) ? Double.NaN : 1;
                }
                // Multiple a with base |b| times and return inverse of result if exponent < 0
                boolean NegExponent = b < 0;
                double base = a;
                b = (NegExponent) ? -b : b;
                for (int i = 0; i < b; i++) {
                    a *= base;
                }
                return (NegExponent) ? 1 / a : a;
            }
        }
    };

    // Main function of the program
    public static void main(String[] args)
    {
        Scanner input = new Scanner(System.in);
        int mode;
        double[] vals = {0, 0};
        // Main loop
        while (true) {
            // Ensure program does not crash on error
            try {
                // Clear screen and display welcome message
                System.out.print("\033[H\033[2J\033[3J");
                System.out.printf("\033[4mJava CLI calc V%s\033[0m\nChoose a function\n", VERSION);
                System.out.print(
                    "\033[31m1\033[0m - \033[34mAddition\033[0m         " +
                    "\033[31m3\033[0m - \033[34mMultiplication\033[0m   " +
                    "\033[31m5\033[0m - \033[34mExponentation\033[0m  \n" +
                    "\033[31m2\033[0m - \033[34mSubtraction\033[0m      " +
                    "\033[31m4\033[0m - \033[34mDivision\033[0m         " +
                    "\033[31m6\033[0m - \033[34mQuit\033[0m           \n"
                );
                // Ask user to chose mode
                System.out.print("\033[31mFunction\033[0m: ");
                mode = Integer.parseInt(input.nextLine()) - 1;
                // Exit program if user wants to
                if (mode == 5) {
                    System.out.println("\nExiting program...");
                    break;
                }
                // Display information about chosen mode
                System.out.println(
                    "\nYou chose \033[34m" + operators[mode].getName() + 
                    "\033[0m. Enter \033[31ma\033[0m and \033[31mb\033[0m to calculate \033[31ma\033[34m" +
                    operators[mode].getSign() + "\033[31mb\033[0m"
                );
                // Ask user to enter values to do calculation
                System.out.print("\033[31ma\033[0m: ");
                vals[0] = Double.parseDouble(input.nextLine());
                System.out.print("\033[31mb\033[0m: ");
                vals[1] = Double.parseDouble(input.nextLine());
                // Run calculation and display result
                System.out.printf("\n\033[34m\033[34mResult\033[0m: %f\n\n", operators[mode].calculate(vals[0], vals[1]));
            // Display encountered error
            } catch (NumberFormatException e) {
                System.out.print("\n" + ERROR + " Invalid Input! ");
            } catch (ArrayIndexOutOfBoundsException e) {
                System.out.print("\n" + ERROR + " Invalid Mode! ");
            } catch (Exception e) {
                System.out.print("\n" + ERROR + " Something went wrong! ");
            }
            // Wait for user pressing enter
            System.out.println("Press enter to restart!");
            input.nextLine();
        }
        // Destroy Scanner object
        input.close();
    }
}