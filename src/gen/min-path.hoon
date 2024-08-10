::  min-path.hoon
::  Find the cheapest way of traversing a grid of costs from the top left
::  to the bottom right, moving only right and down.
::
|=  grid=(list (list @ud))
^-  @ud
::  Input: 2D (n x n) grid of costs to go through a square.
::  Output: Cheapest path from top left to bottom right.
::
=/  num-rows  (lent grid)
=/  num-columns  (lent (snag 0 grid))
::  Number of rows and number of columns in the grid.
::
=/  destination-costs  (reap num-rows (reap num-columns 0))
::  Initially, prepopulate destination-costs with 0s, the same
::  dimesions as grid. The tactic is to replace the 0 in destination-costs
::  at an index with the actual cheapeast cost of going from the top left
::  to that index.
::
::  We do so in a "diagonal" order of indices, since, if we know the cheapest
::  cost of getting to any squares a distance d from the top-left, we can
::  calculate quickly the cheapest cost of getting to any squares a distance
::  d+1 from the top left.
::
=/  row-index  0
=/  column-index  0
::  row-index and column-index keep track of what square we're actually on.
::
|-
=.  destination-costs
::  Change destination-costs to be...
::
%^  snap  destination-costs  row-index
%^  snap  (snag row-index destination-costs)  column-index
::  the current destination-costs but with (row-index, column-index)
::  replaced by the value computed below:
::
?:  &(=(row-index 0) =(column-index 0))
  (snag column-index (snag row-index grid))
  ::  If we're at (0, 0), the cost is going to be just grid[0][0].
  ::
?:  =(row-index 0)
  %+  add
  (snag column-index (snag row-index grid))
  (snag (sub column-index 1) (snag row-index destination-costs))
  ::  Else, if we're at (0, column-index), the cost is going to be
  ::  grid[0][column-index] + destination_costs[0][column-index - 1]
  ::
?:  =(column-index 0)
  %+  add
  (snag column-index (snag row-index grid))
  (snag column-index (snag (sub row-index 1) destination-costs))
  ::  Else, if we're at (row-index, 0), the cost is going to be
  ::  grid[row-index][0] + destination_costs[row-index - 1][0]
  ::
%+  add
(snag column-index (snag row-index grid))
%+  min
(snag (sub column-index 1) (snag row-index destination-costs))
(snag column-index (snag (sub row-index 1) destination-costs))
::  Else, the cost is going to be grid[row-index][column-index] +
::  min(
::    destination-costs[row-index][column-index - 1],
::    destination-costs[row-index - 1][column-index]
::  )
::
?:  &(=(row-index (sub num-rows 1)) =(column-index (sub num-columns 1)))
  (snag column-index (snag row-index destination-costs))
  ::  If we're in the bottom right, produce the answer.
  ::
?:  |(=(column-index 0) =(row-index (sub num-rows 1)))
  ?:  (lth :(add row-index column-index 1) num-columns)
    %=  $
    row-index  0
    column-index  :(add row-index column-index 1)
    ==
  %=  $
  row-index  (sub :(add row-index column-index 2) num-columns)
  column-index  (sub num-columns 1)
  ==
  ::  Else, if we've reached the end of our diagonal, restart again from
  ::  the top right of the next diagonal. Two cases for whether the new
  ::  diagonal starts on the top row or last column.
  ::
%=  $
row-index  +(row-index)
column-index  (sub column-index 1)
==
::  Else, keep moving along the diagonal.
::
