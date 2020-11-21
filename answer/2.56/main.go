package main

import (
	"fmt"

	"../../../sicp-golang/container"
)

func deriv(exp interface{}, variable container.Variable) interface{} {
	if container.IsNumber(exp) {
		return 0
	}
	if container.IsVariable(exp) {
		if container.IsSameVariable(exp, variable) {
			return 1
		}
		return 0
	}
	if isSum(exp) {
		return makeSum(deriv(addend(exp), variable), deriv(augend(exp), variable))
	}
	if isProduct(exp) {
		return makeSum(
			makeProduct(multiplier(exp), deriv(multiplicand(exp), variable)),
			makeProduct(deriv(multiplier(exp), variable), multiplicand(exp)),
		)
	}
	if isExponentiation(exp) {
		return makeProduct(
			exponent(exp),
			makeProduct(
				makeExponentiation(base(exp), makeSum(exponent(exp), -1)),
				deriv(base(exp), variable),
			),
		)
	}
	panic(fmt.Sprintf("unknown expression type: %v", exp))
}

func makeSum(exp1, exp2 interface{}) interface{} {
	return container.MakeList3("+", exp1, exp2)
}

func isSum(exp interface{}) bool {
	return container.IsPair(exp) && exp.(container.Pair).A == "+"
}

func addend(exp interface{}) interface{} {
	e := exp.(container.Pair)
	a := e.D.(container.Pair).A
	return a
}

func augend(exp interface{}) interface{} {
	e := exp.(container.Pair)
	d := e.D.(container.Pair).D
	return d
}

func makeProduct(exp1, exp2 interface{}) interface{} {
	return container.MakeList3("*", exp1, exp2)
}

func isProduct(exp interface{}) bool {
	return container.IsPair(exp) && exp.(container.Pair).A == "*"
}

func multiplier(exp interface{}) interface{} {
	e := exp.(container.Pair)
	a := e.D.(container.Pair).A
	return a
}

func multiplicand(exp interface{}) interface{} {
	e := exp.(container.Pair)
	d := e.D.(container.Pair).D
	return d
}

func makeExponentiation(exp1, exp2 interface{}) interface{} {
	return container.MakeList3("^", exp1, exp2)
}

func isExponentiation(exp interface{}) bool {
	return container.IsPair(exp) && exp.(container.Pair).A == "^"
}

func base(exp interface{}) interface{} {
	e := exp.(container.Pair)
	a := e.D.(container.Pair).A
	return a
}

func exponent(exp interface{}) interface{} {
	e := exp.(container.Pair)
	d := e.D.(container.Pair).D
	return d
}

func main() {
	{
		x := container.MakeVariable("x")
		exp := makeSum(x, 3)
		fmt.Printf("expression: %v\n", exp)

		d := deriv(exp, x)
		fmt.Printf("derived: %v\n", d)
	}
	{
		x := container.MakeVariable("x")
		exp := makeSum(makeSum(x, 3), x)
		fmt.Printf("expression: %v\n", exp)

		d := deriv(exp, x)
		fmt.Printf("derived: %v\n", d)
	}
	{
		x := container.MakeVariable("x")
		exp := makeProduct(x, 3)
		fmt.Printf("expression: %v\n", exp)

		d := deriv(exp, x)
		fmt.Printf("derived: %v\n", d)
	}
	{
		x := container.MakeVariable("x")
		exp := makeExponentiation(x, 3)
		fmt.Printf("expression: %v\n", exp)

		d := deriv(exp, x)
		fmt.Printf("derived: %v\n", d)
	}
	{
		x := container.MakeVariable("x")
		exp := container.MakeList3(".", x, 3)
		fmt.Printf("expression: %v\n", exp)

		d := deriv(exp, x)
		fmt.Printf("derived: %v\n", d)
	}
}
