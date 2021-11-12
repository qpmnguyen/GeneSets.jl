import LightXML
import Downloads

"""
    get_msigdb(version="v7.2")

This function automatically fetches msigdb gene sets from the Broad Institute and generate an array of GeneSet objects containing relevant information 
Input: 
version: The version of the database, starts with "v" (e.g. "v.7.2"). Currently defaulted to version 7.2. 
"""
function get_msigdb(version::String="v7.2")
    urlname = string("https://data.broadinstitute.org/gsea-msigdb/msigdb/release/7.2/msigdb_",version, ".xml")
    println(string("Currently at ", version, " of MSigDB"))
    r = Downloads.download(urlname, "msigdb.xml", method = "GET")
    xdoc = LightXML.parse_file("msigdb.xml");
    xroot = LightXML.root(xdoc);
    sets = LightXML.get_elements_by_tagname(xroot, "GENESET");
    output = [];
    attributes = ["STANDARD_NAME", "MEMBERS", "SYSTEMATIC_NAME", "ORGANISM", "PMID", 
                "CATEGORY_CODE", "SUB_CATEGORY_CODE", "GEOID", 
                "EXACT_SOURCE","GENE_SET_LISTING_URL", "DESCRIPTION_BRIEF"]
    # loop through sets to retrieve elements
    for i in sets
        if LightXML.attribute(i, "CATEGORY_CODE") == "ARCHIVED"
            continue
        end
        if LightXML.attribute(i, "STANDARD_NAME") == Nothing() || LightXML.attribute(i, "MEMBERS") == Nothing()
            continue
        end
        args = []
        # members for gene sets should be automatically
        for j in attributes
            if j == "MEMBERS"
                value = String.(split(LightXML.attribute(i,j), ","))
            else 
                value = LightXML.attribute(i, j)
                value = ifelse(value == Nothing(), "", value)
            end
            push!(args, value)
        end
        print(args[1])
        # ... allows to splat arguments (similar to do.call)
        set = GSet(args...);
        push!(output, set)
    end
    rm("msigdb.xml");
    return(output)
end