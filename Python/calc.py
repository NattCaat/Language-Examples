import os

# all the actual calculation functions.
def add(a: float, b: float) -> float:
    return a + b


def sub(a: float, b: float) -> float:
    return a - b


def mul(a: float, b: float) -> float:
    return a * b


def div(a: float, b: float) -> float:
    return a / b


# why this way? because it's practice in the language
def exp(base: float, exp: float) -> float:
    # this here is exponentiation in the most basic sense

    if exp == 0:
        return 1  # a ^ 0 = 1. ALWAYS
    else:
        n, out = 0, base  # set n and our output
        while exp > 1:  # multiply n times, but only if exponent > 1, because a^1 = a
            out, exp = (
                out * base,
                exp - 1,
            )  # multiply out by the base and subtract 1 from the exponent
        return out


def main():
    modes = (  # this tuple defines the interface components and all functions
        # at the 0th place is the symbol, then the name and at last the function
        ("+", "Addition", add),
        ("-", "Subtraction", sub),
        ("*", "Multiplication", mul),
        ("/", "Division", div),
        ("^", "Exponentiation", exp),
    )

    while True:
        choice = 0
        while True:
            # clear the terminal
            os.system("cls" if os.name == "nt" else "clear")

            # print the full start message
            print("Python CLI calc V1.0")
            print("choose a function")
            print("1 - Add        3 - Multiply   5 - Exponentiation")
            print("2 - Subtract   4 - Divide")

            try:
                choice = (
                    int(input(">>> ")) - 1
                )  # get the input and make it into our index (we count from zero)
                mode = modes[choice]
                break
                    
            except KeyboardInterrupt:  # handle ctrl + c to exit properly
                print("\nExiting program...")
                exit()
            except ValueError:
                print(
                    "ERROR: Please only use numbers"
                )  # we can't handle letters, reject and restart
                input("Press enter to restart...")  # get an enter keypress
            except IndexError:
                print(f"ERROR: Please only use numbers between {(len(modes)-1)*-1} and {len(modes)}.")
                input(
                    "Press enter to restart..."
                )  # get input, but send it nowhere (essentially make it register on enter)
                continue



        print(
            f'\n{mode[1]} - Please choose two numbers a and b to calculate "a{mode[0]}b"'
        )  # print the prompt message
        try:
            # get all inputs
            a = float(input("a: "))
            b = float(input("b: "))
            print(f"result: {mode[2](a,b)}")  # print the results to the terminal
        except KeyboardInterrupt:
            print("\nExiting program...")
            exit()
        except Exception:
            print(
                "ERROR: Please only use numbers."
            )  # we can't handle letters, reject and restart
        input("Press enter to restart...")  # wait to restart


# this only runs if the file is directly executed.
# if we import this file, this part is irrelevant and does nothing
# that way we could theoretically import the functions in here, but also have a test method
if __name__ == "__main__":
    try:
        main()  # start the program
    except KeyboardInterrupt:
        exit()