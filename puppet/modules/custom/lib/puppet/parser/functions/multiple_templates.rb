## How it works:
## It works similar to multiple sources.
## Checks for existence of each template mentioned one after the other and returns the first file that exists.

module Puppet::Parser::Functions
    require 'erb'

    newfunction(:multiple_templates, :type => :rvalue) do |args|
        contents = nil
        environment = compiler.environment
        sources = args

        sources.each do |file|
            Puppet.debug("Looking for #{file} in #{environment}")
            if filename = Puppet::Parser::Files.find_template(file, environment)
                wrapper = Puppet::Parser::TemplateWrapper.new(self)
                wrapper.file = file

                begin
                     contents = wrapper.result
                rescue => detail
                     raise Puppet::ParseError, "Failed to parse template %s: %s" % [file, detail]
                end

                break
            end
        end

        raise Puppet::ParseError, "multiple_templates: No match found for files: #{sources.join(', ')}, environment: #{environment}" if contents == nil

        contents
    end
end
