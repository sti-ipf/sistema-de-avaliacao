class Admin::QuestionsController < ApplicationController
  
  def index
    @question_texts = QuestionText.all(:joins => [:question, :segment])
    render :layout => 'custom'
  end

  def new
    @question = Question.new
  end

end


