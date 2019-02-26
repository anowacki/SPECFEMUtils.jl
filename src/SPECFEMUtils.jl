"""
# SPECFEMUtils

A number of utilities for dealing with seismic wave propagation simulations
with the SPECFEM3D_GLOBE software.
"""
module SPECFEMUtils

import DelimitedFiles: readdlm, writedlm
import Printf

import DataStructures

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
    mt = MT([parse(Float64, split(lines[i])[2]) for i in 8:13])
    CMTSolution(desc, name, tshift, halfdur, lat, lon, dep, mt)
end

"""
    write_cmtsolution(file, cmt)
    
Write a `CMTSolution` structure `cmt` to file in SPECFEM CMTSOLUTION format.
"""
function write_cmtsolution(file, cmt)
    open(file, "w") do f
        println(f, cmt.desc)
        println(f, "event name:     ", cmt.name)
        println(f, "time shift:     ", cmt.tshift)
        println(f, "half duration:  ", cmt.halfdur)
        println(f, "latitude:       ", cmt.lat)
        println(f, "longitude:      ", cmt.lon)
        println(f, "depth:          ", cmt.dep)
        println(f, "Mrr:            ", cmt.mt[:rr])
        println(f, "Mtt:            ", cmt.mt[:tt])
        println(f, "Mpp:            ", cmt.mt[:pp])
        println(f, "Mrt:            ", cmt.mt[:rt])
        println(f, "Mrp:            ", cmt.mt[:rp])
        println(f, "Mtp:            ", cmt.mt[:tp])
    end
end

"""
    read_stations(file) -> stations

Read in a STATIONS file and return a named tuple containing vectors of the station parameters.
"""
function read_stations(file)
    d = readdlm(file)
    (sta=d[:,1], net=d[:,2], lat=d[:,3], lon=d[:,4], elev=d[:,5], dep=d[:,6])
end

"""
    write_stations(file, sta, net, lat, lon, elev, dep)
    write_stations(file, stations)
    
Write a set of seismic stations to `file` in SPECFEM format, either using a set of
arrays of the same length, or a named tuple containing these arrays.
"""
function write_stations(file, sta, net, lat, lon, elev, dep)
    all(x->length(x)==length(sta), (net, lat, lon, elev, dep)) ||
        throw(ArgumentError("all arrays must be the same length"))
    writedlm(file, [sta net lat lon elev dep], "  ")
end
write_stations(file, s) = write_stations(file, s.sta, s.net, s.lat, s.lon, s.elev, s.dep)

"""
    read_par_file(file) -> parameters
    
Read in a Par_file and return a dictionary `parameters` of the values present.
"""
function read_par_file(file)
    params = DataStructures.OrderedDict{String,Any}()
    for (i, line) in enumerate(readlines(file))
        length(replace(line, r"\s"=>"")) > 0 || continue
        # Skip comment lines
        occursin(r"^ *#", line) && continue
        occursin(r"^.*=.*$", line) || error("Bad format of line $i: \"$line\"")
        key = strip(replace(line, r"=.*"=>""))
        value = strip(split(replace(line, r".*="=>""))[1])
        value = if lowercase(value) == ".true."
            true
        elseif lowercase(value) == ".false."
            false
        elseif tryparse(Int, value) != nothing
            parse(Int, value)
        elseif tryparse(Float64, replace(value, r"[dD]"=>"e")) != nothing
            parse(Float64, replace(value, r"[dD]"=>"e"))
        else
            value
        end
        params[key] = value
    end
    params
end

"""
    write_par_file(file, params)
    
Write the values in the `Dict` `params` to `file` in SPECFEM Par_file format.
"""
function write_par_file(file, params)
    open(file, "w") do f
        for (k, v) in params
            T = typeof(v)
            if v isa Integer
                Printf.@printf(f, "%-31s = %i\n", k, v)
            elseif v isa Real
                # Convert to Fortran double precision format
                val_string = replace(Printf.@sprintf("%e", v), "e"=>"d")
                Printf.@printf(f, "%-31s = %s\n", k, val_string)
            elseif v isa Bool
                val_string = v ? ".true." : ".false."
                Printf.@printf(f, "%-31s = %s\n", k, val_string)
            elseif v isa AbstractString
                Printf.@printf(f, "%-31s = %s\n", k, strip(v))
            else
                error("Unexpected type of value $v for key \"$k\"")
            end
        end
    end
end

end # module
