import os


# Color definitions
END = "\033[0m"
GREEN = "\033[0;32m"
BLUE = "\033[0;94m"
REDBOLD = "\033[1;31m"
ORANGEBOLD = "\033[1;33m"
WHITEUNDER = "\033[4;37m"


# Functions used by calculator
def add(a: float, b: float) -> float:
    return a + b

def sub(a: float, b: float) -> float:
    return a - b

def mul(a: float, b: float) -> float:
    return a * b

def div(a: float, b: float) -> float:
    return a / b

def exp(a: float, b: float) -> float:
    # Not figured out yet how to handle roots with help of iterations
    if b != int(b):
        return a ** b
    # 0^0 is not defined
    if a ==  b == 0:
        raise(ZeroDivisionError)

    # Check if b is negative and take absolute value of b
    positiveExp = b > -1
    b = b if positiveExp else -b

    # Calculate exponent manually by iterating product
    product = 1
    for _ in range(int(b)):
        product *= a
    
    return product if positiveExp else 1 / product

# Display a small message and exit program
def exitAppl() -> None:
    print("\nThank you for using the calculator")
    print("Exiting program...")
    exit()


# Main function of the program
def main():
    # Tuple of tuples containting (signe, name, function)
    modes = (
        (f"{BLUE}+{END}", f"{BLUE}Addition{END}", add),
        (f"{BLUE}-{END}", f"{BLUE}Substraction{END}", sub),
        (f"{BLUE}*{END}", f"{BLUE}Multiplicaton{END}", mul),
        (f"{BLUE}/{END}", f"{BLUE}Division{END}", div),
        (f"{BLUE}^{END}", f"{BLUE}Exponentation{END}", exp)
    )

    while True:
        # Clear terminal
        os.system("clear" if os.name != "nt" else "cls")

        # Print start message
        print(f"{WHITEUNDER}Python CLI calc V1.0{END}\n")
        print("Choose a function")
        print(f"{GREEN}1{END} - {BLUE}Add        {GREEN}3{END} - {BLUE}Multiply   {GREEN}5{END} - {BLUE}Exponentiation{END}")
        print(f"{GREEN}2{END} - {BLUE}Subtract   {GREEN}4{END} - {BLUE}Divide     {GREEN}6{END} - {BLUE}Quit{END}")

        try:
            # Get user input
            a = int(input(">>> ")) - 1

            # Check if user wants to quit
            if a == len(modes) or a == -len(modes)-1:
                exitAppl()

            mode = modes[a]

            # Display information of function and get all inputs  
            print(f"\n{BLUE}{mode[1]} - Please choose two numbers a and b to calculate {GREEN}a{mode[0]}{GREEN}b{END}")
            a = float(input("a: "))
            b = float(input("b: "))
            # Print result
            print(f"{BLUE}Result: {GREEN}{mode[2](a, b)}{END}")
            
            # Get enter keypress to continue the program
            input("Press enter to restart...")

        # Handle exceptions and restart program
        except ValueError:
            # User did not enter a number
            print(f"{REDBOLD}ERROR:{END} Please only enter numbers")
            input("Press enter to restart...")
        except IndexError:
            # User chose a function which does not exist
            print(f"{REDBOLD}ERROR:{END} Please enter a number between {-len(modes)} and {len(modes)+1}")
            input("Press enter to restart...")
        except ZeroDivisionError:
            # User wanted to divide by zero
            print(f"{ORANGEBOLD}WARNING:{END} Please don't divide by 0")
            input("Press enter to restart...")
        except KeyboardInterrupt:
            # Quit program properly on ctrl + c
            exitAppl()
        except Exception:
            # Make sure program does not error out
            print(f"{REDBOLD}ERROR:{END} Something went wrong")
            input("Press enter to restart...")


# Run file if file is directly executed
if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        exit()