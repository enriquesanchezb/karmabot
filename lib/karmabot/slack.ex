defmodule Karmabot.Slack do
  use Slack
  require Logger

  def handle_connect(slack, state) do
    Logger.info "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(_message = %{type: "message", subtype: _}, _slack, state), do: {:ok, state}

  # ignore reply_to messages
  def handle_event(_message = %{type: "message", reply_to: _}, _slack, state), do: {:ok, state}

  def handle_event(message = %{type: "message"}, slack, state) do
    if not is_direct_message?(message, slack) do
      case Karmabot.Parser.parse(message.text, slack.me.id) do
        :info -> show_karma(message, slack)
        :reset -> reset_karma(message, slack)
        {:update, changes} -> update_karma(message, slack, changes)
        _ -> :ok
      end
    else
      show_karma(message, slack)
    end
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info(_, _, state), do: {:ok, state}

  defp is_direct_message?(%{channel: channel}, slack), do: Map.has_key? slack.ims, channel

  defp show_karma(%{channel: channel}, slack) do
    msg = Karmabot.Store.get |> Karmabot.Formatter.to_message
    Logger.debug("Showing karma: #{msg}")
    send_message(msg, channel, slack)
  end

  defp reset_karma(%{channel: channel}, slack) do
    Karmabot.Store.set Karmabot.Karma.empty
    Logger.debug "Reseting karma"
    send_message("Karma is gone :runner::dash:", channel, slack)
  end

  defp update_karma(%{channel: channel, user: user}, slack, changes) do
    {cheats, valid_changes} = Enum.partition(changes, &(is_cheater?(user, &1)))
    if cheats != [], do: send_message("<@#{user}>: You cannot update your own karma :middle_finger:", channel, slack)
    current_karma = Karmabot.Store.get
    new_karma = Karmabot.Karma.update(current_karma, valid_changes)
    Karmabot.Store.set new_karma

    changed_users = for {user, _} <- changes, do: user
    changed_karmas = Karmabot.Karma.get(new_karma, changed_users)

    msg = Karmabot.Formatter.to_message changed_karmas
    send_message(msg, channel, slack)
  end

  defp is_cheater?(sending_user, {user, karma}), do: sending_user == user and karma > 0
end
