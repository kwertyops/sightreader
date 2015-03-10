###
#
###
def get_dtw_path(target, source)
  matrix = fill_dtw_matrix(target, source)

  # Find path of least cost
  path = Hash.new
  (0..target.length-1).each do |i|
    path[i] = Array.new
  end

  i = target.length-1
  j = source.length-1

  while(matrix[[i, j]] != Float::INFINITY)
    path[i].push(j)

    left = matrix[[i-1,j]]
    down = matrix[[i, j-1]] 
    downleft = matrix[[i-1, j-1]]
    min_prev = [left, down, downleft].min

    if min_prev == left
      i = i-1
    elsif min_prev == down
      j = j-1
    else
      i = i-1
      j = j-1
    end
  end

  return path
end

def fill_dtw_matrix(target, source)
  matrix = Hash.new

  # Create edge of infinities
  (-1..target.length).each do |i|
    matrix[[i, -1]] = Float::INFINITY
  end
  (-1..source.length).each do |i|
    matrix[[-1, i]] = Float::INFINITY
  end

  # Fill DTW Matrix
  (0..target.length-1).each do |i|
    (0..source.length-1).each do |j|
      target_noteon = target[i][0]
      source_noteon = source[j][0]
      target_x = target_noteon[0]
      target_y = target_noteon[1]
      source_x = source_noteon[0]
      source_y = source_noteon[1]

      distance = Math.hypot(target_x-source_x, target_y-source_y)

      # Assume 0, 0 is in the bottom left corner
      left = matrix[[i-1,j]]
      down = matrix[[i, j-1]] 
      downleft = matrix[[i-1, j-1]]
     
      # Find minimum surrounding cost
      min_prev = 0
      unless left == Float::INFINITY && down == Float::INFINITY && downleft == Float::INFINITY
        min_prev = [left, down, downleft].min
      end

      matrix[[i, j]] = distance + min_prev
    end
  end

  return matrix
end

###
#
###
def print_dtw_matrix(matrix, target, source)
  (0..target.length-1).each do |i|
    print "target" + i.to_s + ", "
    (0..source.length-1).each do |j|
      print matrix[[i, j]].round(2).to_s + ", "
    end
    print "\n"
  end
end