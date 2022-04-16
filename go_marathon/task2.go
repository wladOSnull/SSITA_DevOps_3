package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

func main() {

	scanner := bufio.NewScanner(os.Stdin)
	const regex = "^45[0-9]{2}[ ][0-9]{4}[ ][0-9]{4}[ ][0-9]{4}$|^45[0-9]{14}$"

	fmt.Print("check card number: ")

	scanner.Scan()

	cardNumber := scanner.Text()

	match, _ := regexp.MatchString(regex, cardNumber)

	if match {
		fmt.Println("\ncard IS valide")
	} else {
		fmt.Println("\ncard IS NOT valide !")
	}
}

/*

valide card numbers:

4579975151908906
4585 9119 2222 6084
4550025693563124
4567 6325 5364 6716

*/
