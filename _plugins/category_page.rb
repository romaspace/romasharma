module Jekyll

  class CategoryPage < Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category.html')
      self.data['category'] = category

      category_title_prefix = 'Category: '
      self.data['title'] = "#{category_title_prefix}#{category}"
    end
  end

  class CategoryPageGenerator < Generator
    safe true
    
    def generate(site)
      if site.layouts.key? 'category'
        dir = '/category'
        site.categories.keys.each do |category|
          cat_slug = category.downcase.gsub(/\W+/,'-')
          site.pages << CategoryPage.new(site, site.source, File.join(dir, cat_slug), category)
        end
      end
    end
  end

end
