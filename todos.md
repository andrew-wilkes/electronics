Check out: https://falstad.com/circuit/

Create example circuits.

Teach how they work, and then the person may experiment and try to recreate them.

https://falstad.com/mathphysics.html


Airy Chimes
Andrew Wilkes yes that's the common process. Time dependent functions such as differential response of a capacitor or inductor, are stepwise approximated wrt time, usually first order linear model for them is sufficient. Then one chooses a numerical integration method and solves for a set of linear differential equations defined by such matrix. For nonlinear components (if involved) there is more to this, iterations like Newton-Rhapson algorithm, but for just RLC circuits linear simulation should be fine.

Start at voltage source, every part connected to it gets the input voltage set.
Resistors draw current.
Inductors get a change to their current.
Capacitors draw current according to dv.

All sourcing parts provide a current.
A sourcing resistor sets the voltage.
A sourcing capacitor sets the voltage.

Now need to distribute the current between parts.
Resistors change voltage and capacitors draw current as the voltage increases.
Inductors track the voltage.

1. Deduct inductor current.
2. Calc dv.
3. Set new V and Ri values.
4. Set new Li values.

----------------
Reduce the graph to a simplified circuit model.
Add transistor.
Add models to parts.
