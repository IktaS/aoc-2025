import coord
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

fn parse_input(input: String) {
  let values = input |> string.split(",") |> list.map(int.parse)
  case values {
    [x, y, z] -> {
      use x <- result.try(x)
      use y <- result.try(y)
      use z <- result.try(z)
      Ok(coord.Coordinate3D(x, y, z))
    }
    _ -> {
      // Handle invalid input
      Error(Nil)
    }
  }
}

pub fn find_circuit(
  d: List(dict.Dict(coord.Coordinate3D, Bool)),
  c: coord.Coordinate3D,
) {
  let v =
    d
    |> list.find(fn(a) {
      case dict.get(a, c) {
        Ok(_) -> True
        Error(_) -> False
      }
    })
  case v {
    Ok(a) -> a
    Error(_) -> dict.new() |> dict.insert(c, True)
  }
}

fn print_circuits(circuits: List(dict.Dict(coord.Coordinate3D, Bool))) {
  circuits
  |> list.each(fn(circuit) {
    dict.keys(circuit)
    |> list.fold("", fn(acc, c) { acc <> coord.to_string_3d(c) <> "-" })
    |> echo
  })
}

pub fn drop_circuit(
  d: List(dict.Dict(coord.Coordinate3D, Bool)),
  c: coord.Coordinate3D,
) {
  d
  |> list.filter(fn(a) {
    case dict.get(a, c) {
      Ok(_) -> False
      Error(_) -> True
    }
  })
}

fn dict_length(d: dict.Dict(coord.Coordinate3D, Bool)) {
  dict.keys(d) |> list.length
}

pub fn day8_p1() {
  let assert Ok(input) = file.read(from: "./input/day8.txt")
  let input_str = string.split(input, on: "\n")
  // drop last empty string
  let cleaned_input = list.reverse(input_str) |> list.drop(1) |> list.reverse
  use coords <- result.try(
    cleaned_input
    |> list.map(parse_input)
    |> result.all,
  )
  use distance_list <- result.try(
    coords
    |> list.combination_pairs
    |> list.try_map(fn(p) {
      let #(a, b) = p
      use distance <- result.try(coord.distance_3d(a, b))
      Ok(#(p, distance))
    }),
  )
  let distance_list =
    distance_list
    |> list.sort(fn(a, b) {
      let distance_a = a.1
      let distance_b = b.1
      float.compare(distance_a, distance_b)
    })

  let shortened_distance_list =
    distance_list
    |> list.take(1000)

  let circuits =
    shortened_distance_list
    |> list.try_fold([], fn(acc, item) {
      let #(pair, _) = item
      let #(a, b) = pair

      let circuit_a = find_circuit(acc, a)
      let new_circuit_list = drop_circuit(acc, a)

      // echo "Current list after a"
      // echo print_circuits(new_circuit_list)

      let circuit_b = find_circuit(new_circuit_list, b)
      let new_circuit_list = drop_circuit(new_circuit_list, b)

      // echo "Current list after b"
      // echo print_circuits(new_circuit_list)

      let new_d = dict.merge(circuit_a, circuit_b)
      let new_circuit_list = list.append(new_circuit_list, [new_d])

      // echo "Current list after merge"
      // echo print_circuits(new_circuit_list)

      Ok(new_circuit_list)
    })
  use circuits <- result.try(circuits)

  circuits
  |> list.sort(fn(c_a, c_b) { int.compare(dict_length(c_a), dict_length(c_b)) })
  |> list.reverse
  |> list.take(3)
  |> echo
  |> list.fold(1, fn(acc, circuit) {
    let length = dict_length(circuit)
    acc * length
  })
  |> Ok
}

pub fn day8_p2() {
  let assert Ok(input) = file.read(from: "./input/day8.txt")
  let input_str = string.split(input, on: "\n")
  // drop last empty string
  let cleaned_input = list.reverse(input_str) |> list.drop(1) |> list.reverse
  use coords <- result.try(
    cleaned_input
    |> list.map(parse_input)
    |> result.all,
  )
  use distance_list <- result.try(
    coords
    |> list.combination_pairs
    |> list.try_map(fn(p) {
      let #(a, b) = p
      use distance <- result.try(coord.distance_3d(a, b))
      Ok(#(p, distance))
    }),
  )
  let distance_list =
    distance_list
    |> list.sort(fn(a, b) {
      let distance_a = a.1
      let distance_b = b.1
      float.compare(distance_a, distance_b)
    })

  let circuits =
    distance_list
    |> list.try_fold(#([], 0, 0), fn(acc, item) {
      let #(acc, x_a, x_b) = acc
      let #(pair, _) = item
      let #(a, b) = pair

      let circuit_a = find_circuit(acc, a)

      // echo "Current list after a"
      // echo print_circuits(new_circuit_list)

      // if circuit_a has b, no need to connect
      case dict.has_key(circuit_a, b) {
        True -> Ok(#(acc, x_a, x_b))
        False -> {
          let new_circuit_list = drop_circuit(acc, a)

          let circuit_b = find_circuit(new_circuit_list, b)
          let new_circuit_list = drop_circuit(new_circuit_list, b)

          let new_d = dict.merge(circuit_a, circuit_b)
          let new_circuit_list = list.append(new_circuit_list, [new_d])

          Ok(#(new_circuit_list, a.x, b.x))
        }
      }
    })
  use circuits <- result.try(circuits)

  Ok(circuits.1 * circuits.2)
}
