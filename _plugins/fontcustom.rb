module Jekyll
  class FontcustomFile < StaticFile
    def write(dest)
      begin
        super(dest)
      rescue
      end
      true
    end
  end
  class FontcustomGenerator < Generator
    priority :low
    safe true
    def generate(site)
      system("
        set -e
        dir=$(pwd)
        fontcustom compile ${dir}/_glyphs --output=${dir}/css \
          --font-name=icons --templates=scss \
          --no-hash --force --autowidth
        mkdir -p ${dir}/_site/css
        mv ${dir}/css/icons.* ${dir}/_site/css
      ")
      ['svg', 'ttf', 'woff', 'eot'].each do |ext|
        site.static_files << Jekyll::FontcustomFile.new(site, site.dest, '/', "css/icons.#{ext}")
      end
    end
  end
end
