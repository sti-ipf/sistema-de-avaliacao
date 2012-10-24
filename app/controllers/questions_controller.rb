class QuestionsController < ApplicationController
  layout 'custom'  
  def index
    @question_texts = QuestionText.all(:include => [:question, :segment], :order => "questions.number ASC, questions.service_level_id ASC, question_texts.segment_id ASC")
    render :layout => 'custom'
  end

  def new
    @question = Question.new
    @question.question_texts.build
    @service_levels = ServiceLevel.all.collect{|s| [s.name, s.id]}
    @segments = Segment.all(:select => "DISTINCT name").collect{|i| [i.name]}
    @indicators = []
  end

  def update_indicators
    @indicators = Indicator.all(:conditions => "dimension_id IN (select id from dimensions where service_level_id = #{params[:service_level_id]})").collect {|i| [i.name, i.id]}
    @segments = Segment.all(:conditions => "service_level_id = #{params[:service_level_id]}").collect{|i| [i.name, i.id]}
    respond_to do |format|
      format.js if request.xhr?
    end
  end

  def create
    question = Question.create(:number => params[:question][:number], :service_level_id => params[:question][:service_level_id], :indicator_id => params[:question][:indicator_id])
    params[:question][:question_texts_attributes].each do |q|
      q = q.last
      segment = Segment.first(:conditions => "name = '#{q['segment_id']}' AND service_level_id = #{question.service_level_id}")
      @question_text = QuestionText.create(:text => q['text'], :question_id => question.id, :segment_id => segment.id)
    end
    flash[:notice] = 'Questão cadastrada com sucesso'
    redirect_to questions_path
  end

  def edit
    @question = Question.find(params[:id])
    @service_levels = ServiceLevel.all.collect{|s| [s.name, s.id]}
    @indicators = Indicator.all(:conditions => "dimension_id IN (select id from dimensions where service_level_id = #{@question.service_level_id})").collect {|i| [i.name, i.id]}
    @segments = Segment.all(:conditions => "service_level_id = #{@question.service_level_id}").collect{|i| [i.name, i.id]}
  end

  def update
    question = Question.find(params[:question][:id])
    question.service_level_id = params[:question][:service_level_id]
    question.indicator_id = params[:question][:indicator_id]
    question.number = params[:question][:number]
    question.save
    params[:question][:question_texts_attributes].each do |q|
      q = q.last
      question_text = QuestionText.find(q['id'])
      question_text.text = q['text']
      question_text.segment_id = q['segment_id']
      if q['_destroy'].to_s == 'false'
        question_text.save
      else
        question_text.destroy
      end
    end
    flash[:notice] = 'Questão atualizada com sucesso'
    redirect_to questions_path
  end

end
