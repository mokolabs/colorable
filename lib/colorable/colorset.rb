require "forwardable"

module Colorable
  class Colorset
    include Enumerable
    extend Forwardable

    def initialize(opt={})
      opt = { order: :name, dir: :+, colorset:nil }.merge(opt)
      @pos = 0
      @colorset = build_colorset(opt)
    end

    def_delegators :@colorset, :size, :first, :last, :to_a

    def each(&blk)
      @colorset.each(&blk)
    end

    def at(pos=0)
      @colorset[(@pos+pos)%size]
    end

    def next(n=1)
      @pos = (@pos+n)%size
      at
    end

    def prev(n=1)
      @pos = (@pos-n)%size
      at
    end

    def rewind
      @pos = 0
      at
    end
  
    def find_index(color)
      idx = @colorset.find_index { |c| c == color }
      (@pos+idx)%size if idx
    end

    def sort_by(&blk)
      self.class.new colorset: @colorset.sort_by(&blk)
    end

    def reverse
      self.class.new colorset: @colorset.reverse
    end
 
    def to_s
      "#<%s %d/%d pos='%s/%s/%s'>" % [:Colorset, @pos, size, at.name, at.rgb, at.hsb]
    end
    alias :inspect :to_s

    private
    def build_colorset(opt)
      rgb_part = [:red, :green, :blue]
      hsb_part = [:hue, :sat, :bright]

      order = opt[:order].downcase.intern

      mode =
        case order
        when :name then :NAME
        when :rgb, *rgb_part then :RGB
        when :hsb, :hsv, *hsb_part then :HSB
        else
          raise ArgumentError, "'#{opt[:order]}' is not adequate for order option."
        end

      colorset = opt[:colorset] || begin
                   COLORNAMES.map { |name, _|
                     Colorable::Color.new(name).tap {|c| c.mode = mode }
                   }
                 end

      order_cond =
        case order
        when *rgb_part
          ->color{ color.rgb.move_to_top rgb_part.index(order) }
        when *hsb_part
          ->color{ color.hsb.move_to_top hsb_part.index(order) }
        when :name, :rgb, :hsb, :hsv
          ->color{ color.send order }
        end

      case opt[:dir].intern
      when :+
        colorset.sort_by(&order_cond)
      when :-
        colorset.sort_by(&order_cond).reverse
      else
        raise ArgumentError, "Dir option must  be ':+' or ':-'."
      end
    end

  end
end