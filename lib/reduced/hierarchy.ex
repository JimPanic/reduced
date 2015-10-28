require IEx

defmodule Reduced.Hierarchy do
  @interpolation_regex ~r/^(?<datadir>.*)?%{(::)?(?<interpolation_key>[a-zA-Z_-]+)}$/u

  def load(datadir, level) do
    [first|rest] = Path.split(level)
    first_path   = Path.join([datadir, first])

    interpolate_or_recurse(first_path, rest, Regex.named_captures(@interpolation_regex, first_path))
  end

  def interpolate_or_recurse(first_path, rest, nil) do
    load(first_path, Path.join(rest))
  end

  def interpolate_or_recurse(first_path, [], nil) do
    options_for(first_path)
  end

  def interpolate_or_recurse(first_path, rest, %{"interpolation_key" => interpolation_key, "datadir" => relative_datadir}) do
    Enum.map(options_for(relative_datadir), &(interpolate(first_path, Path.join([relative_datadir, &1]), interpolation_key, &1, rest)))
  end

  def interpolate(first_path, option_path, interpolation_key, option, []) do
    interpolated_tuple(first_path, interpolation_key, option, {:is_regular_file, File.regular?(option_path)})
  end

  def interpolate(_, option_path, interpolation_key, option, level_parts) do
    {interpolation_key, option, load(option_path, Path.join(level_parts))}
  end

  def interpolated_tuple(_, interpolation_key, option, {:is_regular_file, true}) do
    {interpolation_key, option}
  end

  def interpolated_tuple(path, interpolation_key, option, {:is_regular_file, false}) do
    {interpolation_key, option, options_for(path)}
  end

  def options_for(path) do
    options_for(path, {:file_exists, File.exists?(path)})
  end

  def options_for(path, {:file_exists, true}) do
    case File.ls(path) do
      {:ok, files}   ->
        files
      {:error, reason} -> [] # TODO: Log the reason
    end
  end

  def options_for(path, {:file_exists, false}) do
    []
  end
end
