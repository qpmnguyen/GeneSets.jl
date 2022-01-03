using DataDeps
import LightXML
using DataFrames


register(DataDep("MSigDB", 
    """
    This is the Molecular Signatures Database (MSigDB) version 7.4  
    Author: The Broad Institute 
    License: CC BY 4.0 
    Website: https://gsea-msigdb.org/gsea/msigdb/index.jsp
    Aravind Subramanian, Pablo Tamayo, Vamsi K. Mootha, Sayan Mukherjee, Benjamin L. Ebert, Michael A. Gillette, Amanda Paulovich, Scott L. Pomeroy, Todd R. Golub, Eric S. Lander, Jill P. Mesirov. Proceedings of the National Academy of Sciences Oct 2005, 102 (43) 15545-15550; DOI: 10.1073/pnas.0506580102
    Notice: this file is 200 MB
    Current version is 7.4  
    """, 
    "https://data.broadinstitute.org/gsea-msigdb/msigdb/release/7.4/msigdb_v7.4.xml", 
    "746278EBC153E82CC935062CDCD869957A72CDAA79BC0C7AC8013BEA1A08F4F5"
));

"""
    getMsigDB(collection, filepath)

    This function loads in MSigDB gene sets from the Broad Institute into a GSetCollection type 
    structure. 

    Input: 
    collection::String : The collection of interest as a string. 
    id_type::String : The id type 
    filepath::String : The string that points to the path. Defaults to the directory managed by datadep 

    Output:
    An object of GSetCollection Structure 

    Annotations Details: 
    * STANDARD_NAME: gene set name
    * SYSTEMATIC_NAME: gene set name for internal indexing purposes
    * CATEGORY_CODE: gene set collection code, e.g., C2
    * SUB_CATEGORY_CODE: gene set subcategory code, e.g., CGP
    * PMID: PubMed ID for the source publication
    * GEOID: GEO or ArrayExpress ID for the raw microarray data in GEO or ArrayExpress repository
    * EXACT_SOURCE: exact source of the set, usually a specific figure or table in the publication
    * GENESET_LISTING_URL: URL of the original source that listed the gene set members (all blank)
    * EXTERNAL_DETAILS_URL: URL of the original source page of the gene set
    * DESCRIPTION_BRIEF: brief description of the gene set
    * MEMBERS: list of gene set members as they originally appeared in the source
    * MEMBERS_SYMBOLIZED: list of gene set members in the form of human gene symbols
    * MEMBERS_EZID: list of gene set members in the form of human Entrez Gene IDs
    * MEMBERS_MAPPING: pipe-separated list of in the form of: MEMBERS, MEMBERS_SYMBOLIZED, MEMBERS_EZID

    Examples
    ```julia
    H_sets = getMSigDB(collection = "H")
    ```
"""
function getMsigDB(id_type::String="Entrez", 
                    collections::Union{String,missing}=missing,     
                    filepath::String=datadep"MsigDB")
    xdoc = LightXML.parse_file(filepath);
    xroot = LightXML.root(xdoc);
    sets = LightXML.get_elements_by_tagname(xroot, "GENESET")
    attributes = ["STANDARD_NAME", "SYSTEMATIC NAME", "CATEGORY_CODE", "SUB_CATEGORY_CODE", 
                "PMID", "GEOID", "EXACT_SOURCE", "GENESET_LISTING_URL", "EXTERNAL_DETAILS_URL", 
                "DESCRIPTION_BRIEF", "MEMBERS", "MEMBERS_SYMBOLIZED", "MEMBERS_EZID", 
                "MEMBERS_MAPPING", "ORGANISM"]
    

    gset = DataFrames.DataFrame(
        set = LightXML.attribute.(sets, "SYSTEMATIC_NAME"),
        set_name = LightXML.attribute.(sets, "STANDARD_NAME"),
        category = LightXML.attribute.(sets, "CATEGORY_CODE"),
        subcategory = LightXML.attribute.(sets, "SUB_CATEGORY_CODE"),
        pmid = LightXML.attribute.(sets, "PMID"),
        geoid = LightXML.attribute.(sets, "GEOID"),
        exact_source = LightXML.attribute.(sets, "EXACT_SOURCE"),
        url = LightXML.attribute.(sets, "EXTERNAL_DETAILS_URL"),
        description = LightXML.attribute.(sets, "DESCRIPTION_BRIEF"),
        organism = LightXML.attribute.(sets, "ORGANISM"),
        m_gsymbol = LightXML.attribute.(sets, "MEMBERS_SYMBOLIZED"),
        m_entrez = LightXML.attribute.(sets, "MEMBERS_EZID")
    );

    DataFrames.filter!(row -> row.category != "ARCHIVED", gset);
    if (!ismissing(collection)) 
        DataFrames.filter!(row -> row.category == collection, gset);
    end 
    
    if id_type == "entrez"
        members = gset.m_entrez;
    elseif id_type == "gene_symbol"
        members = gset.m_gsymbol;
    end
    
    egset = DataFrames.DataFrame();
    for (idx, value) in enumerate(members)
        set_name = gset.set[idx]
        mem = String.(split(value, ","))
        new_df = DataFrames.DataFrame(
            set = repeat([set_name], length(mem)),
            elements = mem
        )
        append!(egset, new_df)
    end
    
    DataFrames.transform!(egset, :elements => (x -> ifelse.(x .== "", missing, x)) => :elements);
    eset = DataFrames.DataFrame(element = unique(egset.elements)); 


    # construct GSetCollection
    coll = GSetCollection(
        elements = eset,
        sets = gset, 
        element_set = egset
    )
    return(coll)
    
end