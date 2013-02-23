require './lib/Image.rb'
require './lib/ImageHelpers.rb'
require './lib/ColorHelpers.rb'

module AsciiHelpers
  def self.loadAsciiData(folder_name)
    dir = Dir.new(folder_name)
    file_names = dir.entries.keep_if do |entry|
      entry =~ /char_\d+.png/
    end

    ascii_data = []
    file_names.each do |file_name|
      char = escapeChar(file_name[/\d+/].to_i.chr)
      ascii_image = ImageHelpers::loadImage("#{folder_name}/#{file_name}")
      average_greyscale = ImageHelpers::calcAverageGreyscale(ascii_image)
      ascii_data << {:char => char, :average_greyscale => average_greyscale}
    end
    ascii_data
  end

  def self.escapeChar(char)
    return '&lt' if char == '<'
    return '&gt' if char == '>'
    return '&nbsp;' if char == ' '
    char
  end

  def self.reweighAsciiAverageGreyscale!(ascii_data)
    min_average_greyscale = nil
    max_average_greyscale = nil

    ascii_data.each do |datum|
      min_average_greyscale = datum[:average_greyscale] if (min_average_greyscale.nil? or datum[:average_greyscale] < min_average_greyscale)
      max_average_greyscale = datum[:average_greyscale] if (max_average_greyscale.nil? or datum[:average_greyscale] > max_average_greyscale)
    end

    ascii_data.each do |datum|
      datum[:average_greyscale] -= min_average_greyscale
      datum[:average_greyscale] *= 255.0 / (max_average_greyscale - min_average_greyscale)
    end
  end

  def self.colorToChar(ascii_data, unique_colors)
    color_to_char = {}
    unique_colors.each do |color|
      best_diff = nil
      best_char = nil

      ascii_data.each do |datum|
        diff = (ColorHelpers::greyscale(color) - datum[:average_greyscale]).abs
        if best_diff.nil? or diff < best_diff
          best_diff = diff
          best_char = datum[:char]
        end
      end

      color_to_char[color] = best_char
      ascii_data.delete_if do |datum|
        datum[:char] == best_char
      end
    end
    color_to_char
  end

  def self.asciify(ascii_folder_name, ascii_width, ascii_height, reduced_palette_image)
    ascii_data = loadAsciiData(ascii_folder_name)
    reweighAsciiAverageGreyscale!(ascii_data)

    unique_colors = reduced_palette_image.pixels.uniq.sort {|a, b| ColorHelpers::greyscale(b) <=> ColorHelpers::greyscale(a)}
    color_to_char = colorToChar(ascii_data, unique_colors)

    image_blocks = reduced_palette_image.image_blocks(ascii_width, ascii_height)
    ascii_image = AsciiImage.new(image_blocks.width, image_blocks.height)

    for block_y in 0...image_blocks.height
      for block_x in 0...image_blocks.width
        dominant_block_color = ImageHelpers::calcDominantColor(image_blocks[block_x, block_y])
        ascii_image[block_x,block_y] = color_to_char[dominant_block_color]
      end
    end
    ascii_image
  end
end
