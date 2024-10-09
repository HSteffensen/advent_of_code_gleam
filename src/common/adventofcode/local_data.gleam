import gleam/result
import simplifile

pub fn local_data_folder() -> String {
  "./.local/"
}

pub fn create_local_data_folder_if_not_exists() -> Nil {
  simplifile.create_directory_all(local_data_folder()) |> result.unwrap(Nil)
}
