require './lib/ImageHelpers.rb'
require './lib/AsciiHelpers.rb'

# load image
image = ImageHelpers::loadImage('./examples/nick.png')

# reduce image to 16 colors
# using 10 iterations of the k-means clustering algorithm
# and split each iteration across 2 different processors
reduced_palette_image = ImageHelpers::calcReducedPaletteImage(image, 16, 10, 2)
reduced_palette_image.saveToFile('./examples/nick_reduced.png')

# calculate the ascii representation of this image
# using the 8 x 16 pixels images in the /ascii_data folder
ascii_image = AsciiHelpers::asciify('./ascii_data', 8, 16, reduced_palette_image)

# save ascii representation as html
ascii_image.saveToFile('./examples/nick_ascii.html')
