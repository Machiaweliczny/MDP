require "./MDP.rb"
puts "ZADANIE 1.4"
mc = -1
grid =
 [
   [mc, mc, mc, mc],
   [mc, mc, mc, mc],
   [mc, mc, -2000, mc],
   [mc, mc, nil, 100],
 ]

Zad = GridMDP.new(grid,
                  terminals: [[3, 3]],
                  init: [0, 3],
                  gamma: 0.99,
                  p: {l: 0.2, r: 0.0, d: 0.8})

deltas = value_iteration(Zad)[1]
draw_plot(deltas, "zad4")
puts "deltas.size = #{deltas.size}"

Zad.show_utility
Zad.show_policy

# (z zad3)
# [">", ">", ">", "v"]
# [">", ">", "^", "v"]
# ["^", "<", "^", ">"]
# ["^", "^", "X", "X"]
#          VS
# [">", ">", "v", "v"]
# [">", ">", ">", "v"]
# [">", "^", ">", "v"]
# ["^", "^", "X", "X"]
# Nie mozna skrecic w prawo wiec sobie obchodzi stan ujemny na luzie
