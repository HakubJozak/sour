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

module Threescale
  module ApiDocDefaults
    module Operation
      def is_paginated
        param('page', { dataType: 'int', default: 1 })
        param('per_page', { dataType: 'int', default: 20 })
      end

      def system_name
        param 'system_name', 'Unique, human readable identifier'
      end

      def requires_provider_key
        param 'provider_key',
        description: 'provider_key',
        dataType: 'string',
        required: true,
        paramType: "path"
      end
    end
  end
end


TEMPLATE_DOC = Proc.new do

  Operation.mixin Threescale::ApiDocDefaults::Operation

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


#------------------------------ IMPLEMENTATION ---------------------------------


module MixinBuilder
  # mixin('pagination') {
  #   param('page', { dataType: 'int', default: 1 })
  #   param('per_page', { dataType: 'int', default: 20 })
  # }
  #
  def mixin(*args, &block)
    if block_given?
      instance_eval """
        def self.#{name}
          block.call
        end
      """
    else
      include args.first
    end
  end
end


class Resource < Hash
  extend MixinBuilder

  attr_accessor :path

  def initialize(path, type, options = {}, &definition)
    self[:path] = path
    self[:responseClass] = type
    @operations = self[:operations] = []
    self.instance_eval(&definition)
  end

  def operation(method, description = nil, &definition)
    @operations << Operation.new(method, description, &definition)
  end


  def GET( desc = nil, &block) ; operation('GET', desc, &block) ; end
  def POST( desc = nil, &block) ; operation('POST', desc, &block) ; end
  def PUT( desc = nil, &block) ; operation('PUT', desc, &block) ; end
  def DELETE( desc = nil, &block) ; operation('DELETE', desc, &block) ; end

end


#           "description": "Updates page, partial or layout by its ID",
#           "group": "cms",
#           "httpMethod": "PUT",
#           "summary": "Updates a template"
class Operation < Hash
  extend MixinBuilder

  def initialize(method, description, &definition)
    self[:httpMethod] = method
    self[:description] = description
    @params = self[:parameters] = []
    self.instance_eval(&definition)
  end

  def description(text)
    self[:description] = text
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
  extend MixinBuilder

  def initialize(&documentation)
    @resources = self[:apis] = []
    self.instance_eval &documentation
  end

  def api(path, type, options = {}, &definition)
    @resources << Resource.new(path, type, options, &definition)
  end

  def namespace(name)
    self[:namespace] = name
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

end

require 'json'

#builder = Builder.new(&EXAMPLE_DOC)
puts Builder.new(&TEMPLATE_DOC).to_json

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
#         }
#       ],
#       "path": "/templates/{id}.xml",
#       "responseClass": "template"
#     }
#   ],
#   "basePath": "/admin/api/cms",
#   "swagrVersion": "0.1a"
# }
