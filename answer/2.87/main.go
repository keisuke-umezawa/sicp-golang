package main

import (
	"fmt"
)

// Expression is the interface for all expression type.
type Expression interface {
	Add(exp Expression) Expression
}

// Poly is the struct for polynomial expressino.
type Poly struct {
	variable string
	terms    []Term
}

type Term struct {
	coeff Expression
	order int
}

func addTerms(l1, l2 []Term) []Term {
	if len(l1) == 0 {
		return l2
	}
	if len(l2) == 0 {
		return l1
	}
	t1 := l1[0]
	t2 := l2[0]
	if t1.order > t2.order {
		return append([]Term{t1}, addTerms(l1[1:], l2)...)
	}
	if t1.order < t2.order {
		return append([]Term{t2}, addTerms(l1, l2[1:])...)
	}
	return append([]Term{{order: t1.order, coeff: t1.coeff.Add(t2.coeff)}}, addTerms(l1[1:], l2[1:])...)
}

// Add implementation
func (p1 Poly) Add(exp Expression) Expression {
	switch v := exp.(type) {
	case Poly:
		if !isSameVariable(p1, v) {
			panic("Different vairables")
		}
		return Poly{variable: p1.variable, terms: addTerms(p1.terms, v.terms)}
	default:
		panic("No implementation")
	}
}

func isSameVariable(p1, p2 Poly) bool {
	return p1.variable == p2.variable
}

// Scalar is the ...
type Scalar struct {
	value int
}

// Add implementation
func (s1 Scalar) Add(exp Expression) Expression {
	switch v := exp.(type) {
	case Scalar:
		return Scalar{s1.value + v.value}
	default:
		panic("No implementation")
	}
}

func main() {
	{
		p1 := Poly{
			variable: "x",
			terms:    []Term{{order: 2, coeff: Scalar{1}}, {order: 0, coeff: Scalar{2}}},
		}
		p2 := Poly{
			variable: "x",
			terms:    []Term{{order: 2, coeff: Scalar{1}}, {order: 0, coeff: Scalar{2}}},
		}
		fmt.Printf("Add: %v\n", p1.Add(p2))
	}
	{
		s1 := Scalar{4}
		s2 := Scalar{5}
		fmt.Printf("Add: %v\n", s1.Add(s2))
	}
}
