# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.uncountable %w( manage )

  inflect.irregular 'dimensão', 'dimensões'
  inflect.irregular 'indicador', 'indicadores'
  inflect.irregular 'nível de serviço', 'níveis de serviço'
  inflect.irregular 'log de resposta', 'logs de respostas'
  inflect.irregular 'sessão de avaliação', 'sessões de avaliação'
end
