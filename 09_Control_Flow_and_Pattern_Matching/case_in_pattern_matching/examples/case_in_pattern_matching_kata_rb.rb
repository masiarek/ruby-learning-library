# Exercise 1: dispatch a list of event hashes with case/in, one pattern per
# shape, binding the fields each shape carries, with an else for the rest.

events = [
  {type: "click", x: 10, y: 20},
  {type: "key", key: "q", modifiers: ["ctrl"]},
  {type: "resize", size: [80, 24]},
  {type: "key", key: "x"},
  {type: "boom"}
]

events.each do |event|
  line = case event
         in {type: "click", x:, y:} then "click at #{x},#{y}"
         in {type: "key", key:, modifiers: [*, "ctrl", *]} then "ctrl-#{key}"
         in {type: "key", key:} then "key #{key}"
         in {type: "resize", size: [w, h]} then "resize to #{w}x#{h}"
         else "unknown event #{event[:type].inspect}"
         end
  puts line
end
