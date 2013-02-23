require 'oily_png'

class AsciiImage
  attr_reader :width
  attr_reader :height
  attr_reader :chars

  def initialize(width, height)
    @width = width
    @height = height
    @chars = []
  end

  def [](x, y)
    index = (y * @width) + x
    @chars[index]
  end

  def []=(x, y, value)
    index = (y * @width) + x
    @chars[index] = value
  end

  def saveToFile(file_name)
    file = File.open(file_name, 'w')
    file.puts('<p style="font: 10pt courier; white-space: nowrap">')

    for y in 0...@height
      for x in 0...@width
        file.print(self[x,y])
      end
      file.puts('<br>')
    end
    file.puts('</p>')
  end
end

class ImageBlocks
  attr_reader :width
  attr_reader :height
  attr_reader :blocks

  def initialize(width, height)
    @width = width
    @height = height
    @blocks = []
  end

  def [](x, y)
    index = (y * @width) + x
    @blocks[index]
  end

  def []=(x, y, value)
    index = (y * @width) + x
    @blocks[index] = value
  end
end

class Image
  attr_reader :width
  attr_reader :height
  attr_reader :pixels

  def initialize(width, height)
    @width = width
    @height = height
    @pixels = []
  end

  def [](x, y)
    index = (y * @width) + x
    @pixels[index]
  end

  def []=(x, y, value)
    index = (y * @width) + x
    @pixels[index] = value
  end

  def image_blocks(desired_block_width, desired_block_height)
    nb_blocks_x = @width / desired_block_width
    nb_blocks_y = @height / desired_block_height
    nb_blocks_x += 1 if @width % desired_block_width != 0
    nb_blocks_y += 1 if @height % desired_block_height != 0

    image_blocks = ImageBlocks.new(nb_blocks_x, nb_blocks_y)

    for block_y in 0...nb_blocks_y
      for block_x in 0...nb_blocks_x
        block_origin_x = block_x * desired_block_width
        block_origin_y = block_y * desired_block_height

        block_end_x = [block_origin_x + desired_block_width, @width].min
        block_end_y = [block_origin_y + desired_block_height, @height].min

        block_diff_x = block_end_x - block_origin_x
        block_diff_y = block_end_y - block_origin_y

        block = Image.new(block_diff_x, block_diff_y)
        for y in 0...block_diff_y
          for x in 0...block_diff_x
            block[x,y] = self[block_origin_x + x, block_origin_y + y]
          end
        end
        image_blocks[block_x,block_y] = block
      end
    end
    image_blocks
  end

  def saveToFile(file_name)
    canvas = ChunkyPNG::Canvas.new(@width, @height)
    for y in 0...@height
      for x in 0...@width
        canvas[x,y] = ChunkyPNG::Color.rgb(self[x,y][0], self[x,y][1], self[x,y][2])
      end
    end
    canvas.to_image.save(file_name)
  end
end
