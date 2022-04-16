package main

import "fmt"

func Fibonacci() func(int) []int {

	t1 := 0
	t2 := 1
	nextTerm := 0
	var sequence []int
	return func(n int) []int {

		for i := 1; i <= n; i++ {

			if i == 2 {
				sequence = append(sequence, t2)
				continue
			}

			nextTerm = t1 + t2
			t1 = t2
			t2 = nextTerm

			sequence = append(sequence, nextTerm)
		}

		return sequence

	}
}

func main() {

	var length int

	fmt.Print("length of Fibonacci sequence: ")
	fmt.Scanf("%d", &length)

	fib := Fibonacci()

	fmt.Println(fib(length))

}
