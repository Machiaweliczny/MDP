require "./MDP.rb"
puts "ZADANIE 1.5"
mc = -1
grid =
 [
   [mc, mc, mc, mc],
   [mc, mc, mc, mc],
   [mc, mc, -20, mc],
   [mc, mc, nil, 100],
 ]

Zad = GridMDP.new(grid,
                  terminals: [[3, 3]],
                  init: [0, 3],
                  gamma: 0.6)

deltas = value_iteration(Zad)[1]
draw_plot(deltas, "zad5")
puts "deltas.size = #{deltas.size}"

Zad.show_utility
Zad.show_policy

# [">", ">", ">", "v"]
# [">", ">", ">", "v"]
# [">", ">", ">", "v"]
# ["^", "^", "X", "X"]
# Idzie "byle do celu"
