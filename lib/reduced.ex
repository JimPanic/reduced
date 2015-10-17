defmodule Reduced do
  def load(file) do
    :yamerl_constr.file(file)
  end


  def flatten_nested_keys([{key, value}]) do
    flatten_nested_keys({key, value})
  end

  def flatten_nested_keys([{key, value}|tail]) do
    List.flatten([
      flatten_nested_keys({key, value}),
      flatten_nested_keys(tail)
    ])
  end

  def flatten_nested_keys({key, [{inner_key, value}]}) do
    flatten_nested_keys({"#{key}::#{inner_key}", value})
  end

  def flatten_nested_keys({key, [{inner_key, value}|tail]}) do
    List.flatten([
      flatten_nested_keys({"#{key}::#{inner_key}", value}),
      flatten_nested_keys({key, tail})
    ])
  end

  def flatten_nested_keys({key, value}) when not is_map(value) do
    case value do
      {inner_key, inner_value} ->
        flatten_nested_keys({"#{key}::#{inner_key}", inner_value})
      _ ->
        {to_string(key), to_string(value)}
    end
  end

  def flatten_nested_keys({key, value}) when is_map(value) do
    flatten_nested_keys({key, flatten_nested_keys(value)})
  end

  def flatten_nested_keys(data) when is_map(data) do
    Map.to_list(data)
  end
end
