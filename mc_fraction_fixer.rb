# mc_fraction_fixer.rb
# Fraction Fixer - Convertit les fractions LayOut en Unicode
# Par Mario Chabot - 2026
# Version 2.0

require 'sketchup.rb'
require 'extensions.rb'

module MarioCha
  module FractionFixer

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new(
        'Fraction Fixer',
        'mc_fraction_fixer/main.rb'
      )

      ex.description = 'Convertit les fractions (1/2, 3/4, etc.) en caractères Unicode (½, ¾, etc.) dans les fichiers LayOut.'
      ex.version     = '2.6.0'
      ex.copyright   = '2026 Mario Chabot'
      ex.creator     = 'Mario Chabot'

      Sketchup.register_extension(ex, true)

      file_loaded(__FILE__)
    end

  end
end
