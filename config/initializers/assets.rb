# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# AdminLTE CSS
Rails.application.config.assets.precompile += %w( bootstrap/css/bootstrap.min.css )
Rails.application.config.assets.precompile += %w( AdminLTE.min.css )
Rails.application.config.assets.precompile += %w( skins/_all-skins.min.css )
Rails.application.config.assets.precompile += %w( plugins/iCheck/flat/blue.css )

# AdminLTE JS
Rails.application.config.assets.precompile += %w( bootstrap/js/bootstrap.min.js )
Rails.application.config.assets.precompile += %w( plugins/jQuery/jquery-2.2.3.min.js )
Rails.application.config.assets.precompile += %w( iCheck/icheck.min.js )
Rails.application.config.assets.precompile += %w( app.min.js )

# AdminLTE FONT
Rails.application.config.assets.precompile += %w( *.svg *.eot *.woff *.woff2 *.ttf )
