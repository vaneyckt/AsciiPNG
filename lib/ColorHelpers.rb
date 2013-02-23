module ColorHelpers
  def self.greyscale(color)
    greyscale = (color[0] + color[1] + color[2]) / 3.0
    greyscale
  end

  def self.colorDistance(color_a, color_b)
    d0 = color_b[0] - color_a[0]
    d1 = color_b[1] - color_a[1]
    d2 = color_b[2] - color_a[2]

    # sqrt not required. Distance is just used to figure out
    # which center lies closest to a given element.
    (d0 * d0) + (d1 * d1) + (d2 * d2)
  end

  def self.findBestPaletteMatch(color, palette)
    best_distance = nil
    best_palette_color = nil

    palette.each do |palette_color|
      distance = colorDistance(color, palette_color)
      if best_distance.nil? or distance < best_distance
        best_distance = distance
        best_palette_color = palette_color
      end
    end
    best_palette_color
  end

  def self.clampRgbValues(color)
    clamped = []
    clamped[0] = color[0]
    clamped[1] = color[1]
    clamped[2] = color[2]

    clamped[0] = 255 if clamped[0] > 255
    clamped[1] = 255 if clamped[1] > 255
    clamped[2] = 255 if clamped[2] > 255

    clamped[0] = 0 if clamped[0] < 0
    clamped[1] = 0 if clamped[1] < 0
    clamped[2] = 0 if clamped[2] < 0
    clamped
  end

  def self.rgbToLab(color)
    # rgb to xyz
    var_R = (color[0].to_f / 255.0)
    var_G = (color[1].to_f / 255.0)
    var_B = (color[2].to_f / 255.0)

    if (var_R > 0.04045)
      var_R = ((var_R + 0.055) / 1.055) ** 2.4
    else
      var_R = var_R / 12.92
    end

    if (var_G > 0.04045)
      var_G = ((var_G + 0.055) / 1.055) ** 2.4
    else
      var_G = var_G / 12.92
    end

    if (var_B > 0.04045)
      var_B = ((var_B + 0.055) / 1.055) ** 2.4
    else
      var_B = var_B / 12.92
    end

    var_R = var_R * 100.0
    var_G = var_G * 100.0
    var_B = var_B * 100.0

    x = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
    y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
    z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505

    # xyz to lab
    var_X = x / 95.047
    var_Y = y / 100.000
    var_Z = z / 108.883

    if (var_X > 0.008856)
      var_X = var_X ** (1.0 / 3.0)
    else
      var_X = (7.787 * var_X) + (16.0 / 116.0)
    end

    if (var_Y > 0.008856)
      var_Y = var_Y ** (1.0 / 3.0)
    else
      var_Y = (7.787 * var_Y) + (16.0 / 116.0)
    end

    if (var_Z > 0.008856)
      var_Z = var_Z ** (1.0 / 3.0)
    else
      var_Z = (7.787 * var_Z) + (16.0 / 116.0)
    end

    l = (116.0 * var_Y) - 16.0
    a = 500.0 * (var_X - var_Y)
    b = 200.0 * (var_Y - var_Z)

    [l, a, b]
  end

  def self.labToRgb(color)
    # lab to xyz
    var_Y = (color[0].to_f + 16.0) / 116.0
    var_X = (color[1].to_f / 500.0) + var_Y
    var_Z = var_Y - (color[2].to_f / 200.0)

    if ((var_Y ** 3.0) > 0.008856)
      var_Y = var_Y ** 3.0
    else
      var_Y = (var_Y - 16.0 / 116.0) / 7.787
    end

    if ((var_X ** 3.0) > 0.008856)
      var_X = var_X ** 3.0
    else
      var_X = (var_X - 16.0 / 116.0) / 7.787
    end

    if ((var_Z ** 3.0) > 0.008856)
      var_Z = var_Z ** 3.0
    else
      var_Z = (var_Z - 16.0 / 116.0) / 7.787
    end

    x = 95.047 * var_X
    y = 100.000 * var_Y
    z = 108.883 * var_Z

    # xyz to rgb
    var_X = x / 100.0
    var_Y = y / 100.0
    var_Z = z / 100.0

    var_R = var_X *  3.2406 + var_Y * -1.5372 + var_Z * -0.4986
    var_G = var_X * -0.9689 + var_Y *  1.8758 + var_Z *  0.0415
    var_B = var_X *  0.0557 + var_Y * -0.2040 + var_Z *  1.0570

    if (var_R > 0.0031308)
      var_R = 1.055 * (var_R ** (1.0 / 2.4)) - 0.055
    else
      var_R = 12.92 * var_R
    end

    if (var_G > 0.0031308)
      var_G = 1.055 * (var_G ** (1.0 / 2.4)) - 0.055
    else
      var_G = 12.92 * var_G
    end

    if (var_B > 0.0031308)
      var_B = 1.055 * (var_B ** (1.0 / 2.4 )) - 0.055
    else
      var_B = 12.92 * var_B
    end

    r = (var_R * 255.0).to_i
    g = (var_G * 255.0).to_i
    b = (var_B * 255.0).to_i

    clampRgbValues([r, g, b])
  end
end
