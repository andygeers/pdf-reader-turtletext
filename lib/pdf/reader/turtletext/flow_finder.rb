require 'pdf/reader/turtletext/text_area'

class PDF::Reader::Turtletext::FlowFinder < PDF::Reader::Turtletext

  def text_areas(page = 1, tolerance = 0.1)
    # Loop over each TextRun from top left to bottom right
    # and see if it justifies a new area or can be combined with an existing one
    text_areas = []
    content(page).each do |row|
      fuzzed_y_position = row[0]
      row[1].each do |column|
        x_position = column[0]
        text_run = column[1]

        unless combine_text_run_into_areas(text_run, text_areas, tolerance)
          # Create a brand new area for this run
          text_areas << TextArea.new(text_run)
        end
      end
    end
    text_areas
  end

  protected

  def combine_text_run_into_areas(text_run, text_areas, tolerance)
    text_areas.each do |text_area|
      if text_area.integrate_run_if_possible!(text_run, tolerance)
        return true
      end
    end
    return false
  end

  def load_content(page)
    receiver = PDF::Reader::FlowTextReceiver.new
    reader.page(page).walk(receiver)
    receiver.content
  end

end