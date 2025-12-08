import gleam/int

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub fn to_string(coord: Coordinate) -> String {
  "(" <> int.to_string(coord.x) <> ", " <> int.to_string(coord.y) <> ")"
}
