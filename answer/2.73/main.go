package main

import (
	"fmt"

	"../../../sicp-golang/container"
)

// Deriv package

// Operator interface
type Operator interface {
	Deriv(exp interface{}, variable container.Variable) interface{}
}

// Deriv free function
func Deriv(exp interface{}, variable container.Variable) interface{} {
	if container.IsNumber(exp) {
		return 0
	}
	if container.IsVariable(exp) {
		if container.IsSameVariable(exp, variable) {
			return 1
		}
		return 0
	}
	op := exp.(container.Pair).A.(Operator)
	e := exp.(container.Pair).D
	return op.Deriv(e, variable)
}

// Sum package

type sum struct {
	v string
}

// NewSum for sum
func NewSum() sum {
	return sum{"+"}
}

func makeSum(exp1, exp2 interface{}) interface{} {
	return container.MakeList3(NewSum(), exp1, exp2)
}

func addend(exp interface{}) interface{} {
	a := exp.(container.Pair).A
	return a
}

func augend(exp interface{}) interface{} {
	d := exp.(container.Pair).D
	return d
}

func (s sum) Deriv(exp interface{}, variable container.Variable) interface{} {
	return makeSum(Deriv(addend(exp), variable), Deriv(augend(exp), variable))
}

// Product package

type product struct {
	v string
}

// NewProduct for sum
func NewProduct() product {
	return product{"*"}
}

func makeProduct(exp1, exp2 interface{}) interface{} {
	return container.MakeList3(NewProduct(), exp1, exp2)
}

func multiplier(exp interface{}) interface{} {
	a := exp.(container.Pair).A
	return a
}

func multiplicand(exp interface{}) interface{} {
	d := exp.(container.Pair).D
	return d
}

func (p product) Deriv(exp interface{}, variable container.Variable) interface{} {
	return makeSum(
		makeProduct(multiplier(exp), Deriv(multiplicand(exp), variable)),
		makeProduct(Deriv(multiplier(exp), variable), multiplicand(exp)),
	)
}

func main() {
	{
		x := container.MakeVariable("x")
		exp := makeSum(x, 3)
		fmt.Printf("expression: %v\n", exp)

		d := Deriv(exp, x)
		fmt.Printf("derived: %v\n", d)
	}
	{
		x := container.MakeVariable("x")
		exp := makeSum(makeSum(x, 3), x)
		fmt.Printf("expression: %v\n", exp)

		d := Deriv(exp, x)
		fmt.Printf("derived: %v\n", d)
	}
	{
		x := container.MakeVariable("x")
		exp := makeProduct(x, 3)
		fmt.Printf("expression: %v\n", exp)

		d := Deriv(exp, x)
		fmt.Printf("derived: %v\n", d)
	}
}
