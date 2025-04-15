defmodule Kkalb.BikeGameController do
  @moduledoc """
  Module for all the logic that belongs to the guessing game of the bike context.
  """

  @doc """
  Calculates tries and if it was a match based on current tries, target number and guessed number.

  ## Examples

      iex> Kkalb.BikeGameController.guess("1234")
      {1, :match}

  """
  @spec guess(guessed_number :: integer(), target_number :: integer(), tries :: integer()) ::
          {tries :: integer(), indicator :: atom()}
  def guess(guessed_number, target_number, tries) when guessed_number > target_number, do: {tries + 1, :too_high}
  def guess(guessed_number, target_number, tries) when guessed_number < target_number, do: {tries + 1, :too_low}
  def guess(_guessed_number, _target_number, tries), do: {tries + 1, :match}

  @doc """
  Builds the string shown to the user based on game/guessing results.

  ## Examples

      iex> Kkalb.BikeGameController.game_result_to_html(:too_low, 1, 2)
      "You guess was too low. <br /> You already tried 1 time(s)"

  """
  @spec game_result_to_html(atom(), integer(), integer()) :: binary()
  def game_result_to_html(nil, _tries, _highscore) do
    ""
  end

  def game_result_to_html(:too_low, tries, _highscore) do
    "You guess was too low. <br /> You already tried #{tries} time(s)"
  end

  def game_result_to_html(:too_high, tries, _highscore) do
    "You guess was too high. <br /> You already tried #{tries} time(s)"
  end

  def game_result_to_html(:match, tries, 0) do
    """
    You guessed the correct number! <br />
    You tried #{tries} time(s) creating a new personal best.
    """
  end

  def game_result_to_html(:match, tries, highscore) when highscore > tries do
    """
    You guessed the correct number! <br />
    You tried #{tries} time(s), which means you bet the highscore of #{highscore} tries.
    """
  end

  def game_result_to_html(:match, tries, highscore) when highscore == tries do
    """
    You guessed the correct number! <br />
    You tried #{tries} time(s), which equals the highscore of #{highscore} tries.
    """
  end

  def game_result_to_html(:match, tries, highscore) do
    """
    You guessed the correct number! <br />
    You tried #{tries} time(s), better luck next time beating the highscore of #{highscore} tries.
    """
  end
end
