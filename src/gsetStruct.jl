# compiling structs for gene sets and gene set collection 

using Parameters 
using DataFrames 

abstract type AbstractGSetCollection end 
abstract type AbstractGSet end

@with_kw mutable struct GSet <: AbstractGSet
    std_name::String
    ids::Array
    sys_name::String = ""
    org::String = ""
    pmid::String = ""
    cat::String = ""
    subcat::String = ""
    geoid::String = ""
    source::String = ""
    url::String = ""
    description::String = ""
end

@with_kw mutable struct GSetCollection <: AbstractGSetCollection
    elements::DataFrame = DataFrame()
    sets::DataFrame = DataFrame()
    element_set::DataFrame = DataFrame()
end