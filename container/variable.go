package container

// Variable
type Variable struct {
	v string
}

// MakeVariable
func MakeVariable(v string) Variable {
	return Variable{v}
}

// IsVariable
func IsVariable(v interface{}) bool {
	_, ok := v.(Variable)
	return ok
}

// IsNumber
func IsNumber(v interface{}) bool {
	_, ok1 := v.(float32)
	_, ok2 := v.(float64)
	_, ok3 := v.(int)
	return ok1 || ok2 || ok3
}

// IsSameVatiable
func IsSameVariable(v1 interface{}, v2 interface{}) bool {
	return IsVariable(v1) && IsVariable(v2) && v1 == v2
}
