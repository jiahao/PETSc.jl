# rewrites the expressions generated by clang

# dictionary to map pointer types to desired type
# isdefined(modulename, :name) -> Bool
# use wrap_contex.commonbuf for dictionary of names that have been defined

# used to modify Petsc typealiases in function signatures
type_dict = Dict{Any, Any} (
:PetscScalar => :Float64,
:PetscReal => :Float64,
:PetscInt => :Int32,
)


# used to convert typealiases to immutable type definionts
# currently, if the key exists, it is converted
# some the values could be used in the future to specifiy additional
# behavior
typealias_dict = Dict{Any, Any} (
:Vec => 1,
:Mat => 1,
:KSP => 1,
:PC => 1,
:PetscViewer => 1,
:PetscOption => 1,
:IS => 1,
:ISLocalToGlobalMapping => 1,
:ISColoring => 1,
:PetscLayout => 1,
:VecScatter => 1
)


# dictionary for rewriting pointer type annotations in function signatures
# Ptrs are converted to Union(Ptr{ptype}, StridedArray{ptype}, Ptr{Void})
# the objects in the typealias_dict are added automatically
# the keys can be either symbols or expressions
# if the entire type annotation matches a key, it is replace
# if any symbol in the type annotation matches a key, it is replaced
ptr_dict = Dict{Any, Any} (
#:(Ptr{PetscInt}) => :(Union(Ptr{PetscInt}, StridedArray{PetscInt}, Ptr{Void}))
#:Mat => :Mat{S <: type_dict[:PetscScalar]}
)

for i in keys(typealias_dict)
  get!(ptr_dict, i, :($i{S <: PetscScalar}))
end

println("ptr_dict = ", ptr_dict)


# used to modify ccall arguments
# the contents of type_dict are automatically included
# the type paramaterizations are from the tyepalias_dict
# are also automatically included
ccall_dict = Dict{Any, Any} (
#:Mat => :(Ptr{Void}),
)


for i in keys(type_dict)
  get!(ccall_dict, i, type_dict[i])
end

for i in keys(typealias_dict)
  get!(ccall_dict, i, :($i{S <: PetscScalar}))
end

