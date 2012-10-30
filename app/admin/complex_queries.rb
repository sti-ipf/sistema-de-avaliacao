ActiveAdmin.register_page 'Mapa das Respostas' do
  menu false
  content do
    schools = School.all
      @segments = ['Familiares', 'Funcionários', 'Professores', 'Gestores', 'Educandos', 'Coordenadores pedagógicos']
      @data = ComplexQuery.get_schools_status_data(schools, @segments)
      @school_names = []
      schools.each do |s|
        s.service_levels.each do |sl|
          @school_names << "#{sl.name} - #{s.name}"
        end
      end
      render 'complex_queries/map_table', :segments => @segments, :data => @data
    end
end
