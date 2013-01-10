module Sour
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


  #  "description": "Updates page, partial or layout by its ID",
  #  "group": "cms",
  #  "httpMethod": "PUT",
  #  "summary": "Updates a template"
  #
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

    # Examples:
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

    def initialize
      @resources = self[:apis] = []
    end

    def parse_documentation(docs, &block)
      raise 'Already parsing some documentation' if @parsing
      raise 'Pass either string or block to parse' if docs && block_given?


      @parsing = true
      if docs
        self.instance_eval(docs)
      else
        self.instance_eval(&block)
      end
      @parsing = false
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

    def resourcePath(path)
      self[:resourcePath] = path
    end

    def swaggerVersion(version)
      self[:swagrVersion] = version
    end

    alias :swagrVersion :swaggerVersion

    def apiVersion(version)
      self[:apiVersion] = version
    end
  end
end
