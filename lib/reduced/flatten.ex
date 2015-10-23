defmodule Reduced do
  defmodule Flatten do
    def nested_keys([{key, value}]) do
      nested_keys({key, value})
    end

    def nested_keys([{key, value}|tail]) do
      List.flatten([
        nested_keys({key, value}),
        nested_keys(tail)
      ])
    end

    def nested_keys({key, [{inner_key, value}]}) do
      nested_keys({"#{key}::#{inner_key}", value})
    end

    def nested_keys({key, [{inner_key, value}|tail]}) do
      List.flatten([
        nested_keys({"#{key}::#{inner_key}", value}),
        nested_keys({key, tail})
      ])
    end

    def nested_keys({key, value}) when not is_map(value) do
      case value do
        {inner_key, inner_value} ->
          nested_keys({"#{key}::#{inner_key}", inner_value})
        _ ->
          {to_string(key), to_string(value)}
      end
    end

    def nested_keys({key, value}) when is_map(value) do
      nested_keys({key, nested_keys(value)})
    end

    def nested_keys(data) when is_map(data) do
      Map.to_list(data)
    end
  end
end
