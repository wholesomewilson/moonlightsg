module LessonsHelper
  def parse_time(date, hour, minute, ampm)
    @parsed_time = DateTime.parse("#{date} #{hour}:#{minute}#{ampm}")
  end
end
