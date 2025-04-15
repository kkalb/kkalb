defmodule Kkalb.BikeGameControllerTest do
  use ExUnit.Case, async: true

  alias Kkalb.BikeGameController

  setup do
    :ok
  end

  test "guess/3 guessed too low" do
    target = 3
    guess = 2
    tries = 0

    assert {tries + 1, :too_low} == BikeGameController.guess(guess, target, tries)
  end

  test "guess/3 guessed too high" do
    target = 3
    guess = 4
    tries = 0

    assert {tries + 1, :too_high} == BikeGameController.guess(guess, target, tries)
  end

  test "guess/3 with matching setup" do
    target = 3
    guess = 3
    tries = 0

    assert {tries + 1, :match} == BikeGameController.guess(guess, target, tries)
  end

  test "guess/3 the proper number in three tries" do
    target = 3
    inital_guess = 1

    {1, :too_low} = BikeGameController.guess(inital_guess, target, 0)
    {2, :too_high} = BikeGameController.guess(5, target, 1)
    assert {3, :match} == BikeGameController.guess(3, target, 2)
  end
end
