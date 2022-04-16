package main

import (
	"fmt"
	"strconv"
	"strings"
)

const half = 3

var defScopeA = "000"
var defScopeB = "999"

func printMap(a map[int][]string, b int, c string) {

	minKey := 28
	maxKey := -1

	for i := range a {

		if i < minKey {
			minKey = i
		}

		if i > maxKey {
			maxKey = i
		}
	}

	fmt.Println(c, " map:", len(a))
	for i := minKey; i <= maxKey; i++ {
		fmt.Println("key, value: ", i, a[i])
	}

	fmt.Println("length of: ", b, " - ", len(a[b]))
	for _, v := range a[b] {
		fmt.Print(v, " ")
	}
	fmt.Println()
}

func buildMap(a int, b int) map[int][]string {

	sumMap := make(map[int][]string)
	fmt.Println("from: ", a, " to: ", b)

	for i := a; i <= b; i++ {

		sum := 0
		str := strings.Split(strconv.Itoa(i), "")

		for i, v := range str {
			i, _ = strconv.Atoi(v)
			sum += i
		}

		if i < 10 {
			str = append([]string{"0", "0"}, str...)
		} else if i < 100 {
			str = append([]string{"0"}, str...)
		}

		fmt.Println("str: ", str, " sum: ", sum)

		sumMap[sum] = append(sumMap[sum], strings.Join(str, ""))

	}

	return sumMap
}

func threeToThree(a string, b string) {

	firstHalfMap := make(map[int][]string)
	secondHalfMap := make(map[int][]string)

	ticketA := strings.Split(a, "")
	firstHalfTicketA := ticketA[:half]
	secondHalfTicketA := ticketA[half:]

	ticketB := strings.Split(b, "")
	firstHalfTicketB := ticketB[:half]
	secondHalfTicketB := ticketB[half:]

	fmt.Println("ticket A: first: ", firstHalfTicketA, " second: ", secondHalfTicketA)
	fmt.Println("ticket B: first: ", firstHalfTicketB, " second: ", secondHalfTicketB)

	from, _ := strconv.Atoi(defScopeA)
	to, _ := strconv.Atoi(defScopeB)
	secondHalfMap = buildMap(from, to)
	printMap(secondHalfMap, 25, "second")

	/***************************************/

	from, _ = strconv.Atoi(strings.Join(firstHalfTicketA, ""))
	to, _ = strconv.Atoi(strings.Join(firstHalfTicketB, ""))
	firstHalfMap = buildMap(from, to)
	printMap(firstHalfMap, 20, "first")

	//count combination
	combination := 0
	for i, v := range firstHalfMap {

		if w, ok := secondHalfMap[i]; ok {
			//fmt.Println("find FIRST: ", v, " find SECOND: ", w)
			combination += len(v) * len(w)
			fmt.Println("FIND: ", i, "length first/second:", len(v), "*", len(w), "=", (len(v) * len(w)))
		}
	}
	fmt.Println("\n\n--Result--\nEasyFormula: ", combination)

}

func evenToOdd(a string, b string) {

	from, _ := strconv.Atoi(a)
	to, _ := strconv.Atoi(b)
	combination := 0

	for i := from; i <= to; i++ {

		str := strings.Split(strconv.Itoa(i), "")

		even, odd := 0, 0

		for _, v := range str {

			x, _ := strconv.Atoi(v)
			//fmt.Println("number: ", x)
			if x%2 == 0 {
				even += x
			} else {
				odd += x
			}

		}

		//fmt.Println("str: ", str, " even: ", even, " odd: ", odd)

		if even == odd {
			combination += 1
		}
	}

	fmt.Println("HardFormula: ", combination)
}

func luckyTicket(a string, b string) {

	threeToThree(a, b)
	evenToOdd(a, b)
}

func main() {

	var scopeA, scopeB string

	fmt.Print("start scope <space> end scope: ")
	fmt.Scanf("%s%s", &scopeA, &scopeB)

	luckyTicket(scopeA, scopeB)
}

/*

Min: 120123
Max: 320320

--Result--
EasyFormula: 11187
HardFormula: 5790

https://www.careercup.com/question?id=7550661
https://www.quora.com/Whats-the-probability-of-getting-an-equal-sum-of-first-three-digits-and-last-three-digits-of-a-6-digit-ticket-number


*/
