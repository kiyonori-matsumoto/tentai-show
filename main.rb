require 'pp'

MAP = ARGF.readlines.map { |e| e.chomp.split(//).map(&:to_sym) }
pp MAP
# MAP =
# [
#   [:h, :F, :D, :-, :-, :F, :D, :I, :G, :e],
#   [:b, :-, :E, :-, :E, :F, :D, :C, :A, :-],
#   [:-, :h, :f, :d, :-, :-, :e, :-, :-, :e],
#   [:h, :b, :-, :-, :H, :-, :-, :E, :e, :-],
#   [:b, :f, :d, :e, :B, :E, :F, :D, :-, :-],
#   [:h, :I, :G, :-, :-, :-, :f, :d, :h, :-],
#   [:b, :C, :A, :h, :-, :-, :h, :-, :b, :h],
#   [:e, :H, :-, :b, :-, :H, :b, :f, :d, :b],
#   [:-, :B, :-, :H, :-, :B, :-, :H, :I, :G],
#   [:F, :D, :-, :B, :-, :-, :-, :B, :C, :A],
# ]
# [
#   [:e, :h, :-, :e, :H, :F, :D, :-, :e, :-],
#   [:-, :b, :I, :G, :B, :e, :-, :E, :f, :d],
#   [:e, :-, :C, :A, :-, :-, :f, :d, :H, :-],
#   [:-, :E, :-, :H, :-, :E, :E, :-, :B, :e],
#   [:E, :-, :-, :B, :E, :-, :-, :h, :-, :-],
#   [:h, :e, :-, :-, :h, :e, :-, :b, :E, :e],
#   [:b, :E, :e, :H, :b, :E, :f, :d, :-, :-],
#   [:E, :-, :-, :B, :f, :d, :E, :-, :H, :e],
#   [:i, :g, :-, :e, :-, :h, :-, :-, :B, :-],
#   [:c, :a, :e, :-, :-, :b, :F, :D, :F, :D]
# ]

MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1]]
MOVE = {
  a: [-1, -1], b: [0, -1], c: [1, -1], d: [-1, 0], e: [0, 0], f: [1, 0],
  g: [-1,  1], h: [0,  1], i: [1, 1]
}

def get_synmet(x, y, dx, dy, val)
  # p [x, y, dx, dy, val]
  diff = MOVE[val.to_s.downcase.to_sym]
  [x + (dx * 2) + diff[0], y + (dy * 2) + diff[1]]
end

def get_moves(x, y, memo)
  r = []
  memo[[x, y]] = true
  MOVES.each do |mv|
    nx = x + mv[0]
    ny = y + mv[1]
    next unless (0...MAP.size).include?(nx) && (0...MAP.size).include?(ny)
    if MAP[ny][nx] == :-
      unless memo.key?([nx, ny])
        r += get_moves(nx, ny, memo)
      end
    else
      unless memo.key?([nx, ny])
        memo[[nx, ny]] = true
        r << [nx, ny]
      end
    end
  end
  r
end

def b_w(value)
  (value.upcase == value) ? '#' : ' '
end

def start
  MAP.each_with_index do |_m, y|
    _m.each_with_index do |v, x|
      @show[y][x] = b_w(v) if v != :-
    end
  end
end

def extend(moves)
  r = []
  moves.each do |mv|
    r << mv
    case (MAP[mv[1]][mv[0]].to_s.downcase)
    when 'a'
      r << [mv[0] - 1, mv[1]] << [mv[0], mv[1] - 1] <<
           [mv[0] - 1, mv[1] - 1]
    when 'b'
      r << [mv[0], mv[1] - 1]
    when 'c'
      r << [mv[0] + 1, mv[1]] << [mv[0], mv[1] - 1] << [mv[0] + 1, mv[1] - 1]
    when 'd'
      r << [mv[0] - 1, mv[1]]
    when 'f'
      r << [mv[0] + 1, mv[1]]
    when 'g'
      r << [mv[0] - 1, mv[1]] << [mv[0], mv[1] + 1] << [mv[0] - 1, mv[1] + 1]
    when 'h'
      r << [mv[0], mv[1] + 1]
    when 'i'
      r << [mv[0] + 1, mv[1]] << [mv[0], mv[1] + 1] << [mv[0] + 1, mv[1] + 1]
    end
  end
  r
end

def search(blanks, idx)
  if blanks.size == idx
    @show.each do |y|
      y.each do |x|
        print x
      end
      print "\n"
    end
    exit
  end
  bl = blanks[idx]
  if @show[bl[1]][bl[0]] != "-"
    search(blanks, idx + 1)
  else
    # pp idx, @show
    a = get_moves(*bl, {})
    a.each do |mv|
      xb, yb = get_synmet(bl[0], bl[1], mv[0] - bl[0], mv[1] - bl[1], MAP[mv[1]][mv[0]])
      # p [bl, mv, [xb, yb]]
      next unless (0...MAP.size).include?(xb) && (0...MAP.size).include?(yb)
      next if @show[yb][xb] != "-"
      next unless extend(get_moves(xb, yb, {})).include?(mv)
      @show[yb][xb] = @show[bl[1]][bl[0]] = @show[mv[1]][mv[0]]
      search(blanks, idx)
      @show[yb][xb] = @show[bl[1]][bl[0]] = "-"
    end
  end
end

@show = Array.new(MAP.size).map{ Array.new(MAP[0].size, '-') }

start

blanks = []
@show.each_with_index do |v, y|
  v.each_with_index do |w, x|
    if w == '-'
      blanks << [x, y]
    end
  end
end

search(blanks, 0)
