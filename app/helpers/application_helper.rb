module ApplicationHelper

  def flash_messages
    @messages = ''
    flash.each do |type, message|
      @messages = "#{@messages}<br>#{message}"
      @type = type
    end
    javascript = "<script type=\"text/javascript\"> jQuery(function(message) {jQuery.jGrowl(\"#{@messages}\", {easing: \"linear\", life: 49000,theme: \"#{@type}\"});});</script>"
    if defined?(@type)
      javascript 
    else
      ''
    end
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association, path="")
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, [new_object], :child_index => "new_#{association}") do |builder|
      render(path + association.to_s.singularize + "_fields", :f => builder)
    end
    fields = fields.gsub("\"","'").gsub("&",'&amp;').gsub("<",'&lt;').gsub(">",'&gt;').gsub("\n", '')
    link_to_function(name, ("add_fields(this, '#{association}', \"#{raw(fields)}\")"))
  end

  def custom_itens
    if request.path.include?("questions")
      "
      <div class='action_items'>
            <span class='action_item'>#{link_to "Nova questão", new_question_path}</span>
            <span class='action_item'>#{link_to "Importar", import_instrument_path}</span>
      </div>
      ".html_safe
    end
  end

  def custom_title
    if request.path.include?("mapa")
      "Mapa das Respostas"
    elsif request.path.include?("niveis_de_servico")
      "Importar Níveis de Serviço"
    elsif request.path.include?("escolas")
      "Importar Escolas"
    elsif request.path.include?("segmentos")
      "Importar Segmentos"
    elsif request.path.include?("dimensoes")
      "Importar Dimensões"
    elsif request.path.include?("indicadores")
      "Importar Indicadores"
    elsif request.path.include?("questions")
      "Questões ".html_safe
    elsif request.path.include?("manage")
      "Apagar respostas ".html_safe
    else
      "Importar Instrumental"
    end
  end


end

