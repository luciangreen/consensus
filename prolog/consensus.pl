% consensus: run the same program on every backend you have (Prolog, Detlog, C, an ANN, a
% quantum circuit) and compare. Any disagreement is shrunk to a smallest input that still
% shows it (delta debugging), ready to become a bug report and a test.
% A backend is a Name-Goal pair; call(Goal, Input, Output).
%?- verdict([prolog-sum_list, detlog-sum_acc], [1,2,3], V).           % V = agree(6)
%?- verdict([prolog-sum_list, buggy-sum_bug], [1,3,5,2], V).          % V = disagree([prolog-11, buggy-12])
%?- shrink([prolog-sum_list, buggy-sum_bug], [7,1,3,9,5,2], Small).  % Small = [3,5]
:- module(consensus, [verdict/3, disagrees/2, shrink/3, report/3, sum_acc/2, sum_bug/2, max_bug/2, sort_dedupe/2]).
:- use_module(library(lists)).
:- use_module(library(apply)).

% verdict(+Backends, +Input, -Verdict): agree(Output) or disagree([Name-Output, ...]).
verdict(Bs, In, V) :- maplist([N-G, N-O]>>( catch(call(G, In, O0), E, O0 = error(E)) -> O = O0 ; O = fails ), Bs, Outs),
    pairs_values(Outs, Vs), sort(Vs, U),
    ( U = [One] -> V = agree(One) ; V = disagree(Outs) ).

disagrees(Bs, In) :- verdict(Bs, In, disagree(_)).

% shrink(+Backends, +Input, -Smallest): a sublist of Input (of a list input) that still disagrees,
% from which no single element can be removed (1-minimal). Input must disagree.
shrink(Bs, In, Small) :- disagrees(Bs, In), shrink_(Bs, In, S), Small = S.
shrink_(Bs, In, S) :- ( select(_, In, Smaller), disagrees(Bs, Smaller) -> shrink_(Bs, Smaller, S) ; S = In ).

% report(+Backends, +Input, -Report): the verdict, and for a disagreement the shrunk input and its outputs.
report(Bs, In, R) :- verdict(Bs, In, V),
    ( V = agree(O) -> R = agree(O)
    ; shrink(Bs, In, S), verdict(Bs, S, disagree(Outs)), R = bug(input(S), outputs(Outs)) ).

% Backends for the examples: correct ones, and ones with planted bugs.
sum_acc(L, S) :- foldl([X, A0, A]>>(A is A0 + X), L, 0, S).
sum_bug(L, S) :- sum_list(L, S0), ( memberchk(3, L), memberchk(5, L) -> S is S0 + 1 ; S = S0 ).
max_bug(L, M) :- ( L = [] -> M = none ; L = [_] -> L = [M] ; L = [_|T], max_list(T, M) ).   % forgets the first element
sort_dedupe(L, S) :- sort(L, S).
