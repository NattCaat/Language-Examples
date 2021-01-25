import java.util.Scanner;
import java.util.InputMismatchException;
import java.io.IOException;

class Calc {

    // common variables
    private static Scanner in = new Scanner(System.in);
    private static boolean run = true;
    private static String initUi = 
        "Java CLI calc V1.0\n" + 
        "choose a function\n" + 
        "1 - Add        3 - Multiply   5 - Exponentiation\n" + 
        "2 - Subtract   4 - Divide     6 - quit";
    private static String prompt = "You chose: %s%nPlease choose two numbers, 'a' and 'b' such that 'a%sb'%n";
    private static String clsCmd = System.getProperty("os.name").contains("Windows") ? "cmd /c cls" : "clear";
    private static String nanErr = "[Error]: Not a Number. Please only input numbers";
    private static String internErr = "[Error]: Internal error. Sorry, but no one can do anything about this one.";

    public static void main(String[] args) {
        int mode = 0;
        while (run) {
            // try to clear the console and display the UI
            try {
                mode = 0;
                new ProcessBuilder(clsCmd).inheritIO().start().waitFor();
                System.out.println(initUi);
                System.out.print(">>> ");
            } catch (InterruptedException | IOException e1) {
                System.out.println(internErr);
            }

            // try to get input and handle <<NaN errors 
            try {
                mode = in.nextInt();
                in.nextLine();
            } catch (InputMismatchException e) {
                System.out.println(nanErr); 
                reprompt();
                continue;
            }

            // easily changeable modes
            switch (mode) {
                case 1:
                    calc("+", "Addition");
                    break;

                case 2:
                    calc("-", "Subtraction");
                    break;
                case 3:
                    calc("*", "Multiplication");
                    break;
                case 4:
                    calc("/", "Division");
                    break;
                case 5:
                    calc("^", "Exponentiation");
                    break;
                case 6:
                    run = false;
                    break;
                default:
                    break;
            }
        }
        in.close(); // close scanner, just to be nice
    }

    public static void calc(String op, String id) {
        // init variables
        double a = 0;
        double b = 0;
        double out;

        try {
            // display the prompt
            System.out.printf(prompt, id, op);

            // get a (and flush \n)
            System.out.print("a: ");
            a = in.nextDouble();
            in.nextLine();
            
            // get b (and flush \n)
            System.out.print("b: ");
            b = in.nextDouble();
            in.nextLine();

        } catch (InputMismatchException e) {
            // print error
            System.out.println(e);
            reprompt();
            return;
        }

        // calculate values
        switch (op) {
            case "+":
                out = a + b;
                break;
            case "-":
                out = a - b;
                break;
            case "*":
                out = a * b;
                break;
            case "/":
                out = a / b;
                break;
            case "^":
                out = exp(a, b);
                break;
            default:
                return;
        }

        // print result and exit prompt
        System.out.printf("result: %.4f%n", out);
        reprompt();
    }

    public static double exp(double a, double b) {
        int exp = (int) b;
        double out = a;

        for (int i = exp; i > 1; i--)
            out *= a;

        return out;
    }

    public static void reprompt() {
        System.out.println("Either send a 'q'/'Q' to exit or press enter to continue...");
        String exit = in.nextLine(); // enter to restart
        if (exit.contains("q") || exit.contains("Q"))
            run = false;
    }
}