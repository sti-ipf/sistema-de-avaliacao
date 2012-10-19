class EvaluationController < ApplicationController
  autocomplete :school, :name, :full => true
  before_filter :check_session, :only =>[:identify, :instructions, :answer_dimension, :review, :checkreview, :save, :presence_list, :save_presence_list]
  def evaluation_template
    @answers = Answer.find_by_sql("
      SELECT qt.dimension_number, qt.question_number, a.do_not_know, a.do_not_answer, 
        a.one, a.two, a.three, a.four, a.five FROM answers a
      INNER JOIN question_texts qt ON qt.id = a.question_text_id
      INNER JOIN segments s ON s.id = a.segment_id
      WHERE a.school_id = #{params[:school_id]}
      AND a.segment_id = #{params[:segment_id]}
    ")
  end

  def index
    clean_session
    @schools = School.all.collect{ |school| [school.name, school.id] }
  end

  def authenticate
    if params[:school].nil?
      params[:school] = params[:school_id]
    end
    @password = Password.find_by_password_and_school_id(params[:password], params[:school])

    if (!@password.nil?)
      if(!is_session_valid(@password.school.id, @password.segment.id))
        @schools = School.all.collect{ |school| [school.name, school.id] }
        render "index", :alert => 'Ja existe uma avaliação sendo feita para este item.'
      else
        @segment = @password.segment
        @school = @password.school
        @service_level = @password.service_level
        generate_steps
        render "confirm"
        end
    else
      @schools = School.all.collect{ |school| [school.name, school.id] }
      render "index", :alert => 'Senha inválida para a escola selecionada.'
    end
  end

  def identify
    load_params
    generate_steps
    if(params[:commit] == 'sim')
      render "identify"
    else
      clean_session
      @schools = School.all.collect{ |school| [school.name, school.id] }
      render "index", :notice => 'Escola e segmento não confirmados, por favor digite uma nova senha.'
    end
  end

  def instructions
    load_params
    generate_steps
    render "instructions"
  end

  def update_session
      if EvaluationUserSession.update(cookies[:school_id], cookies[:segment_id], cookies[:session])
        render :json => 200
      else
        render :json => 400
      end
  end

  def answerdimension
    load_params
    @dimension_status = DimensionStatus.find_by_sql(["select d.id, d.number, ds.status
                                                        from dimensions d
                                                          left join dimension_statuses ds on d.id = ds.dimension_id
                                                            and ds.segment_id = ? and ds.school_id = ?
                                                        where
                                                          d.service_level_id =?
                                                          and (ds.status is null or ds.status in(?, ?))
                                                          order by d.number", @segment.id, @school.id, @service_level.id, DimensionStatus::IN_PROGRESS, DimensionStatus::NOT_STARTED])
    if @dimension_status.size == 0
      redirect_to :action => "presence_list", :school => @school.id, :segment => @segment.id, :service_level => @service_level.id, :name => @name
      return
    end


    @dimension = Dimension.find(@dimension_status[0].id)

    @practices = Practice.find_by_segment_id_and_school_id_and_dimension_id(@segment.id, @school.id, @dimension.id)

    update_dimension_status DimensionStatus::IN_PROGRESS
    load_questions
    load_answers
    generate_steps
    render "answer"
  end

  def review
    load_params
    do_not_know = params[:do_not_know]
    do_not_answer = params[:do_not_answer]
    quantity_of_people = params[:quantity_of_people].nil? ? Hash.new : params[:quantity_of_people]
    one = params[:one]
    two = params[:two]
    three = params[:three]
    four = params[:four]
    five = params[:five]
    consolidated_practices = params[:consolidated_practices]
    to_be_improved_practices = params[:to_be_improved_practices]
    @json_tables = params[:hdfGabarito]

    @dimension_status = DimensionStatus.find_by_dimension_id_and_school_id_and_segment_id(@dimension.id, @school.id, @segment.id)
    load_answers
    @practice = Practice.find_by_segment_id_and_school_id_and_dimension_id(@segment.id, @school.id, @dimension.id)
    puts "dms:#{@dimension_status.inspect}"
#    if (@dimension_status.nil? || @dimension_status.status != DimensionStatus::FINISHED)
      quantity_of_people.each_pair do |k, v|

        answer = @answers[k.to_i]
        if answer.nil?
          @answers[k.to_i] = Answer.create(:school => @school, :segment => @segment, :question_text_id => k.to_i,
                        :do_not_know => do_not_know[k], :do_not_answer => do_not_answer[k],
                        :quantity_of_people => quantity_of_people[k], :one => one[k],
                        :two => two[k], :three => three[k], :four => four[k], :five => five[k])
        else
          answer.do_not_know = do_not_know[k]
          answer.do_not_answer = do_not_answer[k]
          answer.quantity_of_people = quantity_of_people[k]
          answer.one = one[k]
          answer.two = two[k]
          answer.three = three[k]
          answer.four = four[k]
          answer.five = five[k]
          answer.save
        end
      end
      if @practice.nil?
        @practice = Practice.create(:school => @school, :segment => @segment, :dimension => @dimension,
                      :consolidated => consolidated_practices, 
                      :to_be_improved => to_be_improved_practices)
      else
        @practice.consolidated = consolidated_practices
        @practice.to_be_improved = to_be_improved_practices
        @practice.save
      end
      update_dimension_status DimensionStatus::IN_PROGRESS
      load_questions
      generate_answer_log
      generate_steps
      update_evaluation_stats
      render "review"
    # else
    #   if last_dimension
    #     redirect_to :action => "presence_list", :school => @school.id, :segment => @segment.id, :service_level => @service_level.id
    #   else
    #     redirect_to :action => "answerdimension", :dimension => @dimension.number+1, :school => @school.id, :segment => @segment.id, :service_level => @service_level.id
    #   end
    # end
  end

  def checkreview
    load_params
    generate_steps
    load_questions
    load_answers
    @dimension_status = DimensionStatus.find_by_dimension_id_and_school_id_and_segment_id(@dimension.id, @school.id, @segment.id)
    @dimension_status.status = DimensionStatus::FINISHED
    @dimension_status.save
    @practices = Practice.find_by_segment_id_and_school_id_and_dimension_id(@segment.id, @school.id, @dimension.id)
    if(params[:commit] == 'modificar')
      render "answer"
    else
      render "save"
    end
  end

  def save
    load_params
    generate_steps
    update_dimension_status DimensionStatus::FINISHED
    if(params[:commit] == 'ir para próxima dimensão' || params[:commit] == 'ir para a lista de presença')
      redirect_to :action => "answerdimension", :school => @school.id, :segment => @segment.id, :service_level => @service_level.id, :name => @name
    else
      end_session
    end
  end

  def presence_list
    load_params
    generate_steps
    @presence = Presence.find_all_by_segment_id_and_school_id(@segment.id, @school.id)
    render "presence_list"
  end

  def save_presence_list
    load_params
    generate_steps
    @evaluation_status = EvaluationAnswerStat.find_by_service_level_id_and_segment_id_and_school_id(@service_level.id, @segment.id, @school.id)
    
    respond_to do |format|
      format.html {render "finish", :layout => 'certificate'}
      format.pdf do
        headless = Headless.new
        headless.start
        render :pdf => "export"
        headless.destroy
      end
    end
  end

  def end_session
    clean_session
    redirect_to "http://www.avaliaosasco.paulofreire.org/"
  end

private
  def check_session
    if(!has_session? params[:school], params[:segment])
      @schools = School.all.collect{ |school| [school.name, school.id] }
      render "index", :alert => 'Sua sessão expirou.'
    end
  end

  def update_dimension_status status
    @dimension_status = DimensionStatus.find_by_segment_id_and_school_id_and_dimension_id(@segment.id, @school.id, @dimension.id)
    if @dimension_status.nil?
      @dimension_status = DimensionStatus.create(:school => @school, :segment => @segment, :dimension => @dimension,
                                                 :status => status)
    else
      @dimension_status.status = status
      @dimension_status.save
    end
  end
  def generate_steps
    @steps = []
    @steps << ["Autenticação", "Autenticação"]
    @steps << ["Confirmação segmento", "Confirmação segmento"]
    @steps << ["Identificação","Identificação"]
    @service_level.dimensions.each do |dimension|
      @steps << [dimension.name, "Dimensão #{dimension.number}"]
    end
    @steps << ["Lista de presença", "Lista de presença"]
    @steps << ["Finalização", "Finalização"]
  end

  def load_answers
    answers = Answer.find_by_sql(["select a.* 
                                            from answers a
                                            where 
                                              a.school_id = ?
                                              and a.segment_id = ?", @school.id, @segment.id])
    @answers = {}
    answers.each do | a |
      @answers[a.question_text_id] = a
    end
    @answers
  end
  def load_questions
    @questions = QuestionText.find_by_sql(["select qt.*
                                          from question_texts qt
                                            inner join questions q on qt.question_id = q.id
                                            inner join indicators i on q.indicator_id = i.id
                                            inner join dimensions d on i.dimension_id = d.id
                                          where
                                            q.service_level_id = ?
                                            and qt.segment_id = ?
                                            and d.id = ?", @service_level.id, @segment.id, @dimension.id])
  end

  def load_params
    @school = School.find(params[:school])
    @service_level = ServiceLevel.find(params[:service_level])
    @segment = Segment.find(params[:segment])
    @name = params[:name] if !params[:name].blank?
    @dimension = Dimension.find_by_number_and_service_level_id(params[:dimension], @service_level.id)
  end
  
  def update_evaluation_stats
    stat = EvaluationAnswerStat.find_by_service_level_id_and_segment_id_and_school_id(@service_level.id, @segment.id, @school.id)
    stat.dimension = @dimension
    if !stat.started_to_answer
      stat.started_to_answer = true
      stat.started_at = Time.now
    end
    if last_dimension
      stat.finished_at = Time.now
    end
    stat.save
  end

  def generate_answer_log
    log = ""
    @questions.each do | question |
      log += "#{@dimension.number}.#{question.question.indicator.number}.#{question.question.number}-  0:[#{@answers[question.id].do_not_know}], 1:[#{@answers[question.id].one}], 2:[#{@answers[question.id].two}], 3:[#{@answers[question.id].three}],4:[#{@answers[question.id].four}], 5:[#{@answers[question.id].five}], ø:[#{@answers[question.id].do_not_answer}], Quantidades de pessoas:[#{@answers[question.id].quantity_of_people}]\n"
    end
    a = AnswerLog.create(:service_level => @service_level, :segment => @segment,  :school => @school, :dimension => @dimension, 
                      :person => @name, :questions => log)
  end
  def last_dimension
    dimensions = Dimension.where("service_level_id = ?", @service_level.id).order("number")
    @dimension.number == dimensions.last.number
  end

  def generate_cookies(school_id, segment_id)
    cookies[:school_id] = { :value => school_id, :expires => Time.now + 1.day}
    cookies[:segment_id] = { :value => segment_id, :expires => Time.now + 1.day}
    cookies[:session] = { :value => UUIDTools::UUID.random_create.to_s, :expires => Time.now + 1.day}
  end

  def is_session_valid school_id, segment_id
    session = EvaluationUserSession.where(:school_id => school_id, :segment_id => segment_id).first
    if(session.nil?)
      generate_cookies school_id, segment_id
      session = EvaluationUserSession.new
      session.school_id = school_id
      session.segment_id = segment_id
      session.session_cookie = cookies[:session]
      session.last_request = Time.now
      session.save
      return true
    elsif(session.session_cookie == cookies[:session])
        return true
    else
        return false
    end
  end

  def has_session? school_id, segment_id
    return false if(cookies[:school_id] != school_id || cookies[:segment_id] != segment_id)
    session = EvaluationUserSession.where(:school_id => cookies[:school_id], :segment_id => cookies[:segment_id], :session_cookie => cookies[:session]).first
    !session.nil?
  end

  def clean_session
    session = EvaluationUserSession.where(:school_id => cookies[:school_id], :segment_id => cookies[:segment_id], :session_cookie => cookies[:session]).first
    session.destroy if !session.nil?
    delete_cookies
  end
  
  def delete_cookies
    cookies.delete :school_id
    cookies.delete :segment_id
    cookies.delete :session
  end
end
