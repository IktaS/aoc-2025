import gleam/float
import gleam/int

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub fn to_string(coord: Coordinate) -> String {
  "(" <> int.to_string(coord.x) <> ", " <> int.to_string(coord.y) <> ")"
}

pub type Coordinate3D {
  Coordinate3D(x: Int, y: Int, z: Int)
}

pub fn to_string_3d(coord: Coordinate3D) -> String {
  "("
  <> int.to_string(coord.x)
  <> ", "
  <> int.to_string(coord.y)
  <> ", "
  <> int.to_string(coord.z)
  <> ")"
}

pub fn distance_3d(coord1: Coordinate3D, coord2: Coordinate3D) {
  let dx = int.to_float(coord1.x - coord2.x)
  let dy = int.to_float(coord1.y - coord2.y)
  let dz = int.to_float(coord1.z - coord2.z)
  float.square_root(
    float.multiply(dx, dx)
    |> float.add(float.multiply(dy, dy))
    |> float.add(float.multiply(dz, dz)),
  )
}
