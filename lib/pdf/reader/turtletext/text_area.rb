class PDF::Reader::Turtletext::TextArea

  def initialize(text_run)
    @x = text_run.x
    @y = text_run.y
    @width = text_run.width
    @height = 0
    @text_runs = {}
    record_run(text_run)
  end

  def integrate_run_if_possible!(text_run, tolerance = 0.1)
    if text_run.x + text_run.width < @x * (1 - tolerance)
      #puts "#{text_run.text} < #{self.content}.x1"
      return false
    elsif text_run.x > (@x + @width) * (1 + tolerance)
      #puts "#{text_run.text} > #{self.content}.x2"
      return false
    elsif text_run.y < @y * (1 - tolerance)
      #puts "#{text_run.text} < #{self.content}.y1"
      return false
    elsif text_run.y > (@y + @height) * (1 + tolerance)
      #puts "#{text_run.text} > #{self.content}.y2"
      return false
    else
      record_run(text_run)

      min_x = [text_run.x, @x].min
      max_x = [text_run.x + text_run.width, @x + @width].max
      min_y = [text_run.y, @y].min
      max_y = [text_run.y, @y + @height].max
      @x = min_x
      @y = min_y
      @width = max_x - min_x
      @height = max_y - min_y
      return true
    end
  end

  def content
    text = []
    @text_runs.each do |y, runs|
      runs.each do |x, run|
        text << run
      end
    end
    text.join(" ")
  end

  protected

  def record_run(text_run)
    @text_runs[text_run.y] ||= {}
    @text_runs[text_run.y][text_run.x] ||= ""
    @text_runs[text_run.y][text_run.x] << text_run.text
  end
end