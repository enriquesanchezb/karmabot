defmodule Karmabot do
  use Application

  def start(_type, _args) do
    env = Application.get_env(:karmabot, :env)

    opts = [strategy: :one_for_one, name: Karmabot.Supervisor]
    {:ok, _pid} = Supervisor.start_link(children(env), opts)
  end

  defp children(:test) do
    [{Karmabot.Store, Karmabot.Karma.empty}]
  end

  defp children(_env) do
    slack_token = Application.get_env(:karmabot, :slack_token)
    slack_spec = %{
      id: Slack.Bot,
      start: {Slack.Bot, :start_link, [Karmabot.Slack, [], slack_token]}
    }

    [
      {Karmabot.Store, Karmabot.Karma.empty},
      slack_spec,
    ]
  end
end