import sympy as sp
from sympy.plotting import plot

#  SymPy to perform symbolic mathematics

sp.var ('x, a, b, c')

y = a*x**2+b*x+c
Solution1 = sp.solve (y, x)

display(Solution1)

a = 2
b = 3
c = 1

y = a*x**2+b*x+c
Solution2 = sp.solve (a*x**2+b*x+c, x)
display(Solution2)

print('=-'* 25)
sp.var('x, y')

eq3 = sp.Eq(2*x+1*y, 3) # | 2x+y = 3
eq4 = sp.Eq(1*x+3*y, 4) # | x+3y = 4

print(sp.solve([eq3, eq4], [x, y]))

x = sp.Symbol('x')

# Define a polynomial equation
equation = x**3 + 2*x**2 + 3*x + 4

# Find the roots of the equation
roots = sp.solve(equation, x)
print("Roots:", roots)

# Factorize the equation
factorized = sp.factor(equation)
print("Factorized:", factorized)

# Find the derivative of the equation
derivative = equation.diff(x)
print("Derivative:", derivative)

# Integrate the equation
integration = sp.integrate(equation, x)
print("Integration:", integration)

# Plot the equation
sp.plot(equation, xlim=(-10, 10), ylim=(-100, 100), show=False)
