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
		} else {
			return 0
		}
	}
	if isSum(exp) {
		return container.MakeList3("+", deriv(addend(exp), variable), deriv(augend(exp), variable))
	}
	return exp
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

func isSum(exp interface{}) bool {
	return container.IsPair(exp) && exp.(container.Pair).A == "+"
}

func main() {
	x := container.MakeVariable("x")
	exp := container.MakeList3("+", x, 3)
	fmt.Printf("expression: %v\n", exp)

	d := deriv(exp, x)
	fmt.Printf("derived: %v\n", d)
}
