defmodule XmppTestServer.InputValidator do
  @moduledoc ~S"""
  Module for input-validation.

  ## Functions
  + validate/2
  """

  @doc ~S"""
  Trims and validates the 'value' according to the 'options'.
  Available options:
  * type: :username
  * type: :pwd

  ## Examples

    iex> XmppTestServer.InputValidator.validate("   max.mustermann\n", [type: :username])
    {:ok, "max.mustermann"}

    iex> XmppTestServer.InputValidator.validate("", [type: :username])
    {:error, "The password must be a word: letters, numbers and dots (.)"}

    iex> XmppTestServer.InputValidator.validate("max_mustermann", [type: :username])
    {:error, "The password must be a word: letters, numbers and dots (.)"}

    iex> XmppTestServer.InputValidator.validate("   Test123!\n", [type: :pwd])
    {:ok, "Test123!"}

    iex> XmppTestServer.InputValidator.validate("   Tes123!\n", [type: :pwd])
    {:error, "The password must contain at least 8 characters."}

    iex> XmppTestServer.InputValidator.validate("   Test1234\n", [type: :pwd])
    {:error, "The password must contain a symbol."}

    iex> XmppTestServer.InputValidator.validate("   test1234!\n", [type: :pwd])
    {:error, "The password must contain an uppercase-letter."}

    iex> XmppTestServer.InputValidator.validate("   TEST123!\n", [type: :pwd])
    {:error, "The password must contain a lowercase-letter."}

    iex> XmppTestServer.InputValidator.validate("   Test1 23!\n", [type: :pwd])
    {:error, "The password must contain no whitespace-characters."}

  """
  def validate(value, [type: :username]) do
    with trimmed <- String.trim(value),
         {:ok, word} <- validate_help(trimmed, [regex: ~r/^[a-zA-Z0-9]+([.]?[a-zA-Z0-9]+)*$/], "The password must be a word: letters, numbers and dots (.)"),
         do: {:ok, word}
  end

  def validate(value, [type: :pwd]) do
    with trimmed <- String.trim(value),
         {:ok, valid_length} <- validate_help(trimmed, [length: 8], "The password must contain at least 8 characters."),
         {:ok, valid_number} <- validate_help(valid_length, [regex: ~r/[0-9]+/], "The password must contain a digit."),
         {:ok, valid_lower} <- validate_help(valid_number,  [regex: ~r/[a-z]+/], "The password must contain a lowercase-letter."),
         {:ok, valid_upper} <- validate_help(valid_lower,  [regex: ~r/[A-Z]+/], "The password must contain an uppercase-letter."),
         {:ok, no_whitespace} <- validate_help(valid_upper, [whitespace: false], "The password must contain no whitespace-characters."),
         {:ok, valid_pwd} <- validate_help(no_whitespace, [regex: ~r/[#\!\?&@\$%^&*\(\)]+/], "The password must contain a symbol."),
         do: {:ok, valid_pwd}
  end

  defp validate_help(value, [length: length], msg) do
    if(String.length(value) >= length) do
      {:ok, value}
    else
      {:error, msg}
    end
  end

  defp validate_help(value, [regex: r], msg) do
    if(value =~ r) do
      {:ok, value}
    else
      {:error, msg}
    end
  end

  defp validate_help(value, [whitespace: boolean], msg) do
    if(String.contains?(value, " ") == boolean) do
      {:ok, value}
    else
      {:error, msg}
    end
  end
end
