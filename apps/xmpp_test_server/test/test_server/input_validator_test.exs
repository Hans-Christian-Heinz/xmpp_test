defmodule XmppTestServer.InputValidatoTest do
  use ExUnit.Case, async: true
  alias XmppTestServer.InputValidator, as: Validator

  doctest Validator

  test "validate username" do
    assert {:ok, "max.mustermann1234"} == Validator.validate("  max.mustermann1234\n", [type: :username])
    assert {:error, _} = Validator.validate("max.mustermann!", [type: :username])
    assert {:error, _} = Validator.validate("", [type: :username])
    assert {:error, _} = Validator.validate("max..mustermann", [type: :username])
  end

  test "validate pwd" do
    assert {:ok, "Test1234!"} == Validator.validate("  Test1234!\n", [type: :pwd])
    assert {:error, _} = Validator.validate("Test1234", [type: :pwd])
    assert {:error, _} = Validator.validate("Test12!", [type: :pwd])
    assert {:error, _} = Validator.validate("TestTest1", [type: :pwd])
    assert {:error, _} = Validator.validate("test1234!", [type: :pwd])
    assert {:error, _} = Validator.validate("1aS$", [type: :pwd])
    assert {:error, _} = Validator.validate("Test12345", [type: :pwd])
    assert {:error, _} = Validator.validate("test1234!!", [type: :pwd])
    assert {:error, _} = Validator.validate("Test123 4!", [type: :pwd])
  end
end
