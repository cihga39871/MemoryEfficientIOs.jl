# MemoryEfficientIOs.jl

*A memory-efficient read-only IO for line-by-line processing of large files.*

## Feature

The default `readline(io)` (`eachline(io)`) returns a new allocated String. It is a waste of memory allocation and garbage collection for large files.

MemoryEfficientIO wraps a normal read-only `IO` type, and `readline(io)` (`eachline(io)`) returns a `StringView`, which is a AbstractString pointing to a fixed memory location, so no additional memory allocation and garbage collection for reading files.

# Caution

Since `readline(io)` (`eachline(io)`) uses a shared memory, users need to extract the elements of interest and manually convert them to `String`. 


## Installation

MemoryEfficientIOs.jl can be installed using the Julia package manager. From the Julia REPL, type ] to enter the Pkg REPL mode and run

```julia
pkg> add MemoryEfficientIOs
```

Or using the GitHub link:
```julia
pkg> add https://github.com/cihga39871/MemoryEfficientIOs.jl
```

## Main usage

```julia
julia> using MemoryEfficientIOs

julia> file_path = "/path/to/a/large/file";

julia> meio = MemoryEfficientIO(file_path)  # establish read-only stream

julia> line = readline(meio; keep = false)
"module MemoryEfficientIOs"

julia> typeof(line)  # type of line is StringView from StringView.jl
StringView{SubArray{UInt8, 1, Vector{UInt8}, Tuple{UnitRange{Int64}}, true}}

julia> for line in eachline(meio)
            # do something
       end

julia> seekstart(meio)  # seek the stream to its beginning.
0

julia> while !eof(meio)
           line = readline(meio)
           # do something
       end

julia> close(meio)  # close stream
```

## Memory allocation comparing to IOStream

```julia
julia> using MemoryEfficientIOs

julia> file_path = "/path/to/a/large/file";

julia> meio = MemoryEfficientIO(file_path)  # establish read-only stream

julia> io = open(file_path, "r")

julia> function test_readline(io)
           for i = 1:10
               seekstart(io)
               while !eof(io)
                   readline(io)
               end
           end
       end

julia> test_readline(meio) ; test_readline(io)  # precompiling for first use

julia> @info "Time and Memory of MemoryEfficientIO: readline"

julia> @time test_readline(meio)
 15.429088 seconds (50.32 M allocations: 2.250 GiB, 2.56% gc time)

julia> @time test_readline(io)
  8.786919 seconds (50.88 M allocations: 9.849 GiB, 4.53% gc time)

```