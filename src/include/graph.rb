require 'rubygems'
require 'gnuplot'

def graph_from_intervals(filename, intervals, last_event)
  g = Gruff::Line.new("1000x400")
  g.title = 'Intervals'
  g.hide_legend = true

  intervals.each { |pair|
    x_data = [pair[0][0], pair[1][0]]
    y_data = [pair[0][1], pair[1][1]]
    g.dataxy('User', x_data, y_data, "#6633FF")
  }

  (0..last_event).step(500) { |i|
    g.labels[i] = i.to_s
  }

  g.write(filename)
end

def gnuplot_from_intervals(filename, intervals)

  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.title  "Intervals"
      plot.xlabel "Time"
      plot.ylabel "Note"

      # Plot points
      x_data = Array.new
      y_data = Array.new
      intervals.each { |pair|
        x_data.push(pair[0][0])
        y_data.push(pair[0][1])
      }
      plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
        ds.with = "points pt 7 ps 1 lc rgb 'black'"
        ds.notitle
      end

      # Plot lines
      intervals.each { |pair|
        x_data = [pair[0][0], pair[1][0]]
        y_data = [pair[0][1], pair[1][1]]
        plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
          ds.with = "lines lc rgb 'black'"
          ds.notitle
        end
      }

      plot.terminal "gif"
      plot.output filename+".gif"
    end
  end
end

###
# No return
###
def compare_graph_from_intervals(filename, target, source, last_event)
  g = Gruff::Line.new("1000x400")
  g.title = 'Target vs Source'
  g.hide_legend = true

  target.each { |pair|
    x_data = [pair[0][0], pair[1][0]]
    y_data = [pair[0][1], pair[1][1]]
    g.dataxy('Target', x_data, y_data, "#6633FF")
  }

  source.each { |pair|
    x_data = [pair[0][0], pair[1][0]]
    y_data = [pair[0][1], pair[1][1]]
    g.dataxy('Source', x_data, y_data, "#FF3366")
  }

  (0..last_event).step(500) { |i|
    g.labels[i] = i.to_s
  }

  g.write(filename)
end

def compare_gnuplot_from_intervals(filename, target, source)

  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.title  "Intervals"
      plot.xlabel "Time"
      plot.ylabel "Note"

      # Plot points
      x_data = Array.new
      y_data = Array.new
      target.each { |pair|
        x_data.push(pair[0][0])
        y_data.push(pair[0][1])
      }
      plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
        ds.with = "points pt 7 ps 1 lc rgb 'red'"
        ds.title = "Target"
      end

      # Plot lines
      target.each { |pair|
        x_data = [pair[0][0], pair[1][0]]
        y_data = [pair[0][1], pair[1][1]]
        plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
          ds.with = "lines lc rgb 'red'"
          ds.notitle
        end
      }

      # Plot points
      x_data = Array.new
      y_data = Array.new
      source.each { |pair|
        x_data.push(pair[0][0])
        y_data.push(pair[0][1])
      }
      plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
        ds.with = "points pt 7 ps 1 lc rgb 'blue'"
        ds.title = "Source"
      end

      # Plot lines
      source.each { |pair|
        x_data = [pair[0][0], pair[1][0]]
        y_data = [pair[0][1], pair[1][1]]
        plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
          ds.with = "lines lc rgb 'blue'"
          ds.notitle
        end
      }

      plot.terminal "gif"
      plot.output filename+".gif"
    end
  end
end

def compare_graph_from_intervals_w_dtw(filename, target, source, dtw_path, last_event)
  g = Gruff::Line.new("1000x400")
  g.title = 'Target vs Source w/ DTW'
  g.hide_legend = true

  dtw_path.each { |target_index, matches| 
    matches.each { |match_index|
      x_data = [target[target_index][0][0], source[match_index][0][0]]
      y_data = [target[target_index][0][1], source[match_index][0][1]]
      g.dataxy('Match', x_data, y_data, "#FFFF00")
    }
  }

  target.each { |pair|
    x_data = [pair[0][0], pair[1][0]]
    y_data = [pair[0][1], pair[1][1]]
    g.dataxy('Target', x_data, y_data, "#6633FF")
  }

  source.each { |pair|
    x_data = [pair[0][0], pair[1][0]]
    y_data = [pair[0][1], pair[1][1]]
    g.dataxy('Source', x_data, y_data, "#FF3366")
  }

  (0..last_event).step(500) { |i|
    g.labels[i] = i.to_s
  }

  g.write(filename)
end

def compare_gnuplot_from_intervals_w_dtw(filename, target, source, dtw_path)

  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.title  "Intervals"
      plot.xlabel "Time"
      plot.ylabel "Note"

      # DTW lines
      dtw_path.each { |target_index, matches| 
        matches.each { |match_index|
          x_data = [target[target_index][0][0], source[match_index][0][0]]
          y_data = [target[target_index][0][1], source[match_index][0][1]]
          plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
            ds.with = "lines lc rgb 'grey'"
            ds.notitle
          end
        }
      }

      # Target
      # Plot points
      x_data = Array.new
      y_data = Array.new
      target.each { |pair|
        x_data.push(pair[0][0])
        y_data.push(pair[0][1])
      }
      plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
        ds.with = "points pt 7 ps 1 lc rgb 'red'"
        ds.title = "Target"
      end

      # Plot lines
      target.each { |pair|
        x_data = [pair[0][0], pair[1][0]]
        y_data = [pair[0][1], pair[1][1]]
        plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
          ds.with = "lines lc rgb 'red'"
          ds.notitle
        end
      }

      # Source
      # Plot points
      x_data = Array.new
      y_data = Array.new
      source.each { |pair|
        x_data.push(pair[0][0])
        y_data.push(pair[0][1])
      }
      plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
        ds.with = "points pt 7 ps 1 lc rgb 'blue'"
        ds.title = "Source"
      end

      # Plot lines
      source.each { |pair|
        x_data = [pair[0][0], pair[1][0]]
        y_data = [pair[0][1], pair[1][1]]
        plot.data << Gnuplot::DataSet.new( [x_data, y_data] ) do |ds|
          ds.with = "lines lc rgb 'blue'"
          ds.notitle
        end
      }

      plot.terminal "gif"
      plot.output filename+".gif"
    end
  end
end
