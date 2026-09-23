# building_a_dsl_kata_rb.rb — a menu DSL with sections, built with instance_eval.

class Menu
  Item = Data.define(:name, :price)

  def initialize = @lines = []

  def self.build(&blk) = new.tap { |menu| menu.instance_eval(&blk) }

  def section(title, &blk)
    @lines << title
    instance_eval(&blk)                                # nested block, same self
  end

  def item(name, price) = @lines << Item.new(name:, price:)

  def total = @lines.grep(Item).sum(&:price)

  def to_s
    @lines.map { |l| l.is_a?(Item) ? format("  %-8s %5.2f", l.name, l.price) : l }.join("\n")
  end
end

menu = Menu.build do
  section "Drinks" do
    item "Coffee", 3.0
    item "Tea", 2.5
  end
  section "Food" do
    item "Scone", 4.0
  end
end

puts menu
puts format("total:     %5.2f", menu.total)
