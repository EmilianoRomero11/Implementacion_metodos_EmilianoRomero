# Basic implementation of Finite Automatons
# Returns a list of the types and tokens identified
#
# An Automaton is defined as:
# M = (Q, \Sigma, \delta, F, q_0)
#
# Emiliano Romero López
# 2024-04-23

defmodule Parsing.TokenList do

  @doc """
  Entry frunction to evaluate a string with a given automata
  The automata argument is expressed as:
  {delta, accept, q0}
  """
  def arithmetic_lexer(string) do
    # Hardcode the automata to use for parsing
    # The list of accept states must be updates when the delta function changes
    automata = {&Parsing.TokenList.delta_arithmetic/2, [:int, :float, :var, :exp, :space, :par_close], :start}
    string
    # Split the string into a list of characters
    |> String.graphemes()
    |> eval_dfa(automata, [], [])
  end

  @doc """
  Recursive function to follow the state transitions for each of the characters in the list
  If the final state is in the accept state list, the string is accepted
  """

  def eval_dfa([], {_delta, accept, state}, tokens, temp) do
    #binding() |> IO.inspect()
    cond do
      Enum.member?(accept, state) -> Enum.reverse([{state, temp|>Enum.reverse|>Enum.join} | tokens])
      true -> false
    end
  end
  def eval_dfa([char | tail], {delta, accept, state}, tokens, temp) do
    #binding() |> IO.inspect()
    [new_state, found] = delta.(state, char)
    #Does not add spaces to the list of characters
    if char == " " do
      if found do
        temp = temp|>Enum.reverse
        eval_dfa(tail, {delta, accept, new_state}, [{found, temp|>Enum.join} | tokens], [])
      else
        eval_dfa(tail, {delta, accept, new_state}, tokens, [temp])
      end
    else
      if found do
        temp = temp|>Enum.reverse
        eval_dfa(tail, {delta, accept, new_state}, [{found, temp|>Enum.join} | tokens], [char])
      else
        eval_dfa(tail, {delta, accept, new_state}, tokens, [char | temp])
    end
  end
end

  @doc """
  Transition function to recognize valid arithmetic expressions
  Valid states are:
  - :int
  - :float
  - :exp
  - :var
  - :space
  - :par_close
  """
  def delta_arithmetic(state, char) do
    case state do
      :start -> cond do
        is_sign(char) -> [:sign, false]
        is_digit(char) -> [:int, false]
        is_alpha(char) -> [:var, false]
        char == "_" -> [:var, false]
        char == " " -> [:space, false]
        char == "(" -> [:par_open, false]
        true -> [:fail, false]
      end
      :int -> cond do
        is_digit(char) -> [:int, false]
        is_operator(char) -> [:op, :int]
        char == "e" || char == "E" -> [:fisrtExp, false]
        char == "." -> [:dot, false]
        char == " " -> [:space, :int]
        char == ")" -> [:par_close, :int]
        true -> [:fail, false]
      end
      :dot -> cond do
        is_digit(char) -> [:float, false]
        char == " " -> [:space, :float]
        true -> [:fail, false]
      end
      :float -> cond do
        is_digit(char) -> [:float, false]
        is_operator(char) -> [:op, :float]
        char == "e" || char == "E" -> [:firstExp, false]
        char == " " -> [:space, :float]
        true -> [:fail, false]
      end
      :op -> cond do
        is_sign(char) -> [:sign, :op]
        is_digit(char) -> [:int, :op]
        char == " " -> [:space, :op]
        is_alpha(char) -> [:var, :op]
        char == "(" -> [:par_open, :op]
        true -> [:fail, false]
      end
      :sign -> cond do
        is_digit(char) -> [:int, false]
        char == " " -> [:space, false]
        true -> [:fail, false]
      end
      :var -> cond do
        is_digit(char) -> [:var, false]
        is_operator(char) -> [:op, :var]
        char == "_" -> [:var, false]
        char == " " -> [:space, :var]
        is_alpha(char) -> [:var, false]
        is_sign(char) -> [:op, :var]
        true -> [:fail, false]
      end
      :space -> cond do
        char == " " -> [:space, false]
        is_digit(char) -> [:int, false]
        is_operator(char) -> [:op, false]
        is_alpha(char) -> [:var, false]
        is_sign(char) -> [:sign, false]
        char == "_" -> [:var, false]
        true -> [:fail, false]
      end
      :firstExp -> cond do
        is_sign(char) -> [:exp, :false]
        is_digit(char) -> [:exp, false]
        true -> [:fail,false]
      end
      :exp -> cond do
        is_sign(char) -> [:exp, :false]
        is_digit(char) -> [:exp, false]
        char == " " -> [:space, :exp]
        true -> [:fail,false]
      end
      :par_open -> cond do
        is_digit(char) -> [:int, :par_open]
        true -> [:fail,false]
      end
      :par_close -> cond do
        is_operator(char) -> [:op, :par_close]
        true -> [:fail, false]
      end
      :fail -> [:fail, false]
    end
  end


  @doc """
  Helper function to identify characters that represent digits
  """
  def is_digit(char) do
    "0123456789"
    |> String.graphemes()
    |> Enum.member?(char)
  end

  def is_alpha(char) do
    lowercase = ?a..?z |> Enum.map(&<<&1::utf8>>)
    uppercase = ?A..?Z |> Enum.map(&<<&1::utf8>>)
    Enum.member?(lowercase ++ uppercase, char)
  end

  @doc """
  Helper function to identify characters that represent positive or negative signs for numbers
  """
  def is_sign(char) do
    Enum.member?(["+", "-"], char)
  end

  @doc """
  Helper function to identify characters that represent arithmetic operators
  """
  def is_operator(char) do
    Enum.member?(["+", "-", "*", "/", "%", "^", "="], char)
  end
end
