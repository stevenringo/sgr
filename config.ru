require 'rack/contrib/try_static'
require 'rack/contrib/not_found'
require 'rack/rewrite'

use Rack::Deflater

use Rack::Rewrite do
  r301 '/blog/from', '/blog/to.html'
  r301 '/external', 'https://example.com/external link'
  r301 %r{.*}, 'http://sgr-test.herokuapp.com$&', if: Proc.new do |rack_env|
    ENV['RACK_ENV'] == "production" && rack_env['SERVER_NAME'] != 'sgr-test.herokuapp.com'
  end
end

use Rack::TryStatic,
  urls: %w[/],
  root: "_site",
  try: ['index.html', '/index.html'],
  header_rules: [
    [["html"],  {'Content-Type' => 'text/html; charset=utf-8'}],
    [["css"],   {'Content-Type' => 'text/css'}],
    [["js"],    {'Content-Type' => 'text/javascript'}],
    [["png"],   {'Content-Type' => 'image/png'}],
    ["/assets", {'Cache-Control' => 'public, max-age=31536000'}],
  ]

run Rack::NotFound.new('_site/404.html')
