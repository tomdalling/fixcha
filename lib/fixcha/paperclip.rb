class Fixcha
  class PaperclipIOAdaper < SimpleDelegator
    def initialize(fixcha, options)
      actual_adapter = fixcha.open do |file|
        Paperclip.io_adapters.for(file, options)
      end
      super(actual_adapter)
    end
  end
end

Paperclip.io_adapters.register(Fixcha::PaperclipIOAdaper) do |value|
  Fixcha === value
end
