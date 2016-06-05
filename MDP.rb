# Copyright Damian Trojnar
# Based on reference implementation in python from http://aima.cs.berkeley.edu/python/mdp.html
# Requires ruby 2.0+

require "ostruct"
require "open3"

def argmax(a, &f)
  m = a.map{ |x| f.call(x) }
  a[m.index(m.max)]
end


class MDP < OpenStruct
  def initialize(init:, actList:, terminals:, gamma: 0.9)
    super(init: init, actList: actList, terminals: terminals, gamma: gamma, states: [], reward: {}, utility: {}, pi: {})
  end

  def R(s)
    self.reward[s]
  end

  def T(s)
    raise StandardError("Not implemented yet")
  end

  def actions(s)
    if self.terminals.include?(s)
      return [nil]
    else
      return self.actList
    end
  end
end

class GridMDP < MDP
  LEFT = [-1, 0].freeze
  TOP = [0, -1].freeze
  RIGHT = [1, 0].freeze
  BOTTOM = [0, 1].freeze
  ORIENTATIONS = [LEFT, TOP, RIGHT, BOTTOM]
  MAP_ACTIONS = {LEFT => "<", RIGHT => ">", TOP => "^", BOTTOM => "v", nil => "X" }

  def initialize(grid, terminals:, init: [0,0], gamma: 1.0, p: {l: 0.1, r: 0.1, d: 0.8 })
    super(init: init, actList: ORIENTATIONS, terminals: terminals, gamma: gamma)
    @p = p
    @rows = grid.length
    @cols = grid[0].length
    @cols.times do |x|
      @rows.times do |y|
        self.reward[[x,y]] = grid[y][x]
        self.states << [x,y] unless grid[y][x].nil?
      end
    end
  end

  def T(state, action)
    if action == nil then
      [[0.0, state]]
    else
      [
        [@p[:d], self.go(state, action)],
        [@p[:r], self.go(state, turn_right(action))],
        [@p[:l], self.go(state, turn_left(action))]
     ]
   end
  end

  def go(state, direction)
    state1 = vector_add(state, direction)
    self.states.include?(state1) ? state1 : state
  end

  def go_random(state, action)
    los = rand
    sum = 0
    direction = T(state, action).each do |p, s1|
      sum += p
      return s1 if los <= sum
    end
  end

  def show_policy
    self.states.map do |s|
      self.pi[s] = argmax(self.actions(s)) do |a| expected_utility(s, a) end
    end
    print_it(self.pi, lambda do |a| MAP_ACTIONS[a] end)
    self.pi
  end

  def show_utility
    print_it(self.utility, lambda do |u| u.round(4) if u end)
    self.utility
  end

  private

  def print_it(r, f = lambda { |x| x })
    puts("")
    @rows.times.map do |y|
      (@cols.times.map do |x| f.call(r[[x,y]]) end).inspect
    end.map{ |line| puts line }
  end

  def expected_utility(s, a)
    T(s, a).map do |p, s1| p * self.utility[s1] end.reduce(0, :+)
  end

  def turn_right(action)
    ORIENTATIONS[(ORIENTATIONS.index(action) + 1) % 4]
  end

  def turn_left(action)
    ORIENTATIONS[(ORIENTATIONS.index(action) + 3) % 4]
  end

  def vector_add(s, s1)
    [s[0]+s1[0], s[1]+s1[1]]
  end
end

def value_iteration(mdp, epsilon=0.0001, calc_diff=true)
  result = value_iteration(mdp, epsilon, false)[0] if calc_diff
  u1 = mdp.states.reduce({}) do |h, s|
    h.merge(s => 0.0)
  end
  deltas = []
  finish = mdp.gamma == 1.0 ? epsilon : epsilon * (1.0 - mdp.gamma) / mdp.gamma
  10000.times do |i|
    u = u1.clone
    delta = 0
    mdp.states.each do |s|
      best_action = (mdp.actions(s).map do |a|
        (mdp.T(s, a).map { |p, s1| p * u[s1] }).reduce(0.0, :+)
      end).max
      u1[s] = mdp.R(s) + best_action * mdp.gamma
      delta = [delta, (u1[s] - u[s]).abs].max
    end
    if calc_diff
      max_diff = mdp.states.map do |s| (u1[s] - result[s]).abs end.max
      deltas << [i, max_diff]
    end
    if delta < finish then
      mdp.utility = u1
      return [u1, deltas]
    end
  end # loop
end

# For each s, a, initialize table entry Q(s,a) <- 0
# Observe current state s
# Do forever:
#     Select an action a and execute it
#     Receive immediate reward r
#     Observe the new state s'
#     Update the table entry for Q(s, a) as follows:
#         Q (s, a) = Q(s, a) + α [ r + γ max Q (s', a') - Q (s, a)]
#     s <- s'
# require "pry"
def q_learning(mdp, epsi: 0.2, epochs: 10000)
  q ||= value_iteration(mdp)[0]
  puts "epsi = #{epsi}, epochs = #{epochs}"
  _Q = {}
  _N = {}
  deltas = []
  state_actions = mdp.states.map{ |s| mdp.actions(s).map{ |a| [s, a] } }.flatten(1)
  state_actions.each do |s,a| _Q[[s,a]] = 0; _N[[s,a]] = 0 end
  # mdp.terminals.each do |s| _Q[[s,nil]] = mdp.R(s) end
  s = (mdp.states - mdp.terminals).sample
  1000000000.times do |i|
    print "." if i % 10000 == 0
    if (mdp.terminals.include?(s))
      _Q[[s, nil]] = mdp.R(s)
      s = (mdp.states - mdp.terminals).sample
      epochs -= 1
      u = mdp.states.map do |s| { s => mdp.actions(s).map { |a| _Q[[s,a]] }.max } end.reduce(:merge)
      # binding.pry
      delta = u.map do |s,v| (mdp.utility[s] - u[s]).abs end.max
      deltas << delta
      return {_Q: _Q, deltas: deltas} if epochs == 0
    end
    a = argmax(mdp.actions(s)){ |a| _Q[[s, a]] }
    a = mdp.actions(s).sample if rand < epsi
    s1 = mdp.go_random(s, a)
    _N[[s,a]] += 1.0
    maxs1a1 = mdp.actions(s1).map do |a1| _Q[[s1, a1]] end.max
    qsa = _Q[[s,a]]
    _Q[[s,a]] = qsa + (1.0/_N[[s,a]]) * (mdp.R(s) + mdp.gamma * maxs1a1 - qsa)
    s = s1
  end
end

def pi_q(mdp, s, _Q)
  argmax(mdp.actions(s)){ |a| _Q[[s,a]] }
end

def draw_plot(data, name)
  gnuplot_commands = <<END_STR
    set terminal png
    set title "#{name}"
    set output "#{name}.png"
    set xrange [0:#{data.size}]
    plot "-" with linespoints title "max(abs(U_i[s] - U[s]))"
END_STR
  data.each do |x, y|
    gnuplot_commands << x.to_s + " " + y.to_s + "\n"
  end
  gnuplot_commands << "e\n"

  image, s = Open3.capture2(
    "gnuplot",
    :stdin_data=>gnuplot_commands, :binmode=>true)
end
