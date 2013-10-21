# This method verifies whether a string can be parsed as a number.
def isNumber(string)
    if string.to_i.to_s == string
        return true
    else
        return false
    end
end

# Moves left from the given index and returns a string consisting of all the
# numbers it encounters until it hits something that isn't a number.
def getFirstOperand(expression, index)
    operand = Array.new

    while isNumber(expression[index]) and index >= 0
        operand.unshift(expression[index])
        index -= 1
    end

    return operand.join
end

# Moves right from the given index and returns a string consisting of all the
# numbers it encounters until it hits something that isn't a number.
def getSecondOperand(expression, index)
    operand = Array.new

    while isNumber(expression[index]) and index < expression.size
        operand.push(expression[index])
        index += 1
    end

    return operand.join
end

# Calculate the appropriate operation between the first and second operand.
# Returns the result as a number.
def calcOperation(firstOperand, secondOperand, operator)
    firstOperand = firstOperand.to_i
    secondOperand = secondOperand.to_i

    if operator == "*"
        return firstOperand * secondOperand
    elsif operator == "/"
        return firstOperand / secondOperand
    elsif operator == "+"
        return firstOperand + secondOperand
    elsif operator == "-"
        return firstOperand - secondOperand
    else
        return nil
    end
end

# Resolve all the additions and subtractions in the expression.
# Note that all changes are done in-place, this method is destructive.
def resolveOperation(expression, operators)
    operatorIndex = nil

    # Iterate through the expression locating all the relevant operators and
    # then replace the substring with the result of the operation. Replacements
    # are done in place.
    until (operatorIndex = expression.index(/[#{operators}]/)) == nil

        # Isolate the operands and operator for the addition or subtraction.
        firstOperand = getFirstOperand(expression, operatorIndex - 1)
        operator = expression[operatorIndex]
        secondOperand = getSecondOperand(expression, operatorIndex + 1)

        # Concatenate the operands and operator to get the substring that will
        # be replaced.
        substring = firstOperand + operator + secondOperand

        # Calculate the result of the addition or subtraction.
        replacement = calcOperation(firstOperand, secondOperand, operator).to_s

        # Substitute substring with the calculated result.
        expression.gsub!(substring, replacement)
    end

    return expression
end

# Resolve all operations and return the result of the expression. It returns
# the expression as a string and transforms it in-place.
def calcExpression(expression)
    resolveParen(expression)
    resolveOperation(expression, "*/")
    resolveOperation(expression, "+-")

    return expression
end

# This method recursively resolves all the parenthetical sub-expressions within
# an expression. It returns an expression as a string.
def resolveParen(expression)
    # Find the first parenthetical sub expression.
    parenExpression = findParen(expression)

    # If there are no subexpressions, then return the expression.
    # Otherwise, recursively resolve all subexpressions by replacing them with
    # their calculated results.
    if parenExpression == nil
        return expression
    else
        substring = "(" + parenExpression + ")"

        # If the opening paren has no operator in front of it, then insert a
        # multiplication sign.
        index = expression.index(substring)
        if index > 0 and (isNumber(expression[index - 1]) or expression[index - 1] == ")")
            expression.insert(index, "*")
        end

        result = calcExpression(parenExpression)

        # Recursively resolve the parenetheses for the transformed expression.
        return resolveParen(expression.gsub!(substring, result))
    end
end

# This method finds the first occurring parenthetical subexpression in an
# expression. It returns the subexpression as a string.
def findParen(expression)

    unless (parenIndex = expression.index("(")) == nil
        parenLevel = 1
        parenExpression = Array.new
        parenIndex += 1

        # Adds each element of the expression starting at parenindex to the
        # parenExpression until parenLevel is 0. parenLevel starts at 1 (due to
        # the opening parenthesis) and goes up when another opening paren is
        # encountered and down when a closing paren is encountered.
        # Note that parenExpression does not include its outermost parentheses.
        until parenLevel == 0
            if expression[parenIndex] == ")"
                parenLevel -= 1
            elsif expression[parenIndex] == "("
                parenLevel += 1
            end

            if parenLevel > 0
                parenExpression.push(expression[parenIndex])
            end

            parenIndex += 1
        end

        return parenExpression.join
    end

    return nil
end

# Read in the expressions file as an array of lines.
expressions = File.new("expressions.in").readlines

# Calculate all expressions.
for expression in expressions
    puts calcExpression(expression)
end
