% Theorems about consensus, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module('../prolog/consensus').
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).

% Domain: every list of length 0..5 over 1..5, and backend sets with and without planted bugs.
list(L) :- between(0, 5, N), length(L, N), maplist([X]>>between(1, 5, X), L).
backends([prolog-sum_list, detlog-sum_acc]).
backends([prolog-sum_list, buggy-sum_bug]).
backends([prolog-max_list, buggy-max_bug]).
backends([a-msort, b-sort_dedupe]).

% 1. agree exactly when every backend gives the same output.
theorem(agree_iff_all_equal) :-
    forall(( backends(Bs), list(L) ), ( verdict(Bs, L, V), findall(O, ( member(_-G, Bs), ( catch(call(G, L, O0), _, fail) -> O = O0 ; O = fails ) ), Os), sort(Os, U),
                                        iff(V = agree(_), U = [_]) )).

% 2. Backends that compute the same function always agree.
theorem(equal_backends_agree) :- forall(list(L), verdict([prolog-sum_list, detlog-sum_acc], L, agree(_))).

% 3. The shrunk input still disagrees, comes from the original, and is 1-minimal.
theorem(shrunk_input_is_minimal) :-
    forall(( backends(Bs), list(L), disagrees(Bs, L) ),
           ( shrink(Bs, L, S), disagrees(Bs, S), subseq(S, L), forall(select(_, S, T), \+ disagrees(Bs, T)) )).
subseq([], _).
subseq([X|Xs], [X|Ys]) :- !, subseq(Xs, Ys).
subseq(Xs, [_|Ys]) :- subseq(Xs, Ys).

% 4. The planted sum bug always shrinks to [3,5] or [5,3]: the smallest input that shows it.
theorem(sum_bug_shrinks_to_its_cause) :-
    forall(( list(L), disagrees([p-sum_list, b-sum_bug], L) ), ( shrink([p-sum_list, b-sum_bug], L, S), msort(S, [3, 5]) )).

% 5. verdict is steadfast.
theorem(verdict_is_steadfast) :-
    forall(( backends(Bs), list(L), member(G, [agree(6), agree([]), agree(none)]) ), iff(verdict(Bs, L, G), ( verdict(Bs, L, V), V == G ))).
