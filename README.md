# SPECFEMUtils

A [Julia](https://julialang.org) package to set up and deal with simulations
of seismic wave propagation in the Earth using the
[SPECFEM3D_GLOBE](https://geodynamics.org/cig/software/specfem3d_globe/) software.

## Installation

First clone the repo and activate the project:
```sh
$ git clone https://github.com/anowacki/SPECFEMUtils.jl
$ cd SPECFEMUtils.jl
$ julia --project
```

Then install the dependencies:
```julia
julia> import Pkg; Pkg.instantiate()
```
