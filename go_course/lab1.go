package main

import "fmt"

func main() {

	fmt.Println("How are you?")

	var answer string
	fmt.Scan(&answer)

	fmt.Printf("You are %s\n", answer)
}
