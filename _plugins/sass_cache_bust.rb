# Cache-busting for the compiled main.css.
#
# The bundled jekyll-cache-bust gem computes the version hash from
# assets/_sass, but this theme keeps its Sass in _sass/ — that directory
# does not exist, so the digest was always the MD5 of an empty string and
# the stylesheet URL never changed. Browsers then kept serving a stale
# main.css after style changes.
#
# This filter hashes the actual Sass sources instead. It falls back to the
# build timestamp if anything goes wrong, so a build can never fail here.

require "digest/md5"

module Jekyll
  module SassCacheBust
    SASS_GLOBS = ["_sass/**/*", "assets/css/main.scss"].freeze

    def bust_sass_cache(file_name)
      content = SASS_GLOBS.flat_map { |glob| Dir[glob].sort }.select { |f| File.file?(f) }.map { |f| File.read(f) }.join
      content = Time.now.to_f.to_s if content.empty?
      "#{file_name}?v=#{Digest::MD5.hexdigest(content)}"
    rescue StandardError
      "#{file_name}?v=#{Time.now.to_i}"
    end
  end
end

Liquid::Template.register_filter(Jekyll::SassCacheBust)
