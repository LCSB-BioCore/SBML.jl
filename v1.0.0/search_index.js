var documenterSearchIndex = {"docs":
[{"location":"functions/#Data-types","page":"Reference","title":"Data types","text":"","category":"section"},{"location":"functions/#Helper-types","page":"Reference","title":"Helper types","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"types.jl\"]","category":"page"},{"location":"functions/#SBML.Maybe","page":"Reference","title":"SBML.Maybe","text":"Maybe{X}\n\nType shortcut for \"X or nothing\" or \"nullable X\" in javaspeak. Name got inspired by our functional friends.\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.VPtr","page":"Reference","title":"SBML.VPtr","text":"VPtr\n\nA convenience wrapper for \"any\" (C void) pointer.\n\n\n\n\n\n","category":"type"},{"location":"functions/#Model-data-structures","page":"Reference","title":"Model data structures","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"structs.jl\"]","category":"page"},{"location":"functions/#SBML.AlgebraicRule","page":"Reference","title":"SBML.AlgebraicRule","text":"struct AlgebraicRule <: SBML.Rule\n\nSBML algebraic rule.\n\nFields\n\nmath::SBML.Math\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.AssignmentRule","page":"Reference","title":"SBML.AssignmentRule","text":"struct AssignmentRule <: SBML.Rule\n\nSBML assignment rule.\n\nFields\n\nvariable::String\nmath::SBML.Math\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Compartment","page":"Reference","title":"SBML.Compartment","text":"struct Compartment\n\nSBML Compartment with sizing information.\n\nFields\n\nname::Union{Nothing, String}\nconstant::Union{Nothing, Bool}\nspatial_dimensions::Union{Nothing, Int64}\nsize::Union{Nothing, Float64}\nunits::Union{Nothing, String}\nnotes::Union{Nothing, String}\nannotation::Union{Nothing, String}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Constraint","page":"Reference","title":"SBML.Constraint","text":"struct Constraint\n\nSBML constraint.\n\nFields\n\nmath::SBML.Math\nmessage::String\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Event","page":"Reference","title":"SBML.Event","text":"struct Event\n\nFields\n\nuse_values_from_trigger_time::Int32\nname::Union{Nothing, String}\ntrigger::Union{Nothing, SBML.Trigger}\nevent_assignments::Union{Nothing, Vector{SBML.EventAssignment}}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.EventAssignment","page":"Reference","title":"SBML.EventAssignment","text":"struct EventAssignment\n\nFields\n\nvariable::String\nmath::Union{Nothing, SBML.Math}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.FunctionDefinition","page":"Reference","title":"SBML.FunctionDefinition","text":"struct FunctionDefinition\n\nCustom function definition.\n\nFields\n\nname::Union{Nothing, String}\nbody::Union{Nothing, SBML.Math}\nnotes::Union{Nothing, String}\nannotation::Union{Nothing, String}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.GPAAnd","page":"Reference","title":"SBML.GPAAnd","text":"struct GPAAnd <: SBML.GeneProductAssociation\n\nBoolean binary \"and\" in the association expression\n\nFields\n\nterms::Vector{SBML.GeneProductAssociation}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.GPAOr","page":"Reference","title":"SBML.GPAOr","text":"struct GPAOr <: SBML.GeneProductAssociation\n\nBoolean binary \"or\" in the association expression\n\nFields\n\nterms::Vector{SBML.GeneProductAssociation}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.GPARef","page":"Reference","title":"SBML.GPARef","text":"struct GPARef <: SBML.GeneProductAssociation\n\nGene product reference in the association expression\n\nFields\n\ngene_product::String\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.GeneProduct","page":"Reference","title":"SBML.GeneProduct","text":"struct GeneProduct\n\nGene product metadata.\n\nFields\n\nlabel::String\nname::Union{Nothing, String}\nmetaid::Union{Nothing, String}\nnotes::Union{Nothing, String}\nannotation::Union{Nothing, String}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.GeneProductAssociation","page":"Reference","title":"SBML.GeneProductAssociation","text":"abstract type GeneProductAssociation\n\nAbstract type for all kinds of gene product associations\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Math","page":"Reference","title":"SBML.Math","text":"A simplified representation of MathML-specified math AST\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.MathApply","page":"Reference","title":"SBML.MathApply","text":"struct MathApply <: SBML.Math\n\nFunction application (\"call by name\", no tricks allowed) in mathematical expression\n\nFields\n\nfn::String\nargs::Vector{SBML.Math}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.MathConst","page":"Reference","title":"SBML.MathConst","text":"struct MathConst <: SBML.Math\n\nA constant identified by name (usually something like pi, e or true) in mathematical expression\n\nFields\n\nid::String\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.MathIdent","page":"Reference","title":"SBML.MathIdent","text":"struct MathIdent <: SBML.Math\n\nAn identifier (usually a variable name) in mathematical expression\n\nFields\n\nid::String\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.MathLambda","page":"Reference","title":"SBML.MathLambda","text":"struct MathLambda <: SBML.Math\n\nFunction definition (aka \"lambda\") in mathematical expression\n\nFields\n\nargs::Vector{String}\nbody::SBML.Math\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.MathTime","page":"Reference","title":"SBML.MathTime","text":"struct MathTime <: SBML.Math\n\nA special value representing the current time of the simulation, with a special name.\n\nFields\n\nid::String\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.MathVal","page":"Reference","title":"SBML.MathVal","text":"struct MathVal{T} <: SBML.Math\n\nA literal value (usually a numeric constant) in mathematical expression\n\nFields\n\nval::Any\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Model","page":"Reference","title":"SBML.Model","text":"struct Model\n\nStructure that collects the model-related data. Contains parameters, units, compartments, species and reactions and gene_products, and additional notes and annotation (also present internally in some of the data fields). The contained dictionaries are indexed by identifiers of the corresponding objects.\n\nFields\n\nparameters::Dict{String, SBML.Parameter}\nunits::Dict{String, SBML.UnitDefinition}\ncompartments::Dict{String, SBML.Compartment}\nspecies::Dict{String, SBML.Species}\ninitial_assignments::Dict{String, SBML.Math}\nrules::Vector{SBML.Rule}\nconstraints::Vector{SBML.Constraint}\nreactions::Dict{String, SBML.Reaction}\nobjectives::Dict{String, SBML.Objective}\nactive_objective::String\ngene_products::Dict{String, SBML.GeneProduct}\nfunction_definitions::Dict{String, SBML.FunctionDefinition}\nevents::Dict{String, SBML.Event}\nname::Union{Nothing, String}\nid::Union{Nothing, String}\nmetaid::Union{Nothing, String}\nconversion_factor::Union{Nothing, String}\narea_units::Union{Nothing, String}\nextent_units::Union{Nothing, String}\nlength_units::Union{Nothing, String}\nsubstance_units::Union{Nothing, String}\ntime_units::Union{Nothing, String}\nvolume_units::Union{Nothing, String}\nnotes::Union{Nothing, String}\nannotation::Union{Nothing, String}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Objective","page":"Reference","title":"SBML.Objective","text":"struct Objective\n\nFields\n\ntype::String\nflux_objectives::Dict{String, Float64}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Parameter","page":"Reference","title":"SBML.Parameter","text":"struct Parameter\n\nRepresentation of SBML Parameter structure, holding a value annotated with units and constantness information.\n\nFields\n\nname::Union{Nothing, String}\nvalue::Union{Nothing, Float64}\nunits::Union{Nothing, String}\nconstant::Union{Nothing, Bool}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.RateRule","page":"Reference","title":"SBML.RateRule","text":"struct RateRule <: SBML.Rule\n\nSBML rate rule.\n\nFields\n\nvariable::String\nmath::SBML.Math\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Reaction","page":"Reference","title":"SBML.Reaction","text":"struct Reaction\n\nReaction with stoichiometry that assigns reactants and products their relative consumption/production rates, lower/upper bounds (in tuples lb and ub, with unit names), and objective coefficient (oc). Also may contains notes and annotation.\n\nFields\n\nname::Union{Nothing, String}\nreactants::Dict{String, Float64}\nproducts::Dict{String, Float64}\nkinetic_parameters::Dict{String, SBML.Parameter}\nlower_bound::Union{Nothing, String}\nupper_bound::Union{Nothing, String}\ngene_product_association::Union{Nothing, SBML.GeneProductAssociation}\nkinetic_math::Union{Nothing, SBML.Math}\nreversible::Bool\nmetaid::Union{Nothing, String}\nnotes::Union{Nothing, String}\nannotation::Union{Nothing, String}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Rule","page":"Reference","title":"SBML.Rule","text":"abstract type Rule\n\nAbstract type representing SBML rules.\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Species","page":"Reference","title":"SBML.Species","text":"struct Species\n\nSpecies metadata – contains a human-readable name, a compartment identifier, formula, charge, and additional notes and annotation.\n\nFields\n\nname::Union{Nothing, String}\ncompartment::String\nboundary_condition::Union{Nothing, Bool}\nformula::Union{Nothing, String}\ncharge::Union{Nothing, Int64}\ninitial_amount::Union{Nothing, Float64}\ninitial_concentration::Union{Nothing, Float64}\nsubstance_units::Union{Nothing, String}\nonly_substance_units::Union{Nothing, Bool}\nconstant::Union{Nothing, Bool}\nmetaid::Union{Nothing, String}\nnotes::Union{Nothing, String}\nannotation::Union{Nothing, String}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.Trigger","page":"Reference","title":"SBML.Trigger","text":"struct Trigger\n\nFields\n\npersistent::Bool\ninitial_value::Bool\nmath::Union{Nothing, SBML.Math}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.UnitDefinition","page":"Reference","title":"SBML.UnitDefinition","text":"struct UnitDefinition\n\nRepresentation of SBML unit definition, holding the name of the unit and a vector of SBML.UnitParts.  See the definition of field units in SBML.Model.\n\nFields\n\nname::Union{Nothing, String}\nunit_parts::Vector{SBML.UnitPart}\n\n\n\n\n\n","category":"type"},{"location":"functions/#SBML.UnitPart","page":"Reference","title":"SBML.UnitPart","text":"struct UnitPart\n\nPart of a measurement unit definition that corresponds to the SBML definition of Unit. For example, the unit \"per square megahour\", Mh^(-2), is written as:\n\nSBML.UnitPart(\"second\",  # base SI unit, this says we are measuring time\n         -2,        # exponent, says \"per square\"\n         6,         # log-10 scale of the unit, says \"mega\"\n         1/3600)    # second-to-hour multiplier\n\nCompound units (such as \"volt-amperes\" and \"dozens of yards per ounce\") are built from multiple UnitParts.  See also SBML.UnitDefinition.\n\nFields\n\nkind::String\nexponent::Int64\nscale::Int64\nmultiplier::Float64\n\n\n\n\n\n","category":"type"},{"location":"functions/#Base-functions","page":"Reference","title":"Base functions","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"SBML.jl\"]","category":"page"},{"location":"functions/#SBML.SBML","page":"Reference","title":"SBML.SBML","text":"SBML.jl\n\nBuild status Documentation Stats\n(Image: CI status) (Image: stable documentation) (Image: dev documentation) (Image: SBML Downloads)\n\nThis is a simple wrap of some of the libSBML functionality, mainly the model loading for purposes of COBRA analysis methods and exploration of ODE system and reaction dynamics.\n\nYou might like to try the packages that use SBML.jl; these now include:\n\nCOBREXA.jl, the exascale-ready constraint-based analysis and reconstruction toolkit for finding and modeling steady metabolic fluxes with the models\nSBMLToolkit.jl, for working with the reaction dynamics of the models as ODE systems, well connected to the SciML ModelingToolkit ecosystem.\n\nOther functionality will be added as needed. Feel free to submit a PR that increases the loading \"coverage\".\n\nAcknowledgements\n\nSBML.jl was developed at the Luxembourg Centre for Systems Biomedicine of the University of Luxembourg (uni.lu/lcsb), and the UCL Research Software Development Group (ucl.ac.uk/arc). The development was supported by European Union's Horizon 2020 Programme under PerMedCoE project (permedcoe.eu) agreement no.  951773, and Chan Zuckerberg Initiative (chanzuckerberg.com) under grant 2020-218578 (5022).\n\n<img src=\"docs/src/assets/unilu.svg\" alt=\"Uni.lu logo\" height=\"64px\">   <img src=\"docs/src/assets/lcsb.svg\" alt=\"LCSB logo\" height=\"64px\">   <img src=\"docs/src/assets/permedcoe.svg\" alt=\"PerMedCoE logo\" height=\"64px\">   <img src=\"docs/src/assets/ucl.svg\" alt=\"UCL logo\" height=\"64px\">\n\nInstallation\n\n]add SBML # or\nusing Pkg; Pkg.add(\"SBML\")\n\nUsage\n\nusing SBML\nm = readSBML(\"myModel.xml\")\n\n# m is now a Model structure with:\nm.reactions\nm.species\nm.compartments\n...\n\nThere are several helper functions, for example you can get a nice list of reactions, metabolites and the stoichiometric matrix as follows:\n\nmets, rxns, S = stoichiometry_matrix(m)\n\n\n\n\n\n","category":"module"},{"location":"functions/#SBML.sbml-Tuple{Symbol}","page":"Reference","title":"SBML.sbml","text":"sbml(sym::Symbol) -> Ptr{Nothing}\n\n\nA shortcut that loads a function symbol from SBML_jll.\n\n\n\n\n\n","category":"method"},{"location":"functions/#Loading-and-versioning","page":"Reference","title":"Loading and versioning","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"readsbml.jl\"]","category":"page"},{"location":"functions/#SBML._readSBML-Tuple{Symbol, String, Any, Any}","page":"Reference","title":"SBML._readSBML","text":"_readSBML(symbol::Symbol, fn::String, sbml_conversion, report_severities) -> SBML.Model\n\n\nInternal helper for readSBML.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_association-Tuple{Ptr{Nothing}}","page":"Reference","title":"SBML.get_association","text":"get_association(x::Ptr{Nothing}) -> Union{SBML.GPAAnd, SBML.GPAOr, SBML.GPARef}\n\n\nConvert a pointer to SBML FbcAssociation_t to the GeneProductAssociation tree structure.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_model-Tuple{Ptr{Nothing}}","page":"Reference","title":"SBML.get_model","text":"get_model(mdl::Ptr{Nothing}) -> SBML.Model\n\n\nTake the SBMLModel_t pointer and extract all information required to make a valid SBML.Model structure.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_optional_bool-Tuple{Ptr{Nothing}, Any, Any}","page":"Reference","title":"SBML.get_optional_bool","text":"get_optional_bool(x::Ptr{Nothing}, is_sym, get_sym) -> Union{Nothing, Bool}\n\n\nHelper for getting out boolean flags.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_optional_double-Tuple{Ptr{Nothing}, Any, Any}","page":"Reference","title":"SBML.get_optional_double","text":"get_optional_double(x::Ptr{Nothing}, is_sym, get_sym) -> Union{Nothing, Float64}\n\n\nHelper for getting out C doubles aka Float64s.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_optional_int-Tuple{Ptr{Nothing}, Any, Any}","page":"Reference","title":"SBML.get_optional_int","text":"get_optional_int(x::Ptr{Nothing}, is_sym, get_sym) -> Union{Nothing, Int64}\n\n\nHelper for getting out unsigned integers.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_optional_string-Tuple{Ptr{Nothing}, Any, Any}","page":"Reference","title":"SBML.get_optional_string","text":"get_optional_string(x::Ptr{Nothing}, fn_test, fn_sym) -> Union{Nothing, String}\n\n\nLike get_string, but returns nothing instead of throwing an exception. Also returns values only if fn_test returns true.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_optional_string-Tuple{Ptr{Nothing}, Any}","page":"Reference","title":"SBML.get_optional_string","text":"get_optional_string(x::Ptr{Nothing}, fn_sym) -> Union{Nothing, String}\n\n\nLike get_string, but returns nothing instead of throwing an exception.\n\nThis is used to get notes and annotations and several other things (see get_notes, get_annotations)\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_parameter-Tuple{Ptr{Nothing}}","page":"Reference","title":"SBML.get_parameter","text":"get_parameter(p::Ptr{Nothing}) -> Pair{String, SBML.Parameter}\n\n\nExtract the value of SBML Parameter_t.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_string-Tuple{Ptr{Nothing}, Any}","page":"Reference","title":"SBML.get_string","text":"get_string(x::Ptr{Nothing}, fn_sym) -> String\n\n\nC-call the SBML function fn_sym with a single parameter x, interpret the result as a string and return it, or throw exception in case the pointer is NULL.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.readSBML","page":"Reference","title":"SBML.readSBML","text":"readSBML(fn::String) -> SBML.Model\nreadSBML(fn::String, sbml_conversion; report_severities) -> SBML.Model\n\n\nRead the SBML from a XML file in fn and return the contained SBML.Model.\n\nThe sbml_conversion is a function that does an in-place modification of the single parameter, which is the C pointer to the loaded SBML document (C type SBMLDocument*). Several functions for doing that are prepared, including set_level_and_version, libsbml_convert, and convert_simplify_math.\n\nreport_severities switches on and off reporting of certain errors; see the documentation of get_error_messages for details.\n\nTo read from a string instead of a file, use readSBMLFromString.\n\nExample\n\nm = readSBML(\"my_model.xml\", doc -> begin\n    set_level_and_version(3, 1)(doc)\n    convert_simplify_math(doc)\nend)\n\n\n\n\n\n","category":"function"},{"location":"functions/#SBML.readSBMLFromString","page":"Reference","title":"SBML.readSBMLFromString","text":"readSBMLFromString(str::AbstractString) -> SBML.Model\nreadSBMLFromString(str::AbstractString, sbml_conversion; report_severities) -> SBML.Model\n\n\nRead the SBML from the string str and return the contained SBML.Model.\n\nFor the other arguments see the docstring of readSBML, which can be used to read from a file instead of a string.\n\n\n\n\n\n","category":"function"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"version.jl\"]","category":"page"},{"location":"functions/#SBML.Version-Tuple{}","page":"Reference","title":"SBML.Version","text":"Version() -> VersionNumber\n\n\nGet the version of the used SBML library in Julia version format.\n\n\n\n\n\n","category":"method"},{"location":"functions/#libsbml-representation-converters","page":"Reference","title":"libsbml representation converters","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"The converters are intended to be used as parameters of readSBML.","category":"page"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"converters.jl\"]","category":"page"},{"location":"functions/#SBML.convert_simplify_math","page":"Reference","title":"SBML.convert_simplify_math","text":"Shortcut for libsbml_convert that expands functions, local parameters, and initial assignments in the SBML document.\n\n\n\n\n\n","category":"function"},{"location":"functions/#SBML.libsbml_convert","page":"Reference","title":"SBML.libsbml_convert","text":"libsbml_convert(conversion_options::AbstractVector{<:Pair{String, <:AbstractDict{String, String}}}) -> SBML.var\"#16#17\"{_A, Vector{String}} where _A\nlibsbml_convert(conversion_options::AbstractVector{<:Pair{String, <:AbstractDict{String, String}}}, report_severities) -> SBML.var\"#16#17\"\n\n\nA converter that runs the SBML conversion routine, with specified conversion options. The argument is a vector of pairs to allow specifying the order of conversions.  report_severities switches on and off reporting of certain errors; see the documentation of get_error_messages for details.\n\n\n\n\n\n","category":"function"},{"location":"functions/#SBML.libsbml_convert-2","page":"Reference","title":"SBML.libsbml_convert","text":"libsbml_convert(converter::String) -> SBML.var\"#16#17\"{Vector{Pair{String, Dict{String, String}}}, Vector{String}}\nlibsbml_convert(converter::String, report_severities; kwargs...) -> SBML.var\"#16#17\"{Vector{Pair{String, Dict{String, String}}}}\n\n\nQuickly construct a single run of a libsbml converter from keyword arguments. report_severities switches on and off reporting of certain errors; see the documentation of get_error_messages for details.\n\nExample\n\nreadSBML(\"example.xml\", libsbml_convert(\"stripPackage\", package=\"layout\"))\n\n\n\n\n\n","category":"function"},{"location":"functions/#SBML.set_level_and_version","page":"Reference","title":"SBML.set_level_and_version","text":"set_level_and_version(level, version) -> SBML.var\"#14#15\"{_A, _B, Vector{String}} where {_A, _B}\nset_level_and_version(level, version, report_severities) -> SBML.var\"#14#15\"\n\n\nA converter to pass into readSBML that enforces certain SBML level and version.  report_severities switches on and off reporting of certain errors; see the documentation of get_error_messages for details.\n\n\n\n\n\n","category":"function"},{"location":"functions/#Helper-functions","page":"Reference","title":"Helper functions","text":"","category":"section"},{"location":"functions/#Data-accessors","page":"Reference","title":"Data accessors","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"utils.jl\"]","category":"page"},{"location":"functions/#Base.show-Tuple{IO, MIME{Symbol(\"text/plain\")}, SBML.Model}","page":"Reference","title":"Base.show","text":"show(io::IO, _::MIME{Symbol(\"text/plain\")}, m::SBML.Model)\n\n\nPretty-printer for a SBML model. Avoids flushing too much stuff to terminal by accident.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.check_errors","page":"Reference","title":"SBML.check_errors","text":"check_errors(success::Integer, doc::Ptr{Nothing}, error::Exception) -> Union{Nothing, Bool}\ncheck_errors(success::Integer, doc::Ptr{Nothing}, error::Exception, report_severities) -> Union{Nothing, Bool}\n\n\nIf success is a 0-valued Integer (a logical false), then call get_error_messages to show the error messages reported by SBML in the doc document and throw the error if they are more than 1.  success is typically the value returned by an SBML C function operating on doc which returns a boolean flag to signal a successful operation.\n\n\n\n\n\n","category":"function"},{"location":"functions/#SBML.extensive_kinetic_math-Tuple{SBML.Model, SBML.Math}","page":"Reference","title":"SBML.extensive_kinetic_math","text":"extensive_kinetic_math(m::SBML.Model, formula::SBML.Math) -> Any\n\n\nConvert a SBML math formula to \"extensive\" kinetic laws, where the references to species that are marked as not having only substance units are converted from amounts to concentrations. Compartment sizes are referenced by compartment identifiers. A compartment with no obvious definition available in the model (as detected by seemsdefined) is either defaulted as size-less (i.e., size is 1.0) in case it does not have spatial dimensions, or reported as erroneous.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.fbc_flux_objective-Tuple{SBML.Model, String}","page":"Reference","title":"SBML.fbc_flux_objective","text":"fbc_flux_objective(m::SBML.Model, oid::String) -> Vector{Float64}\n\n\nGet the specified FBC maximization objective from a model, as a vector in the same order as keys(m.reactions).\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.flux_bounds-Tuple{SBML.Model}","page":"Reference","title":"SBML.flux_bounds","text":"flux_bounds(m::SBML.Model) -> Tuple{Vector{Tuple{Float64, String}}, Vector{Tuple{Float64, String}}}\n\n\nExtract the vectors of lower and upper bounds of reaction rates from the model, in the same order as keys(m.reactions).  All bounds are accompanied with the unit of the corresponding value (the behavior is based on SBML specification). Missing bounds are represented by negative/positive infinite values with empty-string unit.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.flux_objective-Tuple{SBML.Model}","page":"Reference","title":"SBML.flux_objective","text":"flux_objective(m::SBML.Model) -> Vector{Float64}\n\n\nCollect a single maximization objective from FBC, and from kinetic parameters if FBC is not available. Fails if there is more than 1 FBC objective.\n\nProvided for simplicity and compatibility with earlier versions of SBML.jl.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_compartment_size-Tuple{SBML.Model, Any}","page":"Reference","title":"SBML.get_compartment_size","text":"get_compartment_size(m::SBML.Model, compartment; default) -> Union{Nothing, Float64}\n\n\nA helper for easily getting out a defaulted compartment size.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.get_error_messages-Tuple{Ptr{Nothing}, Exception, Any}","page":"Reference","title":"SBML.get_error_messages","text":"get_error_messages(doc::Ptr{Nothing}, error::Exception, report_severities)\n\n\nShow the error messages reported by SBML in the doc document and throw the error if they are more than 1.\n\nreport_severities switches the reporting of certain error types defined by libsbml; you can choose from [\"Fatal\", \"Error\", \"Warning\", \"Informational\"].\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.initial_amounts-Tuple{SBML.Model}","page":"Reference","title":"SBML.initial_amounts","text":"initial_amounts(m::SBML.Model; convert_concentrations, compartment_size) -> Base.Generator{Dict{String, SBML.Species}, SBML.var\"#97#101\"{Bool, SBML.var\"#99#103\"{SBML.Model}}}\n\n\nReturn initial amounts for each species as a generator of pairs species_name => initial_amount; the amount is set to nothing if not available. If convert_concentrations is true and there is information about initial concentration available together with compartment size, the result is computed from the species' initial concentration.\n\nThe units of measurement are ignored in this computation, but one may reconstruct them from substance_units field of Species structure.\n\nExample\n\n# get the initial amounts as dictionary\nDict(SBML.initial_amounts(model, convert_concentrations = true))\n\n# suppose the compartment size is 10.0 if unspecified\ncollect(SBML.initial_amounts(\n    model,\n    convert_concentrations = true,\n    compartment_size = comp -> SBML.get_compartment_size(model, comp, 10.0),\n))\n\n# remove the empty entries\nDict(k => v for (k,v) in SBML.initial_amounts(model) if !isnothing(v))\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.initial_concentrations-Tuple{SBML.Model}","page":"Reference","title":"SBML.initial_concentrations","text":"initial_concentrations(m::SBML.Model; convert_amounts, compartment_size) -> Base.Generator{Dict{String, SBML.Species}, SBML.var\"#106#110\"{Bool, SBML.var\"#108#112\"{SBML.Model}}}\n\n\nReturn initial concentrations of the species in the model. Refer to work-alike initial_amounts for details.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.isfreein-Tuple{String, SBML.Math}","page":"Reference","title":"SBML.isfreein","text":"isfreein(id::String, expr::SBML.Math)\n\nDetermine if id is used and not bound (aka. free) in expr.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.kinetic_flux_objective-Tuple{SBML.Model}","page":"Reference","title":"SBML.kinetic_flux_objective","text":"kinetic_flux_objective(m::SBML.Model) -> Union{Vector{Float64}, Vector{Union{Nothing, Float64}}, Vector{Nothing}}\n\n\nGet a kinetic-parameter-specified flux objective from the model, as a vector in the same order as keys(m.reactions).\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.mayfirst-Tuple","page":"Reference","title":"SBML.mayfirst","text":"mayfirst(args...) -> Any\n\n\nHelper to get the first non-nothing value from the arguments.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.maylift-Tuple{Any, Vararg{Union{Nothing, X} where X}}","page":"Reference","title":"SBML.maylift","text":"maylift(f, args::Union{Nothing, X} where X...) -> Any\n\n\nHelper to lift a function to work on Maybe, returning nothing whenever there's a nothing in args.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.seemsdefined-Tuple{String, SBML.Model}","page":"Reference","title":"SBML.seemsdefined","text":"isboundbyrules(\n    id::String,\n    m::SBML.Model\n)\n\nDetermine if an identifier seems defined or used by any Rules in the model.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.stoichiometry_matrix-Tuple{SBML.Model}","page":"Reference","title":"SBML.stoichiometry_matrix","text":"stoichiometry_matrix(m::SBML.Model) -> Tuple{Vector{String}, Vector{String}, SparseArrays.SparseMatrixCSC{Float64, Int64}}\n\n\nExtract the vector of species (aka metabolite) identifiers, vector of reaction identifiers, and a sparse stoichiometry matrix (of type SparseMatrixCSC from SparseArrays package) from an existing SBML.Model. Returns a 3-tuple with these values.\n\n\n\n\n\n","category":"method"},{"location":"functions/#Units-support","page":"Reference","title":"Units support","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"unitful.jl\"]","category":"page"},{"location":"functions/#SBML.unitful-Tuple{SBML.Model, Tuple{Float64, String}, Number}","page":"Reference","title":"SBML.unitful","text":"unitful(m::SBML.Model, val::Tuple{Float64, String}, default_unit::Number) -> Any\n\n\nOverload of unitful that uses the default_unit if the unit is not found in the model.\n\nExample\n\njulia> SBML.unitful(mdl, (10.0,\"firkin\"), 90 * u\"lb\")\n990.0 lb\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.unitful-Tuple{SBML.Model, Tuple{Float64, String}, String}","page":"Reference","title":"SBML.unitful","text":"unitful(m::SBML.Model, val::Tuple{Float64, String}, default_unit::String) -> Any\n\n\nOverload of unitful that allows specification of the default_unit by string ID.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.unitful-Tuple{SBML.Model, Tuple{Float64, String}}","page":"Reference","title":"SBML.unitful","text":"unitful(m::SBML.Model, val::Tuple{Float64, String}) -> Any\n\n\nComputes a properly unitful value from a value-unit pair stored in the model m.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.unitful-Tuple{SBML.UnitDefinition}","page":"Reference","title":"SBML.unitful","text":"unitful(u::SBML.UnitDefinition) -> Any\n\n\nConverts an SBML unit definition (i.e., its vector of UnitParts) to a corresponding Unitful unit.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.unitful-Tuple{SBML.UnitPart}","page":"Reference","title":"SBML.unitful","text":"unitful(u::SBML.UnitPart) -> Any\n\n\nConverts a UnitPart to a corresponding Unitful unit.\n\nThe conversion is done according to the formula from SBML L3v2 core manual release 2(section 4.4.2).\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.unitful-Tuple{Vector{SBML.UnitPart}}","page":"Reference","title":"SBML.unitful","text":"unitful(u::Vector{SBML.UnitPart}) -> Any\n\n\nConverts an SBML unit (i.e., a vector of UnitParts) to a corresponding Unitful unit.\n\n\n\n\n\n","category":"method"},{"location":"functions/#Math-interpretation","page":"Reference","title":"Math interpretation","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"interpret.jl\"]","category":"page"},{"location":"functions/#SBML.default_constants","page":"Reference","title":"SBML.default_constants","text":"A dictionary of default constants filled in place of SBML Math constants in the function conversion.\n\n\n\n\n\n","category":"constant"},{"location":"functions/#SBML.default_function_mapping","page":"Reference","title":"SBML.default_function_mapping","text":"Default mapping of SBML function names to Julia functions, represented as a dictionary from Strings (SBML names) to functions.\n\nThe default mapping only contains the basic SBML functions that are unambiguously represented in Julia; it is supposed to be extended by the user if more functions need to be supported.\n\n\n\n\n\n","category":"constant"},{"location":"functions/#SBML.interpret_math-Tuple{SBML.Math}","page":"Reference","title":"SBML.interpret_math","text":"interpret_math(x::SBML.Math; map_apply, map_const, map_ident, map_lambda, map_time, map_value) -> Any\n\n\nRecursively interpret SBML.Math type. This can be used to relatively easily traverse and evaluate the SBML math, or translate it into any custom representation, such as Expr or the Num of Symbolics.jl (see the SBML test suite for examples).\n\nBy default, the function can convert SBML constants, values and function applications, but identifiers, time values and lambdas are not mapped and throw an error. Similarly SBML function rateOf is undefined, users must to supply their own definition of rateOf that uses the correct derivative.\n\n\n\n\n\n","category":"method"},{"location":"functions/#Internal-math-helpers","page":"Reference","title":"Internal math helpers","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [SBML]\nPages = [\"math.jl\"]","category":"page"},{"location":"functions/#SBML.ast_is-Tuple{Ptr{Nothing}, Symbol}","page":"Reference","title":"SBML.ast_is","text":"ast_is(ast::Ptr{Nothing}, what::Symbol) -> Bool\n\n\nHelper for quickly recognizing kinds of ASTs\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.parse_math-Tuple{Ptr{Nothing}}","page":"Reference","title":"SBML.parse_math","text":"parse_math(ast::Ptr{Nothing}) -> Any\n\n\nThis attempts to parse out a decent Julia-esque Math AST from a pointer to ASTNode_t.\n\n\n\n\n\n","category":"method"},{"location":"functions/#SBML.parse_math_children-Tuple{Ptr{Nothing}}","page":"Reference","title":"SBML.parse_math_children","text":"parse_math_children(ast::Ptr{Nothing}) -> Vector{SBML.Math}\n\n\nRecursively parse all children of an AST node.\n\n\n\n\n\n","category":"method"},{"location":"#SBML.jl-—-load-systems-biology-models-from-SBML-files","page":"Home","title":"SBML.jl — load systems biology models from SBML files","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package provides a straightforward way to load model- and simulation-relevant information from SBML files.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The representation does not follow the XML structure within SBML, but instead translates the contents into native Julia structs. This makes the models much easier to work with from Julia,","category":"page"},{"location":"#Quick-start","page":"Home","title":"Quick-start","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The \"main\" function of the library is readSBML, which does exactly what it says: loads a SBML model from disk into the SBML.Model:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using SBML\njulia> mdl = readSBML(\"Ec_core_flux1.xml\")\nSBML.Model(…)\n\njulia> mdl.compartments\n2-element Array{String,1}:\n \"Extra_organism\"\n \"Cytosol\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"There are several functions that help you with using the data in the usual COBRA-style workflows, such as stoichiometry_matrix. Others are detailed in the relevant sections of the function reference.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> metabolites, reactions, S = stoichiometry_matrix(mdl)\njulia> metabolites\n77-element Array{String,1}:\n \"M_succoa_c\"\n \"M_ac_c\"\n \"M_etoh_c\"\n  ⋮\n\njulia> S\n77×77 SparseArrays.SparseMatrixCSC{Float64,Int64} with 308 stored entries:\n  [60,  1]  =  -1.0\n  [68,  1]  =  1.0\n  [1 ,  2]  =  1.0\n  [6 ,  2]  =  -1.0\n  ⋮\n  [23, 76]  =  1.0\n  [56, 76]  =  -1.0\n  [30, 77]  =  -1.0\n  [48, 77]  =  1.0\n\njulia> Matrix(S)\n77×77 Array{Float64,2}:\n 0.0   1.0  0.0  0.0  0.0  0.0  0.0  …  0.0   0.0  0.0   0.0  0.0  0.0  0.0\n 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0\n 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0\n 0.0   0.0  1.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0\n 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0\n 0.0  -1.0  0.0  0.0  0.0  0.0  0.0  …  0.0   0.0  0.0   0.0  0.0  0.0  0.0\n 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  1.0  -1.0  0.0  0.0  0.0\n 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0\n 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0\n 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0  -1.0  0.0   0.0  0.0  0.0  0.0\n ⋮                         ⋮         ⋱  ⋮                          ⋮","category":"page"},{"location":"#Table-of-contents","page":"Home","title":"Table of contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\"functions.md\"]\nDepth = 2","category":"page"}]
}
