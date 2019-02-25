"""
# SPECFEMUtils

A number of utilities for seismic wave propagation simulations with SPECFEM3D_GLOBE.
"""
module SPECFEMUtils

import DelimitedFileds: readdlm

import MomentTensors: MT

struct CMTSolution
    desc::String
    name::String
    tshift::Float64
    halfdur::Float64
    lat::Float64
    lon::Float64
    dep::Float64
    mt::MT
end

"""
    read_cmtsolution(file) -> cmt::CMTSolution

Return the `CMTSolution` `cmt` contained within `file`
"""
function read_cmtsolution(file)
    lines = readlines(file)
    length(lines) >= 13 || error("Only $(length(lines)) lines in \"$file\"")
    desc = lines[1]
    name = split(lines[2])[3]
    tshift = parse(Float64, split(lines[3])[3])
    halfdur = parse(Float64, split(lines[4])[3])
    lat = parse(Float64, split(lines[5])[2])
    lon = parse(Float64, split(lines[6])[2])
    dep = parse(Float64, split(lines[7])[2])
    mt = MT(parse(Float64, split(lines[i])[2]) for i in 8:13)
    CMTSolution(desc, name, tshift, halfdur, lat, lon, dep, mt)
end

"""
    read_stations(file) -> stations

Read in a STATIONS file and return a named tuple containing vectors of the station parameters.
"""
function read_stations(file)
    d = readdlm(file)
    (sta=d[:,1], net=d[:,2], lat=d[:,3], lon=d[:,4], elev=d[:,5], dep=d[:,6])
end

end # module
