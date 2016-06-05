require "./MDP.rb"
puts "ZADANIE II"
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
                  gamma: 0.7)



qh = q_learning(Zad, epochs: 10000, epsi: 0.5)
draw_plot(qh[:deltas], "zadII")
Zad.show_utility
Zad.show_policy
puts "------"
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
