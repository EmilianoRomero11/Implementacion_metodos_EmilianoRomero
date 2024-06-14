# Evidence: syntax highlighter
#
# Program to process text files containing python code and convert them into HTML.
# Color highlighting is done using a css file.
#
# Emiliano Romero López A01028415
# 2024-05-24

defmodule Syntax_highlighter do

  @doc """
  Function to process all the lines found in a text file and convert them into an HTML file.
  Will scan every line individually.
  Arguments:
  - path : the location of the folder containing the files
  - in_filename : the name of the file to read
  Returns:
  - :ok
  - As a side effect, a new file is created. The new file's name will be the same as the input's, but in an HTML file.
  """

  def write_file(path, in_filename) do

    #Regex to match with the input file name, up until the dot
    new = List.flatten(Regex.scan(~r/\w+\./, in_filename))|>hd()
    #New file name will add the html extension to the name
    out_filename = new <> "html"
    {:ok, out_filename} = File.open(out_filename, [:write])
    #Header for the HTML file
    header = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="python_css.css">
    </head>
    <body>
    <pre>

    """
    #Write header into the HTML
    IO.puts(out_filename, header)
    #Open file and read each line individually
    lines = File.stream!(path<>"/"<>in_filename)
    #Analyze each line to match with regular expressions
    Enum.map(lines, &do_analyze_line(&1, [], out_filename))
    #Ending of the HTML file
    ending = """
    <pre>
    </body>
    </html>
    """
    #Write ending into HTML file
    IO.puts(out_filename, ending)
    #Close HTML file
    File.close(out_filename)
  end

  #Call the function to write HTML after the line is empty, meaning it has been analyzed, and the tokens have been stored in a list
  defp do_analyze_line("", tokens, out_filename), do: write_html(tokens|>Enum.reverse, "", out_filename)


  #Function to process each line individually, each time a token is matched and stored, the function is called again without the #processed token
  #Arguments:
  #- line : a line from the original text file
  #- tokens : empty list at first, contains the tuples of tokens and their type
  #- out_filename : name of the HTML file
  #Returns:
  #- Recursive call of itself until the line has been completely processed


  defp do_analyze_line(line, tokens, out_filename) do
    #Assign a value to the token depending on the match made. Regex.match? only confirms that it is the correct match by returning a boolean, if true, Regex.match extracts the token and puts it in a list
    token =
      cond do
        Regex.match?(~r/^\s+/, line) -> Regex.scan(~r/^\s+/, line)
        Regex.match?(~r/^\b[a-zA-Z_][a-zA-Z0-9_]*\b/, line) -> Regex.scan(~r/^\b[a-zA-Z_][a-zA-Z0-9_]*\b/, line)
        Regex.match?(~r/^\b\w+(?=\s*\()/, line) -> Regex.scan(~r/^\b\w+(?=\s*\()/, line)
        Regex.match?(~r/^\b__\w+__\b/, line) -> Regex.scan(~r/^\b__\w+__\b/, line)
        Regex.match?(~r/^\b(?:and|as|assert|async|await|break|class|continue|def|del|elif|else|except|False|finally|for|from|global|if|import|in|is|lambda|None|nonlocal|not|or|pass|raise|return|True|try|while|with|yield)\b/, line) -> Regex.scan(~r/^\b(?:and|as|assert|async|await|break|class|continue|def|del|elif|else|except|False|finally|for|from|global|if|import|in|is|lambda|None|nonlocal|not|or|pass|raise|return|True|try|while|with|yield)\b/, line)
        Regex.match?(~r/^[-+*\/%=<>!&|^~]+/, line) -> Regex.scan(~r/^[-+*\/%=<>!&|^~]+/, line)
        Regex.match?(~r/^[-+]?\b\d+\.?\d*\b/, line) -> Regex.scan(~r/^[-+]?\b\d+\.?\d*\b/, line)
        Regex.match?(~r/^#.*?$/, line) -> Regex.scan(~r/^#.*?$/, line)
        Regex.match?(~r/^[()\[\]{}:;.,\\]/, line) -> Regex.scan(~r/^[()\[\]{}:;.,\\]/, line)
        Regex.match?(~r/^(\'\'\'[\s\S]*?\'\'\'|"""[\s\S]*?"""|\'[^\n\']*\'|"[^\n"]*")/, line) -> Regex.scan(~r/^(\'\'\'[\s\S]*?\'\'\'|"""[\s\S]*?"""|\'[^\n\']*\'|"[^\n"]*")/, line)
      end
    #Assign a value to the token type depending on the match made by Regex.match?
    type =
      cond do
        Regex.match?(~r/^\s+/, line) -> :whitespace
        Regex.match?(~r/^\b(?:and|as|assert|async|await|break|class|continue|def|del|elif|else|except|False|finally|for|from|global|if|import|in|is|lambda|None|nonlocal|not|or|pass|raise|return|True|try|while|with|yield)\b/, line) -> :reserved
        Regex.match?(~r/^\b\w+(?=\s*\()/, line) -> :function
        Regex.match?(~r/^\b__\w+__\b/, line) -> :magic
        Regex.match?(~r/^\b[a-zA-Z_][a-zA-Z0-9_]*\b/, line) -> :variable
        Regex.match?(~r/^[-+*\/%=<>!&|^~]+/, line) -> :operator
        Regex.match?(~r/^[-+]?\b\d+\.?\d*\b/, line) -> :number
        Regex.match?(~r/^#.*?$/, line) -> :comment
        Regex.match?(~r/^[()\[\]{}:;.,\\]/, line) -> :punctuation
        Regex.match?(~r/^(\'\'\'[\s\S]*?\'\'\'|"""[\s\S]*?"""|\'[^\n\']*\'|"[^\n"]*")/, line) -> :string
      end
    #Extract the string from the list created by the Regex.scan function
    tokenList = token|>List.flatten
    tokenString = hd(tokenList)
    #Count the length of the token and use it to split the line in two at that point
    length = String.length(tokenString)
    String.split_at(line, length)
    {token, newLine} = String.split_at(line, length)
    #Store the token and its type in a tuple, call the function again with the rest of the line
    do_analyze_line(newLine, [{token, type} | tokens], out_filename)
  end

  #Function to write the HTML line into the HTML file when all the tokens have been processed
  defp write_html([], html, out_filename), do: IO.puts(out_filename, html)


  #Function to inject the token and its type into HTML code
  #Arguments:
  #- tokens : empty list at first, contains the tuples of tokens and their type
  #- html : string containing the resulting html code line for each line in the text file
  #- out_filename : name of the HTML file
  #Returns:
  #- Recursive call of itself until the line has been completely processed

  defp write_html([{token, type} | tokens], html, out_filename) do
    #Choose which kind of line to write depending on the type of token found, then inject the token into it
    newHTML =
    case type do
      :whitespace -> html <>"#{token}"
      :variable -> html <>"<span class= variable >#{token}</span>"
      :reserved -> html <>"<span class= reserved >#{token}</span>"
      :operator -> html <>"<span class= operator >#{token}</span>"
      :number -> html <>"<span class= number >#{token}</span>"
      :string -> html <>"<span class= string >#{token}</span>"
      :comment -> html <>"<span class= comment >#{token}</span>"
      :punctuation -> html <>"<span class= punctuation >#{token}</span>"
      :magic -> html <>"<span class= magic >#{token}</span>"
      :function -> html <>"<span class= function >#{token}</span>"
    end
    #Call the function again with the rest of the tokens and the updated HTML line
    write_html(tokens, newHTML, out_filename)
  end

  #Obtain the list of files in the folder and call the funtions for each of them one after the other
  def run_sequential(path) do
    {:ok, files} =
    case File.ls(path) do
      {:ok, files} -> {:ok, files}
      {:error, error} -> {:error, "Error: #{error}"}
    end
    files|>Enum.map(&write_file(path,&1))
  end

  #Call the timer function with the function to start the program to obtain the execution time
  def time_sequential(path) do
    {time, _result} = :timer.tc(fn -> run_sequential(path) end)
    IO.inspect(time/1000000)
  end
end

[path] = System.argv()
Syntax_highlighter.time_sequential(path)
