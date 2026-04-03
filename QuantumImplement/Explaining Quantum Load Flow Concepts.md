
Here is why **Pauli Decomposition** is the "Gold Standard" for current-day Quantum NR implementations:

### 1. The "Measurement" Problem (Quantum Blindness)
A quantum computer is like a black box. You cannot simply "look" inside and see a matrix. You can only **measure** the result.
*   **The Problem:** We need to calculate a "Cost Function" to see how close our guess is to the real answer. This involves calculating the matrix product $A \cdot | \psi \rangle$.
*   **The Solution:** You cannot measure a random matrix $A$ directly. However, you **can** measure Pauli operators ($X, Y, Z$) very easily. By breaking $A$ into Paulis, we turn one "impossible" measurement into a series of "simple" measurements that we then add up classically.

### 2. NISQ Hardware Limits (The "Short Leash")
We are currently in the **NISQ Era** (Noisy Intermediate-Scale Quantum). Our quantum computers are fragile and "noisy."
*   **Alternative - HHL Algorithm:** There is a famous algorithm called HHL that solves linear systems. However, it requires **"Matrix Exponentiation"** and **"Quantum Phase Estimation."** 
    *   *Why we don't use it:* It requires thousands of perfect gates. On today’s hardware, the noise would destroy the calculation before it finished.
*   **VQLS + Pauli Decomp:** This approach is "Variational." It uses short, shallow circuits that the noise doesn't kill. Pauli decomposition allows us to keep the quantum part simple and offload the heavy lifting to the classical processor.

### 3. The "Unitarity" Requirement
Quantum gates must be **Unitary** (they must preserve the total probability of 1). 
*   **The Problem:** Most Jacobian matrices in power systems are **not** unitary. You can't just "plug them in" as a gate.
*   **The Solution:** Pauli operators ($X, Y, Z, I$) **are** unitary. By decomposing the Jacobian into a sum of Paulis ($J = \sum c_i P_i$), we are essentially converting a "non-quantum" matrix into a list of "legal" quantum instructions.

### 4. Linearity = Parallelism
Because $J$ is a linear combination of Paulis, we can run the algorithm like this:
1.  Measure how the circuit performs against Pauli term #1.
2.  Measure it against Pauli term #2.
3.  ...and so on.


Quantum computers don't speak the language of standard calculus or matrices. They only speak the language of 'Rotations' and 'Flips' (Paulis). Pauli Decomposition is our **universal translator**. It takes a complex power grid problem and translates it into a language the quantum hardware can actually execute without crashing or being overwhelmed by noise.



### 1. The "Simple" NR (The Logic)
This refers to the **Newton-Raphson algorithm itself** 


### 2. `np.linalg.solve` (The Classical Workhorse)
This is the standard command used in Python/MATLAB to solve $J \cdot dx = b$.
*   **Role:** The **Classical Executor**. It uses 20th-century algorithms (like Gaussian Elimination or LU Decomposition) to find the answer on a standard CPU.
*   **Importance:** It is our **Benchmarking Tool**. However, its fatal flaw is **scaling**. As the power grid grows from 3 buses to 30,000 buses, the time it takes to "solve" grows cubically ($N^3$). If the grid doubles, the math takes 8 times longer.

### 3. `VQLS` (The Quantum Accelerator)
This is what replaces the "solve" command in your quantum version of the code.
*   **Role:** The **Quantum Optimizer**. It doesn't "calculate" the answer line-by-line; it "evolves" a quantum state to represent the answer.
*   **Use:** It is the research-grade replacement for the `solve` step, designed to run on Quantum Processing Units (QPUs).
*   **Importance:** **Efficiency**. Theoretically, VQLS can solve the system in logarithmic time ($\log N$). In a future grid with millions of solar panels and EV chargers, VQLS could solve in seconds what a classical supercomputer might take hours to finish.

---

### **The Key Difference: "How the Math happens"**

| Feature | Simple NR (Logic) | `np.linalg.solve` (Classical) | `VQLS` (Quantum) |
| :--- | :--- | :--- | :--- |
| **Complexity** | N/A (Iteration Logic) | $O(N^3)$ — Slows down quickly. | $O(\log N)$ — Stays fast. |
| **Hardware** | Your Brain / Code | Standard Intel/AMD CPU | Qiskit / IBM Quantum Chip |

---

### **A Presentation Tip: The "Analogy"**
*"If we are trying to navigate a ship through a storm:"*


the VQLS code is taking more time to implement NR method in 3 bus system, what will happen for more bus system will the time increase or decrease when compared to classical one?


The short answer: **The "Quantum Advantage" only appears as the grid gets MUCH larger.**


### 1. The "Fixed Overhead" (Why VQLS is slow now)
Right now, you are running a **Quantum Simulator**. 
*   **The Overhead:** Every time your code runs VQLS, it has to:
    1.  Create a "circuit" from scratch.
    2.  Start an "Optimization Loop" (like COBYLA) that tests the circuit hundreds of times.
    3.  Simulate the probability of qubits.

### 2. The "Cross-over Point" (The Scaling Secret)

*   **Classical ($O(N^3)$):** If you go from 3 buses to 3,000 buses, the classical work increases by **$1,000,000,000$ times**. 
*   **Quantum ($O(\log N)$):** If you go from 3 buses to 3,000 buses, the quantum work only increases by about **10-15 times**. 

**What will happen?**
There is a **"Cross-over Point"**. For small grids (3, 14, 30 buses), the classical method will always win. But once you hit a certain size (e.g., a national power grid with 50,000 buses), the classical computer will "choke" and take hours, while the quantum computer will still finish in seconds.

### 3. Simulation vs. Real Hardware
*   **What you see now:** Since you are *simulating* a quantum computer on a normal laptop, the laptop has to do "double the work" to pretend it's quantum. This makes it even slower as you add buses.
*   **On a Real QPU:** On a real IBM or Google quantum chip, the qubits interact **instantly**.


**Conclusion for your presentation:**
> *"The goal of this project isn't to beat a classical computer at 3 buses—that's impossible. The goal is to prove that **Quantum scaling is the key** to managing the future's massive, complex green-energy grids that classical computers simply won't be able to handle."*

### **3. Methodology: Quantum-Accelerated Newton-Raphson Load Flow**

#### **3.1 The Computational Bottleneck in Power Systems**
The classical Newton-Raphson (NR) method is the cornerstone of power system load flow analysis. It iteratively solves the non-linear relationship between bus voltages and power injections by linearizing the system using a Jacobian matrix $J$. In each iteration $k$, the linear system is defined as:
$$J^{(k)} \Delta x^{(k)} = \Delta M^{(k)}$$
where $\Delta x$ represents the update vector for voltage magnitudes and phase angles, and $\Delta M$ is the power mismatch vector. As the grid size $N$ increases, solving this linear system using classical algorithms like LU Decomposition or Gaussian Elimination incurs a computational complexity of $O(N^3)$. For large-scale interconnected grids, this cubic scaling limits real-time monitoring and emergency contingency analysis.

#### **3.2 Variational Quantum Linear Solver (VQLS)**
To address the scaling limitations of classical solvers, this research implements the **Variational Quantum Linear Solver (VQLS)**. Unlike the foundational HHL (Harrow-Hassidim-Lloyd) algorithm, which requires high-depth circuits and fault-tolerant hardware, VQLS is a Noisy Intermediate-Scale Quantum (NISQ) friendly algorithm. 

VQLS reformulates the linear system $Ax = b$ as an optimization problem. It prepares a variational ansatz (a parameterized quantum circuit) $|\psi(\theta)\rangle$ and minimizes a cost function $C(\theta)$ defined as:
$$C(\theta) = 1 - \frac{|\langle \phi | A | \psi(\theta) \rangle|^2}{\| A | \psi(\theta) \rangle \|^2}$$
where $|\phi\rangle$ is the quantum state encoding the mismatch vector $b$. The optimal parameters $\theta^*$ yield a quantum state that represents the solution vector $x = A^{-1}b$.

#### **3.3 Pauli Decomposition of the Jacobian**
Quantum hardware cannot directly process arbitrary matrices. Therefore, the Jacobian $J$ must be mapped to the quantum Hilbert space via **Pauli Decomposition**. Any complex $2^n \times 2^n$ matrix can be expressed as a linear combination of Pauli strings:
$$J = \sum_{i} c_i P_i, \quad P_i \in \{I, X, Y, Z\}^{\otimes n}$$
This decomposition serves as the "translator" between classical power flow data and quantum operations. By representing $J$ as a sum of unitaries, the quantum computer can evaluate the cost function through a series of measurements (e.g., the Hadamard Test or Overlap Test) that are natively supported by quantum gates.

---

### **4. Results and Comparative Analysis**

#### **4.1 Comparison of Solver Architectures**
In this study, three distinct approaches were evaluated for a 3-bus system:

1.  **Conceptual NR (Simple):** Provides the mathematical framework for mismatch calculation and Jacobian construction. 
2.  **Classical NR (`np.linalg.solve`):** Serves as the numerical baseline. It offers high precision ($10^{-16}$) for small-scale systems but suffers from $O(N^3)$ complexity.
3.  **Quantum NR (VQLS):** Implements a hybrid quantum-classical loop where the linear solve step is offloaded to a quantum simulator.

| Feature | Classical Solver | Quantum (VQLS) Solver |
| :--- | :--- | :--- |
| **Complexity** | $O(N^3)$ Polynomial | $O(\text{poly}(\log N))$ Polylogarithmic |
| **Convergence** | Quadratic (Standard NR) | Dependent on Ansatz Depth and Optimizer |
| **Hardware** | Classical CPU (Von Neumann) | NISQ Quantum Processor / Simulator |

#### **4.2 Discussion on Computational Scaling and "Quantum Advantage"**
A critical observation in the 3-bus implementation is that the VQLS solver exhibits higher execution times compared to the classical solver. This is attributed to two factors:
1.  **Optimization Overhead:** VQLS requires hundreds of classical-quantum iterations (e.g., using the COBYLA optimizer) to tune the ansatz parameters for a single NR step. For small $N$, the overhead of this optimization far exceeds the time saved in the linear solve.
2.  **Statevector Simulation:** Since the current implementation utilizes a classical simulator, the simulation time scales exponentially with the number of qubits ($2^n$).

However, the **Quantum Advantage** is realized in the asymptotic scaling. While classical time increases cubically with $N$, the quantum circuit depth for VQLS increases only logarithmically. For ultra-large-scale systems (e.g., $N > 10^5$), the classical approach becomes computationally intractable, whereas VQLS maintains a manageable execution time on fault-tolerant quantum hardware.

---

### **5. Conclusion**
The integration of VQLS into the Newton-Raphson load flow demonstrates a feasible pathway for quantum-accelerated power system analysis. While current NISQ simulations show higher latency for minimal bus configurations, the theoretical polylogarithmic scaling of VQLS positions it as a vital technology for real-time management of the increasingly complex and decentralized smart grids of the future.



## 1. Simple Classical NR (Manual / Inverse-Based)

### Approach

[
\Delta x = J^{-1} \cdot \text{mismatch}
]

### Key Points

* Uses direct matrix inversion or manual elimination
* Easy to understand conceptually
* Not efficient for large systems

### Limitations

* Computationally slow
* Numerically unstable

---

## 2. Efficient Classical Method (`np.linalg.solve`)

### Approach

[
J \cdot \Delta x = \text{mismatch}
]

Solved using optimized numerical methods (LU decomposition)

### Key Points

* No matrix inversion required
* Fast and stable
* Industry standard

### Advantages

* High accuracy
* Efficient for large systems

---

## 3. Quantum Approach (VQLS)

### Idea

Solve:
[
A x = b
]

using a variational quantum algorithm.

---

## 🔁 Transformation Used

Since quantum methods require symmetric matrices:

[
Jx = mm
\Rightarrow (J^T J)x = J^T mm
]

Where:

* (A = J^T J)
* (b = J^T mm)

---

# ⚛️ VQLS (Variational Quantum Linear Solver)

## Steps

1. Prepare trial quantum state:
   [
   |\psi(\theta)\rangle
   ]

2. Define cost function:
   [
   C(\theta) = 1 - \frac{|\langle b | A | \psi \rangle|^2}{|A|\psi\rangle|^2 \cdot \langle b|b\rangle}
   ]

3. Optimize parameters (COBYLA)

4. Extract solution vector

---

## Key Idea

Instead of solving directly, VQLS:

* Guesses a solution
* Minimizes error iteratively

---

# 🧩 Pauli Decomposition

## Concept

Any matrix can be written as:

[
A = aI + bX + cY + dZ
]

Where:

[
I =
\begin{bmatrix}1 & 0 \ 0 & 1\end{bmatrix}, \quad
X =
\begin{bmatrix}0 & 1 \ 1 & 0\end{bmatrix}
]

[
Y =
\begin{bmatrix}0 & -i \ i & 0\end{bmatrix}, \quad
Z =
\begin{bmatrix}1 & 0 \ 0 & -1\end{bmatrix}
]

---

## Example

[
A =
\begin{bmatrix}
3 & 1 \
1 & 3
\end{bmatrix}
]

### Coefficients

[
a = 3, \quad b = 1, \quad c = 0, \quad d = 0
]

### Result

[
A = 3I + X
]

---

# 🔁 Quantum NR Workflow

1. Compute mismatch
2. Build Jacobian
3. Convert to symmetric system
4. Perform Pauli decomposition
5. Solve using VQLS
6. Update variables

---

# 📊 Comparison

| Feature     | Classical (Manual) | `np.linalg.solve` | VQLS               |
| ----------- | ------------------ | ----------------- | ------------------ |
| Accuracy    | Medium             | High              | Approximate        |
| Speed       | Slow               | Fast              | Slow (current)     |
| Stability   | Low                | High              | Depends            |
| Scalability | Poor               | Good              | Excellent (future) |
| Use         | Learning           | Industry          | Research           |

---

# 🚀 Key Insights

* All methods solve the same NR equation
* Difference lies in computation technique
* Classical methods dominate today
* Quantum methods are promising for future large-scale systems

---

# 🎯 Final Summary

> Classical methods provide fast and accurate solutions for current systems, while VQLS introduces a quantum-based optimization approach that may offer scalability advantages for very large problems in the future.
