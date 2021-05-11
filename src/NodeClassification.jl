"""
    nodes_and_leaves(g::Graph, maxiter::Int)

Iterativle remove leaves (nodes with degree = 1) from a graph g.
Returns all leaves and their leaves as well as their parents/neighbors.
"""
function nodes_and_leaves(g::Graph, maxiter::Int)
    nodes_per_lvl = []
    append!(nodes_per_lvl, [collect(vertices(g))])
    node_map = [] 
    leaves_per_lvl = []
    parents = []
    tree_nodes = []
    
    for lvl in 1:maxiter
        g, vmap = induced_subgraph(g, nodes_per_lvl[lvl]) # subgraph of current lvl
        leaves = findall(degree(g) .== 1) # leaves only have one neighbour

        # end calulation if no leaves are present
        if isempty(leaves)
            break
        end

        # save vertices map to get the original node index
        append!(node_map, [vmap])

        parents_lvl = map(x -> neighbors(g, x), leaves) # save the parents of the leaves to later define roots
        append!(parents, map_to_inital_graph(node_map, vcat(parents_lvl...)))

        append!(leaves_per_lvl, [leaves]) # save all leaves
        append!(tree_nodes, map_to_inital_graph(node_map, leaves)) # all leaves are part of a tree

        remaing_nodes = collect(vertices(g))
        deleteat!(remaing_nodes, leaves) # remove leaves from nodes list for the next level
        append!(nodes_per_lvl, [remaing_nodes])
    end
    return leaves_per_lvl, tree_nodes, parents
end

"""
    map_to_inital_graph(node_map, nodes)

Nodes are vertices from an induced subgraph. 
This function return the indicies of the original graph of nodes.
"""
function map_to_inital_graph(node_map, nodes)
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
    full_node_classification(g::Graph, maxiter::Int, thershold::Int)

Takes a graph g and classifies its nodes into the categories given in: 
[1] Nitzbon, J., Schultz, P., Heitzig, J., Kurths, J., & Hellmann, F. (2017). 
    Deciphering the imprint of topology on nonlinear dynamical network stability. 
    New Journal of Physics, 19(3), 33029. 
    https://doi.org/10.1088/1367-2630/aa6321
"""
function full_node_classification(g::Graph, maxiter::Int, thershold::Int)
    node_class = Array{Any}(nothing, nv(g))
    leaves_per_lvl, tree_nodes, parents = nodes_and_leaves(g, maxiter)
    sprouts = []

    # roots are the parents of tree nodes which are not in a tree themselfs
    roots = copy(parents)
    deleteat!(roots, findall(x -> x ∈ tree_nodes, roots))
    node_class[roots] .= "Root"

    # real leaves are removed at the first level
    proper_leaves = leaves_per_lvl[1]

    # inner tree nodes are all nodes in a tree which are not proper leaves
    inner_tree_nodes = copy(tree_nodes)
    deleteat!(inner_tree_nodes, findall(x -> x ∈ proper_leaves, inner_tree_nodes))
    node_class[inner_tree_nodes] .= "Inner Tree Node"

    # sprouts are proper leaves which are adjectent to roots
    for k in proper_leaves
        if neighbors(g, k)[1] ∈ roots
            append!(sprouts, k)
        end
    end

    filter!(x -> x ∉ sprouts, proper_leaves) # remove sprouts from the leaves vec
    node_class[proper_leaves] .= "Proper Leave"

    # bulk nodes are all nodes which are neigher roots nor in a tree
    bulk = collect(1:nv(g))
    deleteat!(bulk, findall(x -> x ∈ roots, bulk))
    deleteat!(bulk, findall(x -> x ∈ tree_nodes, bulk))
    node_class[bulk] .= "Bulk"

    # a sprout is dense if its root has a degree > thershold
    d_nn = neighbours_degree(g)
    for s in sprouts
        if d_nn[s][1] <= thershold
            node_class[s] = "Sparse Sprout"
        else
            node_class[s] = "Dense Sprout"
        end
    end

    return node_class
end

"""
    neighbours_degree(g::Graph)
"""
function neighbours_degree(g::Graph)
    degrees = degree(g)
    nns = map(nodes -> neighbors(g, nodes), collect(1:nv(g)))
    d_nn = map(x -> degrees[nns[x]], collect(1:nv(g)))
    return d_nn
end