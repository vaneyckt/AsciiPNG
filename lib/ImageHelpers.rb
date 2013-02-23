require 'oily_png'
require 'kmeans-clustering'

require './lib/Image.rb'
require './lib/ColorHelpers.rb'

module ImageHelpers
  def self.loadImage(file_name)
    chunky_image = ChunkyPNG::Image.from_file(file_name)
    image = Image.new(chunky_image.width, chunky_image.height)
    for y in 0...image.height
      for x in 0...image.width
        image[x,y] = ChunkyPNG::Color.to_truecolor_bytes(chunky_image[x,y])
      end
    end
    image
  end

  def self.calcLabImage(image)
    lab_image = Image.new(image.width, image.height)
    for y in 0...image.height
      for x in 0...image.width
        lab_image[x,y] = ColorHelpers::rgbToLab(image[x,y])
      end
    end
    lab_image
  end

  def self.calcRgbImage(image)
    rgb_image = Image.new(image.width, image.height)
    for y in 0...image.height
      for x in 0...image.width
        rgb_image[x,y] = ColorHelpers::labToRgb(image[x,y])
      end
    end
    rgb_image
  end

  def self.calcAverageGreyscale(image)
    greyscale = 0
    for y in 0...image.height
      for x in 0...image.width
        greyscale += ColorHelpers::greyscale(image[x,y])
      end
    end

    nb_pixels = image.width * image.height
    average_greyscale = greyscale / nb_pixels
    average_greyscale
  end

  def self.calcDominantColor(image)
    color_count = Hash.new(0)
    for y in 0...image.height
      for x in 0...image.width
        color_count[image[x,y]] += 1
      end
    end

    dominant_count = nil
    dominant_color = nil

    color_count.each do |color, count|
      if dominant_count.nil? or count > dominant_count
        dominant_count = count
        dominant_color = color
      end
    end
    dominant_color
  end

  def self.calcReducedPaletteImage(image, nb_colors, nb_iterations, nb_jobs)
    # specify required clustering operations
    KMeansClustering::calcSum = lambda do |elements|
      sum = [0, 0, 0]
      elements.each do |element|
        sum[0] += element[0]
        sum[1] += element[1]
        sum[2] += element[2]
      end
      sum
    end

    KMeansClustering::calcAverage = lambda do |sum, nb_elements|
      average = [0, 0]
      average[0] = sum[0] / nb_elements.to_f
      average[1] = sum[1] / nb_elements.to_f
      average[2] = sum[2] / nb_elements.to_f
      average
    end

    KMeansClustering::calcDistanceSquared = lambda do |element_a, element_b|
      ColorHelpers::colorDistance(element_a, element_b)
    end

    # calculate lab image
    lab_image = calcLabImage(image)

    # calculate initial clustering centers
    centers = lab_image.pixels.uniq.sample(nb_colors)

    # run (parallel) k-means clustering
    puts 'Iterating on palette reduction. This can take a while ...'
    final_centers = KMeansClustering::run(centers, lab_image.pixels, nb_iterations, nb_jobs)

    # calculate reduced lab image
    reduced_lab_image = Image.new(lab_image.width, lab_image.height)
    for y in 0...image.height
      for x in 0...image.width
        reduced_lab_image[x,y] = ColorHelpers::findBestPaletteMatch(lab_image[x,y], final_centers)
      end
    end

    # calculate reduced rgb image
    reduced_image = calcRgbImage(reduced_lab_image)
    reduced_image
  end
end
