package main

import (
	"fmt"
	"regexp"
)

func main() {

	const regex = "(^-?[0-9]+[.,]?[0-9]+)$"

	fmt.Println("Input some value: ")

	var input string
	fmt.Scan(&input)

	if match, _ := regexp.MatchString(regex, input); match == true {
		fmt.Println("OK")
	} else {
		fmt.Println("Wrong")
	}
}
