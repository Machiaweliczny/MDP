require "./MDP.rb"

puts "ZADANIE 1.1"
mc = -0.04
grid =
 [
   [mc, mc, mc, +1],
   [mc, nil , mc, -1],
   [mc, mc, mc, mc]
 ]

Zad = GridMDP.new(grid,
                  terminals: [[3, 0], [3, 1]],
                  init: [0, 2],
                  gamma: 1.0)


deltas = value_iteration(Zad)[1]
puts deltas.inspect
draw_plot(deltas, "zad1")
puts "deltas.size = #{deltas.size}"

Zad.show_utility
Zad.show_policy
