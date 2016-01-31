class Testcase < ActiveRecord::Base
  belongs_to :test
  validates :body, length: { maximum: 1024 }
  validates :result, length: { maximum: 255 }
  validates :note, length: { maximum: 1024 }

  def type
    case self.heading_level
    when -1
      :blank
    when 0
      :testcase
    else
      :heading
    end
  end

  def result
    s = super
    s ||= self.test.result_label_texts.first  # Default value
  end

  def result_color
    color = self.test.result_labels[self.result]
    color ||= "white"  # Default value
  end

  class << self
    def heading_level(text)
      return -1 if text.blank?

      text.strip!
      level = 0
      if text.start_with?("#")
        text.each_char {|char| char == "#" ? level += 1 : break }
      end
      level
    end

    def body(text)
      text.try(:strip!)
      return nil if text.blank?
      
      level = self.heading_level(text)

      if level == 0
        text =~ /(.*)(?:,\s\[.*\])/
        body = $1
        body ||= text
      else
        body = text[level..-1]
        body.strip
      end
    end

    def result(text)
      text.try(:strip!)
      return nil if text.blank?

      text =~ /,(?:\s)?\[(.*)\]/
      result = $1
    end

    def note(text)
      text.try(:strip!)
      return nil if text.blank?

      text =~ /,(?:\s)?\[(?:.*)\],(.*)/
      note = $1
      note.strip if note
    end
  end
end