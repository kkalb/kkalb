defmodule Kkalb.BikeGameControllerTest do
  use ExUnit.Case, async: true

  alias Kkalb.BikeGameController

  describe "guess" do
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

  describe "game_result_to_html" do
    test "game_result_to_html/3 when ind is nil" do
      assert "" == BikeGameController.game_result_to_html(nil, 0, 0)
    end

    test "game_result_to_html/3 when match created highscore or equal" do
      base_msg = "You guessed the correct number! <br />\n"

      test_cases = [
        {{0, 0}, "You tried 0 time(s) creating a new personal best."},
        {{1, 0}, "You tried 1 time(s) creating a new personal best."},
        {{1, 1}, "You tried 1 time(s), which equals the highscore of 1 tries."},
        {{2, 2}, "You tried 2 time(s), which equals the highscore of 2 tries."},
        {{1, 2}, "You tried 1 time(s), which means you bet the highscore of 2 tries."}
      ]

      for {{tries, highscore}, expected_suffix} <- test_cases do
        expected = base_msg <> expected_suffix <> "\n"
        assert BikeGameController.game_result_to_html(:match, tries, highscore) == expected
      end
    end

    test "game_result_to_html/3 when match w/o new highscore" do
      base_msg = "You guessed the correct number! <br />\n"

      test_cases = [
        {{2, 1}, "You tried 2 time(s), better luck next time beating the highscore of 1 tries."},
        {{5, 3}, "You tried 5 time(s), better luck next time beating the highscore of 3 tries."}
      ]

      for {{tries, highscore}, expected_suffix} <- test_cases do
        expected = base_msg <> expected_suffix <> "\n"
        assert BikeGameController.game_result_to_html(:match, tries, highscore) == expected
      end
    end

    test "game_result_to_html/3 when too low" do
      for tries <- [0, 1, 42, 420, 1337] do
        expected = "You guess was too low. <br /> You already tried #{tries} time(s)"
        assert BikeGameController.game_result_to_html(:too_low, tries, 0) == expected
      end
    end

    test "game_result_to_html/3 when too high" do
      for tries <- [0, 1, 42, 420, 1337] do
        expected = "You guess was too high. <br /> You already tried #{tries} time(s)"
        assert BikeGameController.game_result_to_html(:too_high, tries, 0) == expected
      end
    end
  end
end
