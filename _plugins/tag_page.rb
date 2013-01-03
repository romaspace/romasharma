module Jekyll

  class TagPage < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag'] = tag

      tag_title_prefix = 'Tag: '
      self.data['title'] = "#{tag_title_prefix}#{tag}"
    end
  end

  class TagPageGenerator < Generator
    safe true
    
    def generate(site)
      if site.layouts.key? 'tag'
        dir = '/tag'
        site.tags.keys.each do |tag|
          tag_slug = tag.downcase.gsub(/\W+/,'-')
          site.pages << TagPage.new(site, site.source, File.join(dir, tag_slug), tag)
        end
      end
    end
  end

end
