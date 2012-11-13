IpfOsascoAvaliacao2011::Application.routes.draw do
  
  match "admin/questions", :to => 'questions#index', :as => 'questions'
  match "admin/questions/new", :to => 'questions#new', :as => 'new_question'
  match "admin/create_question", :to => 'questions#create', :as => 'create_question'
  match "admin/questions/:id/edit", :to => 'questions#edit', :as => 'edit_question'
  match "admin/update_question", :to => 'questions#update', :as => 'update_question'
  match "update_indicators/:service_level_id", :to => 'questions#update_indicators'

  
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  root :to => 'evaluation#index'
  match "autenticar", :to => 'evaluation#authenticate'
  match "confirmar", :to => 'evaluation#confirm'
  match "identificar", :to => 'evaluation#identify'
  match "instrucoes", :to => 'evaluation#instructions'
  match "responder_dimensao", :to => 'evaluation#answerdimension'
  match "revisar", :to => 'evaluation#review'
  match "validar_revisao", :to => 'evaluation#checkreview'
  match "salvar", :to => 'evaluation#save'
  match "lista_presenca", :to => 'evaluation#presence_list'
  match "salvar_lista_presenca", :to => 'evaluation#save_presence_list'
  match "gabarito", :to => 'evaluation#evaluation_template', :as => 'template'
  match "update_session", :to => 'evaluation#update_session'
  match "end_session", :to => 'evaluation#end_session'

  match "passwords/generate_all_letters", :to => 'passwords#generate_all_letters'
  match "passwords/generate_creche_conveniadas_letters", :to => 'passwords#generate_creche_conveniadas_letters'
  match "passwords/generate_all_passwords", :to => 'passwords#generate_all_passwords'
  match "admin/passwords/:id/download_letter", :to => 'admin_passwords#download_letter'

  match "mapa", :to => 'complex_queries#map_table', :as => 'map'
  match "sistema/respostas/gerar_estatisticas", :to => 'system#generate_answer_stats', :as => 'generate_answer_stats'
  match "sistema/senhas/gerar", :to => 'system#generate_passwords', :as => 'generate_passwords'
  match "sistema/instrumental/importar", :to => 'system#import_instrument', :as => 'import_instrument'
  match "sistema/niveis_de_servico/importar", :to => 'system#import_service_levels', :as => 'import_service_levels'
  match "sistema/escolas/importar", :to => 'system#import_schools', :as => 'import_schools'
  match "sistema/dimensoes/importar", :to => 'system#import_dimensions', :as => 'import_dimensions'
  match "sistema/segmentos/importar", :to => 'system#import_segments', :as => 'import_segments'
  match "sistema/indicadores/importar", :to => 'system#import_indicators', :as => 'import_indicators'

  match '/admin/manage' => 'manage#index', :as => :admin_manage
  match '/admin/apagar_dados_de_respostas' => 'manage#destroy', :as => :destroy_evaluation_data

  

  resources :evaluation do
    get :autocomplete_school_name, :on => :collection
  end

  

end

