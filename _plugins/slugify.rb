module Jekyll
  module Slugify
    def slugify(input)      
      input.downcase.gsub(/\W+/,'-')
    end
  end
end

Liquid::Template.register_filter(Jekyll::Slugify)
