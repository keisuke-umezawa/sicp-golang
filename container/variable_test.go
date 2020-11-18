package container

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMakeVariable(t *testing.T) {
	v := MakeVariable("x")
	fmt.Printf("%v\n", v)
}

func TestIsVariable(t *testing.T) {
	v := MakeVariable("x")
	assert.True(t, IsVariable(v))

	assert.False(t, IsVariable(1.0))
	assert.False(t, IsVariable("x"))
}

func TestIsNumber(t *testing.T) {
	assert.True(t, IsNumber(1.0))
	assert.True(t, IsNumber(1))
	assert.False(t, IsNumber("1.0"))
}

func TestIsSameVariable(t *testing.T) {
	x1 := MakeVariable("x")
	x2 := MakeVariable("x")
	y := MakeVariable("y")

	assert.True(t, IsSameVariable(x1, x2))
	assert.False(t, IsSameVariable(x1, y))
}
