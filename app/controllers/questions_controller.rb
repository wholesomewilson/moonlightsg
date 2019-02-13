class QuestionsController < ApplicationController
  before_action :set_questions_and_lesson
  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    respond_to do |format|
      format.js { render 'questions.js.erb' }
    end
  end

  private
  def set_questions_and_lesson
    @lesson = Question.find(params[:id]).lesson
    @questions = @lesson.questions
  end
end
