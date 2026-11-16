# consensus

run the same program on every backend you have (Prolog, Detlog, C, an ANN, a quantum circuit) and compare. Any disagreement is shrunk to a smallest input that still shows it (delta debugging), ready to become a bug report and a test. A backend is a Name-Goal pair; call(Goal, Input, Output).

## Use

```prolog
?- use_module(prolog/consensus).
?- verdict([prolog-sum_list, detlog-sum_acc], [1,2,3], V).           % V = agree(6)
?- verdict([prolog-sum_list, buggy-sum_bug], [1,3,5,2], V).          % V = disagree([prolog-11, buggy-12])
?- shrink([prolog-sum_list, buggy-sum_bug], [7,1,3,9,5,2], Small).  % Small = [3,5]
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every list of length 0..5 over 1..5, and backend sets with and without planted bugs.

1. agree exactly when every backend gives the same output.
2. Backends that compute the same function always agree.
3. The shrunk input still disagrees, comes from the original, and is 1-minimal.
4. The planted sum bug always shrinks to [3,5] or [5,3]: the smallest input that shows it.
5. verdict is steadfast.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
