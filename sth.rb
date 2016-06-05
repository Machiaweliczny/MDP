require "./MDP.rb"

puts "Value iteration"
mc = -1
grid =
 [
   [100, mc, mc, mc, 100],
   [mc, -20, -5, mc, mc],
   [mc, -10, mc, -10, mc],
   [mc, mc, -5, -20, mc],
   [100, mc, mc, mc, 100],
 ]

Zad = GridMDP.new(grid,
                  terminals: [[0, 0], [0, 4], [4, 0], [4, 4]],
                  init: [2, 2],
                  gamma: 0.99)

deltas = value_iteration(Zad)
draw_plot(deltas, "sth")
puts "deltas.size = #{deltas.size}"

Zad.show_utility
Zad.show_policy

#########

puts "Q-learning"

qh = q_learning(Zad, epochs: 10_000, epsi: 0.05)
q = qh[:_Q]
puts
qgroup = q.map { |k, v| { [k[0], GridMDP::MAP_ACTIONS[k[1]]] => v.round(2) } }
  .reduce(:merge)
  .group_by { |x| x.first.first }.map { |k, v| { k => v.map { |v| [v.first.last, v.last] } } }
puts qgroup
u = Zad.states.map { |s| { s => Zad.actions(s).map { |a| q[[s, a]] }.max } }.reduce(:merge)
Zad.send(:print_it, u, ->(x) { x.round(2) if x })
qv = (0..4).to_a.product((0..4).to_a).map { |s| { s => pi_q(Zad, s, q) } }
pi = (0..4).to_a.product((0..4).to_a).map { |s| { s => GridMDP::MAP_ACTIONS[pi_q(Zad, s, q)] } }.reduce({}, :merge)
Zad.send(:print_it, pi)
