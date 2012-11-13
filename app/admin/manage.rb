ActiveAdmin.register Manage do
  menu :parent => "Administração", :priority => 2, :label => 'Gerenciamento'

  config.comments = false
  before_filter do @skip_sidebar = true end
  # menu false
  config.clear_action_items!   # this will prevent the 'new button' showing up


  controller do
    def index
      @schools = School.all.collect{|s| [s.name]}
      @service_levels = ServiceLevel.all.collect{|s| [s.name]}
      @segments = Segment.all(:select => "DISTINCT name", :order => "name").collect{|s| [s.name.remover_acentos]}
      @dimensions = Dimension.all(:select => "DISTINCT number", :order => "number").collect{|s| [s.number]}

      render 'admin/manage/index', :layout => 'custom'
    end

    def destroy
      render 'admin/manage/index', :layout => 'custom'
    end
  end  

end

