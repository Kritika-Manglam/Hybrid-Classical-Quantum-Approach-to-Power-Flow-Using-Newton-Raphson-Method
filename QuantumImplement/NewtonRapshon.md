# Newton-Raphson Method

The Newton-Raphson method is an iterative numerical technique used for finding successively better approximations to the roots of a real-valued function, and its primary purpose is to efficiently solve non-linear equations.

## Flow Chart For Newton Raphson Method

![Flow Chart](src/Flow-chart.png)

It works as an iterative approach using derivatives. Starting with an initial guess, the method approximates the function locally by its tangent line and calculates the x-intercept of this tangent line as the next, improved guess. This process is repeated until the desired level of accuracy is achieved.

$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}$$

This mathematical formula defines the iterative process. The method exhibits quadratic convergence, meaning that the number of correct decimal places roughly doubles with each iteration, provided certain conditions are met, such as a sufficiently good initial guess and a non-zero derivative at the root.

## Advantages

- **Quadratic convergence**: Fast and accurate once close to the true solution
- **Suitable for nonlinear systems**: Ideal for power flow equations.

## Limitations

- Requires a **good initial guess**; poor guesses can cause divergence.
- **Derivative near zero** can hinder convergence.
- **High computational cost** for large systems due to repeated Jacobian evaluation.

The Newton-Raphson method finds significant application in power systems for solving nonlinear equations, particularly in load flow analysis. Power flow equations are inherently nonlinear, and the Newton-Raphson method is widely used due to its fast convergence to find the voltage magnitudes and angles at various buses, which are critical for power system operation and planning.

---

# Basic Equations of Newton-Raphson Method in Power Systems

The equations relate the injected active (P) and reactive (Q) power at each bus to the bus voltage magnitudes ($V$) and phase angles ($\delta$). For a given bus $i$ connected to bus $k$, the power flow equations are generally expressed as:

$$P_i = V_i^2 G_{ii} + \sum_{k \neq i} V_i V_k (G_{ik} \cos(\delta_i - \delta_k) + B_{ik} \sin(\delta_i - \delta_k))$$

$$Q_i = -V_i^2 B_{ii} + \sum_{k \neq i} V_i V_k (G_{ik} \sin(\delta_i - \delta_k) - B_{ik} \cos(\delta_i - \delta_k))$$

where $G$ and $B$ are the real and imaginary parts of the admittance matrix elements. To solve these non-linear equations iteratively, the Newton-Raphson method linearizes them around an initial operating point. This linearization leads to the formation of the Jacobian matrix, which contains the partial derivatives of the power mismatches with respect to the voltage magnitudes and angles.

The Jacobian matrix ($J$) for a power system typically has the following structure, partitioning its elements based on the derivatives:

$$J = \begin{bmatrix} \frac{\partial P}{\partial \delta} & \frac{\partial P}{\partial |V|} \\ \frac{\partial Q}{\partial \delta} & \frac{\partial Q}{\partial |V|} \end{bmatrix}$$

This matrix relates the changes in power mismatches ($\Delta P, \Delta Q$) to the changes in voltage angles ($\Delta \delta$) and voltage magnitudes ($\Delta V$) in a matrix form:

$$\begin{bmatrix} \Delta P \\ \Delta Q \end{bmatrix} = \begin{bmatrix} J_{11} & J_{12} \\ J_{21} & J_{22} \end{bmatrix} \begin{bmatrix} \Delta \delta \\ \Delta |V| \end{bmatrix}$$

The iterative update equations are derived by solving this linearized system to find the corrections to the voltage angles and magnitudes. These corrections are then added to the current values to obtain a new, improved estimate for the next iteration:

$$\begin{bmatrix} \delta^{k+1} \\ |V|^{k+1} \end{bmatrix} = \begin{bmatrix} \delta^k \\ |V|^k \end{bmatrix} + \begin{bmatrix} \Delta \delta^k \\ \Delta |V|^k \end{bmatrix}$$

The iterative process continues until the power mismatches ($\Delta P$ and $\Delta Q$) fall below a predefined small tolerance value, which serves as the convergence criteria. Typical tolerance settings are on the order of $10^{-4}$ or $10^{-5}$ per unit (p.u.), indicating that the calculated power flows are very close to the specified injected powers.
