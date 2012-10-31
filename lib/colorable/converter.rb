module Colorable::Converter
  class NoNameError < StandardError; end
  
  def name2rgb(name)
    COLORNAMES.assoc(name)[1]
  rescue
    raise NoNameError, "'#{name}' not exist"
  end

  def rgb2name(rgb)
    validate_rgb(rgb)
    COLORNAMES.rassoc(rgb).tap { |c, rgb| break c if c }
  end

  def rgb2hsb(rgb)
    validate_rgb(rgb)
    r, g, b = rgb.map(&:to_f)
    hue = Math.atan2(Math.sqrt(3)*(g-b), 2*r-g-b).to_degree

    min, max = [r, g, b].minmax
    sat = [min, max].all?(&:zero?) ? 0.0 : ((max - min) / max * 100)

    bright = max / 2.55
    [hue, sat, bright].map(&:round)
  end
  alias :rgb2hsv :rgb2hsb

  class NotImplemented < StandardError; end
  def rgb2hsl(rgb)
    validate_rgb(rgb)
    raise NotImplemented, 'Not Implemented Yet'
    r, g, b = rgb.map(&:to_f)
    hue = Math.atan2(Math.sqrt(3)*(g-b), 2*r-g-b).to_degree

    min, max = [r, g, b].minmax
    sat = [min, max].all?(&:zero?) ? 0.0 : ((max - min) / (1-(max+min-1).abs) * 100)

    lum = 0.298912*r + 0.586611*g + 0.114478*b
    [hue, sat, lum].map(&:round)
  end

  def hsb2rgb(hsb)
    validate_hsb(hsb)
    hue, sat, bright = hsb
    norm = ->range{ hue.norm(range, 0..255) }
    rgb_h =
      case hue
      when 0..60    then [255, norm[0..60], 0]
      when 60..120  then [255-norm[60..120], 255, 0]
      when 120..180 then [0, 255, norm[120..180]]
      when 180..240 then [0, 255-norm[180..240], 255]
      when 240..300 then [norm[240..300], 0, 255]
      when 300..360 then [255, 0, 255-norm[300.360]]
      end
    rgb_s = rgb_h.map { |val| val + (255-val) * (1-sat/100.0) }
    rgb_s.map { |val| (val * bright/100.0).round }
  end
  alias :hsv2rgb :hsb2rgb

  def rgb2hex(rgb)
    validate_rgb(rgb)
    hex = rgb.map do |val|
      val.to_s(16).tap { |h| break "0#{h}" if h.size==1 }
    end
    '#' + hex.join.upcase
  end

  def hex2rgb(hex)
    validate_hex(hex)
    _, *hex = hex.unpack('A1A2A2A2')
    hex.map { |val| val.to_i(16) }
  end
  
  private
  def validate_rgb(rgb)
    if rgb.all? { |val| val.between?(0, 255) }
      rgb
    else
      raise ArgumentError, "'#{rgb}' is invalid for a RGB value"
    end
  end

  def validate_hsb(hsb)
    h, *sb = hsb
    if h.between?(0, 360) && sb.all? { |val| val.between?(0, 100) } 
      hsb
    else
      raise ArgumentError, "'#{hsb}' is invalid for a HSB value"
    end
  end
  
  def validate_hex(hex)
    if hex.match(/^#[0-9A-F]{6}$/i)
      hex.upcase
    else
      raise ArgumentError, "'#{hex}' is invalid for a HEX value"
    end
  end
  
  # Based on X11 color names - Wikipedia, the free encyclopedia
  # http://en.wikipedia.org/wiki/X11_color_names
  # When W3C color conflict with X11, a name of the color is appended with '2'.
  COLORNAMES = [["Alice Blue", [240, 248, 255]], ["Antique White", [250, 235, 215]], ["Aqua", [0, 255, 255]], ["Aquamarine", [127, 255, 212]], ["Azure", [240, 255, 255]], ["Beige", [245, 245, 220]], ["Bisque", [255, 228, 196]], ["Black", [0, 0, 0]], ["Blanched Almond", [255, 235, 205]], ["Blue", [0, 0, 255]], ["Blue Violet", [138, 43, 226]], ["Brown", [165, 42, 42]], ["Burlywood", [222, 184, 135]], ["Cadet Blue", [95, 158, 160]], ["Chartreuse", [127, 255, 0]], ["Chocolate", [210, 105, 30]], ["Coral", [255, 127, 80]], ["Cornflower", [100, 149, 237]], ["Cornsilk", [255, 248, 220]], ["Crimson", [220, 20, 60]], ["Cyan", [0, 255, 255]], ["Dark Blue", [0, 0, 139]], ["Dark Cyan", [0, 139, 139]], ["Dark Goldenrod", [184, 134, 11]], ["Dark Gray", [169, 169, 169]], ["Dark Green", [0, 100, 0]], ["Dark Khaki", [189, 183, 107]], ["Dark Magenta", [139, 0, 139]], ["Dark Olive Green", [85, 107, 47]], ["Dark Orange", [255, 140, 0]], ["Dark Orchid", [153, 50, 204]], ["Dark Red", [139, 0, 0]], ["Dark Salmon", [233, 150, 122]], ["Dark Sea Green", [143, 188, 143]], ["Dark Slate Blue", [72, 61, 139]], ["Dark Slate Gray", [47, 79, 79]], ["Dark Turquoise", [0, 206, 209]], ["Dark Violet", [148, 0, 211]], ["Deep Pink", [255, 20, 147]], ["Deep Sky Blue", [0, 191, 255]], ["Dim Gray", [105, 105, 105]], ["Dodger Blue", [30, 144, 255]], ["Firebrick", [178, 34, 34]], ["Floral White", [255, 250, 240]], ["Forest Green", [34, 139, 34]], ["Fuchsia", [255, 0, 255]], ["Gainsboro", [220, 220, 220]], ["Ghost White", [248, 248, 255]], ["Gold", [255, 215, 0]], ["Goldenrod", [218, 165, 32]], ["Gray", [190, 190, 190]], ["Gray2", [128, 128, 128]], ["Green", [0, 255, 0]], ["Green Yellow", [173, 255, 47]], ["Green2", [0, 128, 0]], ["Honeydew", [240, 255, 240]], ["Hot Pink", [255, 105, 180]], ["Indian Red", [205, 92, 92]], ["Indigo", [75, 0, 130]], ["Ivory", [255, 255, 240]], ["Khaki", [240, 230, 140]], ["Lavender", [230, 230, 250]], ["Lavender Blush", [255, 240, 245]], ["Lawn Green", [124, 252, 0]], ["Lemon Chiffon", [255, 250, 205]], ["Light Blue", [173, 216, 230]], ["Light Coral", [240, 128, 128]], ["Light Cyan", [224, 255, 255]], ["Light Goldenrod", [250, 250, 210]], ["Light Gray", [211, 211, 211]], ["Light Green", [144, 238, 144]], ["Light Pink", [255, 182, 193]], ["Light Salmon", [255, 160, 122]], ["Light Sea Green", [32, 178, 170]], ["Light Sky Blue", [135, 206, 250]], ["Light Slate Gray", [119, 136, 153]], ["Light Steel Blue", [176, 196, 222]], ["Light Yellow", [255, 255, 224]], ["Lime", [0, 255, 0]], ["Lime Green", [50, 205, 50]], ["Linen", [250, 240, 230]], ["Magenta", [255, 0, 255]], ["Maroon", [176, 48, 96]], ["Maroon2", [127, 0, 0]], ["Medium Aquamarine", [102, 205, 170]], ["Medium Blue", [0, 0, 205]], ["Medium Orchid", [186, 85, 211]], ["Medium Purple", [147, 112, 219]], ["Medium Sea Green", [60, 179, 113]], ["Medium Slate Blue", [123, 104, 238]], ["Medium Spring Green", [0, 250, 154]], ["Medium Turquoise", [72, 209, 204]], ["Medium Violet Red", [199, 21, 133]], ["Midnight Blue", [25, 25, 112]], ["Mint Cream", [245, 255, 250]], ["Misty Rose", [255, 228, 225]], ["Moccasin", [255, 228, 181]], ["Navajo White", [255, 222, 173]], ["Navy", [0, 0, 128]], ["Old Lace", [253, 245, 230]], ["Olive", [128, 128, 0]], ["Olive Drab", [107, 142, 35]], ["Orange", [255, 165, 0]], ["Orange Red", [255, 69, 0]], ["Orchid", [218, 112, 214]], ["Pale Goldenrod", [238, 232, 170]], ["Pale Green", [152, 251, 152]], ["Pale Turquoise", [175, 238, 238]], ["Pale Violet Red", [219, 112, 147]], ["Papaya Whip", [255, 239, 213]], ["Peach Puff", [255, 218, 185]], ["Peru", [205, 133, 63]], ["Pink", [255, 192, 203]], ["Plum", [221, 160, 221]], ["Powder Blue", [176, 224, 230]], ["Purple", [160, 32, 240]], ["Purple2", [127, 0, 127]], ["Red", [255, 0, 0]], ["Rosy Brown", [188, 143, 143]], ["Royal Blue", [65, 105, 225]], ["Saddle Brown", [139, 69, 19]], ["Salmon", [250, 128, 114]], ["Sandy Brown", [244, 164, 96]], ["Sea Green", [46, 139, 87]], ["Seashell", [255, 245, 238]], ["Sienna", [160, 82, 45]], ["Silver", [192, 192, 192]], ["Sky Blue", [135, 206, 235]], ["Slate Blue", [106, 90, 205]], ["Slate Gray", [112, 128, 144]], ["Snow", [255, 250, 250]], ["Spring Green", [0, 255, 127]], ["Steel Blue", [70, 130, 180]], ["Tan", [210, 180, 140]], ["Teal", [0, 128, 128]], ["Thistle", [216, 191, 216]], ["Tomato", [255, 99, 71]], ["Turquoise", [64, 224, 208]], ["Violet", [238, 130, 238]], ["Wheat", [245, 222, 179]], ["White", [255, 255, 255]], ["White Smoke", [245, 245, 245]], ["Yellow", [255, 255, 0]], ["Yellow Green", [154, 205, 50]]]

end