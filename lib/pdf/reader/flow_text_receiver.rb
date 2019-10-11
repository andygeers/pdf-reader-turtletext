require 'pdf/reader/text_run'

# Receiver to access positional (x,y) text content from a PDF
#
# Typical usage:
#
#   reader = PDF::Reader.new(filename)
#   receiver = PDF::Reader::PositionalTextReceiver.new
#   reader.page(page).walk(receiver)
#   receiver.content
#
class PDF::Reader::FlowTextReceiver < PDF::Reader::PageTextReceiver

  # record text that is drawn on the page
  def show_text(string) # Tj
    raise PDF::Reader::MalformedPDFError, "current font is invalid" if @state.current_font.nil?
    newx, newy = @state.trm_transform(0,0)

    glyphs = @state.current_font.unpack(string)
    chars = ""
    width = 0
    glyphs.each_with_index do |glyph_code, index|
      utf8_chars = @state.current_font.to_utf8(glyph_code)

      # apply to glyph displacment for the current glyph so the next
      # glyph will appear in the correct position
      glyph_width = @state.current_font.glyph_width(glyph_code) / 1000.0
      th = 1
      scaled_glyph_width = glyph_width * @state.font_size * th

      chars << utf8_chars
      width += scaled_glyph_width
    end

    @content[newy] ||= {}
    existing_text_run = @content[newy][newx] ||= PDF::Reader::TextRun.new(newx, newy, 0, @state.font_size, "")
    @content[newy][newx] = PDF::Reader::TextRun.new(newx, newy, existing_text_run.width + width, @state.font_size, existing_text_run.text + chars)
  end

  def page=(page)
    super(page)
    @content = {}
  end

  # override PageTextReceiver content accessor .
  # Returns a hash of positional text:
  #   {
  #     y_coord=>{x_coord=>TextRun, x_coord=>TextRun },
  #     y_coord=>{x_coord=>TextRun, x_coord=>TextRun }
  #   }
  def content
    @content
  end

end
