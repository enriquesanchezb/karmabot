defmodule Karmabot.Parser do
  @karma_regex ~R/<@(\w+)>:?\s*(-{2,2}|\+{2,2})/

  def parse(message, my_id) do
    cond do
      message =~ ~r/^\s*<@#{my_id}>:?\s*(?:info)?\s*$/ -> :info
      message =~ ~r/^\s*<@#{my_id}>(?::?\s*|\s+)reset\s*$/ -> :reset
      true ->
        case extract_karma(message) do
          [] -> nil
          karma -> {:update, karma}
        end
    end
  end

  def extract_karma(message) do
    for [_match, user, karma] <- Regex.scan(@karma_regex, message),
        do: {user, karma_value(karma)}
  end

  defp karma_value("++"), do: 1
  defp karma_value("--"), do: -1
end