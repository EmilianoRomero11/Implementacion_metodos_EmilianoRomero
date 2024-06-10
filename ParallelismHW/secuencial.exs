# Code to find the sum of the prime numbers from 0 to a given number, secuential version
#
#Emiliano Romero López A01028415
#06 - 09 - 2024

defmodule Hw.Primes do

  #Function that receives the limit of the prime numbers to be added
  def sum_primes(limit) do
    do_sum_primes(limit, 0, 0)
  end

  #When the limit is passed, return the sum
  defp do_sum_primes(limit, current, sum) when current > limit do
    sum
  end

  #Check if the current number is prime and add to sum if it is
  defp do_sum_primes(limit, current, sum) do
    if is_prime(current, 2) do
      do_sum_primes(limit, current + 1, sum + current)
    else
      do_sum_primes(limit, current + 1, sum)
    end
  end

  defp is_prime(number, div) do
    cond do
      # If the number is less than 2, it is not a prime number
      number < 2 -> false

      # If the divisor squared is greater than the number,
      #there are no divisors left to check, so the number is prime
      div * div > number -> true

      # If the number is divisible by the current divisor,
      # then it is not a prime number
      rem(number, div) == 0 -> false

      #Check the next divisor
      true -> is_prime(number, div + 1)
    end
  end

end
