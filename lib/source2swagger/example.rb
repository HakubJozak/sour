EXAMPLE_DOC = Proc.new do

namespace 'CMS API'
basePath     = 'vodafone-admin.3scale.net'
swagrVersion = "0.1a"
apiVersion   = "1.0"

api("/api/invoices.xml", 'List[invoice]') {
  # or POST, PUT, UPDATE, DELETE or operation('WHATEVER')
  GET {
    param 'title', { description: 'Title of the page', dataType: 'string', required: true, paramType: "path" }

    # == param with default values: STRING, required: false, and paramType 'query'
    param 'system_name', 'unique identifier of the template chosen by user'

    # == param with default values: INT, required, and paramType 'path'
    id 'ID of the template'
  }
}


# You can define custom parameters or batches of definitions
# to DRY
module MyPagination
  def is_paginated
    param('page', { dataType: 'int', default: 1 })
    param('per_page', { dataType: 'int', default: 20 })
  end
end

Operation.mixin(MyPagination)

end


#------------------------------ REAL EXAMPLE ---------------------------------



TEMPLATE_DOC = Proc.new do


  api("/api/templates.xml", 'List[template]') {

    GET('List all templates') {
      is_paginated
      requires_provider_key
    }

    # TODO: POST('Create a template') {
    #   requires_provider_key
    # }
  }

  api("/api/templates/{id}.xml", 'template') {
    PUT('Update template') {
      requires_provider_key
      id 'ID of the template'
      system_name
      param 'title', 'Title of the template'
      param 'path', 'URI of the page'
      param 'section_id', 'ID of a section', default: 'root section id', type: 'int'
      param 'layout_name', 'system name of a layout', type: 'string'
      param 'layout_id', 'ID of a layout - overrides layout_name', type: 'int'
      param 'liquid_enabled', 'liquid processing of the template content on/off', type: 'boolean'
      param 'handler', "text will be processed by the handler before rendering",
        allowableValues:{
         valueType: "LIST",
         values: [ "", "markdown","textile" ]
        }
    }
  }

end
