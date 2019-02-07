module DateHelper
  def sort_expired_hoote(lessons)
    @lessons = lessons
    @user_lessons = @lessons.select{|lesson| lesson.organizer == current_user}
    @lessons_expired = []
    @user_lessons.to_a.delete_if do |lesson|
      if lesson.datetime_completed <= Date.today
        @lessons_expired.push(lesson)
        true # Make sure the if statement returns true, so it gets marked for deletion
      end
    end
    @user_lessons.concat(@lessons_expired)
  end
end
