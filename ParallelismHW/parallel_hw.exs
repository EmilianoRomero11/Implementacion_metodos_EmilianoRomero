# Code to find the sum of the prime numbers from 0 to a given number using parallelism
#
#Emiliano Romero López A01028415
#06 - 09 - 2024

defmodule Hw.Primes do

  #Function that receives the limit of the prime numbers to be added
  def sum_primes(limit) do
    #Obtain number of available cores
    num_threads = System.schedulers_online()
    sum_primes_parallel(limit, num_threads)
  end

  #Function to calculate the intervals and launch tasks
  defp sum_primes_parallel(limit, num_threads) do

    #Obtain the interval which will determine the ranges for the tasks
    interval = limit / num_threads |> Kernel.trunc()
    mult = interval * num_threads
    #Account for the remaining numbers when it is not an exact division
    remaining = limit - mult

    #Call function to create the list of intervals
    intervals = create_interval_list(limit, interval, 1, remaining, [], 0)

    #Launch tasks, each with its corresponding range of numbers, each range is checked by the check_range function
    results =
    intervals
    |>Enum.reverse()|> Enum.map(&Task.async(fn -> check_range(&1, 0) end))
    |> Enum.map(&Task.await(&1))

    #Since the results are returned in a list, call a function to add all of them and obtain the final result
    add_results(results, 0)
  end

  #Functions to add the results
  defp add_results([], sum), do: sum

  defp add_results([head | tail], sum), do: add_results(tail, sum + head)

  #Functions to check a range of numbers
  #When the upper limit is passed, return the sum
  defp check_range({lower_limit, upper_limit}, sum) when lower_limit > upper_limit do
    sum
  end

  #Check each number in the range
  defp check_range({lower_limit, upper_limit}, sum) do
    #Call the function to check if the number is prime
    check = is_prime(lower_limit, 2)

    #Call the next iteration with the next number in the range
    cond do
      #If the number is prime, add it to the sum and procede with the next number
      check == true -> check_range({lower_limit + 1, upper_limit}, sum + lower_limit)
      #Else, procede with next number without adding
      true -> check_range({lower_limit + 1, upper_limit}, sum)
    end

  end

  #Functions to create the list of intervals
  defp create_interval_list(_limit, interval, num_threads, offset, list, start) when num_threads == 8 do
    interval_end = start + interval + offset - num_threads + 1
    [{start, interval_end} | list]
  end

  defp create_interval_list(limit, interval, num_threads, offset, [], start) do
    interval_end = start + interval
    create_interval_list(limit, interval, num_threads + 1, offset, [{start, interval_end}], interval_end+1)
  end

  defp create_interval_list(limit, interval, num_threads, offset, list, start) do
    interval_end = start + interval
    create_interval_list(limit, interval, num_threads + 1, offset, [{start, interval_end} | list], interval_end+1)
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
