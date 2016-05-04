require 'pp'

reads = ARGF.readlines.map { |e| e.chomp.split(//) }
@initial_map = Array.new(reads.size).map { Array.new(reads[0].size, nil) }
reads.each_with_index do |_v, y|
  _v.each_with_index do |v, x|
    next if @initial_map[y][x]
    case (v)
    when '-' then @initial_map[y][x] = :-
    when 'a' then @initial_map[y][x] = :e
    when 'A' then @initial_map[y][x] = :E
    when 'c'
      @initial_map[y][x] = :i
      @initial_map[y][x+1] = :g
      @initial_map[y+1][x] = :c
      @initial_map[y+1][x+1] = :a
    when 'C'
      @initial_map[y][x] = :I
      @initial_map[y][x+1] = :G
      @initial_map[y+1][x] = :C
      @initial_map[y+1][x+1] = :A
    when 'v'
      @initial_map[y][x] = :h
      @initial_map[y+1][x] = :b
    when 'V'
      @initial_map[y][x] = :H
      @initial_map[y+1][x] = :B
    when 'h'
      @initial_map[y][x] = :f
      @initial_map[y][x+1] = :d
    when 'H'
      @initial_map[y][x] = :F
      @initial_map[y][x+1] = :D
    end
  end
end
pp @initial_map
# @initial_map = ARGF.readlines.map { |e| e.chomp.split(//).map(&:to_sym) }
Y = @initial_map.size
X = @initial_map[0].size

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

@moves = {}
def get_moves(x, y, memo, first = true)
  return @moves[[x, y]] if @moves.key?([x, y]) && first
  r = []
  memo[[x, y]] = true
  MOVES.each do |mv|
    nx = x + mv[0]
    ny = y + mv[1]
    next unless (0...X).include?(nx) && (0...Y).include?(ny)
    if @initial_map[ny][nx] == :-
      unless memo.key?([nx, ny])
        r += get_moves(nx, ny, memo, false)
      end
    else
      unless memo.key?([nx, ny])
        memo[[nx, ny]] = true
        r << [nx, ny]
      end
    end
  end
  @moves[[x, y]] = r if first
  r
end

def b_w(value)
  (value.upcase == value) ? '#' : ' '
end

def start
  @initial_map.each_with_index do |_m, y|
    _m.each_with_index do |v, x|
      @show[y][x] = b_w(v) if v != :-
    end
  end
end

def extend(moves)
  r = []
  moves.each do |mv|
    r << mv
    case (@initial_map[mv[1]][mv[0]].to_s.downcase)
    when 'a'
      r << [mv[0] - 1, mv[1]] << [mv[0], mv[1] - 1] << [mv[0] - 1, mv[1] - 1]
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
      xb, yb = get_synmet(bl[0], bl[1], mv[0] - bl[0], mv[1] - bl[1], @initial_map[mv[1]][mv[0]])
      next unless (0...X).include?(xb) && (0...Y).include?(yb)
      next if @show[yb][xb] != "-"
      next unless extend(get_moves(xb, yb, {})).include?(mv)
      @show[yb][xb] = @show[bl[1]][bl[0]] = @show[mv[1]][mv[0]]
      search(blanks, idx)
      @show[yb][xb] = @show[bl[1]][bl[0]] = "-"
    end
  end
end

@show = Array.new(Y).map{ Array.new(X, '-') }

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
