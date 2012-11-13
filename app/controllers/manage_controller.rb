class ManageController < ApplicationController
   def index
      @schools = School.all.collect{|s| [s.name]}
      @service_levels = ServiceLevel.all.collect{|s| [s.name]}
      @segments = Segment.all(:select => "DISTINCT name", :order => "name").collect{|s| [s.name]}
      @dimensions = Dimension.all(:select => "DISTINCT number", :order => "number").collect{|s| [s.number]}

      render 'admin/manage/index', :layout => 'custom'
    end

    def destroy
      exec "mysqldump -uroot -p1234Freire avaliacao_2012 > ~/dump_avalia_2012_#{DateTime.now.to_i}"
      school = params[:school_name]
      service_level = params[:search][:service_level]
      dimension = params[:search][:dimension]
      segment = params[:search][:segment]
      if dimension.blank?
        queries = Manage.search_without_dimension(school, service_level, segment)
      else
        queries = Manage.full_search(school, service_level, segment, dimension)
      end
      queries.each do |query|
        ActiveRecord::Base.connection.execute(query)
      end
      flash[:notice] = 'Dados apagados com sucesso'
      redirect_to admin_manage_path
    end

end