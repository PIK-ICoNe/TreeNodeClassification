"""
    nodes_and_Leafs(g::Graph, maxiter::Int)

Iteratively removes Leafs (nodes with degree = 1) from a graph g.
Returns all Leafs as well as their parents/neighbors
"""
function nodes_and_Leafs(g::Graph, maxiter::Int)
    nodes_per_lvl = []
    append!(nodes_per_lvl, [collect(vertices(g))])
    node_map = [] 
    Leafs_per_lvl = []
    parents = []
    tree_nodes = []
    
    for lvl in 1:maxiter
        g, vmap = induced_subgraph(g, nodes_per_lvl[lvl]) # subgraph of current lvl
        Leafs = findall(degree(g) .== 1) # Leafs only have one neighbor

        # end calulation if no Leafs are present
        if isempty(Leafs)
            break
        end

        # save vertices map to get the original node index
        append!(node_map, [vmap])

        parents_lvl = map(x -> neighbors(g, x), Leafs) # save the parents of the Leafs to later define roots
        append!(parents, map_to_initial_graph(node_map, vcat(parents_lvl...)))

        append!(Leafs_per_lvl, [Leafs]) # save all Leafs
        append!(tree_nodes, map_to_initial_graph(node_map, Leafs)) # all Leafs are part of a tree

        remaing_nodes = collect(vertices(g))
        deleteat!(remaing_nodes, Leafs) # remove Leafs from nodes list for the next level
        append!(nodes_per_lvl, [remaing_nodes])
    end
    return Leafs_per_lvl, tree_nodes, parents
end

"""
    map_to_initial_graph(node_map, nodes)

The nodes are vertices from an induced subgraph. 
This function return the indices of the nodes in the original graph.
"""
function map_to_initial_graph(node_map, nodes)
        if length(node_map) == 1
            node_map = vcat(node_map...)
            nodes = node_map[nodes]
        else
            for m in reverse(1:length(node_map))
                vmap = node_map[m]
                nodes = vmap[nodes]
            end
        end
    return nodes
end

"""
    full_node_classification(g::Graph, maxiters::Int, thershold::Int)

Takes a graph g and classifies its nodes into the categories given in: 
[1] Nitzbon, J., Schultz, P., Heitzig, J., Kurths, J., & Hellmann, F. (2017). 
    Deciphering the imprint of topology on nonlinear dynamical network stability. 
    New Journal of Physics, 19(3), 33029. 
    https://doi.org/10.1088/1367-2630/aa6321
"""
function full_node_classification(g::Graph, maxiters::Int, threshold::Int)
    node_class = Array{Any}(nothing, nv(g))
    Leafs_per_lvl, tree_nodes, parents = nodes_and_Leafs(g, maxiters)
    sprouts = []

    # roots are the parents of tree nodes which are not in a tree themselves
    roots = copy(parents)
    deleteat!(roots, findall(x -> x ∈ tree_nodes, roots))
    node_class[roots] .= "Root"

    # real Leafs are removed at the first level
    proper_Leafs = Leafs_per_lvl[1]

    # inner tree nodes are all nodes in a tree which are not proper Leafs
    inner_tree_nodes = copy(tree_nodes)
    deleteat!(inner_tree_nodes, findall(x -> x ∈ proper_Leafs, inner_tree_nodes))
    node_class[inner_tree_nodes] .= "Inner Tree Node"

    # sprouts are proper Leafs which are adjacent to roots
    for k in proper_Leafs
        if neighbors(g, k)[1] ∈ roots
            append!(sprouts, k)
        end
    end

    filter!(x -> x ∉ sprouts, proper_Leafs) # remove sprouts from the Leafs vec
    node_class[proper_Leafs] .= "Proper Leaf"

    # bulk nodes are all nodes which are neither roots nor in a tree
    bulk = collect(1:nv(g))
    deleteat!(bulk, findall(x -> x ∈ roots, bulk))
    deleteat!(bulk, findall(x -> x ∈ tree_nodes, bulk))
    node_class[bulk] .= "Bulk"

    # a sprout is dense if its root has a degree > thershold
    d_nn = neighbors_degree(g)
    for s in sprouts
        if d_nn[s][1] <= threshold
            node_class[s] = "Sparse Sprout"
        else
            node_class[s] = "Dense Sprout"
        end
    end

    return node_class
end

"""
    neighbors_degree(g::Graph)
"""
function neighbors_degree(g::Graph)
    degrees = degree(g)
    nns = map(nodes -> neighbors(g, nodes), collect(1:nv(g)))
    d_nn = map(x -> degrees[nns[x]], collect(1:nv(g)))
    return d_nn
end
