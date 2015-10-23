defmodule Reduced do
  defmodule Hierarchy do
    @interpolation_regex ~r/^(?<datadir>.*)?%{(::)?(?<interpolation_key>[a-zA-Z_-]+)}$/u

    def load(datadir, level) do
      [first|rest] = Path.split(level)
      first_path   = Path.join([datadir, first])

      case Regex.named_captures(@interpolation_regex, first_path) do
        %{"interpolation_key" => interpolation_key,
          "datadir"           => relative_datadir} ->

          Enum.map(options_for(relative_datadir), fn (option) ->
            case Enum.empty?(rest) do
              true  -> 
                case File.regular?(Path.join([relative_datadir, option])) do
                  true  -> {interpolation_key, option}
                  false -> {interpolation_key, option, options_for(first_path)}
                end

              false ->
                {
                  interpolation_key,
                  option,
                  load(Path.join([relative_datadir, option]), Path.join(rest))
                }
            end
          end)

        nil ->
          case Enum.empty?(rest) do
            true  -> options_for(first_path)
            false -> load(first_path, Path.join(rest)) 
          end
      end
    end

    def options_for(path) do
      case File.exists?(path) do
        true  -> File.ls!(path)
        false -> []
      end
    end
  end
end
