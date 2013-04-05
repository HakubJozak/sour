module Sour
  module MixinBuilder
    # mixin('pagination') {
    #   param('page', { dataType: 'int', default: 1 })
    #   param('per_page', { dataType: 'int', default: 20 })
    # }
    #
    def mixin(*args, &block)
      if block
        file, line = caller.first.split(':', 2)
        line = line.to_io

        name = args.shift
        instance_eval(<<-EOS, file, line - 2)
        def self.#{name.to_s}
            block.call
        end
        EOS
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

    def GET(desc = nil, &block) ; operation('GET', desc, &block) ; end
    def POST(desc = nil, &block) ; operation('POST', desc, &block) ; end
    def PUT(desc = nil, &block) ; operation('PUT', desc, &block) ; end
    def DELETE(desc = nil, &block) ; operation('DELETE', desc, &block) ; end

  end

  class Param < Hash
    def initialize(opts)
      opts.each_pair do |key,value|
        if key == :choices
          raise 'Values of "choices" has to be an array' unless value.is_a?(Array)
          self[:required] ||= false
          self[:allowableValues] = { valueType:"LIST", values: value.dup }
        else
          self[key] = value
        end
      end
    end
  end


  #  "description": "Updates page, partial or layout by its ID",
  #  "group": "cms",
  #  "httpMethod": "PUT",
  #  "summary": "Updates a template"
  #
  class Operation < Hash
    extend MixinBuilder

    def initialize(method, summary, &definition)
      self[:httpMethod] = method
      self[:summary] = summary
      self[:description] = summary
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
      opts = { paramType: default_param_type }

      if args.first.is_a?(String)
        opts[:name] = args.shift

        if args.first.is_a?(String)
          opts[:description] = args.shift
        end
      end

      @params << Param.new(opts.merge(args.shift || {}))
    end

    def id(desc)
      param(name: 'id', description: desc, required: true, dataType: 'int', paramType: 'path')
    end

    private

    def default_param_type
      if self[:httpMethod] == 'GET'
        'path'
      else
        'query'
      end
    end
  end


  class Builder < Hash
    extend MixinBuilder

    def initialize
      @resources = self[:apis] = []
    end

    def parse_documentation(docs, &block)
      raise 'Already parsing some documentation' if @parsing
      raise 'Pass either string to parse or block to evaluation' if docs && block_given?

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
