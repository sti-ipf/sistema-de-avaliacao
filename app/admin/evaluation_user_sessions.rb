ActiveAdmin.register EvaluationUserSession do
  menu :parent => "Administração", :priority => 2, :label => 'Sessão de Avaliação'
  actions :destroy, :index

  index do
    column 'Escola', :school
    column 'Segmento', :segment
    column 'Cookie', :session_cookie
    column '', :actions do |session| 
      link_to 'Deletar', resource_path(session.id) , :method => :delete, :confirm => 'Deseja deletar esta sessão?'
    end
  end

end

