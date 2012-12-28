DOC_CODE = Proc.new do

namespace 'CMS API'
basePath     = 'vodafone-admin.3scale.net'
swagrVersion = "0.1a"
apiVersion   = "1.0"

resource("/api/invoices.xml", 'List[invoice]') {
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
mixin('provider_key') {
  param 'provider_key',
    description: 'provider_key',
    dataType: 'string',
    required: true,
    paramType: "path"
}

mixin('pagination') {
  param('page', { dataType: 'int', default: 1 })
  param('per_page', { dataType: 'int', default: 20 })
}

end

#------------------------------ IMPLEMENTATION ---------------------------------


class Resource < Hash
  attr_accessor :path

  def initialize(path, type, options = {}, &definition)
    self[:path] = path
    self[:responseClass] = type
    @operations = self[:operations] = []
    self.instance_eval(&definition)
  end

  def operation(method, &definition)
    @operations << Operation.new(method, &definition)
  end

  def GET(&block)
    operation('GET', &block)
  end

end


#           "description": "Updates page, partial or layout by its ID",
#           "group": "cms",
#           "httpMethod": "PUT",
#           "summary": "Updates a template"
class Operation < Hash
  def initialize(method, &definition)
    self[:httpMethod] = method
    @params = self[:parameters] = []
    self.instance_eval(&definition)
  end

  def description(text)
    self[:description] = desc
  end

  def summary(text)
    self[:summary] = text
  end

  # Accepted args:
  #
  # param 'name', { attributes }
  # param 'name', 'description', { attributes }
  # param { attributes }
  #
  def param(*args)
    opts = {}

    if args.first.is_a?(String)
      opts[:name] = args.shift

      if args.first.is_a?(String)
        opts[:description] = args.shift
      end
    end

    @params <<  opts.merge(args.shift || {})
  end

  def id(desc)
    param(name: 'id', description: desc,  required: true, paramType: 'int')
  end
end


class Builder < Hash

  def initialize(&documentation)
    @resources = self[:resources] = []
    self.instance_eval &documentation
  end

  def namespace(name)
    self[:namespace] = name
  end

  def resource(path, type, options = {}, &definition)
    @resources << Resource.new(path, type, options, &definition)
  end

  def basePath(path)
    self[:basePath] = path
  end

  def swagrVersion(version)
    self[:swagrVersion] = version
  end

  def apiVersion(version)
    self[:apiVersion] = version
  end

  # mixin('pagination') {
  #   param('page', { dataType: 'int', default: 1 })
  #   param('per_page', { dataType: 'int', default: 20 })
  # }
  #
  def mixin(name, &block)
    instance_eval """
     def self.#{name}
       block.call
     end
    """
  end

end

require 'json'

builder = Builder.new(&DOC_CODE)
puts builder.to_json

# {
#   "apiVersion": "1.0",
#   "apis": [
#     {
#       "operations": [
#         {
#           "description": "Returns list of all pages, partials and layouts (headers only)",
#           "group": "cms",
#           "httpMethod": "GET",
#           "parameters": [
#             {
#               "dataType": "string",
#               "description": "Your api key with 3scale",
#               "name": "provider_key",
#               "paramType": "query",
#               "required": true,
#               "threescale_name": "api_keys"
#             },
#             {
#               "dataType": "int",
#               "defaultValue": "1",
#               "description": "Page in the paginated list. Defaults to 1.",
#               "name": "page",
#               "paramType": "query"
#             }
#           ],
#           "summary": "Templates List"
#         }
#       ],
#       "path": "/templates.xml",
#       "responseClass": "List[template]"
#     },
#     {
#       "operations": [
#         {
#           "description": "Returns a page, partial or layout by its ID",
#           "group": "cms",
#           "httpMethod": "GET",
#           "parameters": [
#             {
#               "dataType": "string",
#               "description": "Your api key with 3scale",
#               "name": "provider_key",
#               "paramType": "query",
#               "required": true,
#               "threescale_name": "api_keys"
#             },
#             {
#               "dataType": "int",
#               "description": "id of the template",
#               "name": "id",
#               "paramType": "path",
#               "required": true
#             }
#           ],
#           "summary": "Template"
#         }
#       ],
#       "path": "/templates/{id}.xml",
#       "responseClass": "template"
#     },
#     {},
#     {
#       "operations": [
#         {
#           "description": "Updates page, partial or layout by its ID",
#           "group": "cms",
#           "httpMethod": "PUT",
#           "summary": "Updates a template"

#           "parameters": [
#             {
#               "dataType": "string",
#               "description": "Your api key with 3scale",
#               "name": "provider_key",
#               "paramType": "query",
#               "required": true,
#               "threescale_name": "api_keys"
#             },
#             {
#               "dataType": "int",
#               "description": "id of the template",
#               "name": "id",
#               "paramType": "path",
#               "required": true
#             },
#             {
#               "allowMultiple": false,
#               "dataType": "string",
#               "description": "Organization name of the account.",
#               "name": "org_name",
#               "paramType": "query",
#               "required": false
#             }
#           ],
p
#         }
#       ],
#       "path": "/templates/{id}.xml",
#       "responseClass": "template"
#     }
#   ],
#   "basePath": "/admin/api/cms",
#   "swagrVersion": "0.1a"
# }
