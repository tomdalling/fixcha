class Fixcha
  DEFAULT_CONTENT_TYPE = 'application/octet-stream'

  attr_reader :path, :content_type

  def initialize(path, content_type: DEFAULT_CONTENT_TYPE)
    @path = path
    @content_type = content_type
  end

  def read(*args)
    path.read(*args)
  end

  def open(*args, &block)
    File.open(path, *args, &block)
  end

  def to_upload
    require_rack_test!
    Rack::Test::UploadedFile.new(path, content_type)
  end

  def to_path
    path.to_path
  end

  private

    @@rack_test_required = false

    def require_rack_test!
      return if @@rack_test_required
      require 'rack/test'
      @@rack_test_required = true
    rescue LoadError
      raise <<~END_MESSAGE
        The rack-test gem is required in order to use the #upload method.

        Please make sure that it is installed, and that you can run this
        without error:

          require 'rack/test'
          puts Rack::Test::UploadedFile

      END_MESSAGE
    end

  class Repo
    attr_reader :base_path, :content_type_repo

    def initialize(base_path:, content_type_repo: nil)
      @base_path = Pathname.new(File.join(*base_path))
      @content_type_repo = content_type_repo || ContentTypeRepo.new
    end

    def fixcha(*file_path_components, content_type: nil)
      path = base_path.join(*file_path_components)
      Fixcha.new(
        path,
        content_type: content_type || content_type_repo.(path)
      )
    end
  end

  class ContentTypeRepo
    DEFAULTS = {
      txt: 'text/plain',
      png: 'image/png',
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      gif: 'image/gif',
      pdf: 'application/pdf',
      svg: 'image/svg+xml',
    }

    attr_reader :content_types_by_extension

    def initialize(content_types_by_extension = {})
      @content_types_by_extension = DEFAULTS
        .merge(content_types_by_extension)
        .map { |k, v| [k.to_s, v] }
        .to_h
    end

    def call(path)
      ext = Pathname(path).extname[1..-1] || ""
      @content_types_by_extension.fetch(ext.downcase, DEFAULT_CONTENT_TYPE)
    end
  end

  module Methods
    def fixcha(*args)
      repo = Repo.new(base_path: 'spec/fixtures')
      repo.fixcha(*args)
    end
  end
end

if defined?(Paperclip)
  require 'fixcha/paperclip'
end
