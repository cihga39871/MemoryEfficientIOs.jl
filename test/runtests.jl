
include("../src/MemoryEfficientIOs.jl")

using .MemoryEfficientIOs
using Test

file_path = joinpath(@__DIR__, "..", "src", "MemoryEfficientIOs.jl")

io = open(file_path, "r")
meio = MemoryEfficientIO(open(file_path, "r"))
seekstart(io)
seekstart(meio)

while !eof(io) && !eof(meio)
    @test readline(io) == readline(meio)
end
@test eof(io)
@test eof(meio)

## speed test
seekstart(io)
seekstart(meio)

@info "Time and Memory of IOStream: readline"
@time while !eof(io)
    readline(io)
end
@info "Time and Memory of MemoryEfficientIO: readline"
@time while !eof(io)
    readline(io)
end

# extreme small INIT_N_BYTE to check whether MemoryEfficientIO works on edge situation
seekstart(io)
seekstart(meio)

MemoryEfficientIOs.set_init_n_byte(10)

resize!(meio.a.data, 10)
resize!(meio.b.data, 10)
while !eof(io) && !eof(meio)
    @test readline(io) == readline(meio)
end
@test eof(io)
@test eof(meio)

## close io
close(meio)
close(io)
