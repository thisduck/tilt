require 'tilt/template'

module Tilt
  # Sass template implementation. See:
  # http://haml.hamptoncatlin.com/
  #
  # Sass templates do not support object scopes, locals, or yield.
  class SassTemplate < Template
    self.default_mime_type = 'text/css'

    def self.engine_initialized?
      defined?(::Sass::Engine) && defined?(::Sass::Plugin)
    end

    def initialize_engine
      require_template_library 'sass'
      require_template_library 'sass/plugin'
    end

    def prepare
      @engine = ::Sass::Engine.new(data, ::Sass::Plugin.engine_options(sass_options))
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.render
    end

  private
    def sass_options
      options.merge(:filename => eval_file, :line => line, :syntax => :sass)
    end
  end

  # Sass's new .scss type template implementation.
  class ScssTemplate < SassTemplate
    self.default_mime_type = 'text/css'

  private
    def sass_options
      options.merge(:filename => eval_file, :line => line, :syntax => :scss)
    end
  end

   # Lessscss template implementation. See:
  # http://lesscss.org/
  #
  # Less templates do not support object scopes, locals, or yield.
  class LessTemplate < Template
    self.default_mime_type = 'text/css'

    def self.engine_initialized?
      defined? ::Less::Engine
    end

    def initialize_engine
      require_template_library 'less'
    end

    def prepare
      @engine = ::Less::Engine.new(data)
    end

    def evaluate(scope, locals, &block)
      @engine.to_css
    end
  end

  # Lessscss template implementation. See:
  # http://lesscss.org/
  #
  # Less templates do not support object scopes, locals, or yield.
  # We're using the npm install lessc binary to compile less here.
  class LesscTemplate < Template
    self.default_mime_type = 'text/css'

    def self.engine_initialized?
      raise LoadError unless (%x[lessc -v 2>&1] =~ /\(LESS Compiler\) \[JavaScript\]/) != nil
    end

    def initialize_engine; end

    def prepare; end

    def evaluate(scope, locals, &block)
      file = Tempfile.new("lessc")
      file.write(data)
      file.close
      `lessc #{file.path}`
    end
  end
end

