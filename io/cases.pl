:- module(cases, [title/1, case/3]).
:- use_module('../prolog/consensus').
:- use_module(engine).
title('consensus').
list_g(L) :- rnd_int(0, 8, N), length(L, N), maplist([X]>>rnd_int(1, 9, X), L).
bs_g(Bs) :- rnd_pick([[prolog-sum_list, detlog-sum_acc], [prolog-sum_list, buggy-sum_bug], [prolog-max_list, buggy-max_bug],
                      [a-msort, b-sort_dedupe], [prolog-sum_list, detlog-sum_acc, buggy-sum_bug]], Bs).
case(verdict, [Bs, L], verdict) :- bs_g(Bs), list_g(L).
case(report, [Bs, L], report) :- bs_g(Bs), list_g(L).
case(shrink, [Bs, L], shrink_or_agree) :- bs_g(Bs), list_g(L).
shrink_or_agree(Bs, L, S) :- ( disagrees(Bs, L) -> shrink(Bs, L, S) ; S = agree ).
