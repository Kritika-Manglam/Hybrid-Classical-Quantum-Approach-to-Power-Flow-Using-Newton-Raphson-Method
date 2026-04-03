# VQLS Concepts Explained

## The Core Problem 

In Newton-Raphson load flow, at **every iteration** we must solve:

```
J · Δx = mm

J  = Jacobian matrix (partial derivatives of power mismatches)
Δx = update vector  [Δδ₂, Δδ₃, ΔV₂, ...]
mm = mismatch vector [ΔP₂, ΔQ₂, ΔP₃, ...]
```

Classical method: `np.linalg.solve(J, mm)` — works in **O(N³)** time.
For a 1000-bus grid at each iteration: 10⁹ operations → slow.

**VQLS replaces this linear solve with a quantum algorithm using O(log N) qubits.**

---

## Example

To keep math simple, use a **2-bus system** (Bus 1: Slack, Bus 2: PQ).
Unknowns: [Δδ₂, ΔV₂]. Mismatches: [ΔP₂, ΔQ₂].

Suppose at **iteration 2** of NR, the Jacobian and mismatch are:

```
J  = [[4, 2],       mm = [2, 1]
      [1, 3]]
```

True classical solution (for reference):
```
4·x + 2·y = 2  →  x = Δδ₂ = 0.4 rad
1·x + 3·y = 1  →  y = ΔV₂ = 0.2 pu
```

Now let's see how **VQLS** finds [0.4, 0.2] using quantum steps.

---

## Step 1: Normal Equations (Symmetrising the Matrix)

VQLS works best with **symmetric positive-definite** matrices.
The code converts the problem:

```
Original:     J · Δx = mm
Transformed:  A · Δx = b

where:  A = Jᵀ · J    (symmetric — same left and right eigenvectors)
        b = Jᵀ · mm   (adjusted right-hand side)
```

**Computing A and b:**
```
Jᵀ = [[4, 1],        Jᵀ·J = [[4,1],[2,3]] · [[4,2],[1,3]]
      [2, 3]]               = [[17, 11],
                               [11, 13]]

A = [[17, 11],
     [11, 13]]

b = Jᵀ · mm = [[4,1],[2,3]] · [2,1] = [4·2+1·1, 2·2+3·1] = [9, 7]
```

Now VQLS must solve: A·Δx = b, i.e., [[17,11],[11,13]]·[x,y] = [9,7]

---

## Step 2: Pauli Decomposition (Representing A on a Quantum Computer)

### What is a Pauli Matrix?

A quantum computer can only directly apply **Pauli gates** to qubits:

```
I = [[1, 0],  [0, 1]]
X = [[0, 1],  [1, 0]]
Y = [[0, -i], [i, 0]]
Z = [[1,  0], [0, -1]]
```

- **I** = Identity (do nothing)
- **X** = Bit-flip (like classical NOT)
- **Y** = Bit-flip + phase
- **Z** = Phase-flip (|0⟩→|0⟩, |1⟩→−|1⟩)

### What is Pauli Decomposition?

**Any matrix can be written as a weighted sum of Pauli matrices.**
This is how VQLS represents the Jacobian matrix on quantum hardware.

For a 2×2 matrix M:
```
M = c_I · I  +  c_X · X  +  c_Y · Y  +  c_Z · Z

where:
  c_I = (M[0,0] + M[1,1]) / 2    ← average of diagonal
  c_Z = (M[0,0] - M[1,1]) / 2    ← half the diagonal difference
  c_X = (M[0,1] + M[1,0]) / 2    ← symmetric off-diagonal
  c_Y = (M[0,1] - M[1,0]) / 2i   ← anti-symmetric part (imaginary)
```

### Applying to Our A = [[17, 11], [11, 13]]:

```
c_I = (17 + 13) / 2 = 15
c_Z = (17 - 13) / 2 = 2
c_X = (11 + 11) / 2 = 11
c_Y = (11 - 11) / 2i = 0   ← zero because A is symmetric (real Jacobian)

Therefore:
A = 15·I  +  11·X  +  2·Z  (no Y term!)

Verify:
  15·[[1,0],[0,1]] + 11·[[0,1],[1,0]] + 2·[[1,0],[0,-1]]
= [[15+2,  11  ],
   [  11,  15-2]]
= [[17, 11],
   [11, 13]] ✓
```

### What This Means in Code:
```python
# SparsePauliOp.from_operator(A) stores this as:
# SparsePauliOp(["I", "X", "Z"], coeffs=[15, 11, 2])
```

> **Why is this useful?**
> On quantum hardware, applying "15·I + 11·X + 2·Z" means running 3 separate
> quantum circuits and combining results — not inverting a matrix directly!

---

## Step 3: Amplitude Encoding (Loading |b⟩ into a Qubit)

### What is Amplitude Encoding?

A single qubit's state is: `|ψ⟩ = α|0⟩ + β|1⟩`

The amplitudes α, β are complex numbers with |α|² + |β|² = 1.

**Idea:** Store a normalised vector `b` as the amplitudes of a quantum state!

### Applying to b = [9, 7]:

```
‖b‖ = √(9² + 7²) = √(81 + 49) = √130 ≈ 11.40

b_norm = [9/11.40, 7/11.40] = [0.7893, 0.6139]

Check: 0.7893² + 0.6139² = 0.623 + 0.377 = 1.0 ✓ (valid quantum state)

|b⟩ = 0.7893·|0⟩ + 0.6139·|1⟩
```

### In Code:
```python
b_circ = amplitude_encode([9, 7])
# Creates a QuantumCircuit that sets qubit to state [0.7893, 0.6139]
# This is done using qc.initialize([0.7893, 0.6139])
```

> **Key limitation:** Quantum state only stores the DIRECTION of b (normalised).
> The magnitude (‖b‖ = 11.40) is lost! We recover it later in Step 6.

---

## Step 4: The Variational Ansatz |ψ(θ)⟩

### What is an Ansatz?

An **ansatz** is a parameterized quantum circuit — a guessable family of quantum states
controlled by tunable angles θ = [θ₀, θ₁, ...].

For our 1-qubit (2×2) system:
```
The simplest ansatz: Ry(θ₀) gate applied to |0⟩

Ry(θ) = [[cos(θ/2),  -sin(θ/2)],
          [sin(θ/2),   cos(θ/2)]]

|ψ(θ₀)⟩ = Ry(θ₀)|0⟩ = [cos(θ₀/2), sin(θ₀/2)]
```

For the 2-qubit case (3×3 system, padded to 4), RealAmplitudes uses:
```
Layer 1: Ry(θ₀)──●──Ry(θ₂)
                  │
         Ry(θ₁)──X──Ry(θ₃)

(● = control, X = CNOT target, creates entanglement between qubits)
```

> **Analogy:** The ansatz is like choosing a form of the solution.
> In classical methods we'd say "assume x = ae^(bt)".
> Here we say "assume |ψ⟩ is reachable by Ry rotations and CNOTs".

---

## Step 5: The VQLS Cost Function C(θ)

This is the **heart of VQLS**. We want to find θ such that |ψ(θ)⟩ ≈ solution of A·x = b.

### Intuition

If |ψ(θ)⟩ IS the solution, then A|ψ(θ)⟩ should be **parallel to |b⟩**.
We measure parallelism using the cosine similarity:

```
C(θ) = 1 − |⟨b | A | ψ(θ)⟩|²
           ─────────────────────
            ‖A|ψ(θ)⟩‖² · ‖b‖²
```

- C(θ) = 0 → A|ψ(θ)⟩ is perfectly parallel to |b⟩ → |ψ(θ)⟩ IS the solution!
- C(θ) = 1 → A|ψ(θ)⟩ is perpendicular to |b⟩ → completely wrong solution

### Example — Evaluating C(θ)

Suppose ansatz gives |ψ(θ)⟩ = [0.898, 0.440] (some trial state).

```
A · ψ = [[17,11],[11,13]] · [0.898, 0.440]
      = [17·0.898 + 11·0.440, 11·0.898 + 13·0.440]
      = [15.27 + 4.84, 9.88 + 5.72]
      = [20.11, 15.60]

|b⟩   = [0.7893, 0.6139]    (normalised b vector)

numerator = |⟨b|A|ψ⟩|² = |0.7893·20.11 + 0.6139·15.60|²
          = |15.87 + 9.58|²
          = |25.45|² = 647.5

denominator = ‖A|ψ⟩‖² = 20.11² + 15.60² = 404.4 + 243.4 = 647.8

C(θ) = 1 − 647.5 / 647.8 = 1 − 0.9995 = 0.0005  Nearly zero!
```

This means |ψ(θ)⟩ = [0.898, 0.440] is very close to the normalised solution.

> Actual normalised solution: Δx_norm = [0.4, 0.2] / ‖[0.4,0.2]‖ = [0.894, 0.447]
> Our trial [0.898, 0.440] is extremely close! ✓

### Why Not Just Measure |⟨b|A|ψ⟩|² Directly?

Because we also need the denominator ‖A|ψ⟩‖² to avoid a trivial false minimum.
Without the denominator, |ψ⟩ = 0 would minimise everything — but that's wrong!

### In Code:
```python
def cost(theta):
    bound = ansatz.assign_parameters(theta)
    sv    = Statevector(bound)      # exact simulation
    psi   = sv.data[:n]            # extract first n amplitudes

    A_psi      = J @ psi                    # apply matrix (classically)
    b_hat      = b / (norm(b) + 1e-30)      # normalised b

    numerator  = abs(dot(b_hat.conj(), A_psi))**2
    denominator= dot(A_psi.conj(), A_psi).real + 1e-30
    return 1.0 - numerator / denominator
```

---

## Step 6: COBYLA Optimiser (Finding the Best θ)



**C**onstrained **O**ptimisation **By** **L**inear **A**pproximations.

A **gradient-free** optimiser: it doesn't need dC/dθ — it probes the cost landscape
with a changing simplex (triangle in 2D, tetrahedron in 3D, etc.).

> **Why no gradient?**
> Computing gradients through quantum circuits is expensive (needs many circuit runs).
> Gradient-free methods like COBYLA are more practical for NISQ hardware.

### What COBYLA Does for Our 1-Qubit Example:

```
θ is just one angle [θ₀] for 1 qubit (Ry gate).

Step 0: θ₀ = random, say θ₀ = 1.2 rad
        |ψ⟩ = [cos(0.6), sin(0.6)] = [0.825, 0.565]
        C(θ₀) ≈ 0.82  ← bad

Step 1: Try θ₀ = 1.8 rad
        |ψ⟩ = [cos(0.9), sin(0.9)] = [0.622, 0.783]
        C ≈ 0.40  ← better

Step 2: Try θ₀ = 1.0 rad
        |ψ⟩ = [cos(0.5), sin(0.5)] = [0.878, 0.479]
        C ≈ 0.04  ← much better

...continuing...

Step 50: θ₀ ≈ 0.99 rad
         |ψ⟩ = [0.894, 0.447] ← normalised [0.4, 0.2] direction ✓
         C ≈ 0.0000  ← converged!
```

```python
theta0 = np.random.uniform(-np.pi, np.pi, n_params)   # random start
res = minimize(cost, theta0, method='COBYLA',
               options={'maxiter': 300, 'rhobeg': 0.5})
# rhobeg = initial step size of the simplex
# maxiter = maximum number of cost function evaluations
```

---

## Step 7: Rescaling — Recovering the Magnitude

### The Problem

After COBYLA converges, we have:
```
psi_final = [0.894, 0.447]   ← unit vector (normalised direction)
```

But the true answer is [0.4, 0.2], which has magnitude ‖Δx‖ = √(0.16+0.04) = 0.447.

**The quantum state only gives direction, not magnitude!**

### The Fix — Least-Squares Projection

If `Δx = scale · psi_final`, then:
```
A · (scale · psi_final) = b
scale · (A · psi_final) = b
```

The best-fit scale (minimising ‖A·scale·ψ − b‖²) is:
```
scale = ⟨A·ψ · b⟩ / ⟨A·ψ · A·ψ⟩
```

**Computing for our example:**
```
A · psi_final = [[17,11],[11,13]] · [0.894, 0.447]
              = [17·0.894+11·0.447, 11·0.894+13·0.447]
              = [15.20+4.92, 9.83+5.81]
              = [20.12, 15.64]

b = [9, 7]

scale = (20.12·9 + 15.64·7) / (20.12² + 15.64²)
      = (181.1 + 109.5)    / (404.8  + 244.6)
      = 290.6 / 649.4
      = 0.4475

Δx_recovered = 0.4475 · [0.894, 0.447]
             = [0.400,  0.200]  ✓ Matches classical solution!
```

### In Code:
```python
A_psi  = J @ psi_final
scale  = np.dot(A_psi, b) / (np.dot(A_psi, A_psi) + 1e-30)
return psi_final * scale          # fully-scaled solution vector
```

---

## 🔁 Complete VQLS Flow (Our Mini Example)

```
NR Problem: J·Δx = mm

                    ↓ Step 1
A = JᵀJ = [[17,11],    b = Jᵀmm = [9, 7]
            [11,13]]

                    ↓ Step 2: Pauli Decompose A
A = 15·I + 11·X + 2·Z (SparsePauliOp)

                    ↓ Step 3: Encode |b⟩
|b⟩ = 0.7893|0⟩ + 0.6139|1⟩         (amplitude_encode)            

                    ↓ Step 4: Choose Ansatz
|ψ(θ)⟩ = Ry(θ₀)|0⟩ (RealAmplitudes circuit)
                       

                    ↓ Step 5: Minimise Cost C(θ)
C(θ) = 1 − |⟨b|A|ψ⟩|² / ‖A|ψ⟩‖²
            (COBYLA, 300 iterations)

                    ↓ Step 6: Rescale
scale = ⟨Aψ·b⟩/‖Aψ‖² = 0.4475

                    ↓ Final
Δx = scale · psi_final = [0.40, 0.20] ✓
```

---

## 📊 Why Each Piece is Necessary

| Component | Without It | With It |
|---|---|---|
| **Normal equations (JᵀJ)** | VQLS may diverge on non-symmetric J | Guaranteed symmetric positive matrix |
| **Pauli decomposition** | Can't apply matrix on quantum hardware | Matrix expressed as gate operations |
| **Amplitude encoding** | Can't load classical vector into qubit | Vector becomes quantum state |
| **Ansatz** | No parameterized state to optimize | Defines the variational search space |
| **Cost function** | No way to measure how right the answer is | Measures alignment of A|ψ⟩ with |b⟩ |
| **COBYLA** | Can't minimize cost without gradient | Gradient-free search on landscape |
| **Rescaling** | Only get direction, lose magnitude | Recovers correct update magnitude |

---

## ⚡ Connection Back to the 3-Bus Problem

At **Iteration 1** of our actual 3-bus problem:
```
J is 3×3  →  pad to 4×4  →  2 qubits needed
A = JᵀJ  →  Pauli decompose into up to 4²=16 terms (II, IX, IY, IZ, XI, ...)
b = Jᵀmm  →  encode into 2-qubit state (4 amplitudes)
Ansatz → 2 qubits, 2 reps → 6 parameters (θ₀ to θ₅)
COBYLA runs up to 300 evaluations
Rescale → recover [Δδ₂, Δδ₃, ΔV₂]
Repeat for iterations 2, 3, ... until ‖mm‖ < 1e-6
```

> The 3-bus system **converges in 3 VQLS iterations** to:
> V₂ = 0.985709 pu, δ₂ = 1.4378°, δ₃ = 3.2449°
> — identical to the classical NR result.
