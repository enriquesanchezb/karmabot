defmodule Karmabot.ParserTest do
  use ExUnit.Case, async: true
  alias Karmabot.Parser, as: Parser

  @my_id "U1J28HCKC"

  test "info" do
    assert Parser.parse("<@#{@my_id}>", @my_id) == :info
    assert Parser.parse("<@#{@my_id}>:", @my_id) == :info
    assert Parser.parse("<@#{@my_id}>: ", @my_id) == :info
    assert Parser.parse("<@#{@my_id}> info", @my_id) == :info
    assert Parser.parse("<@#{@my_id}>:info", @my_id) == :info
    assert Parser.parse("<@#{@my_id}>: info", @my_id) == :info
  end

  test "reset" do
    assert Parser.parse("<@#{@my_id}> reset", @my_id) == :reset
    assert Parser.parse("<@#{@my_id}>:reset", @my_id) == :reset
    assert Parser.parse("<@#{@my_id}>: reset", @my_id) == :reset
  end

  test "update" do
    expected = {:update, [{"U174NDB8F", 1}]}
    assert Parser.parse("<@U174NDB8F>: ++", @my_id) == expected
    assert Parser.parse("<@#{@my_id}> <@U174NDB8F>: ++", @my_id) == expected
    assert Parser.parse("<@#{@my_id}>:<@U174NDB8F>: ++", @my_id) == expected
    assert Parser.parse("<@#{@my_id}>: <@U174NDB8F>: ++", @my_id) == expected
  end

  test "other message" do
    assert Parser.parse("<@#{@my_id}>: informations", @my_id) == nil
    assert Parser.parse("<@#{@my_id}>: resetting", @my_id) == nil
    assert Parser.parse("<@#{@my_id}>: <@U174NDB8F>: +", @my_id) == nil
    assert Parser.parse("<@U174NDB8F>: +", @my_id) == nil
  end

  test "message with no karma" do
    assert Parser.extract_karma("") == []
    assert Parser.extract_karma("<@U07A2APBP>: hey") == []
    assert Parser.extract_karma("<@U07A2APBP>: +--") == []
  end

  test "simple ++" do
    expected = [{"U174NDB8F", 1}]
    assert Parser.extract_karma("<@U174NDB8F>: ++") == expected
    assert Parser.extract_karma("<@U174NDB8F> ++") == expected
    assert Parser.extract_karma("<@U174NDB8F>++") == expected
  end

  test "simple --" do
    expected = [{"U174NDB8F", -1}]
    assert Parser.extract_karma("<@U174NDB8F>: --") == expected
    assert Parser.extract_karma("<@U174NDB8F> --") == expected
    assert Parser.extract_karma("<@U174NDB8F>--") == expected
  end

  test "limit very high values to 1" do
    assert Parser.extract_karma("<@U174NDB8F>: ++++++++++++++++++++++") == [{"U174NDB8F", 1}]
    assert Parser.extract_karma("<@U174NDB8F>: ----------------------") == [{"U174NDB8F", -1}]
  end

  test "multiple occurrences" do
    assert Parser.extract_karma("I'll give <@U174NDB8F>: ++ and for <@U07A2APBP>--") == [{"U174NDB8F", 1}, {"U07A2APBP", -1}]
  end
end