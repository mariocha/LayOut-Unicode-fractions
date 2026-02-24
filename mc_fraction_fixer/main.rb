# Fraction Fixer v2.0 - Fixed: adds dimensions on paper space

require 'sketchup.rb'
require 'fileutils'

module MarioCha
  module FractionFixer

    VERSION = '2.6.0'

    FRACTION_MAP = {
      '1/2' => '½',
      '1/3' => '⅓', '2/3' => '⅔',
      '1/4' => '¼', '3/4' => '¾',
      '1/5' => '⅕', '2/5' => '⅖', '3/5' => '⅗', '4/5' => '⅘',
      '1/6' => '⅙', '5/6' => '⅚',
      '1/8' => '⅛', '3/8' => '⅜', '5/8' => '⅝', '7/8' => '⅞'
    }.freeze

    OVERLAY_LAYER_NAME = "Fractions Unicode"

    def self.convert_layout_file
      unless defined?(Layout)
        UI.messagebox(
          "❌ Le module Layout n'est pas disponible.\n\n" +
          "Vérifiez que vous utilisez SketchUp Pro 2026.",
          MB_OK
        )
        return
      end

      path = UI.openpanel(
        "Sélectionnez un fichier LayOut",
        "",
        "Fichiers LayOut|*.layout||"
      )
      return unless path

      unless File.exist?(path)
        UI.messagebox("❌ Fichier introuvable: #{path}")
        return
      end

      unless path.downcase.end_with?('.layout')
        UI.messagebox("❌ Sélectionnez un fichier .layout", MB_OK)
        return
      end

      result = UI.messagebox(
        "FRACTION FIXER v#{VERSION}\n\n" +
        "Créer des overlays pour les dimensions?\n\n" +
        "OUI = Crée des textes Unicode sur calque\n" +
        "       '#{OVERLAY_LAYER_NAME}'\n\n" +
        "NON = Convertit uniquement textes et labels\n\n" +
        "ANNULER = Annuler",
        MB_YESNOCANCEL
      )

      return if result == IDCANCEL

      create_overlays = (result == IDYES)

#      puts "\n" + "=" * 60
#      puts "FRACTION FIXER v#{VERSION}"
#      puts "=" * 60
#      puts "Fichier: #{File.basename(path)}"
#      puts "Mode: #{create_overlays ? 'OVERLAYS + TEXTES' : 'TEXTES SEULEMENT'}"
#      puts "=" * 60

      UI.start_timer(0.1, false) { process_layout_document(path, create_overlays) }
    end

    def self.process_layout_document(original_path, create_overlays = false)
      doc = nil
      converted_labels = 0
      converted_texts = 0
      created_overlays = 0
      errors = []

			begin
        output_path = original_path.sub(/\.layout$/i, '_UNICODE.layout')

        # Copy original to preserve it
        FileUtils.cp(original_path, output_path)
        doc = Layout::Document.open(output_path)

        puts "\nPages: #{doc.pages.count}"

        overlay_layer = nil
        if create_overlays
          overlay_layer = find_or_create_layer(doc, OVERLAY_LAYER_NAME)
        end

        doc.pages.each_with_index do |page, page_idx|
          puts "\nPage #{page_idx + 1}:"

          page.entities.each do |entity|

            # Labels
            if entity.is_a?(Layout::Label)
              begin
                original = entity.text.to_s
                converted = convert_fractions(original)

                if converted != original
                  entity.text = converted
                  converted_labels += 1
                  puts "  ✓ Label: '#{original}' → '#{converted}'"
                end
              rescue => e
                errors << "Label: #{e.message}"
              end
            end

            # FormattedText
            if entity.is_a?(Layout::FormattedText)
              begin
                original = entity.plain_text.to_s
                converted = convert_fractions(original)

                if converted != original
                  entity.plain_text = converted
                  converted_texts += 1
                  puts "  ✓ Texte: '#{original}' → '#{converted}'"
                end
              rescue => e
                errors << "Text: #{e.message}"
              end
            end

# Dimensions → create real dimension overlays
if create_overlays &&
   (entity.is_a?(Layout::LinearDimension) || entity.is_a?(Layout::AngularDimension))

  begin
    initstyle = entity.style
    text_obj = entity.text
    next unless text_obj.respond_to?(:display_text)

    displ_text = text_obj.display_text.to_s

    # Skip auto text without value or already custom
    next if displ_text.empty? || displ_text == '<>'
    next unless contains_fraction?(displ_text)

    converted = convert_fractions(displ_text)
    next if converted == displ_text

    # 🚫 avoid recreating if already converted
#    next if dimension_overlay_exists?(page, entity, converted)

		vec_conn   = entity.end_connection_point - entity.start_connection_point
		vec_extent = entity.start_extent_point   - entity.start_connection_point
		height = entity.start_connection_point.distance(entity.start_extent_point)

	# 2D cross product sign (paper space)
		cross = vec_conn.x * vec_extent.y - vec_conn.y * vec_extent.x
		height = -height if cross > 0

	# 1️⃣
		new_dim = Layout::LinearDimension.new(
		entity.start_connection_point,
		entity.end_connection_point,
		height
		)
    # 2️⃣ override paper text value   No work yet

    # 3️⃣ add to document on overlay layer
    oDim = doc.add_entity(new_dim, overlay_layer, page)
	oDim.text.grow_mode = 0
    oDim.custom_text = true
#puts  "custom text is #{oDim.custom_text?}"
   oDim.disconnect

#puts   oDim
#puts   oDim.text #<Layout::FormattedText:0x000000014bba48d8>
#puts   oDim.text.class #Layout::FormattedText
#puts   oDim.text.display_text.class #string
#puts   oDim.text.display_text.length #5
#puts   oDim.text.display_text
#oDim.text.plain_text = converted.to_s   # no work !

bounds = oDim.text.bounds
oDim.text = Layout::FormattedText.new(converted, bounds)

    # 4️⃣ Apply initial style
	oDim.style = initstyle

    created_overlays += 1

  rescue => e
    errors << "Dimension: #{e.message}"
    puts "    ⚠️  Dimension error: #{e.message}"
  end
end

	end
end

        total = converted_labels + converted_texts + created_overlays

       puts "\n" + "=" * 60
       puts "RÉSULTATS:"
       puts "  Labels:   #{converted_labels}"
       puts "  Textes:   #{converted_texts}"
	   puts "  Overlays: #{created_overlays}" if create_overlays
    	puts "=" * 60

        if total > 0
          message_parts = ["✅ Conversion réussie!\n"]

          message_parts << "🏷️  Labels: #{converted_labels}" if converted_labels > 0
          message_parts << "📝 Textes: #{converted_texts}" if converted_texts > 0

          if created_overlays > 0
            message_parts << "📏 Overlays: #{created_overlays}"
            message_parts << "\n💡 Calque '#{OVERLAY_LAYER_NAME}' créé"
            message_parts << "   Désactivez-le pour voir dimensions originales"
          end

          doc.save

          message_parts << "\n💾 #{File.basename(output_path)}"
          message_parts << "✅ Original préservé: #{File.basename(original_path)}"

          if errors.any?
            message_parts << "\n⚠️  #{errors.size} avertissement(s)"
          end

          UI.messagebox(message_parts.join("\n"), MB_OK)
        else
          UI.messagebox("ℹ️ Aucune fraction à convertir trouvée.", MB_OK)
        end

      rescue => e
        UI.messagebox("❌ Erreur: #{e.message}\n\nVoir Console", MB_OK)
        puts "\n❌ ERREUR: #{e.message}"
        puts e.backtrace.first(5).join("\n")
      end

#      puts "\n" + "=" * 60
		end

    def self.find_or_create_layer(doc, layer_name)
      doc.layers.each do |layer|
        return layer if layer.name == layer_name
      end
      puts "Création calque: '#{layer_name}'"
      doc.layers.add(layer_name)
    end

    def self.create_overlay_text(doc, page, text_obj, converted_text, layer)
      begin
        # Get bounds from dimension text
        bounds = text_obj.bounds

        # Get corner points
        upper_left = bounds.upper_left
        lower_right = bounds.lower_right

 #       puts "    Bounds: UL(#{upper_left.x.round(2)}, #{upper_left.y.round(2)}) LR(#{lower_right.x.round(2)}, #{lower_right.y.round(2)})"

        # Create new bounds
        text_bounds = Geom::Bounds2d.new(upper_left, lower_right)

        # Create FormattedText with converted text and bounds
        overlay_text = Layout::FormattedText.new(converted_text, text_bounds)
			  overlay_text.grow_mode = 0
#        puts "    ✓ FormattedText créé"

        # Add to entity collection
				otext = doc.add_entity(overlay_text, layer, page)
				ostyle = otext.style
				ostyle.solid_filled = (true)
				ostyle.fill_color = Sketchup::Color.new(240, 250, 240, 250)
				otext.style = ostyle

#       puts "    ✓ Overlay ajouté à la page"

        # Assign to overlay layer
        begin
          if overlay_text.respond_to?(:layer=)
            overlay_text.layer = layer
            puts "    ✓ Calque: '#{layer.name}'"
          end
        rescue => e
          puts "    ⚠️  Layer: #{e.message}"
        end

        return true

      rescue => e
        puts "    ❌ Erreur: #{e.message}"
        puts "    #{e.backtrace.first}"
        return false
      end
    end

    def self.contains_fraction?(text)
      return false unless text.is_a?(String)
      FRACTION_MAP.keys.any? { |fraction| text.include?(fraction) }
    end

    def self.convert_fractions(text)
      return text unless text.is_a?(String)
      result = text.dup
      FRACTION_MAP.sort_by { |k, v| -k.length }.each do |fraction, unicode|
        result.gsub!(fraction, unicode)
      end
      result
    end

    unless file_loaded?(__FILE__)
      menu = UI.menu('Plugins')
      submenu = menu.add_submenu('Fraction Fixer')

      submenu.add_item('Convert LayOut File...') { convert_layout_file }
      submenu.add_separator
      submenu.add_item("About v#{VERSION}") {
        UI.messagebox(
          "Fraction Fixer v#{VERSION}\n\n" +
          "Convertit les fractions en Unicode\n" +
          "dans les fichiers LayOut.\n\n" +
          "✅ SketchUp 2026 Pro\n" +
          "✅ Original préservé\n" +
          "✅ Calque pour overlays\n\n" +
          "Convertit:\n" +
          "  • Labels\n" +
          "  • Zones de texte\n" +
          "  • Dimensions (overlay)\n\n" +
          "Calque '#{OVERLAY_LAYER_NAME}' créé\n" +
          "pour les overlays de dimensions.\n\n" +
          "Par Mario Chabot - 2026",
          MB_OK
        )
      }

      file_loaded(__FILE__)
    end

  end
end

puts "✅ Fraction Fixer v#{ MarioCha::FractionFixer::VERSION } chargé"
