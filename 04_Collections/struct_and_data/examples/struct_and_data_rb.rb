# Struct is a mutable record built positionally or by keyword; Data is an
# immutable one with `with`. Both compare by value and both pattern-match.
# The Python twin (struct_and_data_py.py) prints the same numbered rows.

def row(n, label, value)
  printf("%2d. %-68s %s\n", n, label, value)
end

def raises(klass)
  yield
  "no error"
rescue klass => e
  "#{e.class}: #{e.message}"
end

Point = Struct.new(:x, :y)
row 1,  "Struct.new(:x, :y): Point.new(1, 2), Point.new(x: 1, y: 2)",        [Point.new(1, 2), Point.new(x: 1, y: 2)].inspect
row 2,  "Point.new(1)  (a missing member is nil); Point.new(1, 2, 3)",        "#{Point.new(1).inspect}; #{raises(ArgumentError) { Point.new(1, 2, 3) }}"
pt = Point.new(1, 2)
pt.x = 5
pt[:y] = 6
row 3,  "pt.x = 5; pt[:y] = 6  (mutable); then pt, pt[0]",                   "#{pt.inspect}, #{pt[0]}"
row 4,  "Point.new(1, 2) == / eql? / hash ==; as a Hash key",                 [Point.new(1, 2) == Point.new(1, 2), Point.new(1, 2).eql?(Point.new(1, 2)), Point.new(1, 2).hash == Point.new(1, 2).hash, {Point.new(1, 2) => :key}[Point.new(1, 2)]].inspect
row 5,  "pt.to_a, Point.members, pt.to_h",                                    [pt.to_a, Point.members, pt.to_h].inspect
row 6,  "Struct.new(:x).new(1) == Struct.new(:x).new(1)  (two classes)",      (Struct.new(:x).new(1) == Struct.new(:x).new(1)).inspect
matched = []
case Point.new(1, 2)
in [x, y]
  matched << "in [x, y] -> #{x},#{y}"
end
case Point.new(1, 2)
in {x:, y:}
  matched << "in {x:, y:} -> #{x},#{y}"
end
row 7,  "case Point.new(1, 2) in [x, y]; in {x:, y:}  (both match)",          matched.inspect
Rect = Struct.new(:w, :h) { def area = w * h }
row 8,  "Struct.new(:w, :h) { def area = w * h }.new(2, 3).area",             Rect.new(2, 3).area
KW = Struct.new(:x, :y, keyword_init: true)
row 9,  "Struct.new(:x, :y, keyword_init: true).new(1, 2)",                    raises(ArgumentError) { KW.new(1, 2) }

Coord = Data.define(:lat, :lng)
c = Coord.new(1, 2)
row 10, "Data.define(:lat, :lng): Coord.new(1, 2), Coord.new(lat: 1, lng: 2)", [c, Coord.new(lat: 1, lng: 2)].inspect
row 11, "Coord.new(1); Coord.new(1, 2, 3); Coord.new(lat: 1, lng: 2, alt: 3)", [raises(ArgumentError) { Coord.new(1) }, raises(ArgumentError) { Coord.new(1, 2, 3) }, raises(ArgumentError) { Coord.new(lat: 1, lng: 2, alt: 3) }].join("; ")
row 12, "c.lat = 5  (no setter)",                                             raises(NoMethodError) { c.lat = 5 }
row 13, "c.instance_variable_set(:@lat, 5); c.frozen?",                       "#{raises(FrozenError) { c.instance_variable_set(:@lat, 5) }}; #{c.frozen?}"
row 14, "c.with(lat: 9), then c",                                             [c.with(lat: 9), c].inspect
row 15, "c == Coord.new(1, 2), eql?, hash ==; as a Hash key",                 [c == Coord.new(1, 2), c.eql?(Coord.new(1, 2)), c.hash == Coord.new(1, 2).hash, {c => :key}[Coord.new(1, 2)]].inspect
row 16, "c.respond_to?(:to_a), (:each), (:deconstruct); Enumerable?; c.to_h",  [c.respond_to?(:to_a), c.respond_to?(:each), c.respond_to?(:deconstruct), Coord.include?(Enumerable), c.to_h].inspect
matched = []
begin
  case c
  in [lat, lng]
    matched << "in [lat, lng] matched"
  end
rescue NoMatchingPatternError => e
  matched << "in [lat, lng] -> #{e.class}"
end
case c
in {lat:, lng:}
  matched << "in {lat:, lng:} -> #{lat},#{lng}"
end
case c
in Coord(lat:, lng:)
  matched << "in Coord(lat:, lng:) -> #{lat},#{lng}"
end
row 17, "case c in [lat, lng]; in {lat:, lng:}; in Coord(lat:, lng:)",        matched.inspect
Temp = Data.define(:deg) do
  def initialize(deg:) = super(deg: Float(deg))
end
row 18, 'Temp.new("35").deg, Temp.new(deg: 12).deg  (initialize normalises)', [Temp.new("35").deg, Temp.new(deg: 12).deg].inspect
row 19, "Coord.new(lat: [1], lng: 2).lat << 2  (immutability is shallow)",    (Coord.new(lat: [1], lng: 2).lat << 2).inspect
